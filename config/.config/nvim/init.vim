" NVIM CONFIGURATION

source ~/.vim/plugins.vim
source ~/.vim/common.vim
source ~/.vim/autocmds.vim
source ~/.vim/pluginconfig.vim

" Highlighted yanking
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=750}

" Persistent undo
set undodir=~$XDG_CACHE_HOME/nvim/.undo//
set backupdir=~$XDG_CACHE_HOME/nvim/.backup//
set directory=~$XDG_CACHE_HOME/nvim/.swp//
set undofile

" XDG Environment
set runtimepath^=$XDG_CONFIG_HOME/nvim
set runtimepath+=$XDG_DATA_HOME/nvim
set runtimepath+=$XDG_CONFIG_HOME/nvim/after
set directory=$XDG_CACHE_HOME/nvim/swap   | call mkdir(&directory, 'p')
set backupdir=$XDG_CACHE_HOME/nvim/backup | call mkdir(&backupdir, 'p')
set undodir=$XDG_CACHE_HOME/nvim/undo     | call mkdir(&undodir,   'p')

	" nightfox colour scheme
lua << EOF
  local nightfox = require('nightfox')

-- This function set the configuration of nightfox. If a value is not passed in the setup function
-- it will be taken from the default configuration above
nightfox.setup({
  fox = "nordfox", -- change the colorscheme to use duskfox
  transparent = false, -- Enable setting the background color
  alt_nc = false, -- Non current window bg to alt color see `hl-NormalNC`
  terminal_colors = false, -- Configure the colors used when opening :terminal
  styles = {
    comments = "italic", -- change style of comments to be italic
    keywords = "bold", -- change style of keywords to be bold
    functions = "italic,bold" -- styles can be a comma separated list
  },
  inverse = {
    match_paren = false, -- inverse the highlighting of match_parens
  },
  colors = {
    red = "#FF000", -- Override the red color for MAX POWER
    bg_alt = "#000000",
  },
  hlgroups = {
    TSPunctDelimiter = { fg = "${red}" }, -- Override a highlight group with the color red
    LspCodeLens = { bg = "#000000", style = "italic" },
  }
})

-- Load the configuration set above and apply the colorscheme
nightfox.load()
require('lualine').setup()
EOF

" Colour scheme
if has('termguicolors')
	set termguicolors
endif
syntax enable

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
