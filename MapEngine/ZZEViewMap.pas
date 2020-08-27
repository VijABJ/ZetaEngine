{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEViewMap.PAS
              This class adds some properties/routines to TZEMap in
              order to support drawing to the screen
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/MapEngine/ZZEViewMap.pas,v 1.5 2002/12/18 08:21:04 Vij Exp $
  $Log: ZZEViewMap.pas,v $
  Revision 1.5  2002/12/18 08:21:04  Vij
  streamlined map-event notifications.

  Revision 1.4  2002/11/02 06:57:42  Vij
  support for sprites of portals added.

  Revision 1.3  2002/10/01 12:41:05  Vij
  Added facilities to support Save/Load

  Revision 1.2  2002/09/17 22:19:59  Vij
  Split the Draw() method into stages, and then coded separate methods for
  each of them.  Added option to hook Draw() methods, and the method
  that builds the Visible Tiles List.  Wall drawing code temporarily disabled.

  Revision 1.1.1.1  2002/09/11 21:11:33  Vij
  Starting Version Control


 ============================================================================}
 
unit ZZEViewMap;

interface

uses
  Types,
  Classes,
  ZbGameUtils,
  ZbFileIntf,
  //
  ZEDXSpriteIntf,
  ZZESupport,
  ZZEMap;

