{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZECore.PAS
              The Core Game Engine class
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Core/ZZECore.pas,v 1.4 2002/12/18 08:10:17 Vij Exp $
  $Log: ZZECore.pas,v $
  Revision 1.4  2002/12/18 08:10:17  Vij
  Modified Show[Msg/Input]Box for more flexibility.  Added PreloadDataVolume.

  Revision 1.3  2002/11/02 06:34:14  Vij
  added dialog and cut-scene support.
  implemented new virtual procedure LoadData()

  Revision 1.2  2002/10/01 12:26:54  Vij
  Removed global Map and EntityLoader.  Created Engine properties to
  manage entities (EntityManager) and SAMMs (SAMMManager).  Re-added
  the code to support cutscenes.  Added code to update the game world
  every refresh call.

  Revision 1.1.1.1  2002/09/11 21:11:42  Vij
  Starting Version Control


 ============================================================================}

unit ZZECore;

interface

uses
  Types,
  ZblIEvents,
  ZbCallbacks,
  //
  ZEDXFramework,
  ZEWSBase,
  ZEWSDialogs,
  //
  ZZConstants,
  ZZEGameScreens,
  ZZEViewMap,
  ZZESAMM,
  ZZEWorld;

type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEDialogCloser = class
  public
    procedure EndModalCatcher (AControl: TZEControl; lParam: integer);
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGameCore = class (TZEFrameworkDX)
  private
    FWinSysRoot: TZERootWindow;
    FWinFPS: TZEControl;
    FSAMMManager: TZESAMMManager;
    FEntityManager: TZEEntityManager;
    FCutScene: TZECutScene;
    FPrevDesktop: TZEDesktop;
    FDialogCloser: TZEDialogCloser;
  protected
    procedure LoadSettings; override;
    procedure LoadData; override;
    procedure CleanupSettings; override;
    function PreInitialize: boolean; override;
    function PostInitialize: boolean; override;
    procedure PreShutdown; override;
    procedure PostShutdown; override;
    //
    procedure HandleEvent (Event: TZbEvent); override;
    procedure RenderScene; override;
    procedure PerformProcessing; override;
    //
    procedure ShowFPS; override;
    function IsFPSShown: boolean;
    procedure ToggleFPS (bVisible: boolean);
    //
  public
    function Refresh: boolean; override;
    //
    procedure RunDialog (Dialog: TZEControl);
    procedure ShowMsgBox (cMessage: string; SendCommand: Integer = 0); overload;
    procedure ShowMsgBox (cMessage: string; rBounds: TRect;
      SendCommand: Integer = 0); overload;
    procedure ShowInputBox (cPrompt: string; iCommand: integer;
      ANoCancel: boolean = FALSE); overload;
    procedure ShowInputBox (cPrompt: string; iCommand: integer;
      rBounds: TRect; ANoCancel: boolean = FALSE); overload;
    //
    procedure ShowTextDialog (AFileName: PChar;
      AWidth: Integer = 400; AHeight: Integer = 400;
      AFontName: PChar = NIL);
    //
    procedure MoveFPSDisplayTo (WhereTo: TPoint);
    procedure PlayCutScene (ACutSceneFile: string);
    procedure PreloadDataVolume (cDataFileName: String);
    //
    property DialogCloser: TZEDialogCloser read FDialogCloser;
    property SAMMManager: TZESAMMManager read FSAMMManager;
    property EntityManager: TZEEntityManager read FEntityManager;
    property WinSysRoot: TZERootWindow read FWinSysRoot;
    property FPSVisible: boolean read IsFPSShown write ToggleFPS;
  end;


var
  CoreEngine: TZEGameCore = NIL;

const
  MsgBoxBounds: TRect = (Left:0; Top:0; Right: 400; Bottom: 120);

  function CoreEngineCreator: LongBool;
  function SetupEngineCreator (Config: PChar; UICB, HECB: TZbCallbackFunction): LongBool;

implementation

uses
  SysUtils,
  StrUtils,
  Classes,
  JclStrings,
  //
  ZblIWinWrap,
  ZblAppFrame,
  //
  ZbConfigManager,
  ZbStrIntf,
  ZbDebug,
  //
  ZEDXCore,
  ZEDXAudio,
  ZEDXSpriteIntf,
  ZEDXSprite,
  //
  ZEWSDefines,
  ZEWSButtons,
  ZEWSLineEdit,
  ZEWSMisc,
  ZEWSSupport,
  ZEWSStandard,
  //
  ZZEWorldIntf,
  ZZEWorldImpl,
  //
  ZZESupport;


{ TZEDialogCloser }

