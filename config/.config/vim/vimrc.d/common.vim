" COMMON CONFIGURATION

" Indentation
set tabstop=4 shiftwidth=4 shiftround softtabstop=2 autoindent expandtab list smartindent
set backspace=indent,eol,start
set smarttab

set nrformats-=octal
set complete-=i
set nonumber
set numberwidth=4
" set relativenumber
" set signcolumn=auto
" set nu
set incsearch
set hlsearch
set ignorecase
set smartcase
set autochdir
set wildmenu wildmode=list:longest,full
set splitright
set splitbelow
set lazyredraw
set magic
set scrolloff=3
set showmode
set updatetime=4000
" set colorcolumn=80

set clipboard+=unnamedplus
set encoding=utf-8
scriptencoding utf-8
set autoread
set wrap
set nowrapscan
set history=500
set title
set listchars=tab:▸-
set mouse=a
set hidden
set backup
set writebackup
set swapfile
set undofile
set shortmess+=F

if has('termguicolors')
  set termguicolors
endif

" Write when forgetting sudo
cmap w!! w !sudo tee % >/dev/null

" Move lines
nnoremap <A-S-j> :m .+1<CR>==
nnoremap <A-S-k> :m .-2<CR>==
inoremap <A-S-j> <Esc>:m .+1<CR>==gi
inoremap <A-S-k> <Esc>:m .-2<CR>==gi
vnoremap <A-S-j> :m '>+1<CR>gv=gv
vnoremap <A-S-k> :m '<-2<CR>gv=gv

" Scroll splits together one line
let g:scrollLock = 0
command! ToggleScrollLock let g:scrollLock = !g:scrollLock
nnoremap <silent> <F11> :ToggleScrollLock<CR>
nnoremap <expr> <C-e> (g:scrollLock == 1) ? ':windo set scrollbind<CR><C-e>:windo set noscrollbind<CR>' : '<C-e>'
nnoremap <expr> <C-y> (g:scrollLock == 1) ? ':windo set scrollbind<CR><C-y>:windo set noscrollbind<CR>' : '<C-y>'
" nnoremap <C-S-E> :windo set scrollbind<CR><C-e>:windo set noscrollbind<CR>
" nnoremap <C-S-Y> :windo set scrollbind<CR><C-y>:windo set noscrollbind<CR>

" Emacs mappings in insert mode
inoremap <A-b> <C-Left>
inoremap <A-f> <C-Right>
inoremap <A-d> <space><esc>ce

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
cnoremap <M-BS> <C-w>
cnoremap <C-k> <C-\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>

" Zoom in and out of splits
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" Exit terminal mode with ESC
tnoremap <Esc> <C-\><C-n>

" Open files using xdg-open
nnoremap gX :silent :execute
	\ "!xdg-open" expand('%:p:h') . "/" . expand("<cfile>") " &"<cr>

" Clear registers
command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor
