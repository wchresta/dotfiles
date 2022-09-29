{ pkgs, lib, ... }:

let
  localLib = pkgs.callPackage ../lib.nix {};
in {
  imports = [
    ../includes/wireplumber.nix
  ];

  home = {
    file = localLib.makeScripts {
      connect_speaker = ''
        bluetoothctl power on
        bluetoothctl connect 00:0C:8A:E9:18:77
      '';

      connect_headset = ''
        bluetoothctl power on
        bluetoothctl connect 38:18:4C:19:F0:59
      '';
    };

    packages = let
      myPythonPkgs = ppkgs: with ppkgs; [
        ipykernel
        pycrypto
      ];
      myPython = pkgs.python3.withPackages myPythonPkgs;
    in
    with pkgs; [
      xorg.xprop
      xorg.xev
      xss-lock
      bind
      brightnessctl
      pulsemixer

      vlc

      i3lock-fancy

      wpa_supplicant_gui

      # User programs
      awscli
      idris
      unzip
      arandr
      pavucontrol
      ripgrep
      zip
      usbutils
      qbittorrent

      # games
      steam
      openttd

      file
      # gdb
      # ddd
      # radare2
      # radare2-cutter

      gnome3.nautilus
      gnome3.gnome-disk-utility
      gnome3.gnome-keyring
      glirc

      s3fs
      borgbackup

      # evince
      # gimp-with-plugins

      # chessx
      # gnuchess
      # xboard
      # stockfish

      # dwarf-fortress-packages.dwarf-fortress-full

      vscode
      myPython
      gcc
      gnumake

      # go
      go
      gopls
      go-check
      go-outline
      go-protobuf
      go-tools
    ];
  };

  programs.i3status.modules = {
    "wireless _first_" = {
      position = 3;
      settings = {
        format_up = "W: (%quality at %essid) %ip";
        format_down = "W: down";
      };
    };

    "battery 0" = {
      position = 2;
      settings = {
        format = "%status %percentage %remaining %emptytime";
        format_down = "No battery";
        status_chr = "⚡ CHR";
        status_bat = "🔋 BAT";
        status_unk = "? UNK";
        status_full = "☻ FULL";
        path = "/sys/class/power_supply/BAT%d/uevent";
        low_threshold = 15;
      };
    };

    "ethernet _first_".enable = false;
  };


  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = "~/.ssh/id_github";
      };

      "terminus" = {
        user = "brachiel";
        hostname = "terminus";
        port = 144;
        identityFile = "~/.ssh/id_terminus";
      };
    };
  };

  # We use xidlehook instead of xautolock, so we roll our own services
  systemd.user.services = {
    xss-lock = {
      Unit = {
        Description = "xss-lock, session locker service";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = lib.concatStringsSep " "
        [
          "${pkgs.xss-lock}/bin/xss-lock"
          "-s \${XDG_SESSION_ID}"
          "-- ${pkgs.i3lock-fancy}/bin/i3lock-fancy -n -g -p"
        ];
      };
    };

    xidlehook-session = {
      Unit = {
        Description = "xidlehook, session locker service";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.xidlehook}/bin/xidlehook"
          "--not-when-fullscreen"
          "--timer 600 '${pkgs.systemd}/bin/loginctl lock-session \${XDG_SESSION_ID}' ''"
        ];
      };
    };
  };


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

  # This seems broken in 22.05 / home-manager atm
  services.blueman-applet.enable = false;
}
