.386
.model flat, stdcall
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
includelib canvas.lib
extern BeginDrawing: proc
public start
.data
	window_title DB "Battleship",0
	area_width EQU 580
	area_height EQU 600
	area DD 0
	elapsed_time DD 0
	arg1 EQU 8
	arg2 EQU 12
	arg3 EQU 16
	arg4 EQU 20
	symbol_width EQU 10
	symbol_height EQU 20
	include digits.inc
	include letters.inc
	matrix_x EQU 50
	matrix_y EQU 70
	matrix_size EQU 480
	cell_size EQU 48
	image_width EQU 48
	image_height EQU 48
	include water.inc
	include boat.inc
	include win1.inc
	include win2.inc
	include win3.inc
	include win4.inc
	boat_clicked DD 0
	boats_remaining DD 20 ; nr of boats remaining in matrix
	boat_hits DD 0
	missed_boat_hits DD 0
	counter DD 0
.code
make_text proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26
	lea esi, letters
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] 
	mov eax, [ebp+arg4]
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3]
	shl eax, 2
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
make_inc proc
    push ebp
    mov ebp, esp
    pusha
    mov edx, [ebp+arg4]
    cmp edx, 0
    je draw_water1_0
    cmp edx, 1
    je draw_boat1_0
	cmp edx, 2
	je draw_win1_0
	cmp edx, 3
	je draw_win2_0
	cmp edx, 4
	je draw_win3_0
	cmp edx, 5
	je draw_win4_0
	cmp edx, 6
draw_water1_0:
    lea esi, water1_0
    jmp draw_image
draw_boat1_0:
    lea esi, boat1_0
    jmp draw_image
draw_win1_0:
    lea esi, win1_0
    jmp draw_image
draw_win2_0:
	lea esi, win2_0
	jmp draw_image
draw_win3_0:
	lea esi, win3_0
	jmp draw_image
draw_win4_0:
	lea esi, win4_0
draw_image:
    mov ecx, image_height
loop_draw_lines:
    mov edi, [ebp+arg1]
    mov eax, [ebp+arg3]
    add eax, image_height 
    sub eax, ecx
    mov ebx, area_width
    mul ebx
    add eax, [ebp+arg2]
    shl eax, 2
    add edi, eax
    push ecx
    mov ecx, image_width
loop_draw_columns:
    push eax
    mov eax, dword ptr [esi] 
    mov dword ptr [edi], eax
    pop eax
    add esi, 4
    add edi, 4
    loop loop_draw_columns
    pop ecx
    loop loop_draw_lines
    popa
    mov esp, ebp
    pop ebp
    ret
make_inc endp
make_image_macro macro drawArea, x, y, imageChoise
	push imageChoise
	push y
	push x
	push drawArea
	call make_inc
	add esp, 16
endm
line_horizontal macro x,y,len,color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_line
endm
line_vertical macro x,y,len,color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, area_width  *  4
	loop bucla_line
endm
draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz check_1_area
	cmp eax, 2
	jz evt_timer
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere 
check_1_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_2_area
	cmp eax, matrix_x + cell_size
	jge check_2_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_2_area
	cmp eax, matrix_y + cell_size
	jge check_2_area
	make_image_macro area, matrix_x, matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_2_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_3_area
	cmp eax, matrix_x + 2*cell_size
	jge check_3_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_3_area
	cmp eax, matrix_y + cell_size
	jge check_3_area
	make_image_macro area, matrix_x + cell_size, matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_3_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_4_area
	cmp eax, matrix_x + 3*cell_size
	jge check_4_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_4_area
	cmp eax, matrix_y + cell_size
	jge check_4_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_4_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_5_area
	cmp eax, matrix_x + 4*cell_size
	jge check_5_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_5_area
	cmp eax, matrix_y + cell_size
	jge check_5_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_5_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_6_area
	cmp eax, matrix_x + 5*cell_size
	jge check_6_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_6_area
	cmp eax, matrix_y + cell_size
	jge check_6_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_6_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_7_area
	cmp eax, matrix_x + 6*cell_size
	jge check_7_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_7_area
	cmp eax, matrix_y + cell_size
	jge check_7_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_7_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_8_area
	cmp eax, matrix_x + 7*cell_size
	jge check_8_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_8_area
	cmp eax, matrix_y + cell_size
	jge check_8_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_8_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_9_area
	cmp eax, matrix_x + 8*cell_size
	jge check_9_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_9_area
	cmp eax, matrix_y + cell_size
	jge check_9_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_9_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_10_area
	cmp eax, matrix_x + 9*cell_size
	jge check_10_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_10_area
	cmp eax, matrix_y + cell_size
	jge check_10_area
	make_image_macro area, matrix_x + 8* cell_size , matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_10_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_11_area
	cmp eax, matrix_x + 10*cell_size
	jge check_11_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y
	jle check_11_area
	cmp eax, matrix_y + cell_size
	jge check_11_area
	make_image_macro area, matrix_x + 9* cell_size , matrix_y, 0
	inc missed_boat_hits
	jmp afisare_litere
