SIZE equ 31

global _start 
section .text
_start:
	; calculate grid size into r12
	mov rax, SIZE
	mov r12, SIZE
	mul r12
	mov r12, rax ; r12 = number of bytes in the grid

	mov r13, rsp ; r13 holds starting address to grid
	sub rsp, r12 ; make space for grid on stack

	mov r14, rsp ; r14 holds starting address to grid 2
	sub rsp, r12 ; make space for grid on stack

	mov r8, 0 ; loop counter

	initialize: ; loop through every row
		mov byte [r13 + r8], 1
		mov byte [r14 + r8], 0
		inc r8
		mov byte [r13 + r8], 0
		mov byte [r14 + r8], 1
		;add rax, 2
		inc r8
		cmp r8, r12
		jle initialize 

	loop: 
		call printGrid
		xchg r13, r14

		mov rsi, nl; buf = '\n'
		call print

		call sleep
		call printGrid
		call sleep
		jmp loop

	mov rax, 60
	xor rdi, rdi
	syscall

print: ; put string buffer into rsi
	mov rax, 1; print
	mov rdi, 0; fd = stdout
	mov rdx, 1; count = 1
	syscall
	ret

print2: 
	mov rax, 1
	mov rdi, 0
	mov rsi, cursor
	mov rdx, len

	syscall
	ret

printGrid: ; print grid starting starting at r13
	push rbp
	mov rbp, rsp

	push r14

	call print2
	mov r8, 0
	mov r14b, 0
	printLoop:
		cmp r14b, SIZE
		jne no
			mov r14b, 0
			mov rsi, nl; buf = '\n'
			call print
		no:
		mov byte r15b, [r13+r8]
		cmp r15b, 1
		je X
			mov rsi, oStr; buf = 'O'
			jmp done
		X:
			mov rsi, xStr; buf = 'X'
		done:
		call print
		inc r14b
		inc r8
		cmp r8, r12
		jne printLoop

	mov rsi, nl; buf = xStr
	call print

	pop r14 

	mov rsp, rbp
	pop rbp
	ret

sleep: 
	mov rax, 35
	mov rdi, sleep_time
	mov rsi, 0
	syscall
	ret

%macro timespec 2
	dq %1
	dq %2
%endmacro

section .data

	sleep_time timespec 0, 500000000

	message: db 0xA; 0xA == \n
	message_length equ $-message

	oStr: db "O"
	xStr: db "X"
	nl: db 0x0A

	cursor db 0x1B, '[', 'H' ; escape sequence to go to home position
	len equ $-cursor
