unit UFrmGeoSetup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.ValEdit,
  Geomap;

type
  TFGeoSetup = class(TScaleForm)
    StatusBar1: TStatusBar;
    BtnCancel: TButton;
    BtnOK: TButton;
    PctMain: TPageControl;
    TabSetup: TTabSheet;
    CmbGeoProvider: TComboBox;
    Label2: TLabel;
    CmbProvince: TComboBox;
    LblProvince: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    CmbCity: TComboBox;
    LblCity: TLabel;
    LblCountrySettings: TLabel;
    ChkCountryLocation: TCheckBox;
    Label1: TLabel;
    CmbOverPasslang: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CmbProvinceChange(Sender: TObject);
    procedure CmbGeoProviderClick(Sender: TObject);
    procedure CmbCityChange(Sender: TObject);
    procedure ChkCountryLocationClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure CmbOverPasslangClick(Sender: TObject);
    procedure CmbOverPasslangChange(Sender: TObject);
    procedure CmbOverPasslangKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    var
      SavedGeoSetting: GEOsettingsRec;
      SavedProvinceList: TStringList;
      SavedCityList: TStringList;
      APlace: TPlace; // No need to free, handled in CoordCache.
    procedure FillPreview;
    procedure FillSetup;
  public
    { Public declarations }
    var
      Lat, Lon: string;
  end;

var
  FGeoSetup: TFGeoSetup;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils, UnitLangResources;

{$R *.dfm}

procedure TFGeoSetup.FillPreview;
begin
  if (not Showing) then
    exit;
  GeoSettings.GetPlaceProvider := TGeoCodeProvider(CmbGeoProvider.ItemIndex);

  // Get Place of selected coordinates
  ClearCoordCache; // Make sure we dont get cached data.
  APlace := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);
  if (APlace = nil) then
    exit;
  LblCountrySettings.Caption := StrSettingsFor + APlace.CountryLocation;

  if (APlace.PrioProvince <> '') then
    LblProvince.Caption := APlace.PrioProvince
  else
    LblProvince.Caption := StrResult + APlace.Province;
  LblProvince.Caption := LblProvince.Caption + #10 +
                         StrAvailableData + #10 +
                         APlace.FProvinceList.Text;

  if (APlace.PrioCity <> '') then
    LblCity.Caption := APlace.PrioCity
  else
    LblCity.Caption := StrResult + APlace.City;
  LblCity.Caption := LblCity.Caption +  #10 +
                     StrAvailableData + #10+
                     APlace.FCityList.Text;

end;

procedure TFGeoSetup.FillSetup;
var
  Preferred: string;
  Level: integer;
begin
  if (APlace = nil) then
    exit;

  CmbProvince.Items.BeginUpdate;
  try
    Preferred := GeoProvinceList.Values[APlace.CountryCode];
    CmbProvince.Items.Clear;
    case GeoSettings.GetPlaceProvider of
      TGeoCodeProvider.gpGeoName:
        begin
          CmbProvince.Items.Add('Default');
          CmbProvince.Items.Add('county');
          CmbProvince.Items.Add('state');
          CmbProvince.Items.Add('None');

          CmbOverPasslang.Enabled := false;
        end;
    TGeoCodeProvider.gpOverPass:
      begin
        begin
          CmbProvince.Items.Add('Default');
          for Level in APlace.RegionLevels do
          begin
            if Level = 0 then
              continue;
            CmbProvince.Items.Add(IntToStr(Level));
          end;
          CmbProvince.Items.Add('None');

          CmbOverPasslang.Enabled := true;
        end;
      end;
    end;
    CmbProvince.ItemIndex := CmbProvince.Items.IndexOf(Preferred);
    if (CmbProvince.ItemIndex < 0) then
      CmbProvince.ItemIndex := 0;
  finally
    CmbProvince.Items.EndUpdate;
  end;

  CmbCity.Items.BeginUpdate;
  try
    Preferred := GeoCityList.Values[APlace.CountryCode];
    CmbCity.Items.Clear;
    case GeoSettings.GetPlaceProvider of
      TGeoCodeProvider.gpGeoName:
        begin
          CmbCity.Items.Add('Default');
          CmbCity.Items.Add('village');
          CmbCity.Items.Add('municipality');
          CmbCity.Items.Add('town');
          CmbCity.Items.Add('city');
          CmbCity.Items.Add('None');
        end;
    TGeoCodeProvider.gpOverPass:
      begin
        begin
          CmbCity.Items.Add('Default');
          for Level in APlace.CityLevels do
          begin
            if Level = 0 then
              continue;
            CmbCity.Items.Add(IntToStr(Level));
          end;
          CmbCity.Items.Add('None');
        end;
      end;
    end;
    CmbCity.ItemIndex := CmbCity.Items.IndexOf(Preferred);
    if (CmbCity.ItemIndex < 0) then
      CmbCity.ItemIndex := 0;
  finally
    CmbCity.Items.EndUpdate;
  end;
end;

procedure TFGeoSetup.ChkCountryLocationClick(Sender: TObject);
begin
  GeoSettings.CountryCodeLocation := ChkCountryLocation.Checked;
  FillPreview;
end;

procedure TFGeoSetup.CmbCityChange(Sender: TObject);
begin
  GeoCityList.Values[APlace.CountryCode] := CmbCity.Text;
  FillPreview;
end;

procedure TFGeoSetup.CmbGeoProviderClick(Sender: TObject);
begin
  GeoSettings.GetPlaceProvider := TGeoCodeProvider(CmbGeoProvider.ItemIndex);
  FillSetup;
  GeoCityList.Values[APlace.CountryCode] := CmbCity.Text;
  GeoProvinceList.Values[APlace.CountryCode] := CmbProvince.Text;
  FillPreview;
end;

procedure TFGeoSetup.CmbOverPasslangChange(Sender: TObject);
begin
  GeoSettings.OverPassLang := CmbOverPasslang.Text;
end;

procedure TFGeoSetup.CmbOverPasslangClick(Sender: TObject);
begin
  GeoSettings.OverPassLang := CmbOverPasslang.Text;
  FillPreview;
end;

procedure TFGeoSetup.CmbOverPasslangKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    FillPreview;
end;

procedure TFGeoSetup.CmbProvinceChange(Sender: TObject);
begin
  GeoProvinceList.Values[APlace.CountryCode] := CmbProvince.Text;
  FillPreview;
end;

procedure TFGeoSetup.BtnCancelClick(Sender: TObject);
begin
  GeoSettings := SavedGeoSetting;
  GeoProvinceList.Assign(SavedProvinceList);
  GeoCityList.Assign(SavedCityList);
end;

procedure TFGeoSetup.BtnOKClick(Sender: TObject);
begin
  ModalResult := MROK;
end;

procedure TFGeoSetup.FormCreate(Sender: TObject);
begin
  SavedProvinceList := TstringList.Create;
  SavedCityList := TstringList.Create;
end;

procedure TFGeoSetup.FormDestroy(Sender: TObject);
begin
  SavedProvinceList.Free;
  SavedCityList.Free;
end;

procedure TFGeoSetup.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  StatusBar1.SimpleText := '';

  SavedGeoSetting := GeoSettings;
  SavedProvinceList.Assign(GeoProvinceList);
  SavedCityList.Assign(GeoCityList);
  CmbGeoProvider.ItemIndex := Ord(GeoSettings.GetPlaceProvider);
  ChkCountryLocation.Checked := GeoSettings.CountryCodeLocation;
  CmbOverPasslang.Text := GeoSettings.OverPassLang;

  FillPreview; // Need CountryCode for setup, so do the Preview first
  FillSetup;
end;

end.
