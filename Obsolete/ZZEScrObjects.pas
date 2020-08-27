{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEScrObjects.PAS
              The displayable version of the game.  All these screen
              objects/classes have only one thing to do: display.
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

unit ZZEScrObjects;

interface

uses
  Types,
  Classes,
  ZbScriptable,
  ZbGameUtils,
  ZEDXSpriteIntf,
  ZZEMapBasics,
  ZZESupport;

const
  DEFAULT_ANIMATION_DELAY   = 100;
  MAX_MOVE_STEPS            = 8;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewEntity = class;
  TZEViewMapNotifyProc = function (ViewEntity: TZEViewEntity): boolean of object;
  TZEViewOffsetChange = (vocDecrease, vocReset, vocIncrease);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewDrawPhase = (dpSurface, dpInhabitants);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewEntity = class (TZbScriptable)
  private
    FOwner: TZECustomTile;
    FSprite: IZESprite;
    //
    FUpdates: boolean;
    FCurrentOffset: TPoint;
    FDeltaOffset: TPoint;
    //
    FDrawSelector: boolean;
    //
    FLastTick: Cardinal;
    FAnimated: boolean;
    FAnimationDelay: Cardinal;
    FAnimationTimer: TZE_SimpleTimeTrigger;
    FOnAnimationEndProc: TZEViewMapNotifyProc;
    //
    FIsMoving: boolean;
    FMoveSteps: integer;
    FOnMotionStopped: TZEViewMapNotifyProc;
  protected
    procedure SetSprite (ASprite: IZESprite);
    procedure SetDeltaOffset (ADeltaOffset: TPoint);
    procedure ChangeOffset (WhatChange: TZEViewOffsetChange);
    //
    procedure SetAnimated (AAnimated: boolean);
    procedure SetAnimationDelay (AAnimationDelay: Cardinal);
    //
    procedure FullStop;
  public
    constructor Create (AOwner: TZECustomTile); virtual;
    destructor Destroy; override;
    //
    procedure Update (WTicksElapsed: Cardinal); virtual;
    procedure Draw (pLoc: TPoint); virtual;
    procedure Move (dWhere: TZEDirection); virtual;
    //
    function AnimationForward: boolean;
    function AnimationBackward: boolean;
    //
    property Owner: TZECustomTile read FOwner;
    property Sprite: IZESprite read FSprite write SetSprite;
    property Animated: boolean read FAnimated write SetAnimated;
    property AnimationDelay: Cardinal read FAnimationDelay write SetAnimationDelay;
    //
    property DeltaOffset: TPoint read FDeltaOffset write SetDeltaOffset;
    property OffsetChange: TZEViewOffsetChange write ChangeOffset;
    property DrawSelector: boolean read FDrawSelector write FDrawSelector;
    //
    property IsMoving: boolean read FIsMoving;
    //
    property OnAnimationEnd: TZEViewMapNotifyProc
      read FOnAnimationEndProc write FOnAnimationEndProc;
    property OnMotionStopped: TZEViewMapNotifyProc
      read FOnMotionStopped write FOnMotionStopped;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewTerrain = class (TZEViewEntity)
  private
    FHeight: integer;
    FTransitions: TList;
  public
    constructor Create (AOwner: TZECustomTile); override;
    destructor Destroy; override;
    //
    procedure Draw (pLoc: TPoint); override;
    //
    procedure ClearTransitions;
    procedure AddTransition (Transition: TZEViewEntity); overload;
    procedure AddTransition (TransitionSprite: IZESprite); overload;
    //
    property Height: integer read FHeight write FHeight;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewFloor = class (TZEViewEntity)
  end;

  TZEViewDominant = class (TZEViewEntity)
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewTile = class (TZECustomTile)
  private
    FDisplayLocation: TPoint;
    FDisplayBounds: TRect;
    FTerrain: TZEViewTerrain;
    FFloor: TZEViewFloor;
    FDominant: TZEViewDominant;
    FGridTile: TZEViewEntity;
    FSelector: TZEViewEntity;
    FSpecialSprite: IZESprite;
  protected
    procedure DisposeTileData (TileData: TZETileData; lParam: integer); override;
    procedure SetDisplayLocation (ADisplayLocation: TPoint);
    function GetTerrain: IZESprite;
    procedure SetTerrain (ATerrain: IZESprite);
    procedure SetGridSprite (AGridSprite: IZESprite);
    function GetSelector: IZESprite;
    procedure SetSelector (ASelector: IZESprite);
    procedure DrawDirect (pLoc: TPoint; Sprite: IZESprite);
  public
    constructor Create (AOwner: TZECustomLevel); override;
    destructor Destroy; override;
    //
    procedure Draw (pLoc: TPoint; DrawPhase: TZEViewDrawPhase); virtual;
    function HasPoint (pLoc: TPoint): boolean;
    //
    procedure Add (Sprite: IZESprite);
    procedure Clear; override;
    //
    property DisplayLocation: TPoint read FDisplayLocation write SetDisplayLocation;
    property Terrain: TZEViewTerrain read FTerrain;
    property Floor: TZEViewFloor read FFloor;
    property Dominant: TZEViewDominant read FDominant;
    property Selector: IZESprite read GetSelector write SetSelector;
    property GridSprite: IZESprite write SetGridSprite;
    property SpecialSprite: IZESprite read FSpecialSprite write FSpecialSprite;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewLevel = class (TZECustomLevel)
  private
    FOrigin: TPoint;
    FTilesInView: TList;
    FTileSelected: TZEViewTile;
  protected
    procedure CreateTiles;
    procedure SetOrigin (AOrigin: TPoint);
    procedure ClearDirtyTilesList;
    procedure SetGridSprite (AGridSprite: IZESprite);
    //
    property IOrigin: TPoint read FOrigin write SetOrigin;
  public
    constructor Create (AOwner: TZECustomMap); override;
    destructor Destroy; override;
    //
    procedure SetDisplayLocations;
    procedure Draw (pLoc: TPoint); virtual;
    procedure BuildDirtyTilesList (pRef: TPoint; rView: TRect);
    //
    function FindTileAt (pLoc: TPoint): TZEViewTile;
    function NewTile (X, Y: integer): TZECustomTile; override;
    //
    property Origin: TPoint read FOrigin;
    property GridSprite: IZESprite write SetGridSprite;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewMap = class (TZECustomMap)
  private
    FScreenBounds: TRect;
    FMapViewport: TRect;
    FScreenCenter: TPoint;
    FViewIsDirty: boolean;
    FActiveLevel: integer;
    FHighlightSprite: IZESprite;
    FSelectionSprite: IZESprite;
    FTileSelected: TZEViewTile;
  protected
    procedure SetGridSprite (AGridSprite: IZESprite);
    procedure SetHighlightSprite (AHighlightSprite: IZESprite);
    procedure TranslateViewport (pDelta: TPoint);
    procedure ValidateVirtualView;
    procedure BuildDirtyList (pRef: TPoint; rView: TRect);
    procedure SetScreenBounds (AScreenBounds: TRect);
    procedure AdjustMapViewport;
    procedure SetActiveLevel (AActiveLevel: integer);
  public
    constructor Create (AWidth, AHeight: integer); override;
    destructor Destroy; override;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal); override;
    function NewLevel: TZECustomLevel; override;
    //
    procedure Center (iLevel, X, Y: integer); overload;
    procedure Center (Tile: TZEViewTile); overload;
    //
    function SelectTileAt (pLoc: TPoint): TZEViewTile;
    procedure PanVirtualView (Direction: TZEDirection; PanAmount: integer);
    procedure Draw; virtual;
    procedure PlaceSelectorAt (AWhereTile: TZEViewTile);
    //
    property GridSprite: IZESprite write SetGridSprite;
    property HighlightSprite: IZESprite write SetHighlightSprite;
    property SelectionSprite: IZESprite read FSelectionSprite write FSelectionSprite;
    property ScreenBounds: TRect read FScreenBounds write SetScreenBounds;
    property ViewIsDirty: boolean read FViewIsDirty write FViewIsDirty;
    property ActiveLevel: integer read FActiveLevel write SetActiveLevel;
  end;

