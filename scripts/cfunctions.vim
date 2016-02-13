
function! Cinit()
  let l:tet  = '#include "' . split(expand("%:p"),'\')[-1][:-2]  . 'h"' 
  let l:tet .= "\n"
  let l:tet .= "#include <stdio.h>"
  let l:tet .= "\n\n\n\n\n\n"
  let l:tet .= "int main(int arg, char** argv)\n"
  let l:tet .= "{\n\n}\n"

  " The next three lines works  or you can use append 
  let @t=l:tet
  execute "normal! 1G"
  execute "put t"
  execute "normal! 1Gdd9j"

endfunction


command! -nargs=* -complete=command Cinit call Cinit(<f-args>)
