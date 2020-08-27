object fmZEEdMain: TfmZEEdMain
  Left = 262
  Top = 119
  ActiveControl = sedFrameCount
  BorderStyle = bsDialog
  Caption = 'Zeta Engine Entity Editor'
  ClientHeight = 511
  ClientWidth = 681
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel5: TBevel
    Left = 205
    Top = 190
    Width = 205
    Height = 287
    Shape = bsFrame
  end
  object Bevel7: TBevel
    Left = 215
    Top = 400
    Width = 186
    Height = 69
    Shape = bsTopLine
  end
  object Bevel6: TBevel
    Left = 214
    Top = 305
    Width = 186
    Height = 92
    Shape = bsTopLine
  end
  object Bevel1: TBevel
    Left = 10
    Top = 12
    Width = 185
    Height = 465
    Shape = bsFrame
  end
  object titleEntities: TLabel
    Left = 19
    Top = 19
    Width = 83
    Height = 13
    Caption = 'Available &Entities:'
    FocusControl = lbEntities
  end
  object Bevel2: TBevel
    Left = 205
    Top = 12
    Width = 466
    Height = 57
    Shape = bsFrame
  end
  object sbtnLoadFolder: TSpeedButton
    Left = 640
    Top = 35
    Width = 23
    Height = 22
    Caption = '...'
  end
  object Bevel3: TBevel
    Left = 205
    Top = 75
    Width = 204
    Height = 108
    Shape = bsFrame
  end
  object titleOrientations: TLabel
    Left = 216
    Top = 83
    Width = 59
    Height = 13
    Caption = '&Orientations:'
  end
  object Bevel4: TBevel
    Left = 320
    Top = 83
    Width = 80
    Height = 88
    Shape = bsLeftLine
  end
  object titleStates: TLabel
    Left = 213
    Top = 197
    Width = 33
    Height = 13
    Caption = 'S&tates:'
    FocusControl = lbStates
  end
  object titleX: TLabel
    Left = 332
    Top = 110
    Width = 10
    Height = 13
    Caption = '&X:'
  end
  object titleY: TLabel
    Left = 332
    Top = 142
    Width = 10
    Height = 13
    Caption = '&Y:'
  end
  object titleDimensions: TLabel
    Left = 329
    Top = 87
    Width = 57
    Height = 13
    Caption = 'Dimensions:'
  end
  object titleImagesCount: TLabel
    Left = 214
    Top = 353
    Width = 68
    Height = 13
    Caption = '&Images Count:'
    FocusControl = sedImageCount
  end
  object titleFramesCount: TLabel
    Left = 314
    Top = 355
    Width = 68
    Height = 13
    Caption = 'F&rames Count:'
    FocusControl = sedFrameCount
  end
  object Bevel8: TBevel
    Left = 416
    Top = 75
    Width = 255
    Height = 402
    Shape = bsFrame
  end
  object titleSequenceFrames: TLabel
    Left = 427
    Top = 84
    Width = 89
    Height = 13
    Caption = 'Sequen&ce Frames:'
    FocusControl = lbSequenceFrames
  end
  object lbEntities: TListBox
    Left = 18
    Top = 37
    Width = 167
    Height = 431
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
  end
  object clbOrientations: TCheckListBox
    Left = 213
    Top = 100
    Width = 101
    Height = 72
    ItemHeight = 13
    Items.Strings = (
      'Unknown'
      'North'
      'NorthEast'
      'East'
      'SouthEast'
      'South'
      'SouthWest'
      'West'
      'NorthWest')
    TabOrder = 2
  end
  object ledActiveFolder: TLabeledEdit
    Left = 214
    Top = 36
    Width = 421
    Height = 21
    EditLabel.Width = 65
    EditLabel.Height = 13
    EditLabel.Caption = 'Active &Folder:'
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 1
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 492
    Width = 681
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object lbStates: TListBox
    Left = 214
    Top = 213
    Width = 187
    Height = 85
    ItemHeight = 13
    TabOrder = 5
  end
  object sedXSpan: TSpinEdit
    Left = 351
    Top = 107
    Width = 49
    Height = 22
    MaxValue = 20
    MinValue = 1
    TabOrder = 3
    Value = 0
  end
  object sedYSpan: TSpinEdit
    Left = 351
    Top = 138
    Width = 49
    Height = 22
    MaxValue = 20
    MinValue = 1
    TabOrder = 4
    Value = 0
  end
  object ledBaseSpriteName: TLabeledEdit
    Left = 213
    Top = 326
    Width = 187
    Height = 21
    EditLabel.Width = 88
    EditLabel.Height = 13
    EditLabel.Caption = '&Base Sprite Name:'
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 6
  end
  object cbRepeats: TCheckBox
    Left = 214
    Top = 408
    Width = 187
    Height = 17
    Caption = 'Repeat Sequence'
    TabOrder = 9
  end
  object ledNameOfNextSequence: TLabeledEdit
    Left = 213
    Top = 445
    Width = 187
    Height = 21
    EditLabel.Width = 77
    EditLabel.Height = 13
    EditLabel.Caption = 'Next Se&quence:'
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 10
  end
  object sedImageCount: TSpinEdit
    Left = 214
    Top = 371
    Width = 86
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 7
    Value = 0
  end
  object sedFrameCount: TSpinEdit
    Left = 314
    Top = 370
    Width = 86
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 8
    Value = 0
  end
  object lbSequenceFrames: TListBox
    Left = 425
    Top = 101
    Width = 236
    Height = 366
    ItemHeight = 13
    TabOrder = 11
  end
end
