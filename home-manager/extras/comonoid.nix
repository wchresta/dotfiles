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

  services.xidlehook = {
    enable = true;
    # detect-sleep = true;  # Not yet in stable
    not-when-fullscreen = true;
    not-when-audio = false;
    timers = [{
      delay = 300;
      command = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -n -g -p";
    }];
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

  programs.autorandr = {
    enable = true;
    profiles.laptop = {
      fingerprint = {
        eDP1 = "00ffffffffffff0006af2d5b00000000001c0104a51d107803ee95a3544c99260f505400000001010101010101010101010101010101b43780a070383e403a2a350025a21000001a902c80a070383e403a2a350025a21000001a000000fe003036564736814231333348414e0000000000024122a8011100000a010a202000f0";
      };
      config = {
        eDP1 = {
          enable = true;
          primary = true;
        };
      };
    };
  };

  # This seems broken in 22.05 / home-manager atm
  services.blueman-applet.enable = false;
}
