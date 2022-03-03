.model tiny
.code
org 100h

VIDEOSEG   	equ 0b800h

COLOR		= 1Ah

WIND_WIDTH    	= 160d  
FRAME_WIDTH	= 16d
HEIGTH		equ 14h

SPACE		equ (5*WIND_WIDTH + WIND_WIDTH/2 - FRAME_WIDTH/2)  ;pointer to the top left corner


Start:		;mov es, VIDEOSEG
		;mov es, bx

                mov dx, offset _Str   ;dx = &_Str;
		mov ah, 09h
                int 21h

		mov ah, 040h ;interrupt func to print dtr
		mov bx, 01h  ;file handler(syandart output - 01h)
		mov cx, 09h ;length
		mov dx, 082h ;addr of buffer
		int 21h

		;mov ah, COLOR
		;mov dx, 082h
		
		
		;mov si, offset CharArrayUp
		;mov di, SPACE  ;pointer to the top left corner
		;mov cx, FRAME_WIDTH		

@@begin_line:	;mov al, CORNER_SYM
		;lodsb       ; mov al, [si]; inc si;
		;stosw       ; mov es:[di], ax; add di, 2
		
		;lodsb
		;rep stosw   ; while(cx--){*(di+2) = *ax}
		
		;lodsb
@@end_kine:	;stosw

		mov ax, 4c00h
		int 21h

_Str		db "console arg:$"

end	Start