{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaIntImpl.PAS
              Implementations of ZetaInterfaces
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DLL/ZetaIntfImpl.pas,v 1.2 2002/12/18 08:28:50 Vij Exp $
  $Log: ZetaIntfImpl.pas,v $
  Revision 1.2  2002/12/18 08:28:50  Vij
  New API functions added

  Revision 1.1  2002/11/02 07:04:43  Vij
  New modules added to version control



 ============================================================================}

unit ZetaIntfImpl;

interface

uses
  Windows,
  Types,
  //
  ZblAppFrame,
  //
  ZZEWorld,
  //ZZEWinWrapper,
  ZZEViewMap,
  ZetaTypes,
  ZetaInterfaces,
  ZbGameUtils,
  ZbCallbacks;
  //ZbScriptMaster;


type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEString = class (TInterfacedObject, IZEString)
  private
    FData: PChar;
  public
    constructor Create (AValue: String);
    destructor Destroy; override;
    //
    function GetPointer: PChar; stdcall;
    function GetSize: Integer; stdcall;
    procedure CopyToBuffer (DestBuf: PChar; iBufLen: Integer); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEUtils = class (TInterfacedObject, IZEUtils)
    procedure CallbackClear; stdcall;
    procedure CallbackAdd (lpszRefName: PChar; lpfnCallback: tCALLBACK); stdcall;
    //
    function GetExitOnEscape: integer; stdcall;
    procedure SetExitOnEscape (iActive: integer); stdcall;
    function GetShowGrid: integer; stdcall;
    procedure SetShowGrid (iActive: integer); stdcall;
    function GetShowPortals: integer; stdcall;
    procedure SetShowPortals (iActive: integer); stdcall;
    function GetEditMode: integer; stdcall;
    procedure SetEditMode (iActive: integer); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEWinWrap = class (TInterfacedObject, IZEWinWrap)
  private
    //FWinWrapper: TZEWindowsWrapper;
  public
    constructor Create;
    destructor Destroy; override;
    //
    function Prepare (lpszConfigFile: PChar;
      lpfnCreateUICallback: TZbCallbackFunction;
      lpfnHandleEventCallback: TZbCallbackFunction): HRESULT; stdcall;
    function InitWindow (hInstance: HINST;
      WindowClassName, WindowTitle: PChar; WindowProc: tCALLBACK;
      WindowFlags: DWORD; iWidth, iHeight: integer): HRESULT; stdcall;
    procedure Execute; stdcall;
    //
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEUIManager = class (TInterfacedObject, IZEUIManager)
  public
    function GetRoot: IZEUIControl; stdcall;
    function CreateDesktop (lpszRefName, lpszDeskName: PChar): HRESULT; stdcall;
    function SwitchDesktop (lpszRefName: PChar): HRESULT; stdcall;
    function GetDesktop (lpszRefName: PChar): IZEUIControl; stdcall;
    //
    function CreateControl (lpszClassName: PChar;
      Left, Top, Right, Bottom: integer): IZEUIControl; stdcall;
    function CreateGameView (Left, Top, Right, Bottom: integer): IZEUIControl; stdcall;
    //
    function GetProp (Control: IZEUIControl; lpszPropName: PChar): Integer; stdcall;
    procedure SetProp (Control: IZEUIControl; lpszPropName, lpszPropValue: PChar); stdcall;
    procedure ToggleParentFontUse (Control: IZEUIControl; bActive: Integer); stdcall;
    //
    procedure Insert (Container, Control: IZEUIControl); stdcall;
    procedure Show (Control: IZEUIControl); stdcall;
    procedure Hide (Control: IZEUIControl); stdcall;
    //
    function IsVisible (Control: IZEUIControl): Integer; stdcall;
    procedure Enable (Control: IZEUIControl; bActive: Integer); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZECore = class (TInterfacedObject, IZECore)
  public
    function ScreenWidth: integer; stdcall;
    function ScreenHeight: integer; stdcall;
    function ScreenColorDepth: integer; stdcall;
    //
    function PlayMusic (lpszMusicName: PChar): HRESULT; stdcall;
    function ClearMusic: HRESULT; stdcall;
    function PlaySound (lpszSoundName: PChar): HRESULT; stdcall;
    function PlayCutScene (lpszCutSceneFile: PChar): HRESULT; stdcall;
    //
    function IsMusicActive: HRESULT; stdcall;
    procedure ToggleMusic (bActive: Integer); stdcall;
    function IsSoundActive: HRESULT; stdcall;
    procedure ToggleSound (bActive: Integer); stdcall;
    //
    procedure ToggleFPSDisplay (bActive: Integer); stdcall;
    procedure MoveFPSDisplay (X, Y: integer); stdcall;
    //
    procedure RunDialog (Control: IZEUIControl); stdcall;
    procedure ShowInputBox (lpszPrompt: PChar; iCommand: integer; ANoCancel: tINTBOOL); stdcall;
    procedure ShowMsgBox (lpfnMessage: PChar); stdcall;
    procedure ShowMsgBox2 (lpszMessage: PChar; SendCommand: Integer); stdcall;
    procedure ShowMsgBoxEx (lpfnMessage: PChar; Left, Top, Right, Bottom: integer); stdcall;
    procedure ShowTextDialog (iWidth, iHeight: Integer; lpszFileName, lpszFontName: PChar); stdcall;
    //
    procedure TogglePause (bActive: Integer); stdcall;
    function GetPauseState: Integer; stdcall;
    procedure Terminate; stdcall;
    //
    procedure PushEvent (EventCommand: Integer); stdcall;
    procedure StartTimer (ATimerValue: Cardinal); stdcall;
    procedure StartTimerEx (AMinutes, ASeconds: Cardinal); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEZetaEntity = class (TInterfacedObject, IZEZetaEntity)
  private
    FEntity: TZEEntity;
  protected
    function CheckTiles (Target: IZEZetaEntity;
      var tRef, tTarget: TZEViewTile): boolean; stdcall;
  public
    constructor Create (AEntity: TZEEntity);
    //
    function GetInternalData: Integer; stdcall;
    function Duplicate: Integer; stdcall;
    //
    function GetName: Integer; stdcall;
    function GetBaseName: Integer; stdcall;
    function GetWidth: Integer; stdcall;
    function GetLength: Integer; stdcall;
    function IsOrientable: Integer; stdcall;
    function CanMove: Integer; stdcall;
    function MovementRate: Integer; stdcall;
    function Updateable: Integer; stdcall;
    //
    function OnMap: Integer; stdcall;
    function OnActiveArea: Integer; stdcall;
    //
    function Orientation: Integer; stdcall;
    function GetStateInfo: Integer; stdcall;
    procedure SetStateInfo (AStateInfo: PChar); stdcall;
    //
    procedure SetHandler (ANewHandler: TZERemoteEntityCallback); stdcall;
    procedure ClearHandler; stdcall;
    function GetHandlerData: Integer; stdcall;
    procedure SetHandlerData (HData: Integer); stdcall;
    //
    procedure BeginPerform (APerformState: PChar; ibImmediate: Integer); stdcall;
    function CanPerform (APerformState: PChar): Integer; stdcall;
    function IsPerforming: Integer; stdcall;
    procedure ClearActions; stdcall;
    procedure MoveTo (X, Y, Z: Integer); stdcall;
    //
    function CanSee (Target: IZEZetaEntity): Integer; stdcall;
    function HowFarFrom (Target: IZEZetaEntity): Integer; stdcall;
    procedure Face (Target: IZEZetaEntity); stdcall;
    procedure Approach (Target: IZEZetaEntity); stdcall;
    //
    procedure FaceTo (Direction: TZbDirection); stdcall;
    function CanStepTo (Direction: TZbDirection): Integer; stdcall;
    procedure StepTo (Direction: TZbDirection); stdcall;
    //
    procedure SetCaption (ACaption: PChar); stdcall;
    procedure PlayEffects (AEffectName: PChar); stdcall;
    procedure ClearEffects; stdcall;
    //
    function GetAreaName: PChar; stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEZetaWorld = class (TInterfacedObject, IZEZetaWorld)
  public
    function SwitchToArea (lpszAreaName: PChar): HRESULT; stdcall;
    function Load (lpszWorldFile: PChar): HRESULT; stdcall;
    //
    function GetPC: Integer; stdcall;
    function CreatePC (lpszMasterName, lpszWorkingName: PChar;
      lpfnCallback: tCALLBACK): HRESULT; stdcall;
    function ReplacePC (lpszMasterName, lpszWorkingName: PChar;
      lpfnCallback: tCALLBACK): HRESULT; stdcall;
    function ClearPC: HRESULT; stdcall;
    //
    procedure DropPC; stdcall;
    procedure DropPCEx (lpszAreaName: PChar; X, Y, Z: Integer); stdcall;
    procedure UnDropPC; stdcall;
    //
    procedure CenterPC; stdcall;
    procedure CenterAt (X, Y, Z: Integer); stdcall;
    //
    procedure LockPortals; stdcall;
    procedure UnlockPortals; stdcall;
    //
    function GetEntity (lpszEntityName: PChar): Integer; stdcall;
    function GetEntity2 (hEntity: Integer): Integer; stdcall;
    procedure DeleteEntity (lpszEntityName: PChar); stdcall;
    procedure EnumEntities (EECallback: TZEEnumEntityProc); stdcall;
    //
    procedure QueueForDeletion (lpszEntityName: PChar); stdcall;
    function DropEntity (lpszEntityBase, lpszEntityName: PChar;
      X, Y, Z: Integer): Integer; stdcall;
    //
    procedure Clear; stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEZetaMain = class (TInterfacedObject, IZEZetaMain)
  private
    FUtils: IZEUtils;
    FWinWrap: IZEWinWrap;
    FUIManager: IZEUIManager;
    FCore: IZECore;
    FWorld: IZEZetaWorld;
  public
    constructor Create;
    destructor Destroy; override;
    //
    function Utils: Integer; stdcall;
    function WinWrapper: Integer; stdcall;
    function UIManager: Integer; stdcall;
    function Core: Integer; stdcall;
    function ZetaWorld: Integer; stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function ZEIntf_GetZetaMain: Integer; stdcall;


