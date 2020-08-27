Attribute VB_Name = "modDI8Keys"
'//#############################################################################
'//
'// Visual Basic Port Of DirectInput8 KeyCodes
'// Ported by Virgilio A. Blones, Jr. (Vij)
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
'// modDI8Keys
'// Author: Virgilio A. Blones, Jr. (Vij) <ZipBreak@hotmail.com>
'//
'// <Description>
'// Keycode numerics were ported as is from DirectInput8 DIK_XXXXX constants
'//
'// <Notes>
'//
'// <Version History>
'// $Header$
'// $Log$
'//
'//#############################################################################
Option Explicit

Public Const DIK_ESCAPE = &H1
Public Const DIK_1 = &H2
Public Const DIK_2 = &H3
Public Const DIK_3 = &H4
Public Const DIK_4 = &H5
Public Const DIK_5 = &H6
Public Const DIK_6 = &H7
Public Const DIK_7 = &H8
Public Const DIK_8 = &H9
Public Const DIK_9 = &HA
Public Const DIK_0 = &HB
Public Const DIK_MINUS = &HC               '(* - on main keyboard *)
Public Const DIK_EQUALS = &HD
Public Const DIK_BACK = &HE                '(* backspace *)
Public Const DIK_TAB = &HF
Public Const DIK_Q = &H10
Public Const DIK_W = &H11
Public Const DIK_E = &H12
Public Const DIK_R = &H13
Public Const DIK_T = &H14
Public Const DIK_Y = &H15
Public Const DIK_U = &H16
Public Const DIK_I = &H17
Public Const DIK_O = &H18
Public Const DIK_P = &H19
Public Const DIK_LBRACKET = &H1A
Public Const DIK_RBRACKET = &H1B
Public Const DIK_RETURN = &H1C             '(* Enter on main keyboard *)
Public Const DIK_LCONTROL = &H1D
Public Const DIK_A = &H1E
Public Const DIK_S = &H1F
Public Const DIK_D = &H20
Public Const DIK_F = &H21
Public Const DIK_G = &H22
Public Const DIK_H = &H23
Public Const DIK_J = &H24
Public Const DIK_K = &H25
Public Const DIK_L = &H26
Public Const DIK_SEMICOLON = &H27
Public Const DIK_APOSTROPHE = &H28
Public Const DIK_GRAVE = &H29              '(* accent grave *)
Public Const DIK_LSHIFT = &H2A
Public Const DIK_BACKSLASH = &H2B
Public Const DIK_Z = &H2C
Public Const DIK_X = &H2D
Public Const DIK_C = &H2E
Public Const DIK_V = &H2F
Public Const DIK_B = &H30
Public Const DIK_N = &H31
Public Const DIK_M = &H32
Public Const DIK_COMMA = &H33
Public Const DIK_PERIOD = &H34             '(* . on main keyboard *)
Public Const DIK_SLASH = &H35              '(* / on main keyboard *)
Public Const DIK_RSHIFT = &H36
Public Const DIK_MULTIPLY = &H37           '(* * on numeric keypad *)
Public Const DIK_LMENU = &H38              '(* left Alt *)
Public Const DIK_SPACE = &H39
Public Const DIK_CAPITAL = &H3A
Public Const DIK_F1 = &H3B
Public Const DIK_F2 = &H3C
Public Const DIK_F3 = &H3D
Public Const DIK_F4 = &H3E
Public Const DIK_F5 = &H3F
Public Const DIK_F6 = &H40
Public Const DIK_F7 = &H41
Public Const DIK_F8 = &H42
Public Const DIK_F9 = &H43
Public Const DIK_F10 = &H44
Public Const DIK_NUMLOCK = &H45
Public Const DIK_SCROLL = &H46             '(* Scroll Lock *)
Public Const DIK_NUMPAD7 = &H47
Public Const DIK_NUMPAD8 = &H48
Public Const DIK_NUMPAD9 = &H49
Public Const DIK_SUBTRACT = &H4A           '(* - on numeric keypad *)
Public Const DIK_NUMPAD4 = &H4B
Public Const DIK_NUMPAD5 = &H4C
Public Const DIK_NUMPAD6 = &H4D
Public Const DIK_ADD = &H4E                '(* + on numeric keypad *)
Public Const DIK_NUMPAD1 = &H4F
Public Const DIK_NUMPAD2 = &H50
Public Const DIK_NUMPAD3 = &H51
Public Const DIK_NUMPAD0 = &H52
Public Const DIK_DECIMAL = &H53            '(* . on numeric keypad *)
' $54 to $55 unassigned
Public Const DIK_OEM_102 = &H56            '(* <> or \ | on RT 102-key keyboard (Non-U.S.) *)
Public Const DIK_F11 = &H57
Public Const DIK_F12 = &H58
' $59 to $63 unassigned
Public Const DIK_F13 = &H64                '(*                     (NEC PC98) *)
Public Const DIK_F14 = &H65                '(*                     (NEC PC98) *)
Public Const DIK_F15 = &H66                '(*                     (NEC PC98) *)
' $67 to $6F unassigned
Public Const DIK_KANA = &H70               '(* (Japanese keyboard)            *)
Public Const DIK_ABNT_C1 = &H73            '(* /? on Brazilian keyboard       *)
' $74 to $78 unassigned
Public Const DIK_CONVERT = &H79            '(* (Japanese keyboard)            *)
' $7A unassigned
Public Const DIK_NOCONVERT = &H7B          '(* (Japanese keyboard)            *)
' $7C unassigned
Public Const DIK_YEN = &H7D                '(* (Japanese keyboard)            *)
Public Const DIK_ABNT_C2 = &H7E            '(* Numpad . on Brazilian keyboard *)
' $7F to 8C unassigned
Public Const DIK_NUMPADEQUALS = &H8D       '(* = on numeric keypad (NEC PC98) *)
' $8E to $8F unassigned
Public Const DIK_CIRCUMFLEX = &H90         '(* (Japanese keyboard)            *)
Public Const DIK_AT = &H91                 '(*                     (NEC PC98) *)
Public Const DIK_COLON = &H92              '(*                     (NEC PC98) *)
Public Const DIK_UNDERLINE = &H93          '(*                     (NEC PC98) *)
Public Const DIK_KANJI = &H94              '(* (Japanese keyboard)            *)
Public Const DIK_STOP = &H95               '(*                     (NEC PC98) *)
Public Const DIK_AX = &H96                 '(*                     (Japan AX) *)
Public Const DIK_UNLABELED = &H97          '(*                        (J3100) *)
' $98 unassigned
Public Const DIK_NEXTTRACK = &H99          '(* Next Track *)
' $9A to $9D unassigned
Public Const DIK_NUMPADENTER = &H9C        '(* Enter on numeric keypad *)
Public Const DIK_RCONTROL = &H9D
' $9E to $9F unassigned
Public Const DIK_MUTE = &HA0               '(* Mute *)
Public Const DIK_CALCULATOR = &HA1         '(* Calculator *)
Public Const DIK_PLAYPAUSE = &HA2          '(* Play / Pause *)
Public Const DIK_MEDIASTOP = &HA4          '(* Media Stop *)
' $A5 to $AD unassigned
Public Const DIK_VOLUMEDOWN = &HAE         '(* Volume - *)
' $AF unassigned
Public Const DIK_VOLUMEUP = &HB0           '(* Volume + *)
' $B1 unassigned
Public Const DIK_WEBHOME = &HB2            '(* Web home *)
Public Const DIK_NUMPADCOMMA = &HB3        '(* , on numeric keypad (NEC PC98) *)
' $B4 unassigned
Public Const DIK_DIVIDE = &HB5             '(* / on numeric keypad *)
' $B6 unassigned
Public Const DIK_SYSRQ = &HB7
Public Const DIK_RMENU = &HB8              '(* right Alt *)
' $B9 to $C4 unassigned
Public Const DIK_PAUSE = &HC5              '(* Pause (watch out - not realiable on some kbds) *)
' $C6 unassigned
Public Const DIK_HOME = &HC7               '(* Home on arrow keypad *)
Public Const DIK_UP = &HC8                 '(* UpArrow on arrow keypad *)
Public Const DIK_PRIOR = &HC9              '(* PgUp on arrow keypad *)
' $CA unassigned
Public Const DIK_LEFT = &HCB               '(* LeftArrow on arrow keypad *)
' $CC unassigned
Public Const DIK_RIGHT = &HCD              '(* RightArrow on arrow keypad *)
' $CE unassigned
Public Const DIK_END = &HCF                '(* End on arrow keypad *)
Public Const DIK_DOWN = &HD0               '(* DownArrow on arrow keypad *)
Public Const DIK_NEXT = &HD1               '(* PgDn on arrow keypad *)
Public Const DIK_INSERT = &HD2             '(* Insert on arrow keypad *)
Public Const DIK_DELETE = &HD3             '(* Delete on arrow keypad *)
Public Const DIK_LWIN = &HDB               '(* Left Windows key *)
Public Const DIK_RWIN = &HDC               '(* Right Windows key *)
Public Const DIK_APPS = &HDD               '(* AppMenu key *)
Public Const DIK_POWER = &HDE
Public Const DIK_SLEEP = &HDF
' $E0 to $E2 unassigned
Public Const DIK_WAKE = &HE3               '(* System Wake *)
' $E4 unassigned
Public Const DIK_WEBSEARCH = &HE5          '(* Web Search *)
Public Const DIK_WEBFAVORITES = &HE6       '(* Web Favorites *)
Public Const DIK_WEBREFRESH = &HE7         '(* Web Refresh *)
Public Const DIK_WEBSTOP = &HE8            '(* Web Stop *)
Public Const DIK_WEBFORWARD = &HE9         '(* Web Forward *)
Public Const DIK_WEBBACK = &HEA            '(* Web Back *)
Public Const DIK_MYCOMPUTER = &HEB         '(* My Computer *)
Public Const DIK_MAIL = &HEC               '(* Mail *)
Public Const DIK_MEDIASELECT = &HED        '(* Media Select *)


