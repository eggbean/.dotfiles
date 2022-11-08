" VIM OPTIONS

" Indentation
set tabstop=4
set shiftwidth=4
set shiftround
set softtabstop=4
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
set noshowmode
set clipboard=unnamed

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

" Set dictionary and regenerate spl files on startup
set spelllang=en_gb
set thesaurus=$VIMFILES/spell/mthesaur.txt
if has('unix')
  set dictionary+=/usr/share/dict/words
  set spellfile=$HOME/.config/vim/spell/en.utf-8.add
  let g:tq_mthesaur_file="~/.config/vim/spell/mthesaur.txt"
elseif has('win32')
  set spellfile=$HOME/vimfiles/spell/en.utf-8.add
  let g:tq_mthesaur_file="~/vimfiles/spell/mthesaur.txt"
endif
for d in glob('spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor

" Language Providers
if has('unix')
  let g:python3_host_prog = '/usr/bin/python3'
elseif has('win32')
  let g:python3_host_prog = (system("where python"))
endif
let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_node_provider = 0
