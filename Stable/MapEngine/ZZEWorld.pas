{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEWorld.PAS
              Classes and Routines to contain/represent a Game World
  Author:     Vij

  -----------------------
  INTERNAL DESIGN NOTES
  -----------------------

  Format of Entity File:
    Name=Name
    Updateable=1|0
    Orientable=1|0
    Orientations=[N][NE][E][SE][S][SW][W][NW] <-- moved to SAMM file!
    MovementRate
    SAMMFile=...

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/MapEngine/ZZEWorld.pas,v 1.5 2002/12/18 08:26:48 Vij Exp $
  $Log: ZZEWorld.pas,v $
  Revision 1.5  2002/12/18 08:26:48  Vij
  Major revision:
    1. Finally fixed occlusion problem (only slight bug due to motion, will
       maybe solve this too, later)
    2. Added OnActiveArea, IgnorePortals and CaptionText property
    3. Added InitPC(), SetCaptionFont()
    4. Added another version for DeleteEntity() and SwitchToArea()
    5. Added QueueForDeletion()
    6. Added BeginPerform(), CanPerform(), IsPerforming()
    7. Added PlayEffects(), ClearEffects()
    8. Added CanSee(), HowFarFrom(), IsNeighbor(), Face(), Approach()
    9. Added CanStepTo(), StepTo (), GetNeighbor ()
   10. Added CaptionFont, ForceAlpha to Draw()
   11. Added RemoteCallback support
   12. Reorder declarations and definitions so that related methods will be
       adjacent in the code (more or less)

  Revision 1.4  2002/11/02 07:00:05  Vij
  new entity functions.  new world functions.  entities are now managed in
  groups, each basically those contained in a single file.  recoded draw
  ordering (again).

  Revision 1.3  2002/10/01 12:49:28  Vij
  Major additions:
  1. Defines entity actions, events and handlers.
  2. Action queueing and action processing.
  3. Methods/Fields for support of Save/Load of World/Entities.
  4. Entity Group, and Manager class for this.
  5. No more entity loader class, nor a global of such.  It is now
     called an EntityManager and is a field of CoreEngine instead.
  6. GameArea class has public Name property, and overloaded Remove/Delete
     methods.
  7. Global ActionRecord Create/Dispose to support code simplicity
     when queueing/processing action records.
  8. Added code to read/write movement rate from file/clone.
  9. Added flag as to whether entity can move or not.
  10. Cleaned up code in XXXXXSpaces() by factoring out common code.

  Revision 1.2  2002/09/17 22:25:49  Vij
  Parameterized most of the workhorse functions of TZEEntity so that there
  need not be any code that decides which variant of the routine to use
  each time it is called.
  Completed the EntityList class.  Added an VisibleEntityList class that
  sorts according to the center of the Entity's position in the map.
  Fixed some bugs in Properties parsing, and also in Entity.Clone()
  Added Draw() to GameArea.  Completed Draw() of Entity.  Added
  PlaceEntity().  Added stub of FindEntity().  Added code to build
  a visible Entities list whenever the Map's Visible Tiles List changes.

  Revision 1.1.1.1  2002/09/11 21:11:33  Vij
  Starting Version Control


  TODO:

  <Effects>
  Types: Floor, Background, Foreground, Halo

 ============================================================================}

unit ZZEWorld;

interface

uses
  Types,
  Classes,
  //
  ZbStrIntf,
  ZbScriptable,
  ZbDoubleList,
  ZbGameUtils,
  ZbFileIntf,
  ZbVirtualFS,
  //
  ZEDXSpriteIntf,
  ZEDXSprite,
  ZEWSSupport,
  //
  ZZEMap,
  ZZESupport,
  ZZEViewMap,
  ZZESAMM;


const
  SPRITE_FAMILY_SELECTORS   = 'Selector';
  SPRITE_MAP_GRID           = 'Grid';
  SPRITE_MAP_BLOCKED_GRID   = 'BlockedGrid';
  SPRITE_MAP_SELECTOR       = 'Selector';
  SPRITE_MAP_HIGHLIGHT      = 'Normal';
  SPRITE_MAP_TRANSITION     = 'MapTransition';
  SPRITE_MAP_STARTPOINT     = 'StartMarker';

  ENTITY_DIR_PREFIX         = '.';
  ENTITY_EXTRA_PREFIX       = '$';

  DEFAULT_PC_NAME           = '@PC@';

  STATE_INFO_MOVE           = 'Moving';
  STATE_INFO_DOUBLEMOVE     = 'Running';

  ENTITY_FOLDER_NAME        = 'ZEDS';

  MOTION_STEPS              = 8;    // DO NOT CHANGE!!!

  cmWorldCommandBase        = 400;
  cmUnloadingArea           = cmWorldCommandBase + 1;
  cmLoadingArea             = cmWorldCommandBase + 2;
  cmDeletedArea             = cmWorldCommandBase + 3;
  cmWorldLoaded             = cmWorldCommandBase + 4;


