{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSMisc.PAS
              Contains other controls with no clear categories
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSMisc.pas,v 1.3 2002/12/18 08:15:19 Vij Exp $
  $Log: ZEWSMisc.pas,v $
  Revision 1.3  2002/12/18 08:15:19  Vij
  Added ScrollBar, TextBox and dialogs that make use of them.

  Revision 1.2  2002/11/02 06:48:10  Vij
  finally implement ScrollGauge.  also modified ScrollBox a bit to support
  dynamic scrolling later.

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSMisc;

interface

uses
  Windows,
  Classes,
  //
  ZblIEvents,
  ZEDXImage,
  ZEDXSpriteIntf,
  ZEWSBase,
  ZEWSSupport,
  ZEWSDefines,
  ZEWSStandard,
  ZEWSButtons;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGaugeStyle = (gsHorizontal, gsVertical);
  TZEGaugeDirection = (gdLeftToRight, gdRightToLeft, gdTopToBottom, gdBottomToTop);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomGauge = class (TZEControl)
  private
    FMin, FMax: integer;
    FCurrent, FRange: integer;
    FStyle: TZEGaugeStyle;
    FDirection: TZEGaugeDirection;
  protected
    procedure IValueChanged; virtual;
    procedure IStyleChanged; virtual;
    procedure SetMin (AMin: integer);
    procedure SetMax (AMax: integer);
    procedure SetCurrent (ACurrent: integer);
    procedure SetStyle (AStyle: TZEGaugeStyle);
    procedure SetDirection (ADirection: TZEGaugeDirection);
  public
    constructor Create (rBounds: TRect); override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    //properties
    property Min: integer read FMin write SetMin;
    property Max: integer read FMax write SetMax;
    property Current: integer read FCurrent write SetCurrent;
    property Style: TZEGaugeStyle read FStyle write SetStyle;
    property Direction: TZEGaugeDirection read FDirection write SetDirection;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEProgressGauge = class (TZECustomGauge)
  private
    FFilledRect: TRect;
    FFillColor: TColorRef;
  protected
    procedure IValueChanged; override;
    procedure IStyleChanged; override;
  public
    constructor Create (rBounds: TRect); override;
    procedure Paint; override;
    //
    property FillColor: TColorRef read FFillColor write FFillColor;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEProgressGaugeEnh = class (TZEProgressGauge)
  private
    FSpriteForFilled: IZESprite;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure Paint; override;
    procedure SetImage (AImageTypeName: string; ATag: integer); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEScrollGauge = class (TZECustomGauge)
  private
    FThumbRect: TRect;
    FRectBefore: TRect;
    FRectAfter: TRect;
    FOnChange: TZENotifyProc;
    FUpdateHandler: TZEClassHandler;
    //
  protected
    procedure IValueChanged; override;
    procedure IStyleChanged; override;
    procedure RecalcThumbsVert;
    procedure RecalcThumbsHoriz;
  public
    constructor Create (rBounds: TRect); override;
    //
    procedure Paint; override;
    procedure ChangeBounds (rBounds: TRect); override;
    //
    procedure MouseLeftClick (var Event: TZbEvent); override;
    //
    property OnChange: TZENotifyProc read FOnChange write FOnChange;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomScrollBox = class (TZEControl)
  private
    FItems: TStrings;
    FTopLine: integer;
    FMaxLines: integer;
    FLineHeight: integer;
    FLinesVisible: integer;
    FAutoScroll: Boolean;
    FOnItemsChanged: TZENotifyProc;
  protected
    procedure SetTopLine (ANewTopLine: integer);
    function GetLineCount: integer;
    procedure RecalcLinesVisible;
    procedure ItemsChanged;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure Paint; override;
    procedure ChangeBounds (rBounds: TRect); override;
    procedure SetFont (ANewFont: TZEFont); override;
    //
    procedure AddText (sText: string); overload;
    procedure AddText (Data: TStrings; bAppend: boolean = FALSE); overload;
    procedure ClearText;
    //
    property AutoScroll: Boolean read FAutoScroll write FAutoScroll;
    property TopLine: integer read FTopLine write SetTopLine;
    property LinesVisible: integer read FLinesVisible;
    property LineCount: integer read GetLineCount;
    property LineHeight: integer read FLineHeight;
    property OnItemsChanged: TZENotifyProc read FOnItemsChanged write FOnItemsChanged;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEScrollBox = class (TZECustomScrollBox)
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEScrollBarStyle = (sbsHorizontal, sbsVertical);

  TZEScrollBar = class (TZEGroupControl)
  private
    FStyle: TZEScrollBarStyle;
    FScrollWidth: Integer;
    FOnScrolled: TZENotifyProc;
    //
    FUpButton: TZEPicturePanel;
    FDownButton: TZEPicturePanel;
    FScroller: TZEScrollGauge;
  protected
    procedure StyleChanged;
    procedure SetStyle (Astyle: TZEScrollBarStyle);
    procedure Scrolled (bDecrease: boolean);
    procedure ScrollerChanged (Sender: TZEControl; lParam: Integer);
    //
    function GetCurrent: Integer;
    procedure SetCurrent (ACurrent: Integer);
    function GetMinimum: Integer;
    procedure SetMinimum (AMinimum: Integer);
    function GetMaximum: Integer;
    procedure SetMaximum (AMaximum: Integer);
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure HandleEvent (var Event: TZbEvent); override;
    procedure ChangeBounds (rBounds: TRect); override;
    //
    property ScrollerStyle: TZEScrollBarStyle read FStyle write SetStyle;
    property OnScrolled: TZENotifyProc read FOnScrolled write FOnScrolled;
    property Current: Integer read GetCurrent write SetCurrent;
    property Minimum: Integer read GetMinimum write SetMinimum;
    property Maximum: Integer read GetMaximum write SetMaximum;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETextBox = class (TZEGroupControl)
  private
    FIgnoreScrollEvents: Boolean;
    FTextView: TZEScrollBox;
    FScrollbar: TZEScrollBar;
  protected
    procedure ScrollBoxChanged (Sender: TZEControl; lParam: Integer);
    procedure ScrollerChanged (Sender: TZEControl; lParam: Integer);
    procedure ReAssignBounds;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure HandleEvent (var Event: TZbEvent); override;
    procedure ChangeBounds (rBounds: TRect); override;
    procedure Paint; override;
    //
    procedure ClearData;
    procedure LoadData (cData: String; bAppend: boolean = TRUE); overload;
    procedure LoadData (Items: TStrings; bAppend: boolean = TRUE); overload;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEPanelGroup = class (TZEGroupControl)
  private
    FPanels: TList;
    FRects: TList;
    FActivePanel: integer;
    FPanelsShown: integer;
    FFirstPanel: integer;
    FLastPanel: integer;
    FMinPanelWidth: integer;
    FPanelWidth: integer;
    //
    FTitle: TZEText;
    FShowCaptions: boolean;
    FOnPanelSelected: TZENotifyProc;
    //
    rButtonArea: TRect;
    FLocked: boolean;
  protected
    procedure ClearRectsList;
    procedure RecalcPanelSize;
    procedure RecalcPanelBounds;
    procedure RecalcPanelVisibility;
    procedure PanelSelected (APanel: TZEPicturePanel);
    procedure SetShowCaptions (bShowCaptions: boolean);
    function GetPanel (iIndex: integer): TZEPicturePanel;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure HandleEvent (var Event: TZbEvent); override;
    procedure Paint; override;
    procedure SetCaption (ACaption: string); override;
    //
    procedure BeginAddPanels;
    procedure AddPanel (AImageName: string; PanelCaption: string = '');
    procedure EndAddPanels;
    //
    // properties
    property ActivePanel: integer read FActivePanel;
    property MinPanelWidth: integer read FMinPanelWidth write FMinPanelWidth;
    property PanelWidth: integer read FPanelWidth;
    property ShowCaptions: boolean read FShowCaptions write SetShowCaptions;
    property OnPanelSelected: TZENotifyProc
      read FOnPanelSelected write FOnPanelSelected;
    property Panels [iIndex: integer]: TZEPicturePanel read GetPanel; default;
  end;

  procedure RegisterControls;


implementation

uses
  SysUtils,
  Math,
  JclGraphUtils,
  DirectDraw,
  ZbDebug,
  ZbRectClipper,
  ZbGameUtils,
  ZEDXFramework;


{ TZECustomGauge }

///////////////////////////////////////////////////////////////////
constructor TZECustomGauge.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_GAUGE;
  SpriteName := '';
  ClearGrowMode;
  SetGrowMode (gmGrowRight + gmGrowLeft + gmGrowTop + gmGrowBottom);
  SetDragMode (dmResizeable);
  //
  FMin := 0; FMax := 0;
  FRange := 0; FCurrent := 0;
  FStyle := gsHorizontal;
  FDirection := gdLeftToRight;
  BackColor := $0000FF;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomGauge.IValueChanged;
begin
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomGauge.IStyleChanged;
begin
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomGauge.SetMin (AMin: integer);
begin
  FMin := AMin;
  if (FMin > FMax) then
    FMax := FMin;
  if (FCurrent < FMin) then
    FCurrent := FMin;
  //
  FRange := FMax - FMin;
  IValueChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomGauge.SetMax (AMax: integer);
begin
  FMax := AMax;
  if (FMax < FMin) then
    FMin := FMax;
  if (FCurrent > FMax) then
    FCurrent := FMax;
  //
  FRange := FMax - FMin;
  IValueChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomGauge.SetCurrent (ACurrent: integer);
begin
  if ((ACurrent <> FCurrent) AND (ACurrent <= FMax) AND (ACurrent >= FMin)) then begin
    FCurrent := ACurrent;
    IValueChanged;
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomGauge.SetStyle (AStyle: TZEGaugeStyle);
begin
  if (AStyle <> FStyle) then begin
    FStyle := AStyle;
    IStyleChanged;
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomGauge.SetDirection (ADirection: TZEGaugeDirection);
begin
  if (ADirection <> FDirection) then begin
    FDirection := ADirection;
    if (FDirection in [gdLeftToRight, gdRightToLeft]) then
      Style := gsHorizontal
      else Style := gsVertical;
    //
    IStyleChanged;
  end;
end;

///////////////////////////////////////////////////////////////////
function TZECustomGauge.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_FILLER_IMAGE) then
    Result := ''
  else if (APropertyName = PROP_NAME_GAUGE_MIN) then
    Result := IntegerToProp (Min)
  else if (APropertyName = PROP_NAME_GAUGE_MAX) then
    Result := IntegerToProp (Max)
  else if (APropertyName = PROP_NAME_GAUGE_CURRENT) then
    Result := IntegerToProp (Current)
  else if (APropertyName = PROP_NAME_GAUGE_STYLE) then
    Result := IntegertoProp (Ord (Style))
  else if (APropertyName = PROP_NAME_GAUGE_DIRECTION) then
    Result := IntegerToProp (Ord (Direction))
  else
    Result := inherited GetPropertyValue (APropertyName);
  //