type
  TZEViewTile = class;
  TZEViewLevel = class;
  TZEViewMap = class;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETileNoticeProc = procedure (AtTile: TZEViewTile) of Object;
  TZEViewListNoticeProc = procedure (AMap: TZEViewMap) of Object;
  TZEDrawProc = procedure (pReference: TPoint) of Object;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewTile = class (TZETile)
  private
    FScrOrigin: TPoint;
    FScrSpan: TPoint;
    FScrBounds: TRect;
    FOnScreen: boolean;
    FUserData: Pointer;
    // working vars...
    FDrawRef: TPoint;
    FSelected: boolean;
    FInFrontOfActive: boolean;
  protected
    procedure SetBounds;
    procedure SetScrOrigin (AOrigin: TPoint);
    procedure SetScrWidth (AScrWidth: integer);
    procedure SetScrHeight (AScrHeight: integer);
  public
    constructor Create (AOwner: TZELEvel; Reader: IZbFileReader = NIL); override;
    destructor Destroy; override;
    //
    procedure DrawFarWalls;
    procedure DrawNearWalls;
    procedure DrawSurfaces;
    procedure BeginDraw (pReference: TPoint);
    //
    procedure DrawDirect (pReference: TPoint; Sprite: IZESprite);
    procedure Draw (pReference: TPoint);
    function HasPoint (pLocation: TPoint): boolean;
    //
    property ScrOrigin: TPoint read FScrOrigin write SetScrOrigin;
    property ScrWidth: integer read FScrSpan.X write SetScrWidth;
    property ScrHeight: integer read FScrSpan.Y write SetScrHeight;
    property ScrBounds: TRect read FScrBounds;
    property OnScreen: boolean read FOnScreen;
    property UserData: Pointer read FUserData write FUserData;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewLevel = class (TZELevel)
  private
    FScrOrigin: TPoint;
    FTilesInView: TList;
    FTileSelected: TZEViewTile;
    //
    FOnDraw: TZEDrawProc;
    FUserData: Pointer;
  protected
    function NewTile (X, Y: integer; Reader: IZbFileReader): TZETile; override;
    //
    procedure SetScrOrigin (AScrOrigin: TPoint);
    procedure ClearDirtyTilesList;
    procedure BuildDirtyTilesList (pReference: TPoint; rView: TRect);
  public
    constructor Create (AOwner: TZEMap; Reader: IZbFileReader = NIL); override;
    destructor Destroy; override;
    //
    procedure SetDisplayLocations;
    procedure Draw (pReference: TPoint);
    function FindTileAt (pLoc: TPoint): TZEViewTile;
    //
    property ScrOrigin: TPoint read FScrOrigin write SetScrOrigin;
    property OnDraw: TZEDrawProc read FOnDraw write FOnDraw;
    property UserData: Pointer read FUserData write FUserData;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEViewMap = class (TZEMap)
  private
    FScreenBounds: TRect;
    FMapViewport: TRect;
    FScreenCenter: TPoint;
    FViewIsDirty: boolean;
    FActiveLevel: integer;
    FTileSelected: TZEViewTile;
    //
    FBeforeViewListRebuild: TZEViewListNoticeProc;
    FAfterViewListRebuild: TZEViewListNoticeProc;
    FTileIncluded: TZETileNoticeProc;
    FOnDraw: TZEDrawProc;
  protected
    procedure CommonInit;
    procedure PostProcessLevel (Level: TZELevel); override;
    function LoadLevel (Reader: IZbFileReader): TZELevel; override;
    procedure TranslateViewport (pDelta: TPoint);
    procedure ValidateVirtualView;
    procedure BuildDirtyList (pReference: TPoint; rView: TRect);
    procedure SetScreenBounds (AScreenBounds: TRect);
    procedure AdjustMapViewport;
    procedure SetActiveLevel (AActiveLevel: integer);
    procedure SetDrawProc (ADrawProc: TZEDrawProc);
    //
    procedure Notice_TileAdded (ATile: TZEViewTile);
    procedure Notice_BeforeViewListBuild;
    procedure Notice_AfterViewListBuilt;
  public
    constructor Create (AWidth, AHeight: integer); overload; override;
    constructor Create (Reader: IZbFileReader); overload; override;
    destructor Destroy; override;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal); override;
    function NewLevel: TZELevel; override;
    //
    procedure Center (iLevel, X, Y: integer); overload;
    procedure Center (Tile: TZEViewTile); overload;
    //
    procedure MapLevelUp;
    procedure MapLevelDown;
    //
    function SelectTileAt (pLoc: TPoint): TZEViewTile;
    procedure PanVirtualView (Direction: TZbDirection; PanAmount: integer);
    procedure Draw;
    procedure PlaceSelectorAt (AWhereTile: TZEViewTile);
    //
    property ScreenBounds: TRect read FScreenBounds write SetScreenBounds;
    property ViewIsDirty: boolean read FViewIsDirty write FViewIsDirty;
    property ActiveLevel: integer read FActiveLevel write SetActiveLevel;
    //
    property BeforeViewListRebuild: TZEViewListNoticeProc
      read FBeforeViewListRebuild write FBeforeViewListRebuild;
    property AfterViewListRebuild: TZEViewListNoticeProc
      read FAfterViewListRebuild write FAfterViewListRebuild;
    property TileIncluded: TZETileNoticeProc
      read FTileIncluded write FTileIncluded;
    property OnDraw: TZEDrawProc read FOnDraw write SetDrawProc;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESpecialSprites = class
  private
    m_Grid: IZESprite;
    m_BlockedGrid: IZESprite;
    m_Highlight: IZESprite;
    m_Selection: IZESprite;
    m_Transition: IZESprite;
    m_Start: IZESprite;
  protected
    procedure SetGrid (ASprite: IZESprite);
    procedure SetBlockedGrid (ASprite: IZESprite);
    procedure SetHighlight (ASprite: IZESprite);
    procedure SetSelection (ASprite: IZESprite);
    procedure SetTransition (ASprite: IZESprite);
    procedure SetStart (ASprite: IZESprite);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearAll;
    //
    property Grid: IZESprite read m_Grid write SetGrid;
    property BlockedGrid: IZESprite read m_BlockedGrid write SetBlockedGrid;
    property Highlight: IZESprite read m_Highlight write SetHighlight;
    property Selection: IZESprite read m_Selection write SetSelection;
    property Transition: IZESprite read m_Transition write SetTransition;
    property Start: IZESprite read m_Start write SetStart;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
var
  GlobalViewEditMode: boolean = FALSE;
  GlobalViewShowGrid: boolean = FALSE;
  GlobalViewShowPortals: boolean = FALSE;
  g_SpecialSprites: TZESpecialSprites = NIL;
  g_VisibleHighlight: boolean = TRUE;


implementation

uses
  SysUtils,
  ZbRectClipper,
  ZbDebug,
  ZZEWorldIntf;

var
  _IBlendArea: TRect;

{ TZEViewTile }

//////////////////////////////////////////////////////////////////////////
constructor TZEViewTile.Create (AOwner: TZELEvel; Reader: IZbFileReader);
begin
  inherited;
  FScrOrigin := Point (0, 0);
  FScrSpan := Point (0, 0);
  FScrBounds := Rect (0, 0, 0, 0);
  FOnScreen := FALSE;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewTile.Destroy;
