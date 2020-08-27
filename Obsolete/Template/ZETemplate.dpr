{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZETemplate.PAS
              Main program for Template (see other notes in ZETemplateU)
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

program ZETemplate;

uses
  Forms,
  ZETemplateU in 'ZETemplateU.pas' {fmTemplate};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmTemplate, fmTemplate);
  Application.Run;
end.
