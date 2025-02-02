object FDateTimeEqual: TFDateTimeEqual
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Exif/Xmp DateTime equalize'
  ClientHeight = 223
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 470
    Top = 145
    Width = 100
    Height = 13
    AutoSize = False
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 204
    Width = 572
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 463
    Height = 204
    Align = alLeft
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    object Bevel1: TBevel
      Left = 6
      Top = 6
      Width = 450
      Height = 38
    end
    object LblGroup: TLabel
      Left = 1
      Top = 11
      Width = 129
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Group:'
      Layout = tlCenter
    end
    object CmbGroup: TComboBox
      Left = 137
      Top = 11
      Width = 129
      Height = 22
      TabOrder = 0
      Text = 'Exif'
      OnClick = CmbGroupClick
      Items.Strings = (
        'Exif'
        'Xmp'
        'QuickTime')
    end
    object LabeledEdit1: TLabeledEdit
      Left = 137
      Top = 55
      Width = 129
      Height = 22
      TabStop = False
      EditLabel.Width = 96
      EditLabel.Height = 22
      EditLabel.Caption = 'DateTimeOriginal:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 1
      Text = '2012:01:12 18:15:00'
    end
    object LabeledEdit2: TLabeledEdit
      Left = 137
      Top = 87
      Width = 129
      Height = 22
      TabStop = False
      EditLabel.Width = 66
      EditLabel.Height = 22
      EditLabel.Caption = 'CreateDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 2
      Text = ''
    end
    object LabeledEdit3: TLabeledEdit
      Left = 137
      Top = 119
      Width = 129
      Height = 22
      TabStop = False
      EditLabel.Width = 65
      EditLabel.Height = 22
      EditLabel.Caption = 'ModifyDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 3
      Text = ''
    end
    object RadioButton1: TRadioButton
      Left = 272
      Top = 58
      Width = 150
      Height = 17
      Caption = '-use as source'
      Checked = True
      TabOrder = 4
      TabStop = True
      OnClick = RadioButtonClick
    end
    object RadioButton2: TRadioButton
      Left = 272
      Top = 90
      Width = 150
      Height = 17
      Caption = '-and copy here'
      TabOrder = 5
      OnClick = RadioButtonClick
    end
    object RadioButton3: TRadioButton
      Left = 272
      Top = 122
      Width = 150
      Height = 17
      Caption = '-and copy here'
      TabOrder = 6
      OnClick = RadioButtonClick
    end
    object ChkFileModified: TCheckBox
      Left = 134
      Top = 156
      Width = 322
      Height = 17
      Hint = 'File: Date modified becomes (shifted) ModifyDate fom metadata'
      Caption = '-change File: Date modified'
      TabOrder = 7
    end
    object ChkFileCreated: TCheckBox
      Left = 134
      Top = 177
      Width = 322
      Height = 17
      Hint = 'File: Date created becomes (shifted) CreateDate from metadata'
      Caption = '-change File: Date created'
      TabOrder = 8
    end
  end
  object Button1: TButton
    Left = 468
    Top = 8
    Width = 100
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 470
    Top = 164
    Width = 100
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 3
    OnClick = Button2Click
  end
end