//////////////////////////////////////////////////////////////////////////
procedure TZEDialogCloser.EndModalCatcher (AControl: TZEControl; lParam: integer);
begin
  if (AControl <> NIL) then begin
    AControl.Hide;
    g_EventManager.Commands.Insert (cmRemoveDialog, 0, Integer (AControl));
  end;
end;


{ TZEGameCore }

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.LoadSettings;
var
  cLine: string;
begin
  // load the tile properties container
  TileProps := TZETileProperties.Create;
  // load the screen settings
  with ConfigManager do begin
    cLine := ReadConfigStr (REZ_DIRECTX_SECTION,
      REZ_DIRECTX_RESOLUTION, REZ_DX_RESOLUTION_DEF);
    //
    IScreenWidth := StrToInt (StrBefore (',', cLine));
      cLine := StrAfter (',', cLine);
    IScreenHeight := StrToInt (StrBefore (',', cLine));
    IScreenDepth := StrToInt (StrAfter (',', cLine));
    //
    IExclusive := ReadConfigBool (REZ_DIRECTX_SECTION,
      REZ_DIRECTX_EXCLUSIVE, REZ_DIRECTX_EXCLUSIVE_DEF);
    //
  end;
  // etcetera
  FWinSysRoot := NIL;
  FWinFPS := NIL;
  FCutScene := NIL;
  FPrevDesktop := NIL;
  FDialogCloser := TZEDialogCloser.Create;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.LoadData;
var
  cImageVolume: string;
  SList: IZbEnumStringList;
begin
  with ConfigManager do begin
    SList := ConfigManager.ReadConfigSection (REZ_DATA_SECTION);
    try
      cImageVolume := SList.First;
      while (cImageVolume <> '') do begin
        PreloadDataVolume (cImageVolume);
        cImageVolume := SList.Next;
      end;
    finally
    end;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.CleanupSettings;
begin
  FDialogCloser.Free;
end;

////////////////////////////////////////////////////////////////////
function TZEGameCore.PreInitialize: boolean;
begin
  ZEWSBase.InitWindowingSystem;
  ZEWSButtons.RegisterControls;
  ZEWSDialogs.RegisterControls;
  ZEWSLineEdit.RegisterControls;
  ZEWSMisc.RegisterControls;
  ZEWSStandard.RegisterControls;
  ZEWSButtons.RegisterControls;
  //
  Result := TRUE;
end;

////////////////////////////////////////////////////////////////////
function TZEGameCore.PostInitialize: boolean;
var
  Desktop: TZEDesktop;
begin
  Music := TRUE;
  //
  // load the music/sound files
  with ConfigManager do begin

    //
    g_MusicMngr.LoadFileList (
      ReadConfigStr (REZ_PATH_SECTION, REZ_MUSIC_PATH, REZ_MUSIC_PATH_DEF),
      ReadConfigSection (REZ_MUSIC_SECTION, sroNamesAndValues));

    //
    g_SoundFXMngr.LoadFileList (
      ReadConfigStr (REZ_PATH_SECTION, REZ_SND_EFX_PATH, REZ_SND_EFX_PATH_DEF),
      ReadConfigSection (REZ_SOUND_EFFECTS_SECTION, sroNamesAndValues));
  end;
  //
  // create the GUI font and color manager
  GUIManager := TZEGUIManager.Create (SpriteFactory);
  //
  // create root window
  FWinSysRoot := TZERootWindow.Create (Bounds);
  FWinSysRoot.BackColor := $FF0000;
  FWinSysRoot.Font := GUIManager ['Default'];
  // add the default desktops
  FWinSysRoot.AddDesktop (DESKTOP_CUT_SCENE, DESKTOP_CUT_SCENE);
  FWinSysRoot.AddDesktop (DESKTOP_MENU, DESKTOP_MENU);
  FWinSysRoot.AddDesktop (DESKTOP_MAIN, DESKTOP_MAIN);
  FWinSysRoot.UseDesktop (DESKTOP_MAIN);
  //
  // create the cut scene control
  Desktop := FWinSysRoot.GetDesktop (DESKTOP_CUT_SCENE);
  FCutScene := TZECutScene.Create (Desktop.LocalBounds);
  Desktop.Insert (FCutScene);
  //
  // initialize the game object managers
  TerrainManager := TZETerrainManager.Create (
    ConfigManager.ReadConfigSection (REZ_TERRAIN_SECTION,
    sroNamesAndValues)) as IZETerrainManager;
  WallManager := TZEWallManager.Create (
    ConfigManager.ReadConfigSection (REZ_WALLS_SECTION,
    sroNamesAndValues)) as IZEWallManager;
  FloorManager := TZEFloorManager.Create as IZEFloorManager;
  FSAMMManager := TZESAMMManager.Create;
  FEntityManager := TZEEntityManager.Create;
  //
  // load the special sprites
  g_SpecialSprites := TZESpecialSprites.Create;
  with g_SpecialSprites, SpriteFactory do begin
    Grid := CreateSprite (SPRITE_FAMILY_SELECTORS, SPRITE_MAP_GRID);
    BlockedGrid := CreateSprite (SPRITE_FAMILY_SELECTORS, SPRITE_MAP_BLOCKED_GRID);
    Selection := CreateSprite (SPRITE_FAMILY_SELECTORS, SPRITE_MAP_SELECTOR);
    Highlight := CreateSprite (SPRITE_FAMILY_SELECTORS, SPRITE_MAP_HIGHLIGHT);
    Transition := CreateSprite (SPRITE_FAMILY_SELECTORS, SPRITE_MAP_TRANSITION);
    Start := CreateSprite (SPRITE_FAMILY_SELECTORS, SPRITE_MAP_STARTPOINT);
  end;
  //
  // create the world to contain the game environment
  GameWorld := TZEGameWorld.Create;
  //
  // init and show the FPS display
  FWinFPS := TZEText.Create (Rect (10, 10, 180, 100));
  FWinSysRoot.Insert (FWinFPS);
  //
  // invoke the callback that generates the UI
  Callbacks.Invoke (SCRIPT_GAME_GUI, ScreenWidth, ScreenHeight);
  //
  // set the mouse cursor, and show it
  MouseCursor.Cursor := SpriteFactory.CreateSprite ('MouseDevice', 'Default');
  //MouseDev.SetVisible (TRUE);

  //
  TraceLn ('OK');
  Result := TRUE;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.PreShutdown;
