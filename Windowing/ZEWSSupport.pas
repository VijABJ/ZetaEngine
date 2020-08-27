{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZEWSSupport.PAS
              Contains support routines and classes for the windowing system
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Windowing/ZEWSSupport.pas,v 1.4 2002/12/18 08:14:00 Vij Exp $
  $Log: ZEWSSupport.pas,v $
  Revision 1.4  2002/12/18 08:14:00  Vij
  code cleanup

  Revision 1.3  2002/11/02 06:48:57  Vij
  added dividers

  Revision 1.2  2002/10/01 12:38:10  Vij
  Changed GUIManager so that it now receives a reference to the sprite
  factory if can use to create UI Graphical Elements.  This removes the
  dependency to a global sprite factory.

  Revision 1.1.1.1  2002/09/11 21:10:14  Vij
  Starting Version Control


 ============================================================================}

unit ZEWSSupport;

interface

uses
  Windows,
  Graphics,
  Classes,
  DirectDraw,
  //
  ZblIStrings,
  ZbDoubleList,
  ZbScriptable,
  //
  ZEDXImage,
  ZEDXSpriteIntf;

const
  (* sections used by this module *)
  REZ_GUI_MNGR_SECTION      =   'GUI_MANAGER';
  REZ_GUI_FONTS_SECTION     =   'GUI_FONTS';

  (* entries in REZ_GUI_MNGR_SECTION *)
  REZ_GM_BTN_DARK_SHADE     =   'ButtonDarkShade';
  REZ_GM_BTN_LIGHT_SHADE    =   'ButtonLightShade';

  (* defaults in REZ_GUI_MNGR_SECTION *)
  REZ_GM_BTN_DARK_SHADE_DEF =   '80807F';
  REZ_GM_BTN_LIGHT_SHADE_DEF=   'DBDBDB';


