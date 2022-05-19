/*
|* @(|)z80.asm
|*
|* Copyright 2000, Aaron Ardiri     (mailto:aaron@ardiri.com)
|*                 Michael Ethetton (mailto:methetton@gambitstudios.com)
|* All rights reserved
|* 
|* This file was generated as part of the "liberty" program developed for 
|* the Palm Computing Platform designed by Palm: http://www.palm.com/ 
|*
|* The contents of this file is confidential and proprietrary in nature 
|* ("Confidential Information"). Redistribution or modification without 
|* prior consent of the original author(s) is prohibited.
|*
|* NOTE:
|* The following portions of code found within this source code file are
|* owned exclusively by Michael Ethetton, and shall not be used in or
|* sold to other projects (internal or external) without the written
|* permission of Michael Ethetton.
|*
|* - z-80 CPU Emulation
|* - Nintendo Gameboy Emulation System
|*
|* The following portions of code found within this source code file are
|* owned exclusively by Aaron Ardiri, and shall not be used in or 
|* sold to other projects (internal or external) without the written 
|* permission of Aaron Ardiri.
|*
|* - GNU prc-tools 2.0 application framework
|* - Help System 
|* - Device Configuration Module
|* - Multiple Code Segments Solution
|*
|* It shall be noted that Aaron Ardiri has licensed the above source code
|* and framework to Michael Ethetton for use only in the "liberty" project.
*/

/*
* PRE-REQUIREMENTS:
* =================
*
*  $0 - 0
*  at - used by assembler
*  v0 - 
*  v1 -
*  a0 - instruction counter (# of instructions to execute)
*  a1 - romoffset 0 ptr
*  a2 - current ROM page ptr (-0x4000 to allow for address values)
*  a3 - ramoffset ptr (-0x8000 to allow for address values)

*  t0-t5 - available for temp. use
*  t6 - pointer for zWrite table
*  t7 - Current Line #

*  s0 - A
*  s1 - Pointer to Register chunk (BC, DE, HL)
*  s2 - SP
*  s3 - PC (will be outdated during processing)
*  s4 - C flag
*  s5 - Z flag
*  s6 - pointer to lookup tables (zOP)
*  s7 - current read address  (current PC + ram/rom offset)

*  t8 - RAM ptr (to actual RAM start)
*  t9 - Interrupts Enabled Flag

*  k0 - reserved by OS
*  k1 - reserved by OS
*  gp - pointer to global
*  sp - stack pointer
*  fp - frame pointer
*  ra - return address
*/


/*
* z-80 instruction loop
*/


zt:
	j	zt

//Z80 Emu

Z80Loop:
DoNext:
/*
	subu	$t0, $s7, $a1
	bltu	$t0, 0x4000, pctok
	subu	$t0, $s7, $a2
pctok:	
	bne	$t0, 0x4403, zz
	subu	$sp, $sp, 4
	sw	$ra, ($sp)
	jal	DispReg
	lw	$ra, ($sp)
	add	$sp, $sp, 4
zty:
	j	zty
*/
zz:
	lbu	$t0, ($s7)		// Get next instruction
	addi	$s7, 1
	sll	$t0, $t0, 2		// x4 to get lookup
	add	$t1, $t0, $s6		// get address of code for instruction
	lw	$t1, ($t1)
	jr	$t1			// do instruction


/*
 * z-80 instructions
 */

// NOP
z00:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD BC,nnnn
z01:
	ulhu	$t3, ($s7)
	addi	$s7, 2
	sh	$t3, regBC($s1)
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD (BC),A
z02:
	lhu	$t2, regBC($s1)		// Address to write to
	move	$t3, $s0		// Value to write
	subu	$a0, 2			// decrement instruction counter
	j	zWrite

// INC BC
z03:                                                    
	lhu	$t3, regBC($s1)		// Load BC
	subu	$a0, 2			// decrement instruction counter
	add	$t3, 1
	sh	$t3, regBC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC B
z04:
	lb	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t3, 1
	sb	$t3, regB($s1)
	sltiu	$s5, $t3, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC B
z05:
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$t3, 1
	sb	$t3, regB($s1)
	sltiu	$s5, $t3, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD B,nn
z06:
	lbu	$t3, ($s7)
	subu	$a0, 2			// decrement instruction counter
	sb	$t3, regB($s1)		// Save B
	add	$s7, 1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RLCA
z07:
	srl	$s4, $s0, 7		// Set or clear C
	sll	$s0, $s0, 1
	move	$s5, $zero		// Clear Z
	or	$s0, $s0, $s4		// get carry
	subu	$a0, 1			// decrement instruction counter
	andi	$s0, 0x00FF
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD (nnnn),SP  ---- special (old ex af,af)
z08:
	ulhu	$t2, ($s7)

	bltu	$t2, 0x08000, z08Cont	// Can't write to ROM

	subu	$t0, $s2, $a1		// see if SP in Low ROM
	bltu	$t0, 0x4000, z08SPOk
	subu	$t0, $s2, $a2		// High ROM?
	bltu	$t0, 0x8000, z08SPOk
	subu	$t0, $s2, $a3		// RAM
z08SPOk:
	add	$t2, $t2, $a3
	ush	$t0, ($t2)		// Save the Stack pointer

z08Cont:
	add	$s7, 2
	subu	$a0, 5			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra




// ADD HL,BC
z09:
	lhu	$t0, regBC($s1)
	lhu	$t1, regHL($s1)
	subu	$a0, 3			// decrement instruction counter
	add	$t1, $t1, $t0
	sh	$t1, regHL($s1)
	sgtu	$s4, $t1, 0x00FFFF	// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD A,(BC)
