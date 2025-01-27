object FDateTimeShift: TFDateTimeShift
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Exif/Xmp: DateTime shift'
  ClientHeight = 276
  ClientWidth = 581
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
    Left = 488
    Top = 199
    Width = 91
    Height = 13
    AutoSize = False
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 257
    Width = 581
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 483
    Height = 257
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
    object Label2: TLabel
      Left = 5
      Top = 154
      Width = 145
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Shift amount:'
    end
    object Label3: TLabel
      Left = 5
      Top = 185
      Width = 145
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'DateTime result:'
    end
    object LblDebug: TLabel
      Left = 5
      Top = 205
      Width = 145
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
    object Bevel1: TBevel
      Left = 6
      Top = 5
      Width = 465
      Height = 34
    end
    object LblGroup: TLabel
      Left = 5
      Top = 11
      Width = 145
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Group:'
      Layout = tlCenter
    end
    object LblEdOriginal: TLabeledEdit
      Left = 153
      Top = 45
      Width = 142
      Height = 22
      EditLabel.Width = 98
      EditLabel.Height = 22
      EditLabel.Caption = 'DateTime original:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = ''
    end
    object LblEdCreate: TLabeledEdit
      Left = 153
      Top = 73
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
      Top = 101
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
      Top = 48
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
      Top = 76
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
      Top = 104
      Width = 175
      Height = 17
      Caption = '-shift'
      TabOrder = 5
      OnClick = ChkShiftClick
    end
    object MeShiftAmount: TMaskEdit
      Left = 153
      Top = 151
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
      Top = 154
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
      Top = 207
      Width = 320
      Height = 17
      Hint = 'File: Date modified becomes (shifted) exif:ModifyDate value'
      Caption = '-change File: Date modified'
      TabOrder = 10
      OnClick = ChkShiftClick
    end
    object ChkFileCreated: TCheckBox
      Left = 153
      Top = 230
      Width = 320
      Height = 17
      Hint = 'File: Date created becomes (shifted) exif:CreateDate value'
      Caption = '-change File: Date created'
      TabOrder = 11
      OnClick = ChkShiftClick
    end
    object DtPickDateResult: TDateTimePicker
      Left = 153
      Top = 179
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
      Top = 179
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
    object CmbGroup: TComboBox
      Left = 153
      Top = 11
      Width = 129
      Height = 22
      TabOrder = 12
      Text = 'Exif'
      OnClick = CmbGroupClick
      Items.Strings = (
        'Exif'
        'Xmp'
        'QuickTime')
    end
  end
  object BtnCancel: TButton
    Left = 488
    Top = 8
    Width = 91
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object BtnExecute: TButton
    Left = 488
    Top = 223
    Width = 91
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 3
    OnClick = BtnExecuteClick
  end
end
