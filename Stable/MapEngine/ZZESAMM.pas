{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZESAMM.PAS
              SAMM - State And Media Manager
              The SAMM class manages all the media files necessary
              to effect the activities and representations of Game Entities.
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/MapEngine/ZZESAMM.pas,v 1.5 2002/12/18 08:20:09 Vij Exp $
  $Log: ZZESAMM.pas,v $
  Revision 1.5  2002/12/18 08:20:09  Vij
  added snSequenceEnded, and checking if sound effects is indeed specified
  before playing it.

  Revision 1.4  2002/11/02 06:56:37  Vij
  MAJOR CODE CHANGES!!!
  re-created the old classes, and created new ones.  Orientations of entities
  is now a class-managed property.  SoundFX support now in the code.  new
  format for ZEDS and SAMMS warranting major changes to code the reads and
  writes these.  There is also no more need to write to a stream only to
  read it back again during cloning.  It is much more direct this time,
  and more efficient.  Dimensions are also property of the SAMM now.

  Revision 1.3  2002/10/01 12:42:33  Vij
  Removed FundamentalSAMM placed it in ZZESupport as a streamable class.
  Added SAMMManager class.

  Revision 1.2  2002/09/17 22:17:50  Vij
  Added header so that history/comments from CVS will be inlined in source.
  Massive overhaul of all classes to remove all the frame-dependencies to
  a single class (EntitySnapShot).
  Fixed bug in call to Format() (there was no %c option, replaced with %s)



 ============================================================================}

unit ZZESAMM;

