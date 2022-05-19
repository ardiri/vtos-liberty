/*
 * @(#)gameboy.cc
 *
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

#include "resource.h"

	.file	1 "gameboy.cc"

// constant labels
#define regBC             0
#define regB              1
#define regC              0
#define regDE             2
#define regD              3
#define regE              2
#define regHL             4
#define regH              5
#define regL              4
#define regA              7
#define regF              6
#define regSP             8
#define regPC             10
#define regInt            12
#define regTimer          13
#define regSerTimer       14  // z80 CPU references
#define regA_old          15

#define xBitOff           16
#define xByteOff          17
#define wxBitOff          18
#define wxByteOff         19
#define xOffset           20
#define oldBgPal          21

#define SelKey            22
#define _dummy1           23 // padding byte

#define curRomIndex       24

#define ptrCurLine        28		// new structure = aligned on 4 byte boundry

#define ptrHLConv         32
#define ptrBgPal          36
#define ptrObjPal0        40
#define ptrObjPal1        44

#define ptrLCDScreen      48
#define ptrScreen         52

#define ptr32KRam         56
#define ptrTileTable      60
#define ptrBGTileRam      64

#define pageCount         68
#define ptrPageTbl        72
#define ptrCurRom         76

#define StartDLine        0x7F4c
#define ScreenWinY        0x7f4d
#define $zero             $0
#define $at               $1
#define $v0               $2
#define $v1               $3
#define $a0               $4
#define $a1               $5
#define $a2               $6
#define $a3               $7
#define $t0               $8
#define $t1               $9
#define $t2               $10
#define $t3               $11
#define $t4               $12
#define $t5               $13
#define $t6               $14
#define $t7               $15
#define $s0               $16
#define $s1               $17
#define $s2               $18
#define $s3               $19
#define $s4               $20
#define $s5               $21
#define $s6               $22
#define $s7               $23
#define $t8               $24
#define $t9               $25
#define $k0               $26
#define $k1               $27
#define $gp               $28
#define $sp               $29
#define $fp               $30
#define $ra               $31


// independant resources
#include "z80mem.asm"
#include "z80.asm"
#include "screen.asm"

/*
 * NOTES:
 *
 *   The following assumptions can be made:
 *
 *     - register "t0" = pointer to gameboy specific "globals" 
 *
 */


.globl	EmulateFrame
	.ent	EmulateFrame

EmulateFrame:
	.frame	$sp,0,$31
	.mask	0x00000000,0
	.fmask	0x00000000,0

main:

// Save registers to stack
	sub	$sp, $sp, 60
	sw	$v0, 56($sp)
	sw	$v1, 52($sp)
	sw	$a0, 48($sp)
	sw	$a1, 44($sp)
	sw	$a2, 40($sp)
	sw	$a3, 36($sp)
	sw	$s0, 32($sp)
	sw	$s1, 28($sp)
	sw	$s2, 24($sp)
	sw	$s3, 20($sp)
	sw	$s4, 16($sp)
	sw	$s5, 12($sp)
	sw	$s6, 8($sp)
	sw	$s7, 4($sp)
	sw	$ra, ($sp)

	move	$s1, $t0

	la	$s6, zOP		// location of data tables
	la	$t6, zWriteTbl		// location of data tables
	lw	$t0, ptrPageTbl($s1)
	lw	$a2, ptrCurRom($s1)


	ulw	$a1, 0($t0)		// Get ROM Page 0 ptr

	sub	$a2, $a2, 0x4000	// Get current ROM page ptr (-0x4000

	lw	$t8, ptr32KRam($s1)	// Get RAM ptr
	sub	$a3, $t8, 0x8000	// -0x8000

	lbu	$s0, regA($s1)		// Load regA

	lbu	$t9, regInt($s1)	// Load Interrupts Enabled Flag

	lbu	$s5, regF($s1)		// Get flags
	andi	$s4, $s5, 0x10
	srl	$s4, $s4, 4		// C Flag
	andi	$s5, 0x80		// Z flag

	ulhu	$s2, regSP($s1)		// Get SP
	bltu	$s2, 0x08000, spROM	// See if ROM
	add	$s2, $s2, $a3
	b	spCont	
spROM:
	bltu	$s2, 0x4000, spLowROM	// If ROM page 0
	add	$s2, $s2, $a2
	b	spCont
spLowROM:
	add	$s2, $s2, $a1
