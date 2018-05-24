ball_x EQU 30h
ball_y EQU 31h
ball_rx EQU 35h
ball_ry EQU 36h

balken_1 EQU 33h
balken_2 EQU 34h

cseg at 0h
ajmp init
cseg at 100h

org 0bh
call timer
reti

org 20h
init:
mov ball_x, #3h
mov ball_y, #3h
call move_balken

mov ie, #10010010b
mov tmod, #00000010b
mov r7, #00h
mov r6, #05h
mov tl0, #0c0h
mov th0, #0c0h
setb p0.0
setb tr0

run:
;call draw_our_shit
jmp run

timer:
call draw_our_shit
call do_logic
ret

draw_our_shit:
	call paint_ball
	call clear_screen

	mov r1, balken_1
	mov r0, #0h
	call paint_balken
	call clear_screen

	mov r1, balken_2
	mov r0, #7h
	call paint_balken
	call clear_screen
	ret

paint_ball:
	mov r0, ball_x
	mov r1, ball_y
	call paint_at
	ret

paint_balken:
	mov dptr, #bitshift_cheat
	mov a, r0
	movc a,@a+dptr
	mov p0, a

	mov dptr, #bitshift_cheat_2
	mov a, r1
	movc a,@a+dptr
	mov p1, a

	ret

move_ball:
	call move_ball_x
	call move_ball_y
	ret

move_ball_y:
	mov a, ball_ry
	cjne a, #0h, ball_richtung
	
	inc ball_y
	mov a, ball_y
	cjne a, #7h, ball_ende
	mov ball_ry, #1h
	jmp ball_ende

	ball_richtung:
	dec ball_y
	mov a, ball_y
	cjne a, #0h, ball_ende
	mov ball_ry, #0h
	ball_ende:
	ret

move_ball_x:
	mov a, ball_rx
	cjne a, #0h, ball_richtung_x
	
	inc ball_x
	mov a, ball_x
	cjne a, #6h, ball_ende_x
	mov ball_rx, #1h
	jmp ball_ende_x

	ball_richtung_x:
	djnz ball_x, continue_check_dec
	jmp init
	continue_check_dec:
	mov a, ball_x
	cjne a, #1h, ball_ende_x
	mov a, ball_y
	;mov r2, balken_1
	;cjne a, r2, switch_dir
	cjne a, balken_1, switch_dir
	cjne a, balken_1, switch_dir
	switch_dir:
	mov ball_rx, #0h
	ball_ende_x:
	ret

move_balken:
	mov a, ball_y
	cjne a, #0h, decrement
	jmp do_copy
	
	decrement:
	dec a
	
	do_copy:
	cjne a, #6h, next
	setfive:
	mov a, #5h
	jmp endshit

	next:
	cjne a, #7h, endshit
	jmp setfive
	
	endshit:
	mov balken_2, a
	mov a, p2
	anl a, #1h
	cjne a, #1h, inccheck
	mov a, balken_1
	cjne a, #0h, decbalken
	ret
	decbalken:
	dec balken_1
	ret
	inccheck:
	mov a, balken_1
	cjne a, #5h, incbalken
	ret
	incbalken:
	inc balken_1
	ret

do_logic:
	call move_ball
	call move_balken
	ret

paint_at:
	mov dptr, #bitshift_cheat
	mov a, r0
	movc a,@a+dptr
	mov p0, a

	mov a, r1
	movc a,@a+dptr
	mov p1, a
	

	call clear_screen
	ret

clear_screen:
	mov p0, #0FFh
	mov p1, #0FFh
	ret

org 300h
bitshift_cheat:
	db 11111110b
	db 11111101b
	db 11111011b
	db 11110111b
	db 11101111b
	db 11011111b
	db 10111111b
	db 01111111b

bitshift_cheat_2:
	db 11111000b
	db 11110001b
	db 11100011b
	db 11000111b
	db 10001111b
	db 00011111b
	db 00111110b
	db 01111100b

end