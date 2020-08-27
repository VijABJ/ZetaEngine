{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEWorldImpl.PAS
              Implementations for ZZEWorldIntf
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/MapEngine/ZZEWorldImpl.pas,v 1.3 2002/11/02 07:01:16 Vij Exp $
  $Log: ZZEWorldImpl.pas,v $
  Revision 1.3  2002/11/02 07:01:16  Vij
  fixed bug in wall code.  it tries to access NIL walls.

  Revision 1.2  2002/10/01 12:43:57  Vij
  Fixed typo in Floor manager class.  Made the FLOOR/WALL family a symbolic
  constant instead of a magic value embedded in code.

  Revision 1.1.1.1  2002/09/11 21:11:33  Vij
  Starting Version Control


 ============================================================================}

{-$DEFINE DONOT_NORMALIZE_TRANSITIONS}
unit ZZEWorldImpl;

interface

uses
  Classes,
  //
  ZblIStrings,
  ZbScriptable,
  ZbDoubleList,
  //
  ZEDXSpriteIntf,
  ZZEWorldIntf;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETerrain = class;
  TZETerrainManager = class;
  TZEFloorManager = class;
  TZEWall = class;
  TZEWallManager = class;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETerrain = class (TInterfacedObject, IZETerrain)
  private
    FName: PChar;
    FIndex: integer;
    FModifier: integer;
    FPassable: boolean;
    FFluidity: integer;
    FDefSprite: IZESprite;
  public
    constructor Create (AName: string; iIndex, iFluidity: integer); virtual;
    destructor Destroy; override;
    //
    // implements IZETerrain
    function GetName: string; stdcall;
    function GetIndex: integer; stdcall;
    function GetModifier: integer; stdcall;
    procedure SetModifier (AModifier: integer); stdcall;
    function GetPassability: boolean; stdcall;
    procedure SetPassability (APassable: boolean); stdcall;
    function GetFluidity: integer; stdcall;
    //
    function GetSpriteVariationCount: integer; stdcall;
    function GetSprite (iVariation: integer): IZESprite; stdcall;
    function GetTransitionSprite (dwTransitionCode: Cardinal): TZETerrainTransition; stdcall;
    //
    property Name: string read GetName;
    property Index: integer read GetIndex;
    property Modifier: integer read GetModifier write SetModifier;
    property Passable: boolean read GetPassability write SetPassability;
    property Fluidity: integer read GetFluidity;
    property SpriteVariationCount: integer read GetSpriteVariationCount;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETerrainManager = class (TInterfacedObject, IZETerrainManager)
  private
    FTerrains: TInterfaceList;
  public
    constructor Create (TerrainDesc: IZbEnumStrings); virtual;
    destructor Destroy; override;
    //
    // implements IZETerrainManager
    function GetTerrainCount: integer; stdcall;
    function GetTerrainByIndex (iIndex: integer): IZETerrain; stdcall;
    function GetTerrainByName (AName: string): IZETerrain; stdcall;
    function GetTerrainName (iIndex: integer): string; stdcall;
    //
    property TerrainCount: integer read GetTerrainCount;
    property TerrainByIndex [iIndex: integer]: IZETerrain read GetTerrainByIndex;
    property TerrainByName [AName: string]: IZETerrain read GetTerrainByName;
    property TerrainNames [iIndex: integer]: string read GetTerrainName;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEFloorManager = class (TInterfacedObject, IZEFloorManager)
  private
    FFloors: IZESprite;
    FFloorCount: integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //
    // implements IZEFloorManager
    function GetFloorCount: integer; stdcall;
    function GetFloorByIndex (iIndex: integer): IZESprite; stdcall;
    //
    property FloorCount: integer read GetFloorCount;
    property Floors [iIndex: integer]: IZESprite read GetFloorByIndex;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWall = class (TInterfacedObject, IZEWall)
  private
    FWallName: PChar;
    FSoundProofed: boolean;
    FSeeThrough: boolean;
    FDestructible: boolean;
    //
    FOrientation: TZEWallOrientation;
    FPosition: TZEWallPosition;
    FState: TZEWallState;
    FSprite: IZESprite;
  protected
    procedure StateChanged;
  public
    constructor Create (AName: PChar; AOrientation: TZEWallOrientation;
      APosition: TZEWallPosition; ASoundProofed, ASeeThrough,
      ADestructible: boolean); virtual;
    destructor Destroy; override;
    //
    // implements IZEWall
    function GetWallName: string; stdcall;
    function GetIsSoundProofed: boolean; stdcall;
    function GetIsSeeThrough: boolean; stdcall;
    function GetIsDestructible: boolean; stdcall;
    //
    function GetOrientation: TZEWallOrientation; stdcall;
    procedure SetOrientation (AOrientation: TZEWallOrientation); stdcall;
    function GetPosition: TZEWallPosition; stdcall;
    procedure SetPosition (APosition: TZEWallPosition); stdcall;
    function GetState: TZEWallState; stdcall;
    procedure SetState (AState: TZEWallState); stdcall;
    function GetSprite: IZESprite; stdcall;
    function Clone: IZEWall; stdcall;
    //
    property WallName: string read GetWallName;
    property IsSoundProofed: boolean read GetIsSoundProofed;
    property IsSeeThrough: boolean read GetIsSeeThrough;
    property IsDestructible: boolean read GetIsDestructible;
    //
    property Orientation: TZEWallOrientation read GetOrientation write SetOrientation;
    property Position: TZEWallPosition read GetPosition write SetPosition;
    property State: TZEWallState read GetState write SetState;
    property Sprite: IZESprite read GetSprite;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWallManager = class (TInterfacedObject, IZEWallManager)
  private
    FWalls: TZbDoubleList;
  public
    constructor Create (WallDesc: IZbEnumStrings); virtual;
    destructor Destroy; override;
    //
    // implements IZEWallManager
    function GetWallCount: integer; stdcall;
    function GetWallByIndex (iIndex: integer): IZEWall; stdcall;
    function GetWallByName (AName: string): IZEWall; stdcall;
    //
    property WallCount: integer read GetWallCount;
    property Walls [iIndex: integer]: IZEWall read GetWallByIndex;
    property Walls2 [AName: string]: IZEWall read GetWallByName;
  end;


