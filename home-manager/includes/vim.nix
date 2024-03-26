{ pkgs, ... }:

let
  cmp-setup = ''
    -- https://github.com/hrsh7th/nvim-cmp
    local cmp = require 'cmp'
    local lspconfig = require 'lspconfig'

    local on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

      local opts = { noremap=true, silent=true }
      buf_set_keymap('n', ',R', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_set_keymap('n', ',c', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      buf_set_keymap('n', ',d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_set_keymap('n', ',E', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_set_keymap('n', ',k', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    end

    cmp.setup({
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
      },

      mapping = {
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item.
        ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item.

        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.close(),
      },

      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
      }, {
        { name = 'buffer' },
      })
    })

    -- Use buffer source for `/`
    cmp.setup.cmdline('/', {
      sources = {
        { name = 'buffer' }
      }
    })

    -- Use cmdline & path source for ':'
    cmp.setup.cmdline(':', {
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })

    -- Setup lspconfig.
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
  '';
in {
   programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      let mapleader=","
      let maplocalleader=","

      syntax on
      filetype plugin indent on

      set ai
      set autoindent
      set colorcolumn=80
      set expandtab
      set hlsearch
      set incsearch
      set magic
      set mouse=a
      set nu
      set shiftwidth=2
      set smartcase
      set smartindent
      set smarttab
      set softtabstop=4
      set spelllang=en_gb
      set tabstop=2
      set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
      set wildmenu
      set wildmode=longest,list,full

      au FileType html set sw=2 spell
      au FileType markdown set spell
      au FileType typescript set sw=2
      au FileType python set tabstop=4 softtabstop=4 sw=4 textwidth=79 expandtab ai

      nmap <C-n> :!nix run<CR>

      " Define extra whitespace colorscheme; this has to be BEFORE the first colorscheme
      highlight ExtraWhitespace ctermbg=yellow guibg=yellow
      autocmd ColorScheme * highlight ExtraWhitespace ctermbg=yellow guibg=yellow
      " Show trailing whitespace:
      au InsertLeave * match ExtraWhitespace /\s\+$/
      au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/

      set termguicolors
      let g:gruvbox_italic=1
      colorscheme gruvbox

      " Setup nvim-tree
      nmap <Leader>e :NvimTreeToggle<CR>
      nmap <Leader>r :NvimTreeRefresh<CR>
      nmap <Leader>f :NvimTreeFindFile<CR>
      " NvimTreeOpen, NvimTreeClose, NvimTreeFocus, NvimTreeFindFileToggle, and NvimTreeResize are also available if you need them
      lua << EOF
        require'nvim-tree'.setup {
          renderer = {
            icons = {
              show = {
                git = true,
                file = true,
                folder = true,
                folder_arrow = true,
              },
            },
          },
          sync_root_with_cwd = true,
          view = {
            adaptive_size = true,
            width = 30,
          }
        };
      EOF

      " Setup nvim-cmp
      set completeopt=menu,menuone,noselect
      lua << EOF
        ${cmp-setup}
      EOF
    '';

    plugins = with pkgs.vimPlugins; [
      gruvbox-nvim
      editorconfig-vim
      vim-surround

      # syntax
      vim-nix
      vim-go
      vim-toml

      # ide things
      nvim-web-devicons  # for file icons
      nvim-tree-lua

      # Auto completion and lsp
      nvim-lspconfig
      nvim-cmp
      cmp-buffer
      cmp-nvim-lsp
      vim-vsnip
      cmp-vsnip

      # lsp servers
      vim-lsp

      # other languages
      idris2-vim
      # ghcid
    ];
  };
}
