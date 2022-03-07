" NVIM CONFIGURATION

source ~/.dotfiles/config/.config/vim/vimrc.d/xdg.vim
source ~/.dotfiles/config/.config/vim/vimrc.d/plugins.vim
source ~/.dotfiles/config/.config/vim/vimrc.d/common.vim
source ~/.dotfiles/config/.config/vim/vimrc.d/autocmds.vim
source ~/.dotfiles/config/.config/vim/vimrc.d/pluginconfig.vim

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

" nightfox colour scheme
lua << EOF
local nightfox = require('nightfox')

nightfox.setup({
  fox = "nordfox", -- Change the colorscheme variant
  transparent = false, -- Enable setting the background color
  alt_nc = false, -- Non current window bg to alt color see `hl-NormalNC`
  terminal_colors = false, -- Configure the colors used when opening :terminal
  styles = {
    comments = "italic",
    functions = "italic,bold",
    keywords = "bold",
    strings = "NONE",
    variables = "NONE",
  },
  inverse = {
    match_paren = false, -- Enable/Disable inverse highlighting for match parens
    visual = false, -- Enable/Disable inverse highlighting for visual selection
    search = false, -- Enable/Disable inverse highlights for search highlights
  },
  colors = {},
  hlgroups = {
    Search = { fg = "${fg}", bg = "${fg_gutter}" },
    IncSearch = { fg = "${bg}", bg = "${cyan}" },
    Substitute = { fg = "${bg}", bg = "#bf616a" },
  }
})

nightfox.load()
require('lualine').setup()
EOF

if has('termguicolors')
  set termguicolors
endif
