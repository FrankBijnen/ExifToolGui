unit UFrmGeoSetup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.ValEdit,
  Geomap;

type
  TPLaceChange = set of (pcProvider, pcLang, pcProvince, pcCity);

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
    Label1: TLabel;
    CmbLang: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CmbProvinceChange(Sender: TObject);
    procedure CmbGeoProviderClick(Sender: TObject);
    procedure CmbCityChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure CmbLangChange(Sender: TObject);
  private
    { Private declarations }
    var
      SavedGeoSetting: GEOsettingsRec;
      SavedProvinceList: TStringList;
      SavedCityList: TStringList;
      APlace: TPlace; // No need to free, handled in CoordCache.
    procedure FillPreview;
    procedure FillSetupProvince(PlaceChange: TPLaceChange = []);
    procedure FillSetupCity(PlaceChange: TPLaceChange = []);
    procedure FillSetup(PlaceChange: TPLaceChange = []);
    procedure GetPlace(PlaceChange: TPLaceChange = []);
    procedure UpdateDesign(PlaceChange: TPLaceChange = []);
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

  LblCountrySettings.Caption := StrNoData;
  LblProvince.Caption := StrNoData;
  LblCity.Caption := StrNoData;

// Need a Place to show the info
  if (APlace = nil) then
    exit;

  LblCountrySettings.Caption := StrSettingsFor + APlace.CountryLocation;
  LblProvince.Caption := StrResult + APlace.Province;
  LblProvince.Caption := LblProvince.Caption + #10 +
                         StrAvailableData + #10 +
                         APlace.FProvinceList.Text;

  LblCity.Caption := StrResult + APlace.City;
  LblCity.Caption := LblCity.Caption +  #10 +
                     StrAvailableData + #10+
                     APlace.FCityList.Text;

end;

//Setup mapping for Province
procedure TFGeoSetup.FillSetupProvince(PlaceChange: TPLaceChange = []);
var
  Preferred: string;
  Level: integer;
begin
  if (pcProvince in PlaceChange) then
    exit;

  CmbProvince.Items.BeginUpdate;
  try
    Preferred := '';
    if Assigned(APlace) then
      Preferred := GeoProvinceList.Values[APlace.CountryCode];
    CmbProvince.Items.Clear;
    case GeoSettings.GetPlaceProvider of
      TGeoCodeProvider.gpGeoName:
        begin
          CmbProvince.Items.Add(PlaceDefault);
          CmbProvince.Items.Add('county');
          CmbProvince.Items.Add('state');
          CmbProvince.Items.Add(PlaceAll);
          CmbProvince.Items.Add(PlaceNone);
        end;
      TGeoCodeProvider.gpOverPass:
        begin
          begin
            CmbProvince.Items.Add(PlaceDefault);
            if Assigned(APlace) then
            begin
              for Level in APlace.RegionLevels do
              begin
                if Level = 0 then
                  continue;
                CmbProvince.Items.Add(IntToStr(Level));
              end;
            end;
            CmbProvince.Items.Add(PlaceAll);
            CmbProvince.Items.Add(PlaceNone);
          end;
        end;
      TGeoCodeProvider.gpExifTool:
        begin
          CmbProvince.Items.Add(PlaceDefault);
          CmbProvince.Items.Add(PlaceNone);
        end;
    end;

    CmbProvince.ItemIndex := CmbProvince.Items.IndexOf(Preferred);
    if (CmbProvince.ItemIndex < 0) then
    begin
      if (Preferred = '')  or
         (pcProvider in PlaceChange) then
        CmbProvince.ItemIndex := 0
      else
        CmbProvince.Text := Preferred;
    end;

  finally
    CmbProvince.Items.EndUpdate;
  end;
end;

// Setup mapping for City
procedure TFGeoSetup.FillSetupCity(PlaceChange: TPLaceChange = []);
var
  Preferred: string;
  Level: integer;
