.MODEL small
.8086
.DATA
	TABLE_K     DB     0EEh,0EDH,0EBH,0E7H,0DEH,0DDH
				DB     0DBH,0D7H,0BEH,0BDH,0BBH,0B7H
				DB    07EH,07DH,07BH,077H

;display table
	TABLE_D  	DB   3fh,06H, 5BH,  4FH, 66H, 6DH
			DB	    7DH,  27H, 7FH, 6FH, 77H, 7CH,
			DB     39H,  5EH, 79H, 71H

	count dw 0000h
	flag dw 0000h
	autoval dw 0000h

.STACK 1024
.CODE
.STARTUP

	cli
	mov       ax,@data
	mov       ds,ax
	mov       es,ax
	;port init
	mov al,88h
	out 06h,al
	mov al,0ffh
	out 02h,al
X0:	mov al,00h
	out 04h,al
X1:	in al,04h
	and al,0f0h
	cmp al,0f0h
	jnz X1
	call D20
	mov al,00h
	out 04h,al
X2:	in al,04h
	and al,0f0h
	cmp al,0f0h
	jz X2
	call D20
	mov al,00h
	out 04h,al
	in al,04h
	and al,0f0h
	cmp al,0f0h
	jz X2

	mov al,0Eh
	mov bl,al
	out 04h,al
	in al,04h
	and al,0f0h
	cmp al,0f0h
	jnz X3
	mov al, 0dh
	mov bl,al
	out 04h ,al
	in al,04h
	and al,0f0h
	cmp al,0f0h
	jnz X3
	mov al, 0bh
	mov bl,al
	out 04h,al
	in al,04h
	and al,0f0h
	cmp al,0f0h
	jnz X3
	mov al, 07h
	mov bl,al
	out 04h,al
	in al,04h
	and al,0f0h
	cmp al,0f0h
	jz X2

X3: or al,bl
	mov cx,0fh
	mov di,00h
	lea di,DS:TABLE_K
X4:	cmp al,[di]
	jz X5
	inc di
	dec cx
	jnz X4

X5: cmp di,04
	jg X8
	inc di
	mov count,di
	cmp flag, 0001h
	jnz X14
	mov cx, count
    mov autoval, cx
	;For counter 0
	mov al, 34h
	out 0eh, al
	mov al, 0e8h
	out 08h, al
	mov al, 03h
	out 08h, al
	;For counter 1
	mov al, 74h
	out 0eh, al
	mov al, 10h
	out 0ah, al
	mov al, 27h
	out 0ah, al
	;For counter 2
	mov al, 90h
	out 0eh, al
	mov al, 01h 	;change it to autoval make it 16 bit change corresponding control word
	out 0ch, al





X14:cmp count, 0dh
	jnz X17
	call auto
X17:jmp X11
X8:	cmp di,09
	jz X6
	cmp di,0ah
	jz X12
	cmp di,0bh
	jz XSt
	cmp di,0ch
	jz Xsp
	jmp X10
X11:lea bx,DS:TABLE_D
	mov al,[bx+di]
	not al
	out 02h,al
	call sespeed
	jmp X10
X6:	call increase
	jmp X10
X12: call decrease
	jmp X10
Xst: call start
	jmp X0
Xsp: call stop
X10:	jmp X0

.EXIT

D20 proc near
	mov cx,2220
X9: loop X9
	ret
D20 endp
sespeed proc near
	mov cx,count
	mov al,00h
Xadd: add al,33h
	dec cx
	jnz Xadd
	out 00h,al
	ret
sespeed endp

increase proc near
		cmp count,05
		jge X7
		inc count
		mov di,count
		lea bx,DS:TABLE_D
	mov al,[bx+di]
	not al
	out 02h,al
	call sespeed
X7:		ret
increase endp

decrease proc near
	cmp count,01
	jle X13
	dec count
	mov di,count
	lea bx,DS:TABLE_D
	mov al,[bx+di]
	not al
	out 02h,al
	call sespeed
X13: ret
decrease endp

start proc near
	cmp count,00
	jg Xend
	mov count,01
	mov di,count
	lea bx,DS:TABLE_D
	mov al,[bx+di]
	not al
	out 02h,al
	mov al,33h
	out 00h,al
Xend:ret
start endp

stop proc near
	mov count,00
	mov di,count
	lea bx,DS:TABLE_D
	mov al,[bx+di]
	not al
	out 02h,al
	mov al,00h
	out 00h,al
	mov al,00110000b
	out 0eh,al
	mov al,0ah
	out 08h,al
	mov al,00H
	out 08h,al
	ret
stop endp

auto proc near
	mov flag, 0001h
	ret
auto endp


END
