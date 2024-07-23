{ config, lib, pkgs, ... }:

{
  imports =
    [
      includes/browser.nix
      includes/development.nix
      includes/initscripts.nix
      includes/kitty.nix
      includes/latex.nix
      includes/monoids.nix
      includes/shell.nix
      includes/vim.nix
      includes/windowManager.nix
    ];

  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "monoid";
    homeDirectory = "/home/monoid";

    sessionPath = [ "~/.local/bin" ];
    sessionVariables = { EDITOR = "nvim"; };

    packages = with pkgs; [
      zip
      unzip
      gnome.file-roller
      gnome.nautilus
      gtypist
      file

      qbittorrent
      baobab  # disk space visualization
      jellyfin-media-player

      gnome.seahorse # keyring UI

      # https://github.com/nix-community/home-manager/issues/3113
      dconf  # For gnome settigs to work

      evince
      gimp

      # Read mail
      thunderbird

      # dns stuff
      dig
    ];
  };

  gtk = {
    enable = false;
    theme = {
      package = pkgs.gnome.gnome_themes_standard;
      name = "Adwaita:dark";
    };
    iconTheme = {
      package = pkgs.gnome.gnome_themes_standard;
      name = "Adwaita:dark";
    };
  };

  xdg.enable = true;

  programs.chromium = {
    enable = true;
  };

  # Enable keyring
  services.gnome-keyring.enable = true;

  # Custom modules
  monoid = {
    windowManager.enable = true;
    windowManager.compositor = "i3";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = false;
}

# vim: set sw=2 expandtabs=2 tabstop=2
