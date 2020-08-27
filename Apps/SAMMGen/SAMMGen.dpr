program SAMMGen;

{$APPTYPE CONSOLE}

uses
  windows,
  SysUtils,
  JclStrings;

var
  cBasePath, cRelativePath, cSAMMPath, cZEDPath, cConfigPath: String;
  cDefImages, cDefSprites: String;
  fDefImages, fDefSprites: Text;


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
  end;

  ////////////////////////////////////////////////////////////////////
  function MakeFileName (cPath: String): String;
  var
    Index: Integer;
  begin
    Result := '';
    for Index := 1 to Length (cPath) do
      if (cPath [Index] = '\') then
        Result := Result + '_'
        else Result := Result + cPath [Index];
  end;

  ////////////////////////////////////////////////////////////////////
  procedure RecurseGen (cRelativePath: String; cSAMMBaseName: String = '');
  var
    cWorkPath, cVirtPath: String;
    cFileName, cExtension: String;
    //
    iContinue, iZEDEntries: Integer;
    TSR: TSearchRec;
    //
    cZEDFileName: String;
    fZED, fSAMM: Text;

    procedure MakeEntries;
    var
      cName, cVirtFile, cSAMMFile: String;
    begin
      cName := cFileName + '.' + cExtension;
      WriteLn ('Processing: ' + cWorkPath + cName + '...');
      //
      cVirtFile := cVirtPath + cName;
      WriteLn (fDefImages, Format ('DefObj/%s=%s,1,0', [cFileName, cVirtFile]));
      WriteLn (fDefSprites, Format ('Entity/%s=DefObj/%s,0,0', [cFileName, cFileName]));
      //
      WriteLn (fZED, '[', cFileName, ']');
      WriteLn (fZED, 'Updateable=0');
      WriteLn (fZED, 'Orientable=0');
      WriteLn (fZED, 'MoveRate=0');
      WriteLn (fZED);
      //
      cSAMMFile := cSAMMPath + cFileName;
      AssignFile (fSAMM, cSAMMFile + '.SAMM');
      Rewrite (fSAMM);
      //
      WriteLn (fSAMM, '[MAIN]');
      WriteLn (fSAMM, 'Name=', cFileName);
      WriteLn (fSAMM, 'Orientations=X');
      WriteLn (fSAMM);

      WriteLn (fSAMM, '[#DEFAULT]');
      WriteLn (fSAMM, 'BaseSprite=', cFileName);
      WriteLn (fSAMM, 'Images=1');
      WriteLn (fSAMM, 'Frames=1');
      WriteLn (fSAMM, 'Repeating=1');
      WriteLn (fSAMM, 'NextAction=');
      WriteLn (fSAMM);

      WriteLn (fSAMM, '[$DEFAULT]');
      WriteLn (fSAMM, '0=0,0,,');
      CloseFile (fSAMM);

      Inc (iZEDEntries);
    end;

  begin
    cWorkPath := cBasePath + cRelativePath + '\';
    cVirtPath := MakeVirtPath (cRelativePath) + '/';
    if (cVirtPath [1] <> '/') then cVirtPath := '/' + cVirtPath;
    //
    cZEDFileName := MakeFileName (MakeFileName (cRelativePath) + '.ZED');
    AssignFile (fZED, cZEDPath + cZEDFileName);
    Rewrite (fZED);
    iZEDEntries := 0;
    //
    try
      iContinue := FindFirst (cWorkPath + '*.*', faAnyFile, TSR);
      if (iContinue = 0) then begin
        //
        while (iContinue = 0) do begin
          // skip the folder spec entries
          if (TSR.Name = '.') OR (TSR.Name = '..') then begin
            iContinue := FindNext (TSR);
            continue;
          end;
          // recurse if subdir
          if ((TSR.Attr AND faDirectory) <> 0) then
            RecurseGen (cRelativePath + '\' + TSR.Name, cSAMMBaseName + TSR.Name);
          // otherwise, check for processeable (?) file
          cFileName := StrBefore ('.', ExtractFileName (TSR.Name));
          cExtension := UpperCase (StrAfter ('.', ExtractFileExt (TSR.Name)));
          if (cExtension = 'ZIF') then MakeEntries;
          //
          iContinue := FindNext (TSR);
        end;
        //
        FindClose (TSR);
        //
      end;
    finally
      CloseFile (fZED);
      if (iZEDEntries = 0) then DeleteFile (cZEDPath + cZEDFileName);
    end;
    //
  end;


////////////////////////////////////////////////////////////////////

begin
  cBasePath := IncludeTrailingPathDelimiter (GetCurrentDir);
  cRelativePath := 'Images';
  //
  cSAMMPath := cBasePath + 'SAMMS\';
    ForceDirectories (cSAMMPath);
  cZEDPath := cBasePath + 'ZEDS\';
    ForceDirectories (cZEDPath);
  cConfigPath := cBasePath + 'Config\';
    ForceDirectories (cConfigPath);
  //
  cDefImages := cConfigPath + 'DefImages.zcf';
  cDefSprites := cConfigPath + 'DefSprites.zcf';
  //
  AssignFile (fDefImages, cDefImages);
  Rewrite (fDefImages);
  WriteLn (fDefImages, ';-----------------------------------------------');
  WriteLn (fDefImages, '; Auto-GENERATED File, Modify at your own risk');
  WriteLn (fDefImages, ';-----------------------------------------------'#13#10);
  //
  AssignFile (fDefSprites, cDefSprites);
  Rewrite (fDefSprites);
  WriteLn (fDefSprites, ';-----------------------------------------------');
  WriteLn (fDefSprites, '; Auto-GENERATED File, Modify at your own risk');
  WriteLn (fDefSprites, ';-----------------------------------------------'#13#10);
  //
  try
    RecurseGen (cRelativePath);
  finally
    CloseFile (fDefImages);
    CloseFile (fDefSprites);
  end;
  //
end.
