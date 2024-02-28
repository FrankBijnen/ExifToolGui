object FrmCheckVersions: TFrmCheckVersions
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Check versions'
  ClientHeight = 264
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object Image1: TImage
    Left = 0
    Top = 1
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
    Top = 8
    Width = 614
    Height = 21
    AutoSize = False
    Caption = 'Installed and available versions'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 235
    Width = 680
    Height = 29
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 223
    ExplicitWidth = 672
    object BtnClose: TBitBtn
      Left = 589
      Top = 1
      Width = 75
      Height = 25
      Kind = bkClose
      NumGlyphs = 2
      TabOrder = 0
    end
    object BtnOpenUrl: TBitBtn
      Left = 485
      Top = 1
      Width = 89
      Height = 25
      Caption = '&Open Url'
      Enabled = False
      Kind = bkYes
      NumGlyphs = 2
      TabOrder = 1
      OnClick = BtnOpenUrlClick
    end
  end
  object LvVersions: TListView
    Left = 45
    Top = 45
    Width = 619
    Height = 179
    Checkboxes = True
    Columns = <
      item
        Caption = 'Method'
        Width = 75
      end
      item
        Caption = 'Url'
        Width = 325
      end
      item
        Caption = 'Installed'
        Width = 75
      end
      item
        Caption = 'Available'
        Width = 75
      end>
    GridLines = True
    Groups = <
      item
        Header = 'ExifToolGui'
        GroupID = 0
        State = [lgsNormal]
        HeaderAlign = taLeftJustify
        FooterAlign = taLeftJustify
        TitleImage = -1
      end
      item
        Header = 'ExifTool'
        GroupID = 1
        State = [lgsNormal]
        HeaderAlign = taLeftJustify
        FooterAlign = taLeftJustify
        TitleImage = -1
      end>
    HideSelection = False
    GroupView = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = LvVersionsDblClick
    OnSelectItem = LvVersionsSelectItem
  end
end
