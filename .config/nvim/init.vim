set autoindent
set expandtab
set incsearch
set magic
set mouse=a
set smartcase
set smartindent
set smarttab
set softtabstop=4
set wildignore+=*\\tmp\\*,*.swp,*.swo,*.zip,.git,.cabal-sandbox
set wildmenu
set wildmode=longest,list,full

set shiftwidth=4
set colorcolumn=80
set number relativenumber
set spelllang=en_gb

au FileType html set sw=2 spell
au FileType markdown set spell
au FileType typescript set sw=2

au FileType haskell nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
au FileType haskell nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
au FileType haskell nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>

au FileType python set tabstop=4 softtabstop=4 sw=4 textwidth=79 expandtab ai

let mapleader=","
inoremap <C-S> <ESC>:w<CR>i
nnoremap <C-S> :w<CR>
nnoremap <leader>$ :%s/ \+$//<CR>
nnoremap <leader>r :source ~/.config/nvim/init.vim<CR>
nnoremap <leader>ve :split ~/.config/nvim/init.vim<CR>G?^[a-z]\?map<CR>
nnoremap <leader>va :w<CR>:source %<CR>:q<CR>
inoremap <leader>: <ESC>?^[^ ]\+ \+:: \+?e<CR><ESC>:noh<CR>a
nnoremap <leader>: ?^[^ ]\+ \+:: \+?e<CR><ESC>:noh<CR>a
inoremap <leader>@ <ESC>yiw$a = fromInteger $ natVal @<ESC>pa Proxy<CR>
nnoremap <leader>@ yiw$a = fromInteger $ natVal @<ESC>pa Proxy<CR>
vnoremap <leader>m cMaybe ()<ESC>P
"nnoremap <leader>d :s/\m::\( \+\)\([^>]\<Bar>\n\)\+> \+/::\1/<CR>
nnoremap <leader>d /::/e<CR>ld$J3x


