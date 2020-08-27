{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEMapBasics.PAS
              Represents a Generic Multi-layered, two-dimensional
              Grid.  This is the ancestor of all the other maps.
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

unit ZZEMapBasics;

interface

uses
  Types,
  Classes,
  ZbScriptable,
  ZbArray2D,
  ZZESupport;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETileData = Pointer;
  //
  TZECustomTileClass = class of TZECustomTile;
  TZECustomTile = class;
  //
  TZECustomLevelClass = class of TZECustomLevel;
  TZECustomLevel = class;
  //
  TZECustomMapClass = class of TZECustomMap;
  TZECustomMap = class;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomTile = class (TZbScriptable)
  private
    FOwner: TZECustomLevel;
    FLocation: TPoint;
    FData: TList;
  protected
    function GetCount: integer;
    function GetTileData (iIndex: integer): TZETileData; virtual;
    procedure DisposeTileData (TileData: TZETileData; lParam: integer); virtual;
    procedure SetTileDataDirect (iIndex: integer; TileData: TZETileData);
  public
    constructor Create (AOwner: TZECustomLevel); virtual;
    destructor Destroy; override;
    //
    procedure Clear; virtual;
    //
    procedure SetTileData (iIndex: integer; TileData: TZETileData); virtual;
    procedure AddTileData (TileData: TZETileData); virtual;
    //
    function GetNeighbor (iDirection: TZEDirection): TZECustomTile;
    function IsNeighbor (Target: TZECustomTile): boolean;
    function GetDirectionTo (Target: TZECustomTile): TZEDirection;
    function HowFarTo (Target: TZECustomTile): integer;
    //
    property Owner: TZECustomLevel read FOwner;
    property Location: TPoint read FLocation;
    property X: integer read FLocation.X;
    property Y: integer read FLocation.Y;
    property Count: integer read GetCount;
    property Data [iIndex: integer]: TZETileData
      read GetTileData write SetTileData; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEScannerLoopPhase = (
    llpLoopOuterInit,
    llpLoopInnerInit,
    llpLoopInnerPreProcess,
    llpLoopInnerPostProcess,
    llpLoopOuterTailEnd);

  TZECustomLevelLoopFunc = procedure (Tile: TZECustomTile;
    iLoopCount: integer; LoopPhase: TZEScannerLoopPhase;
    lParam1, lParam2: integer);

  TZECustomLevelScanFunc = function (Tile: TZECustomTile;
    lParam1, lParam2: integer): boolean;

  TZECustomLevelScanner = function (
    ScanFunc: TZECustomLevelScanFunc; LoopFunc: TZECustomLevelLoopFunc;
    lParam1, lParam2: integer): TZECustomTile of object;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomLevel = class (TZbScriptable)
  private
    FOwner: TZECustomMap;
    FIndex: integer;
    FDimension: TPoint;
    FData: TZbTwoDimensionalList;
    FScanner: TZECustomLevelScanner;
  protected
    function GetTile (X, Y: integer): TZECustomTile;
    procedure SetTile (X, Y: integer; Tile: TZECustomTile);
    procedure DisposeTile (Tile: TZECustomTile); virtual;
    function AddTile (X, Y: integer; TileClass: TZECustomTileClass): TZECustomTile; virtual;
    //
    function PerformScanNWToSE (
      ScanFunc: TZECustomLevelScanFunc; LoopFunc: TZECustomLevelLoopFunc;
      lParam1, lParam2: integer): TZECustomTile;
    function PerformScanSEToNW (
      ScanFunc: TZECustomLevelScanFunc; LoopFunc: TZECustomLevelLoopFunc;
      lParam1, lParam2: integer): TZECustomTile;
    function PerformScanSWToNE (
      ScanFunc: TZECustomLevelScanFunc; LoopFunc: TZECustomLevelLoopFunc;
      lParam1, lParam2: integer): TZECustomTile;
    function PerformScanNEToSW (
      ScanFunc: TZECustomLevelScanFunc; LoopFunc: TZECustomLevelLoopFunc;
      lParam1, lParam2: integer): TZECustomTile;
    //
    property Scanner: TZECustomLevelScanner read FScanner write FScanner;
    //
  public
    constructor Create (AOwner: TZECustomMap); virtual;
    destructor Destroy; override;
    //
    function NewTile (X, Y: integer): TZECustomTile; virtual;
    //
    property Owner: TZECustomMap read FOwner;
    property LevelIndex: integer read FIndex;
    property Dimension: TPoint read FDimension;
    property Width: integer read FDimension.X;
    property Height: integer read FDimension.Y;
    property Data [X, Y : integer]: TZECustomTile read GetTile write SetTile; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomMap = class (TZbScriptable)
  private
    FDimension: TPoint;
    FLevels: TList;
  protected
    function GetLevelCount: integer;
    function GetLevel (iIndex: integer): TZECustomLevel;
    procedure DisposeLevel (Level: TZECustomLevel); virtual;
    function AddLevel (LevelClass: TZECustomLevelClass): TZECustomLevel; virtual;
  public
    constructor Create (AWidth, AHeight: integer); virtual;
    destructor Destroy; override;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal); virtual; abstract;
    function NewLevel: TZECustomLevel; virtual;
    //
    property Dimension: TPoint read FDimension;
    property Width: integer read FDimension.X;
    property Height: integer read FDimension.Y;
    property Count: integer read GetLevelCount;
    property Levels [iIndex: integer]: TZECustomLevel read GetLevel; default;
  end;


