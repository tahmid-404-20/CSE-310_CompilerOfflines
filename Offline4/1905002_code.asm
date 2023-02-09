;-------
;
;-------
.MODEL SMALL
.STACK 1000H
.Data
	CR EQU 0DH
	LF EQU 0AH
	number DB "00000$"
	i DW 1 DUP (0000H)
	j DW 1 DUP (0000H)
.CODE
main PROC
	MOV AX, @DATA
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	SUB SP, 12
	MOV AX, 1
	PUSH AX
	POP BX
; line No 6
	MOV i, BX
	MOV AX, i
	PUSH AX
	POP AX
	MOV AX, i
	CALL print_output
	CALL new_line
	MOV AX, 5
	PUSH AX
	MOV AX, 8
	PUSH AX
; Line no 8
	POP BX
	POP AX
	ADD AX, BX
	PUSH AX
	POP BX
; line No 8
	MOV j, BX
	MOV AX, j
	PUSH AX
	POP AX
	MOV AX, j
	CALL print_output
	CALL new_line
	MOV AX, i
	PUSH AX
	MOV AX, 2
	PUSH AX
	MOV AX, j
	PUSH AX
; Line no 10
	POP BX
	POP AX
	CWD
	MUL BX
	PUSH AX
; Line no 10
	POP BX
	POP AX
	ADD AX, BX
	PUSH AX
	POP BX
; line No 10
	MOV [BP-2], BX
	MOV AX, [BP-2]
	PUSH AX
	POP AX
	MOV AX, [BP-2]
	CALL print_output
	CALL new_line
	MOV AX, [BP-2]
	PUSH AX
	MOV AX, 9
	PUSH AX
; Line no 13
	POP BX
	POP AX
	CWD
	DIV BX
	MOV AX, DX
	PUSH AX
	POP BX
; line No 13
	MOV [BP-6], BX
	MOV AX, [BP-6]
	PUSH AX
	POP AX
	MOV AX, [BP-6]
	CALL print_output
	CALL new_line
	MOV AX, 1
	PUSH AX
	POP BX
; line No 16
	MOV [BP-12], BX
	MOV AX, [BP-12]
	PUSH AX
	POP AX
; Line no 18
	MOV AX, [BP-12]
	PUSH AX
	INC AX
	MOV [BP-12], AX
	POP AX
	MOV AX, [BP-12]
	CALL print_output
	CALL new_line
	MOV AX, [BP-12]
	PUSH AX
; Line no 21
	POP AX
	NEG AX
	PUSH AX
	POP BX
; line No 21
	MOV [BP-2], BX
	MOV AX, [BP-2]
	PUSH AX
	POP AX
	MOV AX, [BP-2]
	CALL print_output
	CALL new_line
	SUB SP, 32
	MOV AX, 1
	PUSH AX
	MOV AX, 2
	PUSH AX
; Line no 26
	POP BX
	POP AX
	ADD AX, BX
	PUSH AX
	MOV AX, 3
	PUSH AX
; Line no 26
	POP BX
	POP AX
	SUB AX, BX
	PUSH AX
	MOV AX, 3
	PUSH AX
	POP BX
	POP AX
	MOV SI, BP
	SUB SI, 14
	SHL AX, 1
	SUB SI, AX
; line No 26
	MOV [SI], BX
	MOV AX, [SI]
	PUSH AX
	POP AX
	MOV AX, 1
	PUSH AX
	MOV AX, 2
	PUSH AX
; Line no 27
	POP BX
	POP AX
	ADD AX, BX
	PUSH AX
	MOV AX, 3
	PUSH AX
; Line no 27
	POP BX
	POP AX
	SUB AX, BX
	PUSH AX
	POP AX
	MOV SI, BP
	SUB SI, 14
	SHL AX, 1
	SUB SI, AX
	MOV AX, [SI]
	CALL print_output
	CALL new_line
	SUB SP, 40
	MOV AX, 0
	PUSH AX
	MOV AX, 1
	PUSH AX
	POP BX
	POP AX
	MOV SI, BP
	SUB SI, 34
	SHL AX, 1
	SUB SI, AX
; line No 31
	MOV [SI], BX
	MOV AX, [SI]
	PUSH AX
	POP AX
	MOV AX, 3
	PUSH AX
	MOV AX, 0
	PUSH AX
	POP AX
	MOV SI, BP
	SUB SI, 34
	SHL AX, 1
	SUB SI, AX
	MOV AX, [SI]
	PUSH AX
	POP BX
	POP AX
	MOV SI, BP
	SUB SI, 14
	SHL AX, 1
	SUB SI, AX
; line No 33
	MOV [SI], BX
	MOV AX, [SI]
	PUSH AX
	POP AX
	MOV AX, 3
	PUSH AX
	POP AX
	MOV SI, BP
	SUB SI, 14
	SHL AX, 1
	SUB SI, AX
	MOV AX, [SI]
	CALL print_output
	CALL new_line
	MOV AX, 0
	PUSH AX
	POP AX
	MOV SI, BP
	SUB SI, 34
	SHL AX, 1
	SUB SI, AX
	MOV AX, [SI]
	CALL print_output
	CALL new_line
	MOV AX, 0
	PUSH AX
	ADD SP, 40
	POP BP
	MOV AX,4CH
	INT 21H
main ENDP
new_line proc
	push ax
	push dx
	mov ah,2
	mov dl,cr
	int 21h
	mov ah,2
	mov dl,lf
	int 21h
	pop dx
	pop ax
	ret
new_line endp
print_output proc  ;print what is in ax
	push ax
	push bx
	push cx
	push dx
	push si
	lea si,number
	mov bx,10
	add si,4
	cmp ax,0
	jnge negate
	print:
	xor dx,dx
	div bx
	mov [si],dl
	add [si],'0'
	dec si
	cmp ax,0
	jne print
	inc si
	lea dx,si
	mov ah,9
	int 21h
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	negate:
	push ax
	mov ah,2
	mov dl,'-'
	int 21h
	pop ax
	neg ax
	jmp print
print_output endp
	END main