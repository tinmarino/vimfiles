" Include
so $v/pack/bundle/opt/vimwiki/ftplugin/vimwiki.vim

" Plugin
packadd table-mode

" Ultisnip
UltiSnipsAddFiletypes markdown

" Preference
set nomodeline
set linebreak
set tw=0
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

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
