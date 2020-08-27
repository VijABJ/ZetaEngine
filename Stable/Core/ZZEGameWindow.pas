{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZEGameWindow.PAS
              Contains the Window that manages the isometric view
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Core/ZZEGameWindow.pas,v 1.3 2002/11/02 06:34:57 Vij Exp $
  $Log: ZZEGameWindow.pas,v $
  Revision 1.3  2002/11/02 06:34:57  Vij
  added full support for game action on mouse-clicks

  Revision 1.2  2002/10/01 12:29:30  Vij
  Added handling code that passes off clicks to the GameWorld when in play mode.

  Revision 1.1.1.1  2002/09/11 21:11:42  Vij
  Starting Version Control


 ============================================================================}

Unit ZZEGameWindow;

interface

uses
  Windows,
  //
  ZblIEvents,
  //
  ZEWSBase,
  ZEWSMisc,
  ZEWSDialogs,
  //
  ZZConstants,
  ZZEViewMap;


const
  cmGameWindowBase      = 400;
  cmGameWindowMax       = cmGameWindowBase + 99;

  cmLClickTile          = cmGameWindowBase + 001;
  cmRClickTile          = cmGameWindowBase + 002;
  cmCtrlLClickTile      = cmGameWindowBase + 003;
  cmCtrlRClickTile      = cmGameWindowBase + 004;
  cmShiftLClickTile     = cmGameWindowBase + 005;
  cmShiftRClickTile     = cmGameWindowBase + 006;

  cmNewTileHighlighted  = cmGameWindowBase + 010;


type
  TZEGameInteractMode = (gmNormal, gmEditing, gmScripted);

  TZEGameWindow = class (TZEControl)
  private
    FViewMap: TZEViewMap;
    FKeyboardScroll: boolean;
    FGameMode: TZEGameInteractMode;
    FTileAtCursor: TZEViewTile;
    FLastPaused: Cardinal;
  protected
    procedure SetView (AViewMap: TZEViewMap);
  public
    constructor Create (rBounds: TRect); override;
    destructor Destroy; override;
    //
    procedure Paint; override;
    procedure HandleEvent (var Event: TZbEvent); override;
    //
    property ViewMap: TZEViewMap read FViewMap write SetView;
    property KeyboardScroll: boolean read FKeyboardScroll write FKeyboardScroll;
    property GameMode: TZEGameInteractMode read FGameMode write FGameMode;
    //
    procedure MouseLeftClick (var Event: TZbEvent); override;
    procedure MouseRightClick (var Event: TZbEvent); override;
  end;

var
  GameWindow: TZEGameWindow = NIL;


implementation

uses
  Types,
  SysUtils,
  DirectInput8,
  //
  ZbGameUtils,
  ZEDXFramework,
  ZEWSStandard,
  ZEWSDefines,
  //
  ZZESupport,
  ZZEWorld;


  function DI8KeyDown (KeyCode: Integer): LongBool;
  begin
    Result := (g_EventManager.Keyboard.KeyState(KeyCode) = ksPressed);
  end;

  function CheckScrollKey: TZbDirection;
  begin
    if ((DI8KeyDown (DIK_LEFT)) OR (DI8KeyDown (DIK_NUMPAD4))) then
      Result := tdEast
    else if (DI8KeyDown (DIK_NUMPAD7)) then
      Result := tdSouthEast
    else if ((DI8KeyDown(DIK_UP)) OR (DI8KeyDown (DIK_NUMPAD8))) then
      Result := tdSouth
    else if (DI8KeyDown (DIK_NUMPAD9)) then
      Result := tdSouthWest
    else if ((DI8KeyDown(DIK_RIGHT)) OR (DI8KeyDown (DIK_NUMPAD6))) then
      Result := tdWest
    else if (DI8KeyDown (DIK_NUMPAD3)) then
      Result := tdNorthWest
    else if ((DI8KeyDown(DIK_DOWN)) OR (DI8KeyDown (DIK_NUMPAD2))) then
      Result := tdNorth
    else if (DI8KeyDown (DIK_NUMPAD1)) then
      Result := tdNorthEast
    else
      Result := tdUnknown;
  end;

  function CheckMoveKey: TZbDirection;
  begin
    if ((DI8KeyDown (DIK_LEFT)) OR (DI8KeyDown (DIK_NUMPAD4))) then
      Result := tdSouthWest
    else if (DI8KeyDown (DIK_NUMPAD7)) then
      Result := tdWest
    else if ((DI8KeyDown(DIK_UP)) OR (DI8KeyDown (DIK_NUMPAD8))) then
      Result := tdNorthWest
    else if (DI8KeyDown (DIK_NUMPAD9)) then
      Result := tdNorth
    else if ((DI8KeyDown(DIK_RIGHT)) OR (DI8KeyDown (DIK_NUMPAD6))) then
      Result := tdNorthEast
    else if (DI8KeyDown (DIK_NUMPAD3)) then
      Result := tdEast
    else if ((DI8KeyDown(DIK_DOWN)) OR (DI8KeyDown (DIK_NUMPAD2))) then
      Result := tdSouthEast
    else if (DI8KeyDown (DIK_NUMPAD1)) then
      Result := tdSouth
    else
      Result := tdUnknown;
  end;


