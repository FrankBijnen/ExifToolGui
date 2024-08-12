object FCopyMetadata: TFCopyMetadata
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Copy metadata options'
  ClientHeight = 387
  ClientWidth = 462
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 388
    Top = 317
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 368
    Width = 462
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 367
    ExplicitWidth = 458
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 380
    Height = 368
    Hint = 'Above data might not be desired to be copied.'
    Align = alLeft
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    ExplicitHeight = 367
    object Label2: TLabel
      Left = 16
      Top = 16
      Width = 196
      Height = 14
      Caption = 'Confirm copying should include:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 16
      Top = 342
      Width = 301
      Height = 14
      Caption = 'Above tags/groups will only be copied where checked!'
    end
    object LvTagNames: TListView
      Left = 16
      Top = 76
      Width = 348
      Height = 260
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
      OnEdited = LvTagNamesEdited
    end
    object PnlButtons: TPanel
      Left = 16
      Top = 45
      Width = 348
      Height = 25
      TabOrder = 0
      object SpbAdd: TSpeedButton
        Left = 2
        Top = 3
        Width = 95
        Height = 22
        Caption = 'Add'
        OnClick = SpbAddClick
      end
      object SpbDel: TSpeedButton
        Left = 84
        Top = 3
        Width = 95
        Height = 22
        Caption = 'Del'
        OnClick = SpbDelClick
      end
      object SpbEdit: TSpeedButton
        Left = 167
        Top = 3
        Width = 95
        Height = 22
        Caption = 'Edit'
        OnClick = SpbEditClick
      end
      object SpbPredefined: TSpeedButton
        Left = 250
        Top = 3
        Width = 95
        Height = 22
        Caption = 'Predefined'
        OnClick = SpbPredefinedClick
      end
    end
  end
  object BtnCancel: TButton
    Left = 388
    Top = 10
    Width = 65
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnExecute: TButton
    Left = 388
    Top = 339
    Width = 65
    Height = 25
    Caption = 'Execute'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object BtnPreview: TButton
    Left = 388
    Top = 286
    Width = 65
    Height = 25
    Caption = 'Preview'
    TabOrder = 2
    OnClick = BtnPreviewClick
  end
end
