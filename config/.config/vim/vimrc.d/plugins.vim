" PLUGINS

if has('unix') | call plug#begin('$XDG_DATA_HOME/vim/plugged')
elseif has('win32') | call plug#begin() | endif
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rsi'
  Plug 'machakann/vim-sandwich'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'junegunn/fzf'
  Plug 'SirVer/ultisnips'
  Plug 'ntpeters/vim-better-whitespace'
  Plug 'airblade/vim-gitgutter'
  Plug 'MattesGroeger/vim-bookmarks'
  Plug 'AndrewRadev/switch.vim'
  Plug 'gerazov/vim-toggle-bool'
  Plug 'chrisbra/matchit'
  Plug 'chrisbra/Recover.vim'
  Plug 'dhruvasagar/vim-zoom'
  " TESTING ...
  Plug 'honza/vim-snippets'
  Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'ap/vim-css-color'
  " Plug 'frazrepo/vim-rainbow'
  " Plug 'sheerun/vim-polyglot'
  " Plug 'mattn/emmet-vim'
  " Plug 'dense-analysis/ale'
  " Plug 'arp242/jumpy.vim'
  " Plug 'jeffkreeftmeijer/vim-numbertoggle'
  " Plug 'pearofducks/ansible-vim'
  " Plug 'hashivim/vim-terraform'
  " Plug 'juliosueiras/vim-terraform-completion'
  " Plug 'tmux-plugins/vim-tmux'
  if has('nvim')
    Plug 'EdenEast/nightfox.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'romgrk/barbar.nvim'
  endif
call plug#end()
