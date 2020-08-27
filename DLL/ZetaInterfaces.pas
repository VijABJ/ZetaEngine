{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaInterfaces.PAS
              COM Interfaces for client use
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DLL/ZetaInterfaces.pas,v 1.2 2002/12/18 08:28:50 Vij Exp $
  $Log: ZetaInterfaces.pas,v $
  Revision 1.2  2002/12/18 08:28:50  Vij
  New API functions added

  Revision 1.1  2002/11/02 07:04:42  Vij
  New modules added to version control



 ============================================================================}

unit ZetaInterfaces;

interface

uses
  Windows,
  ZblIEvents,
  ZbCallbacks,
  ZbGameUtils,
  ZZEWorld,
  ZetaTypes;

  
type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // FORWARD DECLARATIONS
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEString = interface;
  IZEUtils = interface;
  IZEWinWrap = interface;
  IZEUIControl = Integer;
  IZEUIManager = interface;
  IZECore = interface;
  IZEZetaEntity = interface;
  IZEZetaWorld = interface;
  IZEZetaMain = interface;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // callbacks
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEEnumEntityProc = procedure (Entity: IZEZetaEntity); stdcall;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEString = interface (IInterface)
    ['{A9A26220-B1D0-4EA6-8DC9-6BA0B2C35374}']
    function GetPointer: PChar; stdcall;
    function GetSize: Integer; stdcall;
    procedure CopyToBuffer (DestBuf: PChar; iBufLen: Integer); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEUtils = interface (IInterface)
    ['{5F6073CF-8CB8-4E88-A6B2-B3705E07ED2C}']
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

  IZEWinWrap = interface (IInterface)
    ['{1F7DF5F3-511D-4EFB-A055-F31E729591F6}']
    function Prepare (lpszConfigFile: PChar;
      lpfnCreateUICallback: TZbCallbackFunction;
      lpfnHandleEventCallback: TZbCallbackFunction): HRESULT; stdcall;
    function InitWindow (hInstance: HINST;
      WindowClassName, WindowTitle: PChar; WindowProc: tCALLBACK;
      WindowFlags: DWORD; iWidth, iHeight: integer): HRESULT; stdcall;
    procedure Execute; stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEUIManager = interface (IInterface)
    ['{FE7EE316-9519-4723-9975-2C3D8FB73203}']
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
    //
    function GetXPos (Control: IZEUIControl): Integer; stdcall;
    function GetYPos (Control: IZEUIControl): Integer; stdcall;
    function GetWidth (Control: IZEUIControl): Integer; stdcall;
    function GetHeight (Control: IZEUIControl): Integer; stdcall;
    //
    procedure MoveTo (Control: IZEUIControl; NewX, NewY: Integer); stdcall;
    procedure MoveRel (Control: IZEUIControl; DeltaX, DeltaY: Integer); stdcall;
    procedure Resize (Control: IZEUIControl; NewWidth, NewHeight: Integer); stdcall;
    //
    procedure Delete (Control: IZEUIControl); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZECore = interface (IInterface)
    ['{A4E9E226-F461-48E2-900B-1D69C5AF9D8E}']
    //
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
    procedure ShowMsgBoxEx (lpfnMessage: PChar; Left, Top, Right, Bottom, Command: integer); stdcall;
    procedure ShowTextDialog (iWidth, iHeight: Integer; lpszFileName, lpszFontName: PChar); stdcall;
    procedure ShowPromptDialog (iWidth, iHeight: Integer;
      lpszPrompt: PChar; iCommandToGenerate: Integer); stdcall;
    //
    procedure TogglePause (bActive: Integer); stdcall;
    function GetPauseState: Integer; stdcall;
    procedure Terminate; stdcall;
    //
    procedure PushEvent (EventCommand: Integer); stdcall;
    procedure StartTimer (ATimerValue: Cardinal); stdcall;
    procedure StartTimerEx (AMinutes, ASeconds: Cardinal); stdcall;
    //
    procedure AddKeyHook (KeyCode: Integer; UserHandler: TZbKeyCallback); stdcall;
    procedure ClearKeyHook (KeyCode: Integer); stdcall;
    //
    procedure ToggleHighlight (bActive: Integer); stdcall;
    function RandomInt (Range: Integer): Integer; stdcall;
    procedure SetMusicVolume (AVolumePercent: Integer); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEZetaEntity = interface (IInterface)
    ['{72DA30D2-5280-4F0E-B49A-C27CE2898F95}']
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
    procedure Displace (Direction: TZbDirection); stdcall;
    procedure Teleport (DestRef: Pointer); stdcall;
    function DirectionTo (Target: IZEZetaEntity): TZbDirection; stdcall;
    //
    function GetLocationX: Integer; stdcall;
    function GetLocationY: Integer; stdcall;
    function GetLocationZ: Integer; stdcall;
    //
    procedure TeleportTo (X, Y, Z: Integer); stdcall;
    procedure SwapWith (Target: IZEZetaEntity); stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEZetaWorld = interface (IInterface)
    ['{FA1D9F10-2A22-4C7D-981E-688EF1398876}']
    //
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
    function GetCurrentAreaName: Integer; stdcall;
    //
    function Save (lpszWorldFile: PChar): HRESULT; stdcall;
    function GetEntity3 (X, Y, Z: Integer): Integer; stdcall;
    function CheckLocation (X, Y, Z: Integer): Integer; stdcall;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZEZetaMain = interface (IInterface)
    ['{2ACE3741-E207-400B-A11E-500B32736152}']
    function Utils: Integer; stdcall;
    function WinWrapper: Integer; stdcall;
    function UIManager: Integer; stdcall;
    function Core: Integer; stdcall;
    function ZetaWorld: Integer; stdcall;
  end;


implementation


end.

