" CtrlP
  " Open buffer here
  let g:ctrlp_switch_buffer = ''
  " Cache
  let g:ctrlp_cache_dir ='$h/.cache/ctrlp'
  " replace $home by ~ in cache
  let g:ctrlp_tilde_homedir = 1
  let g:ctrlp_mruf_max = 50000
  " Use ag <- grep
  " if executable('ag')
  "   let g:ctrl_user_command = 'ag %s -l --nocolor -g ""'
  " endif
  " Ignore
  let g:ctrlp_cutom_ignore = {
    \ 'dir': '\.git$,undo/',
    \ 'file': 'log'
  \ }
  if $os !=? 'termux'
    " E like edit and closer to ctrl + <c-p> used to paste
    let g:ctrlp_map = '<C-E>'
    vnoremap <C-E> :<C-u>CtrlPMixed<CR>
  else
    " Because move up gives c-e
    let g:ctrlp_map = ',e'
  endif
  " Keep cache
  let g:ctrlp_clear_cache_on_exit = 0
  " Mixed to search in MRU, FIles, Buffers
  let g:ctrlp_types = ['buf', 'mru', 'fil']
  let g:ctrlp_cmd = 'CtrlPMixed'
  " Faster listing <- vim.globpath
  if $os ==? 'windows'
    let g:ctrlp_user_command = 'dir %s /-n /b /s /a-d'
  else
    let g:ctrlp_user_command = 'find %s -type f'
  endif

" vim:sw=2:ts=2:
