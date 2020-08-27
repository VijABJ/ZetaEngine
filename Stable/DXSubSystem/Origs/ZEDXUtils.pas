{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXUtils.PAS
              Utility routines separated from ZEDXImage
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXUtils.pas,v 1.2 2002/11/02 06:41:13 Vij Exp $
  $Log: ZEDXUtils.pas,v $
  Revision 1.2  2002/11/02 06:41:13  Vij
  replaced GetMem() with SafeAllocMem()

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}
unit ZEDXUtils;

interface

uses
  Windows,
  Classes,
  SysUtils,
  DirectDraw;

  
  ///////////////////////////////////////////////////////////////
  // given a bitmap filename, this loads it.  all error-checking
  // and range-checking included. returns 0 if not successful
  function LoadBitmapFile (cFileName: PChar; var Width, Height: integer): hBitmap;

  ///////////////////////////////////////////////////////////////
  // creates a rectangle array containing the bounds of the
  // multiple images within the gridded image.
  function MultiRectsCreate (dcSource: HDC;
    dcWidth, dcHeight: integer; var FRects: PRect): integer;

  ///////////////////////////////////////////////////////////////
  // third-party stuff
  function DDDrawBitmap(_SrcBMP: hBitmap;
                      _SrcX, _SrcY, _SrcW, _SrcH,
                      _DstX, _DstY, _DstW, _DstH: longint;
                      _DestSurf: IDirectDrawSurface7): boolean;
  function DDColorMatch(_surf: IDirectDrawSurface7;
                      _rgb: TColorRef): TColorRef;


implementation


uses
  ZbUtils;


//////////////////////////////////////////////////////////////////////////
function LoadBitmapFile (cFileName: PChar; var Width, Height: integer): hBitmap;
var
  HBM   : hBitmap;    // handle to bitmap
  TBMP  : tBitmap;    // bitmap properties structure
begin
  // assume error return
  Result := 0;
  Width := 0;
  Height := 0;

  // range-check the values given, ignore if not valid
  if ((cFileName = NIL) OR (StrLen (cFileName) = 0)) then exit;

  // if filename does NOT exist, return immediately
  if (NOT FileExists (cFileName)) then exit;

  // Try to load the bitmap.
  HBM := LoadImage (0, cFileName, IMAGE_BITMAP, 0, 0,
            LR_LOADFROMFILE or LR_CREATEDIBSECTION);

  // no bitmap? exit now
  if (HBM = 0) then exit;

  // Get dimension of the BMP.
  GetObject (HBM, sizeof (TBITMAP), @TBMP);
  Width  := TBMP.bmWidth;
  Height := TBMP.bmHeight;

  // success!
  Result := HBM;
end;

//////////////////////////////////////////////////////////////////////////
function MultiRectsCreate (dcSource: HDC;
  dcWidth, dcHeight: integer; var FRects: PRect): integer;
var
  rgbGrid       : TColorRef;              // Grid color.
  rgbCurrent    : TColorRef;              // Current color.
  iPhase        : integer;                // phase determinator
  iXPos, iYPos  : integer;                // coordinates
  iX, iY        : integer;                // top left of current rect
  iRectsCounted : integer;                // number of frames counted
  curRect       : PRect;                  // pointer to current rect to fill
const
  PHASE1      = 0;
  PHASE2      = 1;
begin
  // assume no rects found, NIL the pointer as well
  iRectsCounted := 0;
  FRects := NIL;
  curRect := NIL;

  // Get the grid's color.
  rgbGrid := GetPixel(dcSource, 0, 0);

  // begin loop to find all the rects
  for iPhase := PHASE1 to PHASE2 do begin
    // allocate memory if phase 2 already
    if (iPhase = PHASE2) then begin
      if (iRectsCounted = 0) then break;
      FRects := SafeAllocMem (sizeof (TRect) * iRectsCounted);
      curRect := FRects;
    end else
      iRectsCounted := 0;

    // loop thru the grid pattern, counting them
    iYPos := 0;
    repeat
      Inc (iYPos);  // step to next pixel row
      iY := iYPos;  // set this up as topleft Y

      // loop and find the next vertical cell
      while (iYPos < dcHeight) AND (GetPixel (dcSource, 1, iYPos) <> rgbGrid) do
        Inc (iYPos);

      // if there was a frame found...
      if ((iYPos-1) > iY) then begin
        iX := 1;  // set up for topleft X
        for iXPos := 1 to Pred (dcWidth) do begin
          rgbCurrent := GetPixel (dcSource, iXPos, iYPos-1);
          if (rgbCurrent = rgbGrid) AND ((iXPos-1) > iX) then begin
            if (iPhase = PHASE2) AND (curRect <> NIL) then begin
              curRect^ := Rect (iX, iY, iXPos, iYPos);
              Inc (integer(curRect), SizeOf(TRect));
              iX := iXPos + 1;  // set value of next topleft X
            end else
              Inc (iRectsCounted);
          end;
        end;
      end;

    until (iYPos >= Pred (dcHeight));

  end; // phase loop

  Result := iRectsCounted;
end;

//////////////////////////////////////////////////////////////////////////
// Name : DDDrawBitmap.
// Desc : Draws a bitmap on a DirectDraw surface.
//////////////////////////////////////////////////////////////////////////

function DDDrawBitmap(_SrcBMP: hBitmap;
                      _SrcX, _SrcY, _SrcW, _SrcH,
                      _DstX, _DstY, _DstW, _DstH: longint;
                      _DestSurf: IDirectDrawSurface7): boolean;

var _dcBMP  : hDC;
    _dcSurf : hDC;
    _hr : hResult;

begin
  Result := false;

  // Create DC for the BMP.
  _dcBMP := CreateCompatibleDC(0);
  if _dcBMP = 0 then exit;
  SelectObject(_dcBMP, _SrcBMP);

  // Get DC for the surface.
  _hr := _DestSurf.GetDC(_dcSurf);
  if not failed(_hr) then
    begin
      // Draw.
      Result := StretchBlt(_dcSurf, _DstX, _DstY, _DstW, _DstH, _dcBMP,
                           _SrcX, _SrcY, _SrcW, _SrcH, SRCCOPY);
      // Free surface's DC.
      _DestSurf.ReleaseDC(_dcSurf);
    end;

  // Free BMP's DC.
  DeleteDC(_dcBMP);
end;

//////////////////////////////////////////////////////////////////////////
// Name : DDColorMatch.
// Desc : Returns the nearest color (to _rgb) in the selected surface.
//        If _rgb is CLR_INVALID the function returns the color
//        located on the 0,0 coordinates.
// Warning : This function must be used only under non paletized
//           video modes (16, 24 or 32 bpp).
//////////////////////////////////////////////////////////////////////////

function DDColorMatch(_surf: IDirectDrawSurface7;
                      _rgb: TColorRef): TColorRef;

var _hdc  : HDC;
    _rgbT : TColorRef;
    _ddsd : TDDSurfaceDesc2;
    _val  : longint;
    _hr   : hResult;

begin
  Result := CLR_INVALID;
  _rgbT := CLR_INVALID;

  // Check the surface.
  if _surf = NIL then exit;

  // GDI's SetPixel function will do the Job for us.
  if (_rgb <> CLR_INVALID) then
    begin
      if _surf.GetDC(_hdc) <> DD_OK then exit;

      // Save the 0,0 pixel and change it.
      _rgbT := GetPixel(_hdc, 0, 0);
      SetPixel(_hdc, 0, 0, _rgb);
      _surf.ReleaseDC(_hdc);
    end;

  // Lock the surface...
  _ddsd.dwSize := sizeof(_ddsd);
  repeat
    _hr := _surf.Lock(NIL, _ddsd, 0, 0);
  until _hr <> DDERR_WASSTILLDRAWING;

  // ... and read the value of the 0,0 coordinate.
  if _hr = DD_OK then
    begin
      // Read 4 bytes.
      _val := longint(_ddsd.lpSurface^);
      // Adjust for the current bpp (Bits Per Pixel).
      if (_ddsd.ddpfPixelFormat.dwRGBBitCount < 32)
        then _val := _val and ($FFFFFFFF shr (32 - _ddsd.ddpfPixelFormat.dwRGBBitCount));
      // Unlock.
      _surf.Unlock(NIL);
      // All right.
      Result := _val;
    end;

  // Restore the color in the 0,0 coordinate.
  if (_rgb <> CLR_INVALID) and (_surf.GetDC(_hdc) = DD_OK) then
    begin
      SetPixel(_hdc, 0, 0, _rgbT);
      _surf.ReleaseDC(_hdc);
    end;
end;


end.

