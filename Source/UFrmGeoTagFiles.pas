unit UFrmGeoTagFiles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.ValEdit,
  Geomap;

type
  TFGeotagFiles = class(TScaleForm)
    StatusBar1: TStatusBar;
    BtnCancel: TButton;
    BtnExecute: TButton;
    PctMain: TPageControl;
    TabGeoTagData: TTabSheet;
    AdvPanel1: TPanel;
    LblSample: TLabel;
    ValLocation: TValueListEditor;
    BtnSetupGeoCode: TButton;
    CmbGeoTagMode: TComboBox;
    Label1: TLabel;
    ChkRemoveExisting: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnSetupGeoCodeClick(Sender: TObject);
    procedure CmbGeoTagModeClick(Sender: TObject);
  private
    { Private declarations }
    var
      APlace: TPlace; // No need to free, handled in CoordCache.
      ETcmd, ETouts, ETerrs: string;
  public
    { Public declarations }
    var
      Lat, Lon: string;
      IsQuickTime: boolean;
    procedure FillPreview;
    procedure Execute;
  end;

var
  FGeotagFiles: TFGeotagFiles;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils, UFrmGeoSetup, UnitLangResources;

{$R *.dfm}

procedure TFGeotagFiles.BtnSetupGeoCodeClick(Sender: TObject);
begin
  FGeoSetup.Lat := Lat;
  FGeoSetup.Lon := Lon;
  FGeoSetup.ShowModal;
  FillPreview;
end;

procedure TFGeotagFiles.CmbGeoTagModeClick(Sender: TObject);
begin
  GeoSettings.GeoTagMode := TGeoTagMode(CmbGeoTagMode.ItemIndex);
end;

procedure TFGeotagFiles.FillPreview;
begin
  ValLocation.Strings.BeginUpdate;
  try
    ValLocation.Strings.Clear;
    ValLocation.Strings.AddPair('Lat', Lat);
    ValLocation.Strings.AddPair('Lon', Lon);

    // Get Place of selected coordinates
    ClearCoordCache; // Make sure we dont get cached data.
    APlace := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);
    if not Assigned(APlace) then
      exit;
    ValLocation.Strings.AddPair('Country', APlace.CountryLocation);
    ValLocation.Strings.AddPair('Province', APlace.Province);
    ValLocation.Strings.AddPair('City', APlace.City);
    ValLocation.Strings.AddPair('Location', '');
  finally
    ValLocation.Strings.EndUpdate;
  end;
end;

procedure TFGeotagFiles.Execute;
var
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    // Get data possibly modified by user
    Lat := ValLocation.Values['Lat'];
    Lon := ValLocation.Values['Lon'];

    ETcmd := '';
    case (TGeoTagMode(CmbGeoTagMode.ItemIndex)) of
      TGeoTagMode.gtmCoordinates,
      TGeoTagMode.gtmCoordinatesLocation:
      begin
        ETcmd := '';
        if (ChkRemoveExisting.Checked) then
          ETcmd := ETcmd + '-a' + CRLF + '-Gps*=' + CRLF + '--GPSversion*';
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
        AdjustLatLon(Lat, Lon, 5);
        ETCmd := ETcmd + CRLF + Format('-QuickTime:GPSCoordinates=''%s, %s, %s''', [Lat, Lon, '0']);
      end;
    end;

    case (TGeoTagMode(CmbGeoTagMode.ItemIndex)) of
      TGeoTagMode.gtmLocation,
      TGeoTagMode.gtmCoordinatesLocation:
      begin
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownCountryName=' + ValLocation.Values['Country'];
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownProvinceState=' + ValLocation.Values['Province'];
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownCity=' + ValLocation.Values['City'];
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownSublocation=' + ValLocation.Values['Location'];
      end;
    end;
    ET_OpenExec(ETcmd, Fmain.GetSelectedFiles, ETouts, ETerrs);

    StatusBar1.SimpleText := 'All Done';
  finally
    SetCursor(CrNormal);
  end;
end;

procedure TFGeotagFiles.BtnExecuteClick(Sender: TObject);
begin
  Execute;

  if (ETerrs = '') then
    ModalResult := mrOK;
end;

procedure TFGeotagFiles.FormCreate(Sender: TObject);
begin
  ChkRemoveExisting.Checked := true;
  CmbGeoTagMode.ItemIndex := Ord(GeoSettings.GeoTagMode);
end;

procedure TFGeotagFiles.FormShow(Sender: TObject);
const
  IsQuickTimeStr: array[False..True] of string = ('','QuickTime ');
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  StatusBar1.SimpleText := '';
  IsQuickTime := GetIsQuickTime(Fmain.GetFirstSelectedFile);
  LblSample.Caption := Format(StrSampleS, [IsQuickTimeStr[IsQuickTime], ExtractFileName(Fmain.GetFirstSelectedFile)]);
  FillPreview;
end;

end.
