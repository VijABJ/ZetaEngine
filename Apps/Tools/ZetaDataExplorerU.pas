unit ZetaDataExplorerU;

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
  Grids,
  ExtCtrls,
  ComCtrls,
  //
  ZbVirtualFS;

type
  TfmDataExplorer = class(TForm)
    sbMain: TStatusBar;
    tvFolders: TTreeView;
    splitterMain: TSplitter;
    strFiles: TStringGrid;
    menuMain: TMainMenu;
    popMenuFolders: TPopupMenu;
    popMenuFiles: TPopupMenu;
    menuMainFile: TMenuItem;
    menuFileNew: TMenuItem;
    menuFileSave: TMenuItem;
    menuFileSaveAs: TMenuItem;
    N1: TMenuItem;
    menuFileExit: TMenuItem;
    menuFileOpen: TMenuItem;
    popFolderAdd: TMenuItem;
    popFolderDelete: TMenuItem;
    popFileAdd: TMenuItem;
    popFileDelete: TMenuItem;
    popFileRename: TMenuItem;
    dlgOpen: TOpenDialog;
    dlgSaveVolume: TSaveDialog;
    dlgOpenVolume: TOpenDialog;
    N2: TMenuItem;
    popFileDeleteAll: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure splitterMainMoved(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure menuFileNewClick(Sender: TObject);
    procedure menuFileSaveClick(Sender: TObject);
    procedure menuFileSaveAsClick(Sender: TObject);
    procedure menuFileExitClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure menuFileOpenClick(Sender: TObject);
    procedure popFolderAddClick(Sender: TObject);
    procedure popFolderDeleteClick(Sender: TObject);
    procedure popFileAddClick(Sender: TObject);
    procedure popFileDeleteClick(Sender: TObject);
    procedure popFileRenameClick(Sender: TObject);
    procedure tvFoldersClick(Sender: TObject);
    procedure tvFoldersChange(Sender: TObject; Node: TTreeNode);
    procedure popFileDeleteAllClick(Sender: TObject);
  private
    { Private declarations }
    FVolume: TZbStandardVolume;
    FVolumeLoaded: boolean;
    FChangesMade: int64;
    FWorkName: string;
    //
    procedure ResizeFileList;
    procedure ClearFileList;
    procedure ClearFolderTree;
    procedure ClearViews;
    procedure AddToFilesList (AFileName: string; AFileSize: integer);
    procedure RefillFileList;
    procedure ReloadViewsFromVolume;
    function GetFileNameToSaveTo (bForceNewFileName: boolean = FALSE): string;
    procedure SaveVolumeToFile (AFileName: string);
  public
    { Public declarations }
  end;

var
  fmDataExplorer: TfmDataExplorer;


implementation

{$R *.dfm}

uses
  StrUtils,
  ZbFileIntf,
  ZbFileUtils,
  ZbStrDataEntryDlg;


//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.FormCreate(Sender: TObject);
begin
  FVolume := TZbStandardVolume.Create ('');
  //
  ClearViews;
  tvFolders.Enabled := FALSE;
  strFiles.Enabled := FALSE;
  //
  FVolumeLoaded := FALSE;
  FChangesMade := 0;
  FWorkName := '';
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.FormDestroy(Sender: TObject);
begin
  ClearViews;
  FreeAndNIL (FVolume);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.ResizeFileList;
begin
  strFiles.ColWidths [0] := ((strFiles.Width * 40) div 100);
  strFiles.ColWidths [1] := strFiles.Width - strFiles.ColWidths [0];
  strFiles.Invalidate;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.ClearFileList;
begin
  with strFiles do begin
    RowCount := 1;
    ColCount := 2;
    Cells [0, 0] := 'Filename';
    Cells [1, 0] := 'Size (Bytes)';
  end;
  ResizeFileList;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.ClearFolderTree;
begin
  tvFolders.Items.Clear;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.ClearViews;
begin
  ClearFileList;
  ClearFolderTree;
  tvFolders.Items.AddChild(NIL, ZBFS_ROOT_FOLDER_NAME);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.AddToFilesList (AFileName: string; AFileSize: integer);
var
  iRowLast: integer;
begin
  // if the name is already in the list, no need to add it
  if (strFiles.Cols [0].IndexOf (AFileName) >= 0) then Exit;
  //
  iRowLast := strFiles.RowCount;
  strFiles.RowCount := strFiles.RowCount + 1;
  strFiles.Cells [0, iRowLast] := AFileName;
  strFiles.Cells [1, iRowLast] := IntToStr (AFileSize);
  strFiles.Invalidate;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.RefillFileList;
var
  theFolder: TZbFSFolder;
  theFile: TZbFSFile;
  iIndex: integer;
begin
  strFiles.Enabled := TRUE;
  strFiles.RowCount := 1;
  //
  theFolder := FVolume.ChangeFolder (sbMain.SimpleText);
  if (theFolder.FileCount > 0) then begin
    for iIndex := 0 to Pred (theFolder.FileCount) do begin
      theFile := theFolder.FilesA [iIndex];
      if (theFile = NIL) then break;
      AddToFilesList (theFile.Name, theFile.Size);
    end;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.ReloadViewsFromVolume;

  procedure RecursiveAdd (folder: TZbFSFolder; node: TTreeNode);
  var
    iIndex: integer;
    theFolder: TZbFSFolder;
    theNode: TTreeNode;
  begin
    if (folder = NIL) OR (node = NIL) then Exit;
    //
    for iIndex := 0 to Pred (folder.FolderCount) do begin
      //
      theFolder := folder.FoldersA [iIndex];
      if (theFolder = NIL) then break;
      //
      theNode := tvFolders.Items.AddChild (node, theFolder.Name);
      RecursiveAdd (theFolder, theNode);
    end;
  end;

begin
  ClearViews;
  RecursiveAdd (FVolume.Root, tvFolders.Items [0]);
  tvFolders.Enabled := TRUE;
  tvFolders.Items [0].Expand (TRUE);
  tvFoldersClick (NIL);
end;

//////////////////////////////////////////////////////////////////////////
function TfmDataExplorer.GetFileNameToSaveTo (bForceNewFileName: boolean): string;
begin
  Result := IfThen (bForceNewFileName, '', FWorkName);
  if (Result = '') then begin
    if (NOT dlgSaveVolume.Execute) then Exit;
    Result := dlgSaveVolume.FileName;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.SaveVolumeToFile (AFileName: string);
begin
  if (AFileName = '') then Exit;
  FVolume.WriteVolume (AFileName);
  FWorkName := AFileName;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.splitterMainMoved(Sender: TObject);
begin
  ResizeFileList;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.FormResize(Sender: TObject);
begin
  ResizeFileList;
end;

  { ---------------- MAIN MENU ROUTINES ------------------}

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.menuFileNewClick(Sender: TObject);
var
  lResult: integer;
begin
  if (FVolumeLoaded) AND (FChangesMade > 0) then begin
    lResult := MessageBox (Handle,
      'Some changes to the current volume have not been changed, Abandon anyway?',
      'Creating New Volume...', MB_YESNO);
    if (lResult = IDNO) then Exit;
  end;
  //
  ClearViews;
  FVolume.Root.Clear;
  tvFolders.Enabled := TRUE;
  tvFoldersClick (NIL);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.menuFileOpenClick(Sender: TObject);
begin
  if (NOT dlgOpenVolume.Execute) then Exit;
  if (NOT FileExists (dlgOpenVolume.FileName)) then Exit;
  //
  FVolume.LoadVolume (dlgOpenVolume.FileName);
  ReloadViewsFromVolume;
  FWorkName := dlgOpenVolume.FileName;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.menuFileSaveClick(Sender: TObject);
begin
  SaveVolumeToFile (GetFileNameToSaveTo);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.menuFileSaveAsClick(Sender: TObject);
begin
  SaveVolumeToFile (GetFileNameToSaveTo (TRUE));
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.menuFileExitClick(Sender: TObject);
begin
  Close;
end;

  { ------------- FOLDER POP MENU ROUTINES ---------------}

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.popFolderAddClick(Sender: TObject);
var
  StrEd: TfmStringEntry;
  cFolder: string;
begin
  // cannot add to NIL folder
  if (tvFolders.Selected = NIL) OR (FVolume.fdCurrent = NIL) then Exit;
  // create dialog
  StrEd := TfmStringEntry.Create (Self);
  if (StrEd = NIL) then Exit;
  // configure dialog, and run it
  StrEd.SetCaptions ('Add Folder', 'Folder Name');
  if (StrEd.ShowModal = mrOK) then
    cFolder := Trim (StrEd.GetStrData)
    else cFolder := '';
  StrEd.Free;
  if (cFolder = '') then Exit;
  // check if folder already exists, exit now if so
  if (FVolume.fdCurrent.Folders [cFolder] <> NIL) then begin
    MessageBox (Handle, 'A folder of the same name already exists', 'Error', MB_OK);
    Exit;
  end;
  //
  if (FVolume.fdCurrent.CreateFolder (cFolder) = NIL) then Exit;
  tvFolders.Items.AddChild (tvFolders.Selected, cFolder);
  if (NOT tvFolders.Selected.Expanded) then tvFolders.Selected.Expand (FALSE);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.popFolderDeleteClick(Sender: TObject);
begin
  // cannot delete NIL selections, nor the Root Folder
  if (tvFolders.Selected = NIL) OR (tvFolders.Selected.Level < 1) then Exit;
end;

  { ------------- FILES  POP MENU ROUTINES ---------------}

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.popFileAddClick(Sender: TObject);
var
  fBuffer: Pointer;
  fBufSize: int64;
  cLongName, cFileName: string;
  iPos: integer;
  FileMngr: IZbFileManager;
  Reader: IZbFileReader;
begin
  if (tvFolders.Selected = NIL) OR (NOT dlgOpen.Execute) then Exit;
  //
  FileMngr := TZbFileManager.Create as IZbFileManager;
  sbMain.SimpleText := 'Adding Files...';
  for iPos := 0 to Pred (dlgOpen.Files.Count) do begin
    // get the filename from the dialog box.  check if file exists!
    cLongName := dlgOpen.Files [iPos];
    // create a stream to read file data, if this fails, continue with rest
    Reader := FileMngr.CreateReader (cLongName);
    if (Reader = NIL) then continue;
    //
    cFileName := ExtractFileName (cLongName);
    sbMain.SimpleText := 'Adding ' + cFileName + '...';
    //
    fBufSize := Reader.GetSize;
    fBuffer := Reader.ReadBuffer (fBufSize);
    if (fBuffer <> NIL) then begin
      FVolume.AddFileData (cFileName, fBuffer, fBufSize);
      AddToFilesList (cFileName, fBufSize);
    end;
    //
  end;
  //
  FileMngr := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.popFileDeleteClick(Sender: TObject);
var
  cFullPath: string;
begin
  // be sure that the list is enabled, and that there is something selected
  // other than the first row (which contains the captions
  if (StrFiles.Enabled) AND (StrFiles.Row > 0) then begin
    cFullPath := sbMain.SimpleText + StrFiles.Cells [0, StrFiles.Row];
    FVolume.DeleteFile (cFullPath);
    RefillFileList;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.popFileRenameClick(Sender: TObject);
begin
  //
end;


//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.popFileDeleteAllClick(Sender: TObject);
var
  theFolder: TZbFSFolder;
begin
  theFolder := FVolume.ChangeFolder (sbMain.SimpleText);
  if (theFolder = NIL) then Exit;
  theFolder.Clear;
  RefillFileList;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.tvFoldersClick(Sender: TObject);
begin
  tvFoldersChange(Self, tvFolders.Selected);
end;


//////////////////////////////////////////////////////////////////////////
procedure TfmDataExplorer.tvFoldersChange(Sender: TObject; Node: TTreeNode);
var
  cPathName: string;
begin
  if (Node = NIL) then begin
    //
    strFiles.Enabled := FALSE;
    FVolume.ChangeFolder ('');
    //
  end else begin
    //
    cPathName := '';
    while (Node.Parent <> NIL) do begin
      cPathName := Node.Text + ZBFS_PATH_SEPARATOR + cPathName;
      Node := Node.Parent;
    end;
    cPathName := ZBFS_PATH_SEPARATOR + cPathName;
    sbMain.SimpleText := cPathName;
    RefillFileList;
    //
  end;
end;


end.

