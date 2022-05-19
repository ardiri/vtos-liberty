/*
 * @(#)helio.h
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

#ifndef _HELIO_H
#define _HELIO_H

// system includes
#include <system.h>
#include "resource/gfx.h"
#include "resource/termfont.inc"

// application constants
#define GAME_FPS 22                  // call "emulateframe" 22 times per second
                                     // effective rate of 44 fps
                                     //  - next to gameboy = similar speed

#define ctlKeyUp      keyBitCustom1
#define ctlKeyDown    keyBitCustom2
#define ctlKeyLeft    keyBitCustom3
#define ctlKeyRight   keyBitCustom4
#define ctlKeyStart   keyBitHard1
#define ctlKeySelect  keyBitHard2       
#define ctlKeyButtonA keyBitPageUp
#define ctlKeyButtonB keyBitPageDown    // key definitions during animation

// resource "include" :P
#include "resource.h"

typedef struct
{
  struct 
  {
    UBYTE   strGBRomName[32];           // the currently active ROM!
 
    UWORD   keyMaskSpecial;             // a little "hack" for start/select
  } game;

} PreferencesType;

// local includes
#include "device.h"
#include "game.h"
#include "animate.h"

// functions
extern void    InitApplication(void);
extern BOOLEAN ApplicationHandleEvent(EvtType *);
extern void    ApplicationDisplayDialog(ObjectID);
extern void    EventLoop(void);
extern void    EndApplication(void);
extern BOOLEAN HelioMain(WORD, void *);

#endif 
