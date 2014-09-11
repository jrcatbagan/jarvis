#****************************************************************************************
#
# File: bootloader.s
#
# Created: 10, September 2014
#
# Copyright (C) 2014, Jarielle Catbagan
#
# BSD-style license
# Please refer to COPYING.txt for license details
#
#****************************************************************************************
	
	.code16
	.org 0x0000
main:
	movw $0x07C0, %ax	# initialize 'ds' and 'es' to segment 0x07C0 since that
	movw %ax, %ds		# is where the BIOS places the boot code first 
	movw %ax, %es

	movw $0x0000, %ax	# initialize the stack to 0x0000:0x7B00
	movw %ax, %ss
	movw $0x7B00, %bp
	movw %bp, %sp

	movb %dl, BOOT_DRIVE	# save the drive number where bootloader was loaded from
	
	movw $MSG_BOOT_INIT, %si
	call print_string

	movw $MSG_BOOT_ORIGIN, %si
	call print_string
	call bootnum_toascii
	movw $MSG_BOOT_DRIVE, %si
	call print_string
complete:
	jmp complete

#****************************************************************************************
# functions:
	
print_string:			# this function assumes that the string to be printed
	lodsb			# is passed as an argument where the 'si' register
	andb $0xFF, %al		# points to its location 
	jz print_string_end
	movb $0x0E, %ah
	int $0x10
	jmp print_string
print_string_end:
	ret

bootnum_toascii:		# this function converts an 8-bit hexadecimal value
	movb BOOT_DRIVE, %al	# into an ascii string
	shr $4, %al
	cmp $10, %al
	jg add_55_1
	addb $48, %al
	jmp next1
add_55_1:
	add $55, %al
next1:
	movb %al, (MSG_BOOT_DRIVE + 2)
	movb BOOT_DRIVE, %al
	andb $0x0F, %al
	cmp $10, %al
	jg add_55_2
	addb $48, %al
	jmp next2
add_55_2:
	add $55, %al
next2:
	movb %al, (MSG_BOOT_DRIVE + 3)
bootnum_toascii_end:
	ret

#****************************************************************************************
# variables:
	
MSG_BOOT_INIT:
	.ascii "system on - bootloader initiated"
	.byte 13, 10, 0
MSG_BOOT_ORIGIN:
	.ascii "loaded from drive "
BOOT_DRIVE:
	.byte 0x00
MSG_BOOT_DRIVE:
	.ascii "0x00"
	.byte 13, 10, 0
MSG_BOOT_RELOC:
	.ascii "bootstrapping remaining system"
	.byte 13, 10, 0

	.rept 308
	.byte 0
	.endr

	.word 0xAA55
	
	.end

#****************************************************************************************

