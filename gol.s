SIZE equ 75
SQUARE_SIZE equ SIZE * SIZE

global _start 
section .text
_start:
	mov r13, rsp ; r13 holds starting address to grid
	sub rsp, SQUARE_SIZE ; make space for grid on stack

	mov r14, rsp ; r14 holds starting address to grid 2
	sub rsp, SQUARE_SIZE ; make space for grid on stack

	read_input:
		mov rax, 0
		mov rsi, r13
		mov rdx, SQUARE_SIZE
		syscall

		cmp rax, 0
		jle read_done

		sub rcx, rax
		add rdi, rax
		jmp read_input

	read_done:

	mov rax, 0
	mov rdi, 0 ; read grid from stdin
	mov rsi, r13
	mov rdx, SQUARE_SIZE
	syscall
	
	mov rsi, newline; buf = '\n'
	call print

	mov r8, 0 ; loop counter
	initialize: 
	; loop through every cell and convert 
	; 'X' to 1 and everything else to 0
		cmp byte [r13 + r8], 'X'
		jne off
		mov byte [r13 + r8], 1	
		jmp doneOff
		off:
		mov byte [r13 + r8], 0
		doneOff:

		cmp byte [r14 + r8], 0

		inc r8
		cmp r8, SQUARE_SIZE
		jle initialize 

	loop: 
		call printGrid
		call stepGrid
		call sleep
		xchg r13, r14
		jmp loop

	mov rax, 60
	xor rdi, rdi
	syscall

print: ; put string buffer into rsi
	mov rax, 1; print
	mov rdi, 1; fd = stdout
	mov rdx, 1; count = 1
	syscall
	ret

print2: 
	mov rax, 1
	mov rdi, 1
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
			mov rsi, newline; buf = '\n'
			call print
		no:
		mov byte r15b, [r13+r8]
		cmp r15b, 0
		je X
			mov rsi, aliveCell; buf = '#'
			jmp done
		X:
			mov rsi, deadCell; buf = ' '
		done:
		call print
		inc r14b
		inc r8
		cmp r8, SQUARE_SIZE
		jne printLoop

	mov rsi, newline; buf = '\n'
	call print

	pop r14 

	mov rsp, rbp
	pop rbp
	ret

stepGrid: ; counts grid in r13 and puts results into r14
	push rbp
	mov rbp, rsp

	lea rdi, [r13 + SIZE + 1]
	lea r10, [r14 + SIZE + 1]
	mov r8, 1
	row: 
		mov r9, 1
		col:
			call countCell

			mov r11b, byte [rdi] ; get the contents of the cell
			mov byte [r10], r11b ; copy the state of the cell to the new grid

			cmp r11b, 0
			je dead
			
			; alive 
			cmp al, 1
			jle kill ; death by isolation

			cmp al, 4
			jge kill ; death by overcrowding

			jmp countDone
			kill:
			mov byte [r10], 0
			jmp countDone

			dead:
				cmp al, 3
				jne countDone

				mov byte [r10], 1 ; make cell alive if 3 neighbors
			countDone:

			inc rdi ; increment grid pointers
			inc r10
			inc r9 ; increment loop counters
			cmp r9, SIZE - 1 ; loop test
			jl col

		add rdi, 2 ; increment grid pointers
		add r10, 2
		inc r8 ; increment loop counters
		cmp r8, SIZE - 1 ; loop test
		jl row
	
	mov rsp, rbp
	pop rbp
	ret

countCell: ; r13 = &grid. Address of cell at rdi
	mov rax, 0
	add al, byte [rdi + 1] ; right
	add al, byte [rdi - 1] ; left
	add al, byte [rdi + SIZE] ; down
	add al, byte [rdi - SIZE] ; up
	add al, byte [rdi + SIZE + 1] ; down-right
	add al, byte [rdi + SIZE - 1] ; down-left
	add al, byte [rdi - SIZE - 1] ; up-left
	add al, byte [rdi - SIZE + 1] ; up-right
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

	sleep_time timespec 0, 5000000

	aliveCell: db "#"
	deadCell: db " "
	newline: db 0x0A

	cursor db 0x1B, '[', 'H' ; escape sequence to go to home position
	len equ $-cursor
