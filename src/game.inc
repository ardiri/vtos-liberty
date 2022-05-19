/*
 * @(#)game.inc
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


UWORD hlconv[8] =
{
    0x55500500, 0x5F5A0F0A, 0xF5F0A5A0, 0xFFFAAFAA, 
    0x000FF0FF, 0x0000F0F0, 0x000F000F, 0x00000000
};




UBYTE bgpal[16] =
{
  0x00, 0x05, 0x50, 0x55, 0x0A, 0x0F, 0x5A, 0x5F, 
  0xA0, 0xA5, 0xF0, 0xF5, 0xAA, 0xAF, 0xFA, 0xFF 
};

UBYTE spr_pal0[32] =
{
  0x00, 0x05, 0x50, 0x55, 0x0A, 0x0F, 0x5A, 0x5F, 
  0xA0, 0xA5, 0xF0, 0xF5, 0xAA, 0xAF, 0xFA, 0xFF,
  0xFF, 0xF0, 0x0F, 0x00, 0xF0, 0xF0, 0x00, 0x00,
  0x0F, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00
};


UBYTE spr_pal1[32] =
{
  0x00, 0x05, 0x50, 0x55, 0x0A, 0x0F, 0x5A, 0x5F, 
  0xA0, 0xA5, 0xF0, 0xF5, 0xAA, 0xAF, 0xFA, 0xFF,
  0xFF, 0xF0, 0x0F, 0x00, 0xF0, 0xF0, 0x00, 0x00,
  0x0F, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00
};

