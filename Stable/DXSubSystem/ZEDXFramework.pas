{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXFramework.PAS
              This is an application framework that uses the DirectX Engine
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXFramework.pas,v 1.5 2002/12/18 08:27:26 Vij Exp $
  $Log: ZEDXFramework.pas,v $
  Revision 1.5  2002/12/18 08:27:26  Vij
  Added Pausable/Stoppable Timer

  Revision 1.4  2002/12/01 14:49:07  Vij
  Added StartCountdownTimer(), and event handling for this

  Revision 1.3  2002/11/02 06:43:43  Vij
  Added support for splash screens

  Revision 1.2  2002/10/01 12:34:20  Vij
  SpriteFactory is now a property of the Framework (was a global).  Added flag
  to record if music is being played.  Added code to loop the background music
  if necessary.  Added LoadImageVolume() overloads.

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXFramework;

interface

uses
  Windows,
  Classes,
  //
  ZblIWinWrap,
  ZblIEvents,
  ZbDI8EventManager,
  //
  ZbScriptable,
  ZbIniFileEx,
  ZbGameUtils,
  ZbFileIntf,
  //
  ZEDXCore,
  ZEDXImageLib,
  ZEDXSpriteIntf,
  ZEDXSprite;

const
  ZEDXF_IMAGE_VOLUME          = 'Game.zvf';
  ZEDXF_TICK_THRESHOLD        = 1000;

  SPLASH_FILE                 = 'Splash';

  cmEngineCommandBase         = 50;
  cmEngineTimerExpired        = cmEngineCommandBase + 0;
  cmEngineTimerTick           = cmEngineCommandBase + 1;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESoundOption = (soMusic, soSoundFX);
  TZESoundOptions = set of TZESoundOption;
  TZETimerStatus = (tsRunning, tsStopped, tsPaused);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMouseCursor = class;
  TZEFrameworkDX = class;

  TZECreatorFunc = function: LongBool;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEFrameworkDX = class (TZbScriptable)
  private
    FTicksTotal: Cardinal;
    FFramesRendered: Cardinal;
    //
    FHostWindow: HWND;
    FRunning: boolean;
    FReady: boolean;
    FExclusive: boolean;
    FTerminated: boolean;
    //
    FInitError: Integer;
    FResolution: TZEScreenResolution;
    FBounds: TRect;
    //
    FSoundOptions: TZESoundOptions;
    FMusicTimer: TZbSimpleTimeTrigger;
    FPlayingMusic: boolean;
    //
    FCountdownTimer: TZbSimpleTimeTrigger;
    FTimerStatus: TZETimerStatus;
    //
    FFileManager: IZbFileManager;
    FImageManager: TZEImageManager;
    FSpriteFactory: IZESpriteFactory;
    //
  protected
    FMouseVisible: LongBool;
    FMouseState: TZbMouseState;
    FMouseCursor: TZEMouseCursor;
  protected
    procedure SetSpriteSurface (Sprite: IZESprite);
    //
    function SoundFXActive: boolean;
    procedure ToggleSoundFX (tSoundFX: boolean);
    function MusicActive: boolean;
    procedure ToggleMusic (tMusic: boolean);
    //
    function GetSplashFilename: string; virtual;
    procedure LoadSplash;
    procedure LoadImageVolume (cVolumeFile: string; StrList: TStrings);
    procedure LoadSettings; virtual;
    procedure LoadData; virtual;
    procedure CleanupSettings; virtual;
    function PreInitialize: boolean; virtual;
    function PostInitialize: boolean; virtual;
    procedure PreShutdown; virtual;
    procedure PostShutdown; virtual;
    //
    procedure RestoreResources (bRestoreInput: boolean = FALSE); virtual;
    procedure ShowFPS; virtual;
    //
    procedure HandleEvent (Event: TZbEvent); virtual;
    procedure CheckDevices;
    procedure RenderScene; virtual;
    procedure RenderScreen;
    procedure PerformProcessing; virtual;
    //
    property IExclusive: boolean read FExclusive write FExclusive;
    property IResolution: TZEScreenResolution read FResolution write FResolution;
    property IScreenWidth: integer read FResolution.Width write FResolution.Width;
    property IScreenHeight: integer read FResolution.Height write FResolution.Height;
    property IScreenDepth: integer read FResolution.Depth write FResolution.Depth;
    //
    property Terminated: boolean read FTerminated write FTerminated;
    property InitError: integer read FInitError write FInitError;
    property TicksTotal: Cardinal read FTicksTotal write FTicksTotal;
    property FramesRendered: Cardinal read FFramesRendered write FFramesRendered;
  public
    constructor Create (AConfigFile: string); virtual;
    destructor Destroy; override;
    //
    procedure FlushEvents;
    procedure ClearEvent (var Event: TZbEvent; AZeroOnly: Boolean = FALSE);
    //procedure InsertCommand (ACommand: Integer; AParam1: Integer = 0; AParam2: Integer = 0); overload;
    //procedure InsertCommand (ACommand: Integer; AParam1: Integer; AStr: PChar); overload;
    //
    function Initialize (hWindow: HWND; hAppInstance: HINST): boolean; virtual;
    procedure Shutdown; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure Terminate;
    function Refresh: boolean; virtual;
    //
    procedure SetBackgroundMusic (AMusicName: PChar);
    procedure ClearBackgroundMusic;
    procedure PlaySound (ASoundName: PChar);
    //
    procedure StartCountdownTimer (ACountdownValueInTicks: Cardinal); overload;
    procedure StartCountdownTimer (AMinutes, ASeconds: Cardinal); overload;
    procedure PauseTimer;
    procedure UnPauseTimer;
    procedure StopTimer;
    //
    property HostWindow: HWND read FHostWindow;
    property Running: boolean read FRunning;
    property Ready: boolean read FReady;
    property Exclusive: boolean read FExclusive;
    //
    property Bounds: TRect read FBounds;
    property ScreenWidth: integer read FResolution.Width;
    property ScreenHeight: integer read FResolution.Height;
    property ScreenDepth: integer read FResolution.Depth;
    property SoundFX: boolean read SoundFXActive write ToggleSoundFX;
    property Music: boolean read MusicActive write ToggleMusic;
    property PlayingMusic: boolean read FPlayingMusic;
    //
    property FileManager: IZbFileManager read FFileManager;
    property ImageManager: TZEImageManager read FImageManager;
    property SpriteFactory: IZESpriteFactory read FSpriteFactory;
    //
    property MouseCursor: TZEMouseCursor read FMouseCursor;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMouseCursor = class
  private
    FPosition: TPoint;
    FBounds: TRect;
    //
    FCursor: IZESprite;
    FAnimated: boolean;
    FAnimationTimer: TZbSimpleTimeTrigger;
  protected
    function GetAnimationDelay: Cardinal;
    procedure SetAnimationDelay (ANewDelay: Cardinal);
    procedure SetCursor (Cursor: IZESprite);
    procedure InternalUpdatePosition (APosition: TPoint);
    procedure InternalUpdateBounds (ABounds: TRect);
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure Animate (AElapsedTicks: Cardinal);
    procedure DrawPointer (MouseState: PZbMouseState);
    //
    property Animated: boolean read FAnimated;
    property AnimationDelay: Cardinal
      read GetAnimationDelay write SetAnimationDelay;
    property Cursor: IZESprite read FCursor write SetCursor;
  end;

var
  g_DXFramework: TZEFrameworkDX = NIL;
  g_EngineMaker: TZECreatorFunc = NIL;
  g_EventManager: TZbEventManagerDX = NIL;
  //
  g_LastTick: Cardinal = 0;
  g_ElapsedTicks: Cardinal = 0;
  //
  g_ExitOnEscape: boolean = TRUE;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  //function AppFrameDelegateProc (WWEvent: TZbWinWrapEvent; AParam: Pointer;
  //  AWinHandle: HWND; AExtraData: Pointer): HRESULT; stdcall;
  procedure AttachToAppFrame;


implementation

uses
  Types,
  SysUtils,
  StrUtils,
  //
  ActiveX,
  ComObj,
  //
  DirectInput8,
  DirectShow,
  //
  ZblIAudio,
  ZblAppFrame,
  //
  ZbFileUtils,
  ZbStringUtils,
  ZbConfigManager,
  ZbVirtualFS,
  ZbDebug,
  //
  ZEDXImage,
  ZEDXAudio;


{ TZEFrameworkDX }

////////////////////////////////////////////////////////////////////
constructor TZEFrameworkDX.Create (AConfigFile: string);
begin
  inherited Create;
  CoInitialize (NIL);
  g_DXFramework := Self;
  //
  FTicksTotal := 0;
  FFramesRendered := 0;
  //
  FHostWindow := 0;
  FRunning := FALSE;
  FReady := FALSE;
  FTerminated := FALSE;
  //
  FResolution.Width := 640;
  FResolution.Height := 480;
  FResolution.Depth := 32;
  FExclusive := TRUE;
  FSoundOptions := [];
  FMusicTimer := TZbSimpleTimeTrigger.Create (1000);
  FCountdownTimer:= TZbSimpleTimeTrigger.Create (0);
  FTimerStatus := tsStopped;
  FPlayingMusic := FALSE;
  //
  ZeroMemory (@FResolution, SizeOf (FResolution));
  FBounds := EmptyRect;
  //
  ConfigManager := TZbConfigManager.Create (AConfigFile);
  FFileManager := TZbFileManager.Create as IZbFileManager;
  FImageManager := TZEImageManager.Create;
  FSpriteFactory := TZESpriteFactory.Create (FImageManager);
  FSpriteFactory.OnSpriteCreate := SetSpriteSurface;
  //
  LoadSettings;
  FBounds := Rect (0, 0, FResolution.Width, FResolution.Height);
end;

////////////////////////////////////////////////////////////////////
destructor TZEFrameworkDX.Destroy;
begin
  if (Running) then Deactivate;
  if (Ready) then Shutdown;
  //
  CleanupSettings;
  FCountdownTimer.Free;
  FMusicTimer.Free;
  FFileManager := NIL;
  FSpriteFactory := NIL;
  FreeAndNIL (FImageManager);
  FreeAndNIL (ConfigManager);
  //
  CoUninitialize;
  g_DXFramework := NIL;
  inherited;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.SetSpriteSurface (Sprite: IZESprite);
begin
  if (Sprite <> NIL) then Sprite.SetDestSurface (Pointer (DX7Engine.BackBuffer));
end;

////////////////////////////////////////////////////////////////////
function TZEFrameworkDX.SoundFXActive: boolean;
begin
  Result := (soSoundFX in FSoundOptions) AND
    (g_SoundFXMngr <> NIL) AND (g_SoundFXMngr.Initialized);
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.ToggleSoundFX (tSoundFX: boolean);
begin
  if (tSoundFX AND (NOT (soSoundFX in FSoundOptions))) then begin
    FSoundOptions := FSoundOptions + [soSoundFX];
  end else if ((NOT tSoundFX) AND (soSoundFX in FSoundOptions)) then begin
    FSoundOptions := FSoundOptions - [soSoundFX];
  end;
end;

////////////////////////////////////////////////////////////////////
function TZEFrameworkDX.MusicActive: boolean;
begin
  Result := (soMusic in FSoundOptions) AND (g_MusicMngr <> NIL);
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.ToggleMusic (tMusic: boolean);
begin
  if (tMusic AND (NOT (soMusic in FSoundOptions))) then begin
    FSoundOptions := FSoundOptions + [soMusic];
  end else if ((NOT tMusic) AND (soMusic in FSoundOptions)) then begin
    FSoundOptions := FSoundOptions - [soMusic];
  end;
end;

////////////////////////////////////////////////////////////////////
function TZEFrameworkDX.GetSplashFilename: string;
begin
  Result := Format ('%s%dX%d.ZIF',
    [SPLASH_FILE, FResolution.Width, FResolution.Height]);
  if (FileExists (Result)) then Exit;
  //
  Result := SPLASH_FILE + '.ZIF';
  if (FileExists (Result)) then Exit;
  //
  Result := '';
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.LoadSplash;
var
  SplashImage: TZEImage;
  SplashSprite: IZESprite;
  cSplashFile: string;
begin
  cSplashFile := GetSplashFilename;
  if (cSplashFile = '') then Exit;
  //
  SplashImage := TZEImage.Create (cSplashFile, FALSE);
  if (SplashImage = NIL) then Exit;
  //
  SplashSprite := TZESprite.Create (SplashImage, cSplashFile) as IZESprite;
  SplashSprite.Position := Point (0, 0);
  SplashSprite.SetDestSurface (Pointer (DX7Engine.BackBuffer));
  SplashSprite.Draw (FALSE);
  //
  DX7Engine.Flip;
  SplashSprite := NIL;
  SplashImage.Free;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.LoadImageVolume (cVolumeFile: string; StrList: TStrings);
begin
  if (cVolumeFile = '') OR (ImageManager = NIL) OR
    (NOT FileExists (cVolumeFile)) then Exit;
  //
  ImageManager.LoadLibrary (TZbStandardVolume.Create (cVolumeFile), StrList);
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.LoadSettings;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.LoadData;
var
  StrList: TStrings;
begin
  StrList := TStringList.Create;
  LoadImageVolume (ZEDXF_IMAGE_VOLUME, StrList);
  StrList.Free;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.CleanupSettings;
begin
end;

////////////////////////////////////////////////////////////////////
function TZEFrameworkDX.PreInitialize: boolean;
begin
  Result := TRUE;
end;

////////////////////////////////////////////////////////////////////
function TZEFrameworkDX.PostInitialize: boolean;
begin
  Result := TRUE;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.PreShutdown;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.PostShutdown;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.RestoreResources (bRestoreInput: boolean);
begin
  if (DX7Engine.LostSurfaces) then begin
    //
    DX7Engine.RestoreSurfaces;
    ImageManager.RestoreImages;
    if (bRestoreInput AND Exclusive) then g_EventManager.Restore;
  end;
  //
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.ShowFPS;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.HandleEvent (Event: TZbEvent);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.FlushEvents;
begin
  g_EventManager.Flush;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.ClearEvent (var Event: TZbEvent; AZeroOnly: Boolean);
begin
  if (AZeroOnly) then
    ZeroMemory (@Event, SizeOf (Event))
    else g_EventManager.Clear (@Event);
end;

////////////////////////////////////////////////////////////////////
function EscapeHandler (AKey: Integer; AEvent: TZbKeyState;
  AUserData: Integer): LongBool; stdcall;
begin
  if (AEvent = ksPressed) AND (g_ExitOnEscape) then begin
    try
      g_EventManager.Commands.Insert (cmGlobalExitFinal, 0, 0);
    except
    end;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.CheckDevices;
var
  Event: TZbEvent;
  MusicCurrent, MusicEnd: int64;
begin
  // update event vars
  g_EventManager.Update;
  FMouseVisible := g_EventManager.Mouse.GetMouseState (@FMouseState);
  g_EventManager.Timer.GetTimerValues (@g_ElapsedTicks, @g_LastTick);
  //
  // process the timer because it might fire an event...
  if (FTimerStatus = tsRunning) then begin
    if (FCountdownTimer.CheckResetTrigger (g_ElapsedTicks)) then begin
      FCountdownTimer.TriggerValue := 0;
      g_EventManager.Commands.Insert (cmEngineTimerExpired, 0, 0);
      FTimerStatus := tsStopped;
    end else begin
      g_EventManager.Commands.Insert (cmEngineTimerTick, 0,
        Integer (FCountdownTimer.TriggerValue - FCountdownTimer.Accumulator));
    end;
  end;
  //
  //while TRUE do begin

    ClearEvent (Event, TRUE);
    g_EventManager.Get (@Event);
    if (Event.m_Event <> evDONE) then
      case Event.m_Event of
        evCommand:
          if (Event.m_Command = cmGlobalExitFinal) then begin
            HandleEvent (Event);
            ClearEvent (Event);
            Terminate;
            Exit;
          end;
        evKeyboard:
          if (Event.m_Key = #27) then begin
            g_EventManager.Commands.Insert (cmGlobalExitFinal, 0, 0);
            ClearEvent (Event);
          end;
      end;

      if (Event.m_Event <> evDONE) then begin
        HandleEvent (Event);
        ClearEvent (Event);
      end;

  //end;

  // check the background music if it needs to be restarted
  {if (PlayingMusic) AND (FMusicTimer.CheckResetTrigger (g_ElapsedTicks)) then begin
    try
      MusicMngr.MediaSeeking.GetPositions (MusicCurrent, MusicEnd);
      if (MusicCurrent = MusicEnd) then begin
        MusicCurrent := 0;
        MusicMngr.MediaSeeking.SetPositions (
          MusicCurrent, AM_SEEKING_AbsolutePositioning,
          MusicCurrent, AM_SEEKING_NoPositioning);
        //
      end;
    except
      MusicMngr.Reset;
      FPlayingMusic := FALSE;
    end;
  end;}
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.RenderScene;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.RenderScreen;
begin
  RenderScene;
  if (FMouseVisible) then begin
    FMouseCursor.Animate (g_ElapsedTicks);
    FMouseCursor.DrawPointer (@FMouseState);
  end;
  //
  DX7Engine.Flip;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.PerformProcessing;
begin
end;

////////////////////////////////////////////////////////////////////
function TZEFrameworkDX.Initialize (hWindow: HWND; hAppInstance: HINST): boolean;
begin
  TraceLn ('ZEDX.Initialize() - ENTER');
  Result := FALSE;
  //
  Shutdown;
  FReady := FALSE;
  FRunning := FALSE;
  FHostWindow := hWindow;
  if (HostWindow = 0) then Exit;
  //
  // call pre-initialize in case something needs to be done before
  // initialization of DirectX...
  TraceLn ('--- Calling PreInit()');
  Result := PreInitialize;
  if (NOT Result) then Exit;
  //
  // Initialize DirectMusic.
  TraceLn ('--- Initializing DirectShow');
  g_SoundFXMngr := TZESoundManager.Create;
  SoundFX := g_SoundFXMngr.Initialized;
  g_MusicMngr := TZEMusicManager.Create;
  Music := g_MusicMngr.Initialized;
  //
  // initialize DirectInput
  TraceLn ('--- Initializing EventManager');
  ZbLib_GetEventManagerDX (g_EventManager);
  TraceLn ('... validating ...');
  if (NOT Assigned (g_EventManager)) then Exit;
  TraceLn ('... opening event devices ...');
  g_EventManager.Open (hWindow, hAppInstance, FExclusive);
  //
  TraceLn ('... hooking keyboard ...');
  g_EventManager.Keyboard.AddKeyHook (EscapeHandler, DIK_ESCAPE, Integer (Self));
  //
  TraceLn ('... setting up mouse ...');
  g_EventManager.Mouse.SetBounds (@Bounds);
  g_EventManager.Mouse.Center;
  g_EventManager.Mouse.SetVisible (TRUE);
  //
  TraceLn ('... creating mouse cursor ...');
  FMouseCursor := TZEMouseCursor.Create;
  FMouseCursor.InternalUpdateBounds (Bounds);
  //
  //g_EventManager.Commands.Insert (cmGlobalNull, 0, 0);
  //g_EventManager.Commands.InsertWithStr (cmGlobalNull, 0, 'TEST');
  //
  // Initialize the DirectX Engine
  TraceLn ('--- Initializing DirectX');
  DX7Engine := TZEDXEngine.Create (HostWindow);
  with FResolution do
    Result := DX7Engine.Initialize (Exclusive, Width, Height, Depth);
  //
  // if it failed to initialize, record what error it got
  // and discard it before exiting
  if (NOT Result) then begin
    InitError := DX7Engine.StartupError;
    FreeAndNIL (DX7Engine);
    Exit;
  end;
  //
  // attemp to load splash screen if present...
  TraceLn ('--- Loading Splash Screen');
  LoadSplash;
  //
  // load all data present
  TraceLn ('--- Loading Data');
  LoadData;
  //
  // call post-initialization
  TraceLn ('--- Calling PostInit()');
  Result := PostInitialize;
  if (NOT Result) then Exit;
  //
  //
  FReady := TRUE;
  Result := TRUE;
  TraceLn ('ZEDX.Initialize() - INIT OK');
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.Shutdown;
begin
  if (NOT Ready) then Exit;
  if (Running) then Deactivate;
  //
  PreShutdown;
  //
  // free the sound interfaces
  FreeAndNIL (g_MusicMngr);
  FreeAndNIL (g_SoundFXMngr);
  //
  // free the DirectX proper
  FreeAndNIL (FMouseCursor);
  FreeAndNIL (g_EventManager);
  //
  ImageManager.ClearCache;
  FreeAndNIL (DX7Engine);
  //
  FHostWindow := 0;
  PostShutdown;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.Activate;
begin
  if (Ready AND (NOT Running)) then begin
    RestoreResources;
    g_EventManager.Restore;
    //
    FRunning := TRUE;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.Deactivate;
begin
  if (Running) then FRunning := FALSE;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.Terminate;
begin
  Terminated := TRUE;
end;

////////////////////////////////////////////////////////////////////
function TZEFrameworkDX.Refresh: boolean;
begin
  //
  if (Ready AND Running) then begin
    //
    RestoreResources (TRUE);
    //
    CheckDevices;
    //
    Inc (FTicksTotal, g_ElapsedTicks);
    if (FTicksTotal >= ZEDXF_TICK_THRESHOLD) then begin
      ShowFPS;
      FFramesRendered := 0;
      Dec (FTicksTotal, ZEDXF_TICK_THRESHOLD);
    end;
    //
    if (NOT Terminated) then begin
      PerformProcessing;
      RenderScreen;
      Inc (FFramesRendered);
    end;
    //
    //
  end;
  //
  Result := Terminated;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.SetBackgroundMusic (AMusicName: PChar);
begin
  if (Music) then g_MusicMngr.PlayFile (AMusicName, 100);
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.ClearBackgroundMusic;
begin
  g_MusicMngr.Stop;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.PlaySound (ASoundName: PChar);
begin
  g_SoundFXMngr.PlayFile (ASoundName);
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.StartCountdownTimer (ACountdownValueInTicks: Cardinal);
begin
  FCountdownTimer.TriggerValue := ACountdownValueInTicks;
  FCountdownTimer.Reset;
  FTimerStatus := tsRunning;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.StartCountdownTimer (AMinutes, ASeconds: Cardinal);
begin
  FCountdownTimer.TriggerValueInSeconds := (AMinutes * 60) + ASeconds;
  FCountdownTimer.Reset;
  FTimerStatus := tsRunning;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.PauseTimer;
begin
  if (FTimerStatus = tsRunning) then begin
    FTimerStatus := tsPaused;
    //FCountdownTimer.ResetAccumulator;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.UnPauseTimer;
begin
  if (FCountdownTimer.TriggerValue > 0) then FTimerStatus := tsRunning;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.StopTimer;
begin
  FTimerStatus := tsStopped;
end;


{ TZEMouseCursor }

////////////////////////////////////////////////////////////////////
constructor TZEMouseCursor.Create;
begin
  inherited Create;
  FPosition := Point (0, 0);
  FBounds := Rect (0, 0, 0, 0);
  //
  FCursor := NIL;
  FAnimated := FALSE;
  FAnimationTimer := TZbSimpleTimeTrigger.Create (10);
end;

////////////////////////////////////////////////////////////////////
destructor TZEMouseCursor.Destroy;
begin
  FAnimationTimer.Free;
  FCursor := NIL;
  inherited;
end;

////////////////////////////////////////////////////////////////////
function TZEMouseCursor.GetAnimationDelay: Cardinal;
begin
  Result := FAnimationTimer.TriggerValue;
end;

////////////////////////////////////////////////////////////////////
procedure TZEMouseCursor.SetAnimationDelay (ANewDelay: Cardinal);
begin
  FAnimationTimer.TriggerValue := ANewDelay;
end;

////////////////////////////////////////////////////////////////////
procedure TZEMouseCursor.SetCursor (Cursor: IZESprite);
begin
  if (FCursor <> NIL) then FCursor := NIL;
  FCursor := Cursor;
  FAnimated := (FCursor <> NIL) AND (FCursor.FrameCount > 1);
end;

////////////////////////////////////////////////////////////////////
procedure TZEMouseCursor.InternalUpdatePosition (APosition: TPoint);
begin
  FPosition := APosition;
end;

////////////////////////////////////////////////////////////////////
procedure TZEMouseCursor.InternalUpdateBounds (ABounds: TRect);
begin
  FBounds := ABounds;
end;

////////////////////////////////////////////////////////////////////
procedure TZEMouseCursor.Animate (AElapsedTicks: Cardinal);
begin
  if ((NOT FAnimated) OR (FCursor = NIL)) then Exit;
  //
  if (FAnimationTimer.CheckResetTrigger (AElapsedTicks)) then
    FCursor.CycleFrameForward;
end;

////////////////////////////////////////////////////////////////////
procedure TZEMouseCursor.DrawPointer (MouseState: PZbMouseState);
begin
  if (FCursor = NIL) OR (MouseState = NIL) then Exit;
  //
  FCursor.Position := MouseState.m_Position;
  FCursor.DrawClipped (MouseState.m_Bounds);
end;


////////////////////////////////////////////////////////////////////
function AppFrameDelegateProc (WWEvent: TZbWinWrapEvent; AParam: Pointer;
  AWinHandle: HWND; AExtraData: Pointer): HRESULT; stdcall;

  procedure ShutdownDXFramework;
  begin
    g_DXFramework.Free;
    g_DXFramework := NIL;
  end;

begin
  Result := S_OK;
  //
  case WWEvent of
    //
    wweInitialize: begin
    end;
    //
    wweShutdown: begin
      if (g_DXFramework <> NIL) then ShutdownDXFramework;
    end;
    //
    wweForward: begin
    end;
    //
    wweAttach: begin
    end;
    //
    wweDetach: begin
    end;
    //
    wweActivated: begin
      //
      if (g_DXFramework = NIL) then begin
        //
        if (NOT Assigned (g_EngineMaker)) OR (NOT g_EngineMaker) then begin
          PostQuitMessage (0);
          Exit;
        end;
        //
      end;
      if (g_DXFramework <> NIL) then g_DXFramework.Activate;
    end;
    //
    wweDeactivated: begin
      if (g_DXFramework <> NIL) then g_DXFramework.Deactivate;
    end;
    //
    wwePerform: begin
      if (g_DXFramework = NIL) then Exit;
      if (g_DXFramework.Refresh) then begin
        ShutdownDXFramework;
        PostQuitMessage (0);
      end;
    end;
    //
  end;
end;

////////////////////////////////////////////////////////////////////
procedure AttachToAppFrame;
begin
  if (g_AppWrap <> NIL) then
    g_AppWrap.AddDelegateProc (AppFrameDelegateProc, NIL, 'ZEDXFrameWork', TRUE);
end;


////////////////////////////////////////////////////////////////////
initialization
  CoInitialize (NIL);

finalization
  CoUninitialize;

end.

