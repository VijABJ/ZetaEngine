{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEGameWorld.PAS
              Portrays the Virtual World - represents characters as Actors,
              and the world as WorldMap.  This also contains a reference to
              the Displayable version of the Game - called ViewMap.
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

unit ZZEGameWorld;

interface

uses
  Types,
  Classes,
  ZbDoubleList,
  ZbScriptable,
  ZbGameUtils,
  ZbFileIntf,
  //
  ZZESupport,
  ZZEScrObjects,
  ZZEWorldMap;

  {
    TODO 5 -oVij: things to add to GameWorld
    ----------------------------
    * List of Triggers, triggers are invisible debris
    *
  }

const
  STATE_DELIMITER       = '/';

  MOTION_STEPS          = 8;    // DO NOT CHANGE!!!
  MOTION_DELAY          = 50;

  HEARTBEAT_SPAN        = 1000;

  STATE_WALKING         = 'Walking';
  STATE_ATTACKING       = 'Attacking';
  STATE_STANDING        = 'Standing';
  STATE_DELETE          = 'DELETETHIS';
  STATE_DEAD            = 'Dead';

  MAP_TRANSITION        = 'MapTransition';

  cmMapTransition       = 50;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGameWorld = class;
  TZEGameActorClass = class of TZEGameActor;
  TZEGameActor = class;
  TZEGameCritterClass = class of TZEGameCritter;
  TZEGameCritter = class;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEDrawType = (dtTerrain, dtFloor, dtDebris, dtDominant, dtActor, dtContainer);
  TZEDrawMode = (dmDraw, dmErase, dmFill);

  TZEGameWorldNotice = (
    gwnCritterLoaded,
    gwnTriggerLoaded,
    gwnPreMapTransition,
    gwnPostMapTransition,
    gwnNothing);

  TZEGameWorldNotifyProc = procedure (Notice: TZEGameWorldNotice;
    Actor: TZEGameActor; cParam: PChar);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGameWorld = class (TZbScriptable)
  private
    FNameOfLoadedMap: PChar;
    FViewMap: TZEViewMap;
    FWorldMap: TZEWorldMap;
    FGamePC: TZEGameCritter;
    FCritters: TList;
    FTriggers: TList;
    FPaused: boolean;
    FNotifyProc: TZEGameWorldNotifyProc;
  protected
    procedure EventHandler (WorldEvent: TZEWorldEvent; pParam1, pParam2: Pointer;
      lParam1, lParam2: integer);
    //
    procedure SelectGameActor (WhichOne: TZEGameCritter);
    function DominantWorldToView (WObj: TZEWorldObject): TZEViewEntity;
    procedure SetPaused (APaused: boolean);
    function GetMapName: string;
    procedure SetMapName (AMapName: string);
    procedure InvokeNotify (Notice: TZEGameWorldNotice; Actor: TZEGameActor; cParam: PChar);
    //
    property ActiveActor: TZEGameCritter read FGamePC write SelectGameActor;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //
    // map creation utitilies
    procedure CreateBlankMap (Width, Height, Levels: integer); overload;
    procedure CreateBlankMap (Width, Height: integer); overload;
    //
    // periodic routines
    procedure PerformUpdate (WTicksElapsed: Cardinal);
    procedure PerformAction (WhereTile: TZEViewTile; bPrimary: boolean = true);
    procedure DoMapTransition (MapTrigger: TZEGameActor);
    //
    // utility routines
    procedure MapLevelUp;
    procedure MapLevelDown;
    procedure DrawOnMap (DrawWhere: TZEWorldTile; DrawType: TZEDrawType;
      DrawMode: TZEDrawMode; SpriteName: string);
    //
    procedure MapSave (AFileName: string);
    procedure MapLoad (AFileName: string);
    //
    procedure CreatePC (ClassOfPC: TZEGameCritterClass; SpriteBaseName: string);
    //
    function CritterCount: integer;
    function CritterAdd (ClassOfCritter: TZEGameCritterClass;
      SpriteBaseName: string; Location: TZEVector): TZEGameCritter;
    function CritterIndexOf (Critter: TZEGameCritter): integer;
    procedure CritterDelete (Critter: TZEGameCritter);
    procedure CritterClear;
    function CritterLookup (AName: string): TZEGameCritter; overload;
    function CritterLookup (Location: TZEVector): TZEGameCritter; overload;
    //
    function TriggerAdd (Location: TZEVector; TriggerName, TriggerTag: string): TZEGameActor;
    procedure TriggerClear (Location: TZEVector);
    procedure TriggersClear;
    //
    property NotifyProc: TZEGameWorldNotifyProc read FNotifyProc write FNotifyProc;
    property Paused: boolean read FPaused write SetPaused;
    property PC: TZEGameCritter read FGamePC;
    property ViewMap: TZEViewMap read FViewMap;
    property WorldMap: TZEWorldMap read FWorldMap;
    property MapName: string read GetMapName write SetMapName;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEActorEvent = (
    aeNothing,
    aeHeartbeat,                  // periodic timer event
    aeArrived,                    // actor have arrived at destination
    aeUseOnTarget,                // object wants to use another object
    aeUsed,                       // was used, or clicked
    //
    aeBeginAttackAnimation,       // will start attack animation
    aeEndAttackAnimation,         // attack animation ends
    //
    aeBeginPerform,               // performance begins
    aeEndPerform,                 // performance ends
    //
    aeRequestMove,                // object wants to move, return true if OK
    aeRequestActionPrimary,       // left-clicked while active, what to do?
    aeRequestActionSecondary,     // ditto, right-clicked this time
    //
    aeEntered,                    // tile was entered, for triggers
    aeSpawned,                    // actor was spawned
    aeDestroyed,                  // actor was destroyed/killed
    aeSighted,                    // PC/enemy sighted
    aeTimer,                      // timer event fired
    aeDamaged,                    // damaged
    aeSelected,                   // actor as selected
    aeDeselected,                 // actor was deselected
    //
    aeRequestFeedback,            // actor itself was clicked!
    aeEndOfList                   // list sentinel
    );

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEActorAction = (
    aaNothing,                    // hmm, nothing?
    aaMove,                       // move to a specific direction
    aaAttack,                     // perform an attack on target
    aaUse,                        // activate something (e.g., a chest?)
    aaPerform,                    // perform current state until end of animation
    aaWait,                       // wait for event
    aaEndOfList                   // just a sentinel for this list
    );

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  PZEActionRecord = ^TZEActionRecord;
  TZEActionRecord = record
    Action: TZEActorAction;
    Target: TZEGameActor;
    Direction: TZEDirection;
    ExtraParam: Pointer;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEActorScriptHandler = function (
    Sender: TZEGameActor;
    Event: TZEActorEvent;
    pParam1, pParam2: Pointer;
    lParam1, lParam2: integer): integer;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGameActor = class (TZbScriptable)
  private
    FName: PChar;                 // name of this actor.  REQUIRED!
    FWorldAvatar: TZEWorldObject; // our representative in the game map
    FTileAt: TZEWorldTile;        // the tile where we are, or used to be
    FViewAvatar: TZEViewEntity;   // displayable entity
    FLocation: TZEVector;
    FFacing: TZEDirection;        // where the critter faces...
    //
    FBaseName: PChar;             // base name for actor
    FState : PChar;               // the actor's condition
    //
    FActiveAction: PZEActionRecord;
    FActionQueue: TZbDoubleList;  // list of actions
    //
    FTag: PChar;                  // for use by the scripter
    FExternalData: Pointer;
    FScriptHandler: TZEActorScriptHandler;
    FHeartbeatTimer: TZE_SimpleTimeTrigger;
  protected
    function GetName: string;
    procedure SetName (AName: string);
    procedure SetWorldAvatar (AAvatar: TZEWorldObject);
    function GetBaseName: string;
    function GetActorState: string;
    procedure SetActorState (AState: string);
    procedure SetFacing (AFacing: TZEDirection);
    //
    procedure AssembleStateName; virtual;
    //
    procedure HandleEvent (AEvent: TZEActorEvent;
      pParam1: Pointer = NIL; pParam2: Pointer = NIL;
      lParam1: integer = 0; lParam2: integer = 0); virtual;
    function IsProcessingAction: boolean;
    function GetTag: string;
    procedure SetTag (ATag: string);
    //
    property ActiveAction: PZEActionRecord read FActiveAction write FActiveAction;
    property IAvatar: TZEWorldObject read FWorldAvatar write SetWorldAvatar;
    property IView: TZEViewEntity read FViewAvatar write FViewAvatar;
    property IActorState: string read GetActorState write SetActorState;
    property ILocation: TZEVector read FLocation write FLocation;
  public
    constructor Create (ABaseName: string); virtual;
    destructor Destroy; override;
    //
    procedure AQ_Clear;
    function AQ_Count: integer;
    function AQ_Peek: PZEActionRecord;
    function AQ_GetNext: PZEActionRecord;
    procedure AQ_InsertFront (NewAction: PZEActionRecord);
    procedure AQ_InsertBack (NewAction: PZEActionRecord);
    procedure AQ_InsertBefore (NewAction, Reference: PZEActionRecord);
    procedure AQ_InsertAfter (NewAction, Reference: PZEActionRecord);
    //
    procedure Update (WTicksElapsed: Cardinal); virtual;
    procedure PerformAction (Location: TZEVector; Target: TZEGameActor; bPrimary: boolean = true); virtual;
    //
    property Name: string read GetName write SetName;
    property BaseName: string read GetBaseName;
    property ActorState: string read GetActorState;
    property Avatar: TZEWorldObject read FWorldAvatar;
    property ViewAvatar: TZEViewEntity read FViewAvatar;
    property TileAt: TZEWorldTile read FTileAt;
    property Facing: TZEDirection read FFacing write SetFacing;
    //
    property ProcessingAction: boolean read IsProcessingAction;
    //
    property Tag: string read GetTag write SetTag;
    property ExternalData: Pointer read FExternalData write FExternalData;
    property ScriptHandler: TZEActorScriptHandler read FScriptHandler write FScriptHandler;
  end;

  TZEGameCritter = class (TZEGameActor)
  private
    FTileTo: TZEWorldTile;
    FBodyModifier: PChar;
    FEquipmentModifier: PChar;
    FActionModifier: PChar;
    //
    FMotionCounter: integer;
    FMotionTimer: TZE_SimpleTimeTrigger;
  protected
    function GetBodyModifier: string;
    procedure SetBodyModifier (ABodyModifier: string);
    function GetEquipmentModifier: string;
    procedure SetEquipmentModifier (AEquipmentModifier: string);
    function GetActionModifier: string;
    procedure SetActionModifier (AActionModifier: string);
    //
    procedure AssembleStateName; override;
    //
    property MotionCounter: integer read FMotionCounter write FMotionCounter;
  public
    constructor Create (ABaseName: string); override;
    destructor Destroy; override;
    //
    procedure Update (WTicksElapsed: Cardinal); override;
    procedure PerformAction (Location: TZEVector; Target: TZEGameActor; bPrimary: boolean = true); override;
    //
    property BodyModifier: string read GetBodyModifier write SetBodyModifier;
    property EquipmentModifier: string read GetEquipmentModifier write SetEquipmentModifier;
    property ActionModifier: string read GetActionModifier write SetActionModifier;
  end;


  (* helper routines *)
  procedure ActionRecordDispose (Action: PZEActionRecord);
  function ActionRecordCreate (AAction: TZEActorAction; ATarget: TZEGameActor;
    ADirection: TZEDirection; pExtraParam: Pointer): PZEActionRecord;

var
  GameWorld: TZEGameWorld = NIL;

implementation

uses
  StrUtils,
  SysUtils,
  JclStrings,
  //
  ZEDXDev,
  ZEDXSprite,
  //
  ZZEGameWindow,
  ZZEGameEngine;

type
  TZEMapSignature = array [1..8] of Char;
  PZEMapHeader = ^TZEMapHeader;
  TZEMapHeader = packed record
     MagicNumber: Cardinal;
     Signature: TZEMapSignature;
     MajorVersion: Integer;
     MinorVersion: Integer;
     Dimensions: TZEVector;
     StartLocation: TZEVector;
  end;

const
  MAP_HEADER_MAGIC_NUMBER           = $12091975;
  MAP_HEADER_SIGNATURE              = 'ZETA@VIJ';
  MAP_HEADER_MAJOR_VERSION          = 0;
  MAP_HEADER_MINOR_VERSION          = 9;

var
  FixedMapHeader: TZEMapHeader = (
    MagicNumber: MAP_HEADER_MAGIC_NUMBER;
    Signature: MAP_HEADER_SIGNATURE;
    MajorVersion: MAP_HEADER_MAJOR_VERSION;
    MinorVersion: MAP_HEADER_MINOR_VERSION;
    );


{ TZEGameWorld }

//////////////////////////////////////////////////////////////////////////
constructor TZEGameWorld.Create;
begin
  inherited Create;
  //
  FViewMap := NIL;
  FWorldMap := NIL;
  FNameOfLoadedMap := NIL;
  //
  FGamePC := NIL;
  FCritters := TList.Create;
  FTriggers := TList.Create;
  FPaused := false;
  //
  WorldEventHandler := EventHandler;
  FNotifyProc := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEGameWorld.Destroy;
begin
  TriggersClear;
  FTriggers.Free;
  CritterClear;
  FCritters.Destroy;
  WorldEventHandler := NIL;
  //
  if (FNameOfLoadedMap <> NIL) then StrDispose (FNameOfLoadedMap);
  if (FViewMap <> NIL) then FViewMap.Free;
  if (FWorldMap <> NIL) then FWorldMap.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.CritterCount: integer;
begin
  Result := FCritters.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.CritterAdd (ClassOfCritter: TZEGameCritterClass;
  SpriteBaseName: string; Location: TZEVector): TZEGameCritter;
var
  Critter: TZEGameCritter;
  WTile: TZEWorldTile;
  WLevel: TZEWorldLevel;
  Dom: TZEWorldObject;
begin
  Result := NIL;
  // if no worldmap, or location occupied by another critter, ignore
  if (WorldMap = NIL) OR (CritterLookup (Location) <> NIL) then Exit;
  //
  // get level and tile, if either is NIL, exit
  WLevel := TZEWorldLevel (WorldMap [Location.Z]);
  if (WLevel = NIL) then Exit;
  WTile := TZEWorldTile (WLevel [Location.X, Location.Y]);
  if (WTile = NIL) then Exit;
  //
  // can't drop on PC location, or on invalid location in map
  if (VectorEquals (Location, WorldMap.StartingLocation)) OR
     (WLevel.MotionMap.Cardinals [Location.X, Location.Y] = 0) then Exit;
  //
  Critter := ClassOfCritter.Create (SpriteBaseName);
  Dom := WTile.SetDominant (SpriteBaseName);
  Dom.SetProperties (SpriteManager.GetProps ('', SpriteBaseName));
  Critter.IAvatar := Dom;
  //
  FCritters.Add (Critter);
  Result := Critter;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.CritterIndexOf (Critter: TZEGameCritter): integer;
begin
  if (Critter <> NIL) then
    for Result := 0 to Pred (FCritters.Count) do
      if (FCritters [Result] = Pointer (Critter)) then Exit;
    //
  //
  Result := -1;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.CritterDelete (Critter: TZEGameCritter);
var
  iPos: integer;
begin
  iPos := CritterIndexof (Critter);
  if (iPos >= 0) then begin
    Critter.Free;
    FCritters [iPos] := NIL;
    FCritters.Pack;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.CritterClear;
var
  iPos: integer;
  Critter: TZEGameCritter;
begin
  for iPos := 0 to Pred (FCritters.Count) do begin
    Critter := TZEGameCritter (FCritters [iPos]);
    if (Critter = NIL) then continue;
    Critter.Free;
    FCritters [iPos] := NIL;
  end;
  //
  FCritters.Pack;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.CritterLookup (AName: string): TZEGameCritter;
var
  iPos: integer;
  Critter: TZEGameCritter;
begin
  Result := NIL;
  for iPos := 0 to Pred (FCritters.Count) do begin
    Critter := TZEGameCritter (FCritters [iPos]);
    if (Critter = NIL) then continue;
    if (Critter.Name = AName) then begin
      Result := Critter;
      Break;
    end;
  end;
  //
end;


//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.TriggerAdd (Location: TZEVector; TriggerName, TriggerTag: string): TZEGameActor;
var
  WTile: TZEWorldTile;
  WLevel: TZEWorldLevel;
  Trigger: TZEGameActor;
  VTile: TZEViewTile;
begin
  Result := NIL;
  // no worldmap, no dice
  if (WorldMap = NIL) then Exit;
  //
  // get level and tile, if either is NIL, exit
  WLevel := TZEWorldLevel (WorldMap [Location.Z]);
  if (WLevel = NIL) then Exit;
  WTile := TZEWorldTile (WLevel [Location.X, Location.Y]);
  if (WTile = NIL) then Exit;
  //
  if (WTile.Special = NIL) then begin
    Trigger := TZEGameActor.Create ('');
    Trigger.FLocation := Location;
    WTile.Special := Trigger;
  end else
    Trigger := TZEGameActor (WTile.Special);
  //
  Trigger.Name := TriggerName;
  Trigger.Tag := TriggerTag;
  //
  if (ViewInEditMode) then begin
    with Location do VTile := TZEViewTile (ViewMap [Z] [X, Y]);
    if (VTile <> NIL) then VTile.SpecialSprite :=
      SpriteManager.CreateSprite ('Selector', 'MapTransition');
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.TriggerClear (Location: TZEVector);
var
  WTile: TZEWorldTile;
  WLevel: TZEWorldLevel;
  Trigger: TZEGameActor;
  VTile: TZEViewTile;
begin
  // no worldmap, no dice
  if (WorldMap = NIL) then Exit;
  //
  // get level and tile, if either is NIL, exit
  WLevel := TZEWorldLevel (WorldMap [Location.Z]);
  if (WLevel = NIL) then Exit;
  WTile := TZEWorldTile (WLevel [Location.X, Location.Y]);
  if (WTile = NIL) OR (WTile.Special = NIL) then Exit;
  //
  Trigger := TZEGameActor (WTile.Special);
  Trigger.Free;
  WTile.Special := NIL;
  //
  if (ViewInEditMode) then begin
    with Location do VTile := TZEViewTile (ViewMap [Z] [X, Y]);
    if (VTile <> NIL) then VTile.SpecialSprite := NIL;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.TriggersClear;
var
  iIndex: integer;
  Trigger: TZEGameActor;
begin
  for iIndex := 0 to Pred (FTriggers.Count) do begin
    Trigger := TZEGameActor (FTriggers [iIndex]);
    if (Trigger  <> NIL) then begin
      TriggerClear (Trigger.FLocation);
      FTriggers [iIndex] := NIL;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.CritterLookup (Location: TZEVector): TZEGameCritter;
var
  iPos: integer;
  Critter: TZEGameCritter;
begin
  Result := NIL;
  for iPos := 0 to Pred (FCritters.Count) do begin
    Critter := TZEGameCritter (FCritters [iPos]);
    if (Critter = NIL) then continue;
    if (VectorEquals (Critter.ILocation, Location)) then begin
      Result := Critter;
      Break;
    end;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.EventHandler (WorldEvent: TZEWorldEvent;
  pParam1, pParam2: Pointer; lParam1, lParam2: integer);
var
  VTerrain: TZEViewTerrain;
  VTile: TZEViewTile;
  //
  WObject: TZEWorldObject;
  WTerrain: TZEWorldTerrain;
  WTile: TZEWorldTile;
  iIndex: integer;
begin
  case WorldEvent of
    //////// terrain has changed
    // IN: pParam1: WorldTile, pParam2: WorldTerrain
    wevTerrainChanged:
      begin
        WTile := TZEWorldTile (pParam1);
        WTerrain := TZEWorldTerrain (pParam2);
        //
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTerrain := VTile.Terrain;
          VTerrain.Sprite := SpriteManager.CreateSprite ('', WTerrain.ObjectID);
          //
          if (VTerrain.Sprite <> NIL) then
            begin
              VTerrain.ClearTransitions;
              for iIndex := 0 to Pred (WTerrain.TransitionNames.Count) do
                VTerrain.AddTransition (SpriteManager.CreateSprite ('', WTerrain.TransitionNames [iIndex]));
              //
            end;
          //
        except
        end;
      end;
    //////// transitions changed
    // IN: pParam1: WorldTile, pParam2: WorldTerrain, lParam1: TStrings (Transitions)
    wevTransitionsChanged:
      begin
        WTile := TZEWorldTile (pParam1);
        WTerrain := TZEWorldTerrain (pParam2);
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTerrain := VTile.Terrain;
          VTerrain.ClearTransitions;
          for iIndex := 0 to Pred (WTerrain.TransitionNames.Count) do
             VTerrain.AddTransition (SpriteManager.CreateSprite ('', WTerrain.TransitionNames [iIndex]));
          //
        except
        end;
      end;
    //////// transitions cleared
    // IN: pParam1: WorldTile, pParam2: WorldTerrain
    wevTransitionsCleared:
      begin
        WTile := TZEWorldTile (pParam1);
        if (WTile <> NIL) then
          begin
            VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
            if (VTile <> NIL) then VTile.Terrain.ClearTransitions;;
          end;
        //
      end;
    //////// floor has changed
    // IN: pParam1: WorldTile, pParam2: WorldObject
    wevFloorChanged:
      begin
        WTile := TZEWorldTile (pParam1);
        WObject := TZEWorldObject (pParam2);
        //
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTile.Floor.Sprite := SpriteManager.CreateSprite ('', WObject.ObjectID);
        except
        end;
      end;
    //////// floor was cleared
    // IN: pParam1: WorldTile
    wevFloorCleared:
      begin
        WTile := TZEWorldTile (pParam1);
        //
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTile.Floor.Sprite := NIL;
        except
        end;
      end;
    //////////////////
    // IN: pParam1: WorldTile, pParam2: WorldObject
    wevDominantChanged:
      begin
        WTile := TZEWorldTile (pParam1);
        WObject := TZEWorldObject (pParam2);
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTile.Dominant.Sprite := SpriteManager.CreateSprite ('', WObject.ObjectID);
        except
        end;
      end;
    //////// no more dominant
    // IN: pParam1: WorldTile
    wevDominantCleared:
      begin
        WTile := TZEWorldTile (pParam1);
        //
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTile.Dominant.Sprite := NIL;
        except
        end;
      end;
    //////// floor has changed
    // IN: pParam1: WorldTile, pParam2: WorldObject
    wevDebrisAdded:
      begin
        WTile := TZEWorldTile (pParam1);
        WObject := TZEWorldObject (pParam2);
        //
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTile.Add (SpriteManager.CreateSprite ('', WObject.ObjectID));
        except
        end;
      end;
    //////////////////
    wevDebrisCleared:
      begin
      end;
    //////////////////
    // IN: pParam1: WorldTile
    wevTileCleared:
      begin
        WTile := TZEWorldTile (pParam1);
        //
        try
          VTile := TZEViewTile (ViewMap [WTile.Owner.LevelIndex] [WTile.X, WTile.Y]);
          VTile.Clear;
        except
        end;
      end;
    //////////////////
    wevNewMapLevel:
      begin
        if (ViewMap <> NIL) then ViewMap.NewLevel;
      end;
    //////////////////
    wevStartingLocationReplaced:
      if (ViewInEditMode) then begin
        with PZEVector (pParam2)^ do
          if (X >= 0) AND (Y >= 0) AND (Z >= 0) then begin
            VTile := TZEViewTile (ViewMap [Z] [X, Y]);
            if (VTile <> NIL) then VTile.SpecialSprite := NIL;
          end;
        //
        with PZEVector (pParam1)^ do
          if (X >= 0) AND (Y >= 0) AND (Z >= 0) then begin
            VTile := TZEViewTile (ViewMap [Z] [X, Y]);
            if (VTile <> NIL) then VTile.SpecialSprite :=
              SpriteManager.CreateSprite ('Selector', 'StartMarker');
          end;
        //
      end;
    //////////////////
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.CreateBlankMap (Width, Height, Levels: integer);
begin
  CritterClear;
  //
  if (FGamePC <> NIL) then begin
    FGamePC.Destroy;
    FGamePC := NIL;
  end;
  //
  if (FWorldMap <> NIL) then begin
    FWorldMap.Destroy;
    FWorldMap := NIL;
  end;
  //
  if (FViewMap <> NIL) then begin
    FViewMap.Destroy;
    FViewMap := NIL;
  end;
  //
  FViewMap := TZEViewMap.Create (Width, Height);
  FWorldMap := TZEWorldMap.Create (Width, Height);
  //
  while (Levels > 0) do begin
      FWorldMap.NewLevel;
      Dec (Levels);
    end;
  //
  //if (GameWindow <> NIL) then GameWindow.ViewMap := ViewMap;
  ViewMap.GridSprite := SpriteManager.CreateSprite ('Selector', 'EditGrid');
  ViewMap.HighlightSprite := SpriteManager.CreateSprite ('Selector', 'Normal');
  ViewMap.SelectionSprite := SpriteManager.CreateSprite ('Selector', 'Selector');
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.CreateBlankMap (Width, Height: integer);
begin
  CreateBlankMap (Width, Height, 1);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.SelectGameActor (WhichOne: TZEGameCritter);
begin
  if (FGamePC = WhichOne) then Exit;
  if (FGamePC <> NIL) then FGamePC.HandleEvent (aeDeselected);
  FGamePC := WhichOne;
  if (FGamePC <> NIL) then FGamePC.HandleEvent (aeSelected);
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.DominantWorldToView (WObj: TZEWorldObject): TZEViewEntity;
begin
  Result := NIL;
  if (WObj = NIL) OR (WObj.Tile = NIL) then Exit;
  //
  with WObj do
    Result := TZEViewTile (ViewMap [Tile.Owner.LevelIndex] [Tile.X, Tile.Y]).Dominant;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.SetPaused (APaused: boolean);
begin
  if (FPaused <> APaused) then begin
    FPaused := APaused;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameWorld.GetMapName: string;
begin
  Result := IfThen (FNameOfLoadedMap = NIL, '', string (FNameOfLoadedMap));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.SetMapName (AMapName: string);
begin
  if (FNameOfLoadedMap <> NIL) then StrDispose (FNameOfLoadedMap);
  if (AMapName <> '') then
     FNameOfLoadedMap := StrNew (PChar (AMapName))
     else FNameOfLoadedMap := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.InvokeNotify (Notice: TZEGameWorldNotice; Actor: TZEGameActor; cParam: PChar);
begin
  if (Assigned (NotifyProc)) then NotifyProc (Notice, Actor, cParam);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.PerformUpdate (WTicksElapsed: Cardinal);
var
  iIndex: integer;
  Critter: TZEGameCritter;
begin
  // do not update if we're paused...
  if (Paused) then Exit;
  // udpate the PC, if present
  if (FGamePC <> NIL) then FGamePC.Update (WTicksElapsed);
  //
  // update everyone else
  for iIndex := 0 to Pred (FCritters.Count) do begin
    Critter := TZEGameCritter (FCritters [iIndex]);
    if (Critter <> NIL) then Critter.Update (WTicksElapsed);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.PerformAction (WhereTile: TZEViewTile; bPrimary: boolean);
var
  WTile: TZEWorldTile;
  WDom: TZEWorldObject;
  Actor: TZEGameActor;
begin
  if (WhereTile = NIL) then exit;
  //
  WTile := TZEWorldTile (WorldMap [WhereTile.Owner.LevelIndex] [WhereTile.X, WhereTile.Y]);
  if (WTile = NIL) then Exit;
  //
  WDom := TZEWorldObject (WTile.Dominant);
  if ((WDom <> NIL) AND (WDom.ExternalPointer <> NIL)) then
    Actor := TZEGameActor (WDom.ExternalPointer)
    else Actor := NIL;
  //
  with WhereTile do
    FGamePC.PerformAction (Vector (X, Y, Owner.LevelIndex), Actor, bPrimary);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DoMapTransition (MapTrigger: TZEGameActor);
var
  DropMapName: string;
  DropMapLoc: TZEVector;
  cBuffer: string;
begin
  DropMapName := StrBefore ('[', MapTrigger.Tag);
  cBuffer := StrAfter ('[', MapTrigger.Tag);
  with DropMapLoc do begin
    X := StrToIntSafe (StrBefore (',', cBuffer));
    cBuffer := StrAfter (',', cBuffer);
    Y := StrToIntSafe (StrBefore (',', cBuffer));
    Z := StrToIntSafe (StrAfter (',', cBuffer));
    //
    if (X < 0) OR (Y < 0) OR (Z < 0) then Exit;
  end;
  //
  //
  InvokeNotify (gwnPreMapTransition, NIL, NIL);
  //
  MapLoad (DropMapName);
  WorldMap.StartingLocation := DropMapLoc;
  //
  InvokeNotify (gwnPostMapTransition, NIL, NIL);
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.MapLevelUp;
begin
  if ((ViewMap <> NIL) AND (ViewMap.Count > 1) AND
    (ViewMap.ActiveLevel < Pred (ViewMap.Count))) then
      ViewMap.ActiveLevel := ViewMap.ActiveLevel + 1;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.MapLevelDown;
begin
  if ((ViewMap <> NIL) AND (ViewMap.Count > 1) AND (ViewMap.ActiveLevel > 0)) then
    ViewMap.ActiveLevel := ViewMap.ActiveLevel - 1;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.DrawOnMap (DrawWhere: TZEWorldTile; DrawType: TZEDrawType;
  DrawMode: TZEDrawMode; SpriteName: string);
var
  WTerrain: TZEWorldTerrain;
  WObject: TZEWorldObject;
  WLevel: TZEWorldLevel;
  X, Y: integer;
begin
  // exit immediate if there is no target to draw to
  if (DrawWhere = NIL) then Exit;
  //
  case DrawType of
    //
    dtTerrain: begin
      if (DrawMode = dmDraw) then begin
        //
        WTerrain := TZEWorldTerrain (DrawWhere.SetTerrain (SpriteName));
        if (WTerrain <> NIL) then begin
          WTerrain.SetProperties (SpriteManager.GetProps ('', SpriteName));
          WTerrain.GenerateTransitions (true);
        end;
        //
      end else if (DrawMode = dmErase) then begin
        //
        DrawWhere.SetTerrain ('');
        //
      end else if (DrawMode = dmFill) then begin
        //
        WLevel := TZEWorldLevel (WorldMap [DrawWhere.Owner.LevelIndex]);
        if (WLevel = NIL) then Exit;
        //
        for X := 0 to Pred (WLevel.Width) do
          for Y := 0 to Pred (WLevel.Height) do begin
            DrawWhere := TZEWorldTile (WLevel [X, Y]);
            WTerrain := TZEWorldTerrain (DrawWhere.SetTerrain (SpriteName));
            if (WTerrain <> NIL) then begin
              WTerrain.SetProperties (SpriteManager.GetProps ('', SpriteName));
              WTerrain.ClearTransitions;
            end;
          end;
        //
      end;
    end;
    //
    dtFloor: begin
      if (DrawMode = dmDraw) then begin
        WObject := DrawWhere.SetFloor (SpriteName);
        if (WObject <> NIL) then WObject.SetProperties (SpriteManager.GetProps ('', SpriteName));
      end else if (DrawMode = dmErase) then
        DrawWhere.SetFloor ('');
      //
    end;
    //
    dtDebris: begin
      if (DrawMode = dmDraw) then begin
        WObject := DrawWhere.AddDebris (SpriteName);
        if (WObject <> NIL) then WObject.SetProperties (SpriteManager.GetProps ('', SpriteName));
      end;
    end;
    //
    dtDominant: begin
      if (DrawMode = dmDraw) then begin
        WObject := DrawWhere.SetDominant (SpriteName);
        if (WObject <> NIL) then WObject.SetProperties (SpriteManager.GetProps ('', SpriteName));
      end else if (DrawMode = dmErase) then
        DrawWhere.SetDominant ('');
    end;
    //
  end
end;

const
  CONST_MARKER_FOR_VALID_ITEMS    = $08171975;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.MapSave (AFileName: string);
var
  Writer: IZbFileWriter;
  X, Y, Z: integer;
  Level: TZEWorldLevel;
  Tile: TZEWorldTile;
  //
  listObjectID: TStrings;
  WObj: TZEWorldObject;
  wcIndex: TZEWorldWallCode;
  iIndex: integer;
  //
  Critter: TZEGameCritter;
  TriggerList: TList;
  Trigger: TZEGameActor;

  procedure SelectiveAdd (AObjectID: String);
  begin
    if (AObjectID <> '') AND (listObjectID.IndexOf (AObjectID) < 0) then
      listObjectID.Add (AObjectID);
  end;

begin
  // create a writer, bug out if it can't be done...
  Writer := GameEngine.Files.CreateWriter (AFileName);
  if (Writer = NIL) then Exit;
  //
  // this writes out the header
  FixedMapHeader.Dimensions := Vector (WorldMap.Width, WorldMap.Height, WorldMap.Count);
  FixedMapHeader.StartLocation := WorldMap.StartingLocation;
  Writer.WriteBuffer (@FixedMapHeader, SizeOf (FixedMapHeader));
  //
  // pre-scan the map and generate the list of all unique object IDs
  listObjectID := TStringList.Create;
  for Z := 0 to Pred (WorldMap.Count) do begin
    Level := TZEWorldLevel (WorldMap [Z]);
    for X := 0 to Pred (WorldMap.Width) do begin
      for Y := 0 to Pred (WorldMap.Height) do begin
        //
        Tile := TZEWorldTile (Level [X, Y]);
        if (Tile = NIL) OR (Tile.Terrain = NIL) then continue;
        //
        with Tile do begin
          //
          SelectiveAdd (Terrain.ObjectID);
          if (Floor <> NIL) then SelectiveAdd (Floor.ObjectID);
          //
          if (Dominant <> NIL) AND (Dominant.ExternalPointer = NIL) then
            SelectiveAdd (Dominant.ObjectID);
          //
          for wcIndex := wcNorth to wcWest do
            if (Walls [wcIndex] <> NIL) then SelectiveAdd (Walls [wcIndex].ObjectID);
          //
          for iIndex := 0 to Pred (Count) do begin
            WObj := TZEWorldObject (Data [iIndex]);
            if (WObj = NIL) then continue;
            SelectiveAdd (WObj.ObjectID);
          end;
          //
        end;
      end;
    end;
  end;
  //
  // write out this list...
  Writer.WriteInteger (listObjectID.Count);
  for iIndex := 0 to Pred (listObjectID.Count) do
    Writer.WriteStr (listObjectID [iIndex]);

  //
  // this writes out the map data, EXCEPT FOR DOMINANTS LINKED WITH ACTORS!
  for Z := 0 to Pred (WorldMap.Count) do begin
    Level := TZEWorldLevel (WorldMap [Z]);
    for X := 0 to Pred (WorldMap.Width) do begin
      for Y := 0 to Pred (WorldMap.Height) do begin
        //
        Tile := TZEWorldTile (Level [X, Y]);
        if (Tile = NIL) OR (Tile.Terrain = NIL) then begin
          Writer.WriteInteger (-1);
          continue;
        end else with Tile do begin
          Writer.WriteInteger (listObjectID.IndexOf (Terrain.ObjectID));
          //
          if (Floor <> NIL) then
            Writer.WriteInteger (listObjectID.IndexOf (Floor.ObjectID))
            else Writer.WriteInteger (-1);
          //
          if (Dominant <> NIL) AND (Dominant.ExternalPointer = NIL) then
            Writer.WriteInteger (listObjectID.IndexOf (Dominant.ObjectID))
            else Writer.WriteInteger (-1);
          //
          for wcIndex := wcNorth to wcWest do
            if (Walls [wcIndex] <> NIL) then
              Writer.WriteInteger (listObjectID.IndexOf (Walls [wcIndex].ObjectID))
              else Writer.WriteInteger (-1);
          //
          Writer.WriteInteger (Count);
          for iIndex := 0 to Pred (Count) do begin
            WObj := TZEWorldObject (Data [iIndex]);
            if (WObj <> NIL) then
              Writer.WriteInteger (listObjectID.IndexOf (WObj.ObjectID))
              else Writer.WriteInteger (-1);
          end;
          //
        end;
        //
      end;
    end;
  end;

  //
  // and now, the moment we've been waiting for... the Actors!!!
  //
  Writer.WriteInteger (FCritters.Count);
  for iIndex := 0 to Pred (FCritters.Count) do begin
    Critter := TZEGameCritter (FCritters [iIndex]);
    if (Critter = NIL) then continue;
    //
    with Critter do begin
      Writer.WriteStr (BaseName);
      Writer.WriteInteger (ILocation.X);
      Writer.WriteInteger (ILocation.Y);
      Writer.WriteInteger (ILocation.Z);
      //
      Writer.WriteStr (Tag);
      Writer.WriteStr (Name);
      //
      Writer.WriteStr (BodyModifier);
      Writer.WriteStr (EquipmentModifier);
      Writer.WriteStr (ActionModifier);
      Writer.WriteInteger (Ord (Facing));
    end;
    //
  end;

  //
  // save the triggers, save the triggers, save the triggers
  TriggerList := TList.Create;
  for Z := 0 to Pred (WorldMap.Count) do begin
    Level := TZEWorldLevel (WorldMap [Z]);
    for X := 0 to Pred (WorldMap.Width) do begin
      for Y := 0 to Pred (WorldMap.Height) do begin
        //
        Tile := TZEWorldTile (Level [X, Y]);
        if (Tile = NIL) OR (Tile.Special = NIL) then continue;
        TriggerList.Add (Tile.Special);
      end;
    end;
  end;
  //
  Writer.WriteInteger (TriggerList.Count);
  for iIndex := 0 to Pred (TriggerList.Count) do begin
    Trigger := TZEGameActor (TriggerList [iIndex]);
    with Trigger do begin
      Writer.WriteStr (Tag);
      Writer.WriteInteger (ILocation.X);
      Writer.WriteInteger (ILocation.Y);
      Writer.WriteInteger (ILocation.Z);
    end;
  end;
  //
  TriggerList.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.MapLoad (AFileName: string);
var
  Reader: IZbFileReader;
  pHeader: PZEMapHeader;
  X, Y, Z: integer;
  Level: TZEWorldLevel;
  Tile: TZEWorldTile;
  //
  iCount: integer;
  listObjectID: TStrings;
  wcIndex: TZEWorldWallCode;
  iIndex: integer;
  iNameKey: integer;
  //
  Critter: TZEGameCritter;
  Loc: TZEVector;
  cBaseName: string;

  function GetIDName (iNameIndex: integer): string;
  begin
    if (iNameIndex >= 0) AND (iNameIndex < listObjectID.Count) then
      Result := listObjectID [iNameIndex]
      else Result := '';
  end;

begin
  //
  // if the file doesn't exist, don't load it
  if (NOT FileExists (AFileName)) then Exit;
  //
  // create a reader, bug out if it can't be done...
  Reader := GameEngine.Files.CreateReader (AFileName);
  if (Reader = NIL) then Exit;
  //
  // read the header information
  pHeader := Reader.ReadBuffer (SizeOf (TZEMapHeader));
  if (pHeader = NIL) then Exit;
  //
  // check if we know this header, ignore the load if it isn't familiar...
  if (pHeader.MagicNumber <> FixedMapHeader.MagicNumber) OR
     (pHeader.Signature <> FixedMapHeader.Signature) OR
     (pHeader.MajorVersion <> FixedMapHeader.MajorVersion) OR
     (pHeader.MinorVersion <> FixedMapHeader.MinorVersion) then Exit;
  //
  // create a blank slate to load the  map onto
  CreateBlankMap (pHeader.Dimensions.X, pHeader.Dimensions.Y, pHeader.Dimensions.Z);
  GameWorld.MapName := AFileName;
  //
  // read the names list
  listObjectID := TStringList.Create;
  iCount := Reader.ReadInteger;
  for iIndex := 0 to Pred (iCount) do listObjectID.Add (Reader.ReadStr);
  //
  // this writes out the map data, EXCEPT FOR DOMINANTS LINKED WITH ACTORS!
  for Z := 0 to Pred (WorldMap.Count) do begin
    Level := TZEWorldLevel (WorldMap [Z]);
    for X := 0 to Pred (WorldMap.Width) do begin
      for Y := 0 to Pred (WorldMap.Height) do begin
        //
        Tile := TZEWorldTile (Level [X, Y]);
        //
        // attempt to read ID of terrain, if it ain't there, process next one
        iNameKey := Reader.ReadInteger;
        if (iNameKey < 0) then continue;
        //
        DrawOnMap (Tile, dtTerrain, dmDraw, GetIDName (iNameKey));
        DrawOnMap (Tile, dtFloor, dmDraw, GetIDName (Reader.ReadInteger));
        DrawOnMap (Tile, dtDominant, dmDraw, GetIDName (Reader.ReadInteger));
        //
        for wcIndex := wcNorth to wcWest do
          Tile.SetWalls (wcIndex, GetIDName (Reader.ReadInteger));
        //
        iCount := Reader.ReadInteger;
        for iIndex := 0 to Pred (iCount) do
          DrawOnMap (Tile, dtDebris, dmDraw, GetIDName (Reader.ReadInteger));
        //
      end;
    end;
  end;
  //
  // generate the transitions for the terrain loaded
  for Z := 0 to Pred (WorldMap.Count) do begin
    Level := TZEWorldLevel (WorldMap [Z]);
    for X := 0 to Pred (WorldMap.Width) do begin
      for Y := 0 to Pred (WorldMap.Height) do begin
        //
        Tile := TZEWorldTile (Level [X, Y]);
        if (Tile <> NIL) AND (Tile.Terrain <> NIL) then
          Tile.Terrain.GenerateTransitions (false);
      end
    end;
  end;
  //
  // Actors being loaded, stand by...
  //
  iCount := Reader.ReadInteger;
  for iIndex := 0 to Pred (iCount) do begin
    cBaseName := Reader.ReadStr;
    Loc.X := Reader.ReadInteger;
    Loc.Y := Reader.ReadInteger;
    Loc.Z := Reader.ReadInteger;
    //
    Critter := GameWorld.CritterAdd (TZEGameCritter, cBaseName, Loc);
    //
    with Critter do begin
      Tag := Reader.ReadStr;
      Name := Reader.ReadStr;
      //
      BodyModifier := Reader.ReadStr;
      EquipmentModifier := Reader.ReadStr;
      ActionModifier := Reader.ReadStr;
      Facing := TZEDirection (Reader.ReadInteger);
    end;
    //
  end;
  //
  if (FCritters.Count > 0) AND (Assigned (NotifyProc)) then
    for iIndex := 0 to Pred (FCritters.Count) do
      InvokeNotify (gwnCritterLoaded, FCritters [iIndex], NIL);
  //
  // load the triggers, load the triggers, load the triggers
  iCount := Reader.ReadInteger;
  for iIndex := 0 to Pred (iCount) do begin
    cBaseName := Reader.ReadStr;
    Loc.X := Reader.ReadInteger;
    Loc.Y := Reader.ReadInteger;
    Loc.Z := Reader.ReadInteger;
    TriggerAdd (Loc, MAP_TRANSITION, cBaseName);
  end;
  //
  // reload/reset the starting location
  WorldMap.StartingLocation := pHeader.StartLocation;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWorld.CreatePC (ClassOfPC: TZEGameCritterClass; SpriteBaseName: string);
var
  DropVector: TZEVector;
  Tile: TZEWorldTile;
  Dom: TZEWorldObject;
begin
  // get our starting vector
  if (FGamePC <> NIL) then
    DropVector := Vector (FGamePC.TileAt.X, FGamePC.TileAt.Y, FGamePC.TileAt.Owner.LevelIndex)
    else DropVector := WorldMap.StartingLocation;
  // validate the vector of course, and get rid of the current PC
  if (DropVector.X < 0) OR (DropVector.Y < 0) OR (DropVector.Z < 0) then Exit;
  if (FGamePC <> NIL) then begin
    FGamePC.Destroy;
    FGamePC := NIL;
  end;
  //
  // get reference to the tile. if it's invalid, or someone's already there,
  // we can't drop the PC there so...
  Tile := TZEWorldTile (WorldMap [DropVector.Z][DropVector.X, DropVector.Y]);
  if (Tile = NIL) OR (Tile.Dominant <> NIL) then Exit;
  // check if location is useable terrain!
  if (TZEWorldLevel (Tile.Owner).MotionMap.Cardinals [DropVector.X, DropVector.Y] = 0) then Exit;
  //
  FGamePC := ClassOfPC.Create (SpriteBaseName);
  Dom := Tile.SetDominant (SpriteBaseName);
  Dom.SetProperties (SpriteManager.GetProps ('', SpriteBaseName));
  FGamePC.IAvatar := Dom;
end;


{ Action Record Helpers }

//////////////////////////////////////////////////////////////////////////
procedure ActionRecordDispose (Action: PZEActionRecord);
begin
  if (Action = NIL) then Exit;
  Dispose (Action);
end;

//////////////////////////////////////////////////////////////////////////
function ActionRecordCreate (AAction: TZEActorAction; ATarget: TZEGameActor;
  ADirection: TZEDirection; pExtraParam: Pointer): PZEActionRecord;
begin
  New (Result);
  if (Result <> NIL) then
    with Result^ do begin
      Action := AAction;
      Target := ATarget;
      Direction := ADirection;
      ExtraParam := pExtraParam;
    end;
  //
end;


{ TZEGameActor }

//////////////////////////////////////////////////////////////////////////
constructor TZEGameActor.Create (ABaseName: string);
begin
  inherited Create;
  //
  FWorldAvatar := NIL;
  FTileAt := NIL;
  FFacing := tdUnknown;
  FLocation := Vector (-1, -1, -1);
  //
  FBaseName := StrNew (PChar (ABaseName));
  FState := NIL;
  //
  FActionQueue := TZbDoubleList.Create (false);
  FScriptHandler := NIL;
  //
  FTag := NIL;
  FExternalData := NIL;
  FHeartbeatTimer := TZE_SimpleTimeTrigger.Create (HEARTBEAT_SPAN);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEGameActor.Destroy;
begin
  FreeAndNIL (FHeartbeatTimer);
  FreeAndNIL (FActionQueue);
  IAvatar := NIL;
  if (FBaseName <> NIL) then StrDispose (FBaseName);
  if (FState <> NIL) then StrDispose (FState);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.GetName: string;
begin
  Result := IfThen (FName = NIL, '', string (FName));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.SetName (AName: string);
begin
  if (FName <> NIL) then StrDispose (FName);
  if (AName <> '') then
    FName := StrNew (PChar (AName))
    else FName := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.SetWorldAvatar (AAvatar: TZEWorldObject);
begin
  // if the avatar to set is already ours, no need to do anything
  if (FWorldAvatar = AAvatar) then Exit;
  //
  // if we already have an avatar, get rid of it first
  if (FWorldAvatar <> NIL) then begin
    FWorldAvatar.ExternalPointer := NIL;
    FTileAt.SetDominant ('');
  end;
  //
  // set this avatar to ours
  FWorldAvatar := AAvatar;
  //
  // if avatar is valid, get the tile and the view equivalent
  if (FWorldAvatar <> NIL) then begin
    FWorldAvatar.ExternalPointer := Self;
    FTileAt := TZEWorldTile (FWorldAvatar.Tile);
    FViewAvatar := GameWorld.DominantWorldToView (FWorldAvatar);
    ILocation := Vector (FTileAt.X, FTileAt.Y, FTileAt.Owner.LevelIndex);
  end else begin
    FTileAt := NIL;
    FViewAvatar := NIL;
    ILocation := Vector (-1, -1, -1);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.GetBaseName: string;
begin
  Result := IfThen (FBaseName = NIL, '', string (FBaseName));
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.GetActorState: string;
begin
  Result := IfThen (FState = NIL, '', string (FState));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.SetActorState (AState: string);
begin
  if (FState <> NIL) then StrDispose (FState);
  if (AState <> '') then
    FState := StrNew (PChar (AState))
    else FState := NIL;
  //
  // update the avatar
  if (FWorldAvatar <> NIL) then
    FTileAt.SetDominant (string (FState));
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.SetFacing (AFacing: TZEDirection);
begin
  if (AFacing = FFacing) then Exit;
  FFacing := AFacing;
  AssembleStateName;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.AssembleStateName;
begin
  if (FBaseName = NIL) then Exit;
  if (Facing <> tdUnknown) then
    IActorState := BaseName + STATE_DELIMITER + __DirName [Facing]
    else IActorState := BaseName;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.AQ_Clear;
begin
  FActionQueue.Clear;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.AQ_Count: integer;
begin
  Result := FActionQueue.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.AQ_Peek: PZEActionRecord;
begin
  if (FActionQueue.Count > 0) then
    Result := PZEActionRecord (FActionQueue.Get (0))
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.AQ_GetNext: PZEActionRecord;
begin
  if (FActionQueue.Count > 0) then begin
    Result := PZEActionRecord (FActionQueue.Get (0));
    FActionQueue.Delete (0);
  end
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.AQ_InsertFront (NewAction: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.AQ_InsertBack (NewAction: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, -1);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.AQ_InsertBefore (NewAction, Reference: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, FActionQueue.IndexOf (Reference));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.AQ_InsertAfter (NewAction, Reference: PZEActionRecord);
begin
  FActionQueue.Add ('', NewAction, Succ (FActionQueue.IndexOf (Reference)));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.Update (WTicksElapsed: Cardinal);
begin
  //
  // this just handles the distribution of the heartbeat event
  if (FHeartbeatTimer.CheckResetTrigger (WTicksElapsed)) then begin
    if (Assigned (ScriptHandler)) then ScriptHandler (Self, aeHeartbeat, NIL, NIL, 0, 0);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.PerformAction (Location: TZEVector; Target: TZEGameActor;
  bPrimary: boolean);
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.HandleEvent (AEvent: TZEActorEvent;
  pParam1, pParam2: Pointer; lParam1, lParam2: integer);
begin
  if (Assigned (ScriptHandler)) then
    ScriptHandler (Self, AEvent, pParam1, pParam2, lParam1, lParam2)
    else begin
      //
      // provide default handling maybe?
      //
    end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.IsProcessingAction: boolean;
begin
  Result := (ActiveAction <> NIL);
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameActor.GetTag: string;
begin
  Result := IfThen (FTag = NIL, '', string (FTag));
end;
//////////////////////////////////////////////////////////////////////////
procedure TZEGameActor.SetTag (ATag: string);
begin
  if (FTag <> NIL) then StrDispose (FTag);
  if (ATag <> '') then
    FTag := StrNew (PChar (ATag))
    else FTag := NIL;
end;


{ TZEGameCritter }

//////////////////////////////////////////////////////////////////////////
constructor TZEGameCritter.Create (ABaseName: string);
begin
  inherited;
  FTileTo := NIL;
  FBodyModifier := NIL;
  FEquipmentModifier := NIL;
  FActionModifier := NIL;
  Facing := tdSouthEast;
  //
  FMotionCounter := 0;
  FMotionTimer := TZE_SimpleTimeTrigger.Create (0);
  //
  ActionModifier := STATE_STANDING;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEGameCritter.Destroy;
begin
  FMotionTimer.Free;
  BodyModifier := '';
  EquipmentModifier := '';
  ActionModifier := '';
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameCritter.GetBodyModifier: string;
begin
  Result := IfThen (FBodyModifier = NIL, '', string (FBodyModifier));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameCritter.SetBodyModifier (ABodyModifier: string);
begin
  if (FBodyModifier <> NIL) then StrDispose (FBodyModifier);
  if (ABodyModifier <> '') then
    FBodyModifier := StrNew (PChar (ABodyModifier))
    else FBodyModifier := NIL;
  //
  AssembleStateName;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameCritter.GetEquipmentModifier: string;
begin
  Result := IfThen (FEquipmentModifier = NIL, '', string (FEquipmentModifier));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameCritter.SetEquipmentModifier (AEquipmentModifier: string);
begin
  if (FEquipmentModifier <> NIL) then StrDispose (FEquipmentModifier);
  if (AEquipmentModifier <> '') then
    FEquipmentModifier := StrNew (PChar (AEquipmentModifier))
    else FEquipmentModifier := NIL;
  //
  AssembleStateName;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGameCritter.GetActionModifier: string;
begin
  Result := IfThen (FActionModifier = NIL, '', string (FActionModifier));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameCritter.SetActionModifier (AActionModifier: string);
begin
  if (FActionModifier <> NIL) then StrDispose (FActionModifier);
  if (AActionModifier <> '') then
    FActionModifier := StrNew (PChar (AActionModifier))
    else FActionModifier := NIL;
  //
  AssembleStateName;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameCritter.AssembleStateName;
var
  cStateFullName: string;
begin
  cStateFullName := BaseName;
  if (FBodyModifier <> NIL) then
    cStateFullName := cStateFullName + STATE_DELIMITER + BodyModifier;
  if (FEquipmentModifier <> NIL) then
    cStateFullName := cStateFullName + STATE_DELIMITER + EquipmentModifier;
  if (FActionModifier <> NIL) then
    cStateFullName := cStateFullName + STATE_DELIMITER + ActionModifier;
  if (Facing <> tdUnknown) then
    cStateFullName := cStateFullName + STATE_DELIMITER + __DirName [Facing];
  //
  IActorState := cStateFullName;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameCritter.Update (WTicksElapsed: Cardinal);
var
  DestTile: TZEWorldTile;
  iIndex: integer;
  iGeneralDelay: Cardinal;

  procedure ClearAction;
  begin
    ActionRecordDispose (ActiveAction);
    ActiveAction := NIL;
  end;

begin
  inherited;
  if (ActiveAction <> NIL) then begin
    //
    // an action is still being processed.
    //
    // NOTE THAT CURRENT ACTIONS MUST BE COMPLETED!  only actions still
    // in the queue can be cancelled / overriden.  Once they're out of
    // the queue and is the active action, it must be completed before
    // other actions will be processed.
    //
    case ActiveAction.Action of
      //
      aaMove: begin
        if (FMotionTimer.CheckResetTrigger (WTicksElapsed)) then begin
          Dec (FMotionCounter);
          if (MotionCounter <= 0) then begin
            //
            ClearAction;
            FViewAvatar.OffsetChange := vocReset;
            FViewAvatar.DeltaOffset := Point (0, 0);
            if (AQ_Count = 0) then begin
              ActionModifier := STATE_STANDING;
              HandleEvent (aeArrived);
              //
              if (Self = GameWorld.PC) AND (FTileAt.Special <> NIL) then
                GameWorld.DoMapTransition (TZEGameActor ((FWorldAvatar.Tile as TZEWorldTile).Special));
            end;
            //
          end else begin
            FViewAvatar.OffsetChange := vocIncrease;
            FViewAvatar.AnimationForward;
          end;
          //
        end;
      end;
      //
      aaAttack: begin
        if (FMotionTimer.CheckResetTrigger (WTicksElapsed)) then begin
          if (FViewAvatar.AnimationForward) then begin
            ClearAction;
            ActionModifier := STATE_STANDING;
            HandleEvent (aeEndAttackAnimation);
          end;
        end;
      end;
      //
      aaUse: begin
        HandleEvent (aeUseOnTarget, ActiveAction.Target);
      end;
      //
      aaWait: begin
        if (FMotionTimer.CheckResetTrigger (WTicksElapsed)) then begin
          ClearAction;
          HandleEvent (aeTimer);
        end;
      end;
      //
      aaPerform: begin
        if (FMotionTimer.CheckResetTrigger (WTicksElapsed)) then begin
          if (FViewAvatar.AnimationForward) then begin
            ClearAction;
            ActionModifier := STATE_STANDING;
            HandleEvent (aeEndPerform);
          end;
        end;
      end;
      //
    end;
    //
  end else begin
    //
    // just in case we forget, NIL the action indicator already
    if (ActiveAction <> NIL) then ClearAction;
    //
    // if the queue is empty, do nothing
    if (AQ_Count = 0) then Exit;
    //
    // get the next action in queue
    ActiveAction := AQ_GetNext;
    //
    // and then process it
    case ActiveAction.Action of
      //
      // >>>>  move action processing
      aaMove: begin
        //
        // get destination tile, exit if it doesn't exist!
        DestTile := TZEWorldTile (TileAt.GetNeighbor (ActiveAction.Direction));
        if (DestTile = NIL) OR (NOT DestTile.Passable) then begin
          ClearAction;
          Exit;
        end;
        //
        // set the motion counter
        MotionCounter := MOTION_STEPS;
        //
        // if we're facing the wrong direction, correct this
        if (Facing <> ActiveAction.Direction) then
          Facing := ActiveAction.Direction;
        //
        // if we're currently NOT walking, then set us up so we do
        if (ActionModifier <> STATE_WALKING) then
          ActionModifier := STATE_WALKING;
        //
        // set up the timer
        FMotionTimer.Reset;
        FMotionTimer.TriggerValue := MOTION_DELAY;
        //
        // we'll be moving, so remove our highlight if we're the PC
        if (GameWorld.ActiveActor = Self) then
          FViewAvatar.DrawSelector := false;
        //
        // move our location to the destination tile, tricky part
        TileAt.MoveDominantTo (DestTile);
        FTileAt := DestTile;
        ILocation := Vector (FTileAt.X, FTileAt.Y, FTileAt.Owner.LevelIndex);
        //
        // get a new view avatar resulting from this change
        FViewAvatar := GameWorld.DominantWorldToView (FWorldAvatar);
        if (GameWorld.ActiveActor = Self) then
          FViewAvatar.DrawSelector := true;
        //
        // they're in place, change the graphics, or at least we think...
        AssembleStateName;
        //
        // set up the view avatar so it will animate properly
        FViewAvatar.DeltaOffset := __DirOffset [ActiveAction.Direction];
        for iIndex := 0 to Pred (MotionCounter) do
          FViewAvatar.OffsetChange := vocDecrease;
      end;
      //
      aaAttack: begin
        if (Assigned (ScriptHandler)) then
          iGeneralDelay := Cardinal (ScriptHandler (Self, aeBeginAttackAnimation, NIL, NIL, 0, 0))
          else iGeneralDelay := MOTION_DELAY;
        //
        // set the action state to attacking
        Facing := ActiveAction.Direction;
        ActionModifier := STATE_ATTACKING;
        //
        // set up a timer to monitor the animation
        FMotionTimer.Reset;
        FMotionTimer.TriggerValue := iGeneralDelay;
        //
      end;
      //
      aaUse: begin
      end;
      //
      aaWait: begin
      end;
      //
      aaPerform: begin
        if (Assigned (ScriptHandler)) then
          iGeneralDelay := Cardinal (ScriptHandler (Self, aeBeginPerform, ActiveAction.ExtraParam, NIL, 0, 0))
          else iGeneralDelay := MOTION_DELAY;
        //
        ActionModifier := string (PChar (ActiveAction.ExtraParam));
        //
        // set up a timer to monitor the animation
        FMotionTimer.Reset;
        FMotionTimer.TriggerValue := iGeneralDelay;
        //
      end;
      //
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameCritter.PerformAction (Location: TZEVector; Target:
  TZEGameActor; bPrimary: boolean);
var
  PathList: TList;
  TargetTile: TZEWorldTile;
  iIndex: integer;
  pAction: PZEActionRecord;
  bMoveOK: boolean;
begin
  // this clears the action queue. we need to do this to override
  // what the actor will do next
  FActionQueue.Clear;
  //
  // simple move requests have on target.  that is, the destination tile
  // does not contain any other actor!
  if (bPrimary) AND (Target = NIL) then begin
    //
    // query the script handler if we can move this piece...
    if (NOT Assigned (ScriptHandler)) then
      bMoveOK := true
      else bMoveOK := (ScriptHandler (Self, aeRequestMove, @Location, NIL, 0, 0) <> 0);
    //
    // if the handler don't agree, then bug out now
    if (NOT bMoveOK) then Exit;
    //
    // if we're not on any tile right now, then we're not on the map
    if (FTileAt = NIL) then Exit;
    //
    // get the target tile, we'll go there
    TargetTile := TZEWorldTile (GameWorld.WorldMap [Location.Z] [Location.X, Location.Y]);
    //
    // if it's nothing, nothing to move on, so go out now
    if (TargetTile = NIL) then Exit;
    //
    // get pathing directions from the level we'll be moving on
    PathList := TZEWorldLevel (GameWorld.WorldMap [Location.Z]).FindPath (FTileAt, TargetTile);
    //
    // if it returned NULL, there is possible no way we can go to target
    if (PathList = NIL) then Exit;
    //
    // scan the list we got and convert them to action records
    iIndex := Pred (PathList.Count);
    while (iIndex >= 0) do begin
      //
      // create a MOVE action
      pAction := ActionRecordCreate (aaMove, NIL, TZEDirection (PathList [iIndex]), NIL);
      //
      // if OK, place this in queue
      if (pAction <> NIL) then AQ_InsertBack (pAction);
      //
      // get the next direction record
      Dec (iIndex);
    end;
    //
    // DONE
    //
  end else begin
    //
    // some other target was specified.  maybe add code to generate an event
    // instead and send it to an event handler? hmmm...
    if (Assigned (ScriptHandler)) then
      if (bPrimary) then
      ScriptHandler (Self, aeRequestActionPrimary, @Location, Target, 0, 0)
      else ScriptHandler (Self, aeRequestActionSecondary,@Location, Target, 0, 0);
    //
    // debugging! insert an attack action in the queue
    //
    //pAction := ActionRecordCreate (aaAttack, NIL, tdSouthEast, NIL);
    //
    // if OK, place this in queue
    //if (pAction <> NIL) then AQ_InsertBack (pAction);
    //
  end;
end;


end.

