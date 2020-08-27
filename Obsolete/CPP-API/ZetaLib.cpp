//#############################################################################
//
// Zeta Engine Main Header
// Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)
//
// This file is part of the ZetaEngine 
//
// ZetaEngine is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// ZetaEngine is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Foobar; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//  
//#############################################################################

//#############################################################################
//
// ZetaLib.cpp
// Author: Virgilio A. Blones, Jr. (Vij) <ZipBreak@hotmail.com>
//
// <Description>
// This file implements the callback linking to the Zeta Engine DLL.  Since
// Visual C++ apparently cannot link to a lib file generated by Delphi
// (the Core Zeta Engine itself is written in Delphi), some hocus-pocus
// was required to make the linking of API from a client C++ to the Delphi-
// generated DLL as painless as possible.  Most of the pain are written
// inside this module. :)
//
// <Version History>
// $Header$
// $Log$
//  
//#############################################################################

#define ZETALIB_CPP_MODULE
#define ZETADLL_NAME "ZetaLib.dll"

#include "ZetaLib.hpp"
#include "ZetaFNames.hpp"
#include "ZetaFTypes.hpp"


// Callable function variables 
lpfnZEWW_Prepare          _ZEWW_Prepare = NULL;
lpfnZEWW_CreateWindow     _ZEWW_CreateWindow = NULL;
lpfnZEWW_Execute          _ZEWW_Execute = NULL;
lpfnZEWW_Shutdown         _ZEWW_Shutdown = NULL;

lpfnZEE_Initialize        _ZEE_Initialize = NULL;
lpfnZEE_Shutdown          _ZEE_Shutdown = NULL;
lpfnZEE_TerminateSelf     _ZEE_TerminateSelf = NULL;
lpfnZEE_Activate          _ZEE_Activate = NULL;
lpfnZEE_Deactivate        _ZEE_Deactivate = NULL;
lpfnZEE_Refresh           _ZEE_Refresh = NULL;
lpfnZEE_ScreenWidth       _ZEE_ScreenWidth = NULL;
lpfnZEE_ScreenHeight      _ZEE_ScreenHeight = NULL;
lpfnZEE_ScreenColorDepth  _ZEE_ScreenColorDepth = NULL;

lpfnZEE_SetMusic          _ZEE_SetMusic = NULL;
lpfnZEE_ClearMusic        _ZEE_ClearMusic = NULL;
lpfnZEE_PlaySound         _ZEE_PlaySound = NULL;
lpfnZEE_PlayCutScene      _ZEE_PlayCutScene = NULL;

lpfnZEE_IsMusicActive     _ZEE_IsMusicActive = NULL;
lpfnZEE_ToggleMusic       _ZEE_ToggleMusic = NULL;
lpfnZEE_IsSoundActive     _ZEE_IsSoundActive = NULL;
lpfnZEE_ToggleSound       _ZEE_ToggleSound = NULL;
lpfnZEE_ToggleFPSDisplay  _ZEE_ToggleFPSDisplay = NULL;

lpfnZEE_IsGlobalExitOnEscapeSet   _ZEE_IsGlobalExitOnEscapeSet = NULL;
lpfnZEE_ToggleGlobalExitOnEscape  _ZEE_ToggleGlobalExitOnEscape = NULL;

// the windowing system
lpfnZEUI_Root             _ZEUI_Root = NULL;
lpfnZEUI_CreateDesktop    _ZEUI_CreateDesktop = NULL;
lpfnZEUI_SwitchDesktop    _ZEUI_SwitchDesktop = NULL;
lpfnZEUI_GetDesktop       _ZEUI_GetDesktop = NULL;
lpfnZEUI_CreateGameView   _ZEUI_CreateGameView = NULL;

lpfnZEUI_CreateControl    _ZEUI_CreateControl = NULL;
lpfnZEUI_InsertControl    _ZEUI_InsertControl = NULL;
lpfnZEUI_GetProp          _ZEUI_GetProp = NULL;
lpfnZEUI_SetProp          _ZEUI_SetProp = NULL;

