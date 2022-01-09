{ config, lib, pkgs, ... }:

let
  localLib = pkgs.callPackage ./lib.nix {};
in {
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
  home = {
    username = "monoid";
    homeDirectory = "/home/monoid";

    sessionPath = [ ".local/bin" ];
    sessionVariables = { EDITOR = "nvim"; };
  };

  gtk = {
    enable = false;
    theme = {
      package = pkgs.gnome.gnome_themes_standard;
      name = "Adwaita-Dark";
    };
  };

  programs.bash = {
    enable = true;

    initExtra = ''
      PROMPT_COLOR="0;34m"
      export PS1="\[\033[$PROMPT_COLOR\]\[\e]0;\u@\h: \w\a\]\u:\w\\$\[\033[0m\] "
    '';

    shellAliases = {
      l = "ls -alh";
      ll = "ls -lh";
      la = "ls -a";

      ehome = ''
        ${pkgs.neovim}/bin/nvim -O ~/src/dotfiles/home-manager/home.nix ~/src/dotfiles/home-manager/includes && \
          ${pkgs.git}/bin/git -C ~/src/dotfiles/home-manager commit -a -m "Home update via ehome" && \
          sudo nixos-rebuild switch --update-input monoid-home --update-input light-control'';

      enix = ''
        sudo -E ${pkgs.neovim}/bin/nvim -O /etc/nixos/configuration.nix /etc/nixos/includes/ && \
          sudo /run/current-system/sw/bin/nixos-rebuild switch && \
          sudo -E ${pkgs.git}/bin/git -C /etc/nixos commit -a -m "System update via enix"'';
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
  home.stateVersion = "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = false;
}

# vim: set sw=2 expandtabs=2 tabstop=2