begin
  if (pcCity in PlaceChange) then
    exit;

  CmbCity.Items.BeginUpdate;
  try
    Preferred := '';
    if Assigned(APlace) then
      Preferred := GeoCityList.Values[APlace.CountryCode];
    CmbCity.Items.Clear;
    case GeoSettings.GetPlaceProvider of
      TGeoCodeProvider.gpGeoName:
        begin
          CmbCity.Items.Add(PlaceDefault);
          CmbCity.Items.Add('hamlet');
          CmbCity.Items.Add('village');
          CmbCity.Items.Add('town');
          CmbCity.Items.Add('city');
          CmbCity.Items.Add('municipality');
          CmbCity.Items.Add(PlaceAll);
          CmbCity.Items.Add(PlaceNone);
        end;
    TGeoCodeProvider.gpOverPass:
      begin
        begin
          CmbCity.Items.Add(PlaceDefault);
          if Assigned(APlace) then
          begin
            for Level in APlace.CityLevels do
            begin
              if Level = 0 then
                continue;
              CmbCity.Items.Add(IntToStr(Level));
            end;
          end;
          CmbCity.Items.Add(PlaceAll);
          CmbCity.Items.Add(PlaceNone);
        end;
      end;
    TGeoCodeProvider.gpExifTool:
      begin
        CmbCity.Items.Add(PlaceDefault);
        CmbCity.Items.Add(PlaceNone);
      end;
    end;

    CmbCity.ItemIndex := CmbCity.Items.IndexOf(Preferred);
    if (CmbCity.ItemIndex < 0) then
    begin
      if (Preferred = '') or
         (pcProvider in PlaceChange) then
        CmbCity.ItemIndex := 0
      else
        CmbCity.Text := Preferred;
    end;

  finally
    CmbCity.Items.EndUpdate;
  end;
end;

procedure TFGeoSetup.FillSetup(PlaceChange: TPLaceChange = []);
begin
  // Setup Provider
  CmbGeoProvider.ItemIndex := Ord(GeoSettings.GetPlaceProvider);

  // Setup Language
  SetupLanguageCombo(Cmblang, GeoSettings.ReverseGeoCodeLang);

  // Setup mapping for Province
  FillSetupProvince(PlaceChange);

  // Setup mapping for City
  FillSetupCity(PlaceChange);
end;

procedure TFGeoSetup.GetPlace(PlaceChange: TPLaceChange = []);
begin
  if (pcProvider in PlaceChange) or
     (pcLang in PlaceChange) then
    ClearCoordCache;
  APlace := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);
end;

procedure TFGeoSetup.UpdateDesign(PlaceChange: TPLaceChange = []);
begin
  if (pcProvider in PlaceChange) then
  begin
    // Need the Provider and language to get the correct Place info
    GeoSettings.GetPlaceProvider := TGeoCodeProvider(CmbGeoProvider.ItemIndex);

    // Keep language if possible with new provider. (Eg. Overpass has local, Exiftool has not)
    SetupGeoCodeLanguage(Cmblang, GeoSettings.GetPlaceProvider, GetExifToolLanguage(Cmblang));
  end;

  // Get new language
  if (pcLang in PlaceChange) then
    GeoSettings.ReverseGeoCodeLang := GetExifToolLanguage(Cmblang);

  // Reload place if provider or language change
  GetPlace(PlaceChange);

  if Assigned(APlace) then
  begin
   if (pcProvider in PlaceChange) then
    begin
      // Remove Country defaults.(Province and City)
      GeoCityList.Values[APlace.CountryCode] := '';
      GeoProvinceList.Values[APlace.CountryCode] := '';
    end
    else
    begin
      if (pcProvince in PlaceChange) then
        GeoProvinceList.Values[APlace.CountryCode] := CmbProvince.Text;
      if (pcCity in PlaceChange) then
        GeoCityList.Values[APlace.CountryCode] := CmbCity.Text;;
    end;
  end;

  // Settings for Country defaults.(Province and City)
  FillSetup(PlaceChange);

  // Show preview
  FillPreview;
end;

procedure TFGeoSetup.CmbGeoProviderClick(Sender: TObject);
begin
  UpdateDesign([pcProvider, pcLang]);
end;

procedure TFGeoSetup.CmbLangChange(Sender: TObject);
begin
  UpdateDesign([pcLang]);
end;

procedure TFGeoSetup.CmbProvinceChange(Sender: TObject);
begin
  UpdateDesign([pcProvince]);
end;

procedure TFGeoSetup.CmbCityChange(Sender: TObject);
begin
  UpdateDesign([pcCity]);
end;

procedure TFGeoSetup.BtnCancelClick(Sender: TObject);
begin
  GeoSettings := SavedGeoSetting;
  GeoProvinceList.Assign(SavedProvinceList);
  GeoCityList.Assign(SavedCityList);
end;

procedure TFGeoSetup.BtnOKClick(Sender: TObject);
begin
  GeoSettings.CheckProvider(TGeoCheckMode.cmPlaceProvider);
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
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  StatusBar1.SimpleText := '';

  SavedGeoSetting := GeoSettings;
  SavedProvinceList.Assign(GeoProvinceList);
  SavedCityList.Assign(GeoCityList);

  SetupGeoCodeLanguage(Cmblang, GeoSettings.GetPlaceProvider, GeoSettings.ReverseGeoCodeLang);
  UpdateDesign;
end;

end.
