object FEditFColumn: TFEditFColumn
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit file columns'
  ClientHeight = 205
  ClientWidth = 650
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  DesignSize = (
    650
    205)
  TextHeight = 13
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 542
    Height = 186
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 538
    ExplicitHeight = 185
    DesignSize = (
      542
      186)
    object StringGrid1: TStringGrid
      Left = 16
      Top = 8
      Width = 510
      Height = 81
      Anchors = [akLeft, akTop, akRight]
      ColCount = 1
      DefaultColWidth = 120
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goColSizing, goColMoving]
      ScrollBars = ssHorizontal
      TabOrder = 0
      OnSelectCell = StringGrid1SelectCell
      ExplicitWidth = 506
    end
    object LabeledEdit1: TLabeledEdit
      Left = 16
      Top = 116
      Width = 169
      Height = 21
      Hint = 'Example: Photographer'
      EditLabel.Width = 68
      EditLabel.Height = 13
      EditLabel.Caption = 'Column name:'
      TabOrder = 1
      Text = ''
    end
    object LabeledEdit2: TLabeledEdit
      Left = 200
      Top = 116
      Width = 329
      Height = 21
      Hint = 'Example: -exif:Artist'
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Metadata tag:'
      TabOrder = 2
      Text = ''
    end
    object Button1: TButton
      Left = 16
      Top = 151
      Width = 129
      Height = 25
      Caption = 'Delete selected column'
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 200
      Top = 151
      Width = 97
      Height = 25
      Caption = 'Save changes'
      TabOrder = 4
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 392
      Top = 151
      Width = 137
      Height = 25
      Caption = 'Insert into new column'
      TabOrder = 5
      OnClick = Button3Click
    end
  end
  object Button4: TButton
    Left = 548
    Top = 16
    Width = 64
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 544
  end
  object Button5: TButton
    Left = 548
    Top = 151
    Width = 64
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save'
    Default = True
    TabOrder = 2
    OnClick = Button5Click
    ExplicitLeft = 544
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 186
    Width = 650
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 185
    ExplicitWidth = 646
  end
end
