unit CheckCity1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask;

type
  TFrmCheckCity = class(TForm)
    Splitter1: TSplitter;
    Panel1: TPanel;
    Button1: TButton;
    ListView1: TListView;
    Button4: TButton;
    Button5: TButton;
    SaveDialog1: TSaveDialog;
    LblEdCountries: TLabeledEdit;
    LblEdRegions: TLabeledEdit;
    LblEdCities: TLabeledEdit;
    LblEdPLCodes: TLabeledEdit;
    LblEdlang: TLabeledEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCheckCity: TFrmCheckCity;

implementation

uses geomap, exiftool, exiftoolsgui_utils, Maindef, System.IniFiles, System.StrUtils;

{$R *.dfm}

const Sep = ',';

function SelMatches(const Needle: string; HayStack: TStrings; CompleteWord: boolean): boolean;
var
  SubStr: string;
begin
  result := (HayStack.Text = '*') or
            (Trim(HayStack.Text) = '');

  for Substr in HayStack do
  begin
    if (result) then
      break;
    if (CompleteWord) then
      result := SameText(Needle, Substr)
    else
      result := ContainsText(Needle, Substr);
  end;
end;

function ListFromEdit(AEdit: string): TStringList;
var
  Sub, All: string;
begin
  All := AEdit;
  result := TStringList.Create;
  while (All <> '') do
  begin
    Sub := NextField(All, ',');
    Result.Add(Trim(Sub));
  end;
end;

procedure TFrmCheckCity.Button1Click(Sender: TObject);
var
  EtOut,
  SCities, SCountries, SRegions, SPlCodes: TStringList;
  EtCmd, Aline: string;
  Indx, Loaded: integer;
  City, Region, SubRegion, CountryCode, Country, TimeZone, PlaceCode, Population, Lat, Lon: string;

begin
  EtOut := TStringList.Create;
  ListView1.Items.BeginUpdate;
  Listview1.Items.Clear;
  Loaded := 0;
  panel1.Caption := format('Read: %d, Loaded: %d', [0, Loaded]);
  SCities := ListFromEdit(LblEdCities.Text);
  SCountries := ListFromEdit(LblEdCountries.Text);
  SRegions := ListFromEdit(LblEdRegions.Text);
  SPlCodes := ListFromEdit(LblEdPLCodes.Text);

  try
    EtCmd := '-listgeo' + CRLF + '-sort';
    if (LblEdlang.Text <> '') then
      EtCmd := EtCmd + CRLF + '-lang' + CRLF + LblEdlang.Text;
    ET.OpenExec(EtCmd, '', EtOut);

    for Indx := 2 to EtOut.Count -1 do
    begin

      Aline := EtOut[Indx];

      City := NextField(Aline, ','); //City
      Region := NextField(Aline, ','); //region
      SubRegion := NextField(Aline, ','); //subregion
      CountryCode := NextField(Aline, ','); //CountryCode
      Country := NextField(Aline, ','); //Country
      TimeZone := NextField(Aline, ','); //TimeZone
      PlaceCode := NextField(Aline, ','); //TimeZone
      Population := NextField(Aline, ','); //Population
      Lat := NextField(Aline, ','); //Lat
      Lon := NextField(Aline, ','); //Lon

      if not (SelMatches(CountryCode, SCountries, true)) then
        continue;

      if not (SelMatches(Region, SRegions, false)) then
        continue;

      if not (SelMatches(PlaceCode, SPlCodes, true)) then
        continue;

      if not(SelMatches(City, SCities, false)) then
        continue;


      Inc(Loaded);

      panel1.Caption := format('Read: %d, Loaded: %d', [Indx, Loaded]);
      if ((indx mod 250) = 0) then
        Application.ProcessMessages;

      with Listview1.Items.Add do
      begin
        Caption := City;
        SubItems.Add(PlaceCode);
        SubItems.Add(Region);
        SubItems.Add(SubRegion);
        SubItems.Add(CountryCode);
        SubItems.Add(Lat + ', ' + Lon);
        SubItems.Add('-');
        SubItems.Add('-');
      end;

    end;

  finally
    SCities.Free;
    SCountries.Free;
    SRegions.Free;
    SPlCodes.Free;
    EtOut.Free;
    ListView1.Items.EndUpdate;
  end;
end;

procedure TFrmCheckCity.Button4Click(Sender: TObject);
var
  Anitem: TListItem;
  PLace: Tplace;
  CrWait, CrNormal: HCursor;
  Lat, Lon: string;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    for Anitem in ListView1.Items do
    begin
      if (Anitem.SubItems[5] = '-') and
         (Anitem.SubItems[6] = '-') then
      begin
        ParseLatLon(Anitem.SubItems[4], Lat, Lon);
        Place := GetPlaceOfCoords(Lat, Lon, TGeoCodeProvider.gpOverPass); // No Need to free. see finalization
        Anitem.Subitems[5] := place.GetCity;
        Anitem.Subitems[6] := place.GetProvince;
        Anitem.Checked := Anitem.Caption = Anitem.SubItems[5];
        Anitem.Update;

        Anitem.MakeVisible(false);
        Application.ProcessMessages;
      end;
    end;
  finally
    SetCursor(CrNormal);
  end;
end;

procedure TFrmCheckCity.Button5Click(Sender: TObject);
var
  F: TStreamWriter;
  Anitem: TListItem;
  Check: string;
  Indx: integer;
  SEP: string;
begin
  SEP := ';';
  if (SaveDialog1.Execute) then
  begin
    F := TStreamWriter.Create(SaveDialog1.FileName, false, TEncoding.Unicode);
    try
      F.WriteLine('SEP=;');
      F.Write('Check');
      for Indx := 0 to ListView1.Columns.Count -1 do
      begin
        F.Write(SEP);
        F.Write(ListView1.Columns[Indx].Caption);
      end;
      F.Write(#10);
      for Anitem in Listview1.Items do
      begin
        if (Anitem.Checked) then
          Check := 'OK'
        else
          Check := 'NOT OK';
        begin
          F.Write(Check);
          F.Write(SEP);
          F.Write(#34 + Anitem.Caption + #34);
          for Indx := 0 to Anitem.SubItems.Count -1 do
          begin
            F.Write(SEP);
            F.Write(#34 + Anitem.SubItems[Indx] + #34);
          end;
          F.Write(#10);
        end;
      end;
    finally
      F.Free
    end;
  end;
end;

procedure TFrmCheckCity.FormCreate(Sender: TObject);
var
  GUIini: TMemIniFile;
begin
  ET.StayOpen(GetTempDirectory);

  GUIini := TMemIniFile.Create(GetIniFilePath(True), TEncoding.UTF8);
  geomap.ReadGeoCodeSettings(GUIini);
  GeoSettings.GetCoordProvider := TGeoCodeProvider.gpOverPass;
  GeoSettings.GeoCodingEnable := TGeoCodeEnable.geAll;
end;

procedure TFrmCheckCity.FormDestroy(Sender: TObject);
begin
  ET.OpenExit(true);
end;

end.
