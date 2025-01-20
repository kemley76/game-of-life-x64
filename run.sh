nasm -f elf64 -o gol.o gol.s
ld -o gol gol.o
if [ -n $1 ] ; then 
	./gol < $1	
fi
