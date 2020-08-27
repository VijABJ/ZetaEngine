unit ZetaCfgEdU;

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
  ExtCtrls,
  StdCtrls,
  Buttons,
  Spin,
  ComCtrls,
  Grids,
  ValEdit;


const
  MSG_FILE_NOT_IN_ROOT        = 'File not under Root directory, Copy this file?';
  MSG_DELETE_FONT_CONFIRM     = 'Delete GUI Font Setting: Are You Sure?';
  MSG_DELETE_MUSIC_CONFIRM    = 'Delete Music Item: Are You Sure?';
  MSG_DELETE_SOUND_CONFIRM    = 'Delete Sound Effect Item: Are You Sure?';
  MSG_ALIAS_IN_USE            = 'Name given for alias is already in use';
  MSG_FONT_EXISTS             = 'Font Name Already Exists!';
  MSG_NAME_NOT_UNIQUE         = 'Game Name for the Media MUST be unique!';

  TITLE_WRONG_LOCATION        = 'Wrong File Location';
  TITLE_CONFIRMATION          = 'Confirm Operation';
  TITLE_ALIAS_ERROR           = 'Bad Alias';
  TITLE_FONT_ERROR            = 'Invalid Font';
  TITLE_NAME_ERROR            = 'Invalid Name';


type
  TfmZetaCfgEd = class(TForm)
    mmMain: TMainMenu;
    File1: TMenuItem;
    menuFileNew: TMenuItem;
    menuFileSave: TMenuItem;
    menuFileSaveAs: TMenuItem;
    N1: TMenuItem;
    menuFileExit: TMenuItem;
    menuFileOpen: TMenuItem;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    ledRootFolder: TLabeledEdit;
    sbtnRootFolder: TSpeedButton;
    cbResolutions: TComboBox;
    cbFullScreen: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    sedTileWidth: TSpinEdit;
    sedTileHeight: TSpinEdit;
    sedLevelHeight: TSpinEdit;
    lblTileWidth: TLabel;
    lblTileHeight: TLabel;
    lblLevelHeight: TLabel;
    pgMediaList: TPageControl;
    tsSoundEffects: TTabSheet;
    tsMusic: TTabSheet;
    editEfxFolder: TLabeledEdit;
    sbtnEfxFolder: TSpeedButton;
    vleEfxFiles: TValueListEditor;
    vleMusicFiles: TValueListEditor;
    editMusicFolder: TLabeledEdit;
    sbtnMusicFolder: TSpeedButton;
    dlgOpenMedia: TOpenDialog;
    popupMedia: TPopupMenu;
    popMenuAdd: TMenuItem;
    popMenuDelete: TMenuItem;
    popMenuRename: TMenuItem;
    tsPaths: TTabSheet;
    tsGUI: TTabSheet;
    clbDarkShade: TColorBox;
    Label1: TLabel;
    Label2: TLabel;
    clbLightShade: TColorBox;
    vleGuiFonts: TValueListEditor;
    popupFonts: TPopupMenu;
    popMenuNewFont: TMenuItem;
    popMenuEdit: TMenuItem;
    popMenuNewAlias: TMenuItem;
    N3: TMenuItem;
    popMenuEraseFont: TMenuItem;
    sbtnGetVolumeFile: TSpeedButton;
    dlgOpenVolume: TOpenDialog;
    lbDataFiles: TListBox;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure menuFileExitClick(Sender: TObject);
    procedure menuFileOpenClick(Sender: TObject);
    procedure cbFullScreenClick(Sender: TObject);
    procedure menuFileNewClick(Sender: TObject);
    procedure menuFileSaveClick(Sender: TObject);
    procedure menuFileSaveAsClick(Sender: TObject);
    procedure sbtnEfxFolderClick(Sender: TObject);
    procedure sbtnMusicFolderClick(Sender: TObject);
    procedure popMenuAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure popMenuDeleteClick(Sender: TObject);
    procedure popMenuRenameClick(Sender: TObject);
    procedure popMenuNewFontClick(Sender: TObject);
    procedure popMenuNewAliasClick(Sender: TObject);
    procedure popMenuEditClick(Sender: TObject);
    procedure popMenuEraseFontClick(Sender: TObject);
    procedure sbtnGetVolumeFileClick(Sender: TObject);
  private
    { Private declarations }
    FConfigFileName: string;
    FWindowCaption: string;
    FListAliases: TStrings;
    FListFontNames: TStrings;
    //
    procedure ChangeWindowCaption;
    function SelectFolder (ADefault: string): string;
    function SelectFileName (bResetMediaFolders: boolean = TRUE): boolean;
    function AllFieldsValid: boolean;
    procedure ToggleControls (bEnabled: boolean);
    procedure RefillFontAliases;
    procedure RefillFontNames;
  public
    { Public declarations }
  end;

