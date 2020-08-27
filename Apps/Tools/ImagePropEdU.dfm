object fmImgPropEditor: TfmImgPropEditor
  Left = 486
  Top = 142
  BorderStyle = bsDialog
  Caption = 'Image Properties'
  ClientHeight = 350
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 11
    Width = 415
    Height = 239
    Shape = bsFrame
  end
  object Bevel2: TBevel
    Left = 8
    Top = 248
    Width = 415
    Height = 50
    Shape = bsFrame
  end
  object lbFiles: TListBox
    Left = 17
    Top = 59
    Width = 398
    Height = 181
    ItemHeight = 13
    TabOrder = 1
    OnClick = lbFilesClick
    OnDblClick = lbFilesClick
  end
  object ledImageGameName: TLabeledEdit
    Left = 17
    Top = 33
    Width = 398
    Height = 21
    EditLabel.Width = 112
    EditLabel.Height = 13
    EditLabel.Caption = '&Game Name For Image:'
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 0
    OnChange = ledImageGameNameChange
  end
  object cbTransparent: TCheckBox
    Left = 198
    Top = 261
    Width = 97
    Height = 17
    Caption = '&Transparent'
    TabOrder = 2
  end
  object cbGridded: TCheckBox
    Left = 313
    Top = 261
    Width = 97
    Height = 17
    Caption = '&Multiple Frames'
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 260
    Top = 307
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 346
    Top = 307
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
end