var
  ViewInEditMode: boolean = false;
  

implementation

uses
  SysUtils,
  ZbRectClipper,
  ZEDXDev;


{ TZEViewEntity }

//////////////////////////////////////////////////////////////////////////
constructor TZEViewEntity.Create(AOwner: TZECustomTile);
begin
  FOwner := AOwner;
  FSprite := NIL;
  FCurrentOffset := Point (0, 0);
  FDeltaOffset := Point (0, 0);
  FDrawSelector := false;
  //
  FUpdates := false;
  FLastTick := GlobalLastTick;
  FAnimated := false;
  FAnimationDelay := 0;
  FAnimationTimer := TZE_SimpleTimeTrigger.Create (0);
  FOnAnimationEndProc := NIL;
  //
  FIsMoving := false;
  FMoveSteps := 0;
  FOnMotionStopped := NIL;
  //
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewEntity.Destroy;
begin
  FAnimationTimer.Free;
  FSprite := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.SetSprite (ASprite: IZESprite);
begin
  FSprite := NIL;
  FSprite := ASprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.SetDeltaOffset (ADeltaOffset: TPoint);
begin
  FDeltaOffset := ADeltaOffset;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.ChangeOffset (WhatChange: TZEViewOffsetChange);
begin
  case WhatChange of
    vocDecrease:
      FCurrentOffset := SubPoint (FCurrentOffset, FDeltaOffset);
    vocReset:
      FCurrentOffset := Point (0, 0);
    vocIncrease:
      FCurrentOffset := AddPoint (FCurrentOffset, FDeltaOffset);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.SetAnimated (AAnimated: boolean);
