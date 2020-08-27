{============================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaLib.PAS
              The DLL API Interface for the Zeta Engine
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/DLL/ZetaLib.dpr,v 1.4 2002/12/18 08:28:50 Vij Exp $
  $Log: ZetaLib.dpr,v $
  Revision 1.4  2002/12/18 08:28:50  Vij
  New API functions added

  Revision 1.3  2002/11/02 07:02:46  Vij
  added new exports

  Revision 1.2  2002/10/01 13:50:47  Vij
  Added PlayCutScene(), LoadWorld()

  Revision 1.1.1.1  2002/09/13 17:15:20  Vij
  Starting Version Control



 ============================================================================}

library ZetaLib;

uses
  Windows,
  ZetaAPI in 'ZetaAPI.pas',
  ZetaTypes in 'ZetaTypes.pas',
  ZetaInterfaces in 'ZetaInterfaces.pas',
  ZetaIntfImpl in 'ZetaIntfImpl.pas';

{$R *.res} // this is needed for the version information

exports
  ZEWW_Prepare, ZEWW_CreateWindow, ZEWW_Execute, ZEWW_Shutdown,
  ZEE_Initialize, ZEE_Shutdown, ZEE_TerminateSelf, ZEE_TerminateEngine,
  ZEE_Activate, ZEE_Deactivate, ZEE_Refresh, ZEE_PushEvent, ZEE_AddCallback,
  ZEE_ScreenWidth, ZEE_ScreenHeight, ZEE_ScreenColorDepth,
  ZEE_SetMusic, ZEE_ClearMusic, ZEE_PlaySound, ZEE_PlayCutScene,
  ZEE_TogglePause, ZEE_IsMusicActive, ZEE_ToggleMusic,
  ZEE_IsSoundActive, ZEE_ToggleSound, ZEE_ToggleFPSDisplay,
  ZEE_StartTimer, ZEE_StartTimerEx, ZEE_PauseTimer, ZEE_UnPauseTimer,
  ZEE_StopTimer, ZEE_IsGlobalExitOnEscapeSet, ZEE_ToggleGlobalExitOnEscape,
  ZEE_CmpStr, ZEE_AddKeyHook, ZEE_ClearKeyHook, ZEE_GetElapsedTicks,
  ZEE_GetMouseX, ZEE_GetMouseY, ZEE_DebugText, ZEE_CopyPChar,

  ZEF_FileExists, ZEF_DeleteFile, ZEF_CreateFile, ZEF_OpenFile,
  ZEF_CloseFile, ZEF_WriteToFileI, ZEF_ReadFromFileI,

  ZEUI_Root, ZEUI_CreateDesktop, ZEUI_GetDesktop, ZEUI_SwitchDesktop, ZEUI_CreateGameView,
  ZEUI_CreateControl, ZEUI_InsertControl, ZEUI_GetProp, ZEUI_SetProp,
  ZEUI_ToggleParentFontUse, ZEUI_RunDialog, ZEUI_ShowInputBox,
  ZEUI_ShowMsgBox, ZEUI_ShowMsgBoxEx, ZEUI_ShowTextDialog, ZEUI_ShowPromptDialog,
  ZEUI_Hide, ZEUI_Show, ZEUI_Enable, ZEUI_GetXPos, ZEUI_GetYPos,
  ZEUI_GetWidth, ZEUI_GetHeight, ZEUI_MoveTo, ZEUI_MoveRel, ZEUI_Resize,
  ZEUI_Delete,

  ZEEN_NameToHandle, ZEEN_Delete, ZEEN_Unplace, ZEEN_CompareBaseName,
  ZEEN_CompareName, ZEEN_PrefixInName, ZEEN_GetWidth, ZEEN_GetLength,
  ZEEN_IsOrientable, ZEEN_CanMove, ZEEN_MovementRate, ZEEN_Updateable,
  ZEEN_GetXPos, ZEEN_GetYPos, ZEEN_OnMap, ZEEN_OnActiveArea,
  ZEEN_Orientation, ZEEN_SetStateInfo,
  ZEEN_SetHandler, ZEEN_ClearHandler, ZEEN_GetHandlerData, ZEEN_SetHandlerData,
  ZEEN_BeginPerform, ZEEN_ClearActions, ZEEN_MoveTo,
  ZEEN_CanSee, ZEEN_CanSee2, ZEEN_HowFarFrom, ZEEN_HowFarFrom2,
  ZEEN_Face, ZEEN_Face2, ZEEN_Approach, ZEEN_Approach2,
  ZEEN_IsNeighbor, ZEEN_IsNeighbor2, ZEEN_FaceTo,
  ZEEN_CanStepTo, ZEEN_StepTo, ZEEN_SetCaption, ZEEN_GetNeighbor,

  ZEGE_LoadWorld, ZEGE_SwitchToArea, ZEGE_CreatePC, ZEGE_ReplacePC, ZEGE_ClearPC,
  ZEGE_GetPC, ZEGE_CenterPC, ZEGE_CenterAt, ZEGE_DropPC, ZEGE_DropPCEx,
  ZEGE_UnDropPC, ZEGE_QueueForDeletion, ZEGE_QueueForDeletion2,

  ZEGE_GetEntity, ZEGE_DeleteEntity, ZEGE_DeleteEntity2, ZEGE_EnumEntities,

  ZETA_Run,
  ZEIntf_GetZetaMain;


begin
end.



