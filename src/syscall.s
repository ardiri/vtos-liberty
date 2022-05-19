/*
 * @(#)syscall.s
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

#include <pr3910.h>

/**
 ** vt-os 1.1
 **
 ** -- Aaron Ardiri, 2000
 **/

#define SYSCALL(name,number)                       \
        .globl   name;                             \
        .ent     name;                             \
name:;                                             \
        .set     noat;                             \
        li       v0, number;                       \
        syscall;                                   \
        j        ra;                               \
        .set     at;                               \
        .end     name;                             \

        .text
SYSCALL(EvtGetEvent                                ,9)
SYSCALL(EvtAppendEvt                               ,14)
SYSCALL(TmrIntEnable                               ,16)
SYSCALL(TmrIntDisable                              ,17)
SYSCALL(TmrWaitTime                                ,18)
SYSCALL(RtcGetTime                                 ,19)
SYSCALL(RtcDiffTime                                ,21)
SYSCALL(pmalloc                                    ,48)
SYSCALL(pfree                                      ,50)
SYSCALL(qfree                                      ,53)
SYSCALL(DataNewRecord                              ,54)
SYSCALL(DataOpenRecord                             ,58)
SYSCALL(DataCloseDB                                ,59)
SYSCALL(DataCloseRecord                            ,62)
SYSCALL(DataWriteField                             ,70)
SYSCALL(DataGetField                               ,72)
SYSCALL(DataNewDB                                  ,78)
SYSCALL(DataFindDB                                 ,79)
SYSCALL(DataOpenDB                                 ,80)
SYSCALL(DataFieldSize                              ,89)
SYSCALL(DataTotalRecord                            ,103)
SYSCALL(strlen                                     ,119)
SYSCALL(strcpy                                     ,121)
SYSCALL(_FormDispatchEvent                         ,224)
SYSCALL(FormDrawForm                               ,226)
SYSCALL(FormSetEventHandler                        ,227)
SYSCALL(FormGetActiveFormID                        ,228)
SYSCALL(FormSetActiveForm                          ,229)
SYSCALL(FormGetObjectPointer                       ,233)
SYSCALL(FormGotoForm                               ,234)
SYSCALL(FormSaveBehindBits                         ,252)
SYSCALL(FormRestoreBitBehind                       ,253)
SYSCALL(FormInitForm                               ,255)
SYSCALL(MenuHandleEvent                            ,262)
SYSCALL(memcpy                                     ,322)
SYSCALL(ScrollbarEraseScrollbar                    ,353)
SYSCALL(ScrollbarGetScrollbar                      ,355)
SYSCALL(ScrollbarSetScrollbar                      ,356)
SYSCALL(ScrollbarDrawScrollbar                     ,363)
SYSCALL(SystemHandleEvent                          ,375)
SYSCALL(UISearchForAddress                         ,459)
SYSCALL(UIDeleteAllAppObjects                      ,465)
SYSCALL(MemoryAppStartBlock                        ,502)
SYSCALL(UIApplicationInit                          ,542)
SYSCALL(strncmp                                    ,583)
SYSCALL(SysGetAppID                                ,672) 
SYSCALL(SndPlaySndEffect                           ,734)
SYSCALL(BlockAddr                                  ,738)
SYSCALL(SysGetOSVersionNo                          ,771)

// vt-os 1.1.08

SYSCALL(LcdSetColorMode                            ,856)
SYSCALL(LcdGetColorMode                            ,857)
