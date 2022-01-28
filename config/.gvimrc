" vim.gtk/gvim: map alt+[hjkl] to normal terminal behaivior
if has("gui_running")
    " inoremap == 'ignore any other mappings'
    inoremap <M-h> <ESC>h
    inoremap <M-j> <ESC>j
    inoremap <M-k> <ESC>k
    inoremap <M-l> <ESC>l
    inoremap <M-g> <ESC>g
    inoremap <M-:> <ESC>:

    "" uncomment to disable Alt+[menukey] menu keys (i.e. Alt+h for help)
    "set winaltkeys=no " same as `:set wak=no`

    "" uncomment to disable menubar
    "set guioptions -=m

    "" uncomment to disable icon menubar
    "set guioptions -=T

    "" macro to toggle window menu keys
    "noremap ,wm :call ToggleWindowMenu()<CR>

    "" function to toggle window menu keys
    "function ToggleWindowMenu()
    "    if (&winaltkeys == 'yes')
    "        set winaltkeys=no   "turn off menu keys
    "        set guioptions -=m  "turn off menubar

    "        " uncomment to remove icon menubar
    "        "set guioptions -=T
    "    else
    "        set winaltkeys=yes  "turn on menu keys
    "        set guioptions +=m  "turn on menubar

    "        " uncomment to add icon menubar
    "        "set guioptions +=T
    "    endif
    "endfunction
endif

set lines=45 columns=100
