program ZEEd;

uses
  Forms,
  ZEEdU in 'ZEEdU.pas' {fmZEEdMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmZEEdMain, fmZEEdMain);
  Application.Run;
end.
