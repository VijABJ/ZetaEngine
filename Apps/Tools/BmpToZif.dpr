program BmpToZif;

uses
  Forms,
  BmpToZifU in 'BmpToZifU.pas' {fmBmpToZif};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmBmpToZif, fmBmpToZif);
  Application.Run;
end.