var
  fmZetaCfgEd: TfmZetaCfgEd;

implementation

{$R *.dfm}

uses
  StrUtils,
  IdGlobal,
  //
  JclStrings,
  //
  ZbIniFileEx,
  ZbStringUtils,
  ZZConstants,
  ZEWSSupport,
  //
  FontEditDlgU,
  AliasDlgU,
  ZbStrDataEntryDlg,
  ZbFolderSelectDlg;


const
  acResCount = 4;
  acResNames: array [0..Pred (acResCount)] of String = (
    '640,480,32', '800,600,32', '1024,768,32', '1152,864,32');

function IndexToResName (AIndex: Integer): String;
begin
  if (AIndex < 0) then AIndex := 0;
  if (AIndex >= acResCount) then AIndex := Pred (acResCount);
  Result := acResNames [AIndex];
end;

function ResNameToIndex (AResName: string): Integer;
begin
  for Result := 0 to Pred (acResCount) do
    if (acResNames [Result] = AResName) then Exit;
  //
  Result := -1;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.FormCreate(Sender: TObject);
var
  cApplicationFolder: string;
begin
  FListAliases := TStringList.Create;
  FListFontNames := TStringList.Create;
  //
  FConfigFileName := '';
  FWindowCaption := Caption;
  pgMediaList.ActivePage := tsSoundEffects;
  //
  cApplicationFolder := ExtractFileDir (Application.ExeName);
  dlgOpen.InitialDir := cApplicationFolder;
  dlgSave.InitialDir := cApplicationFolder;
  //
  ToggleControls (FALSE);
  //
  menuFileSave.Enabled := FALSE;
  menuFileSaveAs.Enabled := FALSE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.FormDestroy(Sender: TObject);
begin
  FListAliases.Free;
  FListFontNames.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.ChangeWindowCaption;
begin
  Hide;
  Caption := FWindowCaption + ' - ' + FConfigFileName;
  Show;
end;

//////////////////////////////////////////////////////////////////////////
function TfmZetaCfgEd.SelectFolder (ADefault: string): string;
var
  fmFolderSelect: TfmFolderSelect;
  cmResult: Integer;
begin
  Result := ADefault;
  fmFolderSelect := TfmFolderSelect.Create (Self);
  //
  cmResult := fmFolderSelect.ShowModal;
  if (cmResult = mrOK) then begin
    Result := fmFolderSelect.GetSelectedFolder;
    if (Pos (ledRootFolder.Text, Result) < 1) then begin
      MessageBox (0, 'Folder MUST be relative to root folder as specified', 'ERROR', MB_OK);
      Result := ADefault;
    end;
  end;
  //
  fmFolderSelect.Free;
end;

