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
// <Notes>
// Zeta Engine uses COM interfaces that are directly accessed.  
//
// zeta     : Main interface, used to retrieve the other interfaces
// utils    : for utility functions, basically those that can't be
//            included in the other categories
// winwrap  : wrapper for Windows(TM) windowing system
// core     : engine manipulations
// uim      : user interface manager, for creating buttons, wallpapers,
//            and the like
// world    : manipulates game worlds and entities
//
//
// <Version History>
// $Header: /users/vij/backups/CVS/ZetaEngine/CPP-API/ZetaLib.h,v 1.2 2002/12/18 08:29:45 Vij Exp $
// $Log: ZetaLib.h,v $
// Revision 1.2  2002/12/18 08:29:45  Vij
// synchronized with DLL content
//
// Revision 1.1  2002/11/02 07:10:30  Vij
// re-added to version control using *.h instead of *.hpp
//
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
#include <math.h>
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
#define CC_SCROLLBAR                "ScrollBar"
#define CC_TEXT_BOX                 "TextBox"
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
#define CC_OK_DIALOG                "OKDialog"
#define CC_OK_CANCEL_DIALOG         "OKCancelDialog"
#define CC_CUSTOM_STRINPUT_DIALOG   "CustomStrInputDialog"
#define CC_MESSAGE_DIALOG           "MessageDialog"
#define CC_TEXT_DIALOG              "TextDialog"

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
#define PROP_NAME_CONSUME_CLICK      "ConsumeClick"
#define PROP_NAME_NEXT_SPRITE        "NextSprite"
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
#define PROP_NAME_FILLER_COLOR       "FillerColor"
#define PROP_NAME_FILLER_IMAGE       "FillerImage"
#define PROP_NAME_GAUGE_MIN          "GaugeMinimum"
#define PROP_NAME_GAUGE_MAX          "GaugeMaximum"
#define PROP_NAME_GAUGE_CURRENT      "GaugeCurrent"
#define PROP_NAME_GAUGE_STYLE        "GaugeStyle"
#define PROP_NAME_GAUGE_DIRECTION    "GaugeDirection"

#define PROP_NAME_AUTO_SCROLL        "AutoScroll"
#define PROP_NAME_TEXT_TO_ADD        "TextToAdd"
#define PROP_NAME_FILE_TO_LOAD       "FileToLoad"


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

//
const int cmStandardSystemBase  = 0;
const int cmStandardSystemMax   = cmStandardSystemBase + 199;
//
const int cmGlobalError         = cmStandardSystemBase - 1;
const int cmGlobalNull          = cmStandardSystemBase + 0;
const int cmGlobalInit          = cmStandardSystemBase + 1;
const int cmGlobalShutdown      = cmStandardSystemBase + 2;
const int cmGlobalActivated     = cmStandardSystemBase + 3;
const int cmGlobalDeactivated   = cmStandardSystemBase + 4;
const int cmGlobalExitQuery     = cmStandardSystemBase + 5;
const int cmGlobalExitFinal     = cmStandardSystemBase + 6;
const int cmFinalExit           = cmGlobalExitFinal; // for backward compatibility
//
const int cmEngineCommandBase   = 50;
const int cmEngineTimerExpired  = cmEngineCommandBase + 0;
const int cmEngineTimerTick     = cmEngineCommandBase + 1;
//
const int cmStdCommandBase      = 100;
const int cmOK                  = cmStdCommandBase + 0;
const int cmCancel              = cmStdCommandBase + 1;
const int cmNothing             = cmStdCommandBase + 2;
const int cmReleaseFocus        = cmStdCommandBase + 3;
const int cmYes                 = cmStdCommandBase + 4;
const int cmNo                  = cmStdCommandBase + 5;
const int cmAbort               = cmStdCommandBase + 6;
const int cmRetry               = cmStdCommandBase + 7;
// GUI Commands
const int cmGUICommandBase      = 200;
const int cmGUICommandMax       = cmGUICommandBase + 199;
// used in ZEWSButtons
const int cmPanelClicked        = cmGUICommandBase + 1;
const int cmAcquirePanelFocus   = cmGUICommandBase + 2;
const int cmPBSelectNext        = cmGUICommandBase + 3;
const int cmPBSelectPrevious    = cmGUICommandBase + 4;
// used in ZEWSDialogs
const int cmDesktopHidden       = cmGUICommandBase + 11;
const int cmDesktopShown        = cmGUICommandBase + 12;
const int cmRemoveDialog        = cmGUICommandBase + 13;
const int cmDialogClosed        = cmGUICommandBase + 14;
// used in ZEWSMisc
const int cmScrollerUpdated     = cmGUICommandBase + 21;
const int cmScrollBarChanged    = cmGUICommandBase + 22;
const int cmScrollBoxChanged    = cmGUICommandBase + 23;
const int cmDecorEndSequence    = cmGUICommandBase + 24;
const int cmDecorClicked        = cmGUICommandBase + 25;
// from ZZEWorld
const int cmWorldCommandBase    = 400;
const int cmUnloadingArea       = cmWorldCommandBase + 1;
const int cmLoadingArea         = cmWorldCommandBase + 2;
const int cmDeletedArea         = cmWorldCommandBase + 3;
const int cmWorldLoaded         = cmWorldCommandBase + 4;

