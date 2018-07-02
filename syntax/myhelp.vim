" Tinamrino help syntax file



syn keyword arrow -> 
"hi arrow term=reverse ctermfg=gray ctermbg=red guifg=gray guibg=red3
hi arrow	term=underline ctermfg=green guifg=green


syn match helpSectionDelim	"^=.*$"
syn match helpSectionDelim	"^=.*_"

" For cheatography
" a ... means anything
syn match helpMeta              "\.\.\."
" my keywords to be replaced (from Python)
syn keyword helpMeta            statement statements expression var value key key: collection expr old new num  arg1 arg2 arg3 op start end item delim lst name prompt index seq
syn keyword helpMeta            s x t n e i d
" TODO remove
hi helpMeta ctermfg=lightgreen cterm=italic guifg=lightgreen gui=italic
" TODO True False




"Here I add (martin) 

"syn match	vimComment	+^[ \t:]*".*$+  	contains=helpCommentString 
"syn match	vimComment	excludenl +\s"[^\-:.%#=*].*$+lc=1	contains=helpCommentString
"syn region	helpCommentString	contained oneline start='\S\s\+"'ms=e	end='"'


" syn match vimComment +"[^"]*$+  
"hi def link helpCommentString 	helpString

" syn region	helpString	oneline keepend	start=+[^:a-zA-Z>!\\@]"+lc=1 skip=+\\\\\|\\"+ end=+"+	contains=@vimStringGroup
" syn region	helpString	oneline keepend	start=+[^:a-zA-Z>!\\@]'+lc=1 end=+'+


" Get vim keywords
"let s:path = expand('<sfile>:p:h') . "/vimkeyword.vim"
"execute 'source '.  s:path


" WITH VIM SYNTAX 
let b:current_syntax = ""
unlet b:current_syntax
syntax include @MYVIM syntax/vim.vim
if has("conceal")
  set conceallevel=2
  syntax region vimSnip matchgroup=Snip start=">vim"  end="<vim" concealends  contains=@MYVIM
else
  syn region vimSnip 	matchgroup=Snip start=">vim"  end="<vim" contains=@MYVIM
endif

"
"WITH BASH SYNTAX 
let b:current_syntax = ""
unlet b:current_syntax
syntax include @MYBASH syntax/sh.vim
if has("conceal")
  set conceallevel=2
  syntax region bashSnip matchgroup=Snip start=">bash"  end="<bash" concealends  contains=@MYBASH
else
  syntax region bashSnip matchgroup=Snip start=">bash"  end="<bash" contains=@MYBASH 
endif


"WITH PYTHON SYNTAX
let b:current_syntax = ""
unlet b:current_syntax
syntax include @MYPYTHON syntax/python.vim
if has("conceal")
  set conceallevel=2
  syntax region pythonSnip matchgroup=Snip start=">python"  end="<python" concealends  contains=@MYPYTHON
else
  syntax region pythonSnip matchgroup=Snip start=">python"  end="<python" contains=@MYPYTHON
endif


"WITH C SYNTAX
let b:current_syntax = ""
unlet b:current_syntax
syntax include @C syntax/c.vim
if has("conceal")
  set conceallevel=2
  syntax region pythonSnip matchgroup=Snip start=">c"  end="<c" concealends  contains=@C
else
  syntax region pythonSnip matchgroup=Snip start=">c"  end="<c" contains=@C
endif


" Good and bad background (Gstyle)
syntax match Good  '\cGood:'
syntax match Bad   '\cBad:'
"syntax region Bold matchgroup=Snip start='\*\*' end='\*\*' concealends

" Green1
hi Good cterm=underline ctermfg=darkgreen guifg=darkgreen
" Red1
hi Bad cterm=underline ctermfg=darkred guifg=darkred  
hi Bold cterm=bold




unlet b:current_syntax
runtime! syntax/help.vim

let b:current_syntax = "myhelp"
" vim: ts=8 sw=2
