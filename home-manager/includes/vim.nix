{ pkgs, ... }:

{
   programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      syntax on
      filetype plugin indent on

      set tabstop=2
      set shiftwidth=2
      set ai
      set mouse=a
      set hlsearch
      let mapleader=","
      let maplocalleader=","

      set termguicolors
      let g:gruvbox_italic=1
      colorscheme gruvbox
    '';

    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-go
      gruvbox-nvim
    ];
  };
}
