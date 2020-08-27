unit ImgCfgEdU;

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
  Menus,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  //
  ZEDXImageLib;

type
  TfmImageConfEditor = class(TForm)
    menuMain: TMainMenu;
    menuFile: TMenuItem;
    menuFileLoad: TMenuItem;
    menuFileExit: TMenuItem;
    N1: TMenuItem;
    dlgLoadVolume: TOpenDialog;
    menuFileOpenConfig: TMenuItem;
    dlgLoadConfig: TOpenDialog;
    N2: TMenuItem;
    menuFileSaveConfig: TMenuItem;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Panel2: TPanel;
    lbNames: TListBox;
    lbAliases: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    ledFileName: TLabeledEdit;
    cbTransparentF: TCheckBox;
    cbGriddedF: TCheckBox;
    popMenuAliases: TPopupMenu;
    popMenuNames: TPopupMenu;
    popMenuNamesNew: TMenuItem;
    popMenuNamesDelete: TMenuItem;
    popMenuAliasesNew: TMenuItem;
    popMenuAliasesDelete: TMenuItem;
    dlgSaveConfig: TSaveDialog;
    procedure menuFileExitClick(Sender: TObject);
    procedure menuFileLoadClick(Sender: TObject);
    procedure menuFileOpenConfigClick(Sender: TObject);
    procedure popMenuAliasesPopup(Sender: TObject);
    procedure popMenuNamesPopup(Sender: TObject);
    procedure popMenuNamesNewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure popMenuAliasesNewClick(Sender: TObject);
    procedure lbAliasesClick(Sender: TObject);
    procedure lbNamesClick(Sender: TObject);
    procedure menuFileSaveConfigClick(Sender: TObject);
    procedure popMenuAliasesDeleteClick(Sender: TObject);
    procedure popMenuNamesDeleteClick(Sender: TObject);
  private
    { Private declarations }
    FImageList: TZEImageNames;
    procedure ShowImageProperties;
    procedure ActivateFields;
  public
    { Public declarations }
  end;

var
  fmImageConfEditor: TfmImageConfEditor;

implementation

{$R *.dfm}

uses
  ZbStringUtils,
  ZbVirtualFS,
  ZbConfigManager,
  //
  AliasDlgU,
  ImagePropEdU;


//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.FormCreate(Sender: TObject);
begin
  FImageList := TZEImageNames.Create (NIL);
  ConfigManager := TZbConfigManager.Create ('');
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.FormDestroy(Sender: TObject);
begin
  FreeAndNIL (FImageList);
  FreeAndNIL (ConfigManager);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.menuFileExitClick(Sender: TObject);
begin
  Close;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.ActivateFields;
begin
  lbNames.Items.Clear;
  lbNames.Enabled := TRUE;
  lbAliases.Items.Clear;
  lbAliases.Enabled := TRUE;
  menuFileSaveConfig.Enabled := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.menuFileLoadClick(Sender: TObject);
var
  vSource: TZbStandardVolume;
begin
  if (NOT dlgLoadVolume.Execute) then Exit;
  //
  vSource := TZbStandardVolume.Create (dlgLoadVolume.FileName);
  try
    vSource.EnumerateFiles ('ZIF', fmImgPropEditor.lbFiles.Items);
    //
    FImageList.Clear;
    ActivateFields;
  finally
    vSource.Free;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.menuFileOpenConfigClick(Sender: TObject);
var
  iIndex: integer;
  cIdentifier: string;
begin
  if (NOT dlgLoadConfig.Execute) then Exit;
  FImageList.LoadFromStrEnum (ConfigManager.LoadSimpleConfig (dlgLoadConfig.FileName));
  ActivateFields;
  //
  for iIndex := 0 to Pred (FImageList.NamesCount) do begin
    cIdentifier := FImageList.NamesListA [iIndex];
    if (cIdentifier <> '') then lbNames.Items.Add (cIdentifier);
  end;
  //
  for iIndex := 0to Pred (FImageList.AliasCount) do begin
    cIdentifier := FImageList.AliasListA [iIndex];
    if (cIdentifier <> '') then lbAliases.Items.Add (cIdentifier);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.popMenuAliasesPopup(Sender: TObject);
