unit Geomap;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.IniFiles,
  Vcl.Edge;

type
  TGeoCodeProvider = (gpGeoName, gpOverPass);

  GEOsettingsRec = record
    GetCoordProvider: TGeoCodeProvider;
    GetPlaceProvider: TGeoCodeProvider;
    GeoCodeUrl: string;
    ThrottleGeoCode: integer;
    OverPassUrl: string;
    OverPassCaseSensitive: boolean;
    OverPassCompleteWord: boolean;
    ThrottleOverPass: integer;
    CountryCodeLocation: boolean;
  end;

  TPlace = class
    FCityList : TStringList;
    FProvinceList : TStringList;
    FCountryCode: string;
    FDefLang: string;
    FCountry: string;
    FName: string;
    FNodeId: string;
    FPostCode: string;
    function GetCountryLocation: string;
    function GetPrioProvince: string;
    function GetProvince: string;
    function GetPrioCity: string;
    function GetCity: string;
    function GetSearchResult: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AssignFromGeocode(Key, Value: string);
    procedure AssignFromOverPass(Key: integer; Value: string);
    property CountryCode: string read FCountryCode write FCountryCode;
    property CountryLocation: string read GetCountryLocation;
    property DefLang: string read FDefLang write FDefLang;
    property PostCode: string read FPostCode write FPostCode;
    property Name: string read FName write FName;
    property PrioProvince: string read GetPrioProvince;
    property Province: string read GetProvince;
    property PrioCity: string read GetPrioCity;
    property City: string read GetCity;
    property SearchReault: string read GetSearchResult;
    class function UnEscape(Value: string): string;
  end;

procedure OsmMapInit(Browser: TEdgeBrowser;
                     const Lat, Lon, Desc, InitialZoom: string);
procedure ShowImagesOnMap(Browser: TEdgeBrowser; Apath, ETOuts: string);
procedure MapGetLocation(Browser: TEdgeBrowser);
function MapGoToPlace(Browser: TEdgeBrowser; Place, Bounds, Desc, InitialZoom: string): string;
procedure ParseJsonMessage(const Message: string; var Msg, Parm1, Parm2: string);
function ValidLatLon(const Lat, Lon: string): boolean;
procedure ParseLatLon(const LatLon: string; var Lat, Lon: string);
procedure AdjustLatLon(var Lat, Lon: string; No_Decimals: integer);
function GetPlaceOfCoords(const Lat, Lon: string; const Provider: TGeoCodeProvider): TPlace;
procedure ClearCoordCache;
procedure GetCoordsOfPlace(const Place, Bounds: string; var Lat, Lon: string; const Provider: TGeoCodeProvider);
procedure ReadGeoCodeSettings(GUIini: TMemIniFile);
procedure WriteGeoCodeSettings(GUIini: TMemIniFile);

const
  Coord_Decimals = 6;
  CRLF = #13#10;
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
    OsmFormatSettings: TFormatSettings;
    Html: TStringList;
    FInitialZoom: string;
    FPathName: string;
    PlacesDict: TObjectDictionary<String, TStringList>;
    procedure WriteHeader;
    procedure WritePointsStart;
    procedure WritePoint(const ALat, ALon, AImg: string);
    procedure WritePointsEnd;
    procedure WriteFooter;
  public
    constructor Create(const APathName, AInitialZoom: string);
    destructor Destroy; override;
  end;

var
  GeoSettings: GEOsettingsRec;
  GeoProvinceList: TStringList;
  GeoCityList: TStringList;

implementation

uses
  System.Variants, System.JSON,  System.NetEncoding, System.Math, System.StrUtils, System.DateUtils,
  Winapi.Windows,
  REST.Types, REST.Client, REST.Utils,
  UFrmPlaces, ExifToolsGUI_Utils;

var
  CoordFormatSettings: TFormatSettings; // for StrToFloatDef -see Initialization
  LastQuery: TDateTime;
  CoordCache: TObjectDictionary<string, TPlace>;

