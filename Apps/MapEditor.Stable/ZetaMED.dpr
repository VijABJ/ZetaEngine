{$WARNINGS OFF}
{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaMED.PAS
              Zeta Engine's Map Editor 
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Apps/MapEditor/ZetaMED.dpr,v 1.3 2002/09/17 22:04:04 Vij Exp $
  $Log: ZetaMED.dpr,v $
  Revision 1.3  2002/09/17 22:04:04  Vij
  Two new modules added (ZetaMEDDlgs, ZetaMEDDefs).  See respective source
  for further comments.

  Revision 1.2  2002/09/13 12:48:07  Vij
  Factored out common Mode-handling code and made classes out of it.
  This cleaned out the code much and is easier to understand and extend now.

  Revision 1.1.1.1  2002/09/12 12:02:29  Vij
  Starting Version Control


 ============================================================================}

program ZetaMED;

uses
  ZEDXFramework,
  ZZEWinWrapper,
  ZetaMEDU in 'ZetaMEDU.pas',
  ZetaMEDAux in 'ZetaMEDAux.pas',
  ZetaMEDDlgs in 'ZetaMEDDlgs.pas',
  ZetaMEDDefs in 'ZetaMEDDefs.pas';

const
  (* FOLLOWING constants MUST be unique for each application.  Modify
     these before anything else. *)
  WINDOW_CLASS_NAME         = 'ZetaMapEditor';
  WINDOW_TITLE              = 'Zeta Engine Map Editor';
  PROGRAM_CONFIGURATION     = 'ZetaMED.zsf';


////////////////////////////////////////////////////////////////////////////////
var
  Wrapper: TZEWindowsWrapper;
  bSuccess: boolean;
begin
  Wrapper := WrapperCreate (PROGRAM_CONFIGURATION, CreateInitialGUI, HandleUserEvents);
  if (Wrapper = NIL) then Exit;
  //
  GlobalExitOnEscape := TRUE;
  bSuccess := Wrapper.CreateWindow (hInstance, WINDOW_CLASS_NAME, WINDOW_TITLE, NIL, 0, 640, 480);
  if (bSuccess) then Wrapper.Execute;
  Wrapper.Free;
end.