begin
  popMenuAliasesDelete.Enabled := (lbAliases.ItemIndex >= 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.popMenuNamesPopup(Sender: TObject);
begin
  popMenuNamesDelete.Enabled := (lbNames.ItemIndex >= 0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.popMenuNamesNewClick(Sender: TObject);
var
  lResult: integer;
  cName: string;
begin
  lResult := fmImgPropEditor.ShowModal;
  if (lResult = mrCancel) then Exit;
  //
  cName := fmImgPropEditor.ledImageGameName.Text;
  if (FImageList.IdNameInUse (cName)) then begin
    MessageBox (Handle, 'Name already in use!', 'Bad Name', MB_OK);
    Exit;
  end;
  //
  with fmImgPropEditor do
    FImageList.AddName (cName, lbFiles.Items [lbFiles.ItemIndex],
      cbTransparent.Checked, cbGridded.Checked);
  //
  lbNames.Items.Add (cName);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.popMenuAliasesNewClick(Sender: TObject);
var
  lResult: integer;
  cName: string;
begin
  if (lbNames.Items.Count <= 0) then begin
    MessageBox (Handle, 'Cannot make Alias if there are no Names yet.', 'Error', MB_OK);
    Exit;
  end;
  //
  with fmAliasEditDlg do begin
    btnOK.Enabled := FALSE;
    ledAliasName.Text := '';
    cbAliasValues.Items.Clear;
    cbAliasValues.Items.AddStrings (lbNames.Items);
    lResult := ShowModal;
  end;
  if (lResult = mrCancel) then Exit;
  //
  cName := fmAliasEditDlg.ledAliasName.Text;
  if (FImageList.IdNameInUse (cName)) then begin
    MessageBox (Handle, 'Name already in use!', 'Bad Name', MB_OK);
    Exit;
  end;
  //
  with fmAliasEditDlg do
    FImageList.AddAlias (cName, cbAliasValues.Items [cbAliasValues.ItemIndex]);
  //
  lbAliases.Items.Add (cName);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.ShowImageProperties;
var
  cName: string;
  bTransparent, bGridded: boolean;
begin
  // get the properties to display, and display `em
  cName := lbNames.Items [lbNames.ItemIndex];
  ledFileName.Text := FImageList.NamesList [cName];
  FImageList.GetProps (cName, bTransparent, bGridded);
  cbTransparentF.Checked := bTransparent;
  cbGriddedF.Checked := bGridded;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.lbAliasesClick(Sender: TObject);
var
  cAlias, cName: string;
begin
  if (lbAliases.ItemIndex >= 0) then begin
    cAlias := lbAliases.Items [lbAliases.ItemIndex];
    cName := FImageList.AliasList [cAlias];
    lbNames.ItemIndex := lbNames.Items.IndexOf (cName);
    if (lbNames.ItemIndex >= 0) then ShowImageProperties;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.lbNamesClick(Sender: TObject);
var
  cName: string;
begin
  if (lbNames.ItemIndex >= 0) then begin
    //
    // check if there is something selected in the alias list,
    // and if so, if it matches the one selected in the names list
    // if not, disable the selection in the alias list
    if (lbAliases.ItemIndex >= 0) then begin
      cName := lbAliases.Items [lbAliases.ItemIndex];
      if (cName <> lbNames.Items [lbNames.ItemIndex]) then
        lbAliases.ItemIndex := -1;
    end;
    //
    ShowImageProperties;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.menuFileSaveConfigClick (Sender: TObject);
var
  F: TextFile;
  iIndex: integer;
  cIdentifier, cValue: string;
  bTransparent, bGridded: boolean;
begin
  if (NOT dlgSaveConfig.Execute) then Exit;
  //
  AssignFile (F, dlgSaveConfig.FileName);
  try Rewrite (F); except Exit; end;
  //
  try
    //
    // write the header
    WriteLn (F, '; +-----------------------------------------------');
    WriteLn (F, '; | Image Configuration File: ', ExtractFileName (dlgSaveConfig.FileName));
    WriteLn (F, '; +-----------------------------------------------');
    WriteLn (F, '; | * Automatically generated by ImageCfgEditor *');
    WriteLn (F, '; +-----------------------------------------------');
    //
    // write the names list
    WriteLn (F);
    WriteLn (F, '; +----- Names And Filenames Follows -------------');
    for iIndex := 0 to Pred (FImageList.NamesCount) do begin
      cIdentifier := FImageList.NamesListA [iIndex];
      if (cIdentifier = '') then continue;
      //
      cValue := FImageList.NamesList [cIdentifier];
      FImageList.GetProps (cIdentifier, bTransparent, bGridded);
      //
      WriteLn (F, cIdentifier, '=', cValue, ',',
        BoolStr [bTransparent], ',', BoolStr [bGridded]);
    end;
    //
    // write the aliases
    WriteLn (F);
    WriteLn (F, '; +----- Aliases Listed Next ---------------------');
    for iIndex := 0 to Pred (FImageList.AliasCount) do begin
      cIdentifier := FImageList.AliasListA [iIndex];
      if (cIdentifier = '') then break;
      //
      cValue := FImageList.AliasList [cIdentifier];
      WriteLn (F, '#', cIdentifier, '=', cValue);
    end;
    //
  finally
    CloseFile (F);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.popMenuAliasesDeleteClick(Sender: TObject);
begin
  FImageList.DeleteAlias (lbAliases.Items [lbAliases.ItemIndex]);
  lbAliases.Items.Delete (lbAliases.ItemIndex);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmImageConfEditor.popMenuNamesDeleteClick(Sender: TObject);
begin
  FImageList.DeleteName (lbNames.Items [lbNames.ItemIndex]);
  lbNames.Items.Delete (lbNames.ItemIndex); 
end;


end.