type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // forward declarations of all the classes in this module
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntity = class;
  TZEEntityClass = class of TZEEntity;
  TZEEntityManager = class;
  TZEEntityList = class;
  TZEGameArea = class;
  TZEGameWorld = class;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESpanList = array [Low (TZbDirection)..High (TZbDirection)] of TPoint;
  TZELocationCheckFunc = function (AtTile: TZEViewTile): boolean of object;
  TZEPlacerProc = procedure (AtTile: TZEViewTile) of object;
  TZEUnplacerProc = procedure of object;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntityEvent = (
    eeArrived,
    eeStopped,
    eePerformBegins,
    eePerformEnds,
    eeQueryMove,
    eeActionRequest,
    eeTimerFired,
    eeDoActionMain,
    eeDoActionOther,
    eeTriggerPortal,
    eeEndOfList
  );

  TZEEntityAction = (
    eaNothing,            // nothing doing
    eaMoveTo,             // long move action
    eaMove,               // movement action
    eaPerform,            // perform some task (dying, casting, etc)
    eaWait,               // idle until time expires
    eaDelay,              // used to idle entity BEFORE requesting an action
    eaObserve,            // idle until something happens
    eaInteract,           // interact with other entities
    eaRemoveEffects,      // effect have looped, remove it
    eaEndOfList           // sentinel for this list
  );

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  PZEActionRecord = ^TZEActionRecord;
  TZEActionRecord = record
    Action: TZEEntityAction;      // the action, duh?
    Target: TZEEntity;            // target entity, if any
    Destination: TZEViewTile;     // target tile, if any
    Direction: TZbDirection;      // direction required
    cParam: PChar;                // PChar param, MUST deallocate!
    iParam: integer;              // integer param, if any
    dwParam: Cardinal;            // cardinal param, if any
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntityHandler = function (
    Sender: TZEEntity;
    Event: TZEEntityEvent;
    pParam1, pParam2: Pointer;
    lParam1, lParam2: integer): integer of object; stdcall;

  TZERemoteEntityCallback = function (Sender: Integer; Event: Integer;
    pParam1, pParam2, lParam1, lParam2: Integer): Integer; stdcall;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETilesOccupiedRecord = record
    List: TIntegerDynArray;           // list of the tiles
    Count: Integer;                   // how many are in tiles
    Rect: TRect;                      // rectangle space in map grid coords
    ProjRect: TRect;                  // projected rectangle, from anchor to
  end;

  TZEMapFootPrintRecord = record
    Tiles: TZETilesOccupiedRecord;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntity = class (TZbNamedStreamable)
  private
    // innate properties
    FMasterName: PChar;               // name for all objects created by this one
    FSpan: TPoint;                    // size of the object, in map tiles
    FOrientable: boolean;             // TRUE if object has multiple orientations
    FOrientationList: TZESeqOrientationList; // list of orientations, shortcut to SAMM field
    FCanMove: boolean;                // true if entity can move/be moved
    FMovementRate: integer;           // Pixels/Sec movement rate (?)
    FRequiresUpdate: boolean;         // TRUE if object needs no update
    FIgnorePortals: boolean;          // TRUE if object cannot use portals
    FCaptionText: PChar;              // caption text
    // active properties
    FAdjustedBounds: boolean;         // internal variable!
    FMapFootPrint: TZEMapFootPrintRecord;
    FOrientation: TZbDirection;       // current facing
    FGameAreaOwner: TZEGameArea;      // so we'll know which game area owns this entity
    // map-related stuff
    FDrawOffset: TPoint;              // to be subtracted from anchor during drawing
    FBoundingBox: TRect;              // smallest box circumscribing this entity
    FBoundBoxSize: TPoint;            // precalculated dimensions for Bounding Box
    FLowerLeftCoords: TPoint;         // lower left base coord for Entity
    // state management stuff
    FExtraStateInfo: PChar;
    FEntitySnapShot: TZEEntitySnapShot;
    FSAMM: TZEStateAndMediaManager;
    // event management stuff
    FEventHandler: TZEEntityHandler;
    FRemoteHandler: TZERemoteEntityCallback;
    FHandlerData: Pointer;
    FEventCounter: integer;
    FEventTimer: TZbSimpleTimeTrigger;
    FActiveAction: PZEActionRecord;   // current action being processed
    FActionQueue: TZbDoubleList;      // list of actions
    // internal callbacks
    FOKToPlace: TZELocationCheckFunc;
    FPlaceAt: TZEPlacerProc;
    FUnplace: TZEUnplacerProc;
    // for special effects handling
    FEffects: TZEEntity;
  protected
    procedure CommonInit;
    procedure SAMMLoopHandler (Sender: TZEStateAndMediaManager; Notice: TZESAMMNotice);
    function IsOnMap: boolean;
    function IsOnActiveArea: boolean;
    function GetCaptionText: PChar;
    procedure SetCaptionText (ACaptionText: PChar);
    //
    function TileCheck (theTile: TZEViewTile; tSpaces: TZEOccupiedSpaces): boolean;
    function CheckLocation_1By1 (AtTile: TZEViewTile): boolean;
    function CheckLocation_1ByAny (AtTile: TZEViewTile): boolean;
    function CheckLocation_AnyBy1 (AtTile: TZEViewTile): boolean;
    function CheckLocation_AnyByAny (AtTile: TZEViewTile): boolean;
    //
    procedure ClaimTileSpaces (tTile: TZETile; tSpaces: TZEOccupiedSpaces);
    procedure PlaceAt_1By1 (AtTile: TZEViewTile);
    procedure PlaceAt_1ByAny (AtTile: TZEViewTile);
    procedure PlaceAt_AnyBy1 (AtTile: TZEViewTile);
    procedure PlaceAt_AnyByAny (AtTile: TZEViewTile);
    //
    procedure ReleaseTileSpaces (tTile: TZETile; tSpaces: TZEOccupiedSpaces);
    procedure Unplace_1By1;
    procedure Unplace_1ByAny;
    procedure Unplace_AnyBy1;
    procedure Unplace_AnyByAny;
    //
    procedure ClearMapFootPrint;
    procedure CreateMapFootPrint (AAnchorTile: TZETile);
    function GetAnchorTile: TZEViewTile;
    //
    procedure ParsePropsList (EntityProps: IZbEnumStringList);
    function GetMasterName: string;
    procedure CalcBoundingBox (ARefTile: TZEViewTile);
    //
    function CreateStateName: string; virtual;
    procedure SetOrientation (ANewOrientation: TZbDirection);
    function GetExtraStateInfo: string;
    procedure SetExtraStateInfo (ANewExtraStateInfo: string);
    function ComesBefore (Target: TZEEntity): boolean;
    //
    function EffectFunc (Sender: TZEEntity; Event: TZEEntityEvent;
      pParam1, pParam2: Pointer; lParam1, lParam2: integer): Integer; stdcall;
    //
    property GameAreaOwner: TZEGameArea read FGameAreaOwner write FGameAreaOwner;
    property ActiveAction: PZEActionRecord read FActiveAction write FActiveAction;
  public
    constructor Create (AMasterName, AName: string; EntityProps: IZbEnumStringList); overload; virtual;
    constructor Create (Reader: IZbFileReader); overload; virtual;
    destructor Destroy; override;
    //
    procedure Load (Reader: IZbFileReader); override;
    procedure Save (Writer: IZbFileWriter); override;
    //
    procedure AQ_Clear;
    procedure AQ_Done (Action: PZEActionRecord);
    function AQ_Count: integer;
    function AQ_Peek: PZEActionRecord;
    function AQ_Pop: PZEActionRecord;
    procedure AQ_InsertFront (NewAction: PZEActionRecord);
    procedure AQ_InsertBack (NewAction: PZEActionRecord);
    procedure AQ_InsertBefore (NewAction, Reference: PZEActionRecord);
    procedure AQ_InsertAfter (NewAction, Reference: PZEActionRecord);
    //
    procedure BeginPerform (cPerformState: String; bImmediate: boolean = TRUE);
    function CanPerform (cPerformState: String): boolean;
    function IsPerforming: boolean;
    //
    function PrefixInName (APrefix: PChar): LongBool;
    //
    procedure PlayEffects (cEffectName: String);
    procedure ClearEffects;
    //
    procedure ClearAction;
    procedure UpdateSelf (WTicksElapsed: Cardinal); virtual;
    function CallHandler (Event: TZEEntityEvent; 
      pParam1: Pointer = NIL; pParam2: Pointer = NIL;
      lParam1: integer = 0; lParam2: integer = 0): integer; virtual;
    function HandleEvent (Event: TZEEntityEvent;
      pParam1: Pointer = NIL; pParam2: Pointer = NIL;
      lParam1: integer = 0; lParam2: integer = 0): integer; virtual;
    function Clone (ANewName: string): TZEEntity; virtual;
    procedure StateChanged; virtual;
    //
    function OKToPlace (AtTile: TZEViewTile): boolean;
    function PlaceAt (AtTile: TZEViewTile; bCheckLocation: boolean = TRUE): boolean;
    procedure Unplace;
    procedure MoveTo (X, Y, Z: integer); overload;
    procedure MoveTo (ToTile: TZETile); overload;
    procedure MoveTo (ToTile: TZEViewTile); overload;
    //
    function CanSee (Target: TZEEntity): boolean;
    function HowFarFrom (Target: TZEEntity): Integer;
    function IsNeighbor (Target: TZEEntity): boolean;
    procedure Face (Target: TZEEntity); overload;
    procedure Face (ADirection: TZbDirection); overload;
    procedure Approach (Target: TZEEntity);
    //
    function CanStepTo (ADirection: TZbDirection): boolean;
    procedure StepTo (ADirection: TZbDirection);
    function GetNeighbor (ADirection: TZbDirection): TZEEntity;
    function GetAreaName: PChar;
    //
    procedure SetDefaultOrientation;
    function CheckOrientation (ADirection: TZbDirection): boolean;
    procedure Draw (pRef: TPoint; CaptionFont: TZEFont; bForceAlpha: boolean = FALSE); virtual;
    //
    property Name;
    property MasterName: string read GetMasterName;
    property Width: integer read FSpan.X;
    property Length: integer read FSpan.Y;
    property Orientable: boolean read FOrientable;
    property OrientationList: TZESeqOrientationList read FOrientationList;
    property CanMove: boolean read FCanMove;
    property MovementRate: integer read FMovementRate;
    property RequiresUpdate: boolean read FRequiresUpdate;
    property IgnorePortals: boolean read FIgnorePortals write FIgnorePortals;
    property CaptionText: PChar read GetCaptionText write SetCaptionText;
    //
    property BoundingBox: TRect read FBoundingBox;
    property BoundBoxHeight: integer read FBoundBoxSize.Y;
    property BoundBoxWidth: integer read FBoundBoxSize.X;
    property LowerLeftCoords: TPoint read FLowerLeftCoords;
    //
    property OnMap: boolean read IsOnMap;
    property OnActiveArea: boolean read IsOnActiveArea;
    property AnchorTile: TZEViewtile read GetAnchorTile;
    property TilesOccupied: TRect read FMapFootPrint.Tiles.Rect;
    property TopLeft: TPoint read FMapFootPrint.Tiles.Rect.TopLeft;
    property BottomRight: TPoint read FMapFootPrint.Tiles.Rect.BottomRight;
    property Orientation: TZbDirection read FOrientation write SetOrientation;
    //
    property Handler: TZEEntityHandler read FEventHandler write FEventHandler;
    property RemoteHandler: TZERemoteEntityCallback read FRemoteHandler write FRemoteHandler;
    property HandlerData: Pointer read FHandlerData write FHandlerData;
    property ExtraStateInfo: string read GetExtraStateInfo write SetExtraStateInfo;
    property EntitySnapShot: TZEEntitySnapShot read FEntitySnapShot;
    property SAMM: TZEStateAndMediaManager read FSAMM;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntityGroup = class (TZbScriptable)
  private
    FEntityData: TZbDoubleList;
    FEntities: TZbDoubleList;
  protected
    function GetCount: integer;
    function GetEntity_I (iIndex: integer): TZEEntity;
    function GetEntity_S (cEntityName: string): TZEEntity;
    //
    procedure LoadList (cFolder: string); overload;
    procedure LoadList (fsFolder: TZbFSFolder); overload;
    procedure CommonInit;
  public
    constructor Create (cFolder: string); overload;
    constructor Create (fsFolder: TZbFSFolder); overload;
    destructor Destroy; override;
    //
    property Count: integer read GetCount;
    property EntityByIndex [iIndex: integer]: TZEEntity read GetEntity_I;
    property EntityByName [cName: string]: TZEEntity read GetEntity_S; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntityManager = class (TZbScriptable)
  private
    FGroupList: TZbDoubleList;
  protected
    function GetEntityCount: integer;
    function GetEntityByIndex (iIndex: Integer): TZEEntity;
    function GetEntityByName (cName: string): TZEEntity;
    function GetGroupCount: integer;
    function GetGroupByIndex (iIndex: integer): TZEEntityGroup;
    //
    procedure LoadEntities (cFolder: string); overload;
    procedure LoadEntities; overload;
    procedure CommonInit;
  public
    constructor Create (cFolder: string); overload;
    constructor Create; overload;
    destructor Destroy; override;
    //
    function CreateEntity (cEntityMasterName, cNewName: string): TZEEntity;
    //
    property EntityCount: integer read GetEntityCount;
    property EntityByIndex [iIndex: integer]: TZEEntity read GetEntityByIndex; default;
    property GroupCount: integer read GetGroupCount;
    property GroupByIndex [iIndex: integer]: TZEEntityGroup read GetGroupByIndex;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEntityList = class (TZbScriptable)
  private
    FEntities: TZbDoubleList;
  protected
    function GetCount: integer;
    function GetEntity (iIndex: integer): TZEEntity;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //
    procedure Add (Entity: TZEEntity);
    function Find (Entity: TZEEntity): TZEEntity; overload;
    function Find (cEntityName: string): TZEEntity; overload;
    //
    procedure Clear;
    procedure Delete (Entity: TZEEntity); overload;
    procedure Delete (cEntityName: string); overload;
    procedure Remove (Entity: TZEEntity); overload;
    procedure Remove (cEntityName: string); overload;
    //
    property Count: integer read GetCount;
    property Entities [iIndex: integer]: TZEEntity read GetEntity; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEVisibleEntityList = class (TZbScriptable)
  private
    FEntities: TList;
  protected
    function GetCount: integer;
    function GetEntity (iIndex: integer): TZEEntity;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //
    procedure Add (Entity: TZEEntity);
    procedure Remove (Entity: TZEEntity);
    procedure Clear;
    //
    property Count: integer read GetCount;
    property Items [iIndex: integer]: TZEEntity read GetEntity; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGameArea = class (TZbNamedStreamable)
  private
    FOwner: TZEGameWorld;
    FMap: TZEViewMap;
    FEntities: TZEEntityList;
    FVisibles: TZEVisibleEntityList;
  protected
    procedure CommonInit;
    procedure DiscardData;
    procedure PostProcessMap;
    procedure PostLoadProcessing;
    procedure _TileToViewList (ATile: TZEViewTile);
    procedure _BeforeViewListRebuild (AMap: TZEViewMap);
    procedure _AfterViewListRebuild (AMap: TZEViewMap);
    procedure _DrawEntities (pReference: TPoint);
    //
    property Owner: TZEGameWorld read FOwner write FOwner;
  public
    constructor Create (AName: string); overload; virtual;
    constructor Create (Reader: IZbFileReader); overload; virtual;
    destructor Destroy; override;
    //
    procedure Load (Reader: IZbFileReader); override;
    procedure Save (Writer: IZbFileWriter); override;
    //
    function GetDropPoint: TZbVector;
    //
    function PlaceEntity (Entity: TZEEntity; WhereX, WhereY, WhereLevel: integer): boolean; overload;
    function PlaceEntity (Entity: TZEEntity; WhereLoc: TPoint; WhereLevel: integer): boolean; overload;
    function PlaceEntity (Entity: TZEEntity; WhereTile: TZEViewTile): boolean; overload;
    //
    function FindEntity (cEntityName: string): TZEEntity;
    procedure DeleteEntity (cEntityName: string); overload;
    procedure DeleteEntity (Entity: TZEEntity); overload;
    procedure RemoveEntity (cEntityName: string); overload;
    procedure RemoveEntity (Entity: TZEEntity); overload;
    //
    procedure CreateMap (iWidth, iHeight: integer; iLevels: integer = 1);
    procedure ChangeMapLevel (bMoveUp: boolean = TRUE);
    procedure PerformUpdate (WTicksElapsed: Cardinal);
    //
    property Name;
    property Map: TZEViewMap read FMap;
    property Entities: TZEEntityList read FEntities;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEActionModifier = (atShift, atCtrl, atAlt);
  TZEActionModifiers = set of TZEActionModifier;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  TZEGameWorld = class (TZbScriptable)
  private
    FAreas: TZbDoubleList;
    FActiveArea: TZEGameArea;
    FPaused: boolean;
    FPC: TZEEntity;
    FPCCallback: TZERemoteEntityCallback;
    FCaptionFont: TZEFont;
    FToDeleteList: TStrings;
  protected
    procedure SetPaused (APaused: boolean);
    function GetAreaCount: integer;
    function PCEntityFunc(Sender: TZEEntity; Event: TZEEntityEvent;
      pParam1, pParam2: Pointer;lParam1, lParam2: integer): integer; stdcall;
    procedure InitPC (FaceWhere: TZbDirection; Handler: TZERemoteEntityCallback);
    //
    procedure SetCaptionFont (AFont: TZEFont);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //
    procedure ResetGameWindow;
    function CreateNewArea (AName: string): TZEGameArea;
    //
    function SwitchToArea (theArea: TZEGameArea): TZEGameArea; overload;
    function SwitchToArea (AName: string): TZEGameArea; overload;
    //
    procedure DeleteAreas;
    procedure DeleteArea; overload;
    procedure DeleteArea (cAreaName: string); overload;
    procedure DeleteArea (theArea: TZEGameArea); overload;
    function GetArea (AName: string): TZEGameArea;
    function GetAreaByIndex (iIndex: integer): TZEGameArea;
    //
    function TranslateMapToAreaName (Map: TZEMap): String;
    function TranslateAreaNameToMap (AreaName: string): TZEMap;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal);
    procedure PerformAction (AtTile: TZEViewTile; bPrimary: boolean;
      atModifier: TZEActionModifiers);
    //
    procedure SaveToFile (cFileName: string); overload;
    procedure SaveToFile (Writer: IZbFileWriter); overload;
    procedure LoadFromFile (cFileName: string); overload;
    procedure LoadFromFile (Reader: IZbFileReader); overload;
    //
    procedure ReplacePC (cMasterName, cWorkingName: string; Handler: TZERemoteEntityCallback = NIL);
    procedure CreatePC (cMasterName, cWorkingName: string; Handler: TZERemoteEntityCallback = NIL);
    procedure ClearPC;
    procedure DropPC; overload;
    procedure DropPC (theArea: TZEGameArea; DropVector: TZbVector); overload;
    procedure DropPC (cAreaByName: string; DropVector: TZbVector); overload;
    procedure DropPC (cAreaByName: string;
      X: integer = -1; Y: integer = -1; Z: integer = -1); overload;
    procedure UnDropPC;
    //
    function FindEntity (cEntityName: string): TZEEntity;
    procedure DeleteEntity (cEntityName: string); overload;
    procedure DeleteEntity (Entity: TZEEntity); overload;
    procedure QueueForDeletion (cEntityName: String); overload;
    procedure QueueForDeletion (Entity: TZEEntity); overload;
    //
    property CaptionFont: TZEFont read FCaptionFont write SetCaptionFont;
    property Paused: boolean read FPaused write SetPaused;
    property ActiveArea: TZEGameArea read FActiveArea;
    property AreaCount: integer read GetAreaCount;
    property Areas [AName: string]: TZEGameArea read GetArea; default;
    property AreaByIndex [iIndex: integer]: TZEGameArea read GetAreaByIndex;
    property PC: TZEEntity read FPC;
  end;


