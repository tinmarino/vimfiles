"let l_cal =  ["123", "456", "789", 0]
"call append(line('$'), l_cal)
"1r ./ca	
" noremap <LeftMouse> <LeftMouse>:call CalRun()<CR>
noremap <RightMouse> <LeftMouse>:call CalRun()<CR>

" filename, line col (of one char plus one 
" cause with non touchable spaces between lines)
let g:l_cal = ["cal_colosal.txt", 9, 15]
"let g:l_cal = ["cal_big.txt", 6, 9]
"let g:l_cal = ["cal_small.txt", 4, 6]
let g:operation = ''

" Get winwidth 
echom winwidth("%")

function! CalStart()
  new
  only
  call append(0, ["", "", "", "", ""])
  r .vim/scripts/cal_small.txt
endfunction

function! AppendChar(char)
endfunction

function! CalRun()
  	" get touch
	let l_cur = getcurpos()
	let i_line = l_cur[1]
	let i_col = l_cur[2]

	" convert to number
	let y = (i_line - 1) / g:l_cal[1]
	let x = i_col / g:l_cal[2]

	if y == 0
	  if x == 0
		let num = "("
      elseif x == 1
		let num =  ")"
 	  elseif x == 2
		let num = ""
      elseif x == 3
		let g:operation = [:-2]
	  endif

	elseif y == 1
	  if x == 0
		let num = 7
      elseif x == 1
		let num = 8
 	  elseif x == 2
		let num = 9
      elseif x == 3
		let num = '/'
	  endif

	elseif y == 2
	  if x == 0
		let num = 4
      elseif x == 1
		let num = 5
 	  elseif x == 2
		let num = 6
      elseif x == 3
		let num = '*'
	  endif

	elseif y == 3
	  if x == 0
		let num = 1
      elseif x == 1
		let num = 2
 	  elseif x == 2
		let num = 3
      elseif x == 3
		let num = '-'
	  endif

	elseif y == 4
	  if x == 0
		let num = '.'
      elseif x == 1
		let num = 0
 	  elseif x == 2
		let num = '='
      elseif x == 3
		let num = '+'
	  endif

	endif
	
	if exists('num')
		let g:operation .=  "" . num
	endif

	call AppendChar(num)
	try
		"silent echom "I touched " . i_line . ", " . i_col . " x,y = " . x . "," . y 
		" echom "For num: " . num
		echom "Current operation: " . g:operation 
		call eval(g:operation)
		echom "I evaluated"
		let g:result = eval(g:operation)
		echom "Result: " . g:result 
	catch 
	endtry

	call PrintEquation("", g:result)

endfunction

function! PrintEquation(operation, result)
  	let @f=g:result
	normal 1GddO
    normal 1G"fP
endfunction
