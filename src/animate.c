/*
 * @(#)animate.c
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

// global variable structure
typedef struct
{
  UWORD tmrReference;
} AnimateGlobals;

// globals reference
static AnimateGlobals *globals;

/**
 * Initialize the animation engine.
 */
void 
AnimateInitialize()
{
  // create a globals object
  globals = (AnimateGlobals *)pmalloc(sizeof(AnimateGlobals));
  globals->tmrReference = NULL;
}

/**
 * Start animating..
 *
 * @param fps the number of frames per second required.
 */
void
AnimateStart(WORD fps)
{
  if (!globals->tmrReference)
    globals->tmrReference = TmrIntEnable(1000/fps, AnimateCallback);
}

/**
 * Animation callback ground - to add NULL_EVENT to queue.
 */
void
AnimateCallback()
{
  EvtAppendEvt(NULL_EVENT,0,0,0,NULL);
}

/**
 * Stop animation.
 */
void
AnimateStop()
{
  if (globals->tmrReference)
  {
    TmrIntDisable(globals->tmrReference);
    globals->tmrReference = NULL;
  }
}

/**
 * Terminate the animation engine.
 */
void 
AnimateTerminate()
{
  AnimateStop();

  // clean up memory
  pfree(globals);
}
