Attribute VB_Name = "modZetaLib"
'//#############################################################################
'//
'// Visual Basic Interface Module
'// Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)
'//
'// This file is part of the ZetaEngine
'//
'// ZetaEngine is free software; you can redistribute it and/or modify
'// it under the terms of the GNU General Public License as published by
'// the Free Software Foundation; either version 2 of the License, or
'// (at your option) any later version.
'//
'// ZetaEngine is distributed in the hope that it will be useful,
'// but WITHOUT ANY WARRANTY; without even the implied warranty of
'// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'// GNU General Public License for more details.
'//
'// You should have received a copy of the GNU General Public License
'// along with Foobar; if not, write to the Free Software
'// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'//
'//#############################################################################

'//#############################################################################
'//
'// modZetaLib
'// Author: Virgilio A. Blones, Jr. (Vij) <ZipBreak@hotmail.com>
'//
'// <Description>
'// This VB module contains callbacks, types, definitions that is used to make
'// a VB program interface to the ZetaEngine DLL.  For usage example, check
'// SimpleVB example application
'//
'// <Notes>
'//
'// <Version History>
'// $Header$
'// $Log$
'//
'//#############################################################################

Option Explicit


'//#############################################################################
'//                         NAMES OF GUI CONTROLS
'//#############################################################################

'// class names for ZEWSBase
Public Const CC_BASE_CONTROL = "Control"
Public Const CC_BASE_GROUP = "GroupControl"
'// class names for ZEWSButtons
Public Const CC_STANDARD_BUTTON = "StandardButton"
Public Const CC_ICON_BUTTON = "IconButton"
Public Const CC_PICTURE_BUTTON = "PictureButton"
Public Const CC_PUSH_PANEL = "PushPanel"
Public Const CC_PICTURE_PANEL = "PicturePanel"
Public Const CC_CHECKBOX = "Checkbox"
'// class names for ZEWSLineEdit
Public Const CC_CUSTOM_EDIT_CONTROL = "CustomEdit"
Public Const CC_EDIT_CONTROL = "Edit"
Public Const CC_NUMERIC_EDIT_CONTROL = "NumericEdit"
'// class names for ZEWSMisc
Public Const CC_CUSTOM_GAUGE = "CustomGauge"
Public Const CC_CUSTOM_SCROLLBOX = "CustomScrollBox"
Public Const CC_PROGRESS_GAUGE = "ProgressGauge"
Public Const CC_PROGRESS_GAUGE_ENH = "ProgressGaugeEnh"
Public Const CC_SCROLL_GAUGE = "ScrollGauge"
Public Const CC_SCROLLBAR = "ScrollBar"
Public Const CC_TEXT_BOX = "TextBox"
Public Const CC_PANEL_GROUP = "PanelGroup"
'// class names for ZEWSStandard
Public Const CC_CUSTOM_DECOR_IMAGE = "CustomDecorImage"
Public Const CC_DECOR_IMAGE = "DecorImage"
Public Const CC_WALLPAPER = "Wallpaper"
Public Const CC_WINBORDERS = "WinBorders"
Public Const CC_TEXT = "Text"
Public Const CC_LABEL = "Label"
Public Const CC_CUSTOM_PUSH_BUTTON = "CustomPushButton"
Public Const CC_CUSTOM_TOGGLE_BUTTON = "CustomToggleButton"
Public Const CC_CUSTOM_PUSH_PANEL = "CustomPushPanel"
'// class names for ZEWSDialogs
Public Const CC_STANDARD_WINDOW = "StandardWindow"
Public Const CC_DESKTOP = "Desktop"
Public Const CC_ROOT_WINDOW = "RootWindow"
Public Const CC_CUSTOM_DIALOG = "CustomDialog"
Public Const CC_OK_DIALOG = "OKDialog"
Public Const CC_OK_CANCEL_DIALOG = "OKCancelDialog"
Public Const CC_CUSTOM_STRINPUT_DIALOG = "CustomStrInputDialog"
Public Const CC_MESSAGE_DIALOG = "MessageDialog"
Public Const CC_TEXT_DIALOG = "TextDialog"
'// class names for the game UI classes
Public Const CC_GAME_WINDOW = "GameWindow"
Public Const CC_CUT_SCENE_VIEW = "CutSceneView"
Public Const CC_GAME_MAIN_MENU = "GameMainMenu"

