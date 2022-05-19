/*
|* @(|)z80mem.asm
|*
 * Copyright 2000, Aaron Ardiri     (mailto:aaron@ardiri.com)
 *                 Michael Ethetton (mailto:methetton@gambitstudios.com)
 *                 Fredrik Nylund   (mailto:fnylund@hotmail.com)
 * All rights reserved.
 * This file was generated as part of the "liberty" program developed for 
 * the Helio Computing Platform designed by VTech Holdings:
 *
 *   http://www.vtechinfo.com/ 
 *
 * The  contents of this  file is confidential and proprietrary in nature 
 * ("Confidential Information").  Redistribution or modification  without 
 * prior consent of the original author(s) is prohibited.
 *
 * NOTE:
 * The following portions of code found within this source code file  are
 * owned  exclusively by  Michael Ethetton,  and shall  not be used in or
 * sold  to other projects  (internal or external)  without  the  written
 * permission of Michael Ethetton.
 *
 * - z-80 CPU Emulation
 * - Nintendo Gameboy Emulation System
 *
 * The following portions of code found within this source code file are
 * owned  exclusively  by  Aaron Ardiri,  and  shall  not be  used in or 
 * sold to  other projects  (internal or external)  without the  written 
 * permission of Aaron Ardiri.
 *
 * - GNU vtos application framework
 * - Help System
 *
 * The following portions of code found within this source code file ar
 * owned  exclusively by Fredrik Nylund and Aaron Ardiri, and  shall not 
 * be used in or sold to  other projects  (internal or external) without
 * the written permission of one of the owners.
 *
 * - GameBoy(tm) ROM image memory management (desktop + handheld)
 *
 * It  shall be noted  that the Liberty  application was ported from the 
 * Palm Computing Platform version under sponsorship by VTech Holdings.
*/


/*  This code is used for memory writing */

/*
    Write 0000-1FFF  RAM Bank Enable
    Write 2000-3FFF  ROM Bank Select
    Write 4000-5FFF  RAM Bank Select
    Write 6000-7FFF  MCB1 ROM/RAM Bank Select
    Write 8000-87FF  RAM tile data
    Write 8800-8FFF  RAM tile data
    Write 9000-97FF  RAM tile data
    Write 9800-9BFF  RAM screen data
    Write 9C00-9FFF  RAM screen data
    Write A000-BFFF  RAM external (switchable)
    Write C000-DFFF  RAM internal
    Write E000-FDFF  RAM internal Echo
    Write FE00-FEFF  RAM OAM sprite table
    Write FF00-FFFF  RAM I/O ports & internal RAM

 *  t3 = byte to write
 *  t2 = address to write
 */

zWrite:
	andi	$t0,$t2, 0x00FF00	// Get high byte of address
	srl	$t0, $t0, 6		// get lookup
	add	$t1, $t0, $t6		// get address of code for instruction
	lw	$t0, ($t1)
	jr	$t0			// do instruction

zWriteTbl:
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo

	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo

	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo

	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo
	.word	WROM0_lo

	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi

	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi

	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi

	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi
	.word	WROM0_hi

	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo

	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo

	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo

	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo
	.word	WROM1_lo

	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi

	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi

	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi

	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi
	.word	WROM1_hi

	.word	WRAM_tile0
	.word	WRAM_tile0
	.word	WRAM_tile0
	.word	WRAM_tile0
	.word	WRAM_tile0
	.word	WRAM_tile0
	.word	WRAM_tile0
	.word	WRAM_tile0

	.word	WRAM_tile1
	.word	WRAM_tile1
	.word	WRAM_tile1
	.word	WRAM_tile1
	.word	WRAM_tile1
	.word	WRAM_tile1
	.word	WRAM_tile1
	.word	WRAM_tile1

	.word	WRAM_tile2
	.word	WRAM_tile2
	.word	WRAM_tile2
	.word	WRAM_tile2
	.word	WRAM_tile2
	.word	WRAM_tile2
	.word	WRAM_tile2
	.word	WRAM_tile2

	.word	WRAM_screen0
	.word	WRAM_screen0
	.word	WRAM_screen0
	.word	WRAM_screen0

	.word	WRAM_screen1
	.word	WRAM_screen1
	.word	WRAM_screen1
	.word	WRAM_screen1

	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext

	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext

	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext

	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext
	.word	WRAM_ext

	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int

	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int

	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int

	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int
	.word	WRAM_int

	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo

	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo

	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo

	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo
	.word	WRAM_echo

	.word	WRAM_sprite

	.word	WRAM_io