z0A:
	lhu	$t2, regBC($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z0AROM	// See if ROM
	bltu	$t2, 0xE000, z0ARAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z0ARAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z0ARAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z0AROM:
	bltu	$t2, 0x4000, z0ALowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z0ALowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC BC
z0B:
	lhu	$t1, regBC($s1)		// Load BC
	subu	$a0, 2			// decrement instruction counter
	subu	$t1, 1 
	sh	$t1, regBC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC C
z0C:
	lb	$t1, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t1, 1
	sb	$t1, regC($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC C
z0D:
	lbu	$t1, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$t1, 1
	sb	$t1, regC($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD C,nn
z0E:
	lb	$t0, ($s7)
	add	$s7, 1
	sb	$t0, regC($s1)		// Load C
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RRCA
z0F:
	andi	$s4, $s0, 0x01		// Set or clear C
        srl	$s0, $s0, 1
	sll	$t0, $s4, 7		// get rotated bit
	or	$s0, $s0, $t0
	move	$s5, $zero		// Clear Z
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// STOP
z10:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD DE,nnnn
z11:
	ulhu	$t2, ($s7)
	addi	$s7, 2
	sh	$t2, regDE($s1)
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD (DE),A
z12:
	lhu	$t2, regDE($s1)		// Address to write to
	move	$t3, $s0		// Value to write
	subu	$a0, 2			// decrement instruction counter
	j	zWrite



// INC DE
z13:
	lhu	$t1, regDE($s1)		// Load DE
	subu	$a0, 2			// decrement instruction counter
	add	$t1, 1 
	sh	$t1, regDE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC D
z14:
	lb	$t1, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t1, 1
	sb	$t1, regD($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC D
z15:
	lbu	$t1, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$t1, 1
	sb	$t1, regD($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD D,nn
z16:
	lb	$t0, ($s7)
	add	$s7, 1
	sb	$t0, regD($s1)		// Load D
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RLA
z17:
	srl	$t0, $s0, 7		// get rotate bit
        sll	$s0, $s0, 1
	or	$s0, $s0, $s4		// get carry
	move	$s4, $t0		// Set or clear C
	move	$s5, $zero		// Clear Z
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JR
z18:
	lb	$t3, ($s7)		// get displacement
	add	$s7, $s7, $t3		// jump
	add	$s7, 1
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// ADD HL,DE
z19:
	lhu	$t0, regDE($s1)
	lhu	$t1, regHL($s1)
	add	$t1, $t1, $t0
	sh	$t1, regHL($s1)
	sgtu	$s4, $t1, 0xFFFF	// Set or clear C
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD A,(DE)
z1A:
	lhu	$t2, regDE($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z1AROM	// See if ROM
	bltu	$t2, 0xE000, z1ARAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z1ARAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z1ARAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z1AROM:
	bltu	$t2, 0x4000, z1ALowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z1ALowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC DE
z1B:
	lh	$t1, regDE($s1)		// Load DE
	subu	$a0, 2			// decrement instruction counter
	subu	$t1, 1 
	sh	$t1, regDE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC E
z1C:
	lb	$t1, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t1, 1
	sb	$t1, regE($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC E
z1D:
	lb	$t1, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$t1, 1
	sb	$t1, regE($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD E,nn
z1E:
	lb	$t0, ($s7)
	subu	$a0, 2			// decrement instruction counter
	sb	$t0, regE($s1)		// Load E
	add	$s7, 1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RRA
z1F:
	sll	$t1, $s4, 7		// get Carry to bit 7
	andi	$s4, $s0, 0x01		// Set or clear Carry
	srl	$s0, $s0, 1		// rotate
	or	$s0, $s0, $t1		// get the carry bit
	move	$s5, $zero		// Clear Z
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JR NZ,disp
z20:
	bnez	$s5, z20NoJump		// only jump if Z reset (0)
	lb	$t3, ($s7)		// get displacement
	add	$s7, $s7, $t3		// jump
z20NoJump:
	add	$s7, 1
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD HL,nnnn
z21:
	ulhu	$t2, ($s7)
	subu	$a0, 3			// decrement instruction counter
	sh	$t2, regHL($s1)
	add	$s7, 2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LDI  (HL),A --- special (old remapped ld (nnnn),hl)
z22:
	lhu	$t2, regHL($s1)		// get address
	move	$t3, $s0		// get value
	add	$t1, $t2, 1		// Inc HL
	sh	$t1, regHL($s1)		// store it
	subu	$a0, 2			// decrement instruction counter
	j	zWrite



// INC HL
z23:
	lhu	$t1, regHL($s1)		// Load HL
	subu	$a0, 2			// decrement instruction counter
	add	$t1, 1 
	sh	$t1, regHL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC H
z24:
	lb	$t1, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t1, 1
	sb	$t1, regH($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC H
z25:
	lbu	$t1, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$t1, 1
	sb	$t1, regH($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD H,nn
z26:
	lb	$t0, ($s7)
	subu	$a0, 2			// decrement instruction counter
	sb	$t0, regH($s1)		// Load H
	add	$s7, 1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DAA
z27:
	lbu	$t1, regA_old($s1)	// get old A
	subu	$a0, 1			// decrement instruction counter

	beqz	$s4, z27NoCarry


	bltu	$t1, $s0, z27sub	// if old was smaller, was subtract
	
z27add:	
	andi	$t0, $s0, 0x0F		// check low digit
	andi	$t2, $t1, 0x0F
	bltu	$t0, $t2, z27alofix
	bltu	$t0, 0x0A, z27ahi
z27alofix:
	addu	$s0, 0x06		// if over, balance

z27ahi:
	li	$s4, 0			// clear C
	bltu	$s0, $t1, z27ahifix	// check high digit
	bltu	$s0, 0xA0, z27cont
	
z27ahifix:
	addu	$s0, 0x06
	andi	$s0, 0xFF
	li	$s4, 1			// set C
z27cont:
	sltiu	$s5, $s0, 1		// set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	

z27NoCarry:	
	bltu	$t1, $s0, z27add	// if old was smaller, was add


z27sub:
	subu	$t2, $t1, $s0		// get sub operand to t2
	andi	$t0, $t1, 0x0F		// check low digit
	andi	$t3, $t2, 0x0F
	bleu	$t3, $t0, z27slofix
	subu	$t1, 0x06		// carry digit
z27slofix:
	subu	$t1, $t1, $t3

z27shi:
	beqz	$s4, z27shifix		// check high digit
	addu	$t1, $t1, 0xa0
z27shifix:
	andi	$t2, $t2, 0xF0
	subu	$s0, $t1, $t2

z27scont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JR Z,disp
z28:
	beqz	$s5, z28NoJump		// only jump if Z set (1)
	lb	$t3, ($s7)		// get displacement
	add	$s7, $s7, $t3		// jump
z28NoJump:
	add	$s7, 1
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// ADD HL,HL
z29:
	lhu	$t1, regHL($s1)
	subu	$a0, 3			// decrement instruction counter
	add	$t1, $t1, $t1
	sh	$t1, regHL($s1)
	sgtu	$s4, $t1, 0xFFFF	// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LDI A,(HL)
z2A:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	add	$t1, $t2, 1		// increment HL
	sh	$t1, regHL($s1)
	bltu	$t2, 0x8000, z2AROM	// See if ROM
	bltu	$t2, 0xE000, z2ARAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z2ARAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z2ARAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z2AROM:
	bltu	$t2, 0x4000, z2ALowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z2ALowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// DEC HL
z2B:
	lh	$t1, regHL($s1)		// Load HL
	subu	$a0, 2			// decrement instruction counter
	subu	$t1, 1 
	sh	$t1, regHL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC L
z2C:
	lb	$t1, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t1, 1
	sb	$t1, regL($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC L
z2D:
	lbu	$t1, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$t1, 1
	sb	$t1, regL($s1)
	sltiu	$s5, $t1, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD L,nn
z2E:
	lb	$t0, ($s7)
	subu	$a0, 2			// decrement instruction counter
	sb	$t0, regL($s1)		// Load E
	add	$s7, 1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// CPL
z2F:
	not	$t0, $s0
	andi	$s0, $t0, 0x00FF
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JR NC,disp
z30:
	bnez	$s4, z30NoJump		// only jump if C reset (0)
	lb	$t3, ($s7)		// get displacement
	add	$s7, $s7, $t3		// jump
z30NoJump:
	add	$s7, 1
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD SP,nnnn
z31:
	ulhu	$s2, ($s7)
	subu	$a0, 3			// decrement instruction counter
	add	$s7, 2

	bltu	$s2, 0x08000, z31ROM	// See if ROM
	add	$s2, $s2, $a3
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z31ROM:
	bltu	$s2, 0x4000, z31LowROM	// If ROM page 0
	add	$s2, $s2, $a2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z31LowROM:
	add	$s2, $s2, $a1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LDD  (HL),A --- special (old remapped ld (nnnn),a)
z32:
	lhu	$t2, regHL($s1)		// get address
	move	$t3, $s0		// get value
	subu	$t1, $t2, 1		// Dec HL
	sh	$t1, regHL($s1)		// store it
	subu	$a0, 2			// decrement instruction counter
	j	zWrite


// INC  SP
z33:
	add	$s2, 1
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC  (HL)
z34:
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z34ROM	// See if ROM
	bltu	$t2, 0xE000, z34RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z34RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z34RAM:
	add	$t0, $t2, $a3		// RAM read
	lb	$t3, ($t0)
	add	$t3, 1			// increment
	sltiu	$s5, $t3, 1		// Set or clear Z
	j	zWrite
z34ROM:
	bltu 	$t2, 0x4000, z34LowROM	// See if Low ROM
	add	$t0, $t2, $a2		// ROM read
	lb	$t3, ($t0)
	add	$t3, 1			// increment
	sltiu	$s5, $t3, 1		// Set or clear Z
	j	zWrite
z34LowROM:
	add	$t0, $t2, $a1		// ROM0 read
	lb	$t3, ($t0)
	add	$t3, 1			// increment
	sltiu	$s5, $t3, 1		// Set or clear Z
	j	zWrite



// DEC  (HL)
z35:
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z35ROM	// See if ROM
	bltu	$t2, 0xE000, z35RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z35RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z35RAM:
	add	$t0, $t2, $a3		// RAM read
	lbu	$t3, ($t0)
	subu	$t3, 1			// decrement
	sltiu	$s5, $t3, 1		// Set or clear Z
	j	zWrite
z35ROM:
	bltu	$t2, 0x4000, z35LowROM	// See if Low ROM
	add	$t0, $t2, $a2		// ROM read
	lbu	$t3, ($t0)
	subu	$t3, 1			// decrement
	sltiu	$s5, $t3, 1		// Set or clear Z
	j	zWrite
z35LowROM:
	add	$t0, $t2, $a1		// ROM0 read
	lbu	$t3, ($t0)
	subu	$t3, 1			// decrement
	sltiu	$s5, $t3, 1		// Set or clear Z
	j	zWrite




// LD  (HL), nn
z36:
	lhu	$t2, regHL($s1)		// Get Address
	lbu	$t3, ($s7)		// Get Value
	add	$s7, 1
	subu	$a0, 3			// decrement instruction counter
	j	zWrite


// SCF
z37:
	li	$s4, 1			// Set C
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JR  C,disp
z38:
	beqz	$s4, z38NoJump		// only jump if C set (1)
	lb	$t3, ($s7)		// get displacement
	add	$s7, $s7, $t3		// jump
z38NoJump:
	add	$s7, 1
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// ADD  HL, SP
z39:
	lhu	$t1, regHL($s1)
	subu	$t0, $s2, $a1		// see if SP in Low ROM
	bltu	$t0, 0x4000, z39SPOk
	subu	$t0, $s2, $a2		// High ROM?
	bltu	$t0, 0x8000, z39SPOk
	subu	$t0, $s2, $a3		// RAM
z39SPOk:
	add	$t1, $t1, $t0
	sh	$t1, regHL($s1)
	sgtu	$s4, $t1, 0xFFFF	// Set or clear C
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LDD A,(HL)
z3A:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	subu	$t1, $t2, 1		// decrement HL
	sh	$t1, regHL($s1)
	bltu	$t2, 0x8000, z3AROM	// See if ROM
	bltu	$t2, 0xE000, z3ARAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z3ARAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z3ARAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z3AROM:
	bltu	$t2, 0x4000, z3ALowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z3ALowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC  SP
z3B:
	subu	$s2, 1 
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// INC A
z3C:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	addi	$s0, 1
	andi	$s0, $s0, 0x00FF
	sltiu	$s5, $s0, 1		// Set or clear Z
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// DEC A
z3D:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	subu	$s0, 1
	andi	$s0, $s0, 0x00FF
	sltiu	$s5, $s0, 1		// Set or clear Z
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD A,nn
z3E:
	lbu	$s0, ($s7)
	add	$s7, 1
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// CCF
z3F:
	sltiu	$s4, $s4, 1		// Complement Carry
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  B,B
z40:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  B,C
z41:
	lb	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  B,D
z42:
	lb	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  B,E
z43:
	lb	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  B,H
z44:
	lb	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  B,L
z45:
	lb	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD B,(HL)
z46:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z46ROM	// See if ROM
	bltu	$t2, 0xE000, z46RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z46RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z46RAM:
	add	$t2, $t2, $a3		// RAM read
	lb	$t3, ($t2)
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z46ROM:
	bltu	$t2, 0x4000, z46LowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lb	$t3, ($t2)
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z46LowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lb	$t3, ($t2)
	sb	$t3, regB($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  B,A
z47:
	sb	$s0, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  C,B
z48:
	lb	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  C,C
z49:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  B,D
z4A:
	lb	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  C,E
z4B:
	lb	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  C,H
z4C:
	lb	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  C,L
z4D:
	lb	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD C,(HL)
z4E:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z4EROM	// See if ROM
	bltu	$t2, 0xE000, z4ERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z4ERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z4ERAM:
	add	$t2, $t2, $a3		// RAM read
	lb	$t3, ($t2)
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z4EROM:
	bltu	$t2, 0x4000, z4ELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lb	$t3, ($t2)
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z4ELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lb	$t3, ($t2)
	sb	$t3, regC($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  C,A
z4F:
	sb	$s0, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  D,B
z50:
	lb	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  D,C
z51:
	lb	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  D,D
z52:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  D,E
z53:
	lb	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  D,H
z54:
	lb	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  D,L
z55:
	lb	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD D,(HL)
z56:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z56ROM	// See if ROM
	bltu	$t2, 0xE000, z56RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z56RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z56RAM:
	add	$t2, $t2, $a3		// RAM read
	lb	$t3, ($t2)
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z56ROM:
	bltu	$t2, 0x4000, z56LowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lb	$t3, ($t2)
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z56LowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lb	$t3, ($t2)
	sb	$t3, regD($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  D,A
z57:
	sb	$s0, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  E,B
z58:
	lb	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  E,C
z59:
	lb	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  E,D
z5A:
	lb	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  E,E
z5B:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  E,H
z5C:
	lb	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  E,L
z5D:
	lb	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD E,(HL)
z5E:
	lhu	$t2, regHL($s1)
	subu	$a0, 1			// decrement instruction counter
	bltu	$t2, 0x8000, z5EROM	// See if ROM
	bltu	$t2, 0xE000, z5ERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z5ERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z5ERAM:
	add	$t2, $t2, $a3		// RAM read
	lb	$t3, ($t2)
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z5EROM:
	bltu	$t2, 0x4000, z5ELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lb	$t3, ($t2)
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z5ELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lb	$t3, ($t2)
	sb	$t3, regE($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  E,A
z5F:
	sb	$s0, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  H,B
z60:
	lb	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  H,C
z61:
	lb	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  H,D
z62:
	lb	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  H,E
z63:
	lb	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  H,H
z64:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  H,L
z65:
	lb	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD H,(HL)
z66:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z66ROM	// See if ROM
	bltu	$t2, 0xE000, z66RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z66RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z66RAM:
	add	$t2, $t2, $a3		// RAM read
	lb	$t3, ($t2)
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z66ROM:
	bltu	$t2, 0x4000, z66LowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lb	$t3, ($t2)
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z66LowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lb	$t3, ($t2)
	sb	$t3, regH($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  H,A
z67:
	sb	$s0, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  L,B
z68:
	lb	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  L,C
z69:
	lb	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  L,D
z6A:
	lb	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  L,E
z6B:
	lb	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  L,H
z6C:
	lb	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  L,L
z6D:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD L,(HL)
z6E:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z6EROM	// See if ROM
	bltu	$t2, 0xE000, z6ERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z6ERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z6ERAM:
	add	$t2, $t2, $a3		// RAM read
	lb	$t3, ($t2)
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z6EROM:
	bltu	$t2, 0x4000, z6ELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lb	$t3, ($t2)
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z6ELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lb	$t3, ($t2)
	sb	$t3, regL($s1)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  L,A
z6F:
	sb	$s0, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  (HL),B
z70:
	lbu	$t3, regB($s1)		// Get value
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	j	zWrite



// LD  (HL),C
z71:
	lbu	$t3, regC($s1)		// Get value
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	j	zWrite


// LD  (HL),D
z72:
	lbu	$t3, regD($s1)		// Get value
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	j	zWrite


// LD  (HL),E
z73:
	lbu	$t3, regE($s1)		// Get value
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	j	zWrite


// LD  (HL),H
z74:
	lbu	$t3, regH($s1)		// Get value
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	j	zWrite


// LD  (HL),L
z75:
	lbu	$t3, regL($s1)		// Get value
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	j	zWrite


// HALT
z76:
	beqz	$t9, z76NoInt		// If interrupts disabled, continue
	subu	$s7, 1			//  else, Keep PC at Halt until Interrupt occurs
	jr	$ra			// Immediate exit

z76NoInt:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  (HL),A
z77:
	move	$t3, $s0		// Get value
	lhu	$t2, regHL($s1)		// Get Address
	subu	$a0, 2			// decrement instruction counter
	j	zWrite


// LD  A, B
z78:
	lbu	$s0, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  A, C
z79:
	lbu	$s0, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  A, D
z7A:
	lbu	$s0, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  A, E
z7B:
	lbu	$s0, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  A, H
z7C:
	lbu	$s0, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  A, L
z7D:
	lbu	$s0, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD  A, (HL)
z7E:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z7EROM	// See if ROM
	bltu	$t2, 0xE000, z7ERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z7ERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z7ERAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z7EROM:
	bltu	$t2, 0x4000, z7ELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z7ELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// LD  A, A
z7F:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// ADD  A, B
z80:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  A, C
z81:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  A, D
z82:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  A, E
z83:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  A, H
z84:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  A, L
z85:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  A, (HL)
z86:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z86ROM	// See if ROM
	bltu	$t2, 0xE000, z86RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z86RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z86RAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z86ROM:
	bltu	$t2, 0x4000, z86LowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z86LowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
	add	$t0, $s0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  A, A
z87:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	add	$t0, $s0, $s0
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, B
z88:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$s0, $s0, $t3
	add	$t0, $s0, $s4		// add in Carry
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, C
z89:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$s0, $s0, $t3
	add	$t0, $s0, $s4		// add in Carry
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, D
z8A:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$s0, $s0, $t3
	add	$t0, $s0, $s4		// add in Carry
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, E
z8B:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$s0, $s0, $t3
	add	$t0, $s0, $s4		// add in Carry
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, H
z8C:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$s0, $s0, $t3
	add	$t0, $s0, $s4		// add in Carry
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, L
z8D:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	add	$s0, $s0, $t3
	add	$t0, $s0, $s4		// add in Carry
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, (HL)
z8E:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z8EROM	// See if ROM
	bltu	$t2, 0xE000, z8ERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z8ERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z8ERAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
	add	$t0, $s0, $s4		// add in Carry
	add	$t0, $t0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z8EROM:
	bltu	$t2, 0x4000, z8ELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
	add	$t0, $s0, $s4		// add in Carry
	add	$t0, $t0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z8ELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
	add	$t0, $s0, $s4		// add in Carry
	add	$t0, $t0, $t3
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, A
z8F:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	add	$s0, $s0, $s0
	add	$t0, $s0, $s4		// add in Carry
	andi	$s0, $t0, 0x00FF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SUB  A, B
z90:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SUB  A, C
z91:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SUB  A, D
z92:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SUB  A, E
z93:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SUB  A, H
z94:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SUB  A, L
z95:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SUB  A, (HL)
z96:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z96ROM	// See if ROM
	bltu	$t2, 0xE000, z96RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z96RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z96RAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z96ROM:
	bltu	$t2, 0x4000, z96LowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z96LowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SUB  A, A
z97:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	subu	$s0, $s0, $s0
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, B
z98:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	subu	$s0, $s0, $s4		// SUB in Carry
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, C
z99:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	subu	$s0, $s0, $s4		// SUB in Carry
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, D
z9A:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	subu	$s0, $s0, $s4		// SUB in Carry
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, E
z9B:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	subu	$s0, $s0, $s4		// SUB in Carry
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, H
z9C:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	subu	$s0, $s0, $s4		// SUB in Carry
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, L
z9D:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	subu	$s0, $s0, $t3
	subu	$s0, $s0, $s4		// SUB in Carry
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, (HL)
z9E:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, z9EROM	// See if ROM
	bltu	$t2, 0xE000, z9ERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, z9ERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
z9ERAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
	subu	$s0, $s0, $s4		// sub in Carry
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z9EROM:
	bltu	$t2, 0x4000, z9ELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
	subu	$s0, $s0, $s4		// subu in Carry
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
z9ELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
	subu	$s0, $s0, $s4		// sub in Carry
	subu	$s0, $s0, $t3
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, A
z9F:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	subu	$s0, $zero, $s4		// sub in Carry
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// AND  A, B
zA0:
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// AND  A, C
zA1:
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// AND  A, D
zA2:
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// AND  A, E
zA3:
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// AND  A, H
zA4:
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// AND  A, L
zA5:
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// AND  A, (HL)
zA6:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, zA6ROM	// See if ROM
	bltu	$t2, 0xE000, zA6RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zA6RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zA6RAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zA6ROM:
	bltu	$t2, 0x4000, zA6LowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	and	$s0, $s0, $t3
	sltiu	$s5, $s0, 1		// Set or clear Z
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zA6LowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	and	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// AND  A, A
zA7:
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, B
zA8:
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	xor	$s0, $s0, $t3
	sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, C
zA9:
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	xor	$s0, $s0, $t3
	sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, D
zAA:
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	xor	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, E
zAB:
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	xor	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, H
zAC:
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	xor	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, L
zAD:
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	xor	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, (HL)
zAE:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, zAEROM	// See if ROM
	bltu	$t2, 0xE000, zAERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zAERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zAERAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	xor	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zAEROM:
	bltu	$t2, 0x4000, zAELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	xor	$s0, $s0, $t3
	sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zAELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	xor	$s0, $s0, $t3
	sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A
zAF:
	li	$s0, 0
	li	$s5, 1			// Set Z
	li	$s4, 0			// Clear C
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// OR  A, B
zB0:
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// OR  A, C
zB1:
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// OR  A, D
zB2:
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// OR  A, E
zB3:
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// OR  A, H
zB4:
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// OR  A, L
zB5:
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// OR  A, (HL)
zB6:
	lhu	$t2, regHL($s1)
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, zB6ROM	// See if ROM
	bltu	$t2, 0xE000, zB6RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zB6RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zB6RAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zB6ROM:
	bltu	$t2, 0x4000, zB6LowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zB6LowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
	li	$s4, 0			// Clear C
	or	$s0, $s0, $t3
        sltiu	$s5, $s0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// OR  A, A
zB7:
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, B
zB8:
	lbu	$t3, regB($s1)
	subu	$a0, 1			// decrement instruction counter
	seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, C
zB9:
	lbu	$t3, regC($s1)
	subu	$a0, 1			// decrement instruction counter
	seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, D
zBA:
	lbu	$t3, regD($s1)
	subu	$a0, 1			// decrement instruction counter
	seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, E
zBB:
	lbu	$t3, regE($s1)
	subu	$a0, 1			// decrement instruction counter
	seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, H
zBC:
	lbu	$t3, regH($s1)
	subu	$a0, 1			// decrement instruction counter
	seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, L
zBD:
	lbu	$t3, regL($s1)
	subu	$a0, 1			// decrement instruction counter
	seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, (HL)
zBE:
	lhu	$t2, regHL($s1)
	subu	$a0, 1			// decrement instruction counter
	bltu	$t2, 0x8000, zBEROM	// See if ROM
	bltu	$t2, 0xE000, zBERAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zBERAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zBERAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$t3, ($t2)
        seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zBEROM:
	bltu	$t2, 0x4000, zBELowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$t3, ($t2)
        seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zBELowROM:
	add	$t2, $t2, $a1		// ROM0 read
	lbu	$t3, ($t2)
        seq	$s5, $s0, $t3		// Set or clear Z	
	sltu	$s4, $s0, $t3		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A
zBF:
	li	$s5, 1			// Set Z
	li	$s4, 0			// Clear C
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RET  NZ
zC0:
	beqz	$s5, zRET		// only return if Z reset (0)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// POP  BC
zC1:
	ulhu	$t0, ($s2)
	subu	$a0, 3			// decrement instruction counter
	sh	$t0, regBC($s1)
	addi	$s2, 2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JP   NZ,nnnn
zC2:
	beqz	$s5, zDoJump		// only jump if Z reset (0)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


zDoJump:
// JP   nnnn
zC3:
	ulhu	$t2, ($s7)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x4000, zC3LowROM
	bgeu	$t2, 0x8000, zC3RAM
	add	$s7, $t2, $a2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zC3LowROM:
	add	$s7, $t2, $a1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zC3RAM:
	addu	$s7, $t2, $a3
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CALL   NZ,nnnn
zC4:
	beqz	$s5, zDoCall		// only call if Z reset (0)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// PUSH  BC
zC5:
	subu	$s2, 2
	lhu	$t0, regBC($s1)
	subu	$a0, 4			// decrement instruction counter
	ush	$t0, ($s2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
 
// ADD  A, nn
zC6:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t0, ($s7)
	add	$s7, 1
	add	$t0, $s0, $t0
	and	$s0, $t0, 0xFF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RST  00H
zC7:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zC7PCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zC7PCOk
	subu	$t0, $s7, $a3		// PC in RAM
zC7PCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 0		// Jump to 0x00
	subu	$a0, 4			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
// RET  Z
zC8:
	bnez	$s5, zRET		// only return if Z set (1)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zRET:
// RET
zC9:
	ulhu	$t0, ($s2)
	subu	$a0, 4			// decrement instruction counter
	addi	$s2, 2
	bltu	$t0, 0x4000, zC9LowROM
	bltu	$t0, 0x8000, zC9HiROM
	add	$s7, $t0, $a3
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zC9LowROM:
	add	$s7, $t0, $a1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zC9HiROM:
	add	$s7, $t0, $a2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JP   Z,nnnn
zCA:
	bnez	$s5, zDoJump		// only jump if Z set (1)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra





// CB Instructions
zCB:
	lbu	$t0, ($s7)		// Get CB instruction
	addi	$s7, 1
	andi	$t1, $t0, 0x07		// Get register
	sltu	$t3, $t1, 0x06		// Flip reg# for BC,DE,HL 
	xor	$t1, $t1, $t3
	andi	$t3, $t0, 0xF8		// Get actual instruction
	srl	$t3, $t3, 1		// /2 to get lookup
	la	$t4, zCBOP		// location of CB address table
	add	$t3, $t3, $t4		// get address of code for instruction
	lw	$t3, ($t3)
	jr	$t3			// do instruction

// RL
zCB00:
	beq	$t1, 7, zCB00A		// see if RegA
	beq	$t1, 6, zCB00HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	subu	$a0, 2			// decrement instruction counter
	srl	$t1, $t0, 7		// get bit 7 to bit 0
	sll	$t0, $t0, 1		// shift left 1
	andi	$s4, $t1, 0x01		// Set or clear C
	or	$t0, $t0, $s4		// rotated bit
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB00A:
	srl	$t1, $s0, 7		// get bit 7 to bit 0
	sll	$s0, $s0, 1		// shift left 1
	andi	$s4, $t1, 0x01		// Set or clear C
	or	$s0, $s0, $s4		// rotated bit
	andi	$s0, $s0, 0xFF		// remove any extra bits
	sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB00HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB00Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB00RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB00RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB00RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)
	srl	$t1, $t0, 7		// get bit 7 to bit 0
	sll	$t0, $t0, 1		// shift left 1
	andi	$s4, $t1, 0x01		// Set or clear C
	or	$t3, $t0, $s4		// rotated bit
	sltiu	$s5, $t3, 1		// Set or clear Z	
	j	zWrite
zCB00Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RR
zCB08:
	beq	$t1, 7, zCB08A		// see if RegA
	beq	$t1, 6, zCB08HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	subu	$a0, 2			// decrement instruction counter
	andi	$s4, $t0, 0x01		// Set or clear C
	sll	$t1, $s4, 7		// get bit 0 to bit 7
	srl	$t0, $t0, 1		// shift right 1
	or	$t0, $t0, $t1		// rotated bit
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB08A:
	andi	$s4, $s0, 0x01		// Set or clear C
	sll	$t1, $s4, 7		// get bit 0 to bit 7
	srl	$s0, $s0, 1		// shift right 1
	or	$s0, $s0, $t1		// rotated bit
	sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB08HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB08Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB08RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB08RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB08RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)
	andi	$s4, $t0, 1		// Set or clear C
	sll	$t1, $s4, 7		// get bit 0 to bit 7
	srl	$t0, $t0, 1		// shift right 1
	or	$t3, $t0, $t1		// rotated bit
	sltiu	$s5, $t3, 1		// Set or clear Z	
	j	zWrite
zCB08Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RLC
zCB10:
	beq	$t1, 7, zCB10A		// see if RegA
	beq	$t1, 6, zCB10HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	subu	$a0, 2			// decrement instruction counter
	srl	$t1, $t0, 7		// get bit 7 to bit 0
	sll	$t0, $t0, 1		// shift left 1
	or	$t0, $t0, $s4		// C bit
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	andi	$s4, $t1, 0x01		// Set or clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB10A:
	srl	$t1, $s0, 7		// get bit 7 to bit 0
	sll	$s0, $s0, 1		// shift left 1
	or	$s0, $s0, $s4		// C bit
	andi	$s0, $s0, 0xFF		// remove any extra bits
	sltiu	$s5, $s0, 1		// Set or clear Z	
	andi	$s4, $t1, 0x01		// Set or clear C
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB10HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB10Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB10RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB10RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB10RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)
	srl	$t1, $t0, 7		// get bit 7 to bit 0
	sll	$t0, $t0, 1		// shift left 1
	or	$t3, $t0, $s4		// C bit
	sltiu	$s5, $t3, 1		// Set or clear Z	
	andi	$s4, $t1, 0x01		// Set or clear C
	j	zWrite
zCB10Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RRC
zCB18:
	beq	$t1, 7, zCB18A		// see if RegA
	beq	$t1, 6, zCB18HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	sll	$t1, $s4, 7		// get C to bit 7
	andi	$s4, $t0, 0x01		// Set or clear C
	srl	$t0, $t0, 1		// shift right 1
	or	$t0, $t0, $t1		// C bit
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB18A:
	sll	$t1, $s4, 7		// get C to bit 7
	andi	$s4, $s0, 0x01		// Set or clear C
	srl	$s0, $s0, 1		// shift right 1
	or	$s0, $s0, $t1		// C bit
	sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB18HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB18Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB18RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB18RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB18RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)
	sll	$t1, $s4, 7		// get C to bit 7
	andi	$s4, $t0, 0x01		// Set or clear C
	srl	$t0, $t0, 1		// shift right 1
	or	$t3, $t0, $t1		// C bit
	sltiu	$s5, $t3, 1		// Set or clear Z	
	j	zWrite
zCB18Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SLA
zCB20:
	beq	$t1, 7, zCB20A		// see if RegA
	beq	$t1, 6, zCB20HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	subu	$a0, 2			// decrement instruction counter
	srl	$s4, $t0, 7		// get bit 7 to C
	sll	$t0, $t0, 1		// shift left 1
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB20A:
	srl	$s4, $s0, 7		// get bit 7 to C
	sll	$s0, $s0, 1		// shift left 1
	andi	$s0, $s0, 0xFF
	sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB20HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB20Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB20RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB20RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB20RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)
	srl	$s4, $t0, 7		// get bit 7 to C
	sll	$t3, $t0, 1		// shift left 1
	andi	$t3, $t3, 0xFF
	sltiu	$s5, $t3, 1		// Set or clear Z	
	j	zWrite
zCB20Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SRA
zCB28:
	beq	$t1, 7, zCB28A		// see if RegA
	beq	$t1, 6, zCB28HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lb	$t0, ($t2)		// get value- SIGNED
	subu	$a0, 2			// decrement instruction counter
	andi	$s4, $t0, 0x01		// get bit 0 to C
	srl	$t0, $t0, 1		// shift right 1
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB28A:
	andi	$s4, $s0, 0x01		// get bit 0 to C
	ori	$t1, $s0, 0x80		// Get Sign bit
	srl	$s0, $s0, 1		// shift right 1
	or	$s0, $s0, $t1		// restore Sign bit
	sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB28HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB28Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB28RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB28RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB28RAM:
	add	$t1, $t2, $a3		// RAM read
	lb	$t0, ($t1)		// Get Byte - SIGNED
	andi	$s4, $t0, 1		// get bit 0 to C
	srl	$t3, $t0, 1		// shift right 1
	andi	$t3, $t3, 0x00FF
	sltiu	$s5, $t3, 1		// Set or clear Z	
	j	zWrite
zCB28Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SWAP
zCB30:
	beq	$t1, 7, zCB30A		// see if RegA
	beq	$t1, 6, zCB30HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	subu	$a0, 2			// decrement instruction counter
	sll	$t1, $t0, 4		// shift low nibble left 4
	srl	$t0, $t0, 4		// shift high nibble right 4
	or	$t0, $t0, $t1		// combine
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB30A:
	sll	$t1, $s0, 4		// shift low nibble left 4
	srl	$t0, $s0, 4		// shift high nibble right 4
	or	$t0, $t0, $t1		// combine
	andi	$s0, $t0, 0x0FF		// byte only
	sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB30HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB30Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB30RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB30RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB30RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)
	li	$s4, 0			// Clear C
	sll	$t1, $t0, 4		// shift low nibble left 4
	srl	$t0, $t0, 4		// shift high nibble right 4
	or	$t3, $t0, $t1		// combine
	and	$t3, $t3, 0x0FF
	sltiu	$s5, $t3, 1		// Set or clear Z	
	j	zWrite
zCB30Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SRL
zCB38:
	beq	$t1, 7, zCB38A		// see if RegA
	beq	$t1, 6, zCB38HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value- UNSIGNED
	subu	$a0, 2			// decrement instruction counter
	andi	$s4, $t0, 0x01		// get bit 0 to C
	srl	$t0, $t0, 1		// shift right 1
	sb	$t0, ($t2)		// store new reg. value
	sltiu	$s5, $t0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB38A:
	andi	$s4, $s0, 0x01		// get bit 0 to C
	srl	$s0, $s0, 1		// shift right 1
	sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB38HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB38Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB38RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB38RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB38RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$s4, $t0, 0x01		// get bit 0 to C
	srl	$t3, $t0, 1		// shift right 1
	sltiu	$s5, $t3, 1		// Set or clear Z	
	j	zWrite
zCB38Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra



// BIT 0
zCB40:
	beq	$t1, 7, zCB40A		// see if RegA
	beq	$t1, 6, zCB40HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	subu	$a0, 2			// decrement instruction counter
	andi	$t0, $t0, 0x01		// bit 0
	sltiu	$s5, $t0, 1		// Set or clear Z	
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB40A:
	andi	$t0, $s0, 0x01		// bit 0
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB40HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB40Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB40RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB40RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB40RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x01		// bit 0
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB40Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// BIT 1
zCB48:
	beq	$t1, 7, zCB48A		// see if RegA
	beq	$t1, 6, zCB48HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x02		// bit 1
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB48A:
	andi	$t0, $s0, 0x02		// bit 1
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB48HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB48Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB48RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB48RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB48RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x02		// bit 1
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB48Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// BIT 2
zCB50:
	beq	$t1, 7, zCB50A		// see if RegA
	beq	$t1, 6, zCB50HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x04		// bit 2
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB50A:
	andi	$t0, $s0, 0x04		// bit 2
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB50HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB50Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB50RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB50RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB50RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x04		// bit 2
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB50Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// BIT 3
zCB58:
	beq	$t1, 7, zCB58A		// see if RegA
	beq	$t1, 6, zCB58HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x08		// bit 3
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB58A:
	andi	$t0, $s0, 0x08		// bit 3
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB58HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB58Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB58RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB58RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB58RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x08		// bit 3
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB58Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// BIT 4
zCB60:
	beq	$t1, 7, zCB60A		// see if RegA
	beq	$t1, 6, zCB60HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x10		// bit 4
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB60A:
	andi	$t0, $s0, 0x10		// bit 4
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB60HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB60Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB60RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB60RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB60RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x10		// bit 4
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB60Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// BIT 5
zCB68:
	beq	$t1, 7, zCB68A		// see if RegA
	beq	$t1, 6, zCB68HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x20		// bit 5
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB68A:
	andi	$t0, $s0, 0x20		// bit 5
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB68HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB68Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB68RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB68RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB68RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x20		// bit 5
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB68Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// BIT 6
zCB70:
	beq	$t1, 7, zCB70A		// see if RegA
	beq	$t1, 6, zCB70HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x40		// bit 6
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB70A:
	andi	$t0, $s0, 0x40		// bit 6
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB70HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB70Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB70RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB70RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB70RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x40		// bit 6
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB70Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// BIT 7
zCB78:
	beq	$t1, 7, zCB78A		// see if RegA
	beq	$t1, 6, zCB78HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x80		// bit 7
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB78A:
	andi	$t0, $s0, 0x80		// bit 7
	sltiu	$s5, $t0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB78HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB78Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB78RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB78RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB78RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte - UNSIGNED
	andi	$t0, $t0, 0x80		// bit 7
	sltiu	$s5, $t0, 1		// Set or clear Z	
zCB78Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 0
zCB80:
	beq	$t1, 7, zCB80A		// see if RegA
	beq	$t1, 6, zCB80HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0xFE		// bit 0
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB80A:
	andi	$s0, $s0, 0xFE		// bit 0
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB80HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB80Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB80RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB80RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB80RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0xFE		// bit 0
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCB80Cont:
	subu	$a0, 4			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 1
zCB88:
	beq	$t1, 7, zCB88A		// see if RegA
	beq	$t1, 6, zCB88HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0xFD		// bit 1
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB88A:
	andi	$s0, $s0, 0xFD		// bit 1
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB88HL:
	lhu	$t2, regHL($s1)
	bltu	$t2, 0x8000, zCB88Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB88RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB88RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB88RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0xFD		// bit 1
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCB88Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 2
zCB90:
	beq	$t1, 7, zCB90A		// see if RegA
	beq	$t1, 6, zCB90HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0xFB		// bit 2
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB90A:
	andi	$s0, $s0, 0xFB		// bit 2
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB90HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB90Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB90RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB90RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB90RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0xFB		// bit 2
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCB90Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 3
zCB98:
	beq	$t1, 7, zCB98A		// see if RegA
	beq	$t1, 6, zCB98HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0xF7		// bit 3
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCB98A:
	andi	$s0, $s0, 0xF7		// bit 3
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCB98HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCB98Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCB98RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCB98RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCB98RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0xF7		// bit 3
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCB98Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 4
zCBA0:
	beq	$t1, 7, zCBA0A		// see if RegA
	beq	$t1, 6, zCBA0HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0xEF		// bit 4
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBA0A:
	andi	$s0, $s0, 0xEF		// bit 4
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBA0HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBA0Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBA0RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBA0RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBA0RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0xEF		// bit 4
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCBA0Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 5
zCBA8:
	beq	$t1, 7, zCBA8A		// see if RegA
	beq	$t1, 6, zCBA8HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0xDF		// bit 5
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBA8A:
	andi	$s0, $s0, 0xDF		// bit 5
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBA8HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBA8Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBA8RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBA8RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBA8RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0xDF		// bit 5
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCBA8Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 6
zCBB0:
	beq	$t1, 7, zCBB0A		// see if RegA
	beq	$t1, 6, zCBB0HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0xBF		// bit 6
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBB0A:
	andi	$s0, $s0, 0xBF		// bit 6
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBB0HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBB0Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBB0RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBB0RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBB0RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0xBF		// bit 6
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCBB0Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RES 7
zCBB8:
	beq	$t1, 7, zCBB8A		// see if RegA
	beq	$t1, 6, zCBB8HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	andi	$t0, $t0, 0x7F		// bit 7
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBB8A:
	andi	$s0, $s0, 0x7F		// bit 7
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBB8HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBB8Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBB8RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBB8RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBB8RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	andi	$t3, $t0, 0x7F		// bit 7
	subu	$a0, 4			// decrement instruction counter
	j	zWrite
zCBB8Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SET 0
zCBC0:
	beq	$t1, 7, zCBC0A		// see if RegA
	beq	$t1, 6, zCBC0HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x01		// bit 0
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBC0A:
	ori	$s0, $s0, 0x01		// bit 0
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBC0HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBC0Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBC0RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBC0RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBC0RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x01		// bit 0
	j	zWrite
zCBC0Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SEt 1
zCBC8:
	beq	$t1, 7, zCBC8A		// see if RegA
	beq	$t1, 6, zCBC8HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x02		// bit 1
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBC8A:
	ori	$s0, $s0, 0x02		// bit 1
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBC8HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBC8Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBC8RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBC8RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBC8RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x02		// bit 1
	j	zWrite
zCBC8Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SEt 2
zCBD0:
	beq	$t1, 7, zCBD0A		// see if RegA
	beq	$t1, 6, zCBD0HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x04		// bit 2
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBD0A:
	ori	$s0, $s0, 0x04		// bit 2
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBD0HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBD0Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBD0RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBD0RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBD0RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x04		// bit 2
	j	zWrite
zCBD0Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SEt 3
zCBD8:
	beq	$t1, 7, zCBD8A		// see if RegA
	beq	$t1, 6, zCBD8HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x08		// bit 3
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBD8A:
	ori	$s0, $s0, 0x08		// bit 3
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBD8HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBD8Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBD8RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBD8RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBD8RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x08		// bit 3
	j	zWrite
zCBD8Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SEt 4
zCBE0:
	beq	$t1, 7, zCBE0A		// see if RegA
	beq	$t1, 6, zCBE0HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x10		// bit 4
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBE0A:
	ori	$s0, $s0, 0x10		// bit 4
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBE0HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBE0Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBE0RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBE0RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBE0RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x10		// bit 4
	j	zWrite
zCBE0Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SEt 5
zCBE8:
	beq	$t1, 7, zCBE8A		// see if RegA
	beq	$t1, 6, zCBE8HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x20		// bit 5
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBE8A:
	ori	$s0, $s0, 0x20		// bit 5
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBE8HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBE8Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBE8RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBE8RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBE8RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x20		// bit 5
	j	zWrite
zCBE8Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SEt 6
zCBF0:
	beq	$t1, 7, zCBF0A		// see if RegA
	beq	$t1, 6, zCBF0HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x40		// bit 6
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBF0A:
	ori	$s0, $s0, 0x40		// bit 6
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBF0HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBF0Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBF0RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBF0RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBF0RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x40		// bit 6
	j	zWrite
zCBF0Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// SEt 7
zCBF8:
	beq	$t1, 7, zCBF8A		// see if RegA
	beq	$t1, 6, zCBF8HL		// see if (HL)
	add	$t2, $t1, $s1		// get pointer to register
	lbu	$t0, ($t2)		// get value
	ori	$t0, $t0, 0x80		// bit 7
	sb	$t0, ($t2)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
zCBF8A:
	ori	$s0, $s0, 0x80		// bit 7
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zCBF8HL:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x8000, zCBF8Cont	// See if ROM. If so, can't shift!
	bltu	$t2, 0xE000, zCBF8RAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zCBF8RAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zCBF8RAM:
	add	$t1, $t2, $a3		// RAM read
	lbu	$t0, ($t1)		// Get Byte
	ori	$t3, $t0, 0x80		// bit 7
	j	zWrite
zCBF8Cont:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra







// CALL  Z,nnnn
zCC:
	bnez	$s5, zDoCall		// only Call if Z set (1)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zDoCall:
// CALL nnnn
zCD:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zCDPCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zCDPCOk
	subu	$t0, $s7, $a3		// PC in RAM
zCDPCOk:
	add	$t0, 2
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)

	ulhu	$t2, ($s7)
	subu	$a0, 6			// decrement instruction counter
	bltu	$t2, 0x4000, zCDLowROM
	bltu	$t2, 0x8000, zCDHiROM
	add	$s7, $t2, $a3
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zCDLowROM:
	add	$s7, $t2, $a1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zCDHiROM:
	add	$s7, $t2, $a2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADC  A, nn
zCE:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t0, ($s7)
	add	$s0, $s0, $s4
	add	$s7, 1
	add	$t0, $s0, $t0
	and	$s0, $t0, 0xFF
	sltu	$s4, $s0, $t0		// Set or clear C
        sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// RST  08H
zCF:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zCFPCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zCFPCOk
	subu	$t0, $s7, $a3		// PC in RAM
zCFPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 8		// Jump to 0x08
	subu	$a0, 4			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RET  NC
zD0:
	beqz	$s4, zRET		// only return if C reset (0)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// POP  DE
zD1:
	ulhu	$t0, ($s2)
	subu	$a0, 3			// decrement instruction counter
	sh	$t0, regDE($s1)
	addi	$s2, 2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JP   NC,nnnn
zD2:
	beqz	$s4, zDoJump		// only jump if D reset (0)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zD3:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CALL   NC,nnnn
zD4:
	beqz	$s4, zDoCall		// only call if C reset (0)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// PUSH  DE
zD5:
	subu	$s2, 2
	lhu	$t0, regDE($s1)
	subu	$a0, 4			// decrement instruction counter
	ush	$t0, ($s2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
 
// SUB  A, nn
zD6:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t0, ($s7)
	add	$s7, 1
	subu	$s0, $s0, $t0
	sgtu	$s4, $s0, 0xFF		// Set or clear C
	and	$s0, $s0, 0xFF
        sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RST  10H
zD7:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zD7PCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zD7PCOk
	subu	$t0, $s7, $a3		// PC in RAM
zD7PCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 0x10		// Jump to 0x10
	subu	$a0, 4			// decrement insteruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
	
// RET  C
zD8:
	bnez	$s4, zRET		// only return if C set (1)
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RETI
zD9:
	subu	$a0, 4			// decrement instruction counter
	ulhu	$t0, ($s2)
	addi	$s2, 2
	bltu	$t0, 0x4000, zD9LowROM
	bltu	$t0, 0x8000, zD9HiROM
	add	$s7, $t0, $a3
	b	zFB			// Enable Interrupt
zD9LowROM:
	add	$s7, $t0, $a1
	b	zFB			// Enable Interrupt
zD9HiROM:
	add	$s7, $t0, $a2
	b	zFB			// Enable Interrupt

// JP   C,nnnn
zDA:
	bnez	$s4, zDoJump		// only jump if C set (1)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zDB:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CALL  C,nnnn
zDC:
	bnez	$s4, zDoCall		// only Call if C set (1)
	addi	$s7, 2
	subu	$a0, 3			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zDD:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// SBC  A, nn
zDE:
	sb	$s0, regA_old($s1)	// Store old value for possible DAA
	lbu	$t0, ($s7)
	add	$s7, 1
	subu	$s0, $s0, $t0
	subu	$s0, $s0, $s4
	slt	$s4, $s0, $zero		// Set or clear C
	andi	$s0, $s0, 0x00FF
	sltiu	$s5, $s0, 1		// Set or clear Z	
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RST  18H
zDF:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zDFPCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zDFPCOk
	subu	$t0, $s7, $a3		// PC in RAM
zDFPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 0x18		// Jump to 0x10
	subu	$a0, 4			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD  (0xFF00+nn),A
zE0:
	lbu	$t0, ($s7)
	addi	$s7, 1
	addu	$t2, $t0, 0x00FF00	// Address to write to
	move	$t3, $s0		// Byte to write
	subu	$a0, 3			// decrement instruction counter
	j	WRAM_io

// POP  HL
zE1:
	ulhu	$t0, ($s2)
	subu	$a0, 3			// decrement instruction counter
	sh	$t0, regHL($s1)
	addi	$s2, 2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD  (0xFF00+C),A
zE2:
	lbu	$t0, regC($s1)
	subu	$a0, 3			// decrement insteruction counter
	addu	$t2, $t0, 0x00FF00	// Address to write to
	move	$t3, $s0		// Byte to write
	j	WRAM_io


// ???
zE3:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zE4:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// PUSH  HL
zE5:
	subu	$s2, 2
	lhu	$t0, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	ush	$t0, ($s2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
 
// AND  A, nn
zE6:
	lbu	$t0, ($s7)
	add	$s7, 1
	and	$s0, $s0, $t0
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// Clear C
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RST  20H
zE7:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zE7PCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zE7PCOk
	subu	$t0, $s7, $a3		// PC in RAM
zE7PCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 0x20		// Jump to 0x20
	subu	$a0, 4			// decrement insteruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ADD  SP, dd
zE8:
	lb	$t0, ($s7)
	add	$s7, 1
	add	$s2, $s2, $t0
	move	$s5, $zero		// Clear Z
	subu	$a0, 4			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// JP   HL
zE9:
	ulhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x4000, zE9LowROM
	bgeu	$t2, 0x8000, zE9RAM
	add	$s7, $t2, $a2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zE9LowROM:
	add	$s7, $t2, $a1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zE9RAM:
	add	$s7, $t2, $a3
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// LD   (nnnn), A
zEA:
	ulhu	$t2, ($s7)		// Address to write to
	addi	$s7, 2
	move	$t3, $s0		// Byte to write
	subu	$a0, 3			// decrement instruction counter
	j	zWrite

// ???
zEB:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zEC:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zED:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// XOR  A, nn
zEE:
	lbu	$t0, ($s7)
	add	$s7, 1
	xor	$s0, $s0, $t0
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// clear C
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RST  28H
zEF:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zEFPCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zEFPCOk
	subu	$t0, $s7, $a3		// PC in RAM
zEFPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 0x28		// Jump to 0x28
	subu	$a0, 4			// decrement insteruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD  A,(0xFF00+nn)
zF0:
	lbu	$t0, ($s7)
	addi	$s7, 1
	addu	$t0, $t0, 0x00FF00
	add	$t0, $t0, $a3
	lbu	$s0, ($t0)
	subu	$a0, 3			// decrement insteruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// POP  AF
zF1:
	lbu	$t0, ($s2)
	subu	$a0, 3			// decrement instruction counter
	andi	$s5, $t0, 0x80
	sltu	$s5, $zero, $s5		// Set or clear Z
	andi	$s4, $t0, 0x10
	sltu	$s4, $zero, $s4		// Set or clear C
	lbu	$s0, 1($s2)		// Get A
	addi	$s2, 2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD  A,(0xFF00+C)
zF2:
	lbu	$t0, regC($s1)
	addu	$t0, $t0, 0xFF00
	add	$t0, $t0, $a3
	lbu	$s0, ($t0)
	subu	$a0, 3			// decrement insteruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// DI
zF3:
	li	$t9, 0
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zF4:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// PUSH  AF
zF5:
	subu	$s2, 2
	li	$t0, 0

	sll	$t0, $s4, 4		// Get C flag
	sll	$t1, $s5, 7		// Get Z flag
	or	$t0, $t0, $t1		// combine

	sb	$t0, ($s2)
	sb	$s0, 1($s2)
	subu	$a0, 4			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// OR  A, nn
zF6:
	lbu	$t0, ($s7)
	add	$s7, 1
	or	$s0, $s0, $t0
        sltiu	$s5, $s0, 1		// Set or clear Z	
	li	$s4, 0			// clear C
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RST  30H
zF7:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zF7PCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zF7PCOk
	subu	$t0, $s7, $a3		// PC in RAM
zF7PCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 0x30		// Jump to 0x30
	subu	$a0, 4			// decrement insteruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD   HL,SP+dd
zF8:
	subu	$t0, $s2, $a1		// see if SP in Low ROM
	bltu	$t0, 0x4000, zF8SPOk
	subu	$t0, $s2, $a2		// High ROM?
	bltu	$t0, 0x8000, zF8SPOk
	subu	$t0, $s2, $a3		// RAM
zF8SPOk:
	lb	$t1, ($s7)
	addi	$s7, 1
	add	$t1, $t1, $t0
	sh	$t1, regHL($s1)
        sgtu	$s4, $t1, 0x00FFFF	// Set or clear C
	li	$s5, 0			// clear Z
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD   SP, HL
zF9:
	lhu	$t2, regHL($s1)
	subu	$a0, 4			// decrement instruction counter
	bltu	$t2, 0x4000, zF9LowROM
	bgeu	$t2, 0x8000, zC3RAM
	add	$s2, $t2, $a2
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zF9LowROM:
	add	$s2, $t2, $a1
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zF9RAM:
	add	$s2, $t2, $a3
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// LD   A, (nnnn)
zFA:
	ulhu	$t2, ($s7)
	addi	$s7, 2
	subu	$a0, 2			// decrement instruction counter
	bltu	$t2, 0x8000, zFAROM	// See if ROM
	bltu	$t2, 0xE000, zFARAM	// See if echo RAM
	bgeu	$t2, 0xFF00, zFARAM
	andi	$t2, $t2, 0xDFFF	// Yes, mask bit
zFARAM:
	add	$t2, $t2, $a3		// RAM read
	lbu	$s0, ($t2)
  	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFAROM:
	bltu	$t2, 0x4000, zFALowROM	// See if Low ROM
	add	$t2, $t2, $a2		// ROM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFALowROM:
	add	$t2, $t2, $a1		// ROM read
	lbu	$s0, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// EI
zFB:
	lbu	$t3, 0x7F0F($t8)	// Compare IE with IF
	lbu	$t1, 0x7FFF($t8)
	subu	$a0, 1			// decrement instruction counter
	and	$t1, $t3, $t1		// Did interrupt occur
	bnez	$t1, zFBIntr		// yes
	li	$t9, 1			// no, Enable Interrupt
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zFBIntr:
	// Interrupt not enabled until instruction after EI

	subu	$sp, 8
	sb	$a0, 4($sp)		// save counter
	sb	$t1, 5($sp)		// save IE (+) IF
	sb	$t3, 6($sp)		// Save IF
	sw	$ra, ($sp)
	move	$a0, $zero
	jal	DoNext			// Do one more instruction
	lw	$ra, ($sp)
	lbu	$t3, 6($sp)
	lbu	$t1, 5($sp)
	lbu	$a0, 4($sp)
	add	$sp, 8



	li	$t9, 0			// Disable interrupts

	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zFBPCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zFBPCOk
	subu	$t0, $s7, $a3		// PC in RAM
zFBPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)

	andi	$t0, $t1, 0x01		// V-Blank?
	beqz	$t0, zFBNextI1		// no
	add	$s7, $a1, 0x40		// yes, Jump to interrupt handler
	andi	$t3, $t3, 0xFE		// clear IF
	sb	$t3, 0x7f0f($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFBNextI1:
	andi	$t0, $t1, 0x02		// LCDC?
	beqz	$t0, zFBNextI2		// no
	add	$s7, $a1, 0x48		// yes, Jump to interrupt handler
	andi	$t3, $t3, 0xFD		// clear IF
	sb	$t3, 0x7f0f($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFBNextI2:
	andi	$t0, $t1, 0x04		// Timer?
	beqz	$t0, zFBNextI3		// no
	add	$s7, $a1, 0x50		// yes, Jump to interrupt handler
	andi	$t3, $t3, 0xFB		// clear IF
	sb	$t3, 0x7f0f($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFBNextI3:
	andi	$t0, $t1, 0x08		// Serial?
	beqz	$t0, zFBNextI4		// no
	add	$s7, $a1, 0x58		// yes, Jump to interrupt handler
	andi	$t3, $t3, 0xF7		// clear IF
	sb	$t3, 0x7f0f($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFBNextI4:
	andi	$t0, $t1, 0x10		// Joypad?
	beqz	$t0, zFBNextI5		// no
	add	$s7, $a1, 0x60		// yes, Jump to interrupt handler
	andi	$t3, $t3, 0xEF		// clear IF
	sb	$t3, 0x7f0f($t8)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra
zFBNextI5:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// ???
zFC:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// ???
zFD:
	subu	$a0, 1			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// CP  A, nn
zFE:
	lbu	$t0, ($s7)
	add	$s7, 1
	seq	$s5, $s0, $t0 		// Set or clear Z	
	sltu	$s4, $s0, $t0		// Set or clear C
	subu	$a0, 2			// decrement instruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

// RST  38H
zFF:
	subu	$t0, $s7, $a1		// See if PC in Low ROM
	bltu	$t0, 0x4000, zFFPCOk
	subu	$t0, $s7, $a2		// See if PC in High ROM
	bltu	$t0, 0x8000, zFFPCOk
	subu	$t0, $s7, $a3		// PC in RAM
zFFPCOk:
	subu	$s2, 2			// Store PC in Stack
	ush	$t0, ($s2)
	add	$s7, $a1, 0x38		// Jump to 0x38
	subu	$a0, 4			// decrement insteruction counter
	bgez	$a0, DoNext		// do another if >0
	jr	$ra


// Write byte to address
// $t2 = address
// $t3 = byte

zWrite1:
	bltu	$t2, 0x8000, zWriteROM

	add	$t2, $t2, $a3		// RAM write
	sb	$t3, ($t2)
	bgez	$a0, DoNext		// do another if >0
	jr	$ra

zWriteROM:
	bgez	$a0, DoNext		// do another if >0
	jr	$ra




/*
 * z-80 instruction lookup table
 */
zOP:
	.word	z00
	.word	z01
	.word	z02
	.word	z03
	.word	z04
	.word	z05
	.word	z06
	.word	z07
	.word	z08
	.word	z09
	.word	z0A
	.word	z0B
	.word	z0C
	.word	z0D
	.word	z0E
	.word	z0F
	.word	z10
	.word	z11
	.word	z12
	.word	z13
	.word	z14
	.word	z15
	.word	z16
	.word	z17
	.word	z18
	.word	z19
	.word	z1A
	.word	z1B
	.word	z1C
	.word	z1D
	.word	z1E
	.word	z1F
	.word	z20
	.word	z21
	.word	z22
	.word	z23
	.word	z24
	.word	z25
	.word	z26
	.word	z27
	.word	z28
	.word	z29
	.word	z2A
	.word	z2B
	.word	z2C
	.word	z2D
	.word	z2E
	.word	z2F
	.word	z30
	.word	z31
	.word	z32
	.word	z33
	.word	z34
	.word	z35
	.word	z36
	.word	z37
	.word	z38
	.word	z39
	.word	z3A
	.word	z3B
	.word	z3C
	.word	z3D
	.word	z3E
	.word	z3F
	.word	z40
	.word	z41
	.word	z42
	.word	z43
	.word	z44
	.word	z45
	.word	z46
	.word	z47
	.word	z48
	.word	z49
	.word	z4A
	.word	z4B
	.word	z4C
	.word	z4D
	.word	z4E
	.word	z4F
	.word	z50
	.word	z51
	.word	z52
	.word	z53
	.word	z54
	.word	z55
	.word	z56
	.word	z57
	.word	z58
	.word	z59
	.word	z5A
	.word	z5B
	.word	z5C
	.word	z5D
	.word	z5E
	.word	z5F
	.word	z60
	.word	z61
	.word	z62
	.word	z63
	.word	z64
	.word	z65
	.word	z66
	.word	z67
	.word	z68
	.word	z69
	.word	z6A
	.word	z6B
	.word	z6C
	.word	z6D
	.word	z6E
	.word	z6F
	.word	z70
	.word	z71
	.word	z72
	.word	z73
	.word	z74
	.word	z75
	.word	z76
	.word	z77
	.word	z78
	.word	z79
	.word	z7A
	.word	z7B
	.word	z7C
	.word	z7D
	.word	z7E
	.word	z7F
	.word	z80
	.word	z81
	.word	z82
	.word	z83
	.word	z84
	.word	z85
	.word	z86
	.word	z87
	.word	z88
	.word	z89
	.word	z8A
	.word	z8B
	.word	z8C
	.word	z8D
	.word	z8E
	.word	z8F
	.word	z90
	.word	z91
	.word	z92
	.word	z93
	.word	z94
	.word	z95
	.word	z96
	.word	z97
	.word	z98
	.word	z99
	.word	z9A
	.word	z9B
	.word	z9C
	.word	z9D
	.word	z9E
	.word	z9F
	.word	zA0
	.word	zA1
	.word	zA2
	.word	zA3
	.word	zA4
	.word	zA5
	.word	zA6
	.word	zA7
	.word	zA8
	.word	zA9
	.word	zAA
	.word	zAB
	.word	zAC
	.word	zAD
	.word	zAE
	.word	zAF
	.word	zB0
	.word	zB1
	.word	zB2
	.word	zB3
	.word	zB4
	.word	zB5
	.word	zB6
	.word	zB7
	.word	zB8
	.word	zB9
	.word	zBA
	.word	zBB
	.word	zBC
	.word	zBD
	.word	zBE
	.word	zBF
	.word	zC0
	.word	zC1
	.word	zC2
	.word	zC3
	.word	zC4
	.word	zC5
	.word	zC6
	.word	zC7
	.word	zC8
	.word	zC9
	.word	zCA
	.word	zCB
	.word	zCC
	.word	zCD
	.word	zCE
	.word	zCF
	.word	zD0
	.word	zD1
	.word	zD2
	.word	zD3
	.word	zD4
	.word	zD5
	.word	zD6
	.word	zD7
	.word	zD8
	.word	zD9
	.word	zDA
	.word	zDB
	.word	zDC
	.word	zDD
	.word	zDE
	.word	zDF
	.word	zE0
	.word	zE1
	.word	zE2
	.word	zE3
	.word	zE4
	.word	zE5
	.word	zE6
	.word	zE7
	.word	zE8
	.word	zE9
	.word	zEA
	.word	zEB
	.word	zEC
	.word	zED
	.word	zEE
	.word	zEF
	.word	zF0
	.word	zF1
	.word	zF2
	.word	zF3
	.word	zF4
	.word	zF5
	.word	zF6
	.word	zF7
	.word	zF8
	.word	zF9
	.word	zFA
	.word	zFB
	.word	zFC
	.word	zFD
	.word	zFE
	.word	zFF

zCBOP:
	.word	zCB00
	.word	zCB08
	.word	zCB10
	.word	zCB18
	.word	zCB20
	.word	zCB28
	.word	zCB30
	.word	zCB38
	.word	zCB40
	.word	zCB48
	.word	zCB50
	.word	zCB58
	.word	zCB60
	.word	zCB68
	.word	zCB70
	.word	zCB78
	.word	zCB80
	.word	zCB88
	.word	zCB90
	.word	zCB98
	.word	zCBA0
	.word	zCBA8
	.word	zCBB0
	.word	zCBB8
	.word	zCBC0
	.word	zCBC8
	.word	zCBD0
	.word	zCBD8
	.word	zCBE0
	.word	zCBE8
	.word	zCBF0
	.word	zCBF8

