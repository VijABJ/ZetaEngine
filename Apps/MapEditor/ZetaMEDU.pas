{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaMEDU.PAS
              Primary Support Unit for the Zeta Map Editor
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Apps/MapEditor/ZetaMEDU.pas,v 1.4 2002/09/17 22:03:16 Vij Exp $
  $Log: ZetaMEDU.pas,v $
  Revision 1.4  2002/09/17 22:03:16  Vij
  Added cmNewMap handling. Moved constants/symbols to ZetaMEDDefs.pas.
  Added button to support changing the active map levels, and the grid
  display mode. remnants of debug code left for future use.

  Revision 1.3  2002/09/13 12:48:07  Vij
  Factored out common Mode-handling code and made classes out of it.
  This cleaned out the code much and is easier to understand and extend now.

  Revision 1.2  2002/09/12 12:13:17  Vij
  Added Header Comments



 ============================================================================}

unit ZetaMEDU;

interface


  function CreateInitialGUI (ScreenWidth, ScreenHeight: integer): integer; stdcall;
  function HandleUserEvents (iCommand, lData: integer): integer; stdcall;


implementation

uses
  Types,
  Classes,
  SysUtils,
  //
  DirectInput8,
  JclStrings,
  ZbGameUtils,
  //
  ZblIEvents,
  ZEDXSpriteIntf,
  ZEDXFramework,
  //
  ZEWSDefines,
  ZEWSBase,
  ZEWSButtons,
  ZEWSMisc,
  ZEWSDialogs,
  //
  ZZEGameWindow,
  ZZEViewMap,
  ZZEWorldIntf,
  //
  ZZECore,
  ZZEWorld,
  //
  ZZESAMM, // <-- testing
  //
  ZetaMEDDefs,
  ZetaMEDAux,
  ZetaMEDDlgs;


var
  // ****************************************
  // REFERENCES TO USER INTERFACE CONTROLS
  // ****************************************

  ctlLocationDisplay: TZEControl = NIL;
  ctlModeName: TZEControl = NIL;
  ctlEditorStatus: TZEControl = NIL;
  EditorPanel: TMedEditorPanel;
  EditorModes: TMedEditorModeList;



function GridToggler (AKey: Integer; AEvent: TZbKeyState;
  AUserData: Integer): LongBool; stdcall;
begin
  try
    if (AEvent = ksReleased) then
      g_EventManager.Commands.Insert (cmToggleGrid, 0, 0);
  except
  end;
end;

////////////////////////////////////////////////////////////////////
function CreateInitialGUI (ScreenWidth, ScreenHeight: integer): integer;
var
  Desktop: TZEDesktop;
  rBounds, rArea: TRect;
  Control: TZEControl;

