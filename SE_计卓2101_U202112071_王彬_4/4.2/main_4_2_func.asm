.686     
.model flat, stdcall
	ExitProcess PROTO :DWORD
	includelib  kernel32.lib		; ExitProcess �� kernel32.lib��ʵ��
	printf      PROTO C :VARARG
	scanf      PROTO C :VARARG
	includelib  libcmt.lib
	includelib  legacy_stdio_definitions.lib

.data


.code
; ����f����calc_f
; ʹ�üĴ������ݲ�����ecx,edx
; ����ֵ����� edx
calc_f proc addre:dword
	local bias:dword
	push ecx
	mov ecx,addre
	mov bias,100
	mov edx, 0		;edx��ż���ֵ
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


; �ƶ����ݺ���copyData
; ����addr_1��ʾ����д������ʼ��ַ��addr_2��ʾ��д����ʼ��ַ
; ʹ�ö�ջ�����д��ݲ���
; �Ĵ���ʹ�ã�edx ��ż���õ���fֵ
copyData proc addr_1:dword,addr_2:dword
	;�ƶ�����
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
	;�ƶ���ˮ��
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