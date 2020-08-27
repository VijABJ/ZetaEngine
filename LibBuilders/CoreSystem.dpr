program CoreSystem;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  JclStrings,
  ZZConstants in '..\Core\ZZConstants.pas',
  ZZEGameScreens in '..\Core\ZZEGameScreens.pas',
  ZZEGameWindow in '..\Core\ZZEGameWindow.pas',
  ZZESupport in '..\Core\ZZESupport.pas',
  ZZETools in '..\Core\ZZETools.pas',
  ZZECore in '..\Core\ZZECore.pas',
  ZZEMap in '..\MapEngine\ZZEMap.pas',
  ZZEViewMap in '..\MapEngine\ZZEViewMap.pas',
  ZZEWorld in '..\MapEngine\ZZEWorld.pas',
  ZZESAMM in '..\MapEngine\ZZESAMM.pas',
  ZZEWorldImpl in '..\MapEngine\ZZEWorldImpl.pas',
  ZZEWorldIntf in '..\MapEngine\ZZEWorldIntf.pas';


var
  fIntro, fSprites, fImages: Text;
  Skip: Integer = 40;
  IniSectionName: String = 'INTRO';
  Count, Max: Integer;

  ImagePrefix: String = 'INTRO/';
  FilePathPrefix: String = '/Images/INTRO';
  SpritePrefix: String = 'CutScene/INTRO';

  ///////////////////////////////////////----------------------------------
  function PaddedNumber (Number: Integer; Padding: Integer = 3): String;
  begin
    Result := IntToStr (Number);
    while (Length (Result) < Padding) do Result := '0' + Result;
  end;

  ///////////////////////////////////////----------------------------------
  function INI_NAME (Number: Integer): String;
  begin
    Result := IniSectionName + PaddedNumber (Number);
  end;

  ///////////////////////////////////////----------------------------------
  function FILE_NAME (Number: Integer): String;
  begin
    Result := FilePathPrefix + PaddedNumber (Number) + '.ZIF,0,0';
  end;

  ///////////////////////////////////////----------------------------------
  function IMAGE_NAME (Number: Integer): String;
  begin
    Result := ImagePrefix + PaddedNumber (Number);
  end;

  ///////////////////////////////////////----------------------------------
  function SPRITE_NAME (Number: Integer): String;
  begin
    Result := SpritePrefix + PaddedNumber (Number);
  end;

  ///////////////////////////////////////----------------------------------
  procedure WriteMain;
  begin
    WriteLn (fIntro);
    WriteLn (fIntro, '[MAIN]');
    WriteLn (fIntro, 'Caption=');
    WriteLn (fIntro, 'Delay=10');
    WriteLn (fIntro, 'Next=', INI_NAME (1));
    WriteLn (fIntro, ';Music=<PlaceMusicNameHere>');
    WriteLn (fIntro);
  end;

  ///////////////////////////////////////----------------------------------
  procedure WriteSection (SectionNumber: Integer; HasNext: Boolean = TRUE);
  begin
    WriteLn (fIntro, '[', INI_NAME (SectionNumber), ']');
    if (HasNext) then WriteLn (fIntro, 'Next=', INI_NAME (Succ (SectionNumber)));
    WriteLn (fIntro, 'Image=', INI_NAME (SectionNumber));
    WriteLn (fIntro, 'Delay=', Skip);
    WriteLn (fIntro);
  end;


begin
  { TODO -oUser -cConsole Main : Insert code here }

  AssignFile (fImages, 'DefImages.zcf');
  Rewrite (fImages);
  AssignFile (fSprites, 'DefSprites.zcf');
  Rewrite (fSprites);
  //
  AssignFile (fIntro, 'Intro.INI');
  Rewrite (fIntro);
  WriteMain;
  Max := 152;
  for Count := 1 to Max do begin
    WriteSection (Count, Count <> Max);
    WriteLn (fImages, IMAGE_NAME (Count), '=', FILE_NAME (Count));
    WriteLn (fSprites, SPRITE_NAME (Count), '=', IMAGE_NAME (Count));
  end;
  CloseFile (fIntro);
  //
  CloseFile (fSprites);
  CloseFile (fImages);

end.

