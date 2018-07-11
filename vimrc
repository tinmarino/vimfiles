set nocompatible | filetype on | syntax on


" Variable
  " OS
  let $os = 'unknown'
  if has('unix')
    let $os = 'unix'
    let s:tmp = system('uname -a')
    if -1 != match(s:tmp, '\candroid')
      let $os = 'termux'
    endif
  elseif has('win32') || has('win64')
    let $os = 'windows'
  endif

  " Vim
  let $MYVIM = expand('<sfile>:p:h')
  let $vim = $MYVIM
  let $v = $MYVIM
  let $vimrc = $v . "/vimrc"
  let $s = expand("$v/scripts")
  let $ft = expand("$v/ftplugin")
  let $start = expand("$vim/pack/bundle/start")
  let $opt = expand("$vim/pack/bundle/opt")
  let $dump = expand("$vim/undo/dump")

  " Os dependant
  if 'windows' == $os
    let $home = expand("C:/Users/tbf")
    let $alias = expand("H:/Program/Cmder/config/user-aliases.cmd")
  else
    let $home = "~"
  endif



" From vim debian team (better at start)
  if filereadable("/etc/vim/vimrc.local")
    source /etc/vim/vimrc.local
  endif


" Source (my broters)
  source $MYVIM/scripts/myfunctions.vim
  source $MYVIM/scripts/cfunctions.vim
  " TODO if gvim
  " source $MYVIM/scripts/fontsize.vim


" Appearance , Color, Search, Set staff
  set guioptions-=T                  " Toolbar
  set guioptions-=m                  " Menumbar
  set encoding=utf-8
  set nu
  "SEARCH 
  set ignorecase
  set smartcase
  set ignorecase
  set hlsearch      " highlight search terms
  set incsearch     " show search matches as you type
  " Title and color 
  set title                    " change the terminal's title, may not work
  " Enable CursorLine
  set cursorline
  " Default Colors for CursorLine
  highlight  CursorLine term=underline cterm=underline ctermbg=None ctermfg=None
  "Change Color when entering Insert Mode
  autocmd InsertEnter * highlight  CursorLine term=None cterm=None
  " Revert Color to default when leaving Insert Mode
  autocmd InsertLeave * highlight  CursorLine term=underline cterm=underline ctermbg=None ctermfg=None

  set autoindent  " to have auto indentation when return line 
  colorscheme dante
  set laststatus=2 " for airline
  " No auto comment
  set formatoptions-=cro
  " WINDOWS 
    set ruler 
    set backspace=2 
    set foldlevelstart=30 "the folding at opening
    set wrap
    set fileformat=unix
    " set shell=H:/Program/cmder-1.2.9/Cmder.exe
  " TAB
    set expandtab
    set shiftwidth=4
    set tabstop=4
    set wrapscan
  " Viminfo rememebr last 10000 opened files
  let s:viminfo=join(map(split(&viminfo, ","), {arg -> (v:val[0] == "'" ? "'10000" : v:val)}), ",")
  exe("set viminfo=" . s:viminfo)


" Backup
  set nobackup                  " I may change that 
  set noswapfile                " I will this if this is harmfull
  set nowritebackup
  set backupdir=~/.vim/backup// " the double // will put the backup with the full directory  
  set directory=~/.vim/backup// " for the swap files 
  set undolevels=10000         " use many levels of undo
  set history=10000    " After nocompatible 
  set autoread                  " when reopening a file, go to the position as when you quit it +  This will disable read-only to writeable warnings
  set formatoptions-=cro
 
  if has('persistent_undo')
    set undodir=$MYVIM/undo
    set undofile 
  endif 


" Mouse Integration
  " Send more characters for redraws
  set mouse=a " Enable mouse use in all modes
  set ttyfast
  set ttymouse=xterm2


