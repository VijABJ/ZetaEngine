program GuiSprCfgEditor;

uses
  Forms,
  GuiSpriteCfgEdU in 'GuiSpriteCfgEdU.pas' {fmGuiSpriteEd},
  SpritePropDlgU in 'SpritePropDlgU.pas' {fmSpritePropDlg};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmGuiSpriteEd, fmGuiSpriteEd);
  Application.CreateForm(TfmSpritePropDlg, fmSpritePropDlg);
  Application.Run;
end.
