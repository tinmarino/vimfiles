" First py load
if !exists('g:ftpy_reloaded')
  let g:ftpy_reloaded = 0
endif

" Plugin
  packadd jupyter
  " packadd python-mode


" Better ?
  setlocal wrap
  setlocal colorcolumn=120
  setlocal tabstop=4
  setlocal softtabstop=4
  setlocal shiftwidth=4
  setlocal textwidth=0
  setlocal expandtab

" PEP 8
  setlocal autoindent
  setlocal fileformat=unix

" Reload
if !g:ftpy_reloaded
  let g:ftpy_reloaded = 1
  edit
endif
