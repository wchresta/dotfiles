{ pkgs, lib, ... }:

let
  localLib = pkgs.callPackage ../lib.nix {};

  davinci-resolve-19 = with pkgs; davinci-resolve.override (prev: rec {
    inherit (prev) pname;
    version = "19.0.2";

    src = runCommandLocal "${pname}-src.zip" rec {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-dYTrO0wpIN68WhBovmYLK5uWOQ1nubpSyKqPCDMPMiM=";

        impureEnvVars = lib.fetchers.proxyImpureEnvVars;

        nativeBuildInputs = [ curl jq ];
        # ENV VARS
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
        # Get linux.downloadId from HTTP response on https://www.blackmagicdesign.com/products/davinciresolve
        REFERID = "263d62f31cbb49e0868005059abcb0c9";
        DOWNLOADSURL = "https://www.blackmagicdesign.com/api/support/us/downloads.json";
        SITEURL = "https://www.blackmagicdesign.com/api/register/us/download";
        PRODUCT = "DaVinci Resolve";
        VERSION = version;
        USERAGENT = builtins.concatStringsSep " " [
          "User-Agent: Mozilla/5.0 (X11; Linux ${stdenv.hostPlatform.linuxArch})"
          "AppleWebKit/537.36 (KHTML, like Gecko)"
          "Chrome/77.0.3865.75"
          "Safari/537.36"
        ];
        REQJSON = builtins.toJSON {
          "firstname" = "NixOS";
          "lastname" = "Linux";
          "email" = "someone@nixos.org";
          "phone" = "+31 71 452 5670";
          "country" = "nl";
          "street" = "-";
          "state" = "Province of Utrecht";
          "city" = "Utrecht";
          "product" = PRODUCT;
        };
      } ''
      DOWNLOADID=$(
        curl --silent --compressed "$DOWNLOADSURL" \
          | jq --raw-output '.downloads[] | .urls.Linux?[]? | select(.downloadTitle | test("^'"$PRODUCT $VERSION"'( Update)?$")) | .downloadId'
      )
      echo "downloadid is $DOWNLOADID"
      test -n "$DOWNLOADID"
      RESOLVEURL=$(curl \
        --silent \
        --header 'Host: www.blackmagicdesign.com' \
        --header 'Accept: application/json, text/plain, */*' \
        --header 'Origin: https://www.blackmagicdesign.com' \
        --header "$USERAGENT" \
        --header 'Content-Type: application/json;charset=UTF-8' \
        --header "Referer: https://www.blackmagicdesign.com/support/download/$REFERID/Linux" \
        --header 'Accept-Encoding: gzip, deflate, br' \
        --header 'Accept-Language: en-US,en;q=0.9' \
        --header 'Authority: www.blackmagicdesign.com' \
        --header 'Cookie: _ga=GA1.2.1849503966.1518103294; _gid=GA1.2.953840595.1518103294' \
        --data-ascii "$REQJSON" \
        --compressed \
        "$SITEURL/$DOWNLOADID")
      echo "resolveurl is $RESOLVEURL"
      curl \
        --retry 3 --retry-delay 3 \
        --header "Upgrade-Insecure-Requests: 1" \
        --header "$USERAGENT" \
        --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" \
        --header "Accept-Language: en-US,en;q=0.9" \
        --compressed \
        "$RESOLVEURL" \
        > $out
    '';
  });
in {
  imports = [
      ../includes/wireplumber.nix
  ];

  home = {
    file = localLib.makeScripts {
      rise-of-industry = ''
        cd "$HOME/Games/Rise of Industry/"
        steam-run ./start.sh
      '';

      thumbs-swap = ''
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keycode 22 = space"
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keycode 65 = BackSpace"
      '';

      thumbs-reset = ''
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keycode 22 = BackSpace"
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keycode 65 = space"
      '';

      with-thumbs-swapped = ''
        thumbs-swap
        "$@"
        thumbs-reset
      '';
    };

    keyboard.layout = "us";

    packages = with pkgs; [
      ripgrep
      pavucontrol
      pulseaudio  # for pactl
      # https://github.com/lutris/lutris/issues/3965#issuecomment-1100904672
      (writeShellScriptBin "lutris" ''
          env WEBKIT_DISABLE_COMPOSITING_MODE=1 ${lutris}/bin/lutris "$@"
      '')
      wineWowPackages.stable
      mono
      winetricks
      protontricks
      fceux # emulator
      # glirc  # broken

      vlc

      # games
      # polymc # marked unsafe
      mangohud # display vulkan stats
      openttd
      prismlauncher # minecraft

      clonehero

      davinci-resolve-19
      godot_4
      # godot4-mono does not work atm
      # See also https://github.com/NixOS/nixpkgs/pull/285941
      # (pkgs.callPackage ../pkgs/godot4-mono {})
    ];
  };

  /*
  systemd.user.services.choose-hdmi-mode = {
    Unit = {
      Description = "Set preferred hdmi output mode";
    };

    Service = {
      Type = "simple";
      # Choose main screen's HDMI output as the default NVIDIA output (HDMI 3)
      ExecStart = "${pkgs.pulseaudio}/bin/pactl set-card-profile alsa_card.pci-0000_07_00.1 output:hdmi-stereo-extra2";
      Restart="on-failure";
    };

    Install = {
      WantedBy = [ "sound.target" ];
      After = [ "pulseaudio.service" ];
    };
  };
  */

  services.wireplumber = {
    config.enable = false;
    config.extraLuaConfig = ''
      rule = {
        matches = {
          {
            { "device.name", "equals", "alsa_card.pci-0000_07_00.1" },
          },
        },
        apply_properties = {
          ["device.profile"] = "hdmi-stereo-extra2";
        }
      }
      table.insert(alsa_monitor.rules, rule)
    '';
  };

  programs.ssh.matchBlocks = {
    "github.com" = {
      user = "git";
      identityFile = "~/.ssh/id_github_wchresta";
    };

    "gitlab.com" = {
      user = "git";
      identityFile = "~/.ssh/id_github_wchresta";
    };

    "github-wchresta" = {
      user = "git";
      hostname = "github.com";
      identityFile = "~/.ssh/id_github_wchresta";
    };

    "github-brachiel" = {
      user = "git";
      hostname = "github.com";
      identityFile = "~/.ssh/id_github_brachiel";
    };

    "terminus" = {
      user = "brachiel";
      hostname = "terminus.chresta-willi.ch";
      port = 144;
      identityFile = "~/.ssh/id_terminus";
    };

    "comonoid" = {
      hostname = "comonoid.fritz.box";
      user = "monoid";
      identityFile = "~/.ssh/id_comonoid";
    };

    "source.developers.google.com" = {
      identityFile = "~/.ssh/id_dev_google";
    };

    "basemoid" = {
      user = "root";
      identityFile = "~/.ssh/id_basemoid";
      port = 144;
    };
  };
}
