

function! search#char_range(char, dir)
  " Get string with range or '' if < 0 or > 9

  if a:dir
	let l:res = string( str2nr(a:char) + 1 )
	if (l:res == 10) | return '' | endif
	let l:res = '[' . l:res . '-9]'
  else
	let l:res = string( str2nr(a:char) - 1)
	if (l:res == -1) | return '' | endif
	let l:res = '[0-' . l:res . ']'
  endif

  return l:res
endfunction


function! search#isearch(num, dir, inc)
  " Search any number supp to 9
  " 
  " Number: 	(number)  Limiting the range
  " Direction:	(boolean) Higher if true
  " Inclusive:  (boolean) Do the number is include >= or <= 
  "

  let l:start_of_number = '\%([^0-9.]\zs\|^\)'
  let l:pat_list = [l:start_of_number]
  
  " Get hight and low
  let l:list = split(a:num, '\.')
  let l:high = l:list[0]
  if (len(l:list) > 1)
	let l:low = l:list[1]
  else
	let l:low = ''
  endif


  " 1/ High loop
  " ~~~~~~~~~~~~
  for l:c in split(l:high, '\zs')
	" Get the higher range [-]
	let l:range = search#char_range(l:c, a:dir)
	if (l:range == '') | break | endif
	let l:pat = l:pat_list[0] . l:range
	if (a:dir == 0 && l:pat_list[0] == l:start_of_number) 
	  let l:pat .= '\?'
	endif
	call add(l:pat_list, l:pat)

	" Add \d to previous guys
	for i in range(1, len(l:pat_list) - 2)
	  let l:pat_list[i] .= '\d'
	endfor

	" Add to initial pattern
	let l:pat_list[0] .= l:c
  endfor

  " 1.2/ Include with more digit
  if a:dir
	let l:biggest =  l:start_of_number . '\d*\d\{' . string(len(l:pat_list)) . '}'
	call add(l:pat_list, l:biggest)
  endif

  " 1.3/ indlude rest (after .)
  for i in range(1, len(l:pat_list) - 1)
	let l:pat_list[i] .= '\%(\.\d*\)\?\%(\ze\D\|$\)'
  endfor


  " 2/ Low loop
  " ~~~~~~~~~~~
  if (len(l:low) != '')
	let l:pat_list[0] .= '\.'
  else
	let l:pat_list[0] .= '\.\?'
  endif
  for l:c in split(l:low, '\zs')
	" Get the higher range [-]
	let l:cp1 = string( str2nr(l:c) + 1 )
	if (l:cp1 == 10) | break | endif
	call add(l:pat_list, l:pat_list[0] . '[' . cp1 . '-9]\d*')

	" Add to initial pattern
	let l:pat_list[0] .= l:c
  endfor

  " 3/ Add the number itself
  if a:inc
	let l:pat = join(l:pat_list, '\|')
  else
	let l:pat = join(l:pat_list[1:], '\|')
  endif

  return l:pat
endfunction


function! search#wrapper(...)
  let l:pat = ''
  for l:i in range(len(a:000))
	" TODO check if there is a number after
	if (a:000[l:i] == '>=')
	  if (l:pat != '') | let l:pat .= '\&' | endif
	  let l:pat .= '\%(' . search#isearch(a:000[l:i+1], 1, 1) . '\)'
	elseif (a:000[l:i] == '>')
	  if (l:pat != '') | let l:pat .= '\&' | endif
	  let l:pat .= '\%(' . search#isearch(a:000[l:i+1], 1, 0) . '\)'
	elseif (a:000[l:i] == '<=')
	  if (l:pat != '') | let l:pat .= '\&' | endif
	  let l:pat .= '\%(' . search#isearch(a:000[l:i+1], 0, 1) . '\)'
	elseif (a:000[l:i] == '<')
	  if (l:pat != '') | let l:pat .= '\&' | endif
	  let l:pat .= '\%(' . search#isearch(a:000[l:i+1], 0, 0) . '\)'
	endif
  endfor

  echo l:pat
  execute "normal! /" . l:pat . "\<CR>"
endfunction

command! -nargs=* Isearch call search#wrapper(<f-args>)