end;

///////////////////////////////////////////////////////////////////
function TZECustomGauge.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := TRUE;
  //
  if (APropertyName = PROP_NAME_FILLER_IMAGE) then
    SetImage (Value)
  else if (APropertyName = PROP_NAME_GAUGE_MIN) then
    Min := PropToInteger (Value)
  else if (APropertyName = PROP_NAME_GAUGE_MAX) then
    Max := PropToInteger (Value)
  else if (APropertyName = PROP_NAME_GAUGE_CURRENT) then
    Current := PropToInteger (Value)
  else if (APropertyName = PROP_NAME_GAUGE_STYLE) then
    Style := TZEGaugeStyle (PropToInteger (Value))
  else if (APropertyName = PROP_NAME_GAUGE_DIRECTION) then
    Direction := TZEGaugeDirection (PropToInteger (Value))
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
  //
end;


{ TZEProgressGauge }

///////////////////////////////////////////////////////////////////
constructor TZEProgressGauge.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_PROGRESS_GAUGE;
  //
  FFilledRect := NullRect;
  FillColor := $FF0000;
end;

///////////////////////////////////////////////////////////////////
procedure TZEProgressGauge.IValueChanged;
var
  iGap: integer;
begin
  if (FRange <= 0) then exit;
  //
  if (FStyle = gsHorizontal) then
    begin
      iGap := integer (Round (Width * (FCurrent / FRange)));
      if (FDirection = gdLeftToRight) then
        FFilledRect := Rect (0, 0, iGap, Height)
      else if (FDirection = gdRightToLeft) then
        FFilledRect := Rect (Width - iGap, 0, Width, Height);
    end
  //
  else (* gsVertical *)
    begin
      iGap := integer (Round (Height * (FCurrent / FRange)));
      if (FDirection = gdTopToBottom) then
        FFilledRect := Rect (0, 0, Width, iGap)
      else if (FDirection = gdBottomToTop) then
        FFilledRect := Rect (0, Height - iGap, Width, Height);
    end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEProgressGauge.IStyleChanged;
