{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEMap.PAS
              The Game Map Class
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/MapEngine/ZZEMap.pas,v 1.5 2002/12/18 08:19:13 Vij Exp $
  $Log: ZZEMap.pas,v $
  Revision 1.5  2002/12/18 08:19:13  Vij
  implemented FaceTo()

  Revision 1.4  2002/11/02 06:53:04  Vij
  Added portals.  Added neighbor list for tiles and trading space for speed
  during neighbor lookups.  added coordinate validator function.  added MapID
  property for use during loading/saving of portals.

  Revision 1.3  2002/10/01 12:41:05  Vij
  Added facilities to support Save/Load

  Revision 1.2  2002/09/17 22:14:53  Vij
  Fixed TZETile methods. Fixed typo in ReleaseSpaces (was RelaseSpaces).
  Remove call to PassabilityChanged() in method ClaimSpaces() as there
  isn't any change(s) anyways.
  NEW constants: AllSpaces and AllEdges.

  Revision 1.1.1.1  2002/09/11 21:11:33  Vij
  Starting Version Control


 ============================================================================}
 
unit ZZEMap;

interface

uses
  Types,
  Classes,
  //
  ZbScriptable,
  ZbArray2D,
  ZbFileIntf,
  ZbGameUtils,
  ZbPathFinder,
  //
  ZEDXSpriteIntf,
  ZZESupport,
  ZZEWorldIntf;

