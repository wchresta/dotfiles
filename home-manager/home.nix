{ config, lib, pkgs, ... }:

let
  localLib = pkgs.callPackage ./lib.nix {};

  shellAliases = let
      ehome-cmd = file: ''
        ${pkgs.neovim}/bin/nvim ~/src/dotfiles/home-manager/${file} && \
          ${pkgs.git}/bin/git -C ~/src/dotfiles/home-manager/${file} add ~/src/dotfiles/home-manager/${file} && \
          sudo nixos-rebuild switch --update-input monoid-home --update-input light-control && \
          ${pkgs.git}/bin/git -C ~/src/dotfiles/home-manager commit
      '';
    in {
      ls = "ls --color=auto";
      l = "ls -alh";
      ll = "ls -lh";
      la = "ls -a";

      ehome = ehome-cmd "";
      evim = ehome-cmd "includes/vim.nix";

      enix = ''
        sudo -E ${pkgs.neovim}/bin/nvim /etc/nixos/ && \
          sudo -E ${pkgs.git}/bin/git -C /etc/nixos add /etc/nixos && \
          sudo /run/current-system/sw/bin/nixos-rebuild switch && \
          sudo -E ${pkgs.git}/bin/git -C /etc/nixos commit
      '';
    };

in {
  imports =
    [
      includes/browser.nix
      includes/development.nix
      includes/initscripts.nix
      includes/kitty.nix
      includes/latex.nix
      includes/monoids.nix
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

    sessionPath = [ ".local/bin" ];
    sessionVariables = { EDITOR = "nvim"; };

    packages = with pkgs; [
      zip
      unzip
      gnome.file-roller
      gnome.nautilus
      gtypist

      baobab  # disk space visualization
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

  programs.chromium = {
    enable = true;
  };

  programs.powerline-go = {
    enable = true;
    modules = [ "host" "ssh" "cwd" "nix-shell" "gitlite" "exit" ];
    # Soon this is supported:
    # modulesRight = [ "git" "goenv" "venv" ];
    settings = {
      hostname-only-if-ssh = true;
      cwd-max-depth = 4;
      theme = "gruvbox";
      numeric-exit-codes = true;
    };
  };

  programs.zsh = {
    inherit shellAliases;
    enable = true;
    enableSyntaxHighlighting = true;

    defaultKeymap = "viins";
    initExtra = ''
      # Enable shift-tab reverse completion
      bindkey '^[[Z' reverse-menu-complete
    '';
  };

  programs.bash = {
    inherit shellAliases;
    enable = true;
  };

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
