{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaAPI.PAS
              Module containing external API interfaces to the engine
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DLL/ZetaAPI.pas,v 1.4 2002/12/18 08:28:50 Vij Exp $
  $Log: ZetaAPI.pas,v $
  Revision 1.4  2002/12/18 08:28:50  Vij
  New API functions added

  Revision 1.3  2002/11/02 07:03:57  Vij
  lots of new exports here.  will be subsumed into ZetaInterfaces as soon as
  I figure out how to access COM-like interfaces directly from VB

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
  ZbGameUtils,
  ZZEWorld,
  ZetaTypes;


  // ++++++++++++++++++++++++
  // Global Runner
  // ++++++++++++++++++++++++

  procedure ZETA_Run (
    EscapeExits: Integer; hInstance: HINST;
    AWinTitle, AProgConfig: PChar;
    lpfnCreateUICallback, lpfnHandleEventCallback: tCALLBACK); stdcall;

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
  procedure ZEE_TerminateEngine; stdcall;
  procedure ZEE_Activate; stdcall;
  procedure ZEE_Deactivate; stdcall;
  function ZEE_Refresh: tINTBOOL; stdcall;
  procedure ZEE_PushEvent (EventCommand: Integer); stdcall;
  procedure ZEE_AddCallback (AName: PChar; ACallback: tCALLBACK); stdcall;

  function ZEE_ScreenWidth: integer; stdcall;
  function ZEE_ScreenHeight: integer; stdcall;
  function ZEE_ScreenColorDepth: integer; stdcall;

  procedure ZEE_SetMusic (lpszMusicName: PChar); stdcall;
  procedure ZEE_ClearMusic; stdcall;
  procedure ZEE_PlaySound (lpszSoundName: PChar); stdcall;
  procedure ZEE_PlayCutScene (lpszCutSceneFile: PChar); stdcall;

  procedure ZEE_TogglePause (ibActive: tINTBOOL); stdcall;
  function ZEE_IsMusicActive: tINTBOOL; stdcall;
  procedure ZEE_ToggleMusic (ibActive: tINTBOOL); stdcall;
  function ZEE_IsSoundActive: tINTBOOL; stdcall;
  procedure ZEE_ToggleSound (ibActive: tINTBOOL); stdcall;
  procedure ZEE_ToggleFPSDisplay (ibVisible: tINTBOOL); stdcall;

  procedure ZEE_StartTimer (ATimerValue: Cardinal); stdcall;
  procedure ZEE_StartTimerEx (AMinutes, ASeconds: Cardinal); stdcall;
  procedure ZEE_PauseTimer; stdcall;
  procedure ZEE_UnPauseTimer; stdcall;
  procedure ZEE_StopTimer; stdcall;

  function ZEE_IsGlobalExitOnEscapeSet: tINTBOOL; stdcall;
  procedure ZEE_ToggleGlobalExitOnEscape (ibActive: tINTBOOL); stdcall;

  function ZEE_CmpStr (Ref, pCmp: PChar): Integer; stdcall;

  procedure ZEE_AddKeyHook (KeyCode, UserHandler: Integer); stdcall;
  procedure ZEE_ClearKeyHook (KeyCode: Integer); stdcall;

  function ZEE_GetElapsedTicks: Integer; stdcall;
  function ZEE_GetMouseX: Integer; stdcall;
  function ZEE_GetMouseY: Integer; stdcall;

  procedure ZEE_DebugText (lpText: PChar); stdcall;
  function ZEE_CopyPChar (pSource, pDest: PChar; nDestLen: Integer): Integer; stdcall;


  // +++++++++++++++++++++
  //  File-Handling Stuff
  // +++++++++++++++++++++

  function ZEF_FileExists (FileName: PChar; Ext: PChar): Integer; stdcall;
  procedure ZEF_DeleteFile (FileName: PChar; Ext: PChar); stdcall;
  procedure ZEF_CreateFile (FileName: PChar; Ext: PChar); stdcall;

  function ZEF_OpenFile (FileName, Ext: PChar): Integer; stdcall;
  procedure ZEF_CloseFile (hFile: Integer); stdcall;
  procedure ZEF_WriteToFileI (hFile, Data: Integer); stdcall;
  function ZEF_ReadFromFileI (hFile: Integer): Integer; stdcall;


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
  procedure ZEUI_ToggleParentFontUse (ControlRef: tCONTROL; ibActive: tINTBOOL); stdcall;

  procedure ZEUI_RunDialog (ControlRef: tCONTROL); stdcall;
  procedure ZEUI_ShowInputBox (lpszPrompt: PChar; iCommand: integer; ANoCancel: tINTBOOL); stdcall;
  procedure ZEUI_ShowMsgBox (lpszMessage: PChar; SendCommand: Integer); stdcall;
  procedure ZEUI_ShowMsgBoxEx (lpszMessage: PChar; Left, Top, Right, Bottom, SendCommand: integer); stdcall;
  procedure ZEUI_ShowTextDialog (iWidth, iHeight: Integer;
    lpszFileName, lpszFontName: PChar); stdcall;
  procedure ZEUI_ShowPromptDialog (iWidth, iHeight: Integer;
    lpszPrompt: PChar; iCommandToGenerate: Integer); stdcall;


  procedure ZEUI_Hide (ControlRef: tCONTROL); stdcall;
  procedure ZEUI_Show (ControlRef: tCONTROL); stdcall;
  procedure ZEUI_Enable (ControlRef: tCONTROL; ibActive: tINTBOOL); stdcall;

  function ZEUI_GetXPos (ControlRef: tCONTROL): Integer; stdcall;
  function ZEUI_GetYPos (ControlRef: tCONTROL): Integer; stdcall;
  function ZEUI_GetWidth (ControlRef: tCONTROL): Integer; stdcall;
  function ZEUI_GetHeight (ControlRef: tCONTROL): Integer; stdcall;

  procedure ZEUI_MoveTo (ControlRef: tCONTROL; NewX, NewY: Integer); stdcall;
  procedure ZEUI_MoveRel (ControlRef: tCONTROL; DeltaX, DeltaY: Integer); stdcall;
  procedure ZEUI_Resize (ControlREf: tCONTROL; NewWidth, NewHeight: Integer); stdcall;

  procedure ZEUI_Delete (ControlRef: tCONTROL); stdcall;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //  Game Stuff
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //  ENTITIES API
  // ----------------------------------------------------------

  function ZEEN_NameToHandle (lpszName: PChar): Integer; stdcall;
  procedure ZEEN_Delete (hEntity: Integer); stdcall;
  procedure ZEEN_Unplace (hEntity: Integer); stdcall;

  function ZEEN_CompareBaseName (hEntity: Integer; lpszWithName: PChar): Integer; stdcall;
  function ZEEN_CompareName (hEntity: Integer; lpszWithName: PChar): Integer; stdcall;
  function ZEEN_PrefixInName (hEntity: Integer; lpszPrefix: PChar): Integer; stdcall;
  function ZEEN_GetWidth (hEntity: Integer): Integer; stdcall;
  function ZEEN_GetLength (hEntity: Integer): Integer; stdcall;
  function ZEEN_IsOrientable (hEntity: Integer): tINTBOOL; stdcall;
  function ZEEN_CanMove (hEntity: Integer): tINTBOOL; stdcall;
  function ZEEN_MovementRate (hEntity: Integer): Integer; stdcall;
  function ZEEN_Updateable (hEntity: Integer): tINTBOOL; stdcall;

  function ZEEN_GetXPos (hEntity: Integer): Integer; stdcall;
  function ZEEN_GetYPos (hEntity: Integer): Integer; stdcall;

  function ZEEN_OnMap (hEntity: Integer): tINTBOOL; stdcall;
  function ZEEN_OnActiveArea (hEntity: Integer): tINTBOOL; stdcall;

  function ZEEN_Orientation (hEntity: Integer): TZbDirection; stdcall;
  procedure ZEEN_SetStateInfo (hEntity: Integer; lpszStateInfo: PChar); stdcall;

  procedure ZEEN_SetHandler (hEntity: Integer; Handler: tCALLBACK); stdcall;
  procedure ZEEN_ClearHandler (hEntity: Integer); stdcall;
  function ZEEN_GetHandlerData (hEntity: Integer): Integer; stdcall;
  procedure ZEEN_SetHandlerData (hEntity: Integer; AData: Integer); stdcall;

  procedure ZEEN_BeginPerform (hEntity: Integer; APerformState: PChar;
    ibImmediate: Integer); stdcall;
  procedure ZEEN_ClearActions (hEntity: Integer); stdcall;
  procedure ZEEN_MoveTo (hEntity: Integer; X, Y, Z: Integer); stdcall;

  function ZEEN_CanSee (hEntity: Integer; Target: PChar): tINTBOOL; stdcall;
  function ZEEN_CanSee2 (hEntity, Target: Integer): tINTBOOL; stdcall;
  function ZEEN_HowFarFrom (hEntity: Integer; Target: PChar): Integer; stdcall;
  function ZEEN_HowFarFrom2 (hEntity, Target: Integer): Integer; stdcall;
  function ZEEN_IsNeighbor (hEntity: Integer; Target: PChar): tINTBOOL; stdcall;
  function ZEEN_IsNeighbor2 (hEntity, Target: Integer): tINTBOOL; stdcall;

  procedure ZEEN_Face (hEntity: Integer; Target: PChar); stdcall;
  procedure ZEEN_Face2 (hEntity, Target: Integer); stdcall;
  procedure ZEEN_Approach (hEntity: Integer; Target: PChar); stdcall;
  procedure ZEEN_Approach2 (hEntity, Target: Integer); stdcall;

  procedure ZEEN_FaceTo (hEntity: Integer; Direction: TZbDirection); stdcall;
  function ZEEN_CanStepTo (hEntity: Integer; Direction: TZbDirection): tINTBOOL; stdcall;
  procedure ZEEN_StepTo (hEntity: Integer; Direction: TZbDirection); stdcall;
  procedure ZEEN_SetCaption (hEntity: Integer; ACaption: PChar); stdcall;

  function ZEEN_GetNeighbor (hEntity: Integer; Direction: TZbDirection): Integer; stdcall;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //  WORLD API
  // ----------------------------------------------------------

type
  TZEEnumCallbackProc = procedure (hEntity: Integer); stdcall;

  procedure ZEGE_LoadWorld (lpszWorldFile: PChar); stdcall;
  procedure ZEGE_SwitchToArea (lpszAreaName: PChar); stdcall;

  procedure ZEGE_CreatePC (lpszMasterName, lpszWorkingName: PChar;
    lpfnCallback: tCALLBACK); stdcall;
  procedure ZEGE_ReplacePC (lpszMasterName, lpszWorkingName: PChar;
    lpfnCallback: tCALLBACK); stdcall;
  procedure ZEGE_ClearPC; stdcall;

  function ZEGE_GetPC : Integer; stdcall;
  procedure ZEGE_CenterPC; stdcall;
  procedure ZEGE_CenterAt (X, Y, Z: Integer); stdcall;

  procedure ZEGE_LockPortals; stdcall;
  procedure ZEGE_UnlockPortals; stdcall;

  procedure ZEGE_DropPC; stdcall;
  procedure ZEGE_DropPCEx (lpszAreaName: PChar; X, Y, Z: integer); stdcall;
  procedure ZEGE_UnDropPC; stdcall;

  function ZEGE_GetEntity (lpszEntityName: PChar): Integer; stdcall;
  procedure ZEGE_DeleteEntity (hEntity: Integer); stdcall;
  procedure ZEGE_DeleteEntity2 (lpszEntityName: PChar); stdcall;
  procedure ZEGE_EnumEntities (EnumCallback: tCALLBACK); stdcall;

  procedure ZEGE_QueueForDeletion (hEntity: Integer); stdcall;
  procedure ZEGE_QueueForDeletion2 (lpszEntityName: PChar); stdcall;


implementation

uses
  SysUtils,
  Classes,
  StrUtils,
  Math,
  //
  ZblAppFrame,
  ZblIEvents,
  //
  ZbCallbacks,
  ZbDebug,
  ZbScriptable,
  //
  ZEDXFramework,
  ZEWSDefines,
  ZEWSBase,
  ZEWSDialogs,
  //
  ZZEGameWindow,
  ZZECore;


///////////////////////------------------------------------------------------
procedure ZETA_Run (EscapeExits: Integer; hInstance: HINST; AWinTitle, AProgConfig: PChar;
  lpfnCreateUICallback, lpfnHandleEventCallback: tCALLBACK); stdcall;
begin
  TraceLn ('ZETA_Run() - ENTER');
  g_ExitOnEscape := (EscapeExits <> 0);

  TraceLn ('--- Setting up');
  SetupEngineCreator (AProgConfig,
    TZbCallbackFunction (lpfnCreateUICallback),
    TZbCallbackFunction (lpfnHandleEventCallback));

  TraceLn ('--- Initializing');
  ZbLib_AppFrame_Init (hInstance, FALSE, NIL, AWinTitle);
  AttachToAppFrame;

  TraceLn ('--- Ready to run');
  ZbLib_AppFrame_Run;
  ZbLib_AppFrame_Done;
  TraceLn ('ZETA_Run() - EXIT');
end;

///////////////////////------------------------------------------------------
function ZEWW_Prepare (lpszConfigFile: PChar; lpfnCreateUICallback: tCALLBACK;
  lpfnHandleEventCallback: tCALLBACK): integer; stdcall;
begin
  {
  Result := Integer (WrapperCreate (String (lpszConfigFile),
    TZbCallbackFunction (lpfnCreateUICallback),
    TZbCallbackFunction (lpfnHandleEventCallback)));}
  SetupEngineCreator (lpszConfigFile,
    TZbCallbackFunction (lpfnCreateUICallback),
    TZbCallbackFunction (lpfnHandleEventCallback));
  Result := 1975;
end;

///////////////////////------------------------------------------------------
function ZEWW_CreateWindow (ClassRef: integer; hInstance: HINST;
  WindowClassName, WindowTitle: PChar; WindowProc: tCALLBACK;
  WindowFlags: DWORD; iWidth, iHeight: integer): tINTBOOL; stdcall;
{var
  Wrapper: TZEWindowsWrapper;}
begin
  ZbLib_AppFrame_Init (hInstance);//, FALSE, WindowClassName, WindowTitle, iWidth, iHeight);
  Result := IBOOL_TRUE;
  {
  Result := IBOOL_FALSE;
  Wrapper := TZEWindowsWrapper (ClassRef);
  if (Wrapper = NIL) then Exit;
  //
  Result := IBOOL [Wrapper.CreateWindow (hInstance, WindowClassName, WindowTitle,
    TWindowsCallback (WindowProc), WindowFlags, iWidth, iHeight)];}
end;

///////////////////////------------------------------------------------------
procedure ZEWW_Execute (ClassRef: integer); stdcall;
begin
  AttachToAppFrame;
  ZbLib_AppFrame_Run;
  {
  if (ClassRef <> 0) then try
    TZEWindowsWrapper (ClassRef).Execute;
  except end;}
end;

///////////////////////------------------------------------------------------
procedure ZEWW_Shutdown (ClassRef: integer); stdcall;
begin
  ZbLib_AppFrame_Done;
  {
  if (ClassRef <> 0) then try
    TZEWindowsWrapper (ClassRef).Free;
  except end;}
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
procedure ZEE_TerminateEngine; stdcall;
begin
  g_EventManager.Commands.Insert (cmGlobalExitFinal, 0, 0);
  //  if (CoreEngine <> NIL) then CoreEngine.Terminate;
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
procedure ZEE_PushEvent (EventCommand: Integer); stdcall;
begin
  g_EventManager.Commands.Insert (EventCommand, 0, 0);
end;

///////////////////////------------------------------------------------------
procedure ZEE_AddCallback (AName: PChar; ACallback: tCALLBACK); stdcall;
begin
  Callbacks.Add (AName, TZbCallbackFunction (ACallback));
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
  if (CoreEngine <> NIL) then CoreEngine.SetBackgroundMusic (lpszMusicName);
end;

///////////////////////------------------------------------------------------
procedure ZEE_ClearMusic; stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.ClearBackgroundMusic;
end;

///////////////////////------------------------------------------------------
procedure ZEE_PlaySound (lpszSoundName: PChar); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.PlaySound (lpszSoundName);
end;

///////////////////////------------------------------------------------------
procedure ZEE_PlayCutScene (lpszCutSceneFile: PChar); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.PlayCutScene (lpszCutSceneFile);
end;

///////////////////////------------------------------------------------------
procedure ZEE_TogglePause (ibActive: tINTBOOL); stdcall;
begin
  GameWorld.Paused := (ibActive <> IBOOL_FALSE);
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
procedure ZEE_StartTimer (ATimerValue: Cardinal); stdcall;
begin
  CoreEngine.StartCountdownTimer (ATimerValue);
end;

///////////////////////------------------------------------------------------
procedure ZEE_StartTimerEx (AMinutes, ASeconds: Cardinal); stdcall;
begin
  CoreEngine.StartCountdownTimer (AMinutes, ASeconds);
end;

///////////////////////------------------------------------------------------
procedure ZEE_PauseTimer; stdcall;
begin
  TraceLn ('ZEE_PauseTimer ()');
  CoreEngine.PauseTimer;
end;

///////////////////////------------------------------------------------------
procedure ZEE_UnPauseTimer; stdcall;
begin
  TraceLn ('ZEE_UnPauseTimer ()');
  CoreEngine.UnPauseTimer;
end;

///////////////////////------------------------------------------------------
procedure ZEE_StopTimer; stdcall;
begin
  CoreEngine.StopTimer;
end;

///////////////////////------------------------------------------------------
function ZEE_IsGlobalExitOnEscapeSet: tINTBOOL; stdcall;
begin
  Result := IBOOL [g_ExitOnEscape];
end;

///////////////////////------------------------------------------------------
procedure ZEE_ToggleGlobalExitOnEscape (ibActive: tINTBOOL); stdcall;
begin
  g_ExitOnEscape := (ibActive <> IBOOL_FALSE);
end;

///////////////////////------------------------------------------------------
function ZEE_CmpStr (Ref, pCmp: PChar): Integer; stdcall;
begin
  Result := Ord (StrComp (Ref, pCmp) = 0);
end;

///////////////////////------------------------------------------------------
procedure ZEE_AddKeyHook (KeyCode, UserHandler: Integer); stdcall;
begin
  g_EventManager.Keyboard.AddKeyHook (TZbKeyCallback(UserHandler), KeyCode, 0);
end;

///////////////////////------------------------------------------------------
procedure ZEE_ClearKeyHook (KeyCode: Integer); stdcall;
begin
  g_EventManager.Keyboard.AddKeyHook (NIL, KeyCode, 0);
end;

///////////////////////------------------------------------------------------
function ZEE_GetElapsedTicks: Integer; stdcall;
begin
  Result := Integer (g_ElapsedTicks);
end;

///////////////////////------------------------------------------------------
function ZEE_GetMouseX: Integer; stdcall;
begin
  Result := g_EventManager.Mouse.GetPositionX;
end;

///////////////////////------------------------------------------------------
function ZEE_GetMouseY: Integer; stdcall;
begin
  Result := g_EventManager.Mouse.GetPositionY;
end;

///////////////////////------------------------------------------------------
procedure ZEE_DebugText (lpText: PChar); stdcall;
begin
  TraceLn ('ZEE {%s}', [String(lpText)]);
end;

///////////////////////------------------------------------------------------
function ZEE_CopyPChar (pSource, pDest: PChar; nDestLen: Integer): Integer; stdcall;
begin
  Result := StrLen (pSource);
  StrLCopy (pDest, pSource, nDestLen);
end;

///////////////////////------------------------------------------------------
function ZEF_FileExists (FileName: PChar; Ext: PChar): Integer; stdcall;
var
  cFileName: String;
begin
  cFileName := String (FileName) + String (Ext);
  Result := Ord (FileExists (cFileName));
end;

///////////////////////------------------------------------------------------
procedure ZEF_DeleteFile (FileName: PChar; Ext: PChar); stdcall;
var
  cFileName: String;
begin
  try
    cFileName := String (FileName) + String (Ext);
    SysUtils.DeleteFile (cFileName);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEF_CreateFile (FileName: PChar; Ext: PChar); stdcall;
var
  cFileName: String;
  F: File;
begin
  cFileName := String (FileName) + String (Ext);
  AssignFile (F, cFileName);
  Rewrite (F);
  CloseFile (F);
end;

///////////////////////------------------------------------------------------
function ZEF_OpenFile (FileName, Ext: PChar): Integer; stdcall;
var
  cName: String;
begin
  cName := String (FileName);
  if (Ext <> NIL) AND (StrLen (Ext) > 0) then cName := cName + String (Ext);
  Result := CreateFile (PChar (cName), GENERIC_READ OR GENERIC_WRITE, 0,
    NIL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
end;

///////////////////////------------------------------------------------------
procedure ZEF_CloseFile (hFile: Integer); stdcall;
begin
  try
    CloseHandle (hFile);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEF_WriteToFileI (hFile, Data: Integer); stdcall;
var
  dData, dSizeToWrite, dSizeWritten: Cardinal;
begin
  dData := Cardinal (Data);
  dSizeToWrite := SizeOf (dData);
  WriteFile (hFile, dData, dSizeToWrite, dSizeWritten, NIL);
end;

///////////////////////------------------------------------------------------
function ZEF_ReadFromFileI (hFile: Integer): Integer; stdcall;
var
  dData, dSizeRead: Cardinal;
begin
  try
    ReadFile (hFile, dData, SizeOf (dData), dSizeRead, NIL);
    Result := Integer (dData);
  except
    Result := 0;
  end;
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
      CoreEngine.WinSysRoot.UseDesktop (ctlDesk);
      Result := tCONTROL (ctlDesk);
    end;
  end;
end;

///////////////////////------------------------------------------------------
function ZEUI_GetDesktop (lpszRefName: PChar): tCONTROL; stdcall;
begin
  Result := tNULL_CONTROL;
  if (CoreEngine = NIL) then Exit;
  //
  if (lpszRefName = NIL) OR (StrLen (lpszRefName) = 0) then
    Result := tCONTROL (CoreEngine.WinSysRoot.ActiveDesktop)
    else Result := tCONTROL (CoreEngine.WinSysRoot [string (lpszRefName)]);
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
procedure ZEUI_ToggleParentFontUse (ControlRef: tCONTROL; ibActive: tINTBOOL); stdcall;
begin
  try
    TZEControl (ControlRef).SetStyle (syUseParentFont, ibActive <> IBOOL_FALSE);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_RunDialog (ControlRef: tCONTROL); stdcall;
begin
  try
    CoreEngine.RunDialog (TZEControl (ControlRef));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_ShowInputBox (lpszPrompt: PChar; iCommand: integer; ANoCancel: tINTBOOL); stdcall;
begin
  try
    CoreEngine.ShowInputBox (String (lpszPrompt), iCommand, ANoCancel <> IBOOL_FALSE);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_ShowMsgBox (lpszMessage: PChar; SendCommand: Integer); stdcall;
var
  cData: String;
begin
  cData := String (lpszMessage);
  CoreEngine.ShowMsgBox (cData, SendCommand);
end;

///////////////////////------------------------------------------------------
procedure ZEUI_ShowMsgBoxEx (lpszMessage: PChar; Left, Top, Right, Bottom, SendCommand: integer); stdcall;
var
  cData: String;
begin
  cData := String (lpszMessage);
  CoreEngine.ShowMsgBox (cData, Rect (Left, Top, Right, Bottom), SendCommand);
end;

///////////////////////------------------------------------------------------
procedure ZEUI_ShowTextDialog (iWidth, iHeight: Integer; lpszFileName, lpszFontName: PChar); stdcall;
var
  dlg: TZEControl;
begin
  dlg := CreateControl (CC_TEXT_DIALOG, Rect (0, 0, iWidth, iHeight));
  if (dlg = NIL) then Exit;
  //
  if (lpszFontName <> NIL) then
    dlg.SetPropertyValue (PROP_NAME_FONT_NAME, String (lpszFontName));
  if (lpszFileName <> NIL) then begin
    dlg.SetPropertyValue (PROP_NAME_FILE_TO_LOAD, String (lpszFileName));
  end;
  //
  CoreEngine.RunDialog (dlg);
end;

///////////////////////------------------------------------------------------
procedure ZEUI_ShowPromptDialog (iWidth, iHeight: Integer;
  lpszPrompt: PChar; iCommandToGenerate: Integer); stdcall;
begin
  CoreEngine.ShowPromptDialog (iWidth, iHeight, String (lpszPrompt), iCommandToGenerate);
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
procedure ZEUI_Enable (ControlRef: tCONTROL; ibActive: tINTBOOL); stdcall;
begin
  try
    TZEControl (ControlRef).SetState (stDisabled, ibActive = 0);
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEUI_GetXPos (ControlRef: tCONTROL): Integer; stdcall;
begin
  try
    Result := TZEControl (ControlRef).Left;
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEUI_GetYPos (ControlRef: tCONTROL): Integer; stdcall;
begin
  try
    Result := TZEControl (ControlRef).Top;
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEUI_GetWidth (ControlRef: tCONTROL): Integer; stdcall;
begin
  try
    Result := TZEControl (ControlRef).Width;
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEUI_GetHeight (ControlRef: tCONTROL): Integer; stdcall;
begin
  try
    Result := TZEControl (ControlRef).Height;
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_MoveTo (ControlRef: tCONTROL; NewX, NewY: Integer); stdcall;
var
  rBounds: TRect;
  Delta: TPoint;
begin
  try
    rBounds := TZEControl (ControlRef).Bounds;
    Delta := SubPoint (rBounds.BottomRight, rBounds.TopLeft);
    rBounds.TopLeft := Point (NewX, NewY);
    rBounds.BottomRight := AddPoint (rBounds.TopLeft, Delta);
    TZEControl (ControlRef).Bounds := rBounds;
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_MoveRel (ControlRef: tCONTROL; DeltaX, DeltaY: Integer); stdcall;
var
  rBounds: TRect;
  Delta: TPoint;
begin
  try
    rBounds := TZEControl (ControlRef).Bounds;
    Delta := Point (DeltaX, DeltaY);
    rBounds.TopLeft := AddPoint (rBounds.TopLeft, Delta);
    rBounds.BottomRight := AddPoint (rBounds.BottomRight, Delta);
    TZEControl (ControlRef).Bounds := rBounds;
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_Resize (ControlREf: tCONTROL; NewWidth, NewHeight: Integer); stdcall;
var
  rBounds: TRect;
  Delta: TPoint;
begin
  try
    rBounds := TZEControl (ControlRef).Bounds;
    rBounds.BottomRight := AddPoint (rBounds.TopLeft, Point (NewWidth, NewHeight));
    TZEControl (ControlRef).Bounds := rBounds;
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEUI_Delete (ControlRef: tCONTROL); stdcall;
begin
  try
    TZEControl (ControlRef).Free;
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_NameToHandle (lpszName: PChar): Integer; stdcall;
begin
  try
    Result := Integer (GameWorld.FindEntity (String (lpszName)));
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_Delete (hEntity: Integer); stdcall;
begin
  try
    GameWorld.DeleteEntity (TZEEntity (hEntity));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_Unplace (hEntity: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).Unplace;
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_CompareBaseName (hEntity: Integer; lpszWithName: PChar): Integer; stdcall;
var
  EName: PChar;
begin
  try
    EName := PChar (TZEEntity (hEntity).MasterName);
    Result := StrComp (EName, lpszWithName);
  except
    Result := -1;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_CompareName (hEntity: Integer; lpszWithName: PChar): Integer; stdcall;
var
  EName: PChar;
begin
  try
    EName := PChar (TZEEntity (hEntity).Name);
    Result := IfThen (StrComp (EName, lpszWithName) = 1, 1, 0);
  except
    Result := -1;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_PrefixInName (hEntity: Integer; lpszPrefix: PChar): Integer; stdcall;
var
  //cPrefix, cPartialName: String;
  //iPrefixLen, iNameLen: Integer;
  theEntity: TZEEntity;
begin
  Result := 0;
  try
    theEntity := TZEEntity (hEntity);
    Result := Integer (theEntity.PrefixInName (lpszPrefix));
    {
    cPrefix := String (lpszPrefix);
    if (hEntity <> 0) AND (cPrefix <> '') then begin
      iPrefixLen := Length (cPrefix);
      iNameLen := Length (TZEEntity (hEntity).Name);
      //
      if (iPrefixLen <= iNameLen) then begin
        cPartialName := LeftStr (TZEEntity (hEntity).Name, iPrefixLen);
        if (StrComp (PChar (cPartialName), lpszPrefix) = 0) then Result := 1;
      end;
      //
    end;}
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_GetWidth (hEntity: Integer): Integer; stdcall;
begin
  try
    Result := TZEEntity (hEntity).Width;
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_GetLength (hEntity: Integer): Integer; stdcall;
begin
  try
    Result := TZEEntity (hEntity).Length;
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_IsOrientable (hEntity: Integer): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).Orientable];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_CanMove (hEntity: Integer): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).CanMove];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_MovementRate (hEntity: Integer): Integer; stdcall;
begin
  try
    Result := TZEEntity (hEntity).MovementRate;
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_Updateable (hEntity: Integer): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).RequiresUpdate];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_GetXPos (hEntity: Integer): Integer; stdcall;
begin
  try
    if (TZEEntity (hEntity).OnMap) then
      Result := TZEEntity (hEntity).AnchorTile.GridX
      else Result := -1;
  except
    Result := -1;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_GetYPos (hEntity: Integer): Integer; stdcall;
