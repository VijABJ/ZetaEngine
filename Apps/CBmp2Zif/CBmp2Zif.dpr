program CBmp2Zif;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  JclStrings,
  ZbBitmap;


  ////////////////////////////////////////////////////////////////////
  function StrSmartChop (AStr: String; ALimit: Integer): String;
  const
    CHOP_ELLIPSIS = '...';
    CHOP_FUDGE = Length (CHOP_ELLIPSIS);
  var
    iLen, iLeft, iRight: Integer;
  begin
    iLen := Length (AStr);
    if (iLen <= ALimit) OR (ALimit <= CHOP_FUDGE) then
      Result := AStr
    else begin
      Dec (ALimit, CHOP_FUDGE);
      iLeft := ALimit div 2;
      iRight := ALimit - iLeft;
      Result := StrLeft (AStr, iLeft) + CHOP_ELLIPSIS + StrRight (AStr, iRight);
    end;
  end;

  ////////////////////////////////////////////////////////////////////
  procedure DoConvert (AFileName: String);
  var
    theZIF: TZbBitmap32;
  begin
    WriteLn ('Converting: ', StrSmartChop (AFileName, 60), '---');
    theZIF := TZbBitmap32.Create;
    theZIF.LoadFromWinBitmap (AFileName);
    theZIF.WriteToFile (AFileName);
    theZIF.Free;
  end;

  ////////////////////////////////////////////////////////////////////
  procedure RecurseFolder (APath: String);
  var
    TSR: TSearchRec;
    iContinue: Integer;
    cFileName, cExtension: String;
  begin
    APath := IncludeTrailingPathDelimiter (APath);
    iContinue := FindFirst (APath + '*.*', faAnyFile, TSR);
    while (iContinue = 0) do begin
      // skip the folder spec entries
      if (TSR.Name = '.') OR (TSR.Name = '..') then begin
        iContinue := FindNext (TSR);
        continue;
      end;
      // recurse if subdir
      if ((TSR.Attr AND faDirectory) <> 0) then
        RecurseFolder (APath + TSR.Name)
      else begin
        // otherwise, check for processeable (?) file
        cFileName := StrBefore ('.', ExtractFileName (TSR.Name));
        cExtension := UpperCase (StrAfter ('.', ExtractFileExt (TSR.Name)));
        if (cExtension = 'BMP') then DoConvert (APath + TSR.Name);
      end;
      //
      iContinue := FindNext (TSR);
    end;
    FindClose (TSR);
  end;

begin
  RecurseFolder (GetCurrentDir);
end.
