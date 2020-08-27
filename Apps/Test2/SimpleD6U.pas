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


const
  GT: string =
    'HAPPY BIRTHDAY DINDIN! (27 ka na!)#BE HAPPY HA?#SORRY KUNG NAG-AWAY TAYO#' +
    'LOVE PA RIN KITA KAHIT GANUN#I LOVE YOU VERY MUCH!#' +
    'HAPPY BIRTHDAY ULIT!#OO NGA PALA, DID I MENTION I LOVE YOU?#' +
    '- LOVING YOU, VIJ DA KYUT.$';
var
  txtControl: TZEControl;
  //
  iStrPos: Integer = 0;
  CurrentStr: String = '';
  //
  iLastTick: integer = 0;
  iElapsed: Integer = 0;


////////////////////////////////////////////////////////////////////
function CreateInitialGUI (ScreenWidth, ScreenHeight: integer): integer;
var
  Desktop: TZEDesktop;
  rBounds: TRect;
  Control: TZEControl;
  StartRow: Integer;

begin
  // get the default desktop, and set global edit mode
  Desktop := CoreEngine.WinSysRoot [DESKTOP_MAIN];
  if (Desktop = NIL) then Exit;
  CoreEngine.WinSysRoot.UseDesktop (Desktop);
  //
  StartRow := (ScreenHeight - 100) div 2;
  rBounds := Rect (0, StartRow, ScreenWidth, StartRow + 100);
  txtControl := CreateControl (CC_TEXT, rBounds);
  txtControl.SetPropertyValue (PROP_NAME_CAPTION, '');
  Desktop.Insert (txtControl);
  //
  Inc (StartRow, 200);
  rBounds := Rect (ScreenWidth - 200, StartRow, ScreenWidth -10, StartRow + 80);
  Control := CreateStandardButton (rBounds, 'Exit', cmFinalExit);
  Desktop.Insert (Control);
  //
  Control.SetPropertyValue (PROP_NAME_CAPTION, 'EXIT');
  Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Default');
  Control.SetPropertyValue (PROP_NAME_FONT_NAME, 'StandardButton');
  Control.SetPropertyValue (PROP_NAME_COMMAND, IntToStr (cmFinalExit));
  Control.Hide;
  //
  //
  CoreEngine.FPSVisible := FALSE;
  CoreEngine.StartCountdownTimer (10, 0);
  //
  Result := 0;
end;

////////////////////////////////////////////////////////////////////
function HandleUserEvents (iCommand, lData: integer): integer;
begin
  Result := 0;
  //
  if (iCommand = cmEngineTimerTick) then begin
    if (iLastTick = 0) then iLastTick := lData;
    iElapsed := iLastTick - lData;
    if (iElapsed >= 500) then begin
      iLastTick := lData;
      Inc (iStrPos);
      //
      if (GT [iStrPos] = '$') then
        EventQueue.InsertEvent (cmFinalExit)
      else begin
        if (GT [iStrPos] = '#') then begin
          CurrentStr := '';
          Inc (iStrPos);
        end;
        CurrentStr := CurrentStr + GT [iStrPos];
        txtControl.SetPropertyValue (PROP_NAME_CAPTION, CurrentStr);
      end;
      //
    end;
  end;
end;

end.

