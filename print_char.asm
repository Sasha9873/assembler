global _start
section .data
x db 'A'
t dd 19
n equ 100
;in db "%c", 0x0A, 0
;var db "x", 0x0A, 0
;len equ $ - var ;$ - current addr

section .bss
out_ resb n

section .text
_start:

;mov rax, 0x01

;
;mov eax, 3
;mov ecx, in
;mov edx, 100   ;length


mov eax, 0
mov al, [x]
mov ah, 0
push eax
mov eax, 4
mov ebx, 1
mov ecx, esp
mov edx, 1
int 80h

pop eax

;finish
mov eax, 1
mov ebx, 0
int 80h


