.model tiny
.code
org 100h

VIDEOSEG   	equ 0b800h

COLOR		= 1Ah

WIND_WIDTH    	= 160d  
FRAME_WIDTH	= 16d
HEIGTH		equ 7d

ARRAY		= 3

SPACE		equ (5*WIND_WIDTH + WIND_WIDTH/2 - FRAME_WIDTH/2)  ;pointer to the top left corner


Start:		mov ax, VIDEOSEG
		mov es, ax  ; now es pointes to video segment
		

;------------------------------------------------
;Up
;------------------------------------------------
		mov ax, ARRAY
		cmp ax, 2
		je UpArray2
		ja UpConsole
		mov si, offset CharArray
		jmp Up 

UpConsole:	mov si, 082h ;addr of buffer
		jmp Up 


UpArray2:       mov si, offset CharArray2
Up:		mov di, SPACE
		mov dx, di
		mov cx, FRAME_WIDTH
		call DrawLine
 
		;mov ah, 09h
                ;int 21h

		;mov ah, 040h ;interrupt func to print dtr
		;mov bx, 01h  ;file handler(syandart output - 01h)
		;mov cx, 09h ;length
		;mov dx, 082h ;addr of buffer
		;int 21h

		;mov ah, COLOR
		;mov dx, 082h
		
		
		;mov si, offset CharArrayUp
		;mov di, SPACE  ;pointer to the top left corner
		;mov cx, FRAME_WIDTH	
	

;------------------------------------------------
;Middle
;------------------------------------------------

		mov bx, HEIGTH - 2

Middle:		mov ax, ARRAY
		cmp ax, 2
		je MidArray2
		ja Console
		mov si, offset CharArray + 3
		jmp AllMiddle

Console:	mov si, 082h + 3 ;addr of buffer
		jmp AllMiddle

MidArray2:      mov si, offset CharArray2 + 3
AllMiddle: 	add dx, WIND_WIDTH
		mov di, dx
		mov cx, FRAME_WIDTH
		call DrawLine
		sub bx, 1
		cmp bx, 0
		ja Middle

;------------------------------------------------
;Down
;------------------------------------------------
	
		add dx, WIND_WIDTH
		mov di, dx
		mov cx, FRAME_WIDTH
		call DrawLine
		

		mov ax, 4c00h
		int 21h

_Str		db "console arg:$"

CharArray	db '737545090'

CharArray2	db '+-+|_|+-+'

Heigth_2	db HEIGTH

;------------------------------------------------
; Draws a horison line
;
; Entry: SI = addr of array containing frame symbols : [Lft] [Mid]..[Mid] [Rgt]
;	 DI = dtart addr to draw
;	 CX = line length
; Exit	 None
; Note:	 ES = Video Seg addr
; Destroy: AX CX SI DI
;------------------------------------------------

DrawLine	proc
	
		cld

		mov ah, COLOR

@@begin_line:	lodsb       ; mov al, [si]; inc si;
		stosw       ; mov es:[di], ax; add di, 2
		
		lodsb
		rep stosw   ; while(cx--){*(di+2) = *ax}
		
		lodsb
@@end_line:	stosw

		ret
		endp

end		Start