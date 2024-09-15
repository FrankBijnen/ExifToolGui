object FDateTimeShift: TFDateTimeShift
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Exif: DateTime shift'
  ClientHeight = 243
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 500
    Top = 166
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 224
    Width = 577
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 483
    Height = 224
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
    ExplicitHeight = 225
    object Label2: TLabel
      Left = 5
      Top = 119
      Width = 145
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Shift amount:'
    end
    object Label3: TLabel
      Left = 5
      Top = 150
      Width = 145
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = '*DateTime result:'
    end
    object LblDebug: TLabel
      Left = 10
      Top = 170
      Width = 137
      Height = 25
      AutoSize = False
      Caption = 'Debug'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Visible = False
      StyleElements = []
    end
    object LblEdOriginal: TLabeledEdit
      Left = 153
      Top = 10
      Width = 142
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
      Width = 142
      Height = 22
      EditLabel.Width = 66
      EditLabel.Height = 22
      EditLabel.Caption = 'CreateDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 2
      Text = ''
    end
    object LblEdModify: TLabeledEdit
      Left = 153
      Top = 66
      Width = 142
      Height = 22
      EditLabel.Width = 65
      EditLabel.Height = 22
      EditLabel.Caption = 'ModifyDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 4
      Text = ''
    end
    object ChkShiftOriginal: TCheckBox
      Left = 302
      Top = 13
      Width = 175
      Height = 17
      Caption = '-shift'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = ChkShiftClick
    end
    object ChkShiftCreate: TCheckBox
      Left = 302
      Top = 41
      Width = 175
      Height = 17
      Caption = '-shift'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = ChkShiftClick
    end
    object ChkShiftModify: TCheckBox
      Left = 302
      Top = 69
      Width = 175
      Height = 17
      Caption = '-shift'
      TabOrder = 5
      OnClick = ChkShiftClick
    end
    object MeShiftAmount: TMaskEdit
      Left = 153
      Top = 116
      Width = 142
      Height = 22
      Hint = 'Example: [0000:00:01 02:00:00] =shift for 1 day & 2 hours'
      EditMask = '!9999:99:99 99:99:99;1;0'
      MaxLength = 19
      TabOrder = 6
      Text = '    :  :     :  :  '
      OnChange = MeShiftAmountChange
    end
    object ChkIncrement: TCheckBox
      Left = 302
      Top = 119
      Width = 175
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
      Width = 320
      Height = 17
      Hint = 'File: Date modified becomes (shifted) exif:ModifyDate value'
      Caption = '-change File: Date modified'
      TabOrder = 10
      OnClick = ChkShiftClick
    end
    object ChkFileCreated: TCheckBox
      Left = 153
      Top = 195
      Width = 320
      Height = 17
      Hint = 'File: Date created becomes (shifted) exif:CreateDate value'
      Caption = '-change File: Date created'
      TabOrder = 11
      OnClick = ChkShiftClick
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
      MinDate = -109205.000000000000000000
      ParseInput = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnChange = DtPickResultChange
      OnUserInput = DtPickDateResultUserInput
    end
    object DtPickTimeResult: TDateTimePicker
      Left = 245
      Top = 144
      Width = 75
      Height = 22
      Date = 45539.000000000000000000
      Format = 'HH:mm:ss'
      Time = 45539.000000000000000000
      Kind = dtkTime
      ParseInput = True
      ParentShowHint = False
      ShowHint = False
      TabOrder = 9
      OnChange = DtPickResultChange
      OnUserInput = DtPickTimeResultUserInput
    end
  end
  object BtnCancel: TButton
    Left = 500
    Top = 8
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object BtnExecute: TButton
    Left = 500
    Top = 190
    Width = 69
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 3
    OnClick = BtnExecuteClick
  end
end
