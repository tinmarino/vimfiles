" Script to donload a web page and convert it here to markdown


function! s:Download(page)
  " Download the page and convert it
  execute '!pandoc -s -r html ' . a:page '-o %'

  " Keep only title (todo and description)
  
  " Delete the div </?div
  
  " Remove the footer

endfunction


command! -nargs=* Download call s:Download(<f-args>)
