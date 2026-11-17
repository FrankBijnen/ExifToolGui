unit ExifToolsGui_Versions;

interface

uses
  System.Classes, System.SysUtils, System.StrUtils;

type

TETGuiProduct = (etGUI = 0, etPH = 1, etOBetz = 2);

function GetLatestVersion(ETGuiProduct: TETGuiProduct): string;
function CompareVersions(Installed, Available: string): integer;

implementation

uses
  System.JSON, System.UITypes,
  Winapi.Windows,
  REST.Types, REST.Client, REST.Utils,
  ExifToolsGui_Utils, ExifToolsGui_ResourceStrings, UnitLangResources;

function ExecuteRest(const RESTRequest: TRESTRequest): boolean; overload;
begin
  result := true;
  RESTRequest.Execute;
  if (RESTRequest.Response.StatusCode >= 400) then
    raise exception.Create(StrRequestFailedWith + #10 + RESTRequest.Response.StatusText);
end;

function ExecuteRest(const ETGuiProduct: TETGuiProduct; URL: string): string; overload;
var
  RESTClient      : TRESTClient;
  RESTRequest     : TRESTRequest;
  RESTResponse    : TRESTResponse;
  JSONObject      : TJSONObject;
begin
  result := '';

  RESTClient := TRESTClient.Create(URL);
  RESTResponse := TRESTResponse.Create(nil);
  RESTRequest := TRESTRequest.Create(nil);
  RESTRequest.Client := RESTClient;
  RESTRequest.Response := RESTResponse;
  try
    try
      if not ExecuteRest(RESTRequest) then
        exit;

      case (ETGuiProduct) of
        TETGuiProduct.etGUI:
          begin
            JSONObject := RESTResponse.JSONValue as TJSONObject;
            result := JSONObject.GetValue('tag_name').Value;
            // Interesting. Future use?
            //writeln(JSONObject.GetValue('html_url').Value);
            //writeln(JSONObject.GetValue('created_at').Value);
          end;
        else
        begin
          result := Trim(RESTResponse.Content);
        end;

      end;
    finally
      RESTResponse.Free;
      RESTRequest.Free;
      RESTClient.Free;
    end;
  except
    on E:Exception do
    begin
      MessageDlgEx(E.Message, '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
      result := 'NOK';
    end;
  end;
end;

function GetLatestVersion(ETGuiProduct: TETGuiProduct): string;
var
  URL: string;
begin
  result := '';
  case (ETGuiProduct) of
    TETGuiProduct.etGUI:
      URL := StringResource(ETD_Latest_Gui);
    TETGuiProduct.etPH:
      URL := StringResource(ETD_Latest_PH);
    TETGuiProduct.etOBetz:
      URL := StringResource(ETD_Latest_OBetz);
  end;
  result := ExecuteRest(ETGuiProduct, URL);
end;

procedure ParseVersion(const Version: string;
                       out Major: integer;
                       out Minor: integer;
                       out SubMinor: integer);
var
  MajorVer, MinorVer, SubMinorVer: string;
  P: integer;
begin
//For ET this is XX.YY
//For GUI this VX.Y.ZZ.s (ss can be '0', '1 Pre')
  SubMinorVer := Version;
  MajorVer := NextField(SubMinorVer, '.');
  MajorVer := ReplaceAll(MajorVer, ['V'], ['']);

  MinorVer := NextField(SubMinorVer, '.');

  P := Pos('.', SubMinorVer);
  if (P > 0) then
    SubMinorVer := LeftStr(SubMinorVer, P -1);

  Major := StrToIntDef(MajorVer, 0);
  Minor := StrToIntDef(MinorVer, 0);
  SubMinor := StrToIntDef(SubMinorVer, 0);
end;

// Returns the ImageIndex. 0=NOK or 1=OK
function CompareVersions(Installed, Available: string): integer;
var
  MajorInstalled, MinorInstalled, SubMinorInstalled: integer;
  MajorAvailable, MinorAvailable, SubMinorAvailable: integer;
begin
  ParseVersion(Installed, MajorInstalled, MinorInstalled, SubMinorInstalled);
  ParseVersion(Available, MajorAvailable, MinorAvailable, SubMinorAvailable);

  // No version available?
  if (MajorAvailable = 0) and
     (MinorAvailable = 0) and
     (SubMinorAvailable = 0) then
    exit(0);

  if (MajorInstalled < MajorAvailable) then
    exit(0)
  else if (MajorInstalled > MajorAvailable) then
    exit(1);

  if (MinorInstalled < MinorAvailable) then
    exit(0)
  else if (MinorInstalled > MinorAvailable) then
    exit(1);

  if (SubMinorInstalled < SubMinorAvailable) then
    exit(0)
  else if (SubMinorInstalled > SubMinorAvailable) then
    exit(1);

  // All OK
  result := 1;
end;

end.