{ NOTES:

  New SAMM formation (FINISHED)

  [MAIN]
  Name=
  Orientations=A(X:Y),B(X:Y)
  Default=Action1  <-- optional, defaults to 'DEFAULT'

  [#Action1] <-- action properties
  BaseSprite=
  Images=
  Frames=
  Repeating=
  NextAction=

  [$Action1] <-- frame instructions
  ;<FORMAT: INDEX=FrameIndex,FrameDelay,ALPHA,SoundFXName>
  0=0,0,,[optional]  // an ALPHA of -1 means NO ALPHA, ALPHA value in PERCENT (%)

}

interface

uses
  Types,
  Classes,
  //
  ZbScriptable,
  ZbGameUtils,
  ZbDoubleList,
  //
  ZEDXSpriteIntf,
  ZZESupport;

const
  ACTION_TABLE_NAME           = 'Name';
  ACTION_TABLE_ORIENTATIONS   = 'Orientations';
  ACTION_TABLE_DEFAULT        = 'Default';

  ACTION_PROP_BASE_SPRITE     = 'BaseSprite';
  ACTION_PROP_IMAGE_COUNT     = 'Images';
  ACTION_PROP_IMAGE_SPAN      = 'ImageSpan';
  ACTION_PROP_FRAME_COUNT     = 'Frames';
  ACTION_PROP_REPEATING       = 'Repeating';
  ACTION_PROP_NAME_OF_NEXT    = 'NextAction';

  ACTION_SECTION_HEADER       = 'MAIN';
  ACTION_SECTION_MAIN_PREF    = '#';
  ACTION_SECTION_FRAMES_PREF  = '$';

  ACTION_DEFAULT              = 'DEFAULT';

  CFG_PARAM_BASE_SPRITE       = 'BaseSprite';
  CFG_PARAM_IS_REPEATING      = 'IsRepeating';
  CFG_PARAM_NEXT_SEQUENCE     = 'NextSequence';
  CFG_PARAM_SEQUENCE_COUNT    = 'SequenceCount';

  CFG_SEQUENCE_BEGIN_MARKER   = '#';
  CFG_SEQUENCE_END_MARKER     = '@';

  SAMM_FOLDER_NAME            = 'SAMMS';

type
  TZEEntitySnapShot = class;
  //
  TZESequenceOrientation = class;
  TZESeqOrientationList = class;
  //
  TZEMasterAnimFrame = class;
  TZEMasterAnimSequence = class;
  //
  TZEMasterAction = class;
  TZEActionProperties = class;
  TZEActionTable = class;
  TZEActionList = class;
  //
  TZEAnimationFrame = class;
  TZEAnimationSequence = class;
  //
  TZEStateAndMediaManager = class;
  TZESAMMManager = class;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntitySnapshot = class (TZbScriptable)
  private
    FCurrentVector: TZbVector;      // current movement vector
    FEntityFacing: TZbDirection;
    FEntityState: PChar;            // name of the current state
    FAnimSequence: TZEAnimationSequence;
    FCurrentFrame: integer;
    FLastFrame: integer;
    FAnimFrame: TZEAnimationFrame;
    FSleepTime: Cardinal;
    FSpriteToDraw: IZESprite;
    FUseAlpha: boolean;
    FAlpha: DWORD;
  protected
    function GetStateName: string;
    procedure SetStateName (AStateName: string);
    procedure SetAnimSequence (ANewSequence: TZEAnimationSequence);
    function GetSpriteToDraw: IZESprite;
  public
    constructor Create;
    destructor Destroy; override;
    //
    property Sprite: IZESprite read GetSpriteToDraw;
    property EntityVector: TZbVector read FCurrentVector write FCurrentVector;
    property EntityFacing: TZbDirection read FEntityFacing write FEntityFacing;
    property EntityState: string read GetStateName write SetStateName;
    property Sequence: TZEAnimationSequence read FAnimSequence write SetAnimSequence;
    property Frame: TZEAnimationFrame read FAnimFrame;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESequenceOrientation = class (TZbScriptable)
  private
    FOrientation: TZbDirection;
    FDimension: TPoint;
  public
    constructor Create (AOrientation: TZbDirection; ADimension: TPoint); overload;
    constructor Create (cParamStr: String); overload;
    //
    procedure FromString (cParamStr: String);
    function ToString: String;
    //
    property Orientation: TZbDirection read FOrientation;
    property Dimension: TPoint read FDimension;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESeqOrientationList = class (TZbScriptable)
  private
    FList: TList;
  protected
    procedure Clear;
    function GetCount: integer;
    function GetByIndex (iIndex: integer): TZESequenceOrientation;
    function GetByDirection (ADirection: TZbDirection): TZESequenceOrientation;
  public
    constructor Create (cParamStr: String);
    destructor Destroy; override;
    //
    procedure FromString (cParamStr: String);
    function ToString: String;
    function IndexOf (ADirection: TZbDirection): integer;
    //
    property Count: integer read GetCount;
    property ListI [iIndex: integer]: TZESequenceOrientation read GetByIndex;
    property ListD [ADirection: TZbDirection]: TZESequenceOrientation read GetByDirection;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMasterAnimFrame = class (TZbScriptable)
  private
    FIndex: integer;
    FDelay: Cardinal;
    FAlphaPercent: integer;
    FUseAlpha: boolean;
    FAlphaValue: DWORD;
    FSoundFX: PChar;
  protected
    function GetSoundFX: String;
  public
    constructor Create (cParamStr: String);
    destructor Destroy; override;
    //
    procedure FromString (cParamStr: String);
    function ToString: String;
    //
    property Index: integer read FIndex;
    property Delay: Cardinal read FDelay;
    property AlphaPercent: integer read FAlphaPercent;
    property Alpha: DWORD read FAlphaValue;
    property UseAlpha: boolean read FUseAlpha;
    property SoundFX: string read GetSoundFX;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMasterAnimSequence = class (TZbScriptable)
  private
    FList: TList;
  protected
    procedure Clear;
    function GetCount: integer;
    function GetFrameAt (iIndex: integer): TZEMasterAnimFrame;
  public
    constructor Create (ASeqList: TStrings);
    destructor Destroy; override;
    //
    procedure FromStrings (ASeqList: TStrings);
    procedure ToStrings (ASeqList: TStrings);
    //
    property Count: integer read GetCount;
    property ListI [iIndex: integer]: TZEMasterAnimFrame read GetFrameAt; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMasterAction = class (TZbNamedClass)
  private
    FBaseSprite: IZESprite;
    FBaseSpriteName: PChar;
    FMaxImageCount: integer;
    FMaxImageSpan: integer; // how many images to jump to get to the next series
    FMaxFramesInASequence: integer;
    FRepeating: boolean;
    FNameOfNextAction: PChar;
    FSequence: TZEMasterAnimSequence;
  protected
    procedure Cleanup;
    function GetBaseSpriteName: string;
    function GetNameOfNextAction: string;
  public
    constructor Create (AName: String; APropsList, ASeqList: TStrings);
    destructor Destroy; override;
    //
    procedure FromStrings (APropsList, ASeqList: TStrings);
    procedure ToStrings (APropsList, ASeqList: TStrings);
    //
    property Name;
    property BaseSprite: IZESprite read FBaseSprite;
    property BaseSpriteName: string read GetBaseSpriteName;
    property MaxImageCount: integer read FMaxImageCount;
    property MaxImageSpan: integer read FMaxImageSpan;
    property MaxFramesInASequence: integer read FMaxFramesInASequence;
    property Repeating: boolean read FRepeating;
    property NameOfNextAction: string read GetNameOfNextAction;
    property Sequence: TZEMasterAnimSequence read FSequence;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEActionProperties = class (TZbNamedClass)
  private
    FOrientations: TZESeqOrientationList;
    FDefaultState: PChar;
  protected
    function GetDefaultState: String;
    procedure SetDefaultState (ADefaultState: String);
  public
    constructor Create (Source: TStrings);
    destructor Destroy; override;
    //
    procedure FromStrings (Source: TStrings);
    procedure ToStrings (Dest: TStrings);
    //
    property Name;
    property Orientations: TZESeqOrientationList read FOrientations;
    property DefaultState: String read GetDefaultState write SetDefaultState;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEActionTable = class (TZbScriptable)
  private
    FProps: TZEActionProperties;
    FActionList: TZbDoubleList;
  protected
    function GetCount: integer;
    function GetActionName (iIndex: integer): String;
    function GetAction (cActionName: string): TZEMasterAction;
    function ComposeMoniker (AFacing: TZbDirection; AStateName: string): String;
  public
    constructor Create (Source: TStream);
    destructor Destroy; override;
    //
    function CreateSequence (AFacing: TZbDirection; AStateName: string): TZEAnimationSequence;
    //
    property Props: TZEActionProperties read FProps;
    property Count: integer read GetCount;
    property ActionName [iIndex: integer]: String read GetActionName;
    property Actions [cActionName: string]: TZEMasterAction read GetAction; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEActionList = class (TZbScriptable)
  private
    FActionRef: TZEActionTable;
    FList: TZbDoubleList;
  public
    constructor Create (AActionRef: TZEActionTable);
    destructor Destroy; override;
    //
    function GetSequence (AFacing: TZbDirection; AStateName: string): TZEAnimationSequence;
    //
    property Ref: TZEActionTable read FActionRef;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEAnimationSequence = class (TZbNamedClass)
  private
    FMaster: TZEMasterAction;
    FBaseIndex: integer;
    FFrames: TList;
  protected
    function GetCount: integer;
    function GetFrameI (iIndex: integer): TZEAnimationFrame;
  public
    constructor Create (AName: string; AMaster: TZEMasterAction; ABaseIndex: integer);
    destructor Destroy; override;
    //
    property Name;
    property Count: integer read GetCount;
    property BaseIndex: integer read FBaseIndex;
    property Master: TZEMasterAction read FMaster;
    property Frames [iIndex: integer]: TZEAnimationFrame read GetFrameI; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEAnimationFrame = class (TZbScriptable)
  private
    FMaster: TZEMasterAnimFrame;
    FSpriteIndex: integer;
  public
    constructor Create (AMaster: TZEMasterAnimFrame; ABaseIndex: integer);
    //
    property Master: TZEMasterAnimFrame read FMaster;
    property SpriteIndex: integer read FSpriteIndex;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESAMMNotice = (snNothing, snSequenceLooped, snSequenceEnded, snSequenceSwitched);
  TZESAMMNotifyProc = procedure (Sender: TZEStateAndMediaManager; Notice: TZESAMMNotice) of Object;

  TZEStateAndMediaManager = class (TZbNamedClass)
  private
    FList: TZEActionList;
    FNotify: TZESAMMNotifyProc;
  public
    constructor Create (ARefTable: TZEActionTable);
    destructor Destroy; override;
    //
    function Clone: TZEStateAndMediaManager;
    //
    procedure UpdateEntityState (SnapShot: TZEEntitySnapShot; WTicksElapsed: Cardinal); virtual;
    procedure AlignWithNewState (SnapShot: TZEEntitySnapShot); virtual;
    //
    property ActionList: TZEActionList read FList;
    property Notify: TZESAMMNotifyProc read FNotify write FNotify;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESAMMManager = class (TZbScriptable)
  private
    FSAMMTables: TZbDoubleList;
    FSAMMList: TZbDoubleList;
  protected
    function GetSAMM_I (iIndex: integer): TZEStateAndMediaManager;
    function GetSAMM_S (cName: string): TZEStateAndMediaManager;
    procedure LoadSAMMData;
  public
    constructor Create;
    destructor Destroy; override;
    //
    property SAMMByIndex [iIndex: integer]: TZEStateAndMediaManager read GetSAMM_I;
    property SAMMByName [cName: string]: TZEStateAndMediaManager read GetSAMM_S; default;
  end;


implementation

uses
  SysUtils,
  StrUtils,
  JclStrings,
  IdGlobal,
  //
  ZbDebug,
  ZbStringUtils,
  ZbVirtualFS,
  ZbIniFileEx,
  //
  ZEDXSprite,
  ZZECore;


{ TZEEntitySnapshot }

//////////////////////////////////////////////////////////////////////////
constructor TZEEntitySnapshot.Create;
begin
  inherited;
  FCurrentVector := Vector (0, 0, 0);
  FEntityFacing := tdUnknown;
  FEntityState := NIL;
  FAnimSequence := NIL;
  FCurrentFrame := 0;
  FLastFrame := 0;
  FAnimFrame := NIL;
  FSleepTime := 0;
  FSpriteToDraw := NIL;
  FUseAlpha := FALSE;
  FAlpha := 0;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEEntitySnapshot.Destroy;
begin
  FAnimSequence := NIL;
  if (FEntityState <> NIL) then StrDispose (FEntityState);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntitySnapshot.GetStateName: string;
begin
  Result := IfThen (FEntityState = NIL, '', String (FEntityState));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntitySnapshot.SetStateName (AStateName: string);
begin
  if (FEntityState <> NIL) then StrDispose (FEntityState);
  if (AStateName <> '') then
    FEntityState := StrNew (PChar (AStateName))
    else FEntityState := NIL
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntitySnapshot.SetAnimSequence (ANewSequence: TZEAnimationSequence);
begin
  FAnimSequence := ANewSequence;
  if (FAnimSequence = NIL) then begin
    FSpriteToDraw := NIL;
    FAnimFrame := NIL;
  end else begin
    FCurrentFrame := 0;
    FLastFrame := Pred (FAnimSequence.Master.MaxFramesInASequence);
    FAnimFrame := FAnimSequence [FCurrentFrame];
    FSpriteToDraw := FAnimSequence.Master.BaseSprite;
    FSleepTime := FAnimFrame.Master.Delay;
    FUseAlpha := FAnimFrame.Master.UseAlpha;
    FAlpha := FAnimFrame.Master.Alpha;
    if (FAnimFrame.Master.FSoundFX <> NIL) then
      CoreEngine.PlaySound (FAnimFrame.Master.FSoundFX);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntitySnapshot.GetSpriteToDraw: IZESprite;
begin
  if (FSpriteToDraw <> NIL) AND (FAnimFrame <> NIL) then begin
    Result := FSpriteToDraw;
    with Result do begin
      CurrentFrame := FAnimFrame.SpriteIndex;
      UseAlpha := FAnimFrame.Master.UseAlpha;
      if (UseAlpha) then Alpha := FAnimFrame.Master.Alpha;
    end;
  end else
    Result := NIL;
end;

{ TZESequenceOrientation }

//////////////////////////////////////////////////////////////////////////
constructor TZESequenceOrientation.Create (AOrientation: TZbDirection; ADimension: TPoint);
begin
  inherited Create;
  FOrientation := AOrientation;
  FDimension := ADimension;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZESequenceOrientation.Create (cParamStr: String);
begin
  inherited Create;
  FromString (cParamStr);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESequenceOrientation.FromString (cParamStr: String);
begin
  cParamStr := Trim (cParamStr);
  FOrientation := dirNameToDir (StrBefore ('(', cParamStr));
  cParamStr := Trim (StrBefore (')', StrAfter ('(', cParamStr)));
  if (cParamStr = '') then
    FDimension := Point (1, 1)
  else begin
    FDimension.X := StrToIntSafe (StrBefore (':', cParamStr));
    FDimension.Y := StrToIntSafe (StrAfter (':', cParamStr));
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZESequenceOrientation.ToString: String;
begin
  Result := Format ('%s(%d:%d)', [__DirName [FOrientation], FDimension.X, FDimension.Y]);
end;


{ TZESeqOrientationList }

//////////////////////////////////////////////////////////////////////////
constructor TZESeqOrientationList.Create (cParamStr: String);
begin
  inherited Create;
  FList := TList.Create;
  FromString (cParamStr);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZESeqOrientationList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESeqOrientationList.FromString (cParamStr: String);
var
  cData: String;
  theOrientation: TZESequenceOrientation;
begin
  Clear;
  cData := Trim (cParamStr);
  while (cData <> '') do begin
    cParamStr := StrBefore (',', cData);
    cData := Trim (StrAfter (',', cData));
    //
    theOrientation := TZESequenceOrientation.Create (cParamStr);
    FList.Add (Pointer (theOrientation));
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZESeqOrientationList.ToString: String;
var
  iIndex: integer;
  theOrientation: TZESequenceOrientation;
begin
  Result := '';
  for iIndex := 0 to Pred (FList.Count) do begin
    theOrientation := TZESequenceOrientation (FList [iIndex]);
    if (Result <> '') then Result := Result + ',';
    Result := Result + theOrientation.ToString;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZESeqOrientationList.IndexOf (ADirection: TZbDirection): integer;
var
  theOrientation: TZESequenceOrientation;
  iIndex: integer;
begin
  Result := -1;
  for iIndex := 0 to Pred (FList.Count) do begin
    theOrientation := TZESequenceOrientation (FList [iIndex]);
    if (theOrientation.Orientation = ADirection) then begin
      Result := iIndex;
      break;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESeqOrientationList.Clear;
var
  theOrientation: TZESequenceOrientation;
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FList.Count) do begin
    theOrientation := TZESequenceOrientation (FList [iIndex]);
    theOrientation.Free;
    FList [iIndex] := NIL;
  end;
  FList.Pack;
