{ pkgs, ... }:

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
    };

    keyboard.layout = "us";

    packages = with pkgs; [
      ripgrep
      pavucontrol
      pulseaudio  # for pactl
      lutris
      fceux # emulator
      glirc

      vlc

      # games
      polymc
      openttd
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
}
