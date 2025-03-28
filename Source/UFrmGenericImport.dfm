object FGenericImport: TFGenericImport
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Generic import previews'
  ClientHeight = 312
  ClientWidth = 604
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
    Top = 293
    Width = 604
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 323
    ExplicitWidth = 586
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 495
    Height = 293
    Align = alLeft
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    ExplicitHeight = 323
    object Label1: TLabel
      Left = 10
      Top = 20
      Width = 140
      Height = 14
      Hint = 'Only the first selected will be used'
      Caption = 'Select preview to import:'
      ParentShowHint = False
      ShowHint = True
    end
    object LblSample: TLabel
      Left = 213
      Top = 19
      Width = 269
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'LblSample'
    end
    object LvPreviews: TListView
      Left = 10
      Top = 40
      Width = 472
      Height = 173
      Checkboxes = True
      Columns = <
        item
          Caption = 'Group'
          Width = 125
        end
        item
          Caption = 'Preview'
          Width = 175
        end
        item
          Alignment = taRightJustify
          Caption = 'Size'
          Width = 125
        end>
      ReadOnly = True
      TabOrder = 0
      ViewStyle = vsReport
    end
    object ChkAutoRotate: TCheckBox
      Left = 10
      Top = 226
      Width = 470
      Height = 17
      Caption = 'Auto rotate imported JPEG'#39's'
      TabOrder = 1
    end
    object CmbCrop: TComboBox
      Left = 10
      Top = 257
      Width = 204
      Height = 22
      ItemIndex = 0
      TabOrder = 2
      Text = 'Do not crop'
      Items.Strings = (
        'Do not crop'
        'Crop to multiple of 8'
        'Crop to multiple of 16')
    end
  end
  object BtnCancel: TButton
    Left = 503
    Top = 15
    Width = 95
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnExecute: TButton
    Left = 503
    Top = 262
    Width = 95
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 2
    OnClick = BtnExecuteClick
  end
end
