" AUTOCMDS

" Option for specific filetypes
autocmd BufRead,BufNewFile *.md   setlocal textwidth=80 spell spelllang=en_gb
autocmd BufRead,BufNewFile *.txt  setlocal textwidth=80 spell spelllang=en_gb
autocmd BufRead,BufNewFile *.tf   setlocal tabstop=2 shiftwidth=2 expandtab
autocmd BufRead,BufNewFile *.json setlocal tabstop=2 shiftwidth=2 expandtab

" yaml
augroup filetype_yaml
  autocmd!
  autocmd BufNewFile,BufReadPost *.{yaml,yml}
    \ setlocal expandtab |
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal foldlevelstart=20 |
    \ setlocal foldmethod=indent |
    \ setlocal indentkeys-=0# |
    \ setlocal indentkeys-=<:>
augroup END

" sh
augroup filetype_sh
  autocmd!
  autocmd BufNewFile,BufReadPost *.sh
    \ setlocal expandtab |
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2
augroup END

" Skeleton templates
augroup skeleton
  autocmd!
  autocmd BufNewFile *.sh 0r ~/.config/vim/templates/skeleton.sh
  autocmd BufNewFile *.py 0r ~/.config/vim/templates/skeleton.py
augroup END

" Rename tmux windows with filename
if exists('$TMUX')
  augroup tmux
    autocmd!
    autocmd BufEnter * call system(printf('tmux rename-window %s\;
      \ set -a window-status-current-style "fg=#{@vimactive},bg=#{@active}"\;
      \ set -a window-status-style "fg=#{@viminactive}"',
      \ empty(@%) ? 'Noname' : fnamemodify(@%, ':t')))
    autocmd VimLeave * call system(printf('tmux set automatic-rename on\;
    \ set -a window-status-current-style "fg=#{@white}"\;
    \ set -a window-status-style "fg=#{@black}"'))
  augroup end
  autocmd BufEnter * let &titlestring = ' ' . expand("%:t")
endif
