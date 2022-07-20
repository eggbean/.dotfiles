" PLUGINS

call plug#begin('$XDG_DATA_HOME/vim/plugged')
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-commentary'
  Plug 'airblade/vim-gitgutter'
  Plug 'machakann/vim-sandwich'
  Plug 'ntpeters/vim-better-whitespace'
  Plug 'AndrewRadev/switch.vim'
  Plug 'eggbean/vim-toggle-bool', { 'branch': 'new-bools' }
  Plug 'eggbean/vim-tmux-navigator-no-wrapping'
  Plug 'MattesGroeger/vim-bookmarks'
  Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
  Plug 'ctrlpvim/ctrlp.vim'
  " Plug 'sheerun/vim-polyglot'
  " Plug 'mattn/emmet-vim'
  " Plug 'dense-analysis/ale'
  Plug 'tmux-plugins/vim-tmux'
  Plug 'junegunn/fzf'
  " Plug 'jeffkreeftmeijer/vim-numbertoggle'
  " Plug 'arp242/jumpy.vim'
  Plug 'frazrepo/vim-rainbow'
  Plug 'editorconfig/editorconfig-vim'
  " Plug 'pearofducks/ansible-vim'
  " Plug 'hashivim/vim-terraform'
  " Plug 'juliosueiras/vim-terraform-completion'
  Plug 'mattn/vim-gist'
  Plug 'ap/vim-css-color'
  if has('nvim')
    Plug 'folke/which-key.nvim'
    Plug 'EdenEast/nightfox.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'romgrk/barbar.nvim'
  endif
call plug#end()
