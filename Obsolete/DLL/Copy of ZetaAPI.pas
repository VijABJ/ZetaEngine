{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaAPI.PAS
              Module containing external API interfaces to the engine
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DLL/ZetaAPI.pas,v 1.2 2002/10/01 13:50:47 Vij Exp $
  $Log: ZetaAPI.pas,v $
  Revision 1.2  2002/10/01 13:50:47  Vij
  Added PlayCutScene(), LoadWorld()

  Revision 1.1.1.1  2002/09/13 17:15:19  Vij
  Starting Version Control


  TODO:
  World_CreatePC
  World_DropPC
  World_ReplacePC

 ============================================================================}

unit ZetaAPI;

interface

uses
  Types,
  Windows,
  ZetaTypes;


  // ++++++++++++++++++++++++
  //  Windows (TM) Wrapper
  // ++++++++++++++++++++++++

  function ZEWW_Prepare (lpszConfigFile: PChar; lpfnCreateUICallback: tCALLBACK;
    lpfnHandleEventCallback: tCALLBACK): integer; stdcall;
  function ZEWW_CreateWindow (ClassRef: integer; hInstance: HINST;
    WindowClassName, WindowTitle: PChar; WindowProc: tCALLBACK;
    WindowFlags: DWORD; iWidth, iHeight: integer): tINTBOOL; stdcall;
  procedure ZEWW_Execute (ClassRef: integer); stdcall;
  procedure ZEWW_Shutdown (ClassRef: integer); stdcall;

  // ++++++++++++++++++++++++
  //  Engine Proper Routines
  // ++++++++++++++++++++++++

  function ZEE_Initialize (lpszConfigurationFile: PChar;
    hHostWindow: HWND; hAppInstance: HINST): tINTBOOL; stdcall;
  procedure ZEE_Shutdown; stdcall;
  procedure ZEE_TerminateSelf; stdcall;
  procedure ZEE_Activate; stdcall;
  procedure ZEE_Deactivate; stdcall;
  function ZEE_Refresh: tINTBOOL; stdcall;

  function ZEE_ScreenWidth: integer; stdcall;
  function ZEE_ScreenHeight: integer; stdcall;
  function ZEE_ScreenColorDepth: integer; stdcall;

  procedure ZEE_SetMusic (lpszMusicName: PChar); stdcall;
  procedure ZEE_ClearMusic; stdcall;
  procedure ZEE_PlaySound (lpszSoundName: PChar); stdcall;
  procedure ZEE_PlayCutScene (lpszCutSceneFile: PChar); stdcall;

  function ZEE_IsMusicActive: tINTBOOL; stdcall;
  procedure ZEE_ToggleMusic (ibActive: tINTBOOL); stdcall;
  function ZEE_IsSoundActive: tINTBOOL; stdcall;
  procedure ZEE_ToggleSound (ibActive: tINTBOOL); stdcall;
  procedure ZEE_ToggleFPSDisplay (ibVisible: tINTBOOL); stdcall;

  function ZEE_IsGlobalExitOnEscapeSet: tINTBOOL; stdcall;
  procedure ZEE_ToggleGlobalExitOnEscape (ibActive: tINTBOOL); stdcall;


  // ++++++++++++++++++++++++++
  //  Windowing System Helpers
  // ++++++++++++++++++++++++++

  function ZEUI_Root: tCONTROL; stdcall;
  function ZEUI_CreateDesktop (lpszRefName, lpszDeskName: PChar): tCONTROL; stdcall;
  function ZEUI_GetDesktop (lpszRefName: PChar): tCONTROL; stdcall;
  function ZEUI_SwitchDesktop (lpszRefName: PChar): tCONTROL; stdcall;
  function ZEUI_CreateGameView (Left, Top, Right, Bottom: integer): tCONTROL; stdcall;

  function ZEUI_CreateControl (lpszClassName: PChar;
    Left, Top, Right, Bottom: integer): tCONTROL; stdcall;
  procedure ZEUI_InsertControl (ctlDest, ctlToInsert: tCONTROL); stdcall;
  function ZEUI_GetProp (ControlRef: tCONTROL; lpszPropName: PChar): PChar; stdcall;
  procedure ZEUI_SetProp (ControlRef: tCONTROL; lpszPropName, lpszPropValue: PChar); stdcall;

  procedure ZEUI_ShowMsgBox (lpfnMessage: PChar); stdcall;
  procedure ZEUI_ShowMsgBoxEx (lpfnMessage: PChar; Left, Top, Right, Bottom: integer); stdcall;

  procedure ZEUI_Hide (ControlRef: tCONTROL); stdcall;
  procedure ZEUI_Show (ControlRef: tCONTROL); stdcall;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //  Game Stuff
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure ZEGE_LoadWorld (lpszWorldFile: PChar); stdcall;

  procedure ZEGE_CreatePC (lpszMasterName, lpszWorkingName: PChar;
    lpfnCallback: tCALLBACK); stdcall;
  procedure ZEGE_ReplacePC (lpszMasterName, lpszWorkingName: PChar;
    lpfnCallback: tCALLBACK); stdcall;
  procedure ZEGE_ClearPC; stdcall;

  procedure ZEGE_DropPC; stdcall;
  procedure ZEGE_DropPCEx (lpszAreaName: PChar; X, Y, Z: integer); stdcall;
  procedure ZEGE_UnDropPC; stdcall;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //  Rudimentary Scripting Support through Function Callbacks
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure ZESS_ClearCallbacks; stdcall;
  procedure ZESS_AddCallback (lpszRefName: PChar; lpfnCallback: tCALLBACK); stdcall;
  procedure ZESS_TerminateEngine; stdcall;


