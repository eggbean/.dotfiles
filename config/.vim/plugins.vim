" PLUGINS

call plug#begin('$XDG_DATA_HOME/nvim/plugged')
	Plug 'tpope/vim-sensible'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-obsession'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-commentary'
	Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
	Plug 'sheerun/vim-polyglot'
	Plug 'tmux-plugins/vim-tmux'
	Plug 'junegunn/fzf'
	Plug 'jeffkreeftmeijer/vim-numbertoggle'
	Plug 'arp242/jumpy.vim'
	Plug 'ntpeters/vim-better-whitespace'
	Plug 'AndrewRadev/switch.vim'
	Plug 'eggbean/vim-toggle-bool', { 'branch': 'new-bools' }
	Plug 'eggbean/vim-tmux-navigator-no-wrapping'
	Plug 'MattesGroeger/vim-bookmarks'
	Plug 'ap/vim-css-color'
	Plug 'frazrepo/vim-rainbow'
	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'editorconfig/editorconfig-vim'
	Plug 'mattn/emmet-vim'
	Plug 'dense-analysis/ale'
	Plug 'airblade/vim-gitgutter'
	Plug 'pearofducks/ansible-vim'
	Plug 'folke/which-key.nvim'
	Plug 'EdenEast/nightfox.nvim'
	Plug 'nvim-lualine/lualine.nvim'
call plug#end()
