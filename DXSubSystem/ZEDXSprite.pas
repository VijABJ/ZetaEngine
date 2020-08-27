{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXSprite.PAS
              Implementations for interfaces declared in ZZESpriteIntf
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXSprite.pas,v 1.4 2002/11/02 06:43:24 Vij Exp $
  $Log: ZEDXSprite.pas,v $
  Revision 1.4  2002/11/02 06:43:24  Vij
  reordered check for existing sprites.

  Revision 1.3  2002/10/01 12:32:26  Vij
  Remove SpriteCenter interface and class, it's not needed anymore.  Added
  property IdName to Sprite.

  Revision 1.2  2002/09/17 22:09:10  Vij
  Added Bounds property, and the code to support it.

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXSprite;

interface

uses
  Windows,
  Classes,
  DirectDraw,
  //
  ZblIStrings,
  ZbXMLLib,
  ZbDoubleList,
  ZbBitmap,
  //
  ZEDXSpriteIntf,
  ZEDXImage,
  ZEDXImageLib;

type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // This sprite class can be used to create a sprite Interface
  // type.  Interfaces are easier to use in some cases.
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESprite = class (TInterfacedObject, IZESprite)
  private
    FImage: TZEImage;
    FImgFrameStart: integer;
    FImgFrameEnd: integer;
    FImgNumFrames: integer;
    FActiveFrame: integer;
    //
    FIdName: PChar;
    FPosition: TPoint;
    FDestRect: TRect;
    FDestSurface: IDirectDrawSurface7;
    //
    FUseAlpha: boolean;
    FAlpha: DWORD;
  protected
    procedure UpdateDestRect;
    function IsValid: boolean;
    procedure SetImage (AImage: TZEImage);
    //
    procedure InternalDraw (dwBlitOptions: DWORD; bUseClipper: boolean = false);
  public
    constructor Create (AImage: TZEImage; AIdName: string;
      iFirstFrame: integer = 0; iLastFrame: integer = 0); virtual;
    destructor Destroy; override;
    //
    // ***** implements IZESprite *****
    function GetIdName: string; stdcall;
    function GetBounds: TRect; stdcall;
    function GetPosition: TPoint; stdcall;
    procedure SetPosition (APosition: TPoint); stdcall;
    procedure Move (dX, dY: integer); stdcall;
    function GetSize: TPoint; stdcall;
    function GetWidth: integer; stdcall;
    function GetHeight: integer; stdcall;
    function GetFrameCount: integer; stdcall;
    function GetCurrentFrame: integer; stdcall;
    procedure SetCurrentFrame (ANewFrame: integer); stdcall;
    procedure FirstFrame; stdcall;
    procedure NextFrame; stdcall;
    procedure PrevFrame; stdcall;
    procedure LastFrame; stdcall;
    procedure CycleFrameForward; stdcall;
    procedure CycleFrameBackward; stdcall;
    function AtFirstFrame: boolean; stdcall;
    function AtLastFrame: boolean; stdcall;
    //
    function GetDestSurface: Pointer; stdcall;
    procedure SetDestSurface (pDestSurface: Pointer); stdcall;
    function GetSrcSurface: Pointer; stdcall;
    //
    function GetTransparent: boolean; stdcall;
    function GetAlpha: DWORD; stdcall;
    procedure SetAlpha (dwAlpha: DWORD); stdcall;
    function GetUseAlpha: boolean; stdcall;
    procedure SetUseAlpha (AUseAlpha: boolean) stdcall;
    //
    procedure ApplyLighting (Alpha, Red, Green, Blue: DWORD); stdcall;
    procedure ResetLighting; stdcall;
    //
    procedure DrawSprite (Sprite: IZESprite); stdcall;
    procedure Draw (bClip: boolean); stdcall;
    procedure DrawClipped (rClipArea: TRect); stdcall;
    procedure Tesselate (rBounds: TRect; bClip: boolean); stdcall;
    procedure StretchDraw (rBounds: TRect; bClip: boolean); stdcall;
    //
    function __SpecialGetImage: Pointer; stdcall;
    //
    // properties
    property IdName: String read GetIdName;
    property Bounds: TRect read GetBounds;
    property Position: TPoint read GetPosition write SetPosition;
    property Size: TPoint read GetSize;
    property Width: integer read GetWidth;
    property Height: integer read GetHeight;
    property Valid: boolean read IsValid;
    property ActiveFrame: integer read GetCurrentFrame write SetCurrentFrame;
    property FrameCount: integer read GetFrameCount;
    property Alpha: DWORD read GetAlpha write SetAlpha;
    property UseAlpha: boolean read GetUseAlpha write SetUseAlpha;
  end;

  TZESpriteFactory = class (TInterfacedObject, IZESpriteFactory)
  private
    FDescriptors: TZbDoubleList;
    FSource: TZEImageManager;
    FOnSpriteCreate: TZEOnSpriteCreatedProc;
  protected
    function CheckSubClass (AFamily, ASubClass: string): string; virtual;
  public
    constructor Create (ASource: TZEImageManager);
    destructor Destroy; override;
    // ***** implements IZESpriteFactory *****
    function LoadSprList (SprList: IZbEnumStrings): boolean; stdcall;
    function CreateSprite (AFamily, ASubClass: string): IZESprite; stdcall;
    procedure SetOnSpriteCreateProc (AOnSpriteCreate: TZEOnSpriteCreatedProc); stdcall;
    //
    property OnSpriteCreate: TZEOnSpriteCreatedProc write SetOnSpriteCreateProc;
  end;


implementation

uses
  SysUtils,
  Math,
  JclGraphUtils,
  JclStrings,
  ZbRectClipper;


            //////////////////////////////////////
            //                                  //
            //  T Z E S p r i t e   C l a s s   //
            //                                  //
            //////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
constructor TZESprite.Create (AImage: TZEImage; AIdName: string;
  iFirstFrame: integer; iLastFrame: integer);
begin
  SetImage (AImage);
  FImgFrameStart  := iFirstFrame;
  FImgFrameEnd    := iLastFrame;
  FImgNumFrames   := ((iLastFrame - iFirstFrame) + 1);
  FActiveFrame    := FImgFrameStart;
  FPosition       := Point (0, 0);
  FDestSurface    := NIL;
  FUseAlpha       := false;
  FAlpha          := 256;
  FIdName         := StrNew (PChar (AIdName));
end;

//////////////////////////////////////////////////////////////////////////
// should get rid of all resources, but NOT the image since the
// sprite does not own it.
destructor TZESprite.Destroy;
begin
  StrDispose (FIdName);
  FDestSurface := NIL;      // this gets rid of the surface by calling release
  SetImage (NIL);           // make sure the image is NIL too, just in case
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.UpdateDestRect;
begin
  if (FImage <> NIL) then begin
    FImage.ActiveFrame := FActiveFrame;
    //
    FDestRect := Rect (
      FPosition.X, FPosition.Y,
      FPosition.X + FImage.DrawWidth,
      FPosition.Y + FImage.DrawHeight
    );
  end else
    FDestRect := NullRect;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.IsValid: boolean;
begin
  Result := (FImage <> NIL)
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.SetImage (AImage: TZEImage);
begin
  FImage := AImage;
  UpdateDestRect;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.InternalDraw (dwBlitOptions: DWORD; bUseClipper: boolean);
var
  HR: HResult;
  rFinal, rSrcRect: TRect;
begin
  // validate the image we have
  if ((FImage = NIL) OR (FImage.Surface = NIL) OR (FDestSurface = NIL))then exit;

  // select the proper frame
  FImage.ActiveFrame := FActiveFrame;

  // create the rectangle to draw to
  rFinal := FDestRect;

  // create the rectangle to draw from
  rSrcRect := FImage.DrawFrame;

  // do clipping if necessary
  if (bUseClipper) then
    GlobalClipper.PerformClipping (rFinal, rSrcRect);

  // blit the image
  if (NOT FUseAlpha) then
    HR := FDestSurface.Blt (@rFinal, FImage.Surface, @rSrcRect, dwBlitOptions, NIL)
  else begin
    HR := 0;
    PerformAlpha2 (FAlpha, FImage, rSrcRect, FDestSurface, rFinal.TopLeft);
  end;

  // restore the surface if it was displaced
  if (HR = DDERR_SURFACELOST) then FImage.Restore;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetIdName: string;
begin
  Result := String (FIdName);
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetBounds: TRect; stdcall;
begin
  Result := FDestRect;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetPosition: TPoint;
begin
  Result := FPosition;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.SetPosition (APosition: TPoint);
begin
  FPosition := APosition;
  UpdateDestRect;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.Move (dX, dY: integer);
begin
  SetPosition (Point (FPosition.X + dX, FPosition.Y + dY));
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetSize: TPoint;
begin
  Result := Point (Width, Height);
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetWidth: integer;
begin
  if (FImage <> NIL) then begin
    // be sure our frame is selected in the image!
    FImage.ActiveFrame := FActiveFrame;
    Result := FImage.DrawWidth;
  end else
    Result := 0;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetHeight: integer;
begin
  if (FImage <> NIL) then begin
    // be sure our frame is selected in the image!
    FImage.ActiveFrame := FActiveFrame;
    Result := FImage.DrawHeight;
  end else
    Result := 0;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetFrameCount: integer;
begin
  Result := FImgNumFrames;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetCurrentFrame: integer;
begin
  Result := FActiveFrame - FImgFrameStart;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.SetCurrentFrame (ANewFrame: integer);
begin
  if (ANewFrame >= 0) AND (ANewFrame < FImgNumFrames) then
    FActiveFrame := FImgFrameStart + ANewFrame;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.FirstFrame;
begin
  SetCurrentFrame (0);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.NextFrame;
begin
  SetCurrentFrame (Succ (FActiveFrame-FImgFrameStart));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.PrevFrame;
begin
  SetCurrentFrame (Pred (FActiveFrame-FImgFrameStart));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.LastFrame;
begin
  SetCurrentFrame (Pred (FrameCount));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.CycleFrameForward;
begin
  if (AtLastFrame) then
    FirstFrame
    else NextFrame;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.CycleFrameBackward;
begin
  if (AtFirstFrame) then
    LastFrame
    else PrevFrame;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.AtFirstFrame: boolean;
begin
  Result := (FActiveFrame = FImgFrameStart);
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.AtLastFrame: boolean;
begin
  Result := (FActiveFrame = FImgFrameEnd);
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetDestSurface: Pointer;
begin
  Result := Pointer (FDestSurface);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.SetDestSurface (pDestSurface: Pointer);
begin
  FDestSurface := NIL;
  FDestSurface := IDirectDrawSurface7 (pDestSurface);
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetSrcSurface: Pointer;
begin
  Result := Pointer (FImage.Surface);
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetTransparent: boolean;
begin
  Result := FImage.Transparent;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetAlpha: DWORD;
begin
  Result := FAlpha;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.SetAlpha (dwAlpha: DWORD);
begin
  FAlpha := EnsureRange (dwAlpha, 0, 256);
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.GetUseAlpha: boolean;
begin
  Result := FUseAlpha;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.SetUseAlpha (AUseAlpha: boolean);
begin
  FUseAlpha := AUseAlpha;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.ApplyLighting (Alpha, Red, Green, Blue: DWORD);
begin
  FImage.ApplyLight (Alpha, Red, Green, Blue);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.ResetLighting;
begin
  FImage.Restore;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.DrawSprite (Sprite: IZESprite);
var
  bufSource, bufDest: IDirectDrawSurface7;
  rSource, rDest: TRect;
  dwBlitOptions: DWORD;
begin
  if (Sprite = NIL) OR (FImage = NIL) then Exit;
  bufSource := IDirectDrawSurface7 (Sprite.SrcSurface);
  bufDest := IDirectDrawSurface7 (GetDestSurface);
  if (bufDest = NIL) OR (bufSource = NIL) then Exit;
  //
  rDest := FImage.DrawFrame;
  rSource := Rect (0, 0, Sprite.Width, Sprite.Height);
  if (Sprite.Transparent) then
    dwBlitOptions := DDBLT_KEYSRC
    else dwBlitOptions := 0;
  //
  bufDest.Blt (@rDest, bufSource, @rSource, dwBlitOptions, NIL);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.Draw (bClip: boolean);
begin
  InternalDraw (IfThen (FImage.Transparent, DDBLT_KEYSRC, 0), bClip);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.DrawClipped (rClipArea: TRect); stdcall;
begin
  // setup the clipping rectangle
  GlobalClipper.SetClippingRegion (rClipArea);
  // perform the drawing
  InternalDraw (IfThen (FImage.Transparent, DDBLT_KEYSRC, 0), TRUE);
  // reset the clipper
  GlobalClipper.ClearClippingRegion;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.Tesselate (rBounds: TRect; bClip: boolean);
var
  OldPos: TPoint;
  X, Y: integer;
  dwBlitOptions: DWORD;
begin
  // save current anchor point
  OldPos := FPosition;
  // select the proper frame
  FImage.ActiveFrame := FActiveFrame;
  // setup the clipping rectangle
  GlobalClipper.SetClippingRegion (rBounds);
  // this loop perform the tiling draw
  Y := rBounds.Top;
  dwBlitOptions := IfThen (FImage.Transparent, DDBLT_KEYSRC, 0);
  while (Y < GlobalClipper.ClippingRegion.Bottom) do begin
    X := rBounds.Left;
    while (X < GlobalClipper.ClippingRegion.Right) do begin
      SetPosition (Point (X, Y));
      InternalDraw (dwBlitOptions, TRUE);
      Inc (X, FImage.DrawWidth);
    end;
    //
    Inc (Y, FImage.DrawHeight);
  end;
  //
  // reset the clipper
  GlobalClipper.ClearClippingRegion;
  // restore anchor point
  Position := OldPos;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESprite.StretchDraw (rBounds: TRect; bClip: boolean);
var
  OldPos: TPoint;
  dwBlitOptions: DWORD;
begin
  // save current anchor point
  OldPos := FPosition;
  //
  Position := rBounds.TopLeft;
  FDestRect := rBounds;
  //
  // select the proper frame
  FImage.ActiveFrame := FActiveFrame;
  // setup the clipping rectangle
  GlobalClipper.SetClippingRegion (rBounds);
  //
  dwBlitOptions := IfThen (FImage.Transparent, DDBLT_KEYSRC, 0);
  InternalDraw (dwBlitOptions, bClip);
  // reset the clipper
  GlobalClipper.ClearClippingRegion;
  // restore anchor point
  Position := OldPos;
end;

//////////////////////////////////////////////////////////////////////////
function TZESprite.__SpecialGetImage: Pointer; stdcall;
begin
  Result := Pointer (FImage);
end;


      ////////////////////////////////////////////////////
      //                                                //
      //  T Z E S p r i t e F a c t o r y   C l a s s   //
      //                                                //
      ////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////
// image descriptors, supports the sprite list
type
  PZESpriteDescriptor = ^TZESpriteDescriptor;
  TZESpriteDescriptor = record
    pImageName: PChar;
    iFirstFrame: integer;
    iLastFrame: integer;
  end;

//////////////////////////////////////////////////////////////////////////
// support routines for a list of descriptors

  {----------------------------------------------------------------------}
  function __DescriptorCreate (AImageName: PChar; FFirstFrame,
    FLastFrame: integer): PZESpriteDescriptor; overload;
  var
    Descriptor: PZESpriteDescriptor;
  begin
    Result := NIL;
    New (Descriptor);
    if (Descriptor <> NIL) then
      begin
        with Descriptor^ do
          begin
            pImageName := StrNew (AImageName);
            iFirstFrame := FFirstFrame;
            iLastFrame := FLastFrame;
          end;
        //
        Result := Descriptor;
      end;
  end;

  {----------------------------------------------------------------------}
  function __DescriptorCreate (AParameter: string; var cName: string): PZESpriteDescriptor; overload;
  var
    cTemp, cImageName: string;
    iFirstFrame, iLastFrame: integer;
  begin
    // extract the names first
    cName := StrBefore ('=', AParameter);
      AParameter := StrAfter ('=', AParameter);
    cImageName := StrBefore (',', AParameter);
      AParameter := StrAfter (',', AParameter);
    // and now for the values
    cTemp := StrBefore (',', AParameter);
      AParameter := StrAfter (',', AParameter);
      if (cTemp = '') then
        iFirstFrame := 0
        else iFirstFrame := StrToInt (cTemp);
    //
    cTemp := StrBefore (',', AParameter);
      if (cTemp = '') then
        iLastFrame := 0
        else iLastFrame := StrToInt (cTemp);
    //
    Result := __DescriptorCreate (PChar(cImageName), iFirstFrame, iLastFrame);
  end;

  {----------------------------------------------------------------------}
  procedure __DescriptorDispose (aData: pointer);
  var
    Descriptor: PZESpriteDescriptor absolute aData;
  begin
    try
      StrDispose (Descriptor.pImageName);
      Dispose (Descriptor);
    except
    end;
  end;

//////////////////////////////////////////////////////////////////////////
constructor TZESpriteFactory.Create (ASource: TZEImageManager);
begin
  // remember the source of the image, we'll get our image from this one
  FSource := ASource;
  // create the sprite descriptor list
  FDescriptors := TZbDoubleList.Create (TRUE);
  FDescriptors.DisposeProc := __DescriptorDispose;
  FDescriptors.Sorted := TRUE;
  //
  FOnSpriteCreate := NIL;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZESpriteFactory.Destroy;
begin
  FreeAndNIL (FDescriptors);
  FSource := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
function TZESpriteFactory.CheckSubClass (AFamily, ASubClass: string): string;
begin
  Result := ASubClass;
end;

//////////////////////////////////////////////////////////////////////////
function TZESpriteFactory.LoadSprList (SprList: IZbEnumStrings): boolean;
var
  cData, cName: string;
  Descriptor: PZESpriteDescriptor;
begin
  Result := (SprList <> NIL) AND (SprList.Count > 0);
  //
  cData := SprList.First;
  while (cData <> '') do begin
    //
    Descriptor := __DescriptorCreate (cData, cName);
    //
    if (FDescriptors.Get (cName) <> NIL) then FDescriptors.Delete (cName);
    FDescriptors.Add (cName, Pointer (Descriptor));
    //
    cData := SprList.Next;
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZESpriteFactory.CreateSprite (AFamily, ASubClass: string): IZESprite;
var
  Descriptor: PZESpriteDescriptor;
  Image: TZEImage;
  cSpriteName: string;
begin
  Result := NIL;
  if (FSource = NIL) then exit;
  //
  // if default is requested (a blank subclass), get it.
  // if no default was found for this family, get out now!
  ASubClass := CheckSubClass (AFamily, ASubClass);
  if (ASubClass = '') then exit;
  //
  // assemble the name of the sprite's image.
  // some additional rules added (06/July/2002[Vij]):
  // --> if Family is blank, then use the SubClass by itself,
  //     otherwise, use Family/Subclass.
  cSpriteName := AFamily;
  if (cSpriteName <> '') then cSpriteName := cSpriteName + '/';
  cSpriteName := cSpriteName + ASubClass;
  //
  // find the descriptor for this sprite, if not found,
  // it doesn't exist
  Descriptor := PZESpriteDescriptor (FDescriptors.Get (cSpriteName));
  if (Descriptor = NIL) then exit;
  //
  // extract the required image, if none, no cigar and outta here
  // if found, create an image and return it.
  with Descriptor^ do begin
    Image := FSource [string (pImageName)];
    if (Image <> NIL) then
      Result :=  TZESprite.Create (Image, cSpriteName, iFirstFrame, iLastFrame) as IZESprite;
    //
  end;
  //
  if ((Result <> NIL) AND Assigned (FOnSpriteCreate)) then FOnSpriteCreate (Result);
end;

//////////////////////////////////////////////////////////////////////////
procedure TZESpriteFactory.SetOnSpriteCreateProc (AOnSpriteCreate: TZEOnSpriteCreatedProc);
begin
  FOnSpriteCreate := AOnSpriteCreate;
end;


end.

