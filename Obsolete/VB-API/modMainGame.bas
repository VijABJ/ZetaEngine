Attribute VB_Name = "modMainGame"
' ===========================================================================
'
'  ZipBreak 's Zeta Engine - Tiled, Isometric Engine for RPGs
'  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)
'
'  Module:       modMainGame.BAS
'                This module (should) contain the game-specific code
'  Author:       Vij
'
'  * NOTES * READ THIS *
'
'  This is the Visual Basic template that uses the Zeta Engine.  Some parts
'  can be changed, while others MUST NOT be touched at all!  For more specific
'  instructions, read on.
'
'  function CreateInitialGUI ()
'    this will be called by the Zeta Engine System when the User Interface
'    needs to be constructed.  Be default, it does not contain anything
'    since the ESCAPE is enabled as the EXIT key (see below: ESCAPE KEY).
'    the passed values will be the width and height of the screen and can
'    be used to calculate positions of UI elements  the user code wants to
'    construct.
'
'  function HandleUserEvents ()
'    whenever something important happens that the Zeta Engine do not know
'    how to handle, or other events that needs to propagate to the calling
'    program, this function will be called.  the parameters are the numeric
'    value of the event, and extra data related to the said event.
'
'  Sub VB_RunGame ()
'    Call this Subroutine when you're ready to run the program.  See notes
'    written right before the subroutine for more info.
'
'  Sub Main ()
'    This MUST be the entry point of the client VB program.  Do not remove
'    the lines calling ZESS_AddCallback (), the other one can be omitted if
'    its effects is not desired (see below: ESCAPE KEY).  The last line MUST
'    be changed to make the form invoking your game be shown.  You can also
'    add more lines before and after that one
'
'  ESCAPE KEY
'    The first line in Sub Main () normally reads:
'    ->    ZEE_ToggleGlobalExitOnEscape(IBOOL_TRUE)
'    This basically activates the ESCAPE KEY as an EXIT command.  If you
'    don't have a usable exit button, don't touch this.  However, this can
'    be removed if you don't want the press of the ESCAPE key to exit your
'    program.
'
'  -------------------------
'  Version Control / HISTORY
'  -------------------------

'  $Header: /users/vij/backups/CVS/ZetaEngine/VB-API/modMainGame.bas,v 1.1 2002/10/05 15:24:48 Vij Exp $
'  $Log: modMainGame.bas,v $
'  Revision 1.1  2002/10/05 15:24:48  Vij
'  Added to Version Control
'
'
' ===========================================================================

Option Explicit

' ===========================================================================
' GLOBAL VARIABLES
' ===========================================================================

Public cProgramConfig As String
Public Status As Long
Public hHostWindow As Long
Public hAppInstance As Long

' ===========================================================================
' Code to create User Interface
' ===========================================================================
Public Function CreateInitialGUI(ByVal ScreenWidth As Long, ByVal ScreenHeight As Long) As Long
  ' INSERT CODE HERE
End Function

' ===========================================================================
' Code that handles system events, and custom commands (if any)
' ===========================================================================
Public Function HandleUserEvents(ByVal iCommand As Long, ByVal lData As Long) As Long
  ' INSERT CODE HERE
End Function

' ===========================================================================
' Call this to make the program run!  It is best to call this one INSIDE the
' Form_Load () of whatever form is assigned to be visible.  IMPORTANT: be
' sure to have initialized the following global variables FIRST!
' * cProgramConfig - with the filename of the configuration to be used
' * hHostWindow - with the handle of the window to be used for display
'
' To make this simpler, just copy and paste the following code onto the
' Form_Load () sub of your Form.  Remove the leading apostrophe of course.
'
'  cProgramConfig = <FILENAME OF YOUR CONFIG>
'  hHostWindow = Me.hWnd
'  VB_RunGame
'
' ===========================================================================

Public Sub VB_RunGame()
  '
  hAppInstance = App.hInstance
  Status = ZEE_Initialize(cProgramConfig, hHostWindow, hAppInstance)
  If (Status <> IBOOL_FALSE) Then
    '
    Call ZEE_ToggleFPSDisplay(IBOOL_FALSE)
    Call ZEE_Activate
    '
    Status = IBOOL_FALSE
    Do While Status = IBOOL_FALSE
      Status = ZEE_Refresh
      DoEvents
    Loop
    '
    Call ZEE_Deactivate
    Call ZEE_Shutdown
  End If
  '
  Call ZEE_TerminateSelf
  '
End Sub

' ===========================================================================
' Sub Main ().  The program starts running from here.
' ===========================================================================

Sub Main()
  '
  ' general engine pre-initialization
  Call ZEE_ToggleGlobalExitOnEscape(IBOOL_TRUE)
  Call ZESS_AddCallback(SCRIPT_GAME_GUI, AddressOf CreateInitialGUI)
  Call ZESS_AddCallback(SCRIPT_USER_EVENTS, AddressOf HandleUserEvents)
  '
  ' game-specific initialization, change frmYourForm to whatever the name
  ' of your game form is.
  frmYourForm.Visible = True
End Sub
