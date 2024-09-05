object FFileDateTime: TFFileDateTime
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Rename files'
  ClientHeight = 472
  ClientWidth = 575
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 453
    Width = 575
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 452
    ExplicitWidth = 571
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 497
    Height = 453
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
    ExplicitHeight = 452
    object AdvPanel2: TPanel
      Left = 16
      Top = 16
      Width = 457
      Height = 302
      Hint = 'Note: No backup files are created when renaming!'
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object RadioGroup1: TRadioGroup
        Left = 16
        Top = 8
        Width = 409
        Height = 49
        Caption = 'Get DateTime from Exif'
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          'DateTimeOriginal'
          'CreateDate'
          'ModifyDate')
        TabOrder = 0
      end
      object RadioGroup2: TRadioGroup
        Left = 16
        Top = 72
        Width = 260
        Height = 97
        Caption = 'New Filename starts/ends with'
        ItemIndex = 0
        Items.Strings = (
          'YYYYMMDD_HHMMSS Filename'
          'YYYYMMDD_HHMM Filename'
          'YYYYMMDD Filename')
        TabOrder = 1
      end
      object RadioGroup3: TRadioGroup
        Left = 16
        Top = 175
        Width = 260
        Height = 73
        Caption = 'Change Filename'
        ItemIndex = 0
        Items.Strings = (
          'keep as is'
          'set to:')
        TabOrder = 2
        OnClick = RadioGroup3Click
      end
      object RadioGroup4: TRadioGroup
        Left = 280
        Top = 175
        Width = 161
        Height = 73
        Caption = 'Save existing Filename to'
        ItemIndex = 0
        Items.Strings = (
          'Exif:DocumentName'
          'Don'#39't save')
        TabOrder = 3
      end
      object CheckBox1: TCheckBox
        Left = 280
        Top = 84
        Width = 169
        Height = 17
        Caption = '-set separator in Date field'
        TabOrder = 4
        OnClick = CheckBox1Click
      end
      object CheckBox2: TCheckBox
        Left = 280
        Top = 107
        Width = 169
        Height = 17
        Caption = '-set separator in Time field'
        TabOrder = 5
        OnClick = CheckBox1Click
      end
      object Edit1: TEdit
        Left = 115
        Top = 220
        Width = 159
        Height = 22
        Color = clBtnFace
        MaxLength = 64
        TabOrder = 6
      end
      object Button2: TButton
        Left = 366
        Top = 262
        Width = 75
        Height = 25
        Caption = 'Rename'
        TabOrder = 7
        OnClick = Button2Click
      end
      object ChkDateFirst: TCheckBox
        Left = 16
        Top = 254
        Width = 249
        Height = 17
        Caption = '-DateTime first'
        TabOrder = 8
        OnClick = CheckBox1Click
      end
      object ChkSequence: TCheckBox
        Left = 16
        Top = 277
        Width = 249
        Height = 17
        Caption = '-Unique filenames (%-c)'
        TabOrder = 9
        OnClick = CheckBox1Click
      end
    end
    object AdvPanel3: TPanel
      Left = 16
      Top = 344
      Width = 457
      Height = 41
      Hint = 'Files will only be renamed where Exif:DocumentName is defined.'
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object RadioButton1: TRadioButton
        Left = 24
        Top = 8
        Width = 340
        Height = 17
        Caption = 'Use Filename from Exif:DocumentName'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object Button3: TButton
        Left = 366
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Rename'
        TabOrder = 1
        OnClick = Button3Click
      end
    end
    object AdvPanel4: TPanel
      Left = 16
      Top = 400
      Width = 457
      Height = 41
      Hint = 'DateTime part must be separated by SPACE!'
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      object RadioButton2: TRadioButton
        Left = 24
        Top = 8
        Width = 340
        Height = 17
        Caption = 'Remove leading DateTime (incl. SPACE)'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object Button4: TButton
        Left = 366
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Rename'
        TabOrder = 1
        OnClick = Button4Click
      end
    end
  end
  object Button1: TButton
    Left = 503
    Top = 16
    Width = 68
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
