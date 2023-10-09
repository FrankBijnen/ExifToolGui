object FLossLessRotate: TFLossLessRotate
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'JPG: Lossless autorotate'
  ClientHeight = 319
  ClientWidth = 607
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
    Top = 300
    Width = 607
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 299
    ExplicitWidth = 603
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 495
    Height = 300
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
    ExplicitHeight = 299
    object Label1: TLabel
      Left = 10
      Top = 20
      Width = 260
      Height = 14
      Caption = 'Select preview to rotate (Only 1, not required)'
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
    object ChkResetOrientation: TCheckBox
      Left = 10
      Top = 229
      Width = 204
      Height = 17
      Caption = 'Reset Orientation to Horizontal'
      TabOrder = 1
    end
    object CmbCrop: TComboBox
      Left = 10
      Top = 253
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
    Top = 250
    Width = 69
    Height = 25
    Caption = 'Execute'
    TabOrder = 3
    OnClick = Button2Click
  end
end
