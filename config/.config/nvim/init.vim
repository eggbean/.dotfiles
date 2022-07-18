" NVIM CONFIGURATION

source ~/.config/vim/vimrc.d/xdg.vim
source ~/.config/vim/vimrc.d/plugins.vim
source ~/.config/vim/vimrc.d/common.vim
source ~/.config/vim/vimrc.d/autocmds.vim
source ~/.config/vim/vimrc.d/pluginconfig.vim

" Highlighted yanking
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=750}

" Language Providers
if has('macunix')
  let g:python3_host_prog = '/usr/local/bin/python3'
elseif has('unix')
  let g:python3_host_prog = '/usr/bin/python3'
elseif has('win32') || has('win64')
  " Windows
endif
let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_node_provider = 0

" Source lua configuration
lua require('config')
