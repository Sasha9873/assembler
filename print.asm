;%include "st_io.inc"

global _start
section .data
x db 'A'
t dd 19
max_len equ 100

inglish_chars equ 26

c db "wtttt", 0
out_str db "%c %s %d %o 2: %b 16: %x %%", 0 
;out_str db "%c %d", 0 

fault db "Inappropriate symbol after '%'", 0ha, 0 ;0ha - перевод строки(\n), 0 - конец строки

jump_table: 
	dq My_default
	dq Print_bin_number
	dq Print_sym
	dq Print_dec_number
	times 10 dq My_default
	dq Print_ox_number
	times 3 dq My_default
	dq Print_str
	times 4 dq My_default
	dq Print_hex_number
	times 2 dq My_default


section .bss
empty_str resb max_len

section .text
_start:

	mov eax, 666
	push eax
	push eax
	push eax
	push eax

	mov eax, 0
	mov eax, c
	push eax

	mov eax, 0
	mov al, [x]
	mov ah, 0
	push eax

	mov eax, out_str
	push eax

	call Print


	mov eax, 1
	mov ebx, 0
	int 80h


Print:

	push ebp

	mov ebp, esp

	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	mov edi, 2  ; edi = stack shift
	mov esi, [ebp + edi*4] ;skip  saved ebp and ret addr ; eax = addr of out_str
	inc edi

Ret_per:	
	xor eax, eax
	mov al, [esi]
	cmp al, '%'
	je Found_percent
	cmp al, 0
	je end_print
	jmp Print_blank_or_sym
	

end_print:
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax

	pop ebp

	ret



Found_percent:

	inc esi
	xor eax, eax
	mov al, [esi]
	inc esi

	cmp al, '%'
	je Print_percent

	sub al, 'a'
	cmp al, 0    ; mistake
	jl My_default
	cmp al, inglish_chars - 1
	jg My_default

	mov edx, [jump_table + eax*8]  ; now there is addr we want to jump next in edx  

	add al, 'a'
	jmp edx

;	cmp al, 'c'
;	je Print_sym
;	cmp al, 's'
;	je Print_str
;	cmp al, 'd'
;	je Print_dec_number
;	cmp al, 'o'
;	je Print_ox_number
;	cmp al, 'b'
;	je Print_bin_number
;	cmp al, 'x'
;	je Print_hex_number

;	jmp Ret_per


Print_percent:

	push eax

	mov eax, 4
	mov ebx, 1
	mov ecx, esp
	mov edx, 1
	int 80h

	pop eax

	jmp Ret_per


Print_blank_or_sym:
	inc esi
	push eax

	mov eax, 4
	mov ebx, 1
	mov ecx, esp
	mov edx, 1
	int 80h

	pop eax

	jmp Ret_per

Print_sym:
	mov eax, 0
	mov eax, [ebp + edi*4] ;skip  addr of out_str, saved ebp and ret addr
	;mov ah, 0
	push eax

	inc edi

	mov eax, 4
	mov ebx, 1
	mov ecx, esp
	mov edx, 1
	int 80h

	pop eax

	jmp Ret_per


Print_str:
	mov eax, esi
	mov ecx, 0
	mov esi, [ebp + edi*4]
	call StrLen  ; now ecx = str len
	mov esi, eax

	mov edx, ecx
	mov eax, 4
	mov ebx, 1
	mov ecx, [ebp + edi*4]
	int 80h

	inc edi
	
	jmp Ret_per


Print_dec_number:
	mov ebx, 10
	jmp Print_number

Print_number:
	mov eax, [ebp + edi*4]
	push eax
	inc edi

	mov eax, empty_str ; str max len
	push eax

	push ebx

	call Itoa  ; now there is owr number in empty_str
	pop eax
	pop eax
	pop eax

	mov eax, esi
	mov esi, empty_str
	call StrLen  ; now ecx = str len
	mov esi, eax

	mov edx, ecx
	mov eax, 4
	mov ebx, 1
	mov ecx, empty_str
	int 80h

	jmp Ret_per


Print_ox_number:
	mov ebx, 8
	jmp Print_number

Print_bin_number:
	mov ebx, 2
	jmp Print_number


Print_hex_number:
	mov ebx, 16
	jmp Print_number

My_default:
	mov eax, esi
	mov ecx, 0
	mov esi, fault
	call StrLen  ; now ecx = str len
	mov esi, eax

	mov edx, ecx
	mov eax, 4
	mov ebx, 1
	mov ecx, fault
	int 80h

	jmp end_print

	

;------------------------------------------------
; Do str from number (the base of the number system(radix) is in stack).
; Entry: push in stack number, then addr of the str and then radix.
; Returns: None
; Note: str should be appropriate length.
; Destroy: None
;------------------------------------------------

Itoa:	;proc

		push ebp
		mov ebp, esp
		;sub esp, 4   ; space for uninitialised variable

		push esi
		push eax
		push ebx
		push ecx
		push edx
				 
		mov esi, [ebp + 3*4]   ; ESI = addr of str
		mov ebx, [ebp + 2*4]   ; EBH = radix
		mov edx, 0
		mov eax, [ebp + 4*4]   ; EAX = number
		jmp Converting

BegConv:	
		;mov al, ah
		mov edx, 0
Converting:	
		div ebx
		cmp dl, 9
		ja Bigger
		add dl, '0'
ret_big:		
		mov [esi], dl
		inc esi
		cmp eax, 0
		jne BegConv
		jmp end_str
Bigger:		
		add dl, 'A'
		sub dl, 10
		jmp ret_big

end_str:
		mov ah, 0   ; end of the str
		mov [esi], ah


; reverse str
		mov esi, [ebp + 3*4]   ; ESI = addr of str
		call StrLen   ; ECX = strlen without 0
		mov ebx, [ebp + 3*4]
		add ebx, ecx
		dec ebx   ; do not move 0

Reverse:
		mov al, [esi]
		mov ah, [ebx]
		mov [ebx], al
		mov [esi], ah
		
		dec ebx
		inc esi
		cmp ebx, esi
		ja Reverse
		

		pop edx 
		pop ecx 
		pop ebx
		pop eax
		pop esi			
		pop ebp

		ret
		;endp


;------------------------------------------------
; Counts string length.
; Entry: ESI = addr str
; Returns: ECX = str len
; Note: str ends with 0, 0 is not included in str len
; Destroy: ECX
;------------------------------------------------
StrLen:	;proc
		;mov esi, offset _Str ;do in main not here

		push eax
		push esi
		mov ecx, 0

Count:	lodsb   ; mov al, [si]; inc si; 
		inc ecx
		cmp al, 0
		jne Count		 
		
		dec ecx  ; 0 - end sym

		pop esi
		pop eax
		
		ret
		;endp