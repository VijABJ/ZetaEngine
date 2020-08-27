unit ZZIE_API;

interface

uses
  Windows;

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // API set for managing multiple rectangles on a gridded
  // image.  these are also used by engine itself
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function ZZIE_MultiRectsCreate (cFileName: PChar): integer; stdcall;
  procedure ZZIE_MultiRectsDelete (Handle: integer); stdcall;
  function ZZIE_MultiRectsCount (Handle: integer): integer; stdcall;
  function ZZIE_MultiRectsGetRect (Handle: integer;
    iFrameNumber: integer; var R: TRect): integer; stdcall;
  procedure ZZIE_MultiRectsCopyFrame (
    Handle: integer; iFrameNumber: integer;
    dcDest: HDC; destWidth, destHeight: integer); stdcall;

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Functions to manipulate the engine itself
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function ZZIE_EngineInitialize (cFileName: PChar; hHost: HWND): integer; stdcall;
  procedure ZZIE_EngineShutdown; stdcall;
  procedure ZZIE_EngineActivate; stdcall;
  procedure ZZIE_EngineDeactivate; stdcall;
  function ZZIE_EngineRefresh: integer; stdcall;

  procedure ZZIE_SetMusic (AMusicName: PChar); stdcall;
  procedure ZZIE_ClearMusic; stdcall;
  procedure ZZIE_PlaySound (ASoundName: PChar); stdcall;

  procedure ZZIE_EngineSetPlayMode; stdcall;
  procedure ZZIE_EnginePlayCutScene (ACutSceneScript: PChar); stdcall;

  procedure ZZIE_HideFPSDisplay; stdcall;
  procedure ZZIE_ShowFPSDisplay; stdcall;

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // interface to the map and level and tiles
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure ZZIE_MapCreate (cMapName: PChar; Width, Height: integer); stdcall;
  procedure ZZIE_MapAddLevel; stdcall;
  function ZZIE_MapAddEntity (cName, cFamilyName, cSubClassName: PChar;
    iLevel, X, Y: integer): integer; stdcall;
  function ZZIE_MapAddEntityEx (cName, cFamilyName, cSubClassName: PChar;
    iSubClassNumber, iLevel, X, Y: integer): integer; stdcall;

  procedure ZZIE_DeleteEntity (Entity: integer); stdcall;

  function ZZIE_CreateEntity (cName, cFamilyName, cSubClassName: PChar): integer; stdcall;
  function ZZIE_GetTile (iLevel, X, Y: integer): integer; stdcall;
  procedure ZZIE_DropPartyOnMap; stdcall;
  procedure ZZIE_DropPartyOnMapEx (iLevel, X, Y: integer); stdcall;

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // some helpers...
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure ZZIE_TogglePaused; stdcall;
  function ZZIE_GetPauseState: integer; stdcall;
  procedure ZZIE_StopGame; stdcall;
  procedure ZZIE_DisableSounds; stdcall;
  procedure ZZIE_EnableSounds; stdcall;

  function ZZIE_GetDisplayWidth: integer; stdcall;
  function ZZIE_GetDisplayHeight: integer; stdcall;

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // control manipulations
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function ZZIE_RootControl: integer; stdcall;
  function ZZIE_CreateDesktop (ARefName, ADesktopName: PChar): integer; stdcall;
  function ZZIE_CreateGameWindow (Left, Top, Right, Bottom: integer): integer; stdcall;

  function ZZIE_ControlCreate (AClassName: PChar;
    Left, Top, Right, Bottom: integer): integer; stdcall;
  function ZZIE_ControlGetProp (ControlRef: integer; APropName: PChar): PChar; stdcall;
  procedure ZZIE_ControlSetProp (ControlRef: integer; APropName, APropValue: PChar); stdcall;
  procedure ZZIE_ControlInsert (ADest: integer; AControl: integer); stdcall;

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // scripting support through callback
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure ZZIE_ClearCallbacks; stdcall;
  procedure ZZIE_AddCallback (AName: PChar; ARoutine: integer); stdcall;
  procedure ZZIE_TerminateEngine; stdcall;


implementation