spCont:


	ulhu	$s7, regPC($s1)		// Get PC + offset
	bltu	$s7, 0x08000, pcROM	// See if ROM
	add	$s7, $s7, $a3
	b	pcCont
pcROM:
	bltu	$s7, 0x4000, pcLowROM	// If ROM page 0
	add	$s7, $s7, $a2
	b	pcCont
pcLowROM:
	add	$s7, $s7, $a1
pcCont:
 
/*
	lbu	$t2, 0x7fef($t8)
	sub	$t2, 1
	bgtz	$t2, aacont
	li	$t2, 60
	ulw	$t0, ptrLCDScreen($s1)
	lw	$t1, 1240($t0)
	not	$t1
	usw	$t1, 1240($t0)
aacont:
	sb	$t2, 0x7fef($t8)
*/

 	li	$v0, 2			// Set for frame counting

DispFrameLoop:
	subu	$v0, 1			// frame counter
	lw	$t0, ptrScreen($s1)	// Reset screen line
	li	$t7, 0			// Current Line#=0
	sb	$t7, ScreenWinY($t8)
	addi	$t0, $t0, 1404
	sw	$t0, ptrCurLine($s1)
	sb	$t7, StartDLine($t8)	// Save as last row completed


Do144Lines:
	lbu	$t0, 0x7f41($t8)	// OAM Searching Mode
	li	$a0, 20			// 21 instruction cycles
	andi	$t0, $t0, 0xFC
	ori	$t0, $t0, 0x02
	sb	$t0, 0x7f41($t8)

//******	Execute 21 CPU cycles
	jal	Z80Loop

	lb	$t1, 0x7f41($t8)	// OAM Transferring Mode
	ori	$t1, $t1, 0x03
	sb	$t1, 0x7f41($t8)


//****	Serial interrupt

	lbu	$t0, 0x7f02($t8)	// Is serial started?
	bltu	$t0, 0x080, NoSerialInt	// no (If bit 8 is off)

	andi	$t1, $t0, 0x01		// Is timer external?
	beqz	$t1, NoSerialInt	// Yes, and we are not receiving, so continue

	lbu	$t1, regSerTimer($s1)	// decrement Serial Timer
	subu	$t1, 1
	sb	$t1, regSerTimer($s1)
	bnez	$t1, NoSerialInt	// If no overflow, continue

	lbu	$t3, 0x7f0f($t8)	// raise Serial interrupt flag
	ori	$t1, $t3, 0x08
	sb	$t1, 0x7f0f($t8)
	
	andi	$t0, 0x7F		// Stop serial
	sb	$t0, 0x7f02($t8)
	li	$t0, 0xFF
	sb	$t0, 0x7f01($t8)	// Set recieved data to FF

	beqz	$t9, NoSerialInt	// If interrupts are disabled, don't do

	lbu	$t0, 0x7fff($t8)	// Is Serial Int. Enabled?
	andi	$t0, 0x08
	beqz	$t0, NoSerialInt

	andi	$t1, $t3, 0xF7
	sb	$t1, 0x7f0f($t8)	// Clear Serial Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, SerPCOk
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, SerPCOk
	subu	$t0, $s7, $a3		// RAM
SerPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x58		// Jump to Serial interrupt handler

NoSerialInt:


//******	Execute 21 CPU cycles	
	li	$a0, 20			// 21 instruction cycles
	jal	Z80Loop


	lb	$t1, 0x7f04($t8)	// Decrement DivReg
	subu	$t1, $t1, 1
	sb	$t1, 0x7f04($t8)


//****	Do HBlank Interrupt
	lbu	$t0, 0x7f41($t8)	// see if Horizontal Interrupt is enabled
	andi	$t1, $t0, 0x08
	beqz	$t1, NoHBlankInt	// no

	lbu	$t0, 0x7f40($t8)	// Is screen on?
	bltu	$t0, 0x080, NoHBlankInt	// no (If bit 8 is off)

	lbu	$t0, 0x7fff($t8)	// Is LCDC Interrupt Enabled?
	andi	$t1, $t0, 0x02
	beqz	$t1, NoHBlankInt

	lbu	$t3, 0x7f0f($t8)	// raise LCDC interrupt flag
	ori	$t1, $t3, 0x02
	sb	$t1, 0x7f0f($t8)
	
	beqz	$t9, NoHBlankInt	// If interrupts are disabled, don't do

	andi	$t1, $t3, 0xFD
	sb	$t1, 0x7f0f($t8)	// Clear LCDC Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, LCDCHPCOk
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, LCDCHPCOk
	subu	$t0, $s7, $a3		// RAM
LCDCHPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x48		// Jump to LCDC interrupt handler

//	*  DRAW FRAME UP TO CURRENT LINE *
	bnez	$v0, NoHBlankInt
	jal	DrawLines

NoHBlankInt:




//****	Update Timer, Do any interrupt

	lbu	$t0, 0x7f07($t8)	// Is timer on?
	andi	$t1, $t0, 0x04
	beqz	$t1, NoTimerInt		// no

	andi	$t1, $t0, 0x02		// Is timer 16.384 KHz?
	bnez	$t1, DoTimerInc		// yes, do increment
	lbu	$t0, regTimer($s1)	// no, toggle timer
	not	$t0
	sb	$t0, regTimer($s1)
	bnez	$t0, NoTimerInt		// if no increment this pass, branch

DoTimerInc:
	lb	$t1, 0x7f05($t8)	// increment TIMA (Timer Counter)
	add	$t1, 1
	sb	$t1, 0x7f05($t8)
	bnez	$t1, NoTimerInt		// if no overflow, no interrupt

	lb	$t0, 0x7f06($t8)	// else, Load TIMA with TMA (Timer Modulo)
	sb	$t0, 0x7f05($t8)

	lbu	$t3, 0x7f0f($t8)	// raise Timer interrupt flag
	ori	$t1, $t3, 0x04
	sb	$t1, 0x7f0f($t8)
	
	beqz	$t9, NoTimerInt		// If interrupts are disabled, don't do

	lbu	$t0, 0x7fff($t8)	// Is Timer Int. Enabled?
	andi	$t0, 0x04
	beqz	$t0, NoTimerInt

	andi	$t1, $t3, 0xFB
	sb	$t1, 0x7f0f($t8)	// Clear Timer Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, TimerPCOk
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, TimerPCOk
	subu	$t0, $s7, $a3		// RAM
TimerPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x50		// Jump to Timer interrupt handler

NoTimerInt:

	lb	$t0, 0x7f41($t8)	// HBlank Mode
	li	$a0, 50			// 51 instruction cycles
	andi	$t0, $t0, 0xFC
	sb	$t0, 0x7f41($t8)

//******	Execute 51 CPU cycles	
	jal	Z80Loop

	lb	$t0, 0x7f04($t8)	// Decrement DivReg
	subu	$t0, $t0, 1
	sb	$t0, 0x7f04($t8)

	addi	$t7, $t7, 1		// Increment Line #
	sb	$t7, 0x7f44($t8)	// Save it

	lbu	$t0, 0x7f41($t8)	// Clear the coincidence flag
	andi	$t1, $t0, 0xFB
	sb	$t1, 0x7f41($t8)

//	andi	$t0, $t1, 0x20		// See if OAM int enabled
//	bnez	$t0, LCDCInt		// Yes

	lbu	$t0, 0x7f45($t8)	// See if coincidence
	bne	$t0, $t7, NoCoincidence

//****	Do LCDC Interrupt
	lbu	$t0, 0x7f40($t8)	// Is screen on?
	bltu	$t0, 0x080, NoCoincidence	// no (If bit 8 is off)

	or	$t1, $t1, 0x04		// Set the coincidence flag
	sb	$t1, 0x7f41($t8)		
	andi	$t0, $t1, 0x40		// Is LCDC coincidence Interrupt enabled?
	beqz	$t0, NoCoincidence

LCDCInt:
//	lbu	$t0, 0x7f40($t8)	// Is screen on?
//	bltu	$t0, 0x080, NoCoincidence	// no (If bit 8 is off)

	lbu	$t0, 0x7fff($t8)	// Is LCDC Interrupt Enabled?
	andi	$t1, $t0, 0x02
	beqz	$t1, NoCoincidence

	lbu	$t3, 0x7f0f($t8)	// raise LCDC interrupt flag
	ori	$t1, $t3, 0x02
	sb	$t1, 0x7f0f($t8)

	beqz	$t9, NoCoincidence	// If interrupts are disabled, don't do

	andi	$t1, $t3, 0xFD
	sb	$t1, 0x7f0f($t8)	// Clear LCDC Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, LCDC2NotHalt
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, LCDC2NotHalt
	subu	$t0, $s7, $a3		// RAM
LCDC2NotHalt:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x48		// Jump to LCDC interrupt handler


//	*  DRAW FRAME UP TO CURRENT LINE *
	bnez	$v0, NoCoincidence
	jal	DrawLines

