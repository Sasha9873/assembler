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

		mov si, offset _Str		
		call Strlen	



		mov ah, COLOR
		
		mov si, offset _Str
		lodsb       ; mov al, [si]; inc si;
		stosw       ; mov es:[di], ax; add di, 2	

		mov ax, offset _Str
		push ax
		mov ax, offset _Str2
		push ax
		call StrCpy 	

		mov ah, COLOR
		
		mov si, offset _Str
		lodsb       ; mov al, [si]; inc si;
		stosw       ; mov es:[di], ax; add di, 2


		mov ax, 4c00h
		int 21h

_Str2		db "Mew$"
_Str		db "Hello$"


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
		sub sp, 4   ; spece for uninitialised variable
		
		push si
		push ax
		;push cx
		push bx
				 
		mov si, [bp + 2]    ; copy this (second)
		move bx, [bp + 4]   ; copy in it (first)

		;call Strlen  ; now cx = strlen of second str

Copy:		lodsb      ; mov al, [si]; inc si;
		mov bx, al;
		inc bx     ; move pointer 	 
		cmp al, '$'
		jne Copy		
		    
		pop bx				
		;pop cx
		pop ax
		pop si

		ret
		endp
		
end		Start