check_11_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_12_area
	cmp eax, matrix_x + cell_size
	jge check_12_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_12_area
	cmp eax, matrix_y + 2*cell_size
	jge check_12_area
	make_image_macro area, matrix_x, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_12_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_13_area
	cmp eax, matrix_x + 2*cell_size
	jge check_13_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_13_area
	cmp eax, matrix_y + 2*cell_size
	jge check_13_area
	make_image_macro area, matrix_x + cell_size, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_13_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_14_area
	cmp eax, matrix_x + 3*cell_size
	jge check_14_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_14_area
	cmp eax, matrix_y + 2*cell_size
	jge check_14_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_14_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_15_area
	cmp eax, matrix_x + 4*cell_size
	jge check_15_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_15_area
	cmp eax, matrix_y + 2*cell_size
	jge check_15_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_15_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_16_area
	cmp eax, matrix_x + 5*cell_size
	jge check_16_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_16_area
	cmp eax, matrix_y + 2*cell_size
	jge check_16_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_16_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_17_area
	cmp eax, matrix_x + 6*cell_size
	jge check_17_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_17_area
	cmp eax, matrix_y + 2*cell_size
	jge check_17_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_17_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_18_area
	cmp eax, matrix_x + 7*cell_size
	jge check_18_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_18_area
	cmp eax, matrix_y + 2*cell_size
	jge check_18_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_18_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_19_area
	cmp eax, matrix_x + 8*cell_size
	jge check_19_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_19_area
	cmp eax, matrix_y + 2*cell_size
	jge check_19_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_19_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_20_area
	cmp eax, matrix_x + 9*cell_size
	jge check_20_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_20_area
	cmp eax, matrix_y + 2*cell_size
	jge check_20_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_20_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_21_area
	cmp eax, matrix_x + 10*cell_size
	jge check_21_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + cell_size
	jle check_21_area
	cmp eax, matrix_y + 2*cell_size
	jge check_21_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_21_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_22_area
	cmp eax, matrix_x + cell_size
	jge check_22_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_22_area
	cmp eax, matrix_y + 3*cell_size
	jge check_22_area
	make_image_macro area, matrix_x, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_22_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_23_area
	cmp eax, matrix_x + 2*cell_size
	jge check_23_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_23_area
	cmp eax, matrix_y + 3*cell_size
	jge check_23_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_23_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_24_area
	cmp eax, matrix_x + 3*cell_size
	jge check_24_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_24_area
	cmp eax, matrix_y + 3*cell_size
	jge check_24_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_24_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_25_area
	cmp eax, matrix_x + 4*cell_size
	jge check_25_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_25_area
	cmp eax, matrix_y + 3*cell_size
	jge check_25_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_25_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_26_area
	cmp eax, matrix_x + 5*cell_size
	jge check_26_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_26_area
	cmp eax, matrix_y + 3*cell_size
	jge check_26_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 2*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_26_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_27_area
	cmp eax, matrix_x + 6*cell_size
	jge check_27_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_27_area
	cmp eax, matrix_y + 3*cell_size
	jge check_27_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_27_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_28_area
	cmp eax, matrix_x + 7*cell_size
	jge check_28_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_28_area
	cmp eax, matrix_y + 3*cell_size
	jge check_28_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_28_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_29_area
	cmp eax, matrix_x + 8*cell_size
	jge check_29_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_29_area
	cmp eax, matrix_y + 3*cell_size
	jge check_29_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_29_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_30_area
	cmp eax, matrix_x + 9*cell_size
	jge check_30_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_30_area
	cmp eax, matrix_y + 3*cell_size
	jge check_30_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_30_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_31_area
	cmp eax, matrix_x + 10*cell_size
	jge check_31_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 2*cell_size
	jle check_31_area
	cmp eax, matrix_y + 3*cell_size
	jge check_31_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 2*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_31_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_32_area
	cmp eax, matrix_x + cell_size
	jge check_32_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_32_area
	cmp eax, matrix_y + 4*cell_size
	jge check_32_area
	make_image_macro area, matrix_x, matrix_y + 3*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_32_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_33_area
	cmp eax, matrix_x + 2*cell_size
	jge check_33_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_33_area
	cmp eax, matrix_y + 4*cell_size
	jge check_33_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 3*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_33_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_34_area
	cmp eax, matrix_x + 3*cell_size
	jge check_34_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_34_area
	cmp eax, matrix_y + 4*cell_size
	jge check_34_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 3*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_34_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_35_area
	cmp eax, matrix_x + 4*cell_size
	jge check_35_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_35_area
	cmp eax, matrix_y + 4*cell_size
	jge check_35_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 3*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_35_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_36_area
	cmp eax, matrix_x + 5*cell_size
	jge check_36_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_36_area
	cmp eax, matrix_y + 4*cell_size
	jge check_36_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 3*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_36_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_37_area
	cmp eax, matrix_x + 6*cell_size
	jge check_37_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_37_area
	cmp eax, matrix_y + 4*cell_size
	jge check_37_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 3*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_37_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_38_area
	cmp eax, matrix_x + 7*cell_size
	jge check_38_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_38_area
	cmp eax, matrix_y + 4*cell_size
	jge check_38_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 3*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_38_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_39_area
	cmp eax, matrix_x + 8*cell_size
	jge check_39_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_39_area
	cmp eax, matrix_y + 4*cell_size
	jge check_39_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 3*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_39_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_40_area
	cmp eax, matrix_x + 9*cell_size
	jge check_40_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_40_area
	cmp eax, matrix_y + 4*cell_size
	jge check_40_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 3*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_40_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_41_area
	cmp eax, matrix_x + 10*cell_size
	jge check_41_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 3*cell_size
	jle check_41_area
	cmp eax, matrix_y + 4*cell_size
	jge check_41_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 3*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_41_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_42_area
	cmp eax, matrix_x + cell_size
	jge check_42_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_42_area
	cmp eax, matrix_y + 5*cell_size
	jge check_42_area
	make_image_macro area, matrix_x, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_42_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_43_area
	cmp eax, matrix_x + 2*cell_size
	jge check_43_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_43_area
	cmp eax, matrix_y + 5*cell_size
	jge check_43_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_43_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_44_area
	cmp eax, matrix_x + 3*cell_size
	jge check_44_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_44_area
	cmp eax, matrix_y + 5*cell_size
	jge check_44_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_44_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_45_area
	cmp eax, matrix_x + 4*cell_size
	jge check_45_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_45_area
	cmp eax, matrix_y + 5*cell_size
	jge check_45_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_45_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_46_area
	cmp eax, matrix_x + 5*cell_size
	jge check_46_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_46_area
	cmp eax, matrix_y + 5*cell_size
	jge check_46_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_46_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_47_area
	cmp eax, matrix_x + 6*cell_size
	jge check_47_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_47_area
	cmp eax, matrix_y + 5*cell_size
	jge check_47_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_47_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_48_area
	cmp eax, matrix_x + 7*cell_size
	jge check_48_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_48_area
	cmp eax, matrix_y + 5*cell_size
	jge check_48_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_48_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_49_area
	cmp eax, matrix_x + 8*cell_size
	jge check_49_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_49_area
	cmp eax, matrix_y + 5*cell_size
	jge check_49_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 4*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_49_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_50_area
	cmp eax, matrix_x + 9*cell_size
	jge check_50_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_50_area
	cmp eax, matrix_y + 5*cell_size
	jge check_50_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_50_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_51_area
	cmp eax, matrix_x + 10*cell_size
	jge check_51_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 4*cell_size
	jle check_51_area
	cmp eax, matrix_y + 5*cell_size
	jge check_51_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 4*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_51_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_52_area
	cmp eax, matrix_x + cell_size
	jge check_52_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_52_area
	cmp eax, matrix_y + 6*cell_size
	jge check_52_area
	make_image_macro area, matrix_x, matrix_y + 5*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_52_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_53_area
	cmp eax, matrix_x + 2*cell_size
	jge check_53_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_53_area
	cmp eax, matrix_y + 6*cell_size
	jge check_53_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 5*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_53_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_54_area
	cmp eax, matrix_x + 3*cell_size
	jge check_54_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_54_area
	cmp eax, matrix_y + 6*cell_size
	jge check_54_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 5*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_54_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_55_area
	cmp eax, matrix_x + 4*cell_size
	jge check_55_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_55_area
	cmp eax, matrix_y + 6*cell_size
	jge check_55_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 5*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_55_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_56_area
	cmp eax, matrix_x + 5*cell_size
	jge check_56_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_56_area
	cmp eax, matrix_y + 6*cell_size
	jge check_56_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 5*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_56_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_57_area
	cmp eax, matrix_x + 6*cell_size
	jge check_57_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_57_area
	cmp eax, matrix_y + 6*cell_size
	jge check_57_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 5*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_57_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_58_area
	cmp eax, matrix_x + 7*cell_size
	jge check_58_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_58_area
	cmp eax, matrix_y + 6*cell_size
	jge check_58_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 5*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_58_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_59_area
	cmp eax, matrix_x + 8*cell_size
	jge check_59_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_59_area
	cmp eax, matrix_y + 6*cell_size
	jge check_59_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 5*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_59_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_60_area
	cmp eax, matrix_x + 9*cell_size
	jge check_60_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_60_area
	cmp eax, matrix_y + 6*cell_size
	jge check_60_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 5*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_60_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_61_area
	cmp eax, matrix_x + 10*cell_size
	jge check_61_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 5*cell_size
	jle check_61_area
	cmp eax, matrix_y + 6*cell_size
	jge check_61_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 5*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_61_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_62_area
	cmp eax, matrix_x + cell_size
	jge check_62_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_62_area
	cmp eax, matrix_y + 7*cell_size
	jge check_62_area
	make_image_macro area, matrix_x, matrix_y + 6*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_62_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_63_area
	cmp eax, matrix_x + 2*cell_size
	jge check_63_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_63_area
	cmp eax, matrix_y + 7*cell_size
	jge check_63_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 6*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_63_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_64_area
	cmp eax, matrix_x + 3*cell_size
	jge check_64_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_64_area
	cmp eax, matrix_y + 7*cell_size
	jge check_64_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 6*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_64_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_65_area
	cmp eax, matrix_x + 4*cell_size
	jge check_65_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_65_area
	cmp eax, matrix_y + 7*cell_size
	jge check_65_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 6*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_65_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_66_area
	cmp eax, matrix_x + 5*cell_size
	jge check_66_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_66_area
	cmp eax, matrix_y + 7*cell_size
	jge check_66_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 6*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_66_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_67_area
	cmp eax, matrix_x + 6*cell_size
	jge check_67_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_67_area
	cmp eax, matrix_y + 7*cell_size
	jge check_67_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 6*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_67_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_68_area
	cmp eax, matrix_x + 7*cell_size
	jge check_68_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_68_area
	cmp eax, matrix_y + 7*cell_size
	jge check_68_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 6*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_68_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_69_area
	cmp eax, matrix_x + 8*cell_size
	jge check_69_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_69_area
	cmp eax, matrix_y + 7*cell_size
	jge check_69_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 6*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_69_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_70_area
	cmp eax, matrix_x + 9*cell_size
	jge check_70_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_70_area
	cmp eax, matrix_y + 7*cell_size
	jge check_70_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 6*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_70_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_71_area
	cmp eax, matrix_x + 10*cell_size
	jge check_71_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 6*cell_size
	jle check_71_area
	cmp eax, matrix_y + 7*cell_size
	jge check_71_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 6*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_71_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_72_area
	cmp eax, matrix_x + cell_size
	jge check_72_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_72_area
	cmp eax, matrix_y + 8*cell_size
	jge check_72_area
	make_image_macro area, matrix_x, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_72_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_73_area
	cmp eax, matrix_x + 2*cell_size
	jge check_73_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_73_area
	cmp eax, matrix_y + 8*cell_size
	jge check_73_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_73_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_74_area
	cmp eax, matrix_x + 3*cell_size
	jge check_74_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_74_area
	cmp eax, matrix_y + 8*cell_size
	jge check_74_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_74_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_75_area
	cmp eax, matrix_x + 4*cell_size
	jge check_75_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_75_area
	cmp eax, matrix_y + 8*cell_size
	jge check_75_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits	
	jmp afisare_litere