" Map
  noremap > >>
  noremap < <<
  let mapleader=','

  " Ctrlz
  nnoremap <silent> <expr> <leader>d ctrlz#dadcd()
  nnoremap <expr> <c-z> ctrlz#ctrlz()

  nnoremap H :set cursorline! cursorcolumn!<CR> 
  "move one line 
  map <Leader>c :s,^\(\s*\)[^# \t]\@=,\1// ,<CR>gv
  map <Leader>u :s,^\(\s*\)[^# \t]\@=// ,\1,<CR>gv
  " Move lines with shift
  nnoremap <S-Down> :let tmp=getpos('.') <CR>:m+1 <CR>: call cursor(tmp[1]+1,tmp[2]) <CR>
  nnoremap <S-Up>   :let tmp=getpos('.') <CR>:m-2 <CR>: call cursor(tmp[1]-1,tmp[2]) <CR>
  inoremap <S-Up>   <Esc>:let tmp=getpos('.') <CR>:m-2 <CR>: call cursor(tmp[1]-1,tmp[2]) <CR>a
  inoremap <S-Down> <Esc>:let tmp=getpos('.') <CR>:m+1 <CR>: call cursor(tmp[1]+1,tmp[2]) <CR>a
  vnoremap <S-Up> :m '<-2<CR>gv
  vnoremap <S-Down>   :m '>+1<CR>gv
  "ARITHMETIC 
  ino <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
  "just type 8*9 c-a and get the result 
  "copy paste to from clipboard vith ctrl+p  
  nnoremap <C-y> "+y
  vnoremap <C-y> "+y
  nnoremap <C-p> "+p
  vnoremap <C-p> "+p
  "%% to expand path in command mode  
  cnoremap %% <C-R>=expand('%:p:h')<CR>|  
  """""""""""""""

  " Insert mode shotcuts from gnome
  inoremap <C-A> <C-O>^
  inoremap <C-E> <C-O>g_
  inoremap <C-K> <C-O>D 

  imap jk <Esc>
  imap kj <Esc>


  "Get Ctrl + ARROW KEYS,because if you don't do that, the <C-Up>  (ie crtl + up ) key is notreckognise 
  "Works on Ubuntu 
    map [1;5A <C-Up>
    map [1;5B <C-Down>
    map [1;5D <C-Left>
    map [1;5C <C-Right>

    map [1;2D <S-Left>
    map [1;2C <S-Right>
    cmap [1;2D <S-Left>
    cmap [1;2C <S-Right>


  " autocompletion with space
  inoremap <Nul> <C-n>

  " change x and y, but take care, this is changing the x of max sometinmes you dont want that   
  map xy :s/x/y/g<CR>
  map yx :s/y/x/g<CR>


  nnoremap <space> za
  vnoremap <space> zf
  "map <2-LeftMouse> zA
  "

  vnoremap > >gv 
  vnoremap < <gv 

  " Use CTRL-S for saving, also in Insert mode
  noremap <C-S>      :update<CR>
  vnoremap <C-S>    <C-C>:update<CR>
  inoremap <C-S>    <C-O>:update<CR>


  " Commenting blocks of code.
  autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
  autocmd FileType sh,ruby,python   let b:comment_leader = '# '
  autocmd FileType conf,fstab       let b:comment_leader = '# '
  autocmd FileType tex              let b:comment_leader = '% '
  autocmd FileType mail             let b:comment_leader = '> '
  autocmd FileType vim              let b:comment_leader = '" '
  noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
  noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>


  " Fold 
  map z0  :set foldlevel=0<CR><Esc>
  map z1  :set foldlevel=1<CR><Esc>
  map z2  :set foldlevel=2<CR><Esc>
  map z3  :set foldlevel=3<CR><Esc>
  map z4  :set foldlevel=4<CR><Esc>
  map z5  :set foldlevel=5<CR><Esc>
  map z6  :set foldlevel=6<CR><Esc>
  map z7  :set foldlevel=7<CR><Esc>
  map z8  :set foldlevel=8<CR><Esc>
  map z9  :set foldlevel=9<CR><Esc>


  nnoremap <leader>ev :vsplit $MYVIMRC<cr>
  map <Leader>v :e $vimrc<CR>
  map <Leader>x :w<CR>:so %<CR>
  "Todo create backup dir
  map <leader>s :write! $dump/%:t-<C-R>=strftime("%y%m%d")<CR>-bak.txt<CR>


" Command
  if exists(":Man") != 2
    com! -nargs=+ -complete=shellcmd M ru! ftplugin/man.vim | Man <args>
  else
    com! -nargs=+ -complete=shellcmd M Man <args>
  endif


" Folding
  highlight Folded ctermfg=DarkGreen ctermbg=Black
  set foldmethod=expr
  set foldexpr=FoldMethod(v:lnum)
  "autocmd FileType vim set foldmethod=indent " I don't need to fold comments in vim files 
  set shiftwidth=4  " the number of column taken into account for aa fold, IMPORTANT
  
  function! FoldMethod(lnum)
    let crLine=getline(a:lnum)
 
    " check if empty line 
    if crLine =~ '^\s*$' || crLine[0]== "#" "Empty line or end comment 
      return '=' " so same indent level as line before
    endif 


    " check if comment  in syntax
    let l:data =  join( map(synstack(a:lnum, 1), 'synIDattr(v:val, "name")') )
    if l:data =~ ".*omment.*"
      "return max([FoldMethod(a:lnum+1), FoldMethod(a:lnum-1) ]) 
      return '-1'

    endif


  "Otherwise return foldlevel equal to ident /shiftwidth (like if
  "foldmethod=indent)
      "return indent base fold
    return indent(a:lnum)/&shiftwidth

  endfunction

  


  set foldcolumn=0  "the number of columns on the left to show the tree, default =0 
  set foldlevelstart=30 "the folding at opening


" Buffer Management (and it maps)
  "map <Tab> :bnext<cr>
  "map <S-Tab> :bprevious<cr>
  noremap <C-Tab> :BufExplorer<CR>
  " from http://vim.wikia.com/wiki/Easier_buffer_switching
  set wildchar=<Tab> wildmenu wildmode=full
  set wildcharm=<C-Z>
  nnoremap <F10> :b <C-Z>
  " Mappings to access buffers (don't use "\p" because a
  " " delay before pressing "p" would accidentally paste).
  " " \l       : list buffers
  " " \b \f \g : go back/forward/last-used
  " " \1 \2 \3 : go to buffer 1/2/3 etc
  map <Leader>l :ls<CR>
  map <Leader>b :bp<CR>  
  "overwriten by GDB
  map <Leader>f :bn<CR>
  map <Leader>1 :1b<CR>
  map <Leader>2 :2b<CR>
  map <Leader>3 :3b<CR>
  map <Leader>4 :4b<CR>
  map <Leader>5 :5b<CR>
  map <Leader>6 :6b<CR>
  map <Leader>7 :7b<CR>
  map <Leader>8 :8b<CR>
  map <Leader>9 :9b<CR>
  map <Leader>0 :10b<CR>

  map z0 :set foldlevel=0<CR>
  map z1 :set foldlevel=1<CR>
  map z2 :set foldlevel=2<CR>
  map z3 :set foldlevel=3<CR>
  map z4 :set foldlevel=4<CR>
  map z5 :set foldlevel=5<CR>
  map z6 :set foldlevel=6<CR>
  map z7 :set foldlevel=7<CR>

  nmap <c-z> :echom "Warning do not use <c-z><CR>u


" Filetype
  au BufNewFile,BufRead *.masm      setf masm
  au BufNewFile,BufRead *.asm       setf masm
  au BufNewFile,BufRead *.disarm    setf disarm
  au BufNewFile,BufRead *.kd        setf kd


" Plugin
  " Pymode
    let g:pymode_options_colorcolumn = 0 " Remove the red line
    " Auto open cwindow (quickfix) if any errors have been found
    let g:pymode_lint_cwindow = 0
    " let g:pymode_lint_ignore =  "E701"   " Multiple statement on one line
    " let g:pymode_lint_ignore .= ",E501" " Line too long > 80 
    " let g:pymode_lint_ignore .= ",E221" " Multiple spaces before operator
    " let g:pymode_lint_ignore =  "E701" 	" Multiple statement on one line
    " let g:pymode_lint_ignore .= ",E501" " Line too long > 80 
    " let g:pymode_lint_ignore .= ",E221" " Multiple spaces before operator
    let g:pymode_lint_ignore="E221,E303,E302,E501,E202,E222, E201"
    autocmd FileType python set colorcolumn=120
    let g:pymode_options_max_line_length=120
    let g:pymode_options_colorcolumn = 0 " Remove the red line
    " Auto open cwindow (quickfix) if any errors have been found
    let g:pymode_lint_cwindow = 0
    let g:pymode_rope_goto_definition_cmd = 'e'

  " ConqueDbg, a gdb plugging
    let g:ConqueTerm_Color = 2         " 1: strip color after 200 lines, 2: always with color
    let g:ConqueTerm_CloseOnEnd = 1    " close conque when program ends running
    let g:ConqueTerm_StartMessages = 0 " display warning messages if conqueTerm is configured incorrectly 
    let g:ConqueTerm_PyVersion = 3

  " CtrlP
    " E like edit and closer to ctrl + <c-p> used to paste
    let g:ctrlp_map = '<c-e>'
    " Mixed to search in MRU, FIles, Buffers
    let g:ctrlp_cmd = 'CtrlPMixed'
    " Ctrlp Plugin Buffer with ctrl-b
    map <C-b> :CtrlPBuffer<CR>

  " Vim Translator
    ".vimrc
    " language code iso 639-1
    "? define key in visual-mode (optional)
    let g:goog_user_conf = { 'langpair': 'en|ru', 'cmd': 'node', 'v_key': 'T' }

  " AnsiEsc
    " au BufWinEnter *.a.txt AnsiEsc
    " au BufWinEnter *.a.txt set nowrap | echom "I saw an ansi file"
    " au ColorScheme * AnsiEsc!

  " Emacs Command line
    let g:EmacsCommandLineSearchCommandLineDisable = 1

  " Eclim 
    filetype plugin indent on
    let g:EclimCompletionMethod = 'omnifunc'

  " Vimtex
    " Disable overfull/underfull \hbox
    let g:vimtex_quickfix_latexlog = {
        \ 'overfull' : 0,
        \ 'underfull' : 0,
        \}

  " Ultisnip
    let g:UltiSnipsExpandTrigger="<c-j>"
    let g:UltiSnipsUsePythonVersion = 3

  " YouCompleteMe
    let g:ycm_global_ycm_extra_conf = "~/.vim/pack/bundle/start/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py"

  " Vimwiki
    let g:vimwiki_list = [{
      \ 'syntax': 'markdown',
      \ 'ext': '.md',
      \ 'custom_wiki2html': $home . "/vimwiki/wiki2html.sh",
      \ 'path': '~/vimwiki'
      \ }]

  " Termux
    if 'termux' == $os
      autocmd CursorHold,CursorHoldI *  silent update
    endif


" Fastly (added)

