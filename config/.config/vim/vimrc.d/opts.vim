" VIM OPTIONS
"
" Some options are explicitly set to harmonise between different
" versions/platforms/gvim/vim and especially nvim.

syntax on
scriptencoding utf-8
set tabstop=4
set shiftwidth=4
set shiftround
set softtabstop=4
set autoindent
set expandtab
set list
set nosmartindent
set backspace=eol,start
set smarttab
set numberwidth=4
set hlsearch
set ignorecase
set smartcase
set autochdir
set splitright
set splitbelow
set lazyredraw
set scrolloff=3
set sidescroll=1
set sidescrolloff=5
set nostartofline
set cdpath=,.,~/,~/.config/vim
set formatoptions=jtcroqln
set autoread
set nowrapscan
set history=1000
set belloff=all
set title
set tags=./tags;,tags
set tabpagemax=10
set switchbuf=uselast
set showcmd
set shortmess=filnxtToOF
set viewoptions+=options
set sessionoptions+=options
set path=.,,
set nrformats=bin,hex
set nolangremap
set langnoremap
set nojoinspaces
set incsearch
set include=
set commentstring=
set complete=.,w,b,u,t,i,k
set define=
set display=lastline
set fillchars=
set listchars=tab:··,extends:>,precedes:<,nbsp:+
set mouse=a
set mousemodel=popup
set hidden
set backup
set writebackup
set backupcopy=yes
set swapfile
set undofile
set noshowmode
set laststatus=2
set timeoutlen=600
set wildmenu wildmode=list:longest,full
set wildoptions=tagfile
if has('nvim') || v:version > 802
  set wildoptions+=pum
endif

" Save uppercase global variables and limit oldfiles to 20
if !empty(&viminfo)
  if has('unix')
    set viminfo=!,'30,<50,s10,h
  elseif has('win32')
    set viminfo=!,'30,<50,s10,h,rA:,rB:
  endif
endif

" Fix for tmux
if exists('$TERM=tmux-256color')
  let &t_8f = "\<ESC>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<ESC>[48;2;%lu;%lu;%lum"
endif

if has('termguicolors')
  set termguicolors
endif

" Set dictionary and regenerate spl files on startup
set thesaurus=$VIMFILES/spell/mthesaur.txt
let g:tq_mthesaur_file = $VIMFILES . '/spell/mthesaur.txt'
set spelllang=en_gb
if has('unix')
  set dictionary+=/usr/share/dict/words
endif
set spellfile=$VIMFILES/spell/en.utf-8.add
for d in glob('spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor

" Language providers
if has('unix')
  let g:python3_host_prog = '/usr/bin/python3'
elseif has('win32')
  let g:python3_host_prog = (system("where python"))
endif
let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_node_provider = 0

" Set clipboard on WSL
if has('unix') && IsWSL()==1
  let g:clipboard = {
                  \   'name': 'WslClipboard',
                  \   'copy': {
                  \      '+': 'clip.exe',
                  \      '*': 'clip.exe',
                  \    },
                  \   'paste': {
                  \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                  \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                  \    },
                  \   'cache_enabled': 0,
                  \ }
endif
