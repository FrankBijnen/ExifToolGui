object FCopyMetaSingle: TFCopyMetaSingle
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Import into selected files'
  ClientHeight = 296
  ClientWidth = 502
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 433
    Top = 226
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 277
    Width = 502
    Height = 19
    Panels = <>
    ExplicitTop = 288
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 417
    Height = 277
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
    ExplicitHeight = 283
    object CheckBox1: TCheckBox
      Left = 24
      Top = 16
      Width = 145
      Height = 17
      Caption = '-import ALL metadata'
      TabOrder = 0
      OnClick = CheckBox1Click
    end
    object AdvPanel2: TPanel
      Left = 24
      Top = 39
      Width = 369
      Height = 200
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object CheckBox2: TCheckBox
        Left = 16
        Top = 8
        Width = 73
        Height = 17
        Caption = '-Exif:All'
        TabOrder = 0
        OnClick = CheckBox2Click
      end
      object CheckBox3: TCheckBox
        Left = 32
        Top = 31
        Width = 113
        Height = 17
        Caption = '-Exif:Makernotes'
        TabOrder = 1
        OnClick = CheckBox3Click
      end
      object CheckBox4: TCheckBox
        Left = 168
        Top = 31
        Width = 73
        Height = 17
        Caption = '-Exif:GPS'
        TabOrder = 2
        OnClick = CheckBox3Click
      end
      object CheckBox5: TCheckBox
        Left = 16
        Top = 72
        Width = 73
        Height = 17
        Caption = '-Xmp:All'
        TabOrder = 3
        OnClick = CheckBox2Click
      end
      object CheckBox6: TCheckBox
        Left = 16
        Top = 104
        Width = 73
        Height = 17
        Caption = '-Iptc:All'
        TabOrder = 4
        OnClick = CheckBox2Click
      end
      object CheckBox7: TCheckBox
        Left = 16
        Top = 138
        Width = 89
        Height = 17
        Caption = '-ICC Profile'
        TabOrder = 5
        OnClick = CheckBox2Click
      end
      object CheckBox8: TCheckBox
        Left = 16
        Top = 170
        Width = 73
        Height = 17
        Caption = '-Gps:All'
        TabOrder = 6
        OnClick = CheckBox2Click
      end
    end
    object CheckBox9: TCheckBox
      Left = 24
      Top = 250
      Width = 355
      Height = 17
      Caption = 'Dont overwrite existing data (-wm cg)'
      TabOrder = 2
    end
  end
  object Button1: TButton
    Left = 433
    Top = 16
    Width = 64
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 430
    Top = 245
    Width = 64
    Height = 25
    Caption = 'Execute'
    TabOrder = 3
    OnClick = Button2Click
  end
end
