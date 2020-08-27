{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSDefines.PAS
              Definitions And Symbols to make UI code easier to read
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSDefines.pas,v 1.4 2002/12/18 08:15:19 Vij Exp $
  $Log: ZEWSDefines.pas,v $
  Revision 1.4  2002/12/18 08:15:19  Vij
  Added ScrollBar, TextBox and dialogs that make use of them.

  Revision 1.3  2002/11/02 06:46:34  Vij
  move all cmXXXXX here for easy scanning of used values.
  added new property name: PROP_NAME_FILLER_IMAGE

  Revision 1.2  2002/10/01 12:36:51  Vij
  Removed obsolete commands.

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSDefines;

interface

const
  // Standard commands
  cmStdCommandBase      = 100;
  cmOK                  = cmStdCommandBase + 0;
  cmCancel              = cmStdCommandBase + 1;
  cmNothing             = cmStdCommandBase + 2;
  cmReleaseFocus        = cmStdCommandBase + 3;
  cmYes                 = cmStdCommandBase + 4;
  cmNo                  = cmStdCommandBase + 5;
  cmAbort               = cmStdCommandBase + 6;
  cmRetry               = cmStdCommandBase + 7;
  // GUI Commands
  cmGUICommandBase      = 200;
  cmGUICommandMax       = cmGUICommandBase + 199;
  // used in ZEWSButtons
  cmPanelClicked        = cmGUICommandBase + 1;
  cmAcquirePanelFocus   = cmGUICommandBase + 2;
  cmPBSelectNext        = cmGUICommandBase + 3;
  cmPBSelectPrevious    = cmGUICommandBase + 4;
  // used in ZEWSDialogs
  cmDesktopHidden       = cmGUICommandBase + 11;
  cmDesktopShown        = cmGUICommandBase + 12;
  cmRemoveDialog        = cmGUICommandBase + 13;
  cmDialogClosed        = cmGUICommandBase + 14;
  // used in ZEWSMisc
  cmScrollerUpdated     = cmGUICommandBase + 21;
  cmScrollBarChanged    = cmGUICommandBase + 22;
  cmScrollBoxChanged    = cmGUICommandBase + 23;
  //
  cmDecorEndSequence    = cmGUICommandBase + 24;
  cmDecorClicked        = cmGUICommandBase + 25;


  // command for transmitting actions
  cmGlobalCommandPerformAction  = 500;

  // default timer value
  animTimerDelay                = 500;


  //
  // class names for ZEWSBase
  CC_BASE_CONTROL               = 'Control';
  CC_BASE_GROUP                 = 'GroupControl';
  // class names for ZEWSButtons
  CC_STANDARD_BUTTON            = 'StandardButton';
  CC_ICON_BUTTON                = 'IconButton';
  CC_PICTURE_BUTTON             = 'PictureButton';
  CC_PUSH_PANEL                 = 'PushPanel';
  CC_PICTURE_PANEL              = 'PicturePanel';
  CC_CHECKBOX                   = 'Checkbox';
  // class names for ZEWSLineEdit
  CC_CUSTOM_EDIT_CONTROL        = 'CustomEdit';
  CC_EDIT_CONTROL               = 'Edit';
  CC_NUMERIC_EDIT_CONTROL       = 'NumericEdit';
  // class names for ZEWSMisc
  CC_CUSTOM_GAUGE               = 'CustomGauge';
  CC_CUSTOM_SCROLLBOX           = 'CustomScrollBox';
  CC_PROGRESS_GAUGE             = 'ProgressGauge';
  CC_PROGRESS_GAUGE_ENH         = 'ProgressGaugeEnh';
  CC_SCROLL_GAUGE               = 'ScrollGauge';
  CC_SCROLLBAR                  = 'ScrollBar';
  CC_TEXT_BOX                   = 'TextBox';
  CC_PANEL_GROUP                = 'PanelGroup';
  // class names for ZEWSStandard
  CC_CUSTOM_DECOR_IMAGE         = 'CustomDecorImage';
  CC_DECOR_IMAGE                = 'DecorImage';
  CC_WALLPAPER                  = 'Wallpaper';
  CC_WINBORDERS                 = 'WinBorders';
  CC_TEXT                       = 'Text';
  CC_LABEL                      = 'Label';
  CC_CUSTOM_PUSH_BUTTON         = 'CustomPushButton';
  CC_CUSTOM_TOGGLE_BUTTON       = 'CustomToggleButton';
  CC_CUSTOM_PUSH_PANEL          = 'CustomPushPanel';
  // class names for ZEWSDialogs
  CC_STANDARD_WINDOW            = 'StandardWindow';
  CC_DESKTOP                    = 'Desktop';
  CC_ROOT_WINDOW                = 'RootWindow';
  CC_CUSTOM_DIALOG              = 'CustomDialog';
  CC_OK_DIALOG                  = 'OKDialog';
  CC_OK_CANCEL_DIALOG           = 'OKCancelDialog';
  CC_CUSTOM_STRINPUT_DIALOG     = 'CustomStrInputDialog';
  CC_MESSAGE_DIALOG             = 'MessageDialog';
  CC_TEXT_DIALOG                = 'TextDialog';
  //
  CC_GAME_WINDOW                = 'GameWindow';
  CC_CUT_SCENE_VIEW             = 'CutSceneView';
  CC_GAME_MAIN_MENU             = 'GameMainMenu';


  // property names for ZEWSBase module
  PROP_NAME_WINCLASS_NAME       = 'WClassName';
  PROP_NAME_ACTION_NAME         = 'ActionName';
  PROP_NAME_BOUNDS              = 'Bounds';
  PROP_NAME_CAPTION             = 'Caption';
  PROP_NAME_CONTROL_NAME        = 'Name';
  PROP_NAME_BACKCOLOR           = 'BackColor';
  PROP_NAME_SPRITE_NAME         = 'Sprite';
  PROP_NAME_FONT_NAME           = 'Font';
  // property names for ZEWSButtons
  PROP_NAME_GROUP_ID            = 'GroupId';
  PROP_NAME_PICTURE             = 'Picture';
  // property names for ZEWSStandard
  PROP_NAME_REPEAT_X            = 'RepeatX';
  PROP_NAME_REPEAT_Y            = 'RepeatY';
  PROP_NAME_CENTER_X            = 'CenterX';
  PROP_NAME_CENTER_Y            = 'CenterY';
  PROP_NAME_AUTO_WIDTH          = 'AutoWidth';
  PROP_NAME_AUTO_HEIGHT         = 'AutoHeight';
  PROP_NAME_ANIMATES            = 'Animates';
  PROP_NAME_ANIMATE_TICK        = 'AnimateTick';
  PROP_NAME_CONSUME_CLICK       = 'ConsumeClick';
  PROP_NAME_NEXT_SPRITE         = 'NextSprite';
  //
  PROP_NAME_PRESSED             = 'Pressed';
  PROP_NAME_COMMAND             = 'Command';
  PROP_NAME_AUTO_POPUP          = 'AutoPopup';
  PROP_NAME_THREE_STATE         = 'ThreeState';
  PROP_NAME_SHOW_CAPTION        = 'ShowCaption';
  // property names ZEWSLineEdit
  PROP_NAME_NUMEDIT_MAX         = 'NumEditMax';
  PROP_NAME_NUMEDIT_MIN         = 'NumEditMin';
  //
  PROP_NAME_CHECKED             = 'Checked';
  PROP_NAME_DRAW_BORDERS        = 'DrawBorders';
  // property names for ZEWSMisc
  PROP_NAME_FILLER_COLOR        = 'FillerColor';
  PROP_NAME_FILLER_IMAGE        = 'FillerImage';
  PROP_NAME_GAUGE_MIN           = 'GaugeMinimum';
  PROP_NAME_GAUGE_MAX           = 'GaugeMaximum';
  PROP_NAME_GAUGE_CURRENT       = 'GaugeCurrent';
  PROP_NAME_GAUGE_STYLE         = 'GaugeStyle';
  PROP_NAME_GAUGE_DIRECTION     = 'GaugeDirection';
  //
  PROP_NAME_AUTO_SCROLL         = 'AutoScroll';
  PROP_NAME_TEXT_TO_ADD         = 'TextToAdd';
  PROP_NAME_FILE_TO_LOAD        = 'FileToLoad';


  //
  // names of scripts we need...
  SCRIPT_GAME_GUI               = 'GameGUI';
  SCRIPT_MENU_GUI               = 'MenuGUI';
  SCRIPT_USER_EVENTS            = 'UserEventHandler';
  SCRIPT_GAME_IDLE              = 'GameIdle';

  //
  // names of desktops to use
  DESKTOP_CUT_SCENE             = 'DTCutScene';
  DESKTOP_MAIN                  = 'DTMain';
  DESKTOP_MENU                  = 'DTMenu';

  
implementation

end.

