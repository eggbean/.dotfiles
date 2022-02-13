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
