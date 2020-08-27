{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXCore.PAS
              The DirectX Class Interface
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXCore.pas,v 1.2 2002/11/02 06:37:38 Vij Exp $
  $Log: ZEDXCore.pas,v $
  Revision 1.2  2002/11/02 06:37:38  Vij
  code cleanup.  also fixed the windowed mode drawing code.

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXCore;

interface

uses
  Windows,
  SysUtils,
  Classes,
  DirectDraw;

const
  ERROR_NO_ERROR                =   000;

  ERROR_DI8_BEGINS              =   100;
  ERROR_DI8_GEN_INIT_FAILED     =   ERROR_DI8_BEGINS + 0;
  ERROR_DI8_MOUSE_INIT_FAILED   =   ERROR_DI8_BEGINS + 1;
  ERROR_DI8_KBD_INIT_FAILED     =   ERROR_DI8_BEGINS + 2;

  ERROR_DX7_BEGINS              =   200;
  ERROR_DX7_NO_DEVICE           =   ERROR_DX7_BEGINS + 0;
  ERROR_DX7_SCL_FAILED          =   ERROR_DX7_BEGINS + 1;
  ERROR_DX7_MODE_FAILED         =   ERROR_DX7_BEGINS + 2;
  ERROR_DX7_NO_MAINBUFFER       =   ERROR_DX7_BEGINS + 3;
  ERROR_DX7_NO_BACKBUFFER       =   ERROR_DX7_BEGINS + 4;

  (*---------------------------------------------
  //-- error/warning messages
  ErrMessage00  = 'Unknown Error';
  ErrMessage01  = 'DirectMusic failed to initialize, music will be disabled';
  ErrMessage02  = 'DirectInput failed to initialize';
  ErrMessage03  = 'Failed to initialize keyboard';
  ErrMessage04  = 'Failed to initialize mouse';
  ErrMessage05  = 'Failed to initialize DirectDraw';
  ErrMessage06  = 'Failed to initialize proper graphics mode';
  ErrMessage07  = 'Failed to initialize screen buffers'; *)

  MAX_VOLUME                =   25;
  DEFAULT_SOUND_VOLUME      =   100;
  DEFAULT_MUSIC_VOLUME      =   20;
  DM_MIN_VOLUME             =   -9600;
  DS_MIN_VOLUME             =   -10000;


type
  TZEScreenResolution = record
    Width: integer;
    Height: integer;
    Depth: integer;
  end;

  TZEDXEngine = class (TObject)
  private
    FInitialized: boolean;              // true if we're successfully initialized
    FHostWindow: HWND;                  // handle to host window
    FDirectDraw: IDirectDraw7;          // DirectDraw Interface.
    FMainBuffer: IDirectDrawSurface7;   // Primary surface.
    FBackBuffer: IDirectDrawSurface7;   // Backbuffer surface.
    FSysBuffer: IDirectDrawSurface7;    // Backbuffer in system memory
    FResolution: TZEScreenResolution;   // resolution to set
    FViewport: TRect;                   // bounds for viewport
    FWindowedBounds: TRect;             // rect for windowed area
    FStartupError: integer;             // whatever happened during the init
    FExclusive: boolean;                // flags whether full-screen or not
    FBackBufferInSysMem: boolean;       // true if the backbuffer is in system memory
    //
    FBackBufferLocked: boolean;         // true if back buffer is locked
    FBackBufferDesc: TDDSurfaceDesc2;   // descriptor only valid if back buffer is locked!
    //
    property BackBufferInSysMem: boolean read FBackBufferInSysMem write FBackBufferInSysMem;
  protected
    procedure SetResolution (iResolutionX, iResolutionY, iColorDepth: integer);
    //
    function SetCooperativeLevel: boolean;
    function SetVideoMode: boolean;
    function CreateSurfaces: boolean;
    //
    procedure FreeMainBuffers;
    procedure DDClose;
    function DDI_Exclusive: boolean;
    function DDI_Windowed: boolean;
    procedure DDInit;
    //
    function GetMainBuffer: IDirectDrawSurface7;
    function GetBackBuffer: IDirectDrawSurface7;
    //
    // routines to handle windowed mode
    function CalcWindowedRect: TRect;
    procedure AdjustMainWindow;
  public
    constructor Create (_hWnd: HWND); virtual;
    destructor Destroy; override;
    //
    function Initialize (AExclusiveMode: boolean;
      iResolutionX, iResolutionY, iColorDepth: integer;
      SysMemForBackBuffer: boolean = false): boolean;
    procedure Shutdown;
    //
    function LockBackBuffer: boolean;
    procedure UnlockBackBuffer;
    procedure Flip;
    //
    function LostSurfaces: boolean;
    procedure RestoreSurfaces;
    //
    property StartupError: integer read FStartupError;
    property MainBuffer: IDirectDrawSurface7 read GetMainBuffer;
    property BackBuffer: IDirectDrawSurface7 read GetBackBuffer;
    //
    property IsInitialized: boolean read FInitialized;
    property SysMemBackBuf: boolean read FBackBufferInSysMem;
    property DD7: IDirectDraw7 read FDirectDraw;
    property ResolutionX: integer read FResolution.Width;
    property ResolutionY: integer read FResolution.Height;
    property ResolutionDepth: integer read FResolution.Depth;
  end;

var
  DX7Engine: TZEDXEngine = NIL;


implementation

uses
  ZbGameUtils;


{ TZEDXEngine }

////////////////////////////////////////////////////////////////////
constructor TZEDXEngine.Create (_hWnd: HWND);
begin
  FHostWindow := _hWnd;
  //
  FDirectDraw := NIL;
  FMainBuffer := NIL;
  FBackBuffer := NIL;
  FSysBuffer  := NIL;
  //
  FExclusive := true;
  FViewport := Rect (0, 0, 0, 0);
  FWindowedBounds := Rect (0, 0, 0, 0);
  SetResolution (640, 480, 16);
  //
  FStartupError := ERROR_NO_ERROR;
  FInitialized := false;
  //
  FBackBufferLocked := false;
  ZeroMemory (@FBackBufferDesc, SizeOf (FBackBufferDesc));
end;

////////////////////////////////////////////////////////////////////
destructor TZEDXEngine.Destroy;
begin
  Shutdown;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.SetResolution (iResolutionX, iResolutionY, iColorDepth: integer);
begin
  with FResolution do begin
    Width := iResolutionX;
    Height := iResolutionY;
    Depth := iColorDepth;
  end;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.SetCooperativeLevel: boolean;
var
  HR: HResult;
begin
  if (FExclusive) then
    HR := FDirectDraw.SetCooperativeLevel (FHostWindow,
            DDSCL_ALLOWREBOOT OR DDSCL_EXCLUSIVE OR
            DDSCL_FULLSCREEN OR DDSCL_FPUSETUP)
  else
    HR := FDirectDraw.SetCooperativeLevel (FHostWindow, DDSCL_NORMAL OR DDSCL_FPUSETUP);
  //
  Result := (NOT failed (HR));
  if (NOT Result) then FStartupError := ERROR_DX7_SCL_FAILED;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.SetVideoMode: boolean;
var
  HR: HResult;
  ScrMode: Cardinal;
begin
  Result := false;
  // ignore call if not in exclusive mode
  if (NOT FExclusive) then exit;
  // If the selected mode is 320x200x8, use the standard
  // 13h mode instead of Mode X
  with FResolution do
    if ((Width = 320) AND (Height = 200) AND (Depth = 8)) then
      ScrMode := DDSDM_STANDARDVGAMODE
      else ScrMode := 0;

  // Set the video mode.
  with FResolution do
    HR := FDirectDraw.SetDisplayMode(Width, Height, Depth, 0, ScrMode);

  // check return value
  Result := (NOT failed (HR));
  if (NOT Result) then
    FStartupError := ERROR_DX7_MODE_FAILED
    else FWindowedBounds := Rect (0, 0, ResolutionX, ResolutionY);
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.CreateSurfaces: boolean;
var
  HR: HResult;
  DXSurfDesc : TDDSurfaceDesc2;
  DXSurfCaps : TDDSCaps2;
  DXClipper : IDirectDrawClipper;
begin
  Result := false;
  //
  FreeMainBuffers;
  if (FExclusive) then begin
    // Set the primary surface description.
    ZeroMemory (@DXSurfDesc, SizeOf (DXSurfDesc));
    with DXSurfDesc do begin
      dwSize  := SizeOf(DXSurfDesc);
      dwFlags := DDSD_CAPS OR DDSD_BACKBUFFERCOUNT;
      ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE OR DDSCAPS_3DDEVICE OR
                    DDSCAPS_FLIP OR DDSCAPS_COMPLEX;
      dwBackBufferCount := 1;
    end;
    //
    // Create the primary surface.
    HR := FDirectDraw.CreateSurface (DXSurfDesc, FMainBuffer, NIL);
    if (failed(HR)) then begin
      FStartupError := ERROR_DX7_NO_MAINBUFFER;
      Exit;
    end;
    //
    // Get the backbuffer from the primary surface.
    ZeroMemory (@DXSurfCaps, SizeOf (DXSurfCaps));
    DXSurfCaps.dwCaps := DDSCAPS_BACKBUFFER;
    HR := FMainBuffer.GetAttachedSurface(DXSurfCaps, FBackBuffer);
    if (failed (HR)) then begin
      FStartupError := ERROR_DX7_NO_BACKBUFFER;
      Exit;
    end;
    FBackBuffer._AddRef;
    //
    // create another back buffer in system memory if required
    if (BackBufferInSysMem) then begin
      ZeroMemory (@DXSurfDesc, SizeOf (DXSurfDesc));
      with DXSurfDesc do begin
        dwSize  := SizeOf (DXSurfDesc);
        dwFlags := DDSD_CAPS or DDSD_WIDTH or DDSD_HEIGHT;
        dwWidth  := ResolutionX;
        dwHeight := ResolutionY;
        ddsCaps.dwCaps := DDSCAPS_OFFSCREENPLAIN OR DDSCAPS_SYSTEMMEMORY;
        //
      end;
      HR := DX7Engine.DD7.CreateSurface (DXSurfDesc, FSysBuffer, NIL);
      if (FAILED (HR)) then begin
        FStartupError := ERROR_DX7_NO_BACKBUFFER;
        Exit;
      end;
    end;
    //
  end else begin
    // Set the primary surface description.
    ZeroMemory (@DXSurfDesc, SizeOf (DXSurfDesc));
    with DXSurfDesc do begin
      dwSize  := SizeOf(DXSurfDesc);
      dwFlags := DDSD_CAPS;
      ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;
    end;
    //
    // Create the primary surface.
    HR := FDirectDraw.CreateSurface (DXSurfDesc, FMainBuffer, NIL);
    if (failed(HR)) then exit;
    // Set another surface description.
    ZeroMemory (@DXSurfDesc, SizeOf (DXSurfDesc));
    with DXSurfDesc do begin
      dwSize  := SizeOf(DXSurfDesc);
      dwFlags := DDSD_CAPS OR DDSD_WIDTH OR DDSD_HEIGHT;
      ddsCaps.dwCaps := DDSCAPS_OFFSCREENPLAIN OR DDSCAPS_3DDEVICE;
      dwWidth := FResolution.Width;
      dwHeight := FResolution.Height;
    end;
    //
    // Create the back buffer surface.
    HR := FDirectDraw.CreateSurface (DXSurfDesc, FBackBuffer, NIL);
    if (failed (HR)) then exit;
    //
    // Create a clipper interface.
    HR := FDirectDraw.CreateClipper (0, DXClipper, nil);
    if (failed (HR)) then exit;
    // Set the clipper.
    DXClipper.SetHWnd (0, FHostWindow);
    FMainBuffer.SetClipper (DXClipper);
    DXClipper := NIL;
  end;
  //
  Result := true;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.FreeMainBuffers;
begin
  if (Assigned (FSysBuffer)) then FSysBuffer := NIL;
  if (Assigned (FBackBuffer)) then FBackBuffer := NIL;
  if (Assigned (FMainBuffer)) then begin
    if (NOT FExclusive) then FMainBuffer.SetClipper (NIL);
    FMainBuffer := NIL;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.DDClose;
begin
  if (FInitialized) then begin
    FreeMainBuffers;
    if Assigned (FDirectDraw) then FDirectDraw := NIL;
    FInitialized := false;
  end;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.DDI_Exclusive: boolean;
begin
  Result := false;
  if (NOT SetVideoMode) then exit;
  if (NOT CreateSurfaces) then exit;
  //
  SetWindowLong (FHostWindow, GWL_STYLE, 0);
  SetWindowLong (FHostWindow, GWL_EXSTYLE, WS_EX_APPWINDOW);
  //
  //ShowWindow (FHostWindow, SW_HIDE);
  with FResolution do MoveWindow (FHostWindow, 0, 0, Width, Height, TRUE);
  ShowWindow (FHostWindow, SW_SHOW);
  SetFocus (FHostWindow);
  //
  Result := true;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.DDI_Windowed: boolean;
var
  tDelta: TPoint;
begin
  Result := false;
  AdjustMainWindow;
  GetClientRect (FHostWindow, FWindowedBounds);
  //
  GetWindowRect (FHostWindow, FViewport);
  tDelta := Point (0, 0);
  ClientToScreen (FHostWindow, tDelta);
  tDelta := SubPoint (tDelta, FViewport.TopLeft);
  FViewport.TopLeft := AddPoint (FWindowedBounds.TopLeft, tDelta);
  FViewport.BottomRight := AddPoint (FWindowedBounds.BottomRight, tDelta);
  //
  if (NOT CreateSurfaces) then exit;
  Result := true;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.DDInit;
var
  HR: HResult;
  bSuccess: boolean;
begin
  // close DirectDraw first
  DDClose;
  // Create DirectDraw Interface.
  FViewport := Rect (0, 0, FResolution.Width, FResolution.Height);
  HR := DirectDrawCreateEx (NIL, FDirectDraw, IID_IDirectDraw7, NIL);
  if (failed (HR)) then begin
    FStartupError := ERROR_DX7_NO_DEVICE;
    Exit;
  end;
  //
  if (NOT SetCooperativeLevel) then exit;
  //
  if (FExclusive) then
    bSuccess := DDI_Exclusive
    else bSuccess := DDI_Windowed;
  //
  if (bSuccess) then FInitialized := true;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.GetMainBuffer: IDirectDrawSurface7;
begin
  Result := FMainBuffer;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.GetBackBuffer: IDirectDrawSurface7;
begin
  if (NOT BackBufferInSysMem) then
    Result := FBackBuffer
    else Result := FSysBuffer;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.CalcWindowedRect: TRect;
var
  TR, rCurClientRect, rCurWindowRect: TRect;
  Delta: TPoint;
begin
  ZeroMemory (@TR, sizeof (TR));
  //
  GetWindowRect (FHostWindow, rCurWindowRect);
  GetClientRect (FHostWindow, rCurClientRect);
  //
  Delta.X := rCurClientRect.Right - FResolution.Width;
  Delta.Y := rCurClientRect.Bottom - FResolution.Height;
  //
  TR.Left   := rCurWindowRect.Left;
  TR.Top    := rCurWindowRect.Top;
  TR.Right  := rCurWindowRect.Right - Delta.X;
  TR.Bottom := rCurWindowRect.Bottom - Delta.Y;
  //
  Result := TR;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.AdjustMainWindow;
var
  Bounds: TRect;
begin
  // ignore call if we're in exclusive mode
  if (FExclusive) then exit;
  //
  //ShowWindow (FHostWindow, SW_HIDE);
  Bounds := CalcWindowedRect;
  with Bounds do
    MoveWindow (FHostWindow, Left, Top, (Right - Left), (Bottom - Top), TRUE);
  //
  ShowWindow (FHostWindow, SW_SHOW);
  SetFocus (FHostWindow);
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.Initialize (AExclusiveMode: boolean;
  iResolutionX, iResolutionY, iColorDepth: integer;
  SysMemForBackBuffer: boolean): boolean;
begin
  if (FInitialized) then Shutdown;
  SetResolution (iResolutionX, iResolutionY, iColorDepth);
  FExclusive := AExclusiveMode;
  BackBufferInSysMem := SysMemForBackBuffer AND AExclusiveMode;
  DDInit;
  //
  Result := FInitialized;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.Shutdown;
begin
  DDClose;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.LockBackBuffer: boolean;
var
  HR: HResult;
begin
  Result := false;
  if (NOT FInitialized) then Exit;
  //
  ZeroMemory (@FBackBufferDesc, SizeOf (FBackBufferDesc));
	FBackBufferDesc.dwSize := SizeOf (FBackBufferDesc);
  if (NOT BackBufferInSysMem) then
    HR := FBackBuffer.Lock (NIL, FBackBufferDesc, DDLOCK_WAIT, 0)
    else HR := FSysBuffer.Lock (NIL, FBackBufferDesc, DDLOCK_WAIT, 0);
  //
  Result := NOT FAILED (HR);
  FBackBufferLocked := Result;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.UnlockBackBuffer;
begin
  if (NOT FBackBufferLocked) then Exit;
  if (NOT BackBufferInSysMem) then
    FBackBuffer.Unlock (NIL)
    else FSysBuffer.Unlock (NIL);
  //
  FBackBufferLocked := false;
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.Flip;
begin
  if (NOT FInitialized) OR (FBackBufferLocked) then exit;
  //
  if (FExclusive) then begin
    if (BackBufferInSysMem) then
      FBackBuffer.Blt (@FViewport{@FWindowedBounds}, FSysBuffer, NIL, DDBLT_DONOTWAIT, NIL);
    //
    FMainBuffer.Flip(FBackBuffer, 0);
  end else begin
    ClientToScreen (FHostWindow, FWindowedBounds.TopLeft);
    ClientToScreen (FHostWindow, FWindowedBounds.BottomRight);
    FMainBuffer.Blt (@FViewport{@FWindowedBounds}, FBackBuffer, NIL, DDBLT_WAIT, NIL);
  end;
end;

////////////////////////////////////////////////////////////////////
function TZEDXEngine.LostSurfaces: boolean;
begin
  Result := ((FBackBuffer <> NIL) AND (FBackBuffer.IsLost <> 0));
end;

////////////////////////////////////////////////////////////////////
procedure TZEDXEngine.RestoreSurfaces;
begin
  FDirectDraw.RestoreAllSurfaces;
  if (BackBufferInSysMem) then FSysBuffer._Restore;
end;

end.