begin
  IValueChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZEProgressGauge.Paint;
var
  hdcSurface  : HDC;
begin
  if (Surface <> NIL) then
    if (Surface.GetDC (hdcSurface) = DD_OK) then begin
      DCDrawRect (hdcSurface, BackColor, LocalBounds);
      DCDrawRect (hdcSurface, FillColor, FFilledRect);
      Surface.ReleaseDC (hdcSurface);
    end;
  //
end;


{ TZEProgressGaugeEnh }

///////////////////////////////////////////////////////////////////
constructor TZEProgressGaugeEnh.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_PROGRESS_GAUGE_ENH;
  FSpriteForFilled := NIL;
end;

///////////////////////////////////////////////////////////////////
destructor TZEProgressGaugeEnh.Destroy;
begin
  FSpriteForFilled := NIL;
  inherited;
end;

///////////////////////////////////////////////////////////////////
procedure TZEProgressGaugeEnh.Paint;
begin
  if (Surface = NIL) then Exit;
  if (DefaultSprite <> NIL) then ImageFill (DefaultSprite, LocalBounds);
  if (FSpriteForFilled <> NIL) then ImageFill (FSpriteForFilled, FFilledRect);
end;

///////////////////////////////////////////////////////////////////
procedure TZEProgressGaugeEnh.SetImage (AImageTypeName: string; ATag: integer);
begin
  FSpriteForFilled := NIL;
  //
  // don't use WClassName if picturename contains '/' already
  if (Pos ('/', AImageTypeName) > 0) then
    FSpriteForFilled := GUIManager.CreateSprite ('', AImageTypeName)
  else
    FSpriteForFilled := GUIManager.CreateSprite (WClassName, AImageTypeName);
end;


{ TZEScrollGauge }

const
  MIN_THUMB_SIZE = 8;

///////////////////////////////////////////////////////////////////
constructor TZEScrollGauge.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_SCROLL_GAUGE;
  ChangeMouseEventMask ([evLBtnDown, evLBtnUp, evLBtnAuto, evMouseMove]);
  //
  FOnChange := NIL;
  FUpdateHandler := NIL;
  IStyleChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollGauge.Paint;
var
  hdcSurface  : HDC;
begin
  if (Surface <> NIL) AND (Surface.GetDC (hdcSurface) = DD_OK) then begin
    //
    DCDraw3DFrame (hdcSurface, ClientToScreen (FRectBefore), TRUE);
    DCDraw3DFrame (hdcSurface, ClientToScreen (FThumbRect), FALSE);
    DCDraw3DFrame (hdcSurface, ClientToScreen (FRectAfter), TRUE);
    //
    Surface.ReleaseDC (hdcSurface);
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollGauge.ChangeBounds (rBounds: TRect);
begin
  inherited ChangeBounds (rBounds);
  IValueChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollGauge.MouseLeftClick (var Event: TZbEvent);
var
  Pt: TPoint;
begin
  // do nothing if we're disabled
  if (GetState (stDisabled)) then exit;
  Pt := ScreenToClient (Event.m_Pos);
  if (PtInRect (FRectBefore, Pt)) then
    Current := EnsureRange (FCurrent - 1, FMin, FMax)
  else if (PtInRect (FRectAfter, Pt)) then
    Current := EnsureRange (FCurrent + 1, FMin, FMax);
  //
  IValueChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollGauge.RecalcThumbsVert;
var
  iHeight: integer;
  iThumb, iSpaceAbove, iSpaceBelow: integer;
