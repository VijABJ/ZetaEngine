{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEWorldIntf.PAS
              Interfaces for Game World Elements
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/MapEngine/ZZEWorldIntf.pas,v 1.2 2002/10/01 12:43:57 Vij Exp $
  $Log: ZZEWorldIntf.pas,v $
  Revision 1.2  2002/10/01 12:43:57  Vij
  Fixed typo in Floor manager class.  Made the FLOOR/WALL family a symbolic
  constant instead of a magic value embedded in code.

  Revision 1.1.1.1  2002/09/11 21:11:33  Vij
  Starting Version Control


 ============================================================================}

unit ZZEWorldIntf;

interface

uses
  ZbGameUtils,
  ZEDXSpriteIntf,
  ZZESupport;

const
  TERRAIN_DEFAULT_VARIATION       = 0;
  TERRAIN_FAMILY                  = 'Terrain';
  TERRAIN_EDGE                    = '.EDGE.';
  TERRAIN_CORNER                  = '.CORNER.';

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  EDGE_CODE_NORTH                 = $0001;
  EDGE_CODE_EAST                  = $0002;
  EDGE_CODE_SOUTH                 = $0004;
  EDGE_CODE_WEST                  = $0008;
  CORNER_CODE_NE                  = $0001;
  CORNER_CODE_SE                  = $0002;
  CORNER_CODE_SW                  = $0004;
  CORNER_CODE_NW                  = $0008;

  TRANSITION_NORTH                = EDGE_CODE_NORTH;
  TRANSITION_NORTH_EAST           = (CORNER_CODE_NE SHL 4);
  TRANSITION_EAST                 = EDGE_CODE_EAST;
  TRANSITION_SOUTH_EAST           = (CORNER_CODE_SE SHL 4);
  TRANSITION_SOUTH                = EDGE_CODE_SOUTH;
  TRANSITION_SOUTH_WEST           = (CORNER_CODE_SW SHL 4);
  TRANSITION_WEST                 = EDGE_CODE_WEST;
  TRANSITION_NORTH_WEST           = (CORNER_CODE_NW SHL 4);

  TransitionCodes: array [tdNorth..tdNorthWest] of Cardinal = (
    TRANSITION_NORTH, TRANSITION_NORTH_EAST,
    TRANSITION_EAST, TRANSITION_SOUTH_EAST,
    TRANSITION_SOUTH, TRANSITION_SOUTH_WEST,
    TRANSITION_WEST, TRANSITION_NORTH_WEST);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  FLOOR_FAMILY                    = 'Floor';
  WALL_FAMILY                     = 'Walls';

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // this is the return value of IZETerrain.GetTransitionSprite
  // note that one or both of the members can be NIL
  PZETerrainTransition = ^TZETerrainTransition;
  TZETerrainTransition = packed record
    Edges: IZESprite;
    Corners: IZESprite;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZETerrain = interface;
  IZETerrainManager = interface;
  IZEFloorManager = interface;
  IZEWall = interface;
  IZEWallManager = interface;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZETerrain = interface (IInterface)
    ['{A9DAF04C-1B09-4B0F-A4A1-EF226D825523}']
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

  IZETerrainManager = interface (IInterface)
    ['{49129A95-66C7-4DC1-BA1D-E76CEF370D6A}']
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

  IZEFloorManager = interface (IInterface)
    ['{289A5AFB-2DB3-4EF0-B0C1-F8281E1018F4}']
    function GetFloorCount: integer; stdcall;
    function GetFloorByIndex (iIndex: integer): IZESprite; stdcall;
    //
    property FloorCount: integer read GetFloorCount;
    property Floors [iIndex: integer]: IZESprite read GetFloorByIndex;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWallOrientation = (woNothing = 0, woNorthBySouth, woEastByWest);
  TZEWallPosition = (wpNothing = 0, wpNorth, wpEast, wpSouth, wpWest);
  TZEWallState = (wsNormal = 0, wsBurned, wsCracked, wsDamagedSlight,
    wsDamagedMedium, wsDamagedHeavy, wsDestroyed);

  TZEWallSet = array [Low (TZEWallPosition)..High (TZEWallPosition)] of IZEWall;
  TZEWallSpritesSet = array [Low (TZEWallPosition)..High (TZEWallPosition)] of IZESprite;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEWall = interface (IInterface)
    ['{FF30DD39-BB26-4061-8F9C-619E9D0DE57F}']
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

  IZEWallManager = interface (IInterface)
    ['{8C408AD9-C6DF-49A8-A3CD-E330BC3785D6}']
    function GetWallCount: integer; stdcall;
    function GetWallByIndex (iIndex: integer): IZEWall; stdcall;
    function GetWallByName (AName: string): IZEWall; stdcall;
    //
    property WallCount: integer read GetWallCount;
    property Walls [iIndex: integer]: IZEWall read GetWallByIndex;
    property Walls2 [AName: string]: IZEWall read GetWallByName;
  end;

const
  MAX_WALL_STATE  = Ord (High (TZEWallState));
  NUM_WALL_STATES = Succ (MAX_WALL_STATE);

var

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TerrainManager: IZETerrainManager = NIL;
  FloorManager: IZEFloorManager = NIL;
  WallManager: IZEWallManager = NIL;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  __WallPositionToDirection: array [Low (TZEWallPosition)..High (TZEWallPosition)] of TZbDirection = (
    tdUnknown, tdNorth, tdEast, tdSouth, tdWest);
  __DirectionToWallPosition: array [tdUnknown..tdNorthWest] of TZEWallPosition = (
    wpNothing, wpNorth, wpNothing, wpEast, wpNothing,
               wpSouth, wpNothing, wpWest, wpNothing);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  __WallPositionOpposite: array [Low (TZEWallPosition)..High (TZEWallPosition)] of TZEWallPosition = (
    wpNothing, wpSouth, wpWest, wpNorth, wpEast);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  __WallPositionNames: array [Low (TZEWallPosition)..High (TZEWallPosition)] of string =  (
    'Nothing', 'North', 'East', 'South', 'West');
  __WallStateNames: array [Low (TZEWallState)..High (TZEWallState)] of string = (
    'Normal', 'Burned', 'Cracked', 'DamagedSlight',
    'DamagedMedium', 'DamagedHeavy', 'Destroyed');


implementation

end.