NoCoincidence:


//****	Update Timer, Do any interrupt

	lbu	$t0, 0x7f07($t8)	// Is timer on?
	andi	$t1, $t0, 0x04
	beqz	$t1, NoTimerInt2	// no

	andi	$t1, $t0, 0x02		// Is timer 16.384 KHz?
	beqz	$t1, NoTimerInt2	// no, branch

	lb	$t1, 0x7f05($t8)	// increment TIMA (Timer Counter)
	add	$t1, 1
	sb	$t1, 0x7f05($t8)
	bnez	$t1, NoTimerInt2	// if no overflow, no interrupt

	lb	$t0, 0x7f06($t8)	// else, Load TIMA with TMA (Timer Modulo)
	sb	$t0, 0x7f05($t8)

	lbu	$t3, 0x7f0f($t8)	// raise Timer interrupt flag
	ori	$t1, $t3, 0x04
	sb	$t1, 0x7f0f($t8)
	
	beqz	$t9, NoTimerInt2	// If interrupts are disabled, don't do

	lbu	$t0, 0x7fff($t8)	// Is Timer Int. Enabled?
	andi	$t0, 0x04
	beqz	$t0, NoTimerInt2

	andi	$t1, $t3, 0xFB
	sb	$t1, 0x7f0f($t8)	// Clear Timer Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, TimerPCOk2
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, TimerPCOk2
	subu	$t0, $s7, $a3		// RAM
TimerPCOk2:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x50		// Jump to Timer interrupt handler

NoTimerInt2:


	bne	$t7, 144, Do144Lines	// Loop for 144 lines (until VBlank)

//	ulw	$t0, ptrLCDScreen($s1)
//	li	$t1, 0xff00ff00
//	usw	$t1, 12720($t0)

//	b	NoDrawFrame

//	*  DRAW FRAME *
	bnez	$v0, NoDrawFrame
	jal	DrawLines

//	*  DRAW ANY REMAINING SPRITES *

	li	$t7, 159
	jal	DrawJustSprites
	li	$t7, 144



//	* Copy Screen Buffer to Screen
	lw	$t2, ptrLCDScreen($s1)
	lw	$t3, ptrScreen($s1)
	addi	$t2, 1280
	addi	$t3, 1408
	li	$a0, 144

LineCopy:
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

	subu	$a0, 1

	addi	$t3, 88
	addi	$t2, 80

	bnez	$a0, LineCopy

//	ulw	$t0, ptrLCDScreen($s1)
//	li	$t1, 0xffff0000
//	usw	$t1, 12720($t0)


NoDrawFrame:


//	*  PLAY SOUNDS  *


//******	In VBLANK	******

	lb	$t0, 0x7f41($t8)	// Set OAM mode to VBlank
	andi	$t0, $t0, 0xFC
	ori	$t0, $t0, 0x01
	sb	$t0, 0x7f41($t8)

	lbu	$t1, 0x7f40($t8)	// Is screen on?
	andi	$t0, $t1, 0x0080
	beqz	$t0, NotEnteringVBlank

	// Don't raise interrupt flag for Bubble Bobble
	ulw	$t0, 0x134($a1)
	li	$t1, 0x42554242		// If Cart name starts with 'BUBB'
	beq	$t0, $t1, NoRaise	// Don't raise
	lbu	$t3, 0x7f0f($t8)
	ori	$t3, $t3, 0x01
	sb	$t3, 0x7f0f($t8)	// raise interrupt flag
NoRaise:
	lbu	$t2, 0x7fff($t8)	// Is VBlank Int. Enabled?
	andi	$t2, $t2, 1
	beqz	$t2, NotEnteringVBlank

	beqz	$t9, NotEnteringVBlank	// If interrupts are disabled

	andi	$t3, $t3, 0xFE		// Clear VBlank Interrupt Flag
	sb	$t3, 0x7f0f($t8)
	li	$t9, 0			// disable Interrupts
	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, VBPCOk
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, VBPCOk
	subu	$t0, $s7, $a3		// RAM
VBPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x40		// Jump to VB interrupt handler

NotEnteringVBlank:

DoVBLine:


//******	Execute 14 CPU cycles	
	li	$a0, 13			// 21 instruction cycles
	jal	Z80Loop

	bne	$t7, 153, VBNotTopFrame	// See if last line
	li	$t7, 0
	sb	$t7, 0x7f44($t8)	// Yes, loop to line 0
	lb	$t0, 0x7f41($t8)	// Clear the coincidence flag
	andi	$t0, $t0, 0xFB
	sb	$t0, 0x7f41($t8)
