.PHONY: all bootloader clean

all: bootloader disk.img

bootloader:
	make -C bootloader

disk.img: bootloader/bootloader.bin
	cp bootloader/bootloader.bin disk.img

clean:
	make -C bootloader clean
	rm -f disk.img