unit Geomap;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.IniFiles,
  Vcl.Edge,
  ExifToolsGUI_StringList;

const
  PlaceDefault = 'Default';
  PlaceAll     = '*';
  PlaceLocal   = 'Local - Local';
  PlaceNone    = 'None';

type
  TExecRestEvent = procedure(Url, Response: string; Succes: boolean) of object;
  TGeoCodeEnable = (geNone, geAll, geOffline);
  TGeoCodeProvider = (gpGeoName, gpOverPass, gpExifTool);
  TGeoTagMode = (gtmCoordinates, gtmLocation, gtmCoordinatesLocation);

  GEOsettingsRec = record
    GeoCodingEnable: TGeoCodeEnable;
    GetCoordProvider: TGeoCodeProvider;
    GetPlaceProvider: TGeoCodeProvider;
    GeoCodeUrl: string;
    GeoCodeApiKey: string;
    ThrottleGeoCode: integer;
    OverPassUrl: string;
    CaseSensitive: boolean;
    OverPassCompleteWord: boolean;
    GeoCodeLang: string;
    ReverseGeoCodeLang: string;
    ThrottleOverPass: integer;
    CountryCodeLocation: boolean;
    GeoTagMode: TGeoTagMode;
    GeoCodeDialog: boolean;
    ReverseGeoCodeDialog: boolean;
    procedure CheckProvider;
  end;

  TRegionLevels = array[0..3] of integer;
  TCityLevels = array[0..4] of integer;

  TPlace = class
    FCityLevels: TCityLevels;
    FRegionLevels: TRegionLevels;
    FCityList : TNrSortedStringList;
    FProvinceList : TNrSortedStringList;
    FCountryCode: string;
    FDefLang: string;
    FCountryName: string;
    FName: string;
    FNodeId: string;
    FPostCode: string;
    function HtmlEscape(const HTML: string): string;
    function GetCountryLocation: string;
    function GetPrio(const APrio: string; APrioList: TStringList): string;
    function GetPrioProvince: string;
    function GetProvince: string;
    function GetPrioCity: string;
    function GetCity: string;
    function GetSearchResult: string;
    function GetHtmlSearchResult: string;
    function GetRegionLevels: TRegionLevels;
    function GetCityLevels: TCityLevels;
    procedure SetCountryCode(Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AssignFromGeocode(Key, Value: string);
    procedure AssignFromOverPass(Key: integer; Value: string);
    procedure AssignFromExifTool(Key, Value: string);
    procedure Sort;
    property CountryCode: string read FCountryCode write SetCountryCode;
    property CountryName: string read FCountryName;
    property CountryLocation: string read GetCountryLocation;
    property DefLang: string read FDefLang write FDefLang;
    property PostCode: string read FPostCode write FPostCode;
    property Name: string read FName write FName;
    property Province: string read GetProvince;
    property City: string read GetCity;
    property SearchReault: string read GetSearchResult;
    property HtmlSearchResult: string read GetHtmlSearchResult;
    property RegionLevels: TRegionLevels read FRegionLevels;
    property CityLevels: TCityLevels read FCityLevels;

    class function UnEscape(Value: string): string;
  end;

procedure OsmMapInit(Browser: TEdgeBrowser;
                     const Lat, Lon, Desc, InitialZoom: string);
procedure ShowImagesOnMap(Browser: TEdgeBrowser; Apath, ETOuts: string);
procedure MapGetLocation(Browser: TEdgeBrowser);
function MapGoToPlace(Browser: TEdgeBrowser; Place, Bounds, Desc, InitialZoom: string): string;
procedure ParseJsonMessage(const Message: string; var Msg, Parm1, Parm2: string);
function GetCountryList: TStringList;
function ValidLatLon(const Lat, Lon: string): boolean;
procedure ParseLatLon(const LatLon: string; var Lat, Lon: string);
procedure AdjustLatLon(var Lat, Lon: string; No_Decimals: integer);
function GetPlaceOfCoords(const Lat, Lon: string; const Provider: TGeoCodeProvider): TPlace;
procedure ClearCoordCache;
procedure GetCoordsOfPlace(const Place, Bounds: string; var Lat, Lon: string);
procedure ReadGeoCodeSettings(GUIini: TMemIniFile);
procedure WriteGeoCodeSettings(GUIini: TMemIniFile);

const
  Coord_Decimals = 6;
  Place_Decimals = 4;
  CRLF = #13#10;
  OSMHome = 'Home';
  OSMCtrlClick = 'Ctrl Click';
  OSMGetLocation = 'Get Location';
  OSMGetBounds = 'Get Bounds';
  Geo_Settings = 'GeoSettings';
  Geo_City = 'GeoCity';
  Geo_Province = 'GeoProvince';
  InitialZoom_Out = '16';
  InitialZoom_In = '20';

type

  TOSMHelper = class(TObject)
  private
    Scaled: integer;
    OsmFormatSettings: TFormatSettings;
    Html: TStringList;
    FInitialZoom: string;
    FPathName: string;
    PlacesDict: TObjectDictionary<String, TStringList>;
    function GetHyperLink(const HRef: string = ''): string;
    procedure WriteHeader;
    procedure WritePointsStart;
    procedure WritePoint(const ALat, ALon, AImg: string; Link: boolean);
    procedure WritePointsEnd(const GetPlace: boolean);
    procedure WriteTrackPoints;
    procedure WriteFooter;
  public
    constructor Create(const APathName, AInitialZoom: string);
    destructor Destroy; override;
  end;

var
  GeoSettings: GEOsettingsRec;
  GeoProvinceList: TStringList;
  GeoCityList: TStringList;
  ExecRestEvent: TExecRestEvent;

type
  TCountryRegionLevels = record
    Country: string[2];
    Levels: TRegionLevels;
  end;

  TCountryCityLevels = record
    Country: string[2];
    Levels: TCityLevels;
  end;

const
  ConstRegionLevels: array[0..7] of TCountryRegionLevels =
  (
    (Country: 'NL'; Levels:(4, 6, 5, 3)),
    (Country: 'DE'; Levels:(4, 6, 5, 3)),
    (Country: 'PL'; Levels:(4, 6, 5, 3)),
    (Country: 'CA'; Levels:(4, 6, 5, 3)),
    (Country: 'US'; Levels:(4, 6, 5, 3)),
    (Country: 'EC'; Levels:(4, 6, 5, 3)),
    (Country: 'ZA'; Levels:(4, 6, 5, 3)),
    (Country: '';   Levels:(6, 5, 4, 3))
  );

  ConstCityLevels: array[0..12] of TCountryCityLevels =
  (
    (Country: 'NL'; Levels:(10, 8, 9, 7, 0)),
    (Country: 'DE'; Levels:( 8, 7, 6, 9,10)),
    (Country: 'BE'; Levels:( 9, 8, 7,10, 0)),
    (Country: 'FI'; Levels:( 9, 8, 7,10, 0)),
    (Country: 'PT'; Levels:( 9, 8, 7,10, 0)),
    (Country: 'SI'; Levels:(10, 8, 7, 9, 0)),
    (Country: 'SE'; Levels:( 9, 7, 8,10, 0)),
    (Country: 'EC'; Levels:( 6, 7, 8, 9,10)),
    (Country: 'ZA'; Levels:( 6, 7, 8, 9,10)),
    (Country: 'SK'; Levels:( 6, 9, 8, 7,10)),
    (Country: 'GR'; Levels:( 7, 8, 9,10, 0)),
    (Country: 'GB'; Levels:(10, 8, 7, 9, 0)),
    (Country: '';   Levels:( 8, 7, 9,10, 0))
  );

implementation

uses
  System.Variants, System.JSON,  System.NetEncoding, System.Math, System.StrUtils, System.DateUtils,
  Winapi.Windows, Vcl.Dialogs,
  REST.Types, REST.Client, REST.Utils,
  UFrmPlaces, UFrmGeoSearch, ExifToolsGUI_Utils, ExifToolsGui_Data, UnitLangResources;

var
  CoordFormatSettings: TFormatSettings; // for StrToFloatDef -see Initialization
  LastQuery: TDateTime;
  CoordCache: TObjectDictionary<string, TPlace>;
  CountryList: TStringList;

procedure GEOsettingsRec.CheckProvider;
begin

  if (GeoSettings.GeoCodingEnable = TGeoCodeEnable.geAll) and
      ((GeoSettings.GeoCodeApiKey = '') or
       (GeoSettings.ThrottleGeoCode < 1000)) then
    ShowMessage(StrCheckTheGeoCodeRe);

  if (GeoSettings.GeoCodingEnable = TGeoCodeEnable.geOffline) then
  begin
    if (GeoSettings.GetPlaceProvider <> TGeoCodeProvider.gpExifTool) or
       (GeoSettings.GetCoordProvider <> TGeoCodeProvider.gpExifTool) then
    begin
      GeoSettings.GetPlaceProvider := TGeoCodeProvider.gpExifTool;
      GeoSettings.GetCoordProvider := TGeoCodeProvider.gpExifTool;
      ShowMessage(StrCheckOffLineProv);
    end;
  end;
end;

constructor TPlace.Create;
begin
  inherited Create; // Does nothing
  FCityList := TNrSortedStringList.Create;
  FCityList.Duplicates := TDuplicates.dupIgnore;
  FProvinceList := TNrSortedStringList.Create;
  FProvinceList.Duplicates := TDuplicates.dupIgnore;
end;

destructor TPlace.Destroy;
begin
  Clear;
  FCityList.Free;
  FProvinceList.Free;
  inherited;
end;

procedure TPlace.Clear;
begin
  SetLength(FCountryCode, 0);
  SetLength(FDefLang, 0);
  SetLength(FCountryName, 0);
  SetLength(FNodeId, 0);
  SetLength(FName, 0);
  SetLength(FPostCode, 0);
  FCityList.Clear;
  FProvinceList.Clear;
end;

class function TPlace.UnEscape(Value: string): string;
begin
  result := Value;
  if (LeftStr(Value, 1) = '"') and
     (RightStr(Value, 1) = '"') then
    result := Copy(result, 2, Length(result) -2);
  result := StringReplace(result, '\/', '/', [rfReplaceAll]); // Belgium
end;

function TPlace.GetCountryLocation: string;
begin
  if (GeoSettings.CountryCodeLocation) then
    result := FCountryCode
  else
    result := FCountryName;
end;

function TPlace.GetPrio(const APrio: string; APrioList: TStringList): string;
var
  Prio: string;
  APrioField, APrioValue: string;
  Indx: integer;

  procedure Add2Result;
  begin
    if (APrioValue <> '') then
    begin
      if (result <> '') then
        result :=  result + ', ';
      result := result + APrioValue;
    end;
  end;

begin
  result := '';
  Prio := APrio;
  if (Prio = '') then
    exit;

  result := APrioList.Values[Prio];
  if (result <> '') then
    exit;

  if (Prio = PlaceAll) then
  begin
    for Indx := 0 to APrioList.Count -1 do
    begin
      APrioValue := Trim(APrioList.ValueFromIndex[Indx]);
      Add2Result;
    end;
    exit;
  end;

  while (Prio <> '') do
  begin
    APrioField := Trim(NextField(Prio, ','));
    APrioValue := Trim(APrioList.Values[APrioField]);
    Add2Result;
  end;
end;

function TPlace.GetPrioProvince: string;
begin
  result := GetPrio(GeoProvinceList.Values[FCountryCode], FProvinceList);
end;

function TPlace.GetProvince: string;
var
  Level: integer;
  LevelX: string;
begin
  if (GeoProvinceList.Values[FCountryCode] = PlaceNone) then
    exit('');

  result := GetPrioProvince;

  // ExifTool
  if (result = '') and (FProvinceList.Values['GeolocationRegion'] <> '') then
    result := FProvinceList.Values['GeolocationRegion'];

  // Geocode
  if (result = '') and (FProvinceList.Values['county'] <> '') then
    result := FProvinceList.Values['county'];
  if (result = '') and (FProvinceList.Values['state'] <> '') then
    result := FProvinceList.Values['state'];

  // Overpass
  if (result = '') then
  begin
    for Level in RegionLevels do
    begin
      if (Level = 0) then
        break;
      LevelX := IntToStr(Level);
      if (FProvinceList.Values[LevelX] <> '') then
      begin
        result := FProvinceList.Values[LevelX];
        break;
      end;
    end;
  end;
end;

function TPlace.GetPrioCity: string;
begin
  result := GetPrio(GeoCityList.Values[FCountryCode], FCityList);
end;

function TPlace.GetCity: string;
var
  Level: integer;
  LevelX: string;
begin
  if (GeoCityList.Values[FCountryCode] = PlaceNone) then
    exit('');

  result := GetPrioCity;

  // ExifTool
  if (result = '') and (FCityList.Values['GeolocationCity'] <> '') then
    result := FCityList.Values['GeolocationCity'];

  // Geocode
  // Note: hamlet not added to default. Can be specified.
  if (result = '') and (FCityList.Values['village'] <> '') then
    result := FCityList.Values['village'];
  if (result = '') and (FCityList.Values['town'] <> '') then
    result := FCityList.Values['town'];
  if (result = '') and (FCityList.Values['city'] <> '') then
    result := FCityList.Values['city'];
  if (result = '') and (FCityList.Values['municipality'] <> '') then
    result := FCityList.Values['municipality'];

  // Overpass
  if (result = '') then
  begin
    for Level in CityLevels do
    begin
      if (Level = 0) then
        break;
      LevelX := IntToStr(Level);
      if (FCityList.Values[LevelX] <> '') then
      begin
        result := FCityList.Values[LevelX];
        break;
      end;
    end;
  end;
end;

function TPlace.GetSearchResult: string;
begin
  result := '';
  if (FNodeId <> '') then
    result := result + Format('%s, ', [FNodeId]);
  if (FPostCode <> '') then
    result := result + Format('%s, ', [FPostCode]);
  result := result + Format('Name: %s, City: %s, Province: %s, Country: %s, %s', [Name, City, Province, CountryCode, CountryName]);
end;

function TPlace.HtmlEscape(const HTML: string): string;
begin
  result := HTML;
  result := StringReplace(result, '&',  '&amp;',   [rfReplaceAll]);
  result := StringReplace(result, '<',  '&lt;',    [rfReplaceAll]);
  result := StringReplace(result, '>',  '&gt;',    [rfReplaceAll]);
  result := StringReplace(result, '"',  '&quot;',  [rfReplaceAll]);
  result := StringReplace(result, '''', '&#39;',   [rfReplaceAll]);
  result := StringReplace(result, ' ',  '&nbsp;',  [rfReplaceAll]);
  result := StringReplace(result, '-',  '&#8209;', [rfReplaceAll]);
end;

function TPlace.GetHtmlSearchResult: string;
var
  AField: string;
begin
  result := '';

  AField := HtmlEscape(City);
  if (AField <> '') then
    result := result + AField;

  AField := HtmlEscape(Province);
  if (AField <> '') then
  begin
    if (result <> '') then
      result := result + '<br>';
    result := result + AField;
  end;

  if (result <> '') then
    result := Format('%s %s', [result, HtmlEscape(FCountryCode)]);
end;

procedure TPlace.SetCountryCode(Value: string);
begin
  FCountryCode := Value;
  FRegionLevels := GetRegionLevels;
  FCityLevels := GetCityLevels;
end;

procedure TPlace.AssignFromGeocode(Key, Value: string);
begin
  if (Key = 'country_code') then
    CountryCode := Value;
  if (Key = 'country') then
    FCountryName := Value;

  if (Key = 'county') then
    FProvinceList.AddPair(Key, Value);
  if (Key = 'state') then
    FProvinceList.AddPair(Key, Value);

  if (Key = 'postcode') then
    FPostCode := Value;

  if (Key = 'hamlet') then
    FCityList.AddPair(Key, Value);
  if (Key = 'village') then
    FCityList.AddPair(Key, Value);
  if (Key = 'town') then
    FCityList.AddPair(Key, Value);
  if (Key = 'municipality') then
    FCityList.AddPair(Key, Value);
  if (Key = 'city') then
    FCityList.AddPair(Key, Value);
end;

procedure TPlace.AssignFromOverPass(Key: integer; Value: string);
var
  Level: integer;
begin
  if (Key = 0) then
    FNodeId := Value;
  if (Key = 2) then
    FCountryName := Value;
  for Level in RegionLevels do
  begin
    if (Key = Level) then
      FProvinceList.AddPair(IntToStr(Key), Value);
  end;
  for Level in CityLevels do
  begin
    if (Key = Level) then
      FCityList.AddPair(IntToStr(Key), Value);
  end;
end;

procedure TPlace.AssignFromExifTool(Key, Value: string);
begin
  if (SameText(Key, 'GeolocationCountryCode')) then
    CountryCode := Value;
  if (SameText(Key, 'GeolocationCountry')) then
    FCountryName := Value;
  if (SameText(Key, 'GeolocationRegion')) then
    FProvinceList.AddPair(Key, Value);
  if (SameText(Key, 'GeolocationCity')) then
    FCityList.AddPair(Key, Value);
end;

procedure TPlace.Sort;
begin
  FCityList.Sort;
  FProvinceList.Sort;
end;

function TPlace.GetRegionLevels: TRegionLevels;
var
  Indx, H: integer;
begin
  H := High(ConstRegionLevels);
  result := ConstRegionLevels[H].Levels;
  for Indx := 0 to H -1 do
  begin
    if (ConstRegionLevels[Indx].Country = FCountryCode) then
    begin
      result := ConstRegionLevels[Indx].Levels;
      break;
    end;
  end;
end;

function TPlace.GetCityLevels: TCityLevels;
var
  Indx, H: integer;
begin
  H := High(ConstCityLevels);
  result := ConstCityLevels[H].Levels;
  for Indx := 0 to H -1 do
  begin
    if (ConstCityLevels[Indx].Country = FCountryCode) then
    begin
      result := ConstCityLevels[Indx].Levels;
      break;
    end;
  end;
end;

constructor TOSMHelper.Create(const APathName, AInitialZoom: string);
begin
  inherited Create;
  OsmFormatSettings.DecimalSeparator := '.'; // The decimal separator is a . PERIOD!
  OsmFormatSettings.NegCurrFormat := 11;
  FPathName := APathName;
  FInitialZoom := AInitialZoom;
  Html := TStringList.Create;
  PlacesDict := TObjectDictionary<String, TStringList>.Create([doOwnsValues]);
end;

destructor TOSMHelper.Destroy;
begin
  FPathName := '';
  Html.Free;
  PlacesDict.Free;

  inherited Destroy;
end;

function TOSMHelper.GetHyperLink(const HRef: string = ''): string;
var
  FontSize: string;
begin
  FontSize := '';
  if (Scaled <> 100) then
    FontSize := Format('style="font-size: %sem;"',
                      [FormatFloat('#0.##', 100 / Scaled, CoordFormatSettings)]);

  result := Format('<a %s %s>', [FontSize, HRef]);
end;

procedure TOSMHelper.WriteHeader;
begin
  Html.Clear;

  Html.Add('<Html>');
  Html.Add('<head>');
  Html.Add('<title></title>');
//TODO Create resources
  Html.Add('<script type="text/javascript"  src="http://openlayers.org/api/OpenLayers.js"></script>');
  Html.Add('<script src="http://www.openstreetmap.org/openlayers/OpenStreetMap.js"></script>');
  Html.Add('<script type="text/javascript">');
  Html.Add('var map;');
  Html.Add('var allpoints;');     // Needed for CreateExtent
  Html.Add('var imagepoints;');   // All points for Images
  Html.Add('var imagecoords;');   // Including href
  Html.Add('var trackpoints;');   // Trackpoints
  Html.Add('var style;');
  Html.Add('var po;');
  Html.Add('var op;');
  Html.Add('');
  Html.Add('  function initialize()');
  Html.Add('  {');
  Html.Add('     map = new OpenLayers.Map ("map_canvas", {');
  Html.Add('           controls:         [new OpenLayers.Control.Navigation(),');
  Html.Add('                              new OpenLayers.Control.PanZoomBar(),');
  Html.Add('                              new OpenLayers.Control.LayerSwitcher(),');
  Html.Add('                              new OpenLayers.Control.Attribution()');
  Html.Add('                             ],');
  Html.Add('           maxResolution:    156543.0399,');
  Html.Add('           numZoomLevels:    10,');
  Html.Add('           units:            "m",');
  Html.Add('           projection:       new OpenLayers.Projection("EPSG:900913"),');
  Html.Add('           displayProjection:new OpenLayers.Projection("EPSG:4326")});');
  Html.Add('');
  Html.Add('     map.addLayer(new OpenLayers.Layer.OSM.Mapnik("Mapnik"));');
  Html.Add('     po = map.getProjectionObject();');
  Html.Add('     op = new OpenLayers.Projection("EPSG:4326");');

  Html.Add('     map.events.listeners.mousedown.unshift({');
  Html.Add('        func: function(e){');
  Html.Add('           if (e.ctrlKey) {');
  Html.Add('              var lonlat = map.getLonLatFromViewPortPx(e.xy).transform(po, op);');
  Html.Add('              SendMessage("' + OSMCtrlClick + '", lonlat.lat, lonlat.lon);');
  Html.Add('            }');
  Html.Add('        }');
  Html.Add('     });');

  Html.Add('     map.events.register(''moveend'', map, function(evt) {');
  Html.Add('       GetBounds("' + OSMGetBounds + '");');
  Html.Add('     })');

  Html.Add('     allpoints = new Array();');
  Html.Add('     imagepoints = new Array();');
  Html.Add('     imagecoords = new Array();');
  Html.Add('     trackpoints = new Array();');
  Html.Add('');
  Html.Add('     AddTrackPoints();');
  Html.Add('     AddImagePoints();');
  Html.Add('     CreateExtent(' + FInitialZoom + ');');
  Html.Add('     CreatePopups();');
  Html.Add('  }');

  Html.Add('  function GetLocation(Func){');
  Html.Add('     var bounds = map.getExtent();');
  Html.Add('     var lonlat = bounds.getCenterLonLat().transform(po, op);');
  Html.Add('     SendMessage(Func, lonlat.lat, lonlat.lon);');
  Html.Add('  }');

  Html.Add('  function GetBounds(Func){');
  Html.Add('     var bounds = map.getExtent();');
  Html.Add('     bounds.transform(po, op);');
  Html.Add('     var lonlat = bounds.getCenterLonLat();');
  Html.Add('     SendMessage(Func, bounds.toBBOX(' + IntToStr(Place_Decimals) + ', true), lonlat.lat + ", " + lonlat.lon);');
  Html.Add('  }');

  Html.Add('  function CreateExtent(ZoomLevel){');
  Html.Add('     allpoints = allpoints.concat(imagepoints);');  // allpoints contains all the track points, add the image points
  Html.Add('     var line_string = new OpenLayers.Geometry.LineString(allpoints);');
  Html.Add('     allpoints = new Array();'); // Remove from memory
  Html.Add('     var bounds = new OpenLayers.Bounds();');
  Html.Add('     line_string.calculateBounds();');
  Html.Add('     bounds.extend(line_string.bounds);');
  Html.Add('     map.zoomToExtent(bounds);');
  Html.Add('     if (map.getZoom() > ZoomLevel){');
  Html.Add('       map.zoomTo(ZoomLevel);');
  Html.Add('     }');
  Html.Add('  }');

  // OpenLayers uses LonLat, not LatLon. Confusing maybe,
  Html.Add('  function AddImagePoint(Id, PointLat, PointLon, Href){');
  Html.Add('     var lonlat;');
  Html.Add('     lonlat = new OpenLayers.LonLat(PointLon, PointLat).transform(op, po);');
  Html.Add('     imagepoints[Id] = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);');
  Html.Add('     imagecoords[Id] = [lonlat, Href];');
  Html.Add('  }');

  Html.Add('  function AddTrkPoint(Id, PointLat, PointLon){');
  Html.Add('     var lonlat;');
  Html.Add('     lonlat = new OpenLayers.LonLat(PointLon, PointLat).transform(op, po);');
  Html.Add('     trackpoints[Id] = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);');
  Html.Add('  }');

  Html.Add('  function SendMessage(msg, parm1, parm2){');
  Html.Add('     window.chrome.webview.postMessage({ msg: msg, parm1: parm1, parm2: parm2});');
  Html.Add('  }');

  Html.Add('  function CreatePopups(){');
  Html.Add('     for (let i = 0; i < imagecoords.length; i++) {');
  Html.Add('       var popup = new OpenLayers.Popup.FramedCloud("Popup", imagecoords[i][0], null, imagecoords[i][1], null, true);');
  Html.Add('       map.addPopup(popup);');
  Html.Add('     }');
  Html.Add('  }');

  Html.Add('  function CreateTrack(linename){');
  Html.Add('     linelayer = new OpenLayers.Layer.Vector(linename);');
  Html.Add('     style = {strokeColor: ''#0000ff'', strokeOpacity: 0.6, fillOpacity: 0, strokeWidth: 5};');
  Html.Add('     var line_string = new OpenLayers.Geometry.LineString(trackpoints);');
  Html.Add('     var linefeature = new OpenLayers.Feature.Vector(line_string, null, style);');
  Html.Add('     linelayer.addFeatures([linefeature]);');
  Html.Add('     map.addLayer(linelayer);');
  // Add trackpoints to allpoints. Needed for CreateExtent
  Html.Add('     allpoints = allpoints.concat(trackpoints);');
  Html.Add('     trackpoints = new Array();');
  Html.Add('  }');
end;

procedure TOSMHelper.WritePointsStart;
begin
  Html.Add('  function AddImagePoints(){');
end;

procedure TOSMHelper.WritePoint(const ALat, ALon, AImg: string; Link: boolean);
var
  Key: string;
begin
  Key := Format('%s,%s', [ALat, ALon]);
  if (not PlacesDict.ContainsKey(Key)) then
    PlacesDict.Add(Key, TStringList.Create);
  PlacesDict.Items[Key].AddObject(AImg, Pointer(Link));
end;

procedure TOSMHelper.WritePointsEnd(const GetPlace: boolean);
var
  Place: TPair<string, TStringList>;
  PlaceLoc: TPlace;
  PointCnt: integer;
  PlaceCnt: integer;
  ImgName, Href, Lat, Lon: string;
begin
  PointCnt := 0;
  for Place in PlacesDict do
  begin
    Href := '';
    for PlaceCnt := 0 to PLace.Value.Count -1 do
    begin
      ImgName := Place.Value[PlaceCnt];
      if (ImgName = '') then
        continue;
      if (boolean(Place.Value.Objects[PlaceCnt]) = true) then
        Href := Href + GetHyperLink('href="file://' + StringReplace(ImgName, '\', '/', [rfReplaceAll]) + '"') +
                       ExtractFileName(ImgName) +
                       '</a><br>'
      else if (GetPlace = false) then
        Href := Href + GetHyperLink + ImgName + '</a><br>';
    end;

    if (GetPlace) then
    begin
      ParseLatLon(Place.Key, Lat, Lon);
      PlaceLoc := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);
      if (Assigned(PlaceLoc)) then
        Href := Href + GetHyperLink + PlaceLoc.HtmlSearchResult + '</a>';
    end;
    Html.Add(Format('     AddImagePoint(%d, %s, ''%s'');', [PointCnt, Place.Key, Href]));
    inc(PointCnt);
  end;
  Html.Add('  }');
end;

procedure TOSMHelper.WriteTrackPoints;
var
  F: TStringList;
begin
  Html.Add('  function AddTrackPoints(){');
  if (FileExists(GetTrackTmp)) then
  begin
    F := TStringList.Create;
    try
      F.LoadFromFile(GetTrackTmp);
      Html.AddStrings(F);
    finally
      F.Free;
    end;
  end;
  Html.Add('  }');
end;

procedure TOSMHelper.WriteFooter;
begin
  WriteTrackPoints;

  Html.Add('</script>');
  Html.Add('</head>');
  Html.Add('<body onload="initialize()" >');
  Html.Add('  <div id="map_canvas" style="width: 100%; height: 100%"></div>');
  Html.Add('</body>');
  Html.Add('</html>');

  Html.SaveToFile(FPathName, TEncoding.UTF8);
end;

// ==============================================================================
procedure OsmMapInit(Browser: TEdgeBrowser;
                     const Lat, Lon, Desc, InitialZoom: string);
var
  OsmHelper: TOSMHelper;
begin
  OsmHelper := TOSMHelper.Create(GetHtmlTmp, InitialZoom);
  try
    OsmHelper.Scaled := Browser.ScaleValue(100);
    OsmHelper.WriteHeader;
    OsmHelper.WritePointsStart;
    OsmHelper.WritePoint(Lat, Lon, Desc, false);
    OsmHelper.WritePointsEnd((GeoSettings.GeoCodingEnable <> TGeoCodeEnable.geNone) and
                             (Desc <> OSMHome));
    OsmHelper.WriteFooter;
  finally
    OsmHelper.Free;
  end;
  Browser.Navigate(GetHtmlTmp);
end;

function KnownCountry(const ACountry:string):boolean;
var
  CountryCode, CountryName: string;
begin
  if not (Assigned(CountryList)) then
    CountryList := GetCountryList;
  CountryName := ACountry;
  CountryCode := NextField(CountryName, '|');
  result := (Length(CountryCode) = 2);
  if result and
     (CountryList.Count > 0) then
    result := result and (Countrylist.Values[CountryCode] <> '');
end;

function ExecuteRest(const RESTRequest: TRESTRequest): boolean;
var
  ARestParm: TRESTRequestParameter;
begin
  result := true;
  try
    try
      RESTRequest.Execute;
      if (RESTRequest.Response.StatusCode >= 400) then
        raise exception.Create(StrRequestFailedWith + #10 + RESTRequest.Response.StatusText);
    except
      on E:Exception do
      begin
        result := false;
        if (MessageDlgEx(E.Message + #10 + StrContinueReenabl, '',
                         TMsgDlgType.mtInformation,
                         [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = IDNO) then
          GeoSettings.GeoCodingEnable := TGeoCodeEnable.geNone;
      end;
    end;
  finally
    if Assigned(ExecRestEvent) then
    begin
      // The Caller will free the params right after this request.
      // No need to restore.
      for ARestParm in RESTRequest.Params do
        ARestParm.Options := [TRESTRequestParameterOption.poDoNotEncode];
      ExecRestEvent(RESTRequest.GetFullRequestURL(true) + #10, RESTRequest.Response.Content, result);
    end;
  end;
end;

procedure Throttle(const Delay: Int64);
var Diff: Int64;
begin
  Diff := Delay - MilliSecondsBetween(Now, LastQuery);
  if (Diff > 0) then
    Sleep(Diff);
  LastQuery := Now;
end;

// ==============================================================================
procedure ShowImagesOnMap(Browser: TEdgeBrowser; Apath, ETOuts: string);
var
  OsmHelper: TOSMHelper;
  ETout, Lat, Lon, MIMEType, Filename, LastCoord: string;
  FirstGpx, IsQuickTime: boolean;
begin
  OsmHelper := TOSMHelper.Create(GetHtmlTmp, InitialZoom_Out);
  try
    OsmHelper.Scaled := Browser.ScaleValue(100);
    OsmHelper.WriteHeader;
    OsmHelper.WritePointsStart;
    ETout := ETOuts;
    FirstGpx := true;

    while (ETout <> '') do
    begin
      FileName := AnalyzeGPSCoords(ETOut, Lat, Lon, MIMEType, IsQuickTime);
      if ((Pos('image', MIMEType) > 0) or
          (Pos('video', MIMEType) > 0) or
          (Pos('application/rdf+xml', MIMEType) > 0)  // XMP side car
         )
         and
         ((Lat <> '-') and // Need Lat
          (Lon <> '-')     // and Lon
         ) then
          OsmHelper.WritePoint(Lat, Lon, IncludeTrailingPathDelimiter(Apath) + Filename, true)
      else
      begin
        if (CreateTrkPoints(FileName, FirstGpx, LastCoord) > 0) then
          FirstGpx := false;
      end;
    end;

    OsmHelper.WritePointsEnd(GeoSettings.GeoCodingEnable <> TGeoCodeEnable.geNone);
    OsmHelper.WriteFooter;
  finally
    OsmHelper.Free;
  end;
  Browser.Navigate(GetHtmlTmp);
end;

// Find default lang, and Country code
// Look ahead in the elements, starting from FromElement
// Only admin_level=2
// If type <> area, we get the next city. Could be a different country.

procedure FillCountry_OverPass(AJSONElements: TJSONArray; FromElement: integer; APlace: TPlace);
var
  JSONElement:  TJSONValue;
  JSONTags:     TJSONObject;
  ElementIndx:  integer;
  ElementType:  string;
begin
  if (GeoSettings.ReverseGeoCodeLang <> PlaceLocal) then
    APlace.DefLang := GeoSettings.ReverseGeoCodeLang;
  for ElementIndx := FromElement to AJSONElements.Count -1 do
  begin
    JSONElement := AJSONElements.Items[ElementIndx];
    ElementType := JSONElement.GetValue<string>('type');
    if (ElementType <> 'area') then
      break;

    JSONTags := JSONElement.GetValue<TJSONObject>('tags') as TJSONObject;
    if (JSONTags.FindValue('admin_level') = nil) then
      continue;
    if (JSONTags.GetValue<string>('admin_level') <> '2') then
      continue;

    if (GeoSettings.ReverseGeoCodeLang = PlaceLocal) and
       (JSONTags.FindValue('default_language') <> nil) then
      APlace.DefLang := JSONTags.GetValue<string>('default_language');
    if (JSONTags.FindValue('ISO3166-1:alpha2') <> nil) then
      APlace.CountryCode := JSONTags.GetValue<string>('ISO3166-1:alpha2');
    break;
  end;
end;

function GetPlaceOfCoords_OverPass(const Lat, Lon: string): TPlace;
var
  RESTClient      : TRESTClient;
  RESTRequest     : TRESTRequest;
  RESTResponse    : TRESTResponse;
  JSONObject      : TJSONObject;
  JSONElements    : TJSONArray;
  JSONElement     : TJSONValue;
  JSONTags        : TJSONObject;
  JSONTagVal      : TJSONValue;
  JSOnAdmin       : integer;
  Data            : string;
begin
  result := TPlace.Create;
  Throttle(GeoSettings.ThrottleOverPass);

  // Overpass query
  Data := format('[out:json];is_in(%s, %s);area._[admin_level][name][boundary=administrative];out qt;', [Trim(Lat), Trim(Lon)]);

  RESTClient := TRESTClient.Create(GeoSettings.OverPassUrl);
  RESTResponse := TRESTResponse.Create(nil);
  RESTRequest := TRESTRequest.Create(nil);
  RESTRequest.Client := RESTClient;
  RESTRequest.Resource := 'interpreter';
  RESTRequest.Response := RESTResponse;
  try
    RESTRequest.params.Clear;
    RESTRequest.params.AddItem('data', Data, TRESTRequestParameterKind.pkGETorPOST);
    if not ExecuteRest(RESTRequest) then
      exit;

    JSONObject := RESTResponse.JSONValue as TJSONObject;
    JSONElements := JSONObject.GetValue<TJSONArray>('elements');

    // Find default lang, and Country code
    FillCountry_OverPass(JSONElements, 0, result);

    for JSONElement in JSONElements do
    begin
      JSONTags := JSONElement.GetValue<TJSONObject>('tags') as TJSONObject;
      JSOnAdmin := JSONTags.GetValue<integer>('admin_level');

      // Get name(local) name if avail
      JSONTagVal := nil;
      if (result.FDefLang <> '') then
        JSONTagVal := JSONTags.FindValue('name:' + result.FDefLang);
      if (JSONTagVal = nil) then
        JSONTagVal := JSONTags.FindValue('name');
      if (JSONTagVal = nil) then // Must have a name
        continue;

      result.AssignFromOverPass(JSOnAdmin, JSONTagVal.Value);
    end;
    result.Sort;
  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
  end;
end;

function GetPlaceOfCoords_GeoCode(const Lat, Lon: string): TPlace;
var
  RESTClient:   TRESTClient;
  RESTRequest:  TRESTRequest;
  RESTResponse: TRESTResponse;
  JSONObject:   TJSONObject;
  JSONAddress:  TJSONObject;
  JSONPair:     TJSONPair;
  LatE, LonE:   string;
begin

  Throttle(GeoSettings.ThrottleGeoCode);

  result := TPlace.Create;

  LatE := Trim(Lat);
  LonE := Trim(Lon);

  RESTClient := TRESTClient.Create(GeoSettings.GeoCodeUrl);
  RESTResponse := TRESTResponse.Create(nil);
  RESTRequest := TRESTRequest.Create(nil);
  RESTRequest.Client := RESTClient;
  RESTRequest.Resource := 'reverse';
  RESTRequest.Response := RESTResponse;
  try
    RESTRequest.params.Clear;
    RESTRequest.params.AddItem('lat', LatE, TRESTRequestParameterKind.pkGETorPOST);
    RESTRequest.params.AddItem('lon', LonE, TRESTRequestParameterKind.pkGETorPOST);

    if (GeoSettings.GeoCodeApiKey <> '') then
      RESTRequest.params.AddItem('api_key', GeoSettings.GeoCodeApiKey , TRESTRequestParameterKind.pkGETorPOST);

    if not ExecuteRest(RESTRequest) then
      exit;

    JSONObject := TJSonObject.ParseJSONValue(RESTResponse.Content) as TJSONObject;
    try
      if (JSONObject.FindValue('address') <> nil) then
      begin
        JSONAddress := JSONObject.GetValue<TJSONObject>('address');
        for JSONPair in JSONAddress do
          result.AssignFromGeocode(TPlace.UnEscape(JSONPair.JsonString.ToString),
                                   TPlace.UnEscape(JSONPair.JsonValue.ToString)
                                  );
        result.Sort;
      end;
    finally
      JSONObject.Free;
    end;
  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
  end;
end;

function GetPlaceOfCoords_ExifTool(const Lat, Lon: string): TPlace;
var
  LatE, LonE, AResult, AKey, AValue: string;
  ETResult: TStrings;
begin
  result := TPlace.Create;
  LatE := Trim(Lat);
  LonE := Trim(Lon);
  result.DefLang := GeoSettings.ReverseGeoCodeLang;

  ETResult := ExifToolGeoLocation(LatE, LonE, result.DefLang);
  try
    for AResult in ETResult do
    begin
      AValue := AResult;
      AKey := Trim(NextField(AValue, ':'));
      AValue := Trim(AValue);
      result.AssignFromExifTool(AKey,
                                AValue
                               );
    end;
    result.Sort;
  finally
    ETResult.Free;
  end;
end;

function GetPlaceOfCoords(const Lat, Lon: string; const Provider: TGeoCodeProvider): TPlace;
var CoordsKey: string;
    LatP, LonP: string;
    CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    LatP := Lat;
    LonP := Lon;
    AdjustLatLon(LatP, LonP, Place_Decimals);
    CoordsKey := LatP + ',' + LonP;
    if (CoordCache.ContainsKey(CoordsKey)) then
    begin
      result := CoordCache.Items[CoordsKey];
      exit;
    end;

    result := nil;

    case (GeoSettings.GeoCodingEnable) of
      TGeoCodeEnable.geNone:
        exit;
      TGeoCodeEnable.geAll:
        begin
          case Provider of
            TGeoCodeProvider.gpGeoName:
              result := GetPlaceOfCoords_GeoCode(Lat, Lon);
            TGeoCodeProvider.gpOverPass:
              result := GetPlaceOfCoords_OverPass(Lat, Lon);
            TGeoCodeProvider.gpExifTool:
              result := GetPlaceOfCoords_ExifTool(Lat, Lon);
          end;
        end;
      TGeoCodeEnable.geOffline:
        begin
          case Provider of
            TGeoCodeProvider.gpExifTool:
              result := GetPlaceOfCoords_ExifTool(Lat, Lon);
          end;
        end;
    end;

    // Also cache if not found
    CoordCache.Add(CoordsKey, result);
  finally
    SetCursor(CrNormal);
  end;
end;

procedure ClearCoordCache;
begin
  CoordCache.Clear;
end;

function ChooseLocation(var Lat, Lon: string): Integer;
begin
  Lat := '';
  Lon := '';
  with FrmPlaces do
  begin
    result := ShowModal;
    if (result <> IDOK) then
      exit;
    if (Listview1.Selected = nil) then
      exit;
    Lat := Listview1.Selected.Caption;
    Lon := Listview1.Selected.Subitems[0];
  end;
end;

function GetCoordsOfPlace_OverPass(const City, CountryRegion, Bounds: string; var Lat, Lon: string): integer;
var
  RESTClient      : TRESTClient;
  RESTRequest     : TRESTRequest;
  RESTResponse    : TRESTResponse;
  JSONObject      : TJSONObject;
  JSONElements    : TJSONArray;
  JSONElement     : TJSONValue;
  JSOnAdmin       : integer;
  ElementIndx     : integer;
  SearchBounds    : string;
  SearchName      : string;
  SearchPlaces    : string;
  SearchNode      : string;
  SearchOp        : string;
  SearchStart     : string;
  SearchEnd       : string;
  SearchCase      : string;
  FormatNL        : string;
  Data            : string;
  ElementType     : string;
  JSONNodeVal     : TJSONObject;
  JSONTagVal      : TJSONValue;
  PlaceResult     : TPlace;
begin
  result := IDOK;
  if (Length(Trim(City)) < 5) and
     (CountryRegion = '') and
     (Bounds = '') then
    exit;

  Throttle(GeoSettings.ThrottleOverPass);

  Lat         := '';
  Lon         := '';
{$IFDEF DEBUG}
  FormatNL    := #10;
{$ELSE}
  FormatNL    := '';
{$ENDIF}
  SearchBounds:= '';
  SearchOp    := '=';
  SearchStart := '';
  SearchEnd   := '';
  SearchCase  := '';

  if (GeoSettings.CaseSensitive = false) then
  begin
    SearchOp    := '~';
    SearchCase  := ',i';
  end;
  if (GeoSettings.OverPassCompleteWord = false) then
    SearchOp    := '~';

  if (SearchOp <> '=') then
  begin
    if (GeoSettings.OverPassCompleteWord = true) then
    begin
      SearchStart := '^';
      SearchEnd   := '$';
    end;
  end;
  SearchPlaces := 'municipality|city|town|village|hamlet';
  SearchNode := Format('node[%%s][place~"%s"](area.searchArea);%%s', [SearchPlaces]);
  SearchName := Format('"%%s"%s"%s%s%s"%s',
                  [SearchOp, SearchStart,
                   StringReplace(Trim(City), '&', '', [rfReplaceAll]),
                   SearchEnd, SearchCase]);

  Data := Format('[out:json][timeout:25];%s',
                  [FormatNL]);

  if (CountryRegion = '') then
  begin   // Query within selected bounds
    if (Bounds <> '') then
      SearchBounds := Format('(%s);', [Bounds]);

    // Join Name and Name:languagecode
    Data := Data + Format('(%s', [FormatNL]);
    Data := Data +
            Format('node[%s][place~"^(%s)$"]%s%s',
              [Format(SearchName, ['name']), SearchPlaces, SearchBounds, FormatNL]);
    if (GeoSettings.GeoCodeLang <> '') then // Search for name:xx xx=selected language code
      Data := Data + Format('node[%s][place~"^(%s)$"]%s%s',
                       [Format(SearchName, ['name:' + LowerCase(GeoSettings.GeoCodeLang)]), SearchPlaces, SearchBounds, FormatNL]);
    Data := Data +  Format(');%s', [FormatNL]);

  end
  else
  begin   // Query within country/region case and language insensitive
    if (KnownCountry(CountryRegion)) then
      Data := Data +
                // Search for ISO country code (2 pos)
                Format('(%s' +
                       ' rel["ISO3166-1"="%s"][boundary=administrative][admin_level="2"];%s'+
                       ');%s' +
                       'map_to_area->.searchArea;%s',
                        [FormatNL,
                         StringReplace(Trim(UpperCase(CountryRegion)), '&', '', [rfReplaceAll]),
                         FormatNL,
                         FormatNL,
                         FormatNL,
                         FormatNL])
    else
      Data := Data +
                // Search for Region
                Format('(%s' +
                        ' rel["name"~"%s", i][boundary=administrative][admin_level~"3|4|5"];%s'+
                        ');%s' +
                        'map_to_area->.searchArea;%s',
                        [FormatNL,
                         StringReplace(Trim(CountryRegion), '&', '', [rfReplaceAll]),
                         FormatNL,
                         FormatNL,
                         FormatNL]);

    // Join Name and Name:languagecode
    Data := Data + Format('(%s', [FormatNL]);
    Data := Data + Format(SearchNode, [Format(SearchName, ['name']), FormatNL]);
    if (GeoSettings.GeoCodeLang <> '') then // Search for name:xx xx=selected language code
      Data := Data + Format(SearchNode, [Format(SearchName, ['name:' + LowerCase(GeoSettings.GeoCodeLang)]), FormatNL]);
    Data := Data +  Format(');%s', [FormatNL]);

  end;
  Data := Data +
    Format('foreach%s{%s'+
           '  out qt;%s' +
           '  is_in; area._[name][boundary=administrative][admin_level];%s' +
           '  out qt;%s' +
           '  out count;%s' +
           '}%s',
             [FormatNL, FormatNL, FormatNL, FormatNL, FormatNL, FormatNL, FormatNL, FormatNL]);

  RESTClient := TRESTClient.Create(GeoSettings.OverPassUrl);
  RESTResponse := TRESTResponse.Create(nil);
  RESTRequest := TRESTRequest.Create(nil);
  RESTRequest.Client := RESTClient;
  RESTRequest.Resource := 'interpreter';
  RESTRequest.Response := RESTResponse;

  PlaceResult := TPlace.Create;
  try
    RESTRequest.params.Clear;
    RESTRequest.params.AddItem('data', Data, TRESTRequestParameterKind.pkGETorPOST);
    if not ExecuteRest(RESTRequest) then
      exit;

    FrmPlaces.Listview1.Items.Clear;
    JSONObject := RESTResponse.JSONValue as TJSONObject;
    JSONElements := JSONObject.GetValue<TJSONArray>('elements');
    for ElementIndx := 0 to JSONElements.Count -1 do
    begin
      JSONElement := JSONElements.Items[ElementIndx];
      ElementType := JSONElement.GetValue<string>('type');
      if (ElementType = 'node')  then
      begin
        Lat := JSONElement.GetValue<string>('lat');
        Lon := JSONElement.GetValue<string>('lon');
        JSONNodeVal := JSONElement.GetValue<TJSONObject>('tags') as TJSONObject;

        PlaceResult.Clear;
        PlaceResult.AssignFromOverPass(0, Format('%s: %s',
                                                 [JSONElement.GetValue<string>('type'),
                                                  JSONElement.GetValue<string>('id')])
                                       );
        if (JSONNodeVal.FindValue('postal_code') <> nil) then
          PlaceResult.PostCode := JSONNodeVal.GetValue<string>('postal_code');
        if (JSONNodeVal.FindValue('name') <> nil) then
          PlaceResult.Name := JSONNodeVal.GetValue<string>('name');
        continue;
      end;

      if (ElementType = 'count')  then
      begin
        FrmPlaces.AddPlace2LV(PlaceResult.SearchReault, Lat, Lon);
        continue;
      end;

      if (ElementType = 'area')  then
      begin
        if (PlaceResult.CountryCode = '') then  // First get country code
          FillCountry_OverPass(JSONElements, ElementIndx, PlaceResult);

        JSONNodeVal := JSONElement.GetValue<TJSONObject>('tags') as TJSONObject;
      // Get name(local) name if avail
        JSONTagVal := nil;
        if (PlaceResult.FDefLang <> '') then
          JSONTagVal := JSONNodeVal.FindValue('name:' + PlaceResult.FDefLang);
        if (JSONTagVal = nil) then
          JSONTagVal := JSONNodeVal.FindValue('name');
        if (JSONTagVal = nil) then // Must have a name
          continue;

        JSOnAdmin := JSONNodeVal.GetValue<integer>('admin_level');
        PlaceResult.AssignFromOverPass(JSOnAdmin, JSONTagVal.Value);

        continue;
      end;
    end;
    PlaceResult.Sort;
    result := ChooseLocation(Lat, Lon);

  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
    PlaceResult.Free;
  end;
end;

function GetCoordsOfPlace_GeoCode(const City, Country: string; var Lat, Lon: string):integer;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  JValue: TJSONValue;
  Places: TJSONArray;
begin
  result := IDOK;
  if (Length(Trim(City)) < 5) and
     (Country = '') then
    exit;

  Throttle(GeoSettings.ThrottleGeoCode);

  Lat := '';
  Lon := '';

  RESTClient := TRESTClient.Create(GeoSettings.GeoCodeUrl);
  RESTResponse := TRESTResponse.Create(nil);
  RESTRequest := TRESTRequest.Create(nil);
  RESTRequest.Client := RESTClient;
  RESTRequest.Resource := 'search';
  RESTRequest.Response := RESTResponse;
  try
    RESTRequest.params.Clear;
    if (Country <> '') then
    begin
      RESTRequest.params.AddItem('city', City, TRESTRequestParameterKind.pkGETorPOST);
      RESTRequest.params.AddItem('country', Country, TRESTRequestParameterKind.pkGETorPOST);
    end
    else
      RESTRequest.params.AddItem('q', City, TRESTRequestParameterKind.pkGETorPOST);

    if (GeoSettings.GeoCodeApiKey <> '') then
      RESTRequest.params.AddItem('api_key', GeoSettings.GeoCodeApiKey , TRESTRequestParameterKind.pkGETorPOST);

    if not ExecuteRest(RESTRequest) then
      exit;

    FrmPlaces.Listview1.Items.Clear;

    Places := RESTResponse.JSONValue as TJSONArray;
    for JValue in Places do
      FrmPlaces.AddPlace2LV(JValue.GetValue<string>('display_name'), JValue.GetValue<string>('lat'), JValue.GetValue<string>('lon'));
    result := ChooseLocation(Lat, Lon);
  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
  end;
end;

function GetCoordsOfPlace_ExifTool(const City, CountryRegion: string; var Lat, Lon: string):integer;
var
  ETResult: TStringList;
  Match: string; // cc for CountryCode or '' for all
  ETerr: string;
  AValue: string;
  AKey: string;
  Display: string;
begin
  result := IDOK;

  if (City = '') and
     (CountryRegion = '') then
    exit;

  Lat := '';
  Lon := '';

  ETResult := TStringList.Create;
  try
    Match := '';
    if (KnownCountry(CountryRegion)) then
      Match := 'cc';

    ETResult.Text := ExifToolGeoLocation(City, CountryRegion, Match, GeoSettings.GeoCodeLang, ETerr);
    FrmPlaces.Listview1.Items.Clear;
    if (ETerr <> '') then
      FrmPlaces.AddPlace2LV(ETerr, '', '')
    else
    begin
      Display := '';
      for ETerr in ETResult do
      begin
        AValue := ETerr;
        AKey := Trim(NextField(AValue, ' '));
        AKey := Trim(NextField(AValue, ':'));

        AValue := Trim(AValue);
        if (AKey = 'Time Zone') then
          continue;
// City should be first, Position last
        if (AKey = 'City') then
          Display := AValue
        else if (AKey = 'Position') then
        begin
          ParseLatLon(AValue, Lat, Lon);
          FrmPlaces.AddPlace2LV(Display, Lat, Lon);
          Display := '';
        end
        else
          Display := Display + ', ' + AKey + '=' + AValue;
      end;
    end;

    result := ChooseLocation(Lat, Lon);

  finally
    ETResult.Free;
  end;
end;

procedure GetCoordsOfPlace(const Place, Bounds: string; var Lat, Lon: string);
var
  CrWait, CrNormal: HCURSOR;
  CountryRegion: string;
  RetrySearch: boolean;
begin
  CountryRegion := Place;
  FGeoSearch.EdSearchCity.Text := Trim(NextField(CountryRegion, ','));
  if (FGeoSearch.EdSearchCity.Text = '') then
    exit;
  FGeoSearch.CountryRegion := Trim(CountryRegion);
  FGeoSearch.EdBounds.Text := Bounds;

  repeat
    RetrySearch := false;
    if (GeoSettings.GeoCodeDialog) then
    begin
      if (FGeoSearch.ShowModal <> IDOK) then
        exit;
    end;

    CrWait := LoadCursor(0, IDC_WAIT);
    CrNormal := SetCursor(CrWait);
    try
      case (GeoSettings.GeoCodingEnable) of
        TGeoCodeEnable.geNone:
          exit;
        TGeoCodeEnable.geAll:
          begin
            case GeoSettings.GetCoordProvider of
              TGeoCodeProvider.gpGeoName:
                RetrySearch := (GetCoordsOfPlace_GeoCode(FGeoSearch.EdSearchCity.Text,
                                                         FGeoSearch.CountryRegion,
                                                         Lat, Lon) = IDRETRY);
              TGeoCodeProvider.gpOverPass:
                RetrySearch := (GetCoordsOfPlace_OverPass(FGeoSearch.EdSearchCity.Text,
                                                          FGeoSearch.CountryRegion,
                                                          FGeoSearch.EdBounds.Text,
                                                          Lat, Lon) = IDRETRY);
              TGeoCodeProvider.gpExifTool:
                RetrySearch := (GetCoordsOfPlace_ExifTool(FGeoSearch.EdSearchCity.Text,
                                                          FGeoSearch.CountryRegion,
                                                          Lat, Lon) = IDRETRY);
            end;
          end;
        TGeoCodeEnable.geOffline:
          begin
            case GeoSettings.GetCoordProvider of
              TGeoCodeProvider.gpExifTool:
                RetrySearch := (GetCoordsOfPlace_ExifTool(FGeoSearch.EdSearchCity.Text,
                                                          FGeoSearch.CountryRegion,
                                                          Lat, Lon) = IDRETRY);
            end;
          end;
      end;

    finally
      SetCursor(CrNormal);
    end;
  until (not RetrySearch);
end;

procedure MapGetLocation(Browser: TEdgeBrowser);
begin
  Browser.ExecuteScript('GetLocation("' + OSMGetLocation + '");');
end;

function MapGoToPlace(Browser: TEdgeBrowser; Place, Bounds, Desc, InitialZoom: string): string;
var
  Lat, Lon: string;
begin
  result := Place;
  ParseLatLon(Place, Lat, Lon);
  if not(ValidLatLon(Lat, Lon)) then
  begin
    GetCoordsOfPLace(Place, Bounds, Lat, Lon);
    if not(ValidLatLon(Lat, Lon)) then
      exit;
    AdjustLatLon(Lat, Lon, Coord_Decimals);
    result := Lat + ', ' + Lon;
  end;
  OsmMapInit(Browser, Lat, Lon, Desc, InitialZoom);
end;

procedure ParseJsonMessage(const Message: string; var Msg, Parm1, Parm2: string);
var
  JSONValue: TJSONValue;
begin
  JSONValue := TJSonObject.ParseJSONValue(Message);
  try
    Msg := JSONValue.GetValue<string>('msg');
    Parm1 := JSONValue.GetValue<string>('parm1');
    Parm2 := JSONValue.GetValue<string>('parm2');
  finally
    JSONValue.Free;
  end;
end;

function GetCountryList: TStringList;
begin
  if not Assigned(CountryList) then
    CountryList := ExifToolGetCountryList;
  result := CountryList;
end;

function ValidLatLon(const Lat, Lon: string): boolean;
var
  ADouble: Double;
begin
  result := TryStrToFloat(Lat, ADouble, CoordFormatSettings);
  result := result and (Abs(ADouble) <= 90);
  result := result and TryStrToFloat(Lon, ADouble, CoordFormatSettings);
  result := result and (Abs(ADouble) <= 180);
end;

procedure AdjustLatLon(var Lat, Lon: string; No_Decimals: integer);

  procedure AdjustUsingRound(var ACoord: string);
  var
    F: double;
  begin
    if TryStrToFloat(ACoord, F, CoordFormatSettings) then
    begin
      F := RoundTo(F, -No_Decimals);
      ACoord := FloatToStr(F, CoordFormatSettings);
    end;
  end;

begin
  AdjustUsingRound(Lat);
  AdjustUsingRound(Lon);
end;

procedure ParseLatLon(const LatLon: string; var Lat, Lon: string);
begin
  Lon := LatLon;
  Lat := Trim(NextField(Lon, ','));
  Lon := Trim(Lon);
end;

procedure ReadGeoCodeSettings(GUIini: TMemIniFile);
begin
  GeoSettings.GetCoordProvider := TGeoCodeProvider(GUIini.ReadInteger(Geo_Settings, 'GetCoordProvider', 0));
  GeoSettings.GetPlaceProvider := TGeoCodeProvider(GUIini.ReadInteger(Geo_Settings, 'GetPlaceProvider', 1));
  GeoSettings.GeoCodeUrl := GUIini.ReadString(Geo_Settings, 'GeoCodeUrl', ReadResourceId(ETD_GeoCode));
  GeoSettings.GeoCodeApiKey := GUIini.ReadString(Geo_Settings, 'GeoCodeApiKey', '');

  GeoSettings.ThrottleGeoCode := GUIini.ReadInteger(Geo_Settings, 'ThrottleGeoCode', 1000);
  GeoSettings.OverPassUrl := GUIini.ReadString(Geo_Settings, 'OverPassUrl', ReadResourceId(ETD_OverPass));
  GeoSettings.ThrottleOverPass := GUIini.ReadInteger(Geo_Settings, 'ThrottleOverPass', 10);
  GeoSettings.CaseSensitive := GUIini.ReadBool(Geo_Settings, 'OverPassCaseSensitive', True);
  GeoSettings.OverPassCompleteWord := GUIini.ReadBool(Geo_Settings, 'OverPassCompleteWord', True);
  GeoSettings.OverPassCompleteWord := GUIini.ReadBool(Geo_Settings, 'OverPassCompleteWord', True);
  GeoSettings.GeoCodeLang := GUIini.ReadString(Geo_Settings, 'GeoCodeLang', PlaceDefault);
  GeoSettings.ReverseGeoCodeLang := GUIini.ReadString(Geo_Settings, 'ReverseGeoCodeLang', PlaceDefault);
  GeoSettings.CountryCodeLocation := GUIini.ReadBool(Geo_Settings, 'CountryCodeLocation', True);
  GeoSettings.GeoTagMode := TGeoTagMode(GUIini.ReadInteger(Geo_Settings, 'GeoTagMode', 1));
  GeoSettings.GeoCodeDialog := GUIini.ReadBool(Geo_Settings, 'GeoCodeDialog', true);
  GeoSettings.ReverseGeoCodeDialog := GUIini.ReadBool(Geo_Settings, 'ReverseGeoCodeDialog', true);
  GeoSettings.GeoCodingEnable := TGeoCodeEnable(GUIini.ReadInteger(Geo_Settings, 'GeoCodingEnable', 0));

  GUIini.ReadSectionValues(Geo_Province, GeoProvinceList);

  GUIini.ReadSectionValues(Geo_City, GeoCityList);
end;

procedure WriteGeoCodeSettings(GUIini: TMemIniFile);
var
  TmpItems: TStringList;
begin
  GUIini.WriteString(Geo_Settings, 'GeoCodeUrl', GeoSettings.GeoCodeUrl);
  GUIini.WriteString(Geo_Settings, 'OverPassUrl', GeoSettings.OverPassUrl);
  GUIini.WriteString(Geo_Settings, 'GeoCodeApiKey', GeoSettings.GeoCodeApiKey);
  GUIini.WriteInteger(Geo_Settings, 'GetCoordProvider', Ord(GeoSettings.GetCoordProvider));
  GUIini.WriteInteger(Geo_Settings, 'ThrottleGeoCode', GeoSettings.ThrottleGeoCode);
  GUIini.WriteInteger(Geo_Settings, 'GetPlaceProvider', Ord(GeoSettings.GetPlaceProvider));
  GUIini.WriteInteger(Geo_Settings, 'ThrottleOverPass', GeoSettings.ThrottleOverPass);
  GUIini.WriteBool(Geo_Settings, 'OverPassCaseSensitive', GeoSettings.CaseSensitive);
  GUIini.WriteBool(Geo_Settings, 'OverPassCompleteWord', GeoSettings.OverPassCompleteWord);
  GUIini.WriteString(Geo_Settings, 'GeoCodeLang', GeoSettings.GeoCodeLang);
  GUIini.WriteString(Geo_Settings, 'ReverseGeoCodeLang', GeoSettings.ReverseGeoCodeLang);
  GUIini.WriteBool(Geo_Settings, 'CountryCodeLocation', GeoSettings.CountryCodeLocation);
  GUIini.WriteInteger(Geo_Settings, 'GeotagMode', Ord(GeoSettings.GeoTagMode));
  GUIini.WriteBool(Geo_Settings, 'GeoCodeDialog', GeoSettings.GeoCodeDialog);
  GUIini.WriteBool(Geo_Settings, 'ReverseGeoCodeDialog', GeoSettings.ReverseGeoCodeDialog);
  GUIini.WriteInteger(Geo_Settings, 'GeoCodingEnable', Ord(GeoSettings.GeoCodingEnable));

  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.
    TmpItems.Add(Format('[%s]', [Geo_Province]));
    TmpItems.AddStrings(GeoProvinceList);
    TmpItems.Add(Format('[%s]', [Geo_City]));
    TmpItems.AddStrings(GeoCityList);
    GUIini.SetStrings(TmpItems);
  finally
    TmpItems.Free;
  end;
end;

initialization
begin
  CoordFormatSettings.ThousandSeparator := ',';
  CoordFormatSettings.DecimalSeparator := '.';
  GeoCityList := TStringList.Create;
  GeoProvinceList := TStringList.Create;
  CoordCache := TObjectDictionary<string, TPlace>.Create([doOwnsValues]);
  LastQuery := 0;
end;

finalization
begin
  CoordCache.Free;
  GeoCityList.Free;
  GeoProvinceList.Free;
  if (Assigned(CountryList)) then
    CountryList.Free;
end;

end.