check_75_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_76_area
	cmp eax, matrix_x + 5*cell_size
	jge check_76_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_76_area
	cmp eax, matrix_y + 8*cell_size
	jge check_76_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_76_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_77_area
	cmp eax, matrix_x + 6*cell_size
	jge check_77_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_77_area
	cmp eax, matrix_y + 8*cell_size
	jge check_77_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_77_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_78_area
	cmp eax, matrix_x + 7*cell_size
	jge check_78_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_78_area
	cmp eax, matrix_y + 8*cell_size
	jge check_78_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_78_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_79_area
	cmp eax, matrix_x + 8*cell_size
	jge check_79_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_79_area
	cmp eax, matrix_y + 8*cell_size
	jge check_79_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_79_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_80_area
	cmp eax, matrix_x + 9*cell_size
	jge check_80_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_80_area
	cmp eax, matrix_y + 8*cell_size
	jge check_80_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_80_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_81_area
	cmp eax, matrix_x + 10*cell_size
	jge check_81_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 7*cell_size
	jle check_81_area
	cmp eax, matrix_y + 8*cell_size
	jge check_81_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 7*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_81_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_82_area
	cmp eax, matrix_x + cell_size
	jge check_82_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_82_area
	cmp eax, matrix_y + 9*cell_size
	jge check_82_area
	make_image_macro area, matrix_x, matrix_y + 8*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_82_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_83_area
	cmp eax, matrix_x + 2*cell_size
	jge check_83_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_83_area
	cmp eax, matrix_y + 9*cell_size
	jge check_83_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 8*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_83_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_84_area
	cmp eax, matrix_x + 3*cell_size
	jge check_84_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_84_area
	cmp eax, matrix_y + 9*cell_size
	jge check_84_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 8*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_84_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_85_area
	cmp eax, matrix_x + 4*cell_size
	jge check_85_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_85_area
	cmp eax, matrix_y + 9*cell_size
	jge check_85_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 8*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_85_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_86_area
	cmp eax, matrix_x + 5*cell_size
	jge check_86_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_86_area
	cmp eax, matrix_y + 9*cell_size
	jge check_86_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 8*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_86_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_87_area
	cmp eax, matrix_x + 6*cell_size
	jge check_87_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_87_area
	cmp eax, matrix_y + 9*cell_size
	jge check_87_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 8*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_87_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_88_area
	cmp eax, matrix_x + 7*cell_size
	jge check_88_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_88_area
	cmp eax, matrix_y + 9*cell_size
	jge check_88_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 8*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_88_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_89_area
	cmp eax, matrix_x + 8*cell_size
	jge check_89_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_89_area
	cmp eax, matrix_y + 9*cell_size
	jge check_89_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 8*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_89_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_90_area
	cmp eax, matrix_x + 9*cell_size
	jge check_90_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_90_area
	cmp eax, matrix_y + 9*cell_size
	jge check_90_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 8*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_90_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_91_area
	cmp eax, matrix_x + 10*cell_size
	jge check_91_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 8*cell_size
	jle check_91_area
	cmp eax, matrix_y + 9*cell_size
	jge check_91_area
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 8*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_91_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x
	jle check_92_area
	cmp eax, matrix_x + cell_size
	jge check_92_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_92_area
	cmp eax, matrix_y + 10*cell_size
	jge check_92_area
	make_image_macro area, matrix_x, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_92_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + cell_size
	jle check_93_area
	cmp eax, matrix_x + 2*cell_size
	jge check_93_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_93_area
	cmp eax, matrix_y + 10*cell_size
	jge check_93_area
	make_image_macro area, matrix_x + cell_size, matrix_y + 9*cell_size, 1
	inc boat_clicked
	inc boat_hits
	dec boats_remaining
	jmp afisare_litere
