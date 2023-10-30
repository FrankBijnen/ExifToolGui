object FGeotagFiles: TFGeotagFiles
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Geotag files'
  ClientHeight = 381
  ClientWidth = 599
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
    Top = 362
    Width = 599
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 361
    ExplicitWidth = 595
  end
  object BtnCancel: TButton
    Left = 518
    Top = 32
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtnExecute: TButton
    Left = 518
    Top = 331
    Width = 69
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
    ActivePage = TabSetup
    TabOrder = 3
    object TabExecute: TTabSheet
      Caption = 'Execute'
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
        object Label1: TLabel
          Left = 10
          Top = 5
          Width = 115
          Height = 14
          Caption = 'Confirm location info:'
          ParentShowHint = False
          ShowHint = True
        end
        object LblSample: TLabel
          Left = 213
          Top = 4
          Width = 269
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
    object TabSetup: TTabSheet
      Caption = 'Setup'
      ImageIndex = 1
      object Label2: TLabel
        Left = 8
        Top = 5
        Width = 470
        Height = 14
        AutoSize = False
        Caption = 'GeoCode provider:'
      end
      object LblProvince: TLabel
        Left = 169
        Top = 127
        Width = 320
        Height = 80
        AutoSize = False
        Caption = '-'
        WordWrap = True
      end
      object Label3: TLabel
        Left = 8
        Top = 106
        Width = 100
        Height = 13
        Caption = 'Map field to Province'
      end
      object Label4: TLabel
        Left = 8
        Top = 199
        Width = 80
        Height = 13
        Caption = 'Map Field to City'
      end
      object LblCity: TLabel
        Left = 169
        Top = 220
        Width = 320
        Height = 80
        AutoSize = False
        Caption = '-'
        WordWrap = True
      end
      object LblCountrySettings: TLabel
        Left = 8
        Top = 81
        Width = 92
        Height = 19
        Caption = 'Settings for: '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object CmbGeoProvider: TComboBox
        Left = 8
        Top = 25
        Width = 470
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = 'CmbGeoProvider'
        OnClick = CmbGeoProviderClick
        Items.Strings = (
          'GeoCode'
          'Overpass API')
      end
      object CmbProvince: TComboBox
        Left = 8
        Top = 125
        Width = 145
        Height = 21
        TabOrder = 1
        Text = 'CmbProvince'
        OnChange = CmbProvinceChange
      end
      object CmbCity: TComboBox
        Left = 8
        Top = 218
        Width = 145
        Height = 21
        TabOrder = 2
        Text = 'CmbProvince'
        OnChange = CmbCityChange
      end
      object ChkCountryLocation: TCheckBox
        Left = 8
        Top = 55
        Width = 470
        Height = 17
        Caption = 'Map CountryCode'
        TabOrder = 3
        OnClick = ChkCountryLocationClick
      end
    end
  end
end
