{ pkgs, lib, ... }:

with lib;

let
  shellAliases = let
      cfg-src = "~/src/dotfiles/home-manager";
      ehome-cmd = file: with pkgs; ''
        git -C ${cfg-src} pull --autostash && \
        nvim ${cfg-src}/${file} && \
        git -C ${cfg-src}/${file} add ${cfg-src}/${file} && \
        sudo nixos-rebuild switch --update-input monoid-home --update-input light-control && \
        git -C ${cfg-src} commit
      '';
    in {
      ls = "ls --color=auto";
      l = "ls -alh";
      ll = "ls -lh";
      la = "ls -a";

      # Ensure ssh'ed hosts understand kitty
      ssh = "kitty +kitten ssh";

      ehome = ehome-cmd "";
      evim = ehome-cmd "includes/vim.nix";

      enix = ''
        sudo -E nvim /etc/nixos/ && \
          sudo -E ${pkgs.git}/bin/git -C /etc/nixos add /etc/nixos && \
          sudo /run/current-system/sw/bin/nixos-rebuild switch && \
          sudo -E ${pkgs.git}/bin/git -C /etc/nixos commit
      '';

      ebase = ''
        sudo -E nvim /etc/nixos/basemoid && \
          basemoid-switch
      '';
    };
in {
  programs.powerline-go = {
    enable = true;
    modules = [ "host" "ssh" "cwd" "nix-shell" "exit" ];
    modulesRight = [ "git" "goenv" "venv" ];
    settings = {
      hostname-only-if-ssh = true;
      cwd-max-depth = 4;
      theme = "gruvbox";
      numeric-exit-codes = true;
    };
  };

  programs.fzf = {
    enable = true;
    # Gruvbox dark
    colors = {
      "fg" = "#ebdbb2";
      "bg" = "#282828";
      "hl" = "#fabd2f";
      "fg+" = "#ebdbb2";
      "bg+" = "#3c3836";
      "hl+" = "#fabd2f";

      "info" = "#83a598";
      "prompt" = "#bdae93";
      "spinner" = "#fabd2f";
      "pointer" = "#83a598";
      "marker" = "#fe8019";
      "header" = "#665c54";
    };
  };

  programs.zsh = {
    inherit shellAliases;
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;

    syntaxHighlighting.enable = true;

    defaultKeymap = "viins";
    initExtra = ''
      # Enable shift-tab reverse completion
      bindkey '^[[Z' reverse-menu-complete

      # Allow backspace to delete any char
      bindkey -v '^?' backward-delete-char
    '';
  };

  programs.bash = {
    inherit shellAliases;
    enable = true;
  };
}
