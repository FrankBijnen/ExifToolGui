object FDateTimeShift: TFDateTimeShift
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Exif: DateTime shift'
  ClientHeight = 220
  ClientWidth = 463
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 383
    Top = 159
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 201
    Width = 463
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 200
    ExplicitWidth = 459
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 369
    Height = 201
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
    ExplicitHeight = 200
    object Label2: TLabel
      Left = 43
      Top = 125
      Width = 75
      Height = 14
      Alignment = taRightJustify
      Caption = 'Shift amount:'
    end
    object LabeledEdit1: TLabeledEdit
      Left = 120
      Top = 16
      Width = 129
      Height = 22
      EditLabel.Width = 103
      EditLabel.Height = 22
      EditLabel.Caption = '*DateTimeOriginal:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = ''
    end
    object LabeledEdit2: TLabeledEdit
      Left = 120
      Top = 44
      Width = 129
      Height = 22
      EditLabel.Width = 66
      EditLabel.Height = 22
      EditLabel.Caption = 'CreateDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 1
      Text = ''
    end
    object LabeledEdit3: TLabeledEdit
      Left = 120
      Top = 72
      Width = 129
      Height = 22
      EditLabel.Width = 65
      EditLabel.Height = 22
      EditLabel.Caption = 'ModifyDate:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 2
      Text = ''
    end
    object CheckBox1: TCheckBox
      Left = 255
      Top = 19
      Width = 58
      Height = 17
      Caption = '-shift'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = CheckBox1Click
    end
    object CheckBox2: TCheckBox
      Left = 255
      Top = 47
      Width = 58
      Height = 17
      Caption = '-shift'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = CheckBox1Click
    end
    object CheckBox3: TCheckBox
      Left = 255
      Top = 75
      Width = 58
      Height = 17
      Caption = '-shift'
      TabOrder = 5
      OnClick = CheckBox1Click
    end
    object MaskEdit1: TMaskEdit
      Left = 120
      Top = 122
      Width = 128
      Height = 22
      Hint = 'Example: [0000:00:01 02:00:00] =shift for 1 day & 2 hours'
      EditMask = '!9999:99:99 99:99:99;1;0'
      MaxLength = 19
      TabOrder = 6
      Text = '    :  :     :  :  '
      OnChange = MaskEdit1Change
    end
    object CheckBox4: TCheckBox
      Left = 255
      Top = 125
      Width = 97
      Height = 17
      Caption = '=Increment'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = CheckBox4Click
    end
    object LabeledEdit4: TLabeledEdit
      Left = 120
      Top = 152
      Width = 129
      Height = 22
      Hint = 'Example of DateTimeOriginal after shifting'
      EditLabel.Width = 98
      EditLabel.Height = 22
      EditLabel.Caption = '*DateTime result:'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 8
      Text = ''
    end
    object CheckBox5: TCheckBox
      Left = 120
      Top = 180
      Width = 193
      Height = 17
      Hint = 'File: Date modified becomes (shifted) DateTimeOriginal value'
      Caption = '-change File: Date modified'
      TabOrder = 9
    end
  end
  object Button1: TButton
    Left = 383
    Top = 15
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 383
    Top = 178
    Width = 69
    Height = 25
    Caption = 'Execute'
    TabOrder = 3
    OnClick = Button2Click
  end
end
