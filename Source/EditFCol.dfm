object FEditFColumn: TFEditFColumn
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit file columns'
  ClientHeight = 201
  ClientWidth = 634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  DesignSize = (
    634
    201)
  TextHeight = 13
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 494
    Height = 182
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
    ExplicitWidth = 518
    ExplicitHeight = 184
    DesignSize = (
      494
      182)
    object StringGrid1: TStringGrid
      Left = 16
      Top = 7
      Width = 469
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
      ExplicitWidth = 493
    end
    object LabeledEdit1: TLabeledEdit
      Left = 16
      Top = 116
      Width = 170
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
      Width = 170
      Height = 25
      Caption = 'Delete selected column'
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 200
      Top = 151
      Width = 140
      Height = 25
      Caption = 'Save changes'
      TabOrder = 4
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 389
      Top = 151
      Width = 140
      Height = 25
      Caption = 'Insert into new column'
      TabOrder = 5
      OnClick = Button3Click
    end
  end
  object Button4: TButton
    Left = 500
    Top = 16
    Width = 64
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 524
  end
  object Button5: TButton
    Left = 500
    Top = 151
    Width = 64
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save'
    Default = True
    TabOrder = 2
    OnClick = Button5Click
    ExplicitLeft = 524
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 182
    Width = 634
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 184
    ExplicitWidth = 642
  end
end
