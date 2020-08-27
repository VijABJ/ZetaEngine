{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaMEDAux.PAS
              Auxiliary Classes for Zeta Map Editor
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Apps/MapEditor/ZetaMEDAux.pas,v 1.2 2002/09/17 22:05:17 Vij Exp $
  $Log: ZetaMEDAux.pas,v $
  Revision 1.2  2002/09/17 22:05:17  Vij
  Created a dummy class to catch EndModal()s from TZEControls.
  Completed functions of TMedEntityMode.

  Revision 1.1  2002/09/13 12:46:05  Vij
  Starting Version Control



 ============================================================================}

unit ZetaMEDAux;

interface

uses
  Classes,
  ZbScriptable,
  ZEWSBase,
  ZZEViewMap,
  ZZEWorld;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedScrollList = class (TObject)
  private
    FPanel: TZEControl;
    FPrev: TZEControl;
    FNext: TZEControl;
    FMin: integer;
    FMax: integer;
    FCurrent: integer;
  public
    constructor Create;
    //
    procedure Clear;
    procedure Show;
    procedure Hide;
    procedure Disable;
    procedure Enable;
    procedure SetPanelText (AText: string);
    //
    procedure SetMin (AMin: integer);
    procedure SetMax (AMax: integer);
    procedure SetCurrent (ACurrent: integer);
    procedure SetRange (AMin, AMax: integer);
    //
    procedure CurrentForward;
    procedure CurrentBackward;
    function CurrentAtMin: boolean;
    function CurrentAtMax: boolean;
    //
    property Panel: TZEControl read FPanel write FPanel;
    property Prev: TZEControl read FPrev write FPrev;
    property Next: TZEControl read FNext write FNext;
    property Min: integer read FMin write SetMin;
    property Max: integer read FMax write SetMax;
    property Current: integer read FCurrent write SetCurrent;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedEditorPanel = class (TObject)
  private
    FMajor: TMedScrollList;
    FMinor: TMedScrollList;
    FStyle: TMedScrollList;
    FExtra: TMedScrollList;
    FSpritePanel: TZEControl;
  public
    constructor Create;
    destructor Destroy; override;
    //
    property Major: TMedScrollList read FMajor;
    property Minor: TMedScrollList read FMinor;
    property Style: TMedScrollList read FStyle;
    property Extra: TMedScrollList read FExtra;
    property SpritePanel: TZEControl read FSpritePanel write FSpritePanel;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedDisplayLevel = (mdlMajor, mdlMinor, mdlStyle, mdlExtra);

  TMedEditorMode = class (TZbNamedClass)
  private
    FEditorPanel: TMedEditorPanel;
    FAtTile: TZEViewTile;
  protected
    procedure ILeftClick; virtual; abstract;
    procedure ICtrlLeftClick; virtual; abstract;
    procedure IShiftLeftClick; virtual; abstract;
    //
    property EditorPanel: TMedEditorPanel read FEditorPanel write FEditorPanel;
  public
    constructor Create (AEditorPanel: TMedEditorPanel); virtual;
    destructor Destroy; override;
    //
    procedure UpdateDisplay (DisplayLevel: TMedDisplayLevel = mdlMajor); virtual; abstract;
    procedure Select; virtual; abstract;
    procedure Deselect; virtual; abstract;
    //
    procedure LeftClick (theTile: TZEViewTile);
    procedure CtrlLeftClick (theTile: TZEViewTile);
    procedure ShiftLeftClick (theTile: TZEViewTile);
    //
    property Name;
    property AtTile: TZEViewTile read FAtTile;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedEditorModeList = class (TObject)
  private
    FModes: TList;
    FCurrent: integer;
  protected
    procedure Clear;
    function GetCount: integer;
    function GetActiveMode: TMedEditorMode;
  public
    constructor Create;
    destructor Destroy;
    //
    procedure Add (EMode: TMedEditorMode);
    procedure SelectNext;
    procedure SelectPrevious;
    //
    procedure UpdateDisplay (DisplayLevel: TMedDisplayLevel = mdlMajor);
    procedure LeftClick (AtTile: TZEViewTile);
    procedure CtrlLeftClick (AtTile: TZEViewTile);
    procedure ShiftLeftClick (AtTile: TZEViewTile);
    //
    property Count: integer read GetCount;
    property Active: TMedEditorMode read GetActiveMode;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedTerrainMode = class (TMedEditorMode)
  private
    FTerrainMax: integer;
  protected
    procedure ILeftClick; override;
    procedure ICtrlLeftClick; override;
    procedure IShiftLeftClick; override;
  public
    constructor Create (AEditorPanel: TMedEditorPanel);
    //
    procedure UpdateDisplay (DisplayLevel: TMedDisplayLevel = mdlMajor); override;
    procedure Select; override;
    procedure Deselect; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedFloorMode = class (TMedEditorMode)
  private
    FFloorMax: integer;
  protected
    procedure ILeftClick; override;
    procedure ICtrlLeftClick; override;
    procedure IShiftLeftClick; override;
  public
    constructor Create (AEditorPanel: TMedEditorPanel);
    //
    procedure UpdateDisplay (DisplayLevel: TMedDisplayLevel = mdlMajor); override;
    procedure Select; override;
    procedure Deselect; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedWallMode = class (TMedEditorMode)
  private
    FWallMax: integer;
  protected
    procedure ILeftClick; override;
    procedure ICtrlLeftClick; override;
    procedure IShiftLeftClick; override;
  public
    constructor Create (AEditorPanel: TMedEditorPanel);
    //
    procedure UpdateDisplay (DisplayLevel: TMedDisplayLevel = mdlMajor); override;
    procedure Select; override;
    procedure Deselect; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedEntityMode = class (TMedEditorMode)
  private
    FDirList: TStrings;
    FActionList: TStrings;
    FGroup: TZEEntityGroup;
  protected
    procedure ILeftClick; override;
    procedure ICtrlLeftClick; override;
    procedure IShiftLeftClick; override;
    //
    function GetSelectedEntity: TZEEntity;
    procedure UpdateMajor;
    procedure UpdateMinor;
    procedure UpdateStyle;
    procedure UpdateExtra;
  public
    constructor Create (AEditorPanel: TMedEditorPanel);
    destructor Destroy; override;
    //
    procedure UpdateDisplay (DisplayLevel: TMedDisplayLevel = mdlMajor); override;
    procedure Select; override;
    procedure Deselect; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TMedPortalMode = class (TMedEditorMode)
  private
    FPortalNames: TStrings;
  protected
    procedure ILeftClick; override;
    procedure ICtrlLeftClick; override;
    procedure IShiftLeftClick; override;
  public
    constructor Create (AEditorPanel: TMedEditorPanel);
    destructor Destroy; override;
    //
    procedure UpdateDisplay (DisplayLevel: TMedDisplayLevel = mdlMajor); override;
    procedure Select; override;
    procedure Deselect; override;
  end;


