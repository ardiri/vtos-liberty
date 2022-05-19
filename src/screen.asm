/*
 * @(#)screen.asm	
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


/*
 * *******************************************************************
 * *                                                                 *
 * *           DrawLine                                              *
 * *******************************************************************
 */


DoBlankLines:
	move	$t0, $zero
	move	$t1, $zero
DoBLine:

	sd	$t0, ($a3) 
	sd	$t0, 8($a3) 
	sd	$t0, 16($a3) 
	sd	$t0, 24($a3) 
	sd	$t0, 32($a3) 

	sd	$t0, 40($a3)
	sd	$t0, 48($a3) 
	sd	$t0, 56($a3) 
	sd	$t0, 64($a3) 
	sd	$t0, 72($a3) 

	sd	$t0, 80($a3)

	addi	$a3, 88

	addi	$t4, 1				// Increment BG Drawing Line
	bltu	$t4, $t7, DoBLine		// do all lines we are drawing
	sb	$t4, StartDLine($t8)
	sw	$a3, ptrCurLine($s1)		// Increment BG Drawing Line

BLineExit:
	// Restore registers
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
	lw	$t6, 52($sp)
	lw	$t3, 56($sp)
	lw	$v1, 60($sp)
	lw	$v0, 64($sp)
	lw	$t9, 68($sp)
	add	$sp, $sp, 72

DrawRet:
	jr	$ra


/*
* PRE-REQUIREMENTS/USES:
* =================
*
*  $0 - 0
*  at - used by assembler
*  v0 - temp. use - rotated pixels
*  v1 - temp. use - rotated pixels
*  a0 - pointer to HL Table
*  a1 - pointer to preconverted tile table
*  a2 - pointer to BG data table
*  a3 - current screen write location

*  t0-t2 - available for temp. use
*  t3 = bit offset (rotate #)
*  t4 = Current Y line
*  t5 = remaining bytes to write
*  t6 = offset for BG table for current Y
*  t7 = Current Line #


*  s0 - pointer to Window data table
*  s1 - Pointer to Register chunk (BC, DE, HL)
*  s2 - holder for a2
*  s3 - stored Y offset
*  s4 - stored a3
*  s5 - bytes to end of tile row in data table
*  s6 - bit offset #2
*  s7 - tile negate byte

*  t8 - RAM ptr (to actual RAM start)
*  t9 - temp. use

*  k0 - reserved by OS
*  k1 - reserved by OS
*  gp - pointer to global
*  sp - stack pointer
*  fp - frame pointer
*  ra - return address
*/


DrawLines:
	bgtu	$t7, 0x90, DrawRet		// if past screen, dont draw
	lbu	$t4, StartDLine($t8)		// load last row completed
	bleu	$t7,$t4,DrawRet			// don't draw if all lines already drawn

	// save registers we will trash
	sub	$sp, $sp, 72
	sw	$t9, 68($sp)
	sw	$v0, 64($sp)
	sw	$v1, 60($sp)
	sw	$t3, 56($sp)
	sw	$t6, 52($sp)
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


	lw	$a3, ptrCurLine($s1)		// Get current line in screen buffer

	lbu	$t2, 0x7F40($t8)		// Check out LCDC

	andi	$t0, $t2, 0x80
	beqz	$t0, DoBlankLines		// If Screen is off, dont draw the line
	lb	$t1, 0x7F47($t8)		// Get palette
	andi	$t0, $t2, 0x01			// check background
	beqz	$t1, DoBlankLines		// If palette=00, dont draw
	beqz	$t0, DoBlankLines		// If background is off, dont draw

	lw	$a0, ptrBgPal($s1)		// conversion table
	move	$a1, $t8			// Location of tile data table
	addi	$a2, $t8, 0x1800		// ptrTileTable($s1)		// Location of the Background Tile map

	andi	$t0, $t2, 0x08			// BG Data Select (0=0x9800, 1=0x9C00)
	beqz	$t0, LBGSCont
	addi	$a2, $a2, 0x400			// add 0x400
