" PLUGINS

if has('unix') | call plug#begin('$XDG_DATA_HOME/vim/plugged')
elseif has('win32') | call plug#begin() | endif
  if !has('gui_running')
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rsi'
    Plug 'machakann/vim-sandwich'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'sheerun/vim-polyglot'
    Plug 'dense-analysis/ale'
    Plug 'junegunn/fzf'
    Plug 'ntpeters/vim-better-whitespace'
    Plug 'airblade/vim-gitgutter'
    Plug 'MattesGroeger/vim-bookmarks'
    Plug 'AndrewRadev/switch.vim'
    Plug 'gerazov/vim-toggle-bool'
    Plug 'chrisbra/Recover.vim'
    Plug 'chrisbra/SudoEdit.vim'
    Plug 'chrisbra/csv.vim'
    Plug 'dhruvasagar/vim-zoom'
    Plug 'ap/vim-css-color'
    Plug 'eggbean/vim-tmux', { 'branch': 'missing-commands' }
    " TESTING ...
    Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'frazrepo/vim-rainbow'
    " Plug 'ctrlpvim/ctrlp.vim'
    " Plug 'mattn/emmet-vim'
    " Plug 'arp242/jumpy.vim'
    " Plug 'pearofducks/ansible-vim'
    " Plug 'hashivim/vim-terraform'
    " Plug 'juliosueiras/vim-terraform-completion'
    if !has('nvim')
      Plug 'machakann/vim-highlightedyank'
    endif
    if has('nvim')
      Plug 'EdenEast/nightfox.nvim'
      Plug 'nvim-lualine/lualine.nvim'
      Plug 'kyazdani42/nvim-web-devicons'
      Plug 'romgrk/barbar.nvim'
    endif
  endif
  if has('gui_running')
    Plug 'ntpeters/vim-better-whitespace'
    if has('win32')
      Plug 'kkoenig/wimproved.vim'
    endif
  endif
  if has('python3')
    Plug 'SirVer/ultisnips'
    Plug 'ron89/thesaurus_query.vim'
  endif
call plug#end()

" PLUGIN CONFIGURATION

" NERDTree
  map <M-p> :NERDTreeToggle<CR>
  let NERDTreeShowHidden = 1
  let NERDTreeQuitOnOpen = 0
" vim-better-whitespace
  let g:better_whitespace_ctermcolor='Magenta'
  let g:better_whitespace_guicolor='Magenta'
  let g:show_spaces_that_precede_tabs = 1
" vim-tmux-navigator
  let g:tmux_navigator_no_wrap = 1
  let g:tmux_navigator_disable_when_zoomed = 1
  let g:tmux_navigator_no_mappings = 1
  nnoremap <silent> <C-M-h> :TmuxNavigateLeft<CR>
  nnoremap <silent> <C-M-j> :TmuxNavigateDown<CR>
  nnoremap <silent> <C-M-k> :TmuxNavigateUp<CR>
  nnoremap <silent> <C-M-l> :TmuxNavigateRight<CR>
" gruvbox8 colour scheme
  let g:gruvbox_filetype_hi_groups = 1
  let g:gruvbox_italics = 1
  let g:gruvbox_italicize_strings = 0
  let g:gruvbox_plugin_hi_groups = 1
" vim-bookmarks
  let g:bookmark_sign = '⭕'
  let g:bookmark_save_per_working_dir = 0
  let g:bookmark_manage_per_buffer = 1
  let g:bookmark_auto_save_file = '$XDG_DATA_HOME/vim/bookmarks'
  let g:bookmark_display_annotation = 1
" vim-rainbow
  let g:rainbow_active = 1
" vim-toggle-bool
  nnoremap <silent> <Leader>t :ToggleBool<CR>
" pearofducks/ansible-vim
  let g:ansible_unindent_after_newline = 1
" vim-highlightedyank
  let g:highlightedyank_highlight_duration = 750
