/*===========================================================================

  ZipBreak's Zeta Engine - Tiled, Isometric Engine for RPGs
  Copyright (c) 2002 Virgilio A. Blones, Jr. (Vij)

  Module:     ZetaFTypes.hpp
              Function Types, and pointers to such
  Author:     Vij

  -----------------------
  VERSION CONTROL/HISTORY
  -----------------------

  $Header: /users/vij/backups/CVS/ZetaEngine/CPP-API/ZetaFTypes.hpp,v 1.2 2002/10/01 12:51:41 Vij Exp $
  $Log: ZetaFTypes.hpp,v $
  Revision 1.2  2002/10/01 12:51:41  Vij
  Added PlayCutScene(), LoadWorld()

  Revision 1.1.1.1  2002/09/12 14:48:21  Vij
  Starting Version Control



 ===========================================================================*/

#ifndef __ZETA_ENGINE_FUNCTION_POINTER_TYPES__
#define __ZETA_ENGINE_FUNCTION_POINTER_TYPES__


#define ZETA_API __stdcall
#define ZETA_FUNC(RetVal,FuncName,Prototype) \
  typedef RetVal ZETA_API fn##FuncName Prototype; \
  typedef fn##FuncName* lpfn##FuncName

/*------------------------------
 | base function pointer types |
 ------------------------------*/

typedef void ZETA_API fnZetaProc (void);
typedef fnZetaProc* lpfnZetaProc;

typedef int ZETA_API fnZetaFunc (void);
typedef fnZetaFunc* lpfnZetaFunc;

typedef tINTBOOL ZETA_API fnZetaFuncBool (void);
typedef fnZetaFuncBool* lpfnZetaFuncBool;

typedef void ZETA_API fnZetaToggleProc (tINTBOOL);
typedef fnZetaToggleProc* lpfnZetaToggleProc;

typedef void ZETA_API fnZetaPassPCharProc (PCHAR);
typedef fnZetaPassPCharProc* lpfnZetaPassPCharProc;

typedef tINTBOOL ZETA_API fnInitFunc (PCHAR, HWND, HINSTANCE);
typedef fnInitFunc* lpfnInitFunc;


/*--------------------------------------
 | Zeta Engine Specific Function Types |
 --------------------------------------*/

//////////////////////-----------------------------------

/*

typedef int ZETA_API fnZEIntf_GetWinWrap (void);
typedef fnZEIntf_GetWinWrap* lpfnZEIntf_GetWinWrap;

typedef int ZETA_API fnZEIntf_GetCore (void);
typedef fnZEIntf_GetCore* lpfnZEIntf_GetCore;

typedef int ZETA_API fnZEIntf_GetUIManager (void);
typedef fnZEIntf_GetUIManager* lpfnZEIntf_GetUIManager;

typedef int ZETA_API fnZEIntf_GetGameWorld (void);
typedef fnZEIntf_GetGameWorld* lpfnZEIntf_GetGameWorld;
*/

#endif /* __ZETA_ENGINE_FUNCTION_POINTER_TYPES__ */

