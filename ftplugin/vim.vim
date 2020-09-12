
" Compile is sourcing
nnoremap <leader>c :update \| :so %<CR>:echo 'file sourced ' . expand('%')<CR>

"set foldmethod=indent
"set foldexpr=FoldVimMethod(v:lnum)

function! FoldVimMethod(lnum)
  " check if endfunction or endif endfo for vim syntax 
  let crLine = getline( a:lnum ) 
  if crLine =~ '\s*end\(function\|for\|if\)\s*'
	return '=' "the foldlevel of previous line 
  endif 
  return FoldMethod( a:lnum )  
endfunction 
