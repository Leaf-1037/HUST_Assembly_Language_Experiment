.686     
.model flat, stdcall
	ExitProcess PROTO :DWORD
	includelib  kernel32.lib		; ExitProcess 在 kernel32.lib中实现
	printf      PROTO C :VARARG
	includelib  libcmt.lib
	includelib  legacy_stdio_definitions.lib

.data
	timeCycle1 dd ?
	timeCycle2 dd ?
	statusInfos STRUCT
		SAMID	db 9 DUP(0)  ;每组数据的流水号（可以从1开始编号）
		SDA		dd  ?				;状态信息a
		SDB		dd  ?				;状态信息b
		SDC		dd  ?				;状态信息c
		SF      dd  ?				;处理结果f
	statusInfos ENDS

	;结构数组待处理数据  		
	;dataArr statusInfos <'00000001', 2540, 1, 1000, >		;low
	;	statusInfos <'00000002', 2540, 1, 1, >				;mid
	;	statusInfos <'00000003', 2540, 1000, 1, >		;high
	;	statusInfos <'00000004', 3, 4, 5, >					;low
	;	statusInfos <'00000005', 4, 5, 6, >	

	dataArr statusInfos 10000 dup(<'00000001',321,432,10,?>)


	LOWF statusInfos 10000 dup(<>)
	MIDF statusInfos 30 dup(<>)
	HIGHF statusInfos 30 dup(<>)

	lpfmt2 db "    {SAMID = '%s', SDA = %d, SDB = %d, SDC = %d, SF = %d}", 0ah, 0dh, 0
	tips db "Results:", 0ah, 0dh, 0ah, 0dh, 0
	tipLOWF db "LOWF:", 0ah, 0dh, 0
	tipMIDF db "MIDF:", 0ah, 0dh, 0
	tipHIGHF db "HIGHF:", 0ah, 0dh, 0
	getOFFSET db "time = %d", 0ah, 0dh, 0
	lpfmt4 db "total_time = %d", 0ah, 0dh, 0

.stack 200


.code
main proc c

rdtsc
mov timeCycle1, eax
L0:
	mov ecx, 0		;累加计数
	mov ebx, 0		;LOWF存储区数据个数
	mov esi, 0		;MIDF存储区数据个数
	mov edi, 0		;HIGHF存储区数据个数
   
L1:
    mov edx, 0		;edx存放计算值
    mov edx, dataArr[ecx].SDA
	sal edx, 2
	add edx, dataArr[ecx].SDA
	add edx, dataArr[ecx].SDB
	add edx, 100
	sub edx, dataArr[ecx].SDC
	sar edx, 7
	
	cmp edx, 100
	jl SAVE_LOWF

	cmp edx, 100
	je SAVE_MIDF

	cmp edx, 100
	jg SAVE_HIGHF
	

LUP:
	add ecx, 25
	cmp ecx, 249975			;总次数 25*（N-1）
	jle L1
	