lpfnZEUI_ShowMsgBox       _ZEUI_ShowMsgBox = NULL;
lpfnZEUI_ShowMsgBoxEx     _ZEUI_ShowMsgBoxEx = NULL;
lpfnZEUI_Hide             _ZEUI_Hide = NULL;
lpfnZEUI_Show             _ZEUI_Show = NULL;

// game stuff
lpfnZEGE_LoadWorld        _ZEGE_LoadWorld = NULL;

lpfnZEGE_CreatePC         _ZEGE_CreatePC = NULL;
lpfnZEGE_ReplacePC        _ZEGE_ReplacePC = NULL;
lpfnZEGE_ClearPC          _ZEGE_ClearPC = NULL;

lpfnZEGE_DropPC           _ZEGE_DropPC = NULL;
lpfnZEGE_DropPCEx         _ZEGE_DropPCEx = NULL;
lpfnZEGE_UnDropPC         _ZEGE_UnDropPC = NULL;

// for the scripting support
lpfnZESS_ClearCallbacks   _ZESS_ClearCallbacks = NULL;
lpfnZESS_AddCallback      _ZESS_AddCallback = NULL;
lpfnZESS_TerminateEngine  _ZESS_TerminateEngine = NULL;

lpfnZEIntf_GetWinWrap     _ZEIntf_GetWinWrap = NULL;

/*
// interface                                     
DECLARE_INTERFACE_(IMsgBox, IUnknown)
{
  // *** IUnknown methods ***
  STDMETHOD(QueryInterface) (THIS_ REFIID riid, LPVOID FAR* ppvObj);
  STDMETHOD_(ULONG,AddRef) (THIS);
  STDMETHOD_(ULONG,Release) (THIS);
  // *** IMsgBox
  virtual void STDMETHODCALLTYPE ShowMsg ();
};
typedef IMsgBox* pMsgBox;
lpfnGetIntf _GetIntf = NULL;
*/

static HMODULE hmZetaDll = NULL;

///////////////////////////////////////////////////////////////////////////////
//
// Support routines.  These are merely convenience functions that does the
// loading of the DLL, and the mapping of the API functions to local variables
// so that callbacks will be as efficient as possible.
//
///////////////////////////////////////////////////////////////////////////////