LBGSCont:
	move	$s2, $a2			// Store pointer to BG tile map

	lbu	$t6, xByteOff($s1)		// get horizontal byte offset
	li	$s5, 0x1f
	subu	$s5, $s5, $t6			// get bytes to end of tile row

	lbu	$t0, 0x7f42($t8)		// Get SCY
	add	$t0, $t0, $t4			// add current Y
	andi	$s3, $t0, 0x07			// get remainder
	subu	$t0, $t0, $s3			// 8 lines/ tile * 32 tiles/line
	add	$t0, $t0, $t0			// * 2 bits/pixel
	add	$t0, $t0, $t0

	add	$t6, $t6, $t0			// X & Y tile offsets
	andi	$t6, $t6, 0x3FF			// If past end of table, wrap to 1st row

	add	$t0, $s3, $s3			// y line offset*2 for tile adjust
	add	$a1, $a1, $t0			// Add in y line offset
	add	$a2, $s2, $t6			// Add tile start for current row

	li	$t0, 0x08	
	subu	$s3, $t0, $s3			// invert remainder for counting

	move	$s7, $zero			// Used in negating tile #s, if required

	andi	$t0, $t2, 0x10			// BG & Window Tile Data Select
	bnez	$t0, LBGTDS0			// If 1, stick with 0x8000
	addi	$a1, $a1, 0x0800		// else, add 0x800
	li	$s7, 0x080			// Negate tile #s

LBGTDS0:
	lbu	$t3, xBitOff($s1)		// Get x offset for rotate

	andi	$t0, $t2, 0x20			// Is Window on?
	beqz	$t0, DrawBGOnly			// no, no need to check each loop
	lbu	$t0, 0x7F4B($s1)
	bge	$t0, 166, DrawBGOnly		// See if Window X>166
//	lbu	$t0, 0x7F4C($s1)
//	bgt	$t0, $t7, DrawBGOnly


	addi	$s0, $t8, 0x1800
	andi	$t0, $t2, 0x40			// Win Data Select (0=0x9800, 1=0x9C00)
	beqz	$t0, LBGWCont
	addi	$s0, $s0, 0x400			// add 0x400
LBGWCont:

DoALine:
	li	$t5, 21				// BG byte counter
	move	$t9, $t5
	lbu	$t0, 0x7F4A($t8)		// If WindowY>Current Y, dont draw it
	bltu	$t4, $t0, DrawBG
	lbu	$t5, wxByteOff($s1)		// Get WX byte offset

	beqz	$t5, DrawWin			// If 0, then no BG- all Window on line
	subu	$t9, $t9, $t5
// 	subu	$t5, $t5, 1
	b	DrawBG

DNextLine:
	addi	$a3, $a3, 4
	subu	$s3, 1
	addi	$a1, 2				// Increment tile row
	bnez	$s3, DTileTblOk			// See if back to start of row
	li	$s3, 8				// yes, Y row offset=8
	subu	$a1, $a1, 0x10
	addi	$t6, 0x20			// update tile start
	andi	$t6, 0x3FF			// If past end of table, wrap to 1st row
DTileTblOk:
	add	$a2, $s2, $t6
	addi	$t4, $t4, 1			// increment current line
	lbu	$t0, xByteOff($s1)		// get horizontal byte offset
	li	$s5, 0x1f
	subu	$s5, $s5, $t0			// get bytes to end of tile row

	bltu	$t4, $t7, DoALine		// if not finished drawing, loop

	sw	$a3, ptrCurLine($s1)		//  Get current line in screen buffer

	jal	DrawJustSprites

	sb	$t7, StartDLine($t8)		// Save as last row completed

	b	DrawLineRet
	


// ** Draw all Background Lines on screen with Window off

DrawBGOnly:

	move	$s0, $a2
DrawBGLines:
	li	$t5, 21				// BG byte counter
	li	$v0, 0				// stored previous pixels
	li	$v1, 0
BGDraw:
	lbu	$t0, ($a2)			// get the ptr to the tile data table
	addi	$a2, $a2, 1
	xor	$t0, $t0, $s7
	sll	$t0, 4				// x16 to get offset in BG table

	// Do tile word
	add	$t0, $t0, $a1
	lhu	$t2, ($t0)			// get 2 bytes from BG tile data table

	subu	$t5, 1				// decrement counter


	srl	$t1, $t2, 8
	or	$t1, $t1, $v0
	andi	$v0, $t2, 0xFF00
	srl	$t1, $t1, $t3

	andi	$t2, $t2, 0x00FF
	or	$t2, $t2, $v1
	sll	$v1, $t2, 8
	srl	$t2, $t2, $t3


	srl	$t0, $t1, 4			// pixel 0,1
	srl	$s6, $t2, 6
	andi	$t0, $t0, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, ($a3)

	srl	$t0, $t1, 2			// pixel 2,3
	srl	$s6, $t2, 4
	andi	$t0, $t0, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 1($a3)

	srl	$s6, $t2, 2			// pixel 4,5
	andi	$t0, $t1, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 2($a3)

	sll	$t0, $t1, 2			// pixel 6,7
	andi	$t0, $t0, 0x0C
	andi	$s6, $t2, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 3($a3)

	addi	$a3, $a3, 4

	subu	$s5, 1
	blez	$t5, BGDone
	bgez	$s5, BGDraw
	subu	$a2, $a2, 0x20			// at end, subtract 0x20 from row (wrap to beginning of row)
	li	$s5, 0x1f
	b	BGDraw

