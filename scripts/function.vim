


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
call Status2()
