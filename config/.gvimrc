" GVIM CONFIGURATION

syntax on
set t_Co=256
color summerfruit256
if has("gui_gtk2")
  set guifont=Iosevka\ Term\ 14
elseif has("gui_win32")
  set guifont=Iosevka_NF:h14
endif
highlight Cursor guifg=white guibg=red
highlight iCursor guifg=white guibg=steelblue
set guicursor=n-v-c:block-Cursor
set guicursor+=i:ver20-iCursor
set lines=30 columns=80
set guioptions -=L
set guioptions -=r
set guioptions -=m
set guioptions -=T
set winaltkeys=no

" Macro to toggle window menu keys
nnoremap <F9> :call ToggleWindowMenu()<CR>

" Function to toggle window menu keys
function ToggleWindowMenu()
  if (&winaltkeys == 'yes')
    set winaltkeys=no   "turn off menu keys
    set guioptions -=m  "turn off menubar
    set guioptions -=T  "turn off icon toolbar
  else
    set winaltkeys=yes  "turn on menu keys
    set guioptions +=m  "turn on menubar
    set guioptions +=T  "turn on icon toolbar
  endif
endfunction

" Map Alt+[key] to normal terminal behaivior
inoremap <M-:> <ESC>:
inoremap <M-"> <ESC>"
inoremap <M-$> <ESC>$
inoremap <M-%> <ESC>%
inoremap <M-^> <ESC>^
inoremap <M-{> <ESC>{
inoremap <M-}> <ESC>}
inoremap <M-1> <ESC>1
inoremap <M-2> <ESC>2
inoremap <M-3> <ESC>3
inoremap <M-4> <ESC>4
inoremap <M-5> <ESC>5
inoremap <M-6> <ESC>6
inoremap <M-7> <ESC>7
inoremap <M-8> <ESC>8
inoremap <M-9> <ESC>9
inoremap <M-0> <ESC>0
inoremap <M-a> <ESC>a
inoremap <M-b> <ESC>b
inoremap <M-c> <ESC>c
inoremap <M-d> <ESC>d
inoremap <M-e> <ESC>e
inoremap <M-f> <ESC>f
inoremap <M-g> <ESC>g
inoremap <M-h> <ESC>h
inoremap <M-i> <ESC>i
inoremap <M-j> <ESC>j
inoremap <M-k> <ESC>k
inoremap <M-l> <ESC>l
inoremap <M-m> <ESC>m
inoremap <M-n> <ESC>n
inoremap <M-o> <ESC>o
inoremap <M-p> <ESC>p
inoremap <M-q> <ESC>q
inoremap <M-r> <ESC>r
inoremap <M-s> <ESC>s
inoremap <M-t> <ESC>t
inoremap <M-u> <ESC>u
inoremap <M-v> <ESC>v
inoremap <M-w> <ESC>w
inoremap <M-x> <ESC>x
inoremap <M-y> <ESC>y
inoremap <M-z> <ESC>z
inoremap <M-A> <ESC>A
inoremap <M-B> <ESC>B
inoremap <M-C> <ESC>C
inoremap <M-D> <ESC>D
inoremap <M-E> <ESC>E
inoremap <M-F> <ESC>F
inoremap <M-G> <ESC>G
inoremap <M-H> <ESC>H
inoremap <M-I> <ESC>I
inoremap <M-J> <ESC>J
inoremap <M-K> <ESC>K
inoremap <M-L> <ESC>L
inoremap <M-M> <ESC>M
inoremap <M-N> <ESC>N
inoremap <M-O> <ESC>O
inoremap <M-P> <ESC>P
inoremap <M-Q> <ESC>Q
inoremap <M-R> <ESC>R
inoremap <M-S> <ESC>S
inoremap <M-T> <ESC>T
inoremap <M-U> <ESC>U
inoremap <M-V> <ESC>V
inoremap <M-W> <ESC>W
inoremap <M-X> <ESC>X
inoremap <M-Y> <ESC>Y
inoremap <M-Z> <ESC>Z

" Fullscreen with Alt-Enter
set <a-cr>=\<esc>\<cr>
map <silent> <a-cr>
\    :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>