//#############################################################################
// Typedes And Constants 

typedef char* PCHAR ;
typedef int tINTBOOL;
typedef int tCONTROL;
typedef int tCALLBACK;

typedef struct tagTZbPoint {
  int X;
  int Y;
} TZbPoint, *PZbPoint;

typedef struct tagTZbVector {
  int X;
  int Y;
  int Z;
} TZbVector, *PZbVector;

typedef enum TZbDirection {tdUnknown = 0, 
  tdNorth, tdNorthEast, tdEast, tdSouthEast,
  tdSouth, tdSouthWest, tdWest, tdNorthWest};

#define RandomDirection() ((TZbDirection) ((int) (floor (rand () % 9))))

typedef enum TZEEntityEvent {eeArrived = 0,
  eeStopped, eePerformBegins, eePerformEnds, eeQueryMove,
  eeActionRequest, eeTimerFired, eeDoActionMain, eeDoActionOther, 
  eeTriggerPortal, eeEndOfList};

// callback prototypes
typedef int __stdcall RemoteEntityCallback (int Sender, 
  TZEEntityEvent Event, void* pParam1, void* pParam2,
  int lParam1, int lParam2);
typedef RemoteEntityCallback* lpRemoteEntityCallback;

typedef int __stdcall ZetaCallback (int lParam1, int lParam2);
typedef ZetaCallback* lpZetaCallback;

// constants
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

#define ZTRACE(S) OutputDebugString (S)
#define ZTRACELN(S) OutputDebugString (S); OutputDebugString ("\n")

//#############################################################################
// Zeta-Engine Interfaces, will probably port these to COM later.

// IZEUnknown
DECLARE_INTERFACE(IZEUnknown)
{
  // *** IUnknown methods ***
  STDMETHOD(QueryInterface) (REFIID riid, LPVOID FAR* ppvObj);
  STDMETHOD_(ULONG,AddRef) ();
  STDMETHOD_(ULONG,Release) ();
};
typedef IZEUnknown* PZEUnknown;

DECLARE_INTERFACE_(IZEString, IZEUnknown)
{
  STDMETHOD_(PCHAR, GetPointer) ();
  STDMETHOD_(int, GetSize) ();
  STDMETHOD_(void, CopyToBuffer) (PCHAR DestBuf, int iBufLen);
};
typedef IZEString* PZEString;

// IZEUtils
DECLARE_INTERFACE_(IZEUtils, IZEUnknown)
{
  STDMETHOD_(void, CallbackClear) ();
  STDMETHOD_(void, CallbackAdd) (PCHAR lpszRefName, tCALLBACK lpfnCallback);
  //
  STDMETHOD_(int, GetExitOnEscape) ();
  STDMETHOD_(void, SetExitOnEscape) (int iActive);
  STDMETHOD_(int, GetShowGrid) ();
  STDMETHOD_(void, SetShowGrid) (int iActive);
  STDMETHOD_(int, GetShowPortals) ();
  STDMETHOD_(void, SetShowPortals) (int iActive);
  STDMETHOD_(int, GetEditMode) ();
  STDMETHOD_(void, SetEditMode) (int iActive);
};
typedef IZEUtils* PZEUtils;

// IZEWinWrap                                    
DECLARE_INTERFACE_(IZEWinWrap, IZEUnknown)
{
  // *** IZEWinWrap
  STDMETHOD(Prepare) (PCHAR lpszConfigFile, 
    lpZetaCallback lpfnCreateUICallback, lpZetaCallback lpfnHandleEventCallback);
  STDMETHOD(InitWindow) (HINSTANCE hAppInstance, PCHAR WindowClassName,
    PCHAR WindowTitle, tCALLBACK WindowProc, DWORD WindowFlags, int iWidth, int iHeight);
  STDMETHOD_(void, Execute) ();
};
typedef IZEWinWrap* PZEWinWrap;

