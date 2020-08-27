unit ZZEGameScreens;

interface

uses
  Windows,
  Classes,
  //
  ZblIEvents,
  ZEWSBase,
  ZEWSDefines,
  ZEWSStandard,
  ZEWSDialogs,
  ZZConstants;

const
  cmGameScreenCommandBase     = 450;

  cmCutSceneLoaded            = cmGameScreenCommandBase + 0;
  cmCutSceneBegins            = cmGameScreenCommandBase + 1;
  cmCutSceneHasLooped         = cmGameScreenCommandBase + 2;
  cmCutSceneEnds              = cmGameScreenCommandBase + 3;

type
  TZECutScene = class (TZEDecorImage)
  private
    FScenes: TList;
    FCurrentScene: integer;
    FLoopCount: integer;
    FRunning: boolean;
  protected
    procedure LoadCurrentScene;
    procedure AnimateUpdate; override;
    function HasLooped: boolean;
    //
    property Scenes: TList read FScenes;
    property CurrentScene: integer read FCurrentScene write FCurrentScene;
    property LoopCount: integer read FLoopCount write FLoopCount;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure Paint; override;
    procedure MouseLeftClick (var Event: TZbEvent); override;
    //
    procedure LoadCutSceneFile (AFile: string);
    procedure ResetSequence;
    procedure BeginSequence;
    procedure StopSequence;
    //
    property Looped: boolean read HasLooped;
  end;

  TZEPopupMenu = class (TZEDesktop)
  private
    FMarginLeft: integer;
    FMarginRight: integer;
    FVertSpacing: integer;
    FItems: TList;
  protected
    procedure RepositionButtons;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    procedure ChangeBounds (rBounds: TRect); override;
    //
    procedure AddMenuItem (ACaption: string; ACommand: integer;
      AButtonName: string = CC_STANDARD_BUTTON; FontName: string = 'Button');
  end;


implementation

uses
  SysUtils,
  ZbIniFileEx,
  ZEWSSupport,
  ZEDXFramework,
  ZZECore;


//////////////////////////////////////////////////////////////////////////
const
  ZZE_CSI_MAIN_SECTION                  = 'MAIN';
  ZZE_CSI_Var_Image                     = 'Image';
  ZZE_CSI_Var_ImageOption               = 'ImageOption';
    ZZE_CSI_Var_ImageOption_NONE        = 'NONE';
    ZZE_CSI_Var_ImageOption_CLEAR       = 'CLEAR';
    ZZE_CSI_Var_ImageOption_REPLACE     = 'REPLACE';
  ZZE_CSI_Var_Caption                   = 'Caption';
  ZZE_CSI_Var_Delay                     = 'Delay';
  ZZE_CSI_Var_Music                     = 'Music';
  ZZE_CSI_Var_MusicOption               = 'MusicOption';
    ZZE_CSI_Var_MusicOption_NONE        = 'NONE';
    ZZE_CSI_Var_MusicOption_STOP        = 'STOP';
    ZZE_CSI_Var_MusicOption_PLAY        = 'PLAY';
  ZZE_CSI_Var_SoundEffect               = 'SoundEffect';
  ZZE_CSI_Var_NextSection               = 'Next';


//////////////////////////////////////////////////////////////////////////
type
  TZEMusicOption = (moNone, moStop, moPlay);
  TZEImageOption = (ioNone, ioClear, ioReplace, ioAdd {this one may not be supported});

  PZECutSceneInfo = ^TZECutSceneInfo;
  TZECutSceneInfo = record
    ImageFlag: TZEImageOption;
    PSpriteName: PChar;
    PCaptionText: PChar;
    dwDelay: Cardinal;
    //
    MusicFlag: TZEMusicOption;
    PMusic: PChar;
    PSoundEffect: PChar;
  end;


//////////////////////////////////////////////////////////////////////////
function ZZE_CSI_Create (ASpriteFlag: TZEImageOption; ASpriteName, ACaptionText:
  string; ADelay: Cardinal; AMusicFlag: TZEMusicOption;
  AMusic, ASoundEffect: string): PZECutSceneInfo;
var
  CSI: PZECutSceneInfo;
begin
  New (CSI);
  if (CSI <> NIL) then
    begin
      ZeroMemory (CSI, SizeOf (TZECutSceneInfo));
      CSI.ImageFlag := ASpriteFlag;
      if (ASpriteName <> '') then CSI.PSpriteName := StrNew (PChar (ASpriteName));
      if (ACaptionText <> '') then CSI.PCaptionText := StrNew (PChar (ACaptionText));
      CSI.dwDelay := ADelay;
      CSI.MusicFlag := AMusicFlag;
      if (AMusic <> '') then CSI.PMusic := StrNew (PChar (AMusic));
      if (ASoundEffect <> '') then CSI.PSoundEffect := StrNew (PChar (ASoundEffect));
    end;
  //
  Result := CSI;
end;