implementation

uses
  SysUtils,
  Math,
  JclStrings,
  ZbStringUtils,
  ZEDXSprite,
  ZZECore;


{ TZETerrain - implements IZETerrain }

//////////////////////////////////////////////////////////////////////////
constructor TZETerrain.Create (AName: string; iIndex, iFluidity: integer);
begin
  inherited Create;
  FName := StrNew (PChar (AName));
  FIndex := iIndex;
  FModifier := 1;
  FPassable := TRUE;
  FFluidity := iFluidity;
  FDefSprite := CoreEngine.SpriteFactory.CreateSprite (TERRAIN_FAMILY, Name);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZETerrain.Destroy;
begin
  FDefSprite := NIL;
  StrDispose (FName);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetName: string;
begin
  Result := String (FName);
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetIndex: integer;
begin
  Result := FIndex;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetModifier: integer;
begin
  Result := FModifier;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETerrain.SetModifier (AModifier: integer);
begin
  FModifier := AModifier;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetPassability: boolean;
begin
  Result := FPassable;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETerrain.SetPassability (APassable: boolean);
begin
  FPassable := APassable;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetFluidity: integer;
begin
  Result := FFluidity;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetSpriteVariationCount: integer;
begin
  if (FDefSprite = NIL) then
    Result := 0
    else Result := FDefSprite.FrameCount;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetSprite (iVariation: integer): IZESprite;
begin
  iVariation := EnsureRange (iVariation, 0, Pred (SpriteVariationCount));
  if (iVariation = TERRAIN_DEFAULT_VARIATION) then
    Result := FDefSprite
  else begin
    Result := CoreEngine.SpriteFactory.CreateSprite (TERRAIN_FAMILY, Name);
    Result.CurrentFrame := iVariation;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrain.GetTransitionSprite (dwTransitionCode: Cardinal): TZETerrainTransition;
var
  dwEdges, dwCorners: Cardinal;
