" Change fontsize
" F11 / S-f11 Increase guifont (1)
" F12 / S-f12 Increase guifont (2)
" Example: Consolas:h14:cANSI:qDRAFT 
" TODO put that in autoload if gui
" TODO restore window size
" TODO map with ctrl-+ ctrl--

function! FontSizeAdd(num)
  " Get font size and inc
  let l:gf_size_whole = matchstr(&guifont, ':h\zs\d\+')
  let l:gf_size_whole = l:gf_size_whole + a:num
  let l:new_font_size = ':h' . l:gf_size_whole
  " Change &guifont
  let l:guifont_old = &guifont
  let l:guifont_new = substitute(l:guifont_old, ':h\d\+', l:new_font_size, '')
  let &guifont=l:guifont_new
endfunction


if has("gui_running")
    nmap <S-F11> :call FontSizeAdd(-1)<CR>
    nmap <F11> :call FontSizeAdd(1)<CR>
    nmap <S-F12> :call FontSizeAdd(-5)<CR>
    nmap <F12> :call FontSizeAdd(5)<CR>
endif

