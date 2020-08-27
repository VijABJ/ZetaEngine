/*===========================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaDefs.hpp
              Definitions for Zeta Engine Elements And Events
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/CPP-API/ZetaDefs.hpp,v 1.2 2002/10/01 12:51:04 Vij Exp $
  $Log: ZetaDefs.hpp,v $
  Revision 1.2  2002/10/01 12:51:04  Vij
  Fixed typo

  Revision 1.1.1.1  2002/09/12 14:48:21  Vij
  Starting Version Control



 ===========================================================================*/
 
#ifndef __ZETA_ENGINE_HEADER__
#define __ZETA_ENGINE_HEADER__


// *************************
// | Names Of GUI Controls |
// *************************

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



// **********************************
// | Names Of UI Element Properties |
// **********************************

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
#define PROP_NAME_GAUGE_MIN          "GaugeMinimum"
#define PROP_NAME_GAUGE_MAX          "GaugeMaximum"
#define PROP_NAME_GAUGE_CURRENT      "GaugeCurrent"
#define PROP_NAME_GAUGE_STYLE        "GaugeStyle"
#define PROP_NAME_GAUGE_DIRECTION    "GaugeDirection"



// ******************************
// | Names Of GameUsed Entities |
// ******************************

// names of default scripts
#define SCRIPT_GAME_GUI             "GameGUI"
#define SCRIPT_USER_EVENTS          "UserEventHandler"
// names of the default game desktops
#define DESKTOP_CUT_SCENE           "DTCutScene"
#define DESKTOP_MAIN                "DTMain"
#define DESKTOP_MENU                "DTMenu"



// ***********************
// | Predefined Commands |
// ***********************

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

//////////////////////////////////////////////////////////////
const int cmGUICommandBase      = 200;
const int cmGUICommandMax       = cmGUICommandBase + 199;

const int cmPanelClicked        = cmGUICommandBase + 1;
const int cmAcquirePanelFocus   = cmGUICommandBase + 2;
const int cmPBSelectNext        = cmGUICommandBase + 3;
const int cmPBSelectPrevious    = cmGUICommandBase + 4;

const int cmDesktopHidden       =  cmGUICommandBase + 11;
const int cmDesktopShown        =  cmGUICommandBase + 12;


#endif /* __ZETA_ENGINE_HEADER__ */