typedef int IZEUIControl;
typedef enum TZbKeyState {ksNothing = 0, ksPressed, ksReleased};
typedef int __stdcall _TZbKeyCallback (int AKey, TZbKeyState AEvent, int UserData);
typedef _TZbKeyCallback* TZbKeyCallback;

// IZECore
DECLARE_INTERFACE_(IZECore, IZEUnknown)
{
  STDMETHOD_(int, ScreenWidth) ();
  STDMETHOD_(int, ScreenHeight) ();
  STDMETHOD_(int, ScreenColorDepth) ();
  //
  STDMETHOD(PlayMusic) (PCHAR lpszMusicName);
  STDMETHOD(ClearMusic) ();
  STDMETHOD(PlaySound) (PCHAR lpszSoundName);
  STDMETHOD(PlayCutScene) (PCHAR lpszCutSceneFile);
  //
  STDMETHOD(IsMusicActive) ();
  STDMETHOD_(void, ToggleMusic) (int bActive);
  STDMETHOD(IsSoundActive) ();
  STDMETHOD_(void, ToggleSound) (int bActive);
  //
  STDMETHOD_(void, ToggleFPSDisplay) (int bActive);
  STDMETHOD_(void, MoveFPSDisplay) (int X, int Y);
  //
  STDMETHOD_(void, RunDialog) (IZEUIControl Control);
  STDMETHOD_(void, ShowInputBox) (PCHAR lpszPrompt, int iCommand, int ANoCancel);
  STDMETHOD_(void, ShowMsgBox) (PCHAR cMessage);
  STDMETHOD_(void, ShowMsgBox2) (PCHAR cMessage, int SendCommand);
  STDMETHOD_(void, ShowMsgBoxEx) (PCHAR cMessage, 
    int Left, int Top, int Right, int Bottom, int Command = cmNothing);
  STDMETHOD_(void, ShowTextDialog) (int iWidth, int iHeight, PCHAR lpszFileName, PCHAR lpszFontName);
  STDMETHOD_(void, ShowPromptDialog) (int iWidth, int iHeight, PCHAR lpszPrompt, int iCommandToGenerate);
  //
  STDMETHOD_(void, TogglePause) (int bActive);
  STDMETHOD_(int, GetPauseState) ();
  STDMETHOD_(void, Terminate) ();
  //
  STDMETHOD_(void, PushEvent) (int EventCommand);
  STDMETHOD_(void, StartTimer) (int ATimerValue);
  STDMETHOD_(void, StartTimerEx) (int AMinutes, int ASeconds);
  //
  STDMETHOD_(void, AddKeyHook) (int KeyCode, TZbKeyCallback lpfnUserHandler);
  STDMETHOD_(void, ClearKeyHook) (int KeyCode);
  //
  STDMETHOD_(void, ToggleHighlight) (int bActive);
  STDMETHOD_(int, RandomInt) (int Range);
  //
  STDMETHOD_(void, SetMusicVolume) (int VolumePercent);
};
typedef IZECore* PZECore;

// IZEUIManager
DECLARE_INTERFACE_(IZEUIManager, IZEUnknown)
{
  STDMETHOD_(IZEUIControl, GetRoot) ();
  STDMETHOD(CreateDesktop) (PCHAR lpszRefName, PCHAR lpszDeskName);
  STDMETHOD(SwitchDesktop) (PCHAR lpszRefName);
  STDMETHOD_(IZEUIControl, GetDesktop) (PCHAR lpszRefName);
  //
  STDMETHOD_(IZEUIControl, CreateControl) (PCHAR lpszClassName,
    int Left, int Top, int Right, int Bottom);
  STDMETHOD_(IZEUIControl, CreateGameView) (int Left, int Top, int Right, int Bottom);
  //
  STDMETHOD_(PZEString, GetProp) (IZEUIControl Control, PCHAR lpszPropName);
  STDMETHOD_(void, SetProp) (IZEUIControl Control, PCHAR lpszPropName, PCHAR lpszPropValue);
  STDMETHOD_(void, ToggleParentFontUse) (IZEUIControl Control, int bActive);
  //
  STDMETHOD_(void, Insert) (IZEUIControl Container, IZEUIControl Control);
  STDMETHOD_(void, Show) (IZEUIControl Control);
  STDMETHOD_(void, Hide) (IZEUIControl Control);
  //
  STDMETHOD_(void, IsVisible) (IZEUIControl Control);
  STDMETHOD_(void, Enable) (IZEUIControl Control, int bActive);
  //
  STDMETHOD_(int, GetXPos) (IZEUIControl Control);
  STDMETHOD_(int, GetYPos) (IZEUIControl Control);
  STDMETHOD_(int, GetWidth) (IZEUIControl Control);
  STDMETHOD_(int, GetHeight) (IZEUIControl Control);
  //
  STDMETHOD_(void, MoveTo) (IZEUIControl Control, int NewX, int NewY);
  STDMETHOD_(void, MoveRel) (IZEUIControl Control, int DeltaX, int DeltaY);
  STDMETHOD_(void, Resize) (IZEUIControl Control, int NewWidth, int NewHeight);
  //
  STDMETHOD_(void, Delete) (IZEUIControl Control);
};
typedef IZEUIManager* PZEUIManager;

