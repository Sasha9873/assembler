.model tiny
.code
org 100h

Start:          mov ah, 09h
                mov dx, offset HelloStr   ;dx = &HelloStr;
                int 21h
HelloStr        db 'Mew$'

		mov ax, 4c00h 	;exit(0);		
                int 21h

end             Start
