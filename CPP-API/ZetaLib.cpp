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
// $Header: /users/vij/backups/CVS/ZetaEngine/CPP-API/ZetaLib.cpp,v 1.4 2002/12/18 08:29:45 Vij Exp $
// $Log: ZetaLib.cpp,v $
// Revision 1.4  2002/12/18 08:29:45  Vij
// synchronized with DLL content
//
// Revision 1.3  2002/11/02 07:10:00  Vij
// changed the code a lot.  discarded the function API and used the interfaces
// API instead.  much easier to code and read now, more efficient too.
//
//  
//#############################################################################

#define ZETALIB_CPP_MODULE
#define ZETADLL_NAME "ZetaLib.dll"
#include "ZetaLib.h"

#define ZETA_API __stdcall
#define ZETA_FUNC(RetVal,FuncName,Prototype) \
  const char* lpsz_##FuncName = #FuncName; \
  typedef RetVal ZETA_API fn##FuncName Prototype; \
  typedef fn##FuncName* lpfn##FuncName; \
  lpfn##FuncName _##FuncName = NULL
#define ZETA_LINK(FuncName) \
  _##FuncName = (lpfn##FuncName) GetProcAddress (hmZetaDll, lpsz_##FuncName)
#define CALL(FuncName) (*_##FuncName)


// interface getter
ZETA_FUNC(PZEZetaMain,ZEIntf_GetZetaMain,(void));
// handle to DLL
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

  // initialize all the function pointers
  ZETA_LINK(ZEIntf_GetZetaMain);

  return (1);
}

//#############################################################################
void ZELib_Shutdown ()
{
  if (hmZetaDll)
  {
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

//#############################################################################
PZEZetaMain ZEIntf_GetZetaMain ()
{
  return (CALL(ZEIntf_GetZetaMain) ());
}

