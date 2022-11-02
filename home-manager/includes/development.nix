{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # basic tools
    tree
    ghc
    cabal-install
    cabal2nix

    # Go and editor support
    go
    gopls
    go-outline
    gotools
    golint
    gopkgs
    go-check
    delve  # debugger
    go-tools
  ];

  programs.git = {
    enable = true;

    userEmail = "34962284+wchresta@users.noreply.github.com";
    userName = "wchresta";

    extraConfig = {
      core = {
        editor = "nvim";
      };

      init.defaultBranch = "main";
      format.pretty = "oneline";

      safe.directory = "/home/nioxs";

      pull = {
        rebase = true;
      };
    };
  };

  # vsliveshare needs a provider for org.freedesktop.secrets
  # services.gnome-keyring.enable = true; # Broken in 22.05
  programs.vscode = {
    enable = true;
    # Turns out, most extensions are a bit out of date
    extensions = with pkgs.vscode-extensions; [
      ms-vsliveshare.vsliveshare
      ms-python.python
      matklad.rust-analyzer
    ];
  };
}