constructor TPlace.Create;
begin
  inherited Create; // Does nothing
  FCityList := TStringList.Create;
  FCityList.Duplicates := TDuplicates.dupIgnore;
  FProvinceList := TStringList.Create;
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
  SetLength(FCountry, 0);
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
    result := FCountry;
end;

function TPlace.GetPrioProvince: string;
var GeoPrio: string;
begin
  result := '';
  GeoPrio := GeoProvinceList.Values[FCountryCode];
  if (FProvinceList.Values[GeoPrio] <> '') then
    result := FProvinceList.Values[GeoPrio];
end;

function TPlace.GetProvince: string;
begin
  result := GetPrioProvince;

  // Geocode
  if (result = '') and (FProvinceList.Values['county'] <> '') then
    result := FProvinceList.Values['county'];
  if (result = '') and (FProvinceList.Values['state'] <> '') then
    result := FProvinceList.Values['state'];

  // Overpass
  if (result = '') and (FProvinceList.Values['6'] <> '') then
    result := FProvinceList.Values['6'];
  if (result = '') and (FProvinceList.Values['5'] <> '') then
    result := FProvinceList.Values['5'];
  if (result = '') and (FProvinceList.Values['4'] <> '') then
    result := FProvinceList.Values['4'];
  if (result = '') and (FProvinceList.Values['3'] <> '') then
    result := FProvinceList.Values['3'];
end;

function TPlace.GetPrioCity: string;
var GeoPrio: string;
begin
  result := '';
  GeoPrio := GeoCityList.Values[FCountryCode];
  if (FCityList.Values[GeoPrio] <> '') then
    result := FCityList.Values[GeoPrio];
end;

function TPlace.GetCity: string;
begin
  result := GetPrioCity;

  // Geocode
  if (result = '') and (FCityList.Values['village'] <> '') then
    result := FCityList.Values['village'];
  if (result = '') and (FCityList.Values['municipality'] <> '') then
    result := FCityList.Values['municipality'];
  if (result = '') and (FCityList.Values['town'] <> '') then
    result := FCityList.Values['town'];
  if (result = '') and (FCityList.Values['city'] <> '') then
    result := FCityList.Values['city'];

  // Overpass
  if (result = '') and (FCityList.Values['8'] <> '') then
    result := FCityList.Values['8'];
  if (result = '') and (FCityList.Values['7'] <> '') then
    result := FCityList.Values['7'];
  if (result = '') and (FCityList.Values['9'] <> '') then
    result := FCityList.Values['9'];
  if (result = '') and (FCityList.Values['10'] <> '') then
    result := FCityList.Values['10'];
end;

function Tplace.GetSearchResult: string;
begin
  result := '';
  if (FNodeId <> '') then
    result := result + Format('%s, ', [FNodeId]);
  if (FPostCode <> '') then
    result := result + Format('%s, ', [FPostCode]);
  result := result + Format('Name: %s, City: %s, Province: %s, Country: %s, %s', [Name, City, Province, FCountryCode, FCountry]);
end;

procedure TPlace.AssignFromGeocode(Key, Value: string);
begin
  if (Key = 'country_code') then
    FCountryCode := Value;
  if (Key = 'country') then
    FCountry := Value;

  if (Key = 'county') then
    FProvinceList.AddPair(Key, Value);
  if (Key = 'state') then
    FProvinceList.AddPair(Key, Value);

  if (Key = 'postcode') then
    FPostCode := Value;

  if (Key = 'town') then
    FCityList.AddPair(Key, Value);
  if (Key = 'village') then
    FCityList.AddPair(Key, Value);
  if (Key = 'municipality') then
    FCityList.AddPair(Key, Value);
  if (Key = 'city') then
    FCityList.AddPair(Key, Value);
end;

