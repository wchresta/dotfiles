{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghc
    go
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
