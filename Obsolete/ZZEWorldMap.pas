unit ZZEWorldMap;

interface

uses
  Types,
  Classes,
  ZbScriptable,
  ZbArray2D,
  ZbGameUtils,
  //
  ZZESupport,
  ZZEMapBasics,
  ZZEScrObjects,
  ZZEWorldEntity;

const
  PROP_NAME_USEABLE             = 'Useable';
  PROP_NAME_SELECTABLE          = 'Selectable';
  //
  PROP_NAME_TERRAIN_HEIGHT      = 'TerrainHeight';

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldEvent = (
      // elementary events
      wevTerrainChanged,                    // new terrain setup
      wevTileCleared,                       // terrain was removed, so...
      wevTransitionsChanged,                // transitions recalculated
      wevTransitionsCleared,                // terrain transitions removed
      wevFloorChanged,                      // floor has changed
      wevFloorCleared,                      // flor was removed
      wevWallChanged,                       // wall has changed
      wevWallCleared,                       // wall remodelled
      wevDominantChanged,                   // new dominant in town
      wevDominantCleared,                   // dominant was subsumed
      wevDebrisAdded,                       // a new debris added...
      wevDebrisCleared,                     // a debris was discarded
      //
      wevTileChanged,
      //
      wevStartingLocationReplaced,          // starting location was removed
      //
      wevGlobalRefresh,
      wevNewMapLevel,
      wevNewMapLayer,
      wevNewTile
    );

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldEventHandler = procedure (WorldEvent: TZEWorldEvent;
    pParam1, pParam2: Pointer; lParam1, lParam2: integer) of object;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldObject = class (TZEWorldEntity)
  private
    FAtTile: TZECustomTile;
    FSelectable: boolean;
    FUseable: boolean;
    //
  protected
    property AtTile: TZECustomTile read FAtTile write FAtTile;
  public
    constructor Create (AName, AObjectID: string); override;
    destructor Destroy; override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal); override;
    //
    property Selectable: boolean read FSelectable;
    property Useable: boolean read FUseable write FUseable;
    property Tile: TZECustomTile read FAtTile;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldTerrain = class (TZEWorldObject)
  private
    FTerrainHeight: integer;
    FTransitionNames: TStrings;
  public
    constructor Create (AName, AObjectID: string); override;
    destructor Destroy; override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure ClearTransitions;
    procedure GenerateTransitions (bPropagate: boolean = true);
    procedure UpdateNeighborTransitions;
    //
    property TerrainHeight: integer read FTerrainHeight write FTerrainHeight;
    property TransitionNames: TStrings read FTransitionNames;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  TZEWorldWallCode = (wcNorth, wcEast, wcSouth, wcWest);

  TZEWorldTile = class (TZECustomTile)
  private
    FTerrain: TZEWorldTerrain;
    FFloor: TZEWorldObject;
    FDominant: TZEWorldObject;
    FWalls: array [wcNorth..wcWest] of TZEWorldObject;
    FSpecial: Pointer;
  protected
    function GetPassability: boolean;
    procedure DisposeTileData (TileData: TZETileData; lParam: integer); override;
    //
    procedure ClearTile;
    function GetWall (wcPosition: TZEWorldWallCode): TZEWorldObject;
    function GetDebris (iIndex: integer): TZEWorldObject;
    function GetDebrisCount: integer;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal);
  public
    constructor Create (AOwner: TZECustomLevel); override;
    destructor Destroy; override;
    //
    function SetTerrain (TerrainID: string): TZEWorldObject;
    function SetFloor (FloorID: string): TZEWorldObject;
    function SetDominant (DominantID: string): TZEWorldObject;
    function SetWalls (WhichWall: TZEWorldWallCode; WallID: string): TZEWorldObject;
    function AddDebris (DebrisID: string): TZEWorldObject;
    //
    procedure MoveDominantTo (DestTile: TZEWorldTile);
    //
    property Passable: boolean read GetPassability;
    property Terrain: TZEWorldTerrain read FTerrain;
    property Floor: TZEWorldObject read FFloor;
    property Dominant: TZEWorldObject read FDominant;
    property Walls [wcPosition: TZEWorldWallCode]: TZEWorldObject read GetWall;
    property Debris [iIndex: integer]: TZEWorldObject read GetDebris;
    property DebrisCount: integer read GetDebrisCount;
    property Special: Pointer read FSpecial write FSpecial;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldLevel = class (TZECustomLevel)
  private
    FMotionMap: TZbTwoDimensionalList;
  protected
    procedure UpdateMotionMapAt (RefTile: TZEWorldTile);
  public
    constructor Create (AOwner: TZECustomMap); override;
    destructor Destroy; override;
    //
    function NewTile (X, Y: integer): TZECustomTile; override;
    procedure UpdateMotionMap (RefTile: TZEWorldTile = NIL);
    function FindPath (StartTile, TargetTile: TZECustomTile): TList;
    //
    property MotionMap: TZbTwoDimensionalList read FMotionMap;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldMap = class (TZECustomMap)
  private
    FStartingLocation: TZEVector;
  protected
    procedure SetStartingLocation (ALocation: TZEVector);
  public
    constructor Create (AWidth, AHeight: integer); override;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal); override;
    function NewLevel: TZECustomLevel; override;
    //
    property StartingLocation: TZEVector
      read FStartingLocation write SetStartingLocation;
  end;


  procedure GenerateWorldEvent (WorldEvent: TZEWorldEvent; pParam1: Pointer = NIL;
      pParam2: Pointer = NIL; lParam1: integer = 0; lParam2: integer = 0);