'//#############################################################################
'//                    NAMES OF UI ELEMENTS PROPERTIES
'//#############################################################################

'// property names for ZEWSBase module
Public Const PROP_NAME_WINCLASS_NAME = "WClassName"
Public Const PROP_NAME_ACTION_NAME = "ActionName"
Public Const PROP_NAME_BOUNDS = "Bounds"
Public Const PROP_NAME_CAPTION = "Caption"
Public Const PROP_NAME_CONTROL_NAME = "Name"
Public Const PROP_NAME_BACKCOLOR = "BackColor"
Public Const PROP_NAME_SPRITE_NAME = "Sprite"
Public Const PROP_NAME_FONT_NAME = "Font"
'// property names for ZEWSButtons
Public Const PROP_NAME_GROUP_ID = "GroupId"
Public Const PROP_NAME_PICTURE = "Picture"
'// property names for ZEWSStandard
Public Const PROP_NAME_REPEAT_X = "RepeatX"
Public Const PROP_NAME_REPEAT_Y = "RepeatY"
Public Const PROP_NAME_CENTER_X = "CenterX"
Public Const PROP_NAME_CENTER_Y = "CenterY"
Public Const PROP_NAME_AUTO_WIDTH = "AutoWidth"
Public Const PROP_NAME_AUTO_HEIGHT = "AutoHeight"
Public Const PROP_NAME_ANIMATES = "Animates"
Public Const PROP_NAME_ANIMATE_TICK = "AnimateTick"
Public Const PROP_NAME_CONSUME_CLICK = "ConsumeClick"
'//
Public Const PROP_NAME_PRESSED = "Pressed"
Public Const PROP_NAME_COMMAND = "Command"
Public Const PROP_NAME_AUTO_POPUP = "AutoPopup"
Public Const PROP_NAME_THREE_STATE = "ThreeState"
Public Const PROP_NAME_SHOW_CAPTION = "ShowCaption"
'// property names for ZEWSLineEdit
Public Const PROP_NAME_NUMEDIT_MAX = "NumEditMax"
Public Const PROP_NAME_NUMEDIT_MIN = "NumEditMin"
'//
Public Const PROP_NAME_CHECKED = "Checked"
Public Const PROP_NAME_DRAW_BORDERS = "DrawBorders"
'// property names for ZEWSMisc
Public Const PROP_NAME_FILLER_COLOR = "FillerColor"
Public Const PROP_NAME_FILLER_IMAGE = "FillerImage"
Public Const PROP_NAME_GAUGE_MIN = "GaugeMinimum"
Public Const PROP_NAME_GAUGE_MAX = "GaugeMaximum"
Public Const PROP_NAME_GAUGE_CURRENT = "GaugeCurrent"
Public Const PROP_NAME_GAUGE_STYLE = "GaugeStyle"
Public Const PROP_NAME_GAUGE_DIRECTION = "GaugeDirection"
'//
Public Const PROP_NAME_AUTO_SCROLL = "AutoScroll"
Public Const PROP_NAME_TEXT_TO_ADD = "TextToAdd"
Public Const PROP_NAME_FILE_TO_LOAD = "FileToLoad"

'//#############################################################################
'//                        NAMES OF GAME-USED ENTITIES
'//#############################################################################

'// names of default scripts
Public Const SCRIPT_GAME_GUI = "GameGUI"
Public Const SCRIPT_GAME_IDLE = "GameIdle"
Public Const SCRIPT_USER_EVENTS = "UserEventHandler"
'// names of the default game desktops
Public Const DESKTOP_CUT_SCENE = "DTCutScene"
Public Const DESKTOP_MAIN = "DTMain"
Public Const DESKTOP_MENU = "DTMenu"

'//#############################################################################
'//                            PREDEFINED COMMANDS
'//#############################################################################

