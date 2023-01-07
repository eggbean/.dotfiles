" VIM AUTOCMDS

" Set filetype so that linting plugins use bash syntax instead of sh
autocmd BufNewFile,BufRead .bash_aliases,.bash_logout,.bash_profile,.bashrc,*.sh setf bash

" Markdown
autocmd BufNewFile,BufRead *.markdown,*.mdown,*.mkd,*.mkdn,*.mdwn,*.md setf markdown
let g:markdown_fenced_languages = ['html', 'css', 'python', 'sh', 'vim']

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
  autocmd BufNewFile *.* silent! execute '0r $VIMFILES/templates/skeleton.'.expand("<afile>:e")
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

" Fix - don't run better-whitespace in terminal
if has('nvim')
  augroup term
    autocmd TermOpen * :DisableWhitespace
  augroup END
endif

" Highlight Repeated Lines
function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction
command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()
