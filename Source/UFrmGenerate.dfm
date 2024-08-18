object FrmGenerate: TFrmGenerate
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Generating thumbnails'
  ClientHeight = 50
  ClientWidth = 565
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
    Width = 542
    Height = 17
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
    Top = 20
    Width = 565
    Height = 30
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 8
    ExplicitWidth = 557
    object PbProgress: TProgressBar
      Left = 107
      Top = 1
      Width = 457
      Height = 28
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 449
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
