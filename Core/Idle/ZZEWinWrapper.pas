{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEWinWrapper.PAS
              Wraps the Windows(tm) initialization and message loop
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Core/ZZEWinWrapper.pas,v 1.2 2002/12/18 08:11:22 Vij Exp $
  $Log: ZZEWinWrapper.pas,v $
  Revision 1.2  2002/12/18 08:11:22  Vij
  Removed call to DetroyWindow and UnregisterClass.  Wrapped ProcessMessages
  inside try...except block.

  Revision 1.1  2002/11/02 06:35:52  Vij
  Added to version control



 ============================================================================}

unit ZZEWinWrapper;

interface

uses
  Windows,
  ZbCallbacks;
  //ZbScriptMaster;

type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TWindowsCallback = function (hWindow: HWND;
    msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWindowsWrapper = class (TObject)
  private
    FMainWindow: HWND;
    FAppInstance: HINST;
    FWinClassName: PChar;
    FWindowProc: TWindowsCallback;
    //
    FCreateUIFunc: TZbCallbackFunction;
    FHandleEventFunc: TZbCallbackFunction;
    FProgramConfig: PChar;
  protected
    function GetProgramConfig: string;
    procedure SetProgramConfig (AConfigName: string);
  public
    constructor Create;
    destructor Destroy; override;
    //
    function CreateWindow (hInstance: HINST; WindowClassName, WindowTitle: PChar;
      WindowProc: TWindowsCallback; WindowFlags: DWORD;
      iWidth, iHeight: integer; iPosX: integer = 0; iPosY: integer = 0): boolean;
    procedure DestroyWindow;
    //
    function Execute: integer;
    procedure ProcessMessage (hWindow: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM);
    procedure OnWinActivate;
    procedure OnWinDeactivate;
    procedure OnWinDestroy;
    procedure OnIdle;
    //
    property WindowProc: TWindowsCallback read FWindowProc write FWindowProc;
    property CreateUIFunc: TZbCallbackFunction read FCreateUIFunc write FCreateUIFunc;
    property HandleEventFunc: TZbCallbackFunction read FHandleEventFunc write FHandleEventFunc;
    property ProgramConfig: String read GetProgramConfig write SetProgramConfig;
  end;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function WrapperProc (hWindow: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  function WrapperCreate (cConfigFile: string; UICB, HECB: TZbCallbackFunction): TZEWindowsWrapper;


implementation


uses
  SysUtils,
  StrUtils,
  Messages,
  ZbDebug,
  ZEWSDefines,
  ZZECore;


{ TZEWindowsWrapper }

//////////////////////////////////////////////////////////////////////////
constructor TZEWindowsWrapper.Create;
begin
  inherited;
  FMainWindow := 0;
  FAppInstance := 0;
  FWinClassName := NIL;
  FWindowProc := NIL;
  //
  Callbacks.Clear;
  //ScriptMaster.Clear;
  FCreateUIFunc := NIL;
  FHandleEventFunc := NIL;
  FProgramConfig := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWindowsWrapper.Destroy;
begin
  if (FProgramConfig <> NIL) then StrDispose (FProgramConfig);
  if (FWinClassName <> NIL) then StrDispose (FWinClassName);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWindowsWrapper.GetProgramConfig: string;
begin
  Result := IfThen (FProgramConfig = NIL, '', String (FProgramConfig));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWindowsWrapper.SetProgramConfig (AConfigName: string);
begin
  if (FProgramConfig <> NIL) then StrDispose (FProgramConfig);
  if (AConfigName <> '') then
    FProgramConfig := StrNew (PChar (AConfigName))
    else FProgramConfig := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWindowsWrapper.CreateWindow (hInstance: HINST; WindowClassName, WindowTitle: PChar;
  WindowProc: TWindowsCallback; WindowFlags: DWORD; iWidth, iHeight, iPosX, iPosY: integer): boolean;
var
  WndClass: TWndClass;
begin
  Result := FALSE;
  FWinClassName := StrNew (WindowClassName);
  FAppInstance := hInstance;
  FWindowProc := WindowProc;
  //WindowFlags := WindowFlags OR (WS_EX_APPWINDOW OR WS_EX_TOPMOST);
  //
  // create a window class structure and initialize it
  with WndClass do begin
    style := CS_HREDRAW or CS_VREDRAW;
    lpfnWndProc := @WrapperProc;
    cbClsExtra := 4;
    cbWndExtra := 0;
    hInstance := FAppInstance;
    hIcon := LoadIcon (0,IDI_WINLOGO);
    hCursor := 0; //LoadCursor (0,IDC_ARROW);
    hbrBackground := GetStockObject (BLACK_BRUSH);
    lpszMenuName := NIL;
    lpszClassName := FWinClassName;
  end;
  //
  //Register window with system
  if (RegisterClass (WndClass) = 0) then begin
    MessageBox (0, 'Cannot register window class.', 'ERROR', MB_OK or MB_ICONERROR);
    Exit;
  end;
  //Create window
  FMainWindow := CreateWindowEx (WS_EX_APPWINDOW, FWinClassName, WindowTitle,
    WindowFlags, iPosX, iPosY, iWidth, iHeight, 0, 0, FAppInstance, NIL);
  //
  if (FMainWindow = 0) then begin
    MessageBox (0, 'Cannot create system window.', 'ERROR', MB_OK or MB_ICONERROR);
    Exit;
  end;
  //
  SetWindowLong (FMainWindow, GWL_USERDATA, integer (Self));
  ShowWindow (FMainWindow, SW_SHOW);
  UpdateWindow (FMainWindow);
  SetFocus (FMainWindow);
  //
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWindowsWrapper.DestroyWindow;
begin
  if (FMainWindow = 0) then Exit;
  // this is probably done automatically by windows anyway...
	//Windows.DestroyWindow (FMainWindow);
	//UnregisterClass (FWinClassName, FAppInstance);
end;

//////////////////////////////////////////////////////////////////////////
function TZEWindowsWrapper.Execute: integer;
var
  msgWin32: TMsg;
begin
  while (TRUE) do begin
    if (PeekMessage (msgWin32, 0, 0, 0, PM_REMOVE)) then begin
      if (msgWin32.message = WM_QUIT) then break;
      TranslateMessage (msgWin32);
      DispatchMessage (msgWin32);
    end else
      OnIdle;
  end;
  //
  Result := msgWin32.wParam;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWindowsWrapper.ProcessMessage (hWindow: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM);
var
  rBounds: TRect;
begin 
  case msg of
    // On window creation
    WM_CREATE: begin
      if (GetWindowRect (FMainWindow, rBounds)) then
        SetWindowPos (FMainWindow, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE);
    end;
    // On window destruction
    WM_DESTROY: begin
      OnWinDestroy;
      PostQuitMessage(0);
    end;
    // Catch Activate/Deactivate
    WM_ACTIVATE: begin
      if (wParam in [WA_ACTIVE, WA_CLICKACTIVE]) then
        OnWinActivate else OnWinDeactivate;
    end;
    // On cursor set: turn off cursor if full-screen mode
    WM_SETCURSOR: begin
      if (CoreEngine <> NIL) AND (CoreEngine.Exclusive) then SetCursor (0);
    end;
  end;
end;


////////////////////////////////////////////////////////////////////////////////
// Activate().
//  called when the window gets activated initially.  If the Zeta
//  engine had not been constructed, this routine will construct it.
procedure TZEWindowsWrapper.OnWinActivate;
begin
  if (CoreEngine = NIL) then begin
    Callbacks.Add (SCRIPT_GAME_GUI, FCreateUIFunc);
    Callbacks.Add (SCRIPT_USER_EVENTS, FHandleEventFunc);
    //ScriptMaster.AddHandler (SCRIPT_GAME_GUI, FCreateUIFunc);
    //ScriptMaster.AddHandler (SCRIPT_USER_EVENTS, FHandleEventFunc);
    //
    CoreEngine := TZEGameCore.Create (FProgramConfig);
    CoreEngine.Initialize (FMainWindow, FAppInstance);
  end;
  //
  CoreEngine.Activate;
end;

////////////////////////////////////////////////////////////////////////////////
// Deactivate().
//   when the application loses focus, this will be called.  It
//   simply passes the notification to the Engine, if present.
procedure TZEWindowsWrapper.OnWinDeactivate;
begin
  if (CoreEngine <> NIL) then CoreEngine.Deactivate;
end;

////////////////////////////////////////////////////////////////////////////////
// Destroy().
//   user has exited and we need to perform cleanup.  Destroys engine.
procedure TZEWindowsWrapper.OnWinDestroy;
begin
  FMainWindow := 0; // invalidate handle
  // shutdown the engine
  //FreeAndNIL (CoreEngine);
end;

////////////////////////////////////////////////////////////////////////////////
// Idle().
//   everytime there is no message in the windows message pump, this runs.
procedure TZEWindowsWrapper.OnIdle;
var
  bResult: Boolean;
begin
  if (CoreEngine = NIL) then Exit;
  bResult := CoreEngine.Refresh;
  if (bResult) then begin
    FreeAndNIL (CoreEngine);
    PostQuitMessage (0);
  end;
end;


{ Wrapper Callback }

//////////////////////////////////////////////////////////////////////////
function WrapperProc (hWindow: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  Wrapper: TZEWindowsWrapper;
begin
  Wrapper := TZEWindowsWrapper (GetWindowLong (hWindow, GWL_USERDATA));
  if (Wrapper <> NIL) AND (Wrapper.FMainWindow <> 0) then begin
    try
      Wrapper.ProcessMessage (hWindow, msg, wParam, lParam);
      if (Assigned (Wrapper.WindowProc)) then
        Wrapper.WindowProc (hWindow, msg, wParam, lParam);
    except
    end;
  end;
  //
  Result := DefWindowProc (hWindow, msg, wParam, lParam);
end;


//////////////////////////////////////////////////////////////////////////
function WrapperCreate (cConfigFile: string; UICB, HECB: TZbCallbackFunction): TZEWindowsWrapper;
begin
  if (NOT Assigned (UICB)) OR (NOT Assigned (HECB)) then begin
    Result := NIL;
    Exit;
  end;
  //
  Result := TZEWindowsWrapper.Create;
  if (Result = NIL) then begin
    MessageBox (0, 'Cannot create Windows (tm) Wrapper Class', 'ERROR', MB_OK or MB_ICONERROR);
    Exit;
  end;
  //
  Result.ProgramConfig := cConfigFile;
  Result.CreateUIFunc := UICB;
  Result.HandleEventFunc := HECB;
end;


end.