begin
  // cleanup the world
  GameWorld.Free;
  GameWorld := NIL;
  // discard the other special sprites
  g_SpecialSprites.Free;
  g_SpecialSprites := NIL;
  //
  // discard the object managers
  FSAMMManager.Free;
  FEntityManager.Free;
  WallManager := NIL;
  FloorManager := NIL;
  TerrainManager := NIL;
  //
  // discard the windowing system
  FWinSysRoot.Free;
  FWinSysRoot := NIL;
  FWinFPS := NIL;
  //
  GUIManager.Free;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.PostShutdown;
begin
  ZEWSBase.CloseWindowingSystem;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.HandleEvent (Event: TZbEvent);
begin
  inherited;
  // pass it up to the windowing system first
  if (Event.m_Event <> evDONE) then WinSysRoot.HandleEvent (Event);
  // act on events that interest us...
  if (Event.m_Event = evCommand) then begin
    case Event.m_Command of
      cmCutSceneEnds, cmCutSceneHasLooped: begin
        FCutScene.StopSequence;
        if (FPrevDesktop <> NIL) then FWinSysRoot.UseDesktop (FPrevDesktop);
        FPrevDesktop := NIL;
        g_DXFramework.ClearEvent (Event);
      end;
      //
      cmRemoveDialog: begin
        if (Event.m_pData <> NIL) then
          try TZEControl (Event.m_pData).Free; except end;
          //
        g_DXFramework.ClearEvent (Event);
        g_EventManager.Commands.Insert (cmDialogClosed, 0, 0);
      end;
    end;
  end;
  //
  // pass it to the user next...
  if (Event.m_Event <> evDONE) then
    Callbacks.Invoke (SCRIPT_USER_EVENTS, Event.m_Command, Event.m_lData);
  {if (Event.m_Event <> evDONE) AND (ScriptMaster.CheckHandler (PChar (SCRIPT_USER_EVENTS))) then
    ScriptMaster.CallHandler (PChar (SCRIPT_USER_EVENTS), Event.m_Command, Event.m_lData);}
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.RenderScene;
begin
  WinSysRoot.Update (DX7Engine.BackBuffer, g_ElapsedTicks);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.PerformProcessing;
begin
  GameWorld.PerformUpdate (g_ElapsedTicks);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.PlayCutScene (ACutSceneFile: string);
begin
  if (FCutScene = NIL) OR (NOT FileExists (ACutSceneFile)) then Exit;
  // record the desktop to return to, if any
  if (FWinSysRoot.ActiveDesktop = NIL) OR (FWinSysRoot.ActiveDesktop.Name = DESKTOP_CUT_SCENE) then
    FPrevDesktop := NIL
    else FPrevDesktop := FWinSysRoot.ActiveDesktop;
  //
  FWinSysRoot.UseDesktop (DESKTOP_CUT_SCENE);
  FCutScene.LoadCutSceneFile (ACutSceneFile);
  FCutScene.BeginSequence;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.PreloadDataVolume (cDataFileName: String);
