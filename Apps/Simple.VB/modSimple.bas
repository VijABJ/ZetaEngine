Attribute VB_Name = "modSimple"
'//#############################################################################
'//
'// SimpleVB Application Sample
'// Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)
'//
'// This file is part of the ZetaEngine
'//
'// ZetaEngine is free software; you can redistribute it and/or modify
'// it under the terms of the GNU General Public License as published by
'// the Free Software Foundation; either version 2 of the License, or
'// (at your option) any later version.
'//
'// ZetaEngine is distributed in the hope that it will be useful,
'// but WITHOUT ANY WARRANTY; without even the implied warranty of
'// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'// GNU General Public License for more details.
'//
'// You should have received a copy of the GNU General Public License
'// along with Foobar; if not, write to the Free Software
'// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'//
'//#############################################################################

'//#############################################################################
'//
'// SimpleVB
'// Author: Virgilio A. Blones, Jr. (Vij) <ZipBreak@hotmail.com>
'//
'// <Description>
'// This is basically a template Application that uses the Zeta Engine.
'// There is no fancy stuff in here.  All this program does is initialize
'// the Zeta Engine, create an clickable Exit button, and then exits when
'// that button is clicked, or when ESCAPE is pressed.
'//
'// <Notes - Pertain to Sub Main (), mostly>
'//
'// It is IMPORTANT that you set the starting point of your program as
'// Sub Main ().  To do this, go to the menu Project, then select
'// <YourProjectName> Properties...  Then Select "Sub Main" as the Startup
'// object so it will run properly.
'//
'// ZEWW_Prepare () takes the filename of your configuration file as the
'// first argument.  The other arguments are the just provided functions
'// which will serve as callbacks.  You may rename these functions if you wish.
'//
'// ZEWW_CreateWindow () has two String arguments.  The first one is the name
'// of the window and this MUST be unique to your program.  The other one is
'// the caption of the window.  That caption is also used to display the name
'// of your program in the taskbar so make it understandable.
'//
'// the call to ZEE_ToggleGlobalExitOnEscape() can be omitted if you don't want
'// the ESCAPE key to exit your program.
'//
'// <Version History>
'// $Header$
'// $Log$
'//
'//#############################################################################

Option Explicit

'//#############################################################################
'//                   Code to create User Interface
'//#############################################################################
Public Function CreateInitialGUI(ByVal ScreenWidth As Long, ByVal ScreenHeight As Long) As Long
  '
  Dim Desktop As Long, Control As Long
  '
  Desktop = ZEUI_SwitchDesktop(DESKTOP_MENU)
  Control = ZEUI_CreateControl(CC_STANDARD_BUTTON, ScreenWidth - 200, 10, ScreenWidth - 10, 80)
  Call ZEUI_InsertControl(Desktop, Control)
  Call ZEUI_SetProp(Control, PROP_NAME_CAPTION, "EXIT")
  Call ZEUI_SetProp(Control, PROP_NAME_SPRITE_NAME, "Default")
  Call ZEUI_SetProp(Control, PROP_NAME_FONT_NAME, "StandardButton")
  Call ZEUI_SetProp(Control, PROP_NAME_COMMAND, Str(cmFinalExit))
  '
End Function

'//#############################################################################
'//    Code that handles system events, and custom commands (if any)
'//#############################################################################
Public Function HandleUserEvents(ByVal iCommand As Long, ByVal lData As Long) As Long
  ' INSERT CODE HERE
End Function

'//#############################################################################
'//        Sub Main ().  The program starts running from here.
'//#############################################################################

Sub Main()
  '
  Dim WinRef As Long
  Dim WinResult As Boolean
  '
  WinRef = ZEWW_Prepare("SimpleVB.zsf", AddressOf CreateInitialGUI, AddressOf HandleUserEvents)
  If (WinRef <> 0) Then
    WinResult = ZEWW_CreateWindow(WinRef, App.hInstance, "SimpleVB", "SimpleVB", 0, 0, 640, 480)
    ZEE_ToggleGlobalExitOnEscape (IBOOL_TRUE)
    If (WinResult) Then ZEWW_Execute (WinRef)
    ZEWW_Shutdown (WinRef)
  End If
  '
End Sub

