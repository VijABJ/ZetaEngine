object fmImageConfEditor: TfmImageConfEditor
  Left = 441
  Top = 118
  BorderStyle = bsSingle
  Caption = 'Image Configuration Editor'
  ClientHeight = 362
  ClientWidth = 294
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = menuMain
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 343
    Width = 294
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object Panel1: TPanel
    Left = 1
    Top = 3
    Width = 145
    Height = 267
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object Label1: TLabel
      Left = 5
      Top = 8
      Width = 36
      Height = 13
      Caption = '&Aliases:'
      FocusControl = lbAliases
    end
    object lbAliases: TListBox
      Left = 2
      Top = 24
      Width = 141
      Height = 241
      Align = alBottom
      Enabled = False
      ItemHeight = 13
      PopupMenu = popMenuAliases
      Sorted = True
      TabOrder = 0
      OnClick = lbAliasesClick
    end
  end
  object Panel2: TPanel
    Left = 149
    Top = 3
    Width = 145
    Height = 267
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object Label2: TLabel
      Left = 7
      Top = 8
      Width = 36
      Height = 13
      Caption = '&Names:'
      FocusControl = lbNames
    end
    object lbNames: TListBox
      Left = 2
      Top = 25
      Width = 141
      Height = 240
      Align = alBottom
      Enabled = False
      ItemHeight = 13
      PopupMenu = popMenuNames
      Sorted = True
      TabOrder = 0
      OnClick = lbNamesClick
    end
  end
  object ledFileName: TLabeledEdit
    Left = 2
    Top = 289
    Width = 289
    Height = 21
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = 'Filename:'
    Enabled = False
    LabelPosition = lpAbove
    LabelSpacing = 3
    ReadOnly = True
    TabOrder = 3
  end
  object cbTransparentF: TCheckBox
    Left = 4
    Top = 317
    Width = 97
    Height = 17
    Caption = '&Transparent'
    Enabled = False
    TabOrder = 4
  end
  object cbGriddedF: TCheckBox
    Left = 112
    Top = 317
    Width = 176
    Height = 17
    Caption = '&Has Multiple Frames'
    Enabled = False
    TabOrder = 5
  end
  object menuMain: TMainMenu
    Left = 173
    Top = 179
    object menuFile: TMenuItem
      Caption = '&List'
      object menuFileLoad: TMenuItem
        Caption = '&Load From Volume...'
        OnClick = menuFileLoadClick
      end
      object menuFileOpenConfig: TMenuItem
        Caption = 'Load From &Configuration...'
        OnClick = menuFileOpenConfigClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object menuFileSaveConfig: TMenuItem
        Caption = 'Sa&ve Configuration...'
        Enabled = False
        OnClick = menuFileSaveConfigClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object menuFileExit: TMenuItem
        Caption = 'E&xit'
        OnClick = menuFileExitClick
      end
    end
  end
  object dlgLoadVolume: TOpenDialog
    DefaultExt = 'zvf'
    Filter = 'Zeta Volume File (*.zvf)|*.zvf'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Loading Volume...'
    Left = 116
    Top = 140
  end
  object dlgLoadConfig: TOpenDialog
    DefaultExt = 'zcf'
    Filter = 'Zeta Configuration File (*.zcf)|*.zcf'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Loading Configuration...'
    Left = 243
    Top = 152
  end
  object popMenuAliases: TPopupMenu
    OnPopup = popMenuAliasesPopup
    Left = 104
    Top = 90
    object popMenuAliasesNew: TMenuItem
      Caption = '&New...'
      OnClick = popMenuAliasesNewClick
    end
    object popMenuAliasesDelete: TMenuItem
      Caption = '&Delete'
      OnClick = popMenuAliasesDeleteClick
    end
  end
  object popMenuNames: TPopupMenu
    OnPopup = popMenuNamesPopup
    Left = 46
    Top = 101
    object popMenuNamesNew: TMenuItem
      Caption = '&New...'
      OnClick = popMenuNamesNewClick
    end
    object popMenuNamesDelete: TMenuItem
      Caption = '&Delete'
      OnClick = popMenuNamesDeleteClick
    end
  end
  object dlgSaveConfig: TSaveDialog
    DefaultExt = 'zcf'
    Filter = 'Zeta Engine Configuration File (*.zcf)|*.zcf'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Saving Configuration...'
    Left = 82
    Top = 161
  end
end
