SIZE equ 20

global _start 
section .text
_start:
	mov rax, SIZE
	mov r14, SIZE
	mul r14
	mov r12, rax ; r12 = number of bytes in the grid
	mov r8, r12 ; r8 = counter (from size^2 to 0)

	mov r13, rsp ; r13 holds starting address to grid
	mov rax, r13
	sub rsp, r12 ; make space for grid on stack
	initialize: ; loop through every row
		mov byte [rax], 1
		mov byte [rax + 1], 0
		add rax, 2
		sub r8, 2
		cmp r8, 0
		jg initialize 

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

	mov rax, 60
	xor rdi, rdi
	syscall

print: 
	mov rax, 1; print
	mov rdi, 0; fd = stdout
	mov rdx, 1; count = 1
	syscall
	ret

section .data
	message: db 0xA; 0xA == \n
	message_length equ $-message

	oStr: db "O"
	xStr: db "X"
	nl: db 0x0A