uses
  //ZEDXDev,
  Types,
  SysUtils,
  StrUtils,
  JclStrings,
  ZbScriptable,
  ZbScriptMaster,
  ZEDXImage,
  ZZETools,
  ZZEBaseClasses,
  ZZEGameEngine,
  ZZEGameCentral,
  ZEWSBase,
  ZEWSDialogs,
  ZZEGameWindow;


type
  PZE_RectsList = ^TZE_RectsList;
  TZE_RectsList = record
    HBM: hBitmap;
    Count: integer;
    FRects: PRect;
  end;


//////////////////////////////////////////////////////////////////////////
function ZZIE_MultiRectsCreate (cFileName: PChar): integer;
var
  iRectsCounted : integer;                // number of frames counted
  FRects        : PRect;                  // the rects list
  rList         : PZE_RectsList;          // our return value, if any
  HBM           : hBitmap;                // handle to bitmap
  dcSource      : HDC;
  Width, Height : integer;
begin
  // assume no return value
  Result := 0;

  // load the bitmap file
  HBM := LoadBitmapFile (cFileName, Width, Height);
  if (HBM = 0) then exit;

  // Create DC for the BMP.
  dcSource := CreateCompatibleDC (0);
  if (dcSource = 0) then exit;
  SelectObject (dcSource, HBM);

  // create the rectangle array
  iRectsCounted := MultiRectsCreate (dcSource, Width, Height, FRects);

  // free the DC, we're done with it now
  DeleteDC (dcSource);

  // allocate the return record if successful
  if (FRects <> NIL) then
    begin
      New (rList);
      rList.Count := iRectsCounted;
      rList.FRects := FRects;
      rList.HBM := HBM;
    end
  else
  // failed.  make sure list structure is NIL and release the
  // bitmap handle
    begin
      rList := NIL;
      DeleteObject (HBM);
    end;

  // return the structure as an integer
  Result := integer (rList);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_MultiRectsDelete (Handle: integer);
var
  rList: PZE_RectsList;
begin
  try
    rList := PZE_RectsList (Handle);
    if (rList <> NIL) then
      begin
        DeleteObject (rList.HBM);
        FreeMem (rList.FRects, sizeof (TRect) * rList.Count);
        Dispose (rList);
      end;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_MultiRectsCount (Handle: integer): integer;
var
  rList: PZE_RectsList;
begin
  Result := 0;
  try
    rList := PZE_RectsList (Handle);
    if (rList <> NIL) then
      Result := rList.Count;
  except
  end;
end;

///////Internal Helper Function///////////////////////////////////////////
function GetFrameRect (rList: PZE_RectsList; iFrameNumber: integer): TRect;
var
  lpRect: PRect;
begin
  lpRect := rList.FRects;
  Inc (integer (lpRect), sizeof (TRect) * iFrameNumber);
  Result := lpRect^;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_MultiRectsGetRect (Handle: integer; iFrameNumber: integer;
  var R: TRect): integer;
var
  rList: PZE_RectsList;
begin
  // return 0 by default, this is an error return
  Result := 0;

  try
    rList := PZE_RectsList (Handle);
    if ((rList = NIL) OR (rList.FRects = NIL) OR
        (iFrameNumber >= rList.Count)) then exit;
  except
    Exit;
  end;

  R := GetFrameRect (rList, iFrameNumber);
  Result := 1;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_MultiRectsCopyFrame (
  Handle: integer; iFrameNumber: integer;
  dcDest: HDC; destWidth, destHeight: integer);
var
  rList: PZE_RectsList;
  dcSource: HDC;
  R: TRect;
begin
  // validate inputs
  if ((dcDest = 0) OR (destWidth <= 0) OR (destHeight <= 0)) then exit;

  try
    rList := PZE_RectsList (Handle);
    if ((rList = NIL) OR (rList.FRects = NIL) OR
        (iFrameNumber >= rList.Count)) then exit;
  except
    Exit;
  end;

  // Create DC for the BMP.
  dcSource := CreateCompatibleDC (0);
  if (dcSource = 0) then exit;
  SelectObject (dcSource, rList.HBM);

  // perform copy on proper rectangle
  R := GetFrameRect (rList, iFrameNumber);
  StretchBlt (
    dcDest, 0, 0, destWidth, destHeight,
    dcSource, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top,
    SRCCOPY);

  //
  DeleteDC (dcSource);