begin
  Result.Edges := NIL;
  Result.Corners := NIL;
  if (dwTransitionCode = 0) then Exit;
  //
  // separate the corners and edges codes...
  dwEdges := dwTransitionCode AND $000F;
  dwCorners := (dwTransitionCode SHR 4) AND $000F;
  //
  // normalize the corners depending on which edge will be used...
  {$IFNDEF DONOT_NORMALIZE_TRANSITIONS}
  if ((dwEdges AND EDGE_CODE_NORTH) <> 0) then
    dwCorners := dwCorners AND (NOT (CORNER_CODE_NE OR CORNER_CODE_NW));
  if ((dwEdges AND EDGE_CODE_EAST) <> 0) then
    dwCorners := dwCorners AND (NOT (CORNER_CODE_NE OR CORNER_CODE_SE));
  if ((dwEdges AND EDGE_CODE_SOUTH) <> 0) then
    dwCorners := dwCorners AND (NOT (CORNER_CODE_SE OR CORNER_CODE_SW));
  if ((dwEdges AND EDGE_CODE_WEST) <> 0) then
    dwCorners := dwCorners AND (NOT (CORNER_CODE_SW OR CORNER_CODE_NW));
  {$ENDIF}
  //
  // create the images of transitions if necessary...
  if (dwEdges <> 0) then
    Result.Edges := CoreEngine.SpriteFactory.CreateSprite (TERRAIN_FAMILY,
      Name + TERRAIN_EDGE + HexByteLookup [dwEdges]);
  if (dwCorners <> 0) then
    Result.Corners := CoreEngine.SpriteFactory.CreateSprite (TERRAIN_FAMILY,
      Name + TERRAIN_CORNER + HexByteLookup [dwCorners]);
end;


{ TZETerrainManager - implements IZETerrainManager }

//////////////////////////////////////////////////////////////////////////
constructor TZETerrainManager.Create (TerrainDesc: IZbEnumStrings);
var
  cData, cName: string;
  iHeight, iFluidity, iModifier: integer;
  bPassable: boolean;
  theTerrain: IZETerrain;
begin
  inherited Create;
  FTerrains := TInterfaceList.Create;
  if (TerrainDesc = NIL) then Exit;
  //
  cData := TerrainDesc.First;
  while (cData <> '') do begin
    cName := StrBefore ('=', cData);
    cData := StrAfter ('=', cData);
    //
    iHeight := FTerrains.Count;
    //
    iFluidity := StrToIntSafe (StrBefore (',', cData ));
    cData := StrAfter (',', cData);
    //
    bPassable := Trim (StrBefore (',', cData)) = '1';
    iModifier := StrToIntSafe (StrAfter (',', cData));
    //
    theTerrain := TZETerrain.Create (cName, iHeight, iFluidity);
    theTerrain.Modifier := iModifier;
    theTerrain.Passable := bPassable;
    FTerrains.Add (theTerrain);
    //
    cData := TerrainDesc.Next;
  end;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZETerrainManager.Destroy;
begin
  FTerrains.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrainManager.GetTerrainCount: integer;
begin
  Result := FTerrains.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrainManager.GetTerrainByIndex (iIndex: integer): IZETerrain;
begin
  if (iIndex < 0) OR (iIndex >= FTerrains.Count) then
    Result := NIL
    else Result := IZETerrain (FTerrains [iIndex]);
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrainManager.GetTerrainByName (AName: string): IZETerrain;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FTerrains.Count) do begin
    Result := IZETerrain (FTerrains [iIndex]);
    if (Result = NIL) then continue;
    if (Result.Name = AName) then Exit;
  end;
  Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZETerrainManager.GetTerrainName (iIndex: integer): string;
begin
  if (iIndex < 0) OR (iIndex >= FTerrains.Count) then
    Result := ''
    else Result := IZETerrain (FTerrains [iIndex]).Name;
end;


{ TZEFloorManager }

//////////////////////////////////////////////////////////////////////////
constructor TZEFloorManager.Create;
begin
  inherited Create;
  FFloors := CoreEngine.SpriteFactory.CreateSprite (FLOOR_FAMILY, 'Default');
  if (FFloors <> NIL) then
    FFloorCount := FFloors.FrameCount
    else FFloorCount := 0;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEFloorManager.Destroy;
begin
  FFloors := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEFloorManager.GetFloorCount: integer;
begin
  Result := FFloorCount;
end;

//////////////////////////////////////////////////////////////////////////
function TZEFloorManager.GetFloorByIndex (iIndex: integer): IZESprite;
begin
  if (iIndex < 0) OR (iIndex >= FFloorCount) then
    Result := NIL
  else begin
    Result := CoreEngine.SpriteFactory.CreateSprite (FLOOR_FAMILY, 'Default');
    Result.CurrentFrame := iIndex;
  end;