end;

//////////////////////////////////////////////////////////////////////////
function TZESeqOrientationList.GetCount: integer;
begin
  Result := FList.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZESeqOrientationList.GetByIndex (iIndex: integer): TZESequenceOrientation;
begin
  if (iIndex >= 0) AND (iIndex < FList.Count) then
    Result := TZESequenceOrientation (FList [iIndex])
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZESeqOrientationList.GetByDirection (ADirection: TZbDirection): TZESequenceOrientation;
var
  theOrientation: TZESequenceOrientation;
  iIndex: integer;
begin
  Result := NIL;
  for iIndex := 0 to Pred (FList.Count) do begin
    theOrientation := TZESequenceOrientation (FList [iIndex]);
    if (theOrientation.Orientation = ADirection) then begin
      Result := theOrientation;
      break;
    end;
  end;
end;

{ TZEMasterAnimFrame }

//////////////////////////////////////////////////////////////////////////
constructor TZEMasterAnimFrame.Create (cParamStr: String);
begin
  inherited Create;
  FIndex := -1;
  FDelay := 0;
  FAlphaPercent := -1;
  FUseAlpha := FALSE;
  FAlphaValue := 0;
  FSoundFX := NIL;
  //
  FromString (cParamStr);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEMasterAnimFrame.Destroy;
