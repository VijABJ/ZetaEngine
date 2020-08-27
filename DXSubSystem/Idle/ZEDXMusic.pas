{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEDXMusic.PAS
              Contains the DirectShow Media Player class
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DXSubSystem/ZEDXMusic.pas,v 1.3 2002/12/01 14:48:35 Vij Exp $
  $Log: ZEDXMusic.pas,v $
  Revision 1.3  2002/12/01 14:48:35  Vij
  Minor code cleanup

  Revision 1.2  2002/11/02 06:40:37  Vij
  cleaned up FMusicPath.  was a memory leak.

  Revision 1.1.1.1  2002/09/11 21:08:54  Vij
  Starting Version Control


 ============================================================================}

unit ZEDXMusic;

interface

uses
  Windows,
  Classes,
  ActiveX,
  DirectShow,
  //
  ZbStrIntf,
  ZbDoubleList;


type
  TZEMusicManager = class (TObject)
  private
    FMusicList: TZbDoubleList;
    FMusicPath: PChar;
    //
    FVolume: longint;
    bInitialized: boolean;
    // DirectShow stuff.
    FGraphBuilder: IGraphBuilder;
    FMediaControl: IMediaControl;
    FMediaSeeking: IMediaSeeking;
    FMediaEventEx: IMediaEvent;
    FBasicAudio: IBasicAudio;
    FBasicVideo: IBasicVideo;
    FVideoWindow: IVideoWindow;
    // About the media file.
    AudioAvail: boolean;
    VideoAvail: boolean;
    ValidFile: boolean;
    // Video info.
    VideoWidth: longint;
    VideoHeight: longint;
    VideoBitRate: longint;
    //
    bPlaying: boolean;
    bLoaded: boolean;
  protected
    procedure PerformCleanup;
    function NameToFilename (AName: string): string;
    //
    function GetMusicPath: string;
    procedure SetMusicPath (AMusicPath: string);
    //
    property MusicPath: string read GetMusicPath write SetMusicPath;
  public
    constructor Create (SrcPath: string; Items: IZbEnumStringList); virtual;
    destructor Destroy; override;
    //
    function LoadFile (AMusicName: string): boolean;
    procedure Reset;
    procedure UpdateVolume (iNewVolume: longint);
    //
    procedure Play;
    procedure Pause;
    procedure Stop;
    //
    // properties
    property Playing: boolean read bPlaying;
    property Loaded: boolean read bLoaded;
    property Volume: longint read FVolume write UpdateVolume;
    //
    property GraphBuilder: IGraphBuilder read FGraphBuilder;
    property MediaControl: IMediaControl read FMediaControl;
    property MediaSeeking: IMediaSeeking read FMediaSeeking;
    property MediaEvent: IMediaEvent read FMediaEventEx;
    property BasicAudio: IBasicAudio read FBasicAudio;
    property BasicVideo: IBasicVideo read FBasicVideo;
    property VideoWindow: IVideoWindow read FVideoWindow;
  end;

var
  MusicMngr: TZEMusicManager = NIL;


implementation

uses
  SysUtils,
  StrUtils,
  JclStrings,
  //
  ZbStringUtils,
  //ZEDXDev,
  ZEDXCore;


//////////////////////////////////////////////////////////////////////////
constructor TZEMusicManager.Create (SrcPath: string; Items: IZbEnumStringList);
var
  cData, cName, cPath: string;
begin
  inherited Create;
  //
  FMusicList := TZbDoubleList.Create (TRUE);
  FMusicList.DisposeProc := __PCharFree;
  FMusicList.Sorted := TRUE;
  //
  FMusicPath := StrNew (PChar (SrcPath));
  FVolume := DEFAULT_MUSIC_VOLUME;
  //
  SrcPath := IncludeTrailingPathDelimiter (SrcPath);
  cData := Items.First;
  while (cData <> '') do begin
    cName := StrBefore ('=', cData);
    cPath := StrAfter ('=', cData);
    if ((cName <> '') AND (cPath <> '')) then
      FMusicList.Add (cName, StrNew (PChar (SrcPath + cPath)));
    //
    cData := Items.Next;
  end;
  //
  Reset;
end;

//////////////////////////////////////////////////////////////////////////
destructor TZEMusicManager.Destroy;
begin
  PerformCleanup;
  FMusicList.Free;
  if (FMusicPath <> NIL) then StrDispose (FMusicPath);
  inherited;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.PerformCleanup;