BGDone:
	addi	$a3, $a3, 4
//	move	$a2, $s0			// restore BG tile map pointer
	subu	$s3, $s3, 1			// Increment Y row Offset
	addi	$a1, 2				// Increment tile row
	bnez	$s3, BGDTileTblOk		// See if back to start of row
	li	$s3, 8				// yes, Y row offset=8
	subu	$a1, $a1, 0x10
	addi	$t6, 0x20			// update tile start
	andi	$t6, 0x3FF			// If past end of table, wrap to 1st row
//	move	$s0, $a2
BGDTileTblOk:
	add	$a2, $s2, $t6
	addi	$t4, $t4, 1			// increment current line
	lbu	$t0, xByteOff($s1)		// get horizontal byte offset
	li	$s5, 0x1f
	subu	$s5, $s5, $t0			// get bytes to end of tile row

	bltu	$t4, $t7, DrawBGLines		// if not finished drawing, loop

	sw	$a3, ptrCurLine($s1)		//  Get current line in screen buffer

	jal	DrawJustSprites

	sb	$t7, StartDLine($t8)		// Save as last row completed

DrawLineRet:
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
	lw	$t6, 52($sp)
	lw	$t3, 56($sp)
	lw	$v1, 60($sp)
	lw	$v0, 64($sp)
	lw	$t9, 68($sp)
	add	$sp, $sp, 72

	j	$ra





// ** Draw A Single line of Background on screen with Window on

DrawBG:
	li	$v0, 0				// stored previous pixels
	li	$v1, 0
DrawBGLoop:
	lbu	$t0, ($a2)			// get the ptr to the tile data table
	addi	$a2, $a2, 1
	xor	$t0, $t0, $s7
	sll	$t0, 4				// x16 to get offset in BG table

	// Do tile word
	add	$t0, $t0, $a1
	lhu	$t2, ($t0)			// get 2 bytes from BG tile data table

	subu	$t5, 1				// decrement counter


	srl	$t1, $t2, 8
	or	$t1, $t1, $v0
	andi	$v0, $t2, 0xFF00
	srl	$t1, $t1, $t3

	andi	$t2, $t2, 0x00FF
	or	$t2, $t2, $v1
	sll	$v1, $t2, 8
	srl	$t2, $t2, $t3


	srl	$t0, $t1, 4			// pixel 0,1
	srl	$s6, $t2, 6
	andi	$t0, $t0, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, ($a3)

	srl	$t0, $t1, 2
	srl	$s6, $t2, 4
	andi	$t0, $t0, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 1($a3)

	srl	$s6, $t2, 2
	andi	$t0, $t1, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 2($a3)

	sll	$t0, $t1, 2
	andi	$t0, $t0, 0x0C
	andi	$s6, $t2, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 3($a3)


	addi	$a3, $a3, 4

	subu	$s5, 1
	blez	$t5, DBGDone2
	bgez	$s5, DrawBGLoop
	subu	$a2, $a2, 0x20			// at end, subtract 0x20 from row (wrap to beginning of row)
	li	$s5, 0x1f
	b	DrawBGLoop

DBGDone2:
	ulw	$t0, ptrLCDScreen($s1)
	lw	$t1, 1248($t0)
	not	$t1
	usw	$t1, 1248($t0)

	beq	$t9, 21, DNextLine		// If not drawing window, do next line

//  * *  Drawing Window after BG  * *



