

" Plugin
  let s:pymode=exists('g:pymode')
  packadd python-mode
  packadd ipython
  if !s:pymode | edit | endif

" Better ?
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

