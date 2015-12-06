set nocompatible
call pathogen#infect()
filetype on 



" FROM VIM DEBIAN TEAM                
  if filereadable("/etc/vim/vimrc.local")
    source /etc/vim/vimrc.local
  endif


" SYNTAX SLOW 
  "call stfrtime() 
  if has("syntax")
      syntax on
  endif


" APPEARANCE , COLOR, search 
  "SEARCH 
  set smartcase
      "/copyright      " Case insensitive
      "/Copyright      " Case sensitive
      "/copyright\C    " Case sensitive
      "/Copyright\c    " Case insensitive
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


" BACKUP SLOW SOMETIMES  
  set nobackup                  " I may change that 
  set noswapfile                " I will this if this is harmfull
  set backupdir=~/.vim/backup// " the double // will put the backup with the full directory  
  set directory=~/.vim/backup// " for the swap files 
  set undolevels=100000         " use many levels of undo
  set history=100000		" After nocompatible 
  set autoread                  " when reopening a file, go to the position as when you quit it +  This will disable read-only to writeable warnings
 
  if has('persistent_undo')
    set undodir=~/.vim/undo
    set undofile 
  endif 
  set history=100000            " remember more commands and search history


"MOUSE INTEGRATION 
  " Send more characters for redraws
  set mouse=a " Enable mouse use in all modes
  set ttyfast
  set ttymouse=xterm2


"MAP = SHORTCUTS 
  let mapleader=','
  nnoremap H :set cursorline! cursorcolumn!<CR> 
  "move one line 
  map <Leader>c :s,^\(\s*\)[^# \t]\@=,\1// ,<CR>gv
  map <Leader>u :s,^\(\s*\)[^# \t]\@=// ,\1,<CR>gv
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
  "Save with Crtl + S, need to disable something in bashrc  
  "noremap  <C-S>    :update<CR>   
  "vnoremap  <C-S>         <C-C>:update<CR> 
  "inoremap <C-S>         <C-O>:update<CR>

  imap jk <Esc>


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


  nnoremap <space> zA
  vnoremap <space> zf
  "map <2-LeftMouse> zA
  "
  "zr zm with ctrl + direction, never used ....
  nnoremap <silent> <C-Right> zr
  vnoremap <silent> <C-Right> zr
  nnoremap <silent> <C-Left> zm
  vnoremap <silent> <C-Left> zm
  nnoremap <silent> <C-Up> zR
  vnoremap <silent> <C-Up> zR
  nnoremap <silent> <C-Down> zM
  vnoremap <silent> <C-Down> zM

  vnoremap > >gv 
  vnoremap < <gv 


"FOLDING, and folding maps 
  highlight Folded ctermfg=DarkGreen ctermbg=Black
  set foldmethod=expr
  set foldexpr=FoldMethod(v:lnum)
  "autocmd FileType vim set foldmethod=indent " I don't need to fold comments in vim files 
  set shiftwidth=2  " the number of column taken into account for aa fold, IMPORTANT
  
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
      return '='

    endif


  "Otherwise return foldlevel equal to ident /shiftwidth (like if
  "foldmethod=indent)
      "return indent base fold
    return indent(a:lnum)/&shiftwidth

  endfunction

  


  set foldcolumn=0  "the number of columns on the left to show the tree, default =0 
  set foldlevel=10  " WTF 
  "set foldlevelstart=5 "the folding at opening



" BUFFER MANAGEMENT  and it maps 
  map <Tab> :bnext<cr>
  map <S-Tab> :bprevious<cr>
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
  map <Leader>f :bn<CR>
  map <Leader>g :e#<CR>
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


"ECLIM 
  "set nocompatible 
  filetype plugin indent on
  let g:EclimCompletionMethod = 'omnifunc'

""" LARGE FILE 
  " Protect large files from sourcing and other overhead.
  " Files become read only
  if !exists("my_auto_commands_loaded")
    let my_auto_commands_loaded = 1

    let g:LargeFile = 1024 * 1024 
    augroup LargeFile
      autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload undolevels=-1 | syntax off | setlocal foldmethod=manual | else | set eventignore-=FileType | endif
    augroup END
  endif
