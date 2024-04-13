.386
STACK SEGMENT USE16 STACK
	DB 200 DUP(0)
STACK ENDS
;
CODE SEGMENT USE16
	ASSUME CS:CODE,DS:CODE,SS:STACK
COUNT DB 18
HOUR DB ?,?,':'
MIN DB ?,?,':'
SEC DB ?,?
BUF_LEN=$-HOUR
CURSOR DW ?
OLD_INT DW ?,?
NEW08H PROC FAR
	PUSHF
	CALL DWORD PTR CS:OLD_INT
	DEC CS:COUNT
	JZ DISP
	IRET
DISP: 
	MOV CS:COUNT,18
	STI
	PUSHA
	PUSH DS
	PUSH ES
	MOV AX,CS
	MOV DS,AX
	MOV ES,AX
	CALL GET_TIME
	MOV BH,0
	MOV AH,3
	INT 10H
	MOV CURSOR,DX
	MOV BP,OFFSET HOUR
	MOV BH,0
	MOV DH,0
	MOV DL,80-BUF_LEN
	MOV BL,07H
	MOV CX,BUF_LEN
	MOV AL,0
	MOV AH,13H
	INT 10H
	MOV BH,0
	MOV DX,CURSOR
	MOV AH,2
	INT 10H
	POP ES
	POP DS
	POPA
	IRET
NEW08H ENDP
get_time proc
	mov al,4
	out 70H ,al
	jmp $+2
	in al,71H
	mov ah,al
	and al,0FH
	shr ah,4
	add ax,3030H
	xchg ah,al
	mov word ptr hour,ax
	mov al,2
	out 70H,al
	jmp $+2
	in al,71H
	mov ah,al
	and al,0FH
	shr ah,4
	add ax,3030H
	xchg ah,al
	mov word ptr min,ax
	mov al,0
	out 70H,al
	jmp $+2
	in al,71H
	mov ah,al
	and al,0FH
	shr ah,4
	add ax,3030H
	xchg ah,al
	mov word ptr sec,ax
	ret 
get_time endp

BEGIN:	PUSH	CS
		POP	DS
		MOV	AX,3508H
		INT	21H
		MOV	OLD_INT,BX
		MOV 	OLD_INT+2,ES
		MOV	DX,OFFSET	NEW08H
		MOV 	AX,2508H
		INT	21H
NEXT:		MOV	AH,0
		INT	16H
		CMP	AL,'q'
		JNE	NEXT
		LDS	DX,DWORD	PTR	OLD_INT
		MOV	AX,2508H
		INT	21H
		MOV	AH,4CH
		INT	21H
CODE		ENDS
		END	BEGIN