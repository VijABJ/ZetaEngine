{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEGameEngine.PAS
              The display engine class that actually runs the show.
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

unit ZZEGameEngine;

interface

{$DEFINE IMMEDIATE_EXIT}

uses
  Windows,
  Classes,
  ZbFileIntf,
  ZbScriptable,
  ZbGameUtils,
  //
  ZEDXDev,
  ZEDXImage,
  ZEDXSpriteIntf,
  ZEDXCore,
  //
  ZZETools,
  ZEWSBase,
  ZEWSDialogs,
  ZZEGameScreens,
  ZZEGameWindow,
  ZZConstants,
  //
  ZZEMapBasics,
  ZZEScrObjects;

const
  cmExitEngine          = 501;
  cmCutSceneEnds        = 502;
  cmSwitchToMenu        = 503;
  cmSwitchToGame        = 504;
  cmSwitchToCutScene    = 505;
  cmTogglePause         = 506;

type
  TZEEngineMode = (
    emInitializing,
    emCutScene,
    emPlayingGame,
    emMenu,
    emInventory,
    emJournal);

  TZEGameEngine = class (TZbScriptable)
  private
    // REALLY INTERNAL!
    FTicksTotal: Cardinal;
    FFramesRendered: Cardinal;
    FPSDisplay: TZEControl;
    // engine status flags
    FMode: TZEEngineMode;
    FInternalsReady: boolean;
    FInitError: integer;
    FEngineExited: boolean;
    // required info
    FBounds: TRect;
    FHostHandle: HWND;
    // tracking status fields
    FGameReady: boolean;
    FGameRunning: boolean;
    // option fields
    FGameExclusive: boolean;
    FResolution: TZEScreenResolution;
    FMusicAvailable: boolean;
    FSoundAvailable: boolean;
    FNoSound: boolean;
    // images and sprites list
    FImages: TZEImageList;
    // the windowing system
    FRootWindow: TZERootWindow;
    FUpdateThreshold: TZE_SimpleTimeTrigger;
    //
    FFileCenter: IZbFileManager;
    //
    FMusicTick: TZE_SimpleTimeTrigger;
    FCutScenes: TZECutScene;
    FMainMenu: TZEPopupMenu;
  protected
    procedure SetNoSound (bNoSound: boolean);
    procedure SetMode (AMode: TZEEngineMode);
    procedure InitializeInternals;
    procedure ShutdownInternals;
    procedure DefaultGUI;
    procedure LoadGUI;
    procedure UnloadGUI;
    procedure PerformGameProcesses;
    procedure PerformDevicesCheck;
    procedure PerformScreenRender (bCompleteRender: boolean);
    procedure PreloadImages;
    procedure SetSpriteSurface (Sprite: IZESprite);
  public
    constructor Create (ConfigFile: string); virtual;
    destructor Destroy; override;
    //
    procedure Initialize (HostHandle: HWND);
    procedure Shutdown;
    procedure Activate;
    procedure Deactivate;
    //
    function Refresh: boolean;
    procedure TerminateEngine;
    //
    procedure SetBackgroundMusic (AMusicName: string);
    procedure ClearBackgroundMusic;
    procedure PlaySound (ASoundName: string);
    //
    procedure ToggleFPSDisplay (bVisible: boolean);
    //
    property Mode: TZEEngineMode read FMode write SetMode;
    property HostHandle: HWND read FHostHandle;
    property GameReady: boolean read FGameReady;
    property GameRunning: boolean read FGameRunning;
    property GameExclusive: boolean read FGameExclusive;
    property Resolution: TZEScreenResolution read FResolution;
    //
    property RootWindow: TZERootWindow read FRootWindow;
    property MainMenu: TZEPopupMenu read FMainMenu;
    property CutScenes: TZECutScene read FCutScenes;
    property NoSound: boolean read FNoSound write SetNoSound;
    property Files: IZbFileManager read FFileCenter;
  end;

var
  GameEngine: TZEGameEngine = NIL;
  ExitOnEscape: boolean = false;

implementation

uses
  SysUtils,
  DirectShow,
  JclStrings,
  //
  ZbStrIntf,
  ZbFileUtils,
  ZbConfigManager,
  ZbScriptMaster,
  //
  ZEDXSprite,
  ZEDXAudio,
  ZEDXMusic,
  //
  ZEWSSupport,
  ZEWSDefines,
  ZEWSButtons,
  ZEWSLineEdit,
  ZEWSMisc,
  ZEWSStandard,
  //
  ZZESupport,
  ZZEGameWorld;


////////////////////////////////////////////////////////////////////
constructor TZEGameEngine.Create (ConfigFile: string);
var
  cLine: string;
begin
  FMode := emInitializing;
  FInternalsReady := false;
  FHostHandle := 0;
  FEngineExited := false;
  FGameReady := false;
  FGameRunning := false;
  FMusicAvailable := false;
  FSoundAvailable := true;
  FNoSound := false;
  //
  FBounds := Rect (0, 0, 0, 0);
  FCutScenes := NIL;
  FMainMenu := NIL;
  FRootWindow := NIL;
  FFileCenter := TZbFileManager.Create as IZbFileManager;
  //
  // create the global variables
  ConfigManager := TZbConfigManager.Create (ConfigFile);
  TileProps := TZETileProperties.Create;
  //
  // load the global settings from the configuration
  with ConfigManager do
    begin
      cLine := ReadConfigStr (REZ_DIRECTX_SECTION,
                REZ_DIRECTX_RESOLUTION, REZ_DX_RESOLUTION_DEF);
      //
      FResolution.Width := StrToInt (StrBefore (',', cLine));
        cLine := StrAfter (',', cLine);
      FResolution.Height := StrToInt (StrBefore (',', cLine));
      FResolution.Depth := StrToInt (StrAfter (',', cLine));
      //
      FGameExclusive := ReadConfigBool (REZ_DIRECTX_SECTION,
                REZ_DIRECTX_EXCLUSIVE, REZ_DIRECTX_EXCLUSIVE_DEF);
      //
    end;
  //
  FUpdateThreshold := TZE_SimpleTimeTrigger.Create (5);
  FMusicTick := TZE_SimpleTimeTrigger.Create (10000);
  //
  FTicksTotal := 0;
  FFramesRendered := 0;
  FPSDisplay := NIL;
end;

////////////////////////////////////////////////////////////////////
destructor TZEGameEngine.Destroy;
begin
  if (FGameRunning) then Deactivate;
  if (FGameReady) then Shutdown;
  //
  FFileCenter := NIL;
  //
  FreeAndNIL (FUpdateThreshold);
  FreeAndNIL (FMusicTick);
  //
  FreeAndNIL (TileProps);
  FreeAndNIL (ConfigManager);
  //
  inherited;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.SetNoSound (bNoSound: boolean);
begin
  FNoSound := bNoSound;
  ClearBackgroundMusic;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.SetMode (AMode: TZEEngineMode);
begin
  if (FMode = AMode) then Exit;
  //
  FMode := AMode;
  case FMode of
    emCutScene:
      FRootWindow.UseDesktop (DESKTOP_CUT_SCENE);
    emPlayingGame:
      FRootWindow.UseDesktop (DESKTOP_MAIN);
    emMenu:
      FRootWindow.UseDesktop (DESKTOP_MENU);
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.InitializeInternals;
begin
  if (FInternalsReady) then exit;
  //
  // initialize ALL the root devices/interfaces
  //ZbScriptMaster.Initialize;
  //ZbScriptMaster.ScriptMaster.Clear;
  ZEDXDev.InitDeviceHandlers;
  ZEWSBase.InitWindowingSystem;
  ZEWSButtons.RegisterControls;
  ZEWSDialogs.RegisterControls;
  ZEWSLineEdit.RegisterControls;
  ZEWSMisc.RegisterControls;
  ZEWSStandard.RegisterControls;
  ZEWSButtons.RegisterControls;
  //
  FInternalsReady := true;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.ShutdownInternals;
begin
  if (NOT FInternalsReady) then exit;
  //
  ZEWSBase.CloseWindowingSystem;
  ZEDXDev.CloseDeviceHandlers;
  //ZbScriptMaster.Shutdown;
  //
  FInternalsReady := false;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.DefaultGUI;
var
  Desktop: TZEDesktop;
  Control: TZEControl;
  rArea: TRect;

const
  __X   = 30;
  __Y   = 30;

begin
  //
  // fill in the menu desktop
  FMainMenu.AddMenuItem ('See Game', cmSwitchToGame);
  //FMainMenu.AddMenuItem ('Play Cut Scene', cmSwitchToCutScene);
  FMainMenu.AddMenuItem ('Exit', cmExitEngine);
  //
  Desktop := FRootWindow [DESKTOP_MENU];
  rArea := ExpandRect (Desktop.Bounds, -240, -100);
  FMainMenu.Bounds := rArea;
  //
  // fill in the game desktop
  Desktop := FRootWindow [DESKTOP_MAIN];
  //
  // create an isometric view, just so it will be there
  ViewInEditMode := true;
  rArea := ExpandRect (Desktop.LocalBounds, -17, -17);
  Inc (rArea.Top, 50);//Control.Height);
  //GameWindow := TZEGameWindow.Create (rArea);
  //GameWindow.ViewMap := GameWorld.ViewMap;
  Desktop.Insert (GameWindow);

  // VERY IMPORTANT EXIT BUTTON ***************************************
  // add the Exit button
  rArea := ExpandRect (Desktop.LocalBounds, -15, -15);
  Dec (rArea.Right, 80);
  Control := CreateControl (CC_ICON_BUTTON, rArea);
  if (Control <> NIL) then
    begin
      Desktop.Insert (Control);
      Control.SetPropertyvalue (PROP_NAME_SHOW_CAPTION, 'TRUE');
      Control.SetPropertyvalue (PROP_NAME_CAPTION, 'Main Menu');
      Control.SetPropertyvalue (PROP_NAME_FONT_NAME, 'EditorButton');
      Control.SetPropertyvalue (PROP_NAME_SPRITE_NAME, 'Grainy');
      Control.SetPropertyvalue (PROP_NAME_COMMAND, PChar (IntToStr (cmSwitchToMenu)));
    end;
  //
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.LoadGUI;
var
  Desktop: TZEDesktop;
  R: TRect;
begin
  // create the managers
  PreloadImages;
  GUIManager := TZEGUIManager.Create;
  //
  // create root window
  FRootWindow := TZERootWindow.Create (FBounds);
  FRootWindow.BackColor := $FF0000;
  FRootWindow.Font := GUIManager.Fonts ['Caption'];
  //
  // create all the default desktops
  RootWindow.AddDesktop (DESKTOP_CUT_SCENE, DESKTOP_CUT_SCENE);
  RootWindow.AddDesktop (DESKTOP_MENU, DESKTOP_MENU);
  RootWindow.AddDesktop (DESKTOP_MAIN, DESKTOP_MAIN);

  //
  // create the FramePerSecond display
  R := Rect (
    RootWindow.LocalBounds.Right - 75,
    RootWindow.LocalBounds.Top + 15,
    RootWindow.LocalBounds.Right - 15,
    RootWindow.LocalBounds.Top + 75);
  FPSDisplay := TZEText.Create (R);
  FRootWindow.Insert (FPSDisplay);
  FPSDisplay.Font := GUIManager.Fonts ['WhiteOnDark'];
  //
  // create the cut scene desktop
  Desktop := FRootWindow [DESKTOP_CUT_SCENE];
  FCutScenes := TZECutScene.Create (Desktop.LocalBounds);
  Desktop.Insert (FCutScenes);
  FCutScenes.Font := GUIManager.Fonts ['IntroFont'];
  //
  // create the menu in the menu desktop
  Desktop := FRootWindow [DESKTOP_MENU];
  FMainMenu := TZEPopupMenu.Create (Desktop.LocalBounds);
  Desktop.Insert (FMainMenu);
  FMainMenu.Font := GUIManager.Fonts ['MenuFont'];
  //
  // create the game world
  GameWorld := TZEGameWorld.Create;
  GameWorld.CreateBlankMap (20, 20);
  GameWorld.ViewMap.GridSprite := SpriteManager.CreateSprite ('Selector', 'EditGrid');
  GameWorld.ViewMap.HighlightSprite := SpriteManager.CreateSprite ('Selector', 'Normal');
  GameWorld.ViewMap.SelectionSprite := SpriteManager.CreateSprite ('Selector', 'Selector');
  //
  // call the script to create the rest of the GUI
  if (ScriptMaster.CheckHandler (PChar (SCRIPT_GAME_GUI))) then
    ScriptMaster.CallHandler (PChar (SCRIPT_GAME_GUI), Resolution.Width, Resolution.Height)
  else
    DefaultGUI;
  //
  // init mouse
  Mouse := TZEMouse.Create (FBounds);
  Mouse.Cursor := SpriteManager.CreateSprite ('MouseDevice', 'Default');
  Mouse.Visible := true;
  Mouse.Center;
  //
  // by default, begin in the game screen!
  Mode := emPlayingGame;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.UnloadGUI;
begin
  GameWindow := NIL;
  FPSDisplay := NIL;
  //
  if (FRootWindow <> NIL) then begin
    FRootWindow.Free;
    FRootWindow := NIL;
  end;
  //
  if (Mouse <> NIL) then begin
    Mouse.Free;
    Mouse := NIL;
  end;
  //
  if (GUIManager <> NIL) then
    begin
      GUIManager.Free;
      GUIManager := NIL;
    end;
  //
  if (GameWorld <> NIL) then  begin
    GameWorld.Free;
    GameWorld := NIL;
  end;
  //
  FreeAndNIL (FImages);
  GlobalSpritePostProcessor := NIL;
  SpriteManager := NIL;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.PerformGameProcesses;
begin
  try
    GameWorld.PerformUpdate (GlobalElapsedTicks);
  except
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.PerformDevicesCheck;
var
  Event: TZEEvent;
  CDest: TZEControl;
  cAction: string;
  MusicCurrent, MusicEnd: int64;
begin
  // process internal events first
  Event := EventQueue.PopEvent;
  while (Event.Event <> evDONE) do
    begin
      if (Event.Event = evCOMMAND) then
        begin
          case Event.Command of
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
            cmGlobalCommandPerformAction:
              begin
                CDest := TZEControl (Event.pData);
                try
                  cAction := CDest.GetPropertyValue (PROP_NAME_ACTION_NAME);
                  ScriptMaster.CallHandler (PChar (cAction),
                          integer (Event.pData), Event.Command);
                except
                end;
              end;
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
            cmExitEngine:
              TerminateEngine;
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
            cmCutSceneEnds:
              begin
                Mode := emMenu;
                CutScenes.StopSequence;
                ClearBackgroundMusic;
              end;
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
            cmSwitchToMenu, cmSwitchToGame:
              begin
                if (Event.Command = cmSwitchToGame) then
                  Mode := emPlayingGame
                  else Mode := emMenu;
                //
                if (ScriptMaster.CheckHandler (PChar (SCRIPT_USER_EVENTS))) then
                  ScriptMaster.CallHandler (PChar (SCRIPT_USER_EVENTS),
                    Event.Command, integer (Event.pData));
              end;
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
            cmSwitchToCutScene:
              begin
                Mode := emCutScene;
                CutScenes.BeginSequence;
              end;
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
            cmTogglePause:
              GameWorld.Paused := NOT GameWorld.Paused;
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
            else
              begin
                try
                  if (ScriptMaster.CheckHandler (PChar (SCRIPT_USER_EVENTS))) then
                    ScriptMaster.CallHandler (PChar (SCRIPT_USER_EVENTS),
                      Event.Command, integer (Event.pData));
                except
                end;
              end;
            // -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
          end;
        end;
      //
      if (Event.Event <> evDONE) then
        FRootWindow.HandleEvent (Event);
      //
      Event := EventQueue.PopEvent;
    end;

  // check the keyboard
  DI8GetKeyboardState;
  Event.Event := evKeyboard;
  Event.cKey := KeyboardQueue.GetChar;
  while (Event.cKey <> #0) do
    begin
      if (ExitOnEscape) AND (Event.cKey = #27) then begin
        EventQueue.InsertEvent (cmExitEngine);
        break;
      end else begin
        FRootWindow.HandleEvent (Event);
        Event.cKey := KeyboardQueue.GetChar;
      end;
    end;

  // check the mouse
  Mouse.GetEvent (Event);
  while (Event.Event <> evDONE) do
    begin
      //try
      FRootWindow.HandleEvent (Event);
      //except on E: Exception do DebugPrint ('Exception FRootWindow.HandleEvent(): ' + E.Message); end;
      Mouse.GetEvent (Event);
    end;

  // check the background music
  if ((MusicMngr <> NIL) AND (MusicMngr.Playing)) then
    begin
      if (FMusicTick.CheckResetTrigger (GlobalElapsedTicks)) then
        begin
          MusicMngr.MediaSeeking.GetPositions (MusicCurrent, MusicEnd);
          if (MusicCurrent = MusicEnd) then
            begin
              MusicCurrent := 0;
              MusicMngr.MediaSeeking.SetPositions (
                MusicCurrent, AM_SEEKING_AbsolutePositioning,
                MusicCurrent, AM_SEEKING_NoPositioning);
              //
            end;
        end;
    end;
  //
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.PerformScreenRender (bCompleteRender: boolean);
begin
  FRootWindow.Update (DX7Engine.BackBuffer, GlobalElapsedTicks);
  Mouse.Animate (GlobalElapsedTicks);
  Mouse.DrawPointer;
  DX7Engine.Flip;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.PreloadImages;
var
  cImageFolder: string;
  cImageConfig: string;
  cSpriteConfig: string;
  cSpriteList: string;
begin
  //
  with ConfigManager do
    begin
      //
      // create the image list, use configuration file to initialize
      cImageFolder := ReadConfigStr (REZ_D_MNGR_SECTION,
                      REZ_DM_IMAGE_FOLDER, REZ_DM_IMAGE_FOLDER_DEF);
      cImageConfig := ReadConfigStr (REZ_D_MNGR_SECTION,
                      REZ_DM_IMAGE_CONFIG, REZ_DM_IMAGE_CONFIG_DEF);
      FImages := TZEImageList.Create (cImageFolder, cImageConfig);
      //
      // read config some more and create the sprite center
      cSpriteConfig:= ReadConfigStr (REZ_D_MNGR_SECTION,
                      REZ_DM_SPRITE_CONFIG, REZ_DM_SPRITE_CONFIG_DEF);
      cSpriteList  := ReadConfigStr (REZ_D_MNGR_SECTION,
                      REZ_DM_SPRITE_LIST, REZ_DM_SPRITE_LIST_DEF);
      SpriteManager := TZESpriteCenter.Create (NIL{FImages},
              cSpriteList, cSpriteConfig) as IZESpriteCenter;
    end;
  //
  GlobalSpritePostProcessor := SetSpriteSurface;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.SetSpriteSurface (Sprite: IZESprite);
begin
  if (Sprite <> NIL) then Sprite.SetDestSurface (Pointer (DX7Engine.BackBuffer));
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.Initialize (HostHandle: HWND);
var
  bSuccess: boolean;
begin
  Shutdown;
  InitializeInternals;
  if (NOT FInternalsReady) then exit;
  //
  FGameReady := false;
  FGameRunning := false;
  //
  FHostHandle := HostHandle;
  if (FHostHandle = 0) then exit;
  //
  // Initialize DirectInput.
  FInitError := DI8Init (FHostHandle, hInstance);
  if (FInitError <> ERROR_NO_ERROR) then exit;
  //
  // Initialize DirectMusic.
  FMusicAvailable := DM8Init(FHostHandle, true);
  //
  // Initialize the DirectX Engine
  DX7Engine := TZEDXEngine.Create (FHostHandle);
  with FResolution do
    bSuccess := DX7Engine.Initialize (FGameExclusive, Width, Height, Depth);
  //
  // if it failed to initialize, record what error it got
  // and discard it before exiting
  if (NOT bSuccess) then begin
    FInitError := DX7Engine.StartupError;
    FreeAndNIL (DX7Engine);
    Exit;
  end;
  //
  FBounds := Rect (0, 0, FResolution.Width, FResolution.Height);
  //
  // setup the audio first, if necessary
  if (FMusicAvailable) then
    with ConfigManager do
      MusicMngr := TZEMusicManager.Create (
        ReadConfigStr (REZ_PATH_SECTION, REZ_MUSIC_PATH, REZ_MUSIC_PATH_DEF),
        ReadConfigSection (REZ_MUSIC_SECTION, sroNamesAndValues));
  //
  if (FSoundAvailable) then
    with ConfigManager do
      SoundFXMngr := TZESoundEffectsManager.Create (
        ReadConfigStr (REZ_PATH_SECTION, REZ_SND_EFX_PATH, REZ_SND_EFX_PATH_DEF),
        ReadConfigSection (REZ_SOUND_EFFECTS_SECTION, sroNamesAndValues));
  //
  // prepare the graphical user interface
  LoadGUI;
  //
  // initialize flag vars
  FGameReady := true;
  FGameRunning := false;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.Shutdown;
begin
  if (NOT FGameReady) then exit;
  if (FGameRunning) then Deactivate;
  //
  // unload the user interface objects
  UnloadGUI;
  //
  // free the sound interfaces
  if (MusicMngr <> NIL) then
    begin
      MusicMngr.Free;
      MusicMngr := NIL;
    end;
  //
  if (SoundFXMngr <> NIL) then
    begin
      SoundFXMngr.Free;
      SoundFXMngr := NIL;
    end;
  //
  DM8Close;
  DI8Close;
  if (DX7Engine <> NIL) then
    begin
      DX7Engine.Free;
      DX7Engine := NIL;
    end;
  //
  FHostHandle := 0;
  ShutdownInternals;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.Activate;
begin
  if (FGameReady AND NOT (FGameRunning)) then begin
    //
    if (DX7Engine.BackBuffer.IsLost <> 0) then
      DX7Engine.DD7.RestoreAllSurfaces;
    //
    if (FGameExclusive) then begin
      DI8MouseControl(true);
      DI8KeyboardControl(true);
    end;
    //
    FGameRunning := true;
  end;
end;


////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.Deactivate;
begin
  if (FGameRunning) then FGameRunning := false;
end;

////////////////////////////////////////////////////////////////////
function TZEGameEngine.Refresh: boolean;
var
  bDoRender: boolean;
begin
  if (FGameReady AND FGameRunning) then begin
    //
    // restore everything, in case they were lost
    if (DX7Engine.BackBuffer.IsLost <> 0) then begin
      DX7Engine.DD7.RestoreAllSurfaces;
      if (FGameExclusive) then begin
        DI8MouseControl(true);
        DI8KeyboardControl(true);
      end;
      //
    end;
    //
    UpdateGlobalCounter;
    //
    Inc (FTicksTotal, GlobalElapsedTicks);
    if (FTicksTotal >= 1000) then begin
      // display it first though!
      if (FPSDisplay <> NIL) then
        FPSDisplay.Caption := IntToStr (FFramesRendered);
      FFramesRendered := 0;
      Dec (FTicksTotal, 1000);
    end;
    // perform everything else
    PerformDevicesCheck;
    bDoRender := FUpdateThreshold.CheckResetTrigger (GlobalElapsedTicks);
    if (NOT FEngineExited) then begin
      if (Mode = emPlayingGame) then PerformGameProcesses;
      PerformScreenRender (bDoRender);
      Inc (FFramesRendered);
    end;
    //
  end;
  //
  Result := FEngineExited;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.TerminateEngine;
begin
  FEngineExited := true;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.SetBackgroundMusic (AMusicName: string);
begin
  if (NOT NoSound) AND (MusicMngr <> NIL) then begin
    MusicMngr.LoadFile (AMusicName);
    MusicMngr.Play;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.ClearBackgroundMusic;
begin
  if (MusicMngr <> NIL) then MusicMngr.Stop;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.PlaySound (ASoundName: string);
var
  SoundEFX: TZESoundSegment;
begin
  if (NOT NoSound) AND (SoundFXMngr <> NIL) then begin
    SoundEFX := SoundFXMngr [ASoundName];
    if (SoundEFX <> NIL) then SoundEFX.Play;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameEngine.ToggleFPSDisplay (bVisible: boolean);
begin
  if (bVisible) then
    FPSDisplay.Show
    else FPSDisplay.Hide;
end;




end.

