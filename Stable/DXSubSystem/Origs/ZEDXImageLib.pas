{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXImageLib.PAS
              The Image Library class manages a volume of images,
              and a list of names with which to reference it.
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXImageLib.pas,v 1.3 2002/11/02 06:42:18 Vij Exp $
  $Log: ZEDXImageLib.pas,v $
  Revision 1.3  2002/11/02 06:42:18  Vij
  released theFile after loading so it won't take up memory
  disposed libraries properly as well

  Revision 1.2  2002/10/01 12:33:10  Vij
  Added code to support built-in Sprite definition file inside image volumes.

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXImageLib;

interface

uses
  Windows,
  Classes,
  SysUtils,
  DirectDraw,
  //
  ZbScriptable,
  ZbDoublelist,
  ZbBitmap,
  ZbStrIntf,
  ZbVirtualFS,
  //
  ZEDXCore,
  ZEDXImage;

const
  IMAGE_NAMES_FILE          = '/DefImages.zcf';
  IMAGE_NAMES_FILE_ALT      = '/Config/DefImages.zcf';
  SPRITE_NAMES_FILE         = '/DefSprites.zcf';
  SPRITE_NAMES_FILE_ALT     = '/Config/DefSprites.zcf';

type
  TZEImageNames = class (TObject)
  private
    FNames: TZbDoubleList;
    FAliases: TZbDoubleList;
    //
    procedure ParseStringEnum (Items: IZbEnumStringList);
  protected
    function AliasToName (AAlias: string): string;
    function NameToPath (AName: string): string;
    function Translate (AIdentifier: string): string;
    function Canonicalize (AIdentifier: string): string;
    //
    function GetAliasCount: integer;
    function GetAliasByIndex (iIndex: integer): string;
    function GetNamesCount: integer;
    function GetNameByIndex (iIndex: integer): string;
  public
    constructor Create (Items: IZbEnumStringList); virtual;
    destructor Destroy; override;
    //
    procedure Clear;
    procedure LoadFromStrEnum (Items: IZbEnumStringList);
    procedure AddAlias (AAlias, AName: string);
    procedure AddName (AName, AFilename: string;
      AIsTransparent: boolean = true; AIsGridded: boolean = true);
    //
    procedure DeleteAlias (AAlias: string);
    procedure DeleteName (AName: string);
    //
    function GetProps (AName: string; var ATransparent, AIsGridded: boolean): boolean;
    function IdNameInUse (AName: string): boolean;
    //
    property AliasList [AAlias: string]: string read AliasToName;
    property NamesList [AName: string]: string read NameToPath;
    property IdList [AIdentifier: string]: string read Translate; default;
    property CanonNames [AName: string]: string read Canonicalize;
    //
    property AliasCount: integer read GetAliasCount;
    property AliasListA [iIndex: integer]: string read GetAliasByIndex;
    property NamesCount: integer read GetNamesCount;
    property NamesListA [iIndex: integer]: string read GetNameByIndex;
  end;

  TZEImageLibrary = class (TObject)
  private
    FImageNames: TZEImageNames;
    FImageSource: TZbStandardVolume;
    FImageCache: TZbDoubleList;
  protected
    function GetByName (AName: string): TZEImage;
  public
    constructor Create (AImageSource: TZbStandardVolume; StrList: TStrings); virtual;
    destructor Destroy; override;
    //
    procedure ClearCache;
    procedure RestoreImages;
    //
    property Source: TZbStandardVolume read FImageSource;
    property ImageByName [AName: string]: TZEImage read GetByName; default;
  end;

  TZEImageManager = class (TObject)
  private
    FLibraries: TList;
  protected
    function GetLibraryCount: integer;
    function GetLibrary (iIndex: integer): TZEImageLibrary;
    function GetByName (AName: string): TZEImage;
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure LoadLibrary (AImageSource: TZbStandardVolume; StrList: TStrings);
    procedure ClearCache;
    procedure RestoreImages;
    //
    property LibraryCount: integer read GetLibraryCount;
    property Libraries [iIndex: integer]: TZEImageLibrary read GetLibrary;
    property ImageByName [AName: string]: TZEImage read GetByName; default;
  end;


implementation

uses
  ZbStringUtils;
  

{ Support Routines for the Alias/Names List }

//////////////////////////////////////////////////////////////////////////////
type
  PZE_ImageDescriptor = ^TZEImageDescriptor;
  TZEImageDescriptor = record
    pFilename: PChar;
    bIsTransparent: boolean;
    bIsGridded: boolean;
  end;

//////////////////////////////////////////////////////////////////////////////
function __ImageDescCreate (AFilename: PChar; AIsTransparent,
  AIsGridded: boolean): PZE_ImageDescriptor;
var
  Descriptor: PZE_ImageDescriptor;
begin
  try
    New (Descriptor);
    with Descriptor^ do
      begin
        pFilename := StrNew (AFilename);
        bIsTransparent := AIsTransparent;
        bIsGridded := AIsGridded;
      end;
    //
    Result := Descriptor;
  except
    Result := NIL;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
procedure __ImageDescDispose (aData: Pointer);
var
  Descriptor: PZE_ImageDescriptor absolute aData;
begin
  try
    StrDispose (Descriptor.pFilename);
    Dispose (Descriptor);
  except
  end;
end;

{ TZEImageNames }

//////////////////////////////////////////////////////////////////////////////
constructor TZEImageNames.Create (Items: IZbEnumStringList);
begin
  inherited Create;
  //
  FNames := TZbDoubleList.Create (TRUE);
  FNames.DisposeProc := __ImageDescDispose;
  FNames.Sorted := TRUE;
  //
  FAliases := TZbDoubleList.Create (TRUE);
  FAliases.DisposeProc := __PCharFree;
  FAliases.Sorted := TRUE;
  //
  ParseStringEnum (Items);
end;

//////////////////////////////////////////////////////////////////////////////
destructor TZEImageNames.Destroy;
begin
  FNames.Free;
  FAliases.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageNames.ParseStringEnum (Items: IZbEnumStringList);
var
  cData: string;
  cParam1, cParam2: string;
  bParam1, bParam2: boolean;
  bIsAlias: boolean;
begin
  if (Items = NIL) then Exit;
  //
  cData := Items.First;
  while (cData <> '') do begin
    SplitImageSpec (cData, cParam1, cParam2, bParam1, bParam2, bIsAlias);
    if (bIsAlias) then
      AddAlias (cParam1, cParam2)
      else AddName (cParam1, cParam2, bParam1, bParam2);
    //
    cData := Items.Next;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.AliasToName (AAlias: string): string;
begin
  Result := PChar (FAliases.Get (AAlias));
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.NameToPath (AName: string): string;
var
  Descriptor: PZE_ImageDescriptor;
begin
  Descriptor := PZE_ImageDescriptor (FNames.Get (AName));
  if (Descriptor = NIL) then
    Result := ''
    else Result := String (Descriptor.pFilename);
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.Translate (AIdentifier: string): string;
begin
  Result := NameToPath (AIdentifier);
  if (Result = '') then begin
    Result := AliasToName (AIdentifier);
    if (Result <> '') then Result := NameToPath (Result);
  end;
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.Canonicalize (AIdentifier: string): string;
begin
  Result := NameToPath (AIdentifier);
  if (Result = '') then
    Result := AliasToName (AIdentifier)
    else Result := AIdentifier;
  //
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.GetAliasCount: integer;
begin
  Result := FAliases.Count;
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.GetAliasByIndex (iIndex: integer): string;
begin
  Result := FAliases.GetName (iIndex);
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.GetNamesCount: integer;
begin
  Result := FNames.Count;
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.GetNameByIndex (iIndex: integer): string;
begin
  Result := FNames.GetName (iIndex);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageNames.Clear;
begin
  FNames.Clear;
  FAliases.Clear;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageNames.LoadFromStrEnum (Items: IZbEnumStringList);
begin
  if (Items = NIL) then Exit;
  Clear;
  ParseStringEnum (Items);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageNames.AddAlias (AAlias, AName: string);
begin
  FAliases.Add (AAlias, StrNew (PChar (AName)));
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageNames.AddName (AName, AFilename: string;
  AIsTransparent, AIsGridded: boolean);
var
  Descriptor: PZE_ImageDescriptor;
begin
  Descriptor := __ImageDescCreate (PChar (AFilename), AIsTransparent, AIsGridded);
  if (Descriptor <> NIL) then FNames.Add (AName, Pointer (Descriptor));
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageNames.DeleteAlias (AAlias: string);
begin
  FAliases.Delete (AAlias);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageNames.DeleteName (AName: string);
begin
  FNames.Delete (AName);
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.GetProps (AName: string; var ATransparent, AIsGridded: boolean): boolean;
var
  Descriptor: PZE_ImageDescriptor;
begin
  Descriptor := PZE_ImageDescriptor (FNames.Get (AName));
  if (Descriptor <> NIL) then begin
    ATransparent := Descriptor.bIsTransparent;
    AIsGridded := Descriptor.bIsGridded;
    Result := TRUE;
  end else
    Result := FALSE;
  //
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageNames.IdNameInUse (AName: string): boolean;
var
  lpTemp: Pointer;
begin
  Result := TRUE;
  //
  lpTemp := FNames.Get (AName);
  if (lpTemp <> NIL) then Exit;
  //
  lpTemp := FAliases.Get (AName);
  if (lpTemp <> NIL) then Exit;
  //
  Result := FALSE;
end;

{ TZEImageLibrary }

//////////////////////////////////////////////////////////////////////////////
procedure __FreeImage (AData: Pointer);
begin
  if (AData <> NIL) then
    try TZEImage (AData).Free; except end;
end;

//////////////////////////////////////////////////////////////////////////////
constructor TZEImageLibrary.Create (AImageSource: TZbStandardVolume; StrList: TStrings);
var
  theFile: TZbFSFile;
  theStream: TStream;
  theStrList, theFinalList: TStrings;
  lpData: PChar;
  iIndex: integer;
begin
  inherited Create;
  //
  FImageSource := AImageSource;
  FImageCache := TZbDoubleList.Create (TRUE);
  FImageCache.DisposeProc := __FreeImage;
  FImageCache.Sorted := TRUE;
  //
  theStream := TMemoryStream.Create;
  theStrList := TStringList.Create;
  theFinalList := TStringList.Create;
  try
    //
    // load the image configuration list: DefImages.zcf
    //
    theFile := FImageSource.GetFile (IMAGE_NAMES_FILE);
    if (theFile = NIL) then theFile := FImageSource.GetFile (IMAGE_NAMES_FILE_ALT);
    if (theFile = NIL) then Exit;
    lpData := PChar (theFile.Data);
    //
    theStream.Write (lpData^, theFile.Size);
    theStream.Position := 0;
    theStrList.LoadFromStream (theStream);
    //
    for iIndex := 0 to Pred (theStrList.Count) do begin
      theStrList [iIndex] := Trim (theStrList [iIndex]);
      if (theStrList [iIndex] <> '') AND (theStrList [iIndex][1] <> ';') then
        theFinalList.Add (theStrList [iIndex]);
    end;
    //
    FImageNames := TZEImageNames.Create ((TZbEnumStringList.Create (theFinalList) as IZbEnumStringList));
    //
    // load the sprite configuration list: DefSprites.zcf
    //
    theFile := FImageSource.GetFile (SPRITE_NAMES_FILE);
    if (theFile = NIL) then theFile := FImageSource.GetFile (SPRITE_NAMES_FILE_ALT);
    if (theFile = NIL) then Exit;
    lpData := PChar (theFile.Data);
    //
    theStream.Write (lpData^, theFile.Size);
    theStream.Position := 0;
    theStrList.Clear;
    theStrList.LoadFromStream (theStream);
    //
    for iIndex := 0 to Pred (theStrList.Count) do begin
      theStrList [iIndex] := Trim (theStrList [iIndex]);
      if (theStrList [iIndex] <> '') AND (theStrList [iIndex][1] <> ';') then
        StrList.Add (theStrList [iIndex]);
    end;
    //
  finally
    theStrList.Free;
    theFinalList.Free;
    theStream.Free;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
destructor TZEImageLibrary.Destroy;
begin
  FImageCache.Free;
  FImageNames.Free;
  FImageSource.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageLibrary.GetByName (AName: string): TZEImage;
var
  cPath: string;
  theImage: TZbBitmap32;
  theFile: TZbFSFile;
  bTransparent, bGridded: boolean;
begin
  // make sure the image is canonicallized; that is, aliases
  // are translated into proper names first!
  AName := FImageNames.Canonicalize (AName);
  //
  // first, try the cache if the image had been constructed before...
  Result := TZEImage (FImageCache.Get (AName));
  if (Result <> NIL) then Exit;
  //
  // translate this name, and load the file off the source volume...
  // bug out now if the file is not found
  cPath := FImageNames [AName];
  theFile := FImageSource.GetFile (cPath);
  if (theFile = NIL) then Exit;
  //
  // create a stand-in, device-independent image first
  theImage := TZbBitmap32.Create;
  theImage.LoadFromBuffer (theFile.Data);
  theFile.Release;
  if (theImage.Height <= 0) OR (theImage.Width <= 0) then begin
    theImage.Free;
    Exit;
  end;
  //
  // everything checked out so far, create the image will return
  FImageNames.GetProps (AName, bTransparent, bGridded);
  if (NOT bGridded) then
    Result := TZEImage.Create (theImage, bTransparent)
    else Result := TZEGridImage.Create  (theImage, bTransparent);
  //
  // if we have an image to return, cache it!
  if (Result <> NIL) then FImageCache.Add (AName, Pointer (Result));
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageLibrary.ClearCache;
begin
  FImageCache.Clear;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageLibrary.RestoreImages;
var
  iIndex: integer;
  theImage: TZEImage;
begin
  for iIndex := 0 to Pred (FImageCache.Count) do begin
    theImage := TZEImage (FImageCache.Get (iIndex));
    if (theImage <> NIL) then theImage.Restore;
  end;
end;

{ TZEImageManager }

//////////////////////////////////////////////////////////////////////////////
constructor TZEImageManager.Create;
begin
  inherited;
  FLibraries := TList.Create;
end;

//////////////////////////////////////////////////////////////////////////////
destructor TZEImageManager.Destroy;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FLibraries.Count) do begin
    TZEImageLibrary (FLibraries [iIndex]).Free;
    FLibraries [iIndex] := NIL;
  end;
  FreeAndNIL (FLibraries);
  inherited
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageManager.GetLibraryCount: integer;
begin
  Result := FLibraries.Count;
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageManager.GetLibrary (iIndex: integer): TZEImageLibrary;
begin
  if (iIndex < 0) OR (iIndex >= FLibraries.Count) then
    Result := NIL
    else Result := TZEImageLibrary (FLibraries [iIndex]);
end;

//////////////////////////////////////////////////////////////////////////////
function TZEImageManager.GetByName (AName: string): TZEImage;
var
  iIndex: integer;
begin
  Result := NIL;
  for iIndex := 0 to Pred (FLibraries.Count) do begin
    Result := TZEImageLibrary (FLibraries [iIndex]) [AName];
    if (Result <> NIL) then break;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageManager.LoadLibrary (AImageSource: TZbStandardVolume; StrList: TStrings);
var
  ImageLib: TZEImageLibrary;
begin
  ImageLib := TZEImageLibrary.Create (AImageSource, StrList);
  if (ImageLib <> NIL) then FLibraries.Add (Pointer (ImageLib));
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageManager.ClearCache;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FLibraries.Count) do
    TZEImageLibrary (FLibraries [iIndex]).ClearCache;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEImageManager.RestoreImages;
var
  iIndex: integer;
begin
  for iIndex := 0 to Pred (FLibraries.Count) do
    TZEImageLibrary (FLibraries [iIndex]).RestoreImages;
end;


end.

