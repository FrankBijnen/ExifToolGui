object FQuickManager: TFQuickManager
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Workspace manager'
  ClientHeight = 501
  ClientWidth = 771
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
    Width = 665
    Height = 482
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
    ExplicitHeight = 481
    object StringGrid1: TStringGrid
      Left = 16
      Top = 8
      Width = 633
      Height = 385
      ColCount = 3
      DefaultColWidth = 160
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowMoving, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 0
      OnSelectCell = StringGrid1SelectCell
    end
    object Button1: TButton
      Left = 16
      Top = 456
      Width = 155
      Height = 25
      Caption = 'Delete selected line'
      TabOrder = 1
      OnClick = Button1Click
    end
    object LabeledEdit1: TLabeledEdit
      Left = 16
      Top = 421
      Width = 155
      Height = 21
      Hint = 
        'Name ending: ['#177' =multi-value tag (Alt+0177)]  [? =Check for tag ' +
        '(Yes/No)]  [* =Fill in value defined in Hint]  [# =Allow numeric' +
        ' editing]'
      EditLabel.Width = 100
      EditLabel.Height = 13
      EditLabel.Caption = 'Tag name to display:'
      MaxLength = 60
      TabOrder = 2
      Text = ''
    end
    object LabeledEdit2: TLabeledEdit
      Left = 175
      Top = 421
      Width = 226
      Height = 21
      Hint = 
        'Example: [-exif:Artist] or [-xmp-dc:Creator] .. For separator, u' +
        'se [-GUI-SEP] and put caption in Tag name.'
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Tag definition:'
      MaxLength = 120
      TabOrder = 3
      Text = ''
    end
    object Button2: TButton
      Left = 407
      Top = 456
      Width = 114
      Height = 25
      Caption = 'Save changes'
      TabOrder = 4
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 536
      Top = 456
      Width = 113
      Height = 25
      Caption = 'Insert into new line'
      TabOrder = 5
      OnClick = Button3Click
    end
    object LabeledEdit3: TLabeledEdit
      Left = 407
      Top = 421
      Width = 242
      Height = 21
      Hint = 
        'Used as default (Fill in) tag value in case Tag name ends with *' +
        '.'
      EditLabel.Width = 46
      EditLabel.Height = 13
      EditLabel.Caption = 'Hint text:'
      MaxLength = 120
      TabOrder = 6
      Text = ''
    end
  end
  object Button4: TButton
    Left = 675
    Top = 419
    Width = 83
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object Button5: TButton
    Left = 675
    Top = 456
    Width = 83
    Height = 25
    Caption = 'Save'
    Default = True
    TabOrder = 2
    OnClick = Button5Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 482
    Width = 771
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 481
    ExplicitWidth = 746
  end
end