// Write 0000-1FFF  RAM Bank Enable
WROM0_lo:
					// Bank enable not needed
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// Write 2000-3FFF  ROM Bank Select
WROM0_hi:
	lbu	$t0, pageCount($s1)
	bltu	$t3, $t0, WROMPageOK	// see if ROM Page out of range
	subu	$t0, $t0, 1
	and	$t3, $t3, $t0		// if so, bring into range
WROMPageOK:
	bnez	$t3, WROMPage0		// If 0, change to ROM 1
	li	$t3, 1			// Get value of 1
//	movz	$t3, $t0, $t3		// If Page 0, then set to Page 1
WROMPage0:

	subu	$t0, $s2, $a1		// see if SP in Low ROM
	bltu	$t0, 0x4000, WROMSPOk
	subu	$t0, $s2, $a2		// High ROM?
	bgeu	$t0, 0x8000, WROMSPOk
	move	$s2, $t0		// SP In High ROM, get offset only
WROMSPOk:

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x4000, WROMPCOk
	subu	$t0, $s7, $a2		// High ROM?
	bgeu	$t0, 0x8000, WROMPCOk
	move	$s7, $t0		// PC In High ROM, get offset only
WROMPCOk:
	sb	$t3, curRomIndex($s1)	// save index (for save state)
	lw	$t0, ptrPageTbl($s1)
	sll	$t3, 2			// Get bank *4
	add	$t0, $t0, $t3
	lw	$a2, ($t0)		// get new ROM Ptr
	sw	$a2, ptrCurRom($s1)	// Save ROM ptr
	subu	$a2, 0x4000

	bgeu	$s7, 0x8000, WROMPCCont	// If PC in high ROM,
	add	$s7, $s7, $a2		// add back in ROM pointer
WROMPCCont:
	bgeu	$s2, 0x8000, WROMSPCont	// If SP in high ROM,
	add	$s2, $s2, $a2		// add back in ROM pointer
WROMSPCont:

	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	