VBNotTopFrame:

//******	Execute 49 CPU cycles	
	li	$a0, 48			// 21 instruction cycles
	jal	Z80Loop

	lb	$t0, 0x7f04($t8)	// Decrement DivReg
	subu	$t0, $t0, 1
	sb	$t0, 0x7f04($t8)


//****	Serial interrupt
	lbu	$t0, 0x7f02($t8)	// Is serial started?
	blt	$t0, 0x080, VBNoSerialInt	// no (If bit 8 is off)

	andi	$t1, $t0, 0x01		// Is timer external?
	beqz	$t1, VBNoSerialInt	// Yes, and we are not receiving, so continue

	lbu	$t1, regSerTimer($s1)	// decrement Serial Timer
	subu	$t1, 1
	sb	$t1, regSerTimer($s1)
	bnez	$t1, VBNoSerialInt	// If no overflow, continue

	lbu	$t3, 0x7f0f($t8)	// raise Serial interrupt flag
	ori	$t1, $t3, 0x08
	sb	$t1, 0x7f0f($t8)
	
	andi	$t0, 0x7F		// Stop serial
	sb	$t0, 0x7f02($t8)
	li	$t0, 0xFF
	sb	$t0, 0x7f01($t8)	// Set recieved data to FF

	beqz	$t9, VBNoSerialInt	// If interrupts are disabled, don't do

	lbu	$t0, 0x7fff($t8)	// Is Serial Int. Enabled?
	andi	$t0, 0x08
	beqz	$t0, VBNoSerialInt

	andi	$t1, $t3, 0xF7
	sb	$t1, 0x7f0f($t8)	// Clear Serial Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, VBSerPCOk
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, VBSerPCOk
	subu	$t0, $s7, $a3		// RAM
VBSerPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x58		// Jump to Serial interrupt handler

VBNoSerialInt:



//****	Update Timer, do any interrupt
	lbu	$t0, 0x7f07($t8)	// Is timer on?
	andi	$t1, $t0, 0x04
	beqz	$t1, VBNoTimerInt	// no

	andi	$t1, $t0, 0x02		// Is timer 16.384 KHz?
	bnez	$t1, VBDoTimerInc	// yes, do increment
	lbu	$t0, regTimer($s1)	// no, toggle timer
	not	$t0
	sb	$t0, regTimer($s1)
	bnez	$t0, VBNoTimerInt	// if no increment this pass, branch

VBDoTimerInc:
	lb	$t1, 0x7f05($t8)	// increment TIMA (Timer Counter)
	add	$t1, 1
	sb	$t1, 0x7f05($t8)
	bnez	$t1, VBNoTimerInt	// if no overflow, no interrupt

	lb	$t0, 0x7f06($t8)	// else, Load TIMA with TMA (Timer Modulo)
	sb	$t0, 0x7f05($t8)

	lbu	$t3, 0x7f0f($t8)	// raise Timer interrupt flag
	ori	$t1, $t3, 0x04
	sb	$t1, 0x7f0f($t8)
	
	beqz	$t9, VBNoTimerInt	// If interrupts are disabled, don't do

	lbu	$t0, 0x7fff($t8)	// Is Timer Int. Enabled?
	andi	$t0, 0x04
	beqz	$t0, VBNoTimerInt

	andi	$t1, $t3, 0xFB
	sb	$t1, 0x7f0f($t8)	// Clear Timer Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, VBTimerPCOk
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, VBTimerPCOk
	subu	$t0, $s7, $a3		// RAM
VBTimerPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x50		// Jump to Timer interrupt handler

VBNoTimerInt:




//******	Execute 51 CPU cycles	
	li	$a0, 50			// 21 instruction cycles
	jal	Z80Loop


	lb	$t0, 0x7f04($t8)	// Decrement DivReg
	subu	$t0, $t0, 1
	sb	$t0, 0x7f04($t8)

	beqz	$t7, VBLine0		// If Line=0, don't increment
	addi	$t7, $t7, 1		// Increment line#
	sb	$t7, 0x7f44($t8)
VBLine0:

	lbu	$t0, 0x7f41($t8)	// Clear the coincidence flag
	andi	$t1, $t0, 0xFB
	sb	$t1, 0x7f41($t8)

