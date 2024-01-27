" Distraction-free mode
" Originally based on: https://zserge.com/posts/vim-distraction-free/

let g:dfm_width = 80 "absolute width or percentage, like 0.7
let g:dfm_height = 0.8

let s:dfm_enabled = 0
let g:gf_orig = &guifont
let g:current_colorscheme = g:colors_name

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
    if has('gui_gtk')
      let l:gf_size_current = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_font_setting = "IosevkaTerm Nerd Font Mono Medium " . l:gf_size_current
      let &guifont = l:gf_font_setting
    elseif has('gui_win32')
      let l:gf_size_current = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_font_setting = "IosevkaTerm_NFM_Medium:h" . l:gf_size_current . ":W500"
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
    execute 'colorscheme ' . g:current_colorscheme
    let &guifont = g:gf_orig
    unmap j
    unmap k
    cnoremap q q
  endif
endfunction
