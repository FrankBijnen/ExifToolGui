object FCopyMetadata: TFCopyMetadata
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Copy metadata options'
  ClientHeight = 271
  ClientWidth = 421
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 344
    Top = 203
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 252
    Width = 421
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 251
    ExplicitWidth = 417
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 329
    Height = 252
    Hint = 'Above data might not be desired to be copied.'
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
    ExplicitHeight = 251
    object Label2: TLabel
      Left = 16
      Top = 16
      Width = 196
      Height = 14
      Caption = 'Confirm copying should include:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 16
      Top = 236
      Width = 301
      Height = 14
      Caption = 'Above tags/groups will only be copied where checked!'
    end
    object CheckBox1: TCheckBox
      Left = 40
      Top = 38
      Width = 177
      Height = 17
      Caption = '-Exif image Width && Height'
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 40
      Top = 61
      Width = 185
      Height = 17
      Caption = '-Exif image Orientation value'
      TabOrder = 1
    end
    object CheckBox3: TCheckBox
      Left = 40
      Top = 86
      Width = 177
      Height = 17
      Caption = '-Exif image Resolution data'
      TabOrder = 2
    end
    object CheckBox4: TCheckBox
      Left = 40
      Top = 109
      Width = 201
      Height = 17
      Caption = '-Exif ColorSpace && InteropIndex'
      TabOrder = 3
    end
    object CheckBox5: TCheckBox
      Left = 40
      Top = 133
      Width = 121
      Height = 17
      Caption = '-Makernotes data'
      TabOrder = 4
    end
    object CheckBox6: TCheckBox
      Left = 40
      Top = 156
      Width = 153
      Height = 17
      Caption = '-Xmp-photoshop group'
      TabOrder = 5
    end
    object CheckBox7: TCheckBox
      Left = 40
      Top = 179
      Width = 105
      Height = 17
      Caption = '-Xmp-crs group'
      TabOrder = 6
    end
    object CheckBox8: TCheckBox
      Left = 40
      Top = 202
      Width = 105
      Height = 17
      Caption = '-Xmp-Exif group'
      TabOrder = 7
    end
  end
  object Button1: TButton
    Left = 344
    Top = 12
    Width = 65
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 344
    Top = 225
    Width = 65
    Height = 25
    Caption = 'Execute'
    TabOrder = 3
    OnClick = Button2Click
  end
end