procedure TPlace.AssignFromOverPass(Key: integer; Value: string);
begin
  if (Key = 0) then
    FNodeId := Value;
  if (Key = 2) then
    FCountry := Value;
  if (Key >= 3) and
     (Key <= 6) then
    FProvinceList.AddPair(IntToStr(Key), Value);
  if (Key >= 7) and
     (Key <= 10) then
    FCityList.AddPair(IntToStr(Key), Value);
end;

constructor TOSMHelper.Create(const APathName, AInitialZoom: string);
begin
  inherited Create;
  OsmFormatSettings := TFormatSettings.Create(GetThreadLocale);
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

procedure TOSMHelper.WriteHeader;
begin
  Html.Clear;

  Html.Add('<Html>');
  Html.Add('<head>');
  Html.Add('<title></title>');
  Html.Add('<script type="text/javascript"  src="http://openlayers.org/api/OpenLayers.js"></script>');
  Html.Add('<script src="http://www.openstreetmap.org/openlayers/OpenStreetMap.js"></script>');
  Html.Add('<script type="text/javascript">');
  Html.Add('');
  Html.Add('var map;');
  Html.Add('var coords;');
  Html.Add('var points;');
  Html.Add('var style;');
  Html.Add('');
  Html.Add('var lineFeature;');
  Html.Add('var po;');
  Html.Add('var op;');
  Html.Add('');
  Html.Add('  function initialize()');
  Html.Add('  {');
  Html.Add('     map = new OpenLayers.Map ("map_canvas", {');
  Html.Add('           controls:         [new OpenLayers.Control.Navigation(),');
  Html.Add('                              new OpenLayers.Control.PanZoomBar(),');
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

//TODO: Not needed?
//  Html.Add('     map.events.register(''zoomend'', map, function(evt) {');
//  Html.Add('       GetBounds("' + OSMGetBounds + '");');
//  Html.Add('     })');

  Html.Add('     map.events.register(''moveend'', map, function(evt) {');
  Html.Add('       GetBounds("' + OSMGetBounds + '");');
  Html.Add('     })');

  Html.Add('');
  Html.Add('     CreateExtent(' + FInitialZoom + ');');
  Html.Add('     CreatePopups();');
  Html.Add('  }');
  Html.Add('');

  Html.Add('  function GetLocation(Func){');
  Html.Add('     var bounds = map.getExtent();');
  Html.Add('     var lonlat = bounds.getCenterLonLat().transform(po, op);');
  Html.Add('     SendMessage(Func, lonlat.lat, lonlat.lon);');
  Html.Add('  }');

  Html.Add('  function GetBounds(Func){');
  Html.Add('     var bounds = map.getExtent();');
  Html.Add('     bounds.transform(po, op);');
  Html.Add('     var lonlat = bounds.getCenterLonLat();');
  Html.Add('     SendMessage(Func, bounds.toBBOX(4, true), lonlat.lat + ", " + lonlat.lon);');
  Html.Add('  }');
  Html.Add('  function CreateExtent(ZoomLevel){');
  Html.Add('');
  Html.Add('     coords = new Array();');
  Html.Add('     points = new Array();');
  Html.Add('');
  Html.Add('     AddPoints();');
  Html.Add('');
  Html.Add('     var line_string = new OpenLayers.Geometry.LineString(coords);');
  Html.Add('     var bounds = new OpenLayers.Bounds();');
  Html.Add('     line_string.calculateBounds();');
  Html.Add('     bounds.extend(line_string.bounds);');
  Html.Add('     map.zoomToExtent(bounds);');
  Html.Add('     if (map.getZoom() > ZoomLevel){');
  Html.Add('       map.zoomTo(ZoomLevel);');
  Html.Add('     }');
  Html.Add('  }');

  // OpenLayers uses LonLat, not LatLon. Confusing maybe,
  Html.Add('  function AddPoint(Id, PointLat, PointLon, Href){');
  Html.Add('     var lonlat;');
  Html.Add('     lonlat = new OpenLayers.LonLat(PointLon, PointLat).transform(op, po);');
  Html.Add('     coords[Id] = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);');
  Html.Add('     points[Id] = [lonlat, Href];');
  Html.Add('');
  Html.Add('  }');

  Html.Add('  function SendMessage(msg, parm1, parm2){');
  Html.Add('     window.chrome.webview.postMessage({ msg: msg, parm1: parm1, parm2: parm2});');
  Html.Add('  }');

  Html.Add('  function CreatePopups(){');
  Html.Add('     for (let i = 0; i < points.length; i++) {');
  Html.Add('       var popup = new OpenLayers.Popup.FramedCloud("Popup", points[i][0], null, points[i][1], null, true);');
  Html.Add('       map.addPopup(popup);');
  Html.Add('     }');
  Html.Add('  }');
