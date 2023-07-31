unit Geomap;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses Vcl.Edge, System.Classes, System.SysUtils, System.Generics.Collections;

procedure OsmMapInit(Browser: TEdgeBrowser; const Lat, Lon, Desc: string); overload;
procedure OsmMapInit(Browser: TEdgeBrowser; const LatLon, Desc: string); overload;
procedure ShowImagesOnMap(Browser: TEdgeBrowser; Apath, ETOuts: string);
procedure MapGetLocation(Browser: TEdgeBrowser);
function MapGoToPlace(Browser: TEdgeBrowser; Place, Desc: string): string;
procedure ParseJsonMessage(const Message: string; var Msg, Parm1, Parm2: string);
function ValidLatLon(const Lat, Lon: string): boolean;
procedure ParseLatLon(const LatLon: string; var Lat, Lon: string);
procedure AdjustLatLon(var Lat, Lon: string);

const Coord_Decimals = 5;

type

  TOSMHelper = class(TObject)

  private
    OsmFormatSettings: TFormatSettings;
    Html : TStringList;
    FPathName : string;
    PlacesDict : TObjectDictionary<String, TStringList>;
    procedure WriteHeader;
    procedure WritePointsStart;
    procedure WritePoint(const ALat, ALon, AImg: string);
    procedure WritePointsEnd;
    procedure WriteFooter;

  public
    constructor Create(const APathName: string);
    destructor Destroy; override;
  end;


implementation

uses MainDef, UFrmPlaces, ExifToolsGUI_Utils, System.Variants, Winapi.Windows, ExifTool, System.JSON,
     REST.Types, REST.Client, System.NetEncoding;

var CoordFormatSettings: TFormatSettings; // for StrToFloatDef -see Initialization

constructor TOSMHelper.Create(const APathName: string);
begin
  inherited Create;
  OsmFormatSettings := TFormatSettings.Create(GetThreadLocale);
  OsmFormatSettings.DecimalSeparator := '.'; // The decimal separator is a . PERIOD!
  OsmFormatSettings.NegCurrFormat := 11;
  FPathName := APathName;
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
  Html.Add('              SendMessage("Location", lonlat.lat, lonlat.lon);');
  Html.Add('            }');
  Html.Add('        }');
  Html.Add('     });');

  Html.Add('');
  Html.Add('     CreateExtent();');
  Html.Add('     CreatePopups();');
  Html.Add('  }');
  Html.Add('') ;

  Html.Add(' function GetLocation(){');
  Html.Add('     var bounds = map.getExtent();');
  Html.Add('     var lonlat = bounds.getCenterLonLat().transform(po, op);');
  Html.Add('     SendMessage("Location", lonlat.lat, lonlat.lon);');
  Html.Add('  }');

  Html.Add(' function CreateExtent(){');
  Html.Add('');
  Html.Add('    coords = new Array();');
  Html.Add('    points = new Array();');
  Html.Add('');
  Html.Add('    AddPoints();');
  Html.Add('');
  Html.Add('    var line_string = new OpenLayers.Geometry.LineString(coords);');
  Html.Add('    var bounds = new OpenLayers.Bounds();');
  Html.Add('    line_string.calculateBounds();');
  Html.Add('    bounds.extend(line_string.bounds);');
  Html.Add('    map.zoomToExtent(bounds);');
  Html.Add('  }');

//  OpenLayers uses LonLat, not LatLon. Confusing maybe,
  Html.Add('  function AddPoint(Id, PointLat, PointLon, Href){');
  Html.Add('    var lonlat;');
  Html.Add('    lonlat = new OpenLayers.LonLat(PointLon, PointLat).transform(op, po);');
  Html.Add('    coords[Id] = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);');
  Html.Add('    points[Id] = [lonlat, Href];');
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
var Key: string;
begin
  Key := Format('%s,%s', [ALat, ALon]);
  if (not PlacesDict.ContainsKey(Key)) then
    PlacesDict.Add(Key, TStringList.Create);
  PlacesDict.Items[Key].Add(AImg);
end;

procedure TOSMHelper.WritePointsEnd;
var Place: TPair<string, TStringList>;
    PointCnt : integer;
    ImgName, Href: string;
