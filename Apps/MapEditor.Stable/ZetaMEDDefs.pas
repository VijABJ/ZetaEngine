{============================================================================

  ZipBreak's Generic Library
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaMEDDefs.PAS
              Constants and other definitions
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Apps/MapEditor/ZetaMEDDefs.pas,v 1.2 2002/09/17 22:00:34 Vij Exp $
  $Log: ZetaMEDDefs.pas,v $
  Revision 1.2  2002/09/17 22:00:34  Vij
  Added header so that history/comments will be inlined in the source file



 ============================================================================}

unit ZetaMEDDefs;

interface

uses
  Types;

const
  {USE COMMAND RANGE 4000-4199 }
  cmZetaMEDCommandBase    = 4000;
  cmZetaMEDCommandMax     = cmZetaMEDCommandBase + 199;

  cmSelectPrevMode        = cmZetaMEDCommandBase + 000;
  cmSelectNextMode        = cmZetaMEDCommandBase + 001;
  cmSelectPrevSprite      = cmZetaMEDCommandBase + 002;
  cmSelectNextSprite      = cmZetaMEDCommandBase + 003;
  cmSelectPrevVariation   = cmZetaMEDCommandBase + 004;
  cmSelectNextVariation   = cmZetaMEDCommandBase + 005;
  cmSelectPrevStyle       = cmZetaMEDCommandBase + 006;
  cmSelectNextStyle       = cmZetaMEDCommandBase + 007;
  cmSelectPrevExtra       = cmZetaMEDCommandBase + 008;
  cmSelectNextExtra       = cmZetaMEDCommandBase + 009;

  cmNewArea               = cmZetaMEDCommandBase + 010;
  cmNewAreaRequest        = cmZetaMEDCommandBase + 011;
  cmDeleteArea            = cmZetaMEDCommandBase + 012;
  cmDeleteAreaRequest     = cmZetaMEDCommandBase + 013;
  cmSwitchArea            = cmZetaMEDCommandBase + 014;
  cmSwitchAreaRequest     = cmZetaMEDCommandBase + 015;

  cmNewMap                = cmZetaMEDCommandBase + 021;
  cmNewMapRequest         = cmZetaMEDCommandBase + 022;
  cmLoadWorld             = cmZetaMEDCommandBase + 023;
  cmLoadWorldRequest      = cmZetaMEDCommandBase + 024;
  cmSaveWorld             = cmZetaMEDCommandBase + 025;
  cmSaveWorldRequest      = cmZetaMEDCommandBase + 026;
  cmRenameEntityRequest   = cmZetaMEDCommandBase + 027;

  cmToggleGrid            = cmZetaMEDCommandBase + 030;
  cmMapLevelUp            = cmZetaMEDCommandBase + 031;
  cmMapLevelDown          = cmZetaMEDCommandBase + 032;

  cmNewPortalRequest      = cmZetaMEDCommandBase + 040;

  cmGameTestMode          = cmZetaMEDCommandBase + 050;
  cmDropEntityPC          = cmZetaMEDCommandBase + 051;

  EDITOR_BUTTON_FONT      = 'EditorButton';
  EDITOR_BUTTON_REV_FONT  = 'EditorButtonRev';
  EDITOR_LABEL_FONT       = 'EditorLabel';
  EDITOR_BUTTON_FONT_MENU = 'EditorMenuButton';

  DEFAULT_AREA_NAME       = 'Default';
  DEFAULT_MAP_WIDTH       = 10;
  DEFAULT_MAP_HEIGHT      = 10;


implementation

end.