implementation

uses
  SysUtils,
  StrUtils,
  Math,
  //
  ZbScriptable,
  ZbScriptMaster,
  //
  ZEDXDev,
  ZEDXFramework,
  ZEWSDefines,
  ZEWSBase,
  ZEWSDialogs,
  //
  ZZEGameWindow,
  ZZEWorld,
  ZZECore,
  ZZEWinWrapper;



///////////////////////------------------------------------------------------
function ZEWW_Prepare (lpszConfigFile: PChar; lpfnCreateUICallback: tCALLBACK;
  lpfnHandleEventCallback: tCALLBACK): integer; stdcall;
begin
  Result := Integer (WrapperCreate (String (lpszConfigFile),
    TZbScriptCallback (lpfnCreateUICallback),
    TZbScriptCallback (lpfnHandleEventCallback)));
end;

///////////////////////------------------------------------------------------
function ZEWW_CreateWindow (ClassRef: integer; hInstance: HINST;
  WindowClassName, WindowTitle: PChar; WindowProc: tCALLBACK;
  WindowFlags: DWORD; iWidth, iHeight: integer): tINTBOOL; stdcall;
var
  Wrapper: TZEWindowsWrapper;
begin
  Result := IBOOL_FALSE;
  Wrapper := TZEWindowsWrapper (ClassRef);
  if (Wrapper = NIL) then Exit;
  //
  Result := IBOOL [Wrapper.CreateWindow (hInstance, WindowClassName, WindowTitle,
    TWindowsCallback (WindowProc), WindowFlags, iWidth, iHeight)];
end;

///////////////////////------------------------------------------------------
procedure ZEWW_Execute (ClassRef: integer); stdcall;
begin
  if (Classref <> 0) then try
    TZEWindowsWrapper (ClassRef).Execute;
  except end;
end;

///////////////////////------------------------------------------------------
procedure ZEWW_Shutdown (ClassRef: integer); stdcall;
begin
  if (Classref <> 0) then try
    TZEWindowsWrapper (ClassRef).Free;
  except end;
end;


///////////////////////------------------------------------------------------
function ZEE_Initialize (lpszConfigurationFile: PChar;
  hHostWindow: HWND; hAppInstance: HINST): tINTBOOL; stdcall;
begin
  if (CoreEngine = NIL) then begin
    CoreEngine := TZEGameCore.Create (string (lpszConfigurationFile));
    CoreEngine.Initialize (hHostWindow, hAppInstance);
  end;
  Result := IBOOL [(CoreEngine <> NIL) AND (CoreEngine.Ready)];
end;

///////////////////////------------------------------------------------------
procedure ZEE_Shutdown; stdcall;
begin
  if (CoreEngine <> NIL) then FreeAndNIL (CoreEngine);
end;

///////////////////////------------------------------------------------------
procedure ZEE_TerminateSelf; stdcall;
begin
  PostQuitMessage (0);
end;

///////////////////////------------------------------------------------------
procedure ZEE_Activate; stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.Activate;
end;

///////////////////////------------------------------------------------------
procedure ZEE_Deactivate; stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.Deactivate;
end;

///////////////////////------------------------------------------------------
function ZEE_Refresh: tINTBOOL; stdcall;
begin
  Result := IBOOL_TRUE;
  if (CoreEngine = NIL) then Exit;
  Result := IBOOL [CoreEngine.Refresh];
end;

///////////////////////------------------------------------------------------
function ZEE_ScreenWidth: integer; stdcall;
begin
  Result := IfThen (CoreEngine = NIL, 0, CoreEngine.ScreenWidth);