type
  TZESurface = class;
  TZESurfaceClass = class of TZESurface;
  TZETile = class;
  TZETileClass = class of TZETile;
  TZELevel = class;
  TZELevelClass = class of TZELevel;
  TZEMap = class;
  TZEMapClass = class of TZEMap;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESurfaceNotifyProc = procedure (Surface: TZESurface) of Object;

  TZESurface = class (TZbStreamable)
  private
    FOwner: TZETile;
    FTerrain: IZETerrain;
    FTerrainVariation: integer;
    FTerrainSprite: IZESprite;
    FTerrainTransitions: TInterfaceList;
    FFloor: IZESprite;
    FLocked: boolean;
    FNotify: TZESurfaceNotifyProc;
  protected
    procedure CommonInit;
    procedure SetTerrain (ATerrain: IZETerrain);
    procedure SetTerrainVariation (iVariation: integer);
    function GetTransitionsCount: integer;
    function GetTransitionSprite (iIndex: integer): IZESprite;
    procedure SetFloor (AFloor: IZESprite);
    function GetWalkable: boolean;
    function IsSolid: boolean;
    procedure Changed;
  public
    constructor Create (AOwner: TZETile; DefTerrain: IZETerrain = NIL;
      DefFloor: IZESprite = NIL); overload; virtual;
    constructor Create (AOwner: TZETile; Reader: IZbFileReader); overload; virtual;
    destructor Destroy; override;
    //
    procedure Load (Reader: IZbFileReader); override;
    procedure Save (Writer: IZbFileWriter); override;
    //
    procedure Reset;
    procedure UpdateTransitions (bIncludeNeighbors: boolean = FALSE);
    procedure Lock;
    procedure Unlock (bIncludeNeighbors: boolean = FALSE);
    //
    property Owner: TZETile read FOwner;
    property Terrain: IZETerrain read FTerrain write SetTerrain;
    property TerrainVariation: integer read FTerrainVariation write SetTerrainVariation;
    property TerrainSprite: IZESprite read FTerrainSprite;
    property TransitionsCount: integer read GetTransitionsCount;
    property Transitions [iIndex: integer]: IZESprite read GetTransitionSprite;
    property Floor: IZESprite read FFloor write SetFloor;
    property Walkable: boolean read GetWalkable;
    property Solid: boolean read IsSolid;
    property Notify: TZESurfaceNotifyProc read FNotify write FNotify;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEPortalType = (ptStart, ptTransition);
  PZEPortal = ^TZEPortal;
  TZEPortal = record
    Kind: TZEPortalType;
    DestMap: TZEMap;
    DestLoc: TZbVector;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEOccupiedSpace = (osNorth, osEast, osSouth, osWest, osCenter);
  TZEOccupiedSpaces = set of TZEOccupiedSpace;

  TZENeighborList = array [Low (TZbDirection)..High (TZbDirection)] of TZETile;

  TZETile = class (TZbStreamable)
  private
    FOwner: TZELevel;                   // level class owning this tile
    FGridPosition: TPoint;              // position of tile in the grid
    FDrawPosition: TPoint;              // position of tile in draw sequence
    FSurface: TZESurface;               // terrain and/or floor
    FPassability: TZbPassabilityList;   // list of which direction MoveTo is allowed
    FSpaces: TZEOccupiedSpaces;         // list of spaces already occupied
    //
    FWalls: TZEWallSet;
    FWallSprites: TZEWallSpritesSet;
    FPortal: PZEPortal;
    //
    FNeighbors: TZENeighborList;
    //
    FNorthEdge: boolean;
    FWestEdge: boolean;
    FEastEdge: boolean;
    FSouthEdge: boolean;
  protected
    procedure SurfaceChanged (Surface: TZESurface);
    function GetWall (WhichWall: TZEWallPosition): IZEWall;
    procedure ISetWall (WhichWall: TZEWallPosition; NewWall: IZEWall);
    procedure SetWall (WhichWall: TZEWallPosition; NewWall: IZEWall);
    function GetWallSprite (WhichWall: TZEWallPosition): IZESprite;
    procedure InitNeighbors;
    //
    property AtNorthEdge: boolean read FNorthEdge;
    property AtEastEdge: boolean read FEastEdge;
    property AtSouthEdge: boolean read FSouthEdge;
    property AtWestEdge: boolean read FWestEdge;
  public
    constructor Create (AOwner: TZELEvel; Reader: IZbFileReader = NIL); virtual;
    destructor Destroy; override;
    procedure Load (Reader: IZbFileReader); override;
    procedure Save (Writer: IZbFileWriter); override;
    //
    procedure Clear;
    function Empty: boolean;
    //function GetNeighbor (iDirection: TZbDirection): TZETile;
    function IsNeighbor (Target: TZETile): boolean;
    function GetDirectionTo (Target: TZETile): TZbDirection;
    function HowFarTo (Target: TZETile): integer;
    //
    procedure PassabilityChanged (bPropagate: boolean = FALSE);
    function CanExitTo (dWhereTo: TZbDirection): boolean;
    function CanEnterFrom (dWhereTo: TZbDirection): boolean;
    //
    procedure SetPortal (ADestMap: TZEMap; ADestLoc: TZbVector; AKind:
      TZEPortalType = ptTransition); overload;
    procedure SetPortal (ADestMap: TZEMap; ADestX, ADestY, ADestLevel: integer;
      AKind: TZEPortalType = ptTransition); overload;
    procedure ClearPortal;
    //
    function CheckSpace (tSpace: TZEOccupiedSpace): boolean;
    function CheckSpaces (tSpaces: TZEOccupiedSpaces): boolean;
    procedure ClaimSpace (tSpace: TZEOccupiedSpace);
    procedure ClaimSpaces (tSpaces: TZEOccupiedSpaces);
    procedure ReleaseSpace (tSpace: TZEOccupiedSpace);
    procedure ReleaseSpaces (tSpaces: TZEOccupiedSpaces);
    //
    property Owner: TZELevel read FOwner;
    property Neighbors: TZENeighborList read FNeighbors;
    property GridPosition: TPoint read FGridPosition;
    property GridX: integer read FGridPosition.X;
    property GridY: integer read FGridPosition.Y;
    property DrawPosition: TPoint read FDrawPosition;
    property DrawX: integer read FDrawPosition.X;
    property DrawY: integer read FDrawPosition.Y;
    property Surface: TZESurface read FSurface;
    property Wall [WhichWall: TZEWallPosition]: IZEWall read GetWall write SetWall;
    property WallSprites [WhichWall: TZEWallPosition]: IZESprite read GetWallSprite;
    property Portal: PZEPortal read FPortal;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEScannerLoopPhase = (
    llpLoopOuterInit,
    llpLoopInnerInit,
    llpLoopInnerPreProcess,
    llpLoopInnerPostProcess,
    llpLoopOuterTailEnd);

  TZELevelLoopFunc = procedure (Tile: TZETile; iLoopCount: integer;
    LoopPhase: TZEScannerLoopPhase; lParam1, lParam2: integer);

  TZELevelScanFunc = function (Tile: TZETile; lParam1, lParam2: integer): boolean;

  TZELevelScanner = function (ScanFunc: TZELevelScanFunc;
    LoopFunc: TZELevelLoopFunc; lParam1, lParam2: integer): TZETile of object;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZELevel = class (TZbStreamable)
  private
    FOwner: TZEMap;
    FIndex: integer;
    FDimension: TPoint;
    FData: TZbTwoDimensionalList;
    FScanner: TZELevelScanner;
    FMotionMap: TZbMotionMap;
  protected
    function GetTile (X, Y: integer): TZETile;
    procedure SetTile (X, Y: integer; Tile: TZETile);
    procedure DisposeTile (Tile: TZETile); virtual;
    function AddTile (X, Y: integer; Reader: IZbFileReader;
      TileClass: TZETileClass): TZETile; virtual;
    procedure CreateTiles (Reader: IZbFileReader); virtual;
    function NewTile (X, Y: integer; Reader: IZbFileReader): TZETile; virtual;
    //
    function PerformScanNWToSE (
      ScanFunc: TZELevelScanFunc; LoopFunc: TZELevelLoopFunc;
      lParam1, lParam2: integer): TZETile;
    function PerformScanSEToNW (
      ScanFunc: TZELevelScanFunc; LoopFunc: TZELevelLoopFunc;
      lParam1, lParam2: integer): TZETile;
    function PerformScanSWToNE (
      ScanFunc: TZELevelScanFunc; LoopFunc: TZELevelLoopFunc;
      lParam1, lParam2: integer): TZETile;
    function PerformScanNEToSW (
      ScanFunc: TZELevelScanFunc; LoopFunc: TZELevelLoopFunc;
      lParam1, lParam2: integer): TZETile;
    //
    property Scanner: TZELevelScanner read FScanner write FScanner;
    //
  public
    constructor Create (AOwner: TZEMap; Reader: IZbFileReader = NIL); virtual;
    destructor Destroy; override;
    //
    procedure Load (Reader: IZbFileReader); override;
    procedure Save (Writer: IZbFileWriter); override;
    //
    function FindPath (StartTile, TargetTile: TZETile): TList; overload;
    function FindPath (StartPos, TargetPos: TPoint): TList; overload;
    function FindPath (StartPos: TPoint; TargetTile: TZETile): TList; overload;
    function FindPath (StartTile: TZETile; TargetPos: TPoint): TList; overload;
    //
    property Owner: TZEMap read FOwner;
    property LevelIndex: integer read FIndex;
    property Dimension: TPoint read FDimension;
    property Width: integer read FDimension.X;
    property Height: integer read FDimension.Y;
    property Data [X, Y : integer]: TZETile read GetTile write SetTile; default;
    property MotionMap: TZbMotionMap read FMotionMap;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMap = class (TZbStreamable)
  private
    FDimension: TPoint;
    FLevels: TList;
    FMapId: PChar;
  protected
    function GetLevelCount: integer;
    function GetLevel (iIndex: integer): TZELevel;
    procedure DisposeLevel (Level: TZELevel); virtual;
    procedure PostProcessLevel (Level: TZELevel); virtual;
    procedure IAddLevel (Level: TZELevel);
    function AddLevel (LevelClass: TZELevelClass): TZELevel; virtual;
    function LoadLevel (Reader: IZbFileReader): TZELevel; virtual;
    function GetMapId: string;
    procedure SetMapId (AMapId: string);
  public
    constructor Create (AWidth, AHeight: integer); overload; virtual;
    constructor Create (Reader: IZbFileReader); overload; virtual;
    destructor Destroy; override;
    //
    procedure Load (Reader: IZbFileReader); override;
    procedure Save (Writer: IZbFileWriter); override;
    //
    function Valid (X, Y, Z: integer): boolean; overload;
    function Valid (Vector: TZbVector): boolean; overload;
    procedure PerformUpdate (WTicksElapsed: Cardinal); virtual; abstract;
    function NewLevel: TZELevel; virtual;
    //
    property Dimension: TPoint read FDimension;
    property Width: integer read FDimension.X;
    property Height: integer read FDimension.Y;
    property Count: integer read GetLevelCount;
    property Levels [iIndex: integer]: TZELevel read GetLevel; default;
    property MapId: string read GetMapId write SetMapId;
  end;


