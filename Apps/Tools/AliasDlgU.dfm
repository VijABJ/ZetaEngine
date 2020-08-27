object fmAliasEditDlg: TfmAliasEditDlg
  Left = 437
  Top = 167
  BorderStyle = bsDialog
  Caption = 'Alias Dialog'
  ClientHeight = 119
  ClientWidth = 330
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
  object Bevel1: TBevel
    Left = 8
    Top = 9
    Width = 222
    Height = 103
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 20
    Top = 59
    Width = 106
    Height = 13
    Caption = 'Select Value For Alias:'
    FocusControl = cbAliasValues
  end
  object ledAliasName: TLabeledEdit
    Left = 20
    Top = 30
    Width = 183
    Height = 21
    EditLabel.Width = 49
    EditLabel.Height = 13
    EditLabel.Caption = 'Font Alias:'
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 0
    OnChange = ControlOnChange
  end
  object cbAliasValues: TComboBox
    Left = 20
    Top = 75
    Width = 183
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    Sorted = True
    TabOrder = 1
    OnChange = ControlOnChange
  end
  object btnOK: TButton
    Left = 244
    Top = 9
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 244
    Top = 42
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
