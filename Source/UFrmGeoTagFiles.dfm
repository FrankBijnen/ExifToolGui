object FGeotagFiles: TFGeotagFiles
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Geotag files'
  ClientHeight = 380
  ClientWidth = 607
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
    Top = 361
    Width = 607
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitWidth = 595
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
    Left = 514
    Top = 331
    Width = 80
    Height = 25
    Caption = 'Execute'
    TabOrder = 1
    OnClick = BtnExecuteClick
  end
  object PctMain: TPageControl
    Left = 8
    Top = 8
    Width = 500
    Height = 348
    ActivePage = TabGeoTagData
    TabOrder = 3
    object TabGeoTagData: TTabSheet
      Caption = 'Location data'
      object AdvPanel1: TPanel
        Left = 0
        Top = 0
        Width = 495
        Height = 320
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
        object ValLocation: TValueListEditor
          Left = 10
          Top = 25
          Width = 470
          Height = 226
          TabOrder = 1
          ColWidths = (
            150
            314)
        end
        object ChkUpdateLocationInfo: TCheckBox
          Left = 10
          Top = 288
          Width = 470
          Height = 17
          Caption = 
            'Update location info (Country, Province, City and Location) in s' +
            'elected files'
          TabOrder = 0
        end
        object ChkUpdateLatLon: TCheckBox
          Left = 10
          Top = 260
          Width = 470
          Height = 17
          Caption = 'Update Lat/Lon values in selected files'
          TabOrder = 2
        end
      end
    end
  end
  object BtnSetupGeoCode: TButton
    Left = 514
    Top = 284
    Width = 80
    Height = 25
    Caption = 'Setup Geo'
    TabOrder = 4
    OnClick = BtnSetupGeoCodeClick
  end
end
