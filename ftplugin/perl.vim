" First pl load
if !exists('g:ftpl_reloaded')
  let g:ftpl_reloaded = 0
endif

" Plugin
packadd jupyter

set tabstop=4
set softtabstop=4
set shiftwidth=4

" Reload
if !g:ftpl_reloaded
  let g:ftpl_reloaded = 1
  edit
endif
