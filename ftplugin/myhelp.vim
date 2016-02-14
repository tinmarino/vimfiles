


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
