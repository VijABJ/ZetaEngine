//#############################################################################
//
// Zeta Engine Main Header
// Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)
// 
// This file is part of the ZetaEngine 
//
// ZetaEngine is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// ZetaEngine is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Foobar; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//  
//#############################################################################

//#############################################################################
//
// ZetaLib.hpp
// Author: Virgilio A. Blones, Jr. (Vij) <ZipBreak@hotmail.com>
//
// <Description>
// This file contains all the type declarations and definitions required
// by the Zeta Engine.  All functions/subroutines are also declared within
// this file.  This is the ONLY file required to be #include`d in order
// to use the Zeta Engine API.
//
// <Version History>
// $Header$
// $Log$
//  
//#############################################################################

#ifndef __ZETA_ENGINE_LIBRARY_HEADER__
#define __ZETA_ENGINE_LIBRARY_HEADER__

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <objbase.h>


//#############################################################################
// Names Of GUI Controls 

// class names for ZEWSBase
#define CC_BASE_CONTROL             "Control"
#define CC_BASE_GROUP               "GroupControl"
// class names for ZEWSButtons
#define CC_STANDARD_BUTTON          "StandardButton"
#define CC_ICON_BUTTON              "IconButton"
#define CC_PICTURE_BUTTON           "PictureButton"
#define CC_PUSH_PANEL               "PushPanel"
#define CC_PICTURE_PANEL            "PicturePanel"
#define CC_CHECKBOX                 "Checkbox"
// class names for ZEWSLineEdit
#define CC_CUSTOM_EDIT_CONTROL      "CustomEdit"
#define CC_EDIT_CONTROL             "Edit"
#define CC_NUMERIC_EDIT_CONTROL     "NumericEdit"
// class names for ZEWSMisc
#define CC_CUSTOM_GAUGE             "CustomGauge"
#define CC_CUSTOM_SCROLLBOX         "CustomScrollBox"
#define CC_PROGRESS_GAUGE           "ProgressGauge"
#define CC_PROGRESS_GAUGE_ENH       "ProgressGaugeEnh"
#define CC_SCROLL_GAUGE             "ScrollGauge"
#define CC_PANEL_GROUP              "PanelGroup"
// class names for ZEWSStandard
#define CC_CUSTOM_DECOR_IMAGE       "CustomDecorImage"
#define CC_DECOR_IMAGE              "DecorImage"
#define CC_WALLPAPER                "Wallpaper"
#define CC_WINBORDERS               "WinBorders"
#define CC_TEXT                     "Text"
#define CC_LABEL                    "Label"
#define CC_CUSTOM_PUSH_BUTTON       "CustomPushButton"
#define CC_CUSTOM_TOGGLE_BUTTON     "CustomToggleButton"
#define CC_CUSTOM_PUSH_PANEL        "CustomPushPanel"
// class names for ZEWSDialogs
#define CC_STANDARD_WINDOW          "StandardWindow"
#define CC_DESKTOP                  "Desktop"
#define CC_ROOT_WINDOW              "RootWindow"
#define CC_CUSTOM_DIALOG            "CustomDialog"
#define CC_OK_CANCEL_DIALOG         "OKCancelDialog"
// class names for the game UI classes
#define CC_GAME_WINDOW              "GameWindow"
#define CC_CUT_SCENE_VIEW           "CutSceneView"
#define CC_GAME_MAIN_MENU           "GameMainMenu"


//#############################################################################
// Names Of UI Element Properties 

// property names for ZEWSBase module
#define PROP_NAME_WINCLASS_NAME      "WClassName"
#define PROP_NAME_ACTION_NAME        "ActionName"
#define PROP_NAME_BOUNDS             "Bounds"
#define PROP_NAME_CAPTION            "Caption"
#define PROP_NAME_CONTROL_NAME       "Name"
#define PROP_NAME_BACKCOLOR          "BackColor"
#define PROP_NAME_SPRITE_NAME        "Sprite"
#define PROP_NAME_FONT_NAME          "Font"
// property names for ZEWSButtons
#define PROP_NAME_GROUP_ID           "GroupId"
#define PROP_NAME_PICTURE            "Picture"
// property names for ZEWSStandard
#define PROP_NAME_REPEAT_X           "RepeatX"
#define PROP_NAME_REPEAT_Y           "RepeatY"
#define PROP_NAME_CENTER_X           "CenterX"
#define PROP_NAME_CENTER_Y           "CenterY"
#define PROP_NAME_AUTO_WIDTH         "AutoWidth"
#define PROP_NAME_AUTO_HEIGHT        "AutoHeight"
#define PROP_NAME_ANIMATES           "Animates"
#define PROP_NAME_ANIMATE_TICK       "AnimateTick"
//
#define PROP_NAME_PRESSED            "Pressed"
#define PROP_NAME_COMMAND            "Command"
#define PROP_NAME_AUTO_POPUP         "AutoPopup"
#define PROP_NAME_THREE_STATE        "ThreeState"
#define PROP_NAME_SHOW_CAPTION       "ShowCaption"
// property names for ZEWSLineEdit
#define PROP_NAME_NUMEDIT_MAX        "NumEditMax"
#define PROP_NAME_NUMEDIT_MIN        "NumEditMin"
//
#define PROP_NAME_CHECKED            "Checked"
#define PROP_NAME_DRAW_BORDERS       "DrawBorders"
// property names for ZEWSMisc
#define PROP_NAME_FILLER_IMAGE       "FillerImage"
#define PROP_NAME_GAUGE_MIN          "GaugeMinimum"
#define PROP_NAME_GAUGE_MAX          "GaugeMaximum"
#define PROP_NAME_GAUGE_CURRENT      "GaugeCurrent"
#define PROP_NAME_GAUGE_STYLE        "GaugeStyle"
#define PROP_NAME_GAUGE_DIRECTION    "GaugeDirection"