//////////////////////////////////////////////////////////////////////////
procedure ZZE_CSI_Destroy (CSI: PZECutSceneInfo);
begin
  if (CSI = NIL) then Exit;
  //
  if (CSI.PSpriteName <> NIL) then StrDispose (CSI.PSpriteName);
  if (CSI.PCaptionText <> NIL) then StrDispose (CSI.PCaptionText);
  if (CSI.PMusic <> NIL) then StrDispose (CSI.PMusic);
  if (CSI.PSoundEffect <> NIL) then StrDispose (CSI.PSoundEffect);
  Dispose (CSI);
end;

//////////////////////////////////////////////////////////////////////////
function ZZE_CSI_LoadCutScenes (Source: TZbIniFileEx): TList; overload;
var
  SceneList: TList;
  CSI: PZECutSceneInfo;
  //
  cSection: string;
  cSpriteName, cCaptionText: string;
  cMusic, cSoundEffect: string;
  optMusic: TZEMusicOption;
  optImage: TZEImageOption;
  dwDelay: Cardinal;

  // +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
  function ImageOptTextToValue (cOption: string): TZEImageOption;
  begin
    if (cOption = ZZE_CSI_Var_ImageOption_CLEAR) then
      Result := ioClear
    else if (cOption = ZZE_CSI_Var_ImageOption_REPLACE) then
      Result := ioReplace
    else
      Result := ioNone;
  end;

  // +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
  function MusicOptTextToValue (cOption: string): TZEMusicOption;
  begin
    if (cOption = ZZE_CSI_Var_MusicOption_STOP) then
      Result := moStop
    else if (cOption = ZZE_CSI_Var_MusicOption_PLAY) then
      Result := moPlay
    else
      Result := moNone;
  end;

begin
  Result := NIL;
  if (Source = NIL) then Exit;
  //
  SceneList := TList.Create;
  if (SceneList = NIL) then Exit;
  //
  cSection := ZZE_CSI_MAIN_SECTION;
  while ((cSection <> '') AND (Source.SectionExists (cSection))) do begin
    with Source do begin
      cSpriteName := ReadString (cSection, ZZE_CSI_Var_Image, '');
      optImage := ImageOptTextToValue (
        ReadString (cSection, ZZE_CSI_Var_ImageOption, ''));
      if (cSpriteName <> '') then optImage := ioReplace;
      //
      cCaptionText := ReadString (cSection, ZZE_CSI_Var_Caption, '');
      dwDelay := ReadInteger (cSection, ZZE_CSI_Var_Delay, 0);
      //
      cMusic := ReadString (cSection, ZZE_CSI_Var_Music, '');
      optMusic := MusicOptTextToValue (
        ReadString (cSection, ZZE_CSI_Var_MusicOption, ''));
      if (cMusic <> '') then optMusic := moPlay;
      //
      cSoundEffect := ReadString (cSection, ZZE_CSI_Var_SoundEffect, '');
      //
      cSection := ReadString (cSection, ZZE_CSI_Var_NextSection, '');
      //
      // process the data just read, add to list if OK
      CSI := ZZE_CSI_Create (optImage, cSpriteName, cCaptionText,
        dwDelay, optMusic, cMusic, cSoundEffect);
      if (CSI <> NIL) then
        SceneList.Add (Pointer (CSI));
    end;
  end;
  //
  if (SceneList.Count = 0) then FreeAndNIL (SceneList);
  Result := SceneList;
end;

//////////////////////////////////////////////////////////////////////////
function ZZE_CSI_LoadCutScenes (SourceFile: string): TList; overload;
begin
  if (FileExists (SourceFile)) then
    Result := ZZE_CSI_LoadCutScenes (TZbIniFileEx.Create (SourceFile))
    else Result := NIL;
end;


//////////////////////////////////////////////////////////////////////////
procedure ZZE_CSI_UnloadCutScenes (Scenes: TList);
var
  iIndex: integer;
begin
  if (Scenes = NIL) then Exit;
  //
  for iIndex := 0 to Pred (Scenes.Count) do begin
    ZZE_CSI_Destroy (PZECutSceneInfo (Scenes [iIndex]));
    Scenes [iIndex] := NIL;
  end;
end;

{ TZECutScene }

//////////////////////////////////////////////////////////////////////////
constructor TZECutScene.Create (rBounds: TRect);
begin
  inherited;
  WClassName := CC_CUT_SCENE_VIEW;
  //
  CenterX := true;
  CenterY := true;
  Animates := true;
  AnimationTick := 10;
  //
  FLoopCount := 0;
  FScenes := NIL;
  FCurrentScene := 0;
  FRunning := false;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZECutScene.Destroy;
begin
  ZZE_CSI_UnloadCutScenes (FScenes);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.LoadCurrentScene;
var
  CSI: PZECutSceneInfo;
