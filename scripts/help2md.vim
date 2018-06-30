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