implementation

uses
  Math,
  SysUtils,
  StrUtils,
  //
  ZbScriptable,
  ZbUtils,
  ZbDebug,
  ///
  ZEDXFramework,
  //ZEDXDev,
  //
  ZEWSDefines,
  ZEWSBase,
  ZEWSDialogs,
  //
  ZZEGameWindow,
  ZZECore;


{ TZEString }

//////////////////////////////////////////////////////////////////////////
constructor TZEString.Create (AValue: String);
begin
  inherited Create;
  FData := StrNew (PChar (AValue));
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEString.Destroy;
begin
  StrDispose (FData);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEString.GetPointer: PChar; stdcall;
begin
  Result := FData;
end;

//////////////////////////////////////////////////////////////////////////
function TZEString.GetSize: Integer; stdcall;
begin
  Result := StrLen (FData) + 1;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEString.CopyToBuffer (DestBuf: PChar; iBufLen: Integer); stdcall;
var
  iSizeToCopy: Integer;
begin
  if (DestBuf = NIL) OR (iBufLen <= 0) then Exit;
  //
  iSizeToCopy := Math.Min (iBufLen, GetSize);
  StrLCopy (DestBuf, FData, iSizeToCopy);
end;


{ TZEUtils }

//////////////////////////////////////////////////////////////////////////
procedure TZEUtils.CallbackClear; stdcall;
begin
  Callbacks.Clear;
  //if (ScriptMaster <> NIL) then ScriptMaster.Clear;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUtils.CallbackAdd (lpszRefName: PChar; lpfnCallback: tCALLBACK); stdcall;
