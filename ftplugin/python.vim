

" Plugin
  let s:pymode=exists('g:pymode')
  packadd python-mode
  packadd ipython
  if !s:pymode | edit | endif

" Better ?
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set expandtab

" PEP 8
    set textwidth=79
    set autoindent
    set fileformat=unix
    set nowrapscan


    set foldmethod=indent

