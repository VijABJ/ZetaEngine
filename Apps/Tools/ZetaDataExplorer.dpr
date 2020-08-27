program ZetaDataExplorer;

uses
  Forms,
  ZetaDataExplorerU in 'ZetaDataExplorerU.pas' {fmDataExplorer},
  ZbStrDataEntryDlg in '..\..\..\ZbLibrary\CommonForms\ZbStrDataEntryDlg.pas' {fmStringEntry};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmDataExplorer, fmDataExplorer);
  Application.Run;
end.
