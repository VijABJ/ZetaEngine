program WindowingSystem;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Types,
  Windows,
  JclStrings,
  JclGraphics,
  JclGraphUtils,
  //
  ZEWSBase in '..\Windowing\ZEWSBase.pas',
  ZEWSButtons in '..\Windowing\ZEWSButtons.pas',
  ZEWSDefines in '..\Windowing\ZEWSDefines.pas',
  ZEWSDialogs in '..\Windowing\ZEWSDialogs.pas',
  ZEWSLineEdit in '..\Windowing\ZEWSLineEdit.pas',
  ZEWSMisc in '..\Windowing\ZEWSMisc.pas',
  ZEWSStandard in '..\Windowing\ZEWSStandard.pas',
  ZEWSSupport in '..\Windowing\ZEWSSupport.pas';


  (* TESTING FOR 3D TO 2D COORDINATES IN ISOMETRIC SYSTEM *)
  (*
const
  TileSize: TPoint = (X: 64; Y: 32);
  MapSize: TPoint = (X:2; Y:2);
  HalfTile: TPoint = (X:32; Y:16);

type
  TPointF = record
    X, Y: Double;
  end;

var
  MaxCoord, MapAnchor: TPoint;
  X, {Y,} Z: Integer;

  function CalcAnchor (pMapSize: TPoint): TPoint;
  begin
    Result.X := 0; //(pMapSize.Y * HalfTile.X) * -1;
    Result.Y := 0;
  end;

  function From3D (X, Y, Z: Double; Anchor: TPoint): TPointF;
  begin
    Result.X := Anchor.X + (((X + (MapSize.Y - Z)) / 2) * TileSize.X);
    Result.Y := Anchor.Y + (((X + Z) / 2) * TileSize.Y); // correct!
  end;

  procedure WritePoint (P: TPoint; Name: String = '');
  begin
    if (Name <> '') then Write (Name, '=');
    WriteLn ('(', P.X, ',', P.Y, ')');
  end;

  procedure DoTest (X, Y, Z: Double);
  var
    PP: TPointF;
  begin
    PP := From3D (X, Y, Z, MapAnchor);
    WriteLn ('3D=(', + X:5:2, ',', Y:5:2, ',', Z:5:2, ') ==> (',
      PP.X:5:2, ',', PP.Y:5:2, ')');
  end;



begin
  MaxCoord := Point (Pred (MapSize.X), Pred (MapSize.Y));
  MapAnchor := CalcAnchor (MapSize);
  WritePoint (MapSize, 'MapSize');
  WritePoint (MapAnchor, 'MapAnchor');

  //for X := 0 to Pred (MapSize.X) do
  //  for Z := 0 to Pred (MapSize.Y) do
  //    DoTest (X, 0, Z);

  DoTest (0, 0, 0);
  DoTest (0, 0, 0.5);
  DoTest (0.5, 0, 0.5);
  DoTest (0, 0, MapSize.Y);
  DoTest (MapSize.X, 0, 0);
  DoTest (0, 0, 1);

  ReadLn;
end.

*)

var
  FileName: String;
  TSR: TSearchRec;
  FindResult: Integer;
  ImageDirPrefix: String = '/Sprites/';
  SpriteNamePrefix: String = 'DecorImage/';

  fImage, fSprite, fSoundCfg: Text;
  bmpTemp: TJclBitmap32;


  procedure ProcessFolder (theSprite, theFolder: String);
  var
    Index, NumFrames, X: Integer;
    BorderColor, ScanColor: TColor32;
    theFile, theVirtName: String;

  const
    DirName: array [1..8] of string = ('N','NE','E','SE','S','SW','W','NW');
  begin
    for Index := 1 to 8 do begin
      theFile := theSprite + '\' + theFolder + '\' + DirName [Index] + '.BMP';
      bmpTemp.LoadFromFile (theFile);
      //
      BorderColor := bmpTemp.GetPixelB(0, 0);
      NumFrames := 0;
      for X := 1 to Pred (bmpTemp.Width) do begin
        ScanColor := bmpTemp.GetPixelB(X, 1);
        if (ScanColor = BorderColor) then Inc (NumFrames);
      end;
      //
      theVirtName := theSprite + '/' + theFolder + '/' + DirName [Index];
      WriteLn (fImage, theVirtName, '=', ImageDirPrefix, theVirtName, '.ZIF,1,1');
      WriteLn (fSprite, SpriteNamePrefix, theVirtName, '=',
        theVirtName, ',0,', Pred (NumFrames));
    end;

  end;

  procedure ProcessSprite (theSprite: String);
  var
    SR: TSearchRec;
    Ret: Integer;
  begin
    WriteLn ('Processing ', theSprite, '...');
    WriteLn (fImage);
    WriteLn (fImage, '; <<<<<<<<<<<------ ', theSprite, '------>>>>>>>>>>>');
    WriteLn (fSprite);
    WriteLn (fSprite, '; <<<<<<<<<<<------ ', theSprite, '------>>>>>>>>>>>');
    //
    Ret := FindFirst (theSprite + '\*.*', faDirectory, SR);
    while (Ret = 0) do begin
      if (SR.Name <> '.') AND (SR.Name <> '..') then begin
        WriteLn (fSoundCfg, theSprite, SR.Name, '=', theSprite, SR.Name, '.WAV');
        ProcessFolder (theSprite, SR.Name);
      end;
      //
      Ret := FindNext (SR);
    end;
  end;


begin
  AssignFile (fImage, 'Image.CFG');
  Rewrite (fImage);
  AssignFile (fSprite, 'Sprites.CFG');
  Rewrite (fSprite);
  AssignFile (fSoundCfg, 'Sound.CFG');
  Rewrite (fSoundCfg);
  bmpTemp := TJclBitmap32.Create;
  //
  FindResult := FindFirst ('*.*', faDirectory, TSR);
  while (FindResult = 0) do begin
    if (TSR.Name <> '.') AND (TSR.Name <> '..') AND ((TSR.Attr AND faDirectory) <> 0) then
      ProcessSprite (TSR.Name);
    //
    FindResult := FindNext (TSR);
  end;
  //
  bmpTemp.Free;
  CloseFile (fSoundCFG);
  CloseFile (fSprite);
  CloseFile (fImage);
end.

