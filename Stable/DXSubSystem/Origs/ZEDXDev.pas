{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXDev.PAS
              All device interfaces (Mouse/Keyboard) as well as device-
              dependent stuff (Messages/Fonts) are placed here
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXDev.pas,v 1.6 2002/12/01 14:47:53 Vij Exp $
  $Log: ZEDXDev.pas,v $
  Revision 1.6  2002/12/01 14:47:53  Vij
  Remove DebugPrint() and related code.  Added timer events (as cmXXXX)

  Revision 1.5  2002/11/02 06:40:08  Vij
  code cleanup, minor changes regarding timer (it was moved to another module
  and renamed).  added code to cleanup Windows Event Handle properly

  Revision 1.4  2002/10/01 12:31:08  Vij
  Added FlushEvents () to EventManager

  Revision 1.3  2002/09/17 22:08:41  Vij
  Changed all longint vars to integer

  Revision 1.2  2002/09/13 13:17:37  Vij
  Added method (to EventQueue class) to insert an event with a disposeable
  PChar value.  An overloaded version of InsertEvent() was created for this.

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXDev;

interface

uses
  Windows,
  Classes,
  SysUtils,
  DirectDraw,
  DirectInput8,
  ZbGameUtils,
  ZEDXCore,
  ZEDXSpriteIntf;

const
  { Standard System Commands -1 - 199 }
  cmStandardSystemBase  = 0;
  cmStandardSystemMax   = cmStandardSystemBase + 199;

  cmError               = cmStandardSystemBase - 1;
  cmNothing             = cmStandardSystemBase + 0;
  cmOK                  = cmStandardSystemBase + 1;
  cmCancel              = cmStandardSystemBase + 2;
  cmYes                 = cmStandardSystemBase + 3;
  cmNO                  = cmStandardSystemBase + 4;
  cmAbort               = cmStandardSystemBase + 5;
  cmRetry               = cmStandardSystemBase + 6;
  cmGetFocus            = cmStandardSystemBase + 7;
  cmReleaseFocus        = cmStandardSystemBase + 8;
  cmHelp                = cmStandardSystemBase + 9;
  cmExit                = cmStandardSystemBase + 10;
  cmExitConfirm         = cmStandardSystemBase + 11;
  cmFinalExit           = cmStandardSystemBase + 12;
  cmCycleForward        = cmStandardSystemBase + 13;
  cmCycleBackward       = cmStandardSystemBase + 14;
  cmGetDefault          = cmStandardSystemBase + 15;
  cmReleaseDefault      = cmStandardSystemBase + 16;
  cmClose               = cmStandardSystemBase + 17;
  cmResize              = cmStandardSystemBase + 18;
  cmZoom                = cmStandardSystemBase + 19;
  cmDrag                = cmStandardSystemBase + 20;
  cmGotoPrev            = cmStandardSystemBase + 21;
  cmGotoNext            = cmStandardSystemBase + 22;
  cmSystemMenu          = cmStandardSystemBase + 23;
  cmDefault             = cmStandardSystemBase + 24;
  cmMove                = cmStandardSystemBase + 25;
  cmCommandsChanged     = cmStandardSystemBase + 26;
  cmMoveWithMouse       = cmStandardSystemBase + 27;
  cmEngineTimerTick     = cmStandardSystemBase + 28;
  cmEngineTimerExpired  = cmStandardSystemBase + 29;

  { *** Font Options *** }
  TW_ITALIC             = $0001;
  TW_UNDERLINE          = $0002;
  TW_STRIKEOUT          = $0004;

  { *** Mouse Button Constants ***  }
  evLButton             = $0001;
  evRButton             = $0002;
  evMButton             = $0004;
  evTwoButtons          = (evLButton + evRButton);

  { *** Messsage Types *** }
  evMouseDown           = $0001;
  evMouseClick          = evMouseDown;
  evMouseUp             = $0002;
  evMouseDblClick       = $0004;
  evLeftButton          = $0008;
  evRightButton         = $0010;
  evMiddleButton        = $0020;
  evMouseMove           = $0040;
  evMouseAuto           = $0080;

  { ***  Mouse Messages When Translated  *** }
  evLBtnDown            = evLeftButton + evMouseDown;
  evLBtnClick           = evLeftButton + evMouseClick;
  evLBtnDblClick        = evLeftButton + evMouseDblClick;
  evLBtnUp              = evLeftButton + evMouseUp;
  evLBtnAuto            = evLeftButton + evMouseAuto;

  evRBtnDown            = evRightButton + evMouseDown;
  evRBtnClick           = evRightButton + evMouseClick;
  evRBtnDblClick        = evRightButton + evMouseDblClick;
  evRBtnUp              = evRightButton + evMouseUp;
  evRBtnAuto            = evRightButton + evMouseAuto;

  evMBtnDown            = evMiddleButton + evMouseDown;
  evMBtnClick           = evMiddleButton + evMouseClick;
  evMBtnDblClick        = evMiddleButton + evMouseDblClick;
  evMBtnUp              = evMiddleButton + evMouseUp;
  evMBtnAuto            = evMiddleButton + evMouseAuto;

  { message masks and other generic messages }
  evDONE                = 0;
  evNothing             = evDONE;
  evMOUSE               = evMouseUp + evMouseDown + evMouseMove +
                          evMouseAuto + evMouseDblClick +
                          evLeftButton + evRightButton + evMiddleButton;

  evKBD                 = $0100;
  evKeyboard            = evKBD;

  evSysCommand          = $0200;
  evCOMMAND             = $0E00;

  evTimer               = $1000;
  evSysBroadCast        = $2000;
  evFocusBroadCast      = $4000;
  evBROADCAST           = $F000;

  EVENT_NO_COMMAND      = 0;


  (* screen edge flags *)
  seLeft                = $0001;
  seRight               = $0002;
  seTop                 = $0004;
  seBottom              = $0008;


type
  PZEEvent = ^TZEEvent;
  TZEEvent = packed record
    bFreeStr: boolean;
    case Event: integer of
      evDONE:     ();
      evMOUSE:    (
          delta: TPoint;        // stores relative motion
          position: TPoint;     // stores absolute location
          buttons: integer;     // bitmasks of which button is up/down
        );
      evKBD:      (
          cKey: char;           // character pressed. for more info, call
                                // DI8KeyDown ()
        );
      evBROADCAST,
      evCOMMAND:  (
          Command: integer;
          lParam: integer;
          case integer of
            0:  (pStr: PChar);
            1:  (pData: pointer);
            2:  (lData: integer);
            3:  (wData: word);
            4:  (iData: integer);
            5:  (bData: byte);
            6:  (cData: char)
        );
  end;

  TZECustomMouse = class (TObject)
  private
    FPosition: TPoint;
    FDelta: TPoint;
    FVisible: boolean;
    FBounds: TRect;
    FMinBounds: TRect;
    FButtonState: integer;
    FLastEvent: integer;
    FLastEventTick: integer;
    FRepeatDelay: integer;
    FRepeatDelta: TPoint;
  protected
    procedure Update;
    procedure SetEdgeBounds;
    //
    property Bounds: TRect read FBounds write FBounds;
  public
    constructor Create (rConstraints: TRect); virtual;
    destructor Destroy; override;
    //
    procedure SetConstraints (rConstraints: TRect);
    procedure CheckLimits;
    procedure Center;
    //
    procedure GetEvent (var Event: TZEEvent);
    function GetEdgeInfo: integer;
    //
    // properties
    property Position: TPoint read FPosition;
    property X: integer read FPosition.X;
    property Y: integer read FPosition.Y;
    property Delta: TPoint read FDelta;
    property dX: integer read FDelta.X;
    property dY: integer read FDelta.Y;
    property Visible: boolean read FVisible write FVisible;
  end;

  TZEMouse = class (TZECustomMouse)
  private
    FCursor: IZESprite;
    FAnimated: boolean;
    FAnimationTimer: TZbSimpleTimeTrigger;
  protected
    function GetAnimationDelay: Cardinal;
    procedure SetAnimationDelay (ANewDelay: Cardinal);
    procedure SetCursor (Cursor: IZESprite);
  public
    constructor Create (rConstraints: TRect); override;
    destructor Destroy; override;
    //
    procedure Animate (AElapsedTicks: Cardinal);
    procedure DrawPointer;
    //
    property Animated: boolean read FAnimated;
    property AnimationDelay: Cardinal
      read GetAnimationDelay write SetAnimationDelay;
    property Cursor: IZESprite read FCursor write SetCursor;
  end;

  TZEEventManager = class (TObject)
  private
    FEvents: TList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //
    procedure ClearEvent (var Event: TZEEvent);
    procedure CleanupEvent (var Event: TZEEvent);
    //
    procedure InsertEvent (Event: TZEEvent); overload;
    procedure InsertEvent (Command: integer; lpszParam: PChar); overload;
    procedure InsertEvent (Command: integer; lParam: integer = 0;
      lData: integer = 0); overload;
    //
    procedure FlushEvents;
    function PeekEvent: TZEEvent;
    function PopEvent: TZEEvent;
    function HasEvents: boolean;
  end;

  TZEKeyCharactersQueue = class (TObject)
  private
    PQueue: PChar;
    iHead, iTail, iQueueSize: integer;
  protected
    function QueueHasKeys: boolean;
  public
    constructor Create (AQueueSize: integer); virtual;
    destructor Destroy; override;
    //
    procedure InsertChar (AChar: Char);
    function GetChar: Char;
    function PeekChar: Char;
    // properties
    property NotEmpty: boolean read QueueHasKeys;
  end;


var
  GlobalLastTick: Cardinal = 0;
  GlobalElapsedTicks: Cardinal = 0;
  Mouse: TZEMouse = NIL;
  EventQueue: TZEEventManager = NIL;
  KeyboardQueue: TZEKeyCharactersQueue = NIL;
  iKeyboardQueueSize: integer = 128;

  procedure UpdateGlobalCounter;

  // DirectInput Initialize And Shutdown
  function  DI8Init (_hWnd: hWnd; hAppInstance: HINST): integer;
  procedure DI8Close;

  // Mouse Control
  function  DI8MouseControl(_acquire: boolean): boolean;
  function  DI8GetMouseState(var dX, dY: integer;
                  var iLBtnUp, iLBtnDown, iLBtnDblClick,
                  iRBtnUp, iRBtnDown, iRBtnDblClick: integer): boolean;

  // Keyboard Control
  function  DI8KeyboardControl(_acquire: boolean): boolean;
  function  DI8GetKeyboardState: boolean;
  function  DI8KeyDown(_key: byte): boolean;
  function  DI8GetConsoleMode: boolean;
  procedure DI8SetConsoleMode (AConsoleMode: boolean);

  procedure InitDeviceHandlers;
  procedure CloseDeviceHandlers;


implementation

uses
  ZbUtils,
  ZEDXSprite;
  

//////////////////////////////////////////////////////////////////////////
procedure UpdateGlobalCounter;
var
  ThisTick: Cardinal;
begin
  ThisTick := GetTickCount;
  GlobalElapsedTicks := ThisTick - GlobalLastTick;
  GlobalLastTick := ThisTick;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZECustomMouse.Create (rConstraints: TRect);
begin
  FPosition := Point (0, 0);
  FDelta := Point (0, 0);
  FVisible := false;
  FButtonState := 0;
  FLastEvent := 0;
  FLastEventTick := GetTickCount;
  FRepeatDelay := 5;
  FRepeatDelta := Point (4, 4);
  SetConstraints (rConstraints);
  Update;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZECustomMouse.Destroy;
begin
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomMouse.Update;
var
  iLBtnDown, iLBtnUp, iLBtnDblClick: integer;
  iRBtnDown, iRBtnUp, iRBtnDblClick: integer;
  dX, dY: integer;
  bOK: boolean;
  iElapsed: integer;

  const
    MinMoveDelta  = 4;

begin
  bOK := DI8GetMouseState (dX, dY,
            iLBtnUp, iLBtnDown, iLBtnDblClick,
            iRBtnUp, iRBtnDown, iRBtnDblClick);
  //
  FLastEvent := 0;
  if (bOK) then begin
    //if (dX > 0) AND (dX < MinMoveDelta) then dX := MinMoveDelta;
    //if (dY > 0) AND (dY < MinMoveDelta) then dY := MinMoveDelta;
    // update the positions and displacements first
    FDelta := Point (dX, dY);
    FPosition := AddPoint (FPosition, FDelta);
    CheckLimits;
    //
    // update the mouse states
    if (iLBtnDblClick > 0) then begin
      FLastEvent := evLBtnDblClick;
    end else if (iLBtnDown > 0) then begin
      FLastEvent := evLBtnDown;
      FButtonState := FButtonState OR evLButton;
    end else if (iLBtnUp > 0) then begin
      FLastEvent := evLBtnUp;
      FButtonState := FButtonState AND NOT evLButton;
    end else if (iRBtnDblClick > 0) then begin
        FLastEvent := evRBtnDblClick;
    end else if (iRBtnDown > 0) then begin
      FLastEvent := evRBtnDown;
      FButtonState := FButtonState OR evRButton;
    end else if (iRBtnUp > 0) then begin
      FLastEvent := evRBtnUp;
      FButtonState := FButtonState AND NOT evRButton;
    end;
    //
    // check: if there is no button event, check for button
    // auto-event. note that having the two buttons pressed
    // at the same time nullifies this auto event
    if (FLastEvent = 0) then begin
      if (((dX <> 0) OR (dY <> 0)) AND
        ((FButtonState AND evTwoButtons) <> evTwoButtons) ) then begin
          if ((FButtonState AND evLButton) <> 0) then
            FLastEvent := evLBtnAuto
          else if ((FButtonState AND evRButton) <> 0) then
            FLastEvent := evRBtnAuto
          else
            FLastEvent := evMouseMove;
        end
    end;
    //
    // finally, check here if we got an event
    if (FLastEvent <> 0) then
      FLastEventTick := GetTickCount
    else begin
      // if there is no mouse event, check if we need to
      // auto-generate a move here...
      iElapsed := integer(GetTickCount) - FLastEventTick;
      if (iElapsed >= FRepeatDelay) then begin
        FLastEvent := evMouseMove;
        FLastEventTick := GetTickCount;
      end;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomMouse.SetEdgeBounds;
const
  FUDGE_FACTOR = 2;
begin
  FMinBounds := FBounds;
  Inc (FMinBounds.Left, FUDGE_FACTOR);
  Inc (FMinBounds.Top, FUDGE_FACTOR);
  Dec (FMinBounds.Right, FUDGE_FACTOR);
  Dec (FMinBounds.Bottom, FUDGE_FACTOR);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomMouse.SetConstraints (rConstraints: TRect);
begin
  FBounds := rConstraints;
  CheckLimits;
  SetEdgeBounds;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomMouse.CheckLimits;
begin
  if (FPosition.X < FBounds.Left) then
    FPosition.X := FBounds.Left;
  if (FPosition.X >= FBounds.Right) then
    FPosition.X := FBounds.Right - 1;
  if (FPosition.Y < FBounds.Top) then
    FPosition.Y := FBounds.Top;
  if (FPosition.Y >= FBounds.Bottom) then
    FPosition.Y := FBounds.Bottom - 1;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomMouse.Center;
begin
  FPosition.X := FBounds.Left + ((FBounds.Right - FBounds.Left) div 2);
  FPosition.Y := FBounds.Top + ((FBounds.Bottom - FBounds.Top) div 2);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECustomMouse.GetEvent (var Event: TZEEvent);
begin
  Update;
  EventQueue.ClearEvent (Event);
  if (FLastEvent <> 0) then begin
    Event.Event := FLastEvent;
    Event.position := FPosition;
    Event.delta := FDelta;
    Event.buttons := FButtonState;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZECustomMouse.GetEdgeInfo: integer;
begin
  Result := 0;
  if (FPosition.X < FMinBounds.Left) then
    Result := Result OR seLeft;
  if (FPosition.Y < FMinBounds.Top) then
    Result := Result OR seTop;
  if (FPosition.X > FMinBounds.Right) then
    Result := Result OR seRight;
  if (FPosition.Y > FMinBounds.Bottom) then
    Result := Result OR seBottom;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEMouse.Create (rConstraints: TRect);
begin
  inherited Create (rConstraints);
  FCursor := NIL;
  //
  FAnimated := false;
  FAnimationTimer := TZbSimpleTimeTrigger.Create (10);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEMouse.Destroy;
begin
  FCursor := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMouse.GetAnimationDelay: Cardinal;
begin
  Result := FAnimationTimer.TriggerValue;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMouse.SetAnimationDelay (ANewDelay: Cardinal);
begin
  FAnimationTimer.TriggerValue := ANewDelay;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMouse.Animate (AElapsedTicks: Cardinal);
begin
  if ((NOT FAnimated) OR (FCursor = NIL)) then Exit;
  //
  if (FAnimationTimer.CheckResetTrigger (AElapsedTicks)) then
    FCursor.CycleFrameForward;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMouse.DrawPointer;
begin
  if ((FCursor <> NIL) AND (Visible)) then begin
    FCursor.Position := FPosition;
    FCursor.DrawClipped (Bounds);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMouse.SetCursor (Cursor: IZESprite);
begin
  if (FCursor <> NIL) then FCursor := NIL;
  FCursor := Cursor;
  FAnimated := (FCursor <> NIL) AND (FCursor.FrameCount > 1);
end;


//////////////////////////////////////////////////////////////////////////
constructor TZEEventManager.Create;
begin
  inherited;
  FEvents := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEEventManager.Destroy;
var
  iIndex: integer;
  PE: PZEEvent;
begin
  for iIndex := 0 to FEvents.Count-1 do begin
    PE := PZEEvent (FEvents [iIndex]);
    if (PE <> NIL) then begin
      Dispose (PE);
      FEvents [iIndex] := NIL;
    end;
  end;
  //
  FEvents.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEventManager.ClearEvent (var Event: TZEEvent);
begin
  FastClear (@Event, SizeOf (TZEEvent));
  Event.Event := evDONE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEventManager.CleanupEvent (var Event: TZEEvent);
begin
  if (Event.bFreeStr) then StrDispose (Event.pStr);
  ClearEvent (Event);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEventManager.InsertEvent (Event: TZEEvent);
var
  PE: PZEEvent;
begin
  if (Event.Event <> evDONE) then begin
    New (PE);
    PE^ := Event;
    FEvents.Add (Pointer (PE));
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEventManager.InsertEvent (Command: integer; lpszParam: PChar);
var
  Event: TZEEvent;
begin
  if (Command <> EVENT_NO_COMMAND) then begin
    ZeroMemory (@Event, SizeOf (TZEEvent));
    Event.Event := evCommand;
    Event.Command := Command;
    Event.bFreeStr := TRUE;
    Event.pStr := StrNew (lpszParam);
    InsertEvent (Event);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEventManager.InsertEvent (Command, lParam, lData: integer);
var
  Event: TZEEvent;
begin
  if (Command <> EVENT_NO_COMMAND) then begin
    ZeroMemory (@Event, SizeOf (TZEEvent));
    Event.Event := evCommand;
    Event.Command := Command;
    Event.lParam := lParam;
    Event.lData := lData;
    InsertEvent (Event);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEEventManager.FlushEvents;
var
  Event: TZEEvent;
begin
  while (HasEvents) do begin
    Event := PopEvent;
    ClearEvent (Event);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEEventManager.PeekEvent: TZEEvent;
var
  Event: TZEEvent;
begin
  Event.Event := evDONE;
  if (FEvents.Count > 0) then
    Event := PZEEvent (FEvents [0])^;
  //
  Result := Event
end;

//////////////////////////////////////////////////////////////////////////
function TZEEventManager.PopEvent: TZEEvent;
var
  Event: TZEEvent;
  PE: PZEEvent;
begin
  Event.Event := evDONE;
  if (FEvents.Count > 0) then begin
    PE := PZEEvent (FEvents [0]);
    Event := PE^;
    Dispose (PE);
    FEvents [0] := NIL;
    FEvents.Pack;
  end;
  //
  Result := Event
end;

//////////////////////////////////////////////////////////////////////////
function TZEEventManager.HasEvents: boolean;
begin
  Result := (FEvents.Count > 0);
end;


//////////////////////////////////////////////////////////////////////////
function TZEKeyCharactersQueue.QueueHasKeys: boolean;
begin
  Result := (iHead <> iTail);
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEKeyCharactersQueue.Create (AQueueSize: integer);
begin
  inherited Create;
  //
  PQueue := SafeAllocMem (AQueueSize);
  iHead := 0;
  iTail := 0;
  iQueueSize := AQueueSize;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEKeyCharactersQueue.Destroy;
begin
  FreeMem (PQueue, iQueueSize);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEKeyCharactersQueue.InsertChar (AChar: Char);
var
  iOldHead: integer;
begin
  // save old head, then increment head
  iOldHead := iHead;
  Inc (iHead);
  // wrap around the queue if needed.
  if (iHead >= iQueuesize) then iHead := 0;
  // if head meets tail, queue was full! restore head and bail out
  if (iHead = iTail) then
    iHead := iOldHead
    else PChar (Longint (PQueue) + iOldHead)^ := AChar;
end;

//////////////////////////////////////////////////////////////////////////
function TZEKeyCharactersQueue.GetChar: Char;
begin
  if (NOT QueueHasKeys) then
    Result := #0
  else begin
    Result := PChar (Longint (PQueue) + iTail)^;
    Inc (iTail);
    if (iTail >= iQueueSize) then iTail := 0;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEKeyCharactersQueue.PeekChar: Char;
begin
  if (NOT QueueHasKeys) then
    Result := #0
    else Result := PChar (Longint (PQueue) + iTail)^;
end;



// ***************************************************************************
// *                                                                         *
// *            D I R E C T X  8   D I R E C T I N P U T                     *
// *                                                                         *
// ***************************************************************************

const
  // Mouse.
  DIMBufSize = 16;   // #Events stored in mouse's buffer.
  DIMTimeOut = 250;  // Timeout for double-click.

  SH_LEFT_SHIFT       =   $01;
  SH_RIGHT_SHIFT      =   $02;
  SH_SHIFTKEYS        =   (SH_LEFT_SHIFT OR SH_RIGHT_SHIFT);
  SH_LEFT_ALT         =   $04;
  SH_RIGHT_ALT        =   $08;
  SH_ALTKEYS          =   (SH_LEFT_ALT OR SH_RIGHT_ALT);
  SH_LEFT_CTRL        =   $10;
  SH_RIGHT_CTRL       =   $20;
  SH_CTRLKEYS         =   (SH_LEFT_CTRL OR SH_RIGHT_CTRL);
  SH_CAPSLOCK         =   $40;
  SH_NUMLOCK          =   $80;

  DI_KEY_DOWN         =   $80;

type
  KeyShiftRec = packed record
    uCode, uShift: byte;
  end;

var
  // Interfaces
  DI8  : IDirectInput8 = NIL;       // DirectInput Interface.
  DIK8 : IDirectInputDevice8 = NIL; // Keyboard Interface.
  DIM8 : IDirectInputDevice8 = NIL; // Mouse Interface.

  // Mouse.
  DIMButSwapped : boolean = false; // Mouse buttons swapped ?
  DIM0Released  : dWord = 0; // Last time that button 0 was released.
  DIM1Released  : dWord = 0; // Last time that button 1 was released.

  // Mouse.
  DIMEvent : THandle = 0;  // Mouse event.
  DIMou0Clicked  : boolean = false; // Mouse button 0 is pressed ?
  DIMou1Clicked  : boolean = false; // Mouse button 1 is pressed ?

  // Keyboard.
  DIPrevKeyBuffer: array[0..255] of byte;  // old copy of keyboard buffer
  DIKeyBuffer    : array[0..255] of byte;  // Keyboard buffer.
  // for console mode interpretations
  DIConsoleMode  : boolean = false; // raw or processed keys flag
  DIConsoleLastRead : integer = 0;
  DIConsoleMinDelay : integer = 5;
  uShiftStates   : byte = 0;
  arShiftTable : array [1..8] of KeyShiftRec = (
      (uCode:DIK_LSHIFT;    uShift:SH_LEFT_SHIFT),
      (uCode:DIK_RSHIFT;    uShift:SH_RIGHT_SHIFT),
      (uCode:DIK_LMENU;     uShift:SH_LEFT_ALT),
      (uCode:DIK_RMENU;     uShift:SH_RIGHT_ALT),
      (uCode:DIK_LCONTROL;  uShift:SH_LEFT_CTRL),
      (uCode:DIK_RCONTROL;  uShift:SH_RIGHT_CTRL),
      (uCode:DIK_CAPITAL;   uShift:SH_CAPSLOCK),
      (uCode:DIK_NUMLOCK;   uShift:SH_NUMLOCK)
    );

  {---------- KEYCODE AND CHARACTER COMBOS -------------}
  {vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv}

type
  TZZKeyCombos = packed record
    uCode: byte;
    cNormal: char;
    cCaps: char;
  end;

const
  KEY_TABLE_SIZE  = 52;

var
  KeyTable: array [0..KEY_TABLE_SIZE-1] of TZZKeyCombos = (
    (uCode:DIK_1;         cNormal:'1';      cCaps:'!'),
    (uCode:DIK_2;         cNormal:'2';      cCaps:'@'),
    (uCode:DIK_3;         cNormal:'3';      cCaps:'#'),
    (uCode:DIK_4;         cNormal:'4';      cCaps:'$'),
    (uCode:DIK_5;         cNormal:'5';      cCaps:'%'),
    (uCode:DIK_6;         cNormal:'6';      cCaps:'^'),
    (uCode:DIK_7;         cNormal:'7';      cCaps:'&'),
    (uCode:DIK_8;         cNormal:'8';      cCaps:'*'),
    (uCode:DIK_9;         cNormal:'9';      cCaps:'('),
    (uCode:DIK_0;         cNormal:'0';      cCaps:')'),     {10}

    (uCode:DIK_ESCAPE;    cNormal:#27;      cCaps:#27),
    (uCode:DIK_MINUS;     cNormal:'-';      cCaps:'_'),
    (uCode:DIK_EQUALS;    cNormal:'=';      cCaps:'+'),
    (uCode:DIK_BACK;      cNormal:#8;       cCaps:#8),
    (uCode:DIK_TAB;       cNormal:#9;       cCaps:#9),
    (uCode:DIK_LBRACKET;  cNormal:'[';      cCaps:'{'),
    (uCode:DIK_RBRACKET;  cNormal:']';      cCaps:'}'),
    (uCode:DIK_RETURN;    cNormal:#13;      cCaps:#13),
    (uCode:DIK_SEMICOLON; cNormal:';';      cCaps:':'),
    (uCode:DIK_APOSTROPHE;cNormal:'''';     cCaps:'"'),     {20}

    (uCode:DIK_GRAVE;     cNormal:'`';      cCaps:'~'),
    (uCode:DIK_BACKSLASH; cNormal:'\';      cCaps:'|'),
    (uCode:DIK_COMMA;     cNormal:',';      cCaps:'<'),
    (uCode:DIK_PERIOD;    cNormal:'.';      cCaps:'>'),
    (uCode:DIK_SLASH;     cNormal:'/';      cCaps:'?'),
    (uCode:DIK_SPACE;     cNormal:' ';      cCaps:' '),
    (uCode:DIK_A;         cNormal:'a';      cCaps:'A'),
    (uCode:DIK_B;         cNormal:'b';      cCaps:'B'),
    (uCode:DIK_C;         cNormal:'c';      cCaps:'C'),
    (uCode:DIK_D;         cNormal:'d';      cCaps:'D'),     {30}

    (uCode:DIK_E;         cNormal:'e';      cCaps:'E'),
    (uCode:DIK_F;         cNormal:'f';      cCaps:'F'),
    (uCode:DIK_G;         cNormal:'g';      cCaps:'G'),
    (uCode:DIK_H;         cNormal:'h';      cCaps:'H'),
    (uCode:DIK_I;         cNormal:'i';      cCaps:'I'),
    (uCode:DIK_J;         cNormal:'j';      cCaps:'J'),
    (uCode:DIK_K;         cNormal:'k';      cCaps:'K'),
    (uCode:DIK_L;         cNormal:'l';      cCaps:'L'),
    (uCode:DIK_M;         cNormal:'m';      cCaps:'M'),
    (uCode:DIK_N;         cNormal:'n';      cCaps:'N'),     {40}

    (uCode:DIK_O;         cNormal:'o';      cCaps:'O'),
    (uCode:DIK_P;         cNormal:'p';      cCaps:'P'),
    (uCode:DIK_Q;         cNormal:'q';      cCaps:'Q'),
    (uCode:DIK_R;         cNormal:'r';      cCaps:'R'),
    (uCode:DIK_S;         cNormal:'s';      cCaps:'S'),
    (uCode:DIK_T;         cNormal:'t';      cCaps:'T'),
    (uCode:DIK_U;         cNormal:'u';      cCaps:'U'),
    (uCode:DIK_V;         cNormal:'v';      cCaps:'V'),
    (uCode:DIK_W;         cNormal:'w';      cCaps:'W'),
    (uCode:DIK_X;         cNormal:'x';      cCaps:'X'),     {50}

    (uCode:DIK_Y;         cNormal:'y';      cCaps:'Y'),
    (uCode:DIK_Z;         cNormal:'z';      cCaps:'Z')

  );

  {^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
  {---------- KEYCODE AND CHARACTER COMBOS -------------}


//////////////////////////////////////////////////////////////////////////
// Initialize the DirectInput System
// requires: handle to main window: _hWnd
// returns: error message if failed, or ERROR_NO_ERROR on success
function  DI8Init (_hWnd: hWnd; hAppInstance: HINST): integer;
var
  bSuccess: boolean;
  _prop : TDIPropDWord;
begin
  Result := ERROR_DI8_GEN_INIT_FAILED;
  // close if already initialized
  DI8Close;

  // ************************************
  // INITIALIZING DIRECTX DIRECTINPUT
  // Create DirectInput Interface.
  bSuccess := not failed (DirectInput8Create (hAppInstance,
                       DIRECTINPUT_VERSION,
                       IID_IDirectInput8, DI8, NIL));

  // if main init failed, bail out now
  if (NOT bSuccess) then exit;

  // ******************************
  // INITIALIZING MOUSE DEVICE
  // assume failure to initialize mouse
  Result := ERROR_DI8_MOUSE_INIT_FAILED;
  // Are mouse buttons swapped ?
  DIMButSwapped := GetSystemMetrics(SM_SWAPBUTTON) <> 0;
  // Create a IDirectInputDevice interface for the Mouse.
  if failed(DI8.CreateDevice(GUID_SysMouse, DIM8, NIL)) then exit;
  // Set the device's data format.
  if failed(DIM8.SetDataFormat(@c_dfDIMouse)) then exit;
  // Set the cooperative level.
  if failed(DIM8.SetCooperativeLevel(_hWnd, DISCL_FOREGROUND or
                                     DISCL_EXCLUSIVE)) then exit;
  // Create a event for the mouse.
  DIMEvent := CreateEvent (NIL, false, false, NIL);
  if (DIMEvent = 0) then exit;
  // Assign event.
  if failed(DIM8.SetEventNotification(DIMEvent)) then exit;
  // Set buffer's description.
  with _prop do begin
    diph.dwSize       := SizeOf(TDIPropDWord);
    diph.dwHeaderSize := SizeOf(TDIPropHeader);
    diph.dwObj        := 0;
    diph.dwHow        := DIPH_DEVICE;
    dwData            := DIMBufSize;
  end;
  // Assign buffer.
  if failed(DIM8.SetProperty(DIPROP_BUFFERSIZE, _prop.diph)) then exit;

  // ****************************************
  // INITIALIZING KEYBOARD DEVICE
  // assume failure to initialize keyboard
  Result := ERROR_DI8_KBD_INIT_FAILED;
  // Create a IDirectInputDevice interface for the Keyboard.
  if failed(DI8.CreateDevice(GUID_SysKeyboard, DIK8, NIL)) then exit;

  // Set the device's data format.
  if failed(DIK8.SetDataFormat(@c_dfDIKeyboard)) then exit;

  // Set the cooperative level.
  if failed(DIK8.SetCooperativeLevel(_hWnd, DISCL_FOREGROUND or
                                     DISCL_NONEXCLUSIVE)) then exit;

  // everything ok, return success
  Result := ERROR_NO_ERROR;
end;

//////////////////////////////////////////////////////////////////////////
// unassigns all interfaces obtained during initialization
procedure DI8Close;
begin
  if Assigned(DI8) then begin
    // clean up the event handle
    if (DIMEvent <> 0) then begin
      CloseHandle (DIMEvent);
      DIMEvent := 0;
    end;
    // Close Keyboard interface.
    if Assigned(DIK8) then begin
      DIK8.Unacquire;
      DIK8 := NIL;
    end;
    // Close Mouse interface.
    if Assigned(DIM8) then begin
      DIM8.Unacquire;
      DIM8 := NIL;
    end;
    // Close DirectInput interface.
    DI8 := NIL;
  end;
end;

//////////////////////////////////////////////////////////////////////////
// acquires or releases mouse control
function  DI8MouseControl(_acquire: boolean): boolean;
var
  _hr : hResult;
begin
  if (NOT _acquire) then
    _hr := DIM8.Unacquire
    else _hr := DIM8.Acquire;

  Result := NOT FAILED (_hr);
end;

//////////////////////////////////////////////////////////////////////////
// reads the current mouse state
function  DI8GetMouseState(var dX, dY: integer;
  var iLBtnUp, iLBtnDown, iLBtnDblClick,
  iRBtnUp, iRBtnDown, iRBtnDblClick: integer): boolean;
var
  _hr : hResult;
  _od : TDIDeviceObjectData;
  bLeftButtonEvent, bRightButtonEvent : boolean;
  _time : dWord;
  _elements : dWord;

begin
  Result := false;

  dX  := 0; dY  := 0;
  iLBtnUp := 0; iLBtnDown := 0;
  iRBtnUp := 0; iRBtnDown := 0;
  iLBtnDblClick := 0; iRBtnDblClick := 0;

  // Read event by event.
  repeat
    _elements := 1;
    _hr := DIM8.GetDeviceData(SizeOf(TDIDeviceObjectData),
                              @_od, _elements, 0);
    if _hr = DIERR_INPUTLOST then
      begin
        _hr := DIM8.Acquire;
        if not failed(_hr) then
          _hr := DIM8.GetDeviceData (SizeOf(TDIDeviceObjectData),
                                         @_od, _elements, 0);
      end;
    if (failed(_hr)) then exit;
    Result := true;
    if (_elements = 0) then exit;

    // Analyze event data
    bLeftButtonEvent := false;
    bRightButtonEvent := false;
    case _od.dwOfs of
      DIMOFS_X :
        dX := dX + integer(_od.dwData);
      DIMOFS_Y :
        dY := dY + integer(_od.dwData);
      DIMOFS_BUTTON0 :
        if DIMButSwapped then
          bRightButtonEvent := TRUE
          else bLeftButtonEvent := TRUE;
      DIMOFS_BUTTON1 :
        if DIMButSwapped then
          bLeftButtonEvent := TRUE
          else bRightButtonEvent := TRUE;
    end;

    // Button 0 clicked or released ?
    if (bLeftButtonEvent) then begin
      DIMou0Clicked := (_od.dwData and $80 = $80);
      if (NOT DIMou0Clicked) then begin
        inc(iLBtnUp);
        // Double-click check
        _time := GetTickCount;
        if (_time - DIM0Released < DIMTimeOut) then begin
          DIM0Released := 0;
          Inc (iLBtnDblClick);
        end else
          DIM0Released := _time;
      end
        else Inc (iLBtnDown);
    end;

    // Button 1 clicked or released ?
    if (bRightButtonEvent) then begin
      DIMou1Clicked := (_od.dwData and $80 = $80);
      if (NOT DIMou1Clicked) then begin
        Inc (iRBtnUp);
        // Double-click check
        _time := GetTickCount;
        if (_time - DIM1Released < DIMTimeOut) then begin
          DIM1Released := 0;
          Inc (iRBtnDblClick);
        end else
          DIM1Released := _time;
      end
        else Inc (iRBtnDown);
    end;
  until (_elements = 0);
end;


//////////////////////////////////////////////////////////////////////////
// this lengthy procedure reads the keyboard state and
// creates characters based on what keys are pressed
procedure ProcessKeysToChar;
var
  iIndex: integer;
  bUseCapsChar: boolean;
  bDown, bChanged: boolean;
  cCharToInsert: char;
  iCurrentTick: integer;
  uCode: byte;
begin
  //
  // update the shift keys' status first
  //
  uShiftStates := 0;
  for iIndex := 1 to 8 do
    if ((DIKeyBuffer [arShiftTable [iIndex].uCode] AND DI_KEY_DOWN) <> 0) then
      uShiftStates := uShiftStates OR arShiftTable [iIndex].uShift;

  //
  // if any CTRL or ALT keys are pressed, we can't have valid char
  // combos, so skip out now
  //
  if ((uShiftStates AND (SH_ALTKEYS OR SH_CTRLKEYS))<> 0) then exit;

  //
  // get current tick count. if elapse time since last processing
  // is less that the minimum delay, then exit now. otherwise,
  // remember this current tick and get on with business
  //
  iCurrentTick := GetTickCount;
  if ((iCurrentTick - DIConsoleLastRead) < DIConsoleMinDelay) then exit;
  DIConsoleLastRead := iCurrentTick;

  //
  // use caps value for key-char combos if
  //    CAPS lock is active AND not SHIFT keys are down
  //      OR
  //    CAPS lock is not active AND at least one SHIFT key is down
  //
  bUseCapsChar := ((uShiftStates AND SH_CAPSLOCK) <> 0);
  if ((uShiftStates AND SH_SHIFTKEYS) <> 0) then
    bUseCapsChar := NOT bUseCapsChar;

  //
  //
  cCharToInsert := #0;
  for iIndex := 0 to (KEY_TABLE_SIZE-1) do begin
    //
    // get the keycode, and determine if key is currently down,
    // and whether is has changed from last time we checked
    //
    uCode := KeyTable [iIndex].uCode;
    bDown := ((DIKeyBuffer [uCode] AND DI_KEY_DOWN) <> 0);
    bChanged := (DIPrevKeyBuffer [uCode] <> DIKeyBuffer [uCode]);

    //
    // process only keys that are pressed down, and have
    // changed since last we checked
    //
    if (bDown AND bChanged) then begin
      //
      // determine which char to extract from the table
      // and insert into queue
      //
      if (bUseCapsChar) then
        cCharToInsert := KeyTable [iIndex].cCaps
        else cCharToInsert := KeyTable [iIndex].cNormal;

      // out of here now that we have a key to insert
      break;
    end;
  end;

  //
  // if there is a character to insert, then do so here
  //
  if (cCharToInsert <> #0) then
      KeyboardQueue.InsertChar (cCharToInsert);
end;

//////////////////////////////////////////////////////////////////////////
// acquires or release control of keyboard
function DI8KeyboardControl(_acquire: boolean): boolean;
var
  _hr : hResult;
begin
  if (NOT _acquire) then
    _hr := DIK8.Unacquire
    else _hr := DIK8.Acquire;

  Result := (NOT (FAILED(_hr)));
end;

//////////////////////////////////////////////////////////////////////////
// reads the current keyboard state into the buffer
function DI8GetKeyboardState: boolean;
var
  hRetVal : hResult;
begin
  // save a copy of the key buffer
  System.Move (DIKeyBuffer, DIPrevKeyBuffer, sizeof (DIKeyBuffer));
  // Get key states.
  hRetVal := DIK8.GetDeviceState(SizeOf(DIKeyBuffer), @DIKeyBuffer);
  // If input was lost, re-acquire.
  if (hRetVal = DIERR_INPUTLOST) OR (hRetVal = DIERR_NOTACQUIRED) then begin
    hRetVal := DIK8.Acquire;
    if (NOT FAILED (hRetVal)) then
      hRetVal := DIK8.GetDeviceState (SizeOf (DIKeyBuffer), @DIKeyBuffer);
  end;

  // All right ?
  Result := NOT FAILED (hRetVal);
  // if failed, recopy previous buffer to current
  if (NOT Result) then
    System.Move (DIPrevKeyBuffer, DIKeyBuffer, sizeof (DIKeyBuffer))
  // process keys to chars if necessary
  else if (DIConsoleMode) then
    ProcessKeysToChar;
  //
end;

//////////////////////////////////////////////////////////////////////////
// returns TRUE if specified key is pressed
function DI8KeyDown(_key: byte): boolean;
begin
  Result := ((DIKeyBuffer[_key] and DI_KEY_DOWN) <> 0);
end;

//////////////////////////////////////////////////////////////////////////
// returns console mode status
function  DI8GetConsoleMode: boolean;
begin
  Result := DIConsoleMode;
end;

//////////////////////////////////////////////////////////////////////////
// sets/clears console mode operations
procedure DI8SetConsoleMode (AConsoleMode: boolean);
begin
  DIConsoleMode := AConsoleMode;
end;


//////////////////////////////////////////////////////////////////////////
procedure InitDeviceHandlers;
begin
  GlobalLastTick := GetTickCount;
  EventQueue := TZEEventManager.Create;
  KeyboardQueue := TZEKeyCharactersQueue.Create (iKeyboardQueueSize);
  ZeroMemory (@DIKeyBuffer, SizeOf (DIKeyBuffer));
  ZeroMemory (@DIPrevKeyBuffer, SizeOf (DIPrevKeyBuffer));
end;

//////////////////////////////////////////////////////////////////////////
procedure CloseDeviceHandlers;
begin
  FreeAndNIL (EventQueue);
  FreeAndNIL (KeyboardQueue);
end;


end.

