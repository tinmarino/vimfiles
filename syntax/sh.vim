if exists("b:current_syntax")
  finish
endif

" Include default sh
source $VIMRUNTIME/syntax/sh.vim
let b:current_syntax = 'sh'

" Include
  unlet b:current_syntax
  syntax include @shPerlScript syntax/perl.vim

  unlet b:current_syntax
  syntax include @shSedScript syntax/sed.vim

  if ! exists("b:is_wiki_loaded")
    let b:is_wiki_loaded = 1
    source ~/.vim/pack/bundle/opt/wiki/plugin/vimwiki.vim
    source ~/.vim/pack/bundle/opt/wiki/autoload/vimwiki/base.vim
    unlet b:did_ftplugin
    source ~/.vim/pack/bundle/opt/wiki/ftplugin/vimwiki.vim

    unlet b:current_syntax
    syntax include @shWikiScript syntax/vimwiki.vim
    syn clear VimwikiH1Folding
    syn clear VimwikiH2Folding
    syn clear VimwikiH3Folding
  endif


" TODO
syn clear bashStatement
syn clear shFunctionOne
syn clear shExpr

" TODO python

" Define Wiki
  " Define Wiki region
  "syntax region pythonCode matchgroup=Snip start="\\begin{python}" end="\\end{python}" containedin=@TeX contains=@Python
  " syntax region shWikiCode matchgroup=shWikiCommand start=+: '+ skip=+\\'+ end=+'+ contains=@shWikiScript contained skipwhite skipempty
  
  "syntax match shWikiLineContinuation "\\\s*$" contained skipempty nextgroup=shWikiExpression
  "syntax match shWikiExpression "\%(^\|\_s\+\)-\a*e\a*\_s\+" contained nextgroup=shWikiScriptCode
  "syntax match shWikiExpression "\_.*" contained nextgroup=shWikiScriptCode
  "syntax region shWikiScriptCode matchgroup=shWikiCommand start=+[=\\]\@<!'+ skip=+\\'+ end=+'+ contains=@shWikiScript contained skipwhite skipempty nextgroup=shWikiLineContinuation,shWikiExpression
  "syntax region shWikiScriptEmbedded1 matchgroup=shWikiCommand start=+^\s*: "\>+ end=+"+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shWikiScriptCode
  "syntax region shWikiScriptEmbedded1 matchgroup=shWikiCommand start=+\<:\>+ end=+'+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shWikiScriptCode
  "syntax region shWikiScriptEmbedded1 matchgroup=shWikiCommand start=+\<:\>+ end=+'+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shWikiScriptCode
  "syntax region shWikiScriptEmbedded2 matchgroup=shWikiCommand start=+\<wiki\>+ skip=+\\$+ end=+[=\\]\@<!'+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shWikiScriptCode
  syntax region shWikiScriptCode matchgroup=shWikiCommand start=+[=\\]\@<!'+ skip=+\\'+ end=+'+ contains=@shWikiScript contained skipwhite skipempty
  syntax region shWikiScriptCode matchgroup=shWikiCommand start=+[=\\]\@<!"+ skip=+\\"+ end=+"+ contains=@shWikiScript contained skipwhite skipempty
  syntax region shWikiScriptEmbedded1 matchgroup=shWikiCommand start=+^\s*: + end=+[=\\]\@<!'+me=e-1 skip=+\\$+ contains=@shIdList,@shExprList2 nextgroup=shWikiScriptCode
  syntax cluster shCommandSubList add=shWikiScriptEmbedded


" Define Perl
  " Define perl region
  syntax match shPerlLineContinuation "\\\s*$" contained skipempty nextgroup=shPerlExpression
  syntax match shPerlExpression "\%(^\|\_s\+\)-\a*e\a*\_s\+" contained nextgroup=shPerlScriptCode
  syntax region shPerlScriptCode matchgroup=shPerlCommand start=+[=\\]\@<!'+ skip=+\\'+ end=+'+ contains=@shPerlScript contained skipwhite skipempty nextgroup=shPerlLineContinuation,shPerlExpression
  syntax region shPerlScriptEmbedded matchgroup=shPerlCommand start=+\<perl\>+ skip=+\\$+ end=+[=\\]\@<!'+me=e-1 contains=@shIdList,@shExprList2 nextgroup=shPerlScriptCode
  syntax cluster shCommandSubList add=shPerlScriptEmbedded


"" Define Sed
"  " Define Sed
"  syntax region shSedScriptCode matchgroup=shSedCommand start=+[=\\]\@<!'+ skip=+\\'+ end=+'+ contains=@shSedScript contained skipwhite skipempty
"  syntax region shSedScriptEmbedded matchgroup=shSedCommand start=+\<sed\>+ skip=+\\$+ end=+'+me=e-1 contains=@shIdList,@shExprList2,shFunctionOne,bashStatement nextgroup=shSedScriptCode
"  syntax cluster shCommandSubList add=shSedScriptEmbedded
"

" Link
  hi link shWikiCommand Statement
  hi link shWikiExpression shSetOption
  " Perl
  hi def link shPerlCommand Statement
  hi def link shPerlExpression shSetOption
  " Sed
  hi def link shSedCommand Statement
  hi def link shSedExpression shSetOption

" Restore peace
  let b:current_syntax = 'sh'

" Redraw
  syn sync fromstart 