begin
  try
    if (TZEEntity (hEntity).OnMap) then
      Result := TZEEntity (hEntity).AnchorTile.GridY
      else Result := -1;
  except
    Result := -1;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_OnMap (hEntity: Integer): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).OnMap];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_OnActiveArea (hEntity: Integer): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).OnActiveArea];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_Orientation (hEntity: Integer): TZbDirection; stdcall;
begin
  try
    Result := TZEEntity (hEntity).Orientation;
  except
    Result := tdUnknown;
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_SetStateInfo (hEntity: Integer; lpszStateInfo: PChar); stdcall;
begin
  try
    TZEEntity (hEntity).ExtraStateInfo := String (lpszStateInfo);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_SetHandler (hEntity: Integer; Handler: tCALLBACK); stdcall;
begin
  try
    TZEEntity (hEntity).Handler := NIL;
    TZEEntity (hEntity).RemoteHandler := TZERemoteEntityCallback (Handler);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_ClearHandler (hEntity: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).Handler := NIL;
    TZEEntity (hEntity).RemoteHandler := NIL;
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_GetHandlerData (hEntity: Integer): Integer; stdcall;
begin
  try
    Result := Integer (TZEEntity (hEntity).HandlerData);
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_SetHandlerData (hEntity: Integer; AData: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).HandlerData := Pointer (AData);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_BeginPerform (hEntity: Integer; APerformState: PChar;
  ibImmediate: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).BeginPerform (String (APerformState), ibImmediate = 1);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_ClearActions (hEntity: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).AQ_Clear;
    TZEEntity (hEntity).ClearAction;
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_MoveTo (hEntity: Integer; X, Y, Z: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).MoveTo (X, Y, Z);
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_CanSee (hEntity: Integer; Target: PChar): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).CanSee (GameWorld.FindEntity (String (Target)))];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_CanSee2 (hEntity, Target: Integer): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).CanSee (TZEEntity (Target))];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_HowFarFrom (hEntity: Integer; Target: PChar): Integer; stdcall;
begin
  try
    Result := TZEEntity (hEntity).HowFarFrom (GameWorld.FindEntity (String (Target)));
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_HowFarFrom2 (hEntity, Target: Integer): Integer; stdcall;
begin
  try
    Result := TZEEntity (hEntity).HowFarFrom (TZEEntity (Target));
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_IsNeighbor (hEntity: Integer; Target: PChar): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).IsNeighbor (GameWorld.FindEntity (String (Target)))];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_IsNeighbor2 (hEntity, Target: Integer): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).IsNeighbor (TZEEntity (Target))];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_Face (hEntity: Integer; Target: PChar); stdcall;
begin
  try
    TZEEntity (hEntity).Face (GameWorld.FindEntity (String (Target)));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_Face2 (hEntity, Target: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).Face (TZEEntity (Target));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_Approach (hEntity: Integer; Target: PChar); stdcall;