begin
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetBounds;
begin
  FScrBounds.TopLeft := FScrOrigin;
  FScrBounds.BottomRight := AddPoint (FScrOrigin, FScrSpan);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetScrOrigin (AOrigin: TPoint);
begin
  FScrOrigin := AOrigin;
  SetBounds;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetScrWidth (AScrWidth: integer);
begin
  FScrSpan.X := AScrWidth;
  SetBounds;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.SetScrHeight (AScrHeight: integer);
begin
  FScrSpan.Y := AScrHeight;
  SetBounds;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.DrawFarWalls;
var
  wSprite: IZESprite;
  pWallAnchor: TPoint;
begin
  // check the west wall...
  if (WallSprites [wpWest] <> NIL) then begin
    wSprite := WallSprites [wpWest];
    pWallAnchor.X := FDrawRef.X;
    pWallAnchor.Y := FDrawRef.Y + TileProps.TileHalfHeight - wSprite.Height;// + WALL_FUDGE_Y;
    wSprite.Position := pWallAnchor;
    wSprite.UseAlpha := (FInFrontOfActive) AND RectIntersects (_IBlendArea, wSprite.Bounds);
    wSprite.Alpha := 128;
    wSprite.Draw (TRUE);
  end;
  // and the north wall
  if (WallSprites [wpNorth] <> NIL) then begin
    wSprite := WallSprites [wpNorth];
    pWallAnchor.X := FDrawRef.X + TileProps.TileWidth - wSprite.Width;
    pWallAnchor.Y := FDrawRef.Y + TileProps.TileHalfHeight - wSprite.Height + 3;
    wSprite.Position := pWallAnchor;
    wSprite.UseAlpha := (FInFrontOfActive) AND RectIntersects (_IBlendArea, wSprite.Bounds);
    wSprite.Alpha := 128;
    wSprite.Draw (TRUE);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.DrawNearWalls;
var
  wSprite: IZESprite;
  pWallAnchor: TPoint;
begin
  // draw the south wall
  if (WallSprites [wpSouth] <> NIL) then begin
    wSprite := WallSprites [wpSouth];
    pWallAnchor.X := FDrawRef.X;
    pWallAnchor.Y := FDrawRef.Y + TileProps.TileHeight - wSprite.Height;
    wSprite.Position := pWallAnchor;
    wSprite.UseAlpha := FSelected OR (FInFrontOfActive AND RectIntersects (_IBlendArea, wSprite.Bounds));
    wSprite.Alpha := 128;
    wSprite.Draw (TRUE);
  end;
  // and then the east wall
  if (WallSprites [wpEast] <> NIL) then begin
    wSprite := WallSprites [wpEast];
    pWallAnchor.X := FDrawRef.X + TileProps.TileWidth - wSprite.Width;
    pWallAnchor.Y := FDrawRef.Y + TileProps.TileHeight - wSprite.Height;
    wSprite.Position := pWallAnchor;
    wSprite.UseAlpha := FSelected OR (FInFrontOfActive AND RectIntersects (_IBlendArea, wSprite.Bounds));
    wSprite.Alpha := 128;
    wSprite.Draw (TRUE);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.DrawSurfaces;
var
  theSprite: IZESprite;
  iIndex: integer;
  Blocked: LongBool;