end;


//////////////////////////////////////////////////////////////////////////
function ZZIE_EngineInitialize (cFileName: PChar; hHost: HWND): integer;
var
  sFileName: string;
begin
  Result := 0;
  if (GameEngine <> NIL) then exit;
  //
  sFileName := string (cFileName);
  GameEngine := TZEGameEngine.Create (sFileName);
  if (GameEngine = NIL) then exit;
  //
  GameEngine.Initialize (hHost);
  Result := integer (GameEngine.GameReady);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_EngineShutdown;
begin
  if (GameEngine = NIL) then exit;
  GameEngine.Free;
  GameEngine := NIL;
  //FreeAndNIL (GameEngine);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_EngineActivate;
begin
  if (GameEngine <> NIL) then GameEngine.Activate;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_EngineDeactivate;
begin
  if (GameEngine <> NIL) then GameEngine.Deactivate;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_EngineRefresh: integer;
begin
//try
  if (GameEngine <> NIL) then
    Result := integer (GameEngine.Refresh)
  else
    Result := 1;
//except
//  on E: Exception do DebugPrint ('EX: Refresh(): ' + E.Message);
//end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_SetMusic (AMusicName: PChar); stdcall;
begin
  if (GameEngine <> NIL) then
    GameEngine.SetBackgroundMusic (string (AMusicName));
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_ClearMusic; stdcall;
begin
  if (GameEngine <> NIL) then
    GameEngine.ClearBackgroundMusic;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_PlaySound (ASoundName: PChar);
begin
  if (GameEngine <> NIL) then
    GameEngine.PlaySound (string (ASoundName));
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_EngineSetPlayMode;
begin
  if (GameEngine <> NIL) then
    GameEngine.Mode := emPlayingGame;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_EnginePlayCutScene (ACutSceneScript: PChar);
begin
  if (ACutSceneScript <> NIL) then
    begin
      // maybe load a script file here to drive the cutscene engine?
      // then just perform a {GameEngine.Mode := emCutScene}
    end;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_HideFPSDisplay;
begin
  if (GameEngine <> NIL) then GameEngine.ToggleFPSDisplay (false);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_ShowFPSDisplay;
begin
  if (GameEngine <> NIL) then GameEngine.ToggleFPSDisplay (true);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_MapCreate (cMapName: PChar; Width, Height: integer);
begin
  GameCentral.CreateMap (cMapName, Width, Height);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_MapAddLevel;
begin
  if (GameCentral.Map <> NIL) then GameCentral.MapAddLevel;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_MapAddEntity (cName, cFamilyName, cSubClassName: PChar;
  iLevel, X, Y: integer): integer;
var
  Tile: TZETile;
  Entity: TZEBasicEntity;
begin
  Result := 0;
  //
  Tile := TZETile (ZZIE_GetTile (iLevel, X, Y));
  if (Tile = NIL) then Exit;
  //
  Entity := TZEBasicEntity (ZZIE_CreateEntity (cName, cFamilyName, cSubClassName));
  if (Entity = NIL) then Exit;
  //
  GameCentral.Map.AddEntity (Tile, Entity);
  Result := integer (Entity);
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_MapAddEntityEx (cName, cFamilyName, cSubClassName: PChar;
  iSubClassNumber, iLevel, X, Y: integer): integer;
var
  sSubClassName: string;
begin
  sSubClassName := string (cSubClassName) +
    StrPadLeft (IntToStr (iSubClassNumber), 2, '0');
  Result := ZZIE_MapAddEntity (cName, cFamilyName, PChar (sSubClassName), iLevel, X, Y);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_DeleteEntity (Entity: integer); stdcall;
var
  Victim: TZEBasicEntity;
begin
  try
    Victim := TZEBasicEntity (Entity);
    if (Victim = NIL) OR (Victim.AtTile = NIL) then Exit;
    //
    Victim.AtTile.RemoveEntity (Victim);
    Victim.Free;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_CreateEntity (cName, cFamilyName, cSubClassName: PChar): integer; stdcall;
begin
  Result := integer (DisplayManager.MakeEntity (string (cFamilyName),
    string (cSubClassName), string (cName)));
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_GetTile (iLevel, X, Y: integer): integer; stdcall;
var
  Level: TZELevel;