//////////////////////////////////////////////////////////////////////////
function TfmZetaCfgEd.SelectFileName (bResetMediaFolders: boolean): boolean;
begin
  Result := FALSE;
  if (NOT dlgSave.Execute) then Exit;
  FConfigFileName := ChgFileExt (dlgSave.FileName, 'zsf', TRUE);
  ledRootFolder.Text := IncludeTrailingPathDelimiter (ExtractFileDir (FConfigFileName));
  //
  if (bResetMediaFolders) then begin
    editMusicFolder.Text := ledRootFolder.Text;
    editEfxFolder.Text := ledRootFolder.Text;
  end;
  //
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
function TfmZetaCfgEd.AllFieldsValid: boolean;
begin
  Result := FALSE;
  //
  if (cbResolutions.ItemIndex < 0) then begin
    MessageBox (0, 'Please Select A Screen Resolution', 'INVALID ENTRY', MB_OK);
    Exit;
  end;
  //
  Result := TRUE;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.ToggleControls (bEnabled: boolean);
begin
  ledRootFolder.Enabled := bEnabled;
  sbtnRootFolder.Enabled := bEnabled;
  cbFullScreen.Enabled := bEnabled;
  cbResolutions.Enabled := bEnabled;
  lblTileWidth.Enabled := bEnabled;
  sedTileWidth.Enabled := bEnabled;
  lblTileHeight.Enabled := bEnabled;
  sedTileHeight.Enabled := bEnabled;
  lblLevelHeight.Enabled := bEnabled;
  sedLevelHeight.Enabled := bEnabled;
  pgMediaList.Enabled := bEnabled;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.RefillFontAliases;
var
  iIndex: integer;
  cData: string;
begin
  FListAliases.Clear;
  for iIndex := 0 to Pred (vleGuiFonts.Strings.Count) do begin
    cData := vleGuiFonts.Strings.Names [iIndex];
    if (cData [1] <> '#') then continue;
    FListAliases.Add (Copy (cData, 2, Length (cData)));
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.RefillFontNames;
var
  iIndex: integer;
  cData: string;
begin
  FListFontNames.Clear;
  for iIndex := 0 to Pred (vleGuiFonts.Strings.Count) do begin
    cData := vleGuiFonts.Strings.Names [iIndex];
    if (cData [1] = '#') then continue;
    FListFontNames.Add (cData);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.cbFullScreenClick(Sender: TObject);
begin
  cbResolutions.Enabled := cbFullScreen.Checked;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.menuFileNewClick(Sender: TObject);
begin
  if (SelectFileName) then begin
    ToggleControls (TRUE);
    vleMusicFiles.Strings.Clear;
    vleEfxFiles.Strings.Clear;
    vleGuiFonts.Strings.Clear;
    FListAliases.Clear;
    FListFontNames.Clear;
    menuFileSave.Enabled := TRUE;
    menuFileSaveAs.Enabled := TRUE;
    ChangeWindowCaption;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.menuFileOpenClick(Sender: TObject);
var
  Source: TZbIniFileEx;
  cData: String;
  SList: TStrings;
  iIndex: integer;