//****	Do LCDC Interrupt
	lbu	$t0, 0x7f40($t8)	// Is screen on?
	blt	$t0, 0x080, VBNoCoincidence	// no (If bit 8 is off)

	or	$t1, $t1, 0x04		// Set the coincidence flag
	sb	$t1, 0x7f41($t8)		
	andi	$t0, $t1, 0x40		// Is LCDC coincidence Interrupt enabled?
	beqz	$t0, VBNoCoincidence

	lbu	$t0, 0x7fff($t8)	// Is LCDC Interrupt Enabled?
	andi	$t1, 0x02
	beqz	$t1, VBNoCoincidence

	lbu	$t3, 0x7f0f($t8)	// raise LCDC interrupt flag
	ori	$t1, $t3, 0x02
	sb	$t1, 0x7f0f($t8)

	beqz	$t9, VBNoCoincidence	// If interrupts are disabled, don't do

	andi	$t1, $t3, 0xFD
	sb	$t1, 0x7f0f($t8)	// Clear LCDC Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, VBLCDC2NotHalt
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, VBLCDC2NotHalt
	subu	$t0, $s7, $a3		// RAM
VBLCDC2NotHalt:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x48		// Jump to LCDC interrupt handler

VBNoCoincidence:



//****	Update Timer, do any interrupt
	lbu	$t0, 0x7f07($t8)	// Is timer on?
	andi	$t1, $t0, 0x04
	beqz	$t1, VBNoTimerInt2	// no

	andi	$t1, $t0, 0x02		// Is timer 16.384 KHz?
	beqz	$t1, VBNoTimerInt2	// no, branch

	lb	$t1, 0x7f05($t8)	// increment TIMA (Timer Counter)
	add	$t1, 1
	sb	$t1, 0x7f05($t8)
	andi	$t1, 0xFF
	bnez	$t1, VBNoTimerInt2	// if no overflow, no interrupt

	lb	$t0, 0x7f06($t8)	// else, Load TIMA with TMA (Timer Modulo)
	sb	$t0, 0x7f05($t8)

	lbu	$t3, 0x7f0f($t8)	// raise Timer interrupt flag
	ori	$t1, $t3, 0x04
	sb	$t1, 0x7f0f($t8)
	
	beqz	$t9, VBNoTimerInt2	// If interrupts are disabled, don't do

	lbu	$t0, 0x7fff($t8)	// Is Timer Int. Enabled?
	andi	$t0, 0x04
	beqz	$t0, VBNoTimerInt2

	andi	$t1, $t3, 0xFB
	sb	$t1, 0x7f0f($t8)	// Clear Timer Interrupt Flag
	li	$t9, 0			// disable Interrupts

	lbu	$t0, ($s7)		// Get current instruction
	seq	$t0, $t0, 0x76		// If =HALT, then set t0=1, else t0=0
	add	$s7, $s7, $t0		// skip to next instruction if Halt

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, VBTimerPCOk2
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, VBTimerPCOk2
	subu	$t0, $s7, $a3		// RAM
VBTimerPCOk2:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	addi	$s7, $a1, 0x50		// Jump to Timer interrupt handler

VBNoTimerInt2:


	bnez	$t7, DoVBLine		// If frame not complete, loop

	bnez	$v0, DispFrameLoop	// do two frames


//	ulw	$t0, ptrLCDScreen($s1)
//	li	$t1, 0xff00ff00
//	usw	$t1, 12720($t0)

EmulRet:





//****	Save Z-80 Registers

	subu	$t0, $s7, $a1		// see if PC in Low ROM
	bltu	$t0, 0x04000, SavePCOk
	subu	$t0, $s7, $a2		// High ROM?
	bltu	$t0, 0x08000, SavePCOk
	subu	$t0, $s7, $a3		// RAM
SavePCOk:
	sh	$t0, regPC($s1)		// Store PC

	subu	$t0, $s2, $a1		// see if SP in Low ROM
	bltu	$t0, 0x4000, SaveSPOk
	subu	$t0, $s2, $a2		// High ROM?
	bltu	$t0, 0x8000, SaveSPOk
	subu	$t0, $s2, $a3		// RAM
SaveSPOk:

	sh	$t0, regSP($s1)		// Store SP

	sll	$s4, $s4, 4		// Get C flag
	sll	$s5, $s5, 7		// Get Z flag
	or	$s4, $s4, $s5
	sb	$s4, regF($s1)		// Store Flags


	sb	$s0, regA($s1)		// Store regA
	
	sb	$t9, regInt($s1)	// Store Interrupts Enabled Flag