begin
  // draw the surface if necessary
  if (Surface.TerrainSprite <> NIL) then with Surface do begin
    // draw only the floor if present...
    if (Floor <> NIL) then begin
      Floor.Position := FDrawRef;
      Floor.Draw (TRUE);
    end else begin
    // otherwise, draw the terrain
      TerrainSprite.Position := FDrawRef;
      TerrainSprite.Draw (TRUE);
      //
      for iIndex := 0 to Pred (Surface.TransitionsCount) do begin
        theSprite := Surface.Transitions [iIndex];
        if (theSprite = NIL) then continue;
        theSprite.Position := FDrawRef;
        theSprite.Draw (TRUE);
      end;
    end;
  end;
  // draw the grid if necessary
  if (GlobalViewShowGrid) then begin
    Blocked := (NOT Surface.Walkable) OR (CheckSpaces ([osCenter]));
    if Blocked then
      theSprite := g_SpecialSprites.BlockedGrid
      else theSprite := g_SpecialSprites.Grid;
    //
    theSprite.Position:= FDrawRef;
    theSprite.Draw (TRUE);
  end;
  // draw transitions if necessary
  if (GlobalViewShowPortals) AND (Portal <> NIL) then begin
    if (Portal.Kind = ptTransition) then
      theSprite := g_SpecialSprites.Transition
      else theSprite := g_SpecialSprites.Start;
    //
    if (theSprite <> NIL) then begin
      theSprite.Position := FDrawRef;
      theSprite.Draw (TRUE);
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.BeginDraw (pReference: TPoint);
begin
  FDrawRef := AddPoint (pReference, ScrOrigin);
  with (TZEViewLevel (Owner)) do begin
    FInFrontOfActive := (FTileSelected <> NIL) AND (DrawY > FTileSelected.DrawY);
    FSelected := (FTileSelected = Self);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.DrawDirect (pReference: TPoint; Sprite: IZESprite);
begin
  // displace location with our TopLeft
  pReference := AddPoint (pReference, (Owner as TZEViewLevel).ScrOrigin);
  pReference := AddPoint (pReference, ScrOrigin);
  // make sure the tile is centered on the sprite
  pReference.Y := pReference.Y - (Sprite.Height - TileProps.TileHeight);
  pReference.X := pReference.X - ((Sprite.Width - TileProps.TileWidth) div 2);
  //
  // position the sprite first, then draw it
  Sprite.Position := pReference;
  Sprite.Draw (true);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewTile.Draw (pReference: TPoint);
begin
  if (Surface = NIL) then Exit;
  //
  BeginDraw (pReference);
  DrawSurfaces;
  DrawFarWalls;
  //
  // draw other objects here!
  //
  //
  DrawNearWalls;
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewTile.HasPoint (pLocation: TPoint): boolean;
begin
  with ScrBounds, pLocation do
    Result := (X >= Left) AND (X < Right) AND (Y >= Top) AND (Y < Bottom);
  //
  if (Result) then begin
    pLocation := SubPoint (pLocation, ScrOrigin);
    Result := TileProps [pLocation.X, pLocation.Y];
  end;
end;

{ TZEViewLevel }

//////////////////////////////////////////////////////////////////////////
constructor TZEViewLevel.Create (AOwner: TZEMap; Reader: IZbFileReader);
begin
  inherited Create (AOwner, Reader);
  FScrOrigin := Point (0, 0);
  FTilesInView := TList.Create;
  FTileSelected := NIL;
  FOnDraw := NIL;
  FUserData := NIL;
  SetDisplayLocations;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewLevel.Destroy;
begin
  ClearDirtyTilesList;
  FreeAndNIL (FTilesInView);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewLevel.NewTile (X, Y: integer; Reader: IZbFileReader): TZETile;
begin
  Result := AddTile (X, Y, Reader, TZEViewTile);
  if (Result <> NIL) then with (Result as TZEViewTile) do begin
    ScrWidth := TileProps.TileWidth;
    ScrHeight := TileProps.TileHeight;
    if (Reader = NIL) then begin
      Surface.Terrain := NIL;
      Surface.Floor := NIL;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.SetScrOrigin (AScrOrigin: TPoint);
begin
  FScrOrigin := AScrOrigin;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.ClearDirtyTilesList;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FTilesInView.Count) do begin
    TZEViewTile (FTilesInView [iIndex]).FOnScreen := FALSE;
    FTilesInView [iIndex] := NIL;
  end;
  //
  FTilesInView.Pack;
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
  function VL_BDTL_Processor (Tile: TZETile; lParam1, lParam2: integer): boolean;
  var
    DTI: PZEDirtyTileInfo absolute lParam1;
    P: TPoint;
  begin
    Result := false;
    //
    P := AddPoint (DTI.pRef, (Tile as TZEViewTile).ScrOrigin);
    if (P.X >= DTI.rView.Right) OR (P.Y >= DTI.rView.Bottom) then Exit;
    //
    P := AddPoint (P, Point (TileProps.TileWidth, TileProps.TileHeight));
    if (P.X <= DTI.rView.Left) OR (P.Y <= DTI.rView.Top) then Exit;
    //
    TZEViewTile (Tile).FOnScreen := TRUE;
    TZEViewMap (Tile.Owner.Owner).Notice_TileAdded (TZEViewTile (Tile));
    DTI.List.Add (Pointer (Tile));
  end;

  // ************************************************************************