begin
  if (NOT dlgOpen.Execute) then Exit;
  //
  FConfigFileName := ChgFileExt (dlgOpen.FileName, 'zsf', TRUE);
  ledRootFolder.Text := IncludeTrailingPathDelimiter (ExtractFileDir (FConfigFileName));
  //
  Source := TZbIniFileEx.Create (FConfigFileName);
  SList := TStringList.Create;
  try
    with Source do begin
      cData := Trim (ReadString (REZ_DIRECTX_SECTION,
        REZ_DIRECTX_RESOLUTION, REZ_DX_RESOLUTION_DEF));
      cbResolutions.ItemIndex := ResNameToIndex (cData);
      //
      cbFullScreen.Checked := ReadBool (REZ_DIRECTX_SECTION,
        REZ_DIRECTX_EXCLUSIVE, REZ_DIRECTX_EXCLUSIVE_DEF);
      //
      sedTileWidth.Value := ReadInteger (REZ_TILE_ENGINE_SECTION,
        REZ_TENG_TILE_WIDTH, REZ_TENG_TILE_WIDTH_DEF);
      sedTileHeight.Value := ReadInteger (REZ_TILE_ENGINE_SECTION,
        REZ_TENG_TILE_HEIGHT, REZ_TENG_TILE_HEIGHT_DEF);
      sedLevelHeight.Value := ReadInteger (REZ_TILE_ENGINE_SECTION,
        REZ_TENG_LEVEL_HEIGHT, REZ_TENG_LEVEL_HEIGHT_DEF);
      //
      vleMusicFiles.Strings.Clear;
      cData := Trim (ReadString (REZ_PATH_SECTION, REZ_MUSIC_PATH, REZ_MUSIC_PATH_DEF));
      if (cData = '.') then cData := '';
      editMusicFolder.Text := ledRootFolder.Text + cData;
      ReadSection (REZ_MUSIC_SECTION, SList, TRUE);
      if (SList.Count > 0) then vleMusicFiles.Strings.AddStrings(SList);
      //
      vleEfxFiles.Strings.Clear;
      cData := Trim (ReadString (REZ_PATH_SECTION, REZ_SND_EFX_PATH, REZ_SND_EFX_PATH_DEF));
      if (cData = '.') then cData := '';
      editEfxFolder.Text := ledRootFolder.Text + cData;
      ReadSection (REZ_SOUND_EFFECTS_SECTION, SList, TRUE);
      if (SList.Count > 0) then vleEfxFiles.Strings.AddStrings (SList);
      //
      cData := ReadString (REZ_GUI_MNGR_SECTION, REZ_GM_BTN_DARK_SHADE, REZ_GM_BTN_DARK_SHADE_DEF);
      clbDarkShade.Selected := StrToColorRef (cData);
      cData := ReadString (REZ_GUI_MNGR_SECTION, REZ_GM_BTN_LIGHT_SHADE, REZ_GM_BTN_LIGHT_SHADE_DEF);
      clbLightShade.Selected := StrToColorRef (cData);
      //
      vleGuiFonts.Strings.Clear;
      ReadSection (REZ_GUI_FONTS_SECTION, SList, TRUE);
      if (SList.Count > 0) then vleGuiFonts.Strings.AddStrings (SList);
      RefillFontAliases;
      RefillFontNames;
      //
      Source.ReadSection (REZ_DATA_SECTION, SList, TRUE);
      for iIndex := 0 to Pred (SList.Count) do
        lbDataFiles.Items.Add (ledRootFolder.Text + StrAfter ('=', SList [iIndex]));
    end;
  finally
    Source.Free;
    SList.Free;
  end;
  //
  ToggleControls (TRUE);
  menuFileSave.Enabled := TRUE;
  menuFileSaveAs.Enabled := TRUE;
  //
  ChangeWindowCaption;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.menuFileExitClick(Sender: TObject);
begin
  Close;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.menuFileSaveClick(Sender: TObject);
var
  Source: TZbIniFileEx;
  cFolder: String;
  iIndex: integer;
