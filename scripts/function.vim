


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

	" Remove the space befroe : 
	%s/ :$/:/

	" put a space after ; or : in dic 
	%s/,\(\S\)/, \1/g
	%s/:\(\S\)/: \1/g

	" Remove spaces at the end 
	%s/ ^//
endfunction


function! Shuffle()
    return reltimestr(reltime())[-2:]
endfunction

function! GuidToBytes() range
    echom a:firstline
    echom a:lastline
    for l:line in range(a:firstline,a:lastline)
        call cursor(l:line, 1) 
        echom "cursor position :" . line(".")
        " first dword
        s:\v^(\x\x)(\x\x)(\x\x)(\x\x):\\x\4\\x\3\\x\2\\x\1
        " 2 word
        s:\v-(\x\x)(\x\x)\ze\X\x\x\x\x\X:\\x\2\\x\1:g
        " 1 word reversed (shit)
        s:\v-(\x\x)(\x\x)\ze\X:\\x\1\\x\2:g
        " last 6 bytes
        s:\v-(\x\x)(\x\x)(\x\x)(\x\x)(\x\x)(\x\x):\\x\1\\x\2\\x\3\\x\4\\x\5\\x\6
    endfor
endfunction    


command! -nargs=* Pyfix call Pyfix(<f-args>)
command! -range=% Guid2Bytes <line1>,<line2>call GuidToBytes()
