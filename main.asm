ball_x EQU 30h
ball_y EQU 31h
; directions: rx(0=right/1=left) ry(0=down/1=up)
ball_rx EQU 35h
ball_ry EQU 36h

balken_player EQU 33h
balken_enemy EQU 34h

ende EQU 37h

cseg at 0h
ajmp init
cseg at 100h

org 0bh
call timer
reti

org 20h
init:
call clear_screen
mov ende, #0h
; initialize ball position to be in the middle
; of the screen
mov ball_x, #3h
mov ball_y, #3h
; intialize direction of the ball to downwards
; right
mov ball_rx, #0h
mov ball_ry, #0h
mov balken_player, #0h
mov balken_enemy, #0h
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
mov a, ende
cjne a, #0h, init
jmp run

timer:
call drawing_routine

mov a, ende
cjne a, #0h, end_timer

call do_logic
ret
end_timer:
clr tr0
ret

drawing_routine:
	call paint_ball
	call clear_screen

	mov r1, balken_player
	mov r0, #0h
	call paint_balken
	call clear_screen

	mov r1, balken_enemy
	mov r0, #7h
	call paint_balken
	call clear_screen
	ret

paint_ball:
	mov r0, ball_x
	mov r1, ball_y
	call paint_dot
	ret

paint_balken:
	mov dptr, #bitshift_table
	mov a, r0
	movc a,@a+dptr
	mov p0, a

	mov dptr, #bitshift_table_2
	mov a, r1
	movc a,@a+dptr
	mov p1, a

	ret

move_ball:
	call move_ball_y
	call move_ball_x
	ret

move_ball_y:
	mov a, ball_ry
	cjne a, #0h, change_ball_richtung
	
	inc ball_y
	mov a, ball_y
	cjne a, #7h, return_move_ball_y
	mov ball_ry, #1h
	jmp return_move_ball_y

	change_ball_richtung:
	dec ball_y
	mov a, ball_y
	cjne a, #0h, return_move_ball_y
	mov ball_ry, #0h
	return_move_ball_y:
	ret

move_ball_x:
	mov a, ball_rx
	cjne a, #0h, check_game_end
	
	inc ball_x
	mov a, ball_x
	cjne a, #6h, return_move_ball_x
	mov ball_rx, #1h
	jmp return_move_ball_x

	check_game_end:
	djnz ball_x, continue_check_x_pos
	mov ende, #1h
	jmp return_move_ball_x
	
	continue_check_x_pos:
	mov a, ball_x
	cjne a, #1h, return_move_ball_x
	mov a, ball_y
	mov b, balken_player

	cjne a, b, check_direction_change
	jmp switch_dir

	check_direction_change:
	inc b
	cjne a, b, check_direction_change_2
	jmp switch_dir

	check_direction_change_2:
	inc b
	cjne a, b, return_move_ball_x

	switch_dir:
	mov ball_rx, #0h
	return_move_ball_x:
	ret

move_balken:
	mov a, ball_y
	cjne a, #0h, decrement_y_variable
	jmp check_balken_range_1
	
	decrement_y_variable:
	dec a
	
	check_balken_range_1:
	cjne a, #6h, check_balken_range_2
	set_y_max:
	mov a, #5h
	jmp move_both_balken

	check_balken_range_2:
	cjne a, #7h, move_both_balken
	jmp set_y_max
	
	move_both_balken:
	mov balken_enemy, a
	mov a, p2
	anl a, #1h
	cjne a, #1h, inc_check
	mov a, balken_player
	cjne a, #0h, dec_balken_player
	ret
	dec_balken_player:
	dec balken_player
	ret
	inc_check:
	mov a, balken_player
	cjne a, #5h, inc_balken_player
	ret
	inc_balken_player:
	inc balken_player
	ret

;game logic
do_logic:
	call move_ball
	call move_balken
	ret

paint_dot:
	mov dptr, #bitshift_table
	mov a, r0
	movc a,@a+dptr
	mov p0, a

	mov a, r1
	movc a,@a+dptr
	mov p1, a

	call clear_screen
	ret

; reset dot matrix
clear_screen:
	mov p0, #0FFh
	mov p1, #0FFh
	ret

org 300h
bitshift_table:
	db 11111110b
	db 11111101b
	db 11111011b
	db 11110111b
	db 11101111b
	db 11011111b
	db 10111111b
	db 01111111b

bitshift_table_2:
	db 11111000b
	db 11110001b
	db 11100011b
	db 11000111b
	db 10001111b
	db 00011111b
	db 00111110b
	db 01111100b

end
