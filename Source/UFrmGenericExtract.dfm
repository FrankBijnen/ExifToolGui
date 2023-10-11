object FGenericExtract: TFGenericExtract
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Generic extract previews'
  ClientHeight = 356
  ClientWidth = 598
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
    Top = 337
    Width = 598
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 379
    ExplicitWidth = 597
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 495
    Height = 337
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
    ExplicitHeight = 379
    object Label1: TLabel
      Left = 10
      Top = 20
      Width = 149
      Height = 14
      Hint = 'Select at least 1 preview to extract. Multi-select enabled.'
      Caption = 'Select previews to extract:'
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
      TabOrder = 0
      ViewStyle = vsReport
    end
    object ChkSubdirs: TCheckBox
      Left = 10
      Top = 226
      Width = 475
      Height = 17
      Caption = 
        'Create subdirectories for selected Previews (Example: .\Exif\Jpg' +
        'FromRaw)'
      TabOrder = 1
    end
    object ChkAutoRotate: TCheckBox
      Left = 10
      Top = 274
      Width = 475
      Height = 17
      Caption = 'Auto rotate extracted JPEG'#39's (From Exif:Orientation)'
      TabOrder = 3
    end
    object CmbCrop: TComboBox
      Left = 10
      Top = 298
      Width = 204
      Height = 22
      ItemIndex = 0
      TabOrder = 4
      Text = 'Do not crop'
      Items.Strings = (
        'Do not crop'
        'Crop to multiple of 8'
        'Crop to multiple of 16')
    end
    object ChkOverWrite: TCheckBox
      Left = 10
      Top = 250
      Width = 475
      Height = 17
      Caption = 'Overwrite existing JPEG'#39's'
      TabOrder = 2
    end
  end
  object BtnCancel: TButton
    Left = 514
    Top = 16
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnExecute: TButton
    Left = 514
    Top = 302
    Width = 69
    Height = 25
    Caption = 'Execute'
    TabOrder = 2
    OnClick = BtnExecuteClick
  end
end