begin
  // calculate spans of this control
  iHeight := Height;
  //
  if (FRange > 0) then begin
    //
    // calculate dimension for thumb
    iThumb := Round (iHeight / FRange);
    if (iThumb < MIN_THUMB_SIZE) then begin
      iThumb := Math.Min (MIN_THUMB_SIZE, iHeight);
      Dec (iHeight, iThumb);
    end;
    //
    // calculate slack space before thumb
    iSpaceAbove := Round (((FCurrent - FMin) / FRange) * iHeight);
    if (iSpaceAbove > iHeight) then iSpaceAbove := iHeight;
    // calculate slack space after the thumb
    iSpaceBelow := iHeight - iSpaceAbove;
    if (iSpaceBelow < 0) then iSpaceBelow := 0;
    // swap slack spaces if reversed direction
    if (FDirection = gdBottomToTop) then iSpaceAbove := iSpaceBelow;
  end else begin
    iThumb := iHeight;
    iSpaceAbove := 0;
  end;
  // create the rectangles
  FRectBefore := Rect (0, 0, Width, iSpaceAbove);
  FThumbRect := Rect (0, iSpaceAbove, Width, iSpaceAbove + iThumb);
  FThumbRect := ExpandRect (FThumbRect, 0, 1);
  FRectAfter := Rect (0, iSpaceAbove + iThumb, Width, Height);
  //
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollGauge.RecalcThumbsHoriz;
var
  iWidth: integer;
  iThumb, iSpaceLeft, iSpaceRight: integer;
begin
  // calculate spans of this control
  iWidth := Width;
  //
  if (FRange > 0) then begin
    //
    // calculate dimension for thumb
    iThumb := Round (iWidth / FRange);
    if (iThumb < MIN_THUMB_SIZE) then begin
      iThumb := Math.Min (MIN_THUMB_SIZE, iWidth);
      Dec (iWidth, iThumb);
    end;
    //
    // calculate slack space before thumb
    iSpaceLeft := Round (((FCurrent - FMin) / FRange) * iWidth);
    if (iSpaceLeft > iWidth) then iSpaceLeft := iWidth;
    // calculate slack space after the thumb
    iSpaceRight := iWidth - iSpaceLeft;
    if (iSpaceRight < 0) then iSpaceRight := 0;
    // swap slack spaces if reversed direction
    if (FDirection = gdRightToLeft) then iSpaceLeft := iSpaceRight;
    //
  end else begin
    iThumb := iWidth;
    iSpaceLeft := 0;
  end;
  // create the rectangles
  FRectBefore := Rect (0, 0, iSpaceLeft, Height);
  FThumbRect := Rect (iSpaceLeft, 0, iSpaceLeft + iThumb, Height);
  FThumbRect := ExpandRect (FThumbRect, 1, 0);
  FRectAfter := Rect (iSpaceLeft + iThumb, 0, Width, Height);
  //
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollGauge.IValueChanged;
begin
  if (Assigned (FUpdateHandler)) then FUpdateHandler;
  if (Assigned (FOnChange)) then
    FOnChange (Self, FCurrent)
    else g_EventManager.Commands.Insert (cmScrollerUpdated, FCurrent, 0);
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollGauge.IStyleChanged;
begin
  if (FStyle = gsHorizontal) then
    FUpdateHandler := RecalcThumbsHoriz
    else FUpdateHandler := RecalcThumbsVert;
  //
  IValueChanged;
end;


{ TZECustomScrollBox }

///////////////////////////////////////////////////////////////////
constructor TZECustomScrollBox.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_SCROLLBOX;
  ClearGrowMode;
  SetGrowMode (gmGrowRight + gmGrowLeft + gmGrowTop + gmGrowBottom);
  SetDragMode (dmResizeable);
  BackColor := $005500;
  //
  FItems := TStringList.Create;
  FTopLine := 0;
  FMaxLines := 0;
  FLineHeight := 0;
  FLinesVisible := 0;
  FAutoScroll := TRUE;
  FOnItemsChanged := NIL;
  //
  RecalcLinesVisible;
end;

///////////////////////////////////////////////////////////////////
destructor TZECustomScrollBox.Destroy;
begin
  FreeAndNIL (FItems);
  inherited;
end;

///////////////////////////////////////////////////////////////////
function TZECustomScrollBox.SetPropertyValue (APropertyName, Value: string): boolean;
var
  strList: TStrings;
begin
  if (APropertyName = PROP_NAME_AUTO_SCROLL) then begin
    Result := TRUE;
    FAutoScroll := PropToBoolean (Value);
  end else if (APropertyName = PROP_NAME_TEXT_TO_ADD) then begin
    Result := TRUE;
    AddText (Value);
  end else if (APropertyName = PROP_NAME_FILE_TO_LOAD) then begin
    Result := FileExists (Value);
    if (NOT Result) then Exit;
    //
    strList := TStringList.Create;
    try
      strList.LoadFromFile (Value);
      AddText (strList);
    finally
      strList.Free;
    end;
  end else
    Result := inherited SetPropertyValue (APropertyName, Value);
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.SetTopLine (ANewTopLine: integer);
begin
  if (ANewTopLine < 0) OR (ANewTopLine >= FItems.Count) then Exit;
  FTopLine := ANewTopLine;
end;

///////////////////////////////////////////////////////////////////
function TZECustomScrollBox.GetLineCount: integer;
begin
  Result := FItems.Count;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.RecalcLinesVisible;
begin
  if (FLineHeight <= 0) then
    FLinesVisible := 0
  else begin
    FLinesVisible := Height div FLineHeight;
    if (FLinesVisible < 0) then FLinesVisible := 1;
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.ItemsChanged;
begin
  if (Assigned (FOnItemsChanged)) then FOnItemsChanged (Self, FTopLine);
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.Paint;
var
  iAnchor, iIndex, iLastLine: integer;
  rArea: TRect;
  hdcSurface  : HDC;
