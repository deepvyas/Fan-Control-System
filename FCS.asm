; Authored by:
; Deep Vyas		2014A7PS248P
; Hiresh Gupta	2014A7PS163P
; Karan Deep Batra	2014A7PS160P
; Pulkit Gupta	2014A7PS157P

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
	flag db 00h
	autoval dw 0000h
.STACK 1024
.CODE
.STARTUP

	cli
	mov ax,@data
	mov ds,ax
	mov es,ax
	;port init
	mov al,88h
	out 06h,al
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
;checks if  auto flag is set
X5: cmp flag,01h
	jnz Xnf
	cmp di,08
	jg X10
	inc di
	mov autoval,di
	mov flag,00h
	call startdelay
	jmp X10
	;chacks for speed limits
Xnf:cmp di,04
	jg X8
	inc di
	mov count,di
	jmp X11
	;checks incr pressed
X8:	cmp di,09
	jz X6
	;checks decr pressed
	cmp di,0ah
	jz X12
	;checks start key
	cmp di,0bh
	jz XSt
	;checks stop key
	cmp di,0ch
	jz Xsp
	;checks auto key
	cmp di,0Dh
	jz Xaut
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
	jmp X10
Xsp: call stop
	jmp X10
Xaut: call auto
X10:	jmp X0

.EXIT
; Delay of 20 milliseconds
D20 proc near
	mov cx,2220
X9: loop X9
	ret
D20 endp
;sets speed according to count
sespeed proc near
	mov cx,count
	mov al,00h
Xadd: add al,33h
	dec cx
	jnz Xadd
	out 00h,al
	ret
sespeed endp
; increases speed if less than 5
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

; decreases speed if greater than 1
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
; starts motor
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
; stops motor
stop proc near
	mov count,00
	mov di,count
	lea bx,DS:TABLE_D
	mov al,[bx+di]
	not al
	out 02h,al
	mov al,00H
	out 00h,al
	ret
stop endp
; starts a delay system
startdelay proc near
	mov di,autoval
	lea bx,DS:TABLE_D
	mov al,[bx+di]
	not al
	out 02h,al
	mov ax,autoval
loop3:	mov cx,270
loop2:mov dx,800
loop1:nop
	dec dx
	jnz loop1
	dec cx
	jnz loop2
	dec ax
	jnz loop3
	mov al,00H
	out 00h,al
	ret 
startdelay endp
; sets auto mode flag
auto proc near
	mov flag,01h
	ret
auto endp
END
