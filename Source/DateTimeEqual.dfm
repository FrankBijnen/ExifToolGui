object FDateTimeEqual: TFDateTimeEqual
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Exif DateTime equalize'
  ClientHeight = 145
  ClientWidth = 495
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 430
    Top = 76
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 126
    Width = 495
    Height = 19
    Panels = <>
    ExplicitTop = 127
    ExplicitWidth = 499
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 424
    Height = 126
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
    ExplicitHeight = 127
    object LabeledEdit1: TLabeledEdit
      Left = 137
      Top = 24
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
      Top = 56
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
      Top = 88
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
      Top = 27
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
      Top = 59
      Width = 150
      Height = 17
      Caption = '-and copy here'
      TabOrder = 4
      OnClick = RadioButton1Click
    end
    object RadioButton3: TRadioButton
      Left = 272
      Top = 91
      Width = 150
      Height = 17
      Caption = '-and copy here'
      TabOrder = 5
      OnClick = RadioButton1Click
    end
  end
  object Button1: TButton
    Left = 430
    Top = 13
    Width = 65
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 430
    Top = 95
    Width = 65
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 3
    OnClick = Button2Click
  end
end
