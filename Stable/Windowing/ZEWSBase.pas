{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSBase.PAS
              Contains the base window for the windowing system
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSBase.pas,v 1.5 2002/12/01 14:51:50 Vij Exp $
  $Log: ZEWSBase.pas,v $
  Revision 1.5  2002/12/01 14:51:50  Vij
  Added MakeCommandEvent() since this is used quite often by descendant
  controls.  Fixed infinite loop bug in Modal Event handling by creating
  a function that checks whether the current control OWNS the modal
  control; doing this eliminates the instance when a control that DO
  own the modal control will keep recursing on that control!

  Revision 1.4  2002/11/02 06:45:08  Vij
  added ClassHandler.  removed commands and placed them into ZEWSDefines.
  cleaned up conditional code some.

  Revision 1.3  2002/10/01 12:36:32  Vij
  Code cleanup

  Revision 1.2  2002/09/17 22:06:49  Vij
  Moved EndModal() notification to end of EndModal() cleanup code

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSBase;

interface

uses
  Windows,
  DirectDraw,
  //
  ZblIEvents,
  ZbScriptable,
  ZEDXImage,
  ZEDXSpriteIntf,
  ZEWSSupport,
  ZEWSDefines;

const
  { Style Bits   }
  syShadowed    =    $0001;
  syFramed      =    $0002;
  sySelectable  =    $0004;
  syTileable    =    $0008;
  sySingleClick =    $0010;
  syMakeFirst   =    $0020;
  syExplodes    =    $0040;
  syExploding   =    syExplodes;
  syCenterX     =    $0080;
  syCenterY     =    $0100;
  syCentered    =    syCenterX or syCenterY;
  syPreProcess  =    $0200;
  syPostProcess =    $0400;
  syUseParentFont=   $0800;

  { State Bits   }
  stOpen        =    $0001;
  stSelected    =    $0002;
  stCursorOn    =    $0004;
  stCursorIns   =    $0008;
  stModal       =    $0010;
  stExposed     =    $0020;
  stFocused     =    $0040;
  stActive      =    $0080;
  stDragging    =    $0100;
  stCursorOut   =    $0200;
  stVisible     =    $0400;
  stIconized    =    $0800;
  stDisabled    =    $1000;
  stShadowed    =    $2000;
  stInExecute   =    $4000;
  stMouseOver   =    $8000; 

  { Drag Modes }
  dmLimitTop    =    $01;
  dmLimitBottom =    $02;
  dmLimitLeft   =    $04;
  dmLimitRight  =    $08;
  dmLimitAll    =    dmLimitTop or dmLimitBottom or
                     dmLimitLeft or dmLimitRight;
  dmResizable   =    $40;
  dmResizeable  =    dmResizable;
  dmMoveable    =    $80;

  { Grow Modes  }
  gmGrowTop     =    $01;
  gmGrowBottom  =    $02;
  gmGrowLeft    =    $04;
  gmGrowRight   =    $08;
  gmGrowRel     =    $80;

  
type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // This structure hold control-dependent properties
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEControlProps = packed record
    Bounds: TRect;                // dimensions
    Height, Width: integer;       //
    cX, cY: integer;              // cursor position
    Style: integer;               // style flags for the window
    ucGrowMode, ucDragMode: byte; // resize and drag flags
  end;

  // command sets
  TZECommandSet = set of byte;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Forward declarations.  These refer to each other circularly
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEControl = class;
  TZEGroupControl = class;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Procedure and Function types
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEScanProc = procedure (AControl: TZEControl);
  TZEScanFunc = function (AControl: TZEControl): boolean;
  TZENotifyProc = procedure (AControl: TZEControl; lParam: integer) of object;
  TZEClassHandler = procedure of object;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // The mother (or is it father?) of all controls
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEControlClass = class of TZEControl;
  TZEControl = class (TZbNamedClass)
  private
    FWClassName: PChar;                     // window class name
    FSpriteName: PChar;                     // name for default sprite
    FDefaultSprite: IZESprite;              // the sprite we need
    FParent: TZEGroupControl;               // points to parent control
    FNext: TZEControl;                      // points to control next in the list
    Props: TZEControlProps;                 // control properties
    FLocalBounds: TRect;                    // needed always so it's a field now
    State: integer;                         // current states of the control
    FCaption: PChar;                        // caption in string form, various uses
    ddDest: IDirectDrawSurface7;            // direct draw surface, valid only during updates
    MouseEventMask: TZECommandSet;          // mask for accepted mouse events
    FBackColor: TColorRef;                  // background color, optional use
    FFont: TZEFont;                         // font to use, optional use
    rWorkRect: TRect;                       // rect to bound drag operations
    (* stuff to use when running modal *)
    FModalResult: integer;                  // result after modal run terminates
    FOnEndModal: TZENotifyProc;             // procedure handler when modal finishes
    OldCommands: TZECommandSet;             // old commands, saved before modal starts
    (* stuff used to support scripting *)
    FActionName: PChar;                     // name of action to execute
    //
  protected
    function GetActionName: PChar;
    procedure SetActionName (AActionName: PChar); virtual;
    //
    function GetWClassName: string;
    procedure SetWClassName (AWClassName: string); virtual;
    //
    procedure RefreshSprite; virtual;
    function GetSpriteName: string;
    procedure SetSpriteName (const Value: string); //virtual;
    //
    function GetParent: TZEGroupControl;
    procedure SetParent (AParent: TZEGroupControl);
    function GetNext: TZEControl;
    function GetPrevious: TZEControl;
    function GetNextC: TZEControl;
    function GetPreviousC: TZEControl;
    //
    procedure SetBounds (rBounds: TRect);
    function CalcBounds (delta: TPoint): TRect; virtual;
    procedure SizeLimits (var MinSize, MaxSize: TPoint); virtual;
    //
    property ActionName: PChar read GetActionName write SetActionName;
    property ModalResult: integer read FModalResult write FModalResult;
    property OnEndModal: TZENotifyProc read FOnEndModal write FOnEndModal;
    property WClassName: string read GetWClassName write SetWClassName;
    property DefaultSprite: IZESprite read FDefaultSprite;
    //
  public
    constructor Create (rBounds: TRect); virtual;
    destructor Destroy; override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure ClearGrowMode;
    function GetGrowMode (AGrowMode: Byte): boolean;
    procedure SetGrowMode (AGrowMode: Byte; Activate: boolean = true);
    //
    procedure ClearDragMode;
    function GetDragMode (ADragMode: Byte): boolean;
    procedure SetDragMode (ADragMode: Byte; Activate: boolean = true);
    //
    procedure ClearStyle;
    function GetStyle (AStyle: integer): boolean;
    procedure SetStyle (AStyle: integer; Activate: boolean = true);
    //
    procedure SetState (AStates: integer; Activate: boolean = true); virtual;
    function GetState (AStates: integer): boolean; virtual;
    //
    procedure ShowCursor;
    procedure HideCursor;
    procedure BlockCursor;
    procedure NormalCursor;
    procedure CursorTo (X, Y: integer);
    procedure CursorRel (dX, dY: integer);
    procedure DrawCursor; virtual;
    //
    // these routines converts rectangles and points from local
    // (the control's system) to global (the screen's system)
    function ClientToScreen (rBounds: TRect): TRect; overload;
    function ScreenToClient (rBounds: TRect): TRect; overload;
    function ClientToScreen (ptCoords: TPoint): TPoint; overload;
    function ScreenToClient (ptCoords: TPoint): TPoint; overload;
    //
    // XXXXPoint() determines if the local coordinates given
    // are within the boundaries of the control.  XXXXXScreenPoint()
    // does the same but the givens are screen coordinates
    // (e.g., mouse cursor location)
    function ContainsPoint (X, Y: integer): boolean; overload; virtual;
    function ContainsPoint (ptCoords: TPoint): boolean; overload;
    function ContainsScreenPoint (X, Y: integer): boolean; overload;
    function ContainsScreenPoint (ptCoords: TPoint): boolean; overload;
    function ContainsPointEx (X, Y: integer): boolean; virtual;
    //
    // manages the dimensions of the control
    procedure ChangeBounds (rBounds: TRect); virtual;
    //
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure Open; virtual;
    procedure Close; virtual;
    procedure MoveTo (pAnchor: TPoint); overload;
    procedure MoveTo (rBounds: TRect); overload;
    //
    // data-transfer management
    procedure SetData (var Buf); virtual;
    procedure GetData (var Buf); virtual;
    function DataSize: integer; virtual;
    //
    function Focus: boolean;
    function Validate (Command: integer): boolean; virtual;
    function Execute: integer; virtual;
    function CanClose (Command: integer): boolean; virtual;
    //
    // command management
    procedure CommandsChanged;
    procedure DisableCommands (Commands: TZECommandSet);
    procedure EnableCommands (Commands: TZECommandSet);
    procedure GetCommands (var Commands: TZECommandSet);
    procedure SetCommands (Commands: TZECommandSet);
    function CommandEnabled (Command: integer): boolean;
    //
    // list-management
    procedure MakeFirst;
    procedure PutBefore (AControl: TZEControl);
    procedure Select;
    //
    // drawing tools
    procedure DCDrawRect (DC: HDC; AColor: TColorRef; rArea: TRect); 
    procedure DCDrawRectFast (DC: HDC; Brush: HBRUSH; rArea: TRect);
    procedure DCDraw3DFrame (DC: HDC; rArea: TRect; bPressed: boolean);
    //
    // drawing routines
    procedure BeginPaint (ADest: IDirectDrawSurface7); virtual;
    procedure EndPaint;
    procedure Paint; virtual;
    procedure Update (ADest: IDirectDrawSurface7; WTicksElapsed: Cardinal); virtual;
    //
    // event-handling
    procedure ClearMouseEventMask;
    procedure ChangeMouseEventMask (MouseCommands: TZECommandSet);
    procedure ClearEvent (var Event: TZbEvent);
    procedure GetEvent (var Event: TZbEvent); virtual;
    procedure PeekEvent (var Event: TZbEvent); virtual;
    procedure HandleEvent (var Event: TZbEvent); virtual;
    procedure TranslateEvent (var Event: TZbEvent); virtual;
    procedure InsertEvent (var Event: TZbEvent); virtual;
    procedure MakeCommandEvent (var Event: TZbEvent; Command: Integer; lParam: Integer = 0);
    procedure SendEvent (Receiver: TZEControl; var Event: TZbEvent); virtual;
    procedure PostCommand (Command: integer; bShouldBroadcast: boolean = false); virtual;
    procedure Idle; virtual;
    procedure BeginModal (AOnEndModal: TZENotifyProc); virtual;
    procedure EndModal; virtual;
    //
    // virtual mouse event handlers
    procedure MouseLeftClick (var Event: TZbEvent); virtual;
    procedure MouseLeftRelease (var Event: TZbEvent); virtual;
    procedure MouseLeftDouble (var Event: TZbEvent); virtual;
    procedure MouseLeftDrag (var Event: TZbEvent); virtual;
    procedure MouseRightClick (var Event: TZbEvent); virtual;
    procedure MouseRightRelease (var Event: TZbEvent); virtual;
    procedure MouseRightDouble (var Event: TZbEvent); virtual;
    procedure MouseRightDrag (var Event: TZbEvent); virtual;
    procedure MouseOver (var Event: TZbEvent); virtual;
    procedure MouseOut (var Event: TZbEvent); virtual;
    //
    procedure CaptureMouse; virtual;
    function GetMouseFocus: TZEControl;
    procedure ReleaseMouse; virtual;
    //
    procedure GetMouseFallThrough;
    procedure ClearMouseFallThrough;
    //
    function GetCaption: string;
    procedure SetCaption (ACaption: string); virtual;
    procedure SetFont (ANewFont: TZEFont); virtual;
    //
    // graphics stuff
    procedure ImageFill (ATexture: IZESprite; rArea: TRect);
    procedure SetImage (AImageTypeName: string; ATag: integer = 0); overload; virtual;
    procedure SetImage (AImage: IZESprite; ATag: integer = 0); overload; virtual;
    //
    // properties
    property Name;
    property SpriteName: string read GetSpriteName write SetSpriteName;
    property Parent: TZEGroupControl read FParent;
    property Next: TZEControl read GetNext;
    property NextC: TZEControl read GetNextC;
    property Previous: TZEControl read GetPrevious;
    property PreviousC: TZEControl read GetPreviousC;
    property Bounds: TRect read Props.Bounds write ChangeBounds;
    property LocalBounds: TRect read FLocalBounds;
    property Left: Integer read Props.Bounds.Left;
    property Top: Integer read Props.Bounds.Top;
    property Height: integer read Props.Height;
    property Width: integer read Props.Width;
    property Caption: string read GetCaption write SetCaption;
    property BackColor: TColorRef read FBackColor write FBackColor;
    property Font: TZEFont read FFont write SetFont;
    property Surface: IDirectDrawSurface7 read ddDest;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // The Group Control.  This is a control that can contain other
  // controls.
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGroupControl = class (TZEControl)
  protected
    FLast, FCurrent: TZEControl;
    FRunResult: integer;
    FIsRootWindow: boolean;
    //
    property IsRootWindow: boolean read FIsRootWindow write FIsRootWindow;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    // for use in scanning the controls list
    procedure ScanForward (FScanProc: TZEScanProc);
    procedure ScanBackward (FScanProc: TZEScanProc);
    function ScanAndTest (FScanFunc: TZEScanFunc): TZEControl;
    //
    function FindControl (iIndex: integer): TZEControl; overload;
    function FindControl (AName: string): TZEControl; overload;
    function FindIndex (AControl: TZEControl): integer;
    function IsMember (AControl: TZEControl): boolean;
    //
    function GetFirst: TZEControl;
    function GetLast: TZEControl;
    function GetCurrent: TZEControl;
    procedure SetCurrent (AControl: TZEControl);
    //
    procedure Insert (AControl: TZEControl);
    procedure InsertBefore (AControl: TZEControl; CTarget: TZEControl);
    procedure Delete (AControl: TZEControl);
    procedure Remove (AControl: TZEControl);
    //
    procedure SelectNext (bForwards: boolean);
    function NextSelectable: TZEControl;
    function PrevSelectable: TZEControl;
    //
    procedure SetState (AStates: integer; Activate: boolean); override;
    //
    function ContainsPoint (X, Y: integer): boolean; overload; override;
    //
    procedure ChangeBounds (rBounds: TRect); override;
    //
    // data-transfer management
    procedure SetData (var Buf); override;
    procedure GetData (var Buf); override;
    function DataSize: integer; override;
    //
    function Validate (Command: integer): boolean; override;
    function Execute: integer; override;
    function CanClose (Command: integer): boolean; override;
    // drawing routines
    procedure Paint; override;
    procedure Update (ADest: IDirectDrawSurface7; WTicksElapsed: Cardinal); override;
    //
    procedure HandleEvent (var Event: TZbEvent); override;
    //
    procedure SetFont (ANewFont: TZEFont); override;
    // properties
    property First: TZEControl read GetFirst;
    property Last: TZEControl read GetLast;
    property Current: TZEControl read GetCurrent write SetCurrent;
    property RunResult: integer read FRunResult;
  end;


var
  CurrentCommands: TZECommandSet = [];


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Support routines.
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure InitWindowingSystem;
  procedure CloseWindowingSystem;
  procedure RegisterControlClass (ControlName: string; ControlClass: TZEControlClass);
  function CreateControl (ControlName: string; rBounds: TRect): TZEControl;


implementation

uses
  Types,
  SysUtils,
  StrUtils,
  Math,
  //
  ZbRectClipper,
  ZbLinkLst,
  ZbDoubleList,
  ZbGameUtils,
  //
  ZEDXFramework;


var
  (********** INTERNAL VARIABLES, DO NOT MODIFY ***********

    cMouseFocus
      points to the control who have currently captured the
      mouse.  DO NOT FILL this directly!  instead, use
      TZEControl.CaptureMouse to capture mouse control
      and TZEControl.ReleaseMouse to relinquish it.

    cControlOverMouse
      if there is any control under the mouse cursor who
      accepts MouseMove events, this is it.  this is necessary
      to know which control gets the MouseOver() and MouseOut()
      calls.

    cMouseFallThrough
      register by calling TZEControl.GetMouseFallThrough().
      this is the control who accepts unhandled mouse events
      no matter where the mouse cursor is.

    cModalControl
      the current modal control is this one.  Modal control
      is the control that gets ALL the events regardless of its
      position in the windowing stack.  To get this, call
      TZEControl.BeginModal() and end using TZEControl.EndModal()

    ModalStack
      this is a LIFO structure, a stack, that stores the controls
      who have captured the modal focus.  everytime a control
      calls BeginModal(), the currently  modal control, if any,
      is pushed on this stack BEFORE resetting the modal control.
      afterwards, when EndModal() is called, the top of this
      stack is Pop()ed to be the modal control again.

   ********************************************************)
  CMouseFocus: TZEControl = NIL;
  CControlOverMouse: TZEControl = NIL;
  CMouseFallThrough: TZEControl = NIL;
  CModalControl: TZEControl = NIL;
  ModalStack: TZZStack = NIL;


////////////////////////////////////////////////////////////////////
constructor TZEControl.Create (rBounds: TRect);
begin
  inherited Create;
  //
  FWClassName := StrNew ('Base');
  FSpriteName := StrNew ('Default');
  FDefaultSprite := NIL;
  //
  FParent := NIL;
  FNext := NIL;
  //
  FCaption := NIL;
  //
  ddDest := NIL;
  MouseEventMask := [evLBtnClick];
  FBackColor := $000000;
  FFont := NIL;
  //
  Bounds := rBounds;
  CursorTo (0, 0);
  ClearGrowMode;
  ClearDragMode;
  SetDragMode (dmLimitAll);
  ClearStyle;
  SetStyle (syUseParentFont);
  //
  SetState (stVisible, true);
  FModalResult := cmCancel;
  FOnEndModal := NIL;
  OldCommands := [];
end;

////////////////////////////////////////////////////////////////////
destructor TZEControl.Destroy;
begin
  // cleanup code to be sure we won't be missed...
  if (CMouseFocus = Self) then CMouseFocus := NIL;
  if (CControlOverMouse = Self) then CControlOverMouse := NIL;
  if (CMouseFallThrough = Self) then CMouseFallThrough := NIL;
  //
  if (FParent <> NIL) then FParent.Remove (Self);
  //
  if (FCaption <> NIL) then StrDispose (FCaption);
  if (FWClassName <> NIL) then StrDispose (FWClassName);
  if (FSpriteName <> NIL) then StrDispose (FSpriteName);
  //
  FDefaultSprite := NIL;
  FFont := NIL;
  ddDest := NIL;
  inherited;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetActionName: PChar;
begin
  Result := FActionName;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetActionName (AActionName: PChar);
begin
  if (FActionName <> NIL) then
    begin
      StrDispose (FActionName);
      FActionName := NIL;
    end;
  //
  if (AActionName <> NIL) then FActionName := StrNew (AActionName);
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetWClassName: string;
begin
  Result := string (FWClassName);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetWClassName (AWClassName: string);
begin
  if (FWClassName <> NIL) then StrDispose (FWClassName);
  FWClassName := StrNew (PChar (AWClassName));
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.RefreshSprite;
begin
  FDefaultSprite := NIL;
  if (SpriteName <> '') then
    FDefaultSprite := GUIManager.CreateSprite (WClassName, SpriteName)
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetSpriteName: string;
begin
  Result := string (FSpriteName);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetSpriteName(const Value: string);
begin
  StrDispose (FSpriteName);
  FSpriteName := StrNew (PChar (Value));
  //
  RefreshSprite;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetParent: TZEGroupControl;
begin
  Result := FParent;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetParent (AParent: TZEGroupControl);
begin
  FParent := AParent;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetNext: TZEControl;
begin
  if ((FParent <> NIL) AND (FParent.Last = Self)) then
    Result := NIL
  else
    Result := FNext;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetPrevious: TZEControl;
begin
  if ((FParent = NIL) OR (FParent.Last = NIL) OR (FParent.Last.FNext = Self)) then
    Result := NIL
  else
    Result := GetPreviousC;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetNextC: TZEControl;
begin
  Result := FNext;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetPreviousC: TZEControl;
var
  WTarget: TZEControl;
begin
  Result := NIL;
  if ((FParent <> NIL) AND (FParent.Last <> NIL)) then
    begin
      WTarget := FNext;
      while true do
        begin
          // if NIL pointer, get out
          if (WTarget = NIL) then break;
          // back to ourself again?
          if (WTarget = Self) then break;
          // found our previous yet?
          if (WTarget.FNext = Self) then break;
          // next one please
          WTarget := WTarget.FNext;
        end;
      //
      Result := WTarget;
    end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetBounds (rBounds: TRect);
begin
  Props.Bounds := rBounds;
  Props.Width := rBounds.Right - rBounds.Left;
  Props.Height := rBounds.Bottom - rBounds.Top;
  FLocalBounds := Rect (0, 0, Props.Width, Props.Height);
end;

////////////////////////////////////////////////////////////////////
function TZEControl.CalcBounds (delta: TPoint): TRect;
var
  R: TRect;
  p1, p2: integer;
  pMin, pMax: TPoint;

  procedure Adjust (var iValue: integer);
  begin
    if ((Props.ucGrowMode AND gmGrowRel) = 0) then
      iValue := iValue + p2
    else
      iValue := (iValue * p1) + (((p1 - p2) shr 1) div (p1 - p2));
  end;

begin
  R := Bounds;
  //
  p1 := FParent.Props.Width;
  p2 := delta.X;
  if ((Props.ucGrowMode AND gmGrowLeft) <> 0) then Adjust (R.Left);
  if ((Props.ucGrowMode AND gmGrowRight) <> 0) then Adjust (R.Right);
  //
  p1 := FParent.Props.Height;
  p2 := delta.Y;
  if ((Props.ucGrowMode AND gmGrowTop) <> 0) then Adjust (R.Top);
  if ((Props.ucGrowMode AND gmGrowBottom) <> 0) then Adjust (R.Bottom);
  //
  SizeLimits(pMin, pMax);
  R.Right := R.Left + EnsureRange (R.Right-R.Left, pMin.X, pMax.X);
  R.Bottom := R.Top + EnsureRange (R.Bottom-R.Top, pMin.Y, pMax.Y);
  //
  Result := R;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SizeLimits (var MinSize, MaxSize: TPoint);
begin
  MinSize.X := 1; MinSize.Y := 1;
  if (FParent <> NIL) then
    begin
      MaxSize.X := FParent.Props.Width;
      MaxSize.Y := FParent.Props.Height;
    end
  else
    MaxSize := MinSize;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_WINCLASS_NAME) then
    Result := WClassName
  else if (APropertyName = PROP_NAME_BOUNDS) then
    Result := RectToProp (Bounds)
  else if (APropertyName = PROP_NAME_CAPTION) then
    Result := Caption
  else if (APropertyName = PROP_NAME_CONTROL_NAME) then
    Result := Name
  else if (APropertyName = PROP_NAME_BACKCOLOR) then
    Result := CardinalToHexProp (BackColor)
  else if (APropertyName = PROP_NAME_SPRITE_NAME) then
    Result := SpriteName
  else if (APropertyName = PROP_NAME_FONT_NAME) then begin
    if (Font <> NIL) then
      Result := Font.Name
      else Result := '';
    //
  end else
    Result := inherited GetPropertyValue (APropertyName);
end;

////////////////////////////////////////////////////////////////////
function TZEControl.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  //
  if (APropertyName = PROP_NAME_WINCLASS_NAME) then
    WClassName := Value
  else if (APropertyName = PROP_NAME_BOUNDS) then
    Bounds := PropToRect (Value)
  else if (APropertyName = PROP_NAME_CAPTION) then
    Caption := Value
  else if (APropertyName = PROP_NAME_CONTROL_NAME) then
    Name := Value
  else if (APropertyName = PROP_NAME_BACKCOLOR) then
    BackColor := PropHexToCardinal(Value)
  else if (APropertyName = PROP_NAME_SPRITE_NAME) then
    SpriteName := Value
  else if (APropertyName = PROP_NAME_FONT_NAME) then begin
    Font := GUIManager.Fonts [Value];
    SetStyle (syUseParentFont, FALSE);
  end else
    Result := inherited SetPropertyValue (APropertyName, Value);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ClearGrowMode;
begin
  Props.ucGrowMode := 0;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetGrowMode(AGrowMode: Byte): boolean;
begin
  Result := ((Props.ucGrowMode AND AGrowMode) <> 0);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetGrowMode(AGrowMode: Byte; Activate: boolean);
begin
  if ((Activate) AND ((Props.ucGrowMode AND AGrowMode) = 0)) then
    Props.ucGrowMode := Props.ucGrowMode OR AGrowMode
  else if ((NOT Activate) AND ((Props.ucGrowMode AND AGrowMode) <> 0)) then
    Props.ucGrowMode := Props.ucGrowMode AND (NOT AGrowMode);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ClearDragMode;
begin
  Props.ucDragMode := 0;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetDragMode(ADragMode: Byte): boolean;
begin
  Result := ((Props.ucDragMode AND ADragMode) <> 0);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetDragMode(ADragMode: Byte; Activate: boolean);
begin
  if ((Activate) AND ((Props.ucDragMode AND ADragMode) = 0)) then
    Props.ucDragMode := Props.ucDragMode OR ADragMode
  else if ((NOT Activate) AND ((Props.ucDragMode AND ADragMode) <> 0)) then
    Props.ucDragMode := Props.ucDragMode AND (NOT ADragMode);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ClearStyle;
begin
  Props.Style := 0;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetStyle (AStyle: integer): boolean;
begin
  Result := ((Props.Style AND AStyle) <> 0);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetStyle (AStyle: integer; Activate: boolean);
begin
  if ((Activate) AND ((Props.Style AND AStyle) = 0)) then
    Props.Style := Props.Style OR AStyle
  else if ((NOT Activate) AND ((Props.Style AND AStyle) <> 0)) then
    Props.Style := Props.Style AND (NOT AStyle);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetState (AStates: integer; Activate: boolean);
begin
  if (Activate) then
    State := State OR AStates
  else
    State := State AND NOT AStates;
  //
  if (AStates = stCursorOn) OR (AStates = stCursorIns) then
    DrawCursor;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetState (AStates: integer): boolean;
begin
  Result := ((State AND AStates) = AStates);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ShowCursor;
begin
  SetState (stCursorOn, true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.HideCursor;
begin
  SetState (stCursorOn, false);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.BlockCursor;
begin
  SetState (stCursorIns, true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.NormalCursor;
begin
  SetState (stCursorIns, false);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.CursorTo (X, Y: integer);
begin
  Props.cX := X;
  Props.cY := Y;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.CursorRel (dX, dY: integer);
begin
  Props.cX := Props.cX + dX;
  Props.cY := Props.cY + dY;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.DrawCursor;
begin
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ClientToScreen (rBounds: TRect): TRect;
begin
  // displace the bounds by our upper-left, parent-relative coordinates
  OffsetRect (rBounds, Props.Bounds.Left, Props.Bounds.Top);
  // if we DO have a parent, call it to displace it further
  if (FParent <> NIL) then
    rBounds := FParent.ClientToScreen (rBounds);
  //
  Result := rBounds;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ScreenToClient (rBounds: TRect): TRect;
begin
  if (FParent <> NIL) then
    rBounds := FParent.ScreenToClient (rBounds);
  //
  OffsetRect (rBounds, -Props.Bounds.Left, -Props.Bounds.Top);
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ClientToScreen (ptCoords: TPoint): TPoint;
begin
  Inc (ptCoords.X, Props.Bounds.Left);
  Inc (ptCoords.Y, Props.Bounds.Top);
  if (FParent <> NIL) then
    ptCoords := FParent.ClientToScreen (ptCoords);
  //
  Result := ptCoords;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ScreenToClient (ptCoords: TPoint): TPoint;
begin
  Inc (ptCoords.X, -Props.Bounds.Left);
  Inc (ptCoords.Y, -Props.Bounds.Top);
  //
  if (FParent <> NIL) then
    ptCoords := FParent.ScreenToClient (ptCoords);
  //
  Result := ptCoords;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ContainsPoint (X, Y: integer): boolean;
begin
  // for the point to be WITHIN our bounds, the following
  // conditions must be met:
  // a. we should be visible. if not, no point in checking further
  // b. point should be within our bounds, that is >0 and <width/height.
  // c. ContainsPointEx() must return true. that function has the
  //    responsibility to check in case the mouse cursor is over a
  //    transparent area, and thus, isn't actually IN us.
  Result := ((State AND stVisible) <> 0) AND
            (X >= 0) AND (Y >= 0) AND
            (X < Props.Width) AND (Y < Props.Height) AND
            (ContainsPointEx (X, Y));
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ContainsPoint (ptCoords: TPoint): boolean;
begin
  Result := ContainsPoint (ptCoords.X, ptCoords.Y);
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ContainsScreenPoint (X, Y: integer): boolean;
begin
  Result := ContainsPoint (ScreenToClient (Point (X, Y)));
end;

////////////////////////////////////////////////////////////////////
function TZEControl.ContainsScreenPoint (ptCoords: TPoint): boolean;
begin
  Result := ContainsPoint (ScreenToClient (ptCoords));
end;

////////////////////////////////////////////////////////////////////
// ContainsPointEx() - checks if location(X,Y) falls on a non-transparent
// area within our bounds.  by default, it returns true.
function TZEControl.ContainsPointEx (X, Y: integer): boolean;
begin
  Result := true;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ChangeBounds (rBounds: TRect);
begin
  SetBounds (rBounds);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Show;
begin
  if ((State AND stVisible) = 0) then
    SetState (stVisible, true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Hide;
begin
  if ((State AND stVisible) <> 0) then
    SetState (stVisible, false);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Open;
begin
  if ((State AND stOpen) = 0) then
    SetState (stOpen, true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Close;
begin
  if ((State AND stOpen) <> 0) then
    SetState (stOpen, false);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MoveTo (pAnchor: TPoint);
var
  delta: TPoint;
  rTemp: TRect;
begin
  rTemp := Bounds;
  delta.X := pAnchor.X - rTemp.Left;
  delta.Y := pAnchor.Y - rTemp.Top;
  //
  rTemp.Left := rTemp.Left + delta.X;
  rTemp.Top := rTemp.Top + delta.Y;
  rTemp.Right := rTemp.Right + delta.X;
  rTemp.Bottom := rTemp.Bottom + delta.Y;
  //
  MoveTo (rTemp);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MoveTo (rBounds: TRect);
var
  pMin, pMax: TPoint;
  rTemp: TRect;
begin
  // get size limits, and calculate new size while range-checking it
  SizeLimits (pMin, pMax);
  rBounds.Right := rBounds.Left +
    EnsureRange (rBounds.Right-rBounds.Left, pMin.X, pMax.X);
  rBounds.Bottom := rBounds.Top +
    EnsureRange (rBounds.Bottom-rBounds.Top, pMin.Y, pMax.Y);
  // get current bounds
  rTemp := Bounds;
  // rects must be equal since we're just moving it
  if (RectsEqual (rTemp, rBounds)) then
    SetBounds (rBounds);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetData (var Buf);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.GetData (var Buf);
begin
end;

////////////////////////////////////////////////////////////////////
function TZEControl.DataSize: integer;
begin
  Result := 0;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.Focus: boolean;
begin
  Result := true;
  if ((State AND (stModal + stSelected) = 0) AND (FParent <> NIL)) then
    begin
      Result := FParent.Focus;
      if (Result) then
        begin
          if (FParent.Current <> NIL) then
            Result := FParent.Current.Validate (cmReleaseFocus);
          //
          if (Result) then Select;
        end;
    end;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.Validate (Command: integer): boolean;
begin
  Result := (Command <> 0);
end;

////////////////////////////////////////////////////////////////////
function TZEControl.Execute: integer;
begin
  Result := cmCancel;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.CanClose (Command: integer): boolean;
begin
  Result := true;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.CommandsChanged;
begin
  (**************************** TODO ****************************)
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.DisableCommands (Commands: TZECommandSet);
begin
  CurrentCommands := CurrentCommands - Commands;
  CommandsChanged;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.EnableCommands (Commands: TZECommandSet);
begin
  CurrentCommands := CurrentCommands + Commands;
  CommandsChanged;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.GetCommands (var Commands: TZECommandSet);
begin
  Commands := CurrentCommands;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetCommands (Commands: TZECommandSet);
begin
end;

////////////////////////////////////////////////////////////////////
function TZEControl.CommandEnabled (Command: integer): boolean;
begin
  if ((Command AND $FFFFFF00) <> 0) then
    Result := true
  else
    Result := Byte(Command) in CurrentCommands;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MakeFirst;
begin
  if (FParent <> NIL) then
    PutBefore (FParent.First);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.PutBefore (AControl: TZEControl);
begin
  if ((FParent = NIL) OR (AControl = Self) OR (AControl = FNext)) then exit;
  FParent.InsertBefore (Self, AControl);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Select;
begin
  // ignore if this control is not selectable
  if ((Props.Style AND sySelectable) = 0) then exit;
  // put on top if required
  if ((Props.Style AND syMakeFirst) <> 0) then MakeFirst;
  // set as the parent's current
  if (FParent <> NIL) then FParent.SetCurrent (Self);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.DCDrawRect (DC: HDC; AColor: TColorRef; rArea: TRect);
//var
//  LogBrush: TLogBrush;
//  HBR: HBRUSH;
begin
  {------------ TEMPORARILY REMOVED FOR OPTIMIZATION-------------------
  // this portion creates the solid brush
  with LogBrush do
    begin
      lbHatch := 0;
      lbColor := AColor;
      lbStyle := BS_SOLID;
    end;
  //
  HBR := CreateBrushIndirect (LogBrush);
  SelectObject (DC, HBR);
  //
  // draw the rectangle
  rArea := ClientToScreen (rArea);
  Rectangle (DC, rArea.Left, rArea.Top, rArea.Right, rArea.Bottom);
  //
  // cleanup
  DeleteObject (HBR);
  ---------------------------------------------------------------------}
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.DCDrawRectFast (DC: HDC; Brush: HBRUSH; rArea: TRect);
begin
  SelectObject (DC, Brush);
  rArea := ClientToScreen (rArea);
  Rectangle (DC, rArea.Left, rArea.Top, rArea.Right, rArea.Bottom);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.DCDraw3DFrame (DC: HDC; rArea: TRect; bPressed: boolean);
begin
  if (DC = 0) then exit;
  if (bPressed) then begin
    SelectObject (DC, GUIManager.DarkPen);
    Windows.MoveToEx (DC, rArea.Left, rArea.Bottom-2, NIL);
    Windows.LineTo (DC, rArea.Left, rArea.Top);
    Windows.LineTo (DC, rArea.Right-1, rArea.Top);
    SelectObject (DC, GUIManager.LightPen);
    Windows.MoveToEx (DC, rArea.Left, rArea.Bottom-2, NIL);
    Windows.LineTo (DC, rArea.Right-2, rArea.Bottom-2);
    Windows.LineTo (DC, rArea.Right-2, rArea.Top);
  end else begin
    SelectObject (DC, GUIManager.LightPen);
    Windows.MoveToEx (DC, rArea.Left, rArea.Bottom-2, NIL);
    Windows.LineTo (DC, rArea.Left, rArea.Top);
    Windows.LineTo (DC, rArea.Right, rArea.Top);
    SelectObject (DC, GUIManager.DarkPen);
    Windows.MoveToEx (DC, rArea.Left, rArea.Bottom-2, NIL);
    Windows.LineTo (DC, rArea.Right-2, rArea.Bottom-2);
    Windows.LineTo (DC, rArea.Right-2, rArea.Top+1);
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.BeginPaint (ADest: IDirectDrawSurface7);
begin
  ddDest := ADest;
  if (FDefaultSprite = NIL) then RefreshSprite;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.EndPaint;
begin
  ddDest := NIL;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Paint;
//var
//  hdcSurface  : HDC;
begin
  (*
  // this default Paint() simply draws a rectangle
  if (ddDest <> NIL) then
    if (ddDest.GetDC (hdcSurface) = DD_OK) then
      begin
        DCDrawRect (hdcSurface, FBackColor, LocalBounds);
        ddDest.ReleaseDC (hdcSurface);
      end;
  *)
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Update (ADest: IDirectDrawSurface7; WTicksElapsed: Cardinal);
begin
  if (GetState (stVisible)) then begin
    GlobalClipper.SetClippingRegion (ClientToScreen (LocalBounds));
    BeginPaint (ADest);
    Paint;
    EndPaint;
    GlobalClipper.ClearClippingRegion;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ClearMouseEventMask;
begin
  MouseEventMask := [];
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ChangeMouseEventMask (MouseCommands: TZECommandSet);
begin
  MouseEventMask := MouseCommands;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ClearEvent (var Event: TZbEvent);
begin
  g_DXFramework.ClearEvent (Event);
  //EventQueue.ClearEvent (Event);
  //Event.pData := Pointer (Self);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.GetEvent (var Event: TZbEvent);
begin
  if (FParent <> NIL) then
    FParent.GetEvent (Event)
    else ClearEvent (Event);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.PeekEvent (var Event: TZbEvent);
begin
  if (FParent <> NIL) then
    FParent.PeekEvent (Event)
    else ClearEvent (Event);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.HandleEvent (var Event: TZbEvent);
begin
  // if we're not visible, or we're disabled, get out now
  if (((State AND stVisible) = 0) OR ((State AND stDisabled) <> 0)) then exit;

  // if there's no event, bail out immediately
  if (Event.m_Event = evDONE) then exit;

  // handle events here
  case Event.m_Event of
    //
    //
    evLBtnClick:
      begin
        if (byte (evLBtnClick) in MouseEventMask) then
          MouseLeftClick (Event);
        //ClearEvent (Event);
      end;
    //
    //
    evLBtnDblClick:
      begin
        if (byte (evLBtnDblClick) in MouseEventMask) then
          MouseLeftDouble (Event);
        //ClearEvent (Event);
      end;
    //
    //
    evLBtnUp:
      begin
        if (byte (evLBtnUp) in MouseEventMask) then
          MouseLeftRelease (Event);
        //ClearEvent (Event);
      end;
    //
    //
    evLBtnAuto:
      begin
        if (byte (evLBtnAuto) in MouseEventMask) then
          MouseLeftDrag (Event);
        //ClearEvent (Event);
      end;
    //
    //
    evRBtnClick:
      begin
        if (byte (evRBtnClick) in MouseEventMask) then
          MouseRightClick (Event);
        //ClearEvent (Event);
      end;
    //
    //
    evRBtnDblClick:
      begin
        if (byte (evRBtnDblClick) in MouseEventMask) then
          MouseRightDouble (Event);
        //ClearEvent (Event);
      end;
    //
    //
    evRBtnUp:
      begin
        if (byte (evRBtnUp) in MouseEventMask) then
          MouseRightRelease (Event);
        //ClearEvent (Event);
      end;
    //
    //
    evRBtnAuto:
      begin
        if (byte (evRBtnAuto) in MouseEventMask) then
          MouseRightDrag (Event);
        //ClearEvent (Event);
      end;
    //
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.TranslateEvent (var Event: TZbEvent);
begin
  // nothing to do here I think...
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.InsertEvent (var Event: TZbEvent);
begin
  //g_DXFramework.ClearEvent (Event, TRUE);
  if (Event.m_Event = evDONE) then Exit;

  if (Event.m_FreeStr) then begin
    g_EventManager.Commands.InsertWithStr (Event.m_Command, 0, Event.m_pStr);
    StrDispose (Event.m_pStr);
  end else
    g_EventManager.Commands.Insert (Event.m_Command, Event.m_lParam, Event.m_lData);
  //
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MakeCommandEvent (var Event: TZbEvent;
  Command: Integer; lParam: Integer);
begin
  g_DXFramework.ClearEvent (Event, TRUE);
  Event.m_Event := evCOMMAND;
  Event.m_Command := Command;
  Event.m_lParam := lParam;
  Event.m_pData := Self;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SendEvent (Receiver: TZEControl; var Event: TZbEvent);
begin
  if (Receiver <> NIL) then Receiver.HandleEvent (Event);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.PostCommand (Command: integer; bShouldBroadcast: boolean);
begin
  g_EventManager.Commands.Insert (Command, 0, 0);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.Idle;
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.BeginModal (AOnEndModal: TZENotifyProc);
begin
  if (NOT GetState (stVisible)) then Show;
  FOnEndModal := AOnEndModal;
  GetCommands (OldCommands);
  FModalResult := cmCancel;
  SetState (stFocused + stActive + stSelected + stModal, true);
  ModalStack.Push (Pointer (CModalControl));
  CModalControl := Self;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.EndModal;
begin
  if (Assigned (FOnEndModal)) then FOnEndModal (Self, FModalResult);
  SetState (stFocused + stActive + stSelected + stModal, false);
  SetCommands (OldCommands);
  CModalControl := TZEControl (ModalStack.Pop);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseLeftClick (var Event: TZbEvent);
begin
  if ((Props.ucDragMode AND dmMoveable) <> 0) then begin
    if (FParent <> NIL) then
      rWorkRect := FParent.ClientToScreen (FParent.LocalBounds)
    else
      rWorkRect := ClientToScreen (LocalBounds);
    //
    CaptureMouse;
    ClearEvent (Event);
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseLeftRelease (var Event: TZbEvent);
begin
  if (GetState (stDragging)) then begin
    ReleaseMouse;
    ClearEvent (Event);
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseLeftDouble (var Event: TZbEvent);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseLeftDrag (var Event: TZbEvent);
var
  rArea: TRect;
  bHasMovement, bPointInside: boolean;
begin
  if (GetState (stDragging)) then
    begin
      // check if there was actually a dragging motion
      bHasMovement := ((Event.m_Delta.X <> 0) OR (Event.m_Delta.Y <> 0));
      bPointInside := ContainsScreenPoint (Event.m_Pos);
      if (bHasMovement AND bPointInside) then
        begin
          rArea := ClientToScreen (LocalBounds);
          OffsetRect (rArea, Event.m_Delta.X, Event.m_Delta.Y);
          if (RectInRect (rWorkRect, rArea)) then
            begin
              rArea := Bounds;
              OffsetRect (rArea, Event.m_Delta.X, Event.m_Delta.Y);
              ChangeBounds (rArea);
            end;
        end;
      //
      ClearEvent (Event);
    end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseRightClick (var Event: TZbEvent);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseRightRelease (var Event: TZbEvent);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseRightDouble (var Event: TZbEvent);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseRightDrag (var Event: TZbEvent);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseOver (var Event: TZbEvent);
begin
  if (NOT GetState (stMouseOver)) then
    SetState (stMouseOver, true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.MouseOut (var Event: TZbEvent);
begin
  if (GetState (stMouseOver)) then
    SetState (stMouseOver, false);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.CaptureMouse;
begin
  if (CMouseFocus <> NIL) then Exit;
  CMouseFocus := Self;
  SetState (stDragging, true);
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetMouseFocus: TZEControl;
begin
  Result := CMouseFocus;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ReleaseMouse;
begin
  SetState (stDragging, false);
  CMouseFocus := NIL;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.GetMouseFallThrough;
begin
  CMouseFallThrough := Self;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ClearMouseFallThrough;
begin
  CMouseFallThrough := NIL;
end;

////////////////////////////////////////////////////////////////////
function TZEControl.GetCaption: string;
begin
  Result := IfThen ((FCaption = NIL), '', string (FCaption));
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetCaption (ACaption: string);
begin
  if (FCaption <> NIL) then StrDispose (FCaption);
  if (ACaption <> '') then
    FCaption := StrNew (PChar (ACaption))
    else FCaption := NIL;
  //
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetFont (ANewFont: TZEFont);
begin
  FFont := NIL;
  FFont := ANewFont;
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.ImageFill (ATexture: IZESprite; rArea: TRect);
begin
  if ((ddDest <> NIL) AND (ATexture <> NIL)) then
    ATexture.Tesselate (ClientToScreen (rArea), true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetImage (AImageTypeName: string; ATag: integer);
begin
end;

////////////////////////////////////////////////////////////////////
procedure TZEControl.SetImage (AImage: IZESprite; ATag: integer);
begin
end;


////////////////////////////////////////////////////////////////////
constructor TZEGroupControl.Create (rBounds: TRect);
begin
  Inherited Create (rBounds);
  FLast := NIL;
  FCurrent := NIL;
  FIsRootWindow := false;
end;

////////////////////////////////////////////////////////////////////
destructor TZEGroupControl.Destroy;
var
  C: TZEControl;
begin
  if (FCurrent <> NIL) then begin
    FCurrent.SetState (stModal + stSelected, false);
    FCurrent := NIL;
  end;
  //
  C := FLast;
  while (C <> NIL) do begin
    C.Hide;
    Remove (C);
    C.Destroy;
    C := FLast;
  end;
  //
  inherited;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.ScanForward (FScanProc: TZEScanProc);
var
  WTarget: TZEControl;
begin
  if (FLast = NIL) then exit;
  WTarget := First;
  while (WTarget <> NIL) do begin
    FScanProc (WTarget);
    WTarget := WTarget.Next;
  end;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.ScanBackward (FScanProc: TZEScanProc);
var
  WTarget: TZEControl;
begin
  if (FLast = NIL) then exit;
  WTarget := Last;
  while (WTarget <> NIL) do begin
    FScanProc (WTarget);
    WTarget := WTarget.Previous;
  end;
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.ScanAndTest (FScanFunc: TZEScanFunc): TZEControl;
var
  WTarget: TZEControl;
  bFoundOne: boolean;
begin
  Result := NIL;
  bFoundOne := false;
  if (FLast = NIL) then exit;
  WTarget := First;
  while (WTarget <> NIL) do begin
    bFoundOne := FScanFunc (WTarget);
    if (bFoundOne) then break;
    WTarget := WTarget.Next;
  end;
  //
  if (bFoundOne) then Result := WTarget;
end;

////////////////////////////////////////////////////////////////////

    var
      __FC_Control: TZEControl;
      __FC_Index, __FC_Pos: integer;

    function __LocalFindControl (AControl: TZEControl): boolean;
    begin
      Result := false;
      //
      Inc (__FC_Pos);
      if (__FC_Pos = __FC_Index) then begin
        __FC_Control := AControl;
        Result := true;
      end;
    end;

function TZEGroupControl.FindControl (iIndex: integer): TZEControl;
begin
  __FC_Control := NIL;
  __FC_Index := iIndex;
  __FC_Pos := 0;
  Result := ScanAndTest (__LocalFindControl);
end;

////////////////////////////////////////////////////////////////////

    var
      __FCN_Control: TZEControl;
      __FCN_Name: string;

    function __LocalFindControlByName (AControl: TZEControl): boolean;
    begin
      Result := (AControl <> NIL) AND (AControl.Name = __FCN_Name);
    end;

function TZEGroupControl.FindControl (AName: string): TZEControl;
begin
  __FCN_Control := NIL;
  __FCN_Name := AName;
  Result := ScanAndTest (__LocalFindControlByName);
end;

////////////////////////////////////////////////////////////////////

    var
      __FI_Control: TZEControl;
      __FI_Pos: integer;

    function __LocalFindIndex (AControl: TZEControl): boolean;
    begin
      Inc (__FI_Pos);
      Result := (__FI_Control = AControl);
    end;

function TZEGroupControl.FindIndex (AControl: TZEControl): integer;
begin
  __FI_Control := AControl;
  __FI_Pos := 0;
  if (ScanAndTest (__LocalFindIndex) <> NIL) then
    Result := __FI_Pos
  else
    Result := -1;
end;

////////////////////////////////////////////////////////////////////

    var
      __IM_Control: TZEControl;

    function __LocalIsMember (AControl: TZEControl): boolean;
    begin
      Result := (__IM_Control = AControl);
    end;

function TZEGroupControl.IsMember (AControl: TZEControl): boolean;
var
  CFound: TZEControl;
begin
  __IM_Control := AControl;
  CFound := ScanAndTest (__LocalIsMember);
  Result := (CFound <> NIL);
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.GetFirst: TZEControl;
begin
  if (FLast = NIL) then
    Result := NIL
    else Result := FLast.FNext;
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.GetLast: TZEControl;
begin
  Result := FLast;
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.GetCurrent: TZEControl;
begin
  Result := FCurrent;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.SetCurrent (AControl: TZEControl);

  procedure ToggleCurrentStates (bFlag: boolean);
  begin
    if (FCurrent <> NIL) then begin
      FCurrent.SetState (stModal, bFlag);
      FCurrent.SetState (stSelected, bFlag);
      FCurrent.SetState (stFocused, bFlag);
    end;
  end;

begin
  // if it's already current, or it's NIL, ignore it
  if ((AControl = FCurrent) OR (AControl = NIL)) then exit;
  // unselect the current FCurrent
  ToggleCurrentStates (false);
  // move control to top if necessary
  if ((AControl.Props.Style AND syMakeFirst) <> 0) then
    AControl.MakeFirst;
  // select the current FCurrent
  FCurrent := AControl;
  ToggleCurrentStates (true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.Insert (AControl: TZEControl);
begin
  if (AControl = NIL) then exit;
  //
  // insert on top of the list
  InsertBefore (AControl, First);
  //
  // if selectable, select it
  if ((AControl.Props.Style AND sySelectable) <> 0) then
    AControl.Select;
  //
  // set control's font as ours if necessary
  if ((AControl.Props.Style AND syUseParentFont) <> 0) then
    AControl.Font := FFont;
  //
  // activate it too if we're also active
  if ((State AND stActive) <> 0) then AControl.SetState (stActive, true);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.InsertBefore (AControl: TZEControl; CTarget: TZEControl);
var
  WinPtr: TZEControl;
  Pos: TPoint;
  Bounds: TRect;
begin
  // nothing to insert if nothing is given
  if (AControl = NIL) then exit;
  // nothing to do if already in there
  if (AControl = CTarget) then exit;
  // if control to be inserted already in list, remove it first
  if (IsMember (AControl)) then
    Remove (AControl);
  // request to insert at the end of the list?
  if (CTarget = NIL) then begin
    if (FLast = NIL) then begin
      // beginning with an empty list, this should be easy
      FLast := AControl;
      FLast.FNext := AControl;
    end else begin
      // non-empty list, but this is still easy...
      AControl.FNext := FLast.FNext;
      FLast.FNext := AControl;
      FLast := AControl;
    end;
  end else begin
    // we're told to insert somewhere, but nothing's in the list...
    if (FLast = NIL) then exit;
    // make sure the target specified is in the list...
    if (NOT IsMember (CTarget)) then exit;
    // well, everything looks ok...
    AControl.FNext := CTarget;
    WinPtr := CTarget.PreviousC;
    WinPtr.FNext := AControl;
  end;
  // further processing, such as setting Self as the parent
  AControl.FParent := Self;
  // if control is supposed to be centered, then center it...
  if ((AControl.Props.Style AND syCentered) <> 0) then begin
    // horizontal centering...
    if ((AControl.Props.Style AND syCenterX) <> 0) then
      Pos.X := ((Props.Width - AControl.Props.Width) shr 1)
    else
      Pos.X := AControl.Props.Bounds.Left;
    // vertical centering...
    if ((AControl.Props.Style AND syCenterY) <> 0) then
      Pos.Y := ((Props.Height - AControl.Props.Height) shr 1)
    else
      Pos.Y := AControl.Props.Bounds.Top;
    // get bounds, and modify it
    Bounds := AControl.Bounds;
    if ((Bounds.Left <> Pos.X) OR (Bounds.Top <> Pos.Y)) then  AControl.MoveTo (Pos);
  end;
end;

////////////////////////////////////////////////////////////////////

    function __LocalFirstSelectable (AControl: TZEControl): boolean;
    begin
      Result := ((AControl.Props.Style AND sySelectable) <> 0);
    end;

procedure TZEGroupControl.Delete (AControl: TZEControl);
var
  CFound: TZEControl;
begin
  // if control now in list, ignore this call
  if (NOT IsMember (AControl)) then exit;
  //
  AControl.Hide;
  // if we're deleting the current control, then reset current
  if (AControl = FCurrent) then begin
    // clear current pointer, and remove the control to be deleted
    FCurrent := NIL;
    Remove (AControl);
    // look for a selectable control, if one is found, make is current
    CFound := ScanAndTest (__LocalFirstSelectable);
    if (CFound <> NIL) then
      Current := CFound;
  end else
    Remove (AControl);
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.Remove (AControl: TZEControl);
var
  WinPtr :TZEControl;
begin
  // ignore call if control is NIL
  if (AControl = NIL) then exit;
  //
  if (AControl = FLast) then begin
    WinPtr := FLast.PreviousC;
    if (WinPtr = FLast) then begin
      // if FLast points to itself, there is only one item in the
      // list. if so, and we're removing it, we need to empty the list
      FLast := NIL;
      FCurrent := NIL;
    end else begin
      // list looks like this before disconnection... [W] is at the
      // beginning and the end of the list since the list is circular
      //
      // [W] -> [L] ->[1] -> [2] -> ... -> [W]
      //
      // delete [l] like this
      //
      // 1. [W].Next -> [1]
      // 2. [L].Next ->  NIL
      // 3. [L] = [W]
      //
      WinPtr.FNext := FLast.FNext;
      FLast := WinPtr;
    end;
  end else begin
    // adjust pointers of items in list
    WinPtr := AControl.PreviousC;
    WinPtr.FNext := AControl.FNext;
  end;

  // clear list pointer of item removed
  AControl.FNext := NIL;
  AControl.FParent := NIL;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.SelectNext (bForwards: boolean);
var
  CFound: TZEControl;
begin
  if (bForwards) then
    CFound := NextSelectable
  else
    CFound := PrevSelectable;
  //
  if ((CFound <> NIL) AND (CFound <> FCurrent)) then
    Current := CFound;
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.NextSelectable: TZEControl;
var
  CFound :TZEControl;
Begin
  // return NIL if there's nothing in the list
  Result := NIL;
  if (FCurrent = NIL) then exit;
  //
  CFound := FCurrent.NextC;
  while ((CFound <> FCurrent) AND ((CFound.Props.Style AND sySelectable) = 0)) do
    CFound := CFound.NextC;
  //
  if (CFound <> FCurrent) then
    Result := CFound;
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.PrevSelectable: TZEControl;
var
  CFound :TZEControl;
Begin
  // return NIL if there's nothing in the list
  Result := NIL;
  if (FCurrent = NIL) then exit;
  //
  CFound := FCurrent.PreviousC;
  while ((CFound <> FCurrent) AND ((CFound.Props.Style AND sySelectable) = 0)) do
    CFound := CFound.PreviousC;
  //
  if (CFound <> FCurrent) then
    Result := CFound;
end;

////////////////////////////////////////////////////////////////////

    var
      __SS_State: integer;
      __SS_Activate: boolean;

    procedure __LocalChangeState (AControl: TZEControl);
    begin
      AControl.SetState (__SS_State, __SS_Activate)
    end;

procedure TZEGroupControl.SetState (AStates: integer; Activate: boolean);
var
  __OldSS_State: integer;
  __OldSS_Activate: boolean;

  procedure EnterRoutine;
  begin
    __OldSS_State := __SS_State;
    __OldSS_Activate := __SS_Activate;
    __SS_Activate := Activate;
  end;

  procedure ExitRoutine;
  begin
    __SS_State := __OldSS_State;
    __SS_Activate := __OldSS_Activate;
  end;

begin
  inherited SetState (AStates, Activate);
  //
  // initialize...
  EnterRoutine;
  //
  // if we're changing focus states, then notify everyone about it
  if ((State AND stFocused) <> 0) then
    begin
      // first, remove the focus from the active control, if any
      if (FCurrent <> NIL) then
        FCurrent.SetState (stFocused, Activate);
      // make everyone else change their states
      __SS_State := stActive;
      ScanForward (__LocalChangeState);
    end;
  //
  // if Selection or Active state changing...
  if (((State AND stSelected) <> 0) OR ((State AND stActive) <> 0)) then
    begin
      __SS_State := stActive;
      ScanForward (__LocalChangeState);
    end;
  //
  //
  if ((State and stDragging) <> 0) then
    begin
      __SS_State := stDragging;
      ScanForward (__LocalChangeState);
    end;
  //
  (*
  if ((State and stModal) <> 0) then
    begin
      __SS_State := stModal;
      ScanForward (__LocalChangeState);
    end;
  *)
  //
  ExitRoutine;
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.ContainsPoint (X, Y: integer): boolean;
begin
  Result := inherited ContainsPoint (X, Y);
end;

////////////////////////////////////////////////////////////////////

    var
      __CB_Delta: TPoint;

    procedure __LocalChangeBounds (AControl: TZEControl);
    var
      R: TRect;
    begin
      R := AControl.CalcBounds (__CB_Delta);
      AControl.ChangeBounds (R);
    end;

procedure TZEGroupControl.ChangeBounds (rBounds: TRect);
var
  __OldCB_Delta: TPoint;
begin
  __OldCB_Delta := __CB_Delta;
  //
  __CB_Delta.X := (rBounds.Right - rBounds.Left) - Props.Width;
  __CB_Delta.X := (rBounds.Bottom - rBounds.Top) - Props.Height;
  inherited ChangeBounds (rBounds);
  //
  ScanBackward (__LocalChangeBounds);
  //
  __CB_Delta := __OldCB_Delta;
end;

////////////////////////////////////////////////////////////////////
function AdjustPointer (P: Pointer; iOffset: integer): Pointer;
begin
  Result := Pointer (integer (P) + iOffset);
end;

////////////////////////////////////////////////////////////////////

    var
      __SD_Pointer: Pointer;

    procedure __LocalSetData (AControl: TZEControl);
    var
      iSize: integer;
    begin
      iSize := AControl.DataSize;
      if (iSize <> 0) then
        begin
          AControl.SetData (__SD_Pointer^);
          __SD_Pointer := AdjustPointer (__SD_Pointer, iSize);
        end;
    end;

procedure TZEGroupControl.SetData (var Buf);
var
  __OldSD_Pointer: Pointer;
begin
  __OldSD_Pointer := __SD_Pointer;
  //
  __SD_Pointer := @Buf;
  ScanBackward (__LocalSetData);
  //
  __SD_Pointer := __OldSD_Pointer;
end;


////////////////////////////////////////////////////////////////////

    var
      __GD_Pointer: Pointer;

    procedure __LocalGetData (AControl: TZEControl);
    var
      iSize: integer;
    begin
      iSize := AControl.DataSize;
      if (iSize <> 0) then
        begin
          AControl.GetData (__GD_Pointer^);
          __GD_Pointer := AdjustPointer (__GD_Pointer, iSize);
        end;
    end;

procedure TZEGroupControl.GetData (var Buf);
var
  __OldGD_Pointer: Pointer;
begin
  __OldGD_Pointer := __GD_Pointer;
  //
  __GD_Pointer := @Buf;
  ScanBackward (__LocalGetData);
  //
  __GD_Pointer := __OldGD_Pointer;
end;


////////////////////////////////////////////////////////////////////

    var
      __DSZ_Size: integer;

    procedure __LocalDataSize (AControl: TZEControl);
    begin
      __DSZ_Size := AControl.DataSize;
    end;

function TZEGroupControl.DataSize: integer;
var
  __OldDSZ_Size: integer;
begin
  __OldDSZ_Size := __DSZ_Size;
  //
  __DSZ_Size := 0;
  ScanBackward (__LocalDataSize);
  Result := __DSZ_Size;
  //
  __DSZ_Size := __OldDSZ_Size;
end;

////////////////////////////////////////////////////////////////////

    var
      __V_Command: integer;

    function __LocalValidate (AControl: TZEControl): boolean;
    begin
      Result := NOT AControl.Validate (__V_Command);
    end;

function TZEGroupControl.Validate (Command: integer): boolean;
var
  __OldV_Command: integer;
begin
  __OldV_Command := __V_Command;
  Result := (ScanAndTest (__LocalValidate) = NIL);
  __V_Command := __OldV_Command;
end;

////////////////////////////////////////////////////////////////////
function TZEGroupControl.Execute: integer;
var
  Event: TZbEvent;
begin
  State := State OR stInExecute;
  //
  repeat
    //
    FRunResult := cmNothing;
    repeat
      ClearEvent (Event);
      GetEvent (Event);
      TranslateEvent (Event);
      HandleEvent (Event);
      Idle;
    until (FRunResult <> cmNothing);
    //
  until CanClose (FRunResult);
  //
  State := State AND (NOT stInExecute);
  Result := FRunResult;
end;

////////////////////////////////////////////////////////////////////

    var
      __CC_Command: integer;

    function __LocalCanClose (AControl: TZEControl): boolean;
    begin
      Result := NOT AControl.CanClose (__CC_Command);
    end;

function TZEGroupControl.CanClose (Command: integer): boolean;
var
  __OldCC_Command: integer;
begin
  __OldCC_Command := __CC_Command;
  Result := (ScanAndTest (__LocalCanClose) = NIL);
  __CC_Command := __OldCC_Command;
end;

////////////////////////////////////////////////////////////////////
procedure TZEGroupControl.Paint;
begin
  inherited;
end;

////////////////////////////////////////////////////////////////////

    var
      __U_Surface: IDirectDrawSurface7;
      __U_TicksElapsed: Cardinal;

    procedure __LocalGroupUpdate (AControl: TZEControl);
    begin
      AControl.Update (__U_Surface, __U_TicksElapsed);
    end;

procedure TZEGroupControl.Update (ADest: IDirectDrawSurface7; WTicksElapsed: Cardinal);
var
  __OldU_Surface: IDirectDrawSurface7;
  __OldU_TicksElapsed: Cardinal;
begin
  if ((ADest <> NIL) AND (GetState (stVisible))) then
    begin
      inherited Update (ADest, WTicksElapsed);
      GlobalClipper.SetClippingRegion (ClientToScreen (LocalBounds));
        //
      __OldU_Surface := __U_Surface;
      __OldU_TicksElapsed := WTicksElapsed;
      //
      __U_Surface := ADest;
      ScanBackward (__LocalGroupUpdate);
      //
      __U_Surface := __OldU_Surface;
      __U_TicksElapsed := __OldU_TicksElapsed;
      //
      GlobalClipper.ClearClippingRegion;
    end;
end;


////////////////////////////////////////////////////////////////////

    var
      __HE_event: TZbEvent;

    function __LocalHasPoint (AControl: TZEControl): boolean;
    begin
      Result := AControl.ContainsScreenPoint (__HE_event.m_Pos);
    end;

    procedure __LocalDeliverEvent (AControl: TZEControl);
    begin
      if (__HE_event.m_Event = evDONE) then exit;
      AControl.HandleEvent (__HE_event);
    end;

procedure TZEGroupControl.HandleEvent (var Event: TZbEvent);
var
  OverMouse: TZEControl;

  __OLDHE_event: TZbEvent;

  procedure SaveLocalContext;
  begin
    __OLDHE_event := __HE_event;
  end;

  procedure RestoreLocalContext;
  begin
    __HE_event := __OldHE_event;
  end;

  function ControlContainsThis (ctlSubject: TZEControl): boolean;
  var
    Ctl: TZEControl;
  begin
    Result := FALSE;
    Ctl := Self.Parent;
    while (TRUE) do begin
      if (Ctl = NIL) then Exit;
      if (Ctl = ctlSubject) then break;
      //
      Ctl := Ctl.Parent;
    end;
    Result := TRUE;
  end;

begin
  // if there is a modal control, send this event to it right away!
  // note that if this modal is THIS control, we shouldn't pass
  // the event to the modal control (which is THIS) since we will
  // get into an infinite loop.
  //if ((CModalControl <> NIL) AND (NOT GetState (stModal))) then begin
  if ((CModalControl <> NIL) AND (CModalControl <> Self) AND
    (NOT ControlContainsThis (CModalControl))) then begin
      CModalControl.HandleEvent (Event);
      Exit;
  end;

  // in case this group is in drag mode and has captured the mouse...
  if (CMouseFocus = Self) then begin
    inherited HandleEvent (Event);
    Exit;
  end;
  //
  SaveLocalContext;
  if (Event.m_Event <> evDONE) then
    begin
      __HE_event := Event;
      if ((__HE_event.m_Event AND evMOUSE) <> 0) then
        begin
          //
          // if mouse is captured by a control, just send the mouse event
          // to it immediately...
          if (CMouseFocus <> NIL) then
            CMouseFocus.HandleEvent (__HE_event)
          else
          // otherwise, find out which control to hand it off to.
            begin
              OverMouse := ScanAndTest (__LocalHasPoint);
              if (Event.m_Event = evMouseMove) then
                begin
                  // for simple mouse moves, check for MouseOver and
                  // MouseOut events.  we always have the pointer to the
                  // control who owns the space where the mouse is
                  // (CControlOverMouse).  we need only check if the mouse
                  // is still over it.  if not, we have to find which one is
                  //
                  if (OverMouse = NIL) then begin
                    if (CControlOverMouse <> NIL) then
                      CControlOverMouse.MouseOut (__HE_event);
                    //
                    CControlOverMouse := NIL;
                  end else begin
                    if (CControlOverMouse <> NIL) AND (OverMouse <> CControlOverMouse) then begin
                      CControlOverMouse.MouseOut (__HE_event);
                      CControlOverMouse := NIL;
                    end;
                    //
                    if (CControlOverMouse = NIL) AND (evMouseMove in OverMouse.MouseEventmask) then begin
                      OverMouse.MouseOver (__HE_event);
                      CControlOverMouse := OverMouse;
                    end;
                  end;
                end; // of evMouseMove check

              if (OverMouse <> NIL)then OverMouse.HandleEvent (__HE_event);

            end; // of CMouseFocus check

          // check here if the mouse event is not handled yet, if NOT,
          // then pass it to whoever wants it afterwards
          if (IsRootWindow AND ((__HE_event.m_Event AND evMouseMove) <> 0) AND (cMouseFallThrough <> NIL)) then
            CMouseFallThrough.HandleEvent (__HE_event);
          //
        end
      else //if ((Event.m_Event AND evKBD) <> 0)then
        begin
          ScanForward (__LocalDeliverEvent);
        end;
      Event := __HE_event;
    end;
  //
  if (Event.m_Event <> evDONE) then
    inherited HandleEvent (Event);
  //
  RestoreLocalContext;
end;


////////////////////////////////////////////////////////////////////

    var
      __SF_Font: TZEFont;

    procedure __LocalSetFont (AControl: TZEControl);
    begin
      if ((AControl.Props.Style AND syUseParentFont) <> 0) then
        AControl.Font := __SF_Font;
    end;

procedure TZEGroupControl.SetFont (ANewFont: TZEFont);
var
  __OldSF_Font: TZEFont;
begin
  inherited SetFont (ANewFont);
  __OldSF_Font := __SF_Font;
  __SF_Font := ANewFont;
  ScanForward (__LocalSetFont);
  __SF_Font := __OldSF_Font;
end;


      /////////////////////////////////////////////
      //                                         //
      //  W i n d o w   R e g i s t r a t i o n  //
      //         M a n a g e m e n t             //
      //                                         //
      /////////////////////////////////////////////


var
  ControlClasses: TZbDoubleList = NIL;


////////////////////////////////////////////////////////////////////
procedure InitWindowingSystem;
begin
  if (ModalStack <> NIL) then Exit;
  ModalStack := TZZStack.Create;
  //
  ControlClasses := TZbDoubleList.Create (FALSE);
  ControlClasses.Sorted := TRUE;
  // register the two ancestor classes here
  // THIS IS OPTIONAL THOUGH! SO BEWARE
  {$IFDEF REGISTER_ALL_CLASSES}
  RegisterControlClass (CC_BASE_CONTROL, TZEControl);
  RegisterControlClass (CC_BASE_GROUP, TZEGroupControl);
  {$ENDIF}
  CMouseFocus := NIL;
  CControlOverMouse := NIL;
  CMouseFallThrough := NIL;
  CModalControl := NIL;
end;

////////////////////////////////////////////////////////////////////
procedure CloseWindowingSystem;
begin
  FreeAndNIL (ControlClasses);
  FreeAndNIL (ModalStack);
end;

////////////////////////////////////////////////////////////////////
procedure RegisterControlClass (ControlName: string; ControlClass: TZEControlClass);
begin
  if (ControlClasses <> NIL) AND (ControlClasses.Get(ControlName) = NIL) then
    ControlClasses.Add (ControlName, Pointer (ControlClass));
  //
end;

////////////////////////////////////////////////////////////////////
function CreateControl (ControlName: string; rBounds: TRect): TZEControl;
var
  ControlClass: TZEControlClass;
begin
  ControlClass := TZEControlClass (ControlClasses.Get (ControlName));
  if (ControlClass <> NIL) then
    Result := ControlClass.Create (rBounds)
    else Result := NIL;
  //
end;


end.

