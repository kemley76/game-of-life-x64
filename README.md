# Conway's Game of Life in x64 Assembly

![example](https://github.com/user-attachments/assets/714af2e5-b809-48d8-bc0d-fe96226d041f)

## Why?
I made this as fun way to learn the basics of x64 assembly and syscalls 

## How to run
```bash
sh run.sh <input file> # compiles and runs program
./gol < <input file>   # runs compuiled program
```
Two input files are provided already: `gliderGun.txt` and `snark.txt` (shown running above).

## Details
- Compiler: nasm x64 assembler
- Asm syntax: Intel x64
- Tested on: Linux Mint 22

## Adding new patterns
Currently, all patterns must be provided as a text file containing a square grid of alive cells (`#`) and dead cells (space). For it to work properly, you must edit `SIZE` in `gol.s` to be equal to one more than the number of columns in your new pattern file. 

## Possible Future Additions (though I don't plan on it)
- [ ] Functions to follow x64 ABI conventions
- [ ] Ability to determine simulation size on runtime
- [ ] Ability to automaticaly pad the simulation space with empty cells
- [ ] Ability to manually step through the simulation
