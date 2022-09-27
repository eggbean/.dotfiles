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

syntax on
set nrformats-=octal
set complete-=i
set nonumber
set numberwidth=4
set norelativenumber
set signcolumn=auto
set incsearch
set nolangremap
let &nrformats="bin,hex"
set showcmd
set ruler
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
set updatetime=4000
set cdpath=,.,~/src,~/
set complete=.,w,b,u,t
set cscopeverbose

set ttimeout
set ttimeoutlen=100
set laststatus=2
set display+=lastline
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
set mousemodel=popup
set hidden
set backup
set writebackup
set swapfile
set undofile
set shortmess+=F

if has('unnamedplus')
  set clipboard+=unnamedplus
else
  set clipboard+=unnamed
endif

if has('nvim')
  set noshowmode
else
  set showmode
endif

if !empty(&viminfo)
  set viminfo^=!
endif

" Fix for tmux
if exists('$TERM=tmux-256color')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

if has('termguicolors')
  set termguicolors
endif

" Toggle colorcolumn
nnoremap <silent> <F2> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
vnoremap <silent> <F2> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>

" Toggle line numbers
nnoremap <silent> <F3> :set number!<CR>
inoremap <silent> <F3> :set number!<CR>
vnoremap <silent> <F3> :set number!<CR>
nnoremap <silent> <F4> :set relativenumber!<CR>
inoremap <silent> <F4> :set relativenumber!<CR>
vnoremap <silent> <F4> :set relativenumber!<CR>

" Toggle spell-checking
nnoremap <silent> <F7> :set spell!<CR>
vnoremap <silent> <F7> :set spell!<CR>

" Remap Y to be consistent with nvim
nnoremap Y y$

" Write after forgetting sudo
cnoremap w!! w !sudo tee % >/dev/null

" Move lines with Alt+Shift+j/k
if has('unix')
  nnoremap J :m .+1<CR>==
  nnoremap K :m .-2<CR>==
  inoremap J <Esc>:m .+1<CR>==gi
  inoremap K <Esc>:m .-2<CR>==gi
  vnoremap J :m '>+1<CR>gv=gv
  vnoremap K :m '<-2<CR>gv=gv
elseif has('win32')
  nnoremap <M-S-j> :m .+1<CR>==
  nnoremap <M-S-k> :m .-2<CR>==
  inoremap <M-S-j> <Esc>:m .+1<CR>==gi
  inoremap <M-S-k> <Esc>:m .-2<CR>==gi
  vnoremap <M-S-j> :m '>+1<CR>gv=gv
  vnoremap <M-S-k> :m '<-2<CR>gv=gv
endif

" Open files using xdg-open
nnoremap gX :silent :execute
  \ "!xdg-open" expand('%:p:h') . "/" . expand("<cfile>") " &"<CR>

" Scroll splits together one line
let g:scrollLock = 0
command! ToggleScrollLock let g:scrollLock = !g:scrollLock
nnoremap <silent> <F11> :ToggleScrollLock<CR>
nnoremap <expr> <C-e> (g:scrollLock == 1) ? ':windo set scrollbind<CR><C-e>:windo set noscrollbind<CR>' : '<C-e>'
nnoremap <expr> <C-y> (g:scrollLock == 1) ? ':windo set scrollbind<CR><C-y>:windo set noscrollbind<CR>' : '<C-y>'
" nnoremap <C-S-E> :windo set scrollbind<CR><C-e>:windo set noscrollbind<CR>
" nnoremap <C-S-Y> :windo set scrollbind<CR><C-y>:windo set noscrollbind<CR>

" Exit terminal mode with ESC
tnoremap <Esc> <C-\><C-n>

" Clear registers (temporarily)
command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor

" Set dictionary and regenerate spl files on startup
set spelllang=en_gb
if has('unix')
  set dictionary+=/usr/share/dict/words
  set spellfile=$HOME/.config/vim/spell/en.utf-8.add
elseif has('win32')
  set spellfile=$HOME/vimfiles/spell/en.utf-8.add
endif
for d in glob('spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor

" Highlight syntax within Markdown
let g:markdown_fenced_languages = ['html', 'css', 'python', 'sh', 'vim']