L2:
	rdtsc
	mov timeCycle2, eax
	invoke printf,offset tips
			;invoke printf,offset lpfmt2,OFFSET MIDF[0].SAMID,MIDF[0].SDA,MIDF[0].SDB,MIDF[0].SDC,MIDF[0].SF
	
	mov ecx,0
	
	;mov edx, offset LOWF[ecx].SAMID

	invoke printf,offset tipLOWF
	invoke printf,offset lpfmt2, offset LOWF[0].SAMID, LOWF[0].SDA,LOWF[0].SDB,LOWF[0].SDC,LOWF[0].SF
	invoke printf,offset lpfmt2, offset LOWF[25].SAMID, LOWF[25].SDA,LOWF[25].SDB,LOWF[25].SDC,LOWF[25].SF
	invoke printf,offset lpfmt2, offset LOWF[50].SAMID, LOWF[50].SDA,LOWF[50].SDB,LOWF[50].SDC,LOWF[50].SF
	invoke printf,offset lpfmt2, offset LOWF[75].SAMID, LOWF[75].SDA,LOWF[75].SDB,LOWF[75].SDC,LOWF[75].SF
	invoke printf,offset lpfmt2, offset LOWF[100].SAMID, LOWF[100].SDA,LOWF[100].SDB,LOWF[100].SDC,LOWF[100].SF

	invoke printf,offset tipMIDF
	invoke printf,offset lpfmt2, offset MIDF[0].SAMID, MIDF[0].SDA,MIDF[0].SDB,MIDF[0].SDC,MIDF[0].SF
	invoke printf,offset lpfmt2, offset MIDF[25].SAMID, MIDF[25].SDA,MIDF[25].SDB,MIDF[25].SDC,MIDF[25].SF
	invoke printf,offset lpfmt2, offset MIDF[50].SAMID, MIDF[50].SDA,MIDF[50].SDB,MIDF[50].SDC,MIDF[50].SF
	invoke printf,offset lpfmt2, offset MIDF[75].SAMID, MIDF[75].SDA,MIDF[75].SDB,MIDF[75].SDC,MIDF[75].SF
	invoke printf,offset lpfmt2, offset MIDF[100].SAMID, MIDF[100].SDA,MIDF[100].SDB,MIDF[100].SDC,MIDF[100].SF

	invoke printf,offset tipHIGHF
	invoke printf,offset lpfmt2, offset HIGHF[0].SAMID, HIGHF[0].SDA,HIGHF[0].SDB,HIGHF[0].SDC,HIGHF[0].SF
	invoke printf,offset lpfmt2, offset HIGHF[25].SAMID, HIGHF[25].SDA,HIGHF[25].SDB,HIGHF[25].SDC,HIGHF[25].SF
	invoke printf,offset lpfmt2, offset HIGHF[50].SAMID, HIGHF[50].SDA,HIGHF[50].SDB,HIGHF[50].SDC,HIGHF[50].SF
	invoke printf,offset lpfmt2, offset HIGHF[75].SAMID, HIGHF[75].SDA,HIGHF[75].SDB,HIGHF[75].SDC,HIGHF[75].SF
	invoke printf,offset lpfmt2, offset HIGHF[100].SAMID, HIGHF[100].SDA,HIGHF[100].SDB,HIGHF[100].SDC,HIGHF[100].SF

	invoke printf, offset getOFFSET,timeCycle1
	invoke printf, offset getOFFSET,timeCycle2
	mov eax,timeCycle2
	sub eax,timeCycle1
	invoke printf, offset lpfmt4,eax


	invoke ExitProcess, 0

SAVE_LOWF:
	;移动数据
	mov LOWF[ebx].SF, edx
	mov edx, dataArr[ecx].SDA
	mov LOWF[ebx].SDA, edx
	mov edx, dataArr[ecx].SDB
	mov LOWF[ebx].SDB, edx
	mov edx, dataArr[ecx].SDC
	mov LOWF[ebx].SDC, edx

	;移动流水号
	mov edx, 0		;edx index
LP1:
	mov eax, dword ptr dataArr[ecx].SAMID[edx*4]
	mov dword ptr LOWF[ebx].SAMID[edx*4], eax
	inc edx
	cmp edx,3
	jl LP1

	add ebx, 25
	jmp LUP


SAVE_MIDF:
	;移动数据
	mov MIDF[esi].SF, edx
	mov edx, dataArr[ecx].SDA
	mov MIDF[esi].SDA, edx
	mov edx, dataArr[ecx].SDB
	mov MIDF[esi].SDB, edx
	mov edx, dataArr[ecx].SDC
	mov MIDF[esi].SDC, edx

	;移动流水号
	mov edx, 0		;edx index
LP2:
	mov eax, dword ptr dataArr[ecx].SAMID[edx*4]
	mov dword ptr MIDF[esi].SAMID[edx*4], eax
	inc edx
	cmp edx,3
	jl LP2

	add esi, 25
	jmp LUP


SAVE_HIGHF:
	;移动数据
	mov HIGHF[edi].SF, edx
	mov edx, dataArr[ecx].SDA
	mov HIGHF[edi].SDA, edx
	mov edx, dataArr[ecx].SDB
	mov HIGHF[edi].SDB, edx
	mov edx, dataArr[ecx].SDC
	mov HIGHF[edi].SDC, edx

	;移动流水号
	mov edx, 0		;edx index
LP3:
	mov eax, dword ptr dataArr[ecx].SAMID[edx*4]
	mov dword ptr HIGHF[edi].SAMID[edx*4], eax
	inc edx
	cmp edx,3
	jl LP3


	add edi, 25
	jmp LUP

main endp
END
