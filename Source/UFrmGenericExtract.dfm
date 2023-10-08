object FGenericExtract: TFGenericExtract
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Generic extract previews'
  ClientHeight = 399
  ClientWidth = 601
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
    Top = 380
    Width = 601
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
    Height = 380
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
    ExplicitHeight = 379
    object Label1: TLabel
      Left = 10
      Top = 20
      Width = 149
      Height = 14
      Caption = 'Select previews to extract:'
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
      Width = 166
      Height = 17
      Caption = 'Create subdirectories'
      TabOrder = 1
    end
    object ChkAutoRotate: TCheckBox
      Left = 10
      Top = 274
      Width = 204
      Height = 17
      Caption = 'Auto rotate extracted JPEG'#39's'
      TabOrder = 2
    end
    object CmbCrop: TComboBox
      Left = 10
      Top = 298
      Width = 204
      Height = 22
      ItemIndex = 0
      TabOrder = 3
      Text = 'Do not crop'
      Items.Strings = (
        'Do not crop'
        'Crop to multiple of 8'
        'Crop to multiple of 16')
    end
    object ChkOverWrite: TCheckBox
      Left = 10
      Top = 250
      Width = 204
      Height = 17
      Caption = 'Overwrite existing '
      TabOrder = 4
    end
  end
  object Button1: TButton
    Left = 528
    Top = 17
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 528
    Top = 342
    Width = 69
    Height = 25
    Caption = 'Execute'
    TabOrder = 3
    OnClick = Button2Click
  end
end
