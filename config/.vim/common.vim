" COMMON CONFIGURATION

" Indentation
set tabstop=4 shiftwidth=4 shiftround softtabstop=2 autoindent noexpandtab list smartindent
set backspace=indent,eol,start
set smarttab

set nrformats-=octal
set complete-=i
set nonumber
set numberwidth=4
" set relativenumber
" set signcolumn=auto
set incsearch
set hlsearch
set ignorecase
set smartcase
set autochdir
set wildmenu wildmode=list:longest,full
set splitright
set splitbelow
set scrolloff=2
set showmode
set updatetime=4000
" set colorcolumn=80

set clipboard=unnamed
set encoding=utf-8
scriptencoding utf-8
set autoread
set wrap
set nowrapscan
set title
set listchars=tab:▸-
set mouse=a
set hidden
set nobackup
set writebackup
set noswapfile

" Write when forgetting sudo
cmap w!! w !sudo tee % >/dev/null

" Move lines
nnoremap <A-S-j> :m .+1<CR>==
nnoremap <A-S-k> :m .-2<CR>==
inoremap <A-S-j> <Esc>:m .+1<CR>==gi
inoremap <A-S-k> <Esc>:m .-2<CR>==gi
vnoremap <A-S-j> :m '>+1<CR>gv=gv
vnoremap <A-S-k> :m '<-2<CR>gv=gv

" Emacs mappings in insert mode
inoremap <A-d> <space><esc>ce
inoremap <C-k> <C-o>d$

" Emacs-style editing on the command-line
cnoremap <C-d> <Del>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <M-d> <S-Right><C-w>
cnoremap <C-k> <C-\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>

" Zoom in and out of splits
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" Exit terminal mode with ESC
tnoremap <Esc> <C-\><C-n>
