" PLUGINS

if has('unix') | call plug#begin('$XDG_DATA_HOME/vim/plugged')
elseif has('win32') | call plug#begin() | endif
  Plug 'tpope/vim-rsi'
  Plug 'tpope/vim-commentary'
  Plug 'azabiong/vim-highlighter'
  Plug 'ntpeters/vim-better-whitespace'
  Plug 'machakann/vim-sandwich'
  Plug 'dhruvasagar/vim-zoom'
  Plug 'chrisbra/Recover.vim'
  Plug 'iamcco/markdown-preview.nvim', { 'for': 'markdown' }
  Plug 'MattesGroeger/vim-bookmarks'
  if !has('win32')
    Plug 'tpope/vim-eunuch'
    Plug 'juliosueiras/vim-terraform-completion'
    Plug 'LnL7/vim-nix'
  endif
  if !has('gui_running')
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'
    Plug 'nanotee/zoxide.vim'
    Plug 'AndrewRadev/sideways.vim'
    Plug 'AndrewRadev/switch.vim'
    Plug 'chrisbra/csv.vim'
    Plug 'frazrepo/vim-rainbow'
    Plug 'junegunn/fzf'
    Plug 'ap/vim-css-color'
    Plug 'dense-analysis/ale'
    Plug 'eggbean/vim-toggle-bool', { 'branch': 'boolean' }
    Plug 'EinfachToll/DidYouMean'
    Plug 'dstein64/vim-startuptime'
    " EVALUATING ...
    " Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'dkarter/bullets.vim'
    " Plug 'neoclide/coc.nvim', { 'branch': 'release' }
    " Plug 'mattn/emmet-vim'
    " Plug 'pearofducks/ansible-vim'
    if !has('win32')
      Plug 'eggbean/vim-tmux', { 'branch': 'missing-commands' }
      Plug 'christoomey/vim-tmux-navigator'
      Plug 'roxma/vim-tmux-clipboard'
      Plug 'ojroques/vim-oscyank'
    " Plug 'hashivim/vim-terraform'
    " Plug 'hashivim/vim-vagrant'
    " Plug 'hashivim/vim-vaultproject'
    endif
    if has('nvim')
      Plug 'EdenEast/nightfox.nvim'
      Plug 'nvim-lualine/lualine.nvim'
      Plug 'kyazdani42/nvim-web-devicons'
      Plug 'romgrk/barbar.nvim'
      Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
      " EVALUATING ...
      Plug 'phelipetls/jsonpath.nvim'
    endif
    if !has('nvim')
      Plug 'machakann/vim-highlightedyank'
      Plug 'sainnhe/sonokai'
      Plug 'itchyny/lightline.vim'
      Plug 'dracula/vim', { 'as': 'dracula' }
    endif
  endif
  if has('gui_running')
    Plug 'machakann/vim-highlightedyank'
    Plug 'eggbean/resize-font.gvim'
    Plug 'AndrewRadev/typewriter.vim'
    if has('win32')
      Plug 'vim-scripts/wimproved.vim'
    endif
  endif
  if !has('gui_running') && has('python3')
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
  if exists('$TMUX')
    let g:tmux_navigator_no_wrap = 1
    let g:tmux_navigator_disable_when_zoomed = 1
    let g:tmux_navigator_no_mappings = 1
    nnoremap <silent> <ESC><C-h> :TmuxNavigateLeft<CR>
    nnoremap <silent> <ESC><C-j> :TmuxNavigateDown<CR>
    nnoremap <silent> <ESC><C-k> :TmuxNavigateUp<CR>
    nnoremap <silent> <ESC><C-l> :TmuxNavigateRight<CR>
    nnoremap <silent> <ESC><C-Left>  :TmuxNavigateLeft<CR>
    nnoremap <silent> <ESC><C-Down>  :TmuxNavigateDown<CR>
    nnoremap <silent> <ESC><C-Up>    :TmuxNavigateUp<CR>
    nnoremap <silent> <ESC><C-Right> :TmuxNavigateRight<CR>
  endif
" gruvbox8 colour scheme
  let g:gruvbox_filetype_hi_groups = 1
  let g:gruvbox_italics = 1
  let g:gruvbox_italicize_strings = 0
  let g:gruvbox_plugin_hi_groups = 1
" vim-bookmarks
  let g:bookmark_sign = '⭕'
  let g:bookmark_save_per_working_dir = 0
  let g:bookmark_manage_per_buffer = 0
  let g:bookmark_display_annotation = 1
  if has('unix')
    let g:bookmark_auto_save_file = $XDG_DATA_HOME .'/vim-bookmarks'
  elseif has('win32')
    let g:bookmark_auto_save_file = $VIMFILES .'/vim-bookmarks'
  endif
" vim-rainbow
  let g:rainbow_active = 1
" vim-toggle-bool
  nnoremap <silent> <Leader>t :ToggleBool<CR>
" pearofducks/ansible-vim
  let g:ansible_unindent_after_newline = 1
" vim-highlightedyank
  let g:highlightedyank_highlight_duration = 750
  highlight HighlightedyankRegion cterm=reverse gui=reverse
" sideways
  nnoremap <C-h> :SidewaysLeft<CR>
  nnoremap <C-l> :SidewaysRight<CR>
  omap aa <Plug>SidewaysArgumentTextobjA
  xmap aa <Plug>SidewaysArgumentTextobjA
  omap ia <Plug>SidewaysArgumentTextobjI
  xmap ia <Plug>SidewaysArgumentTextobjI
" vim-oscyank
  if !empty($SSH_CONNECTION)
    nnoremap <C-Insert> <Plug>OSCYankOperator
    nnoremap <C-Insert><C-Insert> <leader>c_
    vnoremap <C-Insert> <Plug>OSCYankVisual
  endif
" markdown-preview
  let g:mkdp_echo_preview_url = 1
  let g:mkdp_theme = 'light'
  nmap <leader>m <Plug>MarkdownPreviewToggle
  let g:mkdp_markdown_css = expand('~/.config/vim/css/github-markdown.css')
  if has('unix') && IsWSL()==0
    let g:mkdp_browser = 'qutebrowser'
  elseif has('win32') || IsWSL()==1
    let g:mkdp_browser = 'C:\Program Files\qutebrowser\qutebrowser.exe'
  endif
" lightline.vim
  let g:lightline = { 'colorscheme': 'dracula' }
" bullets.vim
  let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'gitcommit',
    \ 'scratch'
    \]
