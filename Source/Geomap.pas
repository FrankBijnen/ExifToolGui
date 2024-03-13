unit Geomap;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.IniFiles,
  Vcl.Edge;

type
  TExecRestEvent = procedure(Url, Response: string; Succes: boolean) of object;
  TGeoCodeProvider = (gpGeoName, gpOverPass);
  TGeoTagMode = (gtmCoordinates, gtmLocation, gtmCoordinatesLocation);

  GEOsettingsRec = record
    GeoCodingEnable: boolean;
    GetCoordProvider: TGeoCodeProvider;
    GetPlaceProvider: TGeoCodeProvider;
    GeoCodeUrl: string;
    GeoCodeApiKey: string;
    ThrottleGeoCode: integer;
    OverPassUrl: string;
    OverPassCaseSensitive: boolean;
    OverPassCompleteWord: boolean;
    OverPassLang: string;
    ThrottleOverPass: integer;
    CountryCodeLocation: boolean;
    GeoTagMode: TGeoTagMode;
    GeoCodeDialog: boolean;
    ReverseGeoCodeDialog: boolean;
  end;

  TRegionLevels = array[0..3] of integer;
  TCityLevels = array[0..4] of integer;

  TPlace = class
    FCityLevels: TCityLevels;
    FRegionLevels: TRegionLevels;
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
    procedure Sort;
    property CountryCode: string read FCountryCode write SetCountryCode;
    property CountryLocation: string read GetCountryLocation;
    property DefLang: string read FDefLang write FDefLang;
    property PostCode: string read FPostCode write FPostCode;
    property Name: string read FName write FName;
    property PrioProvince: string read GetPrioProvince;
    property Province: string read GetProvince;
    property PrioCity: string read GetPrioCity;
    property City: string read GetCity;
    property SearchReault: string read GetSearchResult;
    property HtmlSearchReault: string read GetHtmlSearchResult;
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
    OsmFormatSettings: TFormatSettings;
    Html: TStringList;
    FInitialZoom: string;
    FPathName: string;
    PlacesDict: TObjectDictionary<String, TStringList>;
    procedure WriteHeader;
    procedure WritePointsStart;
    procedure WritePoint(const ALat, ALon, AImg: string; Link: boolean);
    procedure WritePointsEnd(const GetPlace: boolean);
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

// Sort on stringlist with possibly integer in key.
function SortOnKey(List: TStringList; Index1, Index2: Integer): Integer;
var
  L1, l2: integer;
begin
  result := 0;
  if (TryStrToInt(List.KeyNames[Index1], L1)) and
     (TryStrToInt(List.KeyNames[Index2], L2)) then
  begin // Compare integers
    if (L1 < L2) then
      result := -1
    else if (L1 > L2) then
      result := 1;
  end
  else
  begin // Compare strings
    if (List.KeyNames[Index1] < List.KeyNames[Index2]) then
      result := -1
    else if (List.KeyNames[Index1] > List.KeyNames[Index2]) then
      result := 1;
  end;
end;

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
var
  Level: integer;
  LevelX: string;
begin
  if (GeoProvinceList.Values[FCountryCode] = 'None') then
    exit('');

  result := GetPrioProvince;

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
var GeoPrio: string;
begin
  result := '';
  GeoPrio := GeoCityList.Values[FCountryCode];
  if (FCityList.Values[GeoPrio] <> '') then
    result := FCityList.Values[GeoPrio];
end;

function TPlace.GetCity: string;
var
  Level: integer;
  LevelX: string;
begin
  if (GeoCityList.Values[FCountryCode] = 'None') then
    exit('');

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
  result := result + Format('Name: %s, City: %s, Province: %s, Country: %s, %s', [Name, City, Province, FCountryCode, FCountry]);
end;

function TPlace.GetHtmlSearchResult: string;
begin
  result := Format('<a>%s<br>%s %s</a>', [City, Province, FCountryCode]);
  result := StringReplace(result, ' ', '&nbsp', [rfReplaceAll]);
  result := StringReplace(result, '-', '&#8209;', [rfReplaceAll]);
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
var
  Level: integer;
begin
  if (Key = 0) then
    FNodeId := Value;
  if (Key = 2) then
    FCountry := Value;
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

procedure TPLace.Sort;
begin
  FCityList.CustomSort(SortOnKey) ;
  FProvinceList.CustomSort(SortOnKey) ;