// IZEGameEntity
typedef struct IZEZetaEntity* PZEZetaEntity;
typedef int __stdcall TZERemoteEntityCallback (int hEntity, 
  TZEEntityEvent Event, void* pParam1, void* pParam2, int lParam1, int lParam2);
DECLARE_INTERFACE_(IZEZetaEntity, IZEUnknown)
{
  STDMETHOD_(int, GetInternalData) ();
  STDMETHOD_(PZEZetaEntity, Duplicate) ();
  //
  STDMETHOD_(PZEString, GetName) ();
  STDMETHOD_(PZEString, GetBaseName) ();
  STDMETHOD_(int, GetWidth) ();
  STDMETHOD_(int, GetLength) ();
  STDMETHOD_(int, IsOrientable) ();
  STDMETHOD_(int, CanMove) ();
  STDMETHOD_(int, MovementRate) ();
  STDMETHOD_(int, Updateable) ();
  //
  STDMETHOD_(int, OnMap) ();
  STDMETHOD_(int, OnActiveArea) ();
  //
  STDMETHOD_(int, Orientation) ();
  STDMETHOD_(PZEString, GetStateInfo) ();
  STDMETHOD_(void, SetStateInfo) (PCHAR AStateInfo);
  //
  STDMETHOD_(void, SetHandler) (TZERemoteEntityCallback ANewHandler);
  STDMETHOD_(void, ClearHandler) ();
  STDMETHOD_(int, GetHandlerData) ();
  STDMETHOD_(void, SetHandlerData) (int HData);
  //
  STDMETHOD_(void, BeginPerform) (PCHAR APerformState, int ibImmediate);
  STDMETHOD_(int, CanPerform) (PCHAR APerformState);
  STDMETHOD_(int, IsPerforming) ();
  //
  STDMETHOD_(void, ClearActions) ();
  STDMETHOD_(void, MoveTo) (int X, int Y, int Z);
  //
  STDMETHOD_(int, CanSee) (PZEZetaEntity Target);
  STDMETHOD_(int, HowFarFrom) (PZEZetaEntity Target);
  STDMETHOD_(void, Face) (PZEZetaEntity Target);
  STDMETHOD_(void, Approach) (PZEZetaEntity Target);
  //
  STDMETHOD_(void, FaceTo) (TZbDirection Direction);
  STDMETHOD_(int, CanStepTo) (TZbDirection Direction);
  STDMETHOD_(void, StepTo) (TZbDirection Direction);
  //
  STDMETHOD_(void, SetCaption) (PCHAR ACaption);
  STDMETHOD_(void, PlayEffects) (PCHAR AEffectName);
  STDMETHOD_(void, ClearEffects) ();
  //
  STDMETHOD_(PCHAR, GetAreaName) ();
  STDMETHOD_(void, Displace) (TZbDirection Direction);
  STDMETHOD_(void, TeleportTo) (void* DestRef);
  STDMETHOD_(TZbDirection, DirectionTo) (PZEZetaEntity Target);
  //
  STDMETHOD_(int, GetLocationX) ();
  STDMETHOD_(int, GetLocationY) ();
  STDMETHOD_(int, GetLocationZ) ();
  //
  STDMETHOD_(void, TeleportToLocation) (int X, int Y, int Z);
  STDMETHOD_(void, SwapWith) (PZEZetaEntity Target);
};

