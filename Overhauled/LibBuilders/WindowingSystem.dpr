program WindowingSystem;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  JclStrings,
  ZEWSBase in '..\Windowing\ZEWSBase.pas',
  ZEWSButtons in '..\Windowing\ZEWSButtons.pas',
  ZEWSDefines in '..\Windowing\ZEWSDefines.pas',
  ZEWSDialogs in '..\Windowing\ZEWSDialogs.pas',
  ZEWSLineEdit in '..\Windowing\ZEWSLineEdit.pas',
  ZEWSMisc in '..\Windowing\ZEWSMisc.pas',
  ZEWSStandard in '..\Windowing\ZEWSStandard.pas',
  ZEWSSupport in '..\Windowing\ZEWSSupport.pas';

var
  PathToProcess: String;
  TSR: TSearchRec;
  RetVal: Integer;
  cNameOnly: String;
  f: File;

begin
  PathToProcess := 'D:\projects\src\Thesis\BeavisNButthead\VBGame\Text\';
  RetVal := FindFirst (PathToProcess + '*Questions', faAnyFile, TSR);

  if (RetVal = 0) then begin
    while (RetVal = 0) do begin
      cNameOnly := System.Copy (TSR.Name, 1, Length (TSR.Name) - 1);
      if (cNameOnly <> TSR.Name) then begin
        AssignFile (f, PathToProcess + TSR.Name);
        Rename (f, PathToProcess + cNameOnly);
      end;
      RetVal := FindNext (TSR);
    end;
    FindClose (TSR);
  end;

  { TODO -oUser -cConsole Main : Insert code here }
end.
