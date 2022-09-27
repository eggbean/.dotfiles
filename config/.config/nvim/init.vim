" NVIM CONFIGURATION

if has('unix')
  let $VIM = "$HOME/.config/vim"
elseif has('win32')
  let $VIM = "$HOME/vimfiles"
endif
source $VIM/vimrc.d/xdg.vim
source $VIM/vimrc.d/common.vim
source $VIM/vimrc.d/autocmds.vim
source $VIM/vimrc.d/plugins.vim

" Highlighted yanking
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=750}

" Language Providers
if has('unix')
  let g:python3_host_prog = '/usr/bin/python3'
elseif has('win32')
  " Windows
endif
let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_node_provider = 0

" Source lua configuration
lua require('config')