#define DECLARE_ENTITY_HANDLER(Name) \
  int __stdcall fn##Name (int hEntity, TZEEntityEvent Event, \
  void* pParam1, void* pParam2, int lParam1, int lParam2)

typedef void __stdcall EnumEntityCallback (PZEZetaEntity Entity);
typedef EnumEntityCallback* lpEnumEntityCallback;

// IZEWorld
DECLARE_INTERFACE_(IZEZetaWorld, IZEUnknown)
{
  STDMETHOD(SwitchToArea) (PCHAR lpszAreaName);
  STDMETHOD(Load) (PCHAR lpszWorldFile);
  //
  STDMETHOD_(PZEZetaEntity, GetPC) ();
  STDMETHOD(CreatePC) (PCHAR lpszMasterName, PCHAR lpszWorkingName, lpRemoteEntityCallback lpfnCallback);
  STDMETHOD(ReplacePC) (PCHAR lpszMasterName, PCHAR lpszWorkingName, lpRemoteEntityCallback lpfnCallback);
  STDMETHOD(ClearPC) ();
  //
  STDMETHOD_(void, DropPC) ();
  STDMETHOD_(void, DropPCEx) (PCHAR lpszAreaName, int X, int Y, int Z);
  STDMETHOD_(void, UnDropPC) ();
  //
  STDMETHOD_(void, CenterPC) ();
  STDMETHOD_(void, CenterAt) (int X, int Y, int Z);
  //
  STDMETHOD_(void, LockPortals) ();
  STDMETHOD_(void, UnlockPortals) ();
  //
  STDMETHOD_(PZEZetaEntity, GetEntity) (PCHAR lpszEntityname);
  STDMETHOD_(PZEZetaEntity, GetEntity2) (int hEntity);
  STDMETHOD_(void, DeleteEntity) (PCHAR lpszEntityName);
  STDMETHOD_(void, EnumEntities) (lpEnumEntityCallback tCALLBACK);
  //
  STDMETHOD_(void, QueueForDeletion) (PCHAR lpszEntityName);
  STDMETHOD_(PZEZetaEntity, DropEntity) (PCHAR lpszEntityBase, PCHAR lpszEntityName,
    int X, int Y, int Z);
  //
  STDMETHOD_(void, Clear) ();
  STDMETHOD_(PZEString, GetActiveAreaName) ();
  //
  STDMETHOD(Save) (PCHAR lpszWorldFile);
  STDMETHOD_(PZEZetaEntity, GetEntity3) (int X, int Y, int Z);
  STDMETHOD_(int, CheckLocation) (int X, int Y, int Z);
};
typedef IZEZetaWorld* PZEZetaWorld;

// IZEZeta
DECLARE_INTERFACE_(IZEZetaMain, IZEUnknown)
{
  STDMETHOD_(PZEUtils, Utils) ();
  STDMETHOD_(PZEWinWrap, WinWrapper) ();
  STDMETHOD_(PZEUIManager, UIManager) ();
  STDMETHOD_(PZECore, Core) ();
  STDMETHOD_(PZEZetaWorld, ZetaWorld) ();
};
typedef IZEZetaMain* PZEZetaMain;


//#############################################################################
// API Declarations 

#define ZETACMD(intCommand) ((PCHAR) ZELib_IntToStr (intCommand))

int         ZELib_Initialize ();
void        ZELib_Shutdown ();
const char* ZELib_IntToStr (int iValue);
PZEZetaMain ZEIntf_GetZetaMain ();


//#############################################################################
// 
// Following section generates code and global vars for client programs
// using #define`d names, and also generates several #define`s
//
#if (!defined(ZETALIB_CPP_MODULE)) && (!defined(CLIENT_VARS))

// global vars for client use
#define CLIENT_VARS
PZEZetaMain zeta = NULL;
#define utils       (zeta->Utils())
#define winwrap     (zeta->WinWrapper())
#define core        (zeta->Core())
#define uim         (zeta->UIManager())
#define world       (zeta->ZetaWorld())

// this conditionally generates the escape option
#if defined(ESCAPE_ON_EXIT)
#define GENERATE_ESCAPE_OPTION
#else
#define GENERATE_ESCAPE_OPTION  utils->SetExitOnEscape(IBOOL_TRUE)
#endif

// just to make WinMain shorter...
#define ZetaInit() if (!ZELib_Initialize ()) return (FALSE)