const
  AllSpaces: TZEOccupiedSpaces = [osCenter, osEast, osWest, osNorth, osSouth];
  AllEdges: TZEOccupiedSpaces = [osEast, osWest, osNorth, osSouth];

var
  __WallPosToTileSpace: array [wpNorth..wpWest] of TZEOccupiedSpace = (
    osNorth, osEast, osSouth, osWest);


implementation

uses
  SysUtils,
  StrUtils,
  Windows,
  //
  ZbDebug,
  //
  ZEDXSprite,
  ZZECore;


{ TZESurface }

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.CommonInit;
begin
  FOwner := NIL;
  FTerrain := NIL;
  FTerrainSprite := NIL;
  FTerrainVariation := -1;
  FTerrainTransitions := TInterfaceList.Create;
  SetTerrain (NIL);
  FFloor := NIL;
  FLocked := FALSE;
  FNotify := NIL;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZESurface.Create (AOwner: TZETile; DefTerrain: IZETerrain; DefFloor: IZESprite);
begin
  inherited Create;
  CommonInit;
  FOwner := AOwner;
  Terrain := DefTerrain;
  Floor := DefFloor;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZESurface.Create (AOwner: TZETile; Reader: IZbFileReader);
begin
  CommonInit;
  FOwner := AOwner;
  Load (Reader);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZESurface.Destroy;
begin
  FTerrainTransitions.Free;
  FTerrain := NIL;
  FFloor := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.Load (Reader: IZbFileReader);
var
  cData: string;
begin
  if (Reader.ReadBoolean) then begin
    cData := Reader.ReadStr;
    FTerrainVariation := Reader.ReadInteger;
    FTerrain := TerrainManager.TerrainByName [cData];
    FTerrainSprite := FTerrain.GetSprite (FTerrainVariation);
  end;
  //
  if (Reader.ReadBoolean) then begin
    cData := Reader.ReadStr;
    FFloor := CoreEngine.SpriteFactory.CreateSprite ('', cData);
    FFloor.CurrentFrame := Reader.ReadInteger;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.Save (Writer: IZbFileWriter);
begin
  // check out the terrain first...
  if (FTerrain = NIL) then
    Writer.WriteBoolean (FALSE)
  else begin
    Writer.WriteBoolean (TRUE);
    Writer.WriteStr (FTerrain.Name);
    Writer.WriteInteger (FTerrainVariation);
  end;
  // now the floor
  if (FFloor = NIL) then
    Writer.WriteBoolean (FALSE)
  else begin
    Writer.WriteBoolean (TRUE);
    Writer.WriteStr (FFloor.IdName);
    Writer.WriteInteger (FFloor.CurrentFrame);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.SetTerrain (ATerrain: IZETerrain);
begin
  FTerrain := NIL;
  FTerrain := ATerrain;
  FTerrainSprite := NIL;
  FTerrainVariation := -1;
  //
  if (FTerrain <> NIL) then begin
    FTerrainSprite := FTerrain.GetSprite (0);
    FTerrainVariation := 0;
  end else 
    FFloor := NIL;
  //
  UpdateTransitions;
  Changed;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.SetTerrainVariation (iVariation: integer);
begin
  if (FTerrain <> NIL) then begin
    FTerrainSprite := NIL;
    FTerrainSprite := FTerrain.GetSprite (iVariation);
    FTerrainVariation := FTerrainSprite.CurrentFrame;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZESurface.GetTransitionsCount: integer;
begin
  Result := FTerrainTransitions.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZESurface.GetTransitionSprite (iIndex: integer): IZESprite;
begin
  Result := FTerrainTransitions [iIndex] as IZESprite;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.SetFloor (AFloor: IZESprite);
begin
  FFloor := NIL;
  // if terrain is non-existent, then the floor remains NIL
  if (FTerrain = NIL) then Exit;
  FFloor := AFloor;
  Changed;
end;

//////////////////////////////////////////////////////////////////////////
function TZESurface.GetWalkable: boolean;
begin
  Result := (FFloor <> NIL) OR ((FTerrain <> NIL) AND (FTerrain.Passable));
end;

//////////////////////////////////////////////////////////////////////////
function TZESurface.IsSolid: boolean;
begin
  Result := (FFloor <> NIL) OR ((FTerrain <> NIL) AND (FTerrain.Fluidity = 0));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.Changed;
begin
  if (Assigned (FNotify)) then FNotify (Self);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.Reset;
begin
  if (FTerrain <> NIL) AND (FTerrainVariation >= 0) then begin
    FTerrainSprite := NIL;
    FTerrainSprite := FTerrain.GetSprite (FTerrainVariation);
    UpdateTransitions;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.UpdateTransitions (bIncludeNeighbors: boolean);
var
  Neighbors: array [tdNorth..tdNorthWest] of TZESurface;
  iTerrainHeight: integer;
  iHighestTerrain: integer;
  dPos: TZbDirection;
  theTile: TZETile;
  dwTransitionCode: Cardinal;
  theTerrain: IZETerrain;
  theTransition: TZETerrainTransition;
