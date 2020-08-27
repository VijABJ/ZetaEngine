{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXSpriteIntf.PAS
              Interface declarations for a sprite and sprite list
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXSpriteIntf.pas,v 1.3 2002/10/01 12:32:26 Vij Exp $
  $Log: ZEDXSpriteIntf.pas,v $
  Revision 1.3  2002/10/01 12:32:26  Vij
  Remove SpriteCenter interface and class, it's not needed anymore.  Added
  property IdName to Sprite.

  Revision 1.2  2002/09/17 22:09:10  Vij
  Added Bounds property, and the code to support it.

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXSpriteIntf;

interface

uses
  Types,
  ZblIStrings;

type
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // an interface to a game sprite.  contains mostly routines to
  // ask the sprite to do something to itself, or ask for some of
  // its data (like how many frames it has).  this is intentionally
  // defined without any reference to actual drawing so it won't
  // be dependent on how an image is actually drawn
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IZESprite = interface (IInterface)
    ['{092C1B2E-9662-43BC-8CE0-6C9CA233A5E4}']
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
    property IdName: String read GetIdName;
    property Bounds: TRect read GetBounds;
    property Position: TPoint read GetPosition write SetPosition;
    property Size: TPoint read GetSize;
    property Width: integer read GetWidth;
    property Height: integer read GetHeight;
    property FrameCount: integer read GetFrameCount;
    property CurrentFrame: integer read GetCurrentFrame write SetCurrentFrame;
    property Transparent: boolean read GetTransparent;
    property Alpha: DWORD read GetAlpha write SetAlpha;
    property UseAlpha: boolean read GetUseAlpha write SetUseAlpha;
    property DestSurface: Pointer read GetDestSurface write SetDestSurface;
    property SrcSurface: Pointer read GetSrcSurface;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // this interface is for creating the sprites, and for loading,
  // and managing the sprite descriptors list
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEOnSpriteCreatedProc = procedure (Sprite: IZESprite) of Object;

  IZESpriteFactory = interface (IInterface)
    ['{962AA740-8B65-45DF-A482-FFCA44D9AE6E}']
    function LoadSprList (SprList: IZbEnumStrings): boolean; stdcall;
    function CreateSprite (AFamily, ASubClass: string): IZESprite; stdcall;
    procedure SetOnSpriteCreateProc (AOnSpriteCreate: TZEOnSpriteCreatedProc); stdcall;
    //
    property OnSpriteCreate: TZEOnSpriteCreatedProc write SetOnSpriteCreateProc;
  end;


implementation

end.
