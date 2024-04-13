.686     
.model flat, stdcall
	ExitProcess PROTO :DWORD
	includelib  kernel32.lib		; ExitProcess 在 kernel32.lib中实现
	printf      PROTO C :VARARG
	scanf      PROTO C :VARARG
	includelib  libcmt.lib
	includelib  legacy_stdio_definitions.lib

.data


.code
; 计算f函数calc_f
; 使用寄存器传递参数：ecx,edx
; 返回值存放至 edx
calc_f proc addre:dword
	local bias:dword
	push ecx
	mov ecx,addre
	mov bias,100
	mov edx, 0		;edx存放计算值
    mov edx, [ecx+9]
	sal edx, 2
	add edx, [ecx+9]
	add edx, [ecx+13]
	add edx, bias
	sub edx, [ecx+17]
	sar edx, 7
	pop ecx
	ret
calc_f endp


; 移动数据函数copyData
; 参数addr_1表示被抄写对象起始地址，addr_2表示抄写至起始地址
; 使用堆栈法进行传递参数
; 寄存器使用：edx 存放计算得到的f值
copyData proc addr_1:dword,addr_2:dword
	;移动数据
	push ecx
	push ebx
	push eax

	mov ebx,addr_2
	mov ecx,addr_1
	mov [ebx+21], edx
	mov edx, [ecx+9]
	mov [ebx+9], edx
	mov edx, [ecx+13]
	mov [ebx+13], edx
	mov edx, [ecx+17]
	mov [ebx+17], edx
	;移动流水号
	mov edx, 0		;edx index
LPT:
	mov eax, dword ptr [ecx+edx*4]
	mov dword ptr [ebx+edx*4], eax
	inc edx
	cmp edx,3
	jl LPT

	pop eax
	pop ebx
	pop ecx
	ret
copyData endp

end

