" VIM CONFIGURATION

syntax on
colorscheme gruvbox8_soft
set background=dark

if !has("gui_running")
  source ~/.vim/plugins.vim
endif

source ~/.vim/common.vim
