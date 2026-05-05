.PHONY: all bootloader clean

all: bootloader disk.img

bootloader:
	make -C bootloader

disk.img: bootloader/boot.bin bootloader/core.bin kernel/kernel.bin
	dd if=/dev/zero of=disk.img bs=512 count=100

	dd if=bootloader/boot.bin of=disk.img bs=512 conv=notrunc
	dd if=bootloader/core.bin of=disk.img bs=512 seek=1 conv=notrunc

	dd if=kernel/kernel.bin of=disk.img bs=512 seek=5 conv=notrunc

clean:
	make -C bootloader clean
	rm -f disk.img