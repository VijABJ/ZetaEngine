object fmDataExplorer: TfmDataExplorer
  Left = 369
  Top = 232
  Width = 783
  Height = 540
  Caption = 'fmDataExplorer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = menuMain
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object splitterMain: TSplitter
    Left = 266
    Top = 0
    Width = 6
    Height = 475
    Cursor = crHSplit
    OnMoved = splitterMainMoved
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 475
    Width = 775
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object tvFolders: TTreeView
    Left = 0
    Top = 0
    Width = 266
    Height = 475
    Align = alLeft
    Indent = 19
    PopupMenu = popMenuFolders
    ReadOnly = True
    RightClickSelect = True
    SortType = stText
    TabOrder = 1
    OnChange = tvFoldersChange
    OnClick = tvFoldersClick
  end
  object strFiles: TStringGrid
    Left = 272
    Top = 0
    Width = 503
    Height = 475
    Align = alClient
    DefaultColWidth = 24
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    PopupMenu = popMenuFiles
    TabOrder = 2
  end
  object menuMain: TMainMenu
    Left = 258
    Top = 200
    object menuMainFile: TMenuItem
      Caption = '&File'
      object menuFileNew: TMenuItem
        Caption = '&New'
        ShortCut = 16462
        OnClick = menuFileNewClick
      end
      object menuFileOpen: TMenuItem
        Caption = '&Open...'
        ShortCut = 16463
        OnClick = menuFileOpenClick
      end
      object menuFileSave: TMenuItem
        Caption = '&Save..'
        ShortCut = 16467
        OnClick = menuFileSaveClick
      end
      object menuFileSaveAs: TMenuItem
        Caption = 'Save &As...'
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
  object popMenuFolders: TPopupMenu
    Left = 177
    Top = 154
    object popFolderAdd: TMenuItem
      Caption = '&Add'
      OnClick = popFolderAddClick
    end
    object popFolderDelete: TMenuItem
      Caption = '&Delete'
      OnClick = popFolderDeleteClick
    end
  end
  object popMenuFiles: TPopupMenu
    Left = 461
    Top = 201
    object popFileAdd: TMenuItem
      Caption = '&Add'
      OnClick = popFileAddClick
    end
    object popFileDelete: TMenuItem
      Caption = '&Delete'
      OnClick = popFileDeleteClick
    end
    object popFileRename: TMenuItem
      Caption = '&Rename'
      Enabled = False
      OnClick = popFileRenameClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object popFileDeleteAll: TMenuItem
      Caption = 'Delete A&ll'
      OnClick = popFileDeleteAllClick
    end
  end
  object dlgOpen: TOpenDialog
    Filter = 
      'All Files (*.*)|*.*|Zeta Engine Settings Files (*.zsf)|*.zsf|Zet' +
      'a Engine Image File (*.zif)|*.zif|Zeta Engine Config Files (*.zc' +
      'f)|*.zcf|Zeta Engine Settings File (*.zsf)|*.zsf|State And Media' +
      ' Manager File (*.SAMM)|*.SAMM|Zeta Engine Entity Descriptor (*.Z' +
      'ED)|*.ZED'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofExtensionDifferent, ofPathMustExist, ofFileMustExist, ofShareAware, ofNoReadOnlyReturn, ofEnableSizing, ofDontAddToRecent]
    Left = 348
    Top = 180
  end
  object dlgSaveVolume: TSaveDialog
    DefaultExt = 'zevf'
    Filter = 'Zeta Engine Volume File (*.zvf)|*.zvf'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 165
    Top = 269
  end
  object dlgOpenVolume: TOpenDialog
    DefaultExt = 'zevf'
    Filter = 'Zeta Engine Volume File (*.zvf)|*.zvf'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 133
    Top = 268
  end
end
