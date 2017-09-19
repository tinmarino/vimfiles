
" TAB
  set tabstop=4
  set expandtab


" Apperance  
  set tw=78
  set noreadonly
  set modifiable


" FOLD 
  set foldmethod=expr
  set foldexpr=FoldMyHelpMethod(v:lnum)

  function! FoldMyHelpMethod(lnum)
    let crLine = getline( a:lnum )
    if crLine =~ '^====\+$'
      return 0 
    endif 

    return FoldMethod( a:lnum ) 
  endfunction 
