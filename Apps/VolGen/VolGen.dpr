program VolGen;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  JclStrings,
  ZbVirtualFS,
  ZbFileIntf,
  ZbFileUtils;


var
  faOrdinary: Integer;
  cPhysicalPath: String;

  cVolFileName: String;
  volFile: TZbStandardVolume;

  fileMngr: IZbFileManager;

  ////////////////////////////////////////////////////////////////////
  function MakeVirtPath (cPath: String): String;
  var
    Index: Integer;
  begin
    Result := '';
    for Index := 1 to Length (cPath) do
      if (cPath [Index] = '\') then
        Result := Result + '/'
        else Result := Result + cPath [Index];
    //
    if (Result = '') OR (Result [1] <> '/') then Result := '/' + Result;
  end;

  ////////////////////////////////////////////////////////////////////
  procedure RecurseFolders (cRelativePath: String);
  var
    TSR: TSearchRec;
    iContinue: Integer;
    cWorkPath, cVirtPath: String;
    cFileToLoad, cExtension: String;
    fReader: IZbFileReader;
    Buffer: Pointer;
    BufSize: Integer;
    CurFolder: TZbFSFolder;
    IsFolder, IsSpecial: Boolean;

    function CheckExtension: Boolean;
    begin
      Result := (cExtension <> 'BMP') AND (cExtension <> 'JPG');
    end;

  begin

    // form the path to search...
    cWorkPath := cPhysicalPath + cRelativePath;
    cVirtPath := MakeVirtPath (cRelativePath);
    volFile.ChangeFolder (cVirtPath);

    // process files first
    iContinue := FindFirst (cWorkPath + '\*.*', faOrdinary, TSR);
    while (iContinue = 0) do begin
      //
      cFileToLoad := cWorkPath + '\' + TSR.Name;
      cExtension := UpperCase (StrAfter ('.', ExtractFileExt (cFileToLoad)));
      if (CheckExtension) then begin
        fReader := fileMngr.CreateReader (cFileToLoad);
        if (fReader <> NIL) then begin
          BufSize := fReader.GetSize;
          Buffer := fReader.ReadBuffer (BufSize);
          if (Buffer <> NIL) then begin
            WriteLn ('Adding: ', cFileToLoad);
            volFile.AddFileData (TSR.Name, Buffer, BufSize);
          end;
        end;
      end;
      //
      iContinue := FindNext (TSR);
    end;
    FindClose (TSR);

    // process the folders, pass one, create virtual equivalents
    CurFolder := volFile.FindFolder (cVirtPath);
    iContinue := FindFirst (cWorkPath + '\*.*', faDirectory, TSR);
    while (iContinue = 0) do begin
      //
      IsFolder := ((TSR.Attr AND faDirectory) <> 0);
      IsSpecial := (TSR.Name = '.') OR (TSR.Name = '..');
      if (IsFolder AND (NOT IsSpecial)) then CurFolder.CreateFolder (TSR.Name);
      //
      iContinue := FindNext (TSR);
    end;
    FindClose (TSR);

    // phase two of folder processing, get into them now!
    iContinue := FindFirst (cWorkPath + '\*.*', faDirectory, TSR);
    while (iContinue = 0) do begin
      //
      IsFolder := ((TSR.Attr AND faDirectory) <> 0);
      IsSpecial := (TSR.Name = '.') OR (TSR.Name = '..');
      if (IsFolder AND (NOT IsSpecial)) then begin
        if (cRelativePath = '') then
          RecurseFolders (TSR.Name)
          else RecurseFolders (cRelativePath + '\' + TSR.Name);
        //
      end;
      //
      iContinue := FindNext (TSR);
    end;
    FindClose (TSR);

  end;

////////////////////////////////////////////////////////////////////
begin
  faOrdinary := faAnyFile AND (NOT (faDirectory OR faReadOnly OR faSysFile OR faVolumeID));
  cPhysicalPath := IncludeTrailingPathDelimiter (GetCurrentDir);
  //
  if (ParamCount >= 1) then begin
    cVolFileName := ParamStr (1);
    if (Pos ('.', cVolFileName) = 0) then cVolFileName := cVolFileName + '.zvf';
  end else
    cVolFilename := 'Default.zvf';

  // remove old file first
  DeleteFile (cVolFileName);

  // create the volume
  fileMngr := TZbFileManager.Create as IZbFileManager;
  volFile := TZbStandardVolume.Create ('');
  RecurseFolders ('');

  // write out this new file
  WriteLn ('Writing Volume...');
  volFile.WriteVolume (cVolFileName);
  volFile.Free;
end.