var
  StrList: TStrings;
begin
  StrList := TStringList.Create;
  try
    LoadImageVolume (cDataFileName, StrList);
    SpriteFactory.LoadSprList (TZbEnumStringList.Create (StrList) as IZbEnumStringList);
  finally
    StrList.Free;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.ShowFPS;
begin
  if (FWinFPS <> NIL) then FWinFPS.Caption := IntToStr (FramesRendered) + ' FPS';
end;

////////////////////////////////////////////////////////////////////
function TZEGameCore.IsFPSShown: boolean;
begin
  Result := (FWinFPS <> NIL) AND (FWinFPS.GetState (stVisible));
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.ToggleFPS (bVisible: boolean);
begin
  if (FWinFPS <> NIL) then FWinFPS.SetState (stVisible, bVisible);
end;

////////////////////////////////////////////////////////////////////
function TZEGameCore.Refresh: boolean;
begin
  Result := inherited Refresh;
  // invoke the callback for game updates
  if (Ready) AND (Running) AND (NOT Result) then
    Callbacks.Invoke (SCRIPT_GAME_IDLE, Integer (g_ElapsedTicks), 0);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.RunDialog (Dialog: TZEControl);
begin
  if (Dialog = NIL) then Exit;
  if (WinSysRoot.ActiveDesktop = NIL) then begin
    Dialog.Free;
  end else begin
    WinSysRoot.ActiveDesktop.Insert (Dialog);
    Dialog.Hide;
    Dialog.BeginModal (FDialogCloser.EndModalCatcher);
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.ShowMsgBox (cMessage: string; SendCommand: Integer);
begin
  ShowMsgBox (cMessage, MsgBoxBounds, SendCommand);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.ShowMsgBox (cMessage: string; rBounds: TRect; SendCommand: Integer);
begin
  if (WinSysRoot.ActiveDesktop = NIL) then Exit;
  RunDialog (CreateMessageBox (rBounds, cMessage, SendCommand));
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.ShowInputBox (cPrompt: string;
  iCommand: integer; ANoCancel: boolean);
begin
  ShowInputBox (cPrompt, iCommand, MsgBoxBounds, ANoCancel);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.ShowInputBox (cPrompt: string; iCommand: integer;
  rBounds: TRect; ANoCancel: boolean);
begin
  if (WinSysRoot.ActiveDesktop = NIL) then Exit;
  RunDialog (CreateInputBox (MsgBoxBounds, cPrompt, iCommand, ANoCancel));
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.ShowTextDialog (AFileName: PChar;
  AWidth, AHeight: Integer; AFontName: PChar);
var
  TD: TZEControl;
begin
  if (AFileName = NIL) then Exit;
  //
  TD := CreateControl (CC_TEXT_DIALOG, Rect (0, 0, AWidth, AHeight));
  if (TD = NIL) then Exit;
  //
  TD.SetPropertyValue (PROP_NAME_FILE_TO_LOAD, String (AFileName));
  if (AFontName <> NIL) then
    TD.SetPropertyValue (PROP_NAME_FONT_NAME, String (AFontName));
  //
  RunDialog (TD);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGameCore.MoveFPSDisplayTo (WhereTo: TPoint);
begin
  if (FWinFPS <> NIL) then FWinFPS.MoveTo (WhereTo);
end;

////////////////////////////////////////////////////////////////////
var
  l_Config: PChar = NIL;
  l_UICB: TZbCallbackFunction = NIL;
  l_HECB: TZbCallbackFunction = NIL;

////////////////////////////////////////////////////////////////////
function CoreEngineCreator: LongBool;
begin
  Callbacks.Add (SCRIPT_GAME_GUI, l_UICB);
  Callbacks.Add (SCRIPT_USER_EVENTS, l_HECB);
  //
  try
    CoreEngine := TZEGameCore.Create (String (l_Config));
    CoreEngine.Initialize (g_AppWrap.GetHWND, g_AppWrap.GetInstance);
  except
    CoreEngine := NIL;
  end;
  //
  Result := (CoreEngine <> NIL);
end;

////////////////////////////////////////////////////////////////////
function SetupEngineCreator (Config: PChar; UICB, HECB: TZbCallbackFunction): LongBool;
begin
  l_Config := StrNew (Config);
  l_UICB := UICB;
  l_HECB := HECB;
  g_EngineMaker := CoreEngineCreator;
  Result := TRUE;
end;


initialization

finalization
  if (l_Config <> NIL) then begin
    StrDispose (l_Config);
    l_Config := NIL;
  end;

end.

