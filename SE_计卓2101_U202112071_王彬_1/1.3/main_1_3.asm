.686     
.model flat, stdcall
 ExitProcess PROTO :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf proto c :ptr sbyte, :vararg
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib
 scanf proto c : dword,:vararg

.DATA
password db 'please_eat_apple', 0
buf1 db 'OK!', 0
buf2 db 'Incorrect Password!', 0
buf3 db '请尝试输入正确的字符串密码:', 0
lpFmt	db	"%s",0ah, 0dh, 0
format2 db '%s',0    ;用于scanf函数格式化输入.
val db 16 dup(0)   ;存储scanf得到的用户输入

.STACK 250

.CODE
main proc c
   invoke printf,offset lpFmt,offset buf3
   invoke scanf,offset format2,offset val
   mov ecx, 0			;ecx作为循环变量

L1:
   mov eax, offset val
   mov bl, password[ecx]
   cmp bl, [eax+ecx]
   jnz Exit				;如果有不一样的，则输出错误
   inc ecx				;ecx增加1，迭代20次
   cmp ecx, 15
   jle L1

   invoke printf,offset lpFmt,offset buf1		;打印正确代码
   invoke ExitProcess, 0

Exit:
   invoke printf,offset lpFmt,offset buf2		;打印错误代码
   invoke ExitProcess, 0
main endp
END