
" 	If your script is using functions, then this quote from :help
" 	function-search-undo is relevant:
"
" 	    The last used search pattern and the redo command "." will not be
" 	    changed by the function. This also implies that the effect of
" 	    :nohlsearch is undone when the function returns.

function! WithWithoutFunc(word1,word2)
  " Marks line without the word1 but without word2
  " Word can be a regex but it is preceded by .* and followed by .* in the
  " executed pattern 
  "normal! /^\(\(.*end.*\)\@!.*func.*\)$
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

"	To be called with a range 
function! IntToFloat(col) range
  let l:res =  a:firstline .','. a:lastline " the range 
  "submatch(1)
  let l:res.= 's:\('
  let l:res.= '^\s*' " maybe space at the begining
  let l:res.= '\%(\S\+\s\+\)' "Any non space followed by any space not counting as submatch 
  let l:res.= '\{' . (a:col-1) . '}' " Number of cols before 
  let l:res.= '\)'

  "submatch.2)
  let l:res.= '\(\S*\)' " digit I mean non space, see after what that is 

  "submatch.3)
  let l:res.= '\(.*\)' " the rest of the line 

  "replace 
  let l:res.= ':\=submatch(1) . "\t" . submatch(2) . ".0\t" . submatch(3)'
  
  "execute 
  let g:tmp=l:res
  execute l:res 
  "1040,$s:\(^\s*\%(\S\+\s*\)\{1}\)\(\d\+\.*\d*\)\(.*\):\=submatch(1) . "\t" . submatch(2) . ".0\t" . submatch(3)
  "let l:res+= ':^\%(\d\+\.*\d*\)\s\+\(\d*\.*\d*\):\=submatch(' . a:col . ') . ".0\t" .submatch(2)'
  "execute '1025,$s:^\(\d\+\.*\d*\)\s\+\(\d*\.*\d*\):\=printf("%f\t%f",submatch(' . a:col . ')/3.0, submatch(2) /3.0)'

endfunction

function! ColArith(col)  range 
  " ex: we add first and second column, write in first ( a new one )
  for l:line in range(a:firstline,a:lastline)
    let l:x1 = Getword(l:line,1)
    let l:x2 = Getword(l:line,2)
    let l:x3 = l:x1 + l:x2

    call setline(l:line, l:x3 . "\t" . getline(l:line))
  endfor 
endfunction

function! Getword(line,col)
  " Get the nth word of current line 
  " Todo not only on current line 
  "submatch(1)
  let l:match = '\('
  let l:match.= '^\s*' " maybe space at the begining
  let l:match.= '\%(\S\+\s\+\)' "Any non space followed by any space not counting as submatch 
  let l:match.= '\{' . (a:col-1) . '}' " Number of cols before 
  let l:match.= '\)'

  "submamatch.2)
  let l:match.= '\(\S*\)' " digit I mean non space, see after what that is 

  "submamatch.3)
  let l:match.= '\(.*\)' " the rest of the line 

  "replace 
  let l:result= '\=submatch(2)'
  
  "execute 
  "let g:tmp=l:res
  let g:line=getline('.')
  return substitute(getline(a:line),l:match,l:result,'g')
  
endfunction 

function! OutputSplitWindow(...)
  " this function output the result of the Ex command into a split scratch buffer
  let cmd = join(a:000, ' ')
  let temp_reg = @"
  redir @"
  silent! execute cmd
  redir END
  let output = copy(@")
  let @" = temp_reg
  if empty(output)
    echoerr "no output"
  else
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    put! =output
  endif
endfunction

function! Chapter(string)
  let l:tet  =repeat("=",80)
  let l:tet .= "\n" .  repeat(" ",50) . "*" . a:string . "*"
  let l:tet .= "\n" . a:string . ' ~'
  let l:tet .= "\n\t"

  " The next three lines works 
  let @t=l:tet
  "or can use append 
  execute "put t"

endfunction

function! GetIndex()
  " INIT ALL VARIABLES 
  let l:cursor = getpos(".")
  let b:index  = [] " The lines with ========================= 
  let b:titles = [] 
  let b:ref    = []
  execute 'g/' . repeat("=",80) . '/call add(b:index,line("."))'

  " READ THE FILE 
  while len(b:index) != 0 
    let b:lineNb = remove(b:index,0) 

    let b:line   =  getline(b:lineNb +1)
    if b:line =~ "^\\s*\\*\\(\\S*\\)\\*\\s*$"
      call add(b:ref, substitute( b:line  ,'\s*\*\([^*]*\)\*\s*' , "\\1" , "" )   )
    endif 

    let b:line   =  getline(b:lineNb +2)
      call add(b:titles, b:line[:-2]   )
  endwhile  

  " PREPARE THE BUFFER IN REG To paste 
  let @t=""
  let l:i=0
  while i<len(b:titles)  
    let @t .= (l:i+1) . "/ " . get(b:titles,i) . "\n"  " \n must be in \"\" these quotes 
    let i +=1
  endwhile 
   
  " PASTE AND RETURN 
  call setpos('.',l:cursor) 
  execute 'put t'
  return b:ref

endfunction 

function! Align()
  
endfunction


  "normal! G to go to the end 
command! -nargs=* -complete=command GetIndex call GetIndex(<f-args>)
command! -nargs=* -complete=command Chapter call Chapter(<f-args>)

command! -nargs=+ -complete=command Output call OutputSplitWindow(<f-args>)

command! -nargs=* WithWithout call WithWithoutFunc(<f-args>)
command! -nargs=* Test call TestFunc(<f-args>)

command! -nargs=* -range=% Int2Float <line1>,<line2>call IntToFloat(<f-args>)
command! -nargs=* -range=% Col2Arith <line1>,<line2>call ColArith(<f-args>)
"h command-range default is the whole file 
