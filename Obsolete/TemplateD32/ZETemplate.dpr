{$WARNINGS OFF}
{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZETemplate.PAS
              Template application code using the Zeta Engine
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Apps/TemplateD32/ZETemplate.dpr,v 1.1.1.1 2002/09/12 12:46:14 Vij Exp $
  $Log: ZETemplate.dpr,v $
  Revision 1.1.1.1  2002/09/12 12:46:14  Vij
  Starting Version Control


 ============================================================================}

program ZETemplate;

uses
  Windows,
  Messages,
  SysUtils,
  ZbScriptMaster,
  ZEDXFramework,
  ZEWSDefines,
  ZZECore,
  ZETemplateU in 'ZETemplateU.pas';

const
  (* FOLLOWING constants MUST be unique for each application.  Modify
     these before anything else. *)
  WINDOW_CLASS_NAME         = 'ZetaTemplate';
  WINDOW_TITLE              = 'Zeta Engine Win32 Template (Delphi)';
  PROGRAM_CONFIGURATION     = 'Template.zsf';


var
  (* Win32 system variables.  DO NOT MODIFY! *)
  hMainWindow: HWND;
  hAppInstance: HINST;
  msgWin32: TMsg;


////////////////////////////////////////////////////////////////////////////////
// Activate().
//  called when the window gets activated initially.  If the Zeta
//  engine had not been constructed, this routine will construct it.
procedure OnActivate (hWindow: HWND);
begin
  if (CoreEngine = NIL) then begin
    ScriptMaster.AddHandler (SCRIPT_GAME_GUI, CreateInitialGUI);
    ScriptMaster.AddHandler (SCRIPT_USER_EVENTS, HandleUserEvents);
    //
    CoreEngine := TZEGameCore.Create (PROGRAM_CONFIGURATION);
    CoreEngine.Initialize (hWindow, hAppInstance);
  end;
  //
  CoreEngine.Activate;
end;

////////////////////////////////////////////////////////////////////////////////
// Deactivate().
//   when the application loses focus, this will be called.  It
//   simply passes the notification to the Engine, if present.
procedure OnDeactivate (hWindow: HWND);
begin
  if (CoreEngine <> NIL) then CoreEngine.Deactivate;
end;

////////////////////////////////////////////////////////////////////////////////
// Destroy().
//   user has exited and we need to perform cleanup.  Destroys engine.
procedure OnMainDestroy;
begin
  // shutdown the engine
  FreeAndNIL (CoreEngine);
end;

////////////////////////////////////////////////////////////////////////////////
// Idle().
//   everytime there is no message in the windows message pump, this runs.
procedure OnIdle;
begin
  if (CoreEngine = NIL) then Exit;
  if (CoreEngine.Refresh) then PostQuitMessage (0);
end;


////////////////////////////////////////////////////////////////////////////////
// WinProc().
//   callback of our window.  Windows (the operating system) will call
//   this routine everytime something important happens.
function WinProc (hWindow: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  rBounds: TRect;
begin 
  case msg of
    // On window creation
    WM_CREATE: begin
      if (GetWindowRect (hWindow, rBounds)) then 
        SetWindowPos (hWindow, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE);
    end;
    // On window destruction
    WM_DESTROY: begin
      OnMainDestroy;
      PostQuitMessage(0);
      Result := 0;
      exit;
    end;
    // Catch Activate/Deactivate
    WM_ACTIVATE: begin
      if (wParam in [WA_ACTIVE, WA_CLICKACTIVE]) then
        OnActivate (hWindow)
        else OnDeactivate (hWindow);
    end;
    // On cursor set: turn off cursor if full-screen mode
    WM_SETCURSOR: begin
      if (CoreEngine <> NIL) AND (CoreEngine.Exclusive) then SetCursor (0);
    end;
  end;
  //
  Result := DefWindowProc(hWindow, msg, wParam, lParam);
end;

////////////////////////////////////////////////////////////////////////////////
// InitWindow().
//   creates our window.
function InitWindow (windowClassName, windowTitle: PChar; iWidth, iHeight: Integer): Boolean; stdcall;
var
  WndClass: TWndClass;
begin
  //Initialize window parameters
  hAppInstance := GetModuleHandle (NIL);
  with WndClass do begin
    style := CS_HREDRAW or CS_VREDRAW;
    lpfnWndProc := @WinProc;
    cbClsExtra := 0;
    cbWndExtra := 0;
    hInstance := hAppInstance;
    hIcon := LoadIcon (0,IDI_WINLOGO);
    hCursor := 0;//LoadCursor (0,IDC_ARROW);
    hbrBackground := GetStockObject (BLACK_BRUSH);
    lpszMenuName := NIL;
    lpszClassName := windowClassName;
  end;

  //Register window with system
  if (RegisterClass (WndClass) = 0) then begin
    MessageBox (0, 'Cannot register window class.', 'ERROR', MB_OK or MB_ICONERROR);
    Result := False;
    exit;
  end;

  //Create window
  hMainWindow := CreateWindowEx(WS_EX_APPWINDOW, windowClassName, windowTitle,
    0{WS_OVERLAPPEDWINDOW}, 0, 0, iWidth, iHeight, 0, 0, hAppInstance, nil);
  ShowWindow (hMainWindow, SW_SHOW);
  UpdateWindow (hMainWindow);
  SetFocus (hMainWindow);
  Result := True;
end;


////////////////////////////////////////////////////////////////////////////////
// WinMain().
//   entry point of our program.
function WinMain(hInstance: HINST; hPrevInstance: HINST; lpCmdLine: PChar;
  nCmdShow: integer): integer; stdcall;
begin
  GlobalExitOnEscape := TRUE;
  // create window
  if (NOT InitWindow (WINDOW_CLASS_NAME, WINDOW_TITLE, 640, 480)) then
    PostQuitMessage (0);

  // main process loop
  while (TRUE) do begin
    if (PeekMessage( msgWin32, 0, 0, 0, PM_REMOVE)) then begin
      if (msgWin32.message = WM_QUIT) then break;
      TranslateMessage (msgWin32);
      DispatchMessage (msgWin32);
    end else
      OnIdle;
  end;

  Result := msgWin32.wParam;
end;


////////////////////////////////////////////////////////////////////////////////
begin
  WinMain (hInstance, hPrevInst, CmdLine, CmdShow);
end.