begin
  if (FAnimated <> AAnimated) then
    begin
      FAnimated := AAnimated;
      if (FAnimated) then
        begin
          if (FAnimationDelay = 0) then FAnimationDelay := DEFAULT_ANIMATION_DELAY;
          FLastTick := GlobalLastTick;
          FAnimationTimer.Reset;
          FAnimationTimer.TriggerValue := FAnimationDelay;
        end;
      //
      FUpdates := (FAnimated OR FIsMoving)
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.SetAnimationDelay (AAnimationDelay: Cardinal);
begin
  FAnimationDelay := AAnimationDelay;
  if (Animated) then
    begin
      FLastTick := GlobalLastTick;
      FAnimationTimer.Reset;
      FAnimationTimer.TriggerValue := FAnimationDelay;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.Update (WTicksElapsed: Cardinal);
var
  bAdvanceFrame: boolean;
  bContinue: boolean;
begin
  if (Sprite = NIL) OR (NOT Animated) then Exit;
  //
  bAdvanceFrame := FAnimationTimer.CheckResetTrigger (WTicksElapsed);
  if (bAdvanceFrame) then
    begin
      bContinue := true;
      if (Sprite.AtLastFrame) AND (Assigned (FOnAnimationEndProc)) then
        bContinue := FOnAnimationEndProc (Self);
      //
      if (bContinue) then
        begin
          Sprite.CycleFrameForward;
          if (IsMoving) then
            begin
              ChangeOffset (vocIncrease);
              Inc (FMoveSteps);
              if (FMoveSteps >= MAX_MOVE_STEPS) then FullStop;
            end;
          //
        end;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.Draw (pLoc: TPoint);
var
  SelSprite: IZESprite;
  pRef: TPoint;
begin
  if (Sprite = NIL) then Exit;
  //
  if (DrawSelector) then begin
    SelSprite := TZEViewTile (Owner).Selector;
    if (SelSprite <> NIL) then begin
      pRef.Y := pLoc.Y - (SelSprite.Height - TileProps.TileHeight);
      pRef.X := pLoc.X - ((SelSprite.Width - TileProps.TileWidth) div 2);
    end;
  end else
    SelSprite := NIL;
  //
  // make sure the tile is centered on the sprite
  pLoc.Y := pLoc.Y - (Sprite.Height - TileProps.TileHeight);
  pLoc.X := pLoc.X - ((Sprite.Width - TileProps.TileWidth) div 2);
  //
  // add the offset, if any
  if (FCurrentOffset.X <> 0) OR (FCurrentOffset.Y <> 0) then begin
    pLoc := AddPoint (pLoc, FCurrentOffset);
    if (SelSprite <> NIL) then pRef := AddPoint (pRef, FCurrentOffset);
  end;
  //
  // draw the selector first of course
  if (SelSprite <> NIL) then begin
    SelSprite.Position := pRef;
    SelSprite.Draw (true);
  end;
  //
  // position the sprite first, then draw it
  Sprite.Position := pLoc;
  Sprite.Draw (true);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.Move (dWhere: TZEDirection);
begin
  if (dWhere = tdUnknown) then Exit;
  FDeltaOffset := __DirOffset [dWhere];
  FIsMoving := true;
  FMoveSteps := 0;
  FUpdates := (FAnimated OR FIsMoving)
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewEntity.AnimationForward: boolean;
begin
  Result := Sprite.AtLastFrame;
  Sprite.CycleFrameForward;
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewEntity.AnimationBackward: boolean;
begin
  Result := Sprite.AtFirstFrame;
  Sprite.CycleFrameBackward;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewEntity.FullStop;
begin
  FIsMoving := false;
  FMoveSteps := 0;
  FDeltaOffset := Point (0, 0);
  FUpdates := (FAnimated OR FIsMoving);
  if (Assigned (FOnMotionStopped)) then FOnMotionStopped (Self);
end;


{ TZEViewTerrain }

