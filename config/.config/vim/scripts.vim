" Detect filetype from shebang
if did_filetype()
  finish
endif
if getline(1) =~# '^#!.*/bin/bash\>'
  setfiletype bash
elseif getline(1) =~# '^#!.*/bin/env\s\+bash\>'
  setfiletype bash
endif
