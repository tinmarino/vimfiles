function! Main()
" Code blocks
%s/^\s*>\(\w*\)\s*$/```\1/
%s/<\w*\s*$/```\1/

" Title 0
0s/^\S*\s*\(.*\)/% \1/ | noh

" Titles 1
g/=====================/exe "normal! ddi# \<Esc>$daW"

" Titles 1
"g/---------------------/exe "normal! ddi# \<Esc>$daW"

" Titles 3
g/\~$/s/\(.*\)\~/### \1/

" Links
%s/^\s*\*\S*\*\s*$//
endfunction


" TOC
function! Toc()
  let s:toto = "g/^#/t3"

  " End the TOC
  let @s = "i*	[ly$A](#pi)"
  let @d = "0f(lvi(:s/\%V /-/gj0"
  let @f = "0f(lvi(guj0"

  " Make them code before search ^###
  let @t = "}o```textn{{}O```n"
endfunction

command! Toc call Toc()
