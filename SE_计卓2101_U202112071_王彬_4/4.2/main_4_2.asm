.686     
.model flat, stdcall
	ExitProcess PROTO :DWORD
	includelib  kernel32.lib		; ExitProcess 在 kernel32.lib中实现
	printf      PROTO C :VARARG
	scanf      PROTO C :VARARG
	includelib  libcmt.lib
	includelib  legacy_stdio_definitions.lib

	calc_f proto :dword
	copyData proto :dword,:dword

.data
	username db 36h,20h,2fh,26h,23h,28h,2fh,0
	password db 20h,31h,31h,2dh,24h,26h,33h,20h,31h,24h,0

	str1 db 11 dup(0)
	str2 db 11 dup(0)

	flag dd ?

	buf_enter db 'Enter your username and password',0
	buf_pass db 'Correct! Processing now...',0
	buf_wrong db 'Wrong username or password. Please try again later.',0
	buf_exit db 'You have entered wrong 3 times. The program will be exit.',0

	timeCycle1 dd ?
	timeCycle2 dd ?
	c1 byte 0,0

	statusInfos STRUCT
		SAMID	db 9 DUP(0)  ;每组数据的流水号（可以从1开始编号）
		SDA		dd  ?				;状态信息a
		SDB		dd  ?				;状态信息b
		SDC		dd  ?				;状态信息c
		SF      dd  ?				;处理结果f
	statusInfos ENDS

	;结构数组待处理数据  		
	dataArr statusInfos <'00000001', 2540, 1, 1000, >		;low
		statusInfos <'00000002', 2540, 1, 1, >				;mid
		statusInfos <'00000003', 2540, 1000, 1, >		;high
		statusInfos <'00000004', 3, 4, 5, >					;low
		statusInfos <'00000005', 4, 5, 6, >	

	;dataArr statusInfos 10000 dup(<'00000001',321,432,10,?>)

	LOWF statusInfos 30 dup(<>)
	MIDF statusInfos 30 dup(<>)
	HIGHF statusInfos 30 dup(<>)

	lpfmt1 db "%s",0ah,0dh,0
	lpfmt2 db "    {SAMID = '%s', SDA = %d, SDB = %d, SDC = %d, SF = %d}", 0ah, 0dh, 0
	tips db "Results:", 0ah, 0dh, 0ah, 0dh, 0
	tipLOWF db "LOWF:", 0ah, 0dh, 0
	tipMIDF db "MIDF:", 0ah, 0dh, 0
	tipHIGHF db "HIGHF:", 0ah, 0dh, 0
	getOFFSET db "time = %d", 0ah, 0dh, 0
	lpfmt4 db "total_time = %d", 0ah, 0dh, 0
	lpfmt5 db "%s",0
	lpfmt6 db "%c",0

	cnt dd ?


	;数据段中此为任务4的加解密部分代码

	machine_code db 32H
	len = $ - machine_code
	oldprotect dd ?

	TIMEE dd ?

	OLDINT1 DW  0,0               ;1号中断的原中断矢量（用于中断矢量表反跟踪）
	OLDINT3 DW  0,0               ;3号中断的原中断矢量

	ADDRTABLE DW ?,?,?
	OLD_INT1 DW ?,?
	OLD_INT3 DW ?,?




.stack 200


.code

ENCODER MACRO Input,STRLENTH
	LOCAL counter_J
	mov EBX,0
	mov EAX,0
counter_J:
	mov al,Input[EBX]
	xor al, 41H
	mov Input[EBX],al
	inc EBX
	cmp EBX,STRLENTH
	JL counter_J
	ENDM

; 子程序strcmp str1 str2
; 用于比较两个字符串的是否相等
STR_CMP  macro str1,str2,ans
            LOCAL sc_cmp,sc_start,sc_exit
            mov ecx,0
            mov ans,1
            jmp sc_start
sc_cmp:
            mov ans,0
            jmp sc_exit
sc_start:
            inc ecx
            mov eax,offset str1
            mov ebx,offset str2
            add eax,ecx
            add ebx,ecx
            mov al,[eax]
			xor al,65
            mov bl,[ebx]
            cmp al,bl
            jnz sc_cmp
            cmp ecx,10
            jnz sc_start
            jz sc_exit
sc_exit:     
endm