begin
  try
    TZEEntity (hEntity).Approach (GameWorld.FindEntity (String (Target)));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_Approach2 (hEntity, Target: Integer); stdcall;
begin
  try
    TZEEntity (hEntity).Approach (TZEEntity (Target));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_FaceTo (hEntity: Integer; Direction: TZbDirection); stdcall;
begin
  try
    TZEEntity (hEntity).Face (Direction);
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_CanStepTo (hEntity: Integer; Direction: TZbDirection): tINTBOOL; stdcall;
begin
  try
    Result := IBOOL [TZEEntity (hEntity).CanStepTo (Direction)];
  except
    Result := IBOOL_FALSE;
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_StepTo (hEntity: Integer; Direction: TZbDirection); stdcall;
begin
  try
    while (Direction = tdUnknown) do Direction := GetRandomDirection;
    TZEEntity (hEntity).StepTo (Direction);
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEEN_SetCaption (hEntity: Integer; ACaption: PChar); stdcall;
begin
  try
    TZEEntity (hEntity).CaptionText := ACaption;
  except
  end;
end;

///////////////////////------------------------------------------------------
function ZEEN_GetNeighbor (hEntity: Integer; Direction: TZbDirection): Integer; stdcall;
begin
  try
    Result := Integer (TZEEntity (hEntity).GetNeighbor (Direction));
  except
    Result := 0;
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEGE_LoadWorld (lpszWorldFile: PChar); stdcall;
begin
  GameWorld.LoadFromFile (string (lpszWorldFile));