implementation

uses
  Math,
  SysUtils,
  ZEDXDev;


{ TZECustomTile }

//////////////////////////////////////////////////////////////////////////
constructor TZECustomTile.Create (AOwner: TZECustomLevel);
begin
  inherited Create;
  FOwner := AOwner;
  FLocation := Point (-1, -1);
  FData := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZECustomTile.Destroy;
begin
  Clear;
  FData.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomTile.Clear;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FData.Count) do
    begin
      DisposeTileData (TZETileData (FData [iIndex]), iIndex);
      FData [iIndex] := NIL;
    end;
  //
  FData.Pack;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomTile.GetCount: integer;
begin
  Result := FData.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomTile.GetTileData (iIndex: integer): TZETileData;
begin
  if (iIndex >= 0) AND (iIndex < FData.Count) then
    Result := TZETileData (FData [iIndex])
  else
    Result := NIL;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomTile.SetTileData (iIndex: integer; TileData: TZETileData);
begin
  if (iIndex >= 0) AND (iIndex < FData.Count) then
    begin
      DisposeTileData (TZETileData (FData [iIndex]), iIndex);
      FData [iIndex] := TileData;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomTile.DisposeTileData (TileData: TZETileData; lParam: integer);
begin
  // nothing doing, since TileData need not be an object...
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomTile.SetTileDataDirect (iIndex: integer; TileData: TZETileData);
begin
  if (iIndex >= 0) AND (iIndex < Pred (FData.Count)) then
    FData [iIndex] := Pointer (TileData);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomTile.AddTileData (TileData: TZETileData);
begin
  FData.Add (Pointer (TileData));
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomTile.GetNeighbor (iDirection: TZEDirection): TZECustomTile;
begin
  Result := NIL;
  if (FOwner <> NIL) then
    with FLocation do
      case iDirection of
        // cardinal directions first
        tdNorth:      Result := FOwner [X, Pred (Y)];
        tdEast:       Result := FOwner [Succ (X), Y];
        tdWest:       Result := FOwner [Pred (X), Y];
        tdSouth:      Result := FOwner [X, Succ (Y)];
        // hybrids
        tdNorthEast:  Result := FOwner [Succ (X), Pred (Y)];
        tdNorthWest:  Result := FOwner [Pred (X), Pred (Y)];
        tdSouthEast:  Result := FOwner [Succ (X), Succ (Y)];
        tdSouthWest:  Result := FOwner [Pred (X), Succ (Y)];
      end; // case
    // with
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomTile.IsNeighbor (Target: TZECustomTile): boolean;
var
  dX, dY: integer;
begin
  Result := false;
  if (Target = NIL) then Exit;
  //
  dX := Abs (FLocation.X - Target.FLocation.X);
  dY := Abs (FLocation.Y - Target.FLocation.Y);
  //
  Result := (dX <= 1) AND (dY <= 1);
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomTile.GetDirectionTo (Target: TZECustomTile): TZEDirection;
var
  dX, dY: integer;
  CurPos, RelPos: TPoint;
  Angle, Intermediate: integer;

