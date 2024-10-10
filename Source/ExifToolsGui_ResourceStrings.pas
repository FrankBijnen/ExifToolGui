unit ExifToolsGui_ResourceStrings;

// Note. The resources created here will show up in Better translation manager,
//       But translation will not succeed, because ReadResourceId does not use the language DLL's.
//       This is by intention!

interface

const
  ETD_ResourceStrings   = 'ETD_ResourceStrings';
  ETD_Latest_Gui        = 'ETD_Latest_Gui';
  ETD_Latest_PH         = 'ETD_Latest_PH';
  ETD_Latest_OBetz      = 'ETD_Latest_OBetz';

  ETD_Credits_GUI       = 'ETD_Credits_GUI';
  ETD_Credits_ET        = 'ETD_Credits_ET';
  ETD_GNUGPL            = 'ETD_GNUGPL';

  ETD_Home_Gui          = 'ETD_Home_Gui';
  ETD_Home_PH           = 'ETD_Home_PH';
  ETD_Home_OBetz        = 'ETD_Home_OBetz';

  ETD_Online_Doc        = 'ETD_Online_Doc';
  ETD_Edge_Dll          = 'ETD_Edge_Dll';
  ETD_Edge_Runtime      = 'ETD_Edge_Runtime';
  ETD_Reqs              = 'ETD_Reqs';

  ETD_GeoCode           = 'ETD_GeoCode';
  ETD_OverPass          = 'ETD_OverPass';

function StringResource(const Id: string): string;

implementation

uses
  System.Classes,
  Winapi.Windows,
  ExifToolsGUI_Utils;

var
  ResourceStringList: TStringList;

function StringResource(const Id: string): string;
begin
  if not Assigned(ResourceStringList) then
  begin
    ResourceStringList := TStringList.Create;
    LoadResourceList(ETD_ResourceStrings, ResourceStringList);
  end;
  result := ResourceStringList.Values[Id];
end;

initialization

finalization
begin
  ResourceStringList.Free;
end;

end.
