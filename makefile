# Created: 10, September 2014

jarvis.iso: bootloader.bin
	genisoimage -R -b $< -no-emul-boot -boot-load-size 4 -o $@ .
	mv jarvis.iso bin
	mv *.bin *.list *.o out

bootloader.bin: bootloader.o
	objcopy -O binary $< $@

bootloader.o: bootloader.s
	as -al=bootloader.list -o $@ $<

.PHONY: clean
clean:
	rm -f out/* bin/*.iso
