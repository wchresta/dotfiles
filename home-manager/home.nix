{ config, lib, pkgs, ... }:

#let
#  windowManager = pkgs.callPackage ./home-manager/windowManager.nix { inherit light-control; };
#in windowManager //
{
  imports =
    [
      includes/kitty.nix
      includes/vim.nix
      includes/firefox.nix
      includes/development.nix
      includes/windowManager.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "monoid";
  home.homeDirectory = "/home/monoid";

  home.keyboard = {
    layout = "ch";
  };

  home.sessionPath = [ ".local/bin" ];

  home.packages = with pkgs; [
    ripgrep
    pavucontrol
    pulseaudio  # for pactl
    lutris
    fceux # emulator
    glirc
  ];

  gtk = {
    enable = false;
    theme = {
      package = pkgs.gnome.gnome_themes_standard;
      name = "Adwaita-Dark";
    };
  };

  home.file = {
    ".local/bin/rise-of-industry" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        cd "$HOME/Games/Rise of Industry/"
        steam-run ./start.sh
      '';
    };
  };

  programs.bash = {
    enable = true;

    initExtra = ''
      PROMPT_COLOR="0;34m"
      export PS1="\[\033[$PROMPT_COLOR\]\[\e]0;\u@\h: \w\a\]\u:\w\\$\[\033[0m\] "
    '';
    
    shellAliases = {
      ehome = ''
        ${pkgs.neovim}/bin/nvim -O ~/src/dotconf/home-manager/home.nix ~/src/dotconf/home-manager/includes && \
        ${pkgs.git}/bin/git -C ~/src/dotconf/home-manager commit -a -m "Changes by monoid" && \
        sudo nixos-rebuild switch --update-input monoid-home
      '';
      enix = ''
        sudo -E ${pkgs.neovim}/bin/nvim -O /etc/nixos/configuration.nix /etc/nixos/includes/ && \
        sudo rebuildAndCommitSystem
      '';
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = false;
}

# vim: set sw=2 expandtabs=2 tabstop=2