type

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEVAlign = (vaTop, vaCenter, vaBottom);
  TZEHAlign = (vhLeft, vhCenter, vhRight);

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  {$WARNINGS OFF}
  TZEFont = class (TZbNamedClass)
  private
    hFont: HFONT;
    FHeight: integer;
    FWeight: integer;
    dwItalic: DWORD;
    dwUnderline: DWORD;
    dwStrikeOut: DWORD;
    bMultiLine: boolean;
    FTypeFaceName: PChar;
    rgbText: TColorRef;
    FVAlign: TZEVAlign;
    FHAlign: TZEHAlign;
    bLocked: boolean;
  protected
    procedure ClearFont;
    procedure FontChanged; virtual;
    procedure BeginUpdate;
    procedure EndUpdate;
    //
    function GetFontName: string;
    procedure SetFontName (const AFontName: string);
    //
    function GetItalic: boolean;
    procedure SetItalic (bActivate: boolean);
    function GetUnderline: boolean;
    procedure SetUnderline (bActivate: boolean);
    function GetStrikeOut: boolean;
    procedure SetStrikeOut (bActivate: boolean);
    function GetBold: boolean;
    procedure SetBold (bActivate: boolean);
    procedure SetHeight (AHeight: integer);
    //
  public
    constructor Create (AHeight: integer; AName, AFaceName: string); virtual;
    destructor Destroy; override;
    //
    function Duplicate: TZEFont;
    //
    procedure WriteText (ASurface: IDirectDrawSurface7; AText: string; pAnchor: TPoint); overload;
    procedure WriteText (DC: HDC; AText: string; pAnchor: TPoint); overload;
    procedure WriteText (ASurface: IDirectDrawSurface7; AText: string; AArea: TRect); overload;
    procedure WriteText (DC: HDC; AText: string; AArea: TRect); overload;
    //
    // properties
    property Name;
    property FontName: string read GetFontName write SetFontName;
    property Color: TColorRef read rgbText write rgbText;
    property Italic: boolean read GetItalic write SetItalic;
    property Underline: boolean read GetUnderline write SetUnderline;
    property StrikeOut: boolean read GetStrikeOut write SetStrikeOut;
    property Bold: boolean read GetBold write SetBold;
    property MultiLine: boolean read bMultiLine write bMultiLine;
    property Height: integer read FHeight write SetHeight;
    property VAlignment: TZEVAlign read FVAlign write FVAlign;
    property HAlignment: TZEHAlign read FHAlign write FHAlign;
    property FontHandle: HFONT read hFont;
  end;
  {$WARNINGS ON}

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEFontList = class (TObject)
  private
    FAliases: TZbDoubleList;
    FFonts: TZbDoubleList;
    FUseAliases: boolean;
    //
    procedure CommonInit;
  protected
    function GetFontByIndex (iIndex: integer): TZEFont;
    function GetFontByName (AName: PChar): TZEFont;
    function GetName (iIndex: integer): string;
    function TranslateAliasToName (AAlias: PChar): PChar;
    function RetrieveByName (AName: string): TZEFont;
    function GetFontCount: integer;
    //
    procedure AddFontNames (FontNames: IZbEnumStrings);
    procedure AddEntry (cEntry: string);
    procedure AddAlias (AAlias, AName: string);
    procedure AddFont (cParam: string); overload;
    procedure AddFont (AName, AFaceName: string; AHeight: integer;
      bBold, bItalic, bUnderline, bStrikeOut: boolean; hAlign: TZEHAlign;
      vAlign: TZEVAlign; rgbColor: TColorRef); overload;
  public
    constructor Create (AConfigFile: string = 'Fonts.cfg'); overload; virtual;
    constructor Create (FontNames: IZbEnumStrings); overload; virtual;
    destructor Destroy; override;
    // properties
    property UseAliases: boolean read FUseAliases write FUseAliases;
    property Fonts [iIndex: integer]: TZEFont read GetFontByIndex;
    property Name [iIndex: integer]: string read GetName;
    property FontByName [AName: string]: TZEFont read RetrieveByName; default;
    property Count: integer read GetFontCount;
  end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  TZEGUIManager = class (TObject)
  private
    FFonts: TZEFontList;              // fonts source
    FBtnDarkShade: TColorRef;         // dark shade color
    FBtnLightShade: TColorRef;        // light shade color
    FDarkPen: HPen;                   // pen to use for dark shades
    FLightPen: HPen;                  // pen to use for light shades
    FSpriteSource: IZESpriteFactory;  // source of sprite
  protected
    function GetFontByName (AFontName: string): TZEFont;
  public
    constructor Create (ASpriteSource: IZESpriteFactory); virtual;
    destructor Destroy; override;
    //
    function CreateSprite (AFamilyName, ASubClassName: string): IZESprite;
    //
    property Fonts [AFontName: string]: TZEFont read GetFontByName; default;
    property BtnDarkShade: TColorRef read FBtnDarkShade;
    property BtnLightShade: TColorRef read FBtnLightShade;
    property DarkPen: HPen read FDarkPen;
    property LightPen: HPen read FLightPen;
  end;


  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  procedure DecodeFontSpec (cParam: string;
    var cName, cFaceName: string; var FHeight: integer;
    var bIsBold, bIsItalic, bIsUnderLine, bIsStrikeOut: boolean;
    var iHAlignOrd, iVAlignOrd: integer; var Color: TColor);
  function EncodeFontSpec (cName, cFaceName: string; FHeight: integer;
    bIsBold, bIsItalic, bIsUnderLine, bIsStrikeOut: boolean;
    iHAlignOrd, iVAlignOrd: integer; Color: TColor): string;



var
  GUIManager: TZEGUIManager = NIL;


implementation

uses
  SysUtils,
  StrUtils,
  JclStrings,
  //
  ZblConfigMngr,
  ZbStringUtils,
  ZEDXFramework,
  ZEDXCore;
  

//////////////////////////////////////////////////////////
const
  VA: array [0..2] of TZEVAlign = (vaTop, vaCenter, vaBottom);
  HA:  array [0..2] of TZEHAlign = (vhLeft, vhCenter, vhRight);

{ TZEFont }

//////////////////////////////////////////////////////////
constructor TZEFont.Create (AHeight: integer; AName, AFaceName: string);
begin
  inherited Create;
  //
  Name := AName;
  hFont := 0;
  FHeight := AHeight;
  //
  FWeight := FW_NORMAL;
  dwItalic := 0;
  dwUnderline := 0;
  dwStrikeOut := 0;
  bMultiLine := false;
  //
  FTypeFaceName := StrNew (PChar (AFaceName));
  rgbText := $FFFFFF;
  FVAlign := vaTop;
  FHAlign := vhLeft;
  //
  bLocked := false;
  FontChanged;
end;

//////////////////////////////////////////////////////////
destructor TZEFont.Destroy;
begin
  ClearFont;
  StrDispose (FTypeFaceName);
  inherited;
end;

//////////////////////////////////////////////////////////
procedure TZEFont.ClearFont;
begin
  if (hFont <> 0) then begin
    DeleteObject (hFont);
    hFont := 0;
  end;
end;

//////////////////////////////////////////////////////////
procedure TZEFont.FontChanged;
begin
  if (bLocked) then exit;
  ClearFont;
  //
  if (FontName = '') then
    hFont := 0
  else
    hFont := CreateFont (FHeight, 0, 0, 0, FWeight,
      dwItalic, dwUnderline, dwStrikeOut, DEFAULT_CHARSET,
      OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
      PROOF_QUALITY, FF_DONTCARE AND DEFAULT_PITCH,
      PChar (FontName));
end;

//////////////////////////////////////////////////////////
procedure TZEFont.BeginUpdate;
begin
  bLocked := true;
end;

//////////////////////////////////////////////////////////
procedure TZEFont.EndUpdate;
begin
  bLocked := false;
  FontChanged;
end;

//////////////////////////////////////////////////////////
function TZEFont.GetFontName: string;
begin
  Result := IfThen (FTypeFaceName = NIL, '', String (FTypeFaceName));
end;

//////////////////////////////////////////////////////////
procedure TZEFont.SetFontName (const AFontName: string);
begin
  if (FTypeFaceName <> NIL) then StrDispose (FTypeFaceName);
  if (AFontName <> '') then
    FTypeFaceName := StrNew (PChar (AFontName))
    else FTypeFaceName := NIL;
  //
  FontChanged;
end;

//////////////////////////////////////////////////////////
function TZEFont.GetItalic: boolean;
begin
  Result := (dwItalic <> 0);
end;

//////////////////////////////////////////////////////////
procedure TZEFont.SetItalic (bActivate: boolean);
begin
  if (bActivate AND (dwItalic = 0)) then begin
    dwItalic := 1;
    FontChanged;
  end else if ((NOT bActivate) AND (dwItalic <> 0)) then begin
    dwItalic := 0;
    FontChanged;
  end;
end;

//////////////////////////////////////////////////////////
function TZEFont.GetUnderline: boolean;
begin
  Result := (dwUnderline <> 0);
end;

//////////////////////////////////////////////////////////
procedure TZEFont.SetUnderline (bActivate: boolean);
begin
  if (bActivate AND (dwUnderline = 0)) then begin
    dwUnderline := 1;
    FontChanged;
  end else if ((NOT bActivate) AND (dwUnderline <> 0)) then begin
    dwUnderline := 0;
    FontChanged;
  end;
end;

//////////////////////////////////////////////////////////
function TZEFont.GetStrikeOut: boolean;
begin
  Result := (dwStrikeOut <> 0);
end;

//////////////////////////////////////////////////////////
procedure TZEFont.SetStrikeOut (bActivate: boolean);
begin
  if (bActivate AND (dwStrikeOut = 0)) then begin
    dwStrikeOut := 1;
    FontChanged;
  end else if ((NOT bActivate) AND (dwStrikeOut <> 0)) then begin
    dwStrikeOut := 0;
    FontChanged;
  end;
end;

//////////////////////////////////////////////////////////
function TZEFont.GetBold: boolean;
begin
  Result := (FWeight = FW_BOLD);
end;

//////////////////////////////////////////////////////////
procedure TZEFont.SetBold (bActivate: boolean);
begin
  if (bActivate AND (FWeight <> FW_BOLD)) then begin
    FWeight := FW_BOLD;
    FontChanged;
  end else if (NOT bActivate) AND (FWeight = FW_BOLD) then begin
    FWeight := FW_NORMAL;
    FontChanged;
  end;
end;

//////////////////////////////////////////////////////////
procedure TZEFont.SetHeight (AHeight: integer);
begin
  if (FHeight <> AHeight) then begin
    FHeight := AHeight;
    FontChanged;
  end;
end;

//////////////////////////////////////////////////////////
function TZEFont.Duplicate: TZEFont;
var
  TempFont: TZEFont;
begin
  Result := NIL;
  TempFont := TZEFont.Create (FHeight, Name, FontName);
  if (TempFont <> NIL) then begin
    TempFont.BeginUpdate;
    //
    TempFont.FHeight := FHeight;
    TempFont.FWeight := FWeight;
    TempFont.dwItalic := dwItalic;
    TempFont.dwUnderline := dwUnderline;
    TempFont.dwStrikeOut := dwStrikeOut;
    TempFont.rgbText := rgbText;
    TempFont.FVAlign := FVAlign;
    TempFont.FHAlign := FHAlign;
    //
    TempFont.EndUpdate;
    //
    Result := TempFont;
  end;
end;


//////////////////////////////////////////////////////////////////////////
procedure TZEFont.WriteText (ASurface: IDirectDrawSurface7;
  AText: string; pAnchor: TPoint);
begin
  WriteText (ASurface, AText, Rect (pAnchor.X, pAnchor.Y, pAnchor.X, pAnchor.Y));
end;

//////////////////////////////////////////////////////////////////////////
procedure TZEFont.WriteText (DC: HDC; AText: string; pAnchor: TPoint);
begin
  WriteText (DC, AText, Rect (pAnchor.X, pAnchor.Y, pAnchor.X, pAnchor.Y));
end;

//////////////////////////////////////////////////////////
procedure TZEFont.WriteText (ASurface: IDirectDrawSurface7;
      AText: string; AArea: TRect);
var
  hdcSurface: HDC;
begin
  if ((ASurface <> NIL) AND (ASurface.GetDC (hdcSurface) = DD_OK)) then begin
    WriteText (hdcSurface, AText, AArea);
    ASurface.ReleaseDC (hdcSurface);
  end;
end;

//////////////////////////////////////////////////////////
procedure TZEFont.WriteText (DC: HDC; AText: string; AArea: TRect);
var
  iFormat: integer;
  dispSize: TSize;
begin
  if ((hFont <> 0) AND (DC <> 0)) then begin
    SelectObject (DC, hFont);
    SetBkMode (DC, TRANSPARENT);
    SetTextColor (DC, rgbText);
    //
    // get the space required by the text to draw, and adjust the rectangle
    // given if necessary...
    GetTextExtentPoint32 (DC, PChar (AText), Length (AText), dispSize);
    if (AArea.Right = AArea.Left) then Inc (AArea.Left, dispSize.cX + 5);
    if (AArea.Bottom = AArea.Top) then Inc (AArea.Bottom, dispSize.cY + 5);
    //
    iFormat := 0;
    //
    case FHAlign of
      vhLeft:       iFormat := iFormat OR DT_LEFT;
      vhCenter:     iFormat := iFormat OR DT_CENTER;
      vhRight:      iFormat := iFormat OR DT_RIGHT;
    end;
    //
    case FVAlign of
      vaTop:        iFormat := iFormat OR DT_TOP;
      vaCenter:     iFormat := iFormat OR DT_VCENTER;
      vaBottom:     iFormat := iFormat OR DT_BOTTOM;
    end;
    //
    if (NOT bMultiLine) then iFormat := iFormat OR DT_SINGLELINE;
    iFormat := iFormat OR DT_NOPREFIX;
    DrawText (DC, PChar (AText), -1, AArea, iFormat);
  end;
end;


{ TZEFontList }

//////////////////////////////////////////////////////////

  {--------}
  procedure __FontDispose (aData: pointer);
  begin
    try
      TZEFont (aData).Free;
    except
    end;
  end;
  {--------}
  procedure __AliasDispose (aData: Pointer);
  begin
    if (aData <> NIL) then
      try
        StrDispose (PChar (aData));
      except
      end;
  end;

//////////////////////////////////////////////////////////
procedure TZEFontList.CommonInit;
begin
  FAliases := TZbDoubleList.Create (true);
  FAliases.DisposeProc := __AliasDispose;
  FAliases.Sorted := true;
  //
  FFonts := TZbDoubleList.Create (true);
  FFonts.DisposeProc := __FontDispose;
  FFonts.Sorted := true;
  //
  FUseAliases := true;
end;

//////////////////////////////////////////////////////////
constructor TZEFontList.Create (AConfigFile: string);
begin
  CommonInit;
  if (AConfigFile <> '') then
    AddFontNames (g_ConfigManager.LoadSimpleConfig (AConfigFile));
end;

//////////////////////////////////////////////////////////
constructor TZEFontList.Create (FontNames: IZbEnumStrings);
begin
  CommonInit;
  if (FontNames <> NIL) then AddFontNames (FontNames);
end;

//////////////////////////////////////////////////////////
destructor TZEFontList.Destroy;
begin
  FAliases.Free;
  FFonts.Free;
  inherited;
end;

//////////////////////////////////////////////////////////
procedure TZEFontList.AddEntry (cEntry: string);
var
  cParam1, cParam2: string;
begin
  if (cEntry [1] = '#') then begin
    cParam1 := StrAfter ('#', StrBefore ('=', cEntry));
    cParam2 := StrAfter ('=', cEntry);
    AddAlias (cParam1, cParam2);
  end else
    AddFont (cEntry);
  //
end;

//////////////////////////////////////////////////////////
procedure TZEFontList.AddAlias (AAlias, AName: string);
begin
  FAliases.Add (AAlias, StrNew (PChar (AName)));
end;

//////////////////////////////////////////////////////////
procedure TZEFontList.AddFont (cParam: string);
var
  AName: string;
  AFaceName: string;
  FHeight: integer;
  bIsBold, bIsItalic, bIsStrikeOut, bIsUnderline: boolean;
  iHAlignOrd, iVAlignOrd: integer;
  Color: TColor;
begin
  //
  DecodeFontSpec (cParam, AName, AFaceName, FHeight, bIsBold, bIsItalic,
    bIsUnderline, bIsStrikeOut, iHAlignOrd, iVAlignOrd, Color);
  //
  AddFont (AName, AFaceName, FHeight, bIsBold, bIsItalic, bIsUnderline,
    bIsStrikeOut, HA [iHAlignOrd], VA [iVAlignOrd], Color);
end;

//////////////////////////////////////////////////////////
procedure TZEFontList.AddFont (AName, AFaceName: string; AHeight: integer;
  bBold, bItalic, bUnderline, bStrikeOut: boolean; hAlign: TZEHAlign;
  vAlign: TZEVAlign; rgbColor: TColorRef);
var
  Font: TZEFont;
begin
  Font := TZEFont.Create (AHeight, AName, AFaceName);
  if (Font <> NIL) then begin
    with Font do begin
      BeginUpdate;
      Bold := bBold;
      Italic := bItalic;
      Underline := bUnderline;
      StrikeOut := bStrikeOut;
      VAlignment := vAlign;
      HAlignment := hAlign;
      Color := rgbColor;
      EndUpdate;
    end;
    //
    FFonts.Add (AName, Pointer (Font));
  end;
end;

//////////////////////////////////////////////////////////
function TZEFontList.GetFontByIndex (iIndex: integer): TZEFont;
begin
  Result := TZEFont (FFonts.Get (iIndex));
end;

//////////////////////////////////////////////////////////
function TZEFontList.GetFontByName (AName: PChar): TZEFont;
begin
  Result := TZEFont (FFonts.Get (AName));
  if (Result = NIL) then
    Result := TZEFont (FFonts.Get ('Default'));
end;

//////////////////////////////////////////////////////////
function TZEFontList.GetName (iIndex: integer): string;
begin
  Result := FFonts.GetName (iIndex);
end;

//////////////////////////////////////////////////////////
function TZEFontList.TranslateAliasToName (AAlias: PChar): PChar;
begin
  Result := PChar (FAliases.Get (AAlias));
end;

//////////////////////////////////////////////////////////
function TZEFontList.RetrieveByName (AName: string): TZEFont;
var
  pNameToFind: PChar;
begin
  if (FUseAliases) then
    pNameToFind := TranslateAliasToName (PChar (AName))
  else
    pNameToFind := NIL;
  //
  if (pNameToFind = NIL) then
    pNameToFind := PChar (AName);
  //
  Result := GetFontByName (pNameToFind);
end;

//////////////////////////////////////////////////////////
function TZEFontList.GetFontCount: integer;
begin
  Result := FFonts.Count;
end;

//////////////////////////////////////////////////////////
procedure TZEFontList.AddFontNames (FontNames: IZbEnumStrings);
var
  cData: String;
begin
  cData := FontNames.First;
  while (cData <> '') do begin
    AddEntry (cData);
    cData := FontNames.Next;
  end;
end;


{ TZEGUIManager }

