" vim-plug plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'autozimu/LanguageClient-neovim', { 'commit': '103a88198604a408f7624c33472210cfafce6132', 'do': 'bash install.sh' }
Plug 'Shougo/deoplete.nvim', { 'commit': 'e5a47d4a2f0b2b6f568e708163e2354097e611c6', 'do': ':UpdateRemotePlugins' }
" NerdTree
Plug 'scrooloose/nerdtree', { 'commit': '690d061b591525890f1471c6675bcb5bdc8cdff9', 'on': 'NERDTreeToggle'}
Plug 'Xuyuanp/nerdtree-git-plugin', { 'commit': 'e1fe727127a813095854a5b063c15e955a77eafb' }
" Looks
Plug 'joshdick/onedark.vim', { 'commit': '47bec7a6196a843dad195d2666c3ac84c6e80c78' }
Plug 'chriskempson/base16-vim', { 'commit': '3be3cd82cd31acfcab9a41bad853d9c68d30478d' }
Plug 'vim-airline/vim-airline', { 'commit': 'a2fefe599378b4a493287d10501f51e224753690' }
Plug 'vim-airline/vim-airline-themes', { 'commit': '77aab8c6cf7179ddb8a05741da7e358a86b2c3ab' }
Plug 'junegunn/fzf', { 'commit': '3337be9d450cd349e99273a2d3985ceaf5f3753f', 'do': './install --bin' }
Plug 'junegunn/fzf.vim', { 'commit': 'd2a59a992a2455f609c0fde2ebd84427ea8f919a' }
Plug 'mhinz/vim-signify', { 'commit': '3b5ae37eb2b77c3ae58d60dfdc3fc30258078663' }
call plug#end()

" Change clang binary path
if has('mac')
  call deoplete#custom#var('clangx', 'clang_binary', '/usr/local/bin/clang')
else
  call deoplete#custom#var('clangx', 'clang_binary', 'clang')
endif

" Change clang options
call deoplete#custom#var('clangx', 'default_c_options', '')
call deoplete#custom#var('clangx', 'default_cpp_options', '')

filetype plugin on
syntax on
set spr
set lazyredraw
set updatetime=500
set number
set relativenumber
set list
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,nbsp:␣
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set foldmethod=indent
set foldlevel=99
set conceallevel=2
set mouse=a
let mapleader = ';'

hi Pmenu ctermfg=NONE ctermbg=238 cterm=NONE guifg=NONE guibg=#64666d gui=NONE
hi PmenuSel ctermfg=NONE ctermbg=44 cterm=NONE guifg=NONE guibg=#204a87 gui=NONE

" Set default clipboard
set clipboard=unnamedplus

" Colors
set termguicolors
let base16colorspace=256
colorscheme base16-tomorrow-night
highlight SignColumn guibg=NONE
" colorscheme onedark

" Status Bar
let g:airline_theme='deus'
let g:airline#extensions#tabline#enabled = 1
set noshowmode
set noruler
set laststatus=0
set noshowcmd
set cmdheight=1

"Deoplete
set completeopt+=noinsert
set completeopt+=noselect
set completeopt-=preview
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_camel_case = 1
imap <expr> <tab>   pumvisible() ? "\<c-n>" : "\<tab>"
imap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<tab>"
imap <expr> <cr>    pumvisible() ? deoplete#close_popup() : "\<cr>"

" NerdTree
map <C-n> :NERDTreeToggle<CR>
" open directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" close when only nerdtree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif 

" Vim Buffer switch
map <leader>n :bn<cr>
map <leader>p :bp<cr>
map <leader>d :bd<cr>  

" Language Server
let g:LanguageClient_serverCommands = {
    \ 'python': ['pyls'],
    \ 'cpp': ['ccls'],
    \ 'c': ['ccls'],
    \ 'go': ['gopls'],
    \ } 

" FZF
nnoremap <C-Space> :FZF<CR>
nnoremap <C-g> :Rg<CR>

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
