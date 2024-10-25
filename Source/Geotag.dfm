object FGeotag: TFGeotag
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Import GPS data'
  ClientHeight = 354
  ClientWidth = 704
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 602
    Top = 285
    Width = 96
    Height = 13
    AutoSize = False
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 335
    Width = 704
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 334
    ExplicitWidth = 700
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 590
    Height = 335
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
    ExplicitHeight = 334
    object Label2: TLabel
      Left = 25
      Top = 212
      Width = 418
      Height = 28
      Caption = 
        'Note: Geotagging precision depends on camera time accuracy. If n' +
        'eccesary,'#10'apply Exif:DateTime shift before geotagging.'
    end
    object LblMoreThan1: TLabel
      Left = 47
      Top = 72
      Width = 484
      Height = 30
      AutoSize = False
      Caption = '(if multiple exist for a set of photos)'
      WordWrap = True
    end
    object LabeledEdit1: TLabeledEdit
      Left = 25
      Top = 26
      Width = 506
      Height = 22
      Hint = 'Path and name of log file -use picker button to select one'
      EditLabel.Width = 43
      EditLabel.Height = 14
      EditLabel.Caption = 'Log file:'
      ReadOnly = True
      TabOrder = 0
      Text = ''
    end
    object Button3: TButton
      Left = 542
      Top = 26
      Width = 32
      Height = 23
      Hint = 'Pick log file'
      Caption = '...'
      TabOrder = 1
      OnClick = Button3Click
    end
    object CheckBox1: TCheckBox
      Left = 25
      Top = 51
      Width = 503
      Height = 21
      Hint = 'To be used, all log files must have equal filename extension'
      Caption = '-use all log files in directory'
      TabOrder = 2
      WordWrap = True
    end
    object RadioGroup1: TRadioGroup
      Left = 27
      Top = 105
      Width = 501
      Height = 66
      Caption = 'Reference DateTime value'
      ItemIndex = 0
      Items.Strings = (
        '-Exif:DateTimeOriginal'
        '-Exif:CreateDate')
      TabOrder = 3
    end
    object CheckBox2: TCheckBox
      Left = 25
      Top = 182
      Width = 206
      Height = 17
      Hint = 
        'Not needed if photos were taken in your local (same as PC) TimeZ' +
        'one area'
      Caption = '-use TimeZone offset (h):'
      TabOrder = 4
      OnClick = CheckBox2Click
    end
    object Edit1: TEdit
      Left = 240
      Top = 177
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
      Left = 289
      Top = 177
      Width = 239
      Height = 27
      Hint = 
        'Set TimeZone offset =difference between logged time (UTC) and ca' +
        'mera DateTime'
      Enabled = False
      Max = 11
      Min = -11
      TabOrder = 6
      TickMarks = tmTopLeft
      OnChange = TrackBar1Change
    end
    object ChkUpdateLocation: TCheckBox
      Left = 25
      Top = 308
      Width = 506
      Height = 17
      Caption = 'Update Geo Location (Country, Province, City)'
      TabOrder = 7
    end
    object EdMargin: TLabeledEdit
      Left = 27
      Top = 275
      Width = 51
      Height = 22
      EditLabel.Width = 358
      EditLabel.Height = 14
      EditLabel.Caption = 'Margin before or beyond Track. (Seconds) (-Api GeoMaxExtSecs)'
      TabOrder = 8
      Text = '1800'
    end
    object UdMargin: TUpDown
      Left = 78
      Top = 275
      Width = 17
      Height = 22
      Associate = EdMargin
      Max = 86400
      Position = 1800
      TabOrder = 9
      Thousands = False
    end
  end
  object Button1: TButton
    Left = 602
    Top = 23
    Width = 96
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 602
    Top = 304
    Width = 96
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 3
    OnClick = Button2Click
  end
  object BtnSetupGeoCode: TButton
    Left = 602
    Top = 254
    Width = 96
    Height = 25
    Caption = 'Setup Geo'
    TabOrder = 4
    OnClick = BtnSetupGeoCodeClick
  end
  object BtnOnMap: TButton
    Left = 602
    Top = 213
    Width = 96
    Height = 25
    Caption = 'Show on Map'
    TabOrder = 5
    OnClick = BtnOnMapClick
  end
end
