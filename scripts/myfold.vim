
"FOLDING, and folding maps 
  	highlight Folded ctermfg=DarkGreen ctermbg=Black
  	set foldmethod=indent
  	" set foldexpr=FoldMethod(v:lnum)
  	"autocmd FileType vim set foldmethod=indent " I don't need to fold comments in vim files 
  	set shiftwidth=4  " the number of column taken into account for aa fold, IMPORTANT
  	
  	function! FoldMethod(lnum)
  	  let crLine=getline(a:lnum)
 
  	  " check if empty line 
  	  if crLine =~ '^\s*$' || crLine[0]== "#" "Empty line or end comment 
  	    return '=' " so same indent level as line before
  	  endif 


  	  " check if comment  in syntax
  	  let l:data =  join( map(synstack(a:lnum, 1), 'synIDattr(v:val, "name")') )
  	  if l:data =~ ".*omment.*"
  	    "return max([FoldMethod(a:lnum+1), FoldMethod(a:lnum-1) ]) 
  	    return '-1'

  	  endif


  	"Otherwise return foldlevel equal to ident /shiftwidth (like if
  	"foldmethod=indent)
  	    "return indent base fold
  	  return indent(a:lnum)/&shiftwidth

  	endfunction

  	


  	set foldcolumn=0  "the number of columns on the left to show the tree, default =0 
  	set foldlevelstart=30 "the folding at opening
