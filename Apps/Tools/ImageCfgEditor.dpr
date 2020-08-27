program ImageCfgEditor;

uses
  Forms,
  ImgCfgEdU in 'ImgCfgEdU.pas' {fmImageConfEditor},
  ImagePropEdU in 'ImagePropEdU.pas' {fmImgPropEditor},
  AliasDlgU in 'AliasDlgU.pas' {fmAliasEditDlg};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmImageConfEditor, fmImageConfEditor);
  Application.CreateForm(TfmImgPropEditor, fmImgPropEditor);
  Application.CreateForm(TfmAliasEditDlg, fmAliasEditDlg);
  Application.Run;
end.
