" Plugin
packadd table-mode

set linebreak

map <leader>c :VimwikiAll2HTML<CR><CR>:syntax on<CR>
so $v/pack/bundle/opt/vimwiki/ftplugin/vimwiki.vim
set tw=0
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2


" Syntax
function! s:syntax_helper(alias, language, syntax_file)
  let b:current_syntax = ""
  unlet b:current_syntax
  execute('syntax include ' . a:alias . ' ' . a:syntax_file)
  execute('syntax region ' . a:language . 'Snip matchgroup=Snip start="```' . a:language . '" end="```" contains=' . a:alias)
endfunction

" Text
syntax region White start=+```+   end=+```+
hi White ctermfg=White  guifg=White

" Compiled
call s:syntax_helper('@MYC', 'c', 'syntax/c.vim')
call s:syntax_helper('@MYCPP', 'cpp', 'syntax/cpp.vim')

" Script
call s:syntax_helper('@MYBASH', 'bash', 'syntax/sh.vim')
call s:syntax_helper('@MYPYTHON', 'python', 'syntax/python.vim')
call s:syntax_helper('@MYVIM', 'vim', 'syntax/vim.vim')
call s:syntax_helper('@MYPERL', 'perl', 'syntax/perl.vim')

" Markdown
call s:syntax_helper('@MYHTML', 'html', 'syntax/html.vim')
call s:syntax_helper('@MYTEX', 'latex', 'syntax/tex.vim')


" Autobackup deleted lines if todo
augroup done_textyankpost
  autocmd!
  autocmd TextYankPost $HOME/wiki/todo/*.md  call s:textyankpost(v:event)
augroup END

" Callback : autobackup
function! s:textyankpost(dict)
  " Check
  if v:event['operator'] != 'd' | return | endif
  let $done = expand($h . '/wiki/todo/done.md')
  if expand('%:$') == $done | return | endif

  " Append to done
  let l:new_line = strftime(">%Y/%M/%d at %X : ") . string(a:dict['regcontents'])
  call writefile(a:dict['regcontents'], $done, 'a')
endfunction