end;

///////////////////////------------------------------------------------------
function ZEE_ScreenHeight: integer; stdcall;
begin
  Result := IfThen (CoreEngine = NIL, 0, CoreEngine.ScreenHeight);
end;

///////////////////////------------------------------------------------------
function ZEE_ScreenColorDepth: integer; stdcall;
begin
  Result := IfThen (CoreEngine = NIL, 0, CoreEngine.ScreenDepth);
end;

///////////////////////------------------------------------------------------
procedure ZEE_SetMusic (lpszMusicName: PChar); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.SetBackgroundMusic (string (lpszMusicName));
end;

///////////////////////------------------------------------------------------
procedure ZEE_ClearMusic; stdcall;
begin
  if (CoreEngine <> NIL)then CoreEngine.ClearBackgroundMusic;
end;

///////////////////////------------------------------------------------------
procedure ZEE_PlaySound (lpszSoundName: PChar); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.PlaySound (string (lpszSoundName));
end;

///////////////////////------------------------------------------------------
procedure ZEE_PlayCutScene (lpszCutSceneFile: PChar); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.PlayCutScene (lpszCutSceneFile);
end;

///////////////////////------------------------------------------------------
function ZEE_IsMusicActive: tINTBOOL; stdcall;
begin
  if (CoreEngine <> NIL) then
    Result := IBOOL [CoreEngine.Music]
    else Result := IBOOL_FALSE;
end;

///////////////////////------------------------------------------------------
procedure ZEE_ToggleMusic (ibActive: tINTBOOL); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.Music := (ibActive <> IBOOL_FALSE);
end;

///////////////////////------------------------------------------------------
function ZEE_IsSoundActive: tINTBOOL; stdcall;
begin
  if (CoreEngine <> NIL) then
    Result := IBOOL [CoreEngine.SoundFX]
    else Result := IBOOL_FALSE;
end;

///////////////////////------------------------------------------------------
procedure ZEE_ToggleSound (ibActive: tINTBOOL); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.SoundFX := (ibActive <> IBOOL_FALSE);
end;

///////////////////////------------------------------------------------------
procedure ZEE_ToggleFPSDisplay (ibVisible: tINTBOOL); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.FPSVisible := (ibVisible <> IBOOL_FALSE);
end;

///////////////////////------------------------------------------------------
function ZEE_IsGlobalExitOnEscapeSet: tINTBOOL; stdcall;
begin
  Result := IBOOL [GlobalExitOnEscape];
end;

///////////////////////------------------------------------------------------
procedure ZEE_ToggleGlobalExitOnEscape (ibActive: tINTBOOL); stdcall;
begin
  GlobalExitOnEscape := (ibActive <> IBOOL_FALSE);
end;


///////////////////////------------------------------------------------------
function ZEUI_Root: tCONTROL; stdcall;
begin
  if (CoreEngine <> NIL) then
    Result := tCONTROL (CoreEngine.WinSysRoot)
    else Result := tNULL_CONTROL;
end;

///////////////////////------------------------------------------------------
function ZEUI_CreateDesktop (lpszRefName, lpszDeskName: PChar): tCONTROL; stdcall;
begin
  if (CoreEngine <> NIL) then
    Result := tCONTROL (CoreEngine.WinSysRoot.AddDesktop (string (lpszRefName), string(lpszDeskName)))
    else Result := tNULL_CONTROL;
end;

///////////////////////------------------------------------------------------
function ZEUI_SwitchDesktop (lpszRefName: PChar): tCONTROL; stdcall;
var
  ctlDesk: TZEDesktop;
begin
  Result := tNULL_CONTROL;
  if (CoreEngine <> NIL) then begin
    ctlDesk := CoreEngine.WinSysRoot [string (lpszRefName)];
    if (ctlDesk <> NIL) then begin
      CoreEngine.WInSysRoot.UseDesktop (ctlDesk);
      Result := tCONTROL (ctlDesk);
    end;
  end;
end;

///////////////////////------------------------------------------------------
function ZEUI_GetDesktop (lpszRefName: PChar): tCONTROL; stdcall;
begin
  if (CoreEngine <> NIL) then 
    Result := tCONTROL (CoreEngine.WinSysRoot [string (lpszRefName)])
    else Result := tNULL_CONTROL;
end;

///////////////////////------------------------------------------------------
function ZEUI_CreateGameView (Left, Top, Right, Bottom: integer): tCONTROL; stdcall;
begin
  Result := tNULL_CONTROL;
  if (CoreEngine = NIL) then Exit;
  //
  if (GameWindow <> NIL) then FreeAndNIL (GameWindow);
  GameWindow := TZEGameWindow.Create (Rect (Left, Top, Right, Bottom));
  //
  //GlobalViewEditMode := TRUE;
  Result := tCONTROL (GameWindow);
