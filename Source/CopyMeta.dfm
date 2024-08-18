object FCopyMetadata: TFCopyMetadata
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Copy metadata options'
  ClientHeight = 473
  ClientWidth = 464
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
    Top = 454
    Width = 464
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 352
    Height = 454
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
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 358
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
      Top = 425
      Width = 358
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
      Width = 345
      Height = 347
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
      TabOrder = 1
      ViewStyle = vsReport
      OnCustomDrawItem = LvTagNamesCustomDrawItem
      ExplicitWidth = 337
      ExplicitHeight = 335
    end
    object PnlButtons: TPanel
      AlignWithMargins = True
      Left = 11
      Top = 44
      Width = 345
      Height = 25
      Margins.Left = 10
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 337
      object SpbPredefined: TSpeedButton
        Left = 249
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
        Width = 248
        Height = 22
        Align = alClient
        TabOrder = 0
        Text = 'CmbPredefined'
        OnChange = CmbPredefinedChange
      end
    end
  end
  object PnlRight: TPanel
    Left = 352
    Top = 0
    Width = 112
    Height = 454
    Align = alRight
    TabOrder = 2
    DesignSize = (
      112
      454)
    object Label1: TLabel
      Left = 0
      Top = 376
      Width = 110
      Height = 25
      Alignment = taCenter
      Anchors = [akRight, akBottom]
      AutoSize = False
      Caption = 'Label1'
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
      Left = 0
      Top = 340
      Width = 110
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Preview'
      TabOrder = 1
      OnClick = BtnPreviewClick
    end
    object BtnExecute: TButton
      Left = 0
      Top = 412
      Width = 110
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Execute'
      Default = True
      ModalResult = 1
      TabOrder = 2
    end
  end
end
