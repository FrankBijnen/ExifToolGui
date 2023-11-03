object FGeoSearch: TFGeoSearch
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Search place'
  ClientHeight = 421
  ClientWidth = 593
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
      object GrpCitySearch: TGroupBox
        Left = 3
        Top = 187
        Width = 467
        Height = 104
        Caption = 'City search'
        TabOrder = 5
        object ChkComplete: TCheckBox
          Left = 16
          Top = 62
          Width = 399
          Height = 17
          Caption = 'Complete word (faster)'
          TabOrder = 0
          OnClick = ChkCompleteClick
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
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = 'GeoCode'
        OnChange = CmbGeoProviderChange
        OnClick = CmbGeoProviderChange
        Items.Strings = (
          'GeoCode'
          'Overpass API')
      end
      object EdSearchCity: TLabeledEdit
        Left = 8
        Top = 81
        Width = 470
        Height = 21
        EditLabel.Width = 72
        EditLabel.Height = 13
        EditLabel.Caption = 'Seacrh for City'
        TabOrder = 1
        Text = ''
      end
      object EdRegion: TLabeledEdit
        Left = 8
        Top = 121
        Width = 470
        Height = 21
        EditLabel.Width = 109
        EditLabel.Height = 13
        EditLabel.Caption = 'Within Country/Region'
        TabOrder = 2
        Text = ''
        OnChange = EdRegionChange
      end
      object EdBounds: TLabeledEdit
        Left = 8
        Top = 160
        Width = 470
        Height = 21
        EditLabel.Width = 68
        EditLabel.Height = 13
        EditLabel.Caption = 'Within Bounds'
        TabOrder = 3
        Text = ''
      end
      object ChkCaseSensitve: TCheckBox
        Left = 19
        Top = 215
        Width = 399
        Height = 17
        Caption = 'Case sensitive (faster)'
        TabOrder = 4
        OnClick = ChkCaseSensitveClick
      end
    end
  end
end
