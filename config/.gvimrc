" vim.gtk/gvim: map alt+[key] to normal terminal behaivior
inoremap <M-\:> <ESC>\:
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

"" uncomment to disable Alt+[menukey] menu keys (i.e. Alt+h for help)
set winaltkeys=no " same as `:set wak=no`

"" uncomment to disable menubar
set guioptions -=m

"" uncomment to disable icon menubar
set guioptions -=T

"" macro to toggle window menu keys
noremap <F9> :call ToggleWindowMenu()<CR>

"" function to toggle window menu keys
function ToggleWindowMenu()
    if (&winaltkeys == 'yes')
        set winaltkeys=no   "turn off menu keys
        set guioptions -=m  "turn off menubar

        " uncomment to remove icon menubar
        "set guioptions -=T
    else
        set winaltkeys=yes  "turn on menu keys
        set guioptions +=m  "turn on menubar

        " uncomment to add icon menubar
        "set guioptions +=T
    endif
endfunction

set lines=30 columns=80
set guifont=Iosevka\ Term\ 14
