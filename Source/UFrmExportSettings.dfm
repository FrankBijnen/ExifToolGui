object FrmExportSettings: TFrmExportSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Export settings'
  ClientHeight = 334
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 15
  object PnlBot: TPanel
    Left = 0
    Top = 301
    Width = 530
    Height = 33
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      530
      33)
    object BtnCancel: TBitBtn
      Left = 440
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 0
    end
    object BtnOK: TBitBtn
      Left = 354
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 1
    end
  end
  object MemoTransfer: TMemo
    Left = 0
    Top = 0
    Width = 530
    Height = 41
    Align = alTop
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Lines.Strings = (
      
        'Select the settings to export. All selected settings will be exp' +
        'orted to one (1) ini file.'
      '')
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
  end
  object LvSelections: TListView
    Left = 0
    Top = 41
    Width = 530
    Height = 260
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        Caption = 'Select setting to export'
        Width = 525
      end>
    TabOrder = 2
    ViewStyle = vsReport
  end
end
