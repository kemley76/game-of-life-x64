nasm -f elf64 -o gol.o gol.s
ld -o gol gol.o
./gol < gliderGun.txt
