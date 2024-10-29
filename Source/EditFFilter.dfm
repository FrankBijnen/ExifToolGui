object FEditFFilter: TFEditFFilter
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Configure file filters'
  ClientHeight = 403
  ClientWidth = 464
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
    Width = 464
    Height = 373
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
    ExplicitWidth = 360
    ExplicitHeight = 355
    object BevStartupUse: TBevel
      Left = 40
      Top = 329
      Width = 417
      Height = 20
    end
    object Label1: TLabel
      Left = 45
      Top = 333
      Width = 404
      Height = 13
      AutoSize = False
      Caption = 'Checked item will be used at startup'
    end
    object EdFilter: TEdit
      Left = 40
      Top = 37
      Width = 417
      Height = 21
      TabOrder = 4
      OnChange = EdFilterChange
    end
    object BtnAdd: TButton
      Left = 40
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Add'
      TabOrder = 0
      OnClick = BtnAddClick
    end
    object LbFilter: TCheckListBox
      Left = 40
      Top = 64
      Width = 417
      Height = 262
      ItemHeight = 17
      TabOrder = 5
      OnClick = LbFilterClick
      OnClickCheck = LbFilterClickCheck
      OnDblClick = BtnOkClick
    end
    object BtnUp: TButton
      Left = 7
      Top = 67
      Width = 25
      Height = 52
      Caption = '5'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = BtnUpClick
    end
    object BtnDown: TButton
      Left = 7
      Top = 143
      Width = 25
      Height = 57
      Caption = '6'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      OnClick = BtnUpClick
    end
    object BtnDel: TButton
      Left = 251
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Delete'
      TabOrder = 2
      OnClick = BtnDelClick
    end
    object BtnUpdate: TButton
      Left = 145
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Update'
      TabOrder = 1
      OnClick = BtnUpdateClick
    end
    object BtnDefaults: TButton
      Left = 357
      Top = 6
      Width = 100
      Height = 25
      Caption = 'Defaults'
      TabOrder = 3
      OnClick = BtnDefaultsClick
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 373
    Width = 464
    Height = 30
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 355
    ExplicitWidth = 360
    object BtnCancel: TBitBtn
      Left = 384
      Top = 2
      Width = 75
      Height = 25
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
    end
    object BtnOK: TBitBtn
      Left = 303
      Top = 2
      Width = 75
      Height = 25
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
      OnClick = BtnOkClick
    end
  end
end
