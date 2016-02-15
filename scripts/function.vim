


function! Status2()

 "define 3 custom highlight groups
 hi User1 ctermbg=green ctermfg=red   guibg=green guifg=red
 hi User2 ctermbg=red   ctermfg=blue  guibg=red   guifg=blue
 hi User3 ctermbg=blue  ctermfg=green guibg=blue  guifg=green

 set statusline=
 set statusline+=%1*  "switch to User1 highlight
 set statusline+=%F   "full filename
 set statusline+=%2*  "switch to User2 highlight
 set statusline+=%y   "filetype
 set statusline+=%3*  "switch to User3 highlight
 set statusline+=%l   "line number
 set statusline+=%*   "switch back to statusline highlight
 set statusline+=%P   "percentage thru file
endfunction 
"call Status2()

function! AsciiList()
  let @a=""
  for i in range(256) 
    let l:tmp = printf("%03d : %02x : %c", i, i, i)
	let @A = l:tmp
	let @A = "\n"

  endfor 
endfunction
"call AsciiList()

	

function! Pyfix()
	" Change tabs with 4 spaces
	%s/\t/    /g

	" Remove spaces at the end 
	%s/ ^//

	" Remove the space befroe : 
	%s/ :$/:/

	" put a space after ; or : in dic 
	%s/,\(\S\)/, \1/g
	%s/:\(\S\)/: \1/g
endfunction

command! -nargs=* Pyfix call Pyfix(<f-args>)
