function! s:CtrlZ()
	call writefile([getcwd(),''], '/tmp/cd_vim', 'b')
    return "\<C-z>"
endfunction


" TODO cursor postion not moving
set nosecure
function! ShellRead(cmd)
  echom 'executing: ' . a:cmd
  execute 'r! ' . a:cmd
  delete c	
  return @c[:-2]
endfunction

function! ShellTmp(cmd)
  execute '!' . a:cmd . '> /tmp/vim_cmd'
  let res = readfile('/tmp/vim_cmd')
  return res[0]
endfunction

function! PidDad()
  echom "CdDad"
  let l:pts = ShellTmp('tty')
  echom 'on pts: ' . l:pts
  let l:pts = substitute(l:pts, '/dev/', '', '')
  let l:cmd = 'ps -f ax ' 
  let l:cmd .= '| grep ''' . pts . '\s*Ss'' '
  let l:cmd .= '| awk ''{print $2}'''
  let l:pid = ShellTmp(l:cmd)
  echom l:pid
  return l:pid
endfunction

function! PwdDad()
  let l:pid = PidDad()
  return ShellTmp('readlink /proc/' . l:pid . '/cwd')
endfunction 

function! CdDad()
  execute 'cd ' . PwdDad()
endfunction
nnoremap <leader>d :call CdDad()<CR>

function! R(cmd)
  execute 'r! ' . a:cmd
endfunction


nnoremap <expr> <C-z> <SID>CtrlZ()
