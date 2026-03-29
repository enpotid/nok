.PHONY: all clean

all: boot.bin core.bin

boot.bin: boot.asm
	nasm -o boot.bin boot.asm

core.bin: core.asm
	nasm -o core.bin core.asm

clean:
	rm -f boot.bin