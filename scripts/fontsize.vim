" TODO put that in autoload if gui
if has("unix")
    function! FontSizePlus ()
      let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole + 1
      let l:new_font_size = ' '.l:gf_size_whole
      let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
      let l:gf_size_whole = matchstr(&guifont, '\( \)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole - 1
      let l:new_font_size = ' '.l:gf_size_whole
      let &guifont = substitute(&guifont, ' \d\+$', l:new_font_size, '')
    endfunction

else " Including Windows

    function! FontSizePlus ()
      let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole + 1
      let l:new_font_size = ':h'.l:gf_size_whole
      let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction

    function! FontSizeMinus ()
      let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole - 1
      let l:new_font_size = ':h'.l:gf_size_whole
      let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
    endfunction
endif


function! FontSizeOldWin(inc)
  if (&guifont=='')
    let &guifont='Lucida_Console:h11:cANSI:qDRAFT'
  endif
  let l:gf_size_whole = matchstr(&guifont, ':h\zs\d\+\ze:')
  echom "Size is " . l:gf_size_whole
  let l:gf_size_whole = l:gf_size_whole + a:inc
  let l:new_font_size = ':h' . l:gf_size_whole . ':'
  let &guifont = substitute(&guifont, ':h\d\+:', l:new_font_size, '')
endfunction


if has("gui_running")
    nmap <S-F12> :call FontSizeMinus()<CR>
    nmap <F12> :call FontSizePlus()<CR>
endif

