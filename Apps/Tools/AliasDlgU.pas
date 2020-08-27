unit AliasDlgU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfmAliasEditDlg = class(TForm)
    ledAliasName: TLabeledEdit;
    Label1: TLabel;
    cbAliasValues: TComboBox;
    Bevel1: TBevel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure ControlOnChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetAliasValues (SValues: TStrings);
    procedure SetDefaultAlias (AAliasName: string);
    procedure GetAliasResults (var cAlias, cValue: string);
  end;

var
  fmAliasEditDlg: TfmAliasEditDlg;
  

implementation

{$R *.dfm}

procedure TfmAliasEditDlg.ControlOnChange(Sender: TObject);
begin
  btnOK.Enabled := (ledAliasName.Text <> '') AND (cbAliasValues.ItemIndex >= 0);
end;

procedure TfmAliasEditDlg.SetAliasValues (SValues: TStrings);
begin
  cbAliasValues.Items.Clear;
  cbAliasValues.Items.AddStrings (SValues);
  ControlOnChange (NIL);
end;

procedure TfmAliasEditDlg.SetDefaultAlias (AAliasName: string);
begin
  ledAliasName.Text := AAliasName;
  ControlOnChange (NIL);
end;

procedure TfmAliasEditDlg.GetAliasResults (var cAlias, cValue: string);
begin
  cAlias := ledAliasName.Text;
  cValue := cbAliasValues.Items [cbAliasValues.ItemIndex];
end;

end.
