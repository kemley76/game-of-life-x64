SIZE equ 75
SQUARE_SIZE equ SIZE * SIZE
ALIVE equ '#'
DEAD equ ' '
NL equ 0xA

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
	
	call printNL

	mov r8, 0 ; loop counter
	mov r9, 0
	initialize: ; set second grid to dead
		mov r10b, byte [r13 + r8]
		cmp r10b, NL
		je addNL
			mov byte [r14 + r8], DEAD
			jmp doneInit
		addNL:
			mov byte [r14 + r8], NL
			mov r9, 0
		doneInit:
		inc r8
		inc r9
		cmp r8, SQUARE_SIZE + 1
		jle initialize 

	call clearScreen
	loop: 
		call printGrid
		call printNL
		call stepGrid
		call sleep
		xchg r13, r14
		jmp loop

	mov rax, 60
	xor rdi, rdi
	syscall

clearScreen: ; put string buffer into rsi
	mov rsi, clear
	mov rax, 1; print
	mov rdi, 1; fd = stdout
	mov rdx, clearLen
	syscall
	ret

printNL: ; put string buffer into rsi
	mov rsi, newline
	mov rax, 1; print
	mov rdi, 1; fd = stdout
	mov rdx, 1; count = 1
	syscall
	ret

movCursor: 
	mov rax, 1
	mov rdi, 1
	mov rsi, cursor
	mov rdx, cursorLen

	syscall
	ret

printGrid: ; print grid starting starting at r13
	call movCursor
	mov rsi, r13
	mov rax, 1; print
	mov rdi, 1; fd = stdout
	mov rdx, SQUARE_SIZE; 
	syscall
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

			cmp r11b, ALIVE
			jne dead
			
			; alive 
			cmp al, 1
			jle kill ; death by isolation

			cmp al, 4
			jge kill ; death by overcrowding

			jmp countDone
			kill:
			mov byte [r10], DEAD
			jmp countDone

			dead:
				cmp al, 3
				jne countDone

				mov byte [r10], ALIVE ; make cell alive if 3 neighbors
			countDone:

			inc rdi ; increment grid pointers
			inc r10
			inc r9 ; increment loop counters
			cmp r9, SIZE - 1; loop test
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
	mov bl, ALIVE

	cmp bl, byte [rdi + 1] ; right
	jne next1
	inc rax
	next1:

	cmp bl, byte [rdi - 1] ; left
	jne next2
	inc rax
	next2:

	cmp bl, byte [rdi + SIZE] ; down
	jne next3
	inc rax
	next3:

	cmp bl, byte [rdi - SIZE] ; up
	jne next4
	inc rax
	next4:

	cmp bl, byte [rdi + SIZE + 1] ; down-right
	jne next5
	inc rax
	next5:

	cmp bl, byte [rdi + SIZE - 1] ; down-left
	jne next6
	inc rax
	next6:

	cmp bl, byte [rdi - SIZE - 1] ; up-left
	jne next7
	inc rax

	next7:
	cmp bl, byte [rdi - SIZE + 1] ; up-right
	jne next8
	inc rax

	next8:
	ret

sleep: 
	mov rax, 35
	mov rdi, sleepTime
	mov rsi, 0
	syscall
	ret

%macro timespec 2
	dq %1
	dq %2
%endmacro

section .data

	sleepTime timespec 0, 50000000

	aliveCell: db ALIVE
	deadCell: db DEAD
	newline: db NL

	cursor db 0x1B, '[', 'H' ; move cursor to top left corner
	cursorLen equ $-cursor

	clear db 0x1B, '[', '2', 'J' ; clears all characters in terminal window
	clearLen equ $-cursor