var
  WorldEventHandler: TZEWorldEventHandler = NIL;


implementation

uses
  SysUtils,
  ZbStringUtils,
  ZbPathFinder,
  ZEDXDev;


//////////////////////////////////////////////////////////////////////////
procedure GenerateWorldEvent (WorldEvent: TZEWorldEvent; pParam1, pParam2: Pointer;
  lParam1, lParam2: integer);
begin
  if (Assigned (WorldEventHandler)) then
    WorldEventHandler (WorldEvent, pParam1, pParam2, lParam1, lParam2);
end;



{ TZEWorldObject }

//////////////////////////////////////////////////////////////////////////
constructor TZEWorldObject.Create (AName, AObjectID: string);
begin
  inherited;
  //
  FAtTile := NIL;
  FSelectable := false;
  FUseable := false;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWorldObject.Destroy;
begin
  FAtTile := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldObject.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_USEABLE) then
    Result := BooleanToProp (FUseable)
  else if (APropertyname = PROP_NAME_SELECTABLE) then
    Result := BooleanToProp (Selectable)
  else
    Result := inherited GetPropertyValue (APropertyName);
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldObject.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  if (APropertyName = PROP_NAME_USEABLE) then
    Useable := PropToBoolean (Value)
  else if (APropertyname = PROP_NAME_SELECTABLE) then
    FSelectable := PropToBoolean (Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldObject.PerformUpdate (WTicksElapsed: Cardinal);
begin
end;


{ TZEWorldTerrain }

//////////////////////////////////////////////////////////////////////////
constructor TZEWorldTerrain.Create (AName, AObjectID: string);
begin
  inherited;
  FTransitionNames := TStringList.Create;
  FTerrainHeight := 0;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWorldTerrain.Destroy;
begin
  FTransitionNames.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTerrain.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_TERRAIN_HEIGHT) then
    Result := IntegerToProp (FTerrainHeight)
  else
    Result := GetPropertyValue (APropertyName);
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTerrain.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  if (APropertyName = PROP_NAME_TERRAIN_HEIGHT) then begin
    FTerrainHeight := PropToInteger (Value);
    if (AtTile <> NIL) then
      TZEWorldLevel (AtTile.Owner).UpdateMotionMap (TZEWorldTile (AtTile));
  end else
    Result := inherited SetPropertyValue (APropertyName, Value);
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldTerrain.ClearTransitions;
begin
  FTransitionNames.Clear;
  GenerateWorldEvent (wevTransitionsCleared, AtTile, Self, integer (FTransitionNames));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldTerrain.GenerateTransitions (bPropagate: boolean);
var
  Neighbors: array [tdNorth..tdNorthWest] of TZEWorldTerrain;
  dPos: TZEDirection;
  Tile: TZEWorldTile;
  iLastTerrainLevel: integer;
  iTerrainLevel: integer;
  cTerrainName: string;
  dwTransitionCode: Cardinal;
  dwEdges, dwCorners: Cardinal;