//////////////////////////////////////////////////////////////////////////
constructor TZEViewTerrain.Create (AOwner: TZECustomTile);
begin
  inherited;
  //
  FHeight := 0;
  FTransitions := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewTerrain.Destroy;
begin
  ClearTransitions;
  FTransitions.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTerrain.Draw (pLoc: TPoint);
var
  iIndex: integer;
  TransitionImage: TZEViewEntity;
begin
  inherited;
  //
  if (FTransitions <> NIL) then
    for iIndex := 0 to Pred (FTransitions.Count) do
      begin
        TransitionImage := TZEViewEntity (FTransitions [iIndex]);
        if (TransitionImage <> NIL) then TransitionImage.Draw (pLoc);
        //
      end;
    //
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTerrain.ClearTransitions;
var
  iIndex: integer;
  TransitionImage: TZEViewEntity;
begin
  if (FTransitions = NIL) then Exit;
  for iIndex := 0 to Pred (FTransitions.Count) do
    begin
      TransitionImage := TZEViewEntity (FTransitions [iIndex]);
      if (TransitionImage <> NIL) then
        begin
          TransitionImage.Free;
          FTransitions [iIndex] := NIL;
        end;
      //
    end;
  //
  FTransitions.Pack;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTerrain.AddTransition (Transition: TZEViewEntity);
begin
  if (Transition <> NIL) then
    FTransitions.Add (Pointer (Transition));
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTerrain.AddTransition (TransitionSprite: IZESprite);
var
  Transition: TZEViewEntity;
begin
  if (TransitionSprite = NIL) then Exit;
  Transition := TZEViewEntity.Create (Owner);
  Transition.Sprite := TransitionSprite;
  AddTransition (Transition);
end;

{ TZEViewTile }

//////////////////////////////////////////////////////////////////////////
constructor TZEViewTile.Create (AOwner: TZECustomLevel);
begin
  inherited;
  FDisplayLocation := Point (0, 0);
  FDisplayBounds := Rect (0, 0, 0, 0);
  FTerrain := TZEViewTerrain.Create (Self);
  FFloor := TZEViewFloor.Create (Self);
  FDominant := TZEViewDominant.Create (Self);
  FGridTile := TZEViewEntity.Create (Self);
  FSelector := TZEViewEntity.Create (Self);
  FSpecialSprite := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewTile.Destroy;
begin
  FreeAndNIL (FTerrain);
  FreeAndNIL (FFloor);
  FreeAndNIL (FDominant);
  FreeAndNIL (FGridTile);
  FreeAndNIL (FSelector);
  FSpecialSprite := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.DisposeTileData (TileData: TZETileData; lParam: integer);
begin
  if (TileData <> NIL) then TZEViewEntity (TileData).Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetDisplayLocation (ADisplayLocation: TPoint);
begin
  FDisplayLocation := ADisplayLocation;
  with FDisplayLocation do
    FDisplayBounds := Rect (X, Y, X + TileProps.TileWidth, Y + TileProps.TileHeight);
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewTile.GetTerrain: IZESprite;
begin
  Result := FTerrain.Sprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetTerrain (ATerrain: IZESprite);
begin
  FTerrain.Sprite := ATerrain;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetGridSprite (AGridSprite: IZESprite);
begin
  FGridTile.Sprite := AGridSprite;
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewTile.GetSelector: IZESprite;
begin
  if (Owner <> NIL) AND (Owner.Owner <> NIL) then
    Result := TZEViewMap (Owner.Owner).SelectionSprite
  else
    Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetSelector (ASelector: IZESprite);
begin
  FSelector.Sprite := ASelector;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.DrawDirect (pLoc: TPoint; Sprite: IZESprite);
begin
  // displace location with our TopLeft
  pLoc := AddPoint (pLoc, (Owner as TZEViewLevel).Origin);
  pLoc := AddPoint (pLoc, FDisplayLocation);
  // make sure the tile is centered on the sprite
  pLoc.Y := pLoc.Y - (Sprite.Height - TileProps.TileHeight);
  pLoc.X := pLoc.X - ((Sprite.Width - TileProps.TileWidth) div 2);
  //
  // position the sprite first, then draw it
  Sprite.Position := pLoc;
  Sprite.Draw (true);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.Draw (pLoc: TPoint; DrawPhase: TZEViewDrawPhase);
var
  iIndex: integer;
  ViewEntity: TZEViewEntity;