//#############################################################################
int ZELib_Initialize ()
{
  // assume we're not yet initialized
  iInitialized = 0;
  // load the library, return immediately if this turns out an error
  hmZetaDll = LoadLibrary (ZETADLL_NAME);
  if (!hmZetaDll) { MessageBox (NULL, "Cannot find Zeta Engine DLL.", "ERROR", MB_OK | MB_ICONERROR); return (0); }

  //
  // initialize all the function pointers
  //

  _ZEWW_Prepare = (lpfnZEWW_Prepare) GetProcAddress (hmZetaDll, lpsz_ZEWW_Prepare);
  _ZEWW_CreateWindow = (lpfnZEWW_CreateWindow) GetProcAddress (hmZetaDll, lpsz_ZEWW_CreateWindow);
  _ZEWW_Execute = (lpfnZEWW_Execute) GetProcAddress (hmZetaDll, lpsz_ZEWW_Execute);
  _ZEWW_Shutdown = (lpfnZEWW_Shutdown) GetProcAddress (hmZetaDll, lpsz_ZEWW_Shutdown);


  _ZEE_Initialize = (lpfnZEE_Initialize) GetProcAddress (hmZetaDll, lpsz_ZEE_Initialize);
  _ZEE_Shutdown = (lpfnZEE_Shutdown) GetProcAddress (hmZetaDll, lpsz_ZEE_Shutdown);
  _ZEE_TerminateSelf = (lpfnZEE_TerminateSelf) GetProcAddress (hmZetaDll, lpsz_ZEE_TerminateSelf);
  _ZEE_Activate = (lpfnZEE_Activate) GetProcAddress (hmZetaDll, lpsz_ZEE_Activate);
  _ZEE_Deactivate = (lpfnZEE_Deactivate) GetProcAddress (hmZetaDll, lpsz_ZEE_Deactivate);
  _ZEE_Refresh = (lpfnZEE_Refresh) GetProcAddress (hmZetaDll, lpsz_ZEE_Refresh);

  _ZEE_ScreenWidth = (lpfnZEE_ScreenWidth) GetProcAddress (hmZetaDll, lpsz_ZEE_ScreenWidth);
  _ZEE_ScreenHeight = (lpfnZEE_ScreenHeight) GetProcAddress (hmZetaDll, lpsz_ZEE_ScreenHeight);
  _ZEE_ScreenColorDepth = (lpfnZEE_ScreenColorDepth) GetProcAddress (hmZetaDll, lpsz_ZEE_ScreenColorDepth);

  _ZEE_SetMusic = (lpfnZEE_SetMusic) GetProcAddress (hmZetaDll, lpsz_ZEE_SetMusic);
  _ZEE_ClearMusic = (lpfnZEE_ClearMusic) GetProcAddress (hmZetaDll, lpsz_ZEE_ClearMusic);
  _ZEE_PlaySound = (lpfnZEE_PlaySound) GetProcAddress (hmZetaDll, lpsz_ZEE_PlaySound);
  _ZEE_PlayCutScene = (lpfnZEE_PlayCutScene) GetProcAddress (hmZetaDll, lpsz_ZEE_PlayCutScene);

  _ZEE_IsMusicActive = (lpfnZEE_IsMusicActive) GetProcAddress (hmZetaDll, lpsz_ZEE_IsMusicActive);
  _ZEE_ToggleMusic = (lpfnZEE_ToggleMusic) GetProcAddress (hmZetaDll, lpsz_ZEE_ToggleMusic);
  _ZEE_IsSoundActive = (lpfnZEE_IsSoundActive) GetProcAddress (hmZetaDll, lpsz_ZEE_IsSoundActive);
  _ZEE_ToggleSound = (lpfnZEE_ToggleSound) GetProcAddress (hmZetaDll, lpsz_ZEE_ToggleSound);
  _ZEE_ToggleFPSDisplay = (lpfnZEE_ToggleFPSDisplay) GetProcAddress (hmZetaDll, lpsz_ZEE_ToggleFPSDisplay);

  _ZEE_IsGlobalExitOnEscapeSet = (lpfnZEE_IsGlobalExitOnEscapeSet) GetProcAddress (hmZetaDll, lpsz_ZEE_IsGlobalExitOnEscapeSet);
  _ZEE_ToggleGlobalExitOnEscape = (lpfnZEE_ToggleGlobalExitOnEscape) GetProcAddress (hmZetaDll, lpsz_ZEE_ToggleGlobalExitOnEscape);

  // the windowing system
  _ZEUI_Root = (lpfnZEUI_Root) GetProcAddress (hmZetaDll, lpsz_ZEUI_Root);
  _ZEUI_CreateDesktop = (lpfnZEUI_CreateDesktop) GetProcAddress (hmZetaDll, lpsz_ZEUI_CreateDesktop);
  _ZEUI_SwitchDesktop = (lpfnZEUI_SwitchDesktop) GetProcAddress (hmZetaDll, lpsz_ZEUI_SwitchDesktop);
  _ZEUI_GetDesktop = (lpfnZEUI_GetDesktop) GetProcAddress (hmZetaDll, lpsz_ZEUI_GetDesktop);
  _ZEUI_CreateGameView = (lpfnZEUI_CreateGameView) GetProcAddress (hmZetaDll, lpsz_ZEUI_CreateGameView);

  _ZEUI_CreateControl = (lpfnZEUI_CreateControl) GetProcAddress (hmZetaDll, lpsz_ZEUI_CreateControl);
  _ZEUI_InsertControl = (lpfnZEUI_InsertControl) GetProcAddress (hmZetaDll, lpsz_ZEUI_InsertControl);
  _ZEUI_GetProp = (lpfnZEUI_GetProp) GetProcAddress (hmZetaDll, lpsz_ZEUI_GetProp);
  _ZEUI_SetProp = (lpfnZEUI_SetProp) GetProcAddress (hmZetaDll, lpsz_ZEUI_SetProp);

  _ZEUI_ShowMsgBox = (lpfnZEUI_ShowMsgBox) GetProcAddress (hmZetaDll, lpsz_ZEUI_ShowMsgBox);
  _ZEUI_ShowMsgBoxEx = (lpfnZEUI_ShowMsgBoxEx) GetProcAddress (hmZetaDll, lpsz_ZEUI_ShowMsgBoxEx);

  _ZEUI_Hide = (lpfnZEUI_Hide) GetProcAddress (hmZetaDll, lpsz_ZEUI_Hide);
  _ZEUI_Show = (lpfnZEUI_Show) GetProcAddress (hmZetaDll, lpsz_ZEUI_Show);

  // for the game proper
  _ZEGE_LoadWorld = (lpfnZEGE_LoadWorld) GetProcAddress (hmZetaDll, lpsz_ZEGE_LoadWorld);

  _ZEGE_CreatePC = (lpfnZEGE_CreatePC) GetProcAddress (hmZetaDll, lpsz_ZEGE_CreatePC);
  _ZEGE_ReplacePC = (lpfnZEGE_ReplacePC) GetProcAddress (hmZetaDll, lpsz_ZEGE_ReplacePC);
  _ZEGE_ClearPC = (lpfnZEGE_ClearPC) GetProcAddress (hmZetaDll, lpsz_ZEGE_ClearPC);

  _ZEGE_DropPC = (lpfnZEGE_DropPC) GetProcAddress (hmZetaDll, lpsz_ZEGE_DropPC);
  _ZEGE_DropPCEx = (lpfnZEGE_DropPCEx) GetProcAddress (hmZetaDll, lpsz_ZEGE_DropPCEx);
  _ZEGE_UnDropPC = (lpfnZEGE_UnDropPC) GetProcAddress (hmZetaDll, lpsz_ZEGE_UnDropPC);

  // for the scripting system
  _ZESS_ClearCallbacks = (lpfnZESS_ClearCallbacks) GetProcAddress (hmZetaDll, lpsz_ZESS_ClearCallbacks);
  _ZESS_AddCallback = (lpfnZESS_AddCallback) GetProcAddress (hmZetaDll, lpsz_ZESS_AddCallback);
  _ZESS_TerminateEngine = (lpfnZESS_TerminateEngine) GetProcAddress (hmZetaDll, lpsz_ZESS_TerminateEngine);

  _ZEIntf_GetWinWrap = (lpfnZEIntf_GetWinWrap) GetProcAddress (hmZetaDll, lpsz_ZEIntf_GetWinWrap);
  //_GetIntf = (lpfnGetIntf) GetProcAddress (hmZetaDll, lpsz_GetIntf);

  //pMsgBox pmb = (pMsgBox) (GetIntf ());
  //pmb->ShowMsg ();
  //pmb->Release ();

  return (1);
}

