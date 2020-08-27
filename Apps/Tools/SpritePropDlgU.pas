unit SpritePropDlgU;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  Spin;

type
  TfmSpritePropDlg = class(TForm)
    cbControlsList: TComboBox;
    Label1: TLabel;
    ledSubClassName: TLabeledEdit;
    Bevel1: TBevel;
    btnCancel: TButton;
    btnOK: TButton;
    sedFirstFrame: TSpinEdit;
    sedLastFrame: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    Bevel2: TBevel;
    cbImageNames: TComboBox;
    Label4: TLabel;
    procedure ledSubClassNameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmSpritePropDlg: TfmSpritePropDlg;

implementation

{$R *.dfm}

procedure TfmSpritePropDlg.ledSubClassNameChange(Sender: TObject);
begin
  btnOK.Enabled := (cbControlsList.ItemIndex >= 0) AND
    (ledSubClassName.Text <> '') AND (cbImageNames.ItemIndex >= 0);
end;


end.