//  * *  Draw A Single Line of Window
DrawWin:
	lbu	$t3, wxBitOff($s1)		// Get window bit offset

	li	$t0, 8				// Remove Y offset from pointer to Tile Data
	subu	$t0, $t0, $s3
	add	$t0, $t0, $t0
	subu	$a1, $a1, $t0

	move	$t5, $t9			// Get # of bytes to write

	lbu	$t0, ScreenWinY($t8)		// Get current Window Y
	addi	$t1, $t0, 1
	sb	$t1, ScreenWinY($t8)
	add	$t0, $t0, $t0
	andi	$t9, $t0, 0x0F			// Get remainder
	sub	$t0, $t0, $t9
	add	$t0, $t0, $t0
	add	$a2, $s0, $t0

	add	$a1, $a1, $t9

DrawWinLoop:
	lbu	$t0, ($a2)			// get the ptr to the tile data table
	addi	$a2, $a2, 1
	xor	$t0, $t0, $s7
	sll	$t0, 4				// x16 to get offset in BG table

	// Do tile word
	add	$t0, $t0, $a1
	lhu	$t2, ($t0)			// get 2 bytes from BG tile data table

	subu	$t5, 1				// decrement counter


	srl	$t1, $t2, 8
	or	$t1, $t1, $v0
	andi	$v0, $t2, 0xFF00
	srl	$t1, $t1, $t3

	andi	$t2, $t2, 0x00FF
	or	$t2, $t2, $v1
	sll	$v1, $t2, 8
	srl	$t2, $t2, $t3


	srl	$t0, $t1, 4			// pixel 0,1
	srl	$s6, $t2, 6
	andi	$t0, $t0, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, ($a3)

	srl	$t0, $t1, 2
	srl	$s6, $t2, 4
	andi	$t0, $t0, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 1($a3)

	srl	$s6, $t2, 2
	andi	$t0, $t1, 0x0C
	andi	$s6, $s6, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 2($a3)

	sll	$t0, $t1, 2
	andi	$t0, $t0, 0x0C
	andi	$s6, $t2, 0x03
	or	$t0, $t0, $s6
	add	$t0, $t0, $a0
	lbu	$s6, ($t0)
	sb	$s6, 3($a3)


	addi	$a3, $a3, 4

	bgtz	$t5, DrawWinLoop
DrawWinExit:
	sub	$a1, $a1, $t9

	li	$t0, 8				// Restore Y offset in pointer to Tile Data
	subu	$t0, $t0, $s3
	add	$t0, $t0, $t0
	addu	$a1, $a1, $t0

	lbu	$t3, xBitOff($s1)		// Get x offset for rotate
	b	DNextLine




/* ********************************************************
   ********************************************************

*  s1 - Pointer to Register chunk (BC, DE, HL)
*  t7 - Must be current Y line
*  t8 - Must contain pointer to GB RAM
*
*  $a0 - temp
*  $a1 - pointer to palette table
*  $a2 - pointer to sprites
*  $a3 - pointer to Screen
*  $s4 - pointer to HL table
*  $s6 - pointer to tile data table
*  $s7 - temp
*  $t4 - Starting Y Line
*  $t5 - LCDC
*  $t6 - Sprite Data
*  $s5 - # of sprites left to check
*  $t0-$t3 = temp
*  $v0-$v1 = temp
*/

DrawJustSprites:

	lbu	$t5, 0x7f40($t8)		// Get LCDC
	andi	$t0, $t5, 2			// See if sprites are on
	beqz	$t0, DrawSpriteExit
	beqz	$t7, DrawSpriteExit		// Don't draw sprites on line 0


	// save registers we will trash
	sub	$sp, $sp, 64
	sw	$v1, 60($sp)
	sw	$v0, 56($sp)
	sw	$t6, 52($sp)
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

	lbu	$t4, StartDLine($t8)		// Get starting Y Line
	lw	$a3, ptrScreen($s1)		// Get screen pointer
	
	add	$a2, $t8, 0x7ea0		// Start at end of sprite table (for priority)
	li	$s5, 39				// Check 40 sprites

xDSLoop:
	subu	$a2, $a2, 4
	lw	$t6, ($a2)			// Get next sprite
	andi	$t0, $t6, 0x00ff
	bltu	$t7, $t0, DSDrawRet		// If SpriteY> current Y, don't draw
	bgtu	$t4, $t0, DSDrawRet		// If spriteY<starting Y line, don't draw
	srl	$t2, $t6, 8			// Get X to t2
	andi	$t2, $t2, 0x0FF
	beqz	$t2, DSDrawRet			// If X=0, don't draw
	bltu	$t2, 167, DrawOne		// If x<167, draw the sprite