begin
  if (Surface = NIL) OR (Font = NIL) OR (Surface.GetDC (hdcSurface) <> DD_OK) then exit;
  //
  iAnchor := 0;
  iLastLine := Min (FTopLine + FLinesVisible + 1, Pred (FItems.Count));
  for iIndex := FTopLine to iLastLine do begin
    rArea := ClientToScreen (Rect (0, iAnchor, Width, iAnchor + FLineHeight));
    GlobalClipper.PerformClipping (rArea);
    if (NOT IsRectEmpty (rArea)) then
      Font.WriteText (hdcSurface, FItems [iIndex], rArea);
    //
    Inc (iAnchor, FLineHeight);
  end;
  //
  Surface.ReleaseDC (hdcSurface);
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.ChangeBounds (rBounds: TRect);
begin
  inherited ChangeBounds (rBounds);
  RecalcLinesVisible;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.SetFont (ANewFont: TZEFont);
begin
  inherited SetFont (ANewFont);
  if (Font <> NIL) then
    FLineHeight := Font.Height + 2  { 2 is a fudge factor }
    else FLineHeight := 0;
  //
  RecalcLinesVisible;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.AddText (sText: string);
var
  iLineCount: integer;
  Event: TZbEvent;
begin
  // remove oldest line if we have a hard limit
  if (FMaxLines > 0) AND (FItems.Count >= FMaxLines) then FItems.Delete (0);
  // add the new text...
  FItems.Add (sText);
  // if we don't need to auto-scroll, don't do anything right now
  // exit also if line height is <= 0, this happens if there is no font assigned
  if (FAutoScroll) AND (FLineHeight > 0) then begin
    // recalculate top line, we might need to scroll down
    iLineCount := FItems.Count;
    if (iLineCount < FLinesVisible) then
      FTopLine := 0
    else begin
      FTopLine := iLineCount - FLinesVisible;
      if (FTopLine < 0) then FTopLine := 0;
      if (FTopLine >= iLineCount) then FTopLine := Pred (iLineCount);
    end;
    // send the parent our scroll message
    if (Parent <> NIL) then begin
      MakeCommandEvent (Event, cmScrollBoxChanged, FTopLine);
      Parent.HandleEvent (Event);
    end;
  end;
  //
  ItemsChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.AddText (Data: TStrings; bAppend: boolean);
begin
  if (NOT bAppend) then begin
    FItems.Clear;
    FTopLine := 0;
  end;
  FItems.AddStrings (Data);
  ItemsChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZECustomScrollBox.ClearText;
begin
  FItems.Clear;
  FTopLine := 0;
end;


{ TZEScrollBar }

const
  SB_MIN_WIDTH = 16;

///////////////////////////////////////////////////////////////////
constructor TZEScrollBar.Create (rBounds: TRect);

begin
  inherited;
  WClassName := CC_SCROLLBAR;
  //
  FStyle := sbsHorizontal;
  FOnScrolled := NIL;
  //
  FUpButton := TZEPicturePanel.Create (LocalBounds);
  FUpButton.Command := cmPanelClicked;
  FUpButton.AutoPopup := TRUE;
  FUpButton.GroupId := 17;
  //
  FDownButton := TZEPicturePanel.Create (LocalBounds);
  FDownButton.Command := cmPanelClicked;
  FDownButton.AutoPopup := TRUE;
  FDownButton.GroupId := 17;
  //
  FScroller := TZEScrollGauge.Create (LocalBounds);
  FScroller.OnChange := ScrollerChanged;
  //
  Insert (FScroller);
  Insert (FUpButton);
  Insert (FDownButton);
  //
  Minimum := 0;
  Maximum := 0;
  Current := 0;
  StyleChanged;
end;

///////////////////////////////////////////////////////////////////
destructor TZEScrollBar.Destroy;
begin
  inherited;
end;


///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.HandleEvent (var Event: TZbEvent);
begin
  inherited;
  if (Event.m_Event = evCommand) AND (Event.m_Command = cmPanelClicked) then begin
    Scrolled (TZEControl (Event.m_pData) = FUpButton);
    ClearEvent (Event);
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.ChangeBounds (rBounds: TRect);
begin
  inherited;
  if (FUpButton = NIL) OR (FDownButton = NIL) OR (FScroller = NIL) then Exit;
  StyleChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.StyleChanged;
var
  Left, Right: Integer;
  Top: Integer absolute Left;
  Bottom: Integer absolute Right;
begin
  if (FStyle = sbsHorizontal) then begin
    // horizontal scrollbar
    // ---
    // calculate dimension of scroll gauge
    FScrollWidth := Min (SB_MIN_WIDTH, Height);
    Left := FScrollWidth;
    Right := Width - FScrollWidth;
    // modify the style of the scroll gauge
    FScroller.Style := gsHorizontal;
    FScroller.Direction := gdLeftToRight;
    // assign new rects...
    FScroller.Bounds := Rect (Left, 0, Right, Height);
    FUpButton.Bounds := Rect (0, 0, Left, Height);
    FDownButton.Bounds := Rect (Right, 0, Width, Height);
  end else begin
    // vertical scrollbar
    // ---
    // calculate dimension of scroll gauge
    FScrollWidth := Min (SB_MIN_WIDTH, Width);
    Top := FScrollWidth;
    Bottom := Height - FScrollWidth;
    // modify the style of the scroll gauge
    FScroller.Style := gsVertical;
    FScroller.Direction := gdTopToBottom;
    // assign new rects
    FScroller.Bounds := Rect (0, Top, Width, Bottom);
    FUpButton.Bounds := Rect (0, 0, Width, Top);
    FDownButton.Bounds := Rect (0, Bottom, Width, Height);
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.SetStyle (Astyle: TZEScrollBarStyle);
begin
  if (FStyle = AStyle) then Exit;
  FStyle := AStyle;
  StyleChanged;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.Scrolled (bDecrease: boolean);
