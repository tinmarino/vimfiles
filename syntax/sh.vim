if exists("b:current_syntax")
  finish
endif

" Include default sh
so $VIMRUNTIME/syntax/sh.vim


" Remove sh.vim syntax 'in the way'
" Perl
syn clear shExpr
"syn clear shFunctionOne
" Sed
syn clear kshStatement
syn clear bashStatement



" Perl
" Include perl
let s:save_syntax = b:current_syntax
unlet b:current_syntax
syntax include @PERL syntax/perl.vim
let b:current_syntax = s:save_syntax
unlet s:save_syntax

" Define perl region
syntax region perlSnip matchgroup=Snip start=+p\(er\)\?l[^']*e\s*'+  end=+'+ contains=@PERL


" Sed
" Include Sed
let s:save_syntax = b:current_syntax
unlet b:current_syntax
syn include @shSedScript syntax/sed.vim
let b:current_syntax = s:save_syntax
unlet s:save_syntax

" Define Sed
syn match shSedLineContinuation "\\\s*$" contained skipempty nextgroup=shSedExpression
syn match shSedExpression "\%(^\|\_s\+\)-\a*e\a*\_s\+" contained nextgroup=shSedScriptCode
syn region shSedScriptCode matchgroup=shSedCommand start=+[=\\]\@<!'+ skip=+\\'+ end=+'+ contains=@shSedScript contained skipwhite skipempty nextgroup=shSedLineContinuation,shSedExpression
syn region shSedScriptEmbedded matchgroup=shSedCommand start=+\<sed\>+ skip=+\\$+ end=+[=\\]\@<!'+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shSedScriptCode
syn cluster shCommandSubList add=shSedScriptEmbedded

hi def link shSedCommand Type
hi def link shSedExpression shSetOption
