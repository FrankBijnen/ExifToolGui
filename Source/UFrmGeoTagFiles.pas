unit UFrmGeoTagFiles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.ValEdit,
  Geomap;

type
  TFGeotagFiles = class(TForm)
    StatusBar1: TStatusBar;
    BtnCancel: TButton;
    BtnExecute: TButton;
    PctMain: TPageControl;
    TabExecute: TTabSheet;
    AdvPanel1: TPanel;
    Label1: TLabel;
    LblSample: TLabel;
    ValLocation: TValueListEditor;
    ChkUpdateLocationInfo: TCheckBox;
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
    ChkUpdateLatLon: TCheckBox;
    ChkCountryLocation: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CmbProvinceChange(Sender: TObject);
    procedure CmbGeoProviderClick(Sender: TObject);
    procedure CmbCityChange(Sender: TObject);
    procedure ChkCountryLocationClick(Sender: TObject);
  private
    { Private declarations }
    var
      APlace: TPlace; // No need to free, handled in CoordCache.
      ETcmd, ETouts, ETerrs: string;
    procedure FillSetup;
    procedure FillPreview;
  public
    { Public declarations }
    var
      Lat, Lon: string;
      SetupMode: boolean;
  end;

var
  FGeotagFiles: TFGeotagFiles;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils;

{$R *.dfm}

procedure TFGeotagFiles.FillSetup;
var Preferred: string;
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
        end;
    TGeoCodeProvider.gpOverPass:
      begin
        begin
          CmbProvince.Items.Add('Default');
          CmbProvince.Items.Add('6');
          CmbProvince.Items.Add('5');
          CmbProvince.Items.Add('4');
          CmbProvince.Items.Add('3');
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
        end;
    TGeoCodeProvider.gpOverPass:
      begin
        begin
          CmbCity.Items.Add('Default');
          CmbCity.Items.Add('8');
          CmbCity.Items.Add('7');
          CmbCity.Items.Add('9');
          CmbCity.Items.Add('10');
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

procedure TFGeotagFiles.ChkCountryLocationClick(Sender: TObject);
begin
  GeoSettings.CountryCodeLocation := ChkCountryLocation.Checked;
  FillPreview;
end;

procedure TFGeotagFiles.CmbCityChange(Sender: TObject);
begin
  GeoCityList.Values[APlace.CountryCode] := CmbCity.Text;
  FillPreview;
end;

procedure TFGeotagFiles.CmbGeoProviderClick(Sender: TObject);
begin
  GeoSettings.GetPlaceProvider := TGeoCodeProvider(CmbGeoProvider.ItemIndex);
  FillSetup;
  GeoCityList.Values[APlace.CountryCode] := CmbCity.Text;
  GeoProvinceList.Values[APlace.CountryCode] := CmbProvince.Text;
  FillPreview;
end;

procedure TFGeotagFiles.CmbProvinceChange(Sender: TObject);
begin
  GeoProvinceList.Values[APlace.CountryCode] := CmbProvince.Text;
  FillPreview;
end;

procedure TFGeotagFiles.FillPreview;
begin
  if (not Showing) then
    exit;
  GeoSettings.GetPlaceProvider := TGeoCodeProvider(CmbGeoProvider.ItemIndex);

  ValLocation.Strings.BeginUpdate;
  try
    ValLocation.Strings.Clear;
    ValLocation.Strings.AddPair('Lat', Lat);
    ValLocation.Strings.AddPair('Lon', Lon);

    // Get Place of selected coordinates
    ClearCoordCache; // Make sure we dont get cached data.
    APlace := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);

    LblCountrySettings.Caption := 'Settings for: ' + APlace.CountryLocation;
    ValLocation.Strings.AddPair('Country', APlace.CountryLocation);
    ValLocation.Strings.AddPair('Province', APlace.Province);

    if (APlace.PrioProvince <> '') then
      LblProvince.Caption := APlace.PrioProvince
    else
      LblProvince.Caption := 'Fallback: ' + APlace.Province;
    LblProvince.Caption := LblProvince.Caption + #10 +
                          'Available data:' + #10 +
                           APlace.FProvinceList.Text;

    ValLocation.Strings.AddPair('City', APlace.City);

    if (APlace.PrioCity <> '') then
      LblCity.Caption := APlace.PrioCity
    else
      LblCity.Caption := 'Fallback: ' + APlace.City;
    LblCity.Caption := LblCity.Caption +  #10 +
                      'Available data:' + #10+
                       APlace.FCityList.Text;

    ValLocation.Strings.AddPair('Location', '');
  finally
    ValLocation.Strings.EndUpdate;
  end;