end;

///////////////////////------------------------------------------------------
procedure ZEGE_SwitchToArea (lpszAreaName: PChar); stdcall;
begin
  GameWorld.SwitchToArea (string (lpszAreaName));
end;

///////////////////////------------------------------------------------------
procedure ZEGE_CreatePC (lpszMasterName, lpszWorkingName: PChar; lpfnCallback: tCALLBACK); stdcall;
begin
  GameWorld.CreatePC (
    String (lpszMasterName), String (lpszWorkingName),
    TZERemoteEntityCallback (lpfnCallback));
end;

///////////////////////------------------------------------------------------
procedure ZEGE_ReplacePC (lpszMasterName, lpszWorkingName: PChar; lpfnCallback: tCALLBACK); stdcall;
begin
  GameWorld.ReplacePC (
    String (lpszMasterName), String (lpszWorkingName),
    TZERemoteEntityCallback (lpfnCallback));
end;

///////////////////////------------------------------------------------------
procedure ZEGE_ClearPC; stdcall;
begin
  GameWorld.ClearPC;
end;

///////////////////////------------------------------------------------------
function ZEGE_GetPC : Integer; stdcall;
begin
  Result := Integer (GameWorld.PC);
end;

///////////////////////------------------------------------------------------
procedure ZEGE_CenterPC; stdcall;
begin
  with GameWorld do
    if (PC <> NIL) AND (PC.OnMap) then
      ActiveArea.Map.Center(PC.AnchorTile)
  //