begin
  if (NOT bInitialized) then exit;
  if (bPlaying) then Stop;

  // Hide FVideoWindow and relinquish ownership.
  if Assigned(FVideoWindow) then begin
    FVideoWindow.put_Visible (false);
    FVideoWindow.put_Owner (0);
  end;

  // dispose of any other existing interfaces
  if Assigned(FMediaEventEx) then FMediaEventEx := NIL;
  if Assigned(FMediaSeeking) then FMediaSeeking := NIL;
  if Assigned(FMediaControl) then FMediaControl := NIL;
  if Assigned(FBasicAudio)   then FBasicAudio   := NIL;
  if Assigned(FBasicVideo)   then FBasicVideo   := NIL;
  if Assigned(FVideoWindow)  then FVideoWindow  := NIL;
  if Assigned(FGraphBuilder) then FGraphBuilder := NIL;
  // zero out everything
  Reset;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMusicManager.NameToFilename (AName: string): string;
var
  thePath: PChar;
begin
  thePath := PChar (FMusicList.Get (AName));
  Result := IfThen (thePath = NIL, '', String (thePath));
end;

//////////////////////////////////////////////////////////////////////////
function TZEMusicManager.GetMusicPath: string;
begin
  Result := IfThen (FMusicPath = NIL, '', String (FMusicPath));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.SetMusicPath (AMusicPath: string);
begin
  if (FMusicPath <> NIL) then StrDispose (FMusicPath);
  if (AMusicPath <> '') then
    FMusicPath := StrNew (PChar (AMusicPath))
    else FMusicPath := NIL;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.Reset;
begin
  bInitialized := false;
  // DirectShow stuff.
  FGraphBuilder := NIL;
  FMediaControl := NIL;
  FMediaSeeking := NIL;
  FMediaEventEx := NIL;
  FBasicAudio := NIL;
  FBasicVideo := NIL;
  FVideoWindow := NIL;
  // About the media file.
  AudioAvail := false;
  VideoAvail := false;
  ValidFile := false;
  // Video info.
  VideoWidth := 0;
  VideoHeight := 0;
  VideoBitRate := 0;
  //
  bPlaying := false;
  bLoaded := false;
end;

//////////////////////////////////////////////////////////////////////////
function TZEMusicManager.LoadFile (AMusicName: string): boolean;
var
  _wfn : array [0..MAX_PATH-1] of WChar;
  _vis : longBool;
  cFileName: string;
begin
  Result := FALSE;
  PerformCleanup;

  // translate name to filename
  cFileName := NameToFilename (AMusicName);
  if (cFileName = '') then exit;

  // Get unicode filename.
  MultiByteToWideChar(CP_ACP, 0, pChar(cFilename), -1, @_wfn, MAX_PATH);

  // Initialized.
  bInitialized := TRUE;

  // Create DirectShow Graph.
  if failed(CoCreateInstance(TGUID(CLSID_FilterGraph), NIL,
     CLSCTX_INPROC_SERVER,TGUID(IID_IGraphBuilder), FGraphBuilder))
            then exit;

  // Build the filter graph.
  if FAILED(FGraphBuilder.RenderFile(_wfn, NIL)) then exit;
  // Get the IMediaControl Interface
  if FAILED(FGraphBuilder.QueryInterface(IID_IMediaControl, FMediaControl)) then exit;
  // Get the IMediaSeeking Interface
  if FAILED(FGraphBuilder.QueryInterface(IID_IMediaSeeking, FMediaSeeking)) then exit;
  // Get the IMediaEventEx Interface
  if FAILED(FGraphBuilder.QueryInterface(IID_IMediaEventEx, FMediaEventEx)) then exit;
  // Get Audio and Video Interfaces.
  if FAILED(FGraphBuilder.QueryInterface(IID_IBasicAudio,  FBasicAudio)) then Exit;
  if FAILED(FGraphBuilder.QueryInterface(IID_IBasicVideo,  FBasicVideo)) then Exit;
  if FAILED(FGraphBuilder.QueryInterface(IID_IVideoWindow, FVideoWindow)) then Exit;
  // Get file info.
  AudioAvail := Assigned(FBasicAudio);
  VideoAvail := Assigned(FBasicVideo) and Assigned(FVideoWindow) and
                    (not failed(FVideoWindow.get_Visible(_vis)));
  ValidFile  := (AudioAvail) or (VideoAvail);

  // Get video info.
  if VideoAvail then begin
    FBasicVideo.GetVideoSize(VideoWidth, VideoHeight);
    FBasicVideo.get_BitRate(VideoBitRate);
  end;

  Result := ValidFile;
  if (Result) then begin
    bLoaded := TRUE;
    bPlaying := FALSE;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.UpdateVolume (iNewVolume: longint);
var
  volume: longint;
