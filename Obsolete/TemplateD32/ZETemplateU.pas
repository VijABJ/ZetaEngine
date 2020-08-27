{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZETemplateU.PAS
              Primary Unit for Zeta Engine Template
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Apps/TemplateD32/ZETemplateU.pas,v 1.1.1.1 2002/09/12 12:46:14 Vij Exp $
  $Log: ZETemplateU.pas,v $
  Revision 1.1.1.1  2002/09/12 12:46:14  Vij
  Starting Version Control


 ============================================================================}

unit ZETemplateU;

interface


  function CreateInitialGUI (ScreenWidth, ScreenHeight: integer): integer; stdcall;
  function HandleUserEvents (iCommand, lParam2: integer): integer; stdcall;


implementation

uses
  Types,
  ZbGameUtils,
  //
  ZEDXDev,
  ZEDXFramework,
  //
  ZEWSDefines,
  ZEWSBase,
  ZEWSButtons,
  ZEWSMisc,
  ZEWSDialogs,
  //
  ZZEGameWindow,
  ZZEViewMap,
  //
  ZZECore;

const
  cmSwitchToMainDesktop   = 3001;
  cmSwitchToAltDesktop    = 3002;


////////////////////////////////////////////////////////////////////
function CreateInitialGUI (ScreenWidth, ScreenHeight: integer): integer;
var
  Desktop: TZEDesktop;
  Control: TZEControl;
begin
  Desktop := CoreEngine.WinSysRoot [DESKTOP_MAIN];
  GlobalViewEditMode := TRUE;
  //
  GameWindow := TZEGameWindow.Create (ExpandRect (Desktop.LocalBounds, -5, -5));
  GameWindow.ViewMap := Map;
  Desktop.Insert (GameWindow);
  //
  Control := CreateStandardButton (Rect (300, 0, 400, 260), 'Exit', cmFinalExit);
  Desktop.Insert (Control);
  Control.SetPropertyValue (PROP_NAME_FONT_NAME, CC_STANDARD_BUTTON);
  //
  Control := CreateStandardButton (Rect (300, 60, 400, 260), 'Switch', cmSwitchToAltDesktop);
  Desktop.Insert (Control);
  Control.SetPropertyValue (PROP_NAME_FONT_NAME, CC_STANDARD_BUTTON);
  //
  Desktop := CoreEngine.WinSysRoot.AddDesktop ('AltDesktop', 'AltDesktop');
  Control := CreateStandardButton (Rect (300, 60, 400, 260), 'Switch', cmSwitchToMainDesktop);
  Desktop.Insert (Control);
  Control.SetPropertyValue (PROP_NAME_FONT_NAME, CC_STANDARD_BUTTON);
  //
  Result := 0;
end;

////////////////////////////////////////////////////////////////////
function HandleUserEvents (iCommand, lParam2: integer): integer;
begin
  case iCommand of
    cmSwitchToMainDesktop:
      CoreEngine.WinSysRoot.UseDesktop (DESKTOP_MAIN);
    cmSwitchToAltDesktop:
      CoreEngine.WinSysRoot.UseDesktop ('AltDesktop');
  end;
  Result := 0;
end;


end.
