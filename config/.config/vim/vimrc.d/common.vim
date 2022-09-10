" COMMON CONFIGURATION

" Indentation
set tabstop=2
set shiftwidth=2
set shiftround
set softtabstop=2
set autoindent
set expandtab
set list
set smartindent
set smarttab
set backspace=indent,eol,start

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
set lazyredraw
set magic
set scrolloff=3
set sidescrolloff=5
set showmode
set updatetime=4000
" set colorcolumn=80

set ttimeout
set ttimeoutlen=100
set laststatus=2
set display+=lastline
set clipboard+=unnamedplus
set formatoptions+=j
set sessionoptions-=options
set viewoptions-=options
set encoding=utf-8
scriptencoding utf-8
set autoread
set wrap
set nowrapscan
set history=1000
set belloff=all
set tabpagemax=50
set title
set listchars=tab:▸-,extends:>,precedes:<,nbsp:+
set mouse=a
set hidden
set backup
set writebackup
set swapfile
set undofile
set shortmess+=F
if !empty(&viminfo)
  set viminfo^=!
endif

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

" Zoom toggle (plugin)
noremap Zz <c-w>m

" Exit terminal mode with ESC
tnoremap <Esc> <C-\><C-n>

" Open files using xdg-open
nnoremap gX :silent :execute
  \ "!xdg-open" expand('%:p:h') . "/" . expand("<cfile>") " &"<cr>

" Clear registers
command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor

" Set dictionary and regenerate spl files on startup
set dictionary+=/usr/share/dict/words
set spellfile=vimrc.d/spell/en.utf-8.add
for d in glob('vimrc.d/spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor
