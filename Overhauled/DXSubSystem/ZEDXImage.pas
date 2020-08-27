{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXImage.PAS
              Contains classes to contain and load images, as well
              as one to contain and manage a list of such image
              containers.
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXImage.pas,v 1.1.1.1 2002/09/11 21:08:54 Vij Exp $
  $Log: ZEDXImage.pas,v $
  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXImage;

interface

uses
  Windows,
  Classes,
  SysUtils,
  DirectDraw,
  ZbScriptable,
  ZbDoublelist,
  ZbBitmap,
  ZEDXCore;

type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  (* Basic Image Source Class *)
  TZEImage = class (TZbNamedClass)
  private
    FDXSurface: IDirectDrawSurface7;
    FZbImage: TZbBitmap32;
    FWidth: integer;
    FHeight: integer;
    FBounds: TRect;
    FFrameCount: integer;
    FActiveFrame: integer;
    FIsTransparent: boolean;
    FTransparentColor: TColorRef;
  protected
    function RequestSurface (DimX, DimY: integer;
      var DXSurfDesc: TDDSurfaceDesc2; var DXSurface: IDirectDrawSurface7): boolean;
    procedure WriteBitmap32ToSurface;
    procedure CreateFromBitmap32 (ZbImage: TZbBitmap32);
    procedure CreateFromImage (Source: TZEImage);
    function GetDrawFrame: TRect; virtual;
    function GetDrawWidth: integer; virtual;
    function GetDrawHeight: integer; virtual;
    function GetNumFrames: integer;
    function IsMultiFrames: boolean;
    procedure SetActiveFrame (iWhichFrame: integer);
    function ValidFrameNumber (iWhatFrame: integer): boolean;
    procedure LoadActiveFrame; virtual;
    function  IsValid: boolean;
    procedure SetTransparent (bToggle: boolean);
    procedure MakeTransparent; virtual;
    procedure SetColorKey (crColorKey: TColorRef);
    //
    procedure CommonInit; virtual;
    procedure AfterCreate; virtual;
  public
    {$WARNINGS OFF}
    constructor Create (ZbImage: TZbBitmap32; ATransparent: boolean = TRUE); overload; virtual;
    constructor Create (AFilename: string; ATransparent: boolean = TRUE); overload; virtual;
    constructor Create (Source: TZEImage); overload; virtual;
    destructor Destroy; override;
    {$WARNINGS ON}
    //
    function Restore: boolean; virtual;
    procedure NextFrame;
    procedure PreviousFrame;
    function IsOpaque (iX, iY: integer): boolean;
    function DuplicateFromCurrentFrame: TZEImage;
    procedure CopyCurrentFrame (Source: TZEImage);
    procedure ApplyLight (AlphaLight, RedLight, GreenLight, BlueLight: DWORD);
    // properties
    property Surface: IDirectDrawSurface7 read FDXSurface;
    property Bounds: TRect read FBounds;
    property Width: integer  read FWidth;
    property Height: integer read FHeight;
    property DrawWidth: integer read GetDrawWidth;
    property DrawHeight: integer read GetDrawHeight;
    property DrawFrame: TRect read GetDrawFrame;
    property FrameCount: integer read GetNumFrames;
    property MultiFrames: boolean read IsMultiFrames;
    property ActiveFrame: integer read FActiveFrame write SetActiveFrame;
    property Valid: boolean read IsValid;
    property Transparent: boolean read FIsTransparent write SetTransparent;
    property ColorKey: TColorRef read FTransparentColor write SetColorKey;
    property Name;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  (* Image containing multiple frames bounded by grids *)
  TZEGridImage = class (TZEImage)
  private
    FRects: PRect;
    FDrawWidth: integer;
    FDrawHeight: integer;
    FDrawFrame: TRect;
    //
    procedure CreateRectsList;
    procedure FreeRectsList;
  protected
    procedure CommonInit; override;
    procedure AfterCreate; override;
  protected
    function GetDrawFrame: TRect; override;
    function GetDrawWidth: integer; override;
    function GetDrawHeight: integer; override;
    procedure LoadActiveFrame; override;
  public
    destructor Destroy; override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  TZEImageList = class (TObject)
  private
    FAliases: TZbDoubleList;
    FImages: TZbDoubleList;
    FPathToImages: string;
    FUseAliases: boolean;
  protected
    function PreloadImage (AName, AFilename: PChar; ATransparent: boolean;
      AGridded: boolean = true): TZEImage;
    //
    function GetImage (pSource: pointer): TZEImage;
    function GetImageByIndex (iIndex: integer): TZEImage;
    function GetImageByName (AName: PChar): TZEImage;
    function GetName (iIndex: integer): string;
    function TranslateAliasToName (AAlias: string): PChar;
    function RetrieveByName (AName: string): TZEImage;
    //
    procedure LoadConfigFile (AConfigFile: string);
  public
    constructor Create (APathToImages: string; AConfigFile: string = 'Images.cfg'); virtual;
    destructor Destroy; override;
    //
    procedure AddAlias (AAlias, AName: string);
    procedure AddImage (AName, AFilename: string;
      AIsTransparent: boolean = true; AIsGridded: boolean = true);
    // properties
    property UseAliases: boolean read FUseAliases write FUseAliases;
    property Image [iIndex: integer]: TZEImage read GetImageByIndex;
    property Name [iIndex: integer]: string read GetName;
    property ImageByName [AName: string]: TZEImage read RetrieveByName; default;
  end;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  function SplitImageSpec (cSpecLine: string; var cName, cImageName: string;
          var bTransparent, bGridded, bIsAlias: boolean): boolean;

  // *******************************************************************
  // third-party derived.  original routine to perform alpha-blending
  // downloaded from gamedev.net.  there was only one routine.  the
  // other variations below were extrapolated and tested.
  procedure PerformAlpha (ALPHA: DWORD;
          imgSource: TZEImage; rSrcRect: TRect;
          imgDest: TZEImage; pDestLoc: TPoint);

  procedure PerformAlpha2 (ALPHA: DWORD;
          imgSource: TZEImage; rSrcRect: TRect;
          destSurface: IDirectDrawSurface7; pDestLoc: TPoint);

  procedure PerformAlphaEx (ALPHA: DWORD;
          srcSurface: IDirectDrawSurface7; rSrcRect: TRect; srcColorKey: DWORD;
          destSurface: IDirectDrawSurface7; pDestLoc: TPoint);

  procedure PerformAlphaShade (ALPHA: DWORD; ShadeRed, ShadeGreen, ShadeBlue: DWORD;
          destSurface: IDirectDrawSurface7; rDestRect: TRect);

  procedure PerformAlphaShade2 (ALPHA: DWORD; ShadeRed, ShadeGreen, ShadeBlue: DWORD;
          destSurface: IDirectDrawSurface7; rDestRect: TRect; destColorKey: DWORD);



implementation

uses
  Math,
  StrUtils,
  JclStrings,
  //
  ZbStringUtils,
  ZbUtils,
  ZbStrIntf,
  ZbConfigManager,
  ZbLists,
  //
  ZEDXUtils;


         (*---------------------------------------*
          * TZEImage - image container base class *
          *---------------------------------------*)

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.CommonInit;
begin
  // init name and filename
  Name := '';
  // init vars for multiframe images
  FFrameCount     := 0;
  FActiveFrame   := 0;
  FIsTransparent := false;
  // blank surface, for now
  FDXSurface := NIL;
  FZbImage := NIL;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEImage.Create (ZbImage: TZbBitmap32; ATransparent: boolean);
begin
  inherited Create;
  CommonInit;

  // create our surface from this bitmap32
  CreateFromBitmap32 (ZbImage);
  FFrameCount := 1;

  // update transparency flag
  Transparent := ATransparent;
  AfterCreate;
end;


//////////////////////////////////////////////////////////////////////////
// accepts filename to a bitmap file, or to a ZIF file
constructor TZEImage.Create (AFilename: string; ATransparent: boolean);
var
  cExtension: string;
  ZbImage: TZbBitmap32;
begin
  inherited Create;
  CommonInit;

  // create the internal bitmap
  ZbImage := TZbBitmap32.Create;

  // load the file onto the memory bitmap.  if extension is BMP,
  // it's a bitmap, otherwise, it's our custom bitmap
  cExtension := ExtractFileExt (AFileName);
  if ((cExtension <> '') AND (StrIComp (PChar (cExtension), '.BMP') = 0)) then
    ZbImage.LoadFromWinBitmap (AFilename)
    else ZbImage.LoadFromFile (AFilename);

  // create our surface from this bitmap32
  CreateFromBitmap32 (ZbImage);
  FFrameCount := 1;

  // update transparency flag
  Transparent := ATransparent;
  AfterCreate;
end;

//////////////////////////////////////////////////////////////////////////
constructor TZEImage.Create (Source: TZEImage);
begin
  inherited Create;
  CommonInit;
  //
  CreateFromImage (Source);
  AfterCreate;
end;

//////////////////////////////////////////////////////////////////////////
// disposes of the filename, then calls the inherited destructor
destructor TZEImage.Destroy;
begin
  FZbImage.Free;
  FDXSurface := NIL;
  inherited;
end;

function PByteInc (P: Pointer; Delta: Cardinal = 1): PByte;
begin
  Result := PByte (Cardinal (P) + Delta);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.WriteBitmap32ToSurface;
var
  DXSurfDesc: TDDSurfaceDesc2;
  pBuffer: PByte;
  bufPad: integer;
  X, Y: integer;
  RGBQuad: TZbRGBQuad;
  dwPixel: DWORD;

begin
  // exit if no surface
  if (FDXSurface = NIL) OR (FZbImage = NIL) then Exit;

  // lock the surface
  ZeroMemory (@DXSurfDesc, SizeOf (DXSurfDesc));
  DXSurfDesc.dwSize := SizeOf (DXSurfDesc);
  if (FAILED (FDXSurface.Lock (NIL, DXSurfDesc, DDLOCK_WAIT, 0))) then Exit;

  // get a pointer to the surface
  pBuffer := PByte (DXSurfDesc.lpSurface);
  bufPad := DXSurfDesc.lPitch - Integer ((4 * FZbImage.Width));

  // write out the pixels to the surface
  for Y := 0 to Pred (Height) do begin
    for X := 0 to Pred (Width) do begin
      RGBQuad := FZbImage [Cardinal (X), Cardinal (Y)];
      with RGBQuad do begin
        dwPixel := MakeCanonicalPixel32 (Red, Green, Blue, Alpha);
        PDWord (pBuffer)^ := dwPixel;
        pBuffer := PByteInc (pBuffer, SizeOf (DWORD));
      end;
      //
    end;
    pBuffer := PByteInc (pBuffer, bufPad);
  end;

  // unlock the surface now
  FDXSurface.Unlock (NIL);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.CreateFromBitmap32 (ZbImage: TZbBitmap32);
var
  DXSurfDesc: TDDSurfaceDesc2;
  DXSurface: IDirectDrawSurface7;
begin
  // blank surface, for now
  FDXSurface := NIL;
  FZbImage := NIL;

  // nothing to do if NIL image
  if (ZbImage = NIL) then Exit;
  if (NOT RequestSurface (ZbImage.Width, ZbImage.Height, DXSurfDesc, DXSurface)) then Exit;

  // set the dimensions and bounds
  FWidth := ZbImage.Width;
  FHeight := ZbImage.Height;
  FBounds   := Rect(0, 0, ZbImage.Width, ZbImage.Height);

  // set our surface and image
  FDXSurface := DXSurface;
  FZbImage := ZbImage;

  // write out the bitmap32 to our DX Surface
  WriteBitmap32ToSurface;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.AfterCreate;
begin
end;

//////////////////////////////////////////////////////////////////////////
function TZEImage.RequestSurface (DimX, DimY: integer;
  var DXSurfDesc: TDDSurfaceDesc2; var DXSurface: IDirectDrawSurface7): boolean;
var
  HR: hResult;
begin
  Result := false;
  //
  if (DimX = 0) OR (DimY = 0) then Exit;

  // Set up surface description.
  ZeroMemory (@DXSurfDesc, SizeOf (DXSurfDesc));
  with DXSurfDesc do begin
    dwSize  := SizeOf (DXSurfDesc);
    dwFlags := DDSD_CAPS or DDSD_WIDTH or DDSD_HEIGHT;
    dwWidth  := DimX;
    dwHeight := DimY;
    if (NOT DX7Engine.SysMemBackBuf) then
      ddsCaps.dwCaps := DDSCAPS_OFFSCREENPLAIN
      else ddsCaps.dwCaps := DDSCAPS_OFFSCREENPLAIN OR DDSCAPS_SYSTEMMEMORY;
    //
  end;

  // Create the surface.
  HR := DX7Engine.DD7.CreateSurface (DXSurfDesc, DXSurface, NIL);
  if (FAILED (HR)) then exit;

  //
  // success!
  Result := true;
end;

//////////////////////////////////////////////////////////////////////////
function DDCopySurface (dwCopyFlags: DWORD;
  srcSurface: IDirectDrawSurface7; srcBounds: TRect;
  destSurface: IDirectDrawSurface7; destBounds: TRect): boolean;
var
  HR: HResult;
begin
  // perform the copy
  HR := destSurface.Blt (@destBounds, srcSurface, @srcBounds, dwCopyFlags, NIL);

  // return result
  Result := (NOT failed (HR));
end;


//////////////////////////////////////////////////////////////////////////
procedure TZEImage.CreateFromImage (Source: TZEImage);
var
  DXSurfDesc: TDDSurfaceDesc2;
  DXSurface: IDirectDrawSurface7;
  dwCopyFlags: DWORD;
  HR: hResult;
begin
  // assume nothing yet
  FDXSurface := NIL;

  // Get dimension of the current frame from source
  FWidth  := Source.DrawWidth;
  FHeight := Source.DrawHeight;
  FBounds   := Rect(0, 0, FWidth, FHeight);

  // Set up surface description.
  with DXSurfDesc do begin
    FillChar(DXSurfDesc, SizeOf(DXSurfDesc), #0);
    dwSize  := sizeof(DXSurfDesc);
    dwFlags := DDSD_CAPS or DDSD_WIDTH or DDSD_HEIGHT;
    ddsCaps.dwCaps := DDSCAPS_OFFSCREENPLAIN;// OR DDSCAPS_SYSTEMMEMORY;
    dwWidth  := FWidth;
    dwHeight := FHeight;
  end;

  // Create the surface.
  HR := DX7Engine.DD7.CreateSurface (DXSurfDesc, DXSurface, nil);
  if (failed (HR)) then exit;

  // setup the copy flag
  dwCopyFlags := 0;
  if (Source.Transparent) then dwCopyFlags := dwCopyFlags OR DDBLT_KEYSRC;

  // Copy the source surface
  if (NOT DDCopySurface (dwCopyFlags,
      Source.Surface, Source.DrawFrame,
      DXSurface, FBounds)) then begin
        DXSurface := NIL;
        Exit;
      end;

  // success! now copy other vars
  Transparent := Source.Transparent;

  // Return the surface.
  FDXSurface := DXSurface;
end;

//////////////////////////////////////////////////////////////////////////
// returns the rectangular bounds that can/will be drawn
function TZEImage.GetDrawFrame: TRect;
begin
  Result := FBounds;
end;

//////////////////////////////////////////////////////////////////////////
// returns the width of the image to be drawn
function TZEImage.GetDrawWidth: integer;
begin
  Result := FWidth;
end;

//////////////////////////////////////////////////////////////////////////
// returns the height of the image to be drawn
function TZEImage.GetDrawHeight: integer;
begin
  Result := FHeight;
end;

//////////////////////////////////////////////////////////////////////////
// returns number of frames in the image, 1 for base class
function TZEImage.GetNumFrames: integer;
begin
  Result := FFrameCount;
end;

//////////////////////////////////////////////////////////////////////////
// returns true if image has multiple frames
function TZEImage.IsMultiFrames: boolean;
begin
  Result := (FFrameCount > 1);
end;

//////////////////////////////////////////////////////////////////////////
// checks the index, see if it's valid
function TZEImage.ValidFrameNumber (iWhatFrame: integer): boolean;
begin
  Result := false;
  // no need to do anything if same frame already active
  if (FActiveFrame = iWhatFrame) then exit;
  // range-check! exit if invalid index
  if ((iWhatFrame < 0) OR (iWhatFrame >= FFrameCount)) then exit;
  // it's valid! and a go!
  Result := true;
end;

//////////////////////////////////////////////////////////////////////////
// sets the current frame, index is 0-based
procedure TZEImage.SetActiveFrame (iWhichFrame: integer);
begin
  if (NOT ValidFrameNumber (iWhichFrame)) then exit;
  FActiveFrame := iWhichFrame;
  LoadActiveFrame;
end;

//////////////////////////////////////////////////////////////////////////
// reloads image bounds, coordinates, and surface (if necessary)
// of the current frame.  override for image-specific location
// changes
procedure TZEImage.LoadActiveFrame;
begin
end;

//////////////////////////////////////////////////////////////////////////
// returns true if the loaded image has a valid surface
function  TZEImage.IsValid: boolean;
begin
  Result := (FDXSurface <> NIL);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.SetTransparent (bToggle: boolean);
begin
  if (bToggle <> FIsTransparent) then begin
    FIsTransparent := bToggle;
    if (FIsTransparent) then
      MakeTransparent;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.MakeTransparent;
var
  rFrame: TRect;                  // frame to be drawm
begin
  // no surface, no image, no dice
  if (FDXSurface = NIL) OR (FZbImage = NIL) then exit;
  //
  // get the active frame
  rFrame := DrawFrame;
  FTransparentColor := FZbImage.Pixels32 [Cardinal (rFrame.Left), Cardinal (rFrame.Top)];
  SetColorKey (FTransparentColor);
end;

//////////////////////////////////////////////////////////////////////////
// sets a color to be used as a transparency key
procedure TZEImage.SetColorKey (crColorKey: TColorRef);
var
  DDColorKey : TDDColorKey;
begin
  if (FDXSurface = NIL) then exit;

  // set the color key range
  DDColorKey.dwColorSpaceLowValue  := crColorKey;
  DDColorKey.dwColorSpaceHighValue := crColorKey;

  // Set the color key range to the surface.
  FDXSurface.SetColorKey(DDCKEY_SRCBLT, @DDColorKey);
end;

//////////////////////////////////////////////////////////////////////////
// restores the image on the surface, reloads the file if needed
function TZEImage.Restore: boolean;
begin
  Result := false;
  //
  if (FDXSurface <> NIL )then begin
    FDXSurface._Restore;      // Restore the surface.
    WriteBitmap32ToSurface;   // Reload the image onto the surface
    Result := TRUE;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.NextFrame;
begin
  if (FFrameCount > 1) then begin
    Inc (FActiveFrame);
    if (FActiveFrame >= FFrameCount) then
      FActiveFrame := 0;
    LoadActiveFrame;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.PreviousFrame;
begin
  if (FFrameCount > 1) then begin
    Dec (FActiveFrame);
    if (FActiveFrame < 0) then
      FActiveFrame := FFrameCount - 1;
    LoadActiveFrame;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEImage.IsOpaque (iX, iY: integer): boolean;
var
  rFrame: TRect;
  crColorAtPos: TColorRef;
begin
  Result := true;
  if ((NOT FIsTransparent) OR (FDXSurface = NIL) OR (FZbImage = NIL)) then exit;

  // get the current draw frame
  rFrame := DrawFrame;

  // Get the color on the specified location
  crColorAtPos := FZbImage.Pixels32 [
    Cardinal (rFrame.Left + iX), Cardinal (rFrame.Top + iY)];

  // return the result by comparing it to our transparent pixel
  Result := (crColorAtPos <> FTransparentColor)
end;

//////////////////////////////////////////////////////////////////////////
function TZEImage.DuplicateFromCurrentFrame: TZEImage;
begin
  Result := TZEImage.Create (Self);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.CopyCurrentFrame (Source: TZEImage);
var
  dwCopyFlags: DWORD;
begin
  // nothing to do for invalid source
  if (Source = NIL) then exit;

  // setup the copy flag
  dwCopyFlags := 0;
  if (Source.Transparent) then dwCopyFlags := dwCopyFlags OR DDBLT_KEYSRC;

  // Copy the source surface
  DDCopySurface (dwCopyFlags,
      Source.Surface, Source.DrawFrame,
      FDXSurface, FBounds);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImage.ApplyLight (AlphaLight, RedLight, GreenLight, BlueLight: DWORD);
begin
  if (Transparent) then
    PerformAlphaShade2 (
      AlphaLight, RedLight, GreenLight, BlueLight, Surface, Bounds, FTransparentColor)
  else
    PerformAlphaShade (AlphaLight, RedLight, GreenLight, BlueLight, Surface, Bounds)
  //
end;


         (*---------------------------------------------------*
          * TZEGridImage - multiple images bounded by a grid *
          *---------------------------------------------------*)


//////////////////////////////////////////////////////////////////////////
procedure TZEGridImage.CommonInit;
begin
  inherited;
  //
  FDrawWidth  := Width;
  FDrawHeight := Height;
  FDrawFrame  := Bounds;
  FRects      := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEGridImage.AfterCreate;
begin
  if (Valid) then begin
    CreateRectsList;
    MakeTransparent;
  end;
end;

//////////////////////////////////////////////////////////////////////////
// frees the rectangle list before calling inherited
destructor TZEGridImage.Destroy;
begin
  FreeRectsList;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
// creates the rectangle list by scanning the image loaded
procedure TZEGridImage.CreateRectsList;
var
  hdcSurface  : HDC;                    // handle to DC
  ddSurface   : IDirectDrawSurface7;    // surface of image
begin
  // clear the rectangle array
  FreeRectsList;

  // get surface references, exit if it's not valid
  ddSurface := Surface;
  if (ddSurface = NIL) then exit;

  // exit if surface is too small
  if ((Width <= 2) OR (Height <= 2)) then exit;

  // Get a DC for the surface.
  if (ddSurface.GetDC(hdcSurface) <> DD_OK) then exit;

  // create the rectangle array
  FFrameCount := MultiRectsCreate (hdcSurface, Width, Height, FRects);

  // we're done with the DC now
  ddSurface.ReleaseDC (hdcSurface);

  // load the active frame
  LoadActiveFrame;
end;

//////////////////////////////////////////////////////////////////////////
// disposes of the rectangles list
procedure TZEGridImage.FreeRectsList;
begin
  if (FRects <> NIL) then
    begin
      FreeMem (FRects, sizeof (TRect) * FFrameCount);
      FRects := NIL;
      FFrameCount := 0;
    end;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGridImage.GetDrawFrame: TRect;
begin
  Result := FDrawFrame;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGridImage.GetDrawWidth: integer;
begin
  Result := FDrawWidth;
end;

//////////////////////////////////////////////////////////////////////////
function TZEGridImage.GetDrawHeight: integer;
begin
  Result := FDrawHeight;
end;

//////////////////////////////////////////////////////////////////////////
// reloads the relevant vars corresponding to the active frame
procedure TZEGridImage.LoadActiveFrame;
var
  theRect: PRect;
begin
  if (FActiveFrame >= 0) AND (FActiveFrame < FFrameCount) then begin
    theRect := FRects;
    Inc (integer (theRect), sizeof (TRect) * FActiveFrame);
    FDrawFrame := theRect^;
    FDrawWidth := FDrawFrame.Right - FDrawFrame.Left;
    FDrawHeight := FDrawFrame.Bottom - FDrawFrame.Top;
  end;
end;

//////////////////////////////////////////////////////////////////////////
type
  PZE_ImageDescriptor = ^TZEImageDescriptor;
  TZEImageDescriptor = record
    pFilename: PChar;
    bIsTransparent: boolean;
    bIsGridded: boolean;
    pImage: TZEImage;
  end;

  {--------}
  function __ImageDescCreate (AFilename: PChar; AIsTransparent,
    AIsGridded: boolean): PZE_ImageDescriptor;
  var
    Descriptor: PZE_ImageDescriptor;
  begin
    try
      New (Descriptor);
      with Descriptor^ do begin
        pFilename := StrNew (AFilename);
        bIsTransparent := AIsTransparent;
        bIsGridded := AIsGridded;
        pImage := NIL;
      end;
      //
      Result := Descriptor;
    except
      Result := NIL;
    end;
  end;
  {--------}
  procedure __ImageDescDispose (aData: Pointer);
  var
    Descriptor: PZE_ImageDescriptor absolute aData;
  begin
    try
      with Descriptor^ do begin
        StrDispose (pFilename);
        if (pImage <> NIL) then begin
          pImage.Destroy;
          pImage := NIL;
        end;
      end;
      //
      Dispose (Descriptor);
    except
    end;
  end;

//////////////////////////////////////////////////////////////////////////
constructor TZEImageList.Create (APathToImages: string; AConfigFile: string);
begin
  FAliases := TZbDoubleList.Create (true);
  FAliases.DisposeProc := __PCharFree;
  FAliases.Sorted := true;
  //
  FImages := TZbDoubleList.Create (true);
  FImages.DisposeProc := __ImageDescDispose;
  FImages.Sorted := true;
  //
  FPathToImages := APathToImages;
  FUseAliases := true;
  //
  if (AConfigFile <> '') then LoadConfigFile (AConfigFile);
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEImageList.Destroy;
begin
  FAliases.Free;
  FImages.Free;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function  TZEImageList.PreloadImage (AName, AFilename: PChar; ATransparent: boolean;
          AGridded: boolean): TZEImage;
var
  cFullPathName: string;
  cQualifiedName: string;
  Image: TZEImage;
const
  __ZZIE_DEFAULT_EXTENSION  =  '.BMP';
begin
  // assume no return value yet
  Result := NIL;

  // get the file extension.
  // if no extension found, add the default
  cQualifiedName := ExtractFileExt (string(AFilename));
  if (cQualifiedName = '') then
    cQualifiedName := string (AFilename) + __ZZIE_DEFAULT_EXTENSION
  else
    cQualifiedName := string (AFilename);

  // form the full path name to the image file
  cFullPathName := FPathToImages + cQualifiedName;

  // check first if the file does, indeed exists. if not, bug out
  if (NOT FileExists (cFullPathName)) then exit;

  // load the proper image class, depends on value of AGridded
  if (AGridded) then
    Image := TZEGridImage.Create (cFullPathName, ATransparent)
    else Image := TZEImage.Create (cFullPathName, ATransparent);

  // if load successful, set the image name, and return with the image itself
  if (Image <> NIL) then begin
    Image.Name := AName;
    Result := Image;
  end;
end;

//////////////////////////////////////////////////////////////////////////
// converts the descriptor to a TZEImage
function TZEImageList.GetImage (pSource: pointer): TZEImage;
var
  Descriptor: PZE_ImageDescriptor absolute pSource;
begin
  Result := NIL;
  if (Descriptor <> NIL) then
    with Descriptor^ do begin
      if (pImage = NIL) then
        pImage := PreloadImage (
          PChar (FImages.GetName (Descriptor)),
          pFilename, bIsTransparent, bIsGridded);
      //
      Result := pImage;
    end;
end;

//////////////////////////////////////////////////////////////////////////
// returns the image contained in the specified position
function TZEImageList.GetImageByIndex (iIndex: integer): TZEImage;
begin
  Result := GetImage (FImages.Get (iIndex));
end;

//////////////////////////////////////////////////////////////////////////
function TZEImageList.GetImageByName (AName: PChar): TZEImage;
begin
  Result := GetImage (FImages.Get (AName));
end;

//////////////////////////////////////////////////////////////////////////
function TZEImageList.GetName (iIndex: integer): string;
begin
  Result := FImages.GetName (iIndex);
end;

//////////////////////////////////////////////////////////////////////////
function TZEImageList.TranslateAliasToName (AAlias: string): PChar;
begin
  Result := PChar (FAliases.Get (AAlias));
end;

//////////////////////////////////////////////////////////////////////////
function TZEImageList.RetrieveByName (AName: string): TZEImage;
var
  pNameToFind: PChar;
begin
  if (FUseAliases) then
    pNameToFind := TranslateAliasToName (AName)
    else pNameToFind := NIL;
  //
  if (pNameToFind = NIL) then
    pNameToFind := PChar (AName);
  //
  Result := GetImageByName (pNameToFind);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImageList.LoadConfigFile (AConfigFile: string);
var
  IList: IZbEnumStringList;
  cParam1, cParam2: string;
  bParam1, bParam2: boolean;
  bIsAlias: boolean;
  cData: string;
begin
  IList := ConfigManager.LoadSimpleConfig (AConfigFile);
  if (IList = NIL) then exit;
  //
  cData := IList.First;
  while (cData <> '') do begin
    SplitImageSpec (cData, cParam1, cParam2, bParam1, bParam2, bIsAlias);
    if (bIsAlias) then
      AddAlias (cParam1, cParam2)
    else
      AddImage (cParam1, cParam2, bParam1, bParam2);
    //
    cData := IList.Next;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImageList.AddAlias (AAlias, AName: string);
begin
  FAliases.Add (AAlias, StrNew (PChar (AName)));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEImageList.AddImage (AName, AFilename: string;
  AIsTransparent: boolean; AIsGridded: boolean);
var
  Descriptor: PZE_ImageDescriptor;
begin
  Descriptor := __ImageDescCreate (PChar (AFilename), AIsTransparent, AIsGridded);
  if (Descriptor <> NIL) then
    FImages.Add (AName, Pointer (Descriptor));
end;

//////////////////////////////////////////////////////////////////////////
function SplitImageSpec (cSpecLine: string; var cName, cImageName: string;
  var bTransparent, bGridded, bIsAlias: boolean): boolean;
begin
  //
  Result := false;
  cName := ''; cImageName := '';
  bTransparent := false; bGridded := false; bIsAlias := false;
  //
  cSpecLine := Trim (cSpecLine);
  if (cSpecLine = '') then Exit;
  //
  if (cSpecLine [1] = '#') then begin
    cName := StrAfter ('#', StrBefore ('=', cSpecLine));
    cImageName := StrAfter ('=', cSpecLine);
    bIsAlias := true;
  end else begin
    cName := StrBefore ('=', cSpecLine);
      cSpecLine := StrAfter ('=', cSpecLine);
    cImageName := StrBefore (',', cSpecLine);
      cSpecLine := StrAfter (',',  cSpecLine);
    //
    bTransparent := (cSpecLine = '') OR ((cSpecLine <> '') AND (cSpecLine [1] = '1'));
    bGridded := (cSpecLine = '') OR (Length (cSpecLine) < 3) OR
               ((Length (cSpecLine) >= 3) AND (cSpecLine [3] = '1'));
  end;
  //
  Result := true;
end;

//////////////////////////////////////////////////////////////////////////
procedure PerformAlpha (ALPHA: DWORD; imgSource: TZEImage; rSrcRect: TRect;
  imgDest: TZEImage; pDestLoc: TPoint);
begin
  // validate the image objects passed
  if ((imgSource = NIL) OR (imgDest = NIL)) then exit;
  //
  PerformAlphaEx (ALPHA,
    imgSource.Surface, rSrcRect, imgSource.ColorKey, imgDest.Surface, pDestLoc);
end;

//////////////////////////////////////////////////////////////////////////
procedure PerformAlpha2 (ALPHA: DWORD; imgSource: TZEImage; rSrcRect: TRect;
  destSurface: IDirectDrawSurface7; pDestLoc: TPoint);
begin
  if ((imgSource = NIL) OR (destSurface = NIL)) then Exit;
  //
  PerformAlphaEx (ALPHA,
    imgSource.Surface, rSrcRect, imgSource.ColorKey, destSurface, pDestLoc);
end;

//////////////////////////////////////////////////////////////////////////
procedure PerformAlphaEx (ALPHA: DWORD;
  srcSurface: IDirectDrawSurface7; rSrcRect: TRect; srcColorKey: DWORD;
  destSurface: IDirectDrawSurface7; pDestLoc: TPoint);
var
  iHeight, iWidth: integer;
  srcDDSD, destDDSD: TDDSurfaceDesc2;
  lSrcPitch, lDestPitch: integer;
  lpSrc, lpDest: PBYTE;
  ColorKey: DWORD;
  srcBufPad, destBufPad: integer;
  ALPHABY4: DWORD;
  bOddWidth: boolean;
  doubleColorKey: DWORD;
  ckFinal, ckTemp, ckDest: DWORD;
  i, j: integer;
  srcRed, srcBlue, srcGreen: DWORD;
  destRed, destBlue, destGreen: DWORD;
  REDC, GREENC, BLUEC: DWORD;

const
  PLUS64 = 64 OR (64 SHL 16);

begin
  // DX engine MUST be up, and BPP MUST be >= 16
  if ((DX7Engine = NIL) OR (DX7Engine.ResolutionDepth < 16)) then exit;

  // validate the surfaces and make sure they're not NIL
  if ((srcSurface = NIL) OR (destSurface = NIL)) then exit;

  // range-check the alpha value
  ALPHA := EnsureRange (ALPHA, 0, 256);

  // calculate the width,height of sprite to draw
  iHeight := rSrcRect.Bottom - rSrcRect.Top;
  iWidth := rSrcRect.Right - rSrcRect.Left;

	// lock down source surface for read/write
	ZeroMemory (@srcDDSD, sizeof (srcDDSD));
	srcDDSD.dwSize := sizeof (srcDDSD);
	srcSurface.Lock (NIL, srcDDSD, DDLOCK_WAIT, 0);

  // lock down destination surface for read/write as well
	ZeroMemory (@destDDSD, sizeof (destDDSD));
	destDDSD.dwSize := sizeof (destDDSD);
	destSurface.Lock (NIL, destDDSD, DDLOCK_WAIT, 0);

  // get the pitches
  lSrcPitch := srcDDSD.lPitch;
  lDestPitch := destDDSD.lPitch;

  // create pointers to buffers
  lpSrc := PBYTE (srcDDSD.lpSurface);
  lpDest := PBYTE (destDDSD.lpSurface);

  // get the transparent color of source
  ColorKey := srcColorKey;

  // precalculated stuff...
	ALPHABY4 := (ALPHA div 4) OR ((ALPHA div 4) SHL 16);
	doubleColorKey := ColorKey OR (ColorKey SHL 16);

  //
  case DX7Engine.ResolutionDepth of
    16:
      begin
        // initialize the pointers to the first pixel in the rectangle
        lpSrc := PByteInc (lpSrc,
                  ((rSrcRect.top * lSrcPitch) + (rSrcRect.Left * 2)));
        lpDest := PByteInc (lpDest,
                  ((pDestLoc.Y * lDestPitch) + (pDestLoc.X * 2)));

        // set the horizontal padding
        srcBufPad := (lSrcPitch - (2 * iWidth));
        destBufPad := (lDestPitch - (2 * iWidth));

        // check if source width is odd/even.  divide the
        // width by 2 to process 2 pixels at a time, and
        // account for the odd pixel if necessary
        bOddWidth := ((iWidth mod 2) = 1);
        iWidth := IfThen (bOddWidth, Pred (iWidth) div 2, iWidth div 2);

        // main loop
        i := iHeight;
        repeat
          //
          if (bOddWidth) then
            begin
              ckTemp := PWORD (lpSrc)^;

              if (ckTemp <> ColorKey) then
                begin
                  ckDest := PWORD (lpDest)^;
                  srcBlue := ckTemp AND $1F;
                  destBlue := ckDest AND $1F;
                  srcGreen := (ckTemp SHR 5) AND $3F;
                  destGreen := (ckDest SHR 5) AND $3F;
                  srcRed := (ckTemp SHR 11) AND $1F;
                  destRed := (ckDest SHR 11) AND $1F;
                  //
                  PWORD (lpDest)^ :=
                    WORD ((ALPHA * (SrcBlue - destBlue) SHR 8) + destBlue) OR
                    WORD (((ALPHA * (srcGreen - destGreen) SHR 8) + destGreen) SHL 5) OR
                    WORD (((ALPHA * (srcRed - destRed) SHR 8) + destRed) SHL 11);
                end;

              lpDest := PByteInc (lpDest, 2);
              lpSrc := PByteInc (lpDest, 2);
            end;
          //
          j := iWidth;
          repeat
            ckTemp := PDWORD (lpSrc)^;
            //
            if (ckTemp <> doubleColorKey ) then
              begin
                ckDest := PDWORD (lpDest)^;
                //
                srcBlue := ckTemp AND $001F001F;
                destBlue := ckDest AND $001F001F;
                srcGreen := (ckTemp SHR 5) AND $003F003F;
                destGreen := (ckDest SHR 5) AND $003F003F;
                srcRed := (ckTemp SHR 11) AND $001F001F;
                destRed := (ckDest SHR 11) AND $001F001F;
                //
                BLUEC  :=
                  ((((ALPHA * ((srcBlue + PLUS64) - destBlue)) SHR 8) +
                  destBlue) - ALPHABY4) AND $001F001F;
                GREENC :=
                  (((((ALPHA * ((srcGreen + PLUS64) - destGreen)) SHR 8) +
                  destGreen) - ALPHABY4) AND $003F003F) SHL 5;
                REDC   :=
                  (((((ALPHA * ((srcRed + PLUS64) - destRed)) SHR 8) +
                  destRed) - ALPHABY4) AND $001F001F) SHL 11;

                ckFinal := BLUEC OR GREENC OR REDC;

                if ((ckTemp SHR 16) = ColorKey ) then
                    ckFinal := (ckFinal AND $FFFF) OR (ckDest AND $FFFF0000)
                else if ((ckTemp AND $FFFF) = ColorKey ) then
                    ckFinal := (ckFinal AND $FFFF0000) OR (ckDest AND $FFFF);
                //

                PDWORD (lpDest)^ := ckFinal;
              end;

            lpDest := PByteInc (lpDest, 4);
            lpSrc  := PByteInc (lpSrc, 4);

            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          lpSrc := PByteInc (lpSrc, srcBufPad);

          Dec (i);
          //
        until (i <= 0);
        //
      end;

    24:
      begin
        // initialize the pointers to the first pixel in the rectangle
        lpSrc := PByteInc (lpSrc,
                  ((rSrcRect.top * lSrcPitch) + (rSrcRect.Left * 3)));
        lpDest := PByteInc (lpDest,
                  ((pDestLoc.Y * lDestPitch) + (pDestLoc.X * 3)));

        // set the horizontal padding
        srcBufPad := (lSrcPitch - (3 * iWidth));
        destBufPad := (lDestPitch - (3 * iWidth));

        i := iHeight;
        repeat
          //
          j := iWidth;
          repeat
            //
            ckTemp := PDWORD (lpSrc)^;
            if ((ckTemp AND $FFFFFF) <> ColorKey) then
              begin
                ckDest := PDWORD (lpDest)^;
                //
                srcBlue := ckTemp AND $FF;
                destBlue := ckDest AND $FF;
                srcGreen := (ckTemp SHR 8) AND $FF;
                destGreen := (ckDest SHR 8) AND $FF;
                srcRed := (ckTemp SHR 16) AND $FF;
                destRed := (ckDest SHR 16) AND $FF;

                ckFinal :=
                  (((ALPHA * (destBlue - srcBlue) SHR 8) + srcBlue) OR
                  (((ALPHA * (destGreen - srcGreen) SHR 8) + srcGreen) SHL 8) OR
                  (((ALPHA * (destRed - srcRed) SHR 8) + srcRed) SHL 16));

                PWORD (lpDest)^ := WORD (ckFinal AND $FFFF);
                lpDest := PByteInc (lpDest, 2);

                PBYTE (lpDest)^ := BYTE (ckFinal SHR 16);
                lpDest := PByteInc (lpDest);
              end
            else
              lpDest := PByteInc (lpDest, 3);

            lpSrc  := PByteInc (lpSrc, 3);

            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          lpSrc := PByteInc (lpSrc, srcBufPad);

          Dec (i);
          //
        until (i <= 0);
        //
      end;

    32:
      begin
        // initialize the pointers to the first pixel in the rectangle
        lpSrc := PByteInc (lpSrc,
                  ((rSrcRect.top * lSrcPitch) + (rSrcRect.Left * 4)));
        lpDest := PByteInc (lpDest,
                  ((pDestLoc.Y * lDestPitch) + (pDestLoc.X * 4)));

        // set the horizontal padding
        srcBufPad := (lSrcPitch - (4 * iWidth));
        destBufPad := (lDestPitch - (4 * iWidth));

        i := iHeight;
        repeat
          //
          j := iWidth;
          repeat
            //
            ckTemp := PDWORD (lpSrc)^;
            if ((ckTemp AND $FFFFFF) <> ColorKey) then
              begin
                ckDest := PDWORD (lpDest)^;
                //
                srcBlue := ckTemp AND $FF;
                destBlue := ckDest AND $FF;
                srcGreen := (ckTemp SHR 8) AND $FF;
                destGreen := (ckDest SHR 8) AND $FF;
                srcRed := (ckTemp SHR 16) AND $FF;
                destRed := (ckDest SHR 16) AND $FF;

                ckFinal :=
                  (((ALPHA * (destBlue - srcBlue) SHR 8) + srcBlue) OR
                  (((ALPHA * (destGreen - srcGreen) SHR 8) + srcGreen) SHL 8) OR
                  (((ALPHA * (destRed - srcRed) SHR 8) + srcRed) SHL 16));

                PWORD (lpDest)^ := WORD (ckFinal AND $FFFF);
                lpDest := PByteInc (lpDest, 2);

                PBYTE (lpDest)^ := BYTE (ckFinal SHR 16);
                lpDest := PByteInc (lpDest, 2);
              end
            else
              lpDest := PByteInc (lpDest, 4);

            lpSrc  := PByteInc (lpSrc, 4);

            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          lpSrc := PByteInc (lpSrc, srcBufPad);

          Dec (i);
          //
        until (i <= 0);
        //
      end;
  end;
  //
  srcSurface.Unlock (NIL);
  destSurface.Unlock (NIL);
end;

//////////////////////////////////////////////////////////////////////////
procedure PerformAlphaShade (ALPHA: DWORD; ShadeRed, ShadeGreen, ShadeBlue: DWORD;
  destSurface: IDirectDrawSurface7; rDestRect: TRect);
var
  iHeight, iWidth: integer;
  destDDSD: TDDSurfaceDesc2;
  lDestPitch: integer;
  lpDest: PBYTE;
  destBufPad: integer;
  ALPHABY4: DWORD;
  bOddWidth: boolean;
  ckFinal, ckDest: DWORD;
  i, j: integer;
  destRed, destBlue, destGreen: DWORD;
  dwShadeRed, dwShadeGreen, dwShadeBlue: DWORD;
  REDC, GREENC, BLUEC: DWORD;

const
  PLUS64 = 64 OR (64 SHL 16);

begin
  // DX engine MUST be up, and BPP MUST be >= 16
  if ((DX7Engine = NIL) OR (DX7Engine.ResolutionDepth < 16) OR (destSurface = NIL)) then exit;

  // range-check the alpha value
  ALPHA := EnsureRange (ALPHA, 0, 256);

  // create values to use for the colors
  ShadeRed := ShadeRed AND $FF;
  ShadeGreen := ShadeGreen AND $FF;
  ShadeBlue := ShadeBlue AND $FF;

  // calculate the width,height of sprite to draw
  iHeight := rDestRect.Bottom - rDestRect.Top;
  iWidth := rDestRect.Right - rDestRect.Left;

  // lock down destination surface for read/write
	ZeroMemory (@destDDSD, sizeof (destDDSD));
	destDDSD.dwSize := sizeof (destDDSD);
	destSurface.Lock (NIL, destDDSD, DDLOCK_WAIT, 0);

  // get the pitch, and the pointer
  lDestPitch := destDDSD.lPitch;
  lpDest := PBYTE (destDDSD.lpSurface);

  // precalculated stuff...
	ALPHABY4 := (ALPHA div 4) OR ((ALPHA div 4) SHL 16);

  //
  case DX7Engine.ResolutionDepth of
    16:
      begin
        // convert to 5-6-5 format
        ShadeRed := ShadeRed AND $1F;
        ShadeGreen := ShadeGreen AND $3F;
        ShadeBlue := ShadeBlue AND $1F;
        //
        dwShadeRed := ShadeRed OR (ShadeRed SHL 16);
        dwShadeGreen := ShadeGreen OR (ShadeGreen SHL 16);
        dwShadeBlue := ShadeBlue OR (ShadeBlue SHL 16);
        // calculate start pointer
        lpDest := PByteInc (lpDest,
                  ((rDestRect.Top * lDestPitch) + (rDestRect.Left * 2)));

        // set the horizontal padding
        destBufPad := (lDestPitch - (2 * iWidth));

        // check if width is odd/even.  divide the
        // width by 2 to process 2 pixels at a time, and
        // account for the odd pixel if necessary
        bOddWidth := ((iWidth mod 2) = 1);
        iWidth := IfThen (bOddWidth, Pred (iWidth) div 2, iWidth div 2);

        // main loop
        i := iHeight;
        repeat
          //
          if (bOddWidth) then begin
            ckDest := PWORD (lpDest)^;
            destBlue := ckDest AND $1F;
            destGreen := (ckDest SHR 5) AND $3F;
            destRed := (ckDest SHR 11) AND $1F;
            //
            PWORD (lpDest)^ :=
              WORD ((ALPHA * (ShadeBlue - destBlue) SHR 8) + destBlue) OR
              WORD (((ALPHA * (ShadeGreen - destGreen) SHR 8) + destGreen) SHL 5) OR
              WORD (((ALPHA * (ShadeRed - destRed) SHR 8) + destRed) SHL 11);

            lpDest := PByteInc (lpDest, 2);
          end;
          //
          j := iWidth;
          repeat
            ckDest := PDWORD (lpDest)^;
            //
            destBlue := ckDest AND $001F001F;
            destGreen := (ckDest SHR 5) AND $003F003F;
            destRed := (ckDest SHR 11) AND $001F001F;
            //
            BLUEC  :=
              ((((ALPHA * ((dwShadeBlue + PLUS64) - destBlue)) SHR 8) +
              destBlue) - ALPHABY4) AND $001F001F;
            GREENC :=
              (((((ALPHA * ((dwShadeGreen + PLUS64) - destGreen)) SHR 8) +
              destGreen) - ALPHABY4) AND $003F003F) SHL 5;
            REDC   :=
              (((((ALPHA * ((dwShadeRed + PLUS64) - destRed)) SHR 8) +
              destRed) - ALPHABY4) AND $001F001F) SHL 11;

            ckFinal := BLUEC OR GREENC OR REDC;

            //
            PDWORD (lpDest)^ := ckFinal;

            lpDest := PByteInc (lpDest, 4);
            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          Dec (i);
          //
        until (i <= 0);
        //
      end;

    24:
      begin
        // initialize the pointers to the first pixel in the rectangle
        lpDest := PByteInc (lpDest,
                  ((rDestRect.Top * lDestPitch) + (rDestRect.Left * 3)));

        // set the horizontal padding
        destBufPad := (lDestPitch - (3 * iWidth));

        i := iHeight;
        repeat
          //
          j := iWidth;
          repeat
            //
            ckDest := PDWORD (lpDest)^;
            //
            destBlue := ckDest AND $FF;
            destGreen := (ckDest SHR 8) AND $FF;
            destRed := (ckDest SHR 16) AND $FF;

            ckFinal :=
              (((ALPHA * (destBlue - ShadeBlue) SHR 8) + ShadeBlue) OR
              (((ALPHA * (destGreen - ShadeGreen) SHR 8) + ShadeGreen) SHL 8) OR
              (((ALPHA * (destRed - ShadeRed) SHR 8) + ShadeRed) SHL 16));

            PWORD (lpDest)^ := WORD (ckFinal AND $FFFF);
            lpDest := PByteInc (lpDest, 2);

            PBYTE (lpDest)^ := BYTE (ckFinal SHR 16);
            lpDest := PByteInc (lpDest);

            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          Dec (i);
          //
        until (i <= 0);
        //
      end;

    32:
      begin
        // initialize the pointers to the first pixel in the rectangle
        lpDest := PByteInc (lpDest,
                  ((rDestRect.Top * lDestPitch) + (rDestRect.Left * 4)));

        // set the horizontal padding
        destBufPad := (lDestPitch - (4 * iWidth));

        i := iHeight;
        repeat
          //
          j := iWidth;
          repeat
            //
            ckDest := PDWORD (lpDest)^;
            //
            destBlue := ckDest AND $FF;
            destGreen := (ckDest SHR 8) AND $FF;
            destRed := (ckDest SHR 16) AND $FF;

            ckFinal :=
              (((ALPHA * (destBlue - ShadeBlue) SHR 8) + ShadeBlue) OR
              (((ALPHA * (destGreen - ShadeGreen) SHR 8) + ShadeGreen) SHL 8) OR
              (((ALPHA * (destRed - ShadeRed) SHR 8) + ShadeRed) SHL 16));

            PWORD (lpDest)^ := WORD (ckFinal AND $FFFF);
            lpDest := PByteInc (lpDest, 2);

            PBYTE (lpDest)^ := BYTE (ckFinal SHR 16);
            lpDest := PByteInc (lpDest, 2);

            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          Dec (i);
          //
        until (i <= 0);
        //
      end;
  end;

  //
  destSurface.Unlock (NIL);
end;

//////////////////////////////////////////////////////////////////////////
procedure PerformAlphaShade2 (ALPHA: DWORD; ShadeRed, ShadeGreen, ShadeBlue: DWORD;
  destSurface: IDirectDrawSurface7; rDestRect: TRect; destColorKey: DWORD);
var
  iHeight, iWidth: integer;
  destDDSD: TDDSurfaceDesc2;
  lDestPitch: integer;
  lpDest: PBYTE;
  destBufPad: integer;
  ALPHABY4: DWORD;
  bOddWidth: boolean;
  ckFinal, ckDest: DWORD;
  doubleColorKey: DWORD;
  i, j: integer;
  destRed, destBlue, destGreen: DWORD;
  dwShadeRed, dwShadeGreen, dwShadeBlue: DWORD;
  REDC, GREENC, BLUEC: DWORD;

const
  PLUS64 = 64 OR (64 SHL 16);

begin
  // DX engine MUST be up, and BPP MUST be >= 16
  if ((DX7Engine = NIL) OR (DX7Engine.ResolutionDepth < 16) OR (destSurface = NIL)) then exit;

  // range-check the alpha value
  ALPHA := EnsureRange (ALPHA, 0, 256);

  // create values to use for the colors
  ShadeRed := ShadeRed AND $FF;
  ShadeGreen := ShadeGreen AND $FF;
  ShadeBlue := ShadeBlue AND $FF;

  // calculate the width,height of sprite to draw
  iHeight := rDestRect.Bottom - rDestRect.Top;
  iWidth := rDestRect.Right - rDestRect.Left;

  // lock down destination surface for read/write
	ZeroMemory (@destDDSD, sizeof (destDDSD));
	destDDSD.dwSize := sizeof (destDDSD);
	destSurface.Lock (NIL, destDDSD, DDLOCK_WAIT, 0);

  // get the pitch
  lDestPitch := destDDSD.lPitch;
  // create pointers to buffers
  lpDest := PBYTE (destDDSD.lpSurface);

  // precalculated stuff...
	ALPHABY4 := (ALPHA div 4) OR ((ALPHA div 4) SHL 16);
  doubleColorKey := (destColorKey SHL 16);

  //
  case DX7Engine.ResolutionDepth of
    16:
      begin
        // convert to 5-6-5 format
        ShadeRed := ShadeRed AND $1F;
        ShadeGreen := ShadeGreen AND $3F;
        ShadeBlue := ShadeBlue AND $1F;
        //
        dwShadeRed := ShadeRed OR (ShadeRed SHL 16);
        dwShadeGreen := ShadeGreen OR (ShadeGreen SHL 16);
        dwShadeBlue := ShadeBlue OR (ShadeBlue SHL 16);
        // calculate start pointer
        lpDest := PByteInc (lpDest,
                  ((rDestRect.Top * lDestPitch) + (rDestRect.Left * 2)));

        // set the horizontal padding
        destBufPad := (lDestPitch - (2 * iWidth));

        // check if width is odd/even.  divide the
        // width by 2 to process 2 pixels at a time, and
        // account for the odd pixel if necessary
        bOddWidth := ((iWidth mod 2) = 1);
        iWidth := IfThen (bOddWidth, Pred (iWidth) div 2, iWidth div 2);

        // main loop
        i := iHeight;
        repeat
          //
          if (bOddWidth) then begin
            ckDest := PWORD (lpDest)^;
            if (ckDest <> destColorKey) then begin
              destBlue := ckDest AND $1F;
              destGreen := (ckDest SHR 5) AND $3F;
              destRed := (ckDest SHR 11) AND $1F;
              //
              PWORD (lpDest)^ :=
                WORD ((ALPHA * (ShadeBlue - destBlue) SHR 8) + destBlue) OR
                WORD (((ALPHA * (ShadeGreen - destGreen) SHR 8) + destGreen) SHL 5) OR
                WORD (((ALPHA * (ShadeRed - destRed) SHR 8) + destRed) SHL 11);
            end;
            lpDest := PByteInc (lpDest, 2);
          end;
          //
          j := iWidth;
          repeat
            ckDest := PDWORD (lpDest)^;
            //
            if (ckDest <> doubleColorKey) then begin
              destBlue := ckDest AND $001F001F;
              destGreen := (ckDest SHR 5) AND $003F003F;
              destRed := (ckDest SHR 11) AND $001F001F;
              //
              BLUEC  :=
                ((((ALPHA * ((dwShadeBlue + PLUS64) - destBlue)) SHR 8) +
                destBlue) - ALPHABY4) AND $001F001F;
              GREENC :=
                (((((ALPHA * ((dwShadeGreen + PLUS64) - destGreen)) SHR 8) +
                destGreen) - ALPHABY4) AND $003F003F) SHL 5;
              REDC   :=
                (((((ALPHA * ((dwShadeRed + PLUS64) - destRed)) SHR 8) +
                destRed) - ALPHABY4) AND $001F001F) SHL 11;

              ckFinal := BLUEC OR GREENC OR REDC;
              PDWORD (lpDest)^ := ckFinal;
            end;

            lpDest := PByteInc (lpDest, 4);
            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          Dec (i);
          //
        until (i <= 0);
        //
      end;

    24:
      begin
        // initialize the pointers to the first pixel in the rectangle
        lpDest := PByteInc (lpDest,
                  ((rDestRect.Top * lDestPitch) + (rDestRect.Left * 3)));

        // set the horizontal padding
        destBufPad := (lDestPitch - (3 * iWidth));

        i := iHeight;
        repeat
          //
          j := iWidth;
          repeat
            //
            ckDest := PDWORD (lpDest)^;
            if ((ckDest AND $FFFFFF) <> destColorKey) then begin
              //
              destBlue := ckDest AND $FF;
              destGreen := (ckDest SHR 8) AND $FF;
              destRed := (ckDest SHR 16) AND $FF;

              ckFinal :=
                (((ALPHA * (destBlue - ShadeBlue) SHR 8) + ShadeBlue) OR
                (((ALPHA * (destGreen - ShadeGreen) SHR 8) + ShadeGreen) SHL 8) OR
                (((ALPHA * (destRed - ShadeRed) SHR 8) + ShadeRed) SHL 16));

              PWORD (lpDest)^ := WORD (ckFinal AND $FFFF);
              lpDest := PByteInc (lpDest, 2);

              PBYTE (lpDest)^ := BYTE (ckFinal SHR 16);
              lpDest := PByteInc (lpDest);
            end else
              lpDest := PByteInc (lpDest, 3);

            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          Dec (i);
          //
        until (i <= 0);
        //
      end;

    32:
      begin
        // initialize the pointers to the first pixel in the rectangle
        lpDest := PByteInc (lpDest,
                  ((rDestRect.Top * lDestPitch) + (rDestRect.Left * 4)));

        // set the horizontal padding
        destBufPad := (lDestPitch - (4 * iWidth));

        i := iHeight;
        repeat
          //
          j := iWidth;
          repeat
            //
            ckDest := PDWORD (lpDest)^;
            if ((ckDest AND $FFFFFF) <> destColorKey) then begin
              destBlue := ckDest AND $FF;
              destGreen := (ckDest SHR 8) AND $FF;
              destRed := (ckDest SHR 16) AND $FF;

              ckFinal :=
                (((ALPHA * (destBlue - ShadeBlue) SHR 8) + ShadeBlue) OR
                (((ALPHA * (destGreen - ShadeGreen) SHR 8) + ShadeGreen) SHL 8) OR
                (((ALPHA * (destRed - ShadeRed) SHR 8) + ShadeRed) SHL 16));

              PWORD (lpDest)^ := WORD (ckFinal AND $FFFF);
              lpDest := PByteInc (lpDest, 2);
              PBYTE (lpDest)^ := BYTE (ckFinal SHR 16);
              lpDest := PByteInc (lpDest, 2);
            end else
              lpDest := PByteInc (lpDest, 4);

            Dec (j);
            //
          until (j <= 0);

          lpDest := PByteInc (lpDest, destBufPad);
          Dec (i);
          //
        until (i <= 0);
        //
      end;
  end;

  //
  destSurface.Unlock (NIL);
end;




end.

