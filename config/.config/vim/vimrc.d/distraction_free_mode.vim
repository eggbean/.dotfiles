" Distraction-free mode
" Originally based on: https://zserge.com/posts/vim-distraction-free/

let g:dfm_width = 80 "absolute width or percentage, like 0.7
let g:dfm_height = 0.8

let s:dfm_enabled = 0
let g:gf_orig = &guifont

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
    if (&signcolumn == 'yes')
      let s:sigcol = 1
      set signcolumn=auto
    else
      let s:sigcol = 0
    endif
    set formatoptions+=a
    for key in keys(l:margins)
      execute l:margins[key] . " | wincmd " . key
    endfor
    for key in ['NonText', 'VertSplit', 'StatusLine', 'StatusLineNC']
      execute 'hi ' . key . ' guifg=#eeeeee guibg=#eeeeee'
    endfor
    highlight Cursor guifg=white guibg=gray55
    highlight iCursor guifg=white guibg=gray55
    set linebreak | syntax off
    if has('gui_gtk2') || has('gui_gtk3')
      let l:gf_size_current = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_font_setting = "Iosevka Term Medium " . l:gf_size_current
      let &guifont = l:gf_font_setting
    elseif has('gui_win32')
      let l:gf_size_current = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_font_setting = "Iosevka_NF:h" . l:gf_size_current . ":W500"
      let &guifont = l:gf_font_setting
    endif
    map j gj
    map k gk
    cnoremap q qa
  else
    let s:dfm_enabled = 0
    if (s:sigcol == 1)
      set signcolumn=yes
    endif
    set formatoptions-=a
    for key in keys(l:margins)
      execute "wincmd " . key . " | close "
    endfor
    set nolinebreak | syntax on
    colorscheme PaperColor
    hi StatusLine guibg=grey70 guifg=#eeeeee
    highlight Cursor guifg=white guibg=red
    highlight iCursor guifg=white guibg=steelblue
    if has('gui_gtk2') || has('gui_gtk3')
      let l:current_size = matchstr(&guifont, '\d\+$')
      let &guifont = substitute(g:gf_orig, '\s*\d\+$', '', '')
      let &guifont .= ' ' . l:current_size
    elseif has('gui_win32')
      let l:gf_size = matchstr(&guifont, '\(:h\)\@<=\d\+')
      let l:gf_weight = matchstr(g:gf_orig, ':\(W\d\+\)\?$')
      if empty(l:gf_weight)
        let &guifont = substitute(&guifont, ':\(W\d\+\)\?$', '', '')
      else
        let &guifont = substitute(&guifont, '\(:W\d\+\)\?$', ':'.l:gf_weight, '')
      endif
      let &guifont = substitute(&guifont, '\(:h\d\+\)\?$', ':h' . l:gf_size, '')
    endif
    unmap j
    unmap k
    cnoremap q q
  endif
endfunction
