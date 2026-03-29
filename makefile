.PHONY: all bootloader clean

all: bootloader disk.img

bootloader:
	make -C bootloader

disk.img: bootloader/boot.bin bootloader/core.bin
	cat bootloader/boot.bin bootloader/core.bin > disk.img

clean:
	make -C bootloader clean
	rm -f disk.img