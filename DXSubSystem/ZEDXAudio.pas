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
  ZblDictionary,
  ZblIStrings,
  ZblIAudio,
  //
  ZbDI8SoundMain,
  ZbDS8Monitor,
  //
  ZbScriptable,
  ZbDoubleList;


type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEFileNameManager = class (TZbStrPairDictionary)
  public
    procedure LoadFileList (SrcPath: String; Items: IZbEnumStrings);
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESoundFXManager = class (TZEFileNameManager)
  private
    m_Volume: Integer;
  protected
    procedure AfterCreate; override;
    function CreateData (AData: String): Pointer; override;
  public
    procedure Play (AName: PChar; AVolume: Integer = 0);
    function Initialized: LongBool;
    //
    property Volume: Integer read m_Volume write m_Volume;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESoundManager = class
  private
    m_SoundList: TZbDoubleList;
    m_Volume: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure LoadFileList (SrcPath: string; Items: IZbEnumStrings);
    procedure Play (AName: PChar; AVolume: Integer = 0; ALoop: Integer = 1); virtual;
    function Initialized: LongBool;
    //
    property Volume: Integer read m_Volume write m_Volume;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMusicManager = class (TZESoundManager)
  private
    m_TheName: PChar;
  public
    procedure Stop;
    procedure Play (AName: PChar; AVolume: Integer = 0; ALoop: Integer = 1); override;
    procedure ResetNewVolume (AVolume: Integer = 100);
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

var
  g_AudioManager: TZbAudioManager = NIL;
  g_SoundFXMngr: TZESoundFXManager = NIL;
  g_MusicMngr: TZEMusicManager = NIL;
  g_DS8Thread: TZbDS8Thread = NIL;


implementation

uses
  ActiveX,
  SysUtils,
  JclStrings,
  //
  ZblClasses,
  ZEDXCore;


{ TZEFileNameManager }

//////////////////////////////////////////////////////////////////////////////
procedure TZEFileNameManager.LoadFileList (SrcPath: String; Items: IZbEnumStrings);
begin
  LoadFrom (PChar (SrcPath), Items);
end;


{ TZESoundFXManager }

type
  TZEFX = class
  private
    m_FileName: PChar;
    m_Channel: TZbSoundChannel;
  public
    constructor Create (AFileName: PChar);
    destructor Destroy; override;
    procedure Play (AVolume: Integer);
  end;

  ////////////////////////////////////////////////////////////////////////////
  constructor TZEFX.Create (AFileName: PChar);
  begin
    m_FileName := StrNew (AFileName);
    g_AudioManager.SoundChannelCreate (m_Channel);
  end;

  ////////////////////////////////////////////////////////////////////////////
  destructor TZEFX.Destroy;
  begin
    m_Channel.Stop;
    FreeAndNIL (m_Channel);
    StrDispose (m_FileName);
  end;
  ////////////////////////////////////////////////////////////////////////////
  procedure TZEFX.Play (AVolume: Integer);
  begin
    m_Channel.Stop;
    m_Channel.PlayFromFile (m_FileName, AVolume);
  end;


//////////////////////////////////////////////////////////////////////////////
procedure TZESoundFXManager.AfterCreate;
begin
  SetDisposeProc (__DeleteObject);
  m_Volume := 100;
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundFXManager.CreateData (AData: String): Pointer;
begin
  Result := Pointer (TZEFX.Create (PChar (AData)));
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundFXManager.Play (AName: PChar; AVolume: Integer);
var
  FX: TZEFX;
begin
  FX := TZEFX (__Get (AName));
  if (FX = NIL) then Exit;
  //
  if (AVolume <= 0) then AVolume := m_Volume;
  FX.Play (AVolume);
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundFXManager.Initialized: LongBool;
begin
  Result := (g_AudioManager <> NIL);
end;


{ TZESoundManager }

//////////////////////////////////////////////////////////////////////////////
constructor TZESoundManager.Create;
begin
  inherited;

  // IMPORTANT: Create the DirectShow thread if not already present
  if (g_DS8Thread = NIL) then g_DS8Thread := TZbDS8Thread.Create;

  // create the list
  m_Volume := DEFAULT_SOUND_VOLUME;
  m_SoundList := TZbDoubleList.Create (TRUE);
  m_SoundList.DisposeProc := __DeletePChar;
  m_SoundList.Sorted := TRUE;
  //
end;

//////////////////////////////////////////////////////////////////////////////
destructor TZESoundManager.Destroy;
begin
  FreeAndNIL (m_SoundList);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundManager.LoadFileList (SrcPath: string; Items: IZbEnumStrings);
var
  cParams, cPath, cName, cFileName: string;
begin
  SrcPath :=
    IncludeTrailingPathDelimiter (GetCurrentDir) +
    IncludeTrailingPathDelimiter (SrcPath);
  cParams := Items.First;
  //
  while (cParams <> '') do begin
    cName := StrBefore ('=', cParams);
    cPath := StrAfter ('=', cParams);
    //
    if ((cPath <> '') AND (cName <> '')) then begin
      cFileName := SrcPath + cPath;
      if (NOT FileExists (cFileName)) then continue;
      m_SoundList.Add (cName, StrNew (PChar (cFileName)));
    end;
    //
    cParams := Items.Next;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundManager.Play (AName: PChar; AVolume, ALoop: Integer);
var
  cFileName: PChar;
begin
  cFileName := PChar (m_SoundList.Get (AName));
  if (cFileName = NIL) then Exit;

  if (AVolume <= 0) then AVolume := m_Volume;
  g_DS8Thread.PlayMedia(AName, cFileName, AVolume, ALoop);
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundManager.Initialized: LongBool;
begin
  Result := Assigned (g_DS8Thread);
end;


{ TZEMusicManager }

const
  BACKGROUND_MUSIC_TAG = '$$BACKGROUND$$';

//////////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.Stop;
begin
  g_DS8Thread.Stop (BACKGROUND_MUSIC_TAG);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.Play (AName: PChar; AVolume, ALoop: Integer);
var
  cFileName: PChar;
begin
  cFileName := PChar (m_SoundList.Get (String (AName)));
  if (cFileName = NIL) then Exit;
  //
  m_TheName := cFileName;
  if (AVolume <= 0) then AVolume := m_Volume;
  g_DS8Thread.PlayMedia (BACKGROUND_MUSIC_TAG, m_TheName, AVolume, 0);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.ResetNewVolume (AVolume: Integer);
begin
  Stop;
  if (AVolume <= 0) then AVolume := m_Volume;
  g_DS8Thread.PlayMedia (BACKGROUND_MUSIC_TAG, m_TheName, AVolume, 0);
end;


initialization

finalization
  if (g_DS8Thread <> NIL) then begin
    g_DS8Thread.Shutdown;
    g_DS8Thread := NIL;
  end;

end.

