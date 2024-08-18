object FGeoSearch: TFGeoSearch
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Search place'
  ClientHeight = 419
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 400
    Width = 592
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 399
    ExplicitWidth = 581
  end
  object BtnCancel: TButton
    Left = 518
    Top = 32
    Width = 69
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnOK: TButton
    Left = 518
    Top = 371
    Width = 69
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = BtnOKClick
  end
  object PctMain: TPageControl
    Left = 8
    Top = 8
    Width = 500
    Height = 388
    ActivePage = TabSearch
    TabOrder = 3
    object TabSearch: TTabSheet
      Caption = 'Search'
      ImageIndex = 1
      object Label2: TLabel
        Left = 8
        Top = 5
        Width = 470
        Height = 14
        AutoSize = False
        Caption = 'GeoCode provider:'
      end
      object Label1: TLabel
        Left = 8
        Top = 52
        Width = 97
        Height = 13
        Caption = 'Preferred language:'
      end
      object LblCountryRegion: TLabel
        Left = 8
        Top = 140
        Width = 470
        Height = 13
        AutoSize = False
        Caption = 'Country or Region'
      end
      object GrpCitySearch: TGroupBox
        Left = 8
        Top = 238
        Width = 467
        Height = 104
        Caption = 'City search'
        TabOrder = 4
        object ChkComplete: TCheckBox
          Left = 16
          Top = 62
          Width = 399
          Height = 17
          Caption = 'Complete word (faster)'
          TabOrder = 1
          OnClick = ChkCompleteClick
        end
        object ChkCaseSensitive: TCheckBox
          Left = 16
          Top = 25
          Width = 399
          Height = 17
          Caption = 'Case sensitive (faster)'
          TabOrder = 0
          OnClick = ChkCaseSensitiveClick
        end
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
        ParentFont = False
        TabOrder = 0
        OnChange = CmbGeoProviderChange
        OnClick = CmbGeoProviderChange
        Items.Strings = (
          'GeoCode'
          'Overpass API'
          'ExifTool geolocation')
      end
      object EdSearchCity: TLabeledEdit
        Left = 8
        Top = 112
        Width = 470
        Height = 21
        EditLabel.Width = 72
        EditLabel.Height = 13
        EditLabel.Caption = 'Search for City'
        TabOrder = 2
        Text = ''
      end
      object EdBounds: TLabeledEdit
        Left = 8
        Top = 200
        Width = 470
        Height = 21
        EditLabel.Width = 68
        EditLabel.Height = 13
        EditLabel.Caption = 'Within Bounds'
        TabOrder = 3
        Text = ''
      end
      object CmbLang: TComboBox
        Left = 8
        Top = 68
        Width = 470
        Height = 21
        TabOrder = 1
        Text = 'CmbLang'
        OnChange = CmbLangChange
        OnClick = CmbLangChange
        Items.Strings = (
          'local'
          'default')
      end
      object CmbCountryRegion: TComboBox
        Left = 8
        Top = 156
        Width = 470
        Height = 21
        TabOrder = 5
        OnChange = CmbCountryRegionChange
        OnDrawItem = CmbCountryRegionDrawItem
      end
    end
  end
end
