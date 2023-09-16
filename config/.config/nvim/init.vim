" NVIM CONFIGURATION

" Change xdg directories locations to vim
" and use shared vim configuration
" before reading lua config.
if has('unix')
  let $VIMFILES = "$HOME/.config/vim"
elseif has('win32')
  let $VIMFILES = "$HOME/vimfiles"
endif
source $VIMFILES/vimrc.d/xdg.vim        " Add XDG directories to vim and share with nvim
source $VIMFILES/vimrc.d/opts.vim       " Setting options
source $VIMFILES/vimrc.d/mappings.vim   " Key mappings
source $VIMFILES/vimrc.d/autocmds.vim   " Auto commands dependent on filetype
source $VIMFILES/vimrc.d/plugins.vim    " Plugins and plugin configuration

" Highlighted yanking
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=750}

" Source lua configuration
lua require('config')
