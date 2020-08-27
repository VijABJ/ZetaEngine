{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXAudio.PAS
              Contains DirectMusic Sound Effects Classes
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXAudio.pas,v 1.1.1.1 2002/09/11 21:08:54 Vij Exp $
  $Log: ZEDXAudio.pas,v $
  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXAudio;

interface

uses
  Windows,
  Classes,
  DirectMusic,
  //
  ZbStrIntf,
  ZbScriptable,
  ZbDoubleList;


type
  TZESoundSegment = class (TZbNamedClass)
  private
    FDM8Segment: IDirectMusicSegment8;
  protected
    procedure LoadFile (AFullFilename: string);
    procedure FreeSegment;
    function CheckValid: boolean;
  public
    constructor Create (AName, AFullFilename: string);
    destructor Destroy; override;
    //
    procedure Play;
    procedure Stop;
    //
    property Valid: boolean read CheckValid;
  end;

  TZESoundEffectsManager = class (TObject)
  private
    FSounds: TZbDoubleList;
    FVolume: longint;
  protected
    function GetSoundSegmentByName (AName: string): TZESoundSegment;
  public
    constructor Create (SrcPath: string; Items: IZbEnumStringList); 
    destructor Destroy; override;
    procedure UpdateVolume (iNewVolume: longint);
    //
    property QueryByName [AName: string]: TZESoundSegment
      read GetSoundSegmentByName; default;
    property Volume: longint read FVolume write UpdateVolume;
  end;


  function  DM8Init(_hWnd: hWnd; _reverb: boolean): boolean;
  procedure DM8Close;


var
  DM8Loader      : IDirectMusicLoader8 = NIL;      // File loader.
  DM8Performance : IDirectMusicPerformance8 = NIL; // The player.
  DM8AudioPath   : IDirectMusicAudioPath8 = NIL;   // Audio path.

  SoundFXMngr: TZESoundEffectsManager = NIL;


implementation

uses
  ActiveX,
  SysUtils,
  JclStrings,
  ZEDXCore;

{ TZESoundSegment }

//////////////////////////////////////////////////////////////////////////////
constructor TZESoundSegment.Create (AName, AFullFilename: string);
begin
  inherited Create;
  //
  FDM8Segment := NIL;
  Name := AName;
  LoadFile (AFullFilename);
end;

//////////////////////////////////////////////////////////////////////////////
destructor TZESoundSegment.Destroy;
begin
  FreeSegment;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundSegment.LoadFile (AFullFilename: string);
var
  wcFileName : array [0..MAX_PATH - 1] of WCHAR;
  HR: HResult;
begin
  FreeSegment;
  // Get filename in UNICODE
  MultiByteToWideChar(CP_ACP, 0, pChar(AFullFilename), -1, @wcFileName, MAX_PATH);
  //
  // load the file first...
  HR := DM8Loader.LoadObjectFromFile(
            CLSID_DirectMusicSegment,   // Class identifier.
            IID_IDirectMusicSegment8,   // ID of desired interface.
            wcFileName,                 // Filename.
            FDM8Segment);               // Pointer that receives interface.
  //
  // check the result of loading
  if (failed (HR)) then begin
    FDM8Segment := NIL;
    Exit;
  end;
  //
  // Downloads the band to the performance.
  HR := FDM8Segment.Download(DM8Performance);
  // if failed, NIL our interface
  if (failed (HR)) then
    FDM8Segment := NIL;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundSegment.FreeSegment;
begin
  if (Assigned (FDM8Segment)) then begin
    FDM8Segment.Unload (NIL);
    FDM8Segment := NIL;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundSegment.CheckValid: boolean;
begin
  Result := Assigned (FDM8Segment);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundSegment.Play;
var
  DMState: IDirectMusicSegmentState;
begin
  if (NOT Valid) then Exit;
  //
  DMState := NIL;
  DM8Performance.PlaySegment (FDM8Segment, DMUS_SEGF_SECONDARY, 0, @DMState);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundSegment.Stop;
begin
  if (NOT Valid) then Exit;
  DM8Performance.Stop (FDM8Segment, NIL, 0, 0);
end;

{ TZESoundEffectsManager }

//////////////////////////////////////////////////////////////////////////////
procedure __FreeSoundSegment (AData: Pointer);
begin
  if (AData <> NIL) then
    try TZESoundSegment (AData).Free; except end;
end;

//////////////////////////////////////////////////////////////////////////////
constructor TZESoundEffectsManager.Create (SrcPath: string; Items: IZbEnumStringList);
var
  cParams, cPath, cName: string;
  theSoundSegment: TZESoundSegment;
begin
  FVolume := DEFAULT_SOUND_VOLUME;
  FSounds := TZbDoubleList.Create (TRUE);
  FSounds.DisposeProc := __FreeSoundSegment;
  FSounds.Sorted := TRUE;
  //
  SrcPath := IncludeTrailingPathDelimiter (SrcPath);
  cParams := Items.First;
  while (cParams <> '') do begin
    cName := StrBefore ('=', cParams);
    cPath := StrAfter ('=', cParams);
    if ((cPath <> '') AND (cName <> '')) then begin
      theSoundSegment := TZESoundSegment.Create (cName, SrcPath + cPath);
      if (theSoundSegment = NIL) then continue;
      FSounds.Add (cName, Pointer (theSoundSegment));
    end;
    //
    cParams := Items.Next;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////////
destructor TZESoundEffectsManager.Destroy;
begin
  FSounds.Free;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundEffectsManager.GetSoundSegmentByName (AName: string): TZESoundSegment;
begin
  Result := TZESoundSegment (FSounds.Get (AName));
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundEffectsManager.UpdateVolume (iNewVolume: longint);
var
  volume: longint;
begin
  if (NOT Assigned (DM8AudioPath)) then Exit;
  if (iNewVolume <> FVolume) then begin
    FVolume := iNewVolume;
    //
    volume := (-MAX_VOLUME + FVolume);
    if (volume = -MAX_VOLUME) then
      volume := DM_MIN_VOLUME
    else
      volume := volume * (3000 div MAX_VOLUME);
    //
    DM8AudioPath.SetVolume (volume, 0);
  end;
end;


// ***************************************************************************
// *                                                                         *
// *            D I R E C T X  8   D I R E C T M U S I C                     *
// *                                                                         *
// ***************************************************************************

const
  DM8PERFORMANCE_CHANNELS = 16; // # of performance channels.

function  DM8Init(_hWnd: hWnd; _reverb: boolean): boolean;
var
  _guid : TGUID;
  _path : integer;
begin
  Result := false;

  // Initialize COM.
  if failed (CoInitialize(NIL)) then exit;

  // Create IDirectMusicLoader8 Interface.
  Move (IID_IDirectMusicLoader8, _guid, SizeOf(TGUID));
  if failed (CoCreateInstance(TGUID(CLSID_DirectMusicLoader),
            NIL, CLSCTX_INPROC, _guid, DM8Loader)) then exit;

  // Create IDirectMusicPerformance8 Interface.
  Move (IID_IDirectMusicPerformance8, _guid, SizeOf(TGUID));
  if failed (CoCreateInstance(TGUID(CLSID_DirectMusicPerformance),
            NIL, CLSCTX_INPROC, _guid, DM8Performance)) then exit;

  // Initialize the performance and the synthesizer.
  if _reverb
    then _path := DMUS_APATH_SHARED_STEREOPLUSREVERB
      else _path := DMUS_APATH_DYNAMIC_STEREO;
  if failed(DM8Performance.InitAudio(NIL, NIL, _hWnd, _path,
            DM8PERFORMANCE_CHANNELS, DMUS_AUDIOF_ALL, NIL)) then exit;

  // Retrieve audiopath set by InitAudio.
  if failed(DM8Performance.GetDefaultAudioPath(DM8AudioPath)) then exit;

  // All right.
  Result := true;
end;

procedure DM8Close;
begin
  // Close down the performance
  if assigned(DM8Performance) then DM8Performance.CloseDown;

  // Release all interfaces
  if assigned(DM8AudioPath) then DM8AudioPath := NIL;
  if assigned(DM8Performance) then DM8Performance := NIL;
  if assigned(DM8Loader) then DM8Loader := NIL;

  // Close COM
  CoUninitialize;
end;


end.