// this generates the WinMain () code
#define GENERATE_WINMAIN(GuiFunc,EventFunc) \
  int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) \
  { \
    ZetaInit(); \
    zeta = ZEIntf_GetZetaMain (); \
    GENERATE_ESCAPE_OPTION; \
    winwrap->Prepare (PROGRAM_CONFIGURATION,  GuiFunc, EventFunc); \
    winwrap->InitWindow (hInstance, WINDOW_CLASSNAME, WINDOW_TITLE, 0, 0, 640, 480); \
    winwrap->Execute (); \
    zeta->Release (); \
    return (TRUE); \
  }

//#############################################################################
//
// Buttons of various ilks are created most of the time.  macros saves some of
// the grunt work for doing this
//
#define DEFBTN_IVORY "Ivory"
static inline tCONTROL StdButton (tCONTROL Desktop, int Left, int Top, int Right, 
  char* Caption, int Cmd, char* Font = NULL, char* BtnName = NULL)
{
  tCONTROL Control = uim->CreateControl (CC_STANDARD_BUTTON, Left, Top, Right, Top);
  uim->Insert (Desktop, Control); 
  uim->SetProp (Control, PROP_NAME_COMMAND, ZETACMD (Cmd)); 
  uim->SetProp (Control, PROP_NAME_CAPTION, Caption);
  if (Font) uim->SetProp (Control, PROP_NAME_FONT_NAME, (PCHAR) Font);
  if (BtnName) uim->SetProp (Control, PROP_NAME_SPRITE_NAME, (PCHAR) BtnName);
  //
  return (Control);
}

static inline tCONTROL StdButtonPt (tCONTROL Desktop, TZbPoint TopLeft, 
  TZbPoint BottomRight, char* Caption, int Cmd, char* Font = NULL, char* BtnName = NULL)
{
  return (StdButton (Desktop, TopLeft.X, TopLeft.Y, BottomRight.X,
          Caption, Cmd, Font, BtnName));
}

#endif // (!defined(ZETALIB_CPP_MODULE)) && (!defined(CLIENT_VARS))

