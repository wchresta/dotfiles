{ pkgs, ... }:

let
  localLib = pkgs.callPackage ../lib.nix {};
in {
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
    ];
  };
}
