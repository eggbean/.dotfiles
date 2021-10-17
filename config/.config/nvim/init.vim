" NVIM CONFIGURATION

" Plugins
call plug#begin('$XDG_DATA_HOME/nvim/plugged')
	Plug 'tpope/vim-sensible'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-unimpaired'
	Plug 'junegunn/fzf'
	Plug 'ericpruitt/tmux.vim', {'rtp': 'vim/'}
	Plug 'jeffkreeftmeijer/vim-numbertoggle'
	Plug 'arp242/jumpy.vim'
	Plug 'ntpeters/vim-better-whitespace'
	Plug 'eggbean/vim-tmux-navigator-no-wrapping'
"   Plug 'folke/which-key.nvim'
call plug#end()

" Indentation
set tabstop=4 shiftwidth=4 softtabstop=4 autoindent noexpandtab list

set encoding=utf-8
scriptencoding utf-8
set autoread
set nowrapscan
syntax enable
set background=dark
colorscheme gruvbox
set title
set listchars=tab:▸-
set mouse=a

" XDG Environment
set runtimepath^=$XDG_CONFIG_HOME/nvim
set runtimepath+=$XDG_DATA_HOME/nvim
set runtimepath+=$XDG_CONFIG_HOME/nvim/after
set directory=$XDG_CACHE_HOME/nvim/swap   | call mkdir(&directory, 'p')
set backupdir=$XDG_CACHE_HOME/nvim/backup | call mkdir(&backupdir, 'p')
set undodir=$XDG_CACHE_HOME/nvim/undo     | call mkdir(&undodir,   'p')

" " Persistent undo
" set undodir=~/.config/nvim/.undo//
" set backupdir=~/.config/nvim/.backup//
" set directory=~/.config/nvim/.swp//
" set undofile

" Move lines
nnoremap <A-S-j> :m .+1<CR>==
nnoremap <A-S-k> :m .-2<CR>==
inoremap <A-S-j> <Esc>:m .+1<CR>==gi
inoremap <A-S-k> <Esc>:m .-2<CR>==gi
vnoremap <A-S-j> :m '>+1<CR>gv=gv
vnoremap <A-S-k> :m '<-2<CR>gv=gv

" Disable arrow keys
nnoremap <Left> :echo "No left for you!"<CR>
inoremap <Left> <C-o>:echo "No left for you!"<CR>
vnoremap <Left> :<C-u>echo "No left for you!"<CR>
nnoremap <Down> :echo "No down for you!"<CR>
inoremap <Down> <C-o>:echo "No down for you!"<CR>
vnoremap <Down> :<C-u>echo "No down for you!"<CR>
nnoremap <Up> :echo "No up for you!"<CR>
inoremap <Up> <C-o>:echo "No up for you!"<CR>
vnoremap <Up> :<C-u>echo "No up for you!"<CR>
nnoremap <Right> :echo "No right for you!"<CR>
inoremap <Right> <C-o>:echo "No right for you!"<CR>
vnoremap <Right> :<C-u>echo "No right for you!"<CR>

" Zoom in and out of splits
" https://medium.com/@vinodkri/zooming-vim-window-splits-like-a-pro-d7a9317d40
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" https://stackoverflow.com/a/29693196/140872
autocmd BufEnter * call system("tmux rename-window " . expand("%:t"))
autocmd VimLeave * call system("tmux set automatic-rename")
autocmd BufEnter * let &titlestring = ' ' . expand("%:t")

" Plugin configuration
	" netrw
	let g:netrw_home = $XDG_DATA_HOME.'/nvim'
	" vim-better-whitespace
	let g:show_spaces_that_precede_tabs=1
	" vim-tmux-navigator
	let g:tmux_navigator_no_wrap = 1
	let g:tmux_navigator_disable_when_zoomed = 1
	let g:tmux_navigator_no_mappings = 1
	nnoremap <silent> <C-M-h> :TmuxNavigateLeft<cr>
	nnoremap <silent> <C-M-j> :TmuxNavigateDown<cr>
	nnoremap <silent> <C-M-k> :TmuxNavigateUp<cr>
	nnoremap <silent> <C-M-l> :TmuxNavigateRight<cr>
	nnoremap <silent> <C-M-;> :TmuxNavigatePrevious<cr>
	" molokai colour theme
	let g:molokai_original = 1
	let g:rehash256 = 1