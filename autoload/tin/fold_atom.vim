" From: https://vi.stackexchange.com/questions/2157/collapse-vim-folds-to-a-single-line-similar-to-atom-or-sublime-text
"let g:regexp_blank = '^\s*$\|^\s*[#"/]'
let g:regexp_blank = '^\s*$'
let g:next_close = '='
let g:fold_close =  '^\s*\(};\?\|fi\|end.*\)\s*$'


function! FindIndentHere(line_number, indent_width) abort
  " Finds the indent of a line. The indent of a blank line is the indent of the
  " first non-blank line above it.
  " Regular expression for a "blank" line
  let non_blank_line = a:line_number
  while non_blank_line > 0 && getline(non_blank_line) =~ g:regexp_blank
    let non_blank_line = non_blank_line - 1
  endwhile
  return indent(non_blank_line) / a:indent_width
endfunction


function! FindIndentNext(line_number, indent_width) abort
  " Find next non "bad" indented line
  let non_blank_line = a:line_number+1
  while non_blank_line < line('$') && getline(non_blank_line) =~ g:regexp_blank
    let non_blank_line = non_blank_line + 1
  endwhile
  return indent(non_blank_line) / a:indent_width
endfunction

function! tin#fold_atom#atom_fold_expr(line_number) abort
  " 'foldexpr' for Atom-style indent folding
  " Indent Fold Enhanced for single line
  " -- set foldexpr=AtomStyleFolding(v:lnum)
  " TODO Read the doc if want =, -1. Comment more (important function)

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
  let indent = FindIndentHere(a:line_number, indent_width)

  " Find the indent of the next line
  let indent_below = FindIndentNext(a:line_number, indent_width)


  " Calculate indent level

  if getline(a:line_number) =~# g:regexp_blank
    if getline(a:line_number+1) =~# g:regexp_blank
      return '='
    endif
    let res = g:next_close
    let g:next_close = '='
    return res
  endif

  " TODO more complicated, mus close
  "if getline(a:line_number) =~# g:fold_close
    "return indent+1

  if indent_below > indent
    " If next indent increases increases: Take it
    " -- So the current line belongs to the fold region
    return indent_below

  "elseif indent_below == indent && getline(a:line_number) =~# g:fold_close
      "return '<' . (indent_below+1)

  elseif indent_below < indent
        \ || (indent_below == indent && getline(a:line_number) =~# g:fold_close)
    " If I must close
    if getline(a:line_number) =~# g:fold_close
      if getline(a:line_number+1) =~# g:fold_close
        " If delimiter
        let res = indent
        let g:next_close = '='
      else
        let g:next_close = '<' . (indent_below+1)
        let res = FindIndentHere(a:line_number-1, indent_width)
      endif

    elseif getline(a:line_number+1) =~# g:fold_close
      " If delimiter
      let res = indent

    else
      " Else Just close at next non-blank
      let g:next_close = '<' . (indent_below+1)
      let res = indent
    endif

    if getline(a:line_number+1) !~# g:regexp_blank
      let res = g:next_close
      let g:next_close = '='
    endif

    return res

  else
    return indent
  endif
endfunction


function! tin#fold_atom#atom_fold_text() abort
  " Hi

  " Get number of col
  " -- fold, number 
  let nucolwidth = &foldcolumn + &number*&numberwidth
  " -- ALE sign
  let ale_sign = len(sign_getplaced('%', {'group':'ale'})[0].signs) == 0 ? 0 : 2
  let winwd = winwidth(0) - nucolwidth - ale_sign
  " -- comment column
  let comment_col = float2nr(winwd * 0.4)
  let comment_col = max([30, comment_col])

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
  let comment_start = max([len(name)+2, comment_col+2])
  let comment_width = max([0, winwd - len(fdnfo) - 4 - comment_start])
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