//#############################################################################
void ZELib_Shutdown ()
{
  if (hmZetaDll)
  {
    // shutdown first if it was initialized
    if (iInitialized) ZEE_Shutdown ();
    // now discard the library
    FreeLibrary (hmZetaDll);
    hmZetaDll = NULL;
    iInitialized = 0;
  }
}

//#############################################################################
static char cBuffer [64];
const char* ZELib_IntToStr (int iValue)
{
  itoa (iValue, cBuffer, 10);
  return (cBuffer);
}

///////////////////////////////////////////////////////////////////////////////
//
// Windows (TM) windowing system support.  Gets rid of those window-creation,
// window-initialization, and window-callback mechanism of Windows do that the
// client program will be as simple as a single function named WinMain()
//
///////////////////////////////////////////////////////////////////////////////

//#############################################################################
int ZEWW_Prepare (PCHAR lpszConfigFile, tCALLBACK lpfnCreateUICallback, 
  tCALLBACK lpfnHandleEventCallback)
{
  return ((*_ZEWW_Prepare) (lpszConfigFile, lpfnCreateUICallback, lpfnHandleEventCallback));
}

//#############################################################################
tINTBOOL ZEWW_CreateWindow (int ClassRef, HINSTANCE hAppInstance, PCHAR WindowClassName,
  PCHAR WindowTitle, tCALLBACK WindowProc, DWORD WindowFlags, int iWidth, int iHeight)
{
  return ((*_ZEWW_CreateWindow) (ClassRef, hAppInstance, WindowClassName, WindowTitle, 
    WindowProc, WindowFlags, iWidth, iHeight));
}

//#############################################################################
void ZEWW_Execute (int ClassRef)
{
  (*_ZEWW_Execute) (ClassRef);
}

//#############################################################################
void ZEWW_Shutdown (int ClassRef)
{
  (*_ZEWW_Shutdown) (ClassRef);
}


///////////////////////////////////////////////////////////////////////////////
//
// Zeta Engine management code.  These routines mainly have to do with initia-
// lization/shutdown, and inquiring about engine properties
//
///////////////////////////////////////////////////////////////////////////////


//#############################################################################
tINTBOOL ZEE_Initialize (PCHAR lpszConfigurationFile, HWND hHostWindow, HINSTANCE hAppInstance)
{
  if (_ZEE_Initialize) 
    iInitialized = ((*_ZEE_Initialize) (lpszConfigurationFile, hHostWindow, hAppInstance));
  else
    iInitialized = IBOOL_FALSE;

  return (iInitialized);
}

//#############################################################################
void ZEE_Shutdown ()
{
  if (!iInitialized) return;

  (*_ZEE_Shutdown) ();
  iInitialized = IBOOL_FALSE;
}

//#############################################################################
void ZEE_TerminateSelf ()
{
  (*_ZEE_TerminateSelf) ();
}

//#############################################################################
void ZEE_Activate ()
{
  (*_ZEE_Activate) ();
}

//#############################################################################
void ZEE_Deactivate ()
{
  (*_ZEE_Deactivate) ();
}

//#############################################################################
tINTBOOL ZEE_Refresh ()
{
  return ((*_ZEE_Refresh) ());
}

//#############################################################################
int ZEE_ScreenWidth ()
{
  return ((*_ZEE_ScreenWidth) ());
}

//#############################################################################
int ZEE_ScreenHeight ()
{
  return ((*_ZEE_ScreenHeight) ());
}

//#############################################################################
int ZEE_ScreenColorDepth ()
{
  return ((*_ZEE_ScreenColorDepth) ());
}

//#############################################################################
void ZEE_SetMusic (PCHAR lpszMusicName)
{
  (*_ZEE_SetMusic) (lpszMusicName);
}

//#############################################################################
void ZEE_ClearMusic ()
{
  (*_ZEE_ClearMusic) ();
}

//#############################################################################
void ZEE_PlaySound (PCHAR lpszSoundName)
{
  (*_ZEE_PlaySound) (lpszSoundName);
}

//#############################################################################
void ZEE_PlayCutScene (PCHAR lpszCutSceneFile)
{
  (*_ZEE_PlayCutScene) (lpszCutSceneFile);
}

//#############################################################################
tINTBOOL ZEE_IsMusicActive ()
{
  return ((*_ZEE_IsMusicActive) ());
}

//#############################################################################
void ZEE_ToggleMusic (tINTBOOL ibActive)
{
  (*_ZEE_ToggleMusic) (ibActive);
}

//#############################################################################
tINTBOOL ZEE_IsSoundActive ()
{
  return ((*_ZEE_IsSoundActive) ());
}

//#############################################################################
void ZEE_ToggleSound (tINTBOOL ibActive)
{
  (*_ZEE_ToggleSound) (ibActive);
}

//#############################################################################
void ZEE_ToggleFPSDisplay (tINTBOOL ibVisible)
{
  (*_ZEE_ToggleFPSDisplay) (ibVisible);
}
 
//#############################################################################
tINTBOOL ZEE_IsGlobalExitOnEscapeSet ()
{
  return ((*_ZEE_IsGlobalExitOnEscapeSet) ());
}

//#############################################################################
void ZEE_ToggleGlobalExitOnEscape (tINTBOOL ibActive)
{
  (*_ZEE_ToggleGlobalExitOnEscape) (ibActive);
}

//#############################################################################
tCONTROL ZEUI_Root ()
{
  return ((*_ZEUI_Root) ());
}

//#############################################################################
tCONTROL ZEUI_CreateDesktop (PCHAR lpszRefName, PCHAR lpszDeskName)
{
  return ((*_ZEUI_CreateDesktop) (lpszRefName, lpszDeskName));
}

