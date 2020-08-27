{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSButtons.PAS
              Contains button controls
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSButtons.pas,v 1.4 2002/12/18 08:15:01 Vij Exp $
  $Log: ZEWSButtons.pas,v $
  Revision 1.4  2002/12/18 08:15:01  Vij
  removed local SetupEvent() in favor of class-global MakeCommandEvent()

  Revision 1.3  2002/11/02 06:45:48  Vij
  added proper comments for each class definitions

  Revision 1.2  2002/09/14 07:25:08  Vij
  In PicturePanel, replaced code that previously trims and centers the bounds
  of the picture.  The new code uses FitRect instead which knows how to scale
  down the picture rectangle so that it retains its aspect ratio as opposed
  to being stretched arbitrarily

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSButtons;

interface

uses
  Windows,
  ZblIEvents,
  ZEDXImage,
  ZEDXSpriteIntf,
  ZEWSBase,
  ZEWSSupport,
  ZEWSDefines,
  ZEWSStandard;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEStandardButton = class (TZECustomPushButton)
  private
    FLeftWidth, FRightWidth: integer;
  protected
    procedure RefreshSprite; override;
    procedure DrawButton; override;
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEIconButton = class (TZECustomPushButton)
  protected
    procedure RefreshSprite; override;
    procedure DrawButton; override;
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEPictureButton = class (TZEIconButton)
  protected
    procedure DrawButton; override;
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEPushPanel = class (TZECustomPushPanel)
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEPicturePanel = class (TZECustomPushPanel)
  private
    FPictureName: PChar;
    FPictureSprite: IZESprite;
    FPictureBounds: TRect;
    FGroupId: integer;
  protected
    procedure PressSuccess; override;
    procedure DrawButton; override;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure HandleEvent (var Event: TZbEvent); override;
    procedure ChangeBounds (rBounds: TRect); override;
    procedure SetImage (AImageTypeName: string; ATag: integer = 0); overload; override;
    procedure SetImage (AImage: IZESprite; ATag: integer = 0); overload; override;
    // properties
    property GroupId: integer read FGroupId write FGroupId;
    property Picture: IZESprite read FPictureSprite;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECheckbox = class (TZECustomToggleButton)
  private
    FImgWidth: integer;
  protected
    procedure RefreshSprite; override;
  public
    constructor Create (rBounds: TRect); override;
    procedure Paint; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function CreateStandardButton (rBounds: TRect; ACaption: string;
    ACommand: integer; AFont: TZEFont = NIL): TZEControl;
  function CreatePanelButton (rBounds: TRect; ACaption, ASpriteName, APicture: string;
    ACommand: integer; AAutoPopup: boolean = true; AFont: string = ''): TZEControl;

  procedure RegisterControls;


implementation

uses
  SysUtils,
  StrUtils,
  Classes,
  ZbGameUtils;


{ TZEStandardButton }

//////////////////////////////////////////////////////////
constructor TZEStandardButton.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_STANDARD_BUTTON;
  SpriteName := 'Default';
  ClearGrowMode;
  SetGrowMode (gmGrowRight + gmGrowLeft);
  SetDragMode (dmResizeable);
  //
  ShowCaption := true;
  Margin := 4;
end;

//////////////////////////////////////////////////////////
procedure TZEStandardButton.RefreshSprite;
var
  iMinWidth: integer;
  rArea: TRect;
begin
  inherited;
  //
  if (DefaultSprite = NIL) then begin
    FLeftWidth := 0;
    FRightWidth := 0;
  end else begin
    iMinWidth := 0;
    DefaultSprite.CurrentFrame := 0;
    FLeftWidth := DefaultSprite.Width;
    Inc (iMinWidth, FLeftWidth);
    //
    DefaultSprite.CurrentFrame := 2;
    FRightWidth := DefaultSprite.Width;
    Inc (iMinWidth, FRightWidth);
    //
    Inc (iMinWidth, 10);
    rArea := Bounds;
    rArea.Bottom := rArea.Top + DefaultSprite.Height;
    if ((rArea.Right - rArea.Left) < iMinWidth) then
      rArea.Right := rArea.Left + iMinWidth;
    //
    Bounds := rArea;
  end;
end;

//////////////////////////////////////////////////////////
procedure TZEStandardButton.DrawButton;
var
  rArea: TRect;
  iBaseFrame: integer;
begin
  if (DefaultSprite = NIL) then Exit;
  //
  if (GetState (stDisabled)) then
    iBaseFrame := 6
  else if (Pressed) then
    iBaseFrame := 3
  else if (GetState (stMouseOver)) then
    iBaseFrame := 9
  else
    iBaseFrame := 0;
  //
  DefaultSprite.CurrentFrame := iBaseFrame;
  rArea := Rect (0, 0, FLeftWidth, Height);
  ImageFill (DefaultSprite, rArea);
  //
  DefaultSprite.NextFrame;
  rArea := Rect (FLeftWidth, 0, Width - FRightWidth, Height);
  ImageFill (DefaultSprite, rArea);
  //
  DefaultSprite.NextFrame;
  rArea := Rect (Width - FRightWidth, 0, Width, Height);
  ImageFill (DefaultSprite, rArea);
end;


{ TZEIconButton }

/////////////////////////////////////////////////////
constructor TZEIconButton.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_ICON_BUTTON;
end;

//////////////////////////////////////////////////////////
procedure TZEIconButton.RefreshSprite;
var
  rArea: TRect;
begin
  inherited;
  if (DefaultSprite <> NIL) then begin
    rArea := Bounds;
    DefaultSprite.CurrentFrame := 1;
    rArea.Right := rArea.Left + DefaultSprite.Width;
    rArea.Bottom := rArea.Top + DefaultSprite.Height;
    Bounds := rArea;
  end;
end;

/////////////////////////////////////////////////////
procedure TZEIconButton.DrawButton;
var
  rArea: TRect;
begin
  if (DefaultSprite = NIL) then Exit;
  //
  if (GetState (stDisabled)) then
    DefaultSprite.CurrentFrame := 3
  else if (Pressed) then
    DefaultSprite.CurrentFrame := 2
  else if (GetState (stMouseOver)) then
    DefaultSprite.CurrentFrame := 4
  else
    DefaultSprite.CurrentFrame := 1;
  //
  rArea := Rect (0, 0, DefaultSprite.Width, DefaultSprite.Height);
  ImageFill (DefaultSprite, rArea);
end;


{ TZEPictureButton }

///////////////////////////////////////////////////////////////////
constructor TZEPictureButton.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_PICTURE_BUTTON;
  BackColor := $000000;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPictureButton.DrawButton;
begin
  if (DefaultSprite <> NIL) then
    ImageFill (DefaultSprite, Rect (0, 0, DefaultSprite.Width, Defaultsprite.Height));
end;


{ TZEPushPanel }

///////////////////////////////////////////////////////////////////
constructor TZEPushPanel.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_PUSH_PANEL;
  //
  ShowCaption := true;
end;


{ TZEPicturePanel }

///////////////////////////////////////////////////////////////////
constructor TZEPicturePanel.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_PICTURE_PANEL;
  //
  AutoPopup := false;
  //
  FGroupId := 0;
  FPictureName := StrNew ('');
  FPictureSprite := NIL;
  FPictureBounds := EmptyRect;
end;

///////////////////////////////////////////////////////////////////
destructor TZEPicturePanel.Destroy;
begin
  StrDispose (FPictureName);
  FPictureSprite := NIL;
  inherited;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPicturePanel.PressSuccess;
var
  Event: TZbEvent;
begin
  if ((Parent <> NIL) AND (Command <> cmNothing)) then begin
    //
    // generate a command event.  if the event is the
    // generic cmPanelClicked, just notify our parent,
    // otherwise, generate a system-wide message
    MakeCommandEvent (Event, Command, FGroupId);
    //SetupEvent (Command);
    if (Command = cmPanelClicked) then
      Parent.HandleEvent (Event)
      else InsertEvent (Event);
    //
    // if we're in a group, tell the parent to disable
    // everyone else
    if (FGroupId <> 0) then begin
      MakeCommandEvent (Event, cmAcquirePanelFocus, FGroupId);
      //SetupEvent (cmAcquirePanelFocus);
      Parent.HandleEvent (Event);
    end;
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPicturePanel.DrawButton;
begin
  inherited;
  if (FPictureSprite <> NIL) then begin
    FPictureSprite.StretchDraw (ClientToScreen (FPictureBounds), true);
  end;
end;

///////////////////////////////////////////////////////////////////
function TZEPicturePanel.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_GROUP_ID) then
    Result := IntegerToProp (GroupId)
  else if (APropertyName = PROP_NAME_PICTURE) then
    Result := IfThen (FPictureName <> NIL, string (FPictureName))
  else
    Result := inherited GetPropertyValue (APropertyName);
