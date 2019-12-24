" Include
so $v/pack/bundle/opt/wiki/ftplugin/vimwiki.vim

" Plugin
packadd table-mode

" Ultisnip
UltiSnipsAddFiletypes markdown

" Preference
setlocal linebreak
setlocal tw=0
setlocal expandtab
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

" Alias
map <leader>c :Vimwiki2HTML<CR><CR>:syntax on<CR>


" Autobackup deleted lines if todo
augroup done_textyankpost
  autocmd!
  autocmd TextYankPost */wiki/todo/*.md  call <SID>textyankpost(v:event)
augroup END


" Callback : autobackup
function! s:textyankpost(dict)
  " Check
  if v:event['operator'] != 'd' | return | endif
  if expand('%:$') =~  '/wiki/todo/done.md' | return | endif

  " Append to done
  let l:new_line = a:dict['regcontents']
  let l:new_line[0] = strftime(">%Y/%M/%d at %X : ") . l:new_line[0]
  call writefile(l:new_line, $done , 'a')
endfunction