//#############################################################################
// 
// KeyCodes extracted from DirectInput
const int DIK_ESCAPE          = 0x01;
const int DIK_1               = 0x02;
const int DIK_2               = 0x03;
const int DIK_3               = 0x04;
const int DIK_4               = 0x05;
const int DIK_5               = 0x06;
const int DIK_6               = 0x07;
const int DIK_7               = 0x08;
const int DIK_8               = 0x09;
const int DIK_9               = 0x0A;
const int DIK_0               = 0x0B;
const int DIK_MINUS           = 0x0C;    /* - on main keyboard */
const int DIK_EQUALS          = 0x0D;
const int DIK_BACK            = 0x0E;    /* backspace */
const int DIK_TAB             = 0x0F;
const int DIK_Q               = 0x10;
const int DIK_W               = 0x11;
const int DIK_E               = 0x12;
const int DIK_R               = 0x13;
const int DIK_T               = 0x14;
const int DIK_Y               = 0x15;
const int DIK_U               = 0x16;
const int DIK_I               = 0x17;
const int DIK_O               = 0x18;
const int DIK_P               = 0x19;
const int DIK_LBRACKET        = 0x1A;
const int DIK_RBRACKET        = 0x1B;
const int DIK_RETURN          = 0x1C;    /* Enter on main keyboard */
const int DIK_LCONTROL        = 0x1D;
const int DIK_A               = 0x1E;
const int DIK_S               = 0x1F;
const int DIK_D               = 0x20;
const int DIK_F               = 0x21;
const int DIK_G               = 0x22;
const int DIK_H               = 0x23;
const int DIK_J               = 0x24;
const int DIK_K               = 0x25;
const int DIK_L               = 0x26;
const int DIK_SEMICOLON       = 0x27;
const int DIK_APOSTROPHE      = 0x28;
const int DIK_GRAVE           = 0x29;    /* accent grave */
const int DIK_LSHIFT          = 0x2A;
const int DIK_BACKSLASH       = 0x2B;
const int DIK_Z               = 0x2C;
const int DIK_X               = 0x2D;
const int DIK_C               = 0x2E;
const int DIK_V               = 0x2F;
const int DIK_B               = 0x30;
const int DIK_N               = 0x31;
const int DIK_M               = 0x32;
const int DIK_COMMA           = 0x33;
const int DIK_PERIOD          = 0x34;    /* . on main keyboard */
const int DIK_SLASH           = 0x35;    /* / on main keyboard */
const int DIK_RSHIFT          = 0x36;
const int DIK_MULTIPLY        = 0x37;    /* * on numeric keypad */
const int DIK_LMENU           = 0x38;    /* left Alt */
const int DIK_SPACE           = 0x39;
const int DIK_CAPITAL         = 0x3A;
const int DIK_F1              = 0x3B;
const int DIK_F2              = 0x3C;
const int DIK_F3              = 0x3D;
const int DIK_F4              = 0x3E;
const int DIK_F5              = 0x3F;
const int DIK_F6              = 0x40;
const int DIK_F7              = 0x41;
const int DIK_F8              = 0x42;
const int DIK_F9              = 0x43;
const int DIK_F10             = 0x44;
const int DIK_NUMLOCK         = 0x45;
const int DIK_SCROLL          = 0x46;    /* Scroll Lock */
const int DIK_NUMPAD7         = 0x47;
const int DIK_NUMPAD8         = 0x48;
const int DIK_NUMPAD9         = 0x49;
const int DIK_SUBTRACT        = 0x4A;    /* - on numeric keypad */
const int DIK_NUMPAD4         = 0x4B;
const int DIK_NUMPAD5         = 0x4C;
const int DIK_NUMPAD6         = 0x4D;
const int DIK_ADD             = 0x4E;    /* + on numeric keypad */
const int DIK_NUMPAD1         = 0x4F;
const int DIK_NUMPAD2         = 0x50;
const int DIK_NUMPAD3         = 0x51;
const int DIK_NUMPAD0         = 0x52;
const int DIK_DECIMAL         = 0x53;    /* . on numeric keypad */
// 0x54 to 0x55 unassigned
const int DIK_OEM_102         = 0x56;    /* <> or \ | on RT 102-key keyboard (Non-U.S.) */
const int DIK_F11             = 0x57;
const int DIK_F12             = 0x58;
// 0x59 to 0x63 unassigned
const int DIK_F13             = 0x64;    /*                     (NEC PC98) */
const int DIK_F14             = 0x65;    /*                     (NEC PC98) */
const int DIK_F15             = 0x66;    /*                     (NEC PC98) */
// 0x67 to 0x6F unassigned
const int DIK_KANA            = 0x70;    /* (Japanese keyboard)            */
const int DIK_ABNT_C1         = 0x73;    /* /? on Brazilian keyboard       */
// 0x74 to 0x78 unassigned
const int DIK_CONVERT         = 0x79;    /* (Japanese keyboard)            */
// 0x7A unassigned  
const int DIK_NOCONVERT       = 0x7B;    /* (Japanese keyboard)            */
// 0x7C unassigned
const int DIK_YEN             = 0x7D;    /* (Japanese keyboard)            */
const int DIK_ABNT_C2         = 0x7E;    /* Numpad . on Brazilian keyboard */  
// 0x7F to 8C unassigned
const int DIK_NUMPADEQUALS    = 0x8D;    /* = on numeric keypad (NEC PC98) */
// 0x8E to 0x8F unassigned
const int DIK_CIRCUMFLEX      = 0x90;    /* (Japanese keyboard)            */
const int DIK_AT              = 0x91;    /*                     (NEC PC98) */
const int DIK_COLON           = 0x92;    /*                     (NEC PC98) */
const int DIK_UNDERLINE       = 0x93;    /*                     (NEC PC98) */
const int DIK_KANJI           = 0x94;    /* (Japanese keyboard)            */
const int DIK_STOP            = 0x95;    /*                     (NEC PC98) */
const int DIK_AX              = 0x96;    /*                     (Japan AX) */
const int DIK_UNLABELED       = 0x97;    /*                        (J3100) */
// 0x98 unassigned
const int DIK_NEXTTRACK       = 0x99;    /* Next Track */
// 0x9A to 0x9D unassigned    
const int DIK_NUMPADENTER     = 0x9C;    /* Enter on numeric keypad */
const int DIK_RCONTROL        = 0x9D;
// 0x9E to 0x9F unassigned
const int DIK_MUTE            = 0xA0;    /* Mute */
const int DIK_CALCULATOR      = 0xA1;    /* Calculator */
const int DIK_PLAYPAUSE       = 0xA2;    /* Play / Pause */
const int DIK_MEDIASTOP       = 0xA4;    /* Media Stop */
// 0xA5 to 0xAD unassigned  
const int DIK_VOLUMEDOWN      = 0xAE;    /* Volume - */
// 0xAF unassigned  
const int DIK_VOLUMEUP        = 0xB0;    /* Volume + */
// 0xB1 unassigned  
const int DIK_WEBHOME         = 0xB2;    /* Web home */
const int DIK_NUMPADCOMMA     = 0xB3;    /* , on numeric keypad (NEC PC98) */
// 0xB4 unassigned
const int DIK_DIVIDE          = 0xB5;    /* / on numeric keypad */
// 0xB6 unassigned
const int DIK_SYSRQ           = 0xB7;
const int DIK_RMENU           = 0xB8;    /* right Alt */
// 0xB9 to 0xC4 unassigned
const int DIK_PAUSE           = 0xC5;    /* Pause (watch out - not realiable on some kbds) */
// 0xC6 unassigned
const int DIK_HOME            = 0xC7;    /* Home on arrow keypad */
const int DIK_UP              = 0xC8;    /* UpArrow on arrow keypad */
const int DIK_PRIOR           = 0xC9;    /* PgUp on arrow keypad */
// 0xCA unassigned
const int DIK_LEFT            = 0xCB;    /* LeftArrow on arrow keypad */
// 0xCC unassigned  
const int DIK_RIGHT           = 0xCD;    /* RightArrow on arrow keypad */
// 0xCE unassigned
const int DIK_END             = 0xCF;    /* End on arrow keypad */
const int DIK_DOWN            = 0xD0;    /* DownArrow on arrow keypad */
const int DIK_NEXT            = 0xD1;    /* PgDn on arrow keypad */
const int DIK_INSERT          = 0xD2;    /* Insert on arrow keypad */
const int DIK_DELETE          = 0xD3;    /* Delete on arrow keypad */
const int DIK_LWIN            = 0xDB;    /* Left Windows key */
const int DIK_RWIN            = 0xDC;    /* Right Windows key */
const int DIK_APPS            = 0xDD;    /* AppMenu key */
const int DIK_POWER           = 0xDE;
const int DIK_SLEEP           = 0xDF;
// 0xE0 to 0xE2 unassigned
const int DIK_WAKE            = 0xE3;    /* System Wake */
// 0xE4 unassigned
const int DIK_WEBSEARCH       = 0xE5;    /* Web Search */
const int DIK_WEBFAVORITES    = 0xE6;    /* Web Favorites */
const int DIK_WEBREFRESH      = 0xE7;    /* Web Refresh */
const int DIK_WEBSTOP         = 0xE8;    /* Web Stop */
const int DIK_WEBFORWARD      = 0xE9;    /* Web Forward */
const int DIK_WEBBACK         = 0xEA;    /* Web Back */
const int DIK_MYCOMPUTER      = 0xEB;    /* My Computer */
const int DIK_MAIL            = 0xEC;    /* Mail */
const int DIK_MEDIASELECT     = 0xED;    /* Media Select */