const
  DIM_BUTTON_HEIGHT       = 28;
  DIM_LABEL_HEIGHT        = 40;
  DIM_MARGIN              = 5;
  DIM_TOP_PANEL_HEIGHT    = DIM_LABEL_HEIGHT + DIM_MARGIN;

  DIM_BTN_ARROW_WIDTH     = 40;
  DIM_BTN_MODE_WIDTH      = 130;
  DIM_LEFT_PANEL_WIDTH    = (DIM_BTN_ARROW_WIDTH * 2) + DIM_BTN_MODE_WIDTH;

  DIM_FPS_DISPLAY_WIDTH   = 150;
  DIM_FPS_DISPLAY_HEIGHT  = 80;
  DIM_SPRITE_PANEL_HEIGHT = 250;

  DIM_MENU_BTN_WIDTH      = 80;

  procedure GatherData;
  //var
    //iDebugIndex: integer;
    //Entity: TZEEntity;
    //Sprite: IZESprite;}
  begin
    EditorModes.Add (TMedTerrainMode.Create (EditorPanel));
    EditorModes.Add (TMedFloorMode.Create (EditorPanel));
    EditorModes.Add (TMedWallMode.Create (EditorPanel));
    EditorModes.Add (TMedEntityMode.Create (EditorPanel));
    EditorModes.Add (TMedPortalMode.Create (EditorPanel));
    EditorModes.UpdateDisplay;
    ctlModeName.SetPropertyValue (PROP_NAME_CAPTION, EditorModes.Active.Name);
    //
    //
    // FOLLOWING ARE DEBUG CODE SEQUENCES!!!
    // fill in with walkable terrain instead of water
    {HandleUserEvents (cmSelectNextSprite, 0);
    HandleUserEvents (cmShiftLClickTile, Integer (GameWorld.ActiveArea.Map [0][0,0]));
    GameWorld.ActiveArea.Map[0].GenerateLOS (Point (0, 0), Point (5, 6));
    //}
    {// select portal mode and place a start point
    HandleUserEvents (cmSelectPrevMode, 0);
    HandleUserEvents (cmLClickTile, Integer (GameWorld.ActiveArea.Map [0][0,0]));
    //}
    // select entity mode, and select library #1
    {for iDebugIndex := 0 to 1 do HandleUserEvents (cmSelectPrevMode, 0);
    //
    // select a sprite library
    for iDebugIndex := 0 to 1 do HandleUserEvents (cmSelectNextSprite, 0);
    //
    // now select a sprite
    for iDebugIndex := 0 to 7 do HandleUserEvents (cmSelectNextVariation, 0);
    HandleUserEvents (cmSelectNextVariation, 0);
    //}

    //for iDebugIndex := 0 to 4 do HandleUserEvents (cmSelectNextSprite, 0);
    //HandleUserEvents (cmSelectNextStyle, 0);
    //
    {HandleUserEvents (cmLClickTile, Integer (GameWorld.ActiveArea.Map [0][0,0]));
    Entity := TZEEntity (TZEViewTile (GameWorld.ActiveArea.Map [0][0,0]).UserData);
    Entity.GetNeighbor (tdEast);
    //for iDebugIndex := 0 to 10 do HandleUserEvents (cmSelectNextSprite, 0);}
    //for iDebugIndex := 0 to 3 do HandleUserEvents (cmSelectNextStyle, 0);
    //for iDebugIndex := 0 to 1 do HandleUserEvents (cmSelectNextVariation, 0);
    //
    //HandleUserEvents (cmLClickTile, Integer (GameWorld.ActiveArea.Map [0][0,0]));
    //Entity := TZEEntity (TZEViewTile (GameWorld.ActiveArea.Map [0][0,0]).UserData);
    //Entity.AQ_InsertFront(ActionRecordCreate (eaMoveTo, NIL,
    //  TZEViewTile (GameWorld.ActiveArea.Map [0][8,8]), tdUnknown, NIL, 0, 0
    //  ));}
    //HandleUserEvents (cmLClickTile, Integer (GameWorld.ActiveArea.Map [0][0,0]));
    //
    {HandleUserEvents (cmSelectNextVariation, 0);
    for iDebugIndex := 0 to 2 do HandleUserEvents (cmSelectNextStyle, 0);
    HandleUserEvents (cmLClickTile, Integer (GameWorld.ActiveArea.Map [0][0,0]));}
    //
    {//HandleUserEvents (cmSaveWorld, 0);

    //HandleUserEvents (cmLoadWorld, 0);
    GameWorld.SwitchToArea ('Level2');
    GameWorld.CreatePC ('Beavis', '');
    GameWorld.DropPC;
    GameWorld.PC.MoveTo (3, 22, 0);
    //}
    {HandleUserEvents (cmDropEntityPC, integer (PChar ('Paige')));
    GameWorld.PerformAction (TZEViewTile(GameWorld.ActiveArea.Map [0][5,6]), TRUE, []);
    //}
    //GameWorld.ReplacePC ('Phoebe', '');
    //GameWorld.PC.MoveTo (GameWorld.ActiveArea.Map [0][19,9]);
    //HandleUserEvents (cmGameTestMode, 0);
    //
    //GameWorld.PC.MoveTo (GameWorld.ActiveArea.Map [0][2,2]);
    //GameWorld.PC.MoveTo (GameWorld.ActiveArea.Map [0][3,0]);
    //GameWorld.PC.MoveTo (GameWorld.ActiveArea.Map [0][3,8]);
    //GameWorld.PC.MoveTo (GameWorld.ActiveArea.Map [0][3,0]);
    //GameWorld.PC.MoveTo (GameWorld.ActiveArea.Map [0][5,6]);
    //GameWorld.PC.MoveTo (GameWorld.ActiveArea.Map [0][0,0]);
    //
    //
    //Entity := CoreEngine.EntityManager.CreateEntity('MiscTree1','');
    //Entity.Orientation := tdEast;
    //Sprite := Entity.EntitySnapShot.Sprite;
    //
    //CoreEngine.PlaySound ('101Fire');
  end;

  procedure SetupMenuPanel;
  var
    iInsertionColumn: integer;
  begin
    iInsertionColumn := DIM_LEFT_PANEL_WIDTH + DIM_MARGIN;
    //
    rArea.TopLeft := Point (iInsertionColumn, DIM_MARGIN);
    rArea.BottomRight := AddPoint (rArea.TopLeft, Point (DIM_MENU_BTN_WIDTH, DIM_MARGIN));
    Control := CreateStandardButton (rArea, 'New Area', cmNewArea);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT_MENU);
    Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Ivory');
    //
    Inc (iInsertionColumn, DIM_MENU_BTN_WIDTH);
    //
    rArea.TopLeft := Point (iInsertionColumn, DIM_MARGIN);
    rArea.BottomRight := AddPoint (rArea.TopLeft, Point (DIM_MENU_BTN_WIDTH, DIM_MARGIN));
    Control := CreateStandardButton (rArea, 'Switch Area', cmSwitchArea);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT_MENU);
    Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Ivory');
    //
    Inc (iInsertionColumn, DIM_MENU_BTN_WIDTH);
    //
    rArea.TopLeft := Point (iInsertionColumn, DIM_MARGIN);
    rArea.BottomRight := AddPoint (rArea.TopLeft, Point (DIM_MENU_BTN_WIDTH, DIM_MARGIN));
    Control := CreateStandardButton (rArea, 'Delete Area', cmDeleteArea);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT_MENU);
    Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Ivory');
    //
    Inc (iInsertionColumn, DIM_MENU_BTN_WIDTH + DIM_MARGIN);
    //
    rArea.TopLeft := Point (iInsertionColumn, DIM_MARGIN);
    rArea.BottomRight := AddPoint (rArea.TopLeft, Point (DIM_MENU_BTN_WIDTH, DIM_MARGIN));
    Control := CreateStandardButton (rArea, 'New Map', cmNewMap);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT_MENU);
    Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Ivory');
    //
    Inc (iInsertionColumn, DIM_MENU_BTN_WIDTH);
    //
    rArea.TopLeft := Point (iInsertionColumn, DIM_MARGIN);
    rArea.BottomRight := AddPoint (rArea.TopLeft, Point (DIM_MENU_BTN_WIDTH, DIM_MARGIN));
    Control := CreateStandardButton (rArea, 'Load World', cmLoadWorld);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT_MENU);
    Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Ivory');
    //
    Inc (iInsertionColumn, DIM_MENU_BTN_WIDTH);
    //
    rArea.TopLeft := Point (iInsertionColumn, DIM_MARGIN);
    rArea.BottomRight := AddPoint (rArea.TopLeft, Point (DIM_MENU_BTN_WIDTH, DIM_MARGIN));
    Control := CreateStandardButton (rArea, 'Save World', cmSaveWorld);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT_MENU);
    Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Ivory');
    //
    Inc (iInsertionColumn, DIM_MENU_BTN_WIDTH + DIM_MARGIN);
    //
    rArea.TopLeft := Point (iInsertionColumn, DIM_MARGIN);
    rArea.BottomRight := AddPoint (rArea.TopLeft, Point (DIM_MENU_BTN_WIDTH, DIM_MARGIN));
    Control := CreateStandardButton (rArea, 'TEST ON', cmGameTestMode);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT_MENU);
    Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'Ivory');
  end;

  procedure SetupToolPanel;
  var
    iInsertionRow: integer;
  begin
    // insertion row starts here
    iInsertionRow := DIM_MARGIN;
    //
    // SET UP A LABEL TO DISPLAY CURRENT POSITION
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_LEFT_PANEL_WIDTH,
      iInsertionRow + DIM_LABEL_HEIGHT);
    ctlLocationDisplay := CreateControl (CC_LABEL, rArea);
    Desktop.Insert (ctlLocationDisplay);
    ctlLocationDisplay.SetPropertyValue (PROP_NAME_CAPTION, '[LOCATION]');
    ctlLocationDisplay.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_LABEL_FONT);
    //
    Inc (iInsertionRow, DIM_LABEL_HEIGHT);
    //
    // SET UP THE MODE PANEL CONTROL
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_MARGIN + DIM_BTN_ARROW_WIDTH,
      iInsertionRow + DIM_BUTTON_HEIGHT);
    Control := CreateStandardButton (rArea, '<<', cmSelectPrevMode);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_MODE_WIDTH;
    ctlModeName := CreateStandardButton (rArea, '<MODE>', cmNothing);
    Desktop.Insert (ctlModeName);
    ctlModeName.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    ctlModeName.SetState (stDisabled, TRUE);
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_ARROW_WIDTH;
    Control := CreateStandardButton (rArea, '>>', cmSelectNextMode);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    //
    Inc (iInsertionRow, DIM_BUTTON_HEIGHT + DIM_MARGIN);
    //
    // SET UP THE SPRITE DISPLAY PANEL
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_LEFT_PANEL_WIDTH,
      iInsertionRow + DIM_SPRITE_PANEL_HEIGHT);
    Control := CreateControl (CC_PICTURE_PANEL, rArea);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    Control.SetState (stDisabled, TRUE);
    EditorPanel.SpritePanel := Control;
    //
    Inc (iInsertionRow, DIM_SPRITE_PANEL_HEIGHT);
    //
    // SET UP THE SPRITE SELECTORS
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_MARGIN + DIM_BTN_ARROW_WIDTH,
      iInsertionRow + DIM_BUTTON_HEIGHT);
    Control := CreateStandardButton (rArea, '<<', cmSelectPrevSprite);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Major.Prev := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_MODE_WIDTH;
    Control := CreateStandardButton (rArea, '<SPRITE>', cmNothing);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    Control.SetState (stDisabled, TRUE);
    EditorPanel.Major.Panel := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_ARROW_WIDTH;
    Control := CreateStandardButton (rArea, '>>', cmSelectNextSprite);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Major.Next := Control;
    //
    Inc (iInsertionRow, DIM_BUTTON_HEIGHT);
    //
    // SET UP THE SPRITE VARIATION SELECTORS
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_MARGIN + DIM_BTN_ARROW_WIDTH,
      iInsertionRow + DIM_BUTTON_HEIGHT);
    Control := CreateStandardButton (rArea, '<<', cmSelectPrevVariation);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Minor.Prev := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_MODE_WIDTH;
    Control := CreateStandardButton (rArea, '<variation>', cmNothing);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    Control.SetState (stDisabled, TRUE);
    EditorPanel.Minor.Panel := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_ARROW_WIDTH;
    Control := CreateStandardButton (rArea, '>>', cmSelectNextVariation);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Minor.Next := Control;
    //
    Inc (iInsertionRow, DIM_BUTTON_HEIGHT);
    //
    // SET UP THE STYLE SELECTORS
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_MARGIN + DIM_BTN_ARROW_WIDTH,
      iInsertionRow + DIM_BUTTON_HEIGHT);
    Control := CreateStandardButton (rArea, '<<', cmSelectPrevStyle);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Style.Prev := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_MODE_WIDTH;
    Control := CreateStandardButton (rArea, '<style>', cmNothing);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    Control.SetState (stDisabled, TRUE);
    EditorPanel.Style.Panel := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_ARROW_WIDTH;
    Control := CreateStandardButton (rArea, '>>', cmSelectNextStyle);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Style.Next := Control;
    //
    Inc (iInsertionRow, DIM_BUTTON_HEIGHT);
    //
    // SET UP THE EXTRA SELECTORS
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_MARGIN + DIM_BTN_ARROW_WIDTH,
      iInsertionRow + DIM_BUTTON_HEIGHT);
    Control := CreateStandardButton (rArea, '<<', cmSelectPrevExtra);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Extra.Prev := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_MODE_WIDTH;
    Control := CreateStandardButton (rArea, '<extra>', cmNothing);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    Control.SetState (stDisabled, TRUE);
    EditorPanel.Extra.Panel := Control;
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_ARROW_WIDTH;
    Control := CreateStandardButton (rArea, '>>', cmSelectNextExtra);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    EditorPanel.Extra.Next := Control;
    //
    // SETUP THE GRID TOGGLE BUTTON
    //
    Inc (iInsertionRow, DIM_BUTTON_HEIGHT * 2);
    //
    rArea := Rect (DIM_MARGIN, iInsertionRow, DIM_MARGIN + DIM_BTN_ARROW_WIDTH,
      iInsertionRow + DIM_BUTTON_HEIGHT);
    Control := CreateStandardButton (rArea, 'vv', cmMapLevelDown);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_MODE_WIDTH;
    Control := CreateStandardButton (rArea, 'ToggleGrid', cmToggleGrid);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    //
    rArea.Left := rArea.Right;
    rArea.Right := rArea.Left + DIM_BTN_ARROW_WIDTH;
    Control := CreateStandardButton (rArea, '^^', cmMapLevelUp);
    Desktop.Insert (Control);
    Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
    //
  end;

  procedure SetupKeyHooks;
  begin
    g_EventManager.Keyboard.AddKeyHook (GridToggler, DIK_G, 0);
    //HandleUserEvents (cmNewAreaRequest, Integer (PChar ('Level1')));
  end;

