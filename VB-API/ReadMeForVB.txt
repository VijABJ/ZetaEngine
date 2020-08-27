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
'
' ===========================================================================
