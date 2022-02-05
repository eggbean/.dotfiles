" AUTOCMDS

" Option for specific filetypes
autocmd BufRead,BufNewFile *.md    setlocal textwidth=80 spell spelllang=en_gb
autocmd BufRead,BufNewFile *.notes setlocal textwidth=80 spell spelllang=en_gb
autocmd BufRead,BufNewFile *.txt   setlocal textwidth=80 spell spelllang=en_gb
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