const
  EDGE_CODE_NORTH       = $0001;
  EDGE_CODE_EAST        = $0002;
  EDGE_CODE_SOUTH       = $0004;
  EDGE_CODE_WEST        = $0008;
  CORNER_CODE_NE        = $0001;
  CORNER_CODE_SE        = $0002;
  CORNER_CODE_SW        = $0004;
  CORNER_CODE_NW        = $0008;

  TRANSITION_NORTH      = EDGE_CODE_NORTH;
  TRANSITION_NORTH_EAST = (CORNER_CODE_NE SHL 4);
  TRANSITION_EAST       = EDGE_CODE_EAST;
  TRANSITION_SOUTH_EAST = (CORNER_CODE_SE SHL 4);
  TRANSITION_SOUTH      = EDGE_CODE_SOUTH;
  TRANSITION_SOUTH_WEST = (CORNER_CODE_SW SHL 4);
  TRANSITION_WEST       = EDGE_CODE_WEST;
  TRANSITION_NORTH_WEST = (CORNER_CODE_NW SHL 4);

  TransitionCodes: array [tdNorth..tdNorthWest] of Cardinal = (
    TRANSITION_NORTH, TRANSITION_NORTH_EAST,
    TRANSITION_EAST, TRANSITION_SOUTH_EAST,
    TRANSITION_SOUTH, TRANSITION_SOUTH_WEST,
    TRANSITION_WEST, TRANSITION_NORTH_WEST);

begin
  FTransitionNames.Clear;
  //
  // exit at the following conditions:
  // 1. we're in a NULL tile -- meaning we're floating
  // 2. our tile has no owner, it is a floating tile itself
  if (AtTile = NIL) OR (AtTile.Owner = NIL) then Exit;
  //
  // collect the neighboring terrain, and find the
  // highest terrain surrounding us while we're at it
  iLastTerrainLevel := FTerrainHeight;
  for dPos := tdNorth to tdNorthWest do
    begin
      Neighbors [dPos] := NIL;
      Tile := TZEWorldTile (AtTile.GetNeighbor (dPos));
      if (Tile = NIL) then continue;
      //
      Neighbors [dPos] := Tile.Terrain;
      if (Neighbors [dPos] = NIL) then continue;
      //
      if (Neighbors [dPos].FTerrainHeight > iLastTerrainLevel) then
        iLastTerrainLevel := Neighbors [dPos].FTerrainHeight;
    end;
  //
  // if the highest terrain level is ours, no need for transitions
  //if (FTerrainHeight = iLastTerrainLevel) then Exit;
  if (FTerrainHeight < iLastTerrainLevel) then
  //
  // loop over all the terrain levels from the one after us, up
  // to the height we found in the previous loop
  for iTerrainLevel := Succ (FTerrainHeight) to iLastTerrainLevel do
    begin
      dwTransitionCode := 0;
      cTerrainName := '';
      // loop over everyone of course, gathering info as we go
      for dPos := tdNorth to tdNorthWest do
        begin
          if (Neighbors [dPos] = NIL) then continue;
          // if we find one corresponding to THIS level, process it,
          // and then discard it from the list.  this will make the
          // loop run faster since the only comparison necessary is
          // the one checking for NIL (previous line)
          if (Neighbors [dPos].FTerrainHeight = iTerrainLevel) then
            begin
              dwTransitionCode := dwTransitionCode OR TransitionCodes [dPos];
              if (cTerrainName = '') then
                cTerrainName := Neighbors [dPos].ObjectID;
              //
              Neighbors [dPos] := NIL;
            end;
          //
        end;
      //
      // check if a transition code was generated, and process it if so
      if (dwTransitionCode <> 0) then
        begin
          // separate the corners and edges codes...
          dwEdges := dwTransitionCode AND $000F;
          dwCorners := (dwTransitionCode SHR 4) AND $000F;
          //
          // normalize the corners depending on which edge will be used...
          if ((dwEdges AND EDGE_CODE_NORTH) <> 0) then
            dwCorners := dwCorners AND (NOT (CORNER_CODE_NE OR CORNER_CODE_NW));
          if ((dwEdges AND EDGE_CODE_EAST) <> 0) then
            dwCorners := dwCorners AND (NOT (CORNER_CODE_NE OR CORNER_CODE_SE));
          if ((dwEdges AND EDGE_CODE_SOUTH) <> 0) then
            dwCorners := dwCorners AND (NOT (CORNER_CODE_SE OR CORNER_CODE_SW));
          if ((dwEdges AND EDGE_CODE_WEST) <> 0) then
            dwCorners := dwCorners AND (NOT (CORNER_CODE_SW OR CORNER_CODE_NW));
          //
          // create the images of transitions if necessary...
          if (dwEdges <> 0) then
            FTransitionNames.Add (
              cTerrainName + '/EDGE/' + HexByteLookup [dwEdges AND $000F]);
          //
          if (dwCorners <> 0) then
            FTransitionNames.Add (
              cTerrainName + '/CORNER/' + HexByteLookup [dwCorners AND $000F]);
          //
        end;
      //
    end;
  //
  if (bPropagate) then UpdateNeighborTransitions;
  //
  if (FTransitionNames.Count > 0) then
    GenerateWorldEvent (wevTransitionsChanged, AtTile, Self, integer (FTransitionNames));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldTerrain.UpdateNeighborTransitions;
