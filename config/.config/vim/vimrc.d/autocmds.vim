" AUTOCMDS

" Regenerate spl files on startup
set spellfile=vimrc.d/spell/en.utf-8.add
for d in glob('vimrc.d/spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor

" Option for specific filetypes
autocmd BufRead,BufNewFile *.md    setlocal textwidth=80 spell spelllang=en_gb
autocmd BufRead,BufNewFile *.txt   setlocal textwidth=80 spell spelllang=en_gb
autocmd BufRead,BufNewFile *.tf    setlocal tabstop=2 shiftwidth=2 expandtab
autocmd BufRead,BufNewFile *.json  setlocal tabstop=2 shiftwidth=2 expandtab

" yaml
augroup filetype_yaml
	autocmd!
	autocmd BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
	autocmd FileType yaml |
		setlocal expandtab
		setlocal shiftwidth=2 |
		setlocal softtabstop=2 |
		setlocal tabstop=2
augroup END

" sh
augroup filetype_sh
	autocmd!
	autocmd BufNewFile,BufReadPost *.sh set filetype=sh
	autocmd FileType sh |
		setlocal expandtab
		setlocal shiftwidth=2 |
		setlocal softtabstop=2 |
		setlocal tabstop=2
augroup END

" Skeleton templates
augroup skeleton
    autocmd!
    autocmd bufnewfile *.sh 0r ~/.config/vim/templates/skeleton.sh
    autocmd bufnewfile *.py 0r ~/.config/vim/templates/skeleton.py
augroup END

" Rename tmux windows with filename
if exists('$TMUX')
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
endif