begin
  if (FSoundFX <> NIL) then StrDispose (FSoundFX);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMasterAnimFrame.FromString (cParamStr: String);
var
  cData: string;
begin
  cParamStr := Trim (cParamStr);
  if (cParamStr <> '') then begin
    FIndex := StrToIntSafe (StrBefore (',', cParamStr));
    cParamStr := StrAfter (',', cParamStr);
    //
    FDelay := StrToIntSafe (StrBefore (',', cParamStr));
    cParamStr := StrAfter (',', cParamStr);
    //
    cData := Trim (StrBefore (',', cParamStr));
    FUseAlpha := NOT ((cData = '') OR (cData = '-'));
    if (FUseAlpha) then begin
      FAlphaPercent := StrToInt (cData);
      FAlphaValue := DWORD (Round ((FAlphaPercent / 100) * 255));
    end else begin
      FAlphaPercent := -1;
      FAlphaValue := 0;
    end;
    //
    cData := Trim (StrAfter (',', cParamStr));
    if (cData <> '') then
      FSoundFX := StrNew (PChar (cData));
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMasterAnimFrame.ToString: String;
begin
  Result := Format ('%d,%d,%s,%s', [FIndex, FDelay,
    IfThen (FUseAlpha, IntToStr (FAlphaPercent), ''), SoundFX]);
