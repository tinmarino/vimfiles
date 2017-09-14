set nu

" for gf with libgdx 
" set path+=/home2/tourneboeuf/Software/Java/Libgdx/Jar/Git/gdx/src/**
" set path+=/home2/tourneboeuf/Software/Java/Libgdx/Jar/Git/tests/gdx-tests/src/** 
" " com/badlogic/gdx/tests/AccelerometerTest.java' 
" set path+=/home2/tourneboeuf/Software/Java/Libgdx/Jar/Git/backends/gdx-backend-android/src/**
" set path+=/home2/tourneboeuf/Software/Java/Libgdx/Jar/Git/backends/gdx-backends-gwt/src/**
" set path+=/home2/tourneboeuf/Software/Java/Libgdx/Jar/Git/backends/gdx-backend-lwjgl/src/**
" set path+=/home2/tourneboeuf/Software/Java/Libgdx/Jar/Git/backends/gdx-backend-lwjgl/src/**
" set path+='/home2/tourneboeuf/Software/Java/Libgdx/Jar/Lwjgl/src/java' 
" set path+='/home2/tourneboeuf/Software/Java/Libgdx/Jar/Lwjgl/src/templates' 

" ECLIM 
	command! JI 	JavaImport
	"command! ji 	JavaImport
	command! JIO 	JavaImportOrganize
	"command! jio 	JavaImportOrganize
	command! JC 	JavaCorrect
	"command! jc 	JavaCorrect
	
	" Jump, goto
	command! JS		JavaSearchContext
	nnoremap <Leader>g	:JavaSearchContext<CR>
	let g:EclimJavaSearchSingleResult='edit'
