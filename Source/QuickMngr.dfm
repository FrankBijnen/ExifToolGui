object FQuickManager: TFQuickManager
  Left = 0
  Top = 0
  ActiveControl = SgWorkSpace
  BorderStyle = bsSizeToolWin
  Caption = 'Workspace manager'
  ClientHeight = 620
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
    Height = 566
    ExplicitLeft = 712
    ExplicitTop = 152
    ExplicitHeight = 100
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 617
    Height = 566
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
      Left = 41
      Top = 64
      Width = 575
      Height = 501
      Align = alClient
      ColCount = 4
      DefaultColWidth = 160
      DefaultRowHeight = 19
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowMoving, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 1
      OnDrawCell = SgWorkSpaceDrawCell
      OnSelectCell = SgWorkSpaceSelectCell
    end
    object PnlFuncTop: TPanel
      Left = 1
      Top = 1
      Width = 615
      Height = 63
      Align = alTop
      TabOrder = 0
      object GrpDefAutoComplete: TGroupBox
        AlignWithMargins = True
        Left = 308
        Top = 2
        Width = 303
        Height = 59
        Margins.Top = 1
        Margins.Bottom = 1
        Align = alClient
        Caption = 'Default auto complete options'
        TabOrder = 0
        ExplicitLeft = 236
        ExplicitWidth = 375
        object CmbDefAutoCompleteMode: TComboBox
          AlignWithMargins = True
          Left = 5
          Top = 17
          Width = 293
          Height = 21
          Margins.Top = 2
          Margins.Bottom = 2
          Align = alTop
          TabOrder = 0
          TabStop = False
          Text = 'Default'
          OnChange = CmbDefAutoCompleteModeChange
          Items.Strings = (
            'None'
            'Auto append'
            'Auto suggest'
            'Auto append + suggest')
          ExplicitTop = 16
          ExplicitWidth = 365
        end
        object ChkDefAutoCorrect: TCheckBox
          AlignWithMargins = True
          Left = 5
          Top = 41
          Width = 293
          Height = 17
          Margins.Top = 1
          Margins.Bottom = 1
          TabStop = False
          Align = alTop
          Caption = 'Auto correct'
          TabOrder = 1
          OnClick = ChkDefAutoCorrectClick
          ExplicitTop = 39
          ExplicitWidth = 365
        end
      end
      object PnlAddDel: TPanel
        Left = 1
        Top = 1
        Width = 304
        Height = 61
        Align = alLeft
        TabOrder = 1
        object SpbAddTag: TSpeedButton
          Left = 3
          Top = 29
          Width = 100
          Height = 25
          Caption = 'Add'
          OnClick = SpbAddTagClick
        end
        object SpbDelTag: TSpeedButton
          Left = 101
          Top = 29
          Width = 100
          Height = 25
          Caption = 'Delete'
          OnClick = SpbDelTagClick
        end
        object SpbDefaults: TSpeedButton
          Left = 199
          Top = 29
          Width = 100
          Height = 25
          Caption = 'Defaults'
          OnClick = SpbDefaultsClick
        end
      end
    end
    object PnlSort: TPanel
      Left = 1
      Top = 64
      Width = 40
      Height = 501
      Align = alLeft
      TabOrder = 2
      object BtnColumnDown: TButton
        Left = 7
        Top = 82
        Width = 25
        Height = 57
        Caption = '6'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Webdings'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = BtnColumnDownClick
      end
      object BtnColumnUp: TButton
        Left = 7
        Top = 6
        Width = 25
        Height = 52
        Caption = '5'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Webdings'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = BtnColumnUpClick
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 601
    Width = 944
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object PnlDetail: TPanel
    Left = 620
    Top = 0
    Width = 324
    Height = 566
    Align = alClient
    Constraints.MinWidth = 300
    TabOrder = 1
    OnResize = PnlDetailResize
    object PnlAutoComplete: TPanel
      Left = 1
      Top = 139
      Width = 322
      Height = 426
      Align = alClient
      TabOrder = 0
      object PctAutoOptions: TPageControl
        Left = 1
        Top = 1
        Width = 320
        Height = 96
        ActivePage = TabAutoCompleteOptions
        Align = alTop
        TabOrder = 0
        object TabAutoCompleteOptions: TTabSheet
          Caption = 'Auto complete options'
          object CmbAutoCompleteMode: TComboBox
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 306
            Height = 21
            Align = alTop
            TabOrder = 0
            Text = 'Default'
            OnChange = CmbAutoCompleteModeChange
            Items.Strings = (
              'Default'
              'None'
              'Auto append'
              'Auto suggest'
              'Auto append + suggest')
          end
          object ChkAutoPopulate: TCheckBox
            Left = 0
            Top = 44
            Width = 312
            Height = 17
            Align = alTop
            Caption = 'Auto populate'
            TabOrder = 2
            OnClick = ChkAutoOptionsClick
          end
          object ChkAutoCorrect: TCheckBox
            Left = 0
            Top = 27
            Width = 312
            Height = 17
            Align = alTop
            Caption = 'Auto correct'
            TabOrder = 1
            OnClick = ChkAutoOptionsClick
          end
        end
      end
      object GrpCustomList: TGroupBox
        Left = 1
        Top = 97
        Width = 320
        Height = 328
        Align = alClient
        Caption = 'Custom list'
        TabOrder = 1
        object MemoAutoLines: TMemo
          AlignWithMargins = True
          Left = 17
          Top = 30
          Width = 286
          Height = 293
          Margins.Left = 15
          Margins.Top = 15
          Margins.Right = 15
          Align = alClient
          TabOrder = 0
          OnKeyUp = MemoAutoLinesKeyUp
        end
      end
    end
    object PnlQuickTags: TPanel
      Left = 1
      Top = 1
      Width = 322
      Height = 138
      Align = alTop
      TabOrder = 1
      object EdTagDesc: TLabeledEdit
        Left = 10
        Top = 18
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
        OnKeyUp = EdTagKeyUp
      end
      object EdTagDef: TLabeledEdit
        Left = 10
        Top = 56
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
        OnKeyUp = EdTagKeyUp
      end
      object EdTagHint: TLabeledEdit
        Left = 10
        Top = 101
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
        OnKeyUp = EdTagKeyUp
      end
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 566
    Width = 944
    Height = 35
    Align = alBottom
    TabOrder = 2
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
    end
  end
end
