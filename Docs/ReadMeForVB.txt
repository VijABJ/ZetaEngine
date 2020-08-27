
---------------------------------------------------------------------
Really, really basic readme.  Please wait for one with more details.
In the meantime, below is the sequence you NEED to call the engine
in order to make it work!


' variable Status MUST be declared as Long
Status = ZZIE_EngineInitialize(YourConfigurationFileHere, hWnd of Form)

' check the status, proceed only if it is 1
If (Status = 1) Then

' internal loop sequence
ZZIE_EngineActivate
...
ManipulateTheMapHereIfYouNeedTo
...
Status = 0
Do While Status = 0
  Status = ZZIE_EngineRefresh   ' Refresh returns 0 when the user have exited, for now
  DoEvents											' VERY, VERY IMPORTANT!  REMOVE this and say goodbye to your system
Loop

' shutdown sequence
ZZIE_EngineDeactivate
ZZIE_EngineShutdown

---------------------------------------------------------------------
To manipulate maps, begin by adding a map
	ZZIE_MapCreate (YourMapName, YourMapWidth, YourMapHeight)
	
Be sure to add ONE level, multiple levels have yet to be coded
	ZZIE_MapAddLevel
	
Then add stuff to the map to your heart's content.  Be sure 
that the items you're adding exists in the *.XML and *.cfg
files used by the engine.  To add, use
	ZZIE_MapAddEntity (FamilyName, SubClassName, LevelNumber, Column, Row)
	
Note that all numbers are zero-based

	