begin
  // get the default desktop, and set global edit mode
  Desktop := CoreEngine.WinSysRoot [DESKTOP_MAIN];
  GlobalViewEditMode := TRUE;
  GlobalViewShowGrid := TRUE;
  GlobalViewShowPortals := TRUE;
  // reposition the FPS display
  rBounds := Desktop.LocalBounds;
  CoreEngine.MoveFPSDisplayTo (
    Point (rBounds.Right - DIM_FPS_DISPLAY_WIDTH,
    rBounds.Bottom - DIM_FPS_DISPLAY_HEIGHT));
  //
  rArea := Rect (0, 0, ScreenWidth, ScreenHeight);
  Control := CreateControl (CC_DECOR_IMAGE, rArea);
  Desktop.Insert (Control);
  Control.SetPropertyValue (PROP_NAME_REPEAT_X, '1');
  Control.SetPropertyValue (PROP_NAME_REPEAT_Y, '1');
  Control.SetPropertyValue (PROP_NAME_AUTO_HEIGHT, '0');
  Control.SetPropertyValue (PROP_NAME_AUTO_WIDTH, '0');
  Control.SetPropertyValue (PROP_NAME_SPRITE_NAME, 'TileableBlack');

  // create the game window
  rArea := Rect (rBounds.Left + DIM_LEFT_PANEL_WIDTH,
    rBounds.Top + DIM_TOP_PANEL_HEIGHT, rBounds.Right, rBounds.Bottom);
  GameWindow := TZEGameWindow.Create (ExpandRect (rArea, -DIM_MARGIN, -DIM_MARGIN));
  Desktop.Insert (GameWindow);
  // create a map via the GameWorld class
  GameWorld.CreateNewArea (DEFAULT_AREA_NAME);
  GameWorld.Areas [DEFAULT_AREA_NAME].CreateMap (DEFAULT_MAP_WIDTH, DEFAULT_MAP_HEIGHT);
  GameWorld.SwitchToArea (DEFAULT_AREA_NAME);
  GameWorld.ResetGameWindow;
  //
  //
  SetupToolPanel;
  SetupMenuPanel;
  GatherData;
  //
  //
  // create the exit button
  rArea := Rect (DIM_MARGIN, rBounds.Bottom - (DIM_BUTTON_HEIGHT + DIM_MARGIN),
    DIM_LEFT_PANEL_WIDTH, rBounds.Bottom - DIM_MARGIN);
  Control := CreateStandardButton (rArea, 'Exit', cmGlobalExitFinal);//cmFinalExit);
  Desktop.Insert (Control);
  Control.SetPropertyValue (PROP_NAME_FONT_NAME, EDITOR_BUTTON_FONT);
  //
  Dec (rArea.Top, DIM_LABEL_HEIGHT div 2);
  Dec (rArea.Bottom, DIM_LABEL_HEIGHT div 2);
  ctlEditorStatus := CreateControl (CC_LABEL, rArea);
  Desktop.Insert (ctlEditorStatus);
  ctlEditorStatus.SetPropertyValue (PROP_NAME_CAPTION, '[STATUS/INFO]');
  ctlEditorStatus.SetPropertyValue (PROP_NAME_FONT_NAME, 'StatusFont');
  //
  ctlEditorStatus.SetPropertyValue (PROP_NAME_CAPTION,
    Format ('EDITING: %s', [GameWorld.ActiveArea.Name]));
    
  //
  SetupKeyHooks;
  Result := 0;
