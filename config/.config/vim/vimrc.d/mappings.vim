" VIM MAPPINGS

" Toggle colorcolumn (F2)
nnoremap <silent> <F2> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
vnoremap <silent> <F2> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>

" Toggle line numbers (F3/F4)
nnoremap <silent> <F3> :set number!<CR>
vnoremap <silent> <F3> :set number!<CR>
nnoremap <silent> <F4> :set relativenumber!<CR>
vnoremap <silent> <F4> :set relativenumber!<CR>

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

" Write after forgetting sudo
cnoremap w!! w !sudo tee % >/dev/null

" Insert empty lines without leaving Normal Mode
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

" Open files using xdg-open
nnoremap gX :silent :execute
  \ "!xdg-open" expand('%:p:h') . "/" . expand("<cfile>") " &"<CR>

" Scroll splits together one line
let g:scrollLock = 0
command! ToggleScrollLock let g:scrollLock = !g:scrollLock
nnoremap <silent> <F11> :ToggleScrollLock<CR>
nnoremap <expr> <C-e> (g:scrollLock == 1) ? ':windo set scrollbind<CR><C-e>:windo set noscrollbind<CR>' : '<C-e>'
nnoremap <expr> <C-y> (g:scrollLock == 1) ? ':windo set scrollbind<CR><C-y>:windo set noscrollbind<CR>' : '<C-y>'
" nnoremap <C-S-E> :windo set scrollbind<CR><C-e>:windo set noscrollbind<CR>
" nnoremap <C-S-Y> :windo set scrollbind<CR><C-y>:windo set noscrollbind<CR>

" Exit terminal mode with ESC
tnoremap <ESC> <C-\><C-n>

" Clear registers
command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor
