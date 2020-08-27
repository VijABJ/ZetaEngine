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
  ZbScriptable,
  ZbIniFileEx,
  ZbGameUtils,
  ZbFileIntf,
  //
  ZEDXCore,
  ZEDXDev,
  ZEDXImageLib,
  ZEDXSpriteIntf,
  ZEDXSprite;

const
  ZEDXF_IMAGE_VOLUME          = 'Game.zvf';
  ZEDXF_TICK_THRESHOLD        = 1000;

  SPLASH_FILE                 = 'Splash';

type
  TZESoundOption = (soMusic, soSoundFX);
  TZESoundOptions = set of TZESoundOption;
  TZETimerStatus = (tsRunning, tsStopped, tsPaused);

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
    procedure HandleEvent (Event: TZEEvent); virtual;
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
    function Initialize (hWindow: HWND; hAppInstance: HINST): boolean; virtual;
    procedure Shutdown; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure Terminate;
    function Refresh: boolean; virtual;
    //
    procedure SetBackgroundMusic (AMusicName: string);
    procedure ClearBackgroundMusic;
    procedure PlaySound (ASoundName: string);
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
  end;

var
  GlobalExitOnEscape: boolean = FALSE;


implementation

uses
  Types,
  SysUtils,
  StrUtils,
  DirectInput8,
  DirectShow,
  //
  ZbFileUtils,
  ZbStringUtils,
  ZbConfigManager,
  ZbVirtualFS,
  ZbDebug,
  //
  ZEDXImage,
  ZEDXAudio,
  ZEDXMusic;

{ TZEFrameworkDX }

////////////////////////////////////////////////////////////////////
constructor TZEFrameworkDX.Create (AConfigFile: string);
begin
  inherited Create;
  //
  FTicksTotal := 0;
  FFramesRendered := 0;
  //
  FHostWindow := 0;
  FRunning := FALSE;
  FReady := FALSE;
  FExclusive := FALSE;
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
  Result := (soSoundFX in FSoundOptions) AND (SoundFXMngr <> NIL);
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
  Result := (soMusic in FSoundOptions) AND (MusicMngr <> NIL);
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
    if (bRestoreInput AND Exclusive) then begin
      DI8MouseControl (TRUE);
      DI8KeyboardControl (TRUE);
    end;
  end;
  //
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.ShowFPS;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.HandleEvent (Event: TZEEvent);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.CheckDevices;
var
  Event: TZEEvent;
  MusicCurrent, MusicEnd: int64;
begin
  // process the timer because it might fire an event...
  if (FTimerStatus = tsRunning) then begin
    if (FCountdownTimer.CheckResetTrigger (GlobalElapsedTicks)) then begin
      FCountdownTimer.TriggerValue := 0;
      EventQueue.InsertEvent (cmEngineTimerExpired);
      FTimerStatus := tsStopped;
    end else begin
      EventQueue.InsertEvent (cmEngineTimerTick, 0,
        Integer (FCountdownTimer.TriggerValue - FCountdownTimer.Accumulator));
    end;
  end;
  //
  // process the internal event list first
  Event := EventQueue.PopEvent;
  while (Event.Event <> evDONE) do begin
    if (Event.Command = cmFinalExit) then begin
      HandleEvent (Event);
      Terminate;
      Exit;
    end;
    //
    HandleEvent (Event);
    EventQueue.CleanupEvent (Event);
    Event := EventQueue.PopEvent;
  end;
  //
  //
  // check the keyboard
  if (DI8GetKeyboardState) then begin
    if (GlobalExitOnEscape) AND (DI8KeyDown (DIK_ESCAPE)) then begin
      EventQueue.InsertEvent (cmFinalExit);
      Exit;
    end;
    //
    EventQueue.ClearEvent (Event);
    Event.Event := evKeyboard;
    Event.cKey := KeyboardQueue.GetChar;
    while (Event.cKey <> #0) do begin
      if (GlobalExitOnEscape) AND (Event.cKey = #27) then
        EventQueue.InsertEvent (cmFinalExit)
        else HandleEvent (Event);
      //
      EventQueue.ClearEvent (Event);
      Event.Event := evKeyboard;
      Event.cKey := KeyboardQueue.GetChar;
    end;
  end;
  //
  // check the mouse
  Mouse.GetEvent (Event);
  while (Event.Event <> evDONE) do begin
    HandleEvent (Event);
    Mouse.GetEvent (Event);
  end;
  //
  // check the background music if it needs to be restarted
  if (PlayingMusic) AND (FMusicTimer.CheckResetTrigger (GlobalElapsedTicks)) then begin
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
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.RenderScene;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.RenderScreen;
begin
  RenderScene;
  if ((Mouse <> NIL) AND (Mouse.Visible)) then begin
    Mouse.Animate (GlobalElapsedTicks);
    Mouse.DrawPointer;
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
  Result := PreInitialize;
  if (NOT Result) then Exit;
  //
  // initialize DirectInput
  InitDeviceHandlers;
  InitError := DI8Init (HostWindow, hAppInstance);
  if (InitError <> 0) then Exit;
  //
  // Initialize DirectMusic.
  Music := DM8Init(HostWindow, TRUE);
  //
  // Initialize the DirectX Engine
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
  // initialize the mouse, no cursor yet though...
  Mouse := TZEMouse.Create (Bounds);
  Mouse.Visible := FALSE;
  Mouse.Center;
  //
  // attemp to load splash screen if present...
  LoadSplash;
  //
  // load all data present
  LoadData;
  //
  // call post-initialization
  Result := PostInitialize;
  if (NOT Result) then Exit;
  //
  //
  FReady := TRUE;
  Result := TRUE;
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
  FreeAndNIL (MusicMngr);
  FreeAndNIL (SoundFXMngr);
  DM8Close;
  //
  // free the DirectX proper
  FreeAndNIL (Mouse);
  ImageManager.ClearCache;
  DI8Close;
  CloseDeviceHandlers;
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
    if (Exclusive) then begin
      DI8MouseControl (TRUE);
      DI8KeyboardControl (TRUE);
    end;
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
    UpdateGlobalCounter;
    //
    Inc (FTicksTotal, GlobalElapsedTicks);
    if (FTicksTotal >= ZEDXF_TICK_THRESHOLD) then begin
      ShowFPS;
      FFramesRendered := 0;
      Dec (FTicksTotal, ZEDXF_TICK_THRESHOLD);
    end;
    //
    CheckDevices;
    if (NOT Terminated) then begin
      PerformProcessing;
      RenderScreen;
      Inc (FFramesRendered);
    end;
    //
  end;
  //
  Result := Terminated;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.SetBackgroundMusic (AMusicName: string);
begin
  if (MusicMngr <> NIL) AND (Music) AND (AMusicName <> '') then begin
    if (MusicMngr.LoadFile (AMusicName)) then MusicMngr.Play;
    FPlayingMusic := TRUE;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.ClearBackgroundMusic;
begin
  if (MusicMngr <> NIL) AND (MusicMngr.Playing) then begin
    MusicMngr.Stop;
    FPlayingMusic := FALSE;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEFrameworkDX.PlaySound (ASoundName: string);
var
  SoundEFX: TZESoundSegment;
begin
  if (SoundFXMngr <> NIL) AND (SoundFX) AND (ASoundName <> '') then begin
    SoundEFX := SoundFXMngr [ASoundName];
    if (SoundEFX <> NIL) then SoundEFX.Play;
  end;
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


end.

