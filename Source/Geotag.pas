unit Geotag;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Mask;

type
  TFGeotag = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    LabeledEdit1: TLabeledEdit;
    Button3: TButton;
    CheckBox1: TCheckBox;
    RadioGroup1: TRadioGroup;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    TrackBar1: TTrackBar;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ChkUpdateLocation: TCheckBox;
    BtnSetupGeoCode: TButton;
    EdMargin: TLabeledEdit;
    UdMargin: TUpDown;
    BtnOnMap: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BtnSetupGeoCodeClick(Sender: TObject);
    procedure BtnOnMapClick(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    function LogPath: string;
  public
    { Public declarations }
  end;

var
  FGeotag: TFGeotag;

implementation

uses Main, MainDef, ExifTool, ExifToolsGUI_Utils, UFrmGeoSetup, Geomap, UnitLangResources;

{$R *.dfm}

function TFGeotag.LogPath: string;
begin
  if CheckBox1.Checked then
    result := ExtractFileDir(LabeledEdit1.Text) + '*' + ExtractFileExt(LabeledEdit1.Text)
  else
    result := LabeledEdit1.Text;
end;

procedure TFGeotag.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  with TrackBar1 do
  begin
    Enabled := not Enabled;
    Enabled := CheckBox2.Checked;
  end;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  with FMain.OpenPictureDlg do
  begin
    if GpsXmpDir <> '' then
      InitialDir := GpsXmpDir
    else
      InitialDir := FMain.ShellList.Path;
    Filter := StrAnyGPSLogFile + '|*.*';
    Options := [ofFileMustExist];
    Title := StrSelectGPSLogFile;
    FileName := '';
  end;
  Button2.Enabled := false;
  BtnOnMap.Enabled := false;
  LabeledEdit1.Clear;
  Application.OnHint := DisplayHint;
end;

procedure TFGeotag.TrackBar1Change(Sender: TObject);
var
  I: integer;
  Tx: string[7];
begin
  I := TrackBar1.Position;
  if I >= 0 then
    Tx := '+'
  else
  begin
    Tx := '-';
    I := I * -1;
  end;
  if I < 10 then
    Tx := Tx + '0' + IntToStr(I)
  else
    Tx := Tx + IntToStr(I);
  Edit1.Text := Tx;
end;

procedure TFGeotag.BtnOnMapClick(Sender: TObject);
var
  LastCoord: string;
begin
  if (CreateTrkPoints(LogPath, true, LastCoord) > 0) then
  begin
    Fmain.AdvPageMetadata.ActivePage := FMain.AdvTabOSMMap;
    MapGotoPlace(FMain.EdgeBrowser1, LastCoord, '', '', InitialZoom_Out);
  end;
end;

procedure TFGeotag.BtnSetupGeoCodeClick(Sender: TObject);
begin
  ParseLatLon(Fmain.EditMapFind.Text, FGeoSetup.Lat, FGeoSetup.Lon);
  if not (ValidLatLon(FGeoSetup.Lat, FGeoSetup.Lon)) then
  begin
    MessageDlgEx(StrNoValidLatLon + #10 + StrUseTheOSMMap, '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
    exit;
  end;
  FGeoSetup.ShowModal;
end;

procedure TFGeotag.Button2Click(Sender: TObject);
var
  SavedVerbose: integer;
  ETcmd, ETout, ETerr: string;
  AFile: string;
  SelectedFiles: TStringList;
begin
  SavedVerbose := ET_Options.GetVerbose;
  try
    ETcmd := '-geotag' + CRLF + LogPath + CRLF;
    ETcmd := ETcmd + '-geotime<';
    if CheckBox2.Checked then
    begin
      if RadioGroup1.ItemIndex = 0 then
        ETcmd := ETcmd + '${DateTimeOriginal}'
      else
        ETcmd := ETcmd + '${CreateDate}';
      ETcmd := ETcmd + Edit1.Text + ':00';
    end
    else
    begin
      if RadioGroup1.ItemIndex = 0 then
        ETcmd := ETcmd + 'DateTimeOriginal'
      else
        ETcmd := ETcmd + 'CreateDate"';
    end;

    if (ChkUpdateLocation.Checked) and
       (GeoSettings.GetPlaceProvider = TGeoCodeProvider.gpExifTool) then
      ETcmd := ETcmd + CRLF + '-XMP-photoshop:XMP-iptcCore:XMP-iptcExt:geolocate=geotag';

    ETcmd := ETcmd + CRLF + '-API' + CRLF + Format('GeoMaxExtSecs=%s', [EdMargin.Text]);

    ET_Options.SetVerbose(2);
    ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);

    if (ChkUpdateLocation.Checked) and
       (GeoSettings.GetPlaceProvider <> TGeoCodeProvider.gpExifTool) then
    begin
      SelectedFiles := TStringList.Create;
      try
        SelectedFiles.Text := FMain.GetSelectedFiles(true); // Need complete path
        for AFile in SelectedFiles do
          FillLocationInImage(AFile);
      finally
        SelectedFiles.Free;
      end;
    end;
  finally
    ET_Options.SetVerbose(SavedVerbose);
    ModalResult := mrOK;
  end;
end;

procedure TFGeotag.Button3Click(Sender: TObject);
begin
  if FMain.OpenPictureDlg.Execute then
  begin
    LabeledEdit1.Text := FMain.OpenPictureDlg.FileName;
    GpsXmpDir := ExtractFileDir(FMain.OpenPictureDlg.FileName);
    GpsXmpDir := IncludeTrailingPathDelimiter(GpsXmpDir);
    Button2.Enabled := true;
    BtnOnMap.Enabled := GUIsettings.EnableGMap;
  end;
end;

procedure TFGeotag.CheckBox2Click(Sender: TObject);
begin
  TrackBar1.Enabled := CheckBox2.Checked;
end;

procedure TFGeotag.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

end.
