" Distraction-free mode
" based on: https://zserge.com/posts/vim-distraction-free/
let g:dfm_width = 80 "absolute width or percentage, like 0.7
let g:dfm_height = 0.8

let s:dfm_enabled = 0

function! ToggleDistractionFreeMode()
  let l:w = g:dfm_width > 1 ? g:dfm_width : (winwidth('%') * g:dfm_width)
  let l:margins = {
    \ "l": ("silent leftabove " . float2nr((winwidth('%') - l:w) / 2 - 1) . " vsplit new"),
    \ "h": ("silent rightbelow " . float2nr((winwidth('%') - l:w) / 2 - 1) . " vsplit new"),
    \ "j": ("silent leftabove " . float2nr(winheight('%') * (1 - g:dfm_height) / 2 - 1) . " split new"),
    \ "k": ("silent rightbelow " . float2nr(winheight('%') * (1 - g:dfm_height) / 2 - 1) . " split new"),
    \ }
  if (s:dfm_enabled == 0)
    let s:dfm_enabled = 1
    for key in keys(l:margins)
      execute l:margins[key] . " | wincmd " . key
    endfor
    colorscheme summerfruit256
    for key in ['NonText', 'VertSplit', 'StatusLine', 'StatusLineNC']
      execute 'hi ' . key . ' guifg=white guibg=white'
    endfor
    highlight Cursor guifg=white guibg=gray55
    highlight iCursor guifg=white guibg=gray55
    set linebreak | syntax off
    if has('gui_gtk2')
      set guifont=Iosevka\ Term\ 12
    elseif has('gui_win32')
      set guifont=Iosevka_NF:h12:W500
    endif
    map j gj
    map k gk
  else
    let s:dfm_enabled = 0
    for key in keys(l:margins)
      execute "wincmd " . key . " | close "
    endfor
    set nolinebreak | syntax on
    colorscheme PaperColor
    hi StatusLine guibg=grey70 guifg=white
    highlight Cursor guifg=white guibg=red
    highlight iCursor guifg=white guibg=steelblue
    if has('gui_gtk2')
      set guifont=Iosevka\ Term\ 12
    elseif has('gui_win32')
      set guifont=Iosevka_NF:h12
    endif
    unmap j
    unmap k
  endif
endfunction