end;

procedure TOSMHelper.WritePointsStart;
begin
  Html.Add('  function AddPoints(){');
end;

procedure TOSMHelper.WritePoint(const ALat, ALon, AImg: string);
var
  Key: string;
begin
  Key := Format('%s,%s', [ALat, ALon]);
  if (not PlacesDict.ContainsKey(Key)) then
    PlacesDict.Add(Key, TStringList.Create);
  PlacesDict.Items[Key].Add(AImg);
end;

procedure TOSMHelper.WritePointsEnd;
var
  Place: TPair<string, TStringList>;
  PointCnt: integer;
  ImgName, Href: string;
begin
  PointCnt := 0;
  for Place in PlacesDict do
  begin
    Href := '';
    for ImgName in Place.Value do
      Href := Href + '<a href="file://' + StringReplace(ImgName, '\', '/', [rfReplaceAll]) + '">' + ExtractFileName(ImgName) + '</a><br>';
    Html.Add(Format('     AddPoint(%d, %s, ''%s'');', [PointCnt, Place.Key, Href]));
    inc(PointCnt);
  end;
  Html.Add('  }');
  Html.Add('');
end;

procedure TOSMHelper.WriteFooter;
begin
  Html.Add('</script>');
  Html.Add('</head>');
  Html.Add('<body onload="initialize()" >');
  Html.Add('  <div id="map_canvas" style="width: 100%; height: 100%"></div>');
  Html.Add('</body>');
  Html.Add('</html>');

  Html.SaveToFile(FPathName);
end;

// ==============================================================================
procedure OsmMapInit(Browser: TEdgeBrowser;
                     const Lat, Lon, Desc, InitialZoom: string);
var
  OsmHelper: TOSMHelper;
begin
  OsmHelper := TOSMHelper.Create(GetHtmlTmp, InitialZoom);
  try
    OsmHelper.WriteHeader;
    OsmHelper.WritePointsStart;
    OsmHelper.WritePoint(Lat, Lon, Desc);
    OsmHelper.WritePointsEnd;
    OsmHelper.WriteFooter;
  finally
    OsmHelper.Free;
  end;
  Browser.Navigate(GetHtmlTmp);
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
  ETout, Lat, LatRef, Lon, LonRef, Filename: string;
begin
  OsmHelper := TOSMHelper.Create(GetHtmlTmp, InitialZoom_Out);
  try
    OsmHelper.WriteHeader;
    OsmHelper.WritePointsStart;
    ETout := ETOuts;

    while (ETout <> '') do
    begin
      Filename := NextField(ETout, CRLF);

      Lat := NextField(ETout, CRLF);
      LatRef := NextField(ETout, CRLF);
      if (LatRef = 'S') then
        Insert('-', Lat, 1);

      Lon := NextField(ETout, CRLF);
      LonRef := NextField(ETout, CRLF);
      if (LonRef = 'W') then
        Insert('-', Lon, 1);

      if (Lat <> '-') and (Lon <> '-') then
        OsmHelper.WritePoint(Lat, Lon, IncludeTrailingBackslash(Apath) + Filename);
    end;

    OsmHelper.WritePointsEnd;
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

procedure FillCountry_OverPass(AJSONElements: TJSONArray; FromElement: integer; APlace: TPLace);
var
  JSONElement:  TJSONValue;
  JSONTags:     TJSONObject;
  ElementIndx:  integer;
  ElementType:  string;
begin
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

    if (JSONTags.FindValue('default_language') <> nil) then
      APlace.DefLang := JSONTags.GetValue<string>('default_language');
    if (JSONTags.FindValue('ISO3166-1:alpha2') <> nil) then
      APlace.CountryCode := JSONTags.GetValue<string>('ISO3166-1:alpha2');
    break;
  end;
end;

function GetPlaceOfCoords_OverPass(const Lat, Lon: string): TPlace;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;

  JSONObject     : TJSONObject;
  JSONElements   : TJSONArray;
  JSONElement    : TJSONValue;
  JSONTags       : TJSONObject;
  JSONTagVal     : TJSONValue;
  JSOnAdmin      : integer;
  Data           : string;
begin
  Throttle(GeoSettings.ThrottleOverPass);

  result := TPlace.Create;

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
    RESTRequest.Execute;

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

      result.AssignFromOverPass(JSOnAdmin, JSONTagVal.Value);
    end;
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
    RESTRequest.Execute;

    JSONObject := TJSonObject.ParseJSONValue(RESTResponse.Content) as TJSONObject;
    try
      if (JSONObject.FindValue('address') <> nil) then
      begin
        JSONAddress := JSONObject.GetValue<TJSONObject>('address');
        for JSONPair in JSONAddress do
          result.AssignFromGeocode(TPlace.UnEscape(JSONPair.JsonString.ToString),
                                   TPlace.UnEscape(JSONPair.JsonValue.ToString)
                                  );
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
    AdjustLatLon(LatP, LonP, 4);
    CoordsKey := LatP + ',' + LonP;
    if (CoordCache.ContainsKey(CoordsKey)) then
    begin
      result := CoordCache.Items[CoordsKey];
      exit;
    end;

    result := nil;
    case Provider of
      TGeoCodeProvider.gpGeoName:
        result := GetPlaceOfCoords_GeoCode(Lat, Lon);
      TGeoCodeProvider.gpOverPass:
        result := GetPlaceOfCoords_OverPass(Lat, Lon);
    end;
    if (Assigned(result)) then
      CoordCache.Add(CoordsKey, result);
  finally
    SetCursor(CrNormal);
  end;
end;

procedure ClearCoordCache;
begin
  CoordCache.Clear;
end;

procedure ChooseLocation(var Lat, Lon: string);
begin
  Lat := '';
  Lon := '';
  with FrmPlaces do
  begin
//TODO PARm
//    if (Listview1.Items.Count = 1) then
//    begin
//      Lat := Listview1.Items[0].Caption;
//      Lon := Listview1.Items[0].Subitems[0];
//      exit;
//    end;

    if (ShowModal <> IDOK) then
      exit;
    if (Listview1.Selected = nil) then
      exit;
    Lat := Listview1.Selected.Caption;
    Lon := Listview1.Selected.Subitems[0];
  end;
end;

procedure GetCoordsOfPlace_OverPass(const Place, Bounds: string; var Lat, Lon: string);
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  City, Country: string;

  JSONObject     : TJSONObject;
  JSONElements   : TJSONArray;
  JSONElement    : TJSONValue;
  JSOnAdmin      : integer;
  ElementIndx    : integer;
  SearchName     : string;
  SearchOp       : string;
  SearchStart    : string;
  SearchEnd      : string;
  SearchCase     : string;
  FormatNL       : string;
  JSOnName       : string;
  Data           : string;
  ElementType    : string;
  JSONNodeVal    : TJSONObject;
  PlaceResult    : TPlace;
begin
  if (Length(Trim(Place)) < 5) and
     (Bounds = '') then
    exit;

  Throttle(GeoSettings.ThrottleOverPass);
  Lat := '';
  Lon := '';

  Country := Place;
  City := Trim(NextField(Country, ','));
  if (City = '') then
    exit;

  City := StringReplace(Trim(City), '&', '', [rfReplaceAll]);
  Country := StringReplace(Trim(Country), '&', '', [rfReplaceAll]);

  FormatNL    := '';
  SearchOp    := '=';
  SearchStart := '';
  SearchEnd   := '';
  SearchCase  := '';

  if (GeoSettings.OverPassCaseSensitive = false) then
  begin
    SearchOp    := '~';
    SearchCase  := ',i';
  end;
  if (GeoSettings.OverPassCompleteWord = false) then
    SearchOp    := '~';

  if (SearchOp <> '=') and
     (GeoSettings.OverPassCompleteWord = true) then
  begin
    SearchStart := '^';
    SearchEnd   := '$';
  end;
  SearchName := Format('name%s"%s%s%s"%s', [SearchOp, SearchStart, City, SearchEnd, SearchCase]);

  Data := Format('[out:json][timeout:25];%s',
                  [FormatNL]);
  if (Country = '') then
    // Query within bounds
    Data := Data +
            Format('node[%s][place~"^(village|city|town)$"](%s);%s',
                   [SearchName, Bounds, FormatNL])
  else
  begin
// Does NOT work
//    Data := Data +
//            Format('{{geocodeArea:"%s"}}->.searchArea;%',
//            [Country, FormatNL]);

    Data := Data +
    // Query for country case and language insensitive
            	Format('rel[~"^name"~"^%s", i][boundary=administrative][admin_level~"2|4"];map_to_area->.searchArea;%s',
                     [Country, FormatNL]);
    Data := Data +
            Format('(%s' +
                   'node[%s][place~"city|town|village|hamlet"](area.searchArea);%s' +
                   ');%s',
                   [FormatNL, SearchName, FormatNL, FormatNL]);
  end;
  Data := Data +
    Format('foreach%s{%s out qt;%s' +
           'is_in; area._[name][boundary=administrative][admin_level];%s' +
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
    RESTRequest.Execute;
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
        JSonName := JSONNodeVal.GetValue<string>('name');
        JSOnAdmin := JSONNodeVal.GetValue<integer>('admin_level');

        PlaceResult.AssignFromOverPass(JSOnAdmin, JSOnName);

        continue;
      end;
    end;

    ChooseLocation(Lat, Lon);

  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
    PlaceResult.Free;
  end;
end;

procedure GetCoordsOfPlace_GeoCode(const Place: string; var Lat, Lon: string);
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  JValue: TJSONValue;
  Places: TJSONArray;
  City, Country: string;
begin
  if (Length(Trim(Place)) < 5) then
    exit;

  Throttle(GeoSettings.ThrottleGeoCode);

  Lat := '';
  Lon := '';

  Country := Place;
  City := Trim(NextField(Country, ','));
  if (City = '') then
    exit;

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

    RESTRequest.Execute;
    FrmPlaces.Listview1.Items.Clear;

    Places := RESTResponse.JSONValue as TJSONArray;
    for JValue in Places do
      FrmPlaces.AddPlace2LV(JValue.GetValue<string>('display_name'), JValue.GetValue<string>('lat'), JValue.GetValue<string>('lon'));
    ChooseLocation(Lat, Lon);
  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
  end;
end;

procedure GetCoordsOfPlace(const Place, Bounds: string; var Lat, Lon: string; const Provider: TGeoCodeProvider);
var
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    case Provider of
      TGeoCodeProvider.gpGeoName:
        GetCoordsOfPlace_GeoCode(Place, Lat, Lon);
      TGeoCodeProvider.gpOverPass:
        GetCoordsOfPlace_OverPass(Place, Bounds, Lat, Lon);
    end;
  finally
    SetCursor(CrNormal);
  end;
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
    GetCoordsOfPLace(Place, Bounds, Lat, Lon, GeoSettings.GetCoordProvider);
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

  GeoSettings.GeoCodeUrl := GUIini.ReadString(Geo_Settings, 'GeoCodeUrl', 'https://geocode.maps.co');
  GeoSettings.ThrottleGeoCode := GUIini.ReadInteger(Geo_Settings, 'ThrottleGeoCode', 500);

  GeoSettings.OverPassUrl := GUIini.ReadString(Geo_Settings, 'OverPassUrl', 'https://www.overpass-api.de/api');
  GeoSettings.ThrottleOverPass := GUIini.ReadInteger(Geo_Settings, 'ThrottleOverPass', 10);

  GeoSettings.OverPassCaseSensitive := GUIini.ReadBool(Geo_Settings, 'OverPassCaseSensitive', True);
  GeoSettings.OverPassCompleteWord := GUIini.ReadBool(Geo_Settings, 'OverPassCompleteWord', True);
  GeoSettings.CountryCodeLocation := GUIini.ReadBool(Geo_Settings, 'CountryCodeLocation', True);

  GUIini.ReadSectionValues(Geo_Province, GeoProvinceList);
//Default = 6,5,4,3
  if (GeoProvinceList.Count = 0) then
  begin
    GeoProvinceList.AddPair('NL','4');
    GeoProvinceList.AddPair('DE','4');
    GeoProvinceList.AddPair('PL','4');
    GeoProvinceList.AddPair('CA','4');
    GeoProvinceList.AddPair('US','4');
    GeoProvinceList.AddPair('EC','4');
    GeoProvinceList.AddPair('ZA','4');
  end;

  GUIini.ReadSectionValues(Geo_City, GeoCityList);
//default = 8,7,9,10
  if (GeoCityList.Count = 0) then
  begin
    GeoCityList.AddPair('NL','10');
//    GeoCityList.AddPair('DE','8,7,6,9,10');
    GeoCityList.AddPair('AU','10');
    GeoCityList.AddPair('BE','9');
    GeoCityList.AddPair('FI','9');
    GeoCityList.AddPair('NO','9');
    GeoCityList.AddPair('PT','9');
    GeoCityList.AddPair('SI','9');
//    GeoCityList.AddPair('SE','9,7');
    GeoCityList.AddPair('SE','9');
//    GeoCityList.AddPair('EC','6,7,8');
    GeoCityList.AddPair('EC','6');
//    GeoCityList.AddPair('ZA','6,7,8');
    GeoCityList.AddPair('ZA','6');
//    GeoCityList.AddPair('SK','6,7,8');
    GeoCityList.AddPair('SK','6');
    GeoCityList.AddPair('GR','7');
    GeoCityList.AddPair('GB','10');
  end;
end;

procedure WriteGeoCodeSettings(GUIini: TMemIniFile);
var
  TmpItems: TStringList;
begin
  GUIini.WriteString(Geo_Settings, 'GeoCodeUrl', GeoSettings.GeoCodeUrl);
  GUIini.WriteString(Geo_Settings, 'OverPassUrl', GeoSettings.OverPassUrl);

  GUIini.WriteInteger(Geo_Settings, 'GetCoordProvider', Ord(GeoSettings.GetCoordProvider));
  GUIini.WriteInteger(Geo_Settings, 'ThrottleGeoCode', GeoSettings.ThrottleGeoCode);
  GUIini.WriteInteger(Geo_Settings, 'GetPlaceProvider', Ord(GeoSettings.GetPlaceProvider));
  GUIini.WriteInteger(Geo_Settings, 'ThrottleOverPass', GeoSettings.ThrottleOverPass);
  GUIini.WriteBool(Geo_Settings, 'OverPassCaseSensitive', GeoSettings.OverPassCaseSensitive);
  GUIini.WriteBool(Geo_Settings, 'OverPassCompleteWord', GeoSettings.OverPassCompleteWord);
  GUIini.WriteBool(Geo_Settings, 'CountryCodeLocation', GeoSettings.CountryCodeLocation);

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
end;

end.
