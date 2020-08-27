object fmSpritePropDlg: TfmSpritePropDlg
  Left = 419
  Top = 128
  BorderStyle = bsDialog
  Caption = 'Sprite Properties'
  ClientHeight = 239
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 7
    Top = 125
    Width = 240
    Height = 104
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 7
    Top = 21
    Width = 240
    Height = 97
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 16
    Top = 28
    Width = 223
    Height = 13
    Caption = 'Select &Control:'
    FocusControl = cbControlsList
  end
  object Label2: TLabel
    Left = 16
    Top = 178
    Width = 54
    Height = 13
    Caption = '&First Frame:'
    FocusControl = sedFirstFrame
  end
  object Label3: TLabel
    Left = 145
    Top = 178
    Width = 55
    Height = 13
    Caption = '&Last Frame:'
    FocusControl = sedLastFrame
  end
  object Label4: TLabel
    Left = 16
    Top = 132
    Width = 63
    Height = 13
    Caption = '&Image Name:'
    FocusControl = cbImageNames
  end
  object cbControlsList: TComboBox
    Left = 16
    Top = 44
    Width = 223
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    OnChange = ledSubClassNameChange
    Items.Strings = (
      'Checkbox'
      'Control'
      'CustomDecorImage'
      'CustomDialog'
      'CustomEdit'
      'CustomGauge'
      'CustomPushButton'
      'CustomPushPanel'
      'CustomScrollBox'
      'CustomToggleButton'
      'CutSceneView'
      'DecorImage'
      'Desktop'
      'Edit'
      'GameMainMenu'
      'GameWindow'
      'GroupControl'
      'IconButton'
      'Label'
      'MouseDevice'
      'NumericEdit'
      'OKCancelDialog'
      'PanelGroup'
      'PictureButton'
      'PicturePanel'
      'ProgressGauge'
      'ProgressGaugeEnh'
      'PushPanel'
      'RootWindow'
      'ScrollGauge'
      'StandardButton'
      'StandardWindow'
      'Text'
      'Wallpaper'
      'WinBorders')
  end
  object ledSubClassName: TLabeledEdit
    Left = 16
    Top = 87
    Width = 223
    Height = 21
    EditLabel.Width = 69
    EditLabel.Height = 13
    EditLabel.Caption = '&Specific Name'
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 1
    OnChange = ledSubClassNameChange
  end
  object btnCancel: TButton
    Left = 266
    Top = 55
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object btnOK: TButton
    Left = 266
    Top = 21
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 4
  end
  object sedFirstFrame: TSpinEdit
    Left = 16
    Top = 196
    Width = 94
    Height = 22
    MaxLength = 3
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object sedLastFrame: TSpinEdit
    Left = 145
    Top = 198
    Width = 94
    Height = 22
    MaxLength = 3
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object cbImageNames: TComboBox
    Left = 16
    Top = 150
    Width = 223
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    OnChange = ledSubClassNameChange
  end
end