end;

////////////////////////////////////////////////////////////////////
function HandleUserEvents (iCommand, lData: integer): integer;
var
  AtTile: TZEViewTile;
  cLocation: string;
  rArea: TRect;
  NewMapParams: PZENewMapParams;
  MapPortalParams: PZEMapPortalParams;
  cMasterE, cInstanceE: string;
  Entity: TZEEntity;
  theGameArea: TZEGameArea;
begin
  case iCommand of
    // handle locator display when new tile is highlighted
    cmNewTileHighlighted: begin
      if (ctlLocationDisplay = NIL) then Exit;
      //
      AtTile := TZEViewTile (lData);
      if (AtTile <> NIL) then begin
        cLocation := Format ('X: %d, Y: %d, Z: %d', [AtTile.GridX, AtTile.GridY, AtTile.Owner.LevelIndex]);
        ctlLocationDisplay.SetPropertyValue (PROP_NAME_CAPTION, cLocation);
      end else
        ctlLocationDisplay.SetPropertyValue (PROP_NAME_CAPTION, '[-]');
    end;
    // tile selected was left clicked
    cmLClickTile: begin
      AtTile := TZEViewTile (lData);
      if (AtTile <> NIL) then EditorModes.LeftClick (AtTile);
    end;
    // tile selected was left clicked with the CTRL key held down
    cmCtrlLClickTile: begin
      AtTile := TZEViewTile (lData);
      if (AtTile <> NIL) then EditorModes.CtrlLeftClick (AtTile);
    end;
    // tile selected was left clicked with the SHIFT key held down
    cmShiftLClickTile: begin
      AtTile := TZEViewTile (lData);
      if (AtTile <> NIL) then EditorModes.ShiftLeftClick (AtTile);
    end;
    //
    // FOLLOWING ARE INTERNAL EDITOR COMMANDS
    //
    cmSelectPrevMode: begin
      EditorModes.SelectPrevious;
      ctlModeName.SetPropertyValue (PROP_NAME_CAPTION, EditorModes.Active.Name);
    end;
    //
    cmSelectNextMode: begin
      EditorModes.SelectNext;
      ctlModeName.SetPropertyValue (PROP_NAME_CAPTION, EditorModes.Active.Name);
    end;
    //
    cmSelectPrevSprite: if (NOT EditorPanel.Major.CurrentAtMin) then begin
      EditorPanel.Major.CurrentBackward;
      EditorModes.UpdateDisplay;
    end;
    //
    cmSelectNextSprite: if (NOT EditorPanel.Major.CurrentAtMax) then begin
      EditorPanel.Major.CurrentForward;
      EditorModes.UpdateDisplay;
    end;
    //
    cmSelectPrevVariation: if (NOT EditorPanel.Minor.CurrentAtMin) then begin
      EditorPanel.Minor.CurrentBackward;
      EditorModes.UpdateDisplay (mdlMinor);
    end;
    //
    cmSelectNextVariation: if (NOT EditorPanel.Minor.CurrentAtMax) then begin
      EditorPanel.Minor.CurrentForward;
      EditorModes.UpdateDisplay (mdlMinor);
    end;
    //
    cmSelectPrevStyle: if (NOT EditorPanel.Style.CurrentAtMin) then begin
      EditorPanel.Style.CurrentBackward;
      EditorModes.UpdateDisplay (mdlStyle);
    end;
    //
    cmSelectNextStyle: if (NOT EditorPanel.Style.CurrentAtMax) then begin
      EditorPanel.Style.CurrentForward;
      EditorModes.UpdateDisplay (mdlStyle);
    end;
    //
    cmSelectPrevExtra: if (NOT EditorPanel.Extra.CurrentAtMin) then begin
      EditorPanel.Extra.CurrentBackward;
      EditorModes.UpdateDisplay (mdlExtra);
    end;
    //
    cmSelectNextExtra: if (NOT EditorPanel.Extra.CurrentAtMax) then begin
      EditorPanel.Extra.CurrentForward;
      EditorModes.UpdateDisplay (mdlExtra);
    end;
    //
    cmToggleGrid: begin
      GlobalViewShowGrid := NOT GlobalViewShowGrid;
      //CoreEngine.PlaySound ('101Fire');
    end;
    cmMapLevelUp: begin
      GameWorld.ActiveArea.Map.MapLevelUp;
    end;
    cmMapLevelDown: begin
      GameWorld.ActiveArea.Map.MapLevelDown;
    end;
    //
    cmNewMap: if (GlobalViewEditMode) then begin
      rArea := Rect (0, 0, 400, 200);
      CoreEngine.RunDialog (TZENewMapDialog.Create (rArea));
    end;
    //
    cmNewMapRequest: begin
      NewMapParams := PZENewMapParams (lData);
      with NewMapParams^ do begin
        GameWorld.ActiveArea.CreateMap (X, Y, Z);
        GameWorld.ResetGameWindow;
        //g_DXFramework.FlushEvents;
      end;
      DeleteNewMapParams (NewMapParams);
    end;
    //
    cmLoadWorld: begin
      //GameWorld.LoadFromFile ('Maps\LastEscape.ZWF');
      CoreEngine.ShowInputBox ('Enter World FileName', cmLoadWorldRequest);
    end;
    //
    cmLoadWorldRequest: begin
      cLocation := ChangeFileExt (Format ('Maps\%s', [String (PChar (lData))]), '.ZWF');
      if (NOT FileExists (cLocation)) then
        CoreEngine.ShowMsgBox ('File does not exist!')
      else begin
        GameWorld.LoadFromFile (cLocation);
        //g_DXFramework.FlushEvents;
        ctlEditorStatus.SetPropertyValue (PROP_NAME_CAPTION,
          Format ('EDITING: %s', [GameWorld.ActiveArea.Name]));
      end;
    end;
    //
    cmSaveWorld: begin
      CoreEngine.ShowInputBox ('Enter World FileName', cmSaveWorldRequest);
    end;
    //
    cmSaveWorldRequest: begin
      if (String (PChar (lData)) <> '') then begin
        cLocation := ChangeFileExt (Format ('Maps\%s', [String (PChar (lData))]), '.ZWF');
        GameWorld.SaveToFile (cLocation);
      end;
    end;
    //
    cmNewArea: begin
      CoreEngine.ShowInputBox ('Enter Name Of New Area', cmNewAreaRequest);
    end;
    //
    cmNewAreaRequest: begin
      cLocation := String (PChar (lData));
      if (GameWorld.GetArea (cLocation) <> NIL) then
        CoreEngine.ShowMsgBox ('An Area with that name already exists')
      else begin
        GameWorld.CreateNewArea (cLocation);
        GameWorld.Areas [cLocation].CreateMap (DEFAULT_MAP_WIDTH, DEFAULT_MAP_HEIGHT);
        GameWorld.SwitchToArea (cLocation);
        //g_DXFramework.FlushEvents;
        //
        ctlEditorStatus.SetPropertyValue (PROP_NAME_CAPTION,
          Format ('EDITING: %s', [GameWorld.ActiveArea.Name]));
      end;
    end;
    //
    cmDeleteArea: if (GameWorld.AreaCount > 1) then
      CoreEngine.ShowInputBox ('Enter Name Area To Delete', cmDeleteAreaRequest)
      else CoreEngine.ShowMsgBox ('Not Enough Areas To Delete');
    //
    cmDeleteAreaRequest: begin
      cLocation := String (PChar (lData));
      GameWorld.DeleteArea (cLocation);
      ctlEditorStatus.SetPropertyValue (PROP_NAME_CAPTION,
        Format ('EDITING: %s', [GameWorld.ActiveArea.Name]));
    end;
    //
    cmSwitchArea: if (GameWorld.AreaCount > 1) then begin
      CoreEngine.ShowInputBox ('Enter Name Area To Switch To', cmSwitchAreaRequest);
    end else
      CoreEngine.ShowMsgBox ('No Other Areas To Switch To');
    //
    cmSwitchAreaRequest: begin
      cLocation := String (PChar (lData));
      if (GameWorld.GetArea (cLocation) = NIL) then
        CoreEngine.ShowMsgBox ('No such area')
      else begin
        GameWorld.SwitchToArea (cLocation);
        //g_DXFramework.FlushEvents;
        //
        ctlEditorStatus.SetPropertyValue (PROP_NAME_CAPTION,
          Format ('EDITING: %s', [GameWorld.ActiveArea.Name]));
      end;
    end;
    //
    cmNewPortalRequest: begin
      MapPortalParams := PZEMapPortalParams (lData);
      with MapPortalParams^ do begin
        theGameArea := GameWorld [String (DestName)];
        if (theGameArea <> NIL) AND (theGameArea.Map.Valid (X, Y, Z)) then
          Tile.SetPortal(theGameARea.Map, X, Y, Z);
        //
      end;
      DeleteMapPortalParams (MapPortalParams);
    end;
    //
    cmGameTestMode: begin
      if (GlobalViewEditMode) then
        CoreEngine.ShowInputBox ('Type Entity Name, And ID (NAME,ID):', cmDropEntityPC)
      else begin
        GameWorld.ClearPC;
        GlobalViewEditMode := TRUE;
      end;
    end;
    //
    cmDropEntityPC: begin
      cLocation := String (PChar (lData));
      cMasterE := Trim (StrBefore (',', cLocation));
      cInstanceE := Trim (StrAfter (',', cLocation));
      GameWorld.CreatePC (cMasterE, cInstanceE);
      GameWorld.DropPC;
      GlobalViewEditMode := FALSE;
    end;
    //
    cmRenameEntityRequest: begin
      AtTile := EditorModes.Active.AtTile;
      if (AtTile <> NIL) then begin
        Entity := TZEEntity (AtTile.UserData);
        if (Entity <> NIL) then Entity.Name := String (PChar (lData));
      end;
    end;
  end;
  //
  Result := 0;
end;

initialization
  EditorPanel := TMedEditorPanel.Create;
  EditorModes := TMedEditorModeList.Create;

finalization
  FreeAndNIL (EditorModes);
  FreeAndNIL (EditorPanel);

end.