begin
  if (FConfigFileName = '') OR (NOT AllFieldsValid) then Exit;
  //
  Source := TZbIniFileEx.Create (FConfigFileName, FALSE);
  if (Source = NIL) then Exit;
  //
  with Source do begin
    AddHeaderText (Format ('; FILE: %s', [ExtractFileName(FConfigFileName)]));
    AddHeaderText ('; ----- Zeta Engine Configuration ------');
    AddHeaderText ('; |                                    |');
    AddHeaderText ('; |   automatically generated by Zeta  |');
    AddHeaderText ('; |        Configuration Editor        |');
    AddHeaderText ('; |                                    |');
    AddHeaderText ('; --------------------------------------');

    //
    WriteString (REZ_DIRECTX_SECTION, REZ_DIRECTX_RESOLUTION,
      IndexToResName (cbResolutions.ItemIndex));
    WriteBool (REZ_DIRECTX_SECTION, REZ_DIRECTX_EXCLUSIVE, cbFullScreen.Checked);

    //
    WriteInteger (REZ_TILE_ENGINE_SECTION, REZ_TENG_TILE_WIDTH, sedTileWidth.Value);
    WriteInteger (REZ_TILE_ENGINE_SECTION, REZ_TENG_TILE_HEIGHT, sedTileHeight.Value);
    WriteInteger (REZ_TILE_ENGINE_SECTION, REZ_TENG_LEVEL_HEIGHT, sedLevelHeight.Value);

    //
    if (editMusicFolder.Text <> '') then
      cFolder := Copy (editMusicFolder.Text,
        Length (ledRootFolder.Text) + 1, Length (editMusicFolder.Text))
        else cFolder := '';
    WriteString (REZ_PATH_SECTION, REZ_MUSIC_PATH, IfThen (cFolder = '', '.', cFolder));
    WriteSection (REZ_MUSIC_SECTION, vleMusicFiles.Strings);

    //
    if (editEfxFolder.Text <> '') then
      cFolder := Copy (editEfxFolder.Text,
        Length (ledRootFolder.Text) + 1, Length (editEfxFolder.Text))
        else cFolder := '';
    WriteString (REZ_PATH_SECTION, REZ_SND_EFX_PATH, IfThen (cFolder = '', '.', cFolder));
    WriteSection (REZ_SOUND_EFFECTS_SECTION, vleEfxFiles.Strings);

    //
    for iIndex := 0 to Pred (lbDataFiles.Items.Count) do begin
      cFolder := System.Copy (lbDataFiles.Items [iIndex],
        Length (ledRootFolder.Text) + 1, Length (lbDataFiles.Items [iIndex]));
      WriteString (REZ_DATA_SECTION, IntToStr (iIndex), cFolder);
    end;

    //
    WriteString (REZ_GUI_MNGR_SECTION, REZ_GM_BTN_DARK_SHADE, ColorToString (clbDarkShade.Selected));
    WriteString (REZ_GUI_MNGR_SECTION, REZ_GM_BTN_LIGHT_SHADE, ColorToString (clbLightShade.Selected));

    //
    WriteSection (REZ_GUI_FONTS_SECTION, vleGuiFonts.Strings);

    //
    SaveFile;
  end;
  //
  Source.Free;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.menuFileSaveAsClick(Sender: TObject);
begin
  if (NOT SelectFileName (FALSE)) then Exit;
  menuFileSaveClick (NIL);
  ChangeWindowCaption;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.sbtnEfxFolderClick(Sender: TObject);
begin
  editEfxFolder.Text := SelectFolder (editEfxFolder.Text);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.sbtnMusicFolderClick(Sender: TObject);
begin
  editMusicFolder.Text := SelectFolder (editMusicFolder.Text);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.popMenuAddClick(Sender: TObject);
var
  cKeyName: string;
  cFolderBase: string;
  cFileNameSource: string;
  cFileNameDest: string;
  lPromptResult: longint;
  fmStringEntry: TfmStringEntry;
  bUniqueCheck: boolean;
