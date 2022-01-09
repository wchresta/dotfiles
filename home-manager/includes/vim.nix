{ pkgs, ... }:

{
   programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      syntax on
      filetype plugin indent on

      let mapleader=","
      let maplocalleader=","

      set ai
      set autoindent
      set colorcolumn=80
      set expandtab
      set hlsearch
      set incsearch
      set magic
      set mouse=a
      set shiftwidth=2
      set spelllang=en_gb
      set smartcase
      set smartindent
      set smarttab
      set softtabstop=4
      set tabstop=2
      set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
      set wildmenu
      set wildmode=longest,list,full

      au FileType html set sw=2 spell
      au FileType markdown set spell
      au FileType typescript set sw=2
      au FileType python set tabstop=4 softtabstop=4 sw=4 textwidth=79 expandtab ai

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