check_93_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 2*cell_size
	jle check_94_area
	cmp eax, matrix_x + 3*cell_size
	jge check_94_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_94_area
	cmp eax, matrix_y + 10*cell_size
	jge check_94_area
	make_image_macro area, matrix_x + 2*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_94_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 3*cell_size
	jle check_95_area
	cmp eax, matrix_x + 4*cell_size
	jge check_95_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_95_area
	cmp eax, matrix_y + 10*cell_size
	jge check_95_area
	make_image_macro area, matrix_x + 3*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_95_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 4*cell_size
	jle check_96_area
	cmp eax, matrix_x + 5*cell_size
	jge check_96_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_96_area
	cmp eax, matrix_y + 10*cell_size
	jge check_96_area
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_96_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 5*cell_size
	jle check_97_area
	cmp eax, matrix_x + 6*cell_size
	jge check_97_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_97_area
	cmp eax, matrix_y + 10*cell_size
	jge check_97_area
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_97_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 6*cell_size
	jle check_98_area
	cmp eax, matrix_x + 7*cell_size
	jge check_98_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_98_area
	cmp eax, matrix_y + 10*cell_size
	jge check_98_area
	make_image_macro area, matrix_x + 6*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_98_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 7*cell_size
	jle check_99_area
	cmp eax, matrix_x + 8*cell_size
	jge check_99_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_99_area
	cmp eax, matrix_y + 10*cell_size
	jge check_99_area
	make_image_macro area, matrix_x + 7*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_99_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 8*cell_size
	jle check_100_area
	cmp eax, matrix_x + 9*cell_size
	jge check_100_area
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_100_area
	cmp eax, matrix_y + 10*cell_size
	jge check_100_area
	make_image_macro area, matrix_x + 8*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_100_area:
	mov eax, [ebp+arg2]
	cmp eax, matrix_x + 9*cell_size
	jle check_area_other
	cmp eax, matrix_x + 10*cell_size
	jge check_area_other
	mov eax, [ebp+arg3]
	cmp eax, matrix_y + 9*cell_size
	jle check_area_other
	cmp eax, matrix_y + 10*cell_size
	jge check_area_other
	make_image_macro area, matrix_x + 9*cell_size, matrix_y + 9*cell_size, 0
	inc missed_boat_hits
	jmp afisare_litere
