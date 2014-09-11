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

	movw $MSG_INIT, %si
	call print_string
	
	movw $MSG_BOOT_INIT, %si	# display initial message
	call print_string

	movw $MSG_BOOT_ORIGIN, %si	# display where bootloader was booted from
	call print_string
	call bootnum_toascii
	movw $MSG_BOOT_DRIVE, %si
	call print_string

	movw $MSG_VIDEO_INITIAL, %si	# display the initial video mode
	call print_string
	call get_vidmode	
	call vidmode_toascii
	movw $MSG_VIDEO_MODE, %si
	call print_string

	movw $MSG_BOOT_RELOC, %si	# bootstrap system
	call print_string

	movw $MSG_PMODE_ENABLED, %si
	call print_string

	movb $0x02, %ah
	movb $0x01, %al
	movb $0x00, %ch
	movb $0x03, %cl
	movb $0x00, %dh
	movb BOOT_DRIVE, %dl
	movw $0x7F00, %bx
	movw %bx, %es
	movw $0x0000, %bx
	int $0x13

	movw $MSG_TEST, %si
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
	jg add_55_1a
	addb $48, %al
	jmp next1a
add_55_1a:
	add $55, %al
next1a:
	movb %al, (MSG_BOOT_DRIVE + 2)
	movb BOOT_DRIVE, %al
	andb $0x0F, %al
	cmp $10, %al
	jg add_55_2a
	addb $48, %al
	jmp next2a
add_55_2a:
	add $55, %al
next2a:
	movb %al, (MSG_BOOT_DRIVE + 3)
bootnum_toascii_end:
	ret

	
get_vidmode:
	movb $0x0F, %ah
	int $0x10
get_vidmode_end:
	ret

	
vidmode_toascii:
	movb %al, %ah
	shr $4, %al
	cmp $10, %al
	jg add_55_1b
	addb $48, %al
	jmp next1b
add_55_1b:
	add $55, %al
next1b:
	movb %al, (MSG_VIDEO_MODE + 2)
	movb %ah, %al
	andb $0x0F, %al
	cmp $10, %al
	jg add_55_2b
	addb $48, %al
	jmp next_2b
add_55_2b:
	add $55, %al
next_2b:
	movb %al, (MSG_VIDEO_MODE + 3)
vidmode_toascii_end:
	ret

#****************************************************************************************
# variables:

MSG_INIT:
	.ascii "copyright(c) 2014, Jarielle Catbagan"
	.byte 13, 10, 0
MSG_BOOT_INIT:
	.byte 13, 10
	.ascii "system on - bootloader initiated"
	.byte 13, 10, 0
MSG_BOOT_ORIGIN:
	.ascii "loaded from drive "
	.byte 0
BOOT_DRIVE:
	.byte 0x00
MSG_BOOT_DRIVE:
	.ascii "0x00"
	.byte 13, 10, 0
MSG_BOOT_RELOC:
	.ascii "bootstrapping remaining system"
	.byte 13, 10, 0
MSG_VIDEO_INITIAL:
	.ascii "initial video mode: "
	.byte 0
MSG_VIDEO_MODE:
	.ascii "0x00"
	.byte 13, 10, 0
MSG_PMODE_ENABLED:
	.ascii "protected mode is now enabled"
	.byte 13, 10, 0

#	.org 0x01FE

MSG_TEST:
	.ascii "hello world! :)"

	.org 0x01FE
	.word 0xAA55



#****************************************************************************************

