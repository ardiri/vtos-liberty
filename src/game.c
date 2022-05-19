/*
 * @(#)game.c
 *
 * Copyright 2000, Aaron Ardiri     (mailto:aaron@ardiri.com)
 *                 Michael Ethetton (mailto:methetton@gambitstudios.com)
 *                 Fredrik Nylund   (mailto:fnylund@hotmail.com)
 * All rights reserved.
 * 
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
 * The following portions of code found within this source code file are
 * owned  exclusively by Fredrik Nylund and Aaron Ardiri, and  shall not 
 * be used in or sold to  other projects  (internal or external) without
 * the written permission of one of the owners.
 *
 * - GameBoy(tm) ROM image memory management (desktop + handheld)
 *
 * It  shall be noted  that the Liberty  application was ported from the 
 * Palm Computing Platform version under sponsorship by VTech Holdings.
 */

#include "helio.h"

// binary resources (snap shots)
#include "game.inc"

// emulation state structure (used for saving state)
typedef struct
{
  struct {
    USHORT     regBC;              // BC register
    USHORT     regDE;              // DE register
    USHORT     regHL;              // HL register
    UBYTE      regA;               // accumulator
    UBYTE      regF;               // flags
    USHORT     regSP;              // stack pointer
    USHORT     regPC;              // program counter
    UBYTE      regInt;             // interrupt flag
    UBYTE      regTimer;           // z80 timer
    UBYTE      regSerialTimer;     // z80 serial timer

    UBYTE      regA_old;           // old accumulator
  } z80;

  UBYTE        xBitOff;
  UBYTE        xByteOff;
  UBYTE        wxBitOff;
  UBYTE        wxByteOff;
  UBYTE        xOffset;            // screen/window adjustment variables
  UBYTE        oldBgPallete;       // temp palette variable

  UBYTE        keyState;           // the key state (button press)
  UBYTE        _dummy1;            // "padding"

  USHORT       currRomIndex;       // the current rom page index

} EmuStateType;

// global variable structure
typedef struct
{
  EmuStateType emuState;           // stored state information

  struct {

    UBYTE      *ptrCurrentLine;    // screen buffer pointer

    UWORD      *ptrHLConv;         // the HLConversion table
    UBYTE      *ptrBGPalette;      // the background palette table
    UBYTE      *ptrSpritePalette0; // the sprite 0 palette table
    UBYTE      *ptrSpritePalette1; // the sprite 1 palette table

    UBYTE      *ptrLCDScreen;      // pointer to the REAL LCD screen
    UBYTE      *ptrScreen;         // offscreen buffer resource

    UBYTE      *ptr32KRam;         // the 32K ram chunk
    UBYTE      *ptrTileTable;      // a 4K tile reference table
    UBYTE      *ptrBGTileRam;      // the background tile ram (6K)

    USHORT     pageCount;
    UBYTE      **ptrPages;         // references to the ROM pages
    UBYTE      *ptrCurrRom;        // the current "rom" reference
  } emu;

  // 
  // after here = not used by emulation routines
  //

  UBYTE        *stdBGPalette;      // the default background palette table
  UBYTE        *stdSpritePalette0; // the default sprite 0 palette table
  UBYTE        *stdSpritePalette1; // the default sprite 1 palette table
  
} GameGlobals;

// globals reference
static GameGlobals *globals;

// local functions
static UBYTE *GameGetRomPtr(BYTE *);

/**
 * Initialize the Game.
 *
 * @param prefs the global preference data.
 */  
