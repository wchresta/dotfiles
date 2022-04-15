{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texmaker
    texlive.combined.scheme-basic
  ];
}
