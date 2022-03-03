.model tiny
.code
org 100h

VIDEOSEG	equ 0b800h

.getch		macro
		xor ah, ah
		int 16h
		endm

Start:		mov ax, VIDEOSEG
		mov es, ax  ; now es pointes to video segment
		
		mov bx, (5 * 80d + 40d) * 2  ;es:[bx]->UL scr corner(top left) 
	
		.getch

		mov word ptr es:[bx], 'A' or (4eh shl 8)
		
		.getch

		mov ax, 4c00h ; exit(0);
		int 21h

end	 	Start