/*
 *  Alternate names for keys, to facilitate transition from DOS.
 */
const int DIK_BACKSPACE      = DIK_BACK;      /* backspace */
const int DIK_NUMPADSTAR     = DIK_MULTIPLY;  /* * on numeric keypad */
const int DIK_LALT           = DIK_LMENU;     /* left Alt */
const int DIK_CAPSLOCK       = DIK_CAPITAL;   /* CapsLock */
const int DIK_NUMPADMINUS    = DIK_SUBTRACT;  /* - on numeric keypad */
const int DIK_NUMPADPLUS     = DIK_ADD;       /* + on numeric keypad */
const int DIK_NUMPADPERIOD   = DIK_DECIMAL;   /* . on numeric keypad */
const int DIK_NUMPADSLASH    = DIK_DIVIDE;    /* / on numeric keypad */
const int DIK_RALT           = DIK_RMENU;     /* right Alt */
const int DIK_UPARROW        = DIK_UP;        /* UpArrow on arrow keypad */
const int DIK_PGUP           = DIK_PRIOR;     /* PgUp on arrow keypad */
const int DIK_LEFTARROW      = DIK_LEFT;      /* LeftArrow on arrow keypad */
const int DIK_RIGHTARROW     = DIK_RIGHT;     /* RightArrow on arrow keypad */
const int DIK_DOWNARROW      = DIK_DOWN;      /* DownArrow on arrow keypad */
const int DIK_PGDN           = DIK_NEXT;      /* PgDn on arrow keypad */




#endif /* __ZETA_ENGINE_LIBRARY_HEADER__ */


