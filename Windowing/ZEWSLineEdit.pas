{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSLineEdit.PAS
              Contains editing controls
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSLineEdit.pas,v 1.2 2002/11/02 06:47:25 Vij Exp $
  $Log: ZEWSLineEdit.pas,v $
  Revision 1.2  2002/11/02 06:47:25  Vij
  added divider comments

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSLineEdit;

interface

uses
  Windows,
  Classes,
  //
  ZblIEvents,
  ZEDXImage,
  ZEWSBase,
  ZEWSSupport,
  ZEWSDefines,
  ZEWSStandard;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomEdit = class (TZEControl)
  private
    FLeftPos: integer;
    FCurPos: integer;
    FOldConsoleMode: boolean;
    FTextBounds: TRect;
    FCurLen: integer;
    FTextExtentMax: integer;
    FBackBrush: HBRUSH;
  protected
    function CharValid (CKey: Char): boolean; virtual;
    function ValidateEntry (CEntry: string): boolean; virtual;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure HandleEvent (var Event: TZbEvent); override;
    procedure BeginModal (AOnEndModal: TZENotifyProc); override;
    procedure EndModal; override;
    //
    procedure MouseLeftClick (var Event: TZbEvent); override;
    procedure MouseLeftRelease (var Event: TZbEvent); override;
    //
    procedure Paint; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEdit = class (TZECustomEdit)
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZENumericEdit = class (TZECustomEdit)
  private
    FMaximum: integer;
    FMinimum: integer;
  protected
    function CharValid (CKey: Char): boolean; override;
    function ValidateEntry (CEntry: string): boolean; override;
    function GetValue: integer;
  public
    constructor Create (rBounds: TRect); override;
    //
    function GetPropertyValue (APropertyName: string): string; override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    // properties
    property Maximum: integer read FMaximum write FMaximum;
    property Minimum: integer read FMinimum write FMinimum;
    property Value: integer read GetValue;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function CreateEdit (rBounds: TRect; AFont: TZEFont = NIL): TZEEdit;
  function CreateNumericEdit (rBounds: TRect; AMinimum, AMaximum: integer;
    AFont: TZEFont = NIL): TZENumericEdit;

  procedure RegisterControls;
  

implementation


uses
  SysUtils,
  DirectDraw,
  ZbGameUtils,
  ZEDXFramework;


//////////////////////////////////////////////////////////
constructor TZECustomEdit.Create (rBounds: TRect);
var
  LogBrush: TLogBrush;
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_EDIT_CONTROL;
  SpriteName := 'Cursor';
  SetStyle (syUseParentFont, false);
  ChangeMouseEventMask ([evLBtnDown, evLBtnUp]);
  //
  FTextBounds := ExpandRect (LocalBounds, -2, -2);
  Dec (FTextBounds.Right, 5);  // margin of error for the cursor
  FTextExtentMax := FTextBounds.Right - FTextBounds.Left;
  //
  FLeftPos := 0;  FCurPos := 0;  FCurLen := 0;
  FOldConsoleMode := FALSE;
  BackColor := $755251;
  //
  // this portion creates the solid brush
  with LogBrush do begin
    lbHatch := 0;
    lbColor := BackColor;
    lbStyle := BS_SOLID;
  end;
  //
  FBackBrush := CreateBrushIndirect (LogBrush);
  Font := GUIManager.Fonts ['StandardEdit'];
end;

//////////////////////////////////////////////////////////
destructor TZECustomEdit.Destroy;
begin
  DeleteObject (FBackBrush);
  inherited;
end;

//////////////////////////////////////////////////////////
function TZECustomEdit.CharValid (CKey: Char): boolean;
begin
  Result := true;
end;

//////////////////////////////////////////////////////////
function TZECustomEdit.ValidateEntry (CEntry: string): boolean;
begin
  Result := true;
end;

//////////////////////////////////////////////////////////
procedure TZECustomEdit.HandleEvent (var Event: TZbEvent);
var
  CText: string;
begin
  inherited HandleEvent (Event);
  if (((Event.m_Event AND evKeyboard) <> 0) AND GetState (stFocused)) then
    begin
      case Event.m_Key of
        #13, #27:       // RETURN, ESCAPE
          begin
            EndModal;
          end;
        #8:             // BACKSPACE
          if ((FCurLen > 0) AND (FCurPos > 0)) then begin
            if (FCurPos > FCurLen) then begin
              Caption := Copy (Caption, 1, FCurLen-1);
              Dec (FCurLen);
              FCurPos := FCurLen + 1;
            end else  begin
              CText := Caption;
              System.Delete (CText, FCurPos, 1);
              Caption := CText;
              Dec (FCurLen);
              Dec (FCurPos);
              if (FCurPos <= 0) then
                FCurPos := 1;
            end;
          end;
      else // of case
        if (CharValid (Event.m_Key)) then
        begin
          if (FCurPos > FCurLen) then
            begin
              CText := Caption + Event.m_Key;
            end
          else
            begin
              CText := Caption;
              System.Insert (Event.m_Key, CText, FCurPos);
            end;
          //
          if (ValidateEntry (CText)) then
            begin
              Caption := CText;
              Inc (FCurPos);
              Inc (FCurLen);
            end;
        end;
      end;
    end;
end;

//////////////////////////////////////////////////////////
procedure TZECustomEdit.BeginModal (AOnEndModal: TZENotifyProc);
begin
  inherited BeginModal (AOnEndModal);
  FOldConsoleMode := g_EventManager.Keyboard.InConsoleMode;
  g_EventManager.Keyboard.SetConsoleMode (TRUE);
  //
  if (Caption <> '') then begin
    FCurLen := Length (Caption);
    FCurPos := FCurLen + 1;
    FLeftPos := 1;
  end else begin
    FLeftPos := 1;
    FCurPos := 1;
    FCurLen := 0;
  end;
end;

//////////////////////////////////////////////////////////
procedure TZECustomEdit.EndModal;
begin
  g_EventManager.Keyboard.SetConsoleMode (FOldConsoleMode);
  inherited EndModal;
end;

//////////////////////////////////////////////////////////
procedure TZECustomEdit.MouseLeftClick (var Event: TZbEvent);
var
  bPointInside: boolean;
begin
  //
  // if already modal, just check if the click falls off us.
  // if so, then relinquish the modal state
  if (GetState (stFocused)) then
    begin
      bPointInside := ContainsScreenPoint (Event.m_Pos);
      if (NOT bPointInside) then
        EndModal;
    end
  //
  // if we're not yet modal, then be sure to capture the mouse and
  // monitor it in MouseLeftRelease() to see if we need to turn on
  // modal state
  else
    CaptureMouse;
end;

//////////////////////////////////////////////////////////
procedure TZECustomEdit.MouseLeftRelease (var Event: TZbEvent);
var
  bPointInside: boolean;
begin
  //
  // mouse button was released.  if we're NOT modal, then find out where
  // it was when it was released.  if it was in our area, turn on Modal,
  // otherwise, ignore it.
  if (NOT GetState (stFocused)) then begin
    bPointInside := ContainsScreenPoint (Event.m_Pos);
    if (bPointInside) then
      BeginModal (NIL);
  end;
  //
  // check if we DID capture the mouse.  if so, release it.
  if (GetMouseFocus = Self) then ReleaseMouse;
end;

//////////////////////////////////////////////////////////
procedure TZECustomEdit.Paint;
var
  CText: string;
  hdcSurface: HDC;
  TextSize: TSize;
  bTextFit: boolean;
  R: TRect;
begin
  if (Surface = NIL) OR (Font = NIL) then exit;
  //
  if (Surface.GetDC (hdcSurface) = DD_OK) then begin
    // draw the rectangle first
    DCDrawRectFast (hdcSurface, FBackBrush, LocalBounds);
    //
    if (NOT GetState (stFocused)) then begin
      Font.WriteText (hdcSurface, Caption, ClientToScreen (FTextBounds));
      Surface.ReleaseDC (hdcSurface);
    end else begin
      //
      CText := Copy (Caption, FLeftPos, FCurLen);
      SelectObject (hdcSurface, Font.FontHandle);
      while (true) do begin
        bTextFit := GetTextExtentPoint32 (hdcSurface, PChar(CText),
          Length (CText), TextSize);
        //
        // error occurred? bug out of here
        if (NOT bTextFit) then break;
        // this string already fits inside? then we're done
        if (FTextExtentMax >= TextSize.cX) then break;
        // otherwise, shorten the string and measure it again
        Inc (FLeftPos);
        CText := Copy (Caption, FLeftPos, FCurLen);
      end;
      //
      Font.WriteText (hdcSurface, CText, ClientToScreen (FTextBounds));
      Surface.ReleaseDC (hdcSurface);
      //
      // draw the cursor here if present
      if (DefaultSprite <> NIL) then begin
        R.Left := FTextBounds.Left + TextSize.cX;
        R.Top  := FTextBounds.Bottom - DefaultSprite.Height;
        R.Right := R.Left + DefaultSprite.Width;
        R.Bottom := FTextBounds.Bottom;
        ImageFill (DefaultSprite, R);
      end;
    end;
  end;
  //
end;

/////////////////////////////////////////////////////////////////////
constructor TZEEdit.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_EDIT_CONTROL;
end;

/////////////////////////////////////////////////////////////////////
constructor TZENumericEdit.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_NUMERIC_EDIT_CONTROL;
  //
  FMaximum := 100;
  FMinimum := 0;
end;

/////////////////////////////////////////////////////////////////////
function TZENumericEdit.GetPropertyValue (APropertyName: string): string;
begin
  if (APropertyName = PROP_NAME_NUMEDIT_MAX) then
    Result := IntegerToProp (FMaximum)
  else if (APropertyName = PROP_NAME_NUMEDIT_MIN) then
    Result := IntegerToProp (FMinimum)
  else
    Result := inherited GetPropertyValue (APropertyName);
  //
end;

/////////////////////////////////////////////////////////////////////
function TZENumericEdit.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  Result := true;
  if (APropertyName = PROP_NAME_NUMEDIT_MAX) then
    FMaximum := PropToInteger (Value)
  else if (APropertyName = PROP_NAME_NUMEDIT_MIN) then
    FMinimum := PropToInteger (Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
  //
end;

/////////////////////////////////////////////////////////////////////
function TZENumericEdit.CharValid (CKey: Char): boolean;
const
   _DIGITS  = '0123456789';
begin
  Result := (System.Pos (CKey, _DIGITS) <> 0);
end;

/////////////////////////////////////////////////////////////////////
function TZENumericEdit.ValidateEntry (CEntry: string): boolean;
begin
  if (CEntry = '') then
    Result := TRUE
    else Result := (StrToInt (CEntry) <= FMaximum);
end;

/////////////////////////////////////////////////////////////////////
function TZENumericEdit.GetValue: integer;
begin
  if (Caption = '') then
    Result := 0
    else Result := StrToInt (Caption);
end;


(****************** CLASS-GENERATION FUNCTIONS *************************)
function CreateEdit (rBounds: TRect; AFont: TZEFont): TZEEdit;
begin
  Result := TZEEdit.Create (rBounds);
  if (Result = NIL) then Exit;
  if (AFont <> NIL) then Result.Font := AFont;
end;

function CreateNumericEdit (rBounds: TRect; AMinimum, AMaximum: integer;
    AFont: TZEFont): TZENumericEdit;
begin
  Result := TZENumericEdit.Create (rBounds);
  if (Result = NIL) then Exit;
  if (AFont <> NIL) then Result.Font := AFont
end;


////////////////////////////////////////////////////////////////////
procedure RegisterControls;
begin
  {$IFDEF REGISTER_ALL_CLASSES}
  RegisterControlClass (CC_CUSTOM_EDIT_CONTROL, TZECustomEdit);
  {$ENDIF}
  RegisterControlClass (CC_EDIT_CONTROL, TZEEdit);
  RegisterControlClass (CC_NUMERIC_EDIT_CONTROL, TZENumericEdit);
end;

end.
