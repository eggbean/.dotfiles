" NVIM CONFIGURATION

if has('unix')
  let $VIM = "$HOME/.config/vim"
elseif has('win32')
  let $VIM = "$HOME/vimfiles"
endif
source $VIM/vimrc.d/xdg.vim
source $VIM/vimrc.d/opts.vim
source $VIM/vimrc.d/mappings.vim
source $VIM/vimrc.d/autocmds.vim
source $VIM/vimrc.d/plugins.vim

" Highlighted yanking
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=750}

" Source lua configuration
lua require('config')
