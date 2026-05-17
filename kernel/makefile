.PHONY: all build clean

all: build kernel.bin

build:
	cargo build

kernel.bin: target/x86_64-nok_os/debug/nok
	cp target/x86_64-nok_os/debug/nok kernel.bin

clean:
	rm -f kernel.bin