end;


{ TZEWall }

//////////////////////////////////////////////////////////////////////////
constructor TZEWall.Create (AName: PChar; AOrientation: TZEWallOrientation;
  APosition: TZEWallPosition; ASoundProofed, ASeeThrough, ADestructible: boolean);
begin
  inherited Create;
  //
  FWallName := StrNew (PChar (AName));
  FSoundProofed := ASoundProofed;
  FSeeThrough := ASeeThrough;
  FDestructible := ADestructible;
  //
  FOrientation := AOrientation;
  FPosition := APosition;
  FState := wsNormal;
  FSprite := CoreEngine.SpriteFactory.CreateSprite (WALL_FAMILY, AName);
  //
  StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWall.Destroy;
begin
  FSprite := NIL;
  StrDispose (FWallName);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWall.StateChanged;
begin
  if (FSprite = NIL) then Exit;
  //
  FSprite.CurrentFrame := Ord (FState) +
    IfThen (FOrientation = woEastByWest, NUM_WALL_STATES, 0);
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetWallName: string; stdcall;
begin
  Result := String (FWallName);
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetIsSoundProofed: boolean; stdcall;
begin
  Result := FSoundProofed;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetIsSeeThrough: boolean; stdcall;
begin
  Result := FSeeThrough;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetIsDestructible: boolean; stdcall;
begin
  Result := FDestructible;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetOrientation: TZEWallOrientation; stdcall;
begin
  Result := FOrientation;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWall.SetOrientation (AOrientation: TZEWallOrientation); stdcall;
begin
  FOrientation := AOrientation;
  StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetPosition: TZEWallPosition; stdcall;
begin
  Result := FPosition;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWall.SetPosition (APosition: TZEWallPosition); stdcall;
begin
  FPosition := APosition;
  if (APosition in [wpNorth, wpSouth]) then
    FOrientation := woNorthBySouth
    else FOrientation := woEastByWest;
  StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetState: TZEWallState; stdcall;
begin
  Result := FState;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWall.SetState (AState: TZEWallState); stdcall;
begin
  FState := AState;
  StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.GetSprite: IZESprite; stdcall;
begin
  Result := FSprite;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWall.Clone: IZEWall; stdcall;
begin
  Result := TZEWall.Create (FWallName, FOrientation, FPosition,
    FSoundProofed, FSeeThrough, FDestructible) as IZEWall;
end;


{ TZEWallManager }

//////////////////////////////////////////////////////////////////////////
procedure DisposeInterface (aData: Pointer);
begin
  if (aData <> NIL) then
  try
    IInterface (aData) := NIL;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEWallManager.Create (WallDesc: IZbEnumStrings);
var
  cData, cName: string;
  bSoundProofed, bSeeThrough, bDestructible: boolean;
  theWall: IZEWall;
begin
  inherited Create;
  FWalls := TZbDoubleList.Create (TRUE);
  FWalls.Sorted := TRUE;
  FWalls.DisposeProc := DisposeInterface;
  //
  // TODO: parse the wall configuration file
  cData := WallDesc.First;
  while (cData <> '') do begin
    cName := StrBefore ('=', cData);
    cData := StrAfter ('=', cData);
    bSoundProofed := cData [1] in  ['1', 'Y', 'T'];
    bSeeThrough   := cData [3] in  ['1', 'Y', 'T'];
    bDestructible := cData [5] in  ['1', 'Y', 'T'];
    cData := WallDesc.Next;
    //
    theWall := TZEWall.Create (PChar (cName), woNorthBySouth, wpNorth,
      bSoundProofed, bSeeThrough, bDestructible) as IZEWall;
    theWall._AddRef;
    FWalls.Add (cName, Pointer (theWall));
  end;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWallManager.Destroy;
begin
  FWalls.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWallManager.GetWallCount: integer; stdcall;
begin
  Result := FWalls.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWallManager.GetWallByIndex (iIndex: integer): IZEWall; stdcall;
begin
  Result := IZEWall (FWalls.Get (iIndex)).Clone;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWallManager.GetWallByName (AName: string): IZEWall; stdcall;
begin
  Result := IZEWall (FWalls.Get (AName)).Clone;
end;


end.