begin
  //
  // trigger neighbors' transition updates if necessary
  //
  // NOTE: this is done first in case we bail out in the
  // main body of the routine due to lack of actual terrain
  // to generate transitions for.  this may be counter-
  // intuitive, but we may still have to let the neighbors
  // know in case our terrain was deleted so THEY can
  // renegerate a proper terrain for themselves
  if (bIncludeNeighbors) then begin
    for dPos := tdNorth to tdNorthWest do begin
      theTile := Owner.Neighbors [dPos];
      if (theTile = NIL) OR (theTile.Surface = NIL) OR
        (theTile.Surface.Terrain = NIL) then continue;
      //
      theTile.Surface.UpdateTransitions;
    end;
  end;
  //
  // now do ours...
  FTerrainTransitions.Clear;
  if (FLocked) OR (FTerrain = NIL) OR (FTerrainSprite = NIL) then Exit;
  //
  // find the highest terrain surrounding us
  iTerrainHeight := FTerrain.Index;
  iHighestTerrain := iTerrainHeight;
  for dPos := tdNorth to tdNorthWest do begin
    theTile := Owner.Neighbors [dPos];
    Neighbors [dPos] := NIL;
    if (theTile = NIL) OR (theTile.Surface = NIL) OR
      (theTile.Surface.Terrain = NIL) then continue;
    //
    Neighbors [dPos] := theTile.Surface;
    if (Neighbors [dPos].Terrain.Index > iHighestTerrain) then
      iHighestTerrain := Neighbors [dPos].Terrain.Index;
  end;
  //
  // if no neighbor is higher that this one, no need for transitions
  if (iHighestTerrain <= iTerrainHeight) then Exit;
  //
  // this is the main loop
  for iTerrainHeight := Succ (FTerrain.Index) to iHighestTerrain do begin
    dwTransitionCode := 0;
    theTerrain := NIL;
    //
    for dPos := tdNorth to tdNorthWest do begin
      if ((Neighbors [dPos] = NIL) OR
        (Neighbors [dPos].Terrain.Index <> iTerrainHeight)) then continue;
      //
      if (theTerrain = NIL) then theTerrain := Neighbors [dPos].Terrain;
      dwTransitionCode := dwTransitionCode OR TransitionCodes [dPos];
      Neighbors [dPos] := NIL;
    end;
    //
    if (dwTransitionCode <> 0) AND (theTerrain <> NIL) then begin
      theTransition := theTerrain.GetTransitionSprite (dwTransitionCode);
      if (theTransition.Edges <> NIL) then begin
        FTerrainTransitions.Add (theTransition.Edges);
        //FTerrainSprite.DrawSprite (theTransition.Edges);
        theTransition.Edges := NIL;
      end;
      if (theTransition.Corners <> NIL) then begin
        FTerrainTransitions.Add (theTransition.Corners);
        //FTerrainSprite.DrawSprite (theTransition.Corners);
        theTransition.Corners := NIL;
      end;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.Lock;
begin
  FLocked := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESurface.Unlock (bIncludeNeighbors: boolean);
begin
  FLocked := FALSE;
  UpdateTransitions (bIncludeNeighbors);
end;

{ TZETile }

//////////////////////////////////////////////////////////////////////////
constructor TZETile.Create (AOwner: TZELEvel; Reader: IZbFileReader);
var
  dPos: TZbDirection;
  dWallPos: TZEWallPosition;
begin
  inherited Create;
  FOwner := AOwner;
  FGridPosition := Point (0, 0);
  FDrawPosition := Point (0, 0);
  //
  FSpaces := [];
  FNorthEdge := FALSE;
  FWestEdge := FALSE;
  FEastEdge := FALSE;
  FSouthEdge := FALSE;
  //
  FNeighbors [tdUnknown] := NIL;
  for dPos := tdNorth to tdNorthWest do begin
    FPassability.CanExitTo [dPos] := FALSE;
    FPassability.CanEnterFrom [dPos] := FALSE;
    FNeighbors [dPos] := NIL;
  end;
  //
  for dWallPos := Low (TZEWallPosition) to High (TZEWallPosition) do begin
    FWalls [dWallPos] := NIL;
    FWallSprites [dWallPos] := NIL;
  end;
  // normal creation is when Reader is NIL
  if (Reader = NIL) then begin
    FSurface := TZESurface.Create (Self, NIL, NIL);
    FSurface.Notify := SurfaceChanged;
    FPortal := NIL;
    //
  end else // Reader <> NIL, we're loading ourself
    Load (Reader);
  //
end;

//////////////////////////////////////////////////////////////////////////
destructor TZETile.Destroy;
var
  dWallPos: TZEWallPosition;
begin
  for dWallPos := Low (TZEWallPosition) to High (TZEWallPosition) do begin
    FWalls [dWallPos] := NIL;
    FWallSprites [dWallPos] := NIL;
  end;
  FSurface.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.Load (Reader: IZbFileReader);
begin
  // load the surface
  FSurface := TZESurface.Create (Self, Reader);
  FSurface.Notify := SurfaceChanged;
  SurfaceChanged (FSurface);
  //
  // now load the portal, if any
  if (Reader.ReadBoolean) then begin
    New (FPortal);
    ZeroMemory (FPortal, SizeOf (TZEPortal));
    //
    with FPortal^ do begin
      Kind := TZEPortalType (Reader.ReadInteger);
      if (Kind = ptTransition) then begin
        DestMap := TZEMap (Reader.ReadPStr);
        DestLoc.X := Reader.ReadInteger;
        DestLoc.Y := Reader.ReadInteger;
        DestLoc.Z := Reader.ReadInteger;
      end;
    end;
  end;
  //
  // TODO: load the walls
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.Save (Writer: IZbFileWriter);
begin
  // write the surface
  FSurface.Save (Writer);
  //
  // write out the portal, if any
  if (FPortal = NIL) then
    Writer.WriteBoolean (FALSE)
  else with Writer, FPortal^ do begin
    WriteBoolean (TRUE);
    WriteInteger (Integer (Kind));
    if (Kind = ptTransition) then begin
      WritePStr (DestMap.FMapId);
      WriteInteger (DestLoc.X);
      WriteInteger (DestLoc.Y);
      WriteInteger (DestLoc.Z);
    end;
  end;
  //
  // TODO: save the walls
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.SurfaceChanged (Surface: TZESurface);
begin
  PassabilityChanged (TRUE);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.PassabilityChanged (bPropagate: boolean);