void   
GameInitialize(PreferencesType *prefs)
{
  USHORT i;

  // create a globals object
  globals = (GameGlobals *)pmalloc(sizeof(GameGlobals));
  memset(globals, (UBYTE)0, sizeof(GameGlobals));

  // initialize everything
  globals->emu.ptrScreen         = (UBYTE *)pmalloc(18488 * sizeof(UBYTE));
  globals->emu.ptr32KRam         = (UBYTE *)pmalloc(32768 * sizeof(UBYTE));
  globals->emu.ptrTileTable      = (UBYTE *)pmalloc(4096  * sizeof(UBYTE));
  globals->emu.ptrBGTileRam      = (UBYTE *)pmalloc(6144  * sizeof(UBYTE));
  globals->emu.ptrBGPalette      = (UBYTE *)pmalloc(256   * sizeof(UBYTE));
  globals->emu.ptrSpritePalette0 = (UBYTE *)pmalloc(256   * sizeof(UBYTE));
  globals->emu.ptrSpritePalette1 = (UBYTE *)pmalloc(256   * sizeof(UBYTE));

  // load any binary resources
  globals->emu.ptrHLConv         = &hlconv[0];
  globals->stdBGPalette          = &bgpal[0];
  globals->stdSpritePalette0     = &spr_pal0[0];
  globals->stdSpritePalette1     = &spr_pal1[0];

  // load the game rom image into memory (for emulation)
  {
    USHORT i;
    UBYTE  *romPtr;

    romPtr = GameGetRomPtr(prefs->game.strGBRomName);
    switch (romPtr[328]) 
    {
      case 0:   globals->emu.pageCount =   2; break; //  32Kb 
      case 1:   globals->emu.pageCount =   4; break; //  64Kb
      case 2:   globals->emu.pageCount =   8; break; // 128Kb
      case 3:   globals->emu.pageCount =  16; break; // 256Kb
      case 4:   globals->emu.pageCount =  32; break; // 512Kb
      case 5:   globals->emu.pageCount =  64; break; //   1Mb

      // 
      // the following are not supported at this point [should never get]
      //

      case 6:   globals->emu.pageCount =   0; break; //   2Mb
      case 52:  globals->emu.pageCount =   0; break; // 1.1Mb
      case 53:  globals->emu.pageCount =   0; break; // 1.2Mb
      case 54:  globals->emu.pageCount =   0; break; // 1.4Mb
      default:  globals->emu.pageCount =   0; break; // unknown :(
    }

    // allocate the memory required
    globals->emu.ptrPages = 
      (UBYTE **)pmalloc(globals->emu.pageCount * sizeof(UBYTE *));

    // determine the bank pointers
    globals->emu.ptrPages[0] = romPtr;
    for (i=1; i<globals->emu.pageCount; i++) {
      globals->emu.ptrPages[i] = globals->emu.ptrPages[i-1] + 16384;
    }

    // set the active font to the small terminal font
    GfxSetFont(gfx_termsmall);
  }

  // reset the game, and start!
  GameReset();
}

/**
 * Reset the emulator.
 */  
void
GameReset()
{
  // reset the z80 cpu registers and bits :)
  globals->emuState.z80.regBC          = 0x0013;
  globals->emuState.z80.regDE          = 0x00d8;
  globals->emuState.z80.regHL          = 0x014d;
  globals->emuState.z80.regA           = 0x01;
  globals->emuState.z80.regF           = 0xb0;
  globals->emuState.z80.regSP          = 0xfffe;
  globals->emuState.z80.regPC          = 0x0100;
  globals->emuState.z80.regInt         = 0x00;
  globals->emuState.z80.regTimer       = 0x00;
  globals->emuState.z80.regSerialTimer = 0x00;

  globals->emuState.xBitOff            = 0x08;
  globals->emuState.xByteOff           = 0x00;
  globals->emuState.wxBitOff           = 0x00;
  globals->emuState.wxByteOff          = 0x00;
  globals->emuState.xOffset            = 0x00;
  globals->emuState.oldBgPallete       = 0x00;

  // reset back to the "first" rom page
  globals->emuState.currRomIndex       = 0x01;
  globals->emu.ptrCurrRom = 
    globals->emu.ptrPages[globals->emuState.currRomIndex];

  // reset the palettes - copy from the default resources
  memcpy(globals->emu.ptrBGPalette, globals->stdBGPalette, 256);
  memcpy(globals->emu.ptrSpritePalette0, globals->stdSpritePalette0, 256);
  memcpy(globals->emu.ptrSpritePalette1, globals->stdSpritePalette1, 256);

  // reset the screen memory
  memset(globals->emu.ptrScreen, (UBYTE)0, 18488);

  // reset the ram
  {
    memset(globals->emu.ptr32KRam, (UBYTE)0, 32768);

    globals->emu.ptr32KRam[0x7f00] = 0xcf;
    globals->emu.ptr32KRam[0x7f10] = 0x80;
    globals->emu.ptr32KRam[0x7f11] = 0xbf;
    globals->emu.ptr32KRam[0x7f12] = 0xf3;
    globals->emu.ptr32KRam[0x7f14] = 0xbf;
    globals->emu.ptr32KRam[0x7f16] = 0x3f;
    globals->emu.ptr32KRam[0x7f19] = 0xbf;
    globals->emu.ptr32KRam[0x7f1a] = 0x7f;
    globals->emu.ptr32KRam[0x7f1b] = 0xff;
    globals->emu.ptr32KRam[0x7f1c] = 0x9f;
    globals->emu.ptr32KRam[0x7f1e] = 0xbf;
    globals->emu.ptr32KRam[0x7f20] = 0xff;
    globals->emu.ptr32KRam[0x7f23] = 0xbf;
    globals->emu.ptr32KRam[0x7f24] = 0x77;
    globals->emu.ptr32KRam[0x7f25] = 0xf3;
    globals->emu.ptr32KRam[0x7f26] = 0xf1;
    globals->emu.ptr32KRam[0x7f40] = 0x91;
    globals->emu.ptr32KRam[0x7f41] = 0x00;
    globals->emu.ptr32KRam[0x7f47] = 0xfc;
    globals->emu.ptr32KRam[0x7f48] = 0xff;
    globals->emu.ptr32KRam[0x7f49] = 0xff;

    memset(globals->emu.ptrTileTable, (UBYTE)0, 4096);
    memset(globals->emu.ptrBGTileRam, (UBYTE)0, 6144);
  }
}