begin
  if (NOT Assigned (FBasicAudio)) then Exit;
  if (iNewVolume <> FVolume) then begin
    FVolume := iNewVolume;
    //
    volume := (-MAX_VOLUME + FVolume);
    if (volume = -MAX_VOLUME) then
      volume := DS_MIN_VOLUME
    else
      volume := volume * (3000 div MAX_VOLUME);
    //
    if (bPlaying) then
      FBasicAudio.Put_Volume(volume)
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.Play;
begin
  if ((bLoaded) AND (NOT bPlaying)) then begin
    //UpdateAudioVolume
    FMediaControl.Run;
    bPlaying := true;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.Pause;
begin
  if ((bLoaded) AND (bPlaying)) then begin
    FMediaControl.Pause;
    bPlaying := false;
  end;
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEMusicManager.Stop;
begin
  if ((bLoaded) AND (bPlaying)) then begin
    FMediaControl.Stop;
    bPlaying := false;
  end;
end;


(*

  NOTES:

You can set up notifications in 2 ways. The first way is by event triggers.
You can ask for an event handle that will be triggered when an event occurs,

  INSERT:
    use IMedieEvent.GetEventHandle(out hEvent: OAEVENT): HRESULT;
  :END INSERT

which you can use in a number of ways. You can use MsgWaitForMultipleObjects
in your main loop instead of GetMessage, or you can create a thread that calls
WaitForSingleObject that will wake when the event is triggered. The second
way we can set up notifications is by window messages. You can set a window
as the recipient of a window message when an event occurs. This is the way it
is done most of the time and the way we will use for our simple media player.

  INVESTIGATE:
    function CancelDefaultHandling(lEvCode: Longint): HRESULT; stdcall;
    function RestoreDefaultHandling(lEvCode: Longint): HRESULT; stdcall;
  :END INVESTIGATE

#define WM_GRAPHEVENT	WM_USER		// define a custom window message for graph events
HWND	g_AppWindow;			// applications main window

void SetNotifications()
{
	g_pMediaEvent->SetNotifyWindow((OAHWND)g_AppWindow, WM_GRAPHEVENT, 0);
	g_pMediaEvent->SetNotifyFlags(0);	// turn on notifications
}

 
In our WindowProc we add some code to handle the notifications: 

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_GRAPHEVENT:
		OnGraphEvent();		// handles events
		break;
	default:
		break;
	}
	return DefWindowProc(hwnd, uMsg, lParam, wParam);
}

 
Once we receive a graph event, we must do a few things. DirectShow stores
some data for events internally, so that memory must be freed once we are
done reacting to the event. Also, a window message is sent only once when
the event queue goes from being empty to having messages in it, so we must
handle all pending events. Here is the code that would get called from the
above WindowProc:

void OnGraphEvent()
{
	long EventCode, Param1, Param2;
	while (g_pMediaEvent->GetEvent(&EventCode, &Param1, &Param2, 0) != E_ABORT)
	{
		switch (EventCode)
		{
		// react to specific events here
		default:
			break;
		}	
		g_pMediaEvent->FreeEventParams(EventCode, Param1, Param2);
	}
}


Now we're pretty much ready for playback. Once we know what file we wish to
play, we ask IGraphBuilder to create a suitable filter graph for it:

int CreateGraph(char* filename)
{
	int	length;		// length of filename
	WCHAR*	wfilename;	// where we store WCHAR version of filename

	length = strlen(filename)+1;
	wfilename = new WCHAR[length];
	MultiByteToWideChar(CP_ACP, 0, filename, -1, wfilename, length);
	if (FAILED(g_pGraphBuilder->RenderFile(wfilename, NULL))
		return -1;
	else
		return 0;
}

 
Note that RenderFile only accepts WCHAR strings, so we have to convert if
we are using ANSI char strings. If FGraphBuilder successfully creates a agraph
for our media, we can start playing it like so: 

g_pMediaControl->Run();


When the graph is in a running state, it stays in the running state even
when all data has been passed through the graph. When the EC_COMPLETE
notification is sent, all data has passed through all filters and they are
now waiting for more data. If you look at event handling code in our media
player, you will see this:

switch (EventCode)
{
	case EC_COMPLETE:            
		// here when media is completely done playing
		if (!g_Looping)
	        	g_pMediaControl->Stop();
               	g_pMediaPosition->put_CurrentPosition(0);   // reset to beginning
		break;
	default:
		break;
}

 
Note that we don't need to call IMediaControl::Run() again after setting the
position back to the beginning of the media in order to loop it. Also, we
need to explicitly call IMediaControl::Stop() when we hit EC_COMPLETE. This
isn't necessary, but it helps us to better keep DirectShow under control.  



*)


end.
