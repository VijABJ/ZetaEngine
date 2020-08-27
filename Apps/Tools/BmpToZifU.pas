unit BmpToZifU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ImgList, ToolWin;

type
  TfmBmpToZif = class(TForm)
    lbConvertList: TListBox;
    dlgOpen: TOpenDialog;
    sbMain: TStatusBar;
    tbMain: TToolBar;
    tbtnAdd: TToolButton;
    tbtnDelete: TToolButton;
    tbtnClear: TToolButton;
    ToolButton3: TToolButton;
    tbtnDestination: TToolButton;
    tbtnProcess: TToolButton;
    ToolButton6: TToolButton;
    tbtnAbout: TToolButton;
    tbtnImages: TImageList;
    ToolButton1: TToolButton;
    tbtnExit: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbtnAddClick(Sender: TObject);
    procedure tbtnDeleteClick(Sender: TObject);
    procedure tbtnClearClick(Sender: TObject);
    procedure tbtnExitClick(Sender: TObject);
    procedure tbtnProcessClick(Sender: TObject);
  private
    { Private declarations }
    FTempList: TStrings;
  public
    { Public declarations }
  end;

var
  fmBmpToZif: TfmBmpToZif;

implementation

{$R *.dfm}

uses
  StrUtils,
  ZbBitmap;

//////////////////////////////////////////////////////////////////////////
procedure TfmBmpToZif.FormCreate(Sender: TObject);
begin
  FTempList := TStringList.Create;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmBmpToZif.FormDestroy(Sender: TObject);
begin
  FTempList.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmBmpToZif.tbtnAddClick(Sender: TObject);
var
  iPos: integer;
begin
  if (NOT dlgOpen.Execute) then Exit;
  //
  FTempList.Clear;
  for iPos := 0 to Pred (dlgOpen.Files.Count) do
    if (lbConvertList.Items.IndexOf (dlgOpen.Files [iPos]) < 0) then
      FTempList.Add (dlgOpen.Files [iPos]);
  lbConvertList.Items.AddStrings (FTempList);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmBmpToZif.tbtnDeleteClick(Sender: TObject);
var
  iPos: integer;
  bDeleted: boolean;
begin
  if (lbConvertList.SelCount = 0) then Exit;
  //
  while (TRUE) do begin
    bDeleted := FALSE;
    for iPos := 0 to Pred (lbConvertList.Items.Count) do
      if (lbConvertList.Selected [iPos]) then begin
        lbConvertList.Items.Delete (iPos);
        bDeleted := TRUE;
        break;
      end;
    //
    if (NOT bDeleted) then break;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmBmpToZif.tbtnClearClick(Sender: TObject);
begin
  lbConvertList.Items.Clear;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmBmpToZif.tbtnExitClick(Sender: TObject);
begin
  Close;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmBmpToZif.tbtnProcessClick(Sender: TObject);
var
  ZbImage: TZbBitmap32;
  iPos: integer;
begin
  tbMain.Enabled := FALSE;
  //
  ZbImage := TZbBitmap32.Create;
  for iPos := 0 to Pred (lbConvertList.Items.Count) do begin
    sbMain.SimpleText := 'Processing: ' + lbConvertList.Items [iPos] + '...';
    ZbImage.LoadFromWinBitmap (lbConvertList.Items [iPos]);
    ZbImage.WriteToFile (lbConvertList.Items [iPos]);
  end;
  ZbImage.Free;
  iPos := lbConvertList.Items.Count;
  sbMain.SimpleText := Format ('Finished processing %d File%s',
    [iPos, IfThen ((iPos > 1), 's', '')]);
  //
  tbMain.Enabled := TRUE;
end;


end.

