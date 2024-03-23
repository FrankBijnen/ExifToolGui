unit ExifToolsGui_Data;

// Note. The resources created here will show up in Better translation manager,
//       But translation will not succeed, because ReadResourceId does not use the language DLL's.
//       This is by intention!

interface

const
  ETD_Latest_Gui    = 0;
  ETD_Latest_PH     = 1;
  ETD_Latest_OBetz  = 2;

  ETD_Credits_GUI   = 5;
  ETD_Credits_ET    = 6;
  ETD_GNUGPL        = 7;

  ETD_Home_Gui      = 10;
  ETD_Home_PH       = 11;
  ETD_Home_OBetz    = 12;

  ETD_Online_Doc    = 20;
  ETD_Edge_Dll      = 21;
  ETD_Edge_Runtime  = 22;
  ETD_Reqs          = 23;

  ETD_GeoCode       = 30;
  ETD_OverPass      = 31;

function ReadResourceId(const Id: integer): string;

implementation

uses Winapi.Windows;


function ReadResourceId(const Id: integer): string;
var
 Buffer: array [0..4096] of char;
 Len: integer;
begin
 result:= '';
 Len := LoadString(HInstance, Id, Buffer, SizeOf(Buffer));
 if Len <> 0 then
   result:= Buffer;
end;

end.
