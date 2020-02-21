" First py load
if !exists('g:ftpy_reloaded')
  let g:ftpy_reloaded = 0
endif

" Plugin
  packadd jupyter
  " packadd python-mode


" Better ?
    set wrap
    set colorcolumn=120
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set textwidth=0
    set expandtab

" PEP 8
    set autoindent
    set fileformat=unix
    set foldmethod=indent
    set foldignore=

" Reload
if !g:ftpy_reloaded
  let g:ftpy_reloaded = 1
  edit
endif