//////////////////////////////////////////////////////////
constructor TZEGUIManager.Create (ASpriteSource: IZESpriteFactory);
var
  cBuffer: string;
  LogPen: TLogPen;
begin
  FFonts := NIL;
  FBtnDarkShade := 0;
  FBtnLightShade := 0;
  FDarkPen := 0;
  FLightPen := 0;
  //
  with g_ConfigManager do begin
    // load the font list
    FFonts := TZEFontList.Create (ReadConfigSection (REZ_GUI_FONTS_SECTION, sroNamesAndValues));
    //
    // get the dark shade color
    cBuffer := ReadConfigStr (REZ_GUI_MNGR_SECTION,
      REZ_GM_BTN_DARK_SHADE, REZ_GM_BTN_DARK_SHADE_DEF);
    FBtnDarkShade := StrToColorRef (cBuffer);
    // get the light shade color
    cBuffer := ReadConfigStr (REZ_GUI_MNGR_SECTION,
      REZ_GM_BTN_LIGHT_SHADE, REZ_GM_BTN_LIGHT_SHADE_DEF);
    FBtnLightShade := StrToColorRef (cBuffer);
    // create a pen object for the dark shade color
    LogPen.lopnStyle := PS_SOLID;
    LogPen.lopnWidth := Point (1, 0);
    LogPen.lopnColor := FBtnDarkShade;
    FDarkPen := CreatePenIndirect (LogPen);
    // create a pen object for the light shade color
    LogPen.lopnStyle := PS_SOLID;
    LogPen.lopnWidth := Point (1, 0);
    LogPen.lopnColor := FBtnLightShade;
    FLightPen := CreatePenIndirect (LogPen);
    //
  end;
  //
  FSpriteSource := ASpriteSource;
end;

//////////////////////////////////////////////////////////
destructor TZEGUIManager.Destroy;
begin
  FSpriteSource := NIL;
  DeleteObject (FLightPen);
  DeleteObject (FDarkPen);
  FreeAndNIL (FFonts);
  //
  inherited;
end;

//////////////////////////////////////////////////////////
function TZEGUIManager.GetFontByName (AFontName: string): TZEFont;
begin
  if (FFonts <> NIL) then
    Result := FFonts [AFontName]
    else Result := NIL;
end;

//////////////////////////////////////////////////////////
function TZEGUIManager.CreateSprite (AFamilyName, ASubClassName: string): IZESprite;
begin
  if (ASubClassName = '') then ASubClassName := 'Default';
  Result := FSpriteSource.CreateSprite (AFamilyName, ASubClassName);
end;


//////////////////////////////////////////////////////////////////////////
procedure DecodeFontSpec (cParam: string;
  var cName, cFaceName: string; var FHeight: integer;
  var bIsBold, bIsItalic, bIsUnderLine, bIsStrikeOut: boolean;
  var iHAlignOrd, iVAlignOrd: integer; var Color: TColor);
begin
  cName := StrBefore ('=', cParam);
  cParam := StrAfter ('=', cParam);
  //
  cFaceName := StrBefore (',', cParam);
    cParam := StrAfter (',', cParam);
  FHeight := StrToInt (StrBefore (',', cParam));
    cParam := StrAfter (',', cParam);
  //
  bIsBold := (cParam [1] = '1');
  bIsItalic := (cParam [3] = '1');
  bIsStrikeOut := (cParam [5] = '1');
  bIsUnderline := (cParam [7] = '1');
  //
  iHAlignOrd := integer (cParam [11]) - integer ('0');
  iVAlignOrd := integer (cParam [9]) - integer ('0');
  //
  Color := StrToColorRef (Copy (cParam, 13, 6));
end;

//////////////////////////////////////////////////////////////////////////
function EncodeFontSpec (cName, cFaceName: string; FHeight: integer;
  bIsBold, bIsItalic, bIsUnderLine, bIsStrikeOut: boolean;
  iHAlignOrd, iVAlignOrd: integer; Color: TColor): string;
begin
  Result := Format ('%s=%s,%d,%s,%s,%s,%s,%d,%d,%s',
    [cName, cFaceName, FHeight, BoolStr [bIsBold], BoolStr [bIsItalic],
     BoolStr [bIsUnderline], BoolStr [bIsStrikeOut], iHAlignOrd,
     iVAlignOrd, ColorToString (Color)]);
end;


end.

