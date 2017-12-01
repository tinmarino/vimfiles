"
"
"
" 
" 
" 
let g:l_cal = ['cal_colosal.txt', 9, 15]                                
"let g:l_cal = ["cal_big.txt", 6, 9]
"let g:l_cal = ["cal_small.txt", 4, 6]
let g:operation = ''

" Get winwidth 
" TOOD chack and set the cal template
echom winwidth("%")

let s:d = 0

function! CalStart()
  enew!
  set hidden
  for i in range(g:l_cal[1] - 1)
    call append(0, [''])
  endfor
  execute 'r ' . $MYVIM . '/scripts/' . g:l_cal[0]
  nnoremap <buffer> <LeftMouse> <LeftMouse>:call CalRun()<CR>

  let s:array = readfile($MYVIM . '/scripts/cal.txt')
endfunction

function! AppendChar(x, y, char)
  if ('d' == a:char) | let g:operation = [:-2] | return | endif
  if ('=' == a:char)
    let l:result = eval(g:operation)
	let g:operation = ''
	for l:r in l:result
	  AppendChar(l:r)
	endfor
    return
  endif

  let g:operation .=  '' . a:char

  let l:slice_y = readfile($MYVIM . '/scripts/' . g:l_cal[0])
  let l:slice_y = l:slice_y[a:y * g:l_cal[1] : (a:y + 1) * g:l_cal[1]]

  let l:slice = []
  for l:line in l:slice_y
    call add(l:slice, l:line[a:x * g:l_cal[2] : (a:x + 1) * g:l_cal[2]])
  endfor

  for l:ln in range(g:l_cal[1] - 1)
    execute 'normal ' . string(l:ln + 1) . 'GA' . l:slice[l:ln]
  endfor

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


	call AppendChar(x, y, num)

endfunction                
