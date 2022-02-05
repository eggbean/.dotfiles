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
set noignorecase
set nosmartcase
set wrap
set splitright
set splitbelow
set scrolloff=1
set showmode
set updatetime=4000

set clipboard=unnamed
set encoding=utf-8
scriptencoding utf-8
set spellfile=~/.vim/spell/en.utf-8.add
set autoread
set nowrapscan
set title
set listchars=tab:▸-
set mouse=a
set hidden

" Write when forgetting sudo
cmap w!! w !sudo tee % >/dev/null

" Move lines
nnoremap <A-S-j> :m .+1<CR>==
nnoremap <A-S-k> :m .-2<CR>==
inoremap <A-S-j> <Esc>:m .+1<CR>==gi
inoremap <A-S-k> <Esc>:m .-2<CR>==gi
vnoremap <A-S-j> :m '>+1<CR>gv=gv
vnoremap <A-S-k> :m '<-2<CR>gv=gv

" Emacs-style editing on the command-line:
cnoremap <C-D> <Del>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <C-k> <C-\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>

" Zoom in and out of splits
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" Exit terminal mode with ESC
tnoremap <Esc> <C-\><C-n>
