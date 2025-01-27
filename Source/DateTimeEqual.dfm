object FDateTimeEqual: TFDateTimeEqual
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Exif/Xmp DateTime equalize'
  ClientHeight = 178
  ClientWidth = 529
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 429
    Top = 108
    Width = 99
    Height = 13
    AutoSize = False
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 159
    Width = 529
    Height = 19
    Panels = <>
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 424
    Height = 159
    Align = alLeft
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 1
    object Bevel1: TBevel
      Left = 6
      Top = 6
      Width = 407
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
      TabOrder = 6
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
      TabOrder = 0
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
      TabOrder = 1
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
      TabOrder = 2
      Text = ''
    end
    object RadioButton1: TRadioButton
      Left = 272
      Top = 58
      Width = 150
      Height = 17
      Caption = '-use as source'
      Checked = True
      TabOrder = 3
      TabStop = True
      OnClick = RadioButton1Click
    end
    object RadioButton2: TRadioButton
      Left = 272
      Top = 90
      Width = 150
      Height = 17
      Caption = '-and copy here'
      TabOrder = 4
      OnClick = RadioButton1Click
    end
    object RadioButton3: TRadioButton
      Left = 272
      Top = 122
      Width = 150
      Height = 17
      Caption = '-and copy here'
      TabOrder = 5
      OnClick = RadioButton1Click
    end
  end
  object Button1: TButton
    Left = 429
    Top = 13
    Width = 99
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 429
    Top = 127
    Width = 99
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 3
    OnClick = Button2Click
  end
end