check_area_other:
    jmp afisare_litere
evt_timer:
	inc counter
	cmp boat_clicked, 2
	jne not_all_clicked	
	inc elapsed_time
	make_text_macro 'Y', area, area_width/2 -40, 550
	make_text_macro 'O', area, area_width/2 -30, 550
	make_text_macro 'U', area, area_width/2 -20, 550
	make_text_macro 'W', area, area_width/2 +10, 550
	make_text_macro 'I', area, area_width/2 +20, 550
	make_text_macro 'N', area, area_width/2 +30, 550
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 4*cell_size, 2
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 4*cell_size, 3
	make_image_macro area, matrix_x + 4*cell_size, matrix_y + 5*cell_size, 4
	make_image_macro area, matrix_x + 5*cell_size, matrix_y + 5*cell_size, 5
	cmp elapsed_time, 30
	jl not_30_seconds
	jmp close_program
not_30_seconds:
	jmp afisare_litere
not_all_clicked:
afisare_litere:
	mov ebx, 10
	mov eax, counter
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, area_height-20
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, area_height-20
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 0, area_height-20
	;afis pt boat ramase
	make_text_macro 'R', area, matrix_x+10, 0
	make_text_macro 'E', area, matrix_x+20, 0
	make_text_macro 'M', area, matrix_x+30, 0
	make_text_macro 'A', area, matrix_x+40, 0
	make_text_macro 'I', area, matrix_x+50, 0
	make_text_macro 'N', area, matrix_x+60, 0
	make_text_macro 'B', area, matrix_x+80, 0
	make_text_macro 'O', area, matrix_x+90, 0
	make_text_macro 'A', area, matrix_x+100, 0
	make_text_macro 'T', area, matrix_x+110, 0
	make_text_macro 'S', area, matrix_x+120, 0
	mov ebx, 10
	mov eax, boats_remaining
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, matrix_x+70, 20
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, matrix_x+60, 20
	;afis counter pt lovituri success
	make_text_macro 'G', area, matrix_x+175, 0
	make_text_macro 'O', area, matrix_x+185, 0
	make_text_macro 'O', area, matrix_x+195, 0
	make_text_macro 'D', area, matrix_x+205, 0
	make_text_macro 'H', area, matrix_x+215, 0
	make_text_macro 'I', area, matrix_x+225, 0
	make_text_macro 'T', area, matrix_x+235, 0
	make_text_macro 'S', area, matrix_x+245, 0
	mov ebx, 10
	mov eax, boat_hits
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, matrix_x+215, 20
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, matrix_x+205, 20
	;afis counter pt miss hits
	make_text_macro 'M', area, matrix_x+380, 0
	make_text_macro 'I', area, matrix_x+390, 0
	make_text_macro 'S', area, matrix_x+400, 0
	make_text_macro 'S', area, matrix_x+410, 0
	make_text_macro 'E', area, matrix_x+420, 0
	make_text_macro 'S', area, matrix_x+430, 0
	mov ebx, 10
	mov eax, missed_boat_hits
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, matrix_x+410, 20
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, matrix_x+400, 20
	;main sqr
	line_horizontal matrix_x, matrix_y, matrix_size, 0
	line_horizontal matrix_x, matrix_y+matrix_size, matrix_size, 0
	line_vertical matrix_x, matrix_y, matrix_size, 0
	line_vertical matrix_x+matrix_size, matrix_y, matrix_size+1, 0
	line_vertical matrix_x+cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+2 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+3 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+4 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+5 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+6 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+7 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+8 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+9 * cell_size, matrix_y, matrix_size, 0
	line_vertical matrix_x+10 * cell_size, matrix_y, matrix_size, 0
	line_horizontal matrix_x, matrix_y+cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+2 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+3 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+4 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+5 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+6 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+7 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+8 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+9 * cell_size, matrix_size, 0
	line_horizontal matrix_x, matrix_y+10 * cell_size, matrix_size, 0
	make_text_macro 'A', area, matrix_x+20, 50
	make_text_macro 'B', area, matrix_x+48+20, 50
	make_text_macro 'C', area, matrix_x+96+20, 50
	make_text_macro 'D', area, matrix_x+144+20, 50
	make_text_macro 'E', area, matrix_x+192+20, 50
	make_text_macro 'F', area, matrix_x+240+20, 50
	make_text_macro 'G', area, matrix_x+288+20, 50
	make_text_macro 'H', area, matrix_x+336+20, 50
	make_text_macro 'I', area, matrix_x+384+20, 50
	make_text_macro 'J', area, matrix_x+432+20, 50
	make_text_macro '1', area, 40, matrix_y+18
	make_text_macro '2', area, 40, matrix_y+48+18
	make_text_macro '2', area, 40, matrix_y+48+18
	make_text_macro '3', area, 40, matrix_y+96+18
	make_text_macro '4', area, 40, matrix_y+144+18
	make_text_macro '5', area, 40, matrix_y+192+18
	make_text_macro '6', area, 40, matrix_y+240+18
	make_text_macro '7', area, 40, matrix_y+288+18
	make_text_macro '8', area, 40, matrix_y+336+18
	make_text_macro '9', area, 40, matrix_y+384+18
	make_text_macro '0', area, 40, matrix_y+432+18
	make_text_macro '1', area, 30, matrix_y+432+18



final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp
start:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	close_program:
	push 0
	call exit
end start