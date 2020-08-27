unit ZZEVirtualWorld;

interface

uses
  ZbScriptable;

type
  TZEVirtualWorldTile = class;

  //
  TZEVirtualWorldTile = class (TZbScriptable)
  private
  end;

  TZEVirtualWorldMap = class (TZbNamedClass)
  private
    FWorldTileSize: integer;
    FWorldWidth: integer;
    FWorldLength: integer;
  public
    constructor Create (AName: string; AWorldWidth, AWorldLength, AWorldTileSize: integer); virtual;
    destructor Destroy; override;
  end;

implementation

{ TZEVirtualWorldMap }


constructor TZEVirtualWorldMap.Create (AName: string; AWorldWidth, AWorldLength, AWorldTileSize: integer);
begin
  inherited Create;
  Name := AName;
  FWorldTileSize := AWorldTileSize;
  FWorldWidth := AWorldWidth;
  FWorldLength := AWorldLength;
end;

destructor TZEVirtualWorldMap.Destroy;
begin
  inherited;
end;


end.
