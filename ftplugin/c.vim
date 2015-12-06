
" FOLD
  set foldmethod=expr
  set foldexpr=FoldCMethod(v:lnum)

  function! FoldCMethod(lnum)
    let crLine = getline( a:lnum ) 
    " check if { or }
    if crLine =~ "\s*[{}]\s*" 
      if crLine =~ ".*{.*"
        return FoldMethod(a:lnum+1) "value of the next line   
      else 
	return FoldMethod(a:lnum-1) "value of the previous line + 0 
      endif 
    endif 
    return FoldMethod( a:lnum )
  endfunction 
