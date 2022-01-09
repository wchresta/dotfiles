{ pkgs, ... }:

let
  localLib = pkgs.callPackage ../lib.nix {};
in {
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
      steam

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

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = "~/.ssh/id_github";
      };
    };
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -n -g -p";
  };

  services.blueman-applet.enable = true;
}
