" VIM MAPPINGS

" Toggle line numbers (F2/F3)
nnoremap <silent> <F2> :set number!<CR>
vnoremap <silent> <F2> :set number!<CR>
nnoremap <silent> <F3> :set relativenumber!<CR>
vnoremap <silent> <F3> :set relativenumber!<CR>

" Toggle colorcolumn (F4)
nnoremap <silent> <F4> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
vnoremap <silent> <F4> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>

" Toggle cursorcolumn (F5)
nnoremap <silent> <F5> :set cursorcolumn!<CR>
vnoremap <silent> <F5> :set cursorcolumn!<CR>

" Toggle signcolumn - used for padding on gvim (F6)
nnoremap <silent> <F6> :execute "set signcolumn=" . (&signcolumn == "auto" ? "yes" : "auto")<CR>
vnoremap <silent> <F6> :execute "set signcolumn=" . (&signcolumn == "auto" ? "yes" : "auto")<CR>

" Toggle spell-checking (F7)
nnoremap <silent> <F7> :set spell!<CR>
vnoremap <silent> <F7> :set spell!<CR>

" Toggle Netrw (F8)
let g:NetrwIsOpen=0
function! ToggleNetrw()
  if g:NetrwIsOpen
    let i = bufnr("$")
    while (i >= 1)
      if (getbufvar(i, "&filetype") == "netrw")
        silent exe "bwipeout " . i
      endif
      let i-=1
    endwhile
    let g:NetrwIsOpen=0
  else
    let g:NetrwIsOpen=1
    silent Explore
  endif
endfunction
nnoremap <silent> <F8> :call ToggleNetrw()<CR>
vnoremap <silent> <F8> :call ToggleNetrw()<CR>

" Insert empty lines without leaving Normal Mode
" Set timeoutlen to around 600 for this to work without too much delay
nmap oo o<ESC>k
nmap OO O<ESC>j

" Move lines with Alt+Shift+j/k
if has('unix')
  nnoremap J :m .+1<CR>==
  nnoremap K :m .-2<CR>==
  inoremap J <ESC>:m .+1<CR>==gi
  inoremap K <ESC>:m .-2<CR>==gi
  vnoremap J :m '>+1<CR>gv=gv
  vnoremap K :m '<-2<CR>gv=gv
elseif has('win32')
  nnoremap <M-S-j> :m .+1<CR>==
  nnoremap <M-S-k> :m .-2<CR>==
  inoremap <M-S-j> <ESC>:m .+1<CR>==gi
  inoremap <M-S-k> <ESC>:m .-2<CR>==gi
  vnoremap <M-S-j> :m '>+1<CR>gv=gv
  vnoremap <M-S-k> :m '<-2<CR>gv=gv
endif

" Enable Alt-. readline shortcut in cmd/clink terminal
if has('win32')
  tmap <expr> ® SendToTerm("\<Esc>.")
  func SendToTerm(what)
    call term_sendkeys('', a:what)
    return ''
  endfunc
endif

" Reselect pasted text
nnoremap gp `[v`]

" Open files using xdg-open
nnoremap gX :silent :execute
  \ "!xdg-open" expand('%:p:h') . "/" . expand("<cfile>") " &"<CR>

" Exit terminal mode with ESC
tnoremap <ESC> <C-\><C-n>

" Write after forgetting sudo
cnoremap w!! w !sudo tee % >/dev/null

" Map Alt+[key] to terminal-like behaviour
" so that I don't have to use ESC in gvim and vim for Windows
if has('win32') || has('gui_running')
  inoremap <M-`> <ESC>`
  inoremap <M-"> <ESC>"
  inoremap <M-$> <ESC>$
  inoremap <M-%> <ESC>%
  inoremap <M-^> <ESC>^
  inoremap <M-(> <ESC>(
  inoremap <M-)> <ESC>)
  inoremap <M-{> <ESC>{
  inoremap <M-}> <ESC>}
  inoremap <M-[> <ESC>[
  inoremap <M-]> <ESC>]
  inoremap <M-=> <ESC>=
  inoremap <M-:> <ESC>:
  inoremap <M-/> <ESC>/
  inoremap <M-?> <ESC>?
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
endif
