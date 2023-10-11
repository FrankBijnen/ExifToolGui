object FLossLessRotate: TFLossLessRotate
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'JPG: Lossless autorotate'
  ClientHeight = 401
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
    Top = 382
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
    Height = 382
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
    ExplicitTop = -6
    ExplicitHeight = 390
    object LblPreview: TLabel
      Left = 10
      Top = 20
      Width = 139
      Height = 14
      Hint = 'Only the first selected will be used. Not required.'
      Caption = 'Select preview to rotate.'
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
    object Label1: TLabel
      Left = 10
      Top = 226
      Width = 84
      Height = 14
      Caption = 'Rotate method'
    end
    object Label2: TLabel
      Left = 10
      Top = 323
      Width = 82
      Height = 14
      Caption = 'Set orientation'
    end
    object Label3: TLabel
      Left = 10
      Top = 274
      Width = 163
      Height = 14
      Caption = 'Crop image size to multilple of'
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
    object CmbCrop: TComboBox
      Left = 10
      Top = 291
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
    object CmbRotate: TComboBox
      Left = 10
      Top = 242
      Width = 472
      Height = 22
      TabOrder = 1
      Text = 'Rotate'
      Items.Strings = (
        'No rotate'
        'Auto rotate'
        '90 degrees'
        '180 degrees'
        '270 degrees')
    end
    object CmbResetOrientation: TComboBox
      Left = 10
      Top = 339
      Width = 472
      Height = 22
      TabOrder = 3
      Text = 'Reset Orientation'
      Items.Strings = (
        'No change'
        '[ 1 ]=0'#176
        '[ 3 ]=180'#176
        '[ 6 ]=+90'#176
        '[ 8 ]=-90'#176)
    end
  end
  object BtnCancel: TButton
    Left = 518
    Top = 14
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnExecute: TButton
    Left = 518
    Top = 346
    Width = 69
    Height = 25
    Caption = 'Execute'
    TabOrder = 2
    OnClick = BtnExecuteClick
  end
end
