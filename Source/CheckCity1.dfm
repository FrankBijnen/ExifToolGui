object FrmCheckCity: TFrmCheckCity
  Left = 0
  Top = 0
  Caption = 'FrmCheckCity'
  ClientHeight = 482
  ClientWidth = 783
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 0
    Top = 166
    Height = 316
    ExplicitLeft = 373
    ExplicitTop = 103
    ExplicitHeight = 100
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 783
    Height = 166
    Align = alTop
    Alignment = taRightJustify
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitTop = -1
    ExplicitWidth = 787
    object Button1: TButton
      Left = 78
      Top = 135
      Width = 279
      Height = 25
      Caption = 'ListGeo'
      TabOrder = 5
      OnClick = Button1Click
    end
    object Button4: TButton
      Left = 404
      Top = 16
      Width = 102
      Height = 25
      Caption = 'Check OverPass'
      TabOrder = 6
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 404
      Top = 47
      Width = 102
      Height = 25
      Caption = 'Save XLS'
      TabOrder = 7
      OnClick = Button5Click
    end
    object LblEdCountries: TLabeledEdit
      Left = 78
      Top = 5
      Width = 279
      Height = 23
      EditLabel.Width = 74
      EditLabel.Height = 23
      EditLabel.Caption = 'Countrycodes'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = ''
    end
    object LblEdRegions: TLabeledEdit
      Left = 78
      Top = 57
      Width = 279
      Height = 23
      EditLabel.Width = 42
      EditLabel.Height = 23
      EditLabel.Caption = 'Regions'
      LabelPosition = lpLeft
      TabOrder = 2
      Text = ''
    end
    object LblEdCities: TLabeledEdit
      Left = 78
      Top = 109
      Width = 279
      Height = 23
      EditLabel.Width = 29
      EditLabel.Height = 23
      EditLabel.Caption = 'Cities'
      LabelPosition = lpLeft
      TabOrder = 3
      Text = ''
    end
    object LblEdPLCodes: TLabeledEdit
      Left = 78
      Top = 83
      Width = 279
      Height = 23
      EditLabel.Width = 64
      EditLabel.Height = 23
      EditLabel.Caption = 'PLaceCodes'
      LabelPosition = lpLeft
      TabOrder = 4
      Text = ''
    end
    object LblEdlang: TLabeledEdit
      Left = 78
      Top = 31
      Width = 279
      Height = 23
      EditLabel.Width = 52
      EditLabel.Height = 23
      EditLabel.Caption = 'Language'
      LabelPosition = lpLeft
      TabOrder = 1
      Text = ''
    end
  end
  object ListView1: TListView
    Left = 3
    Top = 166
    Width = 780
    Height = 316
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        Caption = 'City GeoNames'
        Width = 100
      end
      item
        Caption = 'PLaceCode'
      end
      item
        Caption = 'Region GeoNames'
        Width = 100
      end
      item
        Caption = 'SubRegion GeoNames'
        Width = 100
      end
      item
        Caption = 'Country'
      end
      item
        Caption = 'Lat, Lon'
      end
      item
        Caption = 'City Overpass'
        Width = 100
      end
      item
        Caption = 'Region Overpass'
        Width = 100
      end>
    TabOrder = 1
    ViewStyle = vsReport
    ExplicitTop = 157
    ExplicitHeight = 325
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xls'
    Filter = '*,xls|*.xls'
    Left = 539
    Top = 30
  end
end