begin
  Callbacks.Add (lpszRefName, TZbCallbackFunction (lpfnCallback));
  //if (ScriptMaster <> NIL) then
  //  ScriptMaster.AddHandler (lpszRefName, TZbScriptCallback (lpfnCallback));
end;

//////////////////////////////////////////////////////////////////////////
function TZEUtils.GetExitOnEscape: integer; stdcall;
begin
  Result := IfThen (g_ExitOnEscape, 1, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUtils.SetExitOnEscape (iActive: integer); stdcall;
begin
  g_ExitOnEscape := (iActive <> 0);
end;

//////////////////////////////////////////////////////////////////////////
function TZEUtils.GetShowGrid: integer; stdcall;
begin
  Result := IfThen (GlobalViewShowGrid, 1, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUtils.SetShowGrid (iActive: integer); stdcall;
begin
  GlobalViewShowGrid := (iActive <> 0);
end;

//////////////////////////////////////////////////////////////////////////
function TZEUtils.GetShowPortals: integer; stdcall;
begin
  Result := IfThen (GlobalViewShowPortals, 1, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUtils.SetShowPortals (iActive: integer); stdcall;
begin
  GlobalViewShowPortals := (iActive <> 0);
end;

//////////////////////////////////////////////////////////////////////////
function TZEUtils.GetEditMode: integer; stdcall;
begin
  Result := IfThen (GlobalViewEditMode, 1, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUtils.SetEditMode (iActive: integer); stdcall;
begin
  GlobalViewEditMode := (iActive <> 0);
end;


{ TZEWinWrap }

//////////////////////////////////////////////////////////////////////////
constructor TZEWinWrap.Create;
begin
  inherited Create;
  //FWinWrapper := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEWinWrap.Destroy;
begin
  //FWinWrapper.Free;
  if (g_AppWrap <> NIL) then ZbLib_AppFrame_Done;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWinWrap.Prepare (lpszConfigFile: PChar;
  lpfnCreateUICallback: TZbCallbackFunction;
  lpfnHandleEventCallback: TZbCallbackFunction): HRESULT; stdcall;
begin
  SetupEngineCreator (lpszConfigFile,
    TZbCallbackFunction (lpfnCreateUICallback),
    TZbCallbackFunction (lpfnHandleEventCallback));
  {
  FWinWrapper := WrapperCreate (String (lpszConfigFile),
    lpfnCreateUICallback, lpfnHandleEventCallback);
  //
  if (FWinWrapper <> NIL) then
    Result := S_OK
    else Result := S_FALSE;
  }
  Result := S_OK;
end;

//////////////////////////////////////////////////////////////////////////
function TZEWinWrap.InitWindow (hInstance: HINST;
  WindowClassName, WindowTitle: PChar; WindowProc: tCALLBACK;
  WindowFlags: DWORD; iWidth, iHeight: integer): HRESULT; stdcall;
var
  bSuccess: boolean;
begin
  ZbLib_AppFrame_Init (hInstance, FALSE, WindowClassName, WindowTitle, iWidth, iHeight);
  Result := S_OK;
  {//
  Result := S_FALSE;
  if (FWinWrapper = NIL) then Exit;
  //
  bSuccess := FWinWrapper.CreateWindow (hInstance, WindowClassName, WindowTitle,
    TWindowsCallback (WindowProc), WindowFlags, iWidth, iHeight);
  //
  if (bSuccess) then Result := S_OK;}
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEWinWrap.Execute; stdcall;
begin
  AttachToAppFrame;
  ZbLib_AppFrame_Run;
  //if (FWinWrapper <> NIL) then FWinWrapper.Execute;
end;


{ TZEUIManager }

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.GetRoot: IZEUIControl; stdcall;
begin
  if (CoreEngine <> NIL) then
    Result := IZEUIControl (CoreEngine.WinSysRoot)
    else Result := 0;
end;

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.CreateDesktop (lpszRefName, lpszDeskName: PChar): HRESULT; stdcall;
var
  Desktop: TZEControl;
begin
  Result := S_FALSE;
  if (CoreEngine <> NIL) then begin
     Desktop := CoreEngine.WinSysRoot.AddDesktop (String (lpszRefName), String (lpszDeskName));
     if (Desktop <> NIL) then Result := S_OK;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.SwitchDesktop (lpszRefName: PChar): HRESULT; stdcall;
var
  Desktop: TZEControl;
begin
  Result := S_FALSE;
  if (CoreEngine <> NIL) then begin
    Desktop := CoreEngine.WinSysRoot [String (lpszRefName)];
    if (Desktop <> NIL) then begin
      CoreEngine.WinSysRoot.UseDesktop (String (lpszRefName));
      Result := S_OK;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.GetDesktop (lpszRefName: PChar): IZEUIControl; stdcall;
begin
  if (CoreEngine <> NIL) then
    Result := IZEUIControl (CoreEngine.WinSysRoot [String (lpszRefName)])
    else Result := 0;
end;

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.CreateControl (lpszClassName: PChar;
  Left, Top, Right, Bottom: integer): IZEUIControl; stdcall;
var
  Control: TZEControl;
begin
  Result := 0;
  //
  if (CoreEngine <> NIL) then begin
    Control := ZEWSBase.CreateControl (string (lpszClassName), Rect (Left, Top, Right, Bottom));
    if (Control <> NIL) then Result := IZEUIControl (Control);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.CreateGameView (Left, Top, Right, Bottom: integer): IZEUIControl; stdcall;
begin
  Result := 0;
  if (CoreEngine = NIL) then Exit;
  //
  if (GameWindow <> NIL) then FreeAndNIL (GameWindow);
  GameWindow := TZEGameWindow.Create (Rect (Left, Top, Right, Bottom));
  //
  //GlobalViewEditMode := TRUE;
  Result := IZEUIControl (GameWindow);
end;

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.GetProp (Control: IZEUIControl; lpszPropName: PChar): Integer; stdcall;
var
  IString: IZEString;
  PropValue: String;
begin
  Result := 0;
  try
    PropValue := TZbScriptable (Control).GetPropertyValue (lpszPropName);
    if (PropValue = '') then Exit;
    //
    IString := TZEString.Create (PropValue) as IZEString;
    IString._AddRef;
    Result := Integer (IString);
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUIManager.SetProp (Control: IZEUIControl; lpszPropName, lpszPropValue: PChar); stdcall;
begin
  try
    TZbScriptable (Control).SetPropertyValue (lpszPropName, lpszPropValue);
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUIManager.ToggleParentFontUse (Control: IZEUIControl; bActive: Integer); stdcall;
begin
  try
    TZEControl (Control).SetStyle (syUseParentFont, (bActive <> 0));
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUIManager.Insert (Container, Control : IZEUIControl); stdcall;
begin
  try
    TZEGroupControl (Container).Insert (TZEControl (Control));
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUIManager.Show (Control: IZEUIControl); stdcall;
begin
  try
    TZEControl (Control).Show;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUIManager.Hide (Control: IZEUIControl); stdcall;
begin
  try
    TZEControl (Control).Hide;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEUIManager.IsVisible (Control: IZEUIControl): Integer; stdcall;
begin
  try
    Result := Ord (TZEControl (Control).GetState (stVisible));
  except
    Result := 0;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEUIManager.Enable (Control: IZEUIControl; bActive: Integer); stdcall;
begin
  try
    TZEControl (Control).SetState (stDisabled, bActive = 0);
  except
  end;
end;


{ TZECore }

//////////////////////////////////////////////////////////////////////////
function TZECore.ScreenWidth: integer; stdcall;
begin
  Result := IfThen (CoreEngine = NIL, 0, CoreEngine.ScreenWidth);
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.ScreenHeight: integer; stdcall;
begin
  Result := IfThen (CoreEngine = NIL, 0, CoreEngine.ScreenHeight);
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.ScreenColorDepth: integer; stdcall;
begin
  Result := IfThen (CoreEngine = NIL, 0, CoreEngine.ScreenDepth);
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.PlayMusic (lpszMusicName: PChar): HRESULT; stdcall;
begin
  Result := S_FALSE;
  if (CoreEngine <> NIL) then begin
    CoreEngine.SetBackgroundMusic (lpszMusicName);
    Result := S_OK;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.ClearMusic: HRESULT; stdcall;
begin
  Result := S_FALSE;
  if (CoreEngine <> NIL) then begin
    CoreEngine.ClearBackgroundMusic;
    Result := S_OK;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.PlaySound (lpszSoundName: PChar): HRESULT; stdcall;
begin
  Result := S_FALSE;
  if (CoreEngine <> NIL) then begin
    CoreEngine.PlaySound (lpszSoundName);
    Result := S_OK;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.PlayCutScene (lpszCutSceneFile: PChar): HRESULT; stdcall;
begin
  Result := S_FALSE;
  if (CoreEngine <> NIL) then begin
    CoreEngine.PlayCutScene (lpszCutSceneFile);
    Result := S_OK;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.IsMusicActive: HRESULT; stdcall;
begin
  if (CoreEngine <> NIL) AND (CoreEngine.Music) then
    Result := S_OK
    else Result := S_FALSE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ToggleMusic (bActive: Integer); stdcall;
begin
  if (CoreEngine <> NIL) then begin
    if (bActive = 0) then
      CoreEngine.Music := FALSE
      else CoreEngine.Music := TRUE;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.IsSoundActive: HRESULT; stdcall;
begin
  if (CoreEngine <> NIL) AND (CoreEngine.SoundFX) then
    Result := S_OK
    else Result := S_FALSE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ToggleSound (bActive: Integer); stdcall;
begin
  if (CoreEngine <> NIL) then begin
    if (bActive = 0) then
      CoreEngine.SoundFX := FALSE
      else CoreEngine.SoundFX := TRUE;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ToggleFPSDisplay (bActive: Integer); stdcall;
begin
  if (CoreEngine <> NIL) then begin
    if (bActive = 0) then
      CoreEngine.FPSVisible := FALSE
      else CoreEngine.FPSVisible := TRUE
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.MoveFPSDisplay (X, Y: integer); stdcall;
begin
  if (CoreEngine <> NIL) then
    CoreEngine.MoveFPSDisplayTo (Point (X, Y));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.RunDialog (Control: IZEUIControl); stdcall;
begin
  if (CoreEngine <> NIL) AND (Control <> 0) then
    CoreEngine.RunDialog (TZEControl (Control));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ShowInputBox (lpszPrompt: PChar; iCommand: integer;
  ANoCancel: tINTBOOL); stdcall;
begin
  try
    CoreEngine.ShowInputBox (String (lpszPrompt), iCommand, ANoCancel <> IBOOL_FALSE);
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ShowMsgBox (lpfnMessage: PChar); stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.ShowMsgBox (String (lpfnMessage));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ShowMsgBox2 (lpszMessage: PChar; SendCommand: Integer); stdcall;
var
  cData: String;
begin
  cData := String (lpszMessage);
  CoreEngine.ShowMsgBox (cData, SendCommand);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ShowMsgBoxEx (lpfnMessage: PChar; Left, Top, Right, Bottom: integer); stdcall;
begin
  if (CoreEngine <> NIL) then
    CoreEngine.ShowMsgBox (String (lpfnMessage), Rect (Left, Top, Right, Bottom));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.ShowTextDialog (iWidth, iHeight: Integer;
  lpszFileName, lpszFontName: PChar); stdcall;
begin
  CoreEngine.ShowTextDialog (lpszFileName, iWidth, iHeight, lpszFontName);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.TogglePause (bActive: Integer); stdcall;
begin
  GameWorld.Paused := (bActive <> 0);
end;

//////////////////////////////////////////////////////////////////////////
function TZECore.GetPauseState: Integer; stdcall;
begin
  Result := Ord (GameWorld.Paused);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.Terminate; stdcall;
begin
  if (CoreEngine <> NIL) then CoreEngine.Terminate;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.PushEvent (EventCommand: Integer); stdcall;
begin
  g_EventManager.Commands.Insert (EventCommand, 0, 0);
  //EventQueue.InsertEvent (EventCommand);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.StartTimer (ATimerValue: Cardinal); stdcall;
begin
  CoreEngine.StartCountdownTimer (ATimerValue);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZECore.StartTimerEx (AMinutes, ASeconds: Cardinal); stdcall;
begin
  CoreEngine.StartCountdownTimer (AMinutes, ASeconds);
end;


{ TZEZetaEntity }

//////////////////////////////////////////////////////////////////////////
constructor TZEZetaEntity.Create (AEntity: TZEEntity);
begin
  inherited Create;
  FEntity := AEntity;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.CheckTiles (Target: IZEZetaEntity;
  var tRef, tTarget: TZEViewTile): boolean; stdcall;
var
  ETarget: TZEEntity;
begin
  // assume FALSE return
  Result := FALSE;
  // if no target, exit now
  if (Target = NIL) then Exit;
  // if entity is NIL, or not on map, or OUR entity is not on map, exit now
  ETarget := TZEEntity (Target.GetInternalData);
  if (ETarget = NIL) OR (NOT ETarget.OnMap) OR (NOT FEntity.OnMap) then Exit;
  // get the tiles in question
  tRef := FEntity.AnchorTile;
  tTarget := ETarget.AnchorTile;
  // if the two tiles are not on the same level, exit now
  if (tRef.Owner <> tTarget.Owner) then Exit;
  //
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetInternalData: Integer; stdcall;
begin
  Result := Integer (FEntity);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.Duplicate: Integer; stdcall;
var
  IEntity: IZEZetaEntity;
begin
  IEntity := TZEZetaEntity.Create (FEntity) as IZEZetaEntity;
  IEntity._AddRef;
  Result := Integer (IEntity);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetName: Integer; stdcall;
var
  IString: IZEString;
begin
  IString := TZEString.Create (FEntity.Name) as IZEString;
  IString._AddRef;
  Result := Integer (IString);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetBaseName: Integer; stdcall;
var
  IString: IZEString;
begin
  IString := TZEString.Create (FEntity.MasterName) as IZEString;
  IString._AddRef;
  Result := Integer (IString);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetWidth: Integer; stdcall;
begin
  Result := FEntity.Width;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetLength: Integer; stdcall;
begin
  Result := FEntity.Length;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.IsOrientable: Integer; stdcall;
begin
  Result := Ord (FEntity.Orientable);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.CanMove: Integer; stdcall;
begin
  Result := Ord (FEntity.CanMove);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.MovementRate: Integer; stdcall;
begin
  Result := FEntity.MovementRate;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.Updateable: Integer; stdcall;
begin
  Result := Ord (FEntity.RequiresUpdate);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.OnMap: Integer; stdcall;
begin
  Result := Ord (FEntity.OnMap);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.OnActiveArea: Integer; stdcall;
begin
  Result := Ord (FEntity.OnActiveArea);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.Orientation: Integer; stdcall;
begin
  Result := Ord (FEntity.Orientation);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetStateInfo: Integer; stdcall;
var
  IString: IZEString;
begin
  IString := TZEString.Create (FEntity.ExtraStateInfo) as IZEString;
  IString._AddRef;
  Result := Integer (IString);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.SetStateInfo (AStateInfo: PChar); stdcall;
begin
  FEntity.ExtraStateInfo := String (AStateInfo);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.SetHandler (ANewHandler: TZERemoteEntityCallback); stdcall;
begin
  FEntity.RemoteHandler := ANewHandler;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.ClearHandler; stdcall;
begin
  FEntity.RemoteHandler := NIL;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetHandlerData: Integer; stdcall;
begin
  Result := Integer (FEntity.HandlerData);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.SetHandlerData (HData: Integer); stdcall;
begin
  FEntity.HandlerData := Pointer (HData);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.BeginPerform (APerformState: PChar; ibImmediate: Integer); stdcall;
begin
  FEntity.BeginPerform (String (APerformState), (ibImmediate <> 0));
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.CanPerform (APerformState: PChar): Integer; stdcall;
begin
  Result := Ord (FEntity.CanPerform (String (APerformState)));
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.IsPerforming: Integer; stdcall;
begin
  Result := Ord (FEntity.IsPerforming);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.ClearActions; stdcall;
begin
  FEntity.AQ_Clear;
  FEntity.ClearAction;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.MoveTo (X, Y, Z: Integer); stdcall;
begin
  FEntity.MoveTo (X, Y, Z);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.CanSee (Target: IZEZetaEntity): Integer; stdcall;
var
  tRef, tTarget: TZEViewTile;
begin
  // assume FALSE return
  Result := Ord (FALSE);
  if (NOT CheckTiles (Target, tRef, tTarget)) then Exit;
  //
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.HowFarFrom (Target: IZEZetaEntity): Integer; stdcall;
var
  tRef, tTarget: TZEViewTile;
begin
  Result := -1;
  if (NOT CheckTiles (Target, tRef, tTarget)) then Exit;
  Result := FEntity.HowFarFrom (TZEEntity (Target.GetInternalData));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.Face (Target: IZEZetaEntity); stdcall;
begin
  FEntity.Face (TZEEntity (Target.GetInternalData));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.Approach (Target: IZEZetaEntity); stdcall;
begin
  FEntity.Approach (TZEEntity (Target.GetInternalData));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.FaceTo (Direction: TZbDirection); stdcall;
begin
  FEntity.Orientation := Direction;
  FEntity.StateChanged;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.CanStepTo (Direction: TZbDirection): Integer; stdcall;
begin
  Result := IfThen (FEntity.CanStepTo (Direction), 1, 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.StepTo (Direction: TZbDirection); stdcall;
begin
  while (Direction = tdUnknown) do Direction := GetRandomDirection;
  FEntity.StepTo (Direction);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.SetCaption (ACaption: PChar); stdcall;
begin
  FEntity.CaptionText := ACaption;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.PlayEffects (AEffectName: PChar); stdcall;
begin
  FEntity.PlayEffects (String (AEffectName));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaEntity.ClearEffects; stdcall;
begin
  FEntity.ClearEffects;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaEntity.GetAreaName: PChar; stdcall;
begin
  Result := FEntity.GetAreaName;
end;


{ TZEZetaWorld }

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.SwitchToArea (lpszAreaName: PChar): HRESULT; stdcall;
begin
  GameWorld.SwitchToArea (String (lpszAreaName));
  Result := S_OK;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.Load (lpszWorldFile: PChar): HRESULT; stdcall;
begin
  Result := S_FALSE;
  if (NOT FileExists (String (lpszWorldFile))) then Exit;
  GameWorld.LoadFromFile (String (lpszWorldFile));
  Result := S_OK;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.GetPC: Integer; stdcall;
var
  IEntity: IZEZetaEntity;
begin
  if (GameWorld.PC = NIL) then
    Result := 0
  else begin
    IEntity := TZEZetaEntity.Create (GameWorld.PC) as IZEZetaEntity;
    IEntity._AddRef;
    Result := Integer (IEntity);
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.CreatePC (lpszMasterName, lpszWorkingName: PChar;
  lpfnCallback: tCALLBACK): HRESULT; stdcall;
begin
  GameWorld.CreatePC (
    String (lpszMasterName), String (lpszWorkingName),
    TZERemoteEntityCallback (lpfnCallback));
  //
  Result := S_OK;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.ReplacePC (lpszMasterName, lpszWorkingName: PChar;
  lpfnCallback: tCALLBACK): HRESULT; stdcall;
begin
  GameWorld.ReplacePC (
    String (lpszMasterName), String (lpszWorkingName),
    TZERemoteEntityCallback (lpfnCallback));
  //
  Result := S_OK;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.ClearPC: HRESULT; stdcall;
begin
  GameWorld.ClearPC;
  Result := S_OK;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.DropPC; stdcall;
begin
  GameWorld.DropPC;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.DropPCEx (lpszAreaName: PChar; X, Y, Z: Integer); stdcall;
begin
  GameWorld.DropPC (String (lpszAreaName), X, Y, Z);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.UnDropPC; stdcall;
begin
  GameWorld.UnDropPC;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.CenterPC; stdcall;
begin
  with GameWorld do
    if (PC <> NIL) then ActiveArea.Map.Center(PC.AnchorTile)
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.CenterAt (X, Y, Z: Integer); stdcall;
begin
  GameWorld.ActiveArea.Map.Center (Z, Y, X);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.LockPortals; stdcall;
begin
  if (GameWorld.PC <> NIL) then GameWorld.PC.IgnorePortals := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.UnlockPortals; stdcall;
begin
  if (GameWorld.PC <> NIL) then GameWorld.PC.IgnorePortals := FALSE;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.GetEntity (lpszEntityName: PChar): Integer; stdcall;
var
  Entity: TZEEntity;
  IEntity: IZEZetaEntity;
begin
  Result := 0;
  Entity := GameWorld.FindEntity (String (lpszEntityName));
  if (Entity = NIL) then Exit;
  //
  IEntity := TZEZetaEntity.Create (Entity) as IZEZetaEntity;
  IEntity._AddRef;
  Result := Integer (IEntity);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.GetEntity2 (hEntity: Integer): Integer; stdcall;
var
  IEntity: IZEZetaEntity;
begin
  if (hEntity = 0) then
    Result := 0
  else begin
    IEntity := TZEZetaEntity.Create (TZEEntity (hEntity)) as IZEZetaEntity;
    IEntity._AddRef;
    Result := Integer (IEntity);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.DeleteEntity (lpszEntityName: PChar); stdcall;
var
  hTarget: TZEEntity;
begin
  hTarget := GameWorld.FindEntity (String (lpszEntityName));
  //if (hTarget <> NIL) then hTarget.Unplace;
  if (hTarget <> NIL) then GameWorld.DeleteEntity (hTarget);
end;


//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.EnumEntities (EECallback: TZEEnumEntityProc); stdcall;
var
  theEntity: TZEEntity;
  theEList: TZEEntityList;
  theArea: TZEGameArea;
  iAreas, iEntities: integer;
  EntityToPass: IZEZetaEntity;
begin
  if (NOT Assigned (EECallback)) then Exit;
  //
  for iAreas := 0 to Pred (GameWorld.AreaCount) do begin
    theArea := GameWorld.GetAreaByIndex (iAreas);
    if (theArea = NIL) then continue;
    //
    theEList := theArea.Entities;
    if (theEList = NIL) then continue;
    //
    for iEntities := 0 to Pred (theEList.Count) do begin
      theEntity := theEList [iEntities];
      if (theEntity = NIL) OR (NOT theEntity.RequiresUpdate) then continue;
      //
      EntityToPass := TZEZetaEntity.Create (theEntity) as IZEZetaEntity;
      EECallback (EntityToPass);
      EntityToPass := NIL;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.QueueForDeletion (lpszEntityName: PChar); stdcall;
begin
  GameWorld.QueueForDeletion (String (lpszEntityName));
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaWorld.DropEntity (lpszEntityBase, lpszEntityName: PChar;
  X, Y, Z: Integer): Integer; stdcall;
var
  theTile: TZEViewTile;
  theEntity: TZEEntity;
  IEntity: IZEZetaEntity;
begin
  Result := 0;
  // if no area is valid, exit
  if (GameWorld.ActiveArea = NIL) OR
  // if specified coordinate is not valid, exit as well
     (NOT GameWorld.ActiveArea.Map.Valid(X, Y, Z)) then Exit;
  //
  // get tile; exit if it's not there, or it already contains an entity
  theTile := TZEViewTile (GameWorld.ActiveArea.Map [Z][X,Y]);
  if (theTile = NIL) OR (theTile.UserData <> NIL) then Exit;
  //
  theEntity := CoreEngine.EntityManager.CreateEntity (
    String (lpszEntityBase), String (lpszEntityName));
  //
  if (theEntity = NIL) then Exit;
  GameWorld.ActiveArea.PlaceEntity (theEntity, theTile);
  //
  IEntity := TZEZetaEntity.Create (theEntity) as IZEZetaEntity;
  IEntity._AddRef;
  Result := Integer (IEntity);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEZetaWorld.Clear;
begin
  GameWorld.DeleteAreas;
end;

{ TZEZetaMain }

//////////////////////////////////////////////////////////////////////////
constructor TZEZetaMain.Create;
begin
  inherited Create;
  //
  FUtils := TZEUtils.Create as IZEUtils;
  FWinWrap := TZEWinWrap.Create as IZEWinWrap;
  FUIManager := TZEUIManager.Create as IZEUIManager;
  FCore := TZECore.Create as IZECore;
  FWorld := TZEZetaWorld.Create as IZEZetaWorld;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEZetaMain.Destroy;
begin
  FWorld := NIL;
  FCore := NIL;
  FUIManager := NIL;
  FWinWrap := NIL;
  FUtils := NIL;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaMain.Utils: Integer; stdcall;
begin
  Result := Integer (FUtils);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaMain.WinWrapper: Integer; stdcall;
begin
  Result := Integer (FWinWrap);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaMain.UIManager: Integer; stdcall;
begin
  Result := Integer (FUIManager);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaMain.Core: Integer; stdcall;
begin
  Result := Integer (FCore);
end;

//////////////////////////////////////////////////////////////////////////
function TZEZetaMain.ZetaWorld: Integer; stdcall;
begin
  Result := Integer (FWorld);
end;


//////////////////////////////////////////////////////////////////////////
function ZEIntf_GetZetaMain: Integer; stdcall;
var
  ZM: IZEZetaMain;
begin
  ZM := TZEZetaMain.Create as IZEZetaMain;
  ZM._AddRef;
  Result := Integer (ZM);
end;


end.