var
  CenterOpen: boolean;
  dPos: TZbDirection;
  theNeighbor: TZETile;
begin
  with FPassability do begin
    CanExitTo [tdNorth] := (NOT (osNorth in FSpaces)) AND (Neighbors [tdNorth] <> NIL);
    CanExitTo [tdWest] := (NOT (osWest in FSpaces)) AND (Neighbors [tdWest] <> NIL);
    CanExitTo [tdEast] := (NOT (osEast in FSpaces)) AND (Neighbors [tdEast] <> NIL);
    CanExitTo [tdSouth] := (NOT (osSouth in FSpaces)) AND (Neighbors [tdSouth] <> NIL);
    CanExitTo [tdNorthWest] := CanExitTo [tdNorth] AND CanExitTo [tdWest]
      AND (Neighbors [tdNorthWest] <> NIL);
    CanExitTo [tdNorthEast] := CanExitTo [tdNorth] AND CanExitTo [tdEast]
      AND (Neighbors [tdNorthEast] <> NIL);
    CanExitTo [tdSouthWest] := CanExitTo [tdSouth] AND CanExitTo [tdWest]
      AND (Neighbors [tdSouthWest] <> NIL);
    CanExitTo [tdSouthEast] := CanExitTo [tdSouth] AND CanExitTo [tdEast]
      AND (Neighbors [tdSouthEast] <> NIL);
    //
    CenterOpen := (NOT (osCenter in FSpaces)) AND (Surface.Walkable);
    CanEnterFrom [tdNorth] := CenterOpen AND (NOT (osNorth in FSpaces));
    CanEnterFrom [tdEast] := CenterOpen AND (NOT (osEast in FSpaces));
    CanEnterFrom [tdWest] := CenterOpen AND (NOT (osWest in FSpaces));
    CanEnterFrom [tdSouth] := CenterOpen AND (NOT (osSouth in FSpaces));
    CanEnterFrom [tdNorthWest] := CenterOpen AND CanEnterFrom [tdNorth] AND CanEnterFrom [tdWest];
    CanEnterFrom [tdNorthEast] := CenterOpen AND CanEnterFrom [tdNorth] AND CanEnterFrom [tdEast];
    CanEnterFrom [tdSouthWest] := CenterOpen AND CanEnterFrom [tdSouth] AND CanEnterFrom [tdWest];
    CanEnterFrom [tdSouthEast] := CenterOpen AND CanEnterFrom [tdSouth] AND CanEnterFrom [tdEast];
  end;
  //
  if (bPropagate) then begin
    for dPos := Low (TZbDirection) to High (TZbDirection) do begin
      theNeighbor := Neighbors [dPos];
      if (theNeighbor <> NIL) then theNeighbor.PassabilityChanged;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.GetWall (WhichWall: TZEWallPosition): IZEWall;
begin
  Result := FWalls [WhichWall];
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.ISetWall (WhichWall: TZEWallPosition; NewWall: IZEWall);
begin
  // ignore if we have no surface to attach stuff onto
  if (Surface = NIL) OR (Surface.Terrain = NIL) then Exit;
  //
  if (NewWall = NIL) then begin
    // if there is no wall already, bug out to skip
    // the side effects of removing a wall
    if (FWalls [WhichWall] = NIL) then Exit;
    //
    FWalls [WhichWall] := NIL;
    FWallSprites [WhichWall] := NIL;
    ReleaseSpace (__WallPosToTileSpace [WhichWall]);
  end else begin
    // if the space for the wall is already occupied, ignore call
    if (__WallPosToTileSpace [WhichWall] in FSpaces) then Exit;
    //
    FWalls [WhichWall] := NewWall;
    NewWall.Position := WhichWall;
    FWallSprites [WhichWall] := NewWall.GetSprite;
    ClaimSpace (__WallPosToTileSpace [WhichWall]);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.SetWall (WhichWall: TZEWallPosition; NewWall: IZEWall);
begin
  if  (WhichWall = wpNothing) then Exit;
  ISetWall (WhichWall, NewWall);
  {//
  theTile := GetNeighbor (__WallPositionToDirection [WhichWall]);
  WhichWall := __WallPositionOpposite [WhichWall];
  if (theTile <> NIL) then begin
    if (NewWall <> NIL) then
      theTile.ISetWall (WhichWall, NewWall.Clone)
      else theTile.ISetWall (WhichWall, NIL)
  end;}
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.GetWallSprite (WhichWall: TZEWallPosition): IZESprite;
begin
  Result := FWallSprites [WhichWall];
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.InitNeighbors;
begin
  FNeighbors [tdNorth]      := FOwner [GridX, Pred (GridY)];
  FNeighbors [tdEast]       := FOwner [Succ (GridX), GridY];
  FNeighbors [tdWest]       := FOwner [Pred (GridX), GridY];
  FNeighbors [tdSouth]      := FOwner [GridX, Succ (GridY)];
  FNeighbors [tdNorthEast]  := FOwner [Succ (GridX), Pred (GridY)];
  FNeighbors [tdNorthWest]  := FOwner [Pred (GridX), Pred (GridY)];
  FNeighbors [tdSouthEast]  := FOwner [Succ (GridX), Succ (GridY)];
  FNeighbors [tdSouthWest]  := FOwner [Pred (GridX), Succ (GridY)];
  FNeighbors [tdUnknown]    := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.Clear;
begin
  FSurface.Floor := NIL;
  FSurface.Terrain := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.Empty: boolean;
begin
  Result := (FSurface.Terrain = NIL);
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.IsNeighbor (Target: TZETile): boolean;
var
  dX, dY: integer;
begin
  Result := FALSE;
  if (Target = NIL) OR (Target.Owner <> Owner) then Exit;
  //
  dX := Abs (GridX - Target.GridX);
  dY := Abs (GridY - Target.GridY);
  //
  Result := (dX <= 1) AND (dY <= 1);
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.GetDirectionTo (Target: TZETile): TZbDirection;
var
  dPos: TZbDirection;
  distance: TPoint;
  vector: TPoint;
  IsDiagonal: boolean;
