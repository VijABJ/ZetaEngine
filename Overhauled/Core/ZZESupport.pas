{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZESupport.PAS
              Contains support classes/routines/variables/definitions
              for the Tile Engine
  Author:     Vij
  Notes:

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Core/ZZESupport.pas,v 1.3 2002/11/02 06:35:34 Vij Exp $
  $Log: ZZESupport.pas,v $
  Revision 1.3  2002/11/02 06:35:34  Vij
  trimmed code and move most general purpose ones to ZbLibrary

  Revision 1.2  2002/10/01 12:28:25  Vij
  Added a streamable class and utility functions to support read/write of
  string on TStreams.

  Revision 1.1.1.1  2002/09/11 21:11:42  Vij
  Starting Version Control


 ============================================================================}

unit ZZESupport;

interface

uses
  Windows,
  Classes,
  ZbScriptable,
  ZbGameUtils;

type

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZETileProperties = class (TObject)
  private
    FTileHeight: integer;
    FTileHalfHeight: integer;
    FTileWidth: integer;
    FTileHalfWidth: integer;
    FLevelHeight: integer;
    FTileGrid: PBoolean;
    FTileGridSize: integer;
  protected
    procedure InitTileGrid;
    procedure SetTileGridPos (X, Y: integer; bState: boolean = true);
    function GetTileGridPos (X, Y: integer): boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //
    property TileHeight: integer read FTileHeight;
    property TileHalfHeight: integer read FTileHalfHeight;
    property TileWidth: integer read FTileWidth;
    property TileHalfWidth: integer read FTileHalfWidth;
    property LevelHeight: integer read FLevelHeight;
    property TileGrid [X, Y: integer]: boolean read GetTileGridPos; default;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  {$WARNINGS OFF}
  TZEStreamable = class (TZbNamedClass)
  protected
    class function ReadChar (Source: TStream): Char;
    class function ReadString (Source: TStream): string;
    class procedure WriteString (cData: string; Dest: TStream);
  public
    constructor Create (Source: TStream); virtual;
    procedure Load (Source: TStream); virtual; abstract;
    procedure Save (Dest: TStream); virtual; abstract;
    //
    property Name;
  end;
  {$WARNINGS ON}


const
  __DirOffset: array [tdUnknown..tdNorthWest] of TPoint = (
    (X:0;Y:0), (X:4;Y:-2), (X:8;Y:0), (X:4;Y:2), (X:0;Y:4),
    (X:-4;Y:2), (X:-8;Y:0), (X:-4;Y:-2), (X:0;Y:-4));

    
var
  TileProps: TZETileProperties = NIL;


implementation

uses
  SysUtils,
  ZbUtils,
  ZZConstants,
  ZbConfigManager,
  ZbFileUtils,
  ZZETools;


{ TZETileProperties }

//////////////////////////////////////////////////////////////
constructor TZETileProperties.Create;
begin
  // have initial values for everything, just in case...
  FTileHeight     := 0;
  FTileHalfHeight := 0;
  FTileWidth      := 0;
  FTileHalfWidth  := 0;
  FLevelHeight    := 0;
  FTileGrid       := NIL;
  FTileGridSize   := 0;
  //
  // now load the configuration file...
  with ConfigManager do
    begin
      // get the values stored in the configuration file
      FTileHeight := ReadConfigInt (REZ_TILE_ENGINE_SECTION,
                        REZ_TENG_TILE_HEIGHT, REZ_TENG_TILE_HEIGHT_DEF);
      FTileWidth  := ReadConfigInt (REZ_TILE_ENGINE_SECTION,
                        REZ_TENG_TILE_WIDTH, REZ_TENG_TILE_WIDTH_DEF);
      FLevelHeight:= ReadConfigInt (REZ_TILE_ENGINE_SECTION,
                        REZ_TENG_LEVEL_HEIGHT, REZ_TENG_LEVEL_HEIGHT_DEF);
      // calculate the other values
      FTileHalfHeight := FTileHeight div 2;
      FTileHalfWidth := FTileWidth div 2;
      //
      FTileGridSize := FTileHeight * FTileWidth;
      FTileGrid := SafeAllocMem (FTileGridSize);
      InitTileGrid;
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
destructor TZETileProperties.Destroy;
begin
  if (FTileGrid <> NIL) then
    begin
      FreeMem (FTileGrid, FTileGridSize);
      FTileGrid := NIL;
    end;
  //
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETileProperties.InitTileGrid;
var
  iWLen, iHLen: integer;
  X, X2, Y: integer;
begin
  iWLen := FTileHalfWidth - 3;
  iHLen := FTileHalfHeight - 1;
  //
  for Y := 0 to iHLen do
    begin
      X2 := FTileWidth - 1;
      for X := 0 to iWLen do
        begin
          SetTileGridPos (X, Y, true);
          SetTileGridPos (X2, Y, true);
          Dec (X2);
        end;
      //
      Dec (iWLen, 2);
    end;
  //
  iWLen := 1;
  for Y := FTileHalfHeight + 1 to FTileHeight - 1 do
    begin
      X2 := FTileWidth - 1;
      for X := 0 to iWLen do
        begin
          SetTileGridPos (X, Y, true);
          SetTileGridPos (X2, Y, true);
          Dec (X2);
        end;
      //
      Inc (iWLen, 2);
    end;
  //
end;

//////////////////////////////////////////////////////////////////////////
procedure TZETileProperties.SetTileGridPos (X, Y: integer; bState: boolean);
var
  pTarget: PBoolean;
begin
  try
    pTarget := PBoolean (longint (FTileGrid) + (Y * FTileWidth) + X);
    pTarget^ := bState;
  except
  end;
end;

//////////////////////////////////////////////////////////////////////////
function TZETileProperties.GetTileGridPos (X, Y: integer): boolean;
var
  pTarget: PBoolean;
begin
  Result := false;
  try
    pTarget := PBoolean (longint (FTileGrid) + (Y * FTileWidth) + X);
    Result := NOT pTarget^;
  except
  end
end;



{ TZEStreamable }

//////////////////////////////////////////////////////////////////////////
constructor TZEStreamable.Create (Source: TStream);
begin
  inherited Create;
end;

//////////////////////////////////////////////////////////////////////////
class function TZEStreamable.ReadChar (Source: TStream): Char;
begin
  Result := LibReadChar (Source);
end;

//////////////////////////////////////////////////////////////////////////
class function TZEStreamable.ReadString (Source: TStream): string;
begin
  Result := LibReadString (Source);
end;

//////////////////////////////////////////////////////////////////////////
class procedure TZEStreamable.WriteString (cData: string; Dest: TStream);
begin
  LibWriteString (cData, Dest);
end;


end.

