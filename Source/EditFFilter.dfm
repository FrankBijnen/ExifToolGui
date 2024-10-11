object FEditFFilter: TFEditFFilter
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit file filters'
  ClientHeight = 336
  ClientWidth = 499
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 383
    Height = 336
    Align = alLeft
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    ExplicitLeft = -1
    ExplicitTop = -1
    object EdFilter: TEdit
      Left = 9
      Top = 37
      Width = 319
      Height = 21
      TabOrder = 3
      OnChange = EdFilterChange
    end
    object BtnAdd: TButton
      Left = 8
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Add'
      TabOrder = 0
      OnClick = BtnAddClick
    end
    object LbFilter: TListBox
      Left = 8
      Top = 64
      Width = 319
      Height = 262
      ItemHeight = 13
      TabOrder = 4
      OnClick = LbFilterClick
    end
    object BtnUp: TButton
      Left = 333
      Top = 80
      Width = 19
      Height = 52
      Caption = '5'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = BtnUpClick
    end
    object BtnDown: TButton
      Left = 333
      Top = 156
      Width = 19
      Height = 57
      Caption = '6'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = BtnUpClick
    end
    object BtnDel: TButton
      Left = 227
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Delete'
      TabOrder = 2
      OnClick = BtnDelClick
    end
    object BtnUpdate: TButton
      Left = 117
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Update'
      TabOrder = 1
      OnClick = BtnUpdateClick
    end
  end
  object BtnCancel: TButton
    Left = 396
    Top = 254
    Width = 93
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnSave: TButton
    Left = 396
    Top = 301
    Width = 93
    Height = 25
    Caption = 'Save'
    Default = True
    TabOrder = 2
    OnClick = BtnSaveClick
  end
end