//#############################################################################
// Names Of GameUsed Entities 

// names of default scripts
#define SCRIPT_GAME_GUI             "GameGUI"
#define SCRIPT_USER_EVENTS          "UserEventHandler"
// names of the default game desktops
#define DESKTOP_CUT_SCENE           "DTCutScene"
#define DESKTOP_MAIN                "DTMain"
#define DESKTOP_MENU                "DTMenu"


//#############################################################################
// Predefined Commands 

const int cmStandardSystemBase  = 0;
const int cmStandardSystemMax   = cmStandardSystemBase + 199;
//
const int cmError               = cmStandardSystemBase - 1;
const int cmNothing             = cmStandardSystemBase + 0;
const int cmOK                  = cmStandardSystemBase + 1;
const int cmCancel              = cmStandardSystemBase + 2;
const int cmYes                 = cmStandardSystemBase + 3;
const int cmNO                  = cmStandardSystemBase + 4;
const int cmAbort               = cmStandardSystemBase + 5;
const int cmRetry               = cmStandardSystemBase + 6;
const int cmGetFocus            = cmStandardSystemBase + 7;
const int cmReleaseFocus        = cmStandardSystemBase + 8;
const int cmHelp                = cmStandardSystemBase + 9;
const int cmExit                = cmStandardSystemBase + 10;
const int cmExitConfirm         = cmStandardSystemBase + 11;
const int cmFinalExit           = cmStandardSystemBase + 12;
const int cmCycleForward        = cmStandardSystemBase + 13;
const int cmCycleBackward       = cmStandardSystemBase + 14;
const int cmGetDefault          = cmStandardSystemBase + 15;
const int cmReleaseDefault      = cmStandardSystemBase + 16;
const int cmClose               = cmStandardSystemBase + 17;
const int cmResize              = cmStandardSystemBase + 18;
const int cmZoom                = cmStandardSystemBase + 19;
const int cmDrag                = cmStandardSystemBase + 20;
const int cmGotoPrev            = cmStandardSystemBase + 21;
const int cmGotoNext            = cmStandardSystemBase + 22;
const int cmSystemMenu          = cmStandardSystemBase + 23;
const int cmDefault             = cmStandardSystemBase + 24;
const int cmMove                = cmStandardSystemBase + 25;
const int cmCommandsChanged     = cmStandardSystemBase + 26;
const int cmMoveWithMouse       = cmStandardSystemBase + 27;

//#############################################################################
// other standard commands
const int cmGUICommandBase      = 200;
const int cmGUICommandMax       = cmGUICommandBase + 199;

const int cmPanelClicked        = cmGUICommandBase + 1;
const int cmAcquirePanelFocus   = cmGUICommandBase + 2;
const int cmPBSelectNext        = cmGUICommandBase + 3;
const int cmPBSelectPrevious    = cmGUICommandBase + 4;

const int cmDesktopHidden       =  cmGUICommandBase + 11;
const int cmDesktopShown        =  cmGUICommandBase + 12;


//#############################################################################
// Typedes And Contansts 

typedef char* PCHAR ;
typedef int tINTBOOL;
typedef int tCONTROL;
typedef int tCALLBACK;

const tCONTROL tNULL_CONTROL = 0;
const tINTBOOL IBOOL_TRUE = 1;
const tINTBOOL IBOOL_FALSE = 0;

#define NULL_CONTROL(tCTL) (tCTL == tNULL_CONTROL)
#define ITRUE(tIB)    (tIB == IBOOL_TRUE)
#define IFALSE(tIB)   (tIB == IBOOL_FALSE)

#ifdef ZETALIB_CPP_MODULE
tINTBOOL iInitialized;
#else
extern tINTBOOL iInitialized;
#endif

//#############################################################################

DECLARE_INTERFACE(IZEUnknown)
{
  // *** IUnknown methods ***
  STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID FAR* ppvObj);
  STDMETHOD_(ULONG,AddRef) (THIS);
  STDMETHOD_(ULONG,Release) (THIS);
};
typedef IZEUnknown* PZEUnknown;

