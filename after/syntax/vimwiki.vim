" See vimwiki #1275
" Ref
" let neutral_red    = ['#cc241d', 124]     " 204-36-29
" let neutral_green  = ['#98971a', 106]     " 152-151-26
" let neutral_yellow = ['#d79921', 172]     " 215-153-33
" let neutral_blue   = ['#458588', 66]      " 69-133-136
" let neutral_purple = ['#b16286', 132]     " 177-98-134
" let neutral_aqua   = ['#689d6a', 72]      " 104-157-106
" let neutral_orange = ['#d65d0e', 166]     " 214-93-14
" TODO, DONE, STARTED, FIXME, FIXED, XXX.
" syntax keyword myTODO TODO
" highlight myTodo ctermfg=124 guifg=#cc241d

for [keyword, ctermfg, guifg] in [
      \ ['TODO', 124, '#cc241d'], 
      \ ['DONE', 106, '#98971a'], 
      \ ['STARTED', 66, '#d79921'], 
      \ ['FIXME', 132, '#458588'], 
      \ ['FIXED', 72, '#689d6a'], 
      \ ['XXX', 166, '#d65d0e'], 
      \ ]
  execute 'syn keyword my' . keyword . ' ' . keyword
  execute 'hi my' . keyword . ' ctermfg=' . ctermfg . ' guifg=' . guifg 
endfor
