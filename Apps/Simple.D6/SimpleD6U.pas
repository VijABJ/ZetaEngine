{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaMEDU.PAS
              Zeta Engine Delphi Template Support Unit
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$


 ============================================================================}

unit SimpleD6U;

interface


  function CreateInitialGUI (ScreenWidth, ScreenHeight: integer): integer; stdcall;
  function HandleUserEvents (iCommand, lData: integer): integer; stdcall;


implementation

uses
  SysUtils,
  Types,
  //
  ZEDXDev,
  //
  ZEWSDefines,
  ZEWSBase,
  ZEWSDialogs,
  ZEWSButtons,
  //
  ZZECore;


////////////////////////////////////////////////////////////////////
function CreateInitialGUI (ScreenWidth, ScreenHeight: integer): integer;
var
  Desktop: TZEDesktop;
  rBounds, rArea: TRect;
  Control: TZEControl;

begin
  // get the default desktop, and set global edit mode
  Desktop := CoreEngine.WinSysRoot [DESKTOP_MAIN];
  if (Desktop = NIL) then Exit;
  CoreEngine.WinSysRoot.UseDesktop (Desktop);
  //
  rBounds := Rect (ScreenWidth - 200, 10, ScreenWidth -10, 80);
  Control := CreateStandardButton (rArea, 'Exit', cmFinalExit);
  Desktop.Insert (Control);
  //
  Control.SetPropertyValue (PROP_NAME_CAPTION, 'EXIT');
  Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Default');
  Control.SetPropertyValue (PROP_NAME_FONT_NAME, 'StandardButton');
  Control.SetPropertyValue (PROP_NAME_COMMAND, IntToStr (cmFinalExit));
  //
  Result := 0;
end;

////////////////////////////////////////////////////////////////////
function HandleUserEvents (iCommand, lData: integer): integer;
begin
  Result := 0;
end;

end.