'//
Public Const cmStandardSystemBase = 0
Public Const cmStandardSystemMax = cmStandardSystemBase + 199
'//
Public Const cmGlobalError = cmStandardSystemBase - 1
Public Const cmGlobalNull = cmStandardSystemBase + 0
Public Const cmGlobalInit = cmStandardSystemBase + 1
Public Const cmGlobalShutdown = cmStandardSystemBase + 2
Public Const cmGlobalActivated = cmStandardSystemBase + 3
Public Const cmGlobalDeactivated = cmStandardSystemBase + 4
Public Const cmGlobalExitQuery = cmStandardSystemBase + 5
Public Const cmGlobalExitFinal = cmStandardSystemBase + 6
Public Const cmFinalExit = cmGlobalExitFinal ' for backward compatibility
'//
Public Const cmEngineCommandBase = 50
Public Const cmEngineTimerExpired = cmEngineCommandBase + 0
Public Const cmEngineTimerTick = cmEngineCommandBase + 1
'//
Public Const cmStdCommandBase = 100
Public Const cmOK = cmStdCommandBase + 0
Public Const cmCancel = cmStdCommandBase + 1
Public Const cmNothing = cmStdCommandBase + 2
Public Const cmReleaseFocus = cmStdCommandBase + 3
Public Const cmYes = cmStdCommandBase + 4
Public Const cmNo = cmStdCommandBase + 5
Public Const cmAbort = cmStdCommandBase + 6
Public Const cmRetry = cmStdCommandBase + 7
'// GUI Commands
Public Const cmGUICommandBase = 200
Public Const cmGUICommandMax = cmGUICommandBase + 199
'// used in ZEWSButtons
Public Const cmPanelClicked = cmGUICommandBase + 1
Public Const cmAcquirePanelFocus = cmGUICommandBase + 2
Public Const cmPBSelectNext = cmGUICommandBase + 3
Public Const cmPBSelectPrevious = cmGUICommandBase + 4
'// used in ZEWSDialogs
Public Const cmDesktopHidden = cmGUICommandBase + 11
Public Const cmDesktopShown = cmGUICommandBase + 12
Public Const cmRemoveDialog = cmGUICommandBase + 13
Public Const cmDialogClosed = cmGUICommandBase + 14
'// used in ZEWSMisc
Public Const cmScrollerUpdated = cmGUICommandBase + 21
Public Const cmScrollBarChanged = cmGUICommandBase + 22
Public Const cmScrollBoxChanged = cmGUICommandBase + 23
Public Const cmDecorEndSequence = cmGUICommandBase + 24
Public Const cmDecorClicked = cmGUICommandBase + 25



' record structures
Public Type TZbPoint
  X As Long
  Y As Long
End Type

Public Type TZbVector
  X As Long
  Y As Long
  Z As Long
End Type

' Direction constants
Public Const tdUnknown = 0
Public Const tdNorth = 1
Public Const tdNorthEast = 2
Public Const tdEast = 3
Public Const tdSouthEast = 4
Public Const tdSouth = 5
Public Const tdSouthWest = 6
Public Const tdWest = 7
Public Const tdNorthWest = 8
Public Const DirectionFirst = tdNorth
Public Const DirectionLast = tdNorthWest

Public Const eeArrived = 0
Public Const eeStopped = 1
Public Const eePerformBegins = 2
Public Const eePerformEnds = 3
Public Const eeQueryMove = 4
Public Const eeActionRequest = 5
Public Const eeTimerFired = 6
Public Const eeDoActionMain = 7
Public Const eeDoActionOther = 8
Public Const eeTriggerPortal = 9

Public Const ksNothing = 0
Public Const ksPressed = 1
Public Const ksReleased = 2

'type
'  tINTBOOL      = integer;
'  tCONTROL      = integer;
'  tCALLBACK     = integer;

'//#############################################################################
'//                          CONSTANT DECLARATIONS
'//#############################################################################

Public Const IBOOL_TRUE = 1
Public Const IBOOL_FALSE = 0
Public Const tNULL_CONTROL = 0


'//#############################################################################
'//                         GLOBAL RUNNER PROCEDURE
'//#############################################################################