begin
  //
  // set the initial directory depending on which page is active
  if (pgMediaList.ActivePage = tsMusic) then
    cFolderBase := editMusicFolder.Text
    else cFolderBase := editEfxFolder.Text;
  //
  // call the Execute method of the dialog, exit if it was cancelled
  dlgOpenMedia.InitialDir := cFolderBase;
  if (NOT dlgOpenMedia.Execute) then Exit;

  // ask the user for the alias of this file...
  fmStringEntry := TfmStringEntry.Create (Self);
  fmStringEntry.SetCaptions ('Media Name', 'Enter Game Name For This Media');
  lPromptResult := fmStringEntry.ShowModal;
  cKeyName := fmStringEntry.GetStrData;
  fmStringEntry.Free;

  // check results of the input box
  if (lPromptResult = mrCancel) OR (cKeyName = '') then Exit;

  // check if the name given was unique, otherwise, we can't add it...
  if (pgMediaList.ActivePage = tsMusic) then
    bUniqueCheck := (vleMusicFiles.Strings.IndexOfName (cKeyName) < 0)
    else bUniqueCheck := (vleEfxFiles.Strings.IndexOfName (cKeyName) < 0);

  if (NOT bUniqueCheck) then begin
    MessageBox (0, MSG_NAME_NOT_UNIQUE, TITLE_NAME_ERROR, MB_OK);
    Exit;
  end;

  // remember the filename of the file selected
  cFileNameSource := dlgOpenMedia.FileName;

  // check if the file is under the root dir, if not we may have to copy it
  if (Pos (cFolderBase, cFileNameSource) < 1) then begin
    lPromptResult := MessageBox (0, MSG_FILE_NOT_IN_ROOT, TITLE_WRONG_LOCATION, MB_OKCANCEL);
    if (lPromptResult = IDCANCEL) then Exit;
    //
    cFileNameDest := IncludeTrailingPathDelimiter (cFolderBase) +
                     ExtractFileName (cFileNameSource);

    // copy the file
    if (NOT CopyFileTo (cFileNameSource, cFileNameDest)) then Exit;

    //
    cFileNameSource := cFileNameDest;
  end;

  //
  cFileNameSource := Copy (cFileNameSource, Length (cFolderBase) + 1, Length (cFileNameSource));
  if (pgMediaList.ActivePage = tsMusic) then
    vleMusicFiles.Strings.Add (cKeyName + '=' + cFileNameSource)
    else vleEfxFiles.Strings.Add (cKeyName + '=' + cFileNameSource);

end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.popMenuDeleteClick(Sender: TObject);
var
  lPromptResult: integer;
begin
  if (pgMediaList.ActivePage = tsMusic) then begin
    if (vleMusicFiles.Strings.Count < 1) OR (vleMusicFiles.Row < 1) then Exit;
    lPromptResult := MessageBox (0, MSG_DELETE_MUSIC_CONFIRM, TITLE_CONFIRMATION, MB_OKCANCEL);
    if (lPromptResult = IDCANCEL) then Exit;
    vleMusicFiles.DeleteRow (vleMusicFiles.Row);
  end else begin
    if (vleEfxFiles.Strings.Count < 1) OR (vleEfxFiles.Row < 1) then Exit;
    lPromptResult := MessageBox (0, MSG_DELETE_SOUND_CONFIRM, TITLE_CONFIRMATION, MB_OKCANCEL);
    if (lPromptResult = IDCANCEL) then Exit;
    vleEfxFiles.DeleteRow (vleEfxFiles.Row);
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.popMenuRenameClick(Sender: TObject);
var
  fmStringEntry: TfmStringEntry;
  cKeyName: string;

  function RunLineEdit: boolean;
  begin
    // ask the user for the alias of this file...
    fmStringEntry := TfmStringEntry.Create (Self);
    fmStringEntry.SetCaptions ('Media Name', 'Enter Game Name For This Media');
    Result := (fmStringEntry.ShowModal = mrOK);
    cKeyName := fmStringEntry.GetStrData;
    fmStringEntry.Free;
  end;

  function CheckUnique (Target: string; Reference: TStrings): boolean;
  begin
    Result := (Reference.IndexOfName (Target) < 0);
    if (NOT Result) then
      MessageBox (0, MSG_NAME_NOT_UNIQUE, TITLE_NAME_ERROR, MB_OK);
  end;

begin
  if (pgMediaList.ActivePage = tsMusic) then begin
    if (vleMusicFiles.Strings.Count < 1) OR (vleMusicFiles.Row < 1) then Exit;
    if (NOT RunLineEdit) then Exit;
    if (NOT CheckUnique (cKeyName, vleMusicFiles.Strings)) then Exit;
    vleMusicFiles.Keys [vleMusicFiles.Row] := cKeyName;
    //
  end else begin
    if (vleEfxFiles.Strings.Count < 1) OR (vleEfxFiles.Row < 1) then Exit;
    if (NOT RunLineEdit) then Exit;
    if (NOT CheckUnique (cKeyName, vleEfxFiles.Strings)) then Exit;
    vleEfxFiles.Keys [vleEfxFiles.Row] := cKeyName;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.popMenuNewFontClick(Sender: TObject);
