/*
 * @(#)gccfix.c
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

/**
 * The Helio Computing Platform entry routine (mainline).
 *
 * @param cmd    a word value specifying the launch code.
 * @param cmdPBP pointer to a structure associated with the launch code.
 * @return zero if launch successful, non zero otherwise.
 */
BOOLEAN
__main(WORD cmd, void *cmd_ptr)
{
  BOOLEAN result = FALSE;

  // what type of launch was this?
  switch (cmd) 
  {
    case LAUNCH_CMD_NORMAL_LAUNCH:
         {
           UIApplicationInit();
	   HelioMain(cmd, cmd_ptr);
           UIDeleteAllAppObjects();
         }
         result = TRUE;
         break;

    case LAUNCH_CMD_GOTO_REC:
         if (((GotoRec*)cmd_ptr)->find_string != NULL)
           pfree(((GotoRec*)cmd_ptr)->find_string);

    case LAUNCH_CMD_FIND:
    case LAUNCH_CMD_ALARM_HIT:
         pfree(cmd_ptr);
         result = TRUE;
         break;

    default:
         break;
  }

  return result;
}