var
  Neighbor: TZEWorldTerrain;
  dPos: TZEDirection;
  Tile: TZEWorldTile;
begin
  if (AtTile = NIL) OR (AtTile.Owner = NIL) then Exit;
  //
  for dPos := tdNorth to tdNorthWest do
    begin
      Tile := TZEWorldTile (AtTile.GetNeighbor (dPos));
      if (Tile = NIL) then continue;
      //
      Neighbor := Tile.Terrain;
      if (Neighbor = NIL) then continue;
      //
      Neighbor.GenerateTransitions (false);
    end;
  //
end;

{ TZEWorldTile }

//////////////////////////////////////////////////////////////////////////
constructor TZEWorldTile.Create (AOwner: TZECustomLevel);
var
  wcIndex: TZEWorldWallCode;
begin
  inherited;
  //
  FSpecial := NIL;
  FTerrain := NIL;
  FFloor := NIL;
  FDominant := NIL;
  for wcIndex := wcNorth to wcWest do FWalls [wcIndex] := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWorldTile.Destroy;
begin
  ClearTile;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.GetPassability: boolean;
begin
  Result := ((Owner as TZEWorldLevel).MotionMap.Cardinals [X, Y] <> 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldTile.DisposeTileData (TileData: TZETileData; lParam: integer);
var
  WObj: TZEWorldObject;
begin
  WObj := TZEWorldObject (TileData);
  if (WObj <> NIL) then WObj.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldTile.ClearTile;
var
  wcIndex: TZEWorldWallCode;
begin
  Clear; // inherited, clears all debris
  FreeAndNIL (FTerrain);
  FreeAndNIL (FFloor);
  FreeAndNIL (FDominant);
  for wcIndex := wcNorth to wcWest do FreeAndNIL (FWalls [wcIndex]);
  //
  GenerateWorldEvent (wevTileCleared, Self);
  TZEWorldLevel (Owner).UpdateMotionMap (Self);
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.GetWall (wcPosition: TZEWorldWallCode): TZEWorldObject;
begin
  Result := FWalls [wcPosition];
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.GetDebris (iIndex: integer): TZEWorldObject;
begin
  if (iIndex >= 0) AND (iIndex < Count) then
    Result := TZEWorldObject (Data [iIndex])
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.GetDebrisCount: integer;
begin
  Result := Count;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldTile.PerformUpdate (WTicksElapsed: Cardinal);
begin
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.SetTerrain (TerrainID: string): TZEWorldObject;
begin
  Result := NIL;
  // if no ID, and we haven't any terrain, do nothing
  if (TerrainID = '') AND (FTerrain = NIL) then Exit;
  // no ID? then ditch the terrain we have...
  // side-effect: removing the terrain removes everything else, be careful
  if (TerrainID = '') AND (FTerrain <> NIL) then begin
    ClearTile;
    Exit;
  end;
  //
  // terrain id is valid, someone's trying to change the terrain under us
  if (FTerrain = NIL) then begin
    FTerrain := TZEWorldTerrain.Create ('', TerrainID);
    FTerrain.AtTile := Self;
  end
    else FTerrain.ObjectID := TerrainID;
  //
  // new terrain set, tell the world?
  GenerateWorldEvent (wevTerrainChanged, Self, FTerrain);
  TZEWorldLevel (Owner).UpdateMotionMap (Self);
  //
  Result := FTerrain;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.SetFloor (FloorID: string): TZEWorldObject;
begin
  Result := NIL;
  // if no ID, and we haven't any floor, do nothing
  if (FloorID = '') AND (FFloor = NIL) then Exit;
  // no ID? then ditch the floor we have...
  if (FloorID = '') AND (FFloor <> NIL) then begin
    FreeAndNIL (FFloor);
    GenerateWorldEvent (wevFloorCleared, Self);
    TZEWorldLevel (Owner).UpdateMotionMap (Self);
    Exit;
  end;
  //
  // id is valid, someone's trying to change the floor
  if (FFloor = NIL) then begin
    FFloor := TZEWorldObject.Create ('', FloorID);
    FFloor.AtTile := Self;
  end
    else FFloor.ObjectID := FloorID;
  //
  // new floor set, tell the world?
  GenerateWorldEvent (wevFloorChanged, Self, FFloor);
  TZEWorldLevel (Owner).UpdateMotionMap (Self);
  //
  Result := FFloor;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.SetDominant (DominantID: string): TZEWorldObject;
begin
  Result := NIL;
  // if no ID, and we haven't any dominant, do nothing
  if (DominantID = '') AND (FDominant = NIL) then Exit;
  // no ID? then ditch the dominant we have...
  if (DominantID = '') AND (FDominant <> NIL) then begin
    FreeAndNIL (FDominant);
    GenerateWorldEvent (wevDominantCleared, Self);
    TZEWorldLevel (Owner).UpdateMotionMap (Self);
    Exit;
  end;
  //
  // id is valid, someone's trying to replace the dominant
  if (FDominant = NIL) then begin
    FDominant := TZEWorldObject.Create ('', DominantID);
    FDominant.AtTile := Self;
    FDominant.Blocker := true;
  end
    else FDominant.ObjectID := DominantID;
  //
  // new dominant in town, tell the world?
  GenerateWorldEvent (wevDominantChanged, Self, FDominant);
  TZEWorldLevel (Owner).UpdateMotionMap (Self);
  //
  Result := FDominant;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.SetWalls (WhichWall: TZEWorldWallCode; WallID: string): TZEWorldObject;
begin
  Result := NIL;
  // if no ID, and we haven't any floor, do nothing
  if (WallID = '') AND (FWalls [WhichWall] = NIL) then Exit;
  // no ID? then ditch the floor we have...
  if (WallID = '') AND (FWalls [WhichWall] <> NIL) then begin
    FreeAndNIL (FWalls [WhichWall]);
    GenerateWorldEvent (wevWallCleared, Self, NIL, Ord (WhichWall));
    TZEWorldLevel (Owner).UpdateMotionMap (Self);
    Exit;
  end;
  //
  // id is valid, someone's trying to change the floor
  if (FWalls [WhichWall] = NIL) then begin
    FWalls [WhichWall] := TZEWorldObject.Create ('', WallID);
    FWalls [WhichWall].AtTile := Self;
  end
    else FWalls [WhichWall].ObjectID := WallID;
  //
  // new floor set, tell the world?
  GenerateWorldEvent (wevWallChanged, Self, FWalls [WhichWall], Ord (WhichWall));
  TZEWorldLevel (Owner).UpdateMotionMap (Self);
  //
  Result := FWalls [WhichWall];
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldTile.AddDebris (DebrisID: string): TZEWorldObject;
begin
  Result := NIL;
  if (DebrisID <> '') then begin
    Result := TZEWorldObject.Create ('', DebrisID);
    Result.AtTile := Self;
    AddTileData (Pointer (Result));
    GenerateWorldEvent (wevDebrisAdded, Self, Result);
    TZEWorldLevel (Owner).UpdateMotionMap (Self);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldTile.MoveDominantTo (DestTile: TZEWorldTile);
begin
  // of course, no destination, or nothing to transfer, exit already
  if (DestTile = NIL) OR (Dominant = NIL) then Exit;
  // if destination have a dominant, NUKE it
  DestTile.SetDominant ('');
  // manipulate, manipulate...
  DestTile.FDominant := FDominant;
  FDominant.AtTile := DestTile;
  FDominant := NIL;
  // tons of events need to be generated, so here goes...
  GenerateWorldEvent (wevDominantCleared, Self);
  TZEWorldLevel (Owner).UpdateMotionMap (Self);
  //
  GenerateWorldEvent (wevDominantChanged, DestTile, FDominant);
  TZEWorldLevel (Owner).UpdateMotionMap (DestTile);
end;


{ TZEWordLevel }

//////////////////////////////////////////////////////////////////////////
constructor TZEWorldLevel.Create (AOwner: TZECustomMap);
var
  X, Y: integer;
begin
  inherited;
  //
  FMotionMap := TZbTwoDimensionalList.Create (Width, Height);
  //
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do
      NewTile (X, Y);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWorldLevel.Destroy;
begin
  FreeAndNIL (FMotionMap);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldLevel.NewTile (X, Y: integer): TZECustomTile;
begin
  Result := AddTile (X, Y, TZEWorldTile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldLevel.UpdateMotionMapAt (RefTile: TZEWorldTile);
//var
//  iIndex: integer;
begin
  FMotionMap.Cardinals [RefTile.X, RefTile.Y] := 0;
  if (RefTile.Terrain = NIL) OR (RefTile.Terrain.ObjectID = '') then Exit;
  if (RefTile.Floor <> NIL) AND (RefTile.Floor.Blocker) then Exit;
  if (RefTile.Dominant <> NIL) AND (RefTile.Dominant.Blocker) then Exit;
  //for iIndex := 0 to Pred (RefTile.Count) do
  //  if (TZEWorldObject (RefTile [iIndex]).Blocker) then Exit;
  if (RefTile.Count > 0) then Exit;
  //
  FMotionMap.Cardinals [RefTile.X, RefTile.Y] := RefTile.Terrain.TerrainHeight;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldLevel.FindPath (StartTile, TargetTile: TZECustomTile): TList;
var
  PF: TZbPathFinder;
  PathSolution: TList;
  pCurrent, pNext: PPoint;
  iIndex: integer;
  Direction: TZEDirection;
begin
  Result := NIL;
  if (StartTile = NIL) OR (TargetTile = NIL) then Exit;
  //
  //
  PF := TZbPathFinder.Create (FMotionMap);
  PathSolution := PF.SearcForPath (StartTile.Location, TargetTile.Location);
  if (PathSolution <> NIL) then begin
    // get the original point, it's at the end of the list
    iIndex := Pred (PathSolution.Count);
    pCurrent := PPoint (PathSolution [iIndex]);
    // make sure to clear out the last entry, we don't need it anymore
    PathSolution [iIndex] := NIL;
    // move down to next to the last
    Dec (iIndex);
    // process downwards
    while (iIndex >= 0) do begin
      // get next point in line
      pNext := PPoint (PathSolution [iIndex]);
      // convert the two points into a direction
      Direction := LocationsToVector (pCurrent^, pNext^);
      // store this one, in place of the PPoint
      PathSolution [iIndex] := Pointer (Direction);
      //
      // move down one notch
      Dec (iIndex);
      // clean up the current one, and set current to next
      Dispose (pCurrent);
      pCurrent := pNext;
    end;
    //
    Result := PathSolution;
    Result.Pack; // just to be sure...
  end;
  //
  PF.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldLevel.UpdateMotionMap (RefTile: TZEWorldTile);
var
  X, Y: integer;
begin
  if (FMotionMap = NIL) then Exit;
  //
  if (RefTile <> NIL) then
    UpdateMotionMapAt (RefTile)
    else begin
      for X := 0 to Pred (Width) do
        for Y := 0 to Pred (Height) do
          UpdateMotionMapAt (TZEWorldTile (Self [X, Y]));
        //
      //
    end;
  //
end;


{ TZEWorldMap }

//////////////////////////////////////////////////////////////////////////
constructor TZEWorldMap.Create (AWidth, AHeight: integer);
begin
  inherited;
  FStartingLocation := Vector (-1, -1, -1);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldMap.SetStartingLocation (ALocation: TZEVector);
var
  OldStart: TZEVector;
begin
  with ALocation do
    if (X < 0) OR (X >= Width) OR (Y < 0) OR (Y >= Height) OR
       (Z < 0) OR (Z >= Count) then Exit;
  //
  OldStart := FStartingLocation;
  FStartingLocation := ALocation;
  //
  GenerateWorldEvent (wevStartingLocationReplaced, @FStartingLocation, @OldStart);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWorldMap.PerformUpdate (WTicksElapsed: Cardinal);
begin
end;

//////////////////////////////////////////////////////////////////////////
function TZEWorldMap.NewLevel: TZECustomLevel;
begin
  Result := AddLevel (TZEWorldLevel);
  GenerateWorldEvent (wevNewMapLevel, Self);
end;



end.

