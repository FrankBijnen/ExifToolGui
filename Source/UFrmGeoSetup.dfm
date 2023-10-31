object FGeoSetup: TFGeoSetup
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
  OnDestroy = FormDestroy
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
    OnClick = BtnCancelClick
  end
  object BtnOK: TButton
    Left = 518
    Top = 331
    Width = 69
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtnOKClick
  end
  object PctMain: TPageControl
    Left = 8
    Top = 8
    Width = 500
    Height = 348
    ActivePage = TabSetup
    TabOrder = 3
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