var
  fmFontEditDlg: TfmFontEditDlg;
  lResult: integer;
  cFontSpec: string;
  cFontName: string;
begin
  fmFontEditDlg := TfmFontEditDlg.Create (Self);
  lResult := fmFontEditDlg.ShowModal;
  if (lResult = mrOK) then 
    cFontSpec := fmFontEditDlg.GetFontSpec
    else cFontSpec := '';
  fmFontEditDlg.Free;
  //
  if (cFontSpec = '') then Exit;
  cFontName := StrBefore ('=', cFontSpec);
  if (FListAliases.IndexOf (cFontName) >= 0) OR
     (FListFontNames.IndexOf (cFontName) >= 0) then begin
        MessageBox (0, MSG_FONT_EXISTS, TITLE_FONT_ERROR, MB_OK);
        Exit;
      end;
  //
  //
  vleGuiFonts.Strings.Add (cFontSpec);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.popMenuNewAliasClick(Sender: TObject);
var
  fmAliasEditDlg: TfmAliasEditDlg;
  lResult: integer;
  cAlias, cValue: string;
begin
  fmAliasEditDlg := TfmAliasEditDlg.Create (Self);
  fmAliasEditDlg.SetDefaultAlias ('');
  fmAliasEditDlg.SetAliasValues (FListFontNames);
  lResult := fmAliasEditDlg.ShowModal;
  if (lResult = mrOK) then fmAliasEditDlg.GetAliasResults (cAlias, cValue);
  fmAliasEditDlg.Free;
  //
  if (lResult = mrCancel) then Exit;
  if (FListAliases.IndexOf (cAlias) >= 0) OR (FListFontNames.IndexOf (cAlias) >= 0) then begin
    MessageBox (0, MSG_ALIAS_IN_USE, TITLE_ALIAS_ERROR, MB_OK);
    Exit;
  end;
  //
  FListAliases.Add (cAlias);
  vleGuiFonts.Strings.Add ('#' + cAlias + '=' + cValue);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.popMenuEditClick(Sender: TObject);
begin
  if (vleGuiFonts.Strings.Count < 1) OR (vleGuiFonts.Row < 1) then Exit;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.popMenuEraseFontClick(Sender: TObject);
var
  lPromptResult: integer;
begin
  if (vleGuiFonts.Strings.Count < 1) OR (vleGuiFonts.Row < 1) then Exit;
  //
  lPromptResult := MessageBox (0, MSG_DELETE_FONT_CONFIRM, TITLE_CONFIRMATION, MB_OKCANCEL);
  if (lPromptResult = IDCANCEL) then Exit;
  vleGuiFonts.DeleteRow (vleGuiFonts.Row);
  RefillFontAliases;
  RefillFontNames;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmZetaCfgEd.sbtnGetVolumeFileClick(Sender: TObject);
var
  cFolderBase, cVolumeFile, cCopyTarget: string;
  lResult: integer;
begin
  cFolderBase := IncludeTrailingPathDelimiter (ledRootFolder.Text);
  //
  dlgOpenVolume.InitialDir := cFolderBase;
  if (NOT dlgOpenVolume.Execute) then Exit;
  //
  cVolumeFile := dlgOpenVolume.FileName;
  if (Pos (cFolderBase, cVolumeFile) < 1) then begin
    lResult := MessageBox (0, MSG_FILE_NOT_IN_ROOT, TITLE_WRONG_LOCATION, MB_OKCANCEL);
    if (lResult = IDCANCEL) then Exit;
    //
    // copy the file
    cCopyTarget := cFolderBase + ExtractFileName (cVolumeFile);
    if (NOT CopyFileTo (cVolumeFile, cCopyTarget)) then Exit;
    cVolumeFile := cCopyTarget;
    //
  end;
  //
  lbDataFiles.Items.Add (cVolumeFile);
end;

end.

