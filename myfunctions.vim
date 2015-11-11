

function! WithWithoutFunc(word1,word2)
"function! WithWithoutFunc(word1,word2)
"normal! /^\(\(.*end.*\)\@!.*func.*\)$
  " Marks line without the word1 but without word2
  " Word can be a regex but it is preceded by .* and followed by .* in the
  " executed pattern 
  echom a:word1
  "call search ("^\\(\\(.*" . a:word2 . ".*\\)\\@!.*" . a:word1 . ".*\\)$")
  "call matchadd('Search',"^\\(\\(.*" . a:word2 . ".*\\)\\@!.*" . a:word1 . ".*\\)$" )
  "this one is dangerous 

  echom "normal! /^\\(\\(.*" . a:word2 . ".*\\)\\@!.*" . a:word1 . ".*\\)$\<CR>"
  "set hlsearch 
  execute "/^\\(\\(.*" . a:word2 . ".*\\)\\@!.*" . a:word1 . ".*\\)$"
endfunction

function! TestFunc(word) 
  execute "normal /" . a:word . "\<CR>"
endfunction



    function! RangeMatch(min,max) 
      let l:res = RangeSearchRec(a:min,a:max)
      execute "/" . l:res 
      let @/=l:res
    endfunction  

    "TODO if both number don't have same number of digit 
    function! RangeSearchRec(min,max) " suppose number with the same number of digit 
	if len(a:max) == 1 
	  return '[' . a:min . '-' . a:max . ']'
	endif 
	if a:min[0] < a:max[0]  
	  " on cherche de a:min jusqu'à 99999 x times puis de (a:min[0]+1)*10^x à a:max[0]*10^x
	  let l:zeros=repeat('0',len(a:max)-1) " string (a:min[0]+1 +) 000000

	  let l:res = '\%(' . a:min[0] .  '\%(' . RangeSearchRec( a:min[1:],   repeat('9',len(a:max)-1) ) . '\)\)' " 657 à 699

	  if a:min[0] +1 < a:max[0]
	    let l:res.= '\|' . '\%(' 
	    let l:res.= '[' . (a:min[0]+1) . '-' .  a:max[0] . ']' 
	    let l:res.= '\d\{' . (len(a:max)-1) .'}' . '\)' "700 a 900
	  endif 

	  let l:res.= '\|' . '\%(' . a:max[0] .  '\%(' . RangeSearchRec( repeat('0',len(a:max)-1) , a:max[1:] ) . '\)\)' " 900 a 957 

	  return l:res
	else 
	  return  '\%(' . a:min[0] . RangeSearchRec(a:min[1:],a:max[1:]) . '\)' 
	endif 
    endfunction 
    command! -nargs=* Range  call RangeMatch(<f-args>) 

fun! X()
  execute "/function"
  let @/ = 'function'
endfunction

command! -nargs=* WithWithout call WithWithoutFunc(<f-args>)
command! -nargs=* Test call TestFunc(<f-args>)
" 	If your script is using functions, then this quote from :help
" 	function-search-undo is relevant:
"
" 	    The last used search pattern and the redo command "." will not be
" 	    changed by the function. This also implies that the effect of
" 	    :nohlsearch is undone when the function returns.
"
