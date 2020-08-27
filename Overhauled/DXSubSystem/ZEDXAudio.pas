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
  ZblIAudio,
  //
  ZbStrIntf,
  ZbScriptable,
  ZbDoubleList;


type
  TZESoundEffectsManager = class
  private
    m_SoundList: TZbDoubleList;
    m_Volume: Integer;
  protected
    function GetSoundChannel (AName: string): IZbSoundChannel;
    procedure SetVolume (iNewVolume: Integer);
    function GetVolume: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure Init (AWinHandle: HWND; AReverb: LongBool = TRUE);
    procedure LoadFileList (SrcPath: string; Items: IZbEnumStringList);
    //
    procedure PlayFile (AName: String; AVolume: Integer = 0; ALoop: Integer = 1);
    function Initialized: LongBool;
    //
    property _Sounds [AName: string]: IZbSoundChannel read GetSoundChannel; default;
    property Volume: Integer read GetVolume write SetVolume;
  end;



var
  g_SoundFXMngr: TZESoundEffectsManager = NIL;
  g_AudioManager: IZbAudioManager = NIL;


implementation

uses
  ActiveX,
  SysUtils,
  JclStrings,
  ZEDXCore;


type
  PZbSoundChannelInfo = ^TZbSoundChannelInfo;
  TZbSoundChannelInfo = record
    m_Channel: IZbSoundChannel;
    m_FileName: PChar;
  end;

  ////////////////////////////////////////////////////////////////////////////
  function CreateSoundChannelInfo (AFileName: PChar;
    ASoundChannel: IZbSoundChannel): PZbSoundChannelInfo;
  begin
    New (Result);
    Result.m_FileName := StrNew (AFileName);
    Result.m_Channel := ASoundChannel;
  end;

  ////////////////////////////////////////////////////////////////////////////
  procedure DisposeSoundChannelInfo (ASoundChannelInfo: PZbSoundChannelInfo);
  begin
    if (ASoundChannelInfo = NIL) then Exit;
    try
      with ASoundChannelInfo^ do begin
        if (m_Channel <> NIL) then m_Channel.Stop;
        m_Channel := NIL;
        StrDispose (m_FileName);
      end;
      Dispose (ASoundChannelInfo);
    except
    end;
  end;

  ////////////////////////////////////////////////////////////////////////////
  function ZbLib_GetAudioManagerIntf (out AudioManagerIntf: IZbAudioManager): LongBool; stdcall;
    external 'ZbAudioDI8' name 'ZbLib_GetAudioManagerIntf';


{ TZESoundEffectsManager }

//////////////////////////////////////////////////////////////////////////////
procedure __FreeSoundChannelInfo (AData: Pointer);
begin
  if (AData <> NIL) then
    DisposeSoundChannelInfo (PZbSoundChannelInfo (AData));
end;

//////////////////////////////////////////////////////////////////////////////
constructor TZESoundEffectsManager.Create;
begin
  inherited;

  // obtain the audio manager interface, this is IMPORTANT!
  ZbLib_GetAudioManagerIntf (g_AudioManager);

  // create the list
  m_Volume := DEFAULT_SOUND_VOLUME;
  m_SoundList := TZbDoubleList.Create (TRUE);
  m_SoundList.DisposeProc := __FreeSoundChannelInfo;
  m_SoundList.Sorted := TRUE;
  //
end;

//////////////////////////////////////////////////////////////////////////////
destructor TZESoundEffectsManager.Destroy;
begin
  FreeAndNIL (m_SoundList);
  g_AudioManager := NIL;
  inherited;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundEffectsManager.Init (AWinHandle: HWND; AReverb: LongBool);
begin
  g_AudioManager.Init (AWinHandle, AReverb, SND_MNGR_DEF_FREQUENCY, SND_MNGR_DEF_CHANNELS);
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundEffectsManager.LoadFileList (SrcPath: string; Items: IZbEnumStringList);
var
  cParams, cPath, cName, cFileName: string;
  Channel: IZbSoundChannel;
  SCI: PZbSoundChannelInfo;
begin
  SrcPath := IncludeTrailingPathDelimiter (SrcPath);
  cParams := Items.First;
  //
  while (cParams <> '') do begin
    cName := StrBefore ('=', cParams);
    cPath := StrAfter ('=', cParams);
    //
    if ((cPath <> '') AND (cName <> '')) then begin
      cFileName := SrcPath + cPath;
      g_AudioManager.CreateSoundChannel (Channel);
      //
      if (Channel <> NIL) then begin
        SCI := CreateSoundChannelInfo (PChar (cFileName), Channel);
        Channel._AddRef;
        m_SoundList.Add (cName, SCI);
      end;
      //
    end;
    //
    cParams := Items.Next;
  end;
  //
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundEffectsManager.GetSoundChannel (AName: string): IZbSoundChannel;
var
  SCI: PZbSoundChannelInfo;
begin
  SCI := PZbSoundChannelInfo (m_SoundList.Get (AName));
  if (SCI = NIL) then
    Result := NIL
    else Result := SCI.m_Channel;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundEffectsManager.SetVolume (iNewVolume: Integer);
begin
  if (NOT Assigned (g_AudioManager)) then Exit;
  g_AudioManager.SetVolume (iNewVolume);
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundEffectsManager.GetVolume: Integer;
begin
  if (NOT Assigned (g_AudioManager)) then
    Result := 0
    else Result := g_AudioManager.GetVolume;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TZESoundEffectsManager.PlayFile (AName: String; AVolume, ALoop: Integer);
var
  SCI: PZbSoundChannelInfo;
begin
  SCI := PZbSoundChannelInfo (m_SoundList.Get (AName));
  if (SCI <> NIL) then begin
    if (AVolume <= 0) then AVolume := m_Volume;
    SCI.m_Channel.PlayFromFile (SCI.m_FileName, AVolume, ALoop);
  end;
end;

//////////////////////////////////////////////////////////////////////////////
function TZESoundEffectsManager.Initialized: LongBool;
begin
  Result := Assigned (g_AudioManager);
end;


end.

