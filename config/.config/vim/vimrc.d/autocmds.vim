" VIM AUTOCMDS & FUNCTIONS

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
  autocmd BufNewFile *.* silent! execute '0r $VIMFILES/templates/skeleton.'.expand("<afile>:e") | $
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
  augroup END
  autocmd BufEnter * let &titlestring = ' ' . expand("%:t")
endif

" Fix - don't run better-whitespace in terminal
if has('nvim')
  augroup term
    autocmd TermOpen * :DisableWhitespace
  augroup END
endif

" Disable statusline in gvim terminal window (when active)
" (set splitbelow and splitright for this to work)
if has('gui_running')
  augroup TerminalStatusline
    autocmd!
    autocmd TerminalOpen * set laststatus=0
    autocmd BufEnter     * if &buftype != 'terminal' | set laststatus=2 | endif
    autocmd BufEnter     * if &buftype == 'terminal' | set laststatus=0 | endif
  augroup END
endif

" ---------------------
" Some custom commands and functions:

" Send selection to my ix.io pastebin account
command! -range=% IX '<,'>!curl -snF 'f:1=<-' ix.io

" Toggle UPPERCASE/lowercase/Titlecase
" of selection with ~
function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

" Highlight repeated lines
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

" Clear registers
function! WipeReg()
  for i in range(34,122)
    silent! call setreg(nr2char(i), [])
  endfor
  if has ('nvim')
    wsh!
  else
    wv!
  endif
endfunction
command! WipeReg call WipeReg()

" For WSL conditionals
function! IsWSL()
  if has("unix")
    if filereadable("/proc/version") " avoid error on Android
      let lines = readfile("/proc/version")
      if lines[0] =~ "microsoft"
        return 1
      endif
    endif
  endif
  return 0
endfunction
