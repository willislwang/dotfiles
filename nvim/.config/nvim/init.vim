" vim-plug plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }
Plug 'deoplete-plugins/deoplete-go', { 'for': 'go' }
Plug 'fatih/vim-go', { 'for': 'go' }
" NerdTree
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle'}
Plug 'Xuyuanp/nerdtree-git-plugin'
" Looks
Plug 'joshdick/onedark.vim'
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-signify'
call plug#end()

" Change clang binary path
call deoplete#custom#var('clangx', 'clang_binary', '/usr/local/bin/clang')

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
let base16colorspace=256
colorscheme base16-tomorrow
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

