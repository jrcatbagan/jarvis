# Created: 10, September 2014

jarvis.iso: bootloader.bin
	mv $< iso-dep/bin
	genisoimage -R -b bin/bootloader.bin -no-emul-boot -boot-load-size 4 -o $@ \
		iso-dep
	mv jarvis.iso bin
	mv *.list *.o out
	xxd bin/jarvis.iso > jarvis.hexdump
	xxd iso-dep/bin/bootloader.bin > bootloader.hexdump
	mv *.hexdump out

bootloader.bin: bootloader.o
	objcopy -O binary $< $@

bootloader.o: bootloader.s
	as -al=bootloader.list -o $@ $<

.PHONY: clean
clean:
	rm -f out/* bin/*.iso iso-dep/bin/* *.hexdump