begin
  // TODO: code this direction calculation later...
  Result := tdUnknown;
  if (Target = Self) then Exit;
  //
  if (IsNeighbor (Target)) then begin
    for dPos := Succ (Low (TZbDirection)) to High (TZbDirection) do begin
      if (FNeighbors [dPos] = Target) then begin
        Result := dPos;
        break;
      end;
    end;
  end else begin
    // get the distances from 
    vector.X   := Target.GridX - GridX;
    vector.Y   := Target.GridY - GridY;
    distance.X := Abs (vector.X);
    distance.Y := Abs (vector.Y);
    //
    // catch parallel lines
    if (distance.X = 0) then
      Result := IfThen (vector.Y > 0, tdSouth, tdNorth)
    else if (distance.Y = 0) then
      Result := IfThen (vector.X > 0, tdEast, tdWest)
    else begin
      IsDiagonal := distance.X = distance.Y;
      // process diagonals
      if (IsDiagonal) then begin
        // check for lower right quadrant
        if (vector.X > 0) AND (vector.Y > 0) then
          Result := tdSouthEast
        // check for upper right quadrant
        else if (vector.X > 0) AND (vector.Y < 0) then
          Result := tdNorthEast
        // check for lower left quadrant
        else if (vector.X < 0) AND (vector.Y > 0) then
          Result := tdSouthWest
        // check for upper left quadrant
        else if (vector.X < 0) AND (vector.Y < 0) then
          Result := tdNorthWest;
      end else begin
        // process everything else
        //
        // check for lower right quadrant
        if (vector.X > 0) AND (vector.Y > 0) then
          Result := IfThen (distance.X < distance.Y, tdSouth, tdEast)
        // check for upper right quadrant
        else if (vector.X > 0) AND (vector.Y < 0) then
          Result := IfThen (distance.X < distance.Y, tdNorth, tdEast)
        // check for lower left quadrant
        else if (vector.X < 0) AND (vector.Y > 0) then
          Result := IfThen (distance.X < distance.Y, tdSouth, tdWest)
        // check for upper left quadrant
        else if (vector.X < 0) AND (vector.Y < 0) then
          Result := IfThen (distance.X < distance.Y, tdNorth, tdWest);
      end;
      //
    end;
    //
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.HowFarTo (Target: TZETile): integer;
begin
  if (Target = NIL) then
    Result := 0
  else if (IsNeighbor (Target)) then
    Result := 1
  else
    Result := Round (SqRt (Sqr (Abs (GridX - Target.GridX)) +
              Sqr (Abs (GridY - Target.GridY))));
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.CanExitTo (dWhereTo: TZbDirection): boolean;
begin
  if (dWhereTo <> tdUnknown) then
    Result := FPassability.CanExitTo [dWhereTo]
    else Result := FALSE;
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.CanEnterFrom (dWhereTo: TZbDirection): boolean;
begin
  if (dWhereTo <> tdUnknown) then
    Result := FPassability.CanEnterFrom [dWhereTo]
    else Result := FALSE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.SetPortal (ADestMap: TZEMap; ADestLoc: TZbVector; AKind: TZEPortalType);
begin
  ClearPortal;
  //
  if (ADestMap = NIL) then begin
    ADestMap := Owner.Owner;
    AKind := ptStart;
  end;
  //
  New (FPortal);
  with FPortal^ do begin
    Kind := AKind;
    DestMap := ADestMap;
    DestLoc := ADestLoc;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.SetPortal (ADestMap: TZEMap; ADestX, ADestY, ADestLevel: integer;
  AKind: TZEPortalType);
begin
  SetPortal (ADestMap, Vector (ADestX, ADestY, ADestLevel));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.ClearPortal;
begin
  if (FPortal <> NIL) then begin
    Dispose (FPortal);
    FPortal := NIL;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.CheckSpace (tSpace: TZEOccupiedSpace): boolean;
begin
  Result := (tSpace in FSpaces);
end;

//////////////////////////////////////////////////////////////////////////
function TZETile.CheckSpaces (tSpaces: TZEOccupiedSpaces): boolean;
begin
  Result := (tSpaces * FSpaces) <> [];
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.ClaimSpace (tSpace: TZEOccupiedSpace);
begin
  FSpaces := FSpaces + [tSpace];
  PassabilityChanged;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.ClaimSpaces (tSpaces: TZEOccupiedSpaces);
begin
  FSpaces := FSpaces + tSpaces;
  PassabilityChanged;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.ReleaseSpace (tSpace: TZEOccupiedSpace);
begin
  FSpaces := FSpaces - [tSpace];
  PassabilityChanged;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETile.ReleaseSpaces (tSpaces: TZEOccupiedSpaces);
begin
  FSpaces := FSpaces - tSpaces;
  PassabilityChanged;
end;


{ TZELevel}

//////////////////////////////////////////////////////////////////////////
constructor TZELevel.Create (AOwner: TZEMap; Reader: IZbFileReader);
begin
  inherited Create;
  FOwner := AOwner;
  FDimension := FOwner.Dimension;
  FIndex := FOwner.Count;
  FData := TZbTwoDimensionalList.Create (Width, Height);
  FMotionMap := TZbMotionMap.Create (Width, Height, FALSE);
  FScanner := PerformScanNWToSE;
  CreateTiles (Reader);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZELevel.Destroy;
var
  X, Y: integer;
begin
  FMotionMap.Free;
  //
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do begin
      DisposeTile (TZETile (FData [X, Y]));
      FData [X, Y] := NIL;
    end;
  //
  FData.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZELevel.Load (Reader: IZbFileReader);
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TZELevel.Save (Writer: IZbFileWriter);
var
  X, Y: integer;
