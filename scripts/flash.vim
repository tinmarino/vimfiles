function! Flash()
    set cursorline cursorcolumn
    redraw
    sleep 500m
    set nocursorline nocursorcolumn
	redraw
endfunction

nnoremap <leader>f :call Flash()<CR>
