{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEWorldEntity.PAS
              The basic world occupant,with basic characteristics as well
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

unit ZZEWorldEntity;

interface

uses
  Types,
  ZbScriptable;

const
  PROP_NAME_NAME                = 'Name';
  PROP_NAME_DOMINANT            = 'Dominant';
  PROP_NAME_BLOCKER             = 'Blocker';
  PROP_NAME_OPAQUE              = 'Opaque';
  PROP_NAME_COLLAPSIBLE         = 'Collapsible';
  PROP_NAME_MULTIFACING         = 'MultiFacing';
  PROP_NAME_UPDATES             = 'RequiresUpdate';

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldEntityOption = (
      weDominant,
      weBlocker,
      weOpaque,
      weCollapsible,
      weMultiFacing,
      weRequiresUpdate
    );

  TZEWorldEntityOptions = set of TZEWorldEntityOption;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWorldEntity = class (TZbScriptable)
  private
    FName: PChar;
    FObjectID: PChar;
    FExternalPointer: Pointer;
    FExternalInteger: integer;
    FOptions: TZEWorldEntityOptions;
  protected
    function GetName: string;
    procedure SetName (AName: string);
    function GetObjectID: string;
    procedure SetObjectID (AObjectID: string);
    //
    procedure ChangeOptions (AOptions: TZEWorldEntityOptions; bActivate: boolean = true);
    function IsDominant: boolean;
    procedure SetDominant (ADominant: boolean);
    function IsBlocker: boolean;
    procedure SetBlocker (ABlocker: boolean);
    function IsOpaque: boolean;
    procedure SetOpaque (AOpaque: boolean);
    function IsCollapsible: boolean;
    procedure SetCollapsible (ACollapsible: boolean);
    function IsMultiFacing: boolean;
    procedure SetMultiFacing (AMultiFacing: boolean);
    function IsRequiresUpdate: boolean;
    procedure SetRequiresUpdate (ARequiresUpdate: boolean);
    //
    property Options: TZEWorldEntityOptions read FOptions;
  public
    constructor Create (AName, AObjectID: string); virtual;
    destructor Destroy; override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure PerformUpdate (WTicksElapsed: Cardinal); virtual; abstract;
    //
    property Name: string read GetName write SetName;
    property ObjectID: string read GetObjectID write SetObjectID;
    property ExternalPointer: Pointer read FExternalPointer write FExternalPointer;
    property ExternalInteger: integer read FExternalInteger write FExternalInteger;
    //
    property Dominant: boolean read IsDominant write SetDominant;
    property Blocker: boolean read IsBlocker write SetBlocker;
    property Opaque: boolean read IsOpaque write SetOpaque;
    property Collapsible: boolean read IsCollapsible write SetCollapsible;
    property MultiFacing: boolean read IsMultiFacing write SetMultiFacing;
    property RequiresUpdate: boolean read IsRequiresUpdate write SetRequiresUpdate;
  end;


implementation

uses
  SysUtils,
  StrUtils;


{ **** TZEWorldEntity **************************************************** }
constructor TZEWorldEntity.Create (AName, AObjectID: string);
begin
  inherited Create;
  //
  if (AName <> '') then
    FName := StrNew (PChar (AName))
    else FName := NIL;
  if (AObjectID <> '') then
    FObjectID := StrNew (PChar (AObjectID))
    else FObjectID := NIL;
  //
  FExternalPointer := NIL;
  FExternalInteger := 0;
end;

{ ************************************************************************ }
destructor TZEWorldEntity.Destroy;
begin
  if (FName <> NIL) then StrDispose (FName);
  if (FObjectID <> NIL) then StrDispose (FObjectID);
  inherited;
end;

{ ************************************************************************ }
function TZEWorldEntity.GetName: string;
begin
  Result := IfThen (FName = NIL, '', string (FName));
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetName (AName: string);
begin
  if (FName <> NIL) then StrDispose (FName);
  if (AName <> '') then
    FName := StrNew (PChar (AName))
    else FName := NIL;
end;

{ ************************************************************************ }
function TZEWorldEntity.GetObjectID: string;
begin
  Result := IfThen (FObjectID = NIL, '', string (FObjectID));
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetObjectID (AObjectID: string);
begin
  if (FObjectID <> NIL) then StrDispose (FObjectID);
  if (AObjectID <> '') then
    FObjectID := StrNew (PChar (AObjectID))
    else FObjectID := NIL;
end;


{ ************************************************************************ }
function TZEWorldEntity.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_NAME) then
    Result := Name
  else if (APropertyName = PROP_NAME_DOMINANT) then
    Result := BooleanToProp (Dominant)
  else if (APropertyName = PROP_NAME_BLOCKER) then
    Result := BooleanToProp (Blocker)
  else if (APropertyName = PROP_NAME_OPAQUE) then
    Result := BooleanToProp (Opaque)
  else if (APropertyName = PROP_NAME_COLLAPSIBLE) then
    Result := BooleanToProp (Collapsible)
  else if (APropertyName = PROP_NAME_MULTIFACING) then
    Result := BooleanToProp (MultiFacing)
  else if (APropertyName = PROP_NAME_UPDATES) then
    Result := BooleanToProp (RequiresUpdate)
  else
    Result := inherited GetPropertyValue (APropertyName);
  //
