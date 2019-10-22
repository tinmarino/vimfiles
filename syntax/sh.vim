if exists("b:current_syntax")
  finish
endif

" Include default sh
so $VIMRUNTIME/syntax/sh.vim

" Include
  " Include perl
  let s:save_syntax = b:current_syntax
  unlet b:current_syntax

  syntax include @shPerlScript syntax/perl.vim
  unlet b:current_syntax
  syn include @shSedScript syntax/sed.vim

  let b:current_syntax = s:save_syntax
  unlet s:save_syntax


" Define Perl
  " Define perl region
  syn match shPerlLineContinuation "\\\s*$" contained skipempty nextgroup=shPerlExpression
  syn match shPerlExpression "\%(^\|\_s\+\)-\a*e\a*\_s\+" contained nextgroup=shPerlScriptCode
  syn region shPerlScriptCode matchgroup=shPerlCommand start=+[=\\]\@<!'+ skip=+\\'+ end=+'+ contains=@shPerlScript contained skipwhite skipempty nextgroup=shPerlLineContinuation,shPerlExpression
  syn region shPerlScriptEmbedded matchgroup=shPerlCommand start=+\<perl\>+ skip=+\\$+ end=+[=\\]\@<!'+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shPerlScriptCode
  syn cluster shCommandSubList add=shPerlScriptEmbedded


" Define Sed
  " Define Sed
  syn match shSedLineContinuation "\\\s*$" contained skipempty nextgroup=shSedExpression
  syn match shSedExpression "\%(^\|\_s\+\)-\a*e\a*\_s\+" contained nextgroup=shSedScriptCode
  syn region shSedScriptCode matchgroup=shSedCommand start=+[=\\]\@<!'+ skip=+\\'+ end=+'+ contains=@shSedScript contained skipwhite skipempty nextgroup=shSedLineContinuation,shSedExpression
  syn region shSedScriptEmbedded matchgroup=shSedCommand start=+\<sed\>+ skip=+\\$+ end=+[=\\]\@<!'+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shSedScriptCode
  syn cluster shCommandSubList add=shSedScriptEmbedded


" Link
  " Perl
  hi def link shPerlCommand Statement
  hi def link shPerlExpression shSetOption
  " Sed
  hi def link shSedCommand Statement
  hi def link shSedExpression shSetOption