//	ulw	$t0, ptrLCDScreen($s1)
//	li	$t1, 0x0000ffff
//	usw	$t1, 12720($t0)

//	jal	DispReg
FrameRet:

// Restore Register Values
	lw	$ra, ($sp)
	lw	$s7, 4($sp)
	lw	$s6, 8($sp)
	lw	$s5, 12($sp)
	lw	$s4, 16($sp)
	lw	$s3, 20($sp)
	lw	$s2, 24($sp)
	lw	$s1, 28($sp)
	lw	$s0, 32($sp)
	lw	$a3, 36($sp)
	lw	$a2, 40($sp)
	lw	$a1, 44($sp)
	lw	$a0, 48($sp)
	lw	$v1, 52($sp)
	lw	$v0, 56($sp)
	add	$sp, $sp, 60

	j	$31			// Exit Emulate


























//  DISPLAY z-80 REGISTER VALUES

DispReg:

	subu	$sp, $sp, 48 
	sw	$s6, 44($sp)
	sw	$v0, 40($sp)
	sw	$v1, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a2, 24($sp)
	sw	$a3, 20($sp)
	sw	$t9, 16($sp)
	sw	$t8, 12($sp)
	sw	$t7, 8($sp)
	sw	$t6, 4($sp)
	sw	$ra, ($sp)

	subu	$sp, $sp, 4		// Get 4 bytes for strings

	sb	$a0, regA($s1)		// Store regA

	lbu	$a0, SelKey($s1)
	sll	$a0, $a0, 8
	or	$t8, $s0, $a0
	move	$a0, $sp
	move	$s6, $a1

	// SP
	subu	$t0, $s2, $a1		// see if SP in Low ROM
	bltu	$t0, 0x4000, DispSPOk
	subu	$t0, $s2, $a2		// High ROM?
	bltu	$t0, 0x8000, DispSPOk
	subu	$t0, $s2, $a3		// RAM
DispSPOk:

	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000080
	li	$a3,0x00000098
	jal	WriteString

	// PC
	subu	$t0, $s7, $s6
	bltu	$t0, 0x4000, DPCok
	lw	$t0, ptrCurRom($s1)
	subu	$t0, 0x4000
	subu	$t0, $s7, $t0
	bltu	$t0, 0x08000, DPCok
	lw	$t8, 16($sp)
	subu	$t0, $s7, $t8
DPCok:
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000080
	li	$a3,0x00000090
	jal	WriteString


	//Next 4 bytes
	ulhu	$t0, ($s7)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000004
	li	$a3,0x00000090
	jal	WriteString
	

	// RegA
	move	$t0, $s0
	sll	$t0, 8
	sll	$t1, $s4, 4		// Get C flag
//	or	$t0, $t0, $t1
	sll	$t1, $s5, 7		// Get Z flag
//	or	$t0, $t0, $t1
	lbu	$t1, regA($s1)
	or	$t0, $t0, $t1

	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000004
	li	$a3,0x00000098
	jal	WriteString


//	j	DISPRET

	// BC
	lhu	$t0, ($s1)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000020
	li	$a3,0x00000098
	jal	WriteString

	// DE
	lhu	$t0, 2($s1)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000040
	li	$a3,0x00000098
	jal	WriteString

	// HL
	lhu	$t0, 4($s1)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000060
	li	$a3,0x00000098
	jal	WriteString



	// FF00-FFxx
	lw	$t8, 16($sp)
	lhu	$t0, 0x7f0e($t8)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000004
	li	$a3,0x00000088
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x7f40($t8)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000018
	li	$a3,0x00000088
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x7f42($t8)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x0000002C
	li	$a3,0x00000088
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x7f44($t8)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000040
	li	$a3,0x00000088
	jal	WriteString

	lw	$t8, 16($sp)
	lbu	$t0, 0x7f4a($t8)
	sll	$t1, $t9, 8
	or	$t0, $t0, $t1
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000054
	li	$a3,0x00000088
	jal	WriteString

	lw	$t8, 16($sp)
	lbu	$t0, 0x7fff($t8)
	sll	$t0, $t0, 8
	or	$t0, $t0, $t9
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000068
	li	$a3,0x00000088
	jal	WriteString


