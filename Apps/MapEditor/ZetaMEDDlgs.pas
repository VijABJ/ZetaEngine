{============================================================================

  ZipBreak's Generic Library
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaMEDDlgs.PAS
              Dialogs to support Editor functions
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Apps/MapEditor/ZetaMEDDlgs.pas,v 1.2 2002/09/17 22:00:34 Vij Exp $
  $Log: ZetaMEDDlgs.pas,v $
  Revision 1.2  2002/09/17 22:00:34  Vij
  Added header so that history/comments will be inlined in the source file



 ============================================================================}

unit ZetaMEDDlgs;

interface

uses
  Types,
  ZbGameUtils,
  //
  ZEWSBase,
  ZEWSStandard,
  ZEWSDialogs,
  //
  ZZEViewMap,
  //
  ZetaMEDDefs;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  PZENewMapParams = ^TZENewMapParams;
  TZENewMapParams = record
    X, Y, Z: integer;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZENewMapDialog = class (TZEOKCancelDialog)
  private
    FMapWidthEdit: TZEControl;
    FMapHeightEdit: TZEControl;
    FMapLevelEdit: TZEControl;
  public
    constructor Create (rBounds: TRect); override;
    procedure ModalTerminated; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  PZEMapPortalParams = ^TZEMapPortalParams;
  TZEMapPortalParams = record
    Tile: TZEViewTile;
    DestName: PChar;
    X, Y, Z: integer;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMapTransitionDialog = class (TZEOKCancelDialog)
  private
    FTargetTile: TZEViewTile;
    FMapNameEdit: TZEControl;
    FMapColEdit: TZEControl;
    FMapRowEdit: TZEControl;
    FMapLevelEdit: TZEControl;
  public
    constructor Create (rBounds: TRect); override;
    procedure ModalTerminated; override;
    //
    property TargetTile: TZEViewTile read FTargetTile write FTargetTile;
  end;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function CreateNewMapParams (X, Y, Z: integer): PZENewMapParams;
  procedure DeleteNewMapParams (pMapParams: PZENewMapParams);
  function CreateMapPortalParams (Target: TZEViewTile; DestName: string;
    X, Y, Z: integer): PZEMapPortalParams;
  procedure DeleteMapPortalParams (pPortalParams: PZEMapPortalParams);


implementation

uses
  SysUtils,
  StrUtils,
  //
  ZblIEvents,
  ZEDXFramework,
  ZEWSDefines;


const
  MIN_MAP_SIZE_X              = 10;
  MAX_MAP_SIZE_X              = 300;
  MIN_MAP_SIZE_Y              = 10;
  MAX_MAP_SIZE_Y              = 300;
  MIN_MAP_SIZE_Z              = 1;
  MAX_MAP_SIZE_Z              = 4;

var
  __Margin: integer = 20;
  __LabelWidth: integer = 40;
  __EditLineHeight: integer = 20;


function CreateLabeledEditHS (AContainer: TZEGroupControl; ABounds: TRect;
  ACaption, ADefault: string): TZEControl;
var
  rArea: TRect;
begin
  // create the label first...
  with ABounds do rArea := Rect (Left, Top, Left + __LabelWidth, Bottom);
  Result := CreateControl (CC_TEXT, rArea);
  Result.SetStyle (syUseParentFont, FALSE);
  AContainer.Insert (Result);
  Result.SetPropertyValue (PROP_NAME_CAPTION, ACaption);
  Result.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogLabel');
  // create the edit control next...
  with ABounds do rArea := Rect (Left + __LabelWidth, Top, Right, Bottom);
  Result := CreateControl (CC_EDIT_CONTROL, rArea);
  Result.SetStyle (syUseParentFont, FALSE);
  AContainer.Insert (Result);
  Result.SetPropertyValue (PROP_NAME_CAPTION, ADefault);
  Result.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogEditLine');
end;

function CreateLabeledEditHN (AContainer: TZEGroupControl; ABounds: TRect;
  ACaption, ADefault: string; AMin, AMax: integer): TZEControl;
var
  rArea: TRect;
begin
  // create the label first...
  with ABounds do rArea := Rect (Left, Top, Left + __LabelWidth, Bottom);
  Result := CreateControl (CC_TEXT, rArea);
  Result.SetStyle (syUseParentFont, FALSE);
  AContainer.Insert (Result);
  Result.SetPropertyValue (PROP_NAME_CAPTION, ACaption);
  Result.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogLabel');
  // create the edit control next...
  with ABounds do rArea := Rect (Left + __LabelWidth, Top, Right, Bottom);
  Result := CreateControl (CC_NUMERIC_EDIT_CONTROL, rArea);
  Result.SetStyle (syUseParentFont, FALSE);
  AContainer.Insert (Result);
  Result.SetPropertyValue (PROP_NAME_CAPTION, ADefault);
  Result.SetPropertyValue (PROP_NAME_NUMEDIT_MIN, IntToStr (AMin));
  Result.SetPropertyValue (PROP_NAME_NUMEDIT_MAX, IntToStr (AMax));
  Result.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogEditLine');
end;


{ TZENewMapDialog }