Declare Sub ZETA_Run Lib "ZetaLib" (ByVal EscapeExits As Long, _
  ByVal hInstance As Long, ByVal AWinTitle As String, ByVal AProgConfig As String, _
  ByVal lpfnCreateUICallback As Long, ByVal lpfnHandleEventCallback As Long)


'//#############################################################################
'//                         WINDOWS (tm) WRAPPER API
'//#############################################################################

Declare Function ZEWW_Prepare Lib "ZetaLib" (ByVal lpszConfigFile As String, _
  ByVal lpfnCreateUICallback As Long, ByVal lpfnHandleEventCallback As Long) As Long
Declare Function ZEWW_CreateWindow Lib "ZetaLib" (ByVal ClassRef As Long, ByVal hAppInstance As Long, _
  ByVal WindowClassName As String, ByVal WindowTitle As String, ByVal WindowProc As Long, _
  ByVal Windowflags As Long, ByVal iWidth As Long, ByVal iHeight As Long) As Long
Declare Sub ZEWW_Execute Lib "ZetaLib" (ByVal ClassRef As Long)
Declare Sub ZEWW_Shutdown Lib "ZetaLib" (ByVal ClassRef As Long)
  
'//#############################################################################
'//                          ENGINE PROPER ROUTINES
'//#############################################################################

Declare Function ZEE_Initialize Lib "ZetaLib" (ByVal lpszConfigurationFile As String, _
  ByVal hHostWindow As Long, ByVal hAppInstance As Long) As Long
Declare Sub ZEE_Shutdown Lib "ZetaLib" ()
Declare Sub ZEE_TerminateSelf Lib "ZetaLib" ()
Declare Sub ZEE_TerminateEngine Lib "ZetaLib" ()
Declare Sub ZEE_Activate Lib "ZetaLib" ()
Declare Sub ZEE_Deactivate Lib "ZetaLib" ()
Declare Function ZEE_Refresh Lib "ZetaLib" () As Long
Declare Sub ZEE_PushEvent Lib "ZetaLib" (ByVal EventCommand As Long)
Declare Sub ZEE_AddCallback Lib "ZetaLib" (ByVal AName As String, ByVal Handler As Long)

Declare Function ZEE_ScreenWidth Lib "ZetaLib" () As Long
Declare Function ZEE_ScreenHeight Lib "ZetaLib" () As Long
Declare Function ZEE_ScreenColorDepth Lib "ZetaLib" () As Long

Declare Sub ZEE_SetMusic Lib "ZetaLib" (ByVal lpszMusicName As String)
Declare Sub ZEE_ClearMusic Lib "ZetaLib" ()
Declare Sub ZEE_PlaySound Lib "ZetaLib" (ByVal lpszSoundName As String)
Declare Sub ZEE_PlayCutScene Lib "ZetaLib" (ByVal lpszCutSceneFile As String)

Declare Sub ZEE_TogglePause Lib "ZetaLib" (ByVal ibActive As Long)
Declare Function ZEE_IsMusicActive Lib "ZetaLib" () As Long
Declare Sub ZEE_ToggleMusic Lib "ZetaLib" (ByVal ibActive As Long)
Declare Function ZEE_IsSoundActive Lib "ZetaLib" () As Long
Declare Sub ZEE_ToggleSound Lib "ZetaLib" (ByVal ibActive As Long)
Declare Sub ZEE_ToggleFPSDisplay Lib "ZetaLib" (ByVal ibVisible As Long)

Declare Sub ZEE_StartTimer Lib "ZetaLib" (ByVal ATimerValue As Long)
Declare Sub ZEE_StartTimerEx Lib "ZetaLib" (ByVal AMinutes As Long, ByVal ASeconds As Long)
Declare Sub ZEE_PauseTimer Lib "ZetaLib" ()
Declare Sub ZEE_UnPauseTimer Lib "ZetaLib" ()
Declare Sub ZEE_StopTimer Lib "ZetaLib" ()


Declare Function ZEE_IsGlobalExitOnEscapeSet Lib "ZetaLib" () As Long
Declare Sub ZEE_ToggleGlobalExitOnEscape Lib "ZetaLib" (ByVal ibActive As Long)