begin
  if (FTerrain.Sprite = NIL) then
    begin
      if (ViewInEditMode) then FGridTile.Draw (AddPoint (pLoc, FDisplayLocation));
      Exit;
    end;
  //
  pLoc := AddPoint (pLoc, FDisplayLocation);
  if (DrawPhase = dpSurface) then begin
    //
    // draws the terrain and its associated transitions
    FTerrain.Draw (pLoc);
    for iIndex := 0 to Pred (FTerrain.FTransitions.Count) do
      begin
        ViewEntity := TZEViewEntity (FTerrain.FTransitions [iIndex]);
        if (ViewEntity <> NIL) then ViewEntity.Draw (pLoc);
      end;
    //
    // draws the floor
    if (FFloor.Sprite <> NIL) then FFloor.Draw (pLoc);
    //
    if (FSpecialSprite <> NIL) AND (ViewInEditMode) then begin
      FSpecialSprite.Position := pLoc;
      FSpecialSprite.Draw (true);
    end;
    //
  end else begin
    // draw the selector sprite, if present
    if (FSelector.Sprite <> NIL) AND (NOT ViewInEditMode) then FSelector.Draw (pLoc);
    //
    for iIndex := 0 to Pred (Count) do
      begin
        ViewEntity := TZEViewEntity (Self [iIndex]);
        if (ViewEntity = NIL) then continue;
        ViewEntity.Draw (pLoc);
      end;
    //
    if (FDominant.Sprite <> NIL) then FDominant.Draw (pLoc);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewTile.HasPoint (pLoc: TPoint): boolean;
var
  bFirstTest: boolean;
begin
  with FDisplayBounds, pLoc do
    bFirstTest := (X >= Left) AND (X < Right) AND
                  (Y >= Top) AND (Y < Bottom);
  //
  if (bFirstTest) then
    begin
      Dec (pLoc.X, FDisplayBounds.Left);
      Dec (pLoc.Y, FDisplayBounds.Top);
      bFirstTest := TileProps [pLoc.X, pLoc.Y];
    end;
  //
  Result := bFirstTest;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.Add (Sprite: IZESprite);
var
  ViewEntity: TZEViewEntity;
begin
  if (Sprite <> NIL) then
    begin
      ViewEntity := TZEViewEntity.Create (Self);
      ViewEntity.Sprite := Sprite;
      AddTileData (TZETileData (ViewEntity));
    end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.Clear;
begin
  inherited;
  if (FTerrain <> NIL) then begin
    FTerrain.Sprite := NIL;
    FTerrain.ClearTransitions;
  end;
  if (FFloor <> NIL) then FFloor.Sprite := NIL;
  if (FDominant <> NIL) then FDominant.Sprite := NIL;
end;

{ TZEViewLevel }

//////////////////////////////////////////////////////////////////////////
constructor TZEViewLevel.Create (AOwner: TZECustomMap);
begin
  inherited;
  FOrigin := Point (0, 0);
  FTilesInView := TList.Create;
  FTileSelected := NIL;
  //
  CreateTiles;
  SetDisplayLocations;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewLevel.Destroy;
begin
  ClearDirtyTilesList;
  FTilesInView.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.CreateTiles;
var
  X, Y: integer;
begin
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do
      NewTile (X, Y);
      //Self [X, Y] := TZEViewTile.Create (Self);
    //
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.SetOrigin (AOrigin: TPoint);
begin
  FOrigin := AOrigin;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.SetGridSprite (AGridSprite: IZESprite);
var
  X, Y: integer;
  ViewTile: TZEViewTile;
begin
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do
      begin
        ViewTile := TZEViewTile (Self [X, Y]);
        if (ViewTile <> NIL) then
          ViewTile.GridSprite := AGridSprite;
        //
      end;
    //
  //
end;

//////////////////////////////////////////////////////////////////////////

  // ************************************************************
  procedure VL_SDL_LoopHandler (Tile: TZECustomTile;
    iLoopCount: integer; LoopPhase: TZEScannerLoopPhase;
    lParam1, lParam2: integer);
  var
    pStart: PPoint absolute lParam1;
    pPosition: PPoint absolute lParam2;
  begin
    case iLoopCount of
      1:
        case LoopPhase of
          //llpLoopOuterInit: (* already handled this one *)
          //llpLoopInnerPreProcess: (* nothing to do for this one *)

          llpLoopInnerInit:
            pPosition^ := pStart^;

          llpLoopInnerPostProcess:
            Inc (pPosition.X, TileProps.TileWidth);

          llpLoopOuterTailEnd:
            begin
              Dec (pStart.X, TileProps.TileHalfWidth);
              Inc (pStart.Y, Succ (TileProps.TileHalfHeight));
            end;
        end;
      2:
        case LoopPhase of
          //llpLoopInnerPreProcess: (* nothing to do here *)

          llpLoopOuterInit:
            Inc (pStart.X, TileProps.TileWidth);

          llpLoopInnerInit:
            pPosition^ := pStart^;

          llpLoopInnerPostProcess:
            Inc (pPosition.X, TileProps.TileWidth);

          llpLoopOuterTailEnd:
            begin
              Inc (pStart.X, TileProps.TileHalfWidth);
              Inc (pStart.Y, Succ (TileProps.TileHalfHeight));
            end;
        end;
    end;
  end;

  // ************************************************************
  function VL_SDL_SetLocation (Tile: TZECustomTile; lParam1, lParam2: integer): boolean;
  var
    pStart: PPoint absolute lParam1;
    pPosition: PPoint absolute lParam2;
  begin
    (Tile as TZEViewTile).DisplayLocation := pPosition^;
    Result := false;
  end;

  // ************************************************************