begin
  // spot unnecessary changes...
  if (bDecrease AND (Current = Minimum)) OR
     ((NOT bDecrease) AND (Current = Maximum)) then Exit;
  // change the scroll value accordingly
  if (bDecrease) then
    Current := Pred (Current)
    else Current := Succ (Current);
  //
  ScrollerChanged (FScroller, Current);
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.ScrollerChanged (Sender: TZEControl; lParam: Integer);
var
  Event: TZbEvent;
begin
  // send the parent our scroll message
  if (Parent <> NIL) then begin
    MakeCommandEvent (Event, cmScrollBarChanged, Current);
    Parent.HandleEvent (Event);
  end;
  // also send it to the registered handler, if any
  if (Assigned (FOnScrolled)) then FOnScrolled (Self, Current);
end;

///////////////////////////////////////////////////////////////////
function TZEScrollBar.GetCurrent: Integer;
begin
  Result := FScroller.Current;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.SetCurrent (ACurrent: Integer);
begin
  FScroller.Current := ACurrent;
end;

///////////////////////////////////////////////////////////////////
function TZEScrollBar.GetMinimum: Integer;
begin
  Result := FScroller.Min;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.SetMinimum (AMinimum: Integer);
begin
  FScroller.Min := AMinimum;
end;

///////////////////////////////////////////////////////////////////
function TZEScrollBar.GetMaximum: Integer;
begin
  Result := FScroller.Max;
end;

///////////////////////////////////////////////////////////////////
procedure TZEScrollBar.SetMaximum (AMaximum: Integer);
begin
  FScroller.Max := AMaximum;
end;


{ TZETextBox }

const
  TXT_BOX_SCROLLBAR_WIDTH = 15;

///////////////////////////////////////////////////////////////////
constructor TZETextBox.Create (rBounds: TRect);
begin
  inherited;
  WClassName := CC_TEXT_BOX;
  //
  FIgnoreScrollEvents := FALSE;
  FTextView := TZEScrollBox.Create (
    Rect (0, 0, Width - TXT_BOX_SCROLLBAR_WIDTH, Height));
  FTextView.OnItemsChanged := ScrollBoxChanged;
  //
  FScrollbar := TZEScrollBar.Create (
    Rect (Width - TXT_BOX_SCROLLBAR_WIDTH, 0, Width, Height));
  FScrollBar.ScrollerStyle := sbsVertical;
  //FScrollBar.OnScrolled := ScrollerChanged;
  //
  Insert (FTextView);
  Insert (FScrollbar);
  ReAssignBounds;
end;

///////////////////////////////////////////////////////////////////
destructor TZETextBox.Destroy;
begin
  inherited;
end;