//////////////////////////////////////////////////////////////////////////
constructor TZEGameWindow.Create (rBounds: TRect);
begin
  inherited Create (rBounds);
  ChangeMouseEventMask ([evLBtnDown, evLBtnUp, evLBtnAuto,
                     evRBtnDown, evRBtnUp, evRBtnAuto,
                     evMouseMove]);
  WClassName := CC_GAME_WINDOW;
  //
  BackColor := $000000;
  GetMouseFallThrough;
  FViewMap := NIL;
  FKeyboardScroll := TRUE;
  FGameMode := gmNormal;
  FTileAtCursor := NIL;
  //
  FLastPaused := GetTickCount;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEGameWindow.Destroy;
begin
  ClearMouseFallThrough;
  FViewMap := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWindow.SetView (AViewMap: TZEViewMap);
begin
  FViewMap := AViewMap;
  if (FViewMap <> NIL) then
    FViewMap.ScreenBounds := Bounds;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWindow.Paint;
begin
  ImageFill (DefaultSprite, LocalBounds);
  if (FViewMap <> NIL) then FViewMap.Draw;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWindow.HandleEvent (var Event: TZbEvent);
var
  P: TPoint;
  edges: longint;
  scrollDir: TZbDirection;
  AtTile: TZEViewTile;

const
  MOUSE_SCROLL_SPEED    = 8;
  KEYBOARD_SCROLL_SPEED = 48;

begin
  inherited HandleEvent (Event);
  //
  // no view map? then exit NOW!
  if (FViewMap = NIL) then Exit;
  //
  // handle mouse moves here...
  if (Event.m_Event = evMouseMove) then begin
    edges := g_EventManager.Mouse.GetEdgeFlags;
    if ((edges AND seLeft) <> 0) then
      FViewMap.PanVirtualView (tdEast, MOUSE_SCROLL_SPEED);
    if ((edges AND seTop) <> 0) then
      FViewMap.PanVirtualView (tdSouth, MOUSE_SCROLL_SPEED);
    if ((edges AND seRight) <> 0) then
      FViewMap.PanVirtualView (tdWest, MOUSE_SCROLL_SPEED);
    if ((edges AND seBottom) <> 0) then
      FViewMap.PanVirtualView (tdNorth, MOUSE_SCROLL_SPEED);
    //
    P := ScreenToClient (Event.m_Pos);
    AtTile := FViewMap.SelectTileAt (P);
    if (AtTile <> FTileAtCursor) then begin
      FTileAtCursor := AtTile;
      //
      Event.m_Event := evCommand;
      Event.m_Command := cmNewTileHighlighted;
      Event.m_pData := AtTile;
      InsertEvent (Event);
    end;
    //
    FViewMap.PlaceSelectorAt (FTileAtCursor);
    ClearEvent (Event);
  end;
  //
  //
  if (NOT g_EventManager.Keyboard.InConsoleMode) then begin
    if (KeyboardScroll) then begin
      scrollDir := CheckScrollKey;
      if (scrollDir <> tdUnknown) then
        FViewMap.PanVirtualView (scrollDir, KEYBOARD_SCROLL_SPEED);
      //
    end
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWindow.MouseLeftClick (var Event: TZbEvent);
var
  AEvent: TZbEvent;
  Modifiers: TZEActionModifiers;
begin
  inherited;
  // exit now if no map being managed
  if (FViewMap = NIL) then Exit;
  // process the tile clicked on, if any
  if (FTileAtCursor <> NIL) then begin
    // handle edit mode here...
    if (GlobalViewEditMode) then begin
      ZeroMemory (@AEvent, SizeOf (AEvent));
      AEvent.m_Event := evCommand;
      //
      if (DI8KeyDown (DIK_LSHIFT) OR DI8KeyDown (DIK_RSHIFT)) then
        AEvent.m_Command := cmShiftLClickTile
      else if (DI8KeyDown (DIK_LCONTROL) OR DI8KeyDown (DIK_RCONTROL)) then
        AEvent.m_Command := cmCtrlLClickTile
      else
        AEvent.m_Command := cmLClickTile;
      //
      AEvent.m_pData := FTileAtCursor;
      InsertEvent (AEvent);
      ClearEvent (Event);
    end else begin
      Modifiers := [];
      if (DI8KeyDown (DIK_LSHIFT) OR DI8KeyDown (DIK_RSHIFT)) then
        Modifiers := Modifiers + [atShift];
      if (DI8KeyDown (DIK_LCONTROL) OR DI8KeyDown (DIK_RCONTROL)) then
        Modifiers := Modifiers + [atCtrl];
      if (DI8KeyDown (DIK_LALT) OR DI8KeyDown (DIK_RALT)) then
        Modifiers := Modifiers + [atAlt];
      //
      GameWorld.PerformAction (FTileAtCursor, TRUE, Modifiers);
    end;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGameWindow.MouseRightClick (var Event: TZbEvent);
var
  Modifiers: TZEActionModifiers;
begin
  inherited;
  // exit now if no map being managed
  if (FViewMap = NIL) then Exit;
  // process the tile clicked on, if any
  if (FTileAtCursor <> NIL) then begin
    if (GlobalViewEditMode) then begin
    end else begin
      Modifiers := [];
      if (DI8KeyDown (DIK_LSHIFT) OR DI8KeyDown (DIK_RSHIFT)) then
        Modifiers := Modifiers + [atShift];
      if (DI8KeyDown (DIK_LCONTROL) OR DI8KeyDown (DIK_RCONTROL)) then
        Modifiers := Modifiers + [atCtrl];
      if (DI8KeyDown (DIK_LALT) OR DI8KeyDown (DIK_RALT)) then
        Modifiers := Modifiers + [atAlt];
      //
      GameWorld.PerformAction (FTileAtCursor, FALSE, Modifiers);
    end;
  end;
end;


end.

