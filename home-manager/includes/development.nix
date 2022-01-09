{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghc

    # Go and editor support
    go
    gopls
    go-outline
    goimports
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

      pull = {
        rebase = true;
      };
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
    ];
  };
}
