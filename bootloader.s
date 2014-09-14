#****************************************************************************************
#----------------------------------------------------------------------------------------
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
#----------------------------------------------------------------------------------------
	
	.code16
	.org 0x0000

#========================================================================================
# type:	function
# name: main
# parameter(s):
#		- none
# return:
#		- none
#----------------------------------------------------------------------------------------
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
	movw $BOOT_DRIVE, %bx
	movw $MSG_BOOT_DRIVE, %dx
	add $2, %dx
	call _8bithex_toascii
	movw $MSG_BOOT_DRIVE, %si
	call print_string

	movw $MSG_VIDEO_INITIAL, %si	# display the initial video mode
	call print_string
	call get_vidmode	
	movb %al, VIDEO_MODE
	movw $VIDEO_MODE, %bx
	movw $MSG_VIDEO_MODE, %dx
	add $2, %dx
	call _8bithex_toascii
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
	
	
complete:
	jmp complete
	
#========================================================================================

	
#========================================================================================
# type:	function
# name: print_string
# parameter(s):
#		- SI set to the address of message to print
# return:
#		- none
#----------------------------------------------------------------------------------------
print_string:	
0:	lodsb		
	andb $0xFF, %al	
	jz 1f
	movb $0x0E, %ah
	int $0x10
	jmp 0b
1:	ret
#========================================================================================


#========================================================================================
# type:	function
# name: _8bit_toascii
# parameter(s):
#		- BX contains the address of the 8-bit value to convert
#		- DX contains the address where the ascii 2-digit hex will be stored
# return:
#		- none
# description: converts an 8-bit value into an ascii 2-digit hexadecimal	
#----------------------------------------------------------------------------------------
_8bithex_toascii:		
	movb (%bx), %al	
	shr $4, %al
	cmp $10, %al
	jg 0f
	addb $48, %al
	jmp 1f
0:	add $55, %al
1:	push %bx
	movw %dx, %bx
	movb %al, (%bx)
	pop %bx
	movb (%bx), %al
	andb $0x0F, %al
	cmp $10, %al
	jg 2f
	addb $48, %al
	jmp 3f
2:	add $55, %al
3:	inc %dx
	push %bx
	movw %dx, %bx
	movb %al, (%bx)
	pop %bx
	ret
#========================================================================================
	
	
get_vidmode:
	movb $0x0F, %ah
	int $0x10
get_vidmode_end:
	ret

	

#========================================================================================
# variables
#---------------------------------------------------------------------------------------

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
VIDEO_MODE:
	.byte 0x00
MSG_VIDEO_MODE:
	.ascii "0x00"
	.byte 13, 10, 0
MSG_PMODE_ENABLED:
	.ascii "protected mode is now enabled"
	.byte 13, 10, 0

	.org 0x0600


#****************************************************************************************