implementation

uses
  SysUtils,
  StrUtils,
  Math,
  JclStrings,
  //
  ZblIEvents,
  ZbGameUtils,
  //
  ZEWSDefines,
  ZZEMap,
  ZZECore,
  ZZEWorldIntf,
  ZZESAMM,
  //
  ZetaMEDDefs,
  ZetaMEDDlgs;



{ TMedScrollList }

//////////////////////////////////////////////////////////////////////////
constructor TMedScrollList.Create;
begin
  Clear;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.Clear;
begin
  FPanel := NIL;
  FPrev := NIL;
  FNext := NIL;
  FMin := 0;
  FMax := 0;
  FCurrent := 0;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.Show;
begin
  if (FPanel <> NIL) then begin
    FPanel.Show;
    FPrev.Show;
    FNext.Show;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.Hide;
begin
  if (FPanel <> NIL) then begin
    FPanel.Hide;
    FPrev.Hide;
    FNext.Hide;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.Disable;
begin
  if (FPanel <> NIL) then begin
    FPrev.SetState (stDisabled, TRUE);
    FNext.SetState (stDisabled, TRUE);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.Enable;
begin
  if (FPanel <> NIL) then begin
    FPrev.SetState (stDisabled, FALSE);
    FNext.SetState (stDisabled, FALSE);
    Show;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.SetPanelText (AText: string);
