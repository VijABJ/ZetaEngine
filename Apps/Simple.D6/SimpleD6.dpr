{$WARNINGS OFF}
{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     SimpleD6.PAS
              Zeta Engine Delphi Template
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

program SimpleD6;

uses
  ZEDXFramework,
  ZZEWinWrapper,
  SimpleD6U in 'SimpleD6U.pas';

const
  (* FOLLOWING constants MUST be unique for each application.  Modify
     these before anything else. *)
  WINDOW_CLASS_NAME         = 'SimpleD6';
  WINDOW_TITLE              = 'Delphi 6 Template';
  PROGRAM_CONFIGURATION     = 'SimpleD6.zsf';


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