begin
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do
      TZETile (FData [X, Y]).Save (Writer);
    //
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.GetTile (X, Y: integer): TZETile;
begin
  Result := TZETile (FData [X, Y]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZELevel.SetTile (X, Y: integer; Tile: TZETile);
begin
  DisposeTile (TZETile (FData [X, Y]));
  FData [X, Y] := Pointer (Tile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZELevel.DisposeTile (Tile: TZETile);
begin
  Tile.Free;
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.AddTile (X, Y: integer; Reader: IZbFileReader;
  TileClass: TZETileClass): TZETile;
begin
  Result := TileClass.Create (Self, Reader);
  if (Result <> NIL) then with Result do begin
    FGridPosition := Point (X, Y);
    FDrawPosition := Point (X, X + Y);
    FNorthEdge := (Y = 0);
    FWestEdge := (X = 0);
    FEastEdge := (X = Pred (Width));
    FSouthEdge := (Y = Pred (Height));
    SetTile (X, Y, Result);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZELevel.CreateTiles (Reader: IZbFileReader);
var
  X, Y: integer;
  theTile: TZETile;
begin
  //if (Reader = NIL) then Exit;
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do begin
      theTile := NewTile (X, Y, Reader);
      FMotionMap [X, Y] := @theTile.FPassability;
    end;
  //
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do begin
      Self [X, Y].InitNeighbors;
      Self [X, Y].Surface.UpdateTransitions (FALSE);
      Self [X, Y].PassabilityChanged;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.PerformScanNWToSE (ScanFunc: TZELevelScanFunc;
  LoopFunc: TZELevelLoopFunc; lParam1, lParam2: integer): TZETile;
var
  __Row, __Column: integer;
  __Y, __X: integer;
  bFinished: boolean;
  Tile: TZETile;

  procedure CallLoopHandler (iLoopCount: integer; LoopPhase: TZEScannerLoopPhase);
  begin
    if (Assigned (LoopFunc)) then
      LoopFunc (Tile, iLoopCount, LoopPhase, lParam1, lParam2);
  end;

begin
  Result := NIL;
  __Row := 0;
  CallLoopHandler (1, llpLoopOuterInit);
  // scan the upper half
  while (__Row < Height) do begin
    __X := 0;
    __Y := __Row;
    CallLoopHandler (1, llpLoopInnerInit);
    while (true) do begin
      // get a tile, skip out if NIL
      Tile := Self [__X, __Y];
      if (Tile = NIL) then break;
      // call function, skip out if it says so
      CallLoopHandler (1, llpLoopInnerPreProcess);
      bFinished := ScanFunc (Tile, lParam1, lParam2);
      CallLoopHandler (1, llpLoopInnerPostProcess);
      if (bFinished) then begin
        Result := Tile;
        Exit;
      end;
      // move to next tile
      Dec (__Y); Inc (__X);
    end;
    //
    Inc (__Row);
    CallLoopHandler (1, llpLoopOuterTailEnd);
  end;
  //
  // scan the lower half
  __Column := 1;
  CallLoopHandler (2, llpLoopOuterInit);
  while (__Column < Width) do begin
    __X := __Column;
    __Y := Pred (Height);
    CallLoopHandler (2, llpLoopInnerInit);
    while (true) do begin
      // get a tile, skip out if NIL
      Tile := Self [__X, __Y];
      if (Tile = NIL) then break;
      // call function, skip out if it says so
      CallLoopHandler (2, llpLoopInnerPreProcess);
      bFinished := ScanFunc (Tile, lParam1, lParam2);
      CallLoopHandler (2, llpLoopInnerPostProcess);
      if (bFinished) then begin
        Result := Tile;
        Exit;
      end;
      // move to next tile
      Dec (__Y); Inc (__X);
    end;
    //
    Inc (__Column);
    CallLoopHandler (2, llpLoopOuterTailEnd);
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.PerformScanSEToNW (ScanFunc: TZELevelScanFunc;
  LoopFunc: TZELevelLoopFunc; lParam1, lParam2: integer): TZETile;
var
  __Row, __Column: integer;
  __Y, __X: integer;
  bFinished: boolean;
  Tile: TZETile;

  procedure CallLoopHandler (iLoopCount: integer; LoopPhase: TZEScannerLoopPhase);
  begin
    if (Assigned (LoopFunc)) then
      LoopFunc (Tile, iLoopCount, LoopPhase, lParam1, lParam2);
  end;

begin
  Result := NIL;
  __Row := Pred (Height);
  CallLoopHandler (1, llpLoopOuterInit);
  // scan the upper half
  while (__Row >= 0) do begin
    __X := Pred (Width);
    __Y := __Row;
    CallLoopHandler (1, llpLoopInnerInit);
    while (true) do begin
      // get a tile, skip out if NIL
      Tile := Self [__X, __Y];
      if (Tile = NIL) then break;
      // call function, skip out if it says so
      CallLoopHandler (1, llpLoopInnerPreProcess);
      bFinished := ScanFunc (Tile, lParam1, lParam2);
      CallLoopHandler (1, llpLoopInnerPostProcess);
      if (bFinished) then begin
        Result := Tile;
        Exit;
      end;
      // move to next tile
      Inc (__Y); Dec (__X);
    end;
    //
    Dec (__Row);
    CallLoopHandler (1, llpLoopOuterTailEnd);
  end;
  //
  // scan the lower half
  __Column := Pred (Width) - 1;
  CallLoopHandler (2, llpLoopOuterInit);
  while (__Column < Width) do begin
    __X := __Column;
    __Y := 0;
    CallLoopHandler (2, llpLoopInnerInit);
    while (true) do begin
      // get a tile, skip out if NIL
      Tile := Self [__X, __Y];
      if (Tile = NIL) then break;
      // call function, skip out if it says so
      CallLoopHandler (2, llpLoopInnerPreProcess);
      bFinished := ScanFunc (Tile, lParam1, lParam2);
      CallLoopHandler (2, llpLoopInnerPostProcess);
      if (bFinished) then begin
        Result := Tile;
        Exit;
      end;
      // move to next tile
      Inc (__Y); Dec (__X);
    end;
    //
    Dec (__Column);
    CallLoopHandler (2, llpLoopOuterTailEnd);
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.PerformScanSWToNE (ScanFunc: TZELevelScanFunc;
  LoopFunc: TZELevelLoopFunc; lParam1, lParam2: integer): TZETile;
begin
  Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.PerformScanNEToSW (ScanFunc: TZELevelScanFunc;
  LoopFunc: TZELevelLoopFunc; lParam1, lParam2: integer): TZETile;
begin
  Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.NewTile (X, Y: integer; Reader: IZbFileReader): TZETile;
begin
  Result := AddTile (X, Y, Reader, TZETile);
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.FindPath (StartTile, TargetTile: TZETile): TList;
var
  PathFinder: TZbPathFinderEx;
  pCurrent, pNext: PPoint;
  iIndex: integer;
  Direction: TZbDirection;
begin
  Result := NIL;
  if (StartTile = NIL) OR (TargetTile = NIL) then Exit;
  //
  PathFinder := TZbPathFinderEx.Create (FMotionMap);
  if (PathFinder = NIL) then Exit;
  //
  Result := PathFinder.SearchForPath (StartTile.GridPosition,
    TargetTile.GridPosition);//, Width + Height); // added step-checking...
  if (Result <> NIL) then begin
    // get the original point, it's at the end of the list
    iIndex := Pred (Result.Count);
    pCurrent := PPoint (Result [iIndex]);
    // make sure to clear out the last entry, we don't need it anymore
    Result [iIndex] := NIL;
    // move down to next to the last
    Dec (iIndex);
    // process downwards
    while (iIndex >= 0) do begin
      // get next point in line
      pNext := PPoint (Result [iIndex]);
      // convert the two points into a direction
      Direction := LocationsToVector (pCurrent^, pNext^);
      // store this one, in place of the PPoint
      Result [iIndex] := Pointer (Direction);
      // move down one notch
      Dec (iIndex);
      // clean up the current one, and set current to next
      Dispose (pCurrent);
      pCurrent := pNext;
    end;
    // just to be sure...
    Result.Pack;
  end;
  //
  PathFinder.Free;
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.FindPath (StartPos, TargetPos: TPoint): TList;
begin
  Result := FindPath (Self [StartPos.X, StartPos.Y], Self [TargetPos.X, TargetPos.Y]);
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.FindPath (StartPos: TPoint; TargetTile: TZETile): TList;
begin
  Result := FindPath (Self [StartPos.X, StartPos.Y], TargetTile);
end;

//////////////////////////////////////////////////////////////////////////
function TZELevel.FindPath (StartTile: TZETile; TargetPos: TPoint): TList;
begin
  Result := FindPath (StartTile, Self [TargetPos.X, TargetPos.Y]);
end;


{ TZEMap }

//////////////////////////////////////////////////////////////////////////
constructor TZEMap.Create (AWidth, AHeight: integer);
begin
  inherited Create;
  FDimension := Point (AWidth, AHeight);
  FMapId := NIL;
  FLevels := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEMap.Create (Reader: IZbFileReader);
begin
  inherited Create;
  FMapId := NIL;
  Load (Reader);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEMap.Destroy;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FLevels.Count) do begin
    DisposeLevel (Levels [iIndex]);
    FLevels [iIndex] := NIL;
  end;
  if (FMapId <> NIL) then StrDispose (FMapId);
  FLevels.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMap.Load (Reader: IZbFileReader);
var
  iIndex, iCount: integer;
begin
  FMapId := Reader.ReadPStr;
  FDimension.X := Reader.ReadInteger;
  FDimension.Y := Reader.ReadInteger;
  //
  iCount := Reader.ReadInteger;
  FLevels := TList.Create;
  for iIndex := 0 to Pred (iCount) do LoadLevel (Reader);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMap.Save (Writer: IZbFileWriter);
var
  iIndex: integer;
begin
  with Writer do begin
    WritePStr (FMapId);
    WriteInteger (FDimension.X);
    WriteInteger (FDimension.Y);
    WriteInteger (FLevels.Count);
    //
    for iIndex := 0 to Pred (FLevels.Count) do
      TZELevel (FLevels [iIndex]).Save (Writer);
    //
  end;
end;


//////////////////////////////////////////////////////////////////////////
function TZEMap.GetLevelCount: integer;
begin
  Result := FLevels.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMap.GetLevel (iIndex: integer): TZELevel;
begin
  if (iIndex >= 0) AND (iIndex < FLevels.Count) then
    Result := TZELevel (FLevels [iIndex])
    else Result := NIL;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMap.DisposeLevel (Level: TZELevel);
begin
  Level.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMap.PostProcessLevel (Level: TZELevel);
begin
  // nothing to do here
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMap.IAddLevel (Level: TZELevel);
begin
  if (Level <> NIL) then begin
    FLevels.Add (Pointer (Level));
    PostProcessLevel (Level);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMap.AddLevel (LevelClass: TZELevelClass): TZELevel;
begin
  Result := LevelClass.Create (Self);
  if (Result <> NIL) then IAddLevel (Result);
end;

//////////////////////////////////////////////////////////////////////////
function TZEMap.LoadLevel (Reader: IZbFileReader): TZELevel;
begin
  Result := TZELevel.Create (Self, Reader);
  if (Result <> NIL) then IAddLevel (Result);
end;

//////////////////////////////////////////////////////////////////////////
function TZEMap.GetMapId: string;
begin
  Result := IfThen (FMapId = NIL, '', String (FMapId));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMap.SetMapId (AMapId: string);
begin
  if (FMapId <> NIL) then StrDispose (FMapId);
  if (AMapId <> '') then
    FMapId := StrNew (PChar (AMapId))
    else FMapId := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMap.NewLevel: TZELevel;
begin
  Result := AddLevel (TZELevel);
end;

//////////////////////////////////////////////////////////////////////////
function TZEMap.Valid (X, Y, Z: integer): boolean;
begin
  Result := ((X >= 0) AND (X < Width)) AND
            ((Y >= 0) AND (Y < Height)) AND
            ((Z >= 0) AND (Z < FLevels.Count));
end;

//////////////////////////////////////////////////////////////////////////
function TZEMap.Valid (Vector: TZbVector): boolean;
begin
  Result := Valid (Vector.X, Vector.Y, Vector.Z);
end;



end.

