" Script to donload a web page and convert it here to markdown


function! s:Download(page)
  " Download the page and convert it
  execute '!pandoc -s -r html ' . a:page '-o %'

  " Keep only title and description
  let lst = []
  1,/\n^---/+1 s/\v(^title:.*|^description:)((^\S)@!\_.)*$/\=add(lst, submatch(0))[-1]/
  2,/\n^---/ d
  1
  pu=lst
  
  " Delete the div </?div
  g/^<.\?div[^>]*>/d
  
  " Remove the header : until =====

  " Remove the footer

  " Keep me line 1
  1
endfunction


command! -nargs=* Download call s:Download(<f-args>)