procedure TZEViewLevel.SetDisplayLocations;
var
  pStart, pPosition: TPoint;
begin
  if (NOT Assigned (Scanner)) then Exit;
  //
  pStart := Point (((Pred (Height) * TileProps.TileWidth) div 2), 0);
  pPosition := Point (0, 0);
  //
  Scanner (VL_SDL_SetLocation, VL_SDL_LoopHandler, integer (@pStart), integer (@pPosition));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.ClearDirtyTilesList;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FTilesInView.Count) do
    FTilesInView [iIndex] := NIL;
  //
  FTilesInView.Pack;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.Draw (pLoc: TPoint);
var
  iIndex: integer;
  ViewTile: TZEViewTile;
  DrawPhase: TZEViewDrawPhase;
begin
  pLoc := AddPoint (pLoc, Origin);
  for DrawPhase := dpSurface to dpInhabitants do begin
    for iIndex := 0 to Pred (FTilesInView.Count) do begin
      ViewTile := TZEViewTile (FTilesInView [iIndex]);
      if (ViewTile <> NIL) then ViewTile.Draw (pLoc, DrawPhase);
    end;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////

  type
    PZEDirtyTileInfo = ^TZEDirtyTileInfo;
    TZEDirtyTileInfo = record
      pRef: TPoint;
      rView: TRect;
      List: TList;
    end;

  // ************************************************************************
  function VL_BDTL_Processor (Tile: TZECustomTile; lParam1, lParam2: integer): boolean;
  var
    DTI: PZEDirtyTileInfo absolute lParam1;
    P: TPoint;
  begin
    Result := false;
    //
    P := AddPoint (DTI.pRef, (Tile as TZEViewTile).DisplayLocation);
    if (P.X >= DTI.rView.Right) OR (P.Y >= DTI.rView.Bottom) then Exit;
    //
    P := AddPoint (P, Point (TileProps.TileWidth, TileProps.TileHeight));
    if (P.X <= DTI.rView.Left) OR (P.Y <= DTI.rView.Top) then Exit;
    //
    DTI.List.Add (Pointer (Tile));
  end;

  // ************************************************************************

procedure TZEViewLevel.BuildDirtyTilesList (pRef: TPoint; rView: TRect);
var
  DTI: TZEDirtyTileInfo;
begin
  ClearDirtyTilesList;
  if (NOT Assigned (Scanner)) then Exit;
  //
  pRef := AddPoint (pRef, FOrigin);
  DTI.pRef := pRef;
  DTI.rView := rView;
  DTI.List := FTilesInView;
  //
  Scanner (VL_BDTL_Processor, NIL, integer (@DTI), 0);
end;

//////////////////////////////////////////////////////////////////////////

  //************************************************************
  function VL_FTA_Processor (Tile: TZECustomTile; lParam1, lParam2: integer): boolean;
  var
    pRef: PPoint absolute lParam1;
  begin
    // if tile has point, it claims it
    Result := (Tile as TZEViewTile).HasPoint (pRef^);
    // however, even if tile has the point, we still check if it's empty
    // -- i.e., there is no entity in there!  if there isn't any, we must
    // be in edit mode for this claim to be valid.
    //if (Result AND (Tile.Count = 0)) then
    //  Result := Result AND ViewInEditMode;
  end;

function TZEViewLevel.FindTileAt (pLoc: TPoint): TZEViewTile;
begin
  pLoc := SubPoint (pLoc, Origin);
  if ((FTileSelected  = NIL) OR (NOT FTileSelected.HasPoint (pLoc))) then
    FTileSelected := TZEViewTile (Scanner (VL_FTA_Processor, NIL, integer (@pLoc), 0));
  //
  Result := FTileSelected;
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewLevel.NewTile (X, Y: integer): TZECustomTile;
begin
  Result := AddTile (X, Y, TZEViewTile);