'Declare Function ZEE_CmpStr Lib "ZetaLib" (ByVal pRef As String, ByVal pCmp As String) As Long
Declare Function ZEE_CmpStr Lib "ZetaLib" (ByVal pRef As Long, ByVal pCmp As String) As Long
Declare Sub ZEE_AddKeyHook Lib "ZetaLib" (ByVal KeyCode As Long, ByVal UserHandler As Long)
Declare Sub ZEE_ClearKeyHook Lib "ZetaLib" (ByVal KeyCode As Long)

Declare Function ZEE_GetElapsedTicks Lib "ZetaLib" () As Long
Declare Function ZEE_GetMouseX Lib "ZetaLib" () As Long
Declare Function ZEE_GetMouseY Lib "ZetaLib" () As Long

Declare Sub ZEE_DebugText Lib "ZetaLib" (ByVal DebugStr As String)


'//#############################################################################
'//                            WINDOWING SYSTEM
'//#############################################################################

Declare Function ZEUI_Root Lib "ZetaLib" () As Long
Declare Function ZEUI_CreateDesktop Lib "ZetaLib" (ByVal lpszRefName As String, _
  ByVal lpszDeskName As String) As Long
Declare Function ZEUI_GetDesktop Lib "ZetaLib" (ByVal lpszRefName As String) As Long
Declare Function ZEUI_SwitchDesktop Lib "ZetaLib" (ByVal lpszRefName As String) As Long
Declare Function ZEUI_CreateGameView Lib "ZetaLib" (ByVal Left As Long, _
  ByVal Top As Long, ByVal Right As Long, ByVal Bottom As Long) As Long
  
Declare Function ZEUI_CreateControl Lib "ZetaLib" (ByVal lpszClassName As String, _
  ByVal Left As Long, ByVal Top As Long, ByVal Right As Long, ByVal Bottom As Long) As Long
Declare Sub ZEUI_InsertControl Lib "ZetaLib" (ByVal ctlDest As Long, ByVal ctlToInsert As Long)
Declare Function ZEUI_GetProp Lib "ZetaLib" (ByVal ControlRef As Long, ByVal lpszPropName As String) As String
Declare Sub ZEUI_SetProp Lib "ZetaLib" (ByVal ControlRef As Long, ByVal lpszPropName As String, _
  ByVal lpszPropValue As String)
Declare Sub ZEUI_ToggleParentFontUse Lib "ZetaLib" (ByVal ControlRef As Long, ByVal ibActive As Long)

Declare Sub ZEUI_RunDialog Lib "ZetaLib" (ByVal ControlRef As Long)
Declare Sub ZEUI_ShowInputBox Lib "ZetaLib" (ByVal lpszPrompt As String, ByVal iCommand As Long, _
  ByVal ANoCancel As Long)
Declare Sub ZEUI_ShowMsgBox Lib "ZetaLib" (ByVal cMessage As String, ByVal SendCommand As Long)
Declare Sub ZEUI_ShowMsgBoxEx Lib "ZetaLib" (ByVal cMessage As String, _
  ByVal Left As Long, ByVal Top As Long, ByVal Right As Long, _
  ByVal Bottom As Long, ByVal SendCommand As Long)
Declare Sub ZEUI_ShowTextDialog Lib "ZetaLib" (ByVal iWidth As Long, _
  ByVal iHeight As Long, ByVal lpszFileName As String, ByVal lpszFontName As String)
  
Declare Sub ZEUI_Hide Lib "ZetaLib" (ByVal ControlRef As Long)
Declare Sub ZEUI_Show Lib "ZetaLib" (ByVal ControlRef As Long)
Declare Sub ZEUI_Enable Lib "ZetaLib" (ByVal ControlRef As Long, ByVal ibActive As Long)

Declare Function ZEUI_GetXPos Lib "ZetaLib" (ByVal ControlRef As Long) As Long
Declare Function ZEUI_GetYPos Lib "ZetaLib" (ByVal ControlRef As Long) As Long
Declare Function ZEUI_GetWidth Lib "ZetaLib" (ByVal ControlRef As Long) As Long
Declare Function ZEUI_GetHeight Lib "ZetaLib" (ByVal ControlRef As Long) As Long