/**
 * Perform the emulation.
 * 
 * @param prefs the global preference data.
 * @param keyStatus the current key state.
 */  
void   
GameEmulation(PreferencesType *prefs, UWORD keyStatus)
{
  void *ptrEmu = &(globals->emuState);

  // the helio device does not have a very nice "key" pattern so
  // playing games using the keys may not be an easy task :) the
  // following is coded as a "prototype", maybe someone will use
  // the "key" capabilities. :))
  //
  // the system is hardcoded as follows:
  //
  //   pageUp       = button A
  //   pageDown     = button B
  //   to do list   = Left
  //   scheduler    = Right                  [ see helio.h for more info ]
  //
  // :P enjoy
  //
  // -- Aaron Ardiri, 2000

  // adjust the key status
  globals->emuState.keyState = 
    (((keyStatus & ctlKeyDown)    != 0) ? 0x80 : 0x00) |
    (((keyStatus & ctlKeyUp)      != 0) ? 0x40 : 0x00) |
    (((keyStatus & ctlKeyLeft)    != 0) ? 0x20 : 0x00) |
    (((keyStatus & ctlKeyRight)   != 0) ? 0x10 : 0x00) |
    (((keyStatus & ctlKeyStart)   != 0) ? 0x08 : 0x00) |
    (((keyStatus & ctlKeySelect)  != 0) ? 0x04 : 0x00) |
    (((keyStatus & ctlKeyButtonB) != 0) ? 0x02 : 0x00) |
    (((keyStatus & ctlKeyButtonA) != 0) ? 0x01 : 0x00);

// 
// This is for MIKE :) the status of the keypress will be displayed 
//
// -- Aaron Ardiri, 2001

/*
{
  BYTE  str[10], i, j;
  UWORD x; 

  // fill with spaces
  memset(str, (UBYTE)32, 10);

  x = globals->emuState.keyState;
  i = j = 1;
  while (i < (j+8)) {
    if ((x & 0x80) != 0) str[i] = '1'; else str[i] = '0';
    x = x << 1; i++;
  }
  GfxDrawString(str, 10, 20, 6, gfxPaint);
}
*/

  // setup the screen writing information
  globals->emu.ptrLCDScreen  = GfxGetDisplayWindow()->memory;


  // *do* the emulation :P
  asm(".set    noat
       move    $8, %0" : : "g" (ptrEmu));  // t0 = pointer to "data"
  EmulateFrame();

}

/**
 * Terminate the game.
 *
 * @param prefs the global preference data.
 */
void   
GameTerminate(PreferencesType *prefs)
{
  // clean up memory
  pfree(globals->emu.ptrPages);
  pfree(globals->emu.ptrScreen);
  pfree(globals->emu.ptr32KRam);
  pfree(globals->emu.ptrTileTable);
  pfree(globals->emu.ptrBGTileRam);
  pfree(globals->emu.ptrBGPalette);
  pfree(globals->emu.ptrSpritePalette0);
  pfree(globals->emu.ptrSpritePalette1);
  pfree(globals);
}

/**
 * Obtain a pointer to the GameBoy(tm) rom image in a given database. 
 *
 * NOTE: database must be generated using the rom2app conversion utility.
 * 
 * @param romName the database containing the rom image.
 * @return the pointer to the beginning of the rom image.
 */
static UBYTE *
GameGetRomPtr(BYTE *romName)
{
  UBYTE *result = NULL;

  {
    AppID       appid;
    MatInfoList *mat;
    USHORT      startBlock;
    BOOLEAN     romFound;

    // locate the rom image
    romFound = SysGetAppID(romName, &appid);

    // if possible, get the pointer reference 
    if (romFound && (MemoryAppStartBlock(appid, &mat, &startBlock) == TRUE)) {
      result = (UBYTE *)BlockAddr(mat, startBlock) + 4416;
    }
  }

  return result;
}