var
  GameWorld: TZEGameWorld = NIL;


  (* helper routines *)
  procedure ActionRecordDispose (lpAction: PZEActionRecord);
  function ActionRecordCreate (eaAction: TZEEntityAction;
    eTarget: TZEEntity = NIL; vtDestination: TZEViewTile = NIL;
    dWhere: TZbDirection = tdUnknown; acParam: PChar = NIL;
    aiParam: integer = 0; adwParam: Cardinal = 0): PZEActionRecord;


implementation

uses
  Windows,
  SysUtils,
  StrUtils,
  //
  JclStrings,
  DirectDraw,
  //
  ZbIniFileEx,
  ZbDebug,
  //
  ZbUtils,
  ZEDXFramework,
  //ZEDXDev,
  //
  ZEWSBase,
  ZZEGameWindow,
  ZZECore;

const
  GWF_SIGNATURE_VALUE = 'ZE-GWF';
  GWF_SIGNATURE: string = 'ZE-GWF';
  GWF_SIGNATURE_LEN = Length (GWF_SIGNATURE_VALUE);
  GWF_MAGIC_NUMBER = $12101975;
  GWF_MAJOR_VERSION = 1;
  GWF_MINOR_VERSION = 0;
  GWF_VERSION = (GWF_MAJOR_VERSION SHL 16) OR GWF_MINOR_VERSION;

  GWF_TAG_NOTHING             =  Integer ($88990000);
  GWF_TAG_MAP_AVAILABLE       =  Integer ($88990001);
  GWF_TAG_ENTITY_FLOATING     =  Integer ($88990002);
  GWF_TAG_ENTITY_PLACED       =  Integer ($88990003);

type
  // Game World File Header
  PZEGWFHeader = ^TZEGWFHeader;
  TZEGWFHeader = packed record
    iMagicNumber: integer;
    cStrSignature: array [0..Pred (GWF_SIGNATURE_LEN)] of Char;
    iVersionTag: integer;
    iAreaCount: integer;
    iActiveArea: integer;
  end;


{ TZEEntity }

//////////////////////////////////////////////////////////////////////////
constructor TZEEntity.Create (AMasterName, AName: string;
  EntityProps: IZbEnumStringList);
begin
  inherited Create;
  CommonInit;
  Name := AName;
  FMasterName := StrNew (PChar (AMasterName));
  ParsePropsList (EntityProps);
  FSAMM := CoreEngine.SAMMManager [FMasterName];
  FSAMM.Notify := SAMMLoopHandler;
  FOrientationList := FSAMM.ActionList.Ref.Props.Orientations;
  SetDefaultOrientation;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEEntity.Create (Reader: IZbFileReader);
begin
  CommonInit;
  Load (Reader);
  FSAMM := CoreEngine.SAMMManager [FMasterName];
  FSAMM.Notify := SAMMLoopHandler;
  FOrientationList := FSAMM.ActionList.Ref.Props.Orientations;
  Orientation := FOrientation;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEEntity.Destroy;
begin
  ClearEffects;
  AQ_Clear;
  FActionQueue.Free;
  FEventTimer.Free;
  if (FExtraStateInfo <> NIL) then StrDispose (FExtraStateInfo);
  if (FMasterName <> NIL) then StrDispose (FMasterName);
  FSAMM.Free;
  FEntitySnapShot.Free;
  SetCaptionText (NIL);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.CommonInit;
begin
  FMasterName := NIL;
  //
  FSpan := Point (1, 1);
  FOrientable := FALSE;
  FCanMove := FALSE;
  FMovementRate := 0;
  FRequiresUpdate := FALSE;
  FOrientation := tdUnknown;
  FIgnorePortals := TRUE;
  FCaptionText := NIL;
  //
  ClearMapFootPrint;
  FDrawOffset := Point (0, 0);
  FBoundingBox := Rect (0, 0, 0, 0);
  FBoundBoxSize := Point (0, 0);
  FLowerLeftCoords := Point (0, 0);
  CalcBoundingBox (NIL);
  //
  FOKToPlace := CheckLocation_1By1;
  FPlaceAt := PlaceAt_1By1;
  FUnplace := Unplace_1By1;
  FGameAreaOwner := NIL;
  //
  FExtraStateInfo := NIL;
  FEntitySnapShot := TZEEntitySnapShot.Create;
  FSAMM := NIL;
  //
  FActiveAction := NIL;
  FActionQueue := TZbDoubleList.Create (FALSE);
  FEventCounter := 0;
  FEventTimer := TZbSimpleTimeTrigger.Create (0);
  FEventHandler := NIL;
  FHandlerData := NIL;
  //
  FEffects := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.SAMMLoopHandler (Sender: TZEStateAndMediaManager; Notice: TZESAMMNotice);
var
  cName: String;
begin
  // whatever notice this is, we will cancel the active action if it
  // is eaPerform.  eaPerform simply changes the state and waits til
  // the animation sequence is done.
  if (ActiveAction <> NIL) AND (ActiveAction.Action = eaPerform) then begin
    ClearAction;
    //
    if (Notice = snSequenceEnded) then begin
      cName := EntitySnapShot.Sequence.Master.Name;
      HandleEvent (eePerformEnds, Pointer (PChar (cName)));
    end else
      HandleEvent (eePerformEnds);
    //
    if (Notice = snSequenceSwitched) then
      ExtraStateInfo := EntitySnapShot.Sequence.Master.Name;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.IsOnMap: boolean;
begin
  Result := (FMapFootPrint.Tiles.Count > 0);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.IsOnActiveArea: boolean;
begin
  Result :=
    (FMapFootPrint.Tiles.Count > 0) AND
    (GameAreaOwner = GameWorld.ActiveArea);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.GetCaptionText: PChar;
begin
  Result := FCaptionText;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.SetCaptionText (ACaptionText: PChar);
begin
  if (FCaptionText <> NIL) then StrDispose (FCaptionText);
  if (ACaptionText <> NIL) then
    FCaptionText := StrNew (ACAptionText)
    else FCaptionText := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.TileCheck (theTile: TZEViewTile; tSpaces: TZEOccupiedSpaces): boolean;
begin
  Result := (theTile <> NIL) AND (theTile.Surface.Walkable) AND
            (NOT theTile.CheckSpaces (tSpaces));
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CheckLocation_1By1 (AtTile: TZEViewTile): boolean;
begin
  Result := TileCheck (AtTile, [osCenter]);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CheckLocation_1ByAny (AtTile: TZEViewTile): boolean;
var
  theTile: TZEViewTile;
  Y: integer;
begin
  Result := FALSE;
  with AtTile do begin
    // check the north and south end...
    if (NOT TileCheck (AtTile, [osCenter, osSouth])) then Exit;
    theTile := TZEViewTile (Owner [GridX, GridY + FSpan.Y - 1]);
    if (NOT TileCheck (theTile, [osCenter, osNorth])) then Exit;
    // now check all the tiles in between...
    for Y := 1 to (FSpan.Y - 2) do begin
      theTile := TZEViewTile (Owner [GridX, GridY + Y]);
      if (NOT TileCheck (theTile, [osCenter, osNorth, osSouth])) then Exit;
    end;
  end;
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CheckLocation_AnyBy1 (AtTile: TZEViewTile): boolean;
var
  theTile: TZEViewTile;
  X: integer;
begin
  Result := FALSE;
  with AtTile do begin
    // check the east and west end...
    if (NOT TileCheck (AtTile, [osCenter, osEast])) then Exit;
    theTile := TZEViewTile (Owner [GridX + FSpan.X - 1, GridY]);
    if (NOT TileCheck (theTile, [osCenter, osWest])) then Exit;
    // now check all the tiles in between...
    for X := 1 to (FSpan.X - 2) do begin
      theTile := TZEViewTile (Owner [GridX + X, GridY]);
      if (NOT TileCheck (theTile, [osCenter, osWest, osEast])) then Exit;
    end;
  end;
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CheckLocation_AnyByAny (AtTile: TZEViewTile): boolean;
var
  theTile: TZEViewTile;
  X, Y: integer;
begin
  Result := FALSE;
  theTile := AtTile;
  with AtTile do begin
    // check corners...
    if (NOT TileCheck (theTile, [osCenter, osSouth, osEast])) then Exit;
    theTile := TZEViewTile (Owner [GridX, GridY + FSpan.Y - 1]);
    if (NOT TileCheck (theTile, [osCenter, osNorth, osEast])) then Exit;
    theTile := TZEViewTile (Owner [GridX + FSpan.X - 1, GridY]);
    if (NOT TileCheck (theTile, [osCenter, osWest, osSouth])) then Exit;
    theTile := TZEViewTile (Owner [GridX + FSpan.X - 1, GridY + FSpan.Y - 1]);
    if (NOT TileCheck (theTile, [osCenter, osWest, osNorth])) then Exit;
    // check the top and bottom edges...
    for X := 1 to (FSpan.X - 2) do begin
      theTile := TZEViewTile (Owner [GridX + X, GridY]);
      if (NOT TileCheck (theTile, [osCenter, osEast, osWest, osSouth])) then Exit;
      theTile := TZEViewTile (Owner [GridX + X, GridY + FSpan.Y - 1]);
      if (NOT TileCheck (theTile, [osCenter, osEast, osWest, osNorth])) then Exit;
    end;
    // check the left and right edges...
    for Y := 1 to (FSpan.Y - 2) do begin
      theTile := TZEViewTile (Owner [GridX, GridY + Y]);
      if (NOT TileCheck (theTile, [osCenter, osEast, osNorth, osSouth])) then Exit;
      theTile := TZEViewTile (Owner [GridX + FSpan.X - 1, GridY + Y]);
      if (NOT TileCheck (theTile, [osCenter, osWest, osNorth, osSouth])) then Exit;
    end;
    // check the center portions; this may not actually run if there isn't any...
    for X := 1 to (FSpan.X - 2) do begin
      for Y := 1 to (FSpan.Y - 2) do begin
        theTile := TZEViewTile (Owner [GridX + X, GridY + Y]);
        if (NOT TileCheck (theTile, AllSpaces)) then Exit;
      end;
    end;
    //
  end;
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.ClaimTileSpaces (tTile: TZETile; tSpaces: TZEOccupiedSpaces);
begin
  if (tTile = NIL) OR (tSpaces = []) then Exit; // optional?
  tTile.ClaimSpaces (tSpaces);
  TZEViewTile (tTile).UserData := Self;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.PlaceAt_1By1 (AtTile: TZEViewTile);
