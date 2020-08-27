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
  ZblIAudio,
  ZbDS8Monitor,
  //
  ZbStrIntf,
  ZbScriptable,
  ZbDoubleList;


type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZESoundManager = class
  private
    m_SoundList: TZbDoubleList;
    m_Volume: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure LoadFileList (SrcPath: string; Items: IZbEnumStringList);
    procedure PlayFile (AName: PChar; AVolume: Integer = 0; ALoop: Integer = 1); virtual;
    function Initialized: LongBool;
    //
    property Volume: Integer read m_Volume write m_Volume;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEMusicManager = class (TZESoundManager)
  public
    procedure Stop;
    procedure PlayFile (AName: PChar; AVolume: Integer = 0; ALoop: Integer = 1); override;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

var
  g_SoundFXMngr: TZESoundManager = NIL;
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
procedure TZESoundManager.LoadFileList (SrcPath: string; Items: IZbEnumStringList);
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
procedure TZESoundManager.PlayFile (AName: PChar; AVolume, ALoop: Integer);
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
procedure TZEMusicManager.PlayFile (AName: PChar; AVolume, ALoop: Integer);
var
  cFileName: PChar;
begin
  cFileName := PChar (m_SoundList.Get (String (AName)));
  if (cFileName = NIL) then Exit;

  if (AVolume <= 0) then AVolume := m_Volume;
  g_DS8Thread.PlayMedia(BACKGROUND_MUSIC_TAG, cFileName, AVolume, 0);
end;


initialization

finalization
  if (g_DS8Thread <> NIL) then begin
    g_DS8Thread.Shutdown;
    g_DS8Thread := NIL;
  end;

end.

