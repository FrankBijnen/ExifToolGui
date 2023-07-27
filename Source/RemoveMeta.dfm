object FRemoveMeta: TFRemoveMeta
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Remove metadata'
  ClientHeight = 343
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 464
    Top = 273
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 324
    Width = 534
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 449
    Height = 324
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
    object CheckBox1: TCheckBox
      Left = 24
      Top = 16
      Width = 153
      Height = 17
      Caption = '-remove ALL metadata'
      TabOrder = 0
      OnClick = CheckBox1Click
    end
    object AdvPanel2: TPanel
      Left = 24
      Top = 39
      Width = 401
      Height = 282
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
        Top = 9
        Width = 73
        Height = 17
        Caption = '-Exif:All'
        TabOrder = 0
        OnClick = CheckBox2Click
      end
      object CheckBox3: TCheckBox
        Left = 32
        Top = 32
        Width = 113
        Height = 17
        Caption = '-Exif:Makernotes'
        TabOrder = 1
        OnClick = CheckBox3Click
      end
      object CheckBox4: TCheckBox
        Left = 168
        Top = 32
        Width = 73
        Height = 17
        Caption = '-Exif:GPS'
        TabOrder = 2
        OnClick = CheckBox3Click
      end
      object CheckBox5: TCheckBox
        Left = 272
        Top = 32
        Width = 73
        Height = 17
        Caption = '-Exif:IFD1'
        TabOrder = 3
        OnClick = CheckBox3Click
      end
      object CheckBox6: TCheckBox
        Left = 16
        Top = 72
        Width = 73
        Height = 17
        Caption = '-Xmp:All'
        TabOrder = 4
        OnClick = CheckBox2Click
      end
      object CheckBox7: TCheckBox
        Left = 32
        Top = 95
        Width = 81
        Height = 17
        Caption = '-Xmp-Exif'
        TabOrder = 5
        OnClick = CheckBox7Click
      end
      object CheckBox8: TCheckBox
        Left = 168
        Top = 93
        Width = 97
        Height = 17
        Caption = '-Xmp-Acdsee'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 6
        OnClick = CheckBox7Click
      end
      object CheckBox9: TCheckBox
        Left = 272
        Top = 93
        Width = 105
        Height = 17
        Caption = '-Xmp-Mediapro'
        TabOrder = 7
        OnClick = CheckBox7Click
      end
      object CheckBox10: TCheckBox
        Left = 32
        Top = 120
        Width = 113
        Height = 17
        Caption = '-Xmp-Photoshop'
        TabOrder = 8
        OnClick = CheckBox7Click
      end
      object CheckBox11: TCheckBox
        Left = 168
        Top = 120
        Width = 73
        Height = 17
        Caption = '-Xmp-Crs'
        TabOrder = 9
        OnClick = CheckBox7Click
      end
      object CheckBox12: TCheckBox
        Left = 272
        Top = 120
        Width = 105
        Height = 17
        Caption = '-Xmp-Microsoft'
        TabOrder = 10
        OnClick = CheckBox7Click
      end
      object CheckBox13: TCheckBox
        Left = 16
        Top = 188
        Width = 73
        Height = 17
        Caption = '-Iptc:All'
        TabOrder = 11
        OnClick = CheckBox2Click
      end
      object CheckBox14: TCheckBox
        Left = 16
        Top = 211
        Width = 105
        Height = 17
        Caption = '-Photoshop:All'
        TabOrder = 12
        OnClick = CheckBox2Click
      end
      object CheckBox15: TCheckBox
        Left = 16
        Top = 234
        Width = 73
        Height = 17
        Caption = '-JFIF:All'
        TabOrder = 13
        OnClick = CheckBox2Click
      end
      object CheckBox16: TCheckBox
        Left = 16
        Top = 257
        Width = 81
        Height = 17
        Caption = '-ICC Profile'
        TabOrder = 14
        OnClick = CheckBox2Click
      end
      object CheckBox17: TCheckBox
        Left = 168
        Top = 147
        Width = 73
        Height = 17
        Caption = '-Xmp-Pdf'
        TabOrder = 15
        OnClick = CheckBox7Click
      end
      object CheckBox18: TCheckBox
        Left = 32
        Top = 147
        Width = 81
        Height = 17
        Caption = '-Xmp-Tiff'
        TabOrder = 16
        OnClick = CheckBox7Click
      end
    end
  end
  object Button1: TButton
    Left = 464
    Top = 16
    Width = 65
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 464
    Top = 292
    Width = 65
    Height = 25
    Caption = 'Execute'
    Enabled = False
    TabOrder = 3
    OnClick = Button2Click
  end
end
