object FEditFFilter: TFEditFFilter
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit file filters'
  ClientHeight = 375
  ClientWidth = 374
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
    Width = 374
    Height = 345
    Align = alClient
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    ExplicitTop = -4
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
      OnDblClick = BtnOkClick
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
  object Panel1: TPanel
    Left = 0
    Top = 345
    Width = 374
    Height = 30
    Align = alBottom
    TabOrder = 1
    ExplicitWidth = 373
    object BtnCancel: TBitBtn
      Left = 292
      Top = 2
      Width = 75
      Height = 25
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 0
    end
    object BtnOK: TBitBtn
      Left = 211
      Top = 2
      Width = 75
      Height = 25
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 1
      OnClick = BtnOkClick
    end
  end
end