begin
  if (FPanel <> NIL) then FPanel.SetPropertyValue (PROP_NAME_CAPTION, AText);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.SetMin (AMin: integer);
begin
  FMin := AMin;
  if (FMax < FMin) then FMax := FMin;
  FCurrent := EnsureRange (FCurrent, FMin, FMax);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.SetMax (AMax: integer);
begin
  FMax := AMax;
  if (FMin > FMax) then FMin := FMax;
  FCurrent := EnsureRange (FCurrent, FMin, FMax);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.SetCurrent (ACurrent: integer);
begin
  FCurrent := EnsureRange (ACurrent, FMin, FMax);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.SetRange (AMin, AMax: integer);
begin
  FMin := AMin;
  FMax := AMax;
  FCurrent := EnsureRange (FCurrent, FMin, FMax);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.CurrentForward;
begin
  if (NOT CurrentAtMax) then
    Inc (FCurrent)
    else FCurrent := 0;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedScrollList.CurrentBackward;
begin
  if (NOT CurrentAtMin) then
    Dec (FCurrent)
    else FCurrent := FMax;
end;

//////////////////////////////////////////////////////////////////////////
function TMedScrollList.CurrentAtMin: boolean;
begin
  Result := (FCurrent = FMin);
end;

//////////////////////////////////////////////////////////////////////////
function TMedScrollList.CurrentAtMax: boolean;
begin
  Result := (FCurrent = FMax);
end;



{ TMedEditorPanel }

//////////////////////////////////////////////////////////////////////////
constructor TMedEditorPanel.Create;
begin
  inherited;
  FMajor := TMedScrollList.Create;
  FMinor := TMedScrollList.Create;
  FStyle := TMedScrollList.Create;
  FExtra := TMedScrollList.Create;
  FSpritePanel := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TMedEditorPanel.Destroy;
begin
  FExtra.Free;
  FStyle.Free;
  FMinor.Free;
  FMajor.Free;
  inherited;
end;


{ TMedEditorMode }

//////////////////////////////////////////////////////////////////////////
constructor TMedEditorMode.Create (AEditorPanel: TMedEditorPanel);
begin
  inherited Create;
  FEditorPanel := AEditorPanel;
  FAtTile := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TMedEditorMode.Destroy;
begin
  FEditorPanel := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorMode.LeftClick (theTile: TZEViewTile);
begin
  if (theTile = NIL) then Exit;
  FAtTile := theTile;
  ILeftClick;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorMode.CtrlLeftClick (theTile: TZEViewTile);
begin
  if (theTile = NIL) then Exit;
  FAtTile := theTile;
  ICtrlLeftClick;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorMode.ShiftLeftClick (theTile: TZEViewTile);
begin
  if (theTile = NIL) then Exit;
  FAtTile := theTile;
  IShiftLeftClick;
end;


{ TMedEditorModeList }

//////////////////////////////////////////////////////////////////////////
constructor TMedEditorModeList.Create;
begin
  inherited Create;
  FModes := TList.Create;
  FCurrent := -1;
end;

//////////////////////////////////////////////////////////////////////////
destructor TMedEditorModeList.Destroy;
begin
  Clear;
  FModes.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.Clear;
var
  iIndex: integer;
  theMode: TMedEditorMode;
begin
  for iIndex := 0 to Pred (FModes.Count) do begin
    theMode := TMedEditorMode (FModes [iIndex]);
    theMode.Free;
    FModes [iIndex] := NIL;
  end;
  FModes.Pack;
end;

//////////////////////////////////////////////////////////////////////////
function TMedEditorModeList.GetCount: integer;
begin
  Result := FModes.Count;
end;

//////////////////////////////////////////////////////////////////////////
function TMedEditorModeList.GetActiveMode: TMedEditorMode;
begin
  if (FCurrent >= 0) then
    Result := TMedEditorMode (FModes [FCurrent])
    else Result := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.Add (EMode: TMedEditorMode);