begin
  Result := tdUnknown;
  if (Target = NIL) OR (Target = Self) OR
     (Target.Owner <> Owner) then Exit;
  //
  CurPos := FLocation;
  RelPos := Target.FLocation;
  //
  dX := RelPos.X - CurPos.X;
  dY := RelPos.Y - CurPos.Y;
  if (dX = 0) AND (dY = 0) then Exit;
  //
  // catch special case, dY is 0, because this will trigger a division by 0 error
  if (dY = 0)  then begin
    if (dX > 0) then
      Result := tdEast
      else Result := tdWest;
    //
  end else if (dX = 0) then begin
    if (dY > 0) then
      Result := tdSouth
      else Result := tdNorth
    //
  end else begin
    Intermediate := Abs (Round (RadToDeg (ArcTan2 (dX, dY))));
    //
    // first quadrant calculations
    if (dX >= 0) AND (dY <= 0) then
      Angle := 180 - Intermediate
    // second quadrant
    else if (dX >= 0) AND (dY >= 0) then
      Angle := 180 - Intermediate
    // third quadrant
    else if (dX <= 0) AND (dY >= 0) then
      Angle := 180 + Intermediate
    // fourth quadrant
    else
      Angle := 360 - Intermediate;
    //
    //if (Angle >= 0) AND (Angle <= 40) then
    //  Result := tdNorth
    if (Angle >= 41) AND (Angle <= 50) then
      Result := tdNorthEast
    else if (Angle >= 51) AND (Angle <= 130) then
      Result := tdEast
    else if (Angle >= 131) AND (Angle <= 140) then
      Result := tdSouthEast
    else if (Angle >= 141) AND (Angle <= 220) then
      Result := tdSouth
    else if (Angle >= 221) AND (Angle <= 230) then
      Result := tdSouthWest
    else if (Angle >= 231) AND (Angle <= 310) then
      Result := tdWest
    else if (Angle >= 311) AND (Angle <= 320) then
      Result := tdNorthWest
    else
      Result := tdNorth;   (**)
    //
    //DebugPrint (Format ('dX=[%d], dY=[%d], Inter=[%d], Angle=[%d]',
    //  [dX, dY, Intermediate, Angle]));
  end;
  //

end;

//////////////////////////////////////////////////////////////////////////
function TZECustomTile.HowFarTo (Target: TZECustomTile): integer;
begin
  Result := 0;
  if (Target = NIL) then Exit;
  if (IsNeighbor (Target)) then
    Result := 1
    else  Result := Round (SqRt (
        Sqr (Abs (FLocation.X - Target.FLocation.X)) +
        Sqr (Abs (FLocation.Y - Target.FLocation.Y))
      ));
end;


{ TZECustomLevel }

//////////////////////////////////////////////////////////////////////////
constructor TZECustomLevel.Create (AOwner: TZECustomMap);
begin
  inherited Create;
  FOwner := AOwner;
  FDimension := FOwner.Dimension;
  FIndex := FOwner.Count;
  FData := TZbTwoDimensionalList.Create (Width, Height);
  FScanner := PerformScanNWToSE;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZECustomLevel.Destroy;
var
  X, Y: integer;
begin
  for X := 0 to Pred (Width) do
    for Y := 0 to Pred (Height) do
      begin
        DisposeTile (TZECustomTile (FData [X, Y]));
        FData [X, Y] := NIL;
      end;
  //
  FData.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomLevel.GetTile (X, Y: integer): TZECustomTile;
