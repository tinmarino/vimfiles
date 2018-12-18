" Plugin
packadd table-mode

set linebreak

map <leader>c :VimwikiAll2HTML<CR><CR>:syntax on<CR>
so $MYVIM/pack/bundle/start/vimwiki/ftplugin/vimwiki.vim
set noexpandtab

set tabstop=2
set softtabstop=2
set shiftwidth=2