end;

{ ************************************************************************ }
function TZEWorldEntity.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  if (APropertyName = PROP_NAME_NAME) then
    Name := Value
  else if (APropertyName = PROP_NAME_DOMINANT) then
    Dominant := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_BLOCKER) then
    Blocker := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_OPAQUE) then
    Opaque := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_COLLAPSIBLE) then
    Collapsible := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_MULTIFACING) then
    MultiFacing := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_UPDATES) then
    RequiresUpdate := PropToBoolean (Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
  //
end;

{ ************************************************************************ }
procedure TZEWorldEntity.ChangeOptions (AOptions: TZEWorldEntityOptions; bActivate: boolean);
begin
  if (bActivate) then
    FOptions := FOptions + AOptions
  else
    FOptions := FOptions - AOptions;
  //
  //if (Assigned (WorldEntityEventHandler)) then
  //  WorldEntityEventHandler (Self, wevOOptionsChanged, 0, 0);
end;

{ ************************************************************************ }
function TZEWorldEntity.IsDominant: boolean;
begin
  Result := weDominant in Options;
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetDominant (ADominant: boolean);
begin
  ChangeOptions ([weDominant], ADominant);
end;

{ ************************************************************************ }
function TZEWorldEntity.IsBlocker: boolean;
begin
  Result := weBlocker in Options;
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetBlocker (ABlocker: boolean);
begin
  ChangeOptions ([weBlocker], ABlocker);
end;

{ ************************************************************************ }
function TZEWorldEntity.IsOpaque: boolean;
begin
  Result := weOpaque in Options;
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetOpaque (AOpaque: boolean);
begin
  ChangeOptions ([weOpaque], AOpaque);
end;

{ ************************************************************************ }
function TZEWorldEntity.IsCollapsible: boolean;
begin
  Result := weCollapsible in Options;
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetCollapsible (ACollapsible: boolean);
begin
  ChangeOptions ([weCollapsible], ACollapsible);
end;

{ ************************************************************************ }
function TZEWorldEntity.IsMultiFacing: boolean;
begin
  Result := weMultiFacing in Options;
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetMultiFacing (AMultiFacing: boolean);
begin
  ChangeOptions ([weMultiFacing], AMultiFacing);
end;

{ ************************************************************************ }
function TZEWorldEntity.IsRequiresUpdate: boolean;
begin
  Result := weRequiresUpdate in Options;
end;

{ ************************************************************************ }
procedure TZEWorldEntity.SetRequiresUpdate (ARequiresUpdate: boolean);
begin
  ChangeOptions ([weRequiresUpdate], ARequiresUpdate);
end;



end.