end;

function TPLace.GetRegionLevels: TRegionLevels;
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

function TPLace.GetCityLevels: TCityLevels;
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
//TODO Create resources
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
  Html.Add('     SendMessage(Func, bounds.toBBOX(' + IntToStr(Place_Decimals) + ', true), lonlat.lat + ", " + lonlat.lon);');
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
        Href := Href + '<a href="file://' + StringReplace(ImgName, '\', '/', [rfReplaceAll]) + '">' +
                        ExtractFileName(ImgName) + '</a><br>'
      else if (GetPlace = false) then
        Href := Href + '<a>' + ImgName + '</a><br>';
    end;

    if (GetPlace) then
    begin
      ParseLatLon(Place.Key, Lat, Lon);
      PlaceLoc := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);
      if (Assigned(PlaceLoc)) then
        Href := Href + PlaceLoc.HtmlSearchReault;
    end;

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
    OsmHelper.WritePoint(Lat, Lon, Desc, false);
    OsmHelper.WritePointsEnd((GeoSettings.GeoCodingEnable) and (Desc <> OSMHome));
    OsmHelper.WriteFooter;
  finally
    OsmHelper.Free;
  end;
  Browser.Navigate(GetHtmlTmp);
end;

function ExecuteRest(const RESTRequest: TRESTRequest): boolean;
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
          GeoSettings.GeoCodingEnable := false;
      end;
    end;
  finally
    if Assigned(ExecRestEvent) then
      ExecRestEvent(RESTRequest.GetFullRequestURL(true) + #10, RESTRequest.Response.Content, result);
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
  ETout, Lat, Lon, Filename: string;
  IsQuickTime: boolean;
begin
  OsmHelper := TOSMHelper.Create(GetHtmlTmp, InitialZoom_Out);
  try
    OsmHelper.WriteHeader;
    OsmHelper.WritePointsStart;
    ETout := ETOuts;

    while (ETout <> '') do
    begin
      FileName := AnalyzeGPSCoords(ETOut, Lat, Lon, IsQuickTime);
      if (Lat <> '-') and (Lon <> '-') then
        OsmHelper.WritePoint(Lat, Lon, IncludeTrailingBackslash(Apath) + Filename, true);
    end;

    OsmHelper.WritePointsEnd(true);
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
  if (GeoSettings.OverPassLang <> 'default') and
     (GeoSettings.OverPassLang <> 'local') then
    APlace.DefLang := GeoSettings.OverPassLang;
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

    if (GeoSettings.OverPassLang = 'local') and
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
    if (GeoSettings.GeoCodingEnable = false) then
      exit;

    case Provider of
      TGeoCodeProvider.gpGeoName:
        result := GetPlaceOfCoords_GeoCode(Lat, Lon);
      TGeoCodeProvider.gpOverPass:
        result := GetPlaceOfCoords_OverPass(Lat, Lon);
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

procedure ChooseLocation(var Lat, Lon: string);
begin
  Lat := '';
  Lon := '';
  with FrmPlaces do
  begin
    if (ShowModal <> IDOK) then
      exit;
    if (Listview1.Selected = nil) then
      exit;
    Lat := Listview1.Selected.Caption;
    Lon := Listview1.Selected.Subitems[0];
  end;
end;

procedure GetCoordsOfPlace_OverPass(const City, Country, Bounds: string; var Lat, Lon: string);
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
  if (Length(Trim(City)) < 5) and
     (Country = '') and
     (Bounds = '') then
    exit;

  Throttle(GeoSettings.ThrottleOverPass);

  Lat         := '';
  Lon         := '';
  FormatNL    := '';
  SearchBounds:= '';
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
  SearchName := Format('name%s"%s%s%s"%s',
                  [SearchOp, SearchStart,
                   StringReplace(Trim(City), '&', '', [rfReplaceAll]),
                   SearchEnd, SearchCase]);

  Data := Format('[out:json][timeout:25];%s',
                  [FormatNL]);

  if (Country = '') then
  begin   // Query within selected bounds
    if (Bounds <> '') then
      SearchBounds := Format('(%s);', [Bounds]);

    Data := Data +
            Format('node[%s][place~"^(village|city|town)$"]%s%s',
                     [SearchName, SearchBounds, FormatNL]);

  end
  else
  begin   // Query within country/region case and language insensitive
    Data := Data +
            	Format('rel[~"^name"~"^%s", i][boundary=administrative][admin_level~"2|4"];map_to_area->.searchArea;%s',
                       [StringReplace(Trim(Country), '&', '', [rfReplaceAll]),
                        FormatNL]);
    Data := Data +
            Format('(%s' +
                   'node[%s][place~"city|town|village|hamlet"](area.searchArea);%s' +
                   ');%s',
                     [FormatNL, SearchName, FormatNL, FormatNL]);
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
    ChooseLocation(Lat, Lon);

  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
    PlaceResult.Free;
  end;
end;

procedure GetCoordsOfPlace_GeoCode(const City, Country: string; var Lat, Lon: string);
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  JValue: TJSONValue;
  Places: TJSONArray;
begin
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
    ChooseLocation(Lat, Lon);
  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
  end;
end;

procedure GetCoordsOfPlace(const Place, Bounds: string; var Lat, Lon: string);
var
  CrWait, CrNormal: HCURSOR;
  Region: string;
begin
  if (GeoSettings.GeoCodingEnable = false) then
    exit;

  Region := Place;
  FGeoSearch.EdSearchCity.Text := Trim(NextField(Region, ','));
  if (FGeoSearch.EdSearchCity.Text = '') then
    exit;
  FGeoSearch.EdRegion.Text := Trim(Region);
  FGeoSearch.EdBounds.Text := Bounds;

  if (GeoSettings.GeoCodeDialog) then
  begin
    if (FGeoSearch.ShowModal <> IDOK) then
      exit;
  end;

  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    case GeoSettings.GetCoordProvider  of
      TGeoCodeProvider.gpGeoName:
        GetCoordsOfPlace_GeoCode(FGeoSearch.EdSearchCity.Text, FGeoSearch.EdRegion.Text, Lat, Lon);
      TGeoCodeProvider.gpOverPass:
        GetCoordsOfPlace_OverPass(FGeoSearch.EdSearchCity.Text, FGeoSearch.EdRegion.Text, FGeoSearch.EdBounds.Text, Lat, Lon);
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
  GeoSettings.OverPassCaseSensitive := GUIini.ReadBool(Geo_Settings, 'OverPassCaseSensitive', True);
  GeoSettings.OverPassCompleteWord := GUIini.ReadBool(Geo_Settings, 'OverPassCompleteWord', True);
  GeoSettings.OverPassCompleteWord := GUIini.ReadBool(Geo_Settings, 'OverPassCompleteWord', True);
  GeoSettings.OverPassLang := GUIini.ReadString(Geo_Settings, 'OverPassLang', 'default');
  GeoSettings.CountryCodeLocation := GUIini.ReadBool(Geo_Settings, 'CountryCodeLocation', True);
  GeoSettings.GeoTagMode := TGeoTagMode(GUIini.ReadInteger(Geo_Settings, 'GeoTagMode', 1));
  GeoSettings.GeoCodeDialog := GUIini.ReadBool(Geo_Settings, 'GeoCodeDialog', true);
  GeoSettings.ReverseGeoCodeDialog := GUIini.ReadBool(Geo_Settings, 'ReverseGeoCodeDialog', true);
  GeoSettings.GeoCodingEnable := GUIini.ReadBool(Geo_Settings, 'GeoCodingEnable', false);

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
  GUIini.WriteBool(Geo_Settings, 'OverPassCaseSensitive', GeoSettings.OverPassCaseSensitive);
  GUIini.WriteBool(Geo_Settings, 'OverPassCompleteWord', GeoSettings.OverPassCompleteWord);
  GUIini.WriteString(Geo_Settings, 'OverPassLang', GeoSettings.OverPassLang);
  GUIini.WriteBool(Geo_Settings, 'CountryCodeLocation', GeoSettings.CountryCodeLocation);
  GUIini.WriteInteger(Geo_Settings, 'GeotagMode', Ord(GeoSettings.GeoTagMode));
  GUIini.WriteBool(Geo_Settings, 'GeoCodeDialog', GeoSettings.GeoCodeDialog);
  GUIini.WriteBool(Geo_Settings, 'ReverseGeoCodeDialog', GeoSettings.ReverseGeoCodeDialog);
  GUIini.WriteBool(Geo_Settings, 'GeoCodingEnable', GeoSettings.GeoCodingEnable);

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
