object FEditFFilter: TFEditFFilter
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit file filters'
  ClientHeight = 241
  ClientWidth = 400
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
    Width = 305
    Height = 241
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
    ExplicitHeight = 240
    object Edit1: TEdit
      Left = 8
      Top = 8
      Width = 209
      Height = 21
      TabOrder = 0
      OnChange = Edit1Change
    end
    object Button1: TButton
      Left = 223
      Top = 6
      Width = 74
      Height = 25
      Caption = 'Add filter'
      TabOrder = 1
      OnClick = Button1Click
    end
    object ListBox1: TListBox
      Left = 8
      Top = 37
      Width = 209
      Height = 164
      ItemHeight = 13
      TabOrder = 2
      OnClick = ListBox1Click
    end
    object Button2: TButton
      Left = 8
      Top = 207
      Width = 97
      Height = 25
      Caption = 'Delete selected'
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button5: TButton
      Left = 222
      Top = 53
      Width = 19
      Height = 52
      Caption = '5'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 222
      Top = 129
      Width = 19
      Height = 57
      Caption = '6'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = Button5Click
    end
  end
  object Button3: TButton
    Left = 319
    Top = 161
    Width = 65
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object Button4: TButton
    Left = 319
    Top = 208
    Width = 65
    Height = 25
    Caption = 'Save'
    TabOrder = 2
    OnClick = Button4Click
  end
end