end;

///////////////////////////////////////////////////////////////////
function TZEPicturePanel.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  if (APropertyName = PROP_NAME_GROUP_ID) then
    GroupId := PropToInteger (Value)
  else if (APropertyName = PROP_NAME_PICTURE) then
    SetImage (Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
end;

///////////////////////////////////////////////////////////////////
procedure TZEPicturePanel.HandleEvent (var Event: TZbEvent);
begin
  inherited HandleEvent (Event);
  if (Event.m_Event = evCOMMAND) then begin
    if ((Event.m_Command = cmAcquirePanelFocus) AND
        (Event.m_lData = FGroupId) AND
        (TZEControl(Event.m_pData) <> Self)) then
          begin
            Pressed := false;
          end;
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPicturePanel.ChangeBounds (rBounds: TRect);
begin
  inherited ChangeBounds (rBounds);
  //
  if (FPictureSprite <> NIL) then
    FPictureBounds := CenterRect (LocalBounds,
          Rect (0, 0, FPictureSprite.Width, FPictureSprite.Height));
  //
end;

///////////////////////////////////////////////////////////////////
procedure TZEPicturePanel.SetImage (AImageTypeName: string; ATag: integer);
begin
  // if setting same ol' pic, ignore call
  if (string (FPictureName) = AImageTypeName) then exit;
  // remove the old sprite first
  FPictureSprite := NIL;
  StrDispose (FPictureName);
  // set a new one if necessary
  FPictureName := StrNew (PChar (AImageTypeName));
  // don't use WClassName if picturename contains '/' already
  if (Pos ('/', AImageTypeName) > 0) then
    FPictureSprite := GUIManager.CreateSprite ('', FPictureName)
  else
    FPictureSprite := GUIManager.CreateSprite (WClassName, FPictureName);
  // change the bounds if valid sprite given
  if (FPictureSprite <> NIL) then
    FPictureBounds := CenterRect (LocalBounds,
      Rect (0, 0, FPictureSprite.Width, FPictureSprite.Height));
end;

///////////////////////////////////////////////////////////////////
procedure TZEPicturePanel.SetImage (AImage: IZESprite; ATag: integer);
begin
  // is this the same as current pic? then ignore
  if (FPictureSprite = AImage) then Exit;
  // remove the old sprite first
  FPictureSprite := NIL;
  StrDispose (FPictureName);
  // set new names and sprites
  FPictureName := StrNew (PChar (IntToStr (integer (AImage))));
  FPictureSprite := AImage;
  // change the bounds if valid sprite given
  if (FPictureSprite <> NIL) then
    FPictureBounds := FitRectInRect (
      Rect (0, 0, FPictureSprite.Width, FPictureSprite.Height),
      LocalBounds);
end;


{ TZECheckbox }

///////////////////////////////////////////////////////////////////
constructor TZECheckbox.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CHECKBOX;
  ClearGrowMode;
  SetGrowMode (gmGrowRight + gmGrowLeft);
  SetDragMode (dmResizeable);
  //
  FImgWidth := 0;
end;

///////////////////////////////////////////////////////////////////
procedure TZECheckbox.RefreshSprite;
var
  rArea: TRect;
begin
  inherited;
  //
  if (DefaultSprite <> NIL) then begin
    rArea := Bounds;
    rArea.Bottom := rArea.Top + DefaultSprite.Height;
    FImgWidth := DefaultSprite.Width;
    Bounds := rArea;
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZECheckbox.Paint;
var
  rArea: TRect;
  iBaseFrame: integer;
begin
  if (DefaultSprite <> NIL) then begin
    if (Checked) then
      iBaseFrame := 2
      else iBaseFrame := 0;
    //
    if (GetState (stDisabled)) then
      Inc (iBaseFrame);
    //
    DefaultSprite.CurrentFrame := iBaseFrame;
    rArea := Rect (0, 0, FImgWidth, Height);
    ImageFill (DefaultSprite, rArea);
    //
    if (Font <> NIL) then begin
      rArea := ClientToScreen (Rect (FImgWidth, 0, Width, Height));
      Font.WriteText (Surface, Caption, rArea);
    end;
  end;
end;


{ Helper Routines }

//////////////////////////////////////////////////////////////////////////////////////
function CreateStandardButton (rBounds: TRect; ACaption: string;
    ACommand: integer; AFont: TZEFont): TZEControl;
begin
  Result := CreateControl (CC_STANDARD_BUTTON, rBounds);
  if (Result <> NIL) then begin
    if (AFont <> NIL) then
      Result.Font := AFont
      else Result.SetPropertyValue (PROP_NAME_FONT_NAME, CC_STANDARD_BUTTON);
    //
    Result.SetPropertyValue (PROP_NAME_CAPTION, ACaption);
    Result.SetPropertyValue (PROP_NAME_COMMAND, IntToStr(ACommand));
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////
function CreatePanelButton (rBounds: TRect; ACaption, ASpriteName, APicture: string;
  ACommand: integer; AAutoPopup: boolean; AFont: string): TZEControl;
begin
  Result := CreateControl (CC_PICTURE_PANEL, rBounds);
  if (Result <> NIL) then begin
    //
    Result.SetPropertyValue (PROP_NAME_SPRITE_NAME, ASpriteName);
    if (ACaption = '') then
      Result.SetPropertyValue (PROP_NAME_SHOW_CAPTION, 'FALSE')
      else begin
        Result.SetPropertyValue (PROP_NAME_SHOW_CAPTION, 'TRUE');
        Result.SetPropertyValue (PROP_NAME_CAPTION, ACaption);
      end;
    //
    if (APicture <> '') then
      Result.SetPropertyValue (PROP_NAME_PICTURE, APicture);
    //
    if (ACommand <> 0) then
      Result.SetPropertyvalue (PROP_NAME_COMMAND, PChar (IntToStr (ACommand)));
    //
    Result.SetPropertyValue (PROP_NAME_AUTO_POPUP, IfThen (AAutoPopup, 'TRUE', 'FALSE'));
    //
    if (AFont <> '') then begin
      Result.SetStyle (syUseParentFont, false);
      Result.SetPropertyValue (PROP_NAME_FONT_NAME, AFont);
    end;
    //
  end;
end;


{ Registration }

///////////////////////////////////////////////////////////////////
procedure RegisterControls;
begin
  RegisterControlClass (CC_STANDARD_BUTTON, TZEStandardButton);
  RegisterControlClass (CC_ICON_BUTTON, TZEIconButton);
  RegisterControlClass (CC_PICTURE_BUTTON, TZEPictureButton);
  RegisterControlClass (CC_PUSH_PANEL, TZEPushPanel);
  RegisterControlClass (CC_PICTURE_PANEL, TZEPicturePanel);
  RegisterControlClass (CC_CHECKBOX, TZECheckbox);
end;


end.