end;

//////////////////////////////////////////////////////////////////////////
function TZEMasterAnimFrame.GetSoundFX: String;
begin
  Result := IfThen (FSoundFX = NIL, '', String (FSoundFX));
end;


{ TZEMasterAnimSequence }

//////////////////////////////////////////////////////////////////////////
constructor TZEMasterAnimSequence.Create (ASeqList: TStrings);
begin
  inherited Create;
  FList := TList.Create;
  FromStrings (ASeqList);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEMasterAnimSequence.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMasterAnimSequence.Clear;
var
  iIndex: integer;
  theFrame: TZEMasterAnimFrame;
begin
  for iIndex := 0 to Pred (FList.Count) do begin
    theFrame := TZEMasterAnimFrame (FList [iIndex]);
    theFrame.Free;
    FList [iIndex] := NIL;
  end;
  FList.Pack;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMasterAnimSequence.FromStrings (ASeqList: TStrings);
var
  iIndex: integer;
  cData: String;
  theFrame: TZEMasterAnimFrame;
begin
  for iIndex := 0 to Pred (ASeqList.Count) do begin
    cData := Trim (StrAfter ('=', ASeqList [iIndex]));
    theFrame := TZEMasterAnimFrame.Create (cData);
    FList.Add (theFrame);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMasterAnimSequence.ToStrings (ASeqList: TStrings);
var
  iIndex: integer;
  cData: String;
  theFrame: TZEMasterAnimFrame;
begin
  ASeqList.Clear;
  for iIndex := 0 to Pred (FList.Count) do begin
    theFrame := TZEMasterAnimFrame (FList [iIndex]);
    cData := Format ('%d=%s', [iIndex, theFrame.ToString]);
    ASeqList.Add (cData);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMasterAnimSequence.GetCount: integer;
begin
  Result := FList.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMasterAnimSequence.GetFrameAt (iIndex: integer): TZEMasterAnimFrame;
begin
  if (iIndex >= 0) AND (iIndex < FList.Count) then
    Result := TZEMasterAnimFrame (FList [iIndex])
    else Result := NIL;
end;


{ TZEMasterAction }

//////////////////////////////////////////////////////////////////////////
constructor TZEMasterAction.Create (AName: String; APropsList, ASeqList: TStrings);
begin
  inherited Create;
  FBaseSprite := NIL;
  FBaseSpriteName := NIL;
  FMaxImageCount := -1;
  FMaxImageSpan := -1;
  FMaxFramesInASequence := -1;
  FRepeating := TRUE;
  FNameOfNextAction := NIL;
  FSequence := NIL;
  //
  FromStrings (APropsList, ASeqList);
  Name := AName;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEMasterAction.Destroy;
begin
  Cleanup;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMasterAction.FromStrings (APropsList, ASeqList: TStrings);
var
  cData: string;
begin
  Cleanup;
  //
  cData := APropsList.Values [ACTION_PROP_BASE_SPRITE];
  FBaseSpriteName := StrNew (PChar (cData));
  FBaseSprite := CoreEngine.SpriteFactory.CreateSprite ('Entity', string (FBaseSpriteName));
  //
  cData := APropsList.Values [ACTION_PROP_IMAGE_COUNT];
  FMaxImageCount := StrToIntSafe (cData);
  cData := APropsList.Values [ACTION_PROP_IMAGE_SPAN];
  if (cData = '') then
    FMaxImageSpan := FMaxImageCount
    else FMaxImageSpan := StrToIntSafe (cData);
  //
  cData := APropsList.Values [ACTION_PROP_FRAME_COUNT];
  FMaxFramesInASequence := StrToIntSafe (cData);
  cData := APropsList.Values [ACTION_PROP_REPEATING];
  FRepeating := (cData <> '') AND (cData [1] in ['1', 'Y', 'T']);
  //
  cData := Trim (APropsList.Values [ACTION_PROP_NAME_OF_NEXT]);
  if (cData <> '') then  FNameOfNextAction := StrNew (PChar (cData));
  //
  FSequence := TZEMasterAnimSequence.Create (ASeqList);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMasterAction.ToStrings (APropsList, ASeqList: TStrings);
begin
  if (FSequence = NIL) then Exit;
  with APropsList do begin
    Clear;
    Add (Format ('%s=%s', [ACTION_PROP_BASE_SPRITE, BaseSpriteName]));
    Add (Format ('%s=%d', [ACTION_PROP_IMAGE_COUNT, FMaxImageCount]));
    Add (Format ('%s=%d', [ACTION_PROP_FRAME_COUNT, FMaxFramesInASequence]));
    Add (Format ('%s=%s', [ACTION_PROP_REPEATING, BoolStr [FRepeating]]));
    Add (Format ('%s=%s', [ACTION_PROP_NAME_OF_NEXT, NameOfNextAction]));
  end;
  FSequence.ToStrings (ASeqList);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMasterAction.Cleanup;
