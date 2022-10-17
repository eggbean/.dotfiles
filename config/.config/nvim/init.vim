" NVIM CONFIGURATION

" Change xdg directories locations to vim
" and use shared vim configuration
" before reading lua config.
if has('unix')
  let $VIMFILES = "$HOME/.config/vim"
elseif has('win32')
  let $VIMFILES = "$HOME/vimfiles"
endif
source $VIMFILES/vimrc.d/xdg.vim
source $VIMFILES/vimrc.d/opts.vim
source $VIMFILES/vimrc.d/mappings.vim
source $VIMFILES/vimrc.d/autocmds.vim
source $VIMFILES/vimrc.d/plugins.vim

" Highlighted yanking
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=750}

" Source lua configuration
lua require('config')
