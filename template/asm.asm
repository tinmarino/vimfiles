_myfct@4 PROC NEAR
	; VAR DEFINE
	arg0	= dword ptr 8
	var0	= dword ptr -4

	; STACK SAVE
	push 	ebp
	mov 	ebp, esp
	add		esp, var0
	push	ebx
	push 	ecx


	; STACK RESTORE
	pop		ecx
	pop		ebx
	sub		esp, var0
	mov		esp, ebp
	pop		ebp
	retn 	4
_myfct@4 ENDP
