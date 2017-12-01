7"
"call append(line('$'), l_cal)
"1r ./ca	
" noremap <LeftMouse> <LeftMouse>:call CalRun()<CR>

" filename, line col (of one char plus one 
" cause with non touchable spaces between lines)
let g:l_cal = ["cal_colosal.txt", 9, 15]
"let g:l_cal = ["cal_big.txt", 6, 9]
"let g:l_cal = ["cal_small.txt", 4, 6]
let g:operation = ''

" Get winwidth 
echom winwidth("%")


function! CalStart()
  enew!
  set hidden
  for i in range(g:l_cal[1])
    call append(0, [''])
  endfor
  execute 'r ' . $MYVIM . '/scripts/' . g:l_cal[0]
  nnoremap <LeftMouse> <LeftMouse>:call CalRun()<CR>

  let s:array = readfile($MYVIM . '/scripts/cal.txt')
endfunction

function! AppendChar(char)
  if ('d' == a:char) | let g:operation = [:-2] | endif
endfunction

function! CalRun()
  	" get touch
	let l_cur = getcurpos()
	let i_line = l_cur[1]
	let i_col = l_cur[2]

	" convert to number
	let y = (i_line - g:l_cal[1]) / g:l_cal[1]
	let x = i_col / g:l_cal[2]
    let num = s:array[y][x]

    "
	if exists('num')
		let g:operation .=  "" . num
        echom 'touching ' . num
	endif

	call AppendChar(num)

    " Dbg
    echom "Current operation: " . g:operation 
    let g:result = eval(g:operation)
    echom "Result: " . g:result 

	call PrintEquation("", g:result)

endfunction

function! PrintEquation(operation, result)
  	let @f=g:result
	normal 1GddO
    normal 1G"fP
endfunction