procedure TZEViewLevel.BuildDirtyTilesList (pReference: TPoint; rView: TRect);
var
  DTI: TZEDirtyTileInfo;
begin
  ClearDirtyTilesList;
  if (NOT Assigned (Scanner)) then Exit;
  //
  pReference := AddPoint (pReference, ScrOrigin);
  DTI.pRef := pReference;
  DTI.rView := rView;
  DTI.List := FTilesInView;
  //
  Scanner (VL_BDTL_Processor, NIL, integer (@DTI), 0);
end;

//////////////////////////////////////////////////////////////////////////

  // ************************************************************
  procedure VL_SDL_LoopHandler (Tile: TZETile;
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
  function VL_SDL_SetLocation (Tile: TZETile; lParam1, lParam2: integer): boolean;
  var
    pStart: PPoint absolute lParam1;
    pPosition: PPoint absolute lParam2;
  begin
    (Tile as TZEViewTile).ScrOrigin := pPosition^;
    Result := FALSE;
  end;

  // ************************************************************

procedure TZEViewLevel.SetDisplayLocations;
var
  pStart, pPosition: TPoint;
begin
  pStart := Point (((Pred (Height) * TileProps.TileWidth) div 2), 0);
  pPosition := Point (0, 0);
  //
  Scanner (VL_SDL_SetLocation, VL_SDL_LoopHandler, integer (@pStart), integer (@pPosition));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewLevel.Draw (pReference: TPoint);
var
  iIndex, iLast: integer;
  theTile: TZEViewTile;
begin
  pReference := AddPoint (pReference, ScrOrigin);
  iLast := Pred (FTilesInView.Count);
  // first loop, sets the draw states, and draws the surfaces...
  for iIndex := 0 to iLast do begin
    theTile := TZEViewTile (FTilesInView [iIndex]);
    theTile.BeginDraw (pReference);
    theTile.DrawSurfaces;
  end;
  // call the draw callback...
  if (Assigned (FOnDraw)) then FOnDraw (pReference);
  { TEMPORARILY COMMENTED OUT, WALL-DRAWING CODE }
  (*
  // second loop, draws the far walls...
  for iIndex := 0 to iLast do begin
    theTile := TZEViewTile (FTilesInView [iIndex]);
    theTile.DrawFarWalls;
  end;
  // and now for the near walls...
  for iIndex := 0 to iLast do begin
    theTile := TZEViewTile (FTilesInView [iIndex]);
    theTile.DrawNearWalls;
  end;
  *)
end;

//////////////////////////////////////////////////////////////////////////

  //************************************************************
  function VL_FTA_Processor (Tile: TZETile; lParam1, lParam2: integer): boolean;
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
  pLoc := SubPoint (pLoc, ScrOrigin);
  if ((FTileSelected  = NIL) OR (NOT FTileSelected.HasPoint (pLoc))) then
    FTileSelected := TZEViewTile (Scanner (VL_FTA_Processor, NIL, integer (@pLoc), 0));
  //
  Result := FTileSelected;
end;


{ TZEViewMap }

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.CommonInit;
begin
  FScreenBounds := Rect (0, 0, 0, 0);
  FMapViewport := Rect (0, 0, 0, 0);
  FScreenCenter := Point (0, 0);
  FViewIsDirty := TRUE;
  FTileSelected := NIL;
  //
  FBeforeViewListRebuild := NIL;
  FAfterViewListRebuild := NIL;
  FTileIncluded := NIL;
  FOnDraw := NIL;
  //
  AdjustMapViewport;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEViewMap.Create (AWidth, AHeight: integer);
begin
  inherited Create (AWidth, AHeight);
  CommonInit;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEViewMap.Create (Reader: IZbFileReader);
begin
  inherited Create (Reader);
  CommonInit;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEViewMap.Destroy;
begin
  FTileSelected := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.PostProcessLevel (Level: TZELevel);
var
  iIndex: integer;
  vLevel: TZEViewLevel;

  procedure AdjustLevelHeight (ALevel: TZEViewLevel);
  begin
    ALevel.ScrOrigin := AddPoint (ALevel.ScrOrigin, Point (0, TileProps.LevelHeight));
  end;

begin
  if (Level <> NIL) then begin
    //
    vLevel := Level as TZEViewLevel;
    vLevel.OnDraw := OnDraw;
    //
    for iIndex := 0 to Pred (Count) do begin
      vLevel := TZEViewLevel (Self [iIndex]);
      if (vLevel = NIL) then continue;
      AdjustLevelHeight (vLevel);
    end;
    //
    AdjustMapViewport;
    FActiveLevel := Pred (Count);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewMap.LoadLevel (Reader: IZbFileReader): TZELevel;
begin
  Result := TZEViewLevel.Create (Self, Reader);
  if (Result <> NIL) then IAddLevel (Result);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.PerformUpdate (WTicksElapsed: Cardinal);
begin
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewMap.NewLevel: TZELevel;
begin
  Result := AddLevel (TZEViewLevel);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.TranslateViewport (pDelta: TPoint);
begin
  with FMapViewport do begin
    TopLeft := AddPoint (TopLeft, pDelta);
    BottomRight := AddPoint (BottomRight, pDelta);
  end;
  ValidateVirtualView;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.ValidateVirtualView;
var
  iDelta: integer;
begin
  if (FMapViewport.Left > FScreenBounds.Left) then begin
    iDelta := FMapViewport.Left - FScreenBounds.Left;
    Dec (FMapViewport.Left, iDelta);
    Dec (FMapViewport.Right, iDelta);
  end;
  //
  if (FMapViewport.Top > FScreenBounds.Top) then begin
    iDelta := FMapViewport.Top - FScreenBounds.Top;
    Dec (FMapViewport.Top, iDelta);
    Dec (FMapViewport.Bottom, iDelta);
  end;
  //
  if (FMapViewport.Right < FScreenBounds.Right) then begin
    iDelta := FScreenBounds.Right - FMapViewport.Right;
    Inc (FMapViewport.Left, iDelta);
    Inc (FMapViewport.Right, iDelta);
  end;
  //
  if (FMapViewport.Bottom < FScreenBounds.Bottom) then begin
    iDelta := FScreenBounds.Bottom - FMapViewport.Bottom;
    Inc (FMapViewport.Top, iDelta);
    Inc (FMapViewport.Bottom, iDelta);
  end;
  //
  ViewIsDirty := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.BuildDirtyList (pReference: TPoint; rView: TRect);
var
  iIndex: integer;
  Level: TZEViewLevel;
begin
  Notice_BeforeViewListBuild;
  for iIndex := FActiveLevel downto 0 do begin
    Level := TZEViewLevel (Self [iIndex]);
    if (Level = NIL) then continue;
    Level.BuildDirtyTilesList (pReference, rView);
  end;
  ViewIsDirty := FALSE;
  Notice_AfterViewListBuilt;
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
  with FScreenBounds, FScreenCenter do begin
    X := Left + ((Right - Left) div 2) - TileProps.TileHalfWidth;
    Y := Top + ((Bottom - Top) div 2) - TileProps.TileHalfHeight;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.AdjustMapViewport;
begin
  with FMapViewport, Dimension do begin
    Left    := 0;
    Top     := 0;
    Right   := ((X + Y) * TileProps.TileWidth) div 2;
    Bottom  := ((X + Y) * TileProps.TileHalfHeight) +
               (X + Y - 1) +
               (TileProps.LevelHeight * Succ (Count));
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.SetActiveLevel (AActiveLevel: integer);
begin
  if (FActiveLevel <> AActiveLevel) AND (AActiveLevel >= 0) AND
     (AActiveLevel < Count) then begin
        FActiveLevel := AActiveLevel;
        ViewIsDirty := TRUE;
     end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.SetDrawProc (ADrawProc: TZEDrawProc);
var
  iIndex: integer;
  Level: TZEViewLevel;
begin
  FOnDraw := ADrawProc;
  for iIndex := 0 to Pred (Count) do begin
    Level := TZEViewLevel (Self [iIndex]);
    if (Level = NIL) then continue;
    Level.OnDraw := OnDraw;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.Notice_TileAdded (ATile: TZEViewTile);
begin
  if (Assigned (FTileIncluded)) then FTileIncluded (ATile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.Notice_BeforeViewListBuild;
begin
  if (Assigned (FBeforeViewListRebuild)) then FBeforeViewListRebuild (Self);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.Notice_AfterViewListBuilt;
begin
  if (Assigned (FAfterViewListRebuild)) then FAfterViewListRebuild (Self);
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
  if (Tile <> NIL) then begin
    pTarget := Tile.ScrOrigin;
    if (Tile.Owner <> NIL) then
      PTarget := AddPoint (pTarget, (Tile.Owner as TZEViewLevel).ScrOrigin);
    //
    pTarget := AddPoint (pTarget, FMapViewport.TopLeft);
    delta := SubPoint (FScreenCenter, pTarget);
    //
    TranslateViewport (delta);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.MapLevelUp;
begin
  SetActiveLevel (Succ (FActiveLevel));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.MapLevelDown;
begin
  SetActiveLevel (Pred (FActiveLevel));
end;

//////////////////////////////////////////////////////////////////////////
function TZEViewMap.SelectTileAt (pLoc: TPoint): TZEViewTile;
var
  iIndex: integer;
  Level: TZEViewLevel;
  pDelta: TPoint;
const
  BLEND_X_SPAN  = 0;
  BLEND_Y_SPAN  = 0;
begin
  Result := NIL;
  _IBlendArea := Rect (-1, -1, -1, -1);
  //
  pLoc := AddPoint (pLoc, SubPoint (FScreenBounds.TopLeft, FMapViewport.TopLeft));
  for iIndex := FActiveLevel downto 0 do begin
    Level := TZEViewLevel (Self [iIndex]);
    if (Level = NIL) then continue;
    Result := Level.FindTileAt (pLoc);
    if (Result <> NIL) then with Result do begin
      pDelta := AddPoint (FMapViewport.TopLeft, TZEViewLevel (Owner).ScrOrigin);
      _IBlendArea := DisplaceRect (Result.ScrBounds, pDelta);
      break;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.PanVirtualView (Direction: TZbDirection; PanAmount: integer);
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
  if (ViewIsDirty) then begin
    rView := FScreenBounds;
    Inc (rView.Bottom, TileProps.TileHeight + TileProps.LevelHeight);
    BuildDirtyList (FMapViewport.TopLeft, rView);
  end;
  //
  GlobalClipper.SetClippingRegion (FScreenBounds);
  for iIndex := 0 to FActiveLevel do begin
    Level := TZEViewLevel (Self [iIndex]);
    if (Level <> NIL) then Level.Draw (FMapViewport.TopLeft);
  end;
  //
  if (FTileSelected <> NIL) AND (g_VisibleHighlight) then
    FTileSelected.DrawDirect (FMapViewport.TopLeft, g_SpecialSprites.Highlight);
  //
  GlobalClipper.ClearClippingRegion;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEViewMap.PlaceSelectorAt (AWhereTile: TZEViewTile);
begin
  if (FTileSelected = AWhereTile) then Exit;
  FTileSelected := AWhereTile;
end;


{ TZESpecialSprites }

//////////////////////////////////////////////////////////////////////////
constructor TZESpecialSprites.Create;
begin
  inherited;
  ClearAll;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZESpecialSprites.Destroy;
begin
  ClearAll;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpecialSprites.ClearAll;
begin
  m_Grid := NIL;
  m_BlockedGrid := NIL;
  m_Highlight := NIL;
  m_Selection := NIL;
  m_Transition := NIL;
  m_Start := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpecialSprites.SetGrid (ASprite: IZESprite);
begin
  m_Grid := NIL;
  m_Grid := ASprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpecialSprites.SetBlockedGrid (ASprite: IZESprite);
begin
  m_BlockedGrid := NIL;
  m_BlockedGrid := ASprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpecialSprites.SetHighlight (ASprite: IZESprite);
begin
  m_Highlight := NIL;
  m_Highlight := ASprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpecialSprites.SetSelection (ASprite: IZESprite);
begin
  m_Selection := NIL;
  m_Selection := ASprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpecialSprites.SetTransition (ASprite: IZESprite);
begin
  m_Transition := NIL;
  m_Transition := ASprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpecialSprites.SetStart (ASprite: IZESprite);
begin
  m_Start := NIL;
  m_Start := ASprite;
end;


end.

