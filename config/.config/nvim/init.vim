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
	Plug 'machakann/vim-highlightedyank'
	Plug 'pearofducks/ansible-vim'
call plug#end()

" Indentation
set tabstop=4 shiftwidth=4 shiftround softtabstop=4 autoindent noexpandtab list smartindent
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
set nosplitright
set nosplitbelow
set scrolloff=1
set showmode
set updatetime=4000

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
au BufRead,BufNewFile *.md    setlocal textwidth=80
au BufRead,BufNewFile *.notes setlocal textwidth=80
au BufRead,BufNewFile *.tf    setlocal tabstop=2 shiftwidth=2 expandtab
au BufRead,BufNewFile *.json  setlocal tabstop=2 shiftwidth=2 expandtab
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

" Rename tmux windows with filename
augroup tmux | au!
autocmd BufEnter * call system(printf('tmux rename-window %s\;
	\ set -a window-status-current-style "fg=#{@vimactive},bg=#{@active}"\;
	\ set -a window-status-style "fg=#{@viminactive}"',
	\ empty(@%) ? 'Noname' : fnamemodify(@%, ':t')))
autocmd VimLeave * call system(printf('tmux set automatic-rename on\;
	\ set -a window-status-current-style "fg=#{@white}"\;
	\ set -a window-status-style "fg=#{@black}"'))
augroup end
autocmd BufEnter * let &titlestring = ' ' . expand("%:t")

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
	" molokai colour scheme
	let g:molokai_original = 1
	let g:rehash256 = 1
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
	" vim-highlightedyank
	let g:highlightedyank_highlight_duration = 750
	" pearofducks/ansible-vim
	let g:ansible_unindent_after_newline = 1

" Colour scheme
if has('termguicolors')
	set termguicolors
endif
syntax enable
colorscheme gruvbox8_soft
set background=dark

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