// Write 4000-5FFF  RAM Bank Select
WROM1_lo:
					// not implemented
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// Write 6000-7FFF  MCB1 ROM/RAM Bank Select
WROM1_hi:
					// not implemented
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// Write 8000-87FF  RAM tile data
WRAM_tile0:
	addu	$t1, $t2, $a3		// RAM write
	sb	$t3, ($t1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// Write 8800-8FFF  RAM tile data
WRAM_tile1:
	add	$t1, $t2, $a3		// RAM write
	sb	$t3, ($t1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// Write 9000-97FF  RAM tile data
WRAM_tile2:
	add	$t2, $t2, $a3		// RAM write
	sb	$t3, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// Write 9800-9BFF  RAM screen data
WRAM_screen0:
	add	$t0, $t2, $a3		// RAM write
	sb	$t3, ($t0)
	sll	$t3, 4
	subu	$t2, 0x09800
	add	$t0, $t2, $t2
	lw	$t1, ptrTileTable($s1)
	add	$t0, $t0, $t1
	sh	$t3, ($t0)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// Write 9C00-9FFF  RAM screen data
WRAM_screen1:
	add	$t0, $t2, $a3		// RAM write
	sb	$t3, ($t0)
	sll	$t3, 4
	subu	$t2, 0x09800
	add	$t0, $t2, $t2
	lw	$t1, ptrTileTable($s1)
	add	$t0, $t0, $t1
	sh	$t3, ($t0)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// Write A000-BFFF  RAM external (switchable)
WRAM_ext:
	add	$t2, $t2, $a3		// RAM write
	sb	$t3, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// Write C000-DFFF  RAM internal
WRAM_int:
	add	$t2, $t2, $a3		// RAM write
	sb	$t3, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// Write E000-FDFF  RAM internal Echo
WRAM_echo:
	andi	$t2, $t2, 0xDFFF	// mask bit
	add	$t2, $t2, $a3		// RAM write
	sb	$t3, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// Write FE00-FEFF  RAM OAM sprite table
WRAM_sprite:
	add	$t2, $t2, $a3		// RAM write
	sb	$t3, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// Write FF00-FFFF  RAM I/O ports & internal RAM
WRAM_io:
	andi	$t0, $t2, 0x00FF
	sltiu	$t1, $t0, 0x4E		// see if address>FF4D
	beqz	$t1, WRAM_ioWrite	// yes, branch

	sll	$t0, $t0, 2		// Get lookup

	la	$t1, zHigh2
	add	$t1, $t1, $t0		// get address of code for instruction
	lw	$t0, ($t1)
	jr	$t0			// do instruction

WRAM_ioWrite:
	addu	$t1, $t2, $a3		// RAM write
	sb	$t3, ($t1)

	bne	$t0, 0x00FF, WRAM_ioExit	//  See if writing to IE
	beqz	$t9, WRAM_ioExit	// If interrupts aren't enabled, don't do anything
	j	zFB			// Do EI to check for pending interrupts
WRAM_ioExit:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

	


zHigh2:
	.word	zFF00
	.word	zFF01
	.word	zFF02
	.word	zFF03
	.word	zFF04
	.word	zFF05
	.word	zFF06
	.word	zFF07
	.word	zFF08
	.word	zFF09
	.word	zFF0A
	.word	zFF0B
	.word	zFF0C
	.word	zFF0D
	.word	zFF0E
	.word	zFF0F
	.word 	zFF10
	.word	zFF11
	.word	zFF12
	.word	zFF13
	.word	zFF14
	.word	zFF15
	.word	zFF16
	.word	zFF17
	.word	zFF18
	.word	zFF19
	.word	zFF1A
	.word	zFF1B
	.word	zFF1C
	.word	zFF1D
	.word	zFF1E
	.word	zFF1F
	.word	zFF20
	.word	zFF21
	.word	zFF22
	.word	zFF23
	.word	zFF24
	.word	zFF25
	.word	zFF26
	.word	zFF27
	.word	zFF28
	.word	zFF29
	.word	zFF2A
	.word	zFF2B
	.word	zFF2C
	.word	zFF2D
	.word	zFF2E
	.word	zFF2F
	.word	zFF30
	.word	zFF31
	.word	zFF32
	.word	zFF33
	.word	zFF34
	.word	zFF35
	.word	zFF36
	.word	zFF37
	.word	zFF38
	.word	zFF39
	.word	zFF3A
	.word	zFF3B
	.word	zFF3C
	.word	zFF3D
	.word	zFF3E
	.word	zFF3F
	.word	zFF40
	.word	zFF41
	.word	zFF42
	.word	zFF43
	.word	zFF44
	.word	zFF45
	.word	zFF46
	.word	zFF47
	.word	zFF48
	.word	zFF49
	.word	zFF4A
	.word	zFF4B
	.word	zFF4C
	.word	zFF4D





// *************************************
// * Loads joypad byte
					// P1
zFF00:
	andi	$t0, $t3, 0x10		// See if Scanning U/D/L/R
	beqz	$t0, zKeybd2
	andi	$t0, $t3, 0x20		// scanning Start/Sel/B/A
	beqz	$t0, zKeybd1
	li	$t1, 0xFF
	sb	$t1, 0x7F00($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zKeybd1:
	lbu	$t0, SelKey($s1)	// St/Sel/B/A
	not	$t0, $t0
	andi	$t0, $t0, 0x0F
	ori	$t0, $t0, 0xD0
	sb	$t0, 0x7F00($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zKeybd2:
	lbu	$t0, SelKey($s1)	// U/D/L/R
	not	$t0, $t0
	srl	$t0, 4
	andi	$t0, $t0, 0x0F
	ori	$t0, 0xE0
	sb	$t0, 0x7F00($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF01:
	sb	$t3, 0x7F01($t8)	// SB Serial transfer
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

					// SC
zFF02:
	andi	$t0, $t3, 0x80		// See if Start Timer
	beqz	$t0, zFF02W
	li	$t0, 9
	sb	$t0, regSerTimer($s1)	// Load the Serial Timer Countdown
zFF02W:
	sb	$t3, 0x7F02($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF03:
	sb	$t3, 0x7F03($t8)	// * not used *
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF04:
	sb	$zero, 0x7F04($t8)	// DIV
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF05:
	sb	$t3, 0x7F05($t8)	// TIMA timer counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF06:
	sb	$t3, 0x7F06($t8)	// TMA timer modulo
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF07:
	sb	$t3, 0x7F07($t8)	// TAC timer control
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF08:
	sb	$t3, 0x7F08($t8)	// 0x08-0x0E **not used**
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF09:
	sb	$t3, 0x7F09($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF0A:
	sb	$t3, 0x7F0A($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF0B:
	sb	$t3, 0x7F0B($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF0C:
	sb	$t3, 0x7F0C($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF0D:
	sb	$t3, 0x7F0D($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF0E:
	sb	$t3, 0x7F0E($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF0F:
	ori	$t3, $t3, 0xE0		// IF
	sb	$t3, 0x7F0F($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

					// Sound Registers...
zFF10:
	sb	$t3, 0x7F10($t8)	// Snd 1 Freq. Sweep Register
/*
	move.b	%d1, %d0		// Sweep Time in bits 4-6
	lsr.b	#4, %d0			// move to bits 0-2
	andi.b	#0x07, %d0
	move.b	%d0, snd1FTime(%a0)	| Save it to counter
	move.b	%d0, snd1FCtr(%a0)
	andi.b	#0x07, %d1		| Get freq. change divisor
	move.b	%d1, snd1Div(%a0)

	move.w	0x14(%a4), %d0 		| Save Freq to Current Frequency
	move.b	0x13(%a4), %d0
	andi.w	#0x07FF, %d0
	move.w	%d0, snd1Freq(%a0)
*/
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF11:
	sb	$t3, 0x7F11($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF12:
	sb	$t3, 0x7F12($t8)	// Snd 1 Envelope
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
/*
	move.b	%d1, %d0		| Envelope sweep & counter
	andi.b	#0x03, %d0
	move.b	%d0, snd1Env(%a0)
	move.b	%d0, snd1ECtr(%a0)
	andi.b	#0xF0, %d1		| set initial volume
	lsr.b	#4, %d1
	move.b	%d1, snd1Vol(%a0)
*/

zFF13:
	sb	$t3, 0x7F13($t8)	//  Snd 1 Freq (Low)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
/*
	move.w	0x14(%a4), %d0 		| Save to Current Frequency
	move.b	%d1, %d0
	andi.w	#0x07FF, %d0
	move.w	%d0, snd1Freq(%a0)
*/

zFF14:
	sb	$t3, 0x7F14($t8)	//  Snd 1 Freq (Low)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
/*
	move.w	0x14(%a4), %d0 		| Save to Current Frequency
	move.b	0x13(%a4), %d0
	andi.w	#0x07FF, %d0
	move.w	%d0, snd1Freq(%a0)
*/

zFF15:
	sb	$t3, 0x7F15($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF16:
	sb	$t3, 0x7F16($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF17:
	sb	$t3, 0x7F17($t8)	// Snd 2 Envelope
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
/*
	move.b	%d1, %d0		| Envelope sweep & counter
	andi.b	#0x03, %d0
	move.b	%d0, snd2Env(%a0)
	move.b	%d0, snd2ECtr(%a0)
	andi.b	#0xF0, %d1		| set initial volume
	lsr.b	#4, %d1
	move.b	%d1, snd2Vol(%a0)
*/

zFF18:
	sb	$t3, 0x7F18($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF19:
	sb	$t3, 0x7F19($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF1A:
	sb	$t3, 0x7F1A($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF1B:
	sb	$t3, 0x7F1B($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF1C:
	sb	$t3, 0x7F1C($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF1D:
	sb	$t3, 0x7F1D($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF1E:
	sb	$t3, 0x7F1E($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF1F:
	sb	$t3, 0x7F1F($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF20:
	sb	$t3, 0x7F20($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF21:
	sb	$t3, 0x7F21($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF22:
	sb	$t3, 0x7F22($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF23:
	sb	$t3, 0x7F23($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF24:
	sb	$t3, 0x7F24($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF25:
	sb	$t3, 0x7F25($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF26:
	lbu	$t0, 0x7F26($t8)	// Turn on/off Sound (bit 7)
	andi	$t3, 0x80		// Bits 0-3 are current sound channel status
	andi	$t0, 0x7F 
	or	$t3, $t3, $t0
	sb	$t3, 0x7F26($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF27:
	sb	$t3, 0x7F27($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF28:
	sb	$t3, 0x7F28($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF29:
	sb	$t3, 0x7F29($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF2A:
	sb	$t3, 0x7F2A($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF2B:
	sb	$t3, 0x7F2B($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF2C:
	sb	$t3, 0x7F2C($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF2D:
	sb	$t3, 0x7F2D($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF2E:
	sb	$t3, 0x7F2E($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF2F:
	sb	$t3, 0x7F2F($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF30:
	sb	$t3, 0x7F30($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF31:
	sb	$t3, 0x7F31($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF32:
	sb	$t3, 0x7F32($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF33:
	sb	$t3, 0x7F33($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF34:
	sb	$t3, 0x7F34($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF35:
	sb	$t3, 0x7F35($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF36:
	sb	$t3, 0x7F36($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF37:
	sb	$t3, 0x7F37($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF38:
	sb	$t3, 0x7F38($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF39:
	sb	$t3, 0x7F39($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF3A:
	sb	$t3, 0x7F3A($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF3B:
	sb	$t3, 0x7F3B($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF3C:
	sb	$t3, 0x7F3C($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF3D:
	sb	$t3, 0x7F3D($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF3E:
	sb	$t3, 0x7F3E($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF3F:
	sb	$t3, 0x7F3F($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF40:
	lbu	$t0, 0x7F40($t8)	// Get current LCDC
	beq	$t0, $t3, zFF40Exit	// If no change, do nothing
	bnez	$v0, zFF40DontDraw	// Is drawing frame?

	subu	$sp, $sp, 4		// If so, draw up to current line
	sw	$ra, ($sp)
	jal	DrawLines
	lw	$ra, ($sp)
	add	$sp, $sp, 4
zFF40DontDraw:
	sb	$t3, 0x7F40($t8)
zFF40Exit:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF41:
	andi	$t3, $t3, 0xF8		// STAT (LCDC Status)
//	ori	$t3, $t3, 0x80
	sb	$t3, 0x7F41($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF42:
	lbu	$t0, 0x7F42($t8)	// Get current SCY
	beq	$t0, $t3, zFF42Exit	// If no change, do nothing
	bnez	$v0, zFF42DontDraw	// Is drawing frame?

	subu	$sp, $sp, 4		// If so, draw up to current line
	sw	$ra, ($sp)
	jal	DrawLines
	lw	$ra, ($sp)
	add	$sp, $sp, 4
zFF42DontDraw:
	sb	$t3, 0x7F42($t8)
zFF42Exit:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF43:
	lbu	$t0, 0x7F43($t8)	// Get current SCX
	beq	$t0, $t3, zFF43Exit	// If no change, do nothing
	bnez	$v0, zFF43DontDraw	// Is drawing frame?

	subu	$sp, $sp, 4		// If so, draw up to current line
	sw	$ra, ($sp)
	jal	DrawLines
	lw	$ra, ($sp)
	add	$sp, $sp, 4
zFF43DontDraw:
	sb	$t3, 0x7F43($t8)	// Save SCX
	and	$t0, $t3, 0x07		// Get remainder (x scroll offset)

	li	$t1, 8
	subu	$t0, $t1, $t0		// invert remainder
	sb	$t0, xBitOff($s1)	// Save pixel offset
	srl	$t1, $t3, 3		// /8 pixels/tile
	sb	$t1, xByteOff($s1)	// Save Byte offset
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFF43Exit:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



zFF44:
	lbu	$t0, ptrScreen($s1)	// LY
	sb	$zero, 0x7F44($t8)
	addiu	$t0, $t0, 1408
	sb	$t0, ptrCurLine($s1) 	// Reset Screen Pointer

	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF45:
	sb	$t3, 0x7F45($t8)	// LYC
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// *************************************
// *  Performs the DMA transfer function
zFF46:
					// DMA

	andi	$t3, 0x0FF		// Get address to transfer from
	sll	$t3, 8
	bge	$t3, 0x08000, zDMARAM
	blt	$t3, 0x04000, zDMALowROM
	add	$t3, $t3, $a2
	b	zDMANext
zDMALowROM:
	add	$t3, $t3, $a1
	b	zDMANext
zDMARAM:
	add	$t3, $t3, $a3
zDMANext:
	add	$t2, $t8, 0x07e00	// Get Sprite Ram (transfer to address)

	// Transfer 160 bytes

	ld	$t0, ($t3)
	ld	$t4, 8($t3)
	sd	$t0, ($t2)
	sd	$t4, 8($t2)
	ld	$t0, 16($t3)
	ld	$t4, 24($t3)
	sd	$t0, 16($t2)
	sd	$t4, 24($t2)
	ld	$t0, 32($t3)
	ld	$t4, 40($t3)
	sd	$t0, 32($t2)
	sd	$t4, 40($t2)
	ld	$t0, 48($t3)
	ld	$t4, 56($t3)
	sd	$t0, 48($t2)
	sd	$t4, 56($t2)
	ld	$t0, 64($t3)
	ld	$t4, 72($t3)
	sd	$t0, 64($t2)
	sd	$t4, 72($t2)

	ld	$t0, 80($t3)
	ld	$t4, 88($t3)
	sd	$t0, 80($t2)
	sd	$t4, 88($t2)
	ld	$t0, 96($t3)
	ld	$t4, 104($t3)
	sd	$t0, 96($t2)
	sd	$t4, 104($t2)
	ld	$t0, 112($t3)
	ld	$t4, 120($t3)
	sd	$t0, 112($t2)

	sd	$t4, 120($t2)
	ld	$t0, 128($t3)
	ld	$t4, 136($t3)
	sd	$t0, 128($t2)
	sd	$t4, 136($t2)
	ld	$t0, 144($t3)
	ld	$t4, 152($t3)
	sd	$t0, 144($t2)
	sd	$t4, 152($t2)

//	jr	$ra			// Whole thing takes 160 microseconds

	lbu	$t0, ($s7)		//  See if next inst. is LD a
	bne	$t0, 0x3E, DontSkip
	add	$s7, 2			// skip load
	li	$s0, 1			// move 1 to reg. A
DontSkip:
	jr	$ra			// Whole thing takes 160 microseconds


zFF47:
	lbu	$t0, 0x7F47($t8)	// Get current BGP
	beq	$t0, $t3, zFF47Exit	// If no change, do nothing

	bnez	$v0, zFF47DontDraw	// Is drawing frame?

	subu	$sp, $sp, 4		// If so, draw up to current line
	sw	$ra, ($sp)
	jal	DrawLines
	lw	$ra, ($sp)
	add	$sp, $sp, 4
zFF47DontDraw:
	sb	$t3, 0x7F47($t8)	// Save BGP
	beqz	$t3, zFF47Exit		// If palette=0, do nothing

	lw	$t5, ptrBgPal($s1)	// get pointer to bg palette

UpdPalette:
	andi	$t1, $t3, 0x03		// Get palette #00 value
	sll	$t2, $t1, 2
	or	$t4, $t2, $t1
	sll	$t3, $t3, 4
	andi	$t1, $t3, 0xC0		// Get palette #01 value
	srl	$t2, $t1, 2
	or	$t4, $t4, $t1
	or	$t4, $t4, $t2
	andi	$t1, $t3, 0x0300	// Get palette #10 value
	sll	$t2, $t1, 2
	or	$t4, $t4, $t1
	or	$t4, $t4, $t2
	sll	$t3, $t3, 4
	andi	$t1, $t3, 0xC000	// Get palette #11 value
	srl	$t2, $t1, 2
	or	$t4, $t4, $t1
	or	$t4, $t4, $t2

	andi	$t0, $t4, 0x0F		// save 0
	sll	$t1, $t0, 4
	or	$t0, $t0, $t1
	sb	$t0, ($t5)
	andi	$t0, $t0, 0xF0		// save 1
	srl	$t1, $t4, 4
	andi	$t1, $t1, 0x0F
	or	$t0, $t0, $t1
	sb	$t0, 1($t5)
	andi	$t0, $t4, 0xFF		// save 2
	sb	$t0, 2($t5)
	andi	$t0, $t4, 0xF0		// save 3
	srl	$t1, $t0, 4
	or	$t0, $t0, $t1
	sb	$t0, 3($t5)
	andi	$t0, $t4, 0x0F		// save 4
	sll	$t1, $t0, 4
	andi	$t0, $t4, 0x0F00
	srl	$t0, $t0, 8
	or	$t0, $t0, $t1
	sb	$t0, 4($t5)
	andi	$t1, $t4, 0x0F		// save 5
	andi	$t0, $t4, 0xF000
	srl	$t0, $t0, 12
	or	$t0, $t0, $t1
	sb	$t0, 5($t5)
	andi	$t1, $t4, 0xF0		// save 6
	andi	$t0, $t4, 0x0F00
	srl	$t0, $t0, 8
	or	$t0, $t0, $t1
	sb	$t0, 6($t5)
	andi	$t1, $t4, 0xF0		// save 7
	andi	$t0, $t4, 0xF000
	srl	$t0, $t0, 12
	or	$t0, $t0, $t1
	sb	$t0, 7($t5)
	andi	$t1, $t4, 0x0F00	// save 8
	srl	$t1, $t1, 4
	andi	$t0, $t4, 0x0F
	or	$t0, $t0, $t1
	sb	$t0, 8($t5)
	srl	$t0, $t4, 4		// save 9
	sb	$t0, 9($t5)
	andi	$t1, $t4, 0xF000	// save 10
	srl	$t1, $t1, 8
	andi	$t0, $t4, 0x0F
	or	$t0, $t0, $t1
	sb	$t0, 10($t5)
	andi	$t1, $t0, 0xF0		// save 11
	andi	$t0, $t4, 0xF0	
	srl	$t0, $t0, 4
	or	$t0, $t0, $t1
	sb	$t0, 11($t5)
	andi	$t1, $t4, 0x0F00	// save 12
	srl	$t1, $t1, 4
	srl	$t0, $t1, 4
	or	$t0, $t0, $t1
	sb	$t0, 12($t5)
	andi	$t1, $t0, 0xF0		// save 13
	andi	$t0, $t4, 0xF000	
	srl	$t0, $t0, 12
	or	$t0, $t0, $t1
	sb	$t0, 13($t5)
	srl	$t0, $t4, 8		// save 14
	sb	$t0, 14($t5)
	andi	$t1, $t0, 0xF0		// save 15
	srl	$t0, $t1, 4
	or	$t0, $t0, $t1
	sb	$t0, 15($t5)


zFF47Exit: 
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

	j	UpdPalette

zFF48:
	lbu	$t0, 0x7F48($t8)	// Get current PAL0
	beq	$t0, $t3, zFF47Exit	// If no change, do nothing
	bnez	$v0, zFF48DontDraw	// Is drawing frame?

	subu	$sp, $sp, 4		// If so, draw up to current line
	sw	$ra, ($sp)
	jal	DrawLines
	lw	$ra, ($sp)
	add	$sp, $sp, 4
zFF48DontDraw:
	sb	$t3, 0x7F48($t8)	// Save BGP
	beqz	$t3, zFF47Exit		// If palette=0, do nothing

	lw	$t5, ptrObjPal0($s1)	// get pointer to bg palette



zFF49:
	lbu	$t0, 0x7F49($t8)	// Get current PAL1
	beq	$t0, $t3, zFF47Exit	// If no change, do nothing
	bnez	$v0, zFF49DontDraw	// Is drawing frame?

	subu	$sp, $sp, 4		// If so, draw up to current line
	sw	$ra, ($sp)
	jal	DrawLines
	lw	$ra, ($sp)
	add	$sp, $sp, 4
zFF49DontDraw:
	sb	$t3, 0x7F49($t8)	// Save BGP
	beqz	$t3, zFF47Exit		// If palette=0, do nothing

	lw	$t5, ptrObjPal1($s1)	// get pointer to bg palette

	j	UpdPalette

zFF4A:
	sb	$t3, 0x7F4A($t8)	// WY
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF4B:
	sb	$t3, 0x7F4B($t8)	// WX

	add	$t0, $t3, 1
	srl	$t1, $t0, 3		// /8
	sb	$t1, wxByteOff($s1)	// Save Byte offset

	andi	$t0, $t0, 0x07		// Get remainder (x scroll offset)

	sb	$t0, wxBitOff($s1)	// Save pixel offset

	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zFF4C:
	sb	$t3, 0x7F4C($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFF4D:
	sb	$t3, 0x7F4D($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

