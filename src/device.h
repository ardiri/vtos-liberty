/*
 * @(#)device.h
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

#ifndef _DEVICE_H
#define _DEVICE_H

#include "helio.h"

// typedefs, constants
#define EVT_FORM_CONFIGURE 1024

#define evtWaitForever    -1
#define noPreferenceFound -1

#define keyBitPower       0x0001  // power button
#define keyBitPageUp      0x0002
#define keyBitPageDown    0x0004  // scroll buttons [side of helio]
#define keyBitHard1       0x0008
#define keyBitHard2       0x0010
#define keyBitHard3       0x0020  // application buttons
#define keyBitCustom1     0x0100 
#define keyBitCustom2     0x0200 
#define keyBitCustom3     0x0400 
#define keyBitCustom4     0x0800  // custom buttons 

// functions
extern void  DeviceInitialize();
extern void  DeviceGetEvent(EvtType *, SHORT);
extern SHORT DeviceGetTicks();
extern SHORT DeviceTicksPerSecond();
extern void  DeviceGetOSVersionNumber(BYTE *);
extern SHORT DeviceGetAppPreferences(void *, SHORT *, BOOLEAN);
extern void  DeviceSetAppPreferences(void *, SHORT, BOOLEAN);
extern UWORD DeviceKeyCurrentState();
extern void  DeviceTerminate();

#endif 
