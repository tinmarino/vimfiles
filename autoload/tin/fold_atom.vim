" From: https://vi.stackexchange.com/questions/2157/collapse-vim-folds-to-a-single-line-similar-to-atom-or-sublime-text
"let g:regexp_blank = '^\s*$\|^\s*[#"/]'
let g:regexp_blank = '^\s*$'
let g:next_close = -1
let g:fold_close =  '^\s*\(}\|fi\|end.*\)\s*$'


" Finds the indent of a line. The indent of a blank line is the indent of the
" first non-blank line above it.
function! FindIndent(line_number, indent_width) abort
  " Regular expression for a "blank" line
  let non_blank_line = a:line_number
  while non_blank_line > 0 && getline(non_blank_line) =~ g:regexp_blank
    let non_blank_line = non_blank_line - 1
  endwhile
  return indent(non_blank_line) / a:indent_width
endfunction


" 'foldexpr' for Atom-style indent folding
function! tin#fold_atom#atom_fold_expr(line_number) abort
  " Indent Fold Enhanced for single line
  " -- set foldexpr=AtomStyleFolding(v:lnum)
  if getline(a:line_number) =~# g:regexp_blank
    if getline(a:line_number+1) =~# g:regexp_blank
      return '='
    endif
    let res = g:next_close
    let g:next_close = '='
    return res
  endif
 
  let indent_width = &shiftwidth

  " Find current indent
  let indent = FindIndent(a:line_number, indent_width)

  " Now find the indent of the next line
  let indent_below = FindIndent(a:line_number + 1, indent_width)

  " Calculate indent level
  if indent_below > indent
    return indent_below
  elseif getline(a:line_number) =~# g:fold_close
    let res = '<' . (indent + 1)
    if getline(a:line_number+1) =~# g:regexp_blank
      let g:next_close = res
      return '='
    else
      let g:next_close = '='
      return res
    endif
  elseif indent_below < indent && getline(a:line_number + 1) !~# g:fold_close
    return '<' . indent
  else
    return indent
  endif
endfunction


function! tin#fold_atom#atom_fold_text() abort
  " Get number of col
  let nucolwidth = &foldcolumn + &number*&numberwidth
  " Hardcode 2 for ALE Lint
  let winwd = winwidth(0) - nucolwidth - 2
  " Hardcode
  let comment_col = 30

  " Get Number of lines
  let foldlinecount = foldclosedend(v:foldstart) - foldclosed(v:foldstart) + 1

  " Get comment
  let comment = getline(v:foldstart + 1)
  let comment = substitute(comment, '^\s*[`#"'']*', '', 1)
  let comment = substitute(comment, '[`#"'']*\s*$', '', 1)

  " String build
  let fdnfo = repeat('>', v:foldlevel) . ' ' . string(foldlinecount)
  let name =  strpart(getline(v:foldstart), 0 , winwd - len(fdnfo))
  "echom 'Tin name ' len(name) .','. len(fdnfo)
  let comment_start = max([len(name)+2, comment_col])
  let comment_width = max([0, winwd - len(fdnfo) - 6 - comment_start])
  let comment = comment[0: comment_width -1]

  " Printf and return
   let line=printf('%-' . comment_col . 's     %-' . comment_width . 's %' . len(fdnfo) . 's', name, comment, fdnfo)
  "echom line
  return line
endfunction

function! tin#fold_atom#main(...) abort
  set foldmethod=expr
  set foldexpr=tin#fold_atom#atom_fold_expr(v:lnum)
  set foldtext=tin#fold_atom#atom_fold_text()
endfunction