begin
  Result := TZECustomTile (FData [X, Y]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomLevel.SetTile (X, Y: integer; Tile: TZECustomTile);
begin
  if (FData <> NIL) then DisposeTile (TZECustomTile (FData [X, Y]));
  FData [X, Y] := Pointer (Tile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomLevel.DisposeTile (Tile: TZECustomTile);
begin
  Tile.Free;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomLevel.AddTile (X, Y: integer; TileClass: TZECustomTileClass): TZECustomTile;
begin
  Result := TileClass.Create (Self);
  if (Result <> NIL) then
    begin
      Result.FLocation := Point (X, Y);
      //
      DisposeTile (TZECustomTile (Data [X, Y]));
      FData [X, Y] := Pointer (Result);
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomLevel.PerformScanNWToSE (ScanFunc: TZECustomLevelScanFunc;
  LoopFunc: TZECustomLevelLoopFunc; lParam1, lParam2: integer): TZECustomTile;
var
  __Row, __Column: integer;
  __Y, __X: integer;
  bFinished: boolean;
  Tile: TZECustomTile;

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
  while __Row < Height do
    begin
      __X := 0;
      __Y := __Row;
      CallLoopHandler (1, llpLoopInnerInit);
      while (true) do
        begin
          // get a tile, skip out if NIL
          Tile := Self [__X, __Y];
          if (Tile = NIL) then break;
          // call function, skip out if it says so
          CallLoopHandler (1, llpLoopInnerPreProcess);
          bFinished := ScanFunc (Tile, lParam1, lParam2);
          CallLoopHandler (1, llpLoopInnerPostProcess);
          if (bFinished) then
            begin
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
  while (__Column < Width) do
    begin
      __X := __Column;
      __Y := Pred (Height);
      CallLoopHandler (2, llpLoopInnerInit);
      while (true) do
        begin
          // get a tile, skip out if NIL
          Tile := Self [__X, __Y];
          if (Tile = NIL) then break;
          // call function, skip out if it says so
          CallLoopHandler (2, llpLoopInnerPreProcess);
          bFinished := ScanFunc (Tile, lParam1, lParam2);
          CallLoopHandler (2, llpLoopInnerPostProcess);
          if (bFinished) then
            begin
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
function TZECustomLevel.PerformScanSEToNW (ScanFunc: TZECustomLevelScanFunc;
  LoopFunc: TZECustomLevelLoopFunc; lParam1, lParam2: integer): TZECustomTile;
var
  __Row, __Column: integer;
  __Y, __X: integer;
  bFinished: boolean;
  Tile: TZECustomTile;

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
  while __Row >= 0 do
    begin
      __X := Pred (Width);
      __Y := __Row;
      CallLoopHandler (1, llpLoopInnerInit);
      while (true) do
        begin
          // get a tile, skip out if NIL
          Tile := Self [__X, __Y];
          if (Tile = NIL) then break;
          // call function, skip out if it says so
          CallLoopHandler (1, llpLoopInnerPreProcess);
          bFinished := ScanFunc (Tile, lParam1, lParam2);
          CallLoopHandler (1, llpLoopInnerPostProcess);
          if (bFinished) then
            begin
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
  while (__Column < Width) do
    begin
      __X := __Column;
      __Y := 0;
      CallLoopHandler (2, llpLoopInnerInit);
      while (true) do
        begin
          // get a tile, skip out if NIL
          Tile := Self [__X, __Y];
          if (Tile = NIL) then break;
          // call function, skip out if it says so
          CallLoopHandler (2, llpLoopInnerPreProcess);
          bFinished := ScanFunc (Tile, lParam1, lParam2);
          CallLoopHandler (2, llpLoopInnerPostProcess);
          if (bFinished) then
            begin
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
function TZECustomLevel.PerformScanSWToNE (ScanFunc: TZECustomLevelScanFunc;
  LoopFunc: TZECustomLevelLoopFunc; lParam1, lParam2: integer): TZECustomTile;
begin
  Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomLevel.PerformScanNEToSW (ScanFunc: TZECustomLevelScanFunc;
  LoopFunc: TZECustomLevelLoopFunc; lParam1, lParam2: integer): TZECustomTile;
begin
  Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomLevel.NewTile (X, Y: integer): TZECustomTile;
begin
  Result := AddTile (X, Y, TZECustomTile);
end;


{ TZECustomMap }

//////////////////////////////////////////////////////////////////////////
constructor TZECustomMap.Create (AWidth, AHeight: integer);
begin
  inherited Create;
  FDimension := Point (AWidth, AHeight);
  FLevels := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZECustomMap.Destroy;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FLevels.Count) do
    begin
      DisposeLevel (Levels [iIndex]);
      FLevels [iIndex] := NIL;
    end;
  //
  FLevels.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomMap.GetLevelCount: integer;
begin
  Result := FLevels.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomMap.GetLevel (iIndex: integer): TZECustomLevel;
begin
  if (iIndex >= 0) AND (iIndex < FLevels.Count) then
    Result := TZECustomLevel (FLevels [iIndex])
  else
    Result := NIL;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomMap.DisposeLevel (Level: TZECustomLevel);
begin
  Level.Free;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomMap.AddLevel (LevelClass: TZECustomLevelClass): TZECustomLevel;
begin
  Result := LevelClass.Create (Self);
  if (Result <> NIL) then FLevels.Add (Pointer (Result));
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomMap.NewLevel: TZECustomLevel;
begin
  Result := AddLevel (TZECustomLevel);
end;

end.