begin
  FBaseSprite := NIL;
  if (FBaseSpriteName <> NIL) then begin
    StrDispose (FBaseSpriteName);
    FBaseSpriteName := NIL;
  end;
  FMaxImageCount := -1;
  FMaxFramesInASequence := -1;
  FRepeating := TRUE;
  if (FNameOfNextAction <> NIL) then begin
    StrDispose (FNameOfNextAction);
    FNameOfNextAction := NIL;
  end;
  FreeAndNIL (FSequence);
end;

//////////////////////////////////////////////////////////////////////////
function TZEMasterAction.GetBaseSpriteName: string;
begin
  Result := IfThen (FBaseSpriteName = NIL, '', String (FBaseSpriteName));
end;

//////////////////////////////////////////////////////////////////////////
function TZEMasterAction.GetNameOfNextAction: string;
begin
  Result := IfThen (FNameOfNextAction = NIL, '', String (FNameOfNextACtion));
end;


{ TZEActionProperties }

//////////////////////////////////////////////////////////////////////////
constructor TZEActionProperties.Create (Source: TStrings);
begin
  inherited Create;
  FOrientations := NIL;
  FDefaultState := NIL;
  FromStrings (Source);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEActionProperties.Destroy;
begin
  FOrientations.Free;
  DefaultState := '';
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEActionProperties.GetDefaultState: String;
begin
  Result := IfThen (FDefaultState = NIL, '', String (FDefaultState));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEActionProperties.SetDefaultState (ADefaultState: String);
begin
  if (FDefaultState <> NIL) then begin
    StrDispose (FDefaultState);
    FDefaultState := NIL;
  end;
  //
  if (ADefaultState <> '') then
    FDefaultState := StrNew (PChar (ADefaultState));
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEActionProperties.FromStrings (Source: TStrings);
var
  cData: String;
begin
  Name := Source.Values [ACTION_TABLE_NAME];
  cData := Source.Values [ACTION_TABLE_ORIENTATIONS];
  if (FOrientations <> NIL) then FOrientations.Free;
  FOrientations := TZESeqOrientationList.Create (cData);
  //
  cData := Source.Values [ACTION_TABLE_DEFAULT];
  if (cData = '') then cData := ACTION_DEFAULT;
  DefaultState := cData;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEActionProperties.ToStrings (Dest: TStrings);
begin
  Dest.Clear;
  Dest.Add (Format ('%s=%s', [ACTION_TABLE_NAME, Name]));
  Dest.Add (Format ('%s=%s', [ACTION_TABLE_ORIENTATIONS, FOrientations.ToString]));
  Dest.Add (Format ('%s=%s', [ACTION_TABLE_DEFAULT, DefaultState]));
end;


{ TZEActionTable }

//////////////////////////////////////////////////////////////////////////
constructor TZEActionTable.Create (Source: TStream);
var
  IniSource: TZbIniFileEx;
  StrList, PropsList, SeqList: TStrings;
  iIndex: integer;
  cData: string;
  Action: TZEMasterAction;
begin
  inherited Create;
  //
  FProps := NIL;
  FActionList := TZbDoubleList.Create (TRUE);
  FActionList.Sorted := TRUE;
  FActionList.DisposeProc := __DeleteObject;
  //
  IniSource := TZbIniFileEx.Create (Source);
  StrList := TStringList.Create;
  PropsList := TStringList.Create;
  SeqList := TStringList.Create;
  try
    //
    // read the main section and create the action properties
    IniSource.ReadSection (ACTION_SECTION_HEADER, PropsList, TRUE);
    FProps := TZEActionProperties.Create (PropsList);
    //
    // read all section names and place all action names into
    // a separate list (to be processed later)
    IniSource.ReadSections (PropsList);
    StrList.Clear;
    for iIndex := 0 to Pred (PropsList.Count) do begin
      cData := PropsList [iIndex];
      if (cData [1] = ACTION_SECTION_MAIN_PREF) then
        StrList.Add (StrAfter (ACTION_SECTION_MAIN_PREF, cData));
    end;
    //
    // this loop creates the action objects...
    for iIndex := 0 to Pred (StrList.Count) do begin
      cData := StrList [iIndex];
      IniSource.ReadSection (ACTION_SECTION_MAIN_PREF + cData, PropsList, TRUE);
      IniSource.ReadSection (ACTION_SECTION_FRAMES_PREF + cData, SeqList, TRUE);
      //
      Action := TZEMasterAction.Create (cData, PropsList, SeqList);
      if (Action <> NIL) then FActionList.Add (cData, Action);
      //
    end;
  finally
    IniSource.Free;
    StrList.Free;
    PropsList.Free;
    SeqList.Free;
  end;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEActionTable.Destroy;
begin
  FActionList.Free;
  FProps.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEActionTable.GetCount: integer;
begin
  Result := FActionList.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEActionTable.GetActionName (iIndex: integer): String;
var
  theAction: TZEMasterAction;
begin
  theAction := TZEMasterAction (FActionList.Get (iIndex));
  Result := IfThen (theAction = NIL, '', theAction.Name);
end;

