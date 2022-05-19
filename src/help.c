/*
 * @(#)help.c
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

// image resources
#include "help.inc"

// global variable structure
typedef struct
{
  GfxWindow *helpWindow;
} HelpGlobals;

// globals reference
static HelpGlobals *globals;

/**
 * Initialize the help instructions screen.
 *
 * @return the height in pixels of the instructions data area.
 */
SHORT
HelpInitialize()
{
  GfxRegion region = {{   0,   0 }, { 140, 116 }};

  // create a globals object
  globals = (HelpGlobals *)pmalloc(sizeof(HelpGlobals));

  // initialize windows
  globals->helpWindow = GfxCreateWindow(region.extent.x, region.extent.y);

  // draw the help
  {
    GfxFont   currFont;
    GfxWindow *currWindow;
    GfxWindow *tmpWindow;

    currWindow = GfxGetDrawWindow();
    currFont   = GfxGetFont();

    // draw to help window
    GfxSetDrawWindow(globals->helpWindow);
    GfxFillRegion(globals->helpWindow, &region, gfx_white);

    GfxSetFont(gfx_palmosNormalFont);
    {
      BYTE  *str, *ptrStr;
      SHORT x, y;

      // initialize
      y   = 2;
      str = (BYTE *)pmalloc(256 * sizeof(BYTE));

      // general text
      x = 4;
      strcpy(str,
"Liberty supports games designed for the original GameBoy.");
      ptrStr = str;
      while (strlen(ptrStr) != 0) {
        BYTE count = GfxGetWordWrap(ptrStr, region.extent.x-x);

	x = (region.extent.x - GfxGetCharsWidth(ptrStr, count)) >> 1;
        GfxDrawString(ptrStr, count, x, y, gfxPaint); 
	y += GfxGetFontHeight(); x = 4;

        ptrStr += count;
      }

      // add a space (little)
      y += GfxGetFontHeight() >> 1;

      x = 4;
      strcpy(str, "ENJOY!!");
      GfxSetFont(gfx_palmosBoldFont);
      x = (region.extent.x - GfxGetCharsWidth(str, strlen(str))) >> 1;
      GfxDrawString(str, strlen(str), x, y, gfxPaint); 
      y += GfxGetFontHeight();

      // clean up
      pfree(str);
    }

    // restore settings
    GfxSetFont(currFont);
    GfxSetDrawWindow(currWindow);
  }
  
  return region.extent.y;
}

/**
 * Draw the instructions on the screen.
 *
 * @param offset the offset height of the window to start copying from.
 */
void
HelpDrawInstructions(SHORT offset)
{
  GfxRegion helpArea = {{   0, offset }, { 140, 116 }};

  // blit the required area
  GfxCopyRegion(globals->helpWindow, GfxGetDrawWindow(),
                &helpArea, 5, 20, gfxPaint);
}

/**
 * Terminate the help instructions screen.
 */
void
HelpTerminate()
{
  // clean up memory
  GfxDisposeWindow(globals->helpWindow);
  pfree(globals);
}
