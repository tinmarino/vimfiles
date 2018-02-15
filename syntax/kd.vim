" quit when a syntax file was already loaded.
if exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim


syn match       kdComment "$$.*$"





syn keyword kdBuiltin ENTER 	a 	ad 	ah 	al 	as aS 	ba 	bc 	bd 	be 	bl 	bp bu bm 	br 	bs 	c 	d da db dc dd dD df dp dq du dw 	dda ddp ddu dpa dpp dpu dqa dqp dqu 	dg 	dl 	ds dS 	dt 	dv 	dx 	e ea eb ed eD ef ep eq eu ew eza 	f fp 	g 	gh 	gn gN 	gu 	ib iw id 	j 	k kb kc kd kp kP kv 	l+ l- 	ld 	lm 	ln 	ls lsa 	lsc 	le lsf lsf- 	lsp 	m 	n 	ob ow od 	p 	pa 	pc 	pct 	ph 	pt 	q qq 	qd 	r 	rdmsr 	rm 	s 	so 	sq 	ss 	sx sxd sxe sxi sxn sxr sx- 	t 	ta 	tb 	tc 	tct 	th 	tt 	u ub uu 	up 	ur 	ux 	vercommand 	version 	vertarget 	wrmsr 	wt 	x 	z 	
syn match kdBuiltin "\(\$<\|\$><\|\$\$<\|\$\$><\|\$\$>a<\)"
syn match kdBuiltin "\(?\|\#\|||\|||s\||\||s\|\~e\|\~f\|\~u\|\~n\|\~m\|\~s\|\~s\)" 	
syn keyword kdBuiltin poi

syn match kdVariable "\${\w\+}"
syn match kdVariable "\$\w\+"

syn match kdOperator "+\|>>\|<<\|\*"



syn match kdToken "\(\.block\|\.break\|\.catch\|\.continue\|\.do\|\.else\|\.elsif\|\.for\|\.foreach\|\.if\|\.leave\|\.printf\|\.while\)"


syn match kdFunction  "\(\.abandon\|\.allow_exec_cmds\|\.allow_image_mapping\|\.apply_dbp\|\.asm\|\.attach\|\.beep\|\.bpcmds\|\.bpsync\|\.breakin\|\.browse\|\.bugcheck\|\.cache\|\.call\|\.chain\|\.childdbg\|\.clients\|\.closehandle\|\.cls\|\.context\|\.copysym\|\.cordll\|\.crash\|\.create\|\.createdir\|\.cxr\|\.detach\|\.dml_flow\|\.dml_start\|\.dump\|\.dumpcab\|\.dvalloc\|\.dvfree\|\.echo\|\.echocpunum\|\.echotime\|\.echotimestamps\|\.ecxr\|\.effmach\|\.enable_long_status\|\.enable_unicode\|\.endpsrv\|\.endsrv\|\.enumtag\|\.event_code\|\.eventlog\|\.exepath\|\.expr\|\.exptr\|\.exr\|\.extmatch\|\.extpath\|\.f\|\.fiber\|\.fiximports\|\.flash_on_break\|\.fnent\|\.fnret\|\.force_radix_output\|\.force_tb\|\.formats\|\.fpo\|\.frame\|\.help\|\.hh\|\.hideinjectedcode\|\.holdmem\|\.idle_cmd\|\.ignore_missing_pages\|\.inline\|\.imgscan\|\.kdfiles\|\.kframes\|\.kill\|\.lastevent\|\.lines\|\.load\|\.locale\|\.logappend\|\.logclose\|\.logfile\|\.logopen\|\.netuse\|\.noshell\|\.noversion\|\.nvload\|\.nvlist\|\.nvunload\|\.nvunloadall\|\.ofilter\|\.open\|\.opendump\|\.outmask\|\.pagein\|\.pcmd\|\.pop\|\.prefer_dml\|\.process\|\.prompt_allow\|\.push\|\.quit_lock\|\.readmem\|\.reboot\|\.record_branches\|\.reload\|\.remote_exit\|\.restart\|\.restart\|\.rrestart\|\.scroll_prefs\|\.secure\|\.send_file\|\.server\|\.servers\|\.setdll\|\.shell\|\.settings\|\.show_sym_failures\|\.sleep\|\.sound_notify\|\.srcfix\|\.srcnoisy\|\.srcpath\|\.step_filter\|\.suspend_ui\|\.symfix\|\.symopt\|\.sympath\|\.thread\|\.time\|\.tlist\|\.trap\|\.tss\|\.ttime\|\.typeopt\|\.unload\|\.unloadall\|\.urestart\|\.wake\|\.write_cmd_hist\|\.writemem\|\.wtitle\)"


syn match kdFunction "\.break"


hi def link kdBuiltin       Number
hi def link kdComment       Comment
hi def link kdToken         Statement
hi def link kdFunction      Number
hi def link kdVariable      Function
hi def link kdOperator      Operator