//////////////////////////////////////////////////////////////////////////
function TZEActionTable.GetAction (cActionName: string): TZEMasterAction;
begin
  Result := TZEMasterAction (FActionList.Get (cActionName));
end;

//////////////////////////////////////////////////////////////////////////
function TZEActionTable.ComposeMoniker (AFacing: TZbDirection; AStateName: string): String;
begin
  if (AStateName = '') then AStateName := Props.DefaultState;
  Result := Format ('%s.%s$%s', [Props.Name, __DirName [AFacing], AStateName]);
end;

//////////////////////////////////////////////////////////////////////////
function TZEActionTable.CreateSequence (AFacing: TZbDirection;
  AStateName: string): TZEAnimationSequence;
var
  MasterAction: TZEMasterAction;
  SeqFacing: TZESequenceOrientation;
  iDirIndex, iBaseIndex: integer;
  cSequenceName: string;
begin
  Result := NIL;
  if (AStateName = '') then AStateName := Props.DefaultState;
  MasterAction := GetAction (AStateName);
  if (MasterAction = NIL) then Exit;
  //
  SeqFacing := Props.Orientations.ListD [AFacing];
  if (SeqFacing = NIL) AND (AFacing <> tdUnknown) then begin
    AFacing := tdUnknown;
    SeqFacing := Props.Orientations.ListD [AFacing];
  end;
  //
  if (SeqFacing = NIL) then Exit;
  iDirIndex := Props.Orientations.IndexOf (AFacing);
  iBaseIndex:= iDirIndex * MasterAction.MaxImageSpan;
  //
  cSequenceName := ComposeMoniker (AFacing, AStateName);
  Result := TZEAnimationSequence.Create (cSequenceName, MasterAction, iBaseIndex);
end;


{ TZEActionList }

//////////////////////////////////////////////////////////////////////////
constructor TZEActionList.Create (AActionRef: TZEActionTable);
begin
  inherited Create;
  FActionRef := AActionRef;
  FList := TZbDoubleList.Create (TRUE);
  FList.Sorted := TRUE;
  FList.DisposeProc := __DeleteObject;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEActionList.Destroy;
begin
  FActionRef := NIL;
  FreeAndNIL (FList);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEActionList.GetSequence (AFacing: TZbDirection; AStateName: string): TZEAnimationSequence;
begin
  Result := TZEAnimationSequence (FList.Get (Ref.ComposeMoniker (AFacing, AStateName)));
  if (Result <> NIL) then Exit;
  //
  Result := Ref.CreateSequence (AFacing, AStateName);
  if (Result <> NIL) then FList.Add (Result.Name, Result);
end;


{ TZEAnimationFrame }

//////////////////////////////////////////////////////////////////////////
constructor TZEAnimationFrame.Create (AMaster: TZEMasterAnimFrame; ABaseIndex: integer);
begin
  inherited Create;
  FMaster := AMaster;
  FSpriteIndex := ABaseIndex + FMaster.Index;
end;


{ TZEAnimationSequence }

//////////////////////////////////////////////////////////////////////////
constructor TZEAnimationSequence.Create (AName: string; AMaster: TZEMasterAction;
  ABaseIndex: integer);
var
  iIndex: integer;
  theAFrame: TZEAnimationFrame;
begin
  inherited Create;
  Name := AName;
  FMaster := AMaster;
  FBaseIndex := ABaseIndex;
  FFrames := TList.Create;
  //
  for iIndex := 0 to Pred (FMaster.Sequence.Count) do begin
    theAFrame := TZEAnimationFrame.Create (FMaster.Sequence [iIndex], FBaseIndex);
    FFrames.Add (theAFrame);
  end;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEAnimationSequence.Destroy;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FFrames.Count) do begin
    TZEAnimationFrame (FFrames [iIndex]).Free;
    FFrames [iIndex] := NIL;
  end;
  FFrames.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEAnimationSequence.GetCount: integer;
begin
  Result := FFrames.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEAnimationSequence.GetFrameI (iIndex: integer): TZEAnimationFrame;
begin
  if (iIndex >= 0) AND (iIndex < FFrames.Count) then
    Result := TZEAnimationFrame (FFrames [iIndex])
    else Result := NIL;
end;


{ TZEStateAndMediaManager }

//////////////////////////////////////////////////////////////////////////
constructor TZEStateAndMediaManager.Create (ARefTable: TZEActionTable);
begin
  inherited Create;
  FList := TZEActionList.Create (ARefTable);
  FNotify := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEStateAndMediaManager.Destroy;
begin
  FList.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEStateAndMediaManager.Clone: TZEStateAndMediaManager;
begin
  Result := TZEStateAndMediaManager.Create (FList.Ref);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEStateAndMediaManager.UpdateEntityState (
  SnapShot: TZEEntitySnapShot; WTicksElapsed: Cardinal);
var
  cNextSequence: string;
  iSwitchCount: integer;
