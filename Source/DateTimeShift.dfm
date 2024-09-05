object FDateTimeShift: TFDateTimeShift
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Exif: DateTime shift'
  ClientHeight = 249
  ClientWidth = 544
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 458
    Top = 166
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 230
    Width = 544
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 229
    ExplicitWidth = 540
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 230
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
    ExplicitHeight = 229
    object Label2: TLabel
      Left = 1
      Top = 119
      Width = 148
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Shift amount:'
    end
    object Label3: TLabel
      Left = 49
      Top = 150
      Width = 98
      Height = 14
      Caption = '*DateTime result:'
    end
    object LblEdOriginal: TLabeledEdit
      Left = 153
      Top = 10
      Width = 140
      Height = 22
      EditLabel.Width = 105
      EditLabel.Height = 22
      EditLabel.Caption = '*DateTime original:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = ''
    end
    object LblEdCreate: TLabeledEdit
      Left = 153
      Top = 38
      Width = 140
      Height = 22
      EditLabel.Width = 66
      EditLabel.Height = 22
      EditLabel.Caption = 'CreateDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 1
      Text = ''
    end
    object LblEdModify: TLabeledEdit
      Left = 153
      Top = 66
      Width = 140
      Height = 22
      EditLabel.Width = 65
      EditLabel.Height = 22
      EditLabel.Caption = 'ModifyDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 2
      Text = ''
    end
    object ChkShiftOriginal: TCheckBox
      Left = 300
      Top = 13
      Width = 110
      Height = 17
      Caption = '-shift'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = ChkShiftOriginalClick
    end
    object ChkShiftCreate: TCheckBox
      Left = 300
      Top = 41
      Width = 110
      Height = 17
      Caption = '-shift'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = ChkShiftOriginalClick
    end
    object ChkShiftModify: TCheckBox
      Left = 300
      Top = 69
      Width = 110
      Height = 17
      Caption = '-shift'
      TabOrder = 5
      OnClick = ChkShiftOriginalClick
    end
    object MeShiftAmount: TMaskEdit
      Left = 153
      Top = 116
      Width = 140
      Height = 22
      Hint = 'Example: [0000:00:01 02:00:00] =shift for 1 day & 2 hours'
      EditMask = '!9999:99:99 99:99:99;1;0'
      MaxLength = 19
      TabOrder = 6
      Text = '    :  :     :  :  '
      OnChange = MeShiftAmountChange
    end
    object ChkIncrement: TCheckBox
      Left = 300
      Top = 119
      Width = 110
      Height = 17
      Caption = '=Increment'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = ChkIncrementClick
    end
    object ChkFileModified: TCheckBox
      Left = 153
      Top = 172
      Width = 232
      Height = 17
      Hint = 'File: Date modified becomes (shifted) DateTimeOriginal value'
      Caption = '-change File: Date modified'
      TabOrder = 8
      OnClick = ChkShiftOriginalClick
    end
    object ChkFileCreated: TCheckBox
      Left = 153
      Top = 195
      Width = 232
      Height = 17
      Hint = 'File: Date created becomes (shifted) DateTimeOriginal value'
      Caption = '-change File: Date created'
      TabOrder = 9
      OnClick = ChkShiftOriginalClick
    end
    object DtPickDateResult: TDateTimePicker
      Left = 153
      Top = 144
      Width = 90
      Height = 22
      Hint = 'Example of DateTimeOriginal after shifting'
      Date = 45539.000000000000000000
      Format = 'yyyy:MM:dd'
      Time = 45539.000000000000000000
      MinDate = -54054.000000000000000000
      ParseInput = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      OnChange = DtPickResultChange
      OnUserInput = DtPickDateResultUserInput
    end
    object DtPickTimeResult: TDateTimePicker
      Left = 245
      Top = 144
      Width = 72
      Height = 22
      Date = 45539.000000000000000000
      Format = 'HH:mm:ss'
      Time = 45539.000000000000000000
      Kind = dtkTime
      ParseInput = True
      TabOrder = 11
      OnChange = DtPickResultChange
      OnUserInput = DtPickTimeResultUserInput
    end
  end
  object BtnCancel: TButton
    Left = 458
    Top = 8
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object BtnExecute: TButton
    Left = 458
    Top = 190
    Width = 69
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 3
    OnClick = BtnExecuteClick
  end
end