begin
  Result := 0;
  //
  if (GameCentral.Map <> NIL) then
    begin
      Level := GameCentral.Map [iLevel];
      if (Level <> NIL) then
        Result := integer (Level [X,Y]);
      //
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_DropPartyOnMap; stdcall;
begin
  if (GameCentral <> NIL) then GameCentral.DropPCOnMap;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_DropPartyOnMapEx (iLevel, X, Y: integer); stdcall;
begin
  GameCentral.Map.StartPoint := Point (X, Y);
  ZZIE_DropPartyOnMap;
end;


//////////////////////////////////////////////////////////////////////////
procedure ZZIE_TogglePaused; stdcall;
begin
  GameCentral.Paused := NOT GameCentral.Paused;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_GetPauseState: integer; stdcall;
begin
  Result := Integer (GameCentral.Paused);
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_StopGame; stdcall;
begin
  GameCentral.Stopped := true;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_DisableSounds; stdcall;
begin
  if (GameEngine <> NIL) then
    GameEngine.NoSound := true;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_EnableSounds; stdcall;
begin
  if (GameEngine <> NIL) then
    GameEngine.NoSound := false;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_GetDisplayWidth: integer;
begin
  if (GameEngine <> NIL) then
    Result := GameEngine.Resolution.Width
  else
    Result := 0;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_GetDisplayHeight: integer;
begin
  if (GameEngine <> NIL) then
    Result := GameEngine.Resolution.Height
  else
    Result := 0;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_RootControl: integer;
begin
  if (GameEngine <> NIL) then
    Result := integer (GameEngine.RootWindow)
  else
    Result := 0;
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_CreateDesktop (ARefName, ADesktopName: PChar): integer;
var
  Desktop: TZEDesktop;
begin
  Result := 0;
  if (GameEngine = NIL) then Exit;
  //
  Desktop := GameEngine.RootWindow [string (ARefName)];
  if (Desktop = NIL) then
    Desktop := GameEngine.RootWindow.AddDesktop (string (ARefName), string (ADesktopName));
  //
  Result := integer (Desktop);
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_CreateGameWindow (Left, Top, Right, Bottom: integer): integer;
var
  R: TRect;
begin
  if (GameWindow = NIL) then
    begin
      R := Rect (Left, Top, Right, Bottom);
      GameWindow := TZEGameWindow.Create (R);
      //GameWindow.MapView := GameCentral.MapView;
      GameCentral.CenterMapAtCenter;
    end;
  //
  Result := integer (GameWindow);
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_ControlCreate (AClassName: PChar;
  Left, Top, Right, Bottom: integer): integer;
begin
  Result := integer (CreateControl (AClassName, Rect (Left, Top, Right, Bottom)));
end;

//////////////////////////////////////////////////////////////////////////
function ZZIE_ControlGetProp (ControlRef: integer; APropName: PChar): PChar;
var
  Scriptable: TZbScriptable;
begin
  Result := NIL;
  Scriptable := TZbScriptable (ControlRef);
  try
    Result := PChar (Scriptable.GetPropertyValue (string (APropName)));
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_ControlSetProp (ControlRef: integer; APropName, APropValue: PChar);
var
  Scriptable: TZbScriptable;
begin
  Scriptable := TZbScriptable (ControlRef);
  try
    Scriptable.SetPropertyValue (APropName, APropValue);
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_ControlInsert (ADest: integer; AControl: integer);
var
  Group: TZEGroupControl;
  Control: TZEControl;
begin
  Group := TZEGroupControl (ADest);
  Control := TZEControl (AControl);
  if ((Group = NIL) OR (Control = NIL)) then Exit;
  //
  try
    Group.Insert (Control);
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_ClearCallbacks; stdcall;
begin
  if (ScriptMaster <> NIL) then
    ScriptMaster.Clear;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_AddCallback (AName: PChar; ARoutine: integer);
begin
  if (ScriptMaster <> NIL) then
    ScriptMaster.AddHandler (AName, TZbScriptCallback (ARoutine));
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZIE_TerminateEngine;
begin
  if (GameEngine <> NIL) then GameEngine.TerminateEngine;
end;

end.

