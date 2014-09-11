# Created: 10, September 2014

build: bootloader.bin
	dd if=bootloader.bin of=bootloader.img bs=512
	mv bootloader.img bin/floppy
	mv *.bin *.list *.o out

bootloader.bin: bootloader.o
	objcopy -O binary $< $@

bootloader.o: bootloader.s
	as -al=bootloader.list -o $@ $<

.PHONY: clean
clean:
	rm -f out/* bin/floppy/*.img
