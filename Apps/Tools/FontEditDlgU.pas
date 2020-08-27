unit FontEditDlgU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, ComCtrls;

type
  TfmFontEditDlg = class(TForm)
    cbFontNames: TComboBox;
    Label1: TLabel;
    spedFontSize: TSpinEdit;
    Label2: TLabel;
    ledGameName: TLabeledEdit;
    Bevel1: TBevel;
    GroupBox1: TGroupBox;
    cbBold: TCheckBox;
    cbUnderline: TCheckBox;
    cbItalic: TCheckBox;
    cbStrikeOut: TCheckBox;
    clrFontColor: TColorBox;
    Label3: TLabel;
    Bevel2: TBevel;
    GroupBox2: TGroupBox;
    cbHAlign: TComboBox;
    cbVAlign: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    sbMain: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetFontValues (cFontSpec: string);
    function GetFontSpec: string;
  end;

implementation

{$R *.dfm}

uses
  ZEWSSupport;

procedure TfmFontEditDlg.FormCreate(Sender: TObject);
begin
  cbFontNames.Items := Screen.Fonts;
end;

procedure TfmFontEditDlg.btnOKClick(Sender: TObject);
begin
  //
  // validate all the fields, start with the game name
  if (ledGameName.Text = '') then begin
    sbMain.SimpleText := 'ERROR: Game Name REQUIRED';
    Exit;
  end;

  //
  if (cbFontNames.ItemIndex < 0) then begin
    sbMain.SimpleText := 'ERROR: No font selected';
    Exit;
  end;

  //
  if (cbHAlign.ItemIndex < 0) OR (cbVAlign.ItemIndex < 0) then begin
    sbMain.SimpleText := 'ERROR: Missing alignment specifier';
    Exit;
  end;

  ModalResult := mrOK;
end;

procedure TfmFontEditDlg.SetFontValues (cFontSpec: string);
begin
end;

function TfmFontEditDlg.GetFontSpec: string;
begin
  Result := EncodeFontSpec (ledGameName.Text, cbFontNames.Items [cbFontNames.ItemIndex],
    spedFontSize.Value, cbBold.Checked, cbItalic.Checked, cbUnderline.Checked,
    cbStrikeOut.Checked, cbHAlign.ItemIndex, cbVAlign.ItemIndex,
    clrFontColor.Selected);
end;


end.