end;

{ TZEViewMap }

//////////////////////////////////////////////////////////////////////////
constructor TZEViewMap.Create (AWidth, AHeight: integer);
begin
  inherited;
  FScreenBounds := Rect (0, 0, 0, 0);
  FMapViewport := Rect (0, 0, 0, 0);
  FScreenCenter := Point (0, 0);
  FViewIsDirty := true;
  FHighlightSprite := NIL;
  FTileSelected := NIL;
  FSelectionSprite := NIL;
  //
  AdjustMapViewport;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewMap.Destroy;
begin
  FHighlightSprite := NIL;
  FSelectionSprite := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.PerformUpdate (WTicksElapsed: Cardinal);
{var
  X, Y, Z: integer;
  Level: TZEViewLevel;
  Tile: TZEViewTile;}
begin
  {for Z := 0 to Pred (Count) do  begin
    Level := TZEViewLevel (Self [Z]);
    if (Level = NIL) then continue;
    for X := 0 to Pred (Level.Width) do
      for Y := 0 to Pred (Level.Height) do begin
        Tile := TZEViewTile (Level [X, Y]);
        if (Tile = NIL) then continue;
        if (Tile.Dominant.FUpdates) then Tile.Dominant.Update (WTicksElapsed);
        // TODO: check if other stuff need to update other than the dominant
      end;
    //
  end}
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewMap.NewLevel: TZECustomLevel;
var
  iIndex: integer;
  Level: TZEViewLevel;

  procedure AdjustLevelHeight (ALevel: TZEViewLevel);
  begin
    ALevel.IOrigin := AddPoint (ALevel.IOrigin, Point (0, TileProps.LevelHeight));
  end;

begin
  Result := AddLevel (TZEViewLevel);
  if (Result <> NIL) then
    begin
      for iIndex := 0 to Pred (Count) do
        begin
          Level := TZEViewLevel (Self [iIndex]);
          if (Level = NIL) then continue;
          AdjustLevelHeight (Level);
        end;
      //
      AdjustMapViewport;
      FActiveLevel := Pred (Count);
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.SetGridSprite (AGridSprite: IZESprite);
var
  iIndex: integer;
  Level: TZEViewLevel;
begin
  for iIndex := 0 to Pred (Count) do
    begin
      Level := TZEViewLevel (Self [iIndex]);
      if (Level = NIL) then continue;
      Level.GridSprite := AGridSprite;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.SetHighlightSprite (AHighlightSprite: IZESprite);
begin
  FHighlightSprite := NIL;
  FHighlightSprite := AHighlightSprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.TranslateViewport (pDelta: TPoint);
begin
  with FMapViewport do
    begin
      TopLeft := AddPoint (TopLeft, pDelta);
      BottomRight := AddPoint (BottomRight, pDelta);
    end;
  //
  ValidateVirtualView;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.ValidateVirtualView;
var
  iDelta: integer;
begin
  if (FMapViewport.Left > FScreenBounds.Left) then
    begin
      iDelta := FMapViewport.Left - FScreenBounds.Left;
      Dec (FMapViewport.Left, iDelta);
      Dec (FMapViewport.Right, iDelta);
    end;
  //
  if (FMapViewport.Top > FScreenBounds.Top) then
    begin
      iDelta := FMapViewport.Top - FScreenBounds.Top;
      Dec (FMapViewport.Top, iDelta);
      Dec (FMapViewport.Bottom, iDelta);
    end;
  //
  if (FMapViewport.Right < FScreenBounds.Right) then
    begin
      iDelta := FScreenBounds.Right - FMapViewport.Right;
      Inc (FMapViewport.Left, iDelta);
      Inc (FMapViewport.Right, iDelta);
    end;
  //
  if (FMapViewport.Bottom < FScreenBounds.Bottom) then
    begin
      iDelta := FScreenBounds.Bottom - FMapViewport.Bottom;
      Inc (FMapViewport.Top, iDelta);
      Inc (FMapViewport.Bottom, iDelta);
    end;
  //
  ViewIsDirty := true;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.BuildDirtyList (pRef: TPoint; rView: TRect);
var
  iIndex: integer;
  Level: TZEViewLevel;
begin
  for iIndex := 0 to Pred (Count) do
    begin
      Level := TZEViewLevel (Self [iIndex]);
      if (Level = NIL) then continue;
      Level.BuildDirtyTilesList (pRef, rView);
    end;
  //
  ViewIsDirty := false;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.SetScreenBounds (AScreenBounds: TRect);
