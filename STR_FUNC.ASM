.model tiny
.code
org 100h

VIDEOSEG   	equ 0b800h

COLOR		= 1Ah

WIND_WIDTH    	= 160d  
FRAME_WIDTH	= 16d
HEIGTH		equ 7d

ARRAY		= 2

MESLEN		= 6

SPACE		equ (5*WIND_WIDTH + WIND_WIDTH/2 - FRAME_WIDTH/2)  ;pointer to the top left corner


Start:		mov ax, VIDEOSEG
		mov es, ax  ; now es pointes to video segment

COMMENT *	mov si, offset _Str		
		call Strlen
	*	

		mov di, SPACE + WIND_WIDTH

		mov ah, COLOR

		mov ah, 09h
                mov dx, offset _Str   ;dx = &HelloStr;
                int 21h

		add di, WIND_WIDTH
		
		mov si, offset _Str
		lodsb       ; mov al, [si]; inc si;
		stosw       ; mov es:[di], ax; add di, 2	

		add di, WIND_WIDTH

		;mov ax, offset _Str
		;push ax
		;mov ax, offset _Str2
		;push ax
		;call StrCpy 	

		;mov ah, 09h
                ;mov dx, offset _Str   ;dx = &HelloStr;
                ;int 21h

Comment *	push offset _Str2
		push '$'
		call StrChr
		mov si, ax
		lodsb
		stosw
	*
		mov dx, 12
		push dx
		mov dx, offset _Str
		push dx
		push 10
		call Itoa

		mov ah, 09h
                mov dx, offset _Str   ;dx = &HelloStr;
                int 21h

		mov ax, 4c00h
		int 21h

_Str2		db "Mew$"
_Str		db "Hello$"


;------------------------------------------------
; Do str from number (the base of the number system(radix) is in stack).
; Entry: push in stack number, then addr of the str and then radix.
; Returns: None
; Note: str should be appropriate length.
; Destroy: None
;------------------------------------------------

Itoa		proc

		push bp
		mov bp, sp
		;sub sp, 4   ; space for uninitialised variable

		push si ax bx cx dx
				 
		mov si, [bp + 6]   ; SI = addr of str
		mov bh, [bp + 4]   ; BH = radix
		mov ax, [bp + 8]   ; AX = number	
		jmp Converting

BegConv:	;mov al, ah
		mov ah, 0
Converting:	div bh
		mov [si], ah
		inc si
		cmp al, 0
		jne BegConv
		;lodsb    ; mov al, [si]; inc si; 

		;xchg   reverse str
		;and divide another way if 2^n
		
		mov [si], '$'

		pop dx cx bx ax si			
		pop bp

		ret
		endp


;------------------------------------------------
; Counts string length.
; Entry: SI = addr str
; Returns: CX = str len
; Note: str ends with $, $ is not included in str len
; Destroy: CX, SI
;------------------------------------------------
StrLen		proc
		;mov si, offset _Str ;do in main not here

		push ax
		mov cx, 0

Count:		lodsb   ; mov al, [si]; inc si; 
		inc cx
		cmp al, '$'
		jne Count		 
		
		dec cx  ; $ - end sym

		pop ax
		
		ret
		endp

;------------------------------------------------
; Copy second str to the first str .
; Entry: push in stack addr of the first str then addr of the second str
; Returns: None
; Note: strs end with $, len first str >= len second str
; Destroy: None
;------------------------------------------------
StrCpy		proc
		
		push bp
		mov bp, sp
		;sub sp, 4   ; spece for uninitialised variable

		push si
		push ax
		;push cx
		push bx		
				 
		mov si, [bp + 4]    ; copy this (second)
		mov bx, [bp + 6]   ; copy in it (first)

		;call Strlen  ; now cx = strlen of second str

Copy:		lodsb      ; mov al, [si]; inc si;
		;stosw
		mov [bx], al;
		inc bx     ; mov pointer 	 
		cmp al, '$'
		jne Copy		
		    
		pop bx				
		;pop cx
		pop ax
		pop si

		pop bp

		ret
		endp


;------------------------------------------------
; Find first necessary symbol in str.
; Entry: push in stack addr of the str then symbol you want to find.
; Returns: AX = 0 if sym is not in str and else pointer to appropriate first symbol.
; Note: strs end with $s
; Destroy: AX
;------------------------------------------------

StrChr		proc

		push bp
		mov bp, sp
		;sub sp, 4   ; spece for uninitialised variable

		push si
				 
		mov si, [bp + 6]   ; SI = addr str
		mov ah, [bp + 4]   ; AH = sym  		
		    
FindSym:	lodsb      ; mov al, [si]; inc si;		
		cmp al, '$'
		je NotFound
		cmp al, ah
		jne FindSym				

		mov ax, si
		jmp Found

NotFound:	cmp al, ah
		je Find
		mov ax, 1

Find:		mov ax, si
Found:		pop si	

		dec ax			

		pop bp

		ret
		endp
		

		
end		Start