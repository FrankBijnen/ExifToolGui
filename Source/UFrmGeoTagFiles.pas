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
    ValLocation.Strings.AddPair('CountryCode', APlace.CountryCode);
    ValLocation.Strings.AddPair('CountryName', APlace.CountryName);
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
  CmdLat, CmdLon: string;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    // Get data possibly modified by user
    CmdLat := Trim(ValLocation.Values['Lat']);
    CmdLon := Trim(ValLocation.Values['Lon']);

    ETcmd := '';
    case (TGeoTagMode(CmbGeoTagMode.ItemIndex)) of
      TGeoTagMode.gtmCoordinates,
      TGeoTagMode.gtmCoordinatesLocation:
      begin
        if (ChkRemoveExisting.Checked) then
          ETcmd := ETcmd + '-a' + CRLF + '-Gps*=' + CRLF + '--GPSversion*';
        if (CmdLat <> '') then
        begin
//          ETcmd := ETcmd + CRLF + '-GPS:GpsLatitudeRef=';
          ETcmd := ETcmd + CRLF + '-GpsLatitudeRef=';
          if CmdLat[1] = '-' then
          begin
            ETcmd := ETcmd + 'S';
            Delete(CmdLat, 1, 1);
          end
          else
            ETcmd := ETcmd + 'N';
//          ETcmd := ETcmd + CRLF + '-GPS:GpsLatitude=' + CmdLat;
          ETcmd := ETcmd + CRLF + '-GpsLatitude=' + CmdLat;
        end;
        if (CmdLon <> '') then
        begin
//          ETcmd := ETcmd + CRLF + '-GPS:GpsLongitudeRef=';
          ETcmd := ETcmd + CRLF + '-GpsLongitudeRef=';
          if CmdLon[1] = '-' then
          begin
            ETcmd := ETcmd + 'W';
            Delete(CmdLon, 1, 1);
          end
          else
            ETcmd := ETcmd + 'E';
//          ETcmd := ETcmd + CRLF + '-GPS:GpsLongitude=' + CmdLon;
          ETcmd := ETcmd + CRLF + '-GpsLongitude=' + CmdLon;
        end;

        // Get data possibly modified by user. With minus sign for West and South!
        CmdLat := Trim(ValLocation.Values['Lat']);
        CmdLon := Trim(ValLocation.Values['Lon']);

        AdjustLatLon(CmdLat, CmdLon, 5);
        ETCmd := ETcmd + CRLF + Format('-QuickTime:GPSCoordinates=''%s, %s, %s''', [CmdLat, CmdLon, '0']);
      end;
    end;

    case (TGeoTagMode(CmbGeoTagMode.ItemIndex)) of
      TGeoTagMode.gtmLocation,
      TGeoTagMode.gtmCoordinatesLocation:
      begin
// Compatibility with exiftool -geolocation
        Etcmd := Etcmd + CRLF + '-xmp:CountryCode=' + ValLocation.Values['CountryCode'];
        Etcmd := Etcmd + CRLF + '-xmp:Country=' + ValLocation.Values['CountryName'];
        Etcmd := Etcmd + CRLF + '-xmp:State=' + ValLocation.Values['Province'];
        Etcmd := Etcmd + CRLF + '-xmp:City=' + ValLocation.Values['City'];
//
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownCountryCode=' + ValLocation.Values['CountryCode'];
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownCountryName=' + ValLocation.Values['CountryName'];
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownProvinceState=' + ValLocation.Values['Province'];
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownCity=' + ValLocation.Values['City'];
        Etcmd := Etcmd + CRLF + '-xmp:LocationShownSublocation=' + ValLocation.Values['Location'];
      end;
    end;
    ET_OpenExec(ETcmd, Fmain.GetSelectedFiles, ETouts, ETerrs);

    StatusBar1.SimpleText := StrAllDone;
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
  LblSample.Caption := Format(StrSampleS, [IsQuickTimeStr[IsQuickTime] + ExtractFileName(Fmain.GetFirstSelectedFile)]);
  FillPreview;
end;

end.