//////////////////////////////////////////////////////////////////////////
constructor TZENewMapDialog.Create (rBounds: TRect);
var
  R: TRect;
begin
  inherited;
  OKButton.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
  CancelButton.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
  //
  R := ExpandRect (FreeBounds, -__Margin, -__Margin);
  R.Bottom := R.Top + 20;
  __LabelWidth := ((R.Right - R.Left) * 4) div 10;
  //
  FMapWidthEdit := CreateLabeledEditHN (Self, R, 'Columns (X):', '10',
    MIN_MAP_SIZE_X, MAX_MAP_SIZE_X);
  R := DisplaceRect (R, Point (0, 30));
  //
  FMapHeightEdit := CreateLabeledEditHN (Self, R, 'Rows (Y):', '10',
    MIN_MAP_SIZE_Y, MAX_MAP_SIZE_Y);
  R := DisplaceRect (R, Point (0, 30));
  //
  FMapLevelEdit := CreateLabeledEditHN (Self, R, 'Levels (Z):', '1',
    MIN_MAP_SIZE_Z, MAX_MAP_SIZE_Z);
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZENewMapDialog.ModalTerminated;
var
  X, Y, Z: integer;
begin
  //
  if (ModalResult = cmOK) then begin
    X := PropToInteger (FMapWidthEdit.GetPropertyValue (PROP_NAME_CAPTION));
    Y := PropToInteger (FMapHeightEdit.GetPropertyValue (PROP_NAME_CAPTION));
    Z := PropToInteger (FMapLevelEdit.GetPropertyValue (PROP_NAME_CAPTION));
    //
    g_EventManager.Commands.Insert (cmNewMapRequest, 0,
      Integer (CreateNewMapParams (X, Y, Z)));
    //EventQueue.InsertEvent (cmNewMapRequest, 0, integer (CreateNewMapParams (X, Y, Z)));
  end;
  //
end;


{ TZEMapTransitionDialog }

//////////////////////////////////////////////////////////////////////////
constructor TZEMapTransitionDialog.Create (rBounds: TRect);
var
  R: TRect;
begin
  inherited;
  OKButton.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
  CancelButton.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
  //
  R := ExpandRect (FreeBounds, -__Margin, -__Margin);
  R.Bottom := R.Top + 20;
  __LabelWidth := ((R.Right - R.Left) * 4) div 10;
  //
  FMapNameEdit := CreateLabeledEditHS (Self, R, 'Dest Area Name:', '');
  R := DisplaceRect (R, Point (0, 30));
  //
  FMapColEdit := CreateLabeledEditHN (Self, R, 'Dest Column (X):', '0', 0, MAXINT);
  R := DisplaceRect (R, Point (0, 30));
  //
  FMapRowEdit := CreateLabeledEditHN (Self, R, 'Dest Row (Y):', '0', 0, MAXINT);
  R := DisplaceRect (R, Point (0, 30));
  //
  FMapLevelEdit := CreateLabeledEditHN (Self, R, 'Dest Level (Z):', '0', 0, MAXINT);
  //
  FTargetTile := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMapTransitionDialog.ModalTerminated;
var
  DestName: string;
  X, Y, Z: integer;
begin
  //
  if (ModalResult = cmOK) AND (TargetTile <> NIL) then begin
    DestName := Trim (FMapNameEdit.GetPropertyValue(PROP_NAME_CAPTION));
    if (DestName = '') then Exit;
    //
    X := PropToInteger (FMapColEdit.GetPropertyValue (PROP_NAME_CAPTION));
    Y := PropToInteger (FMapRowEdit.GetPropertyValue (PROP_NAME_CAPTION));
    Z := PropToInteger (FMapLevelEdit.GetPropertyValue (PROP_NAME_CAPTION));
    if (X < 0) OR (Y < 0) OR (Z < 0) then Exit;
    //
    g_EventManager.Commands.Insert (cmNewPortalRequest, 0,
      integer (CreateMapPortalParams (TargetTile, DestName, X, Y, Z)));
    //EventQueue.InsertEvent (cmNewPortalRequest, 0,
    //  integer (CreateMapPortalParams (TargetTile, DestName, X, Y, Z)));
  end;
end;


//////////////////////////////////////////////////////////////////////////
function CreateNewMapParams (X, Y, Z: integer): PZENewMapParams;
begin
  New (Result);
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

//////////////////////////////////////////////////////////////////////////
procedure DeleteNewMapParams (pMapParams: PZENewMapParams);
begin
  if (pMapParams <> NIL) then Dispose (pMapParams);
end;

//////////////////////////////////////////////////////////////////////////
function CreateMapPortalParams (Target: TZEViewTile; DestName: string;
  X, Y, Z: integer): PZEMapPortalParams;
begin
  New (Result);
  Result.Tile := Target;
  Result.DestName := StrNew (PChar (DestName));
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

//////////////////////////////////////////////////////////////////////////
procedure DeleteMapPortalParams (pPortalParams: PZEMapPortalParams);
begin
  if (pPortalParams <> NIL) then begin
    StrDispose (pPortalParams.DestName);
    Dispose (pPortalParams);
  end;
end;


end.

