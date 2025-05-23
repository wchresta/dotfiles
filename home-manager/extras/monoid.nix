{ pkgs, lib, ... }:

let
  localLib = pkgs.callPackage ../lib.nix {};
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

      blender
      freecad
      beeref
      bambu-studio
      orca-slicer

      vlc

      # games
      # polymc # marked unsafe
      mangohud # display vulkan stats
      openttd
      prismlauncher # minecraft
      heroic # launcher for GoG, Epic etc

      clonehero

      davinci-resolve
      godot_4
      inkscape
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
