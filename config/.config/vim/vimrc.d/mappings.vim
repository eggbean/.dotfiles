" VIM MAPPINGS

" Toggle colorcolumn
nnoremap <silent> <F2> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
vnoremap <silent> <F2> :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>

" Toggle line numbers
nnoremap <silent> <F3> :set number!<CR>
inoremap <silent> <F3> :set number!<CR>
vnoremap <silent> <F3> :set number!<CR>
nnoremap <silent> <F4> :set relativenumber!<CR>
inoremap <silent> <F4> :set relativenumber!<CR>
vnoremap <silent> <F4> :set relativenumber!<CR>

" Toggle spell-checking
nnoremap <silent> <F7> :set spell!<CR>
vnoremap <silent> <F7> :set spell!<CR>

" Only yanks to clipboard,
" not deletes, changes and puts like with clipboard setting
nnoremap y "+y
nnoremap Y ^"+y$

" Write after forgetting sudo
cnoremap w!! w !sudo tee % >/dev/null

" Move lines with Alt+Shift+j/k
if has('unix')
  nnoremap J :m .+1<CR>==
  nnoremap K :m .-2<CR>==
  inoremap J <Esc>:m .+1<CR>==gi
  inoremap K <Esc>:m .-2<CR>==gi
  vnoremap J :m '>+1<CR>gv=gv
  vnoremap K :m '<-2<CR>gv=gv
elseif has('win32')
  nnoremap <M-S-j> :m .+1<CR>==
  nnoremap <M-S-k> :m .-2<CR>==
  inoremap <M-S-j> <Esc>:m .+1<CR>==gi
  inoremap <M-S-k> <Esc>:m .-2<CR>==gi
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
tnoremap <Esc> <C-\><C-n>

" Clear registers (temporarily)
command! WipeReg for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor
