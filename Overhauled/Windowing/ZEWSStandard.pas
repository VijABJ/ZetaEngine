{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSStandard.PAS
              Contains the standard, most-often used controls
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSStandard.pas,v 1.3 2002/12/18 08:13:23 Vij Exp $
  $Log: ZEWSStandard.pas,v $
  Revision 1.3  2002/12/18 08:13:23  Vij
  code cleanup

  Revision 1.2  2002/11/02 06:48:44  Vij
  code cleanup.  added proper comments and dividers

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSStandard;

interface

uses
  Windows,
  DirectDraw,
  Classes,
  ZblIEvents,
  ZbGameUtils,
  ZEDXImage,
  ZEDXSpriteIntf,
  ZEWSBase,
  ZEWSSupport,
  ZEWSDefines;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEPatternSpread = (
    psRepeatX, psRepeatY,
    psCenterX, psCenterY,
    psAutoWidth, psAutoHeight);
  TZEPatternSpreads = set of TZEPatternSpread;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomDecorImage = class (TZEControl)
  private
    FDrawPattern: TZEPatternSpreads;
    FAnimates: boolean;
    FAnimationTick: Cardinal;
    FAnimationTimer: TZbSimpleTimeTrigger;
    //
    procedure UpdateTimerObject;
  protected
    procedure SetAnimates (bAnimates: boolean);
    procedure SetAnimationTick (dwAnimationTick: Cardinal);
    function IsRepeatX: boolean;
    procedure SetRepeatX (bRepeatX: boolean);
    function IsRepeatY: boolean;
    procedure SetRepeatY (bRepeatY: boolean);
    function IsCenterX: boolean;
    procedure SetCenterX (bCenterX: boolean);
    function IsCenterY: boolean;
    procedure SetCenterY (bCenterY: boolean);
    function HasAutoWidth: boolean;
    procedure SetAutoWidth (bAutoWidth: boolean);
    function HasAutoHeight: boolean;
    procedure SetAutoHeight (bAutoHeight: boolean);
    //
    procedure RefreshSprite; override;
    procedure AnimateUpdate; virtual;
    //
    property Animates: boolean read FAnimates write SetAnimates;
    property AnimationTick: Cardinal read FAnimationTick write SetAnimationTick;
    property RepeatX: boolean read IsRepeatX write SetRepeatX;
    property RepeatY: boolean read IsRepeatY write SetRepeatY;
    property CenterX: boolean read IsCenterX write SetCenterX;
    property CenterY: boolean read IsCenterY write SetCenterY;
    property AutoWidth: boolean read HasAutoWidth write SetAutoWidth;
    property AutoHeight: boolean read HasAutoHeight write SetAutoHeight;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure Paint; override;
    procedure Update (ADest: IDirectDrawSurface7; WTicksElapsed: Cardinal); override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEDecorImage = class (TZECustomDecorImage)
  public
    constructor Create (rBounds: TRect); override;
    //
    property Animates;
    property AnimationTick;
    property RepeatX;
    property RepeatY;
    property CenterX;
    property CenterY;
    property AutoWidth;
    property AutoHeight;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWallpaper = class (TZECustomDecorImage)
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWinBorders = class (TZEControl)
  public
    constructor Create (rBounds: TRect); override;
    procedure Paint; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEText = class (TZEControl)
  public
    constructor Create (rBounds: TRect); override;
    procedure Paint; override;
    procedure SetFont (ANewFont: TZEFont); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZELabel = class (TZEText)
  private
    FLink: TZEControl;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    // properties
    property Link: TZEControl read FLink write FLink;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomPushButton = class (TZEControl)
  private
    FPressed: boolean;
    FOldPressStatus: boolean;
    FCommand: longint;
    FAutoPopup: boolean;        // true if button pops up after pressing
    FThreeState: boolean;       // if true, click to press, click to unpress
    FShowCaption: boolean;      // set to true if caption will be drawn
    FMargin: integer;           // margin around text
  protected
    procedure PressSuccess; virtual;
    procedure SetActionName (AActionName: PChar); override;
    procedure DrawCaption;
    procedure DrawButton; virtual;
    //
    property Margin: integer read FMargin write FMargin;
  public
    constructor Create (rBounds: TRect); override;
    procedure Paint; override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure MouseLeftClick (var Event: TZbEvent); override;
    procedure MouseLeftRelease (var Event: TZbEvent); override;
    procedure MouseLeftDrag (var Event: TZbEvent); override;
    // properties
    property Pressed: boolean read FPressed write FPressed;
    property Command: longint read FCommand write FCommand;
    property AutoPopup: boolean read FAutoPopup write FAutoPopup;
    property ThreeState: boolean read FThreeState write FThreeState;
    property ShowCaption: boolean read FShowCaption write FShowCaption;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomToggleButton = class (TZECustomPushButton)
  private
    FChecked: boolean;
  public
    constructor Create (rBounds: TRect); override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure MouseLeftRelease (var Event: TZbEvent); override;
    //
    property Checked: boolean read FChecked write FChecked;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomPushPanel = class (TZECustomPushButton)
  private
    FDrawBorders: boolean;
  protected
    procedure DrawButton; override;
  public
    constructor Create (rBounds: TRect); override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    property DrawBorders: boolean read FDrawBorders write FDrawBorders;
  end;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure RegisterControls;


implementation

uses
  Math;


{ TZECustomDecorImage }

//////////////////////////////////////////////////////////
constructor TZECustomDecorImage.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_DECOR_IMAGE;
  //
  FDrawPattern := [psRepeatX, psRepeatY];
  FAnimates := false;
  FAnimationTick := 0;
  FAnimationTimer := NIL;
end;

//////////////////////////////////////////////////////////
destructor TZECustomDecorImage.Destroy;
begin
  FAnimationTimer.Free;
  inherited;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.UpdateTimerObject;
begin
  // create the animation object if it's not created yet
  if (FAnimationTimer = NIL) then
    begin
      FAnimationTimer := TZbSimpleTimeTrigger.Create (animTimerDelay);
      if (FAnimationTimer = NIL) then Exit;
    end;
  //
  if (FAnimates AND (FAnimationTick <= 0)) then
    FAnimationTick := animTimerDelay;
  //
  if (FAnimates) then
    FAnimationTimer.TriggerValue := FAnimationTick;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetAnimates (bAnimates: boolean);
begin
  if (FAnimates <> bAnimates) then
    begin
      FAnimates := bAnimates;
      if (FAnimates) then UpdateTimerObject;
    end;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetAnimationTick (dwAnimationTick: Cardinal);
begin
  if (FAnimationTick <> dwAnimationTick) then
    begin
      FAnimationTick := dwAnimationTick;
      if (FAnimates) then UpdateTimerObject;
    end;
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.IsRepeatX: boolean;
begin
  Result := psRepeatX in FDrawPattern;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetRepeatX (bRepeatX: boolean);
begin
  if (IsRepeatX <> bRepeatX) then
    begin
      if (bRepeatX) then
        FDrawPattern := FDrawPattern + [psRepeatX]
      else
        FDrawPattern := FDrawPattern - [psRepeatX];
    end;
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.IsRepeatY: boolean;
begin
  Result := psRepeatY in FDrawPattern;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetRepeatY (bRepeatY: boolean);
begin
  if (IsRepeatY <> bRepeatY) then
    begin
      if (bRepeatY) then
        FDrawPattern := FDrawPattern + [psRepeatY]
      else
        FDrawPattern := FDrawPattern - [psRepeatY];
    end;
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.IsCenterX: boolean;
begin
  Result := psCenterX in FDrawPattern;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetCenterX (bCenterX: boolean);
begin
  if (IsCenterX <> bCenterX) then
    begin
      if (bCenterX) then
        FDrawPattern := FDrawPattern + [psCenterX]
      else
        FDrawPattern := FDrawPattern - [psCenterX];
    end;
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.IsCenterY: boolean;
begin
  Result := psCenterY in FDrawPattern;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetCenterY (bCenterY: boolean);
begin
  if (IsCenterY <> bCenterY) then
    begin
      if (bCenterY) then
        FDrawPattern := FDrawPattern + [psCenterY]
      else
        FDrawPattern := FDrawPattern - [psCenterY];
    end;
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.HasAutoWidth: boolean;
begin
  Result := psAutoWidth in FDrawPattern;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetAutoWidth (bAutoWidth: boolean);
var
  R: TRect;
begin
  if (HasAutoWidth <> bAutoWidth) then
    begin
      if (bAutoWidth) then
        begin
          FDrawPattern := FDrawPattern + [psAutoWidth];
          if (DefaultSprite <> NIL) then
            begin
              R := Bounds;
              R.Right := R.Left + DefaultSprite.Width;
              Bounds := R;
            end;
        end
      else
        FDrawPattern := FDrawPattern - [psAutoWidth];
    end;
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.HasAutoHeight: boolean;
begin
  Result := psAutoHeight in FDrawPattern;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.SetAutoHeight (bAutoHeight: boolean);
var
  R: TRect;
begin
  if (HasAutoHeight <> bAutoHeight) then
    begin
      if (bAutoHeight) then
        begin
          FDrawPattern := FDrawPattern + [psAutoHeight];
          if (DefaultSprite <> NIL) then
            begin
              R := Bounds;
              R.Bottom := R.Top + DefaultSprite.Height;
              Bounds := R;
            end;
        end
      else
        FDrawPattern := FDrawPattern - [psAutoHeight];
    end;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.Paint;
var
  R: TRect;
begin
  if (DefaultSprite = NIL) then Exit;
  //
  R := LocalBounds;
  if (NOT HasAutoWidth) then
    begin
      if (IsCenterX) then
        begin
          R.Left := R.Left + ((Width - DefaultSprite.Width) div 2);
          R.Right := R.Left + DefaultSprite.Width;
        end
      else if (NOT IsRepeatX) then
        R.Right := R.Left + Min (Width, DefaultSprite.Width);
      //
    end;
  //
  if (NOT HasAutoHeight) then
    begin
      if (IsCenterY) then
        begin
          R.Top := R.Top + ((Height - DefaultSprite.Height) div 2);
          R.Bottom := R.Top + DefaultSprite.Height;
        end
      else if (NOT IsRepeatY) then
        R.Bottom := R.Top + Min (Height, DefaultSprite.Height);
      //
    end;
  //
  ImageFill (DefaultSprite, R)
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.Update (ADest: IDirectDrawSurface7; WTicksElapsed: Cardinal);
begin
  if ((FAnimates) AND (FAnimationTimer <> NIL)) then
    if (FAnimationTimer.CheckResetTrigger (WTicksElapsed)) then
      AnimateUpdate;
  //
  inherited;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.RefreshSprite;
var
  R: TRect;
begin
  inherited;
  if (DefaultSprite = NIL) then Exit;
  //
  R := Bounds;
  //
  if (HasAutoWidth) then
    R.Right := R.Left + DefaultSprite.Width;
  //
  if (HasAutoHeight) then
    R.Bottom := R.Top + DefaultSprite.Height;
  //
  Bounds := R;
end;

//////////////////////////////////////////////////////////
procedure TZECustomDecorImage.AnimateUpdate;
begin
  if (DefaultSprite = NIL) then Exit;
  //
  if (DefaultSprite.AtLastFrame) then
    DefaultSprite.FirstFrame
  else
    DefaultSprite.NextFrame;
  //
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_REPEAT_X) then
    Result := BooleanToProp (RepeatX)
  else if (APropertyName = PROP_NAME_REPEAT_Y) then
    Result := BooleanToProp (RepeatY)
  else if (APropertyname = PROP_NAME_CENTER_X) then
    Result := BooleanToProp (CenterX)
  else if (APropertyName = PROP_NAME_CENTER_Y) then
    Result := BooleanToProp (CenterY)
  else if (APropertyName = PROP_NAME_AUTO_WIDTH) then
    Result := BooleanToProp (AutoWidth)
  else if (APropertyName = PROP_NAME_AUTO_HEIGHT) then
    Result := BooleanToProp (AutoHeight)
  else if (APropertyName = PROP_NAME_ANIMATES) then
    Result := BooleanToProp (FAnimates)
  else if (APropertyName = PROP_NAME_ANIMATE_TICK ) then
    Result := IntegerToProp (FAnimationTick)
  else
    Result := inherited GetPropertyValue (APropertyName);
end;

//////////////////////////////////////////////////////////
function TZECustomDecorImage.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  //
  if (APropertyName = PROP_NAME_REPEAT_X) then
    RepeatX := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_REPEAT_Y) then
    RepeatY := PropToBoolean (Value)
  else if (APropertyname = PROP_NAME_CENTER_X) then
    CenterX := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_CENTER_Y) then
    CenterY := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_AUTO_WIDTH) then
    AutoWidth := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_AUTO_HEIGHT) then
    AutoHeight := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_ANIMATES) then
    Animates := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_ANIMATE_TICK) then
    AnimationTick := PropToInteger (Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
end;


//////////////////////////////////////////////////////////
constructor TZEDecorImage.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_DECOR_IMAGE;
  RefreshSprite;
end;


{ TZEWallpaper }

//////////////////////////////////////////////////////////
constructor TZEWallpaper.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_WALLPAPER;
  RefreshSprite;
end;


{ TZEWinBorders }

//////////////////////////////////////////////////////////
constructor TZEWinBorders.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_WINBORDERS;
  RefreshSprite;
end;

//////////////////////////////////////////////////////////
procedure TZEWinBorders.Paint;
var
  rArea: TRect;
  W, H: longint;
const
  TZEB_NOTHING       =   0;
  TZEB_UPPER_LEFT    =   1;
  TZEB_UPPER_RIGHT   =   2;
  TZEB_LOWER_LEFT    =   3;
  TZEB_LOWER_RIGHT   =   4;
  TZEB_LEFT_EDGE     =   5;
  TZEB_RIGHT_EDGE    =   6;
  TZEB_TOP_EDGE      =   7;
  TZEB_BOTTOM_EDGE   =   8;
begin
  // get out of here if no image available
  if (DefaultSprite = NIL) then exit;
  // otherwise, process it
  DefaultSprite.CurrentFrame := TZEB_UPPER_LEFT;
  W := DefaultSprite.Width;
  H := DefaultSprite.Height;
  // draw the upper left corner
  rArea := Rect (0, 0, W, H);
  ImageFill (DefaultSprite, rArea);
  // draw the upper right corner
  DefaultSprite.NextFrame;
  rArea := Rect (Width - W, 0, Width, H);
  ImageFill (DefaultSprite, rArea);
  // draw the lower left corner
  DefaultSprite.NextFrame;
  rArea := Rect (0, Height - H, W, Height);
  ImageFill (DefaultSprite, rArea);
  // draw the lower right corner
  DefaultSprite.NextFrame;
  rArea := Rect (Width - W, Height - H, Width, Height);
  ImageFill (DefaultSprite, rArea);
  // draw the left edge
  DefaultSprite.NextFrame;
  rArea := Rect (0, H, W, Height - H);
  ImageFill (DefaultSprite, rArea);
  // draw the right edge
  DefaultSprite.NextFrame;
  rArea := Rect (Width - W, H, Width, Height - H);
  ImageFill (DefaultSprite, rArea);
  // draw the top edge
  DefaultSprite.NextFrame;
  rArea := Rect (W, 0, Width - W, H);
  ImageFill (DefaultSprite, rArea);
  // draw the bottom edge
  DefaultSprite.NextFrame;
  rArea := Rect (W, Height - H, Width - W, Height);
  ImageFill (DefaultSprite, rArea);
end;


{ TZEText }

//////////////////////////////////////////////////////////
constructor TZEText.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_TEXT;
  SpriteName := '';
end;

//////////////////////////////////////////////////////////
procedure TZEText.Paint;
var
  rArea: TRect;
begin
  if (Font <> NIL) then
    begin
      rArea := ClientToScreen (LocalBounds);
      Font.WriteText (Surface, Caption, rArea);
    end
  else
    inherited;
end;

//////////////////////////////////////////////////////////
procedure TZEText.SetFont (ANewFont: TZEFont);
var
  rArea: TRect;
begin
  inherited SetFont (ANewFont);
  if (Font <> NIL) then
    begin
      rArea := Bounds;
      rArea.Bottom := rArea.Top + Font.Height;
      Bounds := rArea;
    end;
end;


{ TZELabel }

/////////////////////////////////////////////////////
constructor TZELabel.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_LABEL;
  SpriteName := '';
  FLink := NIL;
end;

/////////////////////////////////////////////////////
destructor TZELabel.Destroy;
begin
  FLink := NIL;
  inherited;
end;


{ TZECustomPushButton }

/////////////////////////////////////////////////////
constructor TZECustomPushButton.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_PUSH_BUTTON;
  ChangeMouseEventMask ([evLBtnDown, evLBtnUp, evLBtnAuto, evMouseMove]);
  //
  FPressed := false;
  FOldPressStatus := false;
  FCommand := cmNothing;
  FAutoPopup := true;
  FThreeState := false;
  FShowCaption := false;
  FMargin := 2;
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.PressSuccess;
begin
  if (FCommand <> cmNothing) then PostCommand (FCommand);
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.SetActionName (AActionName: PChar);
begin
  inherited;
  if (ActionName <> NIL) then
    FCommand := cmGlobalCommandPerformAction
  else
    FCommand := cmNothing;
  //
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.DrawCaption;
var
  rArea: TRect;
begin
  if (FShowCaption AND (Font <> NIL)) then
    begin
      rArea := ExpandRect (ClientToScreen (LocalBounds), -FMargin, -FMargin);
      Font.WriteText (Surface, Caption, rArea);
    end;
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.DrawButton;
begin
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.Paint;
begin
  DrawButton;
  DrawCaption;
end;

/////////////////////////////////////////////////////
function TZECustomPushButton.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_PRESSED) then
    Result := BooleanToProp (Pressed)
  else if (APropertyName = PROP_NAME_COMMAND) then
    Result := IntegerToProp (Command)
  else if (APropertyName = PROP_NAME_AUTO_POPUP) then
    Result := BooleanToProp (AutoPopup)
  else if (APropertyName = PROP_NAME_THREE_STATE) then
    Result := BooleanToProp (ThreeState)
  else if (APropertyName = PROP_NAME_SHOW_CAPTION) then
    Result := BooleanToProp (ShowCaption)
  else
    Result := inherited GetPropertyValue (APropertyName);
end;

/////////////////////////////////////////////////////
function TZECustomPushButton.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  if (APropertyName = PROP_NAME_PRESSED) then
    Pressed := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_COMMAND) then
    Command := PropToInteger (Value)
  else if (APropertyName = PROP_NAME_AUTO_POPUP) then
    AutoPopup := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_THREE_STATE) then
    ThreeState := PropToBoolean (Value)
  else if (APropertyName = PROP_NAME_SHOW_CAPTION) then
    ShowCaption := PropToBoolean (Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.MouseLeftClick (var Event: TZbEvent);
begin
  // do nothing if we're disabled
  if (GetState (stDisabled)) then exit;
  // if currently pressed, and auto-popup is OFF, do nothing
  if (FPressed AND (NOT FAutoPopup)) then exit;
  // save current state if we're a three-state button
  if (FThreeState) then FOldPressStatus := FPressed;
  FPressed := TRUE;
  CaptureMouse;
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.MouseLeftRelease (var Event: TZbEvent);
var
  bPointInside: boolean;
begin
  // get outta here if we don't have mouse capture control
  if (GetMouseFocus <> Self) then exit;
  //
  if (FPressed) then begin
    if (FThreeState) then begin
      bPointInside := ContainsScreenPoint (Event.m_Pos);
      if (bPointInside AND (NOT FOldPressStatus) AND FPressed) then
        PressSuccess;
      //
      FPressed := NOT FOldPressStatus;
    end else begin
      FPressed := false;
      PressSuccess;
    end;
  end;
  //
  if (FAutoPopup) then FPressed := false;
  ReleaseMouse;
end;

/////////////////////////////////////////////////////
procedure TZECustomPushButton.MouseLeftDrag (var Event: TZbEvent);
var
  bPointInside: boolean;
begin
  if (GetState (stDragging)) then
    begin
      bPointInside := ContainsScreenPoint (Event.m_Pos);
      //
      if (FPressed AND (NOT bPointInside)) then
        // mouse went out of our bounds!
        MouseOut (Event)
      else if ((NOT FPressed) AND bPointInside) then
        // mouse just entered our space
        MouseOver (Event);
      //
      FPressed := bPointInside;
    end;
end;


{ TZECustomToggleButton }

/////////////////////////////////////////////////////
constructor TZECustomToggleButton.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_TOGGLE_BUTTON;
  FChecked := false;
end;

/////////////////////////////////////////////////////
function TZECustomToggleButton.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_CHECKED) then
    Result := BooleanToProp (Checked)
  else
    Result := inherited GetPropertyValue (APropertyName);
end;

/////////////////////////////////////////////////////
function TZECustomToggleButton.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  if (APropertyName = PROP_NAME_CHECKED) then
    Checked := PropToBoolean (Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
end;

/////////////////////////////////////////////////////
procedure TZECustomToggleButton.MouseLeftRelease (var Event: TZbEvent);
begin
  if (Pressed) then
    begin
      Pressed := false;
      FChecked := NOT FChecked;
    end;
  //
  ReleaseMouse;
end;


{ TZECustomPushPanel }

/////////////////////////////////////////////////////
constructor TZECustomPushPanel.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_PUSH_PANEL;
  //
  ThreeState := true;
  AutoPopup := false;
  ShowCaption := false;
  FDrawBorders := true;
end;

/////////////////////////////////////////////////////
procedure TZECustomPushPanel.DrawButton;
var
  hdcSurface: HDC;
begin
  if (Surface <> NIL) then begin
    if (DefaultSprite <> NIL) then begin
      if (Pressed) then
        DefaultSprite.CurrentFrame := 2
      else
        DefaultSprite.CurrentFrame := 1;
      //
      ImageFill (DefaultSprite, LocalBounds);
    end;
    //
    if (DrawBorders) AND (Surface.GetDC (hdcSurface) = DD_OK) then begin
      DCDraw3DFrame (hdcSurface, ClientToScreen (LocalBounds), Pressed);
      Surface.ReleaseDC (hdcSurface);
    end;
    //
  end;
end;

/////////////////////////////////////////////////////
function TZECustomPushPanel.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_DRAW_BORDERS) then
    Result := BooleanToProp (DrawBorders)
  else
    Result := inherited GetPropertyValue (APropertyName);
  //
end;

/////////////////////////////////////////////////////
function TZECustomPushPanel.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  if (APropertyName = PROP_NAME_DRAW_BORDERS) then
    begin
      DrawBorders := PropToBoolean (Value);
      Result := true;
    end
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
end;


{ Registration }

/////////////////////////////////////////////////////
procedure RegisterControls;
begin
  RegisterControlClass (CC_DECOR_IMAGE, TZEDecorImage);
  RegisterControlClass (CC_WALLPAPER, TZEWallpaper);
  RegisterControlClass (CC_WINBORDERS, TZEWinBorders);
  RegisterControlClass (CC_TEXT, TZEText);
  RegisterControlClass (CC_LABEL, TZELabel);
  {$IFDEF REGISTER_ALL_CLASSES}
  RegisterControlClass (CC_CUSTOM_DECOR_IMAGE, TZECustomDecorImage);
  RegisterControlClass (CC_CUSTOM_PUSH_BUTTON, TZECustomPushButton);
  RegisterControlClass (CC_CUSTOM_TOGGLE_BUTTON, TZECustomToggleButton);
  RegisterControlClass (CC_CUSTOM_PUSH_PANEL, TZECustomPushPanel);
  {$ENDIF}
end;


end.