//	j	DISPRET

	// 8000-80xx
	lw	$t8, 16($sp)
	lhu	$t0, 0x01ea($s6)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000004
	li	$a3,0x00000080
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x01ec($s6)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000018
	li	$a3,0x00000080
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x01ee($s6)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x0000002C
	li	$a3,0x00000080
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x01f0($s6)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000040
	li	$a3,0x00000080
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x01f2($s6)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000054
	li	$a3,0x00000080
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x01f4($s6)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x00000068
	li	$a3,0x00000080
	jal	WriteString

	lw	$t8, 16($sp)
	lhu	$t0, 0x01f6($s6)
	jal	HextoStr		// Converts 2 byte-value to string, stores in ($a0) to 3($a0)
	li	$v0,0x00000000
	li	$a1,0x00000004
	li	$a2,0x0000007c
	li	$a3,0x00000080
	jal	WriteString

DISPRET:
	add	$sp, $sp, 4

// Restore Register Values
	lw	$ra, ($sp)
	lw	$t6, 4($sp)
	lw	$t7, 8($sp)
	lw	$t8, 12($sp)
	lw	$t9, 16($sp)
	lw	$a3, 20($sp)
	lw	$a2, 24($sp)
	lw	$a1, 28($sp)
	lw	$a0, 32($sp)
	lw	$v1, 36($sp)
	lw	$v0, 40($sp)
	lw	$s6, 44($sp)
	add	$sp, $sp, 48

	j	$ra


// Converts 2-byte Hex  value to 4 byte String
// $t0 = hex value
// $a0 = pointer to 4 byte string

HextoStr:
	andi	$t1, $t0, 0x000F
	addi	$t1, $t1, 48
	blt	$t1, 58, NibOk
	addi	$t1, $t1, 7
NibOk:
	sb	$t1, 3($a0)

	andi	$t1, $t0, 0x00F0
	srl	$t1, $t1, 4
	addi	$t1, $t1, 48
	blt	$t1, 58, NibOk1
	addi	$t1, $t1, 7
NibOk1:
	sb	$t1, 2($a0)

	andi	$t1, $t0, 0x0F00
	srl	$t1, $t1, 8
	addi	$t1, $t1, 48
	blt	$t1, 58, NibOk2
	addi	$t1, $t1, 7
NibOk2:
	sb	$t1, 1($a0)

	andi	$t1, $t0, 0xF000
	srl	$t1, $t1, 12
	addi	$t1, $t1, 48
	blt	$t1, 58, NibOk3
	addi	$t1, $t1, 7
NibOk3:
	sb	$t1, ($a0)
	j	$ra


// WRITE STRING
// $a0 = pointer to string
// $a1 = # of bytes
// $a2 = x
// $a3 = y
// $v0 = method

WriteString:
// Save registers to stack
	subu	$sp, $sp, 88
	sw	$ra, 84($sp)
	sw	$v0, 80($sp)
	sw	$v1, 76($sp)
	sw	$t0, 72($sp)
	sw	$t1, 68($sp)
	sw	$t2, 64($sp)
	sw	$t3, 60($sp)
	sw	$t4, 56($sp)
	sw	$t5, 52($sp)
	sw	$t6, 48($sp)
	sw	$t7, 44($sp)
	sw	$t8, 40($sp)
	sw	$t9, 36($sp)
	sw	$s0, 32($sp)
	sw	$s1, 28($sp)
	sw	$s2, 24($sp)
	sw	$s3, 20($sp)
	sw	$s4, 16($sp)
	sw	$s5, 12($sp)
	sw	$s6, 8($sp)
	sw	$s7, 4($sp)
	sw	$a0, ($sp)

	subu	$sp, 32
	.set	noreorder
	.set	nomacro
	jal	GfxDrawString
	sw	$v0,16($sp)
	.set	macro
	.set	reorder
	add	$sp, 32

// Restore Register Values
	lw	$a0, ($sp)
	lw	$s7, 4($sp)
	lw	$s6, 8($sp)
	lw	$s5, 12($sp)
	lw	$s4, 16($sp)
	lw	$s3, 20($sp)
	lw	$s2, 24($sp)
	lw	$s1, 28($sp)
	lw	$s0, 32($sp)
	lw	$t9, 36($sp)
	lw	$t8, 40($sp)
	lw	$t7, 44($sp)
	lw	$t6, 48($sp)
	lw	$t5, 52($sp)
	lw	$t4, 56($sp)
	lw	$t3, 60($sp)
	lw	$t2, 64($sp)
	lw	$t1, 68($sp)
	lw	$t0, 72($sp)
	lw	$v1, 76($sp)
	lw	$v0, 80($sp)
	lw	$ra, 84($sp)
	add	$sp, $sp, 88
	j	$ra

	.end	EmulateFrame
