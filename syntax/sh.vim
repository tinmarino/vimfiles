if exists("b:current_syntax")
  finish
endif

" Include default sh
so $VIMRUNTIME/syntax/sh.vim

syn clear shExpr "TODO gere 

" test
syn region blue	matchgroup=shQuote start=+'+ end=+'+ skip=+\\'+ contains=@Spell	
hi blue ctermfg=cyan

" Include perl
let s:save_syntax = b:current_syntax
unlet b:current_syntax
syntax include @PERL syntax/perl.vim
let b:current_syntax = s:save_syntax
unlet s:save_syntax

" Define perl region
syntax region perlSnip matchgroup=Snip start=+p\(er\)\?l[^']*e\s*'+  end=+'+ contains=@PERL