DSDrawRet:
	subu	$s5, 1
	bgez	$s5, xDSLoop


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
	lw	$t6, 52($sp)
	lw	$v0, 56($sp)
	lw	$v1, 60($sp)
	add	$sp, $sp, 64

DrawSpriteExit:
	j	$ra



//  Draw a sprite... sprite Data in $t6, sprite Y in $t0, X in $t2
DrawOne:

	// Get Screen Line to draw to (y*88)
	sll	$t0, 3				// *8        [ 8]
	add	$t3, $t0, $t0			// + (y*8)*2
	add	$t0, $t3, $t0			//           [24]
	sll	$t3, 2				// + (y*8)*8 [64]
	add	$t0, $t0, $t3			// total = y*88
	add	$t3, $t0, $a3			// add in screen start address

	srl	$t0, $t2, 1			// (x / 8) * 4 bytes per 8 pixels
	andi	$t0, $t0, 0xFC			//

	add	$t3, $t3, $t0			// add in x byte offset
	subu	$t3, 4

	andi	$a0, $t2, 0x07			// get remainder in $a0 (offset)

	srl	$t6, $t6, 16			// Get Pattern #
	andi	$t0, $t6, 0x00FF

	andi	$t1, $t5, 0x04			// See if 8x16 sprites
	beqz	$t1, DSNot16			// If not, do nothing
	andi	$t0, 0x00FE			// If 8x16, ignore low bit
DSNot16:
	
	sll	$t0, $t0, 4			// x 16

	lw	$s4, ptrObjPal0($s1)		// Get pointer to Palette0
	andi	$t1, $t6, 0x1000		// Palette check
	beqz	$t1, DSPal0
	lw	$s4, ptrObjPal1($s1)		// Get pointer to Palette1

DSPal0:
	add	$s6, $t8, $t0			// get to pattern # index in tile data table

//	andi	$t1, $t6, 0x8000		// Is priority=behind BG?
//	bnez	$t1, DrawOneBG			// yes, draw behind BG

	andi	$t1, $t6, 0x2000		// Is X flipped?
	bnez	$t1, DSFlippedX

	andi	$t1, $t6, 0x4000		// Is Y flipped?
	bnez	$t1, DSFlippedY

