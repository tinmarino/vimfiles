" Name: claritybeauty
" Author: Sam Tannous
"   Based on the Clarity and Beauty Emacs color scheme
"   found on https://emacsthemes.com/themes/clarity-theme.html
"   and created by Richard Wellum and Syohei Yoshida.
"" local syntax file - set colors on a per-machine basis:
"" vim: tw=0 ts=4 sw=4

hi clear
set background=dark

if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "claritybeauty"

hi Identifier	term=underline	ctermfg=green	guifg=White
hi Identifier   cterm=none	gui=none

function <SID>set_color(name, fg, bg, ct)
    exe 'highlight ' . a:name . ' ctermfg=' . a:fg . ' ctermbg=' . a:bg . ' cterm=' . a:ct
endfunction

" Green
let color1 = '46'
" Magenta
let color3 = '197'
" Light Blue
let color6 = '45'
" Light SKY Blue
let functionname = '153'
" Yellow
let color5 = '220'

" Gray
let color2 = '245'
" Dark Gray
let color4 = '233'

" light minty green
let color8 = '119'
" strings - beige
let color14 = '185'

" Blue
let color9 = '33'

" Black
let color10 = '232'
" lighter Black
let color11 = '235'
" darkish gray
let color12 = '236'
" Cyan
let color13 = '51'
" another gray
let color15 = '242'

let diffcolor1 = '237'
let diffcolor2 = '124'
let diffcolor3 = '53'
let diffcolor4 = '22'

let white = '254'
let red = '196'
let black = '16'
let search = '208'
let orangered = '202'

"(font-lock-builtin-face ((t (:foreground "LightSteelBlue"))))      147
"(font-lock-comment-face ((t (:foreground "OrangeRed"))))           202
"(font-lock-constant-face ((t (:foreground "Aquamarine"))))         122
"(font-lock-doc-face ((t (:foreground "LightSalmon"))))             216
"(font-lock-function-name-face ((t (:foreground "LightSkyBlue"))))  153
"(font-lock-keyword-face ((t (:foreground "Cyan"))))                 51
"(font-lock-string-face ((t (:foreground "LightSalmon"))))          216
"(font-lock-type-face ((t (:foreground "PaleGreen"))))              121
"(font-lock-variable-name-face ((t (:foreground "LightGoldenrod")))) 227


call <SID>set_color("Boolean", color1, "NONE", "NONE")
"call <SID>set_color("Comment", color2, "NONE", "NONE")
call <SID>set_color("Comment", '202', "NONE", "NONE")
call <SID>set_color("Constant", '51', "NONE", "NONE")
call <SID>set_color("CursorColumn", "NONE", color4, "NONE")
call <SID>set_color("CursorLine", "NONE", color4, "NONE")
call <SID>set_color("CursorLineNr", color5, "NONE", "NONE")
call <SID>set_color("Directory", color6, "NONE", "NONE")
call <SID>set_color("DiffAdd", "NONE", diffcolor4, "NONE")
call <SID>set_color("DiffChange", "NONE", diffcolor1, "NONE")
call <SID>set_color("DiffDelete", "NONE", diffcolor2, "NONE")
call <SID>set_color("DiffText", "NONE", diffcolor3, "NONE")
call <SID>set_color("Error", white, red, "NONE")
"call <SID>set_color("Function", color1, "NONE", "NONE")
call <SID>set_color("Function", white,  "NONE", "NONE")
call <SID>set_color("Identifier", '227', "NONE", "NONE")
call <SID>set_color("LineNr", white, "NONE", "NONE")
"call <SID>set_color("MatchParen", red, black,  "NONE")
"call <SID>set_color("cParenGroup", red, black,  "NONE")
call <SID>set_color("NonText", color9, "NONE", "NONE")
call <SID>set_color("Normal", '230', black, "NONE")
call <SID>set_color("Operator", color5, "NONE", "NONE")
call <SID>set_color("PreProc", '251', "NONE", "NONE")
call <SID>set_color("Pmenu", color5, color10, "NONE")
call <SID>set_color("PmenuSbar", color5, color11, "NONE")
call <SID>set_color("PmenuSel", color6, color10, "NONE")
call <SID>set_color("PmenuThumb", color5, color10, "NONE")
call <SID>set_color("Search", white, search, "NONE")
call <SID>set_color("Special", color9, "NONE", "NONE")
call <SID>set_color("SpecialKey", color13, "NONE", "NONE")
call <SID>set_color("SpellBad", "NONE", "NONE", "underline")
call <SID>set_color("SpellCap", "NONE", "NONE", "underline")
call <SID>set_color("SpellLocal", "NONE", "NONE", "underline")
call <SID>set_color("SpellRare", "NONE", "NONE", "underline")
"call <SID>set_color("cStatement", color5, "NONE", "NONE")
call <SID>set_color("Statement", '51', "NONE", "NONE")
call <SID>set_color("StatusLine", color6, color11, "NONE")
call <SID>set_color("StatusLineNC", white, color11, "NONE")
call <SID>set_color("String", '216', "NONE", "NONE")
call <SID>set_color("Structure", '51', "NONE", "NONE")
call <SID>set_color("StorageClass", '51', "NONE", "NONE")
call <SID>set_color("TabLineFill", white, color11, "NONE")
call <SID>set_color("TabLineSel", white, black, "NONE")
call <SID>set_color("TabLine", white, color15, "NONE")
call <SID>set_color("Todo", white, "NONE", "bold")
call <SID>set_color("Type", 121, "NONE", "NONE")
call <SID>set_color("Visual", "NONE", '153', "NONE")

delf <SID>set_color
