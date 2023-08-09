object FPreferences: TFPreferences
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 391
  ClientWidth = 602
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object AdvPageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 521
    Height = 391
    ActivePage = AdvTabSheet1
    Align = alLeft
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ExplicitHeight = 390
    object AdvTabSheet1: TTabSheet
      Caption = 'General'
      object Label1: TLabel
        Left = 16
        Top = 16
        Width = 97
        Height = 13
        Caption = 'Metadata language:'
      end
      object ComboBox1: TComboBox
        Left = 119
        Top = 13
        Width = 232
        Height = 21
        Style = csDropDownList
        TabOrder = 0
      end
      object CheckBox1: TCheckBox
        Left = 16
        Top = 48
        Width = 265
        Height = 17
        Caption = '-in preview, let GUI temporary rotate images'
        TabOrder = 1
      end
      object RgStartupFolder: TRadioGroup
        Left = 16
        Top = 102
        Width = 385
        Height = 73
        Caption = 'Default startup folder'
        ItemIndex = 0
        Items.Strings = (
          '-start in last visited folder'
          '-start in:')
        TabOrder = 2
        OnClick = RadioGroupClick
      end
      object EdStartupFolder: TEdit
        Left = 87
        Top = 145
        Width = 264
        Height = 21
        TabOrder = 3
      end
      object BtnStartupFolder: TButton
        Left = 357
        Top = 145
        Width = 28
        Height = 22
        Caption = '...'
        TabOrder = 4
        OnClick = BtnBrowseFolder
      end
      object RgExportMetaFolder: TRadioGroup
        Left = 16
        Top = 193
        Width = 385
        Height = 73
        Caption = 'Default export metadata folder'
        ItemIndex = 0
        Items.Strings = (
          '-working folder'
          '-save in:')
        TabOrder = 5
        OnClick = RadioGroupClick
      end
      object EdExportMetaFolder: TEdit
        Left = 87
        Top = 236
        Width = 264
        Height = 21
        TabOrder = 6
      end
      object BtnExportMetaFolder: TButton
        Left = 357
        Top = 236
        Width = 28
        Height = 22
        Caption = '...'
        TabOrder = 7
        OnClick = BtnBrowseFolder
      end
      object LabeledEdit1: TLabeledEdit
        Left = 16
        Top = 272
        Width = 25
        Height = 21
        EditLabel.Width = 323
        EditLabel.Height = 21
        EditLabel.Caption = 
          '-separator character displayed for multi-value tags (keywords, e' +
          'tc)'
        LabelPosition = lpRight
        MaxLength = 1
        TabOrder = 8
        Text = ''
      end
      object RadioGroup3: TRadioGroup
        Left = 207
        Top = 305
        Width = 194
        Height = 40
        Caption = 'Thumbnails size'
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          '-96pix'
          '-128pix'
          '-160pix')
        TabOrder = 9
      end
      object CheckBox2: TCheckBox
        Left = 16
        Top = 71
        Width = 297
        Height = 17
        Caption = '-enable internet access for Google map (requires restart)'
        TabOrder = 10
      end
      object CheckBox3: TCheckBox
        Left = 16
        Top = 321
        Width = 185
        Height = 17
        Caption = '-save Filelist Details state on exit'
        TabOrder = 11
      end
    end
    object AdvTabSheet2: TTabSheet
      Caption = 'Other'
      object RgETOverride: TRadioGroup
        Left = 16
        Top = 62
        Width = 385
        Height = 73
        Caption = 'ExifTool.exe location'
        ItemIndex = 0
        Items.Strings = (
          '-Default search (See Windows documentation on CreateProcess)'
          '-Specify')
        TabOrder = 1
        OnClick = RadioGroupClick
      end
      object CheckBox4: TCheckBox
        Left = 16
        Top = 16
        Width = 337
        Height = 17
        Caption = '-Workspace: move focus to next tag/line after value is entered'
        TabOrder = 0
      end
      object EdETOverride: TEdit
        Left = 87
        Top = 105
        Width = 264
        Height = 21
        TabOrder = 2
      end
      object BtnETOverride: TButton
        Left = 357
        Top = 105
        Width = 28
        Height = 22
        Caption = '...'
        TabOrder = 3
        OnClick = BtnBrowseFolder
      end
    end
  end
  object BtnCancel: TButton
    Left = 527
    Top = 310
    Width = 67
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnSave: TButton
    Left = 527
    Top = 356
    Width = 67
    Height = 25
    Caption = 'Save'
    ModalResult = 1
    TabOrder = 2
    OnClick = BtnSaveClick
  end
end
