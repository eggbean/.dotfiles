" AUTOCMDS

" Option for specific filetypes
autocmd BufRead,BufNewFile *.tf   setlocal tabstop=2
autocmd BufRead,BufNewFile *.json setlocal tabstop=2
autocmd BufRead,BufNewFile *.md   setlocal textwidth=80 spell
autocmd BufRead,BufNewFile *.txt  setlocal tabstop=4 textwidth=80 noexpandtab spell
autocmd Filetype gitcommit setlocal colorcolumn=72 textwidth=80 spell | colorscheme onedark

" Enable syntax completion
if has('autocmd') && exists('+omnifunc')
  autocmd Filetype *
    \ if &omnifunc == "" |
    \   setlocal omnifunc=syntaxcomplete#Complete |
    \ endif
endif

" Skeleton templates
augroup skeleton
  autocmd!
  autocmd BufNewFile *.sh 0r $VIM/templates/skeleton.sh
  autocmd BufNewFile *.py 0r $VIM/templates/skeleton.py
augroup END

" Rename tmux windows with filename
if exists('$TMUX')
  augroup tmux
    autocmd!
    autocmd BufEnter * call system(printf('tmux rename-window %s\;
      \ set -a window-status-current-style "fg=#{@vimactive},nobold"\;
      \ set -a window-status-style "fg=#{@viminactive},nobold"',
      \ empty(@%) ? 'Noname' : fnamemodify(@%, ':t')))
    autocmd VimLeave * call system(printf('tmux set automatic-rename on\;
      \ set -a window-status-current-style "fg=#{@white}"\;
      \ set -a window-status-style "fg=#{@black}"'))
  augroup end
  autocmd BufEnter * let &titlestring = ' ' . expand("%:t")
endif
