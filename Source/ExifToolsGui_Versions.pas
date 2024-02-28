unit ExifToolsGui_Versions;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.Classes, System.SysUtils;

type

TETGuiProduct = (etGUI = 0, etPH = 1, etOBetz = 2);

function GetLatestVersion(ETGuiProduct: TETGuiProduct): string;

implementation

uses
  System.JSON,
  Winapi.Windows,
  REST.Types, REST.Client, REST.Utils,
  ExifToolsGui_Utils, ExifToolsGui_Data, UnitLangResources;

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
    if not ExecuteRest(RESTRequest) then
      exit;

    case (ETGuiProduct) of
      TETGuiProduct.etGUI:
        begin
          JSONObject := RESTResponse.JSONValue as TJSONObject;
          //writeln(JSONObject.GetValue('html_url').Value);
          result := JSONObject.GetValue('tag_name').Value;
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
end;

function GetLatestVersion(ETGuiProduct: TETGuiProduct): string;
var
  URL: string;
begin
  result := '';
  case (ETGuiProduct) of
    TETGuiProduct.etGUI:
      URL := ReadResourceId(ETD_Latest_Gui);
    TETGuiProduct.etPH:
      URL := ReadResourceId(ETD_Latest_PH);
    TETGuiProduct.etOBetz:
      URL := ReadResourceId(ETD_Latest_OBetz);
  end;
  result := ExecuteRest(ETGuiProduct, URL);
end;


end.
