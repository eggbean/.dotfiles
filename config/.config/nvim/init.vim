" NVIM CONFIGURATION

" Plugins
call plug#begin('$XDG_DATA_HOME/nvim/plugged')
	Plug 'tpope/vim-sensible'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-obsession'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-commentary'
	Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }
	Plug 'sheerun/vim-polyglot'
	Plug 'tmux-plugins/vim-tmux'
	Plug 'junegunn/fzf'
	Plug 'jeffkreeftmeijer/vim-numbertoggle'
	Plug 'arp242/jumpy.vim'
	Plug 'ntpeters/vim-better-whitespace'
	Plug 'AndrewRadev/switch.vim'
	Plug 'eggbean/vim-toggle-bool', { 'branch': 'new-bools' }
	Plug 'eggbean/vim-tmux-navigator-no-wrapping'
	Plug 'folke/which-key.nvim'
	Plug 'MattesGroeger/vim-bookmarks'
	Plug 'ap/vim-css-color'
	Plug 'frazrepo/vim-rainbow'
	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'editorconfig/editorconfig-vim'
	Plug 'mattn/emmet-vim'
	Plug 'dense-analysis/ale'
	Plug 'airblade/vim-gitgutter'
	Plug 'pearofducks/ansible-vim'
	Plug 'EdenEast/nightfox.nvim'
	Plug 'nvim-lualine/lualine.nvim'
call plug#end()

" Indentation
set tabstop=4 shiftwidth=4 shiftround softtabstop=2 autoindent noexpandtab list smartindent
set backspace=indent,eol,start
set smarttab

set nrformats-=octal
set complete-=i
set nonumber
set numberwidth=4
" set relativenumber
" set signcolumn=auto
set incsearch
set hlsearch
set noignorecase
set nosmartcase
set wrap
set nosplitbelow
set splitright
set splitbelow
set scrolloff=1
set showmode
set updatetime=4000
set visualbell

set clipboard=unnamed
set encoding=utf-8
scriptencoding utf-8
set autoread
set nowrapscan
set title
set listchars=tab:▸-
set mouse=a
set hidden

" Write when forgetting sudo
cmap w!! w !sudo tee % >/dev/null

" Option for specific filetypes
autocmd BufRead,BufNewFile *.md    setlocal textwidth=80
autocmd BufRead,BufNewFile *.notes setlocal textwidth=80
autocmd BufRead,BufNewFile *.tf    setlocal tabstop=2 shiftwidth=2 expandtab
autocmd BufRead,BufNewFile *.json  setlocal tabstop=2 shiftwidth=2 expandtab
augroup filetype_yaml
	autocmd!
	autocmd BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
	autocmd FileType yaml |
		setlocal expandtab
		setlocal shiftwidth=2 |
		setlocal softtabstop=2 |
		setlocal tabstop=2
augroup END
augroup skeleton
    autocmd!
    "adds bash shebang to .sh files
    autocmd bufnewfile *.sh 0r $XDG_CONFIG_HOME/nvim/templates/skeleton.sh
    autocmd bufnewfile *.py 0r $XDG_CONFIG_HOME/nvim/templates/skeleton.py
augroup END

" Move lines
nnoremap <A-S-j> :m .+1<CR>==
nnoremap <A-S-k> :m .-2<CR>==
inoremap <A-S-j> <Esc>:m .+1<CR>==gi
inoremap <A-S-k> <Esc>:m .-2<CR>==gi
vnoremap <A-S-j> :m '>+1<CR>gv=gv
vnoremap <A-S-k> :m '<-2<CR>gv=gv

" Zoom in and out of splits
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" Exit terminal mode with ESC
tnoremap <Esc> <C-\><C-n>

" Rename tmux windows with filename
augroup tmux | autocmd!
autocmd BufEnter * call system(printf('tmux rename-window %s\;
	\ set -a window-status-current-style "fg=#{@vimactive},bg=#{@active}"\;
	\ set -a window-status-style "fg=#{@viminactive}"',
	\ empty(@%) ? 'Noname' : fnamemodify(@%, ':t')))
autocmd VimLeave * call system(printf('tmux set automatic-rename on\;
	\ set -a window-status-current-style "fg=#{@white}"\;
	\ set -a window-status-style "fg=#{@black}"'))
augroup end
autocmd BufEnter * let &titlestring = ' ' . expand("%:t")

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

" Plugin configuration
	" NERDTree
	map <M-p> :NERDTreeToggle<CR>
	let NERDTreeShowHidden = 1
	let NERDTreeQuitOnOpen = 0
	" vim-better-whitespace
	let g:show_spaces_that_precede_tabs = 1
	" vim-tmux-navigator
	let g:tmux_navigator_no_wrap = 1
	let g:tmux_navigator_disable_when_zoomed = 1
	let g:tmux_navigator_no_mappings = 1
	nnoremap <silent> <C-M-h> :TmuxNavigateLeft<cr>
	nnoremap <silent> <C-M-j> :TmuxNavigateDown<cr>
	nnoremap <silent> <C-M-k> :TmuxNavigateUp<cr>
	nnoremap <silent> <C-M-l> :TmuxNavigateRight<cr>
	nnoremap <silent> <C-M-;> :TmuxNavigatePrevious<cr>
	" gruvbox8 colour scheme
	let g:gruvbox_filetype_hi_groups = 1
	let g:gruvbox_italics = 1
	let g:gruvbox_italicize_strings = 0
	let g:gruvbox_plugin_hi_groups = 1
	" vim-bookmarks
	let g:bookmark_sign = '🔖'
	let g:bookmark_save_per_working_dir = 0
	let g:bookmark_manage_per_buffer = 1
	let g:bookmark_auto_save_file = '$XDG_DATA_HOME/nvim/bookmarks'
	let g:bookmark_display_annotation = 1
	" vim-rainbow
	let g:rainbow_active = 1
	" vim-toggle-bool
	nnoremap <silent> <Leader>t :ToggleBool<CR>
	" pearofducks/ansible-vim
	let g:ansible_unindent_after_newline = 1

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