end;

procedure TFGeotagFiles.BtnExecuteClick(Sender: TObject);
var
  CrWait, CrNormal: HCURSOR;
begin
  if (SetupMode) then
  begin
    ModalResult := MROK;
    exit;
  end;
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    // Get data possibly modified by user
    Lat := ValLocation.Values['Lat'];
    Lon := ValLocation.Values['Lon'];

    ETcmd := '';
    if (ChkUpdateLatLon.Checked) then
    begin
      ETcmd := '-GPS:All=';
      if (Lat <> '') then
      begin
        ETcmd := ETcmd + CRLF + '-GPS:GpsLatitudeRef=';
        if Lat[1] = '-' then
        begin
          ETcmd := ETcmd + 'S';
          Delete(Lat, 1, 1);
        end
        else
          ETcmd := ETcmd + 'N';
        ETcmd := ETcmd + CRLF + '-GPS:GpsLatitude=' + Lat;
      end;
      if (Lon <> '') then
      begin
        ETcmd := ETcmd + CRLF + '-GPS:GpsLongitudeRef=';
        if Lon[1] = '-' then
        begin
          ETcmd := ETcmd + 'W';
          Delete(Lon, 1, 1);
        end
        else
          ETcmd := ETcmd + 'E';
        ETcmd := ETcmd + CRLF + '-GPS:GpsLongitude=' + Lon;
      end;
    end;

    if (ChkUpdateLocationInfo.Checked) then
    begin
      Etcmd := Etcmd + CRLF + '-xmp:LocationShownCountryName=' + ValLocation.Values['Country'];
      Etcmd := Etcmd + CRLF + '-xmp:LocationShownProvinceState=' + ValLocation.Values['Province'];
      Etcmd := Etcmd + CRLF + '-xmp:LocationShownCity=' + ValLocation.Values['City'];
      Etcmd := Etcmd + CRLF + '-xmp:LocationShownSublocation=' + ValLocation.Values['Location'];
    end;
    ET_OpenExec(ETcmd, Fmain.GetSelectedFiles, ETouts, ETerrs);

    StatusBar1.SimpleText := 'All Done';
  finally
    SetCursor(CrNormal);
  end;

  if (ETerrs = '') then
    ModalResult := mrOK;
end;

procedure TFGeotagFiles.FormCreate(Sender: TObject);
begin
  ChkUpdateLatLon.Checked := true;
  ChkUpdateLocationInfo.Checked := true;
  CmbGeoProvider.ItemIndex := Ord(GeoSettings.GetPlaceProvider);
  ChkCountryLocation.Checked := GeoSettings.CountryCodeLocation;
end;

procedure TFGeotagFiles.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  StatusBar1.SimpleText := '';
  LblSample.Caption := Format('Sample: %s', [ExtractFileName(Fmain.GetFirstSelectedFile)]);
  PctMain.ActivePage := TabExecute;

  if (SetupMode) then
    BtnExecute.Caption := 'Ok'
  else
    BtnExecute.Caption := 'Execute';
  ChkUpdateLatLon.Visible := not SetupMode;
  ChkUpdateLocationInfo.Visible := not SetupMode;

  FillPreview;
  FillSetup; // Need CountryCode for setup
end;

end.
