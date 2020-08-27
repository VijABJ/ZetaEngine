{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZETemplateU.PAS
              The primary unit, and the guts, of the Zeta Engine
              Application Template
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header$
  $Log$

 ============================================================================}

unit ZETemplateU;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs;

type
  TfmTemplate = class(TForm)
  private
    procedure AppOnIdle(Sender: TObject; var Done: Boolean);
    procedure AppOnActivate(Sender: TObject);
    procedure AppOnDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmTemplate: TfmTemplate;

implementation

{$R *.dfm}

uses
  ZZEGameEngine;

//////////////////////////////////////////////////////////////////////////
// this function creates the user interface for the game.
// IT MUST BE PRESENT! otherwise, the program is unusable
{$IFDEF COMPLETED}
function CreateInitialGUI (lParam1, lParam2: integer): integer; stdcall;
begin
  Result := 0;
end;
{$ENDIF}

//////////////////////////////////////////////////////////////////////////
// this function handles any events that are not native to the engine
{$IFDEF COMPLETED}
function HandleUserEvents (lParam1, lParam2: integer): integer; stdcall;
begin
  Result := 0;
end;
{$ENDIF}

//////////////////////////////////////////////////////////////////////////
procedure TfmTemplate.FormActivate(Sender: TObject);
begin
  GameEngine.Initialize (Handle);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmTemplate.FormCreate(Sender: TObject);
begin
  // load up the engine, hopefully it's successful
  // NOTE: the configuration need not be the same filename indicated
  GameEngine := TZEGameEngine.Create ('Config\zeta.ini');

  // add callback to handle setting up of the GUI, etc.
  // THE CALLBACKS MUST EXIST!
  {$IFDEF COMPLETED}
  ScriptMaster.AddHandler (SCRIPT_GAME_GUI, CreateInitialGUI);
  ScriptMaster.AddHandler (SCRIPT_USER_EVENTS, HandleUserEvents);
  {$ENDIF}

  // hook up the system messages and funnel them to the engine
  Application.OnIdle       := AppOnIdle;
  Application.OnActivate   := AppOnActivate;
  Application.OnDeactivate := AppOnDeactivate;
  Application.OnRestore    := AppOnActivate;
  Application.OnMinimize   := AppOnDeActivate;

  // if the Engine is in exclusive mode, remove the window borders
  if (GameEngine.GameExclusive) then BorderStyle := bsNone;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmTemplate.FormDestroy(Sender: TObject);
begin
  // shutdown the engine
  FreeAndNIL (GameEngine);
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmTemplate.AppOnIdle(Sender: TObject; var Done: Boolean);
begin
  Done := false;
  if (GameEngine.Refresh) then Close;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmTemplate.AppOnActivate(Sender: TObject);
begin
  GameEngine.Mode := emPlayingGame;
  GameEngine.Activate;
end;

//////////////////////////////////////////////////////////////////////////
procedure TfmTemplate.AppOnDeactivate(Sender: TObject);
begin
  GameEngine.Deactivate;
end;



end.
