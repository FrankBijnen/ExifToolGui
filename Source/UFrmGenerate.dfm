object FrmGenerate: TFrmGenerate
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Generating thumbnails'
  ClientHeight = 62
  ClientWidth = 573
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object LblGenerate: TLabel
    AlignWithMargins = True
    Left = 20
    Top = 0
    Width = 550
    Height = 29
    Margins.Left = 20
    Margins.Top = 0
    Align = alClient
    Caption = 'LblGenerate'
    Layout = tlCenter
    ExplicitWidth = 63
    ExplicitHeight = 15
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 32
    Width = 573
    Height = 30
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 20
    ExplicitWidth = 565
    object PbProgress: TProgressBar
      Left = 107
      Top = 1
      Width = 465
      Height = 28
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 457
    end
    object BtnClose: TBitBtn
      Left = 1
      Top = 1
      Width = 106
      Height = 28
      Align = alLeft
      Caption = '&Close'
      NumGlyphs = 2
      TabOrder = 1
      OnClick = BtnCloseClick
    end
  end
end
