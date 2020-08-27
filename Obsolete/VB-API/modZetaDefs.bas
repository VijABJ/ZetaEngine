Attribute VB_Name = "modZetaDefs"
' ===========================================================================
'
'  ZipBreak 's Zeta Engine - Tiled, Isometric Engine for RPGs
'  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)
'
'  Module:       modZetaDefs.BAS
'                Module for Visual Basic containing symbols need for ZetaEngine
'  Author:       Vij
'
'  -------------------------
'  Version Control / HISTORY
'  -------------------------

'  $Header: /users/vij/backups/CVS/ZetaEngine/VB-API/modZetaDefs.bas,v 1.1 2002/10/01 12:23:17 Vij Exp $
'  $Log: modZetaDefs.bas,v $
'  Revision 1.1  2002/10/01 12:23:17  Vij
'  Starting Version Control
'
'
' ===========================================================================
 
Option Explicit


' ++++++++++++++++++++++++++++++++++++++
'         NAMES OF GUI CONTROLS
' ++++++++++++++++++++++++++++++++++++++

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
Public Const CC_OK_CANCEL_DIALOG = "OKCancelDialog"
'// class names for the game UI classes
Public Const CC_GAME_WINDOW = "GameWindow"
Public Const CC_CUT_SCENE_VIEW = "CutSceneView"
Public Const CC_GAME_MAIN_MENU = "GameMainMenu"

' ++++++++++++++++++++++++++++++++++++++
'    NAMES OF UI ELEMENTS PROPERTIES
' ++++++++++++++++++++++++++++++++++++++

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
Public Const PROP_NAME_GAUGE_MIN = "GaugeMinimum"
Public Const PROP_NAME_GAUGE_MAX = "GaugeMaximum"
Public Const PROP_NAME_GAUGE_CURRENT = "GaugeCurrent"
Public Const PROP_NAME_GAUGE_STYLE = "GaugeStyle"
Public Const PROP_NAME_GAUGE_DIRECTION = "GaugeDirection"

' ++++++++++++++++++++++++++++++++++++++
'      NAMES OF GAME-USED ENTITIES
' ++++++++++++++++++++++++++++++++++++++

'// names of default scripts
Public Const SCRIPT_GAME_GUI = "GameGUI"
Public Const SCRIPT_USER_EVENTS = "UserEventHandler"
'// names of the default game desktops
Public Const DESKTOP_CUT_SCENE = "DTCutScene"
Public Const DESKTOP_MAIN = "DTMain"
Public Const DESKTOP_MENU = "DTMenu"

' ++++++++++++++++++++++++++++++++++++++
'          PREDEFINED COMMANDS
' ++++++++++++++++++++++++++++++++++++++

'//
Public Const cmStandardSystemBase = 0
Public Const cmStandardSystemMax = cmStandardSystemBase + 199
'//
Public Const cmError = cmStandardSystemBase - 1
Public Const cmNothing = cmStandardSystemBase + 0
Public Const cmOK = cmStandardSystemBase + 1
Public Const cmCancel = cmStandardSystemBase + 2
Public Const cmYes = cmStandardSystemBase + 3
Public Const cmNO = cmStandardSystemBase + 4
Public Const cmAbort = cmStandardSystemBase + 5
Public Const cmRetry = cmStandardSystemBase + 6
Public Const cmGetFocus = cmStandardSystemBase + 7
Public Const cmReleaseFocus = cmStandardSystemBase + 8
Public Const cmHelp = cmStandardSystemBase + 9
Public Const cmExit = cmStandardSystemBase + 10
Public Const cmExitConfirm = cmStandardSystemBase + 11
Public Const cmFinalExit = cmStandardSystemBase + 12
Public Const cmCycleForward = cmStandardSystemBase + 13
Public Const cmCycleBackward = cmStandardSystemBase + 14
Public Const cmGetDefault = cmStandardSystemBase + 15
Public Const cmReleaseDefault = cmStandardSystemBase + 16
Public Const cmClose = cmStandardSystemBase + 17
Public Const cmResize = cmStandardSystemBase + 18
Public Const cmZoom = cmStandardSystemBase + 19
Public Const cmDrag = cmStandardSystemBase + 20
Public Const cmGotoPrev = cmStandardSystemBase + 21
Public Const cmGotoNext = cmStandardSystemBase + 22
Public Const cmSystemMenu = cmStandardSystemBase + 23
Public Const cmDefault = cmStandardSystemBase + 24
Public Const cmMove = cmStandardSystemBase + 25
Public Const cmCommandsChanged = cmStandardSystemBase + 26
Public Const cmMoveWithMouse = cmStandardSystemBase + 27

' ++++++++++++++++++++++++++++++++++++++
Public Const cmGUICommandBase = 200
Public Const cmGUICommandMax = cmGUICommandBase + 199

Public Const cmPanelClicked = cmGUICommandBase + 1
Public Const cmAcquirePanelFocus = cmGUICommandBase + 2
Public Const cmPBSelectNext = cmGUICommandBase + 3
Public Const cmPBSelectPrevious = cmGUICommandBase + 4

Public Const cmDesktopHidden = cmGUICommandBase + 11
Public Const cmDesktopShown = cmGUICommandBase + 12