var
  delta: TPoint;
begin
  // set screen rectangle
  FScreenBounds := AScreenBounds;
  // calculate how much to adjust the virtual rectangle
  delta := SubPoint (FScreenBounds.TopLeft, FMapViewport.TopLeft);
  // and adjust it
  TranslateViewport (delta);
  // calculate the dimensions of the whole view rectangle
  // and also of the center tile
  with FScreenBounds, FScreenCenter do
    begin
      X := Left + ((Right - Left) div 2) - TileProps.TileHalfWidth;
      Y := Top + ((Bottom - Top) div 2) - TileProps.TileHalfHeight;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.AdjustMapViewport;
begin
  with FMapViewport, Dimension do
    begin
      Left    := 0;
      Top     := 0;
      Right   := ((X + Y) * TileProps.TileWidth) div 2;
      Bottom  := ((X + Y) * TileProps.TileHalfHeight) +
                 (X + Y - 1) +
                 (TileProps.LevelHeight * Succ (Count));
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.SetActiveLevel (AActiveLevel: integer);
begin
  if (FActiveLevel <> AActiveLevel) AND (AActiveLevel >= 0) AND
     (AActiveLevel < Count) then
        FActiveLevel := AActiveLevel;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.Center (iLevel, X, Y: integer);
var
  Level: TZEViewLevel;
begin
  // check if level is ok
  Level := TZEViewLevel (Self [iLevel]);
  if (Level = NIL) then Exit;
  //
  Center (TZEViewTile (Level [X, Y]));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.Center (Tile: TZEViewTile);
var
  delta: TPoint;
  pTarget: TPoint;
begin
  //
  if (Tile <> NIL) then
    begin
      pTarget := Tile.DisplayLocation;
      if (Tile.Owner <> NIL) then
        PTarget := AddPoint (pTarget, (Tile.Owner as TZEViewLevel).Origin);
      //
      pTarget := AddPoint (pTarget, FMapViewport.TopLeft);
      delta := SubPoint (FScreenCenter, pTarget);
      //
      TranslateViewport (delta);
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewMap.SelectTileAt (pLoc: TPoint): TZEViewTile;
var
  iIndex: integer;
  Level: TZEViewLevel;
begin
  Result := NIL;
  //
  pLoc := AddPoint (pLoc, SubPoint (FScreenBounds.TopLeft, FMapViewport.TopLeft));
  //
  for iIndex := FActiveLevel downto 0 do
    begin
      Level := TZEViewLevel (Self [iIndex]);
      if (Level = NIL) then continue;
      Result := Level.FindTileAt (pLoc);
      if (Result <> NIL) then Exit;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.PanVirtualView (Direction: TZEDirection; PanAmount: integer);
begin
  case Direction of
    tdNorth:          TranslateViewport (Point (0, -PanAmount));
    tdNorthEast:      TranslateViewport (Point (PanAmount, -PanAmount));
    tdEast:           TranslateViewport (Point (PanAmount, 0));
    tdSouthEast:      TranslateViewport (Point (PanAmount, PanAmount));
    tdSouth:          TranslateViewport (Point (0, PanAmount));
    tdSouthWest:      TranslateViewport (Point (-PanAmount, PanAmount));
    tdWest:           TranslateViewport (Point (-PanAmount, 0));
    tdNorthWest:      TranslateViewport (Point (-PanAmount, -PanAmount));
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.Draw;
var
  rView: TRect;
  iIndex: integer;
  Level: TZEViewLevel;
begin
  if (Count <= 0) then Exit;
  //
  if (ViewIsDirty) then
    begin
      rView := FScreenBounds;
      Inc (rView.Bottom, TileProps.TileHeight + TileProps.LevelHeight);
      BuildDirtyList (FMapViewport.TopLeft, rView);
    end;
  //
  GlobalClipper.SetClippingRegion (FScreenBounds);
  for iIndex := 0 to FActiveLevel {Pred (Count)} do
    begin
      Level := TZEViewLevel (Self [iIndex]);
      if (Level <> NIL) then Level.Draw (FMapViewport.TopLeft);
    end;
  //
  if (FTileSelected <> NIL) AND (FHighlightSprite <> NIL) then
    FTileSelected.DrawDirect (FMapViewport.TopLeft, FHighlightSprite);
  //
  GlobalClipper.ClearClippingRegion;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.PlaceSelectorAt (AWhereTile: TZEViewTile);
begin
  if (FTileSelected = AWhereTile) then Exit;
  FTileSelected := AWhereTile;
end;


end.

