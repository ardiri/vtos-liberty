/*
 * @(#)helio.c
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

// function prototypes
BOOLEAN (*FormDispatchEvent)(EvtType *Event);

// interface
static BOOLEAN mainFormEventHandler(EvtType *);

// global variables
static BYTE    romImageName[32] = { "Gmbt_GameBoy" };

/**
 * The Form:mainForm event handling routine.
 *
 * @param event the event to process.
 * @return true if the event was handled, false otherwise.
 */
static BOOLEAN 
mainFormEventHandler(EvtType *event)
{
  BOOLEAN processed = FALSE;

  switch (event->eventType)
  {
    case EVT_FORM_OPEN:
         FormDrawForm(mainForm);
         processed = TRUE;
         break;

    case EVT_CONTROL_SELECT:

         switch (event->eventID)
         {
           case mainFormOkButton:

                // redirect the event
                EvtAppendEvt(EVT_INLAY_SELECT,0,INLAY_OK,0,NULL);
                processed = TRUE;
                break;

           default:
                break;
         }
         break;

    case EVT_FORM_CLOSE:
         processed = TRUE;
         break;

    default:
         break;
  }

  return processed;
}

/**
 * The Helio Computing Platform initialization routine.
 */
void  
InitApplication()
{
  FormGotoForm(mainForm); 
}

/**
 * The application event handling routine.
 *
 * @param event the event to process.
 * @return true if the event was handled, false otherwise.
 */
BOOLEAN 
ApplicationHandleEvent(EvtType *event)
{
  BOOLEAN processed = FALSE;

  switch (event->eventType)
  {
    case EVT_FORM_LOAD:
         {
           ObjectID formID, currFormID;
           Form     *frm;
           BYTE     objectType;
           Err      error;

           // initialize the form
           formID = (ObjectID)event->eventID;
           error  = UISearchForAddress(formID, &objectType, (void **)&frm);
           if ((event->para1 == 1) || (error != TRUE)) {
             FormInitForm(formID);
           }

           // load it
           if (UISearchForAddress(formID, &objectType, (void **)&frm)) {

             switch (formID) 
             {
               case mainForm:
                    FormSetEventHandler(mainForm, 
                                        (void **)&FormDispatchEvent, 
                                        (void *)mainFormEventHandler);
                    break;

               default:
                    break;
             }

             // make it active
             FormSetActiveForm(formID);
             processed = TRUE;
           }
         }
         break;
         
    case EVT_INLAY_SELECT:

         // which button?
         switch (event->para1) 
         {
           case INLAY_OK:

                // does the form wanna handle it?
                processed = FormDispatchEvent(event);

                // no process? relay the event
                if (!processed) {
                  EvtAppendEvt(EVT_INLAY_SELECT,0,INLAY_EXIT,0,NULL);
                  processed = TRUE;
                }
                break; 

           case INLAY_EXIT:

                // does the form wanna handle it?
                processed = FormDispatchEvent(event);

                // no process? relay the event
                if (!processed) {
                  EvtAppendEvt(EVT_INLAY_SELECT,0,INLAY_MAIN_MENU,0,NULL);
                  processed = TRUE;
                }
                break;

           case INLAY_MAIN_MENU:

                // play a little snd
                SndPlaySndEffect(SNDRES5_BEEP);

                // close the current form
                EvtAppendEvt(EVT_FORM_CLOSE,0,0,0,NULL);

                // send an app-stop event
                EvtAppendEvt(EVT_APP_STOP,0,0,0,NULL);

                // lets return to the launcher
                {
                  AppID appID;
                  SysGetAppID((BYTE *)("Mainmenu"), &appID);
                  EvtAppendEvt(EVT_APP_LAUNCH,appID,0,0,NULL);
                }
                processed = TRUE;
                break;

           default:
                break;
         }
         break;

    default:
         break;
  }

  return processed;
}

/**
 * The Helio Computing Platform event processing loop.
 */
void  
EventLoop()
{
  EvtType event;

  do {
    EvtGetEvent(&event);

    if (!ApplicationHandleEvent(&event)) 
      if (!SystemHandleEvent(&event)) 
        if (!MenuHandleEvent(&event)) 
          FormDispatchEvent(&event);

  } while (event.eventType != EVT_APP_STOP);
}

/**
 * The Helio Computing Platform termination routine.
 */
void  
EndApplication()
{
}

/**
 * The Helio Computing Platform entry routine (mainline).
 *
 * @param cmd    a word value specifying the launch code.
 * @param cmdPBP pointer to a structure associated with the launch code.
 * @return zero if launch successful, non zero otherwise.
 */
BOOLEAN
HelioMain(WORD cmd, void *cmd_ptr)
{
  BOOLEAN result = FALSE;

  // what type of launch was this?
  switch (cmd) 
  {
    case LAUNCH_CMD_NORMAL_LAUNCH:
         {
           AppID libertyID = NULL;

           // locate the Liberty application
           SysGetAppID((BYTE *)("Liberty"), &libertyID);

           // Liberty application located?
           if (libertyID != NULL) {

             // register the name of "this" rom in the Liberty launch database
             {
               DatabaseID dbID;
               RecordID   recID;
               UWORD      numRec;

               // open the database
               if (!DataFindDB((BYTE *)("Gmbt_ROMNAME"),&dbID)) {
                 DataNewDB((BYTE *)("Gmbt_ROMNAME"),1,
                           (BYTE*)("VTech Information"),&dbID);
               }
               DataOpenDB(dbID,0,OPEN_RW);

               // open the record
               DataTotalRecord(dbID,&numRec);
               if (numRec == 0) 
                 DataNewRecord(dbID,0,1,&recID);   // create it, if not there
               DataOpenRecord(dbID,0,&recID,NULL);

               // write the record chunk
               DataWriteField(dbID,recID,0,32,(BYTE *)romImageName);

               // close the database
               DataCloseRecord(dbID,recID);
               DataCloseDB(dbID);
             }

             // launch the Liberty application
             EvtAppendEvt(EVT_APP_LAUNCH,libertyID,0,0,NULL);
           }

           // liberty NOT FOUND - show dialog
           else {
          
             // continue as a normal application
             InitApplication();
             EventLoop();
             EndApplication();
           }
         }
         result = TRUE;
         break;

    default:
         break;
  }

  return result;
}
