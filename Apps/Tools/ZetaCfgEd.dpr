program ZetaCfgEd;

uses
  Forms,
  ZetaCfgEdU in 'ZetaCfgEdU.pas' {fmZetaCfgEd},
  ZbFolderSelectDlg in '..\ZbLibrary\CommonForms\ZbFolderSelectDlg.pas' {fmFolderSelect},
  ZbStrDataEntryDlg in '..\ZbLibrary\CommonForms\ZbStrDataEntryDlg.pas' {fmStringEntry},
  AliasDlgU in 'AliasDlgU.pas' {fmAliasEditDlg},
  FontEditDlgU in 'FontEditDlgU.pas' {fmFontEditDlg};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Zeta Engine Startup File Editor';
  Application.CreateForm(TfmZetaCfgEd, fmZetaCfgEd);
  Application.Run;
end.