Declare Sub ZEUI_MoveTo Lib "ZetaLib" (ByVal ControlRef As Long, ByVal NewX As Long, ByVal NewY As Long)
Declare Sub ZEUI_MoveRel Lib "ZetaLib" (ByVal ControlRef As Long, ByVal DeltaX As Long, ByVal DeltaY As Long)
Declare Sub ZEUI_Resize Lib "ZetaLib" (ByVal ControlRef As Long, ByVal W As Long, ByVal H As Long)


Declare Sub ZEUI_Delete Lib "ZetaLib" (ByVal ControlRef As Long)


'//#############################################################################
'//                               GAME STUFF
'//-----------------------------------------------------------------------------
'//                        ENTITY HANDLING ROUTINES
'//#############################################################################

Declare Function ZEEN_NameToHandle Lib "ZetaLib" (ByVal lpszName As String) As Long
Declare Sub ZEEN_Delete Lib "ZetaLib" (ByVal hEntity As Long)
Declare Sub ZEEN_Unplace Lib "ZetaLib" (ByVal hEntity As Long)

Declare Function ZEEN_CompareBaseName Lib "ZetaLib" (ByVal hEntity As Long, _
  ByVal lpszWithName As String) As Long
Declare Function ZEEN_CompareName Lib "ZetaLib" (ByVal hEntity As Long, _
  ByVal lpszWithName As String) As Long
Declare Function ZEEN_PrefixInName Lib "ZetaLib" (ByVal hEntity As Long, _
  ByVal lpszPrefix As String) As Long
Declare Function ZEEN_GetWidth Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Function ZEEN_GetLength Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Function ZEEN_IsOrientable Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Function ZEEN_CanMove Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Function ZEEN_MovementRate Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Function ZEEN_Updateable Lib "ZetaLib" (ByVal hEntity As Long) As Long

Declare Function ZEEN_GetXPos Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Function ZEEN_GetYPos Lib "ZetaLib" (ByVal hEntity As Long) As Long

Declare Function ZEEN_OnMap Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Function ZEEN_OnActiveArea Lib "ZetaLib" (ByVal hEntity As Long) As Long

Declare Function ZEEN_Orientation Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Sub ZEEN_SetStateInfo Lib "ZetaLib" (ByVal hEntity As Long, ByVal lpszStateInfo As String)

Declare Sub ZEEN_SetHandler Lib "ZetaLib" (ByVal hEntity As Long, ByVal Handler As Long)
Declare Sub ZEEN_ClearHandler Lib "ZetaLib" (ByVal hEntity As Long)
Declare Function ZEEN_GetHandlerData Lib "ZetaLib" (ByVal hEntity As Long) As Long
Declare Sub ZEEN_SetHandlerData Lib "ZetaLib" (ByVal hEntity As Long, ByVal AData As Long)

Declare Sub ZEEN_BeginPerform Lib "ZetaLib" (ByVal hEntity As Long, _
  ByVal APerformState As String, ByVal ibImmediate As Long)
Declare Sub ZEEN_ClearActions Lib "ZetaLib" (ByVal hEntity As Long)
Declare Sub ZEEN_MoveTo Lib "ZetaLib" (ByVal hEntity As Long, ByVal X As Long, _
  ByVal Y As Long, ByVal Z As Long)
  
Declare Function ZEEN_CanSee Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As String) As Long
Declare Function ZEEN_CanSee2 Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As Long) As Long
Declare Function ZEEN_HowFarFrom Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As String) As Long
Declare Function ZEEN_HowFarFrom2 Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As Long) As Long
Declare Function ZEEN_IsNeighbor Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As String) As Long
Declare Function ZEEN_IsNeighbor2 Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As Long) As Long

Declare Sub ZEEN_Face Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As String)
Declare Sub ZEEN_Face2 Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As Long)
Declare Sub ZEEN_Approach Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As String)
Declare Sub ZEEN_Approach2 Lib "ZetaLib" (ByVal hEntity As Long, ByVal Target As Long)