// interface                                     
DECLARE_INTERFACE_(IZEWinWrap, IZEUnknown)
{
  // *** IZEWinWrap
  STDMETHOD(Prepare) (THIS_ PCHAR lpszConfigFile, 
    tCALLBACK lpfnCreateUICallback, tCALLBACK lpfnHandleEventCallback);
  STDMETHOD(InitWindow) (THIS_ HINSTANCE hAppInstance, PCHAR WindowClassName,
    PCHAR WindowTitle, tCALLBACK WindowProc, DWORD WindowFlags, int iWidth, int iHeight);
  virtual void STDMETHODCALLTYPE Execute ();
};
typedef IZEWinWrap* PZEWinWrap;

//#############################################################################
// API Declarations 

#define ZETACMD(intCommand) ((PCHAR) ZELib_IntToStr (intCommand))

int       ZELib_Initialize ();
void      ZELib_Shutdown ();
const char* ZELib_IntToStr (int iValue);

int       ZEWW_Prepare (PCHAR lpszConfigFile, tCALLBACK lpfnCreateUICallback, 
            tCALLBACK lpfnHandleEventCallback);
tINTBOOL  ZEWW_CreateWindow (int ClassRef, HINSTANCE hAppInstance, PCHAR WindowClassName,
            PCHAR WindowTitle, tCALLBACK WindowProc, DWORD WindowFlags, int iWidth, int iHeight);
void      ZEWW_Execute (int ClassRef);
void      ZEWW_Shutdown (int ClassRef);

tINTBOOL  ZEE_Initialize (PCHAR lpszConfigurationFile, HWND hHostWindow, HINSTANCE hAppInstance);
void      ZEE_Shutdown ();
void      ZEE_TerminateSelf ();
void      ZEE_Activate ();
void      ZEE_Deactivate ();
tINTBOOL  ZEE_Refresh ();

int       ZEE_ScreenWidth ();
int       ZEE_ScreenHeight ();
int       ZEE_ScreenColorDepth ();

void      ZEE_SetMusic (PCHAR lpszMusicName);
void      ZEE_ClearMusic ();
void      ZEE_PlaySound (PCHAR lpszSoundName);
void      ZEE_PlayCutScene (PCHAR lpszCutSceneFile);

tINTBOOL  ZEE_IsMusicActive ();
void      ZEE_ToggleMusic (tINTBOOL ibActive);
tINTBOOL  ZEE_IsSoundActive ();
void      ZEE_ToggleSound (tINTBOOL ibActive);
void      ZEE_ToggleFPSDisplay (tINTBOOL ibVisible);
 
tINTBOOL  ZEE_IsGlobalExitOnEscapeSet ();
void      ZEE_ToggleGlobalExitOnEscape (tINTBOOL ibActive);


tCONTROL  ZEUI_Root ();
tCONTROL  ZEUI_CreateDesktop (PCHAR lpszRefName, PCHAR lpszDeskName);
tCONTROL  ZEUI_SwitchDesktop (PCHAR lpszRefName);
tCONTROL  ZEUI_GetDesktop (PCHAR lpszRefName);
tCONTROL  ZEUI_CreateGameView (int Left, int Top, int Right, int Bottom);

tCONTROL  ZEUI_CreateControl (PCHAR lpszClassName, int Left, int Top, int Right, int Bottom);
void      ZEUI_InsertControl (tCONTROL ctlDest, tCONTROL ctlToInsert);
PCHAR     ZEUI_GetProp (tCONTROL ControlRef, PCHAR lpszPropName);
void      ZEUI_SetProp (tCONTROL ControlRef, PCHAR lpszPropName, PCHAR lpszPropValue);

void      ZEUI_ShowMsgBox (PCHAR cMessage);
void      ZEUI_ShowMsgBoxEx (PCHAR cMessage, int Left, int Top, int Right, int Bottom);
void      ZEUI_Hide (tCONTROL ControlRef);
void      ZEUI_Show (tCONTROL ControlRef);

void      ZEGE_LoadWorld (PCHAR lpszWordFile);

void      ZEGE_CreatePC (PCHAR lpszMasterName, PCHAR lpszWorkingName, tCALLBACK lpfnCallback);
void      ZEGE_ReplacePC (PCHAR lpszMasterName, PCHAR lpszWorkingName, tCALLBACK lpfnCallback);
void      ZEGE_ClearPC ();

void      ZEGE_DropPC ();
void      ZEGE_DropPCEx (PCHAR lpszAreaName, int X, int Y, int Z);
void      ZEGE_UnDropPC ();

void      ZESS_ClearCallbacks ();
void      ZESS_AddCallback (PCHAR lpszRefName, tCALLBACK lpfnCallback);
void      ZESS_TerminateEngine ();

PZEWinWrap    ZEIntf_GetWinWrap ();

#endif /* __ZETA_ENGINE_LIBRARY_HEADER__ */


