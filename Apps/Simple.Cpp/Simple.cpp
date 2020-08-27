//#############################################################################
//
// Zeta Engine Simple Template
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
// Simple.cpp
// Author: Virgilio A. Blones, Jr. (Vij) <ZipBreak@hotmail.com>
//
// <Description>
// This is basically a template Application that uses the Zeta Engine.  
// There is no fancy stuff in here.  All this program does is initialize
// the Zeta Engine, create an clickable Exit button, and then exits when
// that button is clicked, or when ESCAPE is pressed.
//
// <Notes>
// Here are some portions that can be changed:
//
// #define WINDOW_CLASSNAME        "ZetaEngineCPPTemplate"
// #define WINDOW_TITLE            "ZetaEngine C++ Template"
//    Change these two values to properly reflect the name of your eventual
//    application EXE.  It is important that these two be UNIQUE when compared
//    to all other programs running on the same PC.
//
// #define PROGRAM_CONFIGURATION   "MSVCTemplate.zsf"
//    Change the value to the filename of the configuration file that will be
//    sent to Zeta Engine during initialization.  The Configuration Tool
//    included in the Zeta Engine package will create a *.zsf file for you
//    if you don't know how to manually create one.
//	
// #define EXIT_ON_ESCAPE
//    Remove/Comment out this portion if you don't want the ESC key to send
//    a Terminate message to the Engine (thus causing your program to 
//    immediately exit)
//
//
// <Version History>
// $Header$
// $Log$
//  
//#############################################################################

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#pragma comment (lib, "..\\..\\CPP-API\\ZetaLibCpp.lib")

// these are required!
#define WINDOW_CLASSNAME        "SimpleCpp"
#define WINDOW_TITLE            "SimpleCpp"
#define PROGRAM_CONFIGURATION   "SimpleCpp.zsf"
// this is optional
#define EXIT_ON_ESCAPE
// now include the header itself
#include "ZetaLib.h"


//#############################################################################
// this is called to generate the user interface
int __stdcall CreateInitialGUI (int ScreenWidth, int ScreenHeight)
{
  ////////////////////////////////--------------------
  uim->SwitchDesktop (DESKTOP_MAIN);
  IZEUIControl Desktop = uim->GetDesktop (DESKTOP_MAIN);
  if (!Desktop) return (0);

  ////////////////////////////////--------------------------------------------
  IZEUIControl Control = uim->CreateControl (CC_STANDARD_BUTTON, ScreenWidth - 200, 10, ScreenWidth -10, 80);
  uim->Insert (Desktop, Control);
  //
  uim->SetProp (Control, PROP_NAME_CAPTION, "EXIT");
  uim->SetProp (Control, PROP_NAME_SPRITE_NAME, "Default");
  uim->SetProp (Control, PROP_NAME_FONT_NAME, "StandardButton");
  uim->SetProp (Control, PROP_NAME_COMMAND, (PCHAR) ZETACMD (cmFinalExit));

  return (0);
}

//#############################################################################
// this handles engine and other system events
int __stdcall HandleUserEvents (int iCommand, int lData)
{
  return (0);
}


//#############################################################################
// W A R N I N G ! ! !          W A R N I N G ! ! !         W A R N I N G ! ! ! 
//-----------------------------------------------------------------------------
//          DO NOT REMOVE THIS SECTION UNDER NO CIRCUMSTANCES
//-----------------------------------------------------------------------------
// this creates the WinMain() entry point, and Zeta-Specific Init/Loop codes
//
GENERATE_WINMAIN(CreateInitialGUI,HandleUserEvents)

