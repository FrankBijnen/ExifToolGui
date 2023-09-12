object FGeotag: TFGeotag
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Import GPS data'
  ClientHeight = 256
  ClientWidth = 556
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 488
    Top = 195
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 237
    Width = 556
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitWidth = 550
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 473
    Height = 237
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
    object Label2: TLabel
      Left = 16
      Top = 208
      Width = 423
      Height = 28
      Caption = 
        'Note: Geotagging precision depends on camera time accuracy. If ' +
        'neccesary,'#10'apply Exif:DateTime shift before geotagging.'
    end
    object LabeledEdit1: TLabeledEdit
      Left = 64
      Top = 24
      Width = 355
      Height = 22
      Hint = 'Path and name of log file -use picker button to select one'
      EditLabel.Width = 43
      EditLabel.Height = 22
      EditLabel.Caption = 'Log file:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = ''
    end
    object Button3: TButton
      Left = 425
      Top = 24
      Width = 32
      Height = 23
      Hint = 'Pick log file'
      Caption = '...'
      TabOrder = 1
      OnClick = Button3Click
    end
    object CheckBox1: TCheckBox
      Left = 18
      Top = 52
      Width = 401
      Height = 17
      Hint = 'To be used, all log files must have equal filename extension'
      Caption = 
        '-use all log files in directory (if more than one exist for set ' +
        'of photos)'
      TabOrder = 2
    end
    object RadioGroup1: TRadioGroup
      Left = 18
      Top = 89
      Width = 201
      Height = 73
      Caption = 'Reference DateTime value'
      ItemIndex = 0
      Items.Strings = (
        '-Exif:DateTimeOriginal'
        '-Exif:CreateDate')
      TabOrder = 3
    end
    object CheckBox2: TCheckBox
      Left = 18
      Top = 176
      Width = 161
      Height = 17
      Hint = 
        'Not needed if photos were taken in your local (same as PC) TimeZ' +
        'one area'
      Caption = '-use TimeZone offset (h):'
      TabOrder = 4
      OnClick = CheckBox2Click
    end
    object Edit1: TEdit
      Left = 185
      Top = 173
      Width = 34
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      Text = '+00'
    end
    object TrackBar1: TTrackBar
      Left = 225
      Top = 166
      Width = 232
      Height = 27
      Hint = 
        'Set TimeZone offset =difference between logget time (UTC) and ca' +
        'mera DateTime'
      Enabled = False
      Max = 11
      Min = -11
      TabOrder = 6
      TickMarks = tmTopLeft
      OnChange = TrackBar1Change
    end
  end
  object Button1: TButton
    Left = 488
    Top = 23
    Width = 65
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 488
    Top = 214
    Width = 65
    Height = 25
    Caption = 'Execute'
    TabOrder = 3
    OnClick = Button2Click
  end
end
