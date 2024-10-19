object FFileDateTime: TFFileDateTime
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Rename files'
  ClientHeight = 493
  ClientWidth = 710
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
    Top = 474
    Width = 710
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 450
    ExplicitWidth = 706
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 631
    Height = 474
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
    ExplicitHeight = 450
    object AdvPanel2: TPanel
      Left = 16
      Top = 16
      Width = 600
      Height = 367
      Hint = 'Note: No backup files are created when renaming!'
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object RadioGroup1: TRadioGroup
        Left = 16
        Top = 8
        Width = 564
        Height = 49
        Caption = 'Get DateTime from Exif'
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          'DateTimeOriginal'
          'CreateDate'
          'ModifyDate')
        TabOrder = 0
      end
      object RadioGroup2: TRadioGroup
        Left = 16
        Top = 63
        Width = 324
        Height = 90
        Caption = 'New Filename starts/ends with'
        ItemIndex = 0
        Items.Strings = (
          'YYYYMMDD_HHMMSS Filename'
          'YYYYMMDD_HHMM Filename'
          'YYYYMMDD Filename')
        TabOrder = 1
      end
      object RadioGroup3: TRadioGroup
        Left = 16
        Top = 155
        Width = 324
        Height = 65
        Caption = 'Change Filename'
        ItemIndex = 0
        Items.Strings = (
          'keep as is'
          'set to:')
        TabOrder = 2
        OnClick = RadioGroup3Click
      end
      object RadioGroup4: TRadioGroup
        Left = 357
        Top = 155
        Width = 223
        Height = 65
        Caption = 'Save existing Filename to'
        ItemIndex = 0
        Items.Strings = (
          'Exif:DocumentName'
          'Don'#39't save')
        TabOrder = 3
      end
      object CheckBox1: TCheckBox
        Left = 357
        Top = 73
        Width = 208
        Height = 17
        Caption = '-set separator in Date field'
        TabOrder = 4
        OnClick = CheckBox1Click
      end
      object CheckBox2: TCheckBox
        Left = 357
        Top = 96
        Width = 208
        Height = 17
        Caption = '-set separator in Time field'
        TabOrder = 5
        OnClick = CheckBox1Click
      end
      object Edit1: TEdit
        Left = 115
        Top = 191
        Width = 206
        Height = 22
        Color = clBtnFace
        MaxLength = 64
        TabOrder = 6
        OnChange = EdPreviewChange
      end
      object Button2: TButton
        Left = 505
        Top = 335
        Width = 75
        Height = 25
        Caption = 'Rename'
        TabOrder = 7
        OnClick = Button2Click
      end
      object ChkDateFirst: TCheckBox
        Left = 16
        Top = 223
        Width = 324
        Height = 17
        Caption = '-DateTime first'
        TabOrder = 8
        OnClick = CheckBox1Click
      end
      object RadDuplicates: TRadioGroup
        Left = 16
        Top = 246
        Width = 564
        Height = 82
        Caption = 'Action on duplicate filename'
        ItemIndex = 1
        Items.Strings = (
          'None (Show error)'
          'Use standard sequence %-c'
          'Use custom sequence')
        TabOrder = 9
        OnClick = RadDuplicatesClick
      end
      object PnlCustomSeq: TPanel
        Left = 378
        Top = 298
        Width = 196
        Height = 28
        TabOrder = 10
        object EdSeqPref: TEdit
          Left = 3
          Top = 2
          Width = 26
          Height = 22
          TabOrder = 0
          Text = '-('
          OnChange = EdPreviewChange
        end
        object EdSeqPerc: TEdit
          Left = 31
          Top = 2
          Width = 18
          Height = 22
          Enabled = False
          ReadOnly = True
          TabOrder = 1
          Text = '%'
        end
        object NbSeqStart: TNumberBox
          Left = 55
          Top = 2
          Width = 34
          Height = 22
          MaxLength = 4
          TabOrder = 2
          OnChange = EdPreviewChange
        end
        object UdSeqStart: TUpDown
          Left = 89
          Top = 2
          Width = 16
          Height = 22
          Associate = NbSeqStart
          TabOrder = 3
        end
        object EdSeqColon: TEdit
          Left = 107
          Top = 2
          Width = 16
          Height = 22
          Enabled = False
          ReadOnly = True
          TabOrder = 4
          Text = ':'
        end
        object NbSeqWidth: TNumberBox
          Left = 124
          Top = 2
          Width = 22
          Height = 22
          MinValue = 1.000000000000000000
          MaxValue = 5.000000000000000000
          MaxLength = 1
          TabOrder = 5
          Value = 4.000000000000000000
          OnChange = EdPreviewChange
        end
        object UdWidth: TUpDown
          Left = 146
          Top = 2
          Width = 16
          Height = 22
          Associate = NbSeqWidth
          Position = 4
          TabOrder = 6
        end
        object EdSeqSuf: TEdit
          Left = 163
          Top = 2
          Width = 26
          Height = 22
          TabOrder = 7
          Text = ')'
          OnChange = EdPreviewChange
        end
      end
    end
    object AdvPanel3: TPanel
      Left = 16
      Top = 390
      Width = 600
      Height = 35
      Hint = 'Files will only be renamed where Exif:DocumentName is defined.'
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object RadioButton1: TRadioButton
        Left = 24
        Top = 6
        Width = 450
        Height = 17
        Caption = 'Use Filename from Exif:DocumentName'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object Button3: TButton
        Left = 505
        Top = 5
        Width = 75
        Height = 25
        Caption = 'Rename'
        TabOrder = 1
        OnClick = Button3Click
      end
    end
    object AdvPanel4: TPanel
      Left = 16
      Top = 434
      Width = 600
      Height = 35
      Hint = 'DateTime part must be separated by SPACE!'
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      object RadioButton2: TRadioButton
        Left = 24
        Top = 10
        Width = 450
        Height = 17
        Caption = 'Remove leading DateTime (incl. SPACE)'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object Button4: TButton
        Left = 505
        Top = 5
        Width = 75
        Height = 25
        Caption = 'Rename'
        TabOrder = 1
        OnClick = Button4Click
      end
    end
  end
  object Button1: TButton
    Left = 637
    Top = 16
    Width = 68
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
