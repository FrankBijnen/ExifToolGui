object FQuickManager: TFQuickManager
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Workspace manager'
  ClientHeight = 662
  ClientWidth = 944
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 617
    Top = 0
    Height = 608
    ExplicitLeft = 712
    ExplicitTop = 152
    ExplicitHeight = 100
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 617
    Height = 608
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
    object SgWorkSpace: TStringGrid
      Left = 1
      Top = 36
      Width = 615
      Height = 571
      Align = alClient
      ColCount = 3
      DefaultColWidth = 160
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowMoving, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 1
      OnSelectCell = SgWorkSpaceSelectCell
      ExplicitWidth = 608
    end
    object PnlFuncTop: TPanel
      Left = 1
      Top = 1
      Width = 615
      Height = 35
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 663
      object SpbAddTag: TSpeedButton
        Left = 11
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Add'
        OnClick = SpbAddTagClick
      end
      object SpbDelTag: TSpeedButton
        Left = 113
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Delete'
        OnClick = SpbDelTagClick
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 643
    Width = 944
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitWidth = 1010
  end
  object PnlDetail: TPanel
    Left = 620
    Top = 0
    Width = 324
    Height = 608
    Align = alClient
    Constraints.MinWidth = 300
    TabOrder = 1
    OnResize = PnlDetailResize
    ExplicitLeft = 616
    ExplicitWidth = 352
    object EdTagDesc: TLabeledEdit
      Left = 10
      Top = 42
      Width = 300
      Height = 21
      Hint = 
        'Name ending: ['#177' =multi-value tag (Alt+0177)]  [? =Check for tag ' +
        '(Yes/No)]  [* =Fill in value defined in Hint]  [# =Allow numeric' +
        ' editing]'
      AutoSize = False
      EditLabel.Width = 100
      EditLabel.Height = 13
      EditLabel.Caption = 'Tag name to display:'
      MaxLength = 60
      TabOrder = 0
      Text = ''
      OnKeyUp = LabeledEditKeyUp
    end
    object EdTagDef: TLabeledEdit
      Left = 10
      Top = 80
      Width = 300
      Height = 21
      Hint = 
        'Example: [-exif:Artist] or [-xmp-dc:Creator] .. For separator, u' +
        'se [-GUI-SEP] and put caption in Tag name.'
      AutoSize = False
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Tag definition:'
      MaxLength = 120
      TabOrder = 1
      Text = ''
      OnKeyUp = LabeledEditKeyUp
    end
    object EdTagHint: TLabeledEdit
      Left = 10
      Top = 125
      Width = 300
      Height = 21
      Hint = 
        'Used as default (Fill in) tag value in case Tag name ends with *' +
        '.'
      AutoSize = False
      EditLabel.Width = 46
      EditLabel.Height = 13
      EditLabel.Caption = 'Hint text:'
      MaxLength = 120
      TabOrder = 2
      Text = ''
      OnKeyUp = LabeledEditKeyUp
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 608
    Width = 944
    Height = 35
    Align = alBottom
    TabOrder = 2
    ExplicitWidth = 1010
    DesignSize = (
      944
      35)
    object BtnCancel: TBitBtn
      Left = 849
      Top = 3
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 0
      ExplicitLeft = 915
    end
    object BtnOK: TBitBtn
      Left = 768
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 1
      ExplicitLeft = 834
    end
  end
end
