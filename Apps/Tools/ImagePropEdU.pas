unit ImagePropEdU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, CheckLst;

type
  TfmImgPropEditor = class(TForm)
    ledImageGameName: TLabeledEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    cbTransparent: TCheckBox;
    cbGridded: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    lbFiles: TListBox;
    procedure FormActivate(Sender: TObject);
    procedure ledImageGameNameChange(Sender: TObject);
    procedure lbFilesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmImgPropEditor: TfmImgPropEditor;

implementation

{$R *.dfm}

procedure TfmImgPropEditor.FormActivate(Sender: TObject);
begin
  ledImageGameName.Text := '';
  //btnOK.Enabled := FALSE;
end;

procedure TfmImgPropEditor.ledImageGameNameChange(Sender: TObject);
begin
  btnOK.Enabled := (ledImageGameName.Text <> '') AND (lbFiles.ItemIndex >= 0);
end;

procedure TfmImgPropEditor.lbFilesClick(Sender: TObject);
begin
  ledImageGameNameChange (NIL);
end;

end.