end;

///////////////////////------------------------------------------------------
function ZEUI_CreateControl (lpszClassName: PChar;
  Left, Top, Right, Bottom: integer): tCONTROL; stdcall;
begin
  if (CoreEngine <> NIL) then
    Result := tCONTROL (CreateControl (string (lpszClassName), Rect (Left, Top, Right, Bottom)))
    else Result := tNULL_CONTROL;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_InsertControl (ctlDest, ctlToInsert: tCONTROL); stdcall;
var
  Group: TZEGroupControl;
  Control: TZEControl;
begin
  Group := TZEGroupControl (ctlDest);
  Control := TZEControl (ctlToInsert);
  if ((Group = NIL) OR (Control = NIL)) then Exit;
  //
  try
    Group.Insert (Control);
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEUI_GetProp (ControlRef: tCONTROL; lpszPropName: PChar): PChar; stdcall;
var
  Scriptable: TZbScriptable;
begin
  Result := NIL;
  Scriptable := TZbScriptable (ControlRef);
  try
    Result := PChar (Scriptable.GetPropertyValue (string (lpszPropName)));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_SetProp (ControlRef: tCONTROL; lpszPropName, lpszPropValue: PChar); stdcall;
var
  Scriptable: TZbScriptable;
begin
  Scriptable := TZbScriptable (ControlRef);
  try
    Scriptable.SetPropertyValue (lpszPropName, lpszPropValue);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_ShowMsgBox (lpfnMessage: PChar); stdcall;
var
  cData: String;
begin
  cData := String (lpfnMessage);
  CoreEngine.ShowMsgBox (cData);
end;

///////////////////////------------------------------------------------------
procedure ZEUI_ShowMsgBoxEx (lpfnMessage: PChar; Left, Top, Right, Bottom: integer); stdcall;
var
  cData: String;
begin
  cData := String (lpfnMessage);
  CoreEngine.ShowMsgBox (cData, Rect (Left, Top, Right, Bottom));
end;

///////////////////////------------------------------------------------------
procedure ZEUI_Hide (ControlRef: tCONTROL); stdcall;
begin
  try
    TZEControl (ControlRef).Hide;
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_Show (ControlRef: tCONTROL); stdcall;
begin
  try
    TZEControl (ControlRef).Show;
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEGE_LoadWorld (lpszWorldFile: PChar); stdcall;
begin
  GameWorld.LoadFromFile (string (lpszWorldFile));
end;

///////////////////////------------------------------------------------------
procedure ZEGE_CreatePC (lpszMasterName, lpszWorkingName: PChar; lpfnCallback: tCALLBACK); stdcall;
begin
  GameWorld.CreatePC (
    String (lpszMasterName), String (lpszWorkingName),
    TZEEntityHandler (lpfnCallback));
end;

///////////////////////------------------------------------------------------
procedure ZEGE_ReplacePC (lpszMasterName, lpszWorkingName: PChar; lpfnCallback: tCALLBACK); stdcall;
begin
  GameWorld.ReplacePC (
    String (lpszMasterName), String (lpszWorkingName),
    TZEEntityHandler (lpfnCallback));
end;

///////////////////////------------------------------------------------------
procedure ZEGE_ClearPC; stdcall;
begin
  GameWorld.ClearPC;
end;

///////////////////////------------------------------------------------------
procedure ZEGE_DropPC; stdcall;
begin
  GameWorld.DropPC;
end;

///////////////////////------------------------------------------------------
procedure ZEGE_DropPCEx (lpszAreaName: PChar; X, Y, Z: integer); stdcall;
begin
  GameWorld.DropPC (String (lpszAreaName), X, Y, Z);
end;

///////////////////////------------------------------------------------------
procedure ZEGE_UnDropPC; stdcall;
begin
  GameWorld.UnDropPC;
end;

///////////////////////------------------------------------------------------
procedure ZESS_ClearCallbacks; stdcall;
begin
  if (ScriptMaster <> NIL) then ScriptMaster.Clear;
end;

///////////////////////------------------------------------------------------
procedure ZESS_AddCallback (lpszRefName: PChar; lpfnCallback: tCALLBACK); stdcall;
begin
  if (ScriptMaster <> NIL) then
    ScriptMaster.AddHandler (lpszRefName, TZbScriptCallback (lpfnCallback));
end;

///////////////////////------------------------------------------------------
procedure ZESS_TerminateEngine; stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.Terminate;
end;


end.

