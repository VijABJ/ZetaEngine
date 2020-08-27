{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZConstants.PAS
              Contains definitions of global constants and types
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Core/ZZConstants.pas,v 1.2 2002/10/01 12:27:37 Vij Exp $
  $Log: ZZConstants.pas,v $
  Revision 1.2  2002/10/01 12:27:37  Vij
  Remove reference to Entity file, only Entity folder is needed this time.

  Revision 1.1.1.1  2002/09/11 21:11:42  Vij
  Starting Version Control


 ============================================================================}
 
unit ZZConstants;

interface

uses Types;

const
  (* section names *)
  REZ_DIRECTX_SECTION           =   'DIRECTX';
  REZ_TILE_ENGINE_SECTION       =   'TILE_ENGINE';
  REZ_DATA_SECTION              =   'DATA';
  REZ_PATH_SECTION              =   'PATHS';
  REZ_SOUND_EFFECTS_SECTION     =   'SOUND_EFFECTS';
  REZ_MUSIC_SECTION             =   'MUSIC';
  REZ_TERRAIN_SECTION           =   'TERRAIN';
  REZ_WALLS_SECTION             =   'WALLS';

  (* these items in REZ_DIRECTX_SECTION *)
  REZ_DIRECTX_RESOLUTION        =   'Resolution';
  REZ_DIRECTX_EXCLUSIVE         =   'FullScreen';

  (* defaults for previous entries *)
  REZ_DX_RESOLUTION_DEF         =   '640,480,16';
  REZ_DIRECTX_EXCLUSIVE_DEF     =   TRUE;

  (* these items in REZ_TILE_ENGINE_SECTION *)
  REZ_TENG_TILE_WIDTH           =   'TileWidth';
  REZ_TENG_TILE_HEIGHT          =   'TileHeight';
  REZ_TENG_LEVEL_HEIGHT         =   'LevelHeight';

  (* defaults for previous set *)
  REZ_TENG_TILE_WIDTH_DEF       =   64;
  REZ_TENG_TILE_HEIGHT_DEF      =   31;
  REZ_TENG_LEVEL_HEIGHT_DEF     =   120;

  (* these items in section REZ_PATH_SECTION *)
  REZ_SND_EFX_PATH              =   'SoundEffects';
  REZ_MUSIC_PATH                =   'Music';
  REZ_SPRITE_CONFIG             =   'Sprites';
  REZ_ENTITY_FOLDER             =   'EntityFolder';

  (* defaults for previous entries *)
  REZ_SND_EFX_PATH_DEF          =   'Audio\Sounds\';
  REZ_MUSIC_PATH_DEF            =   'Audio\Music\';
  REZ_SPRITE_CONFIG_DEF         =   'Sprites.zcf';
  REZ_ENTITY_FOLDER_DEF         =   'SAMMS\';

  (* general entries *)
  REZ_ITEM_COUNT                =   'Count';
  REZ_ITEM_COUNT_DEF            =   0;


implementation


end.

