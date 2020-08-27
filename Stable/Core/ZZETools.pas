{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZZETools.PAS
              Contains miscellaneous routines
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/Core/ZZETools.pas,v 1.1.1.1 2002/09/11 21:11:42 Vij Exp $
  $Log: ZZETools.pas,v $
  Revision 1.1.1.1  2002/09/11 21:11:42  Vij
  Starting Version Control


 ============================================================================}

{-$DEFINE __INSIDE_DLL  define this symbol when compiling within a DLL}

unit ZZETools;

interface

uses
  Windows,
  EZDSLBse;

type
  PZE_AliasRec = ^TZE_AliasRec;
  TZE_AliasRec = record
    pAlias: PChar;
    pName: PChar;
  end;

  PBoolean = ^boolean;

  // support routines for a doubly-linked list of names-aliases combo
  function  ZZE_CreateAlias (AAlias, AName: PChar): PZE_AliasRec;
  function  ZZE_AliasCompare (Data1, Data2: pointer): integer;
  procedure ZZE_AliasDisposeData (aData: pointer);
  function  ZZE_AliasDupData (aData: pointer): pointer;
  function  ZZE_IteratorFindAlias (C: TAbstractContainer;
                  aData: pointer; ExtraData: pointer) : boolean;
  function  ZZE_IteratorFindByIndex (C: TAbstractContainer;
                  aData: pointer; ExtraData: pointer) : boolean;

  //-- Error display functions
  procedure ErrHalt (_hWnd: hWnd; _msg: string);
  procedure ErrWarning (_hWnd: hWnd; _msg: string);

var
  bZEApplicationMode: boolean = True;

implementation

uses
  Types,
  {$IFNDEF __INSIDE_DLL}
  Forms,
  {$ENDIF}
  SysUtils;


////////////////////////////////////////////////////////////////////
function ZZE_CreateAlias (AAlias, AName: PChar): PZE_AliasRec;
var
  AliasRec: PZE_AliasRec;
begin
  try
    New (AliasRec);
    with AliasRec^ do
      begin
        pAlias := StrNew (AAlias);
        pName := StrNew (AName);
      end;
    //
    Result := AliasRec;
  except
    Result := NIL;
  end;
end;

////////////////////////////////////////////////////////////////////
function ZZE_AliasCompare (Data1, Data2: pointer): integer;
begin
  if (Data1 = nil) then
    if (Data2 = nil) then
      Result := 0
    else
      Result := -1
  else
    if (Data2 = nil) then
      Result := 1
    else
      Result := StrComp (PZE_AliasRec(Data1).pAlias,
                         PZE_AliasRec(Data2).pAlias);
end;

////////////////////////////////////////////////////////////////////
procedure ZZE_AliasDisposeData (aData: pointer);
var
  AliasRec: PZE_AliasRec absolute aData;
begin
  StrDispose(AliasRec.pAlias);
  StrDispose(AliasRec.pName);
  Dispose (AliasRec);
end;

////////////////////////////////////////////////////////////////////
function ZZE_AliasDupData (aData: pointer): pointer;
var
  AliasRec: PZE_AliasRec absolute aData;
begin
  if (aData = nil) then
    Result := nil
  else
    Result := ZZE_CreateAlias (AliasRec.pAlias, AliasRec.pName);
end;

////////////////////////////////////////////////////////////////////
function ZZE_IteratorFindAlias (
  C : TAbstractContainer; aData : pointer; ExtraData : pointer) : boolean;
var
  AliasRec: PZE_AliasRec absolute aData;
  pAliasToFind: PChar absolute ExtraData;
begin
  if (AliasRec <> NIL) then
    Result := NOT (StrComp (AliasRec.pAlias, pAliasToFind) = 0)
  else
    Result := true;
end;

////////////////////////////////////////////////////////////////////
function ZZE_IteratorFindByIndex (C: TAbstractContainer;
  aData: pointer; ExtraData: pointer) : boolean;
var
  pIndex: ^integer absolute ExtraData;
begin
  if (aData <> NIL) AND (pIndex^ <= 0) then
    Result := false
  else
    begin
      Dec (pIndex^);
      Result := true;
    end;
end;

////////////////////////////////////////////////////////////////////
// Displays error and halt the program
procedure ErrHalt(_hWnd: hWnd; _msg: string);
begin
  MessageBox(_hWnd, PChar(_msg), 'Error', MB_ICONERROR);
  {$IFNDEF __INSIDE_DLL}
  if (bZEApplicationMode) then Application.Terminate;
  {$ENDIF}
end;

////////////////////////////////////////////////////////////////////
// Displays a warning and continue on
procedure ErrWarning(_hWnd: hWnd; _msg: string);
begin
  MessageBox(_hWnd, PChar(_msg), 'Error/Warning', MB_ICONWARNING);
end;


end.