; 打印MIDF存储区函数
; 打印前五条即可
printMIDF proc
	invoke printf,offset tips
	invoke printf,offset tipMIDF
	invoke printf,offset lpfmt2, offset MIDF[0].SAMID, MIDF[0].SDA,MIDF[0].SDB,MIDF[0].SDC,MIDF[0].SF
	invoke printf,offset lpfmt2, offset MIDF[25].SAMID, MIDF[25].SDA,MIDF[25].SDB,MIDF[25].SDC,MIDF[25].SF
	invoke printf,offset lpfmt2, offset MIDF[50].SAMID, MIDF[50].SDA,MIDF[50].SDB,MIDF[50].SDC,MIDF[50].SF
	invoke printf,offset lpfmt2, offset MIDF[75].SAMID, MIDF[75].SDA,MIDF[75].SDB,MIDF[75].SDC,MIDF[75].SF
	invoke printf,offset lpfmt2, offset MIDF[100].SAMID, MIDF[100].SDA,MIDF[100].SDB,MIDF[100].SDC,MIDF[100].SF
	ret
printMIDF endp


main proc c

mov cnt, 1

MODULE_1_PASSWORD:
;	MOV ADDRTABLE,OFFSET PASS1
;	MOV ADDRTABLE+2,OFFSET OVER
;	MOV ADDRTABLE+4,OFFSET PASS2

	cmp cnt,3
	jg EXIT
	invoke printf, offset lpfmt1, offset buf_enter
	mov flag, 1
	invoke scanf, offset lpfmt5, offset str1
	invoke scanf, offset lpfmt5, offset str2

	cli                       ;计时反跟踪开始 
    mov  ah,2ch 
    int  21h
    push dx                   ;保存获取的秒和百分秒

PASS1:
	STR_CMP username,str1,flag
PASS2:
	STR_CMP password,str2,flag

	mov  ah,2ch                 ;获取第二次秒与百分秒
    int  21h
    sti
    cmp  dx,[esp]               ;计时是否相同
    pop  dx
    jz   OK1                    ;如果计时相同，通过本次计时反跟踪   
    jmp OVER           ;如果计时不同，则把转移地址偏离P1
OK1:

	cmp flag,1
	je RIGHT_PASSWORD

	db  'Where to go'            ;定义的冗余信息，扰乱视线

WRONG_PASSWORD:
	inc cnt
	invoke printf, offset lpfmt1, offset buf_wrong
	jmp MODULE_1_PASSWORD

RIGHT_PASSWORD:
	invoke  printf, offset lpfmt1, offset buf_pass
	jmp L0

rdtsc
mov timeCycle1, eax
L0:
	mov ecx, 0		;累加计数
	mov ebx, 0		;LOWF存储区数据个数
	mov esi, 0		;MIDF存储区数据个数
	mov edi, 0		;HIGHF存储区数据个数
   
L1:
	add ecx,offset dataArr
    invoke calc_f,ecx
	sub ecx,offset dataArr
	
	cmp edx, 100
	jl SAVE_LOWF

	cmp edx, 100
	je SAVE_MIDF

	cmp edx, 100
	jg SAVE_HIGHF
	

SAVE_LOWF:
	add ecx, OFFSET dataArr
	add ebx, OFFSET LOWF
OVER:
	invoke copyData, ecx, ebx
	sub ecx, OFFSET dataArr
	sub ebx, OFFSET LOWF

	add ebx, 25
	jmp LUP

SAVE_MIDF:
	add ecx, OFFSET dataArr
	add esi, OFFSET MIDF
	invoke copyData, ecx, esi
	sub ecx, OFFSET dataArr
	sub esi, OFFSET MIDF
	
	add esi, 25
	jmp LUP

SAVE_HIGHF:
	add ecx, OFFSET dataArr
	add edi, OFFSET HIGHF
	invoke copyData, ecx, edi
	sub ecx, OFFSET dataArr
	sub edi, OFFSET HIGHF

	add edi, 25
	jmp LUP

LUP:
	add ecx, 25
	cmp ecx, 100			;总次数 25*（N-1）
	jle L1
	

L2:
	rdtsc
	mov timeCycle2, eax
	invoke printMIDF
	invoke scanf,offset lpfmt5, offset str1
	cmp [str1],'r'
	je L0

EXIT:
	invoke  printf, offset lpfmt1, offset buf_exit
	invoke ExitProcess, 0


main endp


END