end;

///////////////////////------------------------------------------------------
procedure ZEGE_CenterAt (X, Y, Z: Integer); stdcall;
begin
  GameWorld.ActiveArea.Map.Center (Z, Y, X);
end;

///////////////////////------------------------------------------------------
procedure ZEGE_LockPortals; stdcall;
begin
  if (GameWorld.PC <> NIL) then GameWorld.PC.IgnorePortals := TRUE;
end;

///////////////////////------------------------------------------------------
procedure ZEGE_UnlockPortals; stdcall;
begin
  if (GameWorld.PC <> NIL) then GameWorld.PC.IgnorePortals := FALSE;
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
function ZEGE_GetEntity (lpszEntityName: PChar): Integer; stdcall;
begin
  Result := Integer (GameWorld.FindEntity (String (lpszEntityName))); 
end;

///////////////////////------------------------------------------------------
procedure ZEGE_DeleteEntity (hEntity: Integer); stdcall;
begin
end;

///////////////////////------------------------------------------------------
procedure ZEGE_DeleteEntity2 (lpszEntityName: PChar); stdcall;
begin
end;

///////////////////////------------------------------------------------------
procedure ZEGE_EnumEntities (EnumCallback: tCALLBACK); stdcall;
var
  theEntity: TZEEntity;
  theEList: TZEEntityList;
  theArea: TZEGameArea;
  iAreas, iEntities: integer;
  fnCallback: TZEEnumCallbackProc;
