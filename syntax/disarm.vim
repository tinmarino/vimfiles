" Vim syntax file
" Language:     ARM GNU Disassembler (objdump -d -Mintel)
" Maintainer:   @datsuns <the.skeleton7@gmail.com> (forked from @shiracamus <shiracamus@gmail.com>)
" Last Change:  201x 

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case ignore

syn match disOffset     "[+-]"
syn match disNumberHeader  "#"
syn match disNumber     "[+-]\?\<0x[0-9a-f]\+\>" contains=disOffset
syn match disNumber     "[+-]\?\<[0-9a-f]\+\>" contains=disOffset

syn match disRegister   "\<[re]\?[abcd][xhl]\>"
syn match disRegister   "\<[re]\?[sd]il\?\>"
syn match disRegister   "\<[re]\?[sbi]pl\?\>"
syn match disRegister   "\<r[0-9]\+[dwb]\?\>"
syn match disRegister   "[^\t]\<[cdefgs]s\>"hs=s+1
syn match disRegister   "\v(fp|sp|pc|lr)"
syn match disSigleWordRegister   "\<s[0-9]\+[dwb]\?\>"
syn match disDoubleWordRegister   "\<d[0-9]\+[dwb]\?\>"

syn match disAt         "@"
syn match disSection    " \.[a-z][a-z_\.-]*:"he=e-1
syn match disSection    "@[a-z0-9_][a-z0-9_-]\+"hs=s+1 contains=disAt,disNumber

syn match disLabel      "<[a-z0-9_.][a-z0-9_.@+-]\+>"hs=s+1,he=e-1 contains=disNumber,disSection
syn match disHexDump    ":\t\([0-9a-f][0-9a-f][ \t]\)\+"hs=s+1

syn match disError      "<internal disassembler error>"
syn match disError      "(bad)"

syn keyword disTodo     contained TODO

syn region disComment   start="/\*" end="\*/" contains=disTodo
syn match disComment    "[;|].*" contains=disLabel,disTodo
syn match disStatement  "//.*" contains=cStatement

syn match disSpecial    display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
syn region disString    start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=disSpecial
syn region disString    start=+'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=disSpecial

syn match disFormat     ": \+file format "
syn match disTitle      "^[^ ]\+: \+file format .*$" contains=disFormat

syn match disData       ".word"
syn match disData       ".short"
syn match disData       ".byte"

" Opecode matched disNumber
syn match disOpecode    "\v\t(add|ldr|push|ldr|str|cmp|pop|mov|fld|fst|fmr)(h|d|s){0,1}\t"
syn match disOpecode    "\v\tb(ne|x|eq|l){0,1}\t"
syn match disOpecode    "\v\t(vldm|vstr|vldr|vstm)(ia){0,1}\t"

syn match disSpecialOp  "!"

syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_dis_syntax_inits")
  if version < 508
    let did_dis_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  " Comment
  HiLink disComment     Comment
  " Constant: String, Character, Number, Boolean, Float
  HiLink disNumberHeader      Number
  HiLink disNumber      Number
  HiLink disString      String
  " Identifier: Function
  HiLink disHexDump     Identifier
  " Statement: Conditional, Repeat, Label, Operator, Keyword, Exception
  HiLink disStatement	Statement
  HiLink disLabel       Label
  " PreProc: Include, Define, Macro, PreCondit
  HiLink disData        Define
  " Type: StorageClass, Structure, Typedef
  HiLink disRegister    StorageClass
  highlight disSigleWordRegister    guifg=yellow gui=bold ctermfg=yellow
  highlight disDoubleWordRegister   guifg=magenta gui=bold ctermfg=magenta
  HiLink disTitle       Typedef
  " Special: SpecialChar, Tag, Delimiter, SpecialComment, Debug
  HiLink disSpecial     SpecialChar
  HiLink disSection     Special
  " Underlined
  " Ignore
  " Error
  HiLink disError       Error
  " Todo
  HiLink disTodo        Todo
  " Opecode
  HiLink disOpecode     Type
  HiLink disSpecialOp   Title



  delcommand HiLink
endif

let b:current_syntax = "disarm"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sts=4 sw=2