begin
  if (EMode <> NIL) then begin
    FModes.Add (EMode);
    if (FCurrent < 0) then begin
      FCurrent := 0;
      EMode.Select;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.SelectNext;
var
  theMode: TMedEditorMode;
begin
  theMode := GetActiveMode;
  theMode.Deselect;
  //
  if (FCurrent = Pred (FModes.Count)) then
    FCurrent := 0
    else Inc (FCurrent);
  //
  theMode := GetActiveMode;
  theMode.Select;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.SelectPrevious;
var
  theMode: TMedEditorMode;
begin
  theMode := GetActiveMode;
  theMode.Deselect;
  //
  if (FCurrent = 0) then
    FCurrent := Pred (FModes.Count)
    else Dec (FCurrent);
  //
  theMode := GetActiveMode;
  theMode.Select;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.UpdateDisplay (DisplayLevel: TMedDisplayLevel);
var
  theMode: TMedEditorMode;
begin
  theMode := GetActiveMode;
  if (theMode <> NIL) then theMode.UpdateDisplay (DisplayLevel);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.LeftClick (AtTile: TZEViewTile);
var
  theMode: TMedEditorMode;
begin
  theMode := GetActiveMode;
  if (theMode <> NIL) then theMode.LeftClick (AtTile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.CtrlLeftClick (AtTile: TZEViewTile);
var
  theMode: TMedEditorMode;
begin
  theMode := GetActiveMode;
  if (theMode <> NIL) then theMode.CtrlLeftClick (AtTile);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEditorModeList.ShiftLeftClick (AtTile: TZEViewTile);
var
  theMode: TMedEditorMode;
begin
  theMode := GetActiveMode;
  if (theMode <> NIL) then theMode.ShiftLeftClick (AtTile);
end;


///////////////////////////////======================----------------------

{ TMedTerrainMode }

//////////////////////////////////////////////////////////////////////////
constructor TMedTerrainMode.Create (AEditorPanel: TMedEditorPanel);
begin
  inherited Create (AEditorPanel);
  FTerrainMax := Pred (TerrainManager.TerrainCount);
  Name := 'Terrain';
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedTerrainMode.UpdateDisplay (DisplayLevel: TMedDisplayLevel);
var
  theTerrain: IZETerrain;
begin
  with EditorPanel do begin
    //
    theTerrain := TerrainManager.TerrainByIndex [Major.Current];
    if (DisplayLevel = mdlMajor) then begin
      Major.SetPanelText (theTerrain.Name);
      Minor.SetRange (0, Pred (theTerrain.SpriteVariationCount));
      Minor.Current := 0;
    end;
    //
    Minor.SetPanelText (Format ('%d of %d', [Succ (Minor.Current), Succ (Minor.Max)]));
    SpritePanel.SetImage (theTerrain.GetSprite (Minor.Current));
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedTerrainMode.Select;
begin
  with EditorPanel do begin
    Major.Enable;
    Minor.Enable;
    Style.Hide;
    Extra.Hide;
    //
    Major.SetRange (0, FTerrainMax);
    Major.Current := 0;
    //
    UpdateDisplay;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedTerrainMode.Deselect;
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedTerrainMode.ILeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
  with AtTile.Surface, EditorPanel do begin
    Lock;
    Terrain := TerrainManager.TerrainByIndex [Major.Current];
    TerrainVariation := Minor.Current;
    Unlock (TRUE);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedTerrainMode.ICtrlLeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
  with AtTile.Surface do begin
    Lock;
    Terrain := NIL;
    Unlock (TRUE);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedTerrainMode.IShiftLeftClick;
var
  X, Y: integer;
  theLevel: TZEViewLevel;
  theTile: TZEViewTile;
begin
  if (AtTile.Surface = NIL) then Exit;
  theLevel := TZEViewLevel (AtTile.Owner);
  with theLevel, EditorPanel do begin
    // terrain fill code here
    for X := 0 to Pred (Width) do
      for Y := 0 to Pred (Height) do begin
        theTile := TZEViewTile (Data [X, Y]);
        if (theTile = NIL) then continue;
        with theTile.Surface do begin
          Lock;
          Terrain := TerrainManager.TerrainByIndex [Major.Current];
          TerrainVariation := Minor.Current;
          Unlock (FALSE);
        end;
      end;
    // update the transitions
    for X := 0 to Pred (Width) do
      for Y := 0 to Pred (Height) do begin
        theTile := TZEViewTile (Data [X, Y]);
        if (theTile = NIL) then continue;
        theTile.Surface.UpdateTransitions (FALSE);
      end;
    //
  end;
end;


{ TMedFloorMode }

//////////////////////////////////////////////////////////////////////////
constructor TMedFloorMode.Create (AEditorPanel: TMedEditorPanel);
begin
  inherited Create (AEditorPanel);
  FFloorMax := Pred (FloorManager.FloorCount);
  Name := 'Floor';
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedFloorMode.UpdateDisplay (DisplayLevel: TMedDisplayLevel);
begin
  with EditorPanel do begin
    Minor.SetPanelText (Format ('%d of %d', [Succ (Minor.Current), Succ (Minor.Max)]));
    SpritePanel.SetImage (FloorManager.Floors [Minor.Current]);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedFloorMode.Select;
begin
  with EditorPanel do begin
    Major.Show;
    Major.Disable;
    //
    Minor.Enable;
    Minor.SetRange (0, FFloorMax);
    Minor.Current := 0;
    Major.SetPanelText ('FLOORS');
    //
    Style.Hide;
    Extra.Hide;
    //
    UpdateDisplay;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedFloorMode.Deselect;
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedFloorMode.ILeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
  AtTile.Surface.Floor := FloorManager.Floors [EditorPanel.Minor.Current];
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedFloorMode.ICtrlLeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
  AtTile.Surface.Floor := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedFloorMode.IShiftLeftClick;
var
  X, Y: integer;
  theLevel: TZEViewLevel;
  theTile: TZEViewTile;
begin
  if (AtTile.Surface = NIL) then Exit;
  theLevel := TZEViewLevel (AtTile.Owner);
  with theLevel, EditorPanel do begin
    // terrain fill code here
    for X := 0 to Pred (Width) do
      for Y := 0 to Pred (Height) do begin
        theTile := TZEViewTile (Data [X, Y]);
        if (theTile = NIL) OR (theTile.Surface = NIL) then continue;
        theTile.Surface.Floor := FloorManager.Floors [EditorPanel.Minor.Current];
      end;
    //
  end;
end;


{ TMedWallMode }

//////////////////////////////////////////////////////////////////////////
constructor TMedWallMode.Create (AEditorPanel: TMedEditorPanel);
begin
  inherited Create (AEditorPanel);
  FWallMax := Pred (WallManager.WallCount);
  Name := 'Wall';
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedWallMode.UpdateDisplay (DisplayLevel: TMedDisplayLevel);
var
  theWall: IZEWall;
begin
  with EditorPanel do begin
    theWall := WallManager.Walls [Major.Current];
    if (DisplayLevel = mdlMajor) then begin
      Major.SetPanelText (theWall.WallName);
    end;
    //
    Minor.SetPanelText (Format ('%s Wall', [__WallPositionNames [TZEWallPosition (Succ (Minor.Current))]]));
    theWall.Position := TZEWallPosition (Succ (Minor.Current));
    SpritePanel.SetImage (theWall.Sprite);
    theWall := NIL;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedWallMode.Select;
begin
  with EditorPanel do begin
    Major.Enable;
    Major.SetRange (0, FWallMax);
    Major.Current := 0;
    //
    Minor.Enable;
    Minor.SetRange (0, Pred (Ord (High (TZEWallPosition))));
    Minor.Current := 0;
    //
    Style.Hide;
    Extra.Hide;
    //
    UpdateDisplay;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedWallMode.Deselect;
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedWallMode.ILeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
  AtTile.Wall [TZEWallPosition (Succ (EditorPanel.Minor.Current))] :=
    WallManager.Walls [EditorPanel.Major.Current];
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedWallMode.ICtrlLeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
  AtTile.Wall [TZEWallPosition (Succ (EditorPanel.Minor.Current))] := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedWallMode.IShiftLeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
end;


{ TMedEntityMode }

const
  ENTITY_DEFAULT_STATE    =   '.<DEFAULT>.';

//////////////////////////////////////////////////////////////////////////
constructor TMedEntityMode.Create (AEditorPanel: TMedEditorPanel);
begin
  inherited Create (AEditorPanel);
  FDirList := TStringList.Create;
  FActionList := TStringList.Create;
  Name := 'Entity';
end;

//////////////////////////////////////////////////////////////////////////
destructor TMedEntityMode.Destroy;
begin
  FreeAndNIL (FActionList);
  FreeAndNIL (FDirList);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TMedEntityMode.GetSelectedEntity: TZEEntity;
begin
  with EditorPanel do begin
    Result := FGroup.EntityByIndex [Minor.Current];
    if (Result <> NIL) then begin
      Result.Orientation := dirNameToDir (FDirList [Style.Current]);
      Result.ExtraStateInfo := FActionList [Extra.Current];
      Result.StateChanged;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.UpdateMajor;
begin
  with EditorPanel do begin
    FGroup := CoreEngine.EntityManager.GroupByIndex [Major.Current];
    Major.SetPanelText (Format ('Lib#%d', [Major.Current]));
    //
    Minor.SetRange (0, Pred (FGroup.Count));
    Minor.Current := 0;
  end;
  UpdateMinor;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.UpdateMinor;
var
  theEntity: TZEEntity;
  iIndex: integer;
  cEntityName: String;
  SeqOrientation: TZESequenceOrientation;
begin
  FDirList.Clear;
  FActionList.Clear;
  //
  with EditorPanel do begin
    //
    theEntity := FGroup.EntityByIndex [Minor.Current];
    cEntityName := theEntity.MasterName;
    //
    with theEntity.SAMM.ActionList.Ref do begin
      //
      // get the available facings
      for iIndex := 0 to Pred (Props.Orientations.Count) do begin
        SeqOrientation := Props.Orientations.ListI [iIndex];
        FDirList.Add (__DirName [SeqOrientation.Orientation]);
      end;
      //
      // get available actions
      for iIndex := 0 to Pred (Count) do
        FActionList.Add (ActionName [iIndex]);
    end;
    //
    Minor.SetPanelText (cEntityName);
    //
    if (FDirList.Count <= 1) then begin
      Style.Disable;
      Style.SetPanelText ('N/A');
      Style.SetRange (Pred (FDirList.Count), Pred (FDirList.Count));
      Style.Current := Pred (FDirList.Count);
    end else begin
      Style.Enable;
      Style.SetRange (0, Pred (FDirList.Count));
      Style.Current := 0;
    end;
    //
    Extra.Enable;
    Extra.SetRange (0, Pred (FActionList.Count));
    Extra.Current := 0;
  end;
  //
  UpdateStyle;
  UpdateExtra;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.UpdateStyle;
begin
  with EditorPanel do
    if (Style.Current >= 0) then
      Style.SetPanelText (FDirList [Style.Current]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.UpdateExtra;
begin
  with EditorPanel do
    Extra.SetPanelText (FActionList [Extra.Current]);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.UpdateDisplay (DisplayLevel: TMedDisplayLevel);
var
  theEntity: TZEEntity;
begin
  with EditorPanel do begin
    //
    if (DisplayLevel = mdlMajor) then UpdateMajor
    else if (DisplayLevel = mdlMinor) then UpdateMinor
    else if (DisplayLevel = mdlStyle) then UpdateStyle
    else if (DisplayLevel = mdlExtra) then UpdateExtra;
    //
    theEntity := GetSelectedEntity;
    SpritePanel.SetImage (theEntity.EntitySnapShot.Sprite);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.Select;
begin
  with EditorPanel do begin
    Major.Enable;
    Major.SetRange (0, Pred (CoreEngine.EntityManager.GroupCount));
    Major.Current := 0;
    //
    Minor.Show;
    Style.Show;
    Extra.Show;
    //
    UpdateDisplay;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.Deselect;
begin
end;

var
  iEntityCount: integer = 0;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.ILeftClick;
var
  Entity, EntityToPlace: TZEEntity;
begin
  if (AtTile.Surface = NIL) then Exit;
  Entity := GetSelectedEntity;
  if (Entity = NIL) then Exit;
  //
  EntityToPlace := Entity.Clone (Format ('#%s%d', [Entity.Name, iEntityCount]));
  if (EntityToPlace = NIL) then Exit;
  Inc (iEntityCount);
  //
  EntityToPlace.Orientation := Entity.Orientation;
  EntityToPlace.ExtraStateInfo := Entity.ExtraStateInfo;
  if (NOT GameWorld.ActiveArea.PlaceEntity (EntityToPlace, AtTile)) then EntityToPlace.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.ICtrlLeftClick;
var
  Entity: TZEEntity;
begin
  if (AtTile.Surface = NIL) OR (AtTile.UserData = NIL) then Exit;
  Entity := TZEEntity (AtTile.UserData);
  GameWorld.ActiveArea.DeleteEntity (Entity);
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedEntityMode.IShiftLeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
end;


{ TMedPortalMode }


//////////////////////////////////////////////////////////////////////////
constructor TMedPortalMode.Create (AEditorPanel: TMedEditorPanel);
begin
  inherited Create (AEditorPanel);
  FPortalNames := TStringList.Create;
  FPortalNames.Add ('Start Tile');
  FPortalNames.Add ('Transition');
  FPortalNames.Add ('Name Entity');
  Name := 'Portals';
end;

//////////////////////////////////////////////////////////////////////////
destructor TMedPortalMode.Destroy;
begin
  FreeAndNIL (FPortalNames);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedPortalMode.UpdateDisplay (DisplayLevel: TMedDisplayLevel);
begin
  with EditorPanel do begin
    Major.SetPanelText (FPortalNames [Major.Current]);
    if (Major.Current = 0) then
      SpritePanel.SetImage (g_SpecialSprites.Start)
      else SpritePanel.SetImage (g_SpecialSprites.Transition);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedPortalMode.Select;
begin
  with EditorPanel do begin
    Major.Enable;
    Major.SetRange (0, Pred (FPortalNames.Count));
    Major.Current := 0;
    //
    Minor.Hide;
    Style.Hide;
    Extra.Hide;
    //
    UpdateDisplay;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedPortalMode.Deselect;
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedPortalMode.ILeftClick;
var
  MTD: TZEMapTransitionDialog;
  Entity: TZEEntity;
  cCaption: string;
begin
  if (AtTile.Surface = NIL) then Exit;
  case EditorPanel.Major.Current of
    // setting the starting position
    0: begin
      AtTile.ClearPortal;
      AtTile.SetPortal (NIL, -1, -1, -1);
    end;
    // creating map transition
    1: begin
      MTD := TZEMapTransitionDialog.Create (Rect (0, 0, 400, 200));
      MTD.TargetTile := AtTile;
      CoreEngine.RunDialog (MTD);
    end;
    // naming the entities
    2: begin
      if (AtTile.UserData <> NIL) then begin
        Entity := TZEEntity (AtTile.UserData);
        cCaption := Format ('Rename Entity %s at (X:%d, Y:%d, Z:%d)',
          [Entity.Name, Entity.AnchorTile.GridX,
           Entity.AnchorTile.GridY, Entity.AnchorTile.Owner.LevelIndex]);
        CoreEngine.ShowInputBox (cCaption, cmRenameEntityRequest);
      end;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedPortalMode.ICtrlLeftClick;
begin
  if (AtTile.Surface = NIL) then Exit;
  AtTile.ClearPortal;
end;

//////////////////////////////////////////////////////////////////////////
procedure TMedPortalMode.IShiftLeftClick;
begin
end;



end.

