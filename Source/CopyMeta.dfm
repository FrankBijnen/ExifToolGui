object FCopyMetadata: TFCopyMetadata
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Copy metadata options'
  ClientHeight = 464
  ClientWidth = 465
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 445
    Width = 465
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 430
    ExplicitWidth = 448
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 348
    Height = 445
    Hint = 'Above data might not be desired to be copied.'
    Align = alClient
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 336
    ExplicitHeight = 430
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 346
      Height = 40
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Confirm copying should include:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
      ExplicitWidth = 422
    end
    object Label3: TLabel
      Left = 1
      Top = 404
      Width = 346
      Height = 40
      Align = alBottom
      Alignment = taCenter
      AutoSize = False
      Caption = 'Above tags/groups will only be copied where checked!'
      Layout = tlCenter
      WordWrap = True
      ExplicitTop = 428
      ExplicitWidth = 422
    end
    object LvTagNames: TListView
      AlignWithMargins = True
      Left = 11
      Top = 75
      Width = 333
      Height = 326
      Margins.Left = 10
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = 'Tag name'
          Width = 320
        end>
      GridLines = True
      HideSelection = False
      PopupMenu = PopupMenuLv
      TabOrder = 1
      ViewStyle = vsReport
      OnCustomDrawItem = LvTagNamesCustomDrawItem
      ExplicitWidth = 321
      ExplicitHeight = 311
    end
    object PnlButtons: TPanel
      AlignWithMargins = True
      Left = 11
      Top = 44
      Width = 333
      Height = 25
      Margins.Left = 10
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 321
      object SpbPredefined: TSpeedButton
        Left = 237
        Top = 1
        Width = 95
        Height = 23
        Align = alRight
        Caption = 'Predefined'
        OnClick = SpbPredefinedClick
        ExplicitLeft = 250
        ExplicitTop = 3
        ExplicitHeight = 22
      end
      object CmbPredefined: TComboBox
        Left = 1
        Top = 1
        Width = 236
        Height = 22
        Align = alClient
        TabOrder = 0
        Text = 'CmbPredefined'
        OnChange = CmbPredefinedChange
        ExplicitWidth = 224
      end
    end
  end
  object PnlRight: TPanel
    Left = 348
    Top = 0
    Width = 117
    Height = 445
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      117
      445)
    object Label1: TLabel
      Left = 5
      Top = 367
      Width = 110
      Height = 25
      Alignment = taCenter
      Anchors = [akRight, akBottom]
      AutoSize = False
      Caption = 'Label1'
      ExplicitLeft = 0
      ExplicitTop = 374
    end
    object BtnCancel: TButton
      Left = 2
      Top = 8
      Width = 110
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtnPreview: TButton
      Left = 5
      Top = 331
      Width = 110
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Preview'
      TabOrder = 1
      OnClick = BtnPreviewClick
      ExplicitLeft = 0
      ExplicitTop = 316
    end
    object BtnExecute: TButton
      Left = 5
      Top = 403
      Width = 110
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Execute'
      Default = True
      ModalResult = 1
      TabOrder = 2
      ExplicitLeft = 0
      ExplicitTop = 388
    end
  end
  object PopupMenuLv: TPopupMenu
    OnPopup = PopupMenuLvPopup
    Left = 387
    Top = 242
    object Groupview1: TMenuItem
      AutoCheck = True
      Caption = 'Group view'
      OnClick = Groupview1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Checkgroup1: TMenuItem
      Caption = 'Check group'
      OnClick = Checkgroup1Click
    end
    object Uncheckgroup1: TMenuItem
      Tag = 1
      Caption = 'Uncheck group'
      OnClick = Checkgroup1Click
    end
  end
end
