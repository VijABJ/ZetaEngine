object fmGuiSpriteEd: TfmGuiSpriteEd
  Left = 337
  Top = 122
  Width = 557
  Height = 442
  Caption = 'GUI Sprite Configuration Editor'
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
  object sbMain: TStatusBar
    Left = 0
    Top = 377
    Width = 549
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object vleSpriteProps: TValueListEditor
    Left = 0
    Top = 0
    Width = 549
    Height = 377
    Align = alClient
    DisplayOptions = [doAutoColResize, doKeyColFixed]
    Enabled = False
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
    PopupMenu = popSpriteProps
    TabOrder = 1
    ColWidths = (
      150
      393)
  end
  object menuMain: TMainMenu
    Left = 89
    Top = 58
    object menuFile: TMenuItem
      Caption = '&File'
      object menuFileNew: TMenuItem
        Caption = '&New...'
        ShortCut = 16462
        OnClick = menuFileNewClick
      end
      object menuFileOpen: TMenuItem
        Caption = '&Open...'
        ShortCut = 16463
        OnClick = menuFileOpenClick
      end
      object menuFileSave: TMenuItem
        Caption = '&Save'
        Enabled = False
        ShortCut = 16467
        OnClick = menuFileSaveClick
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
  object popSpriteProps: TPopupMenu
    OnPopup = popSpritePropsPopup
    Left = 265
    Top = 78
    object popSpritePropsAdd: TMenuItem
      Caption = '&Add'
      OnClick = popSpritePropsAddClick
    end
    object popSpritePropsDelete: TMenuItem
      Caption = '&Delete'
      OnClick = popSpritePropsDeleteClick
    end
  end
  object dlgOpenImageCfg: TOpenDialog
    DefaultExt = 'zcf'
    Filter = 'Zeta Engine Configration File (*.zcf)|*.zcf'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Title = 'Loading Image Configration Reference...'
    Left = 183
    Top = 104
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'zcf'
    Filter = 'Zeta Engine Configuration File (*.zcf0|*.zcf'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Save Configuration'
    Left = 135
    Top = 206
  end
end
