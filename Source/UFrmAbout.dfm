object FrmAbout: TFrmAbout
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'About'
  ClientHeight = 281
  ClientWidth = 417
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object Image1: TImage
    Left = 0
    Top = 5
    Width = 39
    Height = 38
    Picture.Data = {
      055449636F6E0000010001002020100000000000E80200001600000028000000
      2000000040000000010004000000000080020000000000000000000000000000
      0000000000000000000080000080000000808000800000008000800080800000
      80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
      FFFFFF0000000000000000000000000000000000000000000000000000000000
      0000000000007CCCCCCCCCCCCCCCCCCCCCCCCC0000007CFFFFFFFFFFFFFFFFFF
      FFFFFC0000007CFFFFFFFFFFFFFFFFFFFFFFFC0000007CFFFFFFFFFFFFFFFFFF
      FFFFFC0000007CFFFF4444FFFF4444FFF44FFC0000007CFFF44FF44FF44FF44F
      F44FFC0000007CFFF44FF44FF44FF44FF44FFC0000007CFFF44F444FF44FF44F
      F44FFC0000007CFFF44FFFFFF44FF44FF44FFC0000007CFFF44FFFFFF44FF44F
      F44FFC0000007CFFFF4444FFF44FF44FF44FFC0000007CFFFFFFFFFFFFFFFFFF
      FFFFFC0000007CFFFFFFFFFFFFFFFFFFFFFFFC0077777CFFFFFFFFFFFFFFFFFF
      FFFFFC0700007CCCCCCCCCCCCCCCCCCCCCCCCC0000007CCCCCCCCCCCCCCCCCCC
      CCCCCC0000007CCCCCCCCCCCCCCCCCCCCCCCCC00000077777777777777777777
      7777770000000000000000000000000000000000000000000000000000000000
      000000000FFFF0F00F0F00F000FF0FFF0FFF0FF00F00000FF00F00F000F00F0F
      0F0F0F000F00000FF00F00F000F00F0F0F0F0F000FFF00F00F0F0FFF0FFF0FFF
      0FFF0F000F000000000000F000F0000000000F000FFFF000000F000F00F00000
      00000F0000000000000000000000000000000000000000000000000000000000
      00000000CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      CCCCCCCCFFFFFFFFFC000001F0000001F0000001F0000001F0000001F0000001
      F0000001F0000001F0000001F0000001F0000001F0000001F0000001F0000001
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000}
  end
  object LblVersion: TLabel
    Left = 45
    Top = 5
    Width = 360
    Height = 65
    AutoSize = False
    Caption = 'LblVersion'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object LblSource: TLabel
    Left = 45
    Top = 82
    Width = 360
    Height = 18
    AutoSize = False
    Caption = 'LblSource'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    StyleElements = [seClient, seBorder]
    OnClick = LblOpenUrl
    OnMouseEnter = LblUrlEnter
    OnMouseLeave = LblUrlLeave
  end
  object LblExifTool: TLabel
    Left = 45
    Top = 103
    Width = 360
    Height = 18
    AutoSize = False
    Caption = 'LblExifTool'
  end
  object LblScreen: TLabel
    Left = 45
    Top = 220
    Width = 360
    Height = 22
    AutoSize = False
    Caption = 'LblScreen'
  end
  object LblExifToolHome: TLabel
    Left = 45
    Top = 125
    Width = 360
    Height = 18
    AutoSize = False
    Caption = 'LblExifToolHome'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    StyleElements = [seClient, seBorder]
    OnClick = LblOpenUrl
    OnMouseEnter = LblUrlEnter
    OnMouseLeave = LblUrlLeave
  end
  object GrpLicense: TGroupBox
    Left = 45
    Top = 151
    Width = 360
    Height = 63
    Caption = 'Licensed under'
    TabOrder = 1
    object LblLicense: TLabel
      Left = 9
      Top = 19
      Width = 350
      Height = 25
      AutoSize = False
      Caption = 'GNU General Public License v3.0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object LblGNUGPL: TLabel
      Left = 9
      Top = 44
      Width = 350
      Height = 14
      AutoSize = False
      Caption = 'LblGNUGPL'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      StyleElements = [seClient, seBorder]
      OnClick = LblOpenUrl
      OnMouseEnter = LblUrlEnter
      OnMouseLeave = LblUrlLeave
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 252
    Width = 417
    Height = 29
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 219
    ExplicitWidth = 397
    DesignSize = (
      417
      29)
    object BtnOk: TBitBtn
      Left = 319
      Top = 1
      Width = 85
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkClose
      NumGlyphs = 2
      TabOrder = 0
    end
  end
end