Declare Sub ZEEN_FaceTo Lib "ZetaLib" (ByVal hEntity As Long, ByVal Direction As Long)
Declare Function ZEEN_CanStepTo Lib "ZetaLib" (ByVal hEntity As Long, ByVal Direction As Long)
Declare Sub ZEEN_StepTo Lib "ZetaLib" (ByVal hEntity As Long, ByVal Direction As Long)
Declare Sub ZEEN_SetCaption Lib "ZetaLib" (ByVal hEntity As Long, ByVal ACaption As String)
Declare Function ZEEN_GetNeighbor Lib "ZetaLib" (ByVal hEntity As Long, ByVal Direction As Long)


'//#############################################################################
'//                               GAME STUFF
'//-----------------------------------------------------------------------------
'//                        WORLD HANDLING ROUTINES
'//#############################################################################

Declare Sub ZEGE_LoadWorld Lib "ZetaLib" (ByVal lpszWorldFile As String)
Declare Sub ZEGE_SwitchToArea Lib "ZetaLib" (ByVal lpszWorldFile As String)

Declare Sub ZEGE_CreatePC Lib "ZetaLib" (ByVal lpszMasterName As String, _
  ByVal lpszWorkingName As String, ByVal lpfnCallback As Long)
Declare Sub ZEGE_ReplacePC Lib "ZetaLib" (ByVal lpszMasterName As String, _
  ByVal lpszWorkingName As String, ByVal lpfnCallback As Long)
Declare Sub ZEGE_ClearPC Lib "ZetaLib" ()

Declare Function ZEGE_GetPC Lib "ZetaLib" () As Long
Declare Sub ZEGE_CenterPC Lib "ZetaLib" ()
Declare Sub ZEGE_CenterAt Lib "ZetaLib" (ByVal X As Long, ByVal Y As Long, ByVal Z As Long)

Declare Sub ZEGE_LockPortals Lib "ZetaLib" ()
Declare Sub ZEGE_UnlockPortals Lib "ZetaLib" ()

Declare Sub ZEGE_DropPC Lib "ZetaLib" ()
Declare Sub ZEGE_DropPCEx Lib "ZetaLib" (ByVal lpszAreaName As String, _
  ByVal X As Long, ByVal Y As Long, ByVal Z As Long)
Declare Sub ZEGE_UnDropPC Lib "ZetaLib" ()

Declare Function ZEGE_GetEntity Lib "ZetaLib" (ByVal lpszEntityName As String) As Long
Declare Sub ZEGE_DeleteEntity Lib "ZetaLib" (ByVal hEntity As Long)
Declare Sub ZEGE_DeleteEntity2 Lib "ZetaLib" (ByVal lpszEntityName As String)
Declare Sub ZEGE_EnumEntities Lib "ZetaLib" (ByVal EnumCallback As Long)
Declare Sub ZEGE_QueueForDeletion Lib "ZetaLib" (ByVal hEntity As Long)
Declare Sub ZEGE_QueueForDeletion2 Lib "ZetaLib" (ByVal lpszEntityName As String)


'//#############################################################################
'//                              OTHER SUPPORT
'//#############################################################################

Public Sub RunZeta(ByVal WinClassName As String, ByVal WINTITLE As String, _
  ByVal ConfigFile As String, ByVal UIProc As Long, ByVal GameProc As Long, ByVal ESCAPE_ON As Boolean)
  '
  Dim WinRef As Long
  Dim WinResult As Boolean
  '
  WinRef = ZEWW_Prepare(ConfigFile, UIProc, GameProc)
  If (WinRef) Then
    WinResult = ZEWW_CreateWindow(WinRef, App.hInstance, WinClassName, WINTITLE, 0, 0, 640, 480)
    If ESCAPE_ON Then ZEE_ToggleGlobalExitOnEscape (IBOOL_TRUE)
    Call ZEE_ToggleFPSDisplay(IBOOL_FALSE)
    If (WinResult) Then ZEWW_Execute (WinRef)
    ZEWW_Shutdown (WinRef)
  End If
End Sub
