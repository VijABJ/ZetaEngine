object fmFontEditDlg: TfmFontEditDlg
  Left = 638
  Top = 186
  BorderStyle = bsDialog
  Caption = 'Font Editor'
  ClientHeight = 357
  ClientWidth = 402
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 10
    Top = 196
    Width = 294
    Height = 47
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 9
    Top = 12
    Width = 295
    Height = 104
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 23
    Top = 61
    Width = 24
    Height = 13
    Caption = '&Font:'
    FocusControl = cbFontNames
  end
  object Label2: TLabel
    Left = 172
    Top = 19
    Width = 20
    Height = 13
    Caption = 'Si&ze'
    FocusControl = spedFontSize
  end
  object Label3: TLabel
    Left = 31
    Top = 213
    Width = 24
    Height = 13
    Caption = '&Color'
    FocusControl = clrFontColor
  end
  object cbFontNames: TComboBox
    Left = 23
    Top = 81
    Width = 270
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
  end
  object spedFontSize: TSpinEdit
    Left = 172
    Top = 35
    Width = 121
    Height = 22
    MaxValue = 255
    MinValue = 4
    TabOrder = 1
    Value = 4
  end
  object ledGameName: TLabeledEdit
    Left = 23
    Top = 36
    Width = 134
    Height = 21
    EditLabel.Width = 59
    EditLabel.Height = 13
    EditLabel.Caption = '&Game Name'
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 10
    Top = 121
    Width = 294
    Height = 66
    Caption = 'Styles / Effects'
    TabOrder = 3
    object cbBold: TCheckBox
      Left = 13
      Top = 21
      Width = 97
      Height = 17
      Caption = '&Bold'
      TabOrder = 0
    end
    object cbUnderline: TCheckBox
      Left = 149
      Top = 21
      Width = 97
      Height = 17
      Caption = '&Underline'
      TabOrder = 1
    end
    object cbItalic: TCheckBox
      Left = 13
      Top = 40
      Width = 97
      Height = 17
      Caption = '&Italic'
      TabOrder = 2
    end
    object cbStrikeOut: TCheckBox
      Left = 149
      Top = 40
      Width = 97
      Height = 17
      Caption = 'Stri&ke Out'
      TabOrder = 3
    end
  end
  object clrFontColor: TColorBox
    Left = 101
    Top = 209
    Width = 188
    Height = 22
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 4
  end
  object GroupBox2: TGroupBox
    Left = 10
    Top = 249
    Width = 295
    Height = 74
    Caption = 'Alignments'
    TabOrder = 5
    object Label4: TLabel
      Left = 12
      Top = 22
      Width = 47
      Height = 13
      Caption = '&Horizontal'
    end
    object Label5: TLabel
      Left = 156
      Top = 21
      Width = 35
      Height = 13
      Caption = '&Vertical'
    end
    object cbHAlign: TComboBox
      Left = 12
      Top = 41
      Width = 128
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        'Left'
        'Center'
        'Right')
    end
    object cbVAlign: TComboBox
      Left = 156
      Top = 40
      Width = 128
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        'Top'
        'Center'
        'Bottom')
    end
  end
  object btnOK: TButton
    Left = 314
    Top = 12
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 315
    Top = 45
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 338
    Width = 402
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