///////////////////////////////////////////////////////////////////
function TZETextBox.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  if (APropertyName = PROP_NAME_AUTO_SCROLL) OR
    (APropertyName = PROP_NAME_TEXT_TO_ADD) OR
    (APropertyName = PROP_NAME_FILE_TO_LOAD) then
    Result := FTextView.SetPropertyValue (APropertyName, Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
  //
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.ScrollBoxChanged (Sender: TZEControl; lParam: Integer);
var
  ScrollMax, ItemsCount, ItemsVisible: Integer;
begin
  FIgnoreScrollEvents := TRUE;
  //
  ItemsCount := FTextView.FItems.Count;
  ItemsVisible := FTextView.FLinesVisible;
  //FTextView.FTopLine := 0;
  if (ItemsCount > ItemsVisible) then
    ScrollMax := ItemsCount - ItemsVisible
    else ScrollMax := 0;
  //
  FScrollBar.Minimum := 0;
  FScrollBar.Maximum := ScrollMax;
  FScrollBar.Current := FTextView.FTopLine;
  //
  FIgnoreScrollEvents := FALSE;
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.ScrollerChanged (Sender: TZEControl; lParam: Integer);
begin
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.ReAssignBounds;
var
  rSubControlArea: TRect;
begin
  rSubControlArea := ExpandRect (LocalBounds, -2, -2);
  with rSubControlArea do begin
    FTextView.Bounds := Rect (Left, Top, Right - TXT_BOX_SCROLLBAR_WIDTH, Bottom);
    FScrollbar.Bounds := Rect (Right - TXT_BOX_SCROLLBAR_WIDTH, Top, Right, Bottom);
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.HandleEvent (var Event: TZbEvent);
begin
  inherited;
  if (Event.m_Event = evCommand) then begin
    if (Event.m_Command = cmScrollBarChanged) then begin
      if (NOT FIgnoreScrollEvents) then FTextView.TopLine := Event.m_lParam;
      ClearEvent (Event);
    end else if (Event.m_Command = cmScrollBoxChanged) then begin
      //FScrollbar.Current := FTextView.TopLine;
      //ClearEvent (Event);
    end;
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.ChangeBounds (rBounds: TRect);
begin
  inherited;
  if (FScrollbar = NIL) OR (FTextView = NIL) then Exit;
  ReAssignBounds;
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.Paint;
var
  hdcSurface: HDC;
begin
  inherited;
  if (Surface <> NIL) AND (Surface.GetDC (hdcSurface) = DD_OK) then begin
    DCDraw3DFrame (hdcSurface, ClientToScreen (LocalBounds), TRUE);
    Surface.ReleaseDC (hdcSurface);
  end;
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.ClearData;
begin
  FTextView.ClearText;
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.LoadData (cData: String; bAppend: boolean);
begin
  if (NOT bAppend) then ClearData;
  FTextView.AddText (cData);
end;

///////////////////////////////////////////////////////////////////
procedure TZETextBox.LoadData (Items: TStrings; bAppend: boolean);
begin
  if (NOT bAppend) then ClearData;
  FTextView.AddText (Items);
end;


{ TZEPanelGroup }

///////////////////////////////////////////////////////////////////
constructor TZEPanelGroup.Create (rBounds: TRect);
var
  R: TRect;
  CC: TZEControl; // child control to insert
  PP: TZEPicturePanel;
const
  PG_MARGIN           = 4;
  PG_TITLE_HEIGHT     = 18;
  PG_ARROW_WIDTH      = 20;
begin
  inherited Create (rBounds);
  WClassName := CC_PANEL_GROUP;
  //
  FActivePanel := -1;
  FPanels := TList.Create;
  FRects := TList.Create;
  FPanelsShown := 0;
  FFirstPanel := -1;
  FLastPanel := -1;
  FMinPanelWidth := 10;
  FPanelWidth := FMinPanelWidth;
  FShowCaptions := false;
  FLocked := false;
  //
  // the wallpaper and the background
  CC := TZEWallpaper.Create (LocalBounds);
  CC.SpriteName := WClassName;
  Insert (CC);
  CC := TZEWinBorders.Create (LocalBounds);
  CC.SpriteName := WClassName;
  Insert (CC);
  //
  // create and insert the title header
  R := ExpandRect (LocalBounds, -PG_MARGIN, -PG_MARGIN);
  FTitle := TZEText.Create (Rect (R.Left, R.Top, R.Right, R.Top + PG_TITLE_HEIGHT));
  Insert (FTitle);
    FTitle.Hide;
    //Inc (R.Top, PG_TITLE_HEIGHT);
  //
  // create and insert the left arrow panel
  PP := TZEPicturePanel.Create (
    Rect (R.Left, R.Top, R.Left + PG_ARROW_WIDTH, R.Bottom));
  PP.AutoPopup := true;
  PP.Command := cmPBSelectPrevious;
  PP.SpriteName := WClassName;
  PP.SetImage ('LeftArrow');
  Insert (PP);
  //
  // create and insert the right arrow panel
  PP := TZEPicturePanel.Create (
    Rect (R.Right-PG_ARROW_WIDTH, R.Top, R.Right, R.Bottom));
  PP.AutoPopup := true;
  PP.Command := cmPBSelectNext;
  PP.SpriteName := WClassName;
  PP.SetImage ('RightArrow');
  Insert (PP);
  //
  FOnPanelSelected := NIL;
  //
  Inc (R.Left, PG_ARROW_WIDTH);
  Dec (R.Right, PG_ARROW_WIDTH);
  rButtonArea := R;
end;

///////////////////////////////////////////////////////////////////
destructor TZEPanelGroup.Destroy;
begin
  FTitle := NIL;
  FreeAndNIL (FPanels);
  ClearRectsList;
  inherited;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.ClearRectsList;
var
  iIndex: integer;
  PR: PRect;
begin
  for iIndex := 0 to FRects.Count-1 do
    begin
      PR := PRect (FRects [iIndex]);
      if (PR <> NIL) then
        begin
          Dispose (PR);
          FRects [iIndex] := NIL;
        end;
    end;
  //
  FRects.Clear;
end;

///////////////////////////////////////////////////////////////////
// used to recalculate how many panels will actually fit
// in the panelgroup area
procedure TZEPanelGroup.RecalcPanelSize;
var
  WTotal, WSpan, W: integer;
  iNumPanels, iFudge, iLeft: integer;
  PR: PRect;
begin
  if ((FLocked) OR (FPanels.Count <= 0)) then exit;
  //
  WTotal := rButtonArea.Right - rButtonArea.Left;
  iNumPanels := FPanels.Count;
  WSpan := 0;
  while (true) do
    begin
      WSpan := WTotal div iNumPanels;
      if (WSpan >= FMinPanelWidth) then break;
      Dec (iNumPanels);
      if (iNumPanels <= 0) then break;
    end;
  //
  FPanelsShown := iNumPanels;
  FFirstPanel := 0;
  FLastPanel := FFirstPanel + (FPanelsShown - 1);
  if (FLastPanel > (FPanels.Count-1)) then
    FLastPanel := FPanels.Count-1;
  //
  iFudge := WTotal - (FPanelsShown * WSpan);
  ClearRectsList;
  //
  W := 0;
  iLeft := rButtonArea.Left;
  while (WTotal > 0) do
    begin
      Inc (iLeft, W);
      //
      W := WSpan;
      if (iFudge > 0) then
        begin Inc (W); Dec (iFudge); end;
      //
      Dec (WTotal, W);
      if (WTotal < WSpan) then
        begin Inc (WSpan, WTotal); WTotal := 0; end;
      //
      New (PR);
      PR^ := Rect (iLeft, rButtonArea.Top, iLeft+ W, rButtonArea.Bottom);
      FRects.Add (Pointer (PR));
      //
    end;
  //
  RecalcPanelVisibility;
end;

///////////////////////////////////////////////////////////////////
// used to recalculate bounds of panels shown
procedure TZEPanelGroup.RecalcPanelBounds;
var
  iIndex, iPos: integer;
  PR: PRect;
begin
  // now show those who should be visible
  iPos := 0;
  for iIndex := FFirstPanel to FLastPanel do
    begin
      if (iPos >= FRects.Count) then break;
      //
      PR := PRect (FRects [iPos]);
      Inc (iPos);
      if (PR <> NIL) then
        TZEPicturePanel (FPanels [iIndex]).ChangeBounds (PR^);
    end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.RecalcPanelVisibility;
var
  iIndex: integer;
begin
  //
  // hide everyone first
  for iIndex := 0 to FPanels.Count-1 do
    TZEPicturePanel (FPanels [iIndex]).Hide;
  //
  // now show those who should be visible
  for iIndex := FFirstPanel to FLastPanel do
    TZEPicturePanel (FPanels [iIndex]).Show;
  //
  // done with visibility, recalc their bounds
  RecalcPanelBounds;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.PanelSelected (APanel: TZEPicturePanel);
var
  iIndex: integer;
begin
  FActivePanel := -1;
  if (APanel <> NIL) then
    begin
      for iIndex := 0 to FPanels.Count-1 do
        if (TZEPicturePanel(FPanels [iIndex]) = APanel) then
          begin
            FActivePanel := iIndex;
            break;
          end;
        // end if
      // end for
    end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.SetShowCaptions (bShowCaptions: boolean);
var
  iIndex: integer;
begin
  if (FShowCaptions = bShowCaptions) then Exit;
  //
  // remember this new setting
  FShowCaptions := bShowCaptions;
  //
  // toggle them all
  for iIndex := 0 to FPanels.Count-1 do
    TZEPicturePanel (FPanels [iIndex]).ShowCaption := FShowCaptions;

end;

///////////////////////////////////////////////////////////////////
function TZEPanelGroup.GetPanel (iIndex: integer): TZEPicturePanel;
begin
  if (iIndex >= 0) AND (iIndex < FPanels.Count) then
    Result := TZEPicturePanel (FPanels [iIndex])
  else
    Result := NIL;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.HandleEvent (var Event: TZbEvent);
var
  Panel: TZEPicturePanel;
begin
  inherited HandleEvent (Event);
  if (Event.m_Event = evCOMMAND) then
    case Event.m_Command of
      cmPanelClicked:
        begin
          Panel := TZEPicturePanel (Event.m_pData);
          PanelSelected (Panel);
          ClearEvent (Event);
          //
          // notify any interested party of the selection...
          if (Assigned (FOnPanelSelected)) then
            FOnPanelSelected (Self, FActivePanel);
          //
          // we may need to post our action here
          if (ActionName <> NIL) then
            begin
              Event.m_Event := evCOMMAND;
              Event.m_Command := cmGlobalCommandPerformAction;
              Event.m_pData := Pointer (Self);
              Event.m_lParam := FActivePanel;
              Parent.HandleEvent (Event);
              ClearEvent (Event);
            end;
        end;
      cmPBSelectNext:
        begin
          if (FLastPanel < (FPanels.Count-1)) then
            begin
              Inc (FFirstPanel);
              Inc (FLastPanel);
              RecalcPanelVisibility;
            end;
          ClearEvent (Event);
        end;
      cmPBSelectPrevious:
        begin
          if (FFirstPanel > 0) then
            begin
              Dec (FFirstPanel);
              FLastPanel := FFirstPanel + (FPanelsShown - 1);
              if (FLastPanel >= FPanels.Count) then
                FLastPanel := FPanels.Count-1;
              //
              RecalcPanelVisibility;
            end;
          ClearEvent (Event);
        end;
    end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.Paint;
begin
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.SetCaption (ACaption: string);
begin
  inherited SetCaption (ACaption);
  FTitle.Caption := ACaption;
  if (ACaption = '') then
    begin
      rButtonArea.Top := FTitle.Bounds.Top;
      FTitle.Hide;
      RecalcPanelSize;
    end
  else
    begin
      rButtonArea.Top := FTitle.Bounds.Bottom;
      FTitle.Show;
      RecalcPanelSize;
    end;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.BeginAddPanels;
begin
  FLocked := true;
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.AddPanel (AImageName: string; PanelCaption: string);
var
  Panel: TZEPicturePanel;
begin
  // if there is no image AND there is no caption, we can't possibly
  // use this panel -- ignore the add request
  if (AImageName = '') AND (PanelCaption = '') then exit;
  //
  // add a new panel to the group
  Panel := TZEPicturePanel.Create (EmptyRect);
  if (Panel = NIL) then exit;
  Panel.SpriteName := WClassName;
  Panel.SetImage (AImageName);
  Panel.Command := cmPanelClicked;
  Panel.GroupId := 1975;
  Panel.Caption := PanelCaption;
  Panel.ShowCaption := FShowCaptions;
  Insert (Panel);
  FPanels.Add (Pointer (Panel));
  Panel.Hide;
  //
  RecalcPanelSize;
  // first panel inserted? make it the default then
  if (FPanels.Count = 1) then
    begin
      Panel.Pressed := true;
      PanelSelected (Panel);
    end;
  //
end;

///////////////////////////////////////////////////////////////////
procedure TZEPanelGroup.EndAddPanels;
begin
  FLocked := false;
  RecalcPanelSize;
end;


{ Registration }

///////////////////////////////////////////////////////////////////
procedure RegisterControls;
begin
  {$IFDEF REGISTER_ALL_CLASSES}
  RegisterControlClass (CC_CUSTOM_GAUGE, TZECustomGauge);
  RegisterControlClass (CC_CUSTOM_SCROLLBOX, TZECustomScrollBox);
  {$ENDIF}
  RegisterControlClass (CC_PROGRESS_GAUGE, TZEProgressGauge);
  RegisterControlClass (CC_PROGRESS_GAUGE_ENH, TZEProgressGaugeEnh);
  RegisterControlClass (CC_SCROLL_GAUGE, TZEScrollGauge);
  RegisterControlClass (CC_SCROLLBAR, TZEScrollBar);
  RegisterControlClass (CC_TEXT_BOX, TZETextBox);
  RegisterControlClass (CC_PANEL_GROUP, TZEPanelGroup);
end;


end.




