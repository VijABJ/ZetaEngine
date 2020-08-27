{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSDialogs.PAS
              Contains dialog controls
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSDialogs.pas,v 1.5 2002/12/18 08:15:19 Vij Exp $
  $Log: ZEWSDialogs.pas,v $
  Revision 1.5  2002/12/18 08:15:19  Vij
  Added ScrollBar, TextBox and dialogs that make use of them.

  Revision 1.4  2002/11/02 06:47:00  Vij
  removed commands, moved them to ZEWSDefines

  Revision 1.3  2002/10/01 12:39:16  Vij
  Input dialog box created.

  Revision 1.2  2002/09/17 22:07:51  Vij
  Added StrInputDialogEx.  Added fields to hold the OK and Cancel buttons,
  and the properties to be able to reference them when necessary.

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSDialogs;

interface

uses
  Windows,
  Classes,
  //
  ZblIEvents,
  ZEDXImage,
  //
  ZEWSDefines,
  ZEWSBase,
  ZEWSSupport,
  ZEWSStandard,
  ZEWSMisc,
  ZEWSButtons,
  ZEWSLineEdit;

type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  TZEStandardWindow = class (TZEGroupControl)
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEDesktop = class (TZEGroupControl)
  private
    FWallpaper: TZEControl;
    FBorders: TZEControl;
  protected
    procedure SetWClassName (AWClassName: string); override;
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZERootWindow = class (TZEGroupControl)
  private
    FActiveDesktop: TZEDesktop;
    FDesktops: TStrings;
  protected
    property Desktops: TStrings read FDesktops;
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure Paint; override;
    //
    function AddDesktop (AName, AWClassName: string): TZEDesktop;
    function GetDesktop (AName: string): TZEDesktop;
    procedure UseDesktop (AName: string); overload;
    procedure UseDesktop (Desktop: TZEDesktop); overload;
    //
    property ActiveDesktop: TZEDesktop read FActiveDesktop;
    property Desks [AName: string]: TZEDesktop read GetDesktop; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomDialog = class (TZEStandardWindow)
  private
    FFreeBounds: TRect;
    FCommandToGenerate: Integer;
  protected
    procedure ModalTerminated; virtual;
    //
    property FreeBounds: TRect read FFreeBounds write FFreeBounds;
  public
    constructor Create (rBounds: TRect); override;
    //
    procedure HandleEvent (var Event: TZbEvent); override;
    procedure EndModal; override;
    //
    property CommandToGenerate: Integer
      read FCommandToGenerate write FCommandToGenerate;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEOKDialog = class (TZECustomDialog)
  private
    FOKButton: TZEControl;
  public
    constructor Create (rBounds: TRect); override;
    //
    property OKButton: TZEControl read FOKButton;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEOKCancelDialog = class (TZECustomDialog)
  private
    FOKButton: TZEControl;
    FCancelButton: TZEControl;
    FNoCancel: boolean;
  protected
    procedure ModalTerminated; override;
    procedure SetNoCancel (ANoCancel: boolean);
  public
    constructor Create (rBounds: TRect); override;
    //
    property OKButton: TZEControl read FOKButton;
    property CancelButton: TZEControl read FCancelButton;
    property NoCancel: boolean read FNoCancel write SetNoCancel;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEPromptDialog = class (TZEOKCancelDialog)
  private
    FMessageLine: TZEControl;
  public
    constructor Create (rBounds: TRect); override;
    procedure SetMessage (AMessage: string);
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMessageDialog = class (TZEOKDialog)
  private
    FMessageLine: TZEControl;
  public
    constructor Create (rBounds: TRect); override;
    procedure SetMessage (AMessage: string);
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECustomStrInputDialog = class (TZEOKCancelDialog)
  private
    FEditLine: TZEControl;
    FLabel: TZEControl;
  protected
    function GetFinalValue: string;
    procedure SetFinalValue (AFinalValue: string);
    procedure SetPromptString (PromptString: string);
  public
    constructor Create (rBounds: TRect); override;
    //
    property FinalValue: string read GetFinalValue write SetFinalValue;
    property PromptString: string write SetPromptString;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEStrInputDialogEx = class (TZECustomStrInputDialog)
  protected
    procedure ModalTerminated; override;
  public
    constructor Create (rBounds: TRect); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETextBoxDialog = class (TZEOKDialog)
  private
    FTextDisplay: TZETextBox;
  public
    constructor Create (rBounds: TRect); override;
    function SetPropertyValue (APropertyName, Value: string): boolean; override;
    //
    procedure AddText (cData: String); overload;
    procedure AddText (strList: TStrings); overload;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function CreateMessageBox (R: TRect; cMessage: string; SendCommand: Integer = cmNothing): TZEControl;
  function CreateInputBox (R: TRect; cPrompt: string;
    iCommand: integer; ANoCancel: boolean = FALSE): TZEControl;

  function CreateTextBox (R: TRect; strList: TStrings): TZEControl; overload;
  function CreateTextBox (R: TRect; cFileName: String): TZEControl; overload;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  procedure RegisterControls;


implementation

uses
  SysUtils,
  ZbDebug,
  ZbGameUtils,
  ZEDXFramework;


{ TZEStandardWindow }

///////////////////////////////////////////////////////////////////
constructor TZEStandardWindow.Create (rBounds: TRect);
var
  CC: TZEControl; // child control to insert
begin
  inherited Create (rBounds);
  WClassName := CC_STANDARD_WINDOW;
  //
  CC := TZEWallpaper.Create (LocalBounds);
  CC.SpriteName := WClassName;
  Insert (CC);
  CC := TZEWinBorders.Create (LocalBounds);
  CC.SpriteName := WClassName;
  Insert (CC);
end;


{ TZEDesktop }

//////////////////////////////////////////////////////////////////
constructor TZEDesktop.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_DESKTOP;
  //
  FWallpaper := TZEWallpaper.Create (LocalBounds);
  FWallpaper.SpriteName := WClassName;
  Insert (FWallpaper);
  //
  FBorders := TZEWinBorders.Create (LocalBounds);
  FBorders.SpriteName := WClassName;
  Insert (FBorders);
end;

//////////////////////////////////////////////////////////////////
procedure TZEDesktop.SetWClassName (AWClassName: string);
begin
  inherited;
  if (FWallpaper <> NIL) then FWallpaper.SpriteName := WClassName;
  if (FBorders <> NIL) then FBorders.SpriteName := WClassName;
end;


{ TZERootWindow }

//////////////////////////////////////////////////////////////////
constructor TZERootWindow.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  FDesktops := TStringList.Create;
  FActiveDesktop := NIL;
  IsRootWindow := TRUE;
end;

//////////////////////////////////////////////////////////////////
destructor TZERootWindow.Destroy;
begin
  FActiveDesktop := NIL;
  FDesktops.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////
procedure TZERootWindow.Paint;
begin
  inherited;
  if (FActiveDesktop = NIL) then begin
  end;
end;

//////////////////////////////////////////////////////////////////
function TZERootWindow.AddDesktop (AName, AWClassName: string): TZEDesktop;
var
  Desk: TZEDesktop;
begin
  Result := NIL;
  if (GetDesktop (AName) = NIL) then begin
    Desk := TZEDesktop.Create (LocalBounds);
    if (Desk = NIL) then Exit;
    //
    if (AWClassName <> '') then
      Desk.SetPropertyValue (PROP_NAME_WINCLASS_NAME, AWClassName);
    //
    Desktops.AddObject (AName, Desk);
    Desk.Name := AName;
    Insert (Desk);
    // if this is not the first desktop, then hide it
    if (Desktops.Count > 1) then
      Desk.Hide
    else
      // first desktop, make it active!
      FActiveDesktop := Desk;
    //
    Result := Desk;
  end;
end;

//////////////////////////////////////////////////////////////////
function TZERootWindow.GetDesktop (AName: string): TZEDesktop;
var
  iIndex: integer;
begin
  Result := NIL;
  for iIndex := 0 to Pred (Desktops.Count) do begin
    if (Desktops [iIndex] = AName) then begin
      Result := TZEDesktop (Desktops.Objects [iIndex]);
      break;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////
procedure TZERootWindow.UseDesktop (AName: string);
begin
  UseDesktop (GetDesktop (AName));
end;

//////////////////////////////////////////////////////////////////
procedure TZERootWindow.UseDesktop (Desktop: TZEDesktop);
var
  Event: TZbEvent;
  iIndex: integer;

  procedure SetupEvent (Command: integer; pStr: PChar);
  begin
    g_DXFramework.ClearEvent (Event, TRUE);
    Event.m_FreeStr := TRUE;
    Event.m_Event := evCommand;
    Event.m_Command := Command;
    Event.m_pStr := StrNew (pStr);
  end;

begin
  //if (Desktop = NIL) then Exit;
  //
  ClearModalVars;
  //
  // send notification of hiding the active desktop
  if (ActiveDesktop <> NIL) then begin
    SetupEvent (cmDesktopHidden, PChar (ActiveDesktop.Name));
    InsertEvent (Event);
    FActiveDesktop := NIL;
  end;
  //
  // hide all the desktops first
  for iIndex := 0 to Pred (Desktops.Count) do
    TZEDesktop (Desktops.Objects [iIndex]).Hide;
  //
  // and show this one
  FActiveDesktop := Desktop;
  if (FActiveDesktop <> NIL) then begin
    ActiveDesktop.Show;
    SetupEvent (cmDesktopShown, PChar (ActiveDesktop.Name));
    InsertEvent (Event);
  end;
end;


{ TZECustomDialog }

//////////////////////////////////////////////////////////////////
constructor TZECustomDialog.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  WClassName := CC_CUSTOM_DIALOG;
  //
  SetStyle (syCenterX OR syCenterY);
  FFreeBounds := LocalBounds;
  //
  FCommandToGenerate := cmNothing;
end;

//////////////////////////////////////////////////////////////////
procedure TZECustomDialog.HandleEvent (var Event: TZbEvent);
begin
  inherited HandleEvent (Event);
  if ((Event.m_Event = evCOMMAND) AND (GetState (stModal))) then begin
    case Event.m_Command of
      cmOK, cmCancel, cmYes, cmNo, cmAbort, cmRetry:
        begin
          ModalResult := Event.m_Command;
          EndModal;
          ClearEvent (Event);
        end;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////
procedure TZECustomDialog.EndModal;
begin
  inherited;
  ModalTerminated;
end;

//////////////////////////////////////////////////////////////////
procedure TZECustomDialog.ModalTerminated;
begin
  if (CommandToGenerate <> cmNothing) then
    g_EventManager.Commands.Insert (CommandToGenerate, 0, 0);
    //EventQueue.InsertEvent (CommandToGenerate);
  //
end;


{ TZEOKDialog }

//////////////////////////////////////////////////////////////////
constructor TZEOKDialog.Create (rBounds: TRect);
var
  R: TRect;
begin
  inherited Create (rBounds);
  WClassName := CC_OK_DIALOG;
  //
  with LocalBounds do FreeBounds := Rect (Left, Top, Right, Bottom - 28);
  //
  R := ExpandRect (LocalBounds, -4, -4);
  R.Top := R.Bottom - 20;
  FOKButton := CreatePanelButton (R, 'OK', '', '', cmOK);
  Insert (FOKButton);
  FOKButton.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogButton');
end;


{ TZEOKCancelDialog }

//////////////////////////////////////////////////////////////////
constructor TZEOKCancelDialog.Create (rBounds: TRect);
var
  R: TRect;
  W: integer;
begin
  inherited Create (rBounds);
  WClassName := CC_OK_CANCEL_DIALOG;
  //
  with LocalBounds do FreeBounds := Rect (Left, Top, Right, Bottom - 28);
  //
  R := ExpandRect (LocalBounds, -4, -4);
  R.Top := R.Bottom - 20;
  W := (R.Right - R.Left) div 2;
  R.Right := R.Left + W;
  //
  FOKButton := CreatePanelButton (R, 'OK', '', '', cmOK);
  Insert (FOKButton);
  FOKButton.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogButton');
  //
  R.Left := R.Right;
  R.Right := R.Left + W;
  FCancelButton := CreatePanelButton (R, 'Cancel', '', '', cmCancel);
  Insert (FCancelButton);
  FCancelButton.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogButton');
  //
  FNOCancel := FALSE;
end;

//////////////////////////////////////////////////////////////////
procedure TZEOKCancelDialog.SetNoCancel (ANoCancel: boolean);
begin
  FNoCancel := ANoCancel;
  if (FNoCancel) then FCancelButton.Hide else FCancelButton.Show;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEOKCancelDialog.ModalTerminated;
begin
  if (ModalResult = cmOK) AND (CommandToGenerate <> cmNothing) then
    g_EventManager.Commands.Insert (CommandToGenerate, 0, 0);
  //
end;



{ TZECustomStrInputDialog }

//////////////////////////////////////////////////////////////////
constructor TZECustomStrInputDialog.Create (rBounds: TRect);
var
  R: TRect;
begin
  inherited;
  WClassName := CC_CUSTOM_STRINPUT_DIALOG;
  //
  R := ExpandRect (FreeBounds, -5, -5);
  //
  Inc (R.Top, 10);
  R.Bottom := R.Top + 20;
  FLabel := CreateControl (CC_TEXT, R);
  Insert (FLabel);
  FLabel.SetPropertyValue (PROP_NAME_CAPTION, '[CAPTION]');
  FLabel.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogLabel');
  //
  R.Top := R.Bottom + 2;
  R.Bottom := R.Top + 20;
  FEditLine := CreateControl (CC_EDIT_CONTROL, R);
  Insert (FEditLine);
  FEditLine.SetStyle (syUseParentFont, FALSE);
  FEditLine.SetPropertyValue (PROP_NAME_FONT_NAME, 'DialogEditLine');
end;

//////////////////////////////////////////////////////////////////
function TZECustomStrInputDialog.GetFinalValue: string;
begin
  if (ModalResult <> cmOK) then
    Result := ''
    else Result := FEditLine.Caption;
end;

//////////////////////////////////////////////////////////////////
procedure TZECustomStrInputDialog.SetFinalValue (AFinalValue: string);
begin
  FEditLine.Caption := AFinalValue;
end;

//////////////////////////////////////////////////////////////////
procedure TZECustomStrInputDialog.SetPromptString (PromptString: string);
begin
  FLabel.Caption := PromptString;
end;

{ TZEPromptDialog }

//////////////////////////////////////////////////////////////////
constructor TZEPromptDialog.Create (rBounds: TRect);
begin
  inherited;
  FMessageLine := CreateControl (CC_TEXT, ExpandRect (FreeBounds, -4, -4));
  Insert (FMessageLine);
  FMessageLine.SetPropertyValue (PROP_NAME_CAPTION, 'MESSAGE GOES HERE');
  FMessageLine.SetPropertyValue (PROP_NAME_FONT_NAME, 'MessageText');
end;

//////////////////////////////////////////////////////////////////
procedure TZEPromptDialog.SetMessage (AMessage: string);
begin
  FMessageLine.Caption := AMessage;
end;


{ TZEMessageDialog }

//////////////////////////////////////////////////////////////////
constructor TZEMessageDialog.Create (rBounds: TRect);
var
  R: TRect;
begin
  inherited;
  WClassName := CC_MESSAGE_DIALOG;
  //
  R := ExpandRect (FreeBounds, -10, -12);
  FMessageLine := CreateControl (CC_TEXT, R);
  Insert (FMessageLine);
  FMessageLine.SetPropertyValue (PROP_NAME_CAPTION, 'MESSAGE GOES HERE');
  FMessageLine.SetPropertyValue (PROP_NAME_FONT_NAME, 'MessageText');
end;

//////////////////////////////////////////////////////////////////
procedure TZEMessageDialog.SetMessage (AMessage: string);
begin
  FMessageLine.SetPropertyValue (PROP_NAME_CAPTION, AMessage);
end;


{ TZEStrInputDialogEx }

//////////////////////////////////////////////////////////////////////////
constructor TZEStrInputDialogEx.Create (rBounds: TRect);
begin
  inherited;
  PromptString := '<MESSAGE HERE>';
  FinalValue := '';
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEStrInputDialogEx.ModalTerminated;
var
  cFinal: string;
begin
  if (ModalResult = cmOK) AND (CommandToGenerate <> cmNothing) then begin
    cFinal := Trim (FinalValue);
    if (cFinal = '') then Exit;
    g_EventManager.Commands.InsertWithStr (CommandToGenerate, 0, PChar (cFinal));
  end;
end;


{ TZETextBoxDialog }

//////////////////////////////////////////////////////////////////
constructor TZETextBoxDialog.Create (rBounds: TRect);
var
  R: TRect;
begin
  inherited;
  WClassName := CC_TEXT_DIALOG;
  //
  R := ExpandRect (FreeBounds, -5, -5);
  FTextDisplay := CreateControl (CC_TEXT_BOX, R) as TZETextBox;
  Insert (FTextDisplay);
end;

//////////////////////////////////////////////////////////////////
function TZETextBoxDialog.SetPropertyValue (APropertyName, Value: string): boolean;
begin
  if (APropertyName = PROP_NAME_TEXT_TO_ADD) OR
    (APropertyName = PROP_NAME_FILE_TO_LOAD) then
    Result := FTextDisplay.SetPropertyValue (APropertyName, Value)
  else
    Result := inherited SetPropertyValue (APropertyName, Value);
  //
end;

//////////////////////////////////////////////////////////////////
procedure TZETextBoxDialog.AddText (cData: String);
begin
  FTextDisplay.LoadData (cData);
end;

//////////////////////////////////////////////////////////////////
procedure TZETextBoxDialog.AddText (strList: TStrings);
begin
  FTextDisplay.LoadData (strList, FALSE);
end;


{ Utility Routines }

//////////////////////////////////////////////////////////////////
function CreateMessageBox (R: Trect; cMessage: string; SendCommand: Integer): TZEControl;
begin
  Result := TZEMessageDialog.Create (R);
  with TZEMessageDialog (Result) do begin
    if (SendCommand <> cmNothing) then CommandToGenerate := SendCommand;
    SetMessage (cMessage);
  end;
end;

//////////////////////////////////////////////////////////////////
function CreateInputBox (R: TRect; cPrompt: string;
  iCommand: integer; ANoCancel: boolean): TZEControl;
begin
  Result := TZEStrInputDialogEx.Create (R);
  TZEStrInputDialogEx (Result).PromptString := cPrompt;
  TZEStrInputDialogEx (Result).CommandToGenerate := iCommand;
  TZEStrInputDialogEx (Result).NoCancel := ANoCancel;
end;

//////////////////////////////////////////////////////////////////
function CreateTextBox (R: TRect; strList: TStrings): TZEControl;
begin
  Result := TZETextBoxDialog.Create (R);
  TZETextBoxDialog (Result).AddText (strList);
end;

//////////////////////////////////////////////////////////////////
function CreateTextBox (R: TRect; cFileName: String): TZEControl;
var
  strList: TStrings;
begin
  Result := NIL;
  if (NOT FileExists (cFileName)) then Exit;
  //
  strList := TStringList.Create;
  try
    strList.LoadFromFile (cFileName);
    Result := CreateTextBox (R, strList);
  finally
    strList.Free;
  end;
end;


{ Registration }

//////////////////////////////////////////////////////////////////
procedure RegisterControls;
begin
  RegisterControlClass (CC_STANDARD_WINDOW, TZEStandardWindow);
  RegisterControlClass (CC_DESKTOP, TZEDesktop);
  {$IFDEF REGISTER_ALL_CLASSES}
  RegisterControlClass (CC_ROOT_WINDOW, TZERootWindow);
  RegisterControlClass (CC_CUSTOM_DIALOG, TZECustomDialog);
  {$ENDIF}
  RegisterControlClass (CC_OK_DIALOG, TZEOKDialog);
  RegisterControlClass (CC_OK_CANCEL_DIALOG, TZEOKCancelDialog);
  {$IFDEF REGISTER_ALL_CLASSES}
  RegisterControlClass (CC_CUSTOM_STRINPUT_DIALOG, TZECustomStrInputDialog);
  {$ENDIF}
  RegisterControlClass (CC_MESSAGE_DIALOG, TZEMessageDialog);
  RegisterControlClass (CC_TEXT_DIALOG, TZETextBoxDialog);
end;


end.