begin
  fnCallback := TZEEnumCallbackProc (EnumCallback);
  if (NOT Assigned (fnCallback)) then Exit;
  //
  try
    for iAreas := 0 to Pred (GameWorld.AreaCount) do begin
      theArea := GameWorld.GetAreaByIndex (iAreas);
      if (theArea = NIL) then continue;
      //
      theEList := theArea.Entities;
      if (theEList = NIL) then continue;
      //
      for iEntities := 0 to Pred (theEList.Count) do begin
        theEntity := theEList [iEntities];
        if (theEntity = NIL) OR (NOT theEntity.OnMap) OR
          (NOT theEntity.RequiresUpdate) then continue;
        //
        fnCallback (Integer (theEntity));
      end;
    end;
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEGE_QueueForDeletion (hEntity: Integer); stdcall;
begin
  try
    GameWorld.QueueForDeletion (TZEEntity (hEntity));
  except
  end;
end;

///////////////////////------------------------------------------------------
procedure ZEGE_QueueForDeletion2 (lpszEntityName: PChar); stdcall;
begin
  GameWorld.QueueForDeletion (String (lpszEntityName));
end;

{///////////////////////------------------------------------------------------
procedure ZESS_ClearCallbacks; stdcall;
begin
  if (ScriptMaster <> NIL) then ScriptMaster.Clear;
end;

///////////////////////------------------------------------------------------
procedure ZESS_AddCallback (lpszRefName: PChar; lpfnCallback: tCALLBACK); stdcall;
begin
  if (ScriptMaster <> NIL) then
    ScriptMaster.AddHandler (lpszRefName, TZbScriptCallback (lpfnCallback));
end;}


end.

