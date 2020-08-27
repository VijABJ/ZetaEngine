object fmZetaCfgEd: TfmZetaCfgEd
  Left = 454
  Top = 246
  BorderStyle = bsSingle
  Caption = 'Zeta Configuration Editor'
  ClientHeight = 359
  ClientWidth = 436
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 7
    Top = 64
    Width = 162
    Height = 69
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 7
    Top = 7
    Width = 422
    Height = 52
    Shape = bsFrame
  end
  object sbtnRootFolder: TSpeedButton
    Left = 400
    Top = 28
    Width = 23
    Height = 21
    Caption = '...'
  end
  object Bevel3: TBevel
    Left = 175
    Top = 64
    Width = 254
    Height = 69
    Shape = bsFrame
  end
  object lblTileWidth: TLabel
    Left = 186
    Top = 79
    Width = 48
    Height = 13
    Caption = 'Tile &Width'
    FocusControl = sedTileWidth
  end
  object lblTileHeight: TLabel
    Left = 272
    Top = 79
    Width = 51
    Height = 13
    Caption = 'Tile &Height'
    FocusControl = sedTileHeight
  end
  object lblLevelHeight: TLabel
    Left = 359
    Top = 79
    Width = 60
    Height = 13
    Caption = '&Level Height'
    FocusControl = sedLevelHeight
  end
  object ledRootFolder: TLabeledEdit
    Left = 14
    Top = 28
    Width = 383
    Height = 21
    EditLabel.Width = 58
    EditLabel.Height = 13
    EditLabel.Caption = 'Root &Folder:'
    LabelPosition = lpAbove
    LabelSpacing = 3
    ReadOnly = True
    TabOrder = 0
  end
  object cbResolutions: TComboBox
    Left = 16
    Top = 99
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    Items.Strings = (
      '640x480x32'
      '800x600x32'
      '1024x768x32'
      '1152x864x32')
  end
  object cbFullScreen: TCheckBox
    Left = 16
    Top = 72
    Width = 130
    Height = 20
    Caption = 'Full &Screen Mode'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = cbFullScreenClick
  end
  object sedTileWidth: TSpinEdit
    Left = 186
    Top = 98
    Width = 60
    Height = 22
    MaxValue = 256
    MinValue = 4
    TabOrder = 3
    Value = 32
  end
  object sedTileHeight: TSpinEdit
    Left = 272
    Top = 98
    Width = 60
    Height = 22
    MaxValue = 256
    MinValue = 4
    TabOrder = 4
    Value = 15
  end
  object sedLevelHeight: TSpinEdit
    Left = 359
    Top = 98
    Width = 60
    Height = 22
    MaxValue = 512
    MinValue = 64
    TabOrder = 5
    Value = 80
  end
  object pgMediaList: TPageControl
    Left = 7
    Top = 137
    Width = 421
    Height = 216
    ActivePage = tsPaths
    HotTrack = True
    MultiLine = True
    TabIndex = 2
    TabOrder = 6
    TabPosition = tpLeft
    object tsSoundEffects: TTabSheet
      Caption = 'Sounds'
      object sbtnEfxFolder: TSpeedButton
        Left = 362
        Top = 25
        Width = 24
        Height = 21
        Caption = '...'
        OnClick = sbtnEfxFolderClick
      end
      object editEfxFolder: TLabeledEdit
        Left = 13
        Top = 25
        Width = 347
        Height = 21
        EditLabel.Width = 102
        EditLabel.Height = 13
        EditLabel.Caption = 'Sound Effects Folder:'
        LabelPosition = lpAbove
        LabelSpacing = 3
        TabOrder = 0
      end
      object vleEfxFiles: TValueListEditor
        Left = 14
        Top = 51
        Width = 374
        Height = 151
        KeyOptions = [keyUnique]
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
        PopupMenu = popupMedia
        TabOrder = 1
        TitleCaptions.Strings = (
          'Game Name'
          'Source Filename')
        ColWidths = (
          144
          224)
      end
    end
    object tsMusic: TTabSheet
      Caption = 'Music'
      ImageIndex = 1
      object sbtnMusicFolder: TSpeedButton
        Left = 362
        Top = 25
        Width = 24
        Height = 21
        Caption = '...'
        OnClick = sbtnMusicFolderClick
      end
      object vleMusicFiles: TValueListEditor
        Left = 14
        Top = 51
        Width = 374
        Height = 151
        KeyOptions = [keyUnique]
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
        PopupMenu = popupMedia
        TabOrder = 1
        TitleCaptions.Strings = (
          'Game Name'
          'Source Filename')
        ColWidths = (
          144
          224)
      end
      object editMusicFolder: TLabeledEdit
        Left = 13
        Top = 25
        Width = 347
        Height = 21
        EditLabel.Width = 63
        EditLabel.Height = 13
        EditLabel.Caption = 'Music Folder:'
        LabelPosition = lpAbove
        LabelSpacing = 3
        TabOrder = 0
      end
    end
    object tsPaths: TTabSheet
      Caption = 'Paths'
      ImageIndex = 2
      object sbtnGetVolumeFile: TSpeedButton
        Left = 323
        Top = 5
        Width = 59
        Height = 17
        Caption = 'Add'
        OnClick = sbtnGetVolumeFileClick
      end
      object Label3: TLabel
        Left = 16
        Top = 8
        Width = 50
        Height = 13
        Caption = '&Data Files:'
      end
      object lbDataFiles: TListBox
        Left = 13
        Top = 26
        Width = 371
        Height = 98
        ItemHeight = 13
        TabOrder = 0
      end
    end
    object tsGUI: TTabSheet
      Caption = 'GUI'
      ImageIndex = 3
      object Label1: TLabel
        Left = 15
        Top = 12
        Width = 91
        Height = 13
        Caption = 'Button Dark Shade'
        FocusControl = clbDarkShade
      end
      object Label2: TLabel
        Left = 133
        Top = 12
        Width = 91
        Height = 13
        Caption = 'Button Light Shade'
        FocusControl = clbLightShade
      end
      object clbDarkShade: TColorBox
        Left = 15
        Top = 33
        Width = 104
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 16
        TabOrder = 0
      end
      object clbLightShade: TColorBox
        Left = 133
        Top = 33
        Width = 104
        Height = 22
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 16
        TabOrder = 1
      end
      object vleGuiFonts: TValueListEditor
        Left = 15
        Top = 65
        Width = 370
        Height = 135
        KeyOptions = [keyUnique]
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
        PopupMenu = popupFonts
        TabOrder = 2
        TitleCaptions.Strings = (
          'Game Name'
          'Properties')
        ColWidths = (
          112
          252)
      end
    end
  end
  object mmMain: TMainMenu
    Left = 271
    Top = 35
    object File1: TMenuItem
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
        Caption = '&Save...'
        ShortCut = 16467
        OnClick = menuFileSaveClick
      end
      object menuFileSaveAs: TMenuItem
        Caption = 'Save &as...'
        ShortCut = 16449
        OnClick = menuFileSaveAsClick
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
  object dlgOpen: TOpenDialog
    Filter = 'Zeta Engine Startup File (*.zsf)|*.zsf'
    Options = [ofHideReadOnly, ofNoChangeDir, ofShowHelp, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 307
    Top = 45
  end
  object dlgSave: TSaveDialog
    Filter = 'Zeta Engine Startup File (*.zsf)|*.zsf'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoChangeDir, ofShowHelp, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing, ofDontAddToRecent]
    Left = 240
    Top = 40
  end
  object dlgOpenMedia: TOpenDialog
    Filter = 
      'Wave Files (*.wav)|*.wav|MIDI Files (*.midi)|*.mid;*.midi|MP3 Fi' +
      'les (*.mp3)|*.mp3|All Supported Files|*.wav;*.mid;*.midi;*.mp3'
    Options = [ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 204
    Top = 38
  end
  object popupMedia: TPopupMenu
    Left = 176
    Top = 40
    object popMenuAdd: TMenuItem
      Caption = '&Add'
      OnClick = popMenuAddClick
    end
    object popMenuDelete: TMenuItem
      Caption = '&Delete'
      OnClick = popMenuDeleteClick
    end
    object popMenuRename: TMenuItem
      Caption = '&Rename'
      OnClick = popMenuRenameClick
    end
  end
  object popupFonts: TPopupMenu
    Left = 351
    Top = 45
    object popMenuNewFont: TMenuItem
      Caption = '&New Font...'
      OnClick = popMenuNewFontClick
    end
    object popMenuNewAlias: TMenuItem
      Caption = 'New &Alias...'
      OnClick = popMenuNewAliasClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object popMenuEdit: TMenuItem
      Caption = '&Edit...'
      OnClick = popMenuEditClick
    end
    object popMenuEraseFont: TMenuItem
      Caption = '&Delete'
      OnClick = popMenuEraseFontClick
    end
  end
  object dlgOpenVolume: TOpenDialog
    DefaultExt = 'zvf'
    Filter = 'Zeta Engine Volume File (*.zvf)|*.zvf'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Open Volume File...'
    Left = 144
    Top = 44
  end
end
