{ stdenv
, lib
, cacert
, curl
, requireFile
, unzip
, appimage-run
, addDriverRunpath
, dbus
, libGLU
, xorg
, buildFHSEnv
, buildFHSEnvChroot
, bash
, writeText
, ocl-icd
, xkeyboard_config
, glib
, libarchive
, libxcrypt
, python3
, aprutil
, makeDesktopItem
, copyDesktopItems
, jq

, studioVariant ? false

, common-updater-scripts
, writeShellApplication
}:

let
  davinci = (
    stdenv.mkDerivation rec {
      pname = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      version = "19.1";

      nativeBuildInputs = [
        (appimage-run.override { buildFHSEnv = buildFHSEnvChroot; } )
        addDriverRunpath
        copyDesktopItems
        unzip
      ];

      # Pretty sure, there are missing dependencies ...
      buildInputs = [
        libGLU
        xorg.libXxf86vm
      ];

      src = requireFile {
        name = "DaVinci_Resolve_${version}_Linux.zip";
        url = "scp://basemoid/mnt/bulkstore1/resources/cache/DaVinci_Resolve_${version}_Linux.zip";
        sha256 = "1hl5xjlzgmamvjd0gfm6z2h6y20swakqy9vmkv65qrd52flmkgki";
      };

      # The unpack phase won't generate a directory
      sourceRoot = ".";

      installPhase = let
        appimageName = "DaVinci_Resolve_${lib.optionalString studioVariant "Studio_"}${version}_Linux.run";
      in ''
        runHook preInstall

        export HOME=$PWD/home
        mkdir -p $HOME

        mkdir -p $out
        test -e ${lib.escapeShellArg appimageName}
        appimage-run ${lib.escapeShellArg appimageName} -i -y -n -C $out

        mkdir -p $out/{configs,DolbyVision,easyDCP,Fairlight,GPUCache,logs,Media,"Resolve Disk Database",.crashreport,.license,.LUT}
        runHook postInstall
      '';

      dontStrip = true;

      postFixup = ''
        for program in $out/bin/*; do
          isELF "$program" || continue
          addDriverRunpath "$program"
        done

        for program in $out/libs/*; do
          isELF "$program" || continue
          if [[ "$program" != *"libcudnn_cnn_infer"* ]];then
            echo $program
            addDriverRunpath "$program"
          fi
        done
        ln -s $out/libs/libcrypto.so.1.1 $out/libs/libcrypt.so.1
      '';

      desktopItems = [
        (makeDesktopItem {
          name = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
          desktopName = "Davinci Resolve${lib.optionalString studioVariant " Studio"}";
          genericName = "Video Editor";
          exec = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
          icon = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
          comment = "Professional video editing, color, effects and audio post-processing";
          categories = [
            "AudioVideo"
            "AudioVideoEditing"
            "Video"
            "Graphics"
          ];
        })
      ];
    }
  );
in
buildFHSEnv {
  inherit (davinci) pname version;

  targetPkgs = pkgs: with pkgs; [
    alsa-lib
    aprutil
    bzip2
    davinci
    dbus
    expat
    fontconfig
    freetype
    glib
    libGL
    libGLU
    libarchive
    libcap
    librsvg
    libtool
    libuuid
    libxcrypt # provides libcrypt.so.1
    libxkbcommon
    nspr
    ocl-icd
    opencl-headers
    python3
    python3.pkgs.numpy
    udev
    xdg-utils # xdg-open needed to open URLs
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xkeyboardconfig
    zlib
  ];

  extraPreBwrapCmds = lib.optionalString studioVariant ''
    mkdir -p ~/.local/share/DaVinciResolve/license || exit 1
  '';

  extraBwrapArgs = lib.optionals studioVariant [
    "--bind \"$HOME\"/.local/share/DaVinciResolve/license ${davinci}/.license"
  ];

  runScript = "${bash}/bin/bash ${
    writeText "davinci-wrapper"
    ''
    export QT_XKB_CONFIG_ROOT="${xkeyboard_config}/share/X11/xkb"
    export QT_PLUGIN_PATH="${davinci}/libs/plugins:$QT_PLUGIN_PATH"
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib32:${davinci}/libs
    ${davinci}/bin/resolve
    ''
  }";

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
    ln -s ${davinci}/share/applications/*.desktop $out/share/applications/
    ln -s ${davinci}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve${lib.optionalString studioVariant "-studio"}.png
  '';

  passthru = {
    inherit davinci;
    updateScript = lib.getExe (writeShellApplication {
      name = "update-davinci-resolve";
      runtimeInputs = [ curl jq common-updater-scripts ];
      text = ''
        set -o errexit
        drv=pkgs/applications/video/davinci-resolve/default.nix
        currentVersion=${lib.escapeShellArg davinci.version}
        downloadsJSON="$(curl --fail --silent https://www.blackmagicdesign.com/api/support/us/downloads.json)"

        latestLinuxVersion="$(echo "$downloadsJSON" | jq '[.downloads[] | select(.urls.Linux) | .urls.Linux[] | select(.downloadTitle | test("DaVinci Resolve")) | .downloadTitle]' | grep -oP 'DaVinci Resolve \K\d+\.\d+(\.\d+)?' | sort | tail -n 1)"
        update-source-version davinci-resolve "$latestLinuxVersion" --source-key=davinci.src

        # Since the standard and studio both use the same version we need to reset it before updating studio
        sed -i -e "s/""$latestLinuxVersion""/""$currentVersion""/" "$drv"

        latestStudioLinuxVersion="$(echo "$downloadsJSON" | jq '[.downloads[] | select(.urls.Linux) | .urls.Linux[] | select(.downloadTitle | test("DaVinci Resolve")) | .downloadTitle]' | grep -oP 'DaVinci Resolve Studio \K\d+\.\d+(\.\d+)?' | sort | tail -n 1)"
        update-source-version davinci-resolve-studio "$latestStudioLinuxVersion" --source-key=davinci.src
      '';
    });
  };

  meta = with lib; {
    description = "Professional video editing, color, effects and audio post-processing";
    homepage = "https://www.blackmagicdesign.com/products/davinciresolve";
    license = licenses.unfree;
    maintainers = with maintainers; [ amarshall jshcmpbll orivej ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
  };
}