'(*
' *  Alternate names for keys, to facilitate transition from DOS.
' *)
Public Const DIK_BACKSPACE = DIK_BACK           '(* backspace *)
Public Const DIK_NUMPADSTAR = DIK_MULTIPLY      '(* * on numeric keypad *)
Public Const DIK_LALT = DIK_LMENU               '(* left Alt *)
Public Const DIK_CAPSLOCK = DIK_CAPITAL         '(* CapsLock *)
Public Const DIK_NUMPADMINUS = DIK_SUBTRACT     '(* - on numeric keypad *)
Public Const DIK_NUMPADPLUS = DIK_ADD           '(* + on numeric keypad *)
Public Const DIK_NUMPADPERIOD = DIK_DECIMAL     '(* . on numeric keypad *)
Public Const DIK_NUMPADSLASH = DIK_DIVIDE       '(* / on numeric keypad *)
Public Const DIK_RALT = DIK_RMENU               '(* right Alt *)
Public Const DIK_UPARROW = DIK_UP               '(* UpArrow on arrow keypad *)
Public Const DIK_PGUP = DIK_PRIOR               '(* PgUp on arrow keypad *)
Public Const DIK_LEFTARROW = DIK_LEFT           '(* LeftArrow on arrow keypad *)
Public Const DIK_RIGHTARROW = DIK_RIGHT         '(* RightArrow on arrow keypad *)
Public Const DIK_DOWNARROW = DIK_DOWN           '(* DownArrow on arrow keypad *)
Public Const DIK_PGDN = DIK_NEXT                '(* PgDn on arrow keypad *)

'(*
' *  Alternate names for keys originally not used on US keyboards.
' *)

Public Const DIK_PREVTRACK = DIK_CIRCUMFLEX       '(* Japanese keyboard *)