//#############################################################################
tCONTROL ZEUI_SwitchDesktop (PCHAR lpszRefName)
{
  return ((*_ZEUI_SwitchDesktop) (lpszRefName));
}

//#############################################################################
tCONTROL ZEUI_GetDesktop (PCHAR lpszRefName)
{
  return ((*_ZEUI_GetDesktop) (lpszRefName));
}

//#############################################################################
tCONTROL ZEUI_CreateGameView (int Left, int Top, int Right, int Bottom)
{
  return ((*_ZEUI_CreateGameView) (Left, Top, Right, Bottom));
}

//#############################################################################
tCONTROL ZEUI_CreateControl (PCHAR lpszClassName, int Left, int Top, int Right, int Bottom)
{
  return ((*_ZEUI_CreateControl) (lpszClassName, Left, Top, Right, Bottom));
}

//#############################################################################
void ZEUI_InsertControl (tCONTROL ctlDest, tCONTROL ctlToInsert)
{
  (*_ZEUI_InsertControl) (ctlDest, ctlToInsert);
}

//#############################################################################
PCHAR ZEUI_GetProp (tCONTROL ControlRef, PCHAR lpszPropName)
{
  return ((*_ZEUI_GetProp) (ControlRef, lpszPropName));
}

//#############################################################################
void ZEUI_SetProp (tCONTROL ControlRef, PCHAR lpszPropName, PCHAR lpszPropValue)
{
  (*_ZEUI_SetProp) (ControlRef, lpszPropName, lpszPropValue);
}

//#############################################################################
void ZEUI_ShowMsgBox (PCHAR cMessage)
{
  (*_ZEUI_ShowMsgBox) (cMessage);
}

//#############################################################################
void ZEUI_ShowMsgBoxEx (PCHAR cMessage, int Left, int Top, int Right, int Bottom)
{
  (*_ZEUI_ShowMsgBoxEx) (cMessage, Left, Top, Right, Bottom);
}

//#############################################################################
void ZEUI_Hide (tCONTROL ControlRef)
{
  (*_ZEUI_Hide) (ControlRef);
}

//#############################################################################
void ZEUI_Show (tCONTROL ControlRef)
{
  (*_ZEUI_Show) (ControlRef);
}

//#############################################################################
void ZEGE_LoadWorld (PCHAR lpszWorldFile)
{
  (*_ZEGE_LoadWorld) (lpszWorldFile);
}

//#############################################################################
void ZEGE_CreatePC (PCHAR lpszMasterName, PCHAR lpszWorkingName, tCALLBACK lpfnCallback)
{
  (*_ZEGE_CreatePC) (lpszMasterName, lpszWorkingName, lpfnCallback);
}

//#############################################################################
void ZEGE_ReplacePC (PCHAR lpszMasterName, PCHAR lpszWorkingName, tCALLBACK lpfnCallback)
{
  (*_ZEGE_ReplacePC) (lpszMasterName, lpszWorkingName, lpfnCallback);
}

//#############################################################################
void ZEGE_ClearPC ()
{
  (*_ZEGE_ClearPC) ();
}
 

//#############################################################################
void ZEGE_DropPC ()
{
  (*_ZEGE_DropPC) ();
}

//#############################################################################
void ZEGE_DropPCEx (PCHAR lpszAreaName, int X, int Y, int Z)
{
  (*_ZEGE_DropPCEx) (lpszAreaName, X, Y, Z);
}

//#############################################################################
void ZEGE_UnDropPC ()
{
  (*_ZEGE_UnDropPC) ();
}

//#############################################################################
void ZESS_ClearCallbacks ()
{
  (*_ZESS_ClearCallbacks) ();
}

//#############################################################################
void ZESS_AddCallback (PCHAR lpszRefName, tCALLBACK lpfnCallback)
{
  (*_ZESS_AddCallback) (lpszRefName, lpfnCallback);
}

//#############################################################################
void ZESS_TerminateEngine ()
{
  (*_ZESS_TerminateEngine) ();
}

//#############################################################################
PZEWinWrap ZEIntf_GetWinWrap ()
{
  return ((PZEWinWrap) ((*_ZEIntf_GetWinWrap) ()));
}
