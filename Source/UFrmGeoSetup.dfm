object FGeoSetup: TFGeoSetup
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Geotag files'
  ClientHeight = 421
  ClientWidth = 593
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
    Top = 402
    Width = 593
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 401
    ExplicitWidth = 589
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
    Top = 371
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
    Height = 388
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
        Top = 167
        Width = 320
        Height = 80
        AutoSize = False
        Caption = '-'
        WordWrap = True
      end
      object Label3: TLabel
        Left = 8
        Top = 146
        Width = 100
        Height = 13
        Caption = 'Map field to Province'
      end
      object Label4: TLabel
        Left = 8
        Top = 239
        Width = 80
        Height = 13
        Caption = 'Map Field to City'
      end
      object LblCity: TLabel
        Left = 169
        Top = 260
        Width = 320
        Height = 80
        AutoSize = False
        Caption = '-'
        WordWrap = True
      end
      object LblCountrySettings: TLabel
        Left = 8
        Top = 121
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
      object Label1: TLabel
        Left = 8
        Top = 52
        Width = 97
        Height = 13
        Caption = 'Preferred language:'
      end
      object CmbGeoProvider: TComboBox
        Left = 8
        Top = 25
        Width = 470
        Height = 21
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = 'GeoCode'
        OnClick = CmbGeoProviderClick
        Items.Strings = (
          'GeoCode'
          'Overpass API')
      end
      object CmbProvince: TComboBox
        Left = 8
        Top = 165
        Width = 145
        Height = 21
        TabOrder = 1
        Text = 'CmbProvince'
        OnChange = CmbProvinceChange
      end
      object CmbCity: TComboBox
        Left = 8
        Top = 258
        Width = 145
        Height = 21
        TabOrder = 2
        Text = 'CmbProvince'
        OnChange = CmbCityChange
      end
      object ChkCountryLocation: TCheckBox
        Left = 3
        Top = 95
        Width = 470
        Height = 17
        Caption = 'Map CountryCode'
        TabOrder = 3
        OnClick = ChkCountryLocationClick
      end
      object CmbOverPasslang: TComboBox
        Left = 8
        Top = 68
        Width = 470
        Height = 21
        TabOrder = 4
        Text = 'CmbOverPasslang'
        OnChange = CmbOverPasslangChange
        OnClick = CmbOverPasslangClick
        OnKeyUp = CmbOverPasslangKeyUp
        Items.Strings = (
          'local'
          'default')
      end
    end
  end
end