begin
  ClaimTileSpaces (AtTile, [osCenter]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.PlaceAt_1ByAny (AtTile: TZEViewTile);
var
  Y: integer;
begin
  try
    ClaimTileSpaces (AtTile, [osCenter, osSouth]);
    with AtTile do begin
      ClaimTileSpaces ((Owner [GridX, GridY + FSpan.Y - 1]), [osCenter, osNorth]);
      for Y := 1 to (FSpan.Y - 2) do
        ClaimTileSpaces ((Owner [GridX, GridY + Y]), [osCenter, osNorth, osSouth]);
    end;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.PlaceAt_AnyBy1 (AtTile: TZEViewTile);
var
  X: integer;
begin
  try
    ClaimTileSpaces (AtTile, [osCenter, osEast]);
    with AtTile do begin
      ClaimTileSpaces ((Owner [GridX + FSpan.X - 1, GridY]), [osCenter, osWest]);
      for X := 1 to (FSpan.X - 2) do
        ClaimTileSpaces ((Owner [GridX + X, GridY]), [osCenter, osEast, osWest]);
    end;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.PlaceAt_AnyByAny (AtTile: TZEViewTile);
var
  X, Y: integer;
begin
  try
    ClaimTileSpaces (AtTile, [osCenter, osEast, osSouth]);
    with AtTile do begin
      // claim other three corners
      ClaimTileSpaces ((Owner [GridX, GridY + FSpan.Y - 1]), [osCenter, osNorth, osEast]);
      ClaimTileSpaces ((Owner [GridX + FSpan.X - 1, GridY]), [osCenter, osSouth, osWest]);
      ClaimTileSpaces ((Owner [GridX + FSpan.X - 1, GridY + FSpan.Y - 1]), [osCenter, osNorth, osWest]);
      // claim the top and bottom edges
      for X := 1 to (FSpan.X - 2) do begin
        ClaimTileSpaces ((Owner [GridX + X, GridY]), [osCenter, osEast, osWest, osSouth]);
        ClaimTileSpaces ((Owner [GridX + X, GridY + FSpan.Y - 1]), [osCenter, osEast, osWest, osNorth]);
      end;
      // claim the left and right edges...
      for Y := 1 to (FSpan.Y - 2) do begin
        ClaimTileSpaces ((Owner [GridX, GridY + Y]), [osCenter, osEast, osNorth, osSouth]);
        ClaimTileSpaces ((Owner [GridX + FSpan.X - 1, GridY + Y]), [osCenter, osWest, osNorth, osSouth]);
      end;
      // claim the rest...
      for X := 1 to (FSpan.X - 2) do
        for Y := 1 to (FSpan.Y - 2) do
          ClaimTileSpaces ((Owner [GridX + X, GridY + Y]), AllSpaces);
        //
      //
    end;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.ReleaseTileSpaces (tTile: TZETile; tSpaces: TZEOccupiedSpaces);
begin
  if (tTile = NIL) OR (tSpaces = []) then Exit;
  tTile.ReleaseSpaces (tSpaces);
  TZEViewTile (tTile).UserData := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Unplace_1By1;
begin
  ReleaseTileSpaces (AnchorTile, [osCenter]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Unplace_1ByAny;
var
  Y: integer;
begin
  try
    ReleaseTileSpaces (AnchorTile, [osCenter, osSouth]);
    with AnchorTile do begin
      ReleaseTileSpaces ((Owner [GridX, GridY + FSpan.Y - 1]), [osCenter, osNorth]);
      for Y := 1 to (FSpan.Y - 2) do
        ReleaseTileSpaces ((Owner [GridX, GridY + Y]), [osCenter, osNorth, osSouth]);
      //
    end;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Unplace_AnyBy1;
var
  X: integer;
begin
  try
    ReleaseTileSpaces (AnchorTile, [osCenter, osEast]);
    with AnchorTile do begin
      ReleaseTileSpaces ((Owner [GridX + FSpan.X - 1, GridY]), [osCenter, osWest]);
      for X := 1 to (FSpan.X - 2) do
        ReleaseTileSpaces ((Owner [GridX + X, GridY]), [osCenter, osEast, osWest]);
      //
    end;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Unplace_AnyByAny;
var
  X, Y: integer;
begin
  try
    ReleaseTileSpaces (AnchorTile, [osCenter, osEast, osSouth]);
    with AnchorTile do begin
      // claim other three corners
      ReleaseTileSpaces ((Owner [GridX, GridY + FSpan.Y - 1]), [osCenter, osNorth, osEast]);
      ReleaseTileSpaces ((Owner [GridX + FSpan.X - 1, GridY]), [osCenter, osSouth, osWest]);
      ReleaseTileSpaces ((Owner [GridX + FSpan.X - 1, GridY + FSpan.Y - 1]), [osCenter, osNorth, osWest]);
      // claim the top and bottom edges
      for X := 1 to (FSpan.X - 2) do begin
        ReleaseTileSpaces ((Owner [GridX + X, GridY]), [osCenter, osEast, osWest, osSouth]);
        ReleaseTileSpaces ((Owner [GridX + X, GridY + FSpan.Y - 1]), [osCenter, osEast, osWest, osNorth]);
      end;
      // claim the left and right edges...
      for Y := 1 to (FSpan.Y - 2) do begin
        ReleaseTileSpaces ((Owner [GridX, GridY + Y]), [osCenter, osEast, osNorth, osSouth]);
        ReleaseTileSpaces ((Owner [GridX + FSpan.X - 1, GridY + Y]), [osCenter, osWest, osNorth, osSouth]);
      end;
      // claim the rest...
      for X := 1 to (FSpan.X - 2) do
        for Y := 1 to (FSpan.Y - 2) do
          ReleaseTileSpaces ((Owner [GridX + X, GridY + Y]), AllSpaces);
        //
      //
    end;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.ClearMapFootPrint;
begin
  with FMapFootPrint do begin
    SetLength (Tiles.List, 0);
    Tiles.Count := 0;
    Tiles.Rect := Rect (0, 0, 0, 0);
    Tiles.ProjRect := Rect (0, 0, 0, 0);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.CreateMapFootPrint (AAnchorTile: TZETile);
var
  X, Y, iIndex: integer;
  theTile: TZETile;
begin
  ClearMapFootPrint;
  //
  with AAnchorTile, FMapFootPrint do begin
    Tiles.Count := FSpan.X * FSpan.Y;
    SetLength (Tiles.List, Tiles.Count);
    Tiles.Rect := Rect (GridX, GridY, GridX + FSpan.X, GridY + FSpan.Y);
    Tiles.ProjRect := Rect (GridX, GridY, Owner.Width, Owner.Height);
    //
    iIndex := 0;
    for Y := Tiles.Rect.Top to Pred (Tiles.Rect.Bottom) do begin
      for X := Tiles.Rect.Left to Pred (Tiles.Rect.Right) do begin
        theTile := Owner [X, Y];
        Tiles.List [iIndex] := Integer (theTile);
        Inc (iIndex);
      end; // for
    end; // for
  end; // with
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.GetAnchorTile: TZEViewTile;
begin
  if (FMapFootPrint.Tiles.Count = 0) then
    Result := NIL
    else Result := TZEViewTile (FMapFootPrint.Tiles.List [0]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.ParsePropsList (EntityProps: IZbEnumStringList);
var
  cData: string;
begin
  if (EntityProps = NIL) then Exit;
  // Updateable=<1|0>
  cData := EntityProps.First;
  FRequiresUpdate := (StrAfter ('=', cData) = '1');
  // Orientable=<1|0>
  cData := EntityProps.Next;
  FOrientable := (StrAfter ('=', cData) = '1');
  // this sets the default orientation and span
  FOrientation := tdUnknown;
  FSpan := Point (1, 1);
  //
  cData := EntityProps.Next;
  FMovementRate := StrToIntSafe (StrAfter ('=', cData));
  FCanMove := (FMovementRate > 0);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.GetMasterName: string;
begin
  Result := IfThen (FMasterName = NIL, '', String (FMasterName));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.CalcBoundingBox (ARefTile: TZEViewTile);
begin
  // no valid area occupied? exit now if so
  if (NOT OnMap) OR (ARefTile = NIL) then Exit;
  //
  with FBoundingBox, FSpan, ARefTile do begin
    //
    Left := ScrOrigin.X - (Pred (Y) * TileProps.TileHalfWidth);
    Top := ScrOrigin.Y;
    //
    Right := Left + ((X + Y) * TileProps.TileHalfWidth);
    Bottom := Top + ((X + Y) * TileProps.TileHalfHeight);
    //
    FBoundBoxSize := Point (Right - Left, Bottom - Top);
    FLowerLeftCoords := Point (Left, Bottom);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.StateChanged;
begin
  FEntitySnapShot.EntityState := CreateStateName;
  FEntitySnapShot.EntityFacing := FOrientation;
  FSAMM.AlignWithNewState (FEntitySnapShot);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CreateStateName: string;
begin
  Result := ExtraStateInfo;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.SetOrientation (ANewOrientation: TZbDirection);
var
  SeqDir: TZESequenceOrientation;
begin
  // see if a sequence for the direction requested exists
  SeqDir := FOrientationList.ListD [ANewOrientation];
  if (SeqDir = NIL) then Exit;
  //
  FOrientation := ANewOrientation;
  FSpan := SeqDir.Dimension;
  //
  // this reassigns some of the internal function/procedure
  // handlers so that the entity will adjust itself relative
  // to the tile coverage of itself
  if (FSpan.X = 1) AND (FSpan.Y = 1) then begin
    FOKToPlace := CheckLocation_1By1;
    FPlaceAt := PlaceAt_1By1;
    FUnplace := Unplace_1By1;
  end else if (FSpan.X = 1) then begin
    FOKToPlace := CheckLocation_1ByAny;
    FPlaceAt := PlaceAt_1ByAny;
    FUnplace := Unplace_1ByAny;
  end else if (FSpan.Y = 1) then begin
    FOKToPlace := CheckLocation_AnyBy1;
    FPlaceAt := PlaceAt_AnyBy1;
    FUnplace := Unplace_AnyBy1;
  end else begin
    FOKToPlace := CheckLocation_AnyByAny;
    FPlaceAt := PlaceAt_AnyByAny;
    FUnplace := Unplace_AnyByAny;
  end;
  //
  StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.GetExtraStateInfo: string;
begin
  Result := IfThen (FExtraStateInfo = NIL, '', String (FExtraStateInfo));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.SetExtraStateInfo (ANewExtraStateInfo: string);
begin
  if (FExtraStateInfo <> NIL) then StrDispose (FExtraStateInfo);
  if (ANewExtraStateInfo <> '') then
    FExtraStateInfo := StrNew (PChar (ANewExtraStateInfo))
    else FExtraStateInfo := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.ComesBefore (Target: TZEEntity): boolean;
var
  rIntersection: TRect;
begin
  Result := IntersectRect (rIntersection,
    FMapFootPrint.Tiles.ProjRect, Target.FMapFootPrint.Tiles.Rect);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Load (Reader: IZbFileReader);
begin
  with Reader do begin
    Name := ReadStr;
    FMasterName := ReadPStr;
    FRequiresUpdate := ReadBoolean;
    FOrientable := ReadBoolean;
    //
    FOrientation := TZbDirection (ReadInteger);
    FSpan.X := ReadInteger;
    FSpan.Y := ReadInteger;
    //
    FExtraStateInfo := ReadPStr;
    FMovementRate := ReadInteger;
    FCanMove := (FMovementRate > 0);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Save (Writer: IZbFileWriter);
begin
  with Writer do begin
    WriteStr (Name);
    WritePStr (FMasterName);
    WriteBoolean (FRequiresUpdate);
    WriteBoolean (FOrientable);
    //
    WriteInteger (Integer (FOrientation));
    WriteInteger (FSpan.X);
    WriteInteger (FSpan.Y);
    //
    WritePStr (FExtraStateInfo);
    WriteInteger (FMovementRate);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.AQ_Clear;
begin
  while (FActionQueue.Count > 0) do AQ_Done (AQ_Pop);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.AQ_Done (Action: PZEActionRecord);
begin
  ActionRecordDispose (Action);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.AQ_Count: integer;
begin
  Result := FActionQueue.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.AQ_Peek: PZEActionRecord;
begin
  if (FActionQueue.Count > 0) then
    Result := PZEActionRecord (FActionQueue.Get (0))
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.AQ_Pop: PZEActionRecord;
begin
  if (FActionQueue.Count > 0) then begin
    Result := PZEActionRecord (FActionQueue.Get (0));
    FActionQueue.Delete (0);
  end
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.AQ_InsertFront (NewAction: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.AQ_InsertBack (NewAction: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, -1);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.AQ_InsertBefore (NewAction, Reference: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, FActionQueue.IndexOf (Reference));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.AQ_InsertAfter (NewAction, Reference: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, Succ (FActionQueue.IndexOf (Reference)));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.BeginPerform (cPerformState: String; bImmediate: boolean);
begin
  // clear the queue if immediate performace required
  if (bImmediate) then AQ_Clear;
  // insert perform action at rear of queue
  AQ_InsertBack (ActionRecordCreate (eaPerform, Self, NIL, tdUnknown,
    PChar (cPerformState), 0, 0));
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CanPerform (cPerformState: String): boolean;
var
  animSeq: TZEAnimationSequence;
begin
  animSeq := FSAMM.ActionList.GetSequence(FOrientation, cPerformState);
  Result := (animSeq <> NIL);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.IsPerforming: boolean;
begin
  Result := (ActiveAction <> NIL) AND (ActiveAction.Action = eaPerform);
end;

var
  iEffNumber: Integer = 0;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.EffectFunc (Sender: TZEEntity; Event: TZEEntityEvent;
  pParam1, pParam2: Pointer; lParam1, lParam2: integer): Integer; stdcall;
begin
  Result := 0;
  if (Event = eePerformEnds) then AQ_InsertFront (ActionRecordCreate (eaRemoveEffects));
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.PrefixInName (APrefix: PChar): LongBool;
var
  iPrefixLen, iNameLen: Integer;
begin
  // assume no such prefix, if prefix to test is NIL, return immediately
  Result := FALSE;
  if (APrefix = NIL) then Exit;

  // check length of prefix, bail out if zero
  iPrefixLen := StrLen (APrefix);
  if (iPrefixLen = 0) then Exit;

  // if length of name is shorter than the prefix to test,
  // then there surely won't be any matching prefix...
  iNameLen := StrLen (__FName);
  if (iNameLen < iPrefixLen) then Exit;

  Result := (StrLComp (__FName, APrefix, iPrefixLen) = 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.PlayEffects (cEffectName: String);
var
  Eff: TZEEntity;
  EffName: String;
begin
  ClearEffects;
  // create the effect entity first of all, bug out if this fails
  EffName := Format ('%s#%d', ['Effects', iEffNumber]);
  Eff := CoreEngine.EntityManager.CreateEntity('Effects', EffName);
  if (Eff = NIL) then Exit;
  // we've used up an effect number so increment this value
  Inc (iEffNumber);
  //
  Eff.FMapFootPrint.Tiles.Count := 1;
  Eff.FGameAreaOwner := GameAreaOwner;
  Eff.Handler := EffectFunc;
  Eff.CalcBoundingBox (AnchorTile);
  Eff.BeginPerform (cEffectName);
  //
  FEffects := Eff;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.ClearEffects;
begin
  if (FEffects <> NIL) then begin
    FastClear (@FEffects.FMapFootPrint, SizeOf (FEffects.FMapFootPrint));
    FEffects.FGameAreaOwner := NIL;
    FEffects.FBoundingBox := Rect (0, 0, 0, 0);
    FreeAndNIL (FEffects);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.ClearAction;
begin
  if (ActiveAction <> NIL) then begin
    AQ_Done (ActiveAction);
    ActiveAction := NIL;
    FDrawOffset := Point (0, 0);
    FEventTimer.TriggerValue := 0;
    FEventCounter := 0;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.UpdateSelf (WTicksElapsed: Cardinal);
var
  tmpAction: PZEActionRecord;
  PathList: TList;
  iIndex: integer;

  procedure StopMotion;
  begin
    AQ_Clear;
    ClearAction;
    ExtraStateInfo := '';
    StateChanged;
  end;

begin
  // check if there is any effects ongoing...
  if (FEffects <> NIL) then FEffects.UpdateSelf (WTicksElapsed);
  //
  // ignore this call if entity is NOT updateable
  if (NOT FRequiresUpdate) then Exit;
  //
  // check the event queue...
  if (ActiveAction = NIL) then begin
  // no action being processed, check queue
    ActiveAction := AQ_Pop;
    // if there is no action, insert a delay in our action queue
    // when this delay clears, we will then request an action!
    if (ActiveAction = NIL) then begin
      if (ExtraStateInfo = STATE_INFO_MOVE) then StopMotion;
      tmpAction := ActionRecordCreate (eaDelay, Self, NIL, tdUnknown, NIL, 0, 100);
      AQ_InsertFront (tmpAction);
      Exit;
    end;
    //
    with ActiveAction^ do begin
      case Action of
        /////////////////////////////------------------------
        // Destination - Target Tile
        eaMoveTo: begin
          if (Destination <> NIL) AND (NOT Destination.CheckSpaces (AllSpaces)) then begin
            PathList := Destination.Owner.FindPath (AnchorTile, Destination);
            if (PathList <> NIL) then begin
              for iIndex := 0 to Pred (PathList.Count) do begin
                tmpAction := ActionRecordCreate (eaMove, NIL, NIL,
                  TZbDirection (PathList [iIndex]), NIL, 0, 0);
                if (tmpAction <> NIL) then AQ_InsertFront (tmpAction);
              end; // for
            end; // if
          end; // if
          ClearAction;
        end;
        /////////////////////////////------------------------
        // Direction - Which neighbor to go to next...
        eaMove: begin
          if (NOT CanStepTo (Direction)) then
            StopMotion
          else begin
            Destination := TZEViewTile (AnchorTile.Neighbors[Direction]);
            // re-orient if necessary
            if (Orientable) AND (Orientation <> Direction) then
              Orientation := Direction;
            // physically move to the new tile
            Unplace;
            PlaceAt (Destination);
            // change state to moving, if necessary
            if (ExtraStateInfo <> STATE_INFO_MOVE) then begin
              ExtraStateInfo := STATE_INFO_MOVE;
              StateChanged;
            end;
            // set up a timer to handle to moving
            FEventCounter := MOTION_STEPS;
            FEventTimer.TriggerValue := FMovementRate;
            FDrawOffset := __DirOffset [Direction];
            // *** this portion is something of a hack for now ***
            FAdjustedBounds := Direction in [tdNorth,tdWest];
            if (FAdjustedBounds) then begin
              Inc (FMapFootPrint.Tiles.Rect.Right);
              Inc (FMapFootPrint.Tiles.Rect.Bottom);
            end;
          end;
        end;
        /////////////////////////////------------------------
        eaPerform: begin
          ExtraStateInfo := String (cParam);
          StateChanged;
          HandleEvent (eePerformBegins);
        end;
        /////////////////////////////------------------------
        eaDelay, eaWait: begin
          FEventTimer.TriggerValue := dwParam;
        end;
        /////////////////////////////------------------------
        eaObserve: begin
        end;
        /////////////////////////////------------------------
        eaInteract: begin
        end;
        /////////////////////////////------------------------
        eaRemoveEffects: begin
          ClearEffects;
          ClearAction;
        end;
        /////////////////////////////------------------------
        eaNothing, eaEndOfList: ClearAction; // this really shouldn't happen...
        /////////////////////////////------------------------
      end; // case
    end;// with
    //
  end else begin
  // currently processing an action, continue on it
    with ActiveAction^ do begin
      case Action of
        /////////////////////////////------------------------
        eaMove: begin
          if (FEventTimer.CheckResetTrigger (WTicksElapsed)) then begin
            Dec (FEventCounter);
            if (FEventCounter <= 0) then begin
              // done with this movement action, remove it
              ClearAction;
              HandleEvent (eeArrived);

              // re-adjust the bounds, if necessary
              if (FAdjustedBounds) then begin
                Dec (FMapFootPrint.Tiles.Rect.Right);
                Dec (FMapFootPrint.Tiles.Rect.Bottom);
                FAdjustedBounds := FALSE;
              end;
              // check if we have no more move actions, or
              // no more actions for that matter.  if so, we
              // might have to trigger a portal on this tile
              if (AQ_Count = 0) then begin
                //
                // send a stop message first! the client program
                // may want to do something before triggering anything
                HandleEvent (eeStopped);
                //
                // check for portal trigger...
                if (AnchorTile.Portal <> NIL) AND
                   (AnchorTile.Portal.Kind = ptTransition) then begin
                    // perform the map transition here, tricky parts...
                    HandleEvent (eeTriggerPortal, AnchorTile.Portal);
                    // (for now, ask the event handler to do this for us)
                    // maybe exit immediately?
                    Exit;
                  end;
              end;
            end;
          end;
        end;
        /////////////////////////////------------------------
        eaPerform: begin
          // nothing to do here, the SAMMHandler should signal completion
        end;
        /////////////////////////////------------------------
        eaDelay, eaWait: begin
          if (FEventTimer.CheckResetTrigger (WTicksElapsed)) then begin
            if (Action = eaDelay) then
              HandleEvent (eeActionRequest)
              else HandleEvent (eeTimerFired);
            //
            ClearAction;
            //
          end;
        end;
        /////////////////////////////------------------------
        eaObserve: begin
        end;
        /////////////////////////////------------------------
        eaInteract: begin
        end;
        eaNothing, eaEndOfList: ClearAction; // this really shouldn't happen...
        /////////////////////////////------------------------
      end; // case
    end; // with
  end; // else
  //
  // update our LOOKS onscreen via the SAMM
  SAMM.UpdateEntityState (FEntitySnapShot, WTicksElapsed);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CallHandler (Event: TZEEntityEvent; pParam1, pParam2: Pointer;
  lParam1, lParam2: integer): integer;
begin
  if (Assigned (FEventHandler)) then
    Result := FEventHandler (Self, Event, pParam1, pParam2, lParam1, lParam2)
  else if (Assigned (FRemoteHandler)) then
    Result := FRemoteHandler (Integer (Self), Integer (Event),
      Integer (pParam1), Integer (pParam2), lParam1, lParam2)
  else
    Result := 1;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.HandleEvent (Event: TZEEntityEvent; pParam1, pParam2: Pointer;
  lParam1, lParam2: integer): integer;
var
  AtTile: TZEViewTile;
begin
  Result := 1;
  case Event of
    //
    eeDoActionMain: begin
      AtTile := TZEViewTile (pParam1);
      if (AtTile <> NIL) then begin
        if (AtTile.UserData <> NIL) then begin
          pParam2 := AtTile.UserData;
          Result := CallHandler (Event, pParam1, pParam2, lParam1, lParam2);
        end else begin
          Result := CallHandler (eeQueryMove, pParam1, NIL);
          if (Result <> 0) then MoveTo (AtTile);
        end;
      end;
    end;
    //
    else begin
      Result := CallHandler (Event, pParam1, pParam2, lParam1, lParam2);
    end; // else in case
    //
  end; // case
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.Clone (ANewName: string): TZEEntity;
var
  SelfClass: TZEEntityClass;
begin
  if (ANewName = '') then ANewName := Name;
  SelfClass := TZEEntityClass (Self.ClassType);
  Result := SelfClass.Create (String (MasterName), ANewName, NIL);
  //
  Result.FRequiresUpdate := FRequiresUpdate;
  Result.FOrientable := FOrientable;
  Result.FMovementRate := FMovementRate;
  Result.FCanMove := (FMovementRate > 0);
  //
  Result.FSAMM := FSAMM.Clone;
  Result.FSAMM.Notify := Result.SAMMLoopHandler;
  Result.Orientation := Orientation;
  Result.ExtraStateInfo := ExtraStateInfo;
  Result.StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.OKToPlace (AtTile: TZEViewTile): boolean;
begin
  Result := FALSE;
  // if we're already anchored, we're not placeable anywhere else...
  if (OnMap) then Exit;
  // if dest tile is NOTHING, well, nothing to do
  if (AtTile = NIL) OR (NOT Assigned (FOKToPlace)) then Exit;
  Result := FOKToPlace (AtTile);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.PlaceAt (AtTile: TZEViewTile; bCheckLocation: boolean): boolean;
begin
  Result := FALSE;
  if (bCheckLocation) AND (NOT (OKToPlace (AtTile))) then Exit;
  if (NOT Assigned (FPlaceAt)) then Exit;
  //
  FPlaceAt (AtTile);
  CreateMapFootPrint (AtTile);
  if (FGameAreaOwner <> NIL) then FGameAreaOwner.Map.ViewIsDirty := TRUE;
  //
  CalcBoundingBox (AnchorTile);
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Unplace;
begin
  // if we're floating, no need to do anything at all.
  if (NOT OnMap) OR (NOT Assigned (FUnplace)) then Exit;
  //
  FUnplace;
  ClearMapFootPrint;
  ClearEffects;
  //
  if (FGameAreaOwner <> NIL) then FGameAreaOwner.Map.ViewIsDirty := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.MoveTo (X, Y, Z: integer);
var
  theLevel: TZELevel;
  theTile: TZETile;
begin
  if (NOT OnMap) then Exit;
  theLevel := GameAreaOwner.Map [Z];
  if (theLevel = NIL) then Exit;
  theTile := theLevel [X, Y];
  if (theTile <> NIL) then MoveTo (theTile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.MoveTo (ToTile: TZETile);
begin
  MoveTo (TZEViewTile (ToTile));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.MoveTo (ToTile: TZEViewTile);
//var
//  bMoveOK: boolean;
begin
  if (ToTile <> NIL) AND (ToTile.UserData = NIL) then begin
    //bMoveOK := HandleEvent (eeQueryMove, Pointer (ToTile)) <> 0;
    //if (bMoveOK) then
    AQ_InsertBack(ActionRecordCreate (eaMoveTo, NIL, ToTile, tdUnknown, NIL, 0, 0));
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CanSee (Target: TZEEntity): boolean;
begin
  Result := FALSE;
  if (Target = NIL) OR (NOT OnMap) OR (Target.GameAreaOwner <> GameAreaOwner) then Exit;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.HowFarFrom (Target: TZEEntity): Integer;
begin
  Result := -1;
  if (Target = NIL) OR (NOT OnMap) OR (Target.GameAreaOwner <> GameAreaOwner) then Exit;
  Result := AnchorTile.HowFarTo (Target.AnchorTile);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.IsNeighbor (Target: TZEEntity): boolean;
begin
  Result := FALSE;
  if (Target = NIL) OR (NOT OnMap) OR (Target.GameAreaOwner <> GameAreaOwner) then Exit;
  Result := AnchorTile.IsNeighbor (Target.AnchorTile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Face (Target: TZEEntity);
begin
  if (Target <> NIL) then Face (AnchorTile.GetDirectionTo (Target.AnchorTile));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Face (ADirection: TZbDirection);
begin
  if (ADirection <> tdUnknown) then begin
    Orientation := ADirection;
    StateChanged;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Approach (Target: TZEEntity);
begin
  if (Target = NIL) OR (NOT OnMap) OR
    (Target.GameAreaOwner <> GameAreaOwner) OR
    (NOT Target.OnMap) then Exit;
  //
  StepTo (AnchorTile.GetDirectionTo (Target.AnchorTile));
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CanStepTo (ADirection: TZbDirection): boolean;
var
  vtTarget: TZEViewTile;
begin
  Result := FALSE;
  if (NOT OnMap) OR (NOT CanMove) OR (ADirection = tdUnknown) then Exit;
  //
  vtTarget := TZEViewTile (AnchorTile.Neighbors [ADirection]);
  if (vtTarget = NIL) OR (NOT AnchorTile.CanExitTo (ADirection)) OR
     (NOT vtTarget.CanEnterFrom (__DirOpposite [ADirection])) then Exit;
  //
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.StepTo (ADirection: TZbDirection);
var
  tmpAction: PZEActionRecord;
begin
  if (NOT CanStepTo (ADirection)) then Exit;
  tmpAction := ActionRecordCreate (eaMove, NIL, NIL, ADirection, NIL, 0, 0);
  AQ_InsertFront (tmpAction);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.GetNeighbor (ADirection: TZbDirection): TZEEntity;
var
  vtAnchor, nTile: TZEViewTile;
begin
  Result := NIL;
  if (NOT OnMap) then Exit;
  vtAnchor := AnchorTile;
  if (vtAnchor = NIL) then Exit;
  //
  nTile := TZEViewTile (vtAnchor.Neighbors [ADirection]);
  if (nTile = NIL) then Exit;
  Result := TZEEntity (nTile.UserData);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.GetAreaName: PChar;
begin
  if (GameAreaOwner = NIL) then
    Result := NIL
    else Result := GameAreaOwner.__FName;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.SetDefaultOrientation;
var
  SeqDir: TZESequenceOrientation;
begin
  Orientation := tdUnknown;
  if (NOT Orientable) then Exit;
  //
  SeqDir := FOrientationList.ListI [0];
  if (SeqDir = NIL) then Exit;
  //
  Orientation := SeqDir.Orientation;
  //StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntity.CheckOrientation (ADirection: TZbDirection): boolean;
begin
  Result := (FOrientationList.ListD [ADirection] <> NIL);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntity.Draw (pRef: TPoint; CaptionFont: TZEFont; bForceAlpha: boolean);
var
  ISprite: IZESprite;
  opRef, pDelta: TPoint;
  //
  //bUseAlpha: boolean;
  //dwAlpha: Cardinal;
begin
  if (NOT OnMap) then Exit;
  if (bForceAlpha) then Exit;
  //
  ISprite := EntitySnapShot.Sprite;
  if (ISprite <> NIL) then begin
    opRef := pRef;
    //
    pDelta.X := (ISprite.Width - FBoundBoxSize.X) div 2;
    pDelta.Y := ISprite.Height - FBoundBoxSize.Y;
    //
    pRef := SubPoint (AddPoint (pRef, FBoundingBox.TopLeft), pDelta);
    if (FEventCounter > 0) then begin
      pDelta := ScalePoint (FDrawOffset, FEventCounter, FEventCounter);
      pRef := SubPoint (pRef, pDelta);
    end;
    ISprite.Position := pRef;
    (*if (bForceAlpha) then begin
      bUseAlpha := ISprite.UseAlpha;
      dwAlpha := ISprite.Alpha;
      //
      ISprite.UseAlpha := TRUE;
      ISprite.Alpha := 128;
      ISprite.Draw (TRUE);
      //
      ISprite.UseAlpha := bUseAlpha;
      ISprite.Alpha := dwAlpha;
    end else*)
      ISprite.Draw (TRUE);
    //
    // check if caption needs to drawn as well

    if (FCaptionText <> NIL) AND (CaptionFont <> NIL) then begin
      Dec (pRef.Y, CaptionFont.Height + 3);
      CaptionFont.WriteText (IDirectDrawSurface7 (ISprite.DestSurface),
        String (FCaptionText), pRef);
      //
    end;
    //
    if (FEffects <> NIL) then FEffects.Draw (opRef, NIL);
  end;
end;


{ TZEEntityGroup }

procedure TZEEntityGroup.CommonInit;
begin
  FEntityData := TZbDoubleList.Create (TRUE);
  FEntityData.DisposeProc := __DeleteObject;
  FEntityData.Sorted := TRUE;
  //
  FEntities := TZbDoubleList.Create (TRUE);
  FEntities.DisposeProc := __DeleteObject;
  FEntities.Sorted := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEEntityGroup.Create (cFolder: string);
begin
  inherited Create;
  CommonInit;
  LoadList (cFolder);
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEEntityGroup.Create (fsFolder: TZbFSFolder);
begin
  inherited Create;
  CommonInit;
  LoadList (fsFolder);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEEntityGroup.Destroy;
begin
  FEntities.Free;
  FEntityData.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityGroup.LoadList (cFolder: string);
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityGroup.LoadList (fsFolder: TZbFSFolder);

  procedure ProcessFile (AFile: TZbFSFile);
  var
    theStream: TStream;
    StrList, SectionList: TStrings;
    cName: string;
    IniFile: TZbIniFileEx;
    iIndex: integer;
  begin
    theStream := TMemoryStream.Create;
    theStream.Write (AFile.Data^, AFile.Size);
    theStream.Position := 0;
    AFile.Release;
    //
    IniFile := TZbIniFileEx.Create (theStream);
    SectionList := TStringList.Create;
    try
      IniFile.ReadSections (SectionList);
      for iIndex := 0 to Pred (SectionList.Count) do begin
        cName := SectionList [iIndex];
        //
        StrList := TStringList.Create;
        IniFile.ReadSection (cName, StrList, TRUE);
        FEntityData.Add (cName, Pointer (StrList));
      end;
      //
    finally
      IniFile.Free;
      theStream.Free;
      SectionList.Free;
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
  if (fsFolder <> NIL) then ProcessFolder (fsFolder);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityGroup.GetCount: integer;
begin
  Result := FEntityData.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityGroup.GetEntity_I (iIndex: integer): TZEEntity;
var
  cName: string;
begin
  cName := FEntityData.GetName (iIndex);
  Result := GetEntity_S (cName);
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityGroup.GetEntity_S (cEntityName: string): TZEEntity;
var
  StrList: TStrings;
begin
  Result := TZEEntity (FEntities.Get (cEntityName));
  if (Result = NIL) then begin
    StrList := TStrings (FEntityData.Get (cEntityName));
    if (StrList = NIL) then Exit;
    //
    Result := TZEEntity.Create (cEntityName, cEntityName,
      TZbEnumStringList.Create (StrList) as IZbEnumStringList);
    //
    if (Result <> NIL) then FEntities.Add (cEntityName, Pointer (Result));
  end;
end;


{ TZEEntityManager }

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityManager.CommonInit;
begin
  FGroupList := TZbDoubleList.Create (TRUE);
  FGroupList.DisposeProc := __DeleteObject;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEEntityManager.Create (cFolder: string);
begin
  inherited Create;
  CommonInit;
  LoadEntities (cFolder);
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEEntityManager.Create;
begin
  inherited Create;
  CommonInit;
  LoadEntities;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEEntityManager.Destroy;
begin
  FGroupList.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityManager.LoadEntities (cFolder: string);
var
  TSR: TSearchRec;
  theGroup: TZEEntityGroup;
begin
  cFolder := IncludeTrailingPathDelimiter (cFolder);
  if (FindFirst (cFolder + '*.*', faAnyFile, TSR) = 0) then begin
    repeat
      if (TSR.Name <> '') then begin
        if ((TSR.Attr AND faDirectory) <> 0) then begin
          if (TSR.Name <> '.') AND (TSR.Name <> '..') then begin
            theGroup := TZEEntityGroup.Create (cFolder + TSR.Name);
            if (theGroup.Count > 0) then
              FGroupList.Add ('', Pointer (theGroup))
              else theGroup.Free;
            //
          end;
        end;
      end;
    until (FindNext (TSR) <> 0);
    FindClose (TSR);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityManager.LoadEntities;
var
  iIndex: integer;
  theVolume: TZbStandardVolume;
  theGroup: TZEEntityGroup;
begin
  for iIndex := 0 to Pred (CoreEngine.ImageManager.LibraryCount) do begin
    theVolume := CoreEngine.ImageManager.Libraries [iIndex].Source;
    theGroup := TZEEntityGroup.Create (theVolume.Root.Folders [ENTITY_FOLDER_NAME]);
    if (theGroup.Count > 0) then
      FGroupList.Add ('', Pointer (theGroup))
      else theGroup.Free;
    //
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityManager.GetEntityCount: integer;
var
  iIndex: integer;
begin
  Result := 0;
  for iIndex := 0 to Pred (FGroupList.Count) do
    Result := Result + TZEEntityGroup (FGroupList.Get (iIndex)).Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityManager.GetEntityByIndex (iIndex: Integer): TZEEntity;
var
  iPos: integer;
  theGroup: TZEEntityGroup;
begin
  Result := NIL;
  for iPos := 0 to Pred (FGroupList.Count) do begin
    theGroup := TZEEntityGroup (FGroupList.Get (iPos));
    if (iIndex < theGroup.Count) then begin
      Result := theGroup.EntityByIndex [iIndex];
      break;
    end;
    Dec (iIndex, theGroup.Count);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityManager.GetEntityByName (cName: string): TZEEntity;
var
  iIndex: integer;
  theGroup: TZEEntityGroup;
begin
  Result := NIL;
  for iIndex := 0 to Pred (FGroupList.Count) do begin
    theGroup := TZEEntityGroup (FGroupList.Get (iIndex));
    Result := theGroup [cName];
    if (Result <> NIL) then break;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityManager.GetGroupCount: integer;
begin
  Result := FGroupList.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityManager.GetGroupByIndex (iIndex: integer): TZEEntityGroup;
begin
  if (iIndex >= 0) AND (iIndex < FGroupList.Count) then
    Result := TZEEntityGroup (FGroupList.Get (iIndex))
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityManager.CreateEntity (cEntityMasterName, cNewName: string): TZEEntity;
begin
  Result := GetEntityByName (cEntityMasterName);
  if (Result <> NIL) then Result := Result.Clone (cNewName);
end;


{ TZEEntityList }

//////////////////////////////////////////////////////////////////////////
constructor TZEEntityList.Create;
begin
  inherited Create;
  FEntities := TZbDoubleList.Create (TRUE);
  FEntities.Sorted := TRUE;
  FEntities.DisposeProc := DisposeScriptable;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEEntityList.Destroy;
begin
  FEntities.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityList.GetCount: integer;
begin
  Result := FEntities.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityList.GetEntity (iIndex: integer): TZEEntity;
begin
  Result := TZEEntity (FEntities.Get (iIndex));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityList.Add (Entity: TZEEntity);
begin
  // don't add if NULL or already in the list
  if (Entity = NIL) OR (Find (Entity) <> NIL) then Exit;
  FEntities.Add (Entity.Name, Pointer (Entity));
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityList.Find (Entity: TZEEntity): TZEEntity;
begin
  Result := TZEEntity (FEntities.Get (FEntities.GetName (Entity)));
end;

//////////////////////////////////////////////////////////////////////////
function TZEEntityList.Find (cEntityName: string): TZEEntity;
begin
  Result := TZEEntity (FEntities.Get (cEntityName));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityList.Clear;
begin
  FEntities.Clear;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityList.Delete (Entity: TZEEntity);
begin
  if (Entity = NIL) then Exit;
  FEntities.Delete (FEntities.GetName (Entity));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityList.Delete (cEntityName: string);
begin
  FEntities.Delete (cEntityName);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityList.Remove (Entity: TZEEntity);
begin
  if (Entity = NIL) then Exit;
  FEntities.Remove (FEntities.GetName (Entity));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEntityList.Remove (cEntityName: string);
begin
  FEntities.Remove (cEntityName);
end;


{ TZEVisibleEntityList }

//////////////////////////////////////////////////////////////////////////
constructor TZEVisibleEntityList.Create;
begin
  inherited Create;
  FEntities := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEVisibleEntityList.Destroy;
begin
  Clear;
  FEntities.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEVisibleEntityList.GetCount: integer;
begin
  Result := FEntities.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEVisibleEntityList.GetEntity (iIndex: integer): TZEEntity;
begin
  Result := TZEEntity (FEntities [iIndex]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEVisibleEntityList.Add (Entity: TZEEntity);
var
  iIndex: integer;
  theEntity: TZEEntity;
begin
  // check if entity is already in the list, if so, ignore this
  if (FEntities.IndexOf(Entity) > 0) then Exit;
  //
  iIndex := 0;
  while (iIndex < FEntities.Count) do begin
    theEntity := TZEEntity (FEntities [iIndex]);
    //if (theEntity = NIL) then continue;
    //
    if (Entity.ComesBefore (theEntity)) then break;
    Inc (iIndex);
  end;
  FEntities.Insert (iIndex, Pointer (Entity));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEVisibleEntityList.Remove (Entity: TZEEntity);
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FEntities.Count) do
    if (TZEEntity (FEntities [iIndex]) = Entity) then begin
      FEntities [iIndex] := NIL;
      FEntities.Pack;
      break;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEVisibleEntityList.Clear;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FEntities.Count) do FEntities [iIndex] := NIL;
  FEntities.Clear;
end;


{ TZEGameArea }

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.CommonInit;
begin
  FMap := NIL;
  FEntities := TZEEntityList.Create;
  FVisibles := TZEVisibleEntityList.Create;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEGameArea.Create (AName: string);
begin
  inherited Create;
  CommonInit;
  Name := AName;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEGameArea.Create (Reader: IZbFileReader);
begin
  inherited Create;
  CommonInit;
  Load (Reader);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.Load (Reader: IZbFileReader);
var
  iIndex, iCount: integer;
  X, Y, Z: integer;
begin
  inherited;
  //
  if (NOT Reader.ReadBoolean) then Exit;
  //
  FMap := TZEViewMap.Create (Reader);
  PostProcessMap;
  //
  iCount := Reader.ReadInteger;
  for iIndex := 0 to Pred (iCount) do begin
    if (NOT Reader.ReadBoolean) then begin
      X := -1;
      Y := -1;
      Z := -1;
    end else begin
      X := Reader.ReadInteger;
      Y := Reader.ReadInteger;
      Z := Reader.ReadInteger;
    end;
    //
    PlaceEntity (TZEEntity.Create (Reader), X, Y, Z);
  end;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEGameArea.Destroy;
begin
  DiscardData;
  FEntities.Free;
  FVisibles.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.Save (Writer: IZbFileWriter);
var
  iIndex: integer;
begin
  inherited;
  // if there is no map, write a NIL marker to indicate this...
  if (FMap = NIL) then begin
    Writer.WriteBoolean (FALSE);
    Exit;
  end;
  // write tag to indicate that there IS a map in there
  // and then immediately write the map data
  Writer.WriteBoolean (TRUE);
  FMap.Save (Writer);
  // write how many entities are going to be Save()d
  Writer.WriteInteger (FEntities.Count);
  for iIndex := 0 to Pred (FEntities.Count) do begin
    with FEntities [iIndex] do begin
      // flag floating entities as
      if (NOT OnMap) then
        Writer.WriteBoolean (FALSE)
      else begin
      // placed tiles need to have a record of where
      // they currently are in the map so they can
      // be re-placed there during load time
        Writer.WriteBoolean (TRUE);
        Writer.WriteInteger (AnchorTile.GridX);
        Writer.WriteInteger (AnchorTile.GridY);
        Writer.WriteInteger (AnchorTile.Owner.LevelIndex);
      end;
      Save (Writer);
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.DiscardData;
begin
  // no map? nothing to do if so...
  if (FMap = NIL) then Exit;
  // discard the entities first so they can unlink themselves from the map
  FEntities.Clear;
  FVisibles.Clear;
  // discard the map next
  FreeAndNIL (FMap);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.PostProcessMap;
begin
  with FMap do begin
    // set the callbacks
    BeforeViewListRebuild := _BeforeViewListRebuild;
    AfterViewListRebuild := _AfterViewListRebuild;
    TileIncluded := _TileToViewList;
    OnDraw := _DrawEntities;
    MapId := Self.Name;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.PostLoadProcessing;
var
  theLevel: TZELevel;
  theTile: TZETile;
  thePortal: PZEPortal;
  X, Y, Z: integer;
  theAreaName: PChar;
begin
  with FMap do begin
    for Z := 0 to Pred (Count) do begin
      theLevel := Levels [Z];
      for X := 0 to Pred (Width) do begin
        for Y := 0 to Pred (Height) do begin
          theTile := theLevel [X, Y];
          thePortal := theTile.Portal;
          if (thePortal = NIL) OR (thePortal.Kind = ptStart) then continue;
          //
          theAreaName := PChar (thePortal.DestMap);
          thePortal.DestMap := Owner.Areas [String (theAreaName)].Map;
          StrDispose (theAreaName);
        end;
      end;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea._TileToViewList (ATile: TZEViewTile);
begin
  if (ATile.UserData <> NIL) then FVisibles.Add (TZEEntity (ATile.UserData));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea._BeforeViewListRebuild (AMap: TZEViewMap);
begin
  FVisibles.Clear;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea._AfterViewListRebuild (AMap: TZEViewMap);
begin
  // nothing to do here
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea._DrawEntities (pReference: TPoint);
var
  iIndex: integer;
  Entity: TZEEntity;
begin
  for iIndex := 0 to Pred (FVisibles.Count) do begin
    Entity := FVisibles [iIndex];
    Entity.Draw (pReference, Owner.CaptionFont);
  end;
  //
  with Owner do begin
    if (PC <> NIL) AND (PC.GameAreaOwner = Self) then
      PC.Draw (pReference, Owner.CaptionFont, TRUE);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameArea.GetDropPoint: TZbVector;
var
  X, Y, Z: integer;
  theTile: TZETile;
begin
  if (FMap <> NIL) then with FMap do begin
    for Z := 0 to Pred (Count) do begin
      for X := 0 to Pred (Width) do begin
        for Y := 0 to Pred (Height) do begin
          theTile := Levels [Z][X, Y];
          if (theTile = NIL) OR (theTile.Portal = NIL) then continue;
          if (theTile.Portal.Kind = ptStart) AND (NOT theTile.CheckSpace (osCenter)) then begin
            Result := Vector (X, Y, Z);
            Exit;
          end;
        end;
      end;
    end;
  end;
  //
  Result := NullVector;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameArea.PlaceEntity (Entity: TZEEntity; WhereX, WhereY, WhereLevel: integer): boolean;
var
  theLevel: TZEViewLevel;
  theTile: TZEViewTile;
begin
  Result := FALSE;
  //
  if (Entity = NIL) OR (WhereLevel >= FMap.Count) then Exit;
  if (WhereX < 0) OR (WhereY < 0) then Exit;
  //
  theLevel := TZEViewLevel (FMap [WhereLevel]);
  if (theLevel = NIL) OR (WhereX >= theLevel.Width) OR (WhereY >= theLevel.Height) then Exit;
  //
  theTile := TZEViewTile (theLevel [WhereX, WhereY]);
  if (theTile = NIL) OR (theTile.UserData <> NIL) then Exit;
  //
  Result := PlaceEntity (Entity, theTile);
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameArea.PlaceEntity (Entity: TZEEntity; WhereLoc: TPoint; WhereLevel: integer): boolean;
begin
  Result := PlaceEntity (Entity, WhereLoc.X, WhereLoc.Y, WhereLevel);
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameArea.PlaceEntity (Entity: TZEEntity; WhereTile: TZEViewTile): boolean;
begin
  Result := Entity.PlaceAt (WhereTile);
  if (Result) then begin
    // place in Master Entities List if not already there
    if (FEntities.Find (Entity) <> Entity) then begin
      FEntities.Add (Entity);
      Entity.GameAreaOwner := Self;
    end;
    // force map to redraw
    FMap.ViewIsDirty := TRUE;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameArea.FindEntity (cEntityName: string): TZEEntity;
begin
  Result := FEntities.Find (cEntityName);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.DeleteEntity (cEntityName: string);
begin
  DeleteEntity (TZEEntity (FEntities.Find (cEntityName)));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.DeleteEntity (Entity: TZEEntity);
begin
  if (Entity <> NIL) then begin
    if (Owner.PC = Entity) then begin
      Owner.UnDropPC;
    end else begin
      Entity.Unplace;
      FEntities.Delete (Entity);
    end;
    // force map to redraw
    FMap.ViewIsDirty := TRUE;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.RemoveEntity (cEntityName: string);
begin
  RemoveEntity (TZEEntity (FEntities.Find (cEntityName)));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.RemoveEntity (Entity: TZEEntity);
begin
  if (Entity <> NIL) then begin
    Entity.Unplace;
    FEntities.Remove (Entity);
    // force map to redraw
    FMap.ViewIsDirty := TRUE;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.CreateMap (iWidth, iHeight: integer; iLevels: integer);
begin
  DiscardData;
  // create the map according to specifications given
  FMap := TZEViewMap.Create (iWidth, iHeight);
  with FMap do begin
    NewLevel;
    while (iLevels > 1) do begin
      Dec (iLevels);
      NewLevel;
    end;
  end;
  PostProcessMap;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.ChangeMapLevel (bMoveUp: boolean);
begin
  if (Map = NIL) then Exit;
  if (bMoveUp) then
    Map.MapLevelUp
    else Map.MapLevelDown;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameArea.PerformUpdate (WTicksElapsed: Cardinal);
var
  iIndex: integer;
  theEntity: TZEEntity;
begin
  try
    for iIndex := 0 to Pred (FEntities.Count) do begin
      theEntity := FEntities [iIndex];
      if (theEntity = NIL) then continue;
      if (theEntity.RequiresUpdate) OR (theEntity.FEffects <> NIL) then
        theEntity.UpdateSelf (WTicksElapsed);
    end;
  except
  end;
end;


{ TZEGameWorld }

//////////////////////////////////////////////////////////////////////////
constructor TZEGameWorld.Create;
begin
  inherited Create;
  FActiveArea := NIL;
  FPaused := FALSE;
  FAreas := TZbDoubleList.Create (TRUE);
  FAreas.Sorted := TRUE;
  FAreas.DisposeProc := DisposeScriptable;
  FPC := NIL;
  FPCCallback := NIL;
  FCaptionFont := NIL;
  FToDeleteList := TStringList.Create;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEGameWorld.Destroy;
begin
  FreeAndNIL (FToDeleteList);
  ClearPC;
  FCaptionFont := NIL;
  FActiveArea := NIL;
  FAreas.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.SetPaused (APaused: boolean);
begin
  FPaused := APaused;
  // TODO: may have to insert code to notify entities and ares (?)
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DeleteAreas;
begin
  FreeAndNIL (FPC);
  FAreas.Clear;
  FActiveArea := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DeleteArea;
begin
  DeleteArea (FActiveArea);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DeleteArea (cAreaName: string);
begin
  DeleteArea (TZEGameArea (FAreas.Get (cAreaName)));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DeleteArea (theArea: TZEGameArea);
begin
  // nothing to do if no area given
  if (theArea = NIL) then Exit;
  // clear active area if it's the one being deleted
  if (FActiveArea = theArea) then FActiveArea := NIL;
  // queue a notification event, and then delete the area
  //EventQueue.InsertEvent (cmDeletedArea, PChar (FActiveArea.Name));
  g_EventManager.Commands.InsertWithStr (cmDeletedArea, 0, PChar (FActiveArea.Name));
  FAreas.Delete (FAreas.IndexOf (Pointer (theArea)));
  // if active area was not touched, nothing more to do here
  if (FActiveArea <> NIL) then Exit;
  // set a new active area, just pick the first one in the list
  theArea := TZEGameArea (FAreas.Get (0));
  if (theArea <> NIL) then SwitchToArea (theArea.Name);
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.GetAreaCount: integer;
begin
  Result := FAreas.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.PCEntityFunc(Sender: TZEEntity; Event: TZEEntityEvent;
  pParam1, pParam2: Pointer; lParam1, lParam2: integer): integer; stdcall;
var
  tPortal: PZEPortal;
  cAreaName: String;
  theArea: TZEGameArea;
begin
  Result := 1;
  // handle portal triggering of PC here
  if (Event = eeTriggerPortal) then begin
    tPortal := PZEPortal (pParam1);
    cAreaName := TranslateMapToAreaName (tPortal.DestMap);
    theArea := GetArea (cAreaName);
    if (theArea = NIL) then Exit;
    //
    // consult callback if portal transition is allowed...
    if (Assigned (FPCCallback)) then
      Result := FPCCallback (Integer (Sender), Integer (Event),
        Integer (PChar (cAreaName)), Integer (pParam2), lParam1, lParam2);
    //
    // if portal is NOT allowed, exit now
    if (Result <> 1) then Exit;
    //
    // perform map transition RIGHT NOW!
    UnDropPC;
    if (theArea <> ActiveArea) then SwitchToArea (theArea);
    DropPC (theArea, tPortal.DestLoc);
    //
    Exit;
  end;
  //
  if (Assigned (FPCCallback)) then
    Result := FPCCallback (Integer (Sender), Integer (Event),
      Integer (pParam1), Integer (pParam2), lParam1, lParam2);
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.GetAreaByIndex (iIndex: integer): TZEGameArea;
begin
  Result := TZEGameArea (FAreas.Get (iIndex));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.ResetGameWindow;
begin
  if (GameWindow = NIL) then Exit;
  //
  if (ActiveArea = NIL) then
    GameWindow.ViewMap := NIL
    else GameWindow.ViewMap := ActiveArea.Map;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.CreateNewArea (AName: string): TZEGameArea;
begin
  // if there is an area with the same name, just return it
  Result := GetArea (AName);
  if (Result <> NIL) then Exit;
  //
  Result := TZEGameArea.Create (AName);
  if (Result = NIL) then Exit;
  //
  Result.Owner := Self;
  FAreas.Add (AName, Pointer (Result));
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.SwitchToArea (theArea: TZEGameArea): TZEGameArea;
begin
  Result := theArea;
  // nothing to do if this is already the active area
  if (theArea = FActiveArea) then Exit;
  //
  if (FActiveArea <> NIL) then
    g_EventManager.Commands.InsertWithStr (cmUnloadingArea, 0, PChar (FActiveArea.Name));
    //EventQueue.InsertEvent (cmUnloadingArea, PChar (FActiveArea.Name));
  //
  FActiveArea := theArea;
  //
  if (FActiveArea <> NIL) then
    g_EventManager.Commands.InsertWithStr (cmLoadingArea, 0, PChar (FActiveArea.Name));
    //EventQueue.InsertEvent (cmLoadingArea, PChar (FActiveArea.Name));
  //
  ResetGameWindow;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.SwitchToArea (AName: string): TZEGameArea;
begin
  Result := SwitchToArea (GetArea (AName));
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.GetArea (AName: string): TZEGameArea;
begin
  Result := TZEGameArea (FAreas.Get (AName));
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.TranslateMapToAreaName (Map: TZEMap): String;
var
  theArea: TZEGameArea;
  iIndex: integer;
begin
  Result := '';
  for iIndex := 0 to Pred (FAreas.Count) do begin
    theArea := TZEGameArea (FAreas.Get (iIndex));
    if (theArea.Map = Map) then begin
      Result := theArea.Name;
      break;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.TranslateAreaNameToMap (AreaName: string): TZEMap;
var
  theArea: TZEGameArea;
begin
  theArea := GetArea (AreaName);
  if (theArea <> NIL) then
    Result := theArea.Map
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.PerformUpdate (WTicksElapsed: Cardinal);
var
  iPos: Integer;
  hTarget: TZEEntity;
begin
  if (FPaused) then Exit;
  //
  if (FToDeleteList.Count > 0) then begin
    for iPos := 0 to Pred (FToDeleteList.Count) do begin
      hTarget := FindEntity (FToDeleteList [iPos]);
      if (hTarget <> NIL) then DeleteEntity (hTarget);
    end;
    FToDeleteList.Clear;
  end;
  if (ActiveArea <> NIL) then ActiveArea.PerformUpdate (WTicksElapsed);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.PerformAction (AtTile: TZEViewTile; bPrimary: boolean;
  atModifier: TZEActionModifiers);
const
  actionType: array [boolean] of TZEEntityEvent = (eeDoActionOther, eeDoActionMain);
begin
  // nothing to do if no character on map
  if (PC = NIL) OR (NOT PC.OnMap) OR (FPaused) then Exit;
  PC.HandleEvent (actionType [bPrimary], AtTile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.SaveToFile (cFileName: string);
begin
  SaveToFile (CoreEngine.FileManager.CreateWriter (cFileName));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.SaveToFile (Writer: IZbFileWriter);
var
  iIndex: integer;
  fHeader: TZEGWFHeader;
begin
  // save the header first of all!
  ZeroMemory (@fHeader, SizeOf (TZEGWFHeader));
  with fHeader do begin
    iMagicNumber := GWF_MAGIC_NUMBER;
    for iIndex := 1 to GWF_SIGNATURE_LEN do
      cStrSignature [Pred (iIndex)] := GWF_SIGNATURE [iIndex];
    iVersionTag := GWF_VERSION;
    //
    iAreaCount := FAreas.Count;
    if (FActiveArea <> NIL) then
      iActiveArea := FAreas.IndexOf (FActiveArea)
      else iActiveArea := -1;
  end;
  Writer.WriteBuffer (@fHeader, SizeOf (fHeader));
  // now ask all the areas to write themselves
  for iIndex := 0 to Pred (FAreas.Count) do
    TZEGameArea (FAreas.Get (iIndex)).Save (Writer);
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.LoadFromFile (cFileName: string);
begin
  LoadFromFile (CoreEngine.FileManager.CreateReader (cFileName));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.LoadFromFile (Reader: IZbFileReader);
var
  theArea: TZEGameArea;
  iIndex: integer;
  pfHeader: PZEGWFHeader;
begin
  // load the header here
  pfHeader := Reader.ReadBuffer (SizeOf (TZEGWFHeader));
  try
    // decode the header and bail out on invalid data
    with pfHeader^ do begin
      if (iMagicNumber <> GWF_MAGIC_NUMBER) then Exit;
      for iIndex := 1 to GWF_SIGNATURE_LEN do
        if (cStrSignature [Pred (iIndex)] <> GWF_SIGNATURE [iIndex]) then Exit;
      if (iVersionTag < GWF_VERSION) then Exit;
    end;
    //
    // load all the areas individually...
    FAreas.Clear;
    for iIndex := 0 to Pred (pfHeader.iAreaCount) do begin
      theArea := TZEGameArea.Create (Reader);
      if (theArea <> NIL) then begin
        FAreas.Add (theArea.Name, Pointer (theArea));
        theArea.FOwner := Self;
      end;
    end;
    //
    for iIndex := 0 to Pred (pfHeader.iAreaCount) do
      TZEGameArea (FAreas.Get (iIndex)).PostLoadProcessing;

    // prepare things for viewing
    FActiveArea := NIL;
    if (pfHeader.iActiveArea >= 0) then
      SwitchToArea (FAreas.GetName (pfHeader.iActiveArea));
    //
  finally
    if (pfHeader <> NIL) then FreeMem (pfHeader, SizeOf (TZEGWFHeader));
  end;
  //
  //EventQueue.InsertEvent (cmWorldLoaded);
  g_EventManager.Commands.Insert (cmWorldLoaded, 0, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.SetCaptionFont (AFont: TZEFont);
begin
  FCaptionFont := AFont;
  if (GameWindow <> NIL) then begin
    GameWindow.SetStyle (syUseParentFont, FALSE);
    GameWindow.Font := FCaptionFont;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.InitPC (FaceWhere: TZbDirection;
  Handler: TZERemoteEntityCallback);
begin
  if (FPC = NIL) then Exit;
  //
  FPC.ExtraStateInfo := '';
  FPC.Orientation := FaceWhere;
  FPCCallback := Handler;
  //
  FPC.Handler := PCEntityFunc;
  FPC.IgnorePortals := FALSE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.ReplacePC (cMasterName, cWorkingName: string;
  Handler: TZERemoteEntityCallback);
var
  DropVector: TZbVector;
  TPC: TZEEntity;
  FaceTo: TZbDirection;
begin
  if (FPC = NIL) then begin
    // if there is no PC yet, just create it
    CreatePC (cMasterName, cWorkingName, Handler);
    DropPC;
  end else begin
    //
    if (cWorkingName = '') then cWorkingName := DEFAULT_PC_NAME;
    // attempt to create a PC
    TPC := CoreEngine.EntityManager.CreateEntity (cMasterName, cWorkingName);
    if (TPC = NIL) then Exit;
    // if no handler, then get the one assigned to the current PC
    DropVector.X := FPC.AnchorTile.GridX;
    DropVector.Y := FPC.AnchorTile.GridY;
    DropVector.Z := FPC.AnchorTile.Owner.LevelIndex;
    FaceTo := FPC.Orientation;
    //
    ClearPC;
    FPC := TPC;
    InitPC (FaceTo, Handler);
    DropPC (ActiveArea.Name, DropVector);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.CreatePC (cMasterName, cWorkingName: string;
  Handler: TZERemoteEntityCallback);
begin
  ClearPC;
  if (cWorkingName = '') then cWorkingName := DEFAULT_PC_NAME;
  FPC := CoreEngine.EntityManager.CreateEntity (cMasterName, cWorkingName);
  InitPC (tdNorth, Handler);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.ClearPC;
begin
  if (FPC <> NIL) then begin
    UnDropPC;
    FreeAndNIL (FPC);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DropPC;
begin
  if (FPC = NIL) OR (ActiveArea = NIL) then Exit;
  DropPC (ActiveArea.Name);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DropPC (theArea: TZEGameArea; DropVector: TZbVector);
begin
  // if no PC, or no Area, then Exit now
  if (FPC = NIL) OR (theArea = NIL) then Exit;
  //
  // remove PC from map if it's there already
  // even if the PC is already on the map where the drop
  // is request, we still should UnDrop the PC, just in
  // case he needs to be re-dropped elsewhere on the map
  //if (FPC.OnMap) then begin
  //  if (FPC.GameAreaOwner = theArea) then Exit;
  //  UnDropPC;
  //end;
  if (FPC.OnMap) then UnDropPC;
  //
  // create the drop vector, if it's NULL, get the default
  if (IsNullVector (DropVector)) then begin
    // if there is no default drop vector, we're screwed.
    // to avoid further errors, just exit from here
    DropVector := theArea.GetDropPoint;
    if (IsNullVector (DropVector)) then Exit;
  end;
  //
  theArea.PlaceEntity (FPC, DropVector.X, DropVector.Y, DropVector.Z);
  theArea.Map.Center(FPC.AnchorTile)
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DropPC (cAreaByName: string; DropVector: TZbVector);
begin
  DropPC (GetArea (cAreaByName), DropVector);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DropPC (cAreaByName: string; X, Y, Z: integer);
begin
  DropPC (cAreaByName, Vector (X, Y, Z));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.UnDropPC;
begin
  if (FPC <> NIL) AND (FPC.OnMap) then begin
    FPC.ClearAction;
    FPC.AQ_Clear;
    FPC.GameAreaOwner.RemoveEntity (FPC);
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.FindEntity (cEntityName: string): TZEEntity;
var
  theArea: TZEGameArea;
  iIndex: integer;
begin
  Result := NIL;
  // try the active area first...
  if (ActiveArea <> NIL) then begin
    Result := ActiveArea.FindEntity (cEntityName);
    if (Result <> NIL) then Exit;
  end;
  //
  for iIndex := 0 to Pred (FAreas.Count) do begin
    theArea := TZEGameArea (FAreas.Get (iIndex));
    Result := theArea.FindEntity (cEntityName);
    if (Result <> NIL) then Exit;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DeleteEntity (cEntityName: string);
begin
  DeleteEntity (FindEntity (cEntityName));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DeleteEntity (Entity: TZEEntity);
begin
  if (Entity <> NIL) then Entity.GameAreaOwner.DeleteEntity (Entity);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.QueueForDeletion (cEntityName: String);
begin
  cEntityName := Trim (cEntityName);
  if (cEntityName = '') then Exit;
  FToDeleteList.Add (cEntityName);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.QueueForDeletion (Entity: TZEEntity);
begin
  if (Entity = NIL) then Exit;
  QueueForDeletion (Entity.Name);
end;

{ Utility Routines }

//////////////////////////////////////////////////////////////////////////
procedure ActionRecordDispose (lpAction: PZEActionRecord);
begin
  if (lpAction <> NIL) then begin
    if (lpAction.cParam <> NIL) then StrDispose (lpAction.cParam);
    Dispose (lpAction);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function ActionRecordCreate (eaAction: TZEEntityAction;
  eTarget: TZEEntity; vtDestination: TZEViewTile;
  dWhere: TZbDirection; acParam: PChar; aiParam: integer;
  adwParam: Cardinal): PZEActionRecord;
begin
  New (Result);
  if (Result = NIL) then Exit;
  //
  ZeroMemory (Result, SizeOf (TZEActionRecord));
  with Result^ do begin
    Action := eaAction;
    Target := eTarget;
    Destination := vtDestination;
    Direction := dWhere;
    if (acParam <> NIL) then cParam := StrNew (acParam);
    iParam := aiParam;
    dwParam := adwParam;
  end;
end;


end.

