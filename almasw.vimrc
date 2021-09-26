
" Clause: load once
if exists('g:loaded_almasw') || &compatible
  finish
endif
let g:loaded_almasw = 1


" In
let g:almasw_path_src = '~/AlmaSw'  " Alma software direcotry path

" Generated source directory
" used for Sources, include, idl, lib
" Cmd: rsync -av root@acse2-gns.sco.alma.cl:/alma/ACS-current/ACSSW/include /home/tourneboeuf/Program/ACSSW
let g:almasw_path_gen = '~/Program/ACS-current'

" Internal
let g:almasw_is_path_generated = 0

" ALE
let g:ale_cpp_clang_options = ''
let g:ale_cpp_clang_options .= '-I../include '
let g:ale_cpp_clang_options .= '-I. '
let g:ale_cpp_clang_options .= '-I/home/tourneboeuf/AlmaSw/ '
let g:ale_cpp_clang_options .= '-I/home/tourneboeuf/AlmaSw/ACS/LGPL/CommonSoftware/logging/ws/include/ '
let g:ale_cpp_clang_options .= '-I/home/tourneboeuf/AlmaSw/TELCAL/TelCalDataManager/include '

" Path
" TODO
"noremap gf
function Generate_path() abort
  if g:almasw_is_path_generated
    return
  endif
  g:almasw_path_generated = 1

  let path = ''

  " System path
  " Ex: :/usr/include/c++/10:/usr/include/x86_64-linux-gnu/c++/10:/usr/include/c++/10/backward:/usr/lib/gcc/x86_64-linux-gnu/10/include:/usr/local/include:/usr/include/x86_64-linux-gnu:/usr/include
  let path .= system("echo | gcc -Wp,-v -x c++ - -fsyntax-only 2>&1 | grep -E '^ /' | perl -pe 's/^ /,/; s/\n//g'")
  echom 'tin path ' . path

  " Specific path
  for tail_dir in [
        \ g:almasw_path_gen . '/TAO/ACE_wrappers',
        \ g:almasw_path_gen . '/TAO/ACE_wrappers/TAO'
        \ ]
    let path .= ',' .  expand(tail_dir)
    echom 'tin tail ' . tail_dir
  endfor
  let path .= ','

  " Root path
  for root_dir in [g:almasw_path_src, g:almasw_path_gen]
    echom 'tin root_dir ' . root_dir
    let path .= system('find ' . root_dir . " -type d | grep -E '(idl|src|include)$' | tr '\n' ','")
  endfor
  
  " Change optiom
  execute 'set path+=' . path
endfunction

"noremap gf 
command AlmaswGeneratePath call Generate_path()
