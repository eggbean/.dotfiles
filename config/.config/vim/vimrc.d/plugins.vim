" PLUGINS

call plug#begin('$XDG_DATA_HOME/vim/plugged')
  Plug 'tpope/vim-commentary'
  Plug 'machakann/vim-sandwich'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'chrisbra/matchit'
  Plug 'junegunn/fzf'
  Plug 'airblade/vim-gitgutter'
  Plug 'ntpeters/vim-better-whitespace'
  Plug 'MattesGroeger/vim-bookmarks'
  Plug 'AndrewRadev/switch.vim'
  Plug 'gerazov/vim-toggle-bool'
  Plug 'tmux-plugins/vim-tmux'
  Plug 'mattn/vim-gist'
  " TESTING ...
  Plug 'SirVer/ultisnips'
  Plug 'chrisbra/Recover.vim'
  Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'dhruvasagar/vim-zoom'
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
  if has('nvim')
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'EdenEast/nightfox.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'romgrk/barbar.nvim'
    Plug 'folke/which-key.nvim'
  endif
call plug#end()