begin
  PointCnt := 0;
  for Place in PlacesDict do
  begin
    Href := '';
    for ImgName in Place.Value do
      Href := Href + '<a href="file://' + StringReplace(ImgName, '\', '/', [rfReplaceAll]) + '">' + ExtractFileName(ImgName) + '</a><br>';
    Html.Add(Format('   AddPoint(%d, %s, ''%s'');', [PointCnt, Place.Key, Href]));
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
procedure OsmMapInit(Browser: TEdgeBrowser; const Lat, Lon, Desc: string);
var OsmHelper: TOSMHelper;
begin
  OsmHelper := TOSMHelper.Create(GetHtmlTmp);
  try
    OsmHelper.WriteHeader;
    Osmhelper.WritePointsStart;
    OsmHelper.WritePoint(Lat, Lon, Desc);
    Osmhelper.WritePointsEnd;
    OsmHelper.WriteFooter;
  finally
    OsmHelper.Free;
  end;
  Browser.Navigate(GetHtmlTmp);
end;

procedure OsmMapInit(Browser: TEdgeBrowser; const LatLon, Desc: string);
var Lat, Lon: string;
begin
  ParseLatLon(LatLon, Lat, Lon);
  OsmMapInit(Browser, Lat, Lon, Desc);
end;
// ==============================================================================

procedure ShowImagesOnMap(Browser: TEdgeBrowser; APath, ETOuts: string);
var OsmHelper: TOSMHelper;
    ETout, Lat, LatRef, Lon, LonRef, Filename: string;
begin
  OsmHelper := TOSMHelper.Create(GetHtmlTmp);
  try
    OsmHelper.WriteHeader;
    Osmhelper.WritePointsStart;
    ETout := ETOuts;

    while (ETOut <> '' ) do
    begin
      Filename := NextField(ETOut, CRLF);

      Lat := NextField(ETOut, CRLF);
      LatRef := NextField(ETOut, CRLF);
      if (LatRef = 'S') then
        Insert('-', Lat, 1);

      Lon := NextField(ETOut, CRLF);
      LonRef := NextField(ETOut, CRLF);
      if (LonRef = 'W') then
        Insert('-', Lon, 1);

      if (Lat <> '-') and
         (Lon <> '-') then
        Osmhelper.WritePoint(Lat, Lon, IncludeTrailingBackslash(APath) + Filename);
    end;

    Osmhelper.WritePointsEnd;
    OsmHelper.WriteFooter;
  finally
    OsmHelper.Free;
  end;
  Browser.Navigate(GetHtmlTmp);
end;

procedure GetCoordsOfPLace(const Place: string; var Lat, Lon: string);
var RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    JValue: TJSONValue;
    Places: TJSONArray;
    City, Country: string;
    UrlEncode: System.NetEncoding.TURLEncoding;
begin
  Lat := '';
  Lon := '';
  if (Length(Trim(Place)) < 5) then
    exit;
  UrlEncode := System.NetEncoding.TURLEncoding.Create;
  Country := Place;
  City := Trim(NextField(Country, ','));

  City := UrlEncode.EncodeForm(Trim(City));
  Country := UrlEncode.EncodeForm(Trim(Country));

  RESTClient := TRESTClient.Create('https://geocode.maps.co');
  RESTResponse := TRESTResponse.Create(nil);
  RESTRequest := TRESTRequest.Create(nil);
  RESTRequest.Client := RESTClient;
  RESTRequest.Resource := 'search';
  RESTRequest.Response := RESTResponse;
  try
    RESTRequest.params.Clear;
    RESTRequest.params.AddItem('city', City, TRESTRequestParameterKind.pkGETorPOST);
    RESTRequest.params.AddItem('country', Country, TRESTRequestParameterKind.pkGETorPOST);
    RESTRequest.Execute;
    Places := RESTResponse.JSONValue as TJSONArray;
    if (places.Count = 1) then
    begin
      JValue := Places[0];
      Lat := JValue.GetValue<string>('lat');
      Lon := JValue.GetValue<string>('lon');
    end
    else
    with FrmPlaces do
    begin
      Listview1.Items.Clear;
      for JValue in Places do
      begin
        AddPlace2LV(JValue.GetValue<string>('display_name'),
                    JValue.GetValue<string>('lat'),
                    JValue.GetValue<string>('lon'));
      end;
      if (ShowModal <> IDOK) then
        exit;
      if (Listview1.Selected = nil) then
        exit;
      Lat := Listview1.Selected.Caption;
      Lon := Listview1.Selected.Subitems[0];
    end;
  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
    UrlEncode.Free;
  end;
end;

procedure MapGetLocation(Browser: TEdgeBrowser);
begin
  Browser.ExecuteScript('GetLocation();');
end;

function MapGoToPlace(Browser: TEdgeBrowser; Place, Desc: string): string;
var Lat, Lon: string;
begin
  result := Place;
  ParseLatLon(Place, Lat, Lon);
  if not (ValidLatLon(Lat, Lon)) then
  begin
    GetCoordsOfPLace(Place, Lat, Lon);
    if not (ValidLatLon(Lat, Lon)) then
      exit;
    AdjustLatLon(Lat, Lon);
    result := Lat + ', ' + Lon;
  end;
  OsmMapInit(Browser, Lat, Lon, Desc);
end;

procedure ParseJsonMessage(const Message: string; var Msg, Parm1, Parm2: string);
var JSonValue: TJSonValue;
begin
   JsonValue := TJSonObject.ParseJSONValue(Message);
   try
     Msg := JsonValue.GetValue<string>('msg');
     Parm1 := JsonValue.GetValue<string>('parm1');
     Parm2 := JsonValue.GetValue<string>('parm2');
   finally
     JsonValue.Free;
   end;
end;

function ValidLatLon(const Lat, Lon: string): boolean;
var ADouble: Double;
begin
  result := TryStrToFloat(Lat, ADouble, CoordFormatSettings);
  result := result and (Abs(ADouble) <= 90);
  result := result and TryStrToFloat(Lon, ADouble, CoordFormatSettings);
  result := result and (Abs(ADouble) <= 180);
end;

procedure AdjustLatLon(var Lat, Lon: string);
var P: integer;
begin
  P := Pos('.', Lat) + Coord_Decimals;
  SetLength(Lat, P);
  P := Pos('.', Lon) + Coord_Decimals;
  SetLength(Lon, P);
end;

procedure ParseLatLon(const LatLon: string; var Lat, Lon: string);
begin
  Lon := LatLon;
  Lat := Trim(NextField(Lon, ','));
  Lon := Trim(Lon);
end;

initialization
begin
  CoordFormatSettings.ThousandSeparator := ',';
  CoordFormatSettings.DecimalSeparator := '.';
end;

end.
