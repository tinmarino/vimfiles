"packadd tex

" Compile
map <leader>c :VimtexCompile<CR>

set makeprg=latexmk\ -pdf\ %
set wildignore+=*.log