// Y = Normal
	// Do tile rows 1,2
	lw	$t0, ($s6)			// get 4 bytes from tile
	jal	WriteBytes

	// Do tile rows 3,4
	lw	$t0, 4($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytes

	// Do tile rows 5,6
	lw	$t0, 8($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytes

	// Do tile rows 7,8
	lw	$t0, 12($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytes

	andi	$t1, $t5, 0x04			// See if 8x16 sprites
	beqz	$t1, DSDrawRet			// If not, do next tile


	// Do tile rows 9,10
	lw	$t0, 16($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytes

	// Do tile rows 11,12
	lw	$t0, 20($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytes

	// Do tile rows 13,14
	lw	$t0, 24($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytes

	// Do tile rows 15,16
	lw	$t0, 28($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytes

	b	DSDrawRet


DSFlippedY:
// Y = Flipped
	andi	$t1, $t5, 0x04			// See if 8x16 sprites
	beqz	$t1, DSfYNext			// If not, only do 8 lines
	add	$t3, $t3, 528
	// Do tile rows 15,16
//	lw	$t0, 16($s6)			// get 4 bytes from tile
	lwr	$t0, 18($s6)
	lwl	$t0, 17($s6)
	jal	WriteBytes

	// Do tile rows 13,14
//	lw	$t0, 20($s6)			// get 4 bytes from tile
	lwr	$t0, 22($s6)
	lwl	$t0, 21($s6)
	subu	$t3, $t3, 264
	jal	WriteBytes

	// Do tile rows 11,12
//	lw	$t0, 24($s6)			// get 4 bytes from tile
	lwr	$t0, 26($s6)
	lwl	$t0, 25($s6)
	subu	$t3, $t3, 264
	jal	WriteBytes

	// Do tile rows 9,10
//	lw	$t0, 28($s6)			// get 4 bytes from tile
	lwr	$t0, 30($s6)
	lwl	$t0, 29($s6)
	subu	$t3, $t3, 264
	jal	WriteBytes

	add	$t3, $t3, 616

DSfYNext:
	// Do tile rows 7,8
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 2($s6)
	lwl	$t0, 1($s6)
	add	$t3, $t3, 528
	jal	WriteBytes

	// Do tile rows 5,6
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 6($s6)
	lwl	$t0, 5($s6)
	subu	$t3, $t3, 264
	jal	WriteBytes

	// Do tile rows 3,4
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 10($s6)
	lwl	$t0, 9($s6)
	subu	$t3, $t3, 264
	jal	WriteBytes

	// Do tile rows 1,2
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 14($s6)
	lwl	$t0, 13($s6)
	subu	$t3, $t3, 264
	jal	WriteBytes

	b	DSDrawRet



DSFlippedX:
	andi	$t1, $t6, 0x4000		// Is Y flipped?
	bnez	$t1, DSFlippedXY

// X=Flipped, Y = Normal
	// Do tile rows 1,2
	lw	$t0, ($s6)			// get 4 bytes from tile
	jal	WriteBytesR

	// Do tile rows 3,4
	lw	$t0, 4($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytesR

	// Do tile rows 5,6
	lw	$t0, 8($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytesR

	// Do tile rows 7,8
	lw	$t0, 12($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytesR

	andi	$t1, $t5, 0x04			// See if 8x16 sprites
	beqz	$t1, DSDrawRet			// If not, do next tile


	// Do tile rows 9,10
	lw	$t0, 16($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytesR

	// Do tile rows 11,12
	lw	$t0, 20($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytesR

	// Do tile rows 13,14
	lw	$t0, 24($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytesR

	// Do tile rows 15,16
	lw	$t0, 28($s6)			// get 4 bytes from tile
	add	$t3, $t3, 88
	jal	WriteBytesR

	b	DSDrawRet


DSFlippedXY:
// X=flipped, Y = Flipped
	andi	$t1, $t5, 0x04			// See if 8x16 sprites
	beqz	$t1, DSfXYNext			// If not, only do 8 lines
	add	$t3, $t3, 528
	// Do tile rows 15,16
//	lw	$t0, 16($s6)			// get 4 bytes from tile
	lwr	$t0, 18($s6)
	lwl	$t0, 17($s6)
	jal	WriteBytesR

	// Do tile rows 13,14
//	lw	$t0, 20($s6)			// get 4 bytes from tile
	lwr	$t0, 22($s6)
	lwl	$t0, 21($s6)
	subu	$t3, $t3, 264
	jal	WriteBytesR

	// Do tile rows 11,12
//	lw	$t0, 24($s6)			// get 4 bytes from tile
	lwr	$t0, 26($s6)
	lwl	$t0, 25($s6)
	subu	$t3, $t3, 264
	jal	WriteBytesR

	// Do tile rows 9,10
//	lw	$t0, 28($s6)			// get 4 bytes from tile
	lwr	$t0, 30($s6)
	lwl	$t0, 29($s6)
	subu	$t3, $t3, 264
	jal	WriteBytesR

	add	$t3, $t3, 616

DSfXYNext:
	// Do tile rows 7,8
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 2($s6)
	lwl	$t0, 1($s6)
	add	$t3, $t3, 528
	jal	WriteBytesR

	// Do tile rows 5,6
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 6($s6)
	lwl	$t0, 5($s6)
	subu	$t3, $t3, 264
	jal	WriteBytesR

	// Do tile rows 3,4
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 10($s6)
	lwl	$t0, 9($s6)
	subu	$t3, $t3, 264
	jal	WriteBytesR

	// Do tile rows 1,2
//	lw	$t0, ($s6)			// get 4 bytes from tile
	lwr	$t0, 14($s6)
	lwl	$t0, 13($s6)
	subu	$t3, $t3, 264
	jal	WriteBytesR

	b	DSDrawRet




/* ************************************************
   *     Write 8 pixels (4 bytes) to screen
   *  s4 - Pointer to pixel conv. table
   *  t3 - Byte loc. to write to
   *  t0 - pattern to write (4 bytes, LLHHLLHH)
   *  a0 - pixel Offset
   *  s7, v0, v1, a1, t1, t2 - temp use
   */

WriteBytes:


	andi	$v0, $t0, 0xFF			// get High
	ror	$v0, $v0, $a0

	ror	$v1, $t0, 8			// get Low
	andi	$v1, $v1, 0xFF
	ror	$v1, $v1, $a0

	srl	$t1, $v0, 4			// pixel 0,1
	srl	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, ($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, ($t3)	

	srl	$t1, $v0, 2			// pixel 2,3
	srl	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 1($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 1($t3)	
	
						// pixel 4,5
	srl	$t2, $v1, 2
	andi	$t1, $v0, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 2($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 2($t3)	

	sll	$t1, $v0, 2			// pixel 6,7
	andi	$t1, $t1, 0x0C
	andi	$t2, $v1, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 3($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 3($t3)	


	// offset pixels
	rol	$t1, $v0, 4			// pixel 0,1
	rol	$t2, $v1, 2
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 4($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 4($t3)	

	rol	$t1, $v0, 6			// pixel 2,3
	rol	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 5($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 5($t3)	

	rol	$t1, $v0, 8			// pixel 4,5
	rol	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 6($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 6($t3)	

	rol	$t1, $v0, 10			// pixel 6,7
	rol	$t2, $v1, 8
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 7($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 7($t3)	



	add	$t3, 88 			// Go to next screen line


	srl	$t0, $t0, 16
	andi	$v0, $t0, 0xFF			// get High
	ror	$v0, $v0, $a0

	ror	$v1, $t0, 8			// get Low
	andi	$v1, $v1, 0xFF
	ror	$v1, $v1, $a0



	srl	$t1, $v0, 4			// pixel 0,1
	srl	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, ($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, ($t3)	

	srl	$t1, $v0, 2			// pixel 2,3
	srl	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 1($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 1($t3)	
	
						// pixel 4,5
	srl	$t2, $v1, 2
	andi	$t1, $v0, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 2($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 2($t3)	

	sll	$t1, $v0, 2			// pixel 6,7
	andi	$t1, $t1, 0x0C
	andi	$t2, $v1, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 3($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 3($t3)	


	// offset pixels
	rol	$t1, $v0, 4			// pixel 0,1
	rol	$t2, $v1, 2
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 4($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 4($t3)	

	rol	$t1, $v0, 6			// pixel 2,3
	rol	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 5($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 5($t3)	

	rol	$t1, $v0, 8			// pixel 4,5
	rol	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 6($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 6($t3)	

	rol	$t1, $v0, 10			// pixel 6,7
	rol	$t2, $v1, 8
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 7($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 7($t3)	

	jr	$ra




WriteBytesR:
	la	$s7, revPixels
	andi	$v0, $t0, 0xFF			// get High
	add	$v0, $v0, $s7
	lbu	$v0, ($v0)
	ror	$v0, $v0, $a0

	ror	$v1, $t0, 8			// get Low
	andi	$v1, $v1, 0xFF
	add	$v1, $v1, $s7
	lbu	$v1, ($v1)
	ror	$v1, $v1, $a0

	srl	$t1, $v0, 4			// pixel 0,1
	srl	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, ($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, ($t3)	

	srl	$t1, $v0, 2			// pixel 2,3
	srl	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 1($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 1($t3)	
	
						// pixel 4,5
	srl	$t2, $v1, 2
	andi	$t1, $v0, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 2($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 2($t3)	

	sll	$t1, $v0, 2			// pixel 6,7
	andi	$t1, $t1, 0x0C
	andi	$t2, $v1, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 3($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 3($t3)	


	// offset pixels
	rol	$t1, $v0, 4			// pixel 0,1
	rol	$t2, $v1, 2
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 4($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 4($t3)	

	rol	$t1, $v0, 6			// pixel 2,3
	rol	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 5($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 5($t3)	

	rol	$t1, $v0, 8			// pixel 4,5
	rol	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 6($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 6($t3)	

	rol	$t1, $v0, 10			// pixel 6,7
	rol	$t2, $v1, 8
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 7($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 7($t3)	



	add	$t3, 88 			// Go to next screen line


	srl	$t0, $t0, 16
	la	$s7, revPixels
	andi	$v0, $t0, 0xFF			// get High
	add	$v0, $v0, $s7
	lbu	$v0, ($v0)
	ror	$v0, $v0, $a0

	ror	$v1, $t0, 8			// get Low
	andi	$v1, $v1, 0xFF
	add	$v1, $v1, $s7
	lbu	$v1, ($v1)
	ror	$v1, $v1, $a0



	srl	$t1, $v0, 4			// pixel 0,1
	srl	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, ($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, ($t3)	

	srl	$t1, $v0, 2			// pixel 2,3
	srl	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 1($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 1($t3)	
	
						// pixel 4,5
	srl	$t2, $v1, 2
	andi	$t1, $v0, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 2($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 2($t3)	

	sll	$t1, $v0, 2			// pixel 6,7
	andi	$t1, $t1, 0x0C
	andi	$t2, $v1, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 3($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 3($t3)	


	// offset pixels
	rol	$t1, $v0, 4			// pixel 0,1
	rol	$t2, $v1, 2
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 4($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 4($t3)	

	rol	$t1, $v0, 6			// pixel 2,3
	rol	$t2, $v1, 4
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 5($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 5($t3)	

	rol	$t1, $v0, 8			// pixel 4,5
	rol	$t2, $v1, 6
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 6($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 6($t3)	

	rol	$t1, $v0, 10			// pixel 6,7
	rol	$t2, $v1, 8
	andi	$t1, $t1, 0x0C
	andi	$t2, $t2, 0x03
	or	$t1, $t1, $t2
	add	$t1, $t1, $s4
	lbu	$a1, 7($t3)
	lbu	$s7, 16($t1)
	lbu	$t2, ($t1)
	and	$a1, $a1, $s7
	or	$a1, $a1, $t2
	sb	$a1, 7($t3)	

	jr	$ra


revPixels:
	.byte	0x00,0x80,0x40,0xC0, 0x20,0xA0,0x60,0xE0, 0x10,0x90,0x50,0xD0, 0x30,0xB0,0x70,0xF0
	.byte	0x08,0x88,0x48,0xC8, 0x28,0xA8,0x68,0xE8, 0x18,0x98,0x58,0xD8, 0x38,0xB8,0x78,0xF8
	.byte	0x04,0x84,0x44,0xC4, 0x24,0xA4,0x64,0xE4, 0x14,0x94,0x54,0xD4, 0x34,0xB4,0x74,0xF4
	.byte	0x0C,0x8C,0x4C,0xCC, 0x2C,0xAC,0x6C,0xEC, 0x1C,0x9C,0x5C,0xDC, 0x3C,0xBC,0x7C,0xFC
	.byte	0x02,0x82,0x42,0xC2, 0x22,0xA2,0x62,0xE2, 0x12,0x92,0x52,0xD2, 0x32,0xB2,0x72,0xF2
	.byte	0x0A,0x8A,0x4A,0xCA, 0x2A,0xAA,0x6A,0xEA, 0x1A,0x9A,0x5A,0xDA, 0x3A,0xBA,0x7A,0xFA
	.byte	0x06,0x86,0x46,0xC6, 0x26,0xA6,0x66,0xE6, 0x16,0x96,0x56,0xD6, 0x36,0xB6,0x76,0xF6
	.byte	0x0E,0x8E,0x4E,0xCE, 0x2E,0xAE,0x6E,0xEE, 0x1E,0x9E,0x5E,0xDE, 0x3E,0xBE,0x7E,0xFE

	.byte	0x01,0x81,0x41,0xC1, 0x21,0xA1,0x61,0xE1, 0x11,0x91,0x51,0xD1, 0x31,0xB1,0x71,0xF1
	.byte	0x09,0x89,0x49,0xC9, 0x29,0xA9,0x69,0xE9, 0x19,0x99,0x59,0xD9, 0x39,0xB9,0x79,0xF9
	.byte	0x05,0x85,0x45,0xC5, 0x25,0xA5,0x65,0xE5, 0x15,0x95,0x55,0xD5, 0x35,0xB5,0x75,0xF5
	.byte	0x0D,0x8D,0x4D,0xCD, 0x2D,0xAD,0x6D,0xED, 0x1D,0x9D,0x5D,0xDD, 0x3D,0xBD,0x7D,0xFD
	.byte	0x03,0x83,0x43,0xC3, 0x23,0xA3,0x63,0xE3, 0x13,0x93,0x53,0xD3, 0x33,0xB3,0x73,0xF3
	.byte	0x0B,0x8B,0x4B,0xCB, 0x2B,0xAB,0x6B,0xEB, 0x1B,0x9B,0x5B,0xDB, 0x3B,0xBB,0x7B,0xFB
	.byte	0x07,0x87,0x47,0xC7, 0x27,0xA7,0x67,0xE7, 0x17,0x97,0x57,0xD7, 0x37,0xB7,0x77,0xF7
	.byte	0x0F,0x8F,0x4F,0xCF, 0x2F,0xAF,0x6F,0xEF, 0x1F,0x9F,0x5F,0xDF, 0x3F,0xBF,0x7F,0xFF

