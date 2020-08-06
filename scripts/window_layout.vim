
" From: https://vi.stackexchange.com/a/22545/5026
" Called: rename_link
"
function vimwiki#u#save_win_layout() abort
  if !(v:version > 801 || has('patch-8.1.0307'))
    return
  endif
  let s:layout = winlayout()
  let s:resize_cmd = winrestcmd()
  call s:add_buf_to_layout(s:layout)
endfunction


function vimwiki#u#restore_win_layout() abort
  if !(v:version > 801 || has('patch-8.1.0307'))
    return
  endif
  " Clause: must be save first
  if !exists('s:layouts')
    return
  endif

  " Create clean window
  new
  wincmd o

  " Restore buffers recursively
  call s:apply_layout(s:layout)

  " Resize windows
  exe s:resize_cmd
endfunction


" Replace buffer in layout
" Warning give me an exetended layout: passed in add_buf
function vimwiki#u#replace_buf_in_layout(buf_old, buf_new, ...) abort
  if !(v:version > 801 || has('patch-8.1.0307'))
    return
  endif
  " Get in
  let layout = a:0 ? a:1 : s:layout

  " Leave: Try to replace if in leaf
  if layout[0] ==# 'leaf'
    if len(layout) > 2 && layout[2] == a:buf_old
      let layout[2] = a:buf_new
    endif
    return
  endif

  " Recurse otherwise
  for child_layout in layout[1]
    call vimwiki#u#replace_buf_in_layout(a:buf_old, a:buf_new, child_layout)
  endfor
endfunction


" Append bufnr to leaves: Recursively parse the layout list
" <- ['row', [['leaf', 1002], ['leaf', 1005]]]
" -> ['row', [['leaf', 1002, 1], ['leaf', 1005, 6]]]
function s:add_buf_to_layout(layout) abort
  " Leave: Append bufnr if in leaf
  if a:layout[0] ==# 'leaf'
    call add(a:layout, winbufnr(a:layout[1]))
    return
  endif

  " Recurse otherwise
  for child_layout in a:layout[1]
    call s:add_buf_to_layout(child_layout)
  endfor
endfunction


" Apply saved layout
" Magical !
function s:apply_layout(layout) abort
  " Leave: Load buffer for leaf
  if a:layout[0] ==# 'leaf'
    if bufexists(a:layout[2])
      exe printf('b %d', a:layout[2])
    endif
    return
  endif

  " Split cols or rows, split n-1 times
  let split_method = a:layout[0] ==# 'col' ? 'rightbelow split' : 'rightbelow vsplit'
  let wins = [win_getid()]
  for child_layout in a:layout[1][1:]
    exe split_method
    let wins += [win_getid()]
  endfor

  " Recurse into child windows
  for index in range(len(wins) )
    call win_gotoid(wins[index])
    call s:apply_layout(a:layout[1][index])
  endfor
endfunction
