object FGeotagFiles: TFGeotagFiles
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Geotag files'
  ClientHeight = 408
  ClientWidth = 601
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 389
    Width = 601
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 388
    ExplicitWidth = 587
  end
  object BtnCancel: TButton
    Left = 514
    Top = 32
    Width = 80
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtnExecute: TButton
    Left = 513
    Top = 357
    Width = 80
    Height = 25
    Caption = 'Execute'
    Default = True
    TabOrder = 1
    OnClick = BtnExecuteClick
  end
  object PctMain: TPageControl
    Left = 8
    Top = 8
    Width = 500
    Height = 378
    ActivePage = TabGeoTagData
    TabOrder = 3
    object TabGeoTagData: TTabSheet
      Caption = 'Location data'
      object AdvPanel1: TPanel
        Left = 0
        Top = 0
        Width = 495
        Height = 350
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
        object LblSample: TLabel
          Left = 14
          Top = 4
          Width = 466
          Height = 14
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'LblSample'
        end
        object Label1: TLabel
          Left = 10
          Top = 294
          Width = 131
          Height = 14
          Caption = 'Update in selected files:'
        end
        object ValLocation: TValueListEditor
          Left = 10
          Top = 25
          Width = 470
          Height = 226
          TabOrder = 0
          ColWidths = (
            150
            314)
        end
        object CmbGeoTagMode: TComboBox
          Left = 10
          Top = 314
          Width = 470
          Height = 22
          Style = csDropDownList
          ItemIndex = 1
          TabOrder = 1
          Text = 'Location (Country, Province, City)'
          OnClick = CmbGeoTagModeClick
          Items.Strings = (
            'Coordinates (Lat, Lon) '
            'Location (Country, Province, City)'
            'Coordinates and Location')
        end
        object ChkRemoveExisting: TCheckBox
          Left = 14
          Top = 263
          Width = 454
          Height = 17
          Caption = 'First remove existing GPS tags from all groups'
          TabOrder = 2
        end
      end
    end
  end
  object BtnSetupGeoCode: TButton
    Left = 513
    Top = 309
    Width = 80
    Height = 25
    Caption = 'Setup Geo'
    TabOrder = 4
    OnClick = BtnSetupGeoCodeClick
  end
end