begin
  if (SnapShot = NIL) OR (SnapShot.Sequence = NIL) then Exit;
  with SnapShot do begin
    //
    // if there is no animation frame, there's only one frame
    // then we have nothing to do!
    if (FAnimFrame = NIL) OR (FLastFrame = 0) then Exit;
    //
    iSwitchCount := 0;
    while (TRUE) do begin
      // if elapsed less than required in SleepTime, done now!
      if (WTicksElapsed < FSleepTime) then begin
        Dec (FSleepTime, WTicksElapsed);
        break;
      end;
      // deduct the sleep time from the elapsed
      Dec (WTicksElapsed, FSleepTime);
      FSleepTime := 0;
      Inc (iSwitchCount);
      // more time had elapsed, let's try moving the frame now
      // however, let's check first if we have hit the END of
      // the sequence...
      if (FCurrentFrame = FLastFrame) then begin
        // cycle back if this is a repeating animation
        if (Sequence.Master.Repeating) then begin
          FCurrentFrame := 0;
          FAnimFrame := Sequence [FCurrentFrame];
          FSleepTime := FAnimFrame.Master.Delay;
          //
          // fire an event to user to notify that animation had cycled!
          if (Assigned (FNotify)) then FNotify (Self, snSequenceLooped);
          //
        end else begin
        // not a repeating animation? check if there is
        // a next sequence...
          cNextSequence := Sequence.Master.NameOfNextAction;
          if (Assigned (FNotify)) then FNotify (Self, snSequenceEnded);
          // set the next sequence if any.
          if (cNextSequence <> '') then begin
            Sequence := FList.GetSequence (EntityFacing, cNextSequence);
            if (Assigned (FNotify)) then FNotify (Self, snSequenceSwitched);
          end;
          // done here...
          break;
        end;
      end else begin
        // we're not at the end of the sequence (YET)
        Inc (FCurrentFrame);
        FAnimFrame := Sequence [FCurrentFrame];
        FSleepTime := FAnimFrame.Master.Delay;
      end; // if
      //
    end; // while
    //
    if (iSwitchCount > 0) AND (FAnimFrame <> NIL) AND
      (FAnimFrame.Master.FSoundFX <> NIL) then begin
        CoreEngine.PlaySound (FAnimFrame.Master.FSoundFX);
      //
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEStateAndMediaManager.AlignWithNewState (SnapShot: TZEEntitySnapShot);
begin
  if (SnapShot <> NIL) then begin
    SnapShot.Sequence := FList.GetSequence (SnapShot.EntityFacing, SnapShot.EntityState);
  end;
end;


{ TZESAMMManager }

//////////////////////////////////////////////////////////////////////////
constructor TZESAMMManager.Create;
begin
  inherited Create;
  //
  FSAMMTables := TZbDoubleList.Create (TRUE);
  FSAMMTables.DisposeProc := __DeleteObject;
  FSAMMTables.Sorted := TRUE;
  //
  FSAMMList := TZbDoubleList.Create (TRUE);
  FSAMMList.DisposeProc := __DeleteObject;
  FSAMMList.Sorted := TRUE;
  //
  LoadSAMMData;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZESAMMManager.Destroy;
begin
  FSAMMList.Free;
  FSAMMTables.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESAMMManager.LoadSAMMData;
var
  iIndex: integer;
  theVolume: TZbStandardVolume;
  theFolder: TZbFSFolder;
  theRefTable: TZEActionTable;

  procedure ProcessFile (AFile: TZbFSFile);
  var
    theStream: TStream;
    theData: Pointer;
  begin
    theStream := TMemoryStream.Create;
    theData := AFile.Data;
    theStream.Write (theData^, AFile.Size);
    theStream.Position := 0;
    AFile.Release;
    //
    try
      theRefTable := TZEActionTable.Create (theStream);
      FSAMMTables.Add (theRefTable.Props.Name, theRefTable);
    finally
      theStream.Free;
    end;
  end;

  procedure ProcessFolder (AFolder: TZbFSFolder);
  var
    iPos: integer;
  begin
    for iPos := 0 to Pred (AFolder.FileCount) do
      ProcessFile (AFolder.FilesA [iPos]);
    //
    for iPos := 0 to Pred (AFolder.FolderCount) do
      ProcessFolder (AFolder.FoldersA [iPos]);
    //
  end;

begin
  for iIndex := 0 to Pred (CoreEngine.ImageManager.LibraryCount) do begin
    theVolume := CoreEngine.ImageManager.Libraries [iIndex].Source;
    theFolder := theVolume.Root.Folders [SAMM_FOLDER_NAME];
    if (theFolder <> NIL) then ProcessFolder (theFolder);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZESAMMManager.GetSAMM_I (iIndex: integer): TZEStateAndMediaManager;
begin
  Result := GetSAMM_S (FSAMMTables.GetName (iIndex));
end;

//////////////////////////////////////////////////////////////////////////
function TZESAMMManager.GetSAMM_S (cName: string): TZEStateAndMediaManager;
var
  theRefTable: TZEActionTable;
begin
  Result := TZEStateAndMediaManager (FSAMMList.Get (cName));
  if (Result = NIL) then begin
    //
    theRefTable := TZEActionTable (FSAMMTables.Get (cName));
    if (theRefTable = NIL) then Exit;
    //
    Result := TZEStateAndMediaManager.Create (theRefTable);
    if (Result = NIL) then Exit;
    // set the SAMM's name, and add it to 'constructed' cache
    Result.Name := cName;
    FSAMMList.Add (cName, Result);
    // we don't need the intermediate anymore, get rid of it
    //FSAMMTables.Delete (cName);
  end;
  if (Result <> NIL) then Result := Result.Clone;
end;


end.

