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

// global variable structure
typedef struct
{
  PreferencesType *prefs;
} Globals;

// globals reference
static Globals *globals;

// function prototypes
BOOLEAN (*FormDispatchEvent)(EvtType *Event);

// interface
static BOOLEAN mainFormEventHandler(EvtType *);
static BOOLEAN infoFormEventHandler(EvtType *);

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

         // initialize the game, and reset the emulator
         GameInitialize(globals->prefs);
         GameReset();

         // configure
         EvtAppendEvt(EVT_FORM_CONFIGURE,0,0,0,NULL);
         processed = TRUE;
         break;

    case EVT_FORM_CONFIGURE:
         AnimateStart(GAME_FPS);
         processed = TRUE;
         break;

    case EVT_BITMAP_SELECT:

         switch (event->eventID) 
         {
           case mainFormAboutBitmap:

                // display the info form [modal dialog]
                ApplicationDisplayDialog(infoForm);

                processed = TRUE;
                break;

           case mainFormStartBitmap:
                globals->prefs->game.keyMaskSpecial |= ctlKeyStart;
                processed = TRUE;
                break;

           case mainFormSelectBitmap:
                globals->prefs->game.keyMaskSpecial |= ctlKeySelect;
                processed = TRUE;
                break;

           default:
                break;
         }
         break;

    case PEN_EVENT:

         // NOTE: the following code is "generic", however, may not always
         //       be the "perfect" definition of the  areas that should be
         //       for the "stylus" area. give and take, for speed issues.
         //
         //                                               Aaron Ardiri, 2000

         // what type?
         switch (event->eventID)
         {
           case PEN_DOWN:
           case PEN_MOVE:
           case PEN_UP:
                {
                  SHORT penRegion[2][2] = { {24, 170}, {112,48} };
                  SHORT x, y;

                  x = event->para1;
                  y = event->para2;

                  // did the user tap in the "control" area?
                  if ((x >= penRegion[0][0]) && (y >= penRegion[0][1]) &&
                      (x <= (penRegion[0][0] + penRegion[1][0])) && 
                      (y <= (penRegion[0][1] + penRegion[1][1]))) {

                    SHORT rctUp[2][2]        = { {48, 170}, {24,16} };
                    SHORT rctDown[2][2]      = { {48, 202}, {24,16} };
                    SHORT rctLeft[2][2]      = { {24, 186}, {24,16} };
                    SHORT rctRight[2][2]     = { {72, 186}, {24,16} };
                    SHORT rctUpLeft[2][2]    = { {24, 170}, {24,16} };
                    SHORT rctUpRight[2][2]   = { {72, 170}, {24,16} };
                    SHORT rctDownLeft[2][2]  = { {24, 202}, {24,16} };
                    SHORT rctDownRight[2][2] = { {72, 202}, {24,16} };
                    SHORT rctButtonA[2][2]   = { {96, 170}, {40,24} };
                    SHORT rctButtonB[2][2]   = { {96, 194}, {40,24} };
 
                    if ((x >= rctUp[0][0]) && (y >= rctUp[0][1]) &&
                        (x <= (rctUp[0][0] + rctUp[1][0])) && 
                        (y <= (rctUp[0][1] + rctUp[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        ctlKeyUp;

                    if ((x >= rctDown[0][0]) && (y >= rctDown[0][1]) &&
                        (x <= (rctDown[0][0] + rctDown[1][0])) && 
                        (y <= (rctDown[0][1] + rctDown[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        ctlKeyDown;

                    if ((x >= rctLeft[0][0]) && (y >= rctLeft[0][1]) &&
                        (x <= (rctLeft[0][0] + rctLeft[1][0])) && 
                        (y <= (rctLeft[0][1] + rctLeft[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        ctlKeyLeft;

                    if ((x >= rctRight[0][0]) && (y >= rctRight[0][1]) &&
                        (x <= (rctRight[0][0] + rctRight[1][0])) && 
                        (y <= (rctRight[0][1] + rctRight[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        ctlKeyRight;

                    if ((x >= rctUpLeft[0][0]) && (y >= rctUpLeft[0][1]) &&
                        (x <= (rctUpLeft[0][0] + rctUpLeft[1][0])) && 
                        (y <= (rctUpLeft[0][1] + rctUpLeft[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        (ctlKeyUp | ctlKeyLeft);

                    if ((x >= rctUpRight[0][0]) && (y >= rctUpRight[0][1]) &&
                        (x <= (rctUpRight[0][0] + rctUpRight[1][0])) && 
                        (y <= (rctUpRight[0][1] + rctUpRight[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        (ctlKeyUp | ctlKeyRight);

                    if ((x >= rctDownLeft[0][0]) && (y >= rctDownLeft[0][1]) &&
                        (x <= (rctDownLeft[0][0] + rctDownLeft[1][0])) && 
                        (y <= (rctDownLeft[0][1] + rctDownLeft[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        (ctlKeyDown | ctlKeyLeft);

                    if ((x >= rctDownRight[0][0]) && (y >= rctDownRight[0][1]) &&
                        (x <= (rctDownRight[0][0] + rctDownRight[1][0])) && 
                        (y <= (rctDownRight[0][1] + rctDownRight[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        (ctlKeyDown | ctlKeyRight);

                    if ((x >= rctButtonA[0][0]) && (y >= rctButtonA[0][1]) &&
                        (x <= (rctButtonA[0][0] + rctButtonA[1][0])) && 
                        (y <= (rctButtonA[0][1] + rctButtonA[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        ctlKeyButtonA;

                    if ((x >= rctButtonB[0][0]) && (y >= rctButtonB[0][1]) &&
                        (x <= (rctButtonB[0][0] + rctButtonB[1][0])) && 
                        (y <= (rctButtonB[0][1] + rctButtonB[1][1])))
                      globals->prefs->game.keyMaskSpecial |= 
                        ctlKeyButtonB;

                    // we have handled this event, lets continue
                    processed = TRUE;
                  }
                }
                break;

           default:
                break;
         }
         break;

    case NULL_EVENT:
         {
           UWORD keyState;

           // get the key press state
           keyState = DeviceKeyCurrentState() |
                      globals->prefs->game.keyMaskSpecial;
           globals->prefs->game.keyMaskSpecial = 0;

           // perform the emulation!
           GameEmulation(globals->prefs, keyState);
         }

         processed = TRUE;
         break;

    case EVT_FORM_CLOSE:

         // terminate the game
         AnimateStop();
         GameTerminate(globals->prefs);

         processed = TRUE;
         break;

    default:
         break;
  }

  return processed;
}

/**
 * The Form:infoForm event handling routine.
 *
 * @param event the event to process.
 * @return true if the event was handled, false otherwise.
 */
static BOOLEAN 
infoFormEventHandler(EvtType *event)
{
  BOOLEAN processed = FALSE;

  switch (event->eventType)
  {
    case EVT_FORM_OPEN:
         FormDrawForm(infoForm);

         // configure
         EvtAppendEvt(EVT_FORM_CONFIGURE,0,0,0,NULL);
         processed = TRUE;
         break;

    case EVT_FORM_CONFIGURE:
         processed = TRUE;
         break;

    case EVT_CONTROL_SELECT:

         switch (event->eventID) 
         {
           case infoFormOkButton:

                // close the current form
                EvtAppendEvt(EVT_FORM_CLOSE,0,0,0,NULL);

                processed = TRUE;
                break;

           default:
                break;
         }
         break;

    case EVT_INLAY_SELECT:

         // which button?
         switch (event->para1)
         {
           case INLAY_OK:
                // relay the event
                EvtAppendEvt(EVT_CONTROL_SELECT,infoFormOkButton,0,0,NULL);

                // play a little snd
                SndPlaySndEffect(SNDRES5_BEEP);

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
 * The Palm Computing Platform initialization routine.
 */
void  
InitApplication()
{
  // initialize the device
  DeviceInitialize();
  AnimateInitialize();
  GfxInitialize();

  // define the terminal font for debugging
  GfxDefineFont(gfx_termsmall, 
                font40Size, font40, 
                font40WindowWidth, font40WindowHeight, font40Width);


  // create the globals reference
  globals = (Globals *)pmalloc(sizeof(Globals));
  memset(globals, (UBYTE)0, sizeof(Globals));

  // load preferences
  {
    SHORT prefSize;
    SHORT flag;

    // allocate memory for preferences
    globals->prefs = (PreferencesType *)pmalloc(sizeof(PreferencesType));

    // lets see how large the preference is (if it is there)
    prefSize = 0;
    flag     = DeviceGetAppPreferences(NULL, &prefSize, TRUE);

    // we have some preferences, maybe a match :)
    if ((flag != noPreferenceFound) && (prefSize == sizeof(PreferencesType))) {

      // extract all the bytes
      DeviceGetAppPreferences(globals->prefs,&prefSize,TRUE);
    }

    // we need to reset the preferences..
    else {

      // set default values
      memset(globals->prefs, (UBYTE)0, prefSize);
    }
  }

  // process the "launch" as appropriate
  {
    BOOLEAN    ok;
    DatabaseID dbID;

    // can we locate the "preference" database?
    ok = FALSE;
    if (DataFindDB((BYTE *)("Gmbt_ROMNAME"), &dbID)) {

      RecordID recID;
      UWORD    numRec;

      // open the database
      DataOpenDB(dbID,0,OPEN_RW);

      // find the record
      DataTotalRecord(dbID,&numRec);
      if (numRec != 0) {

        BYTE* buffer;
        UWORD bufSize;
        AppID romID;

        // open the record, and extract the rom name
        DataOpenRecord(dbID,0,&recID,NULL);
        DataGetField(dbID,recID,0,&buffer,&bufSize);

        // verify the "application" (GB rom) exists
        if (SysGetAppID(buffer,&romID)) {
          memcpy(globals->prefs->game.strGBRomName,buffer,bufSize);
          ok = TRUE;                      // we have a valid rom, lets go!
        }

        // clean up
        qfree(buffer);
        DataCloseRecord(dbID,recID);
      }
      DataCloseDB(dbID);
    }

    // rom found? - goto main form
    if (ok)
      FormGotoForm(mainForm);

    // rom not found? - exit emulator
    else 
      EvtAppendEvt(EVT_INLAY_SELECT,0,INLAY_MAIN_MENU,0,NULL);
  }
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

               case infoForm:
                    FormSetEventHandler(infoForm, 
                                        (void **)&FormDispatchEvent, 
                                        (void *)infoFormEventHandler);
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
         
    case EVT_IO_KEY_CTRL:

         switch (event->eventID)
         {
           case EVT_IO_KEY_PRESS:
           case EVT_IO_KEY_REPEAT:

                // does the form wanna handle it?
                processed = FormDispatchEvent(event);

                // ok, if it is one of the following, we want to ignore it
                switch (event->para2)
                {
                  case IO_PHONE_BOOK:
                  case IO_SCHEDULER:
                  case IO_TO_DO_LIST:
                  case IO_UP_ARROW:
                  case IO_DOWN_ARROW:

                       // we are playing! ignore all these keys :P
                       processed = TRUE;
                       break;

                  default:
                       break;
                }
                break;

           default:
                break;
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

    case PEN_EVENT:

         // what type?
         switch (event->eventID)
         {
           case PEN_DOWN:
           case PEN_MOVE:
           case PEN_UP:

                // does the form wanna handle it?
                processed = mainFormEventHandler(event);

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
 * Display a MODAL dialog to the user.
 *
 * @param formID the ID of the form to display.
 */
void
ApplicationDisplayDialog(ObjectID formID)
{
  ObjectID   prevFormID;
  BOOLEAN    appStop, powerDown;
  EvtType    bufEvent;
  GfxWindow *currWindow;

  // save the active form/window
  FormGetActiveFormID(&prevFormID);
  FormSaveBehindBits(prevFormID);
  currWindow = GfxGetDrawWindow();

  GfxSetDrawWindow(GfxGetDisplayWindow());
  appStop   = FALSE;
  powerDown = FALSE;
  {
    BOOLEAN keepFormOpen;
    EvtType event;

    // send load form and open form events
    EvtAppendEvt(EVT_FORM_LOAD, formID, 0, 0, NULL);
    EvtAppendEvt(EVT_FORM_OPEN, formID, 0, 0, NULL);

    // handle all events here (trap them before the OS does) :)
    keepFormOpen = TRUE;
    while (keepFormOpen) {

      EvtGetEvent(&event);

      // this is our exit condition! :)
      keepFormOpen = (event.eventType != EVT_FORM_CLOSE);

      // we have to process the following events in a special way
      if ((event.eventType == EVT_INLAY_SELECT) &&
          (event.para1     == INLAY_MAIN_MENU)) {

        // close the dialog
        EvtAppendEvt(EVT_FORM_CLOSE,0,0,0,NULL);

        // relay the main menu event
        EvtAppendEvt(EVT_INLAY_SELECT,0,INLAY_MAIN_MENU,0,NULL);
      }
      else
      if ((event.eventType == EVT_INLAY_SELECT) &&
          (event.para1     == INLAY_EXIT)) {

        // relay it as an "OK" button press
        EvtAppendEvt(EVT_INLAY_SELECT,0,INLAY_OK,0,NULL);
      }

      // handle the event as required
      else
      if (!ApplicationHandleEvent(&event)) 
        if (!SystemHandleEvent(&event)) 
          if (!MenuHandleEvent(&event)) 
            FormDispatchEvent(&event);

      // stop the app?
      if (event.eventType == EVT_APP_STOP) {

        keepFormOpen = FALSE;
        appStop      = TRUE;

        DeviceGetEvent(&bufEvent, 0);

        // is there a power-down event coming?
        if (bufEvent.eventType == EVT_POWER_DOWN)
          powerDown = TRUE;
      }
    }
  }

  // restore the active form/window
  FormRestoreBitBehind(prevFormID);
  FormSetActiveForm(prevFormID);

  // if not exiting app, return to the previous app
  if (!appStop) {
    EvtAppendEvt(EVT_FORM_LOAD,prevFormID,0,0,NULL);
    EvtAppendEvt(EVT_FORM_CONFIGURE,0,0,0,NULL);
  }
  // need to add the "APP_STOP" event?
  else {
    EvtAppendEvt(EVT_APP_STOP, 0, 0, 0, NULL);

    // need to add the "POWER_DOWN" event?
    if (powerDown) EvtAppendEvt(EVT_POWER_DOWN, 0, 0, 0, NULL);
    else           EvtAppendEvt(bufEvent.eventType,bufEvent.eventID,
                                bufEvent.para1,bufEvent.para2,bufEvent.evtPBP);
  }

  GfxSetDrawWindow(currWindow);
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
  // save preferences
  DeviceSetAppPreferences(globals->prefs,sizeof(PreferencesType),TRUE);
  
  // clean up
  pfree(globals);

  // reset the device to its normal state
  GfxTerminate();
  AnimateTerminate();
  DeviceTerminate();
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
           InitApplication();
           EventLoop();
           EndApplication();
         }
         result = TRUE;
         break;

    default:
         break;
  }

  return result;
}
