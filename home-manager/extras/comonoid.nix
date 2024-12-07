{ pkgs, lib, ... }:

let
  localLib = pkgs.callPackage ../lib.nix {};
in {
  imports = [
    ../includes/wireplumber.nix
  ];

  home = {
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

      helvum
      vlc

      i3lock-fancy

      wpa_supplicant_gui

      # User programs
      awscli
      # idris
      unzip
      arandr
      pavucontrol
      ripgrep
      zip
      usbutils

      # games
      steam
      # https://github.com/lutris/lutris/issues/3965#issuecomment-1100904672
      (writeShellScriptBin "lutris" ''
          env WEBKIT_DISABLE_COMPOSITING_MODE=1 ${lutris}/bin/lutris "$@"
      '')
      wineWowPackages.stable
      winetricks
      protontricks
      prismlauncher

      godot_4

      file
      # gdb
      # ddd
      # radare2
      # radare2-cutter

      nautilus
      gnome-disk-utility
      gnome-keyring
      # glirc  # broken

      s3fs
      borgbackup

      davinci-resolve

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

  xsession.windowManager.i3.config.keybindings = {
    # Connect MOMENTUM 4
    "XF86Search" = "exec --no-startup-id ${pkgs.bluez}/bin/bluetoothctl connect 80:C3:BA:4A:A0:2A";
  };

  programs.i3status.modules = {
    "wireless _first_" = {
      position = 3;
      settings = {
        format_up = "W: (%quality at %essid, %bitrate) %ip";
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

      "monoid" = {
        user = "monoid";
        identityFile = "~/.ssh/id_monoid";
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
  };

  services.xidlehook = {
    enable = true;
    detect-sleep = true;
    not-when-fullscreen = true;
    not-when-audio = false;
    timers = [{
      delay = 300;
      command = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -n -g -p";
    }];
  };
  systemd.user.enable = true;
  systemd.user.services.pre-sleep = {
    Unit = {
      Description = "Lock before sleep";
      Before = [ "pre-sleep.service" ];
    };

    Service = {
      ExecStart = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -n -g -p";
    };

    Install = {
      WantedBy = [ "pre-sleep.service" ];
    };
  };

  systemd.user.services.screensaver-hook = {
    Unit = {
      Description = "Turns on/off screensaver depending on dbus messages";
      PartOf = [ "graphical-session.target" ];
    };

    Service = let
      inhibit = pkgs.writeScript "inhibit" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.xorg.xset}/bin/xset -dpms s off
      '';
      uninhibit = pkgs.writeScript "uninhibit" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.xorg.xset}/bin/xset +dpms s on
      '';
    in {
      ExecStart = "${pkgs.simple-dbus-hook}/bin/simple-dbus-hook --inhibit ${inhibit} --uninhibit ${uninhibit}";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
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