begin
  if (NOT FRunning) then Exit;
  //
  CSI := PZECutSceneInfo (Scenes [FCurrentScene]);
  with CSI^ do begin
    if (PSpriteName <> NIL) then SpriteName := string (PSpriteName);
    if (PCaptionText <> NIL) then Caption := PCaptionText;
    if (PMusic <> NIL) then CoreEngine.SetBackgroundMusic (PMusic);
    if (PSoundEffect <> NIL) then CoreEngine.PlaySound (PSoundEffect);
    //
    AnimationTick := dwDelay;
    if (ImageFlag = ioClear) then SpriteName := '';
    if (MusicFlag = moStop) then CoreEngine.ClearBackgroundMusic;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.AnimateUpdate;
begin
  inherited;
  if (NOT FRunning) OR (Scenes = NIL) then Exit;
  //
  if (FCurrentScene >= Pred (Scenes.Count)) then begin
    FCurrentScene := 0;
    Inc (FLoopCount);
    g_CmdQueue.Insert (cmCutSceneHasLooped, 0, 0);
    //EventQueue.InsertEvent (cmCutSceneHasLooped);
  end else
    Inc (FCurrentScene);
  //
  LoadCurrentScene;
  if (HasLooped) then PostCommand (cmCutSceneEnds);
end;

//////////////////////////////////////////////////////////////////////////
function TZECutScene.HasLooped: boolean;
begin
  Result := (LoopCount > 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.Paint;
var
  rArea: TRect;
begin
  inherited;
  if (Font <> NIL) then begin
    if (Font.VAlignment = vaCenter) then begin
      Font.VAlignment := vaTop;
      Font.MultiLine := TRUE;
    end;
    if (Caption <> '') then begin
      rArea := ClientToScreen (LocalBounds);
      rArea.Top := rArea.Bottom - 60;
      Font.WriteText (Surface, Caption, rArea);
    end;
  end
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.MouseLeftClick (var Event: TZbEvent);
begin
  PostCommand (cmCutSceneEnds);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.LoadCutSceneFile (AFile: string);
begin
  ZZE_CSI_UnloadCutScenes (Scenes);
  FScenes := ZZE_CSI_LoadCutScenes (AFile);
  //
  ResetSequence;
  if (Font <> NIL) then Font.MultiLine := true;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.ResetSequence;
begin
  CurrentScene := 0;
  LoopCount := 0;
  SpriteName := '';
  Caption := '';
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.BeginSequence;
begin
  g_CmdQueue.Insert (cmCutSceneBegins, 0, 0);
  //EventQueue.InsertEvent (cmCutSceneBegins);
  ResetSequence;
  FRunning := true;
  LoadCurrentScene;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECutScene.StopSequence;
begin
  ResetSequence;
  FRunning := false;
end;


{ TZEPopupMenu }

//////////////////////////////////////////////////////////////////////////
constructor TZEPopupMenu.Create (rBounds: TRect);
begin
  inherited;
  WClassName := CC_GAME_MAIN_MENU;
  //
  FMarginLeft := 10;
  FMarginRight := 10;
  FVertSpacing := 15;
  //
  FItems := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEPopupMenu.Destroy;
begin
  FItems.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEPopupMenu.RepositionButtons;
var
  iIndex, Left, Right, Top, CtlHeight: integer;
  RequiredSpace: integer;
  Control: TZEControl;
begin
  if ((FItems = NIL) OR (FItems.Count <= 0)) then Exit;
  //
  Control := TZEControl (FItems [0]);
  RequiredSpace :=  (Control.Height * FItems.Count) +
                    (Pred (FItems.Count) * FVertSpacing);
  //
  // calculate widths differently depending on type of button in use
  if (Control.GetPropertyValue (PROP_NAME_WINCLASS_NAME) = CC_ICON_BUTTON) then
    begin
      Left := (Width - Control.Width) div 2;
      Right := Left + Control.Width;
    end
  else
    begin
      Left := FMarginLeft;
      Right := Width - FMarginRight;
    end;
  //
  CtlHeight := Control.Height;
  Top := (Height - RequiredSpace) div 2;
  //
  for iIndex := 0 to Pred (FItems.Count) do
    begin
      Control := TZEControl (FItems [iIndex]);
      if (Control = NIL) then break;
      //
      Control.Bounds := Rect (Left, Top, Right, Top + CtlHeight);
      Inc (Top, CtlHeight + FVertSpacing);
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEPopupMenu.AddMenuItem (ACaption: string; ACommand: integer;
  AButtonName, FontName: string);
var
  Control: TZEControl;
begin
  Control := CreateControl (AButtonName, LocalBounds);
  if (Control <> NIL) then
    begin
      Insert (Control);
      Control.SetPropertyvalue (PROP_NAME_SHOW_CAPTION, 'TRUE');
      Control.SetPropertyvalue (PROP_NAME_CAPTION, ACaption);
      Control.SetPropertyvalue (PROP_NAME_FONT_NAME, FontName);
      Control.SetPropertyvalue (PROP_NAME_COMMAND, PChar (IntToStr (ACommand)));
      Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Menu');
      //
      FItems.Add (Pointer (Control));
      RepositionButtons;
    end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEPopupMenu.ChangeBounds (rBounds: TRect);
begin
  inherited;
  RepositionButtons;
end;

end.

