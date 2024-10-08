unit ExifToolsGui_Data;

// Note. The resources created here will show up in Better translation manager,
//       But translation will not succeed, because ReadResourceId does not use the language DLL's.
//       This is by intention!

interface

const
  ETD_Latest_Gui    = 10;
  ETD_Latest_PH     = 11;
  ETD_Latest_OBetz  = 12;

  ETD_Credits_GUI   = 15;
  ETD_Credits_ET    = 16;
  ETD_GNUGPL        = 17;

  ETD_Home_Gui      = 20;
  ETD_Home_PH       = 21;
  ETD_Home_OBetz    = 22;

  ETD_Online_Doc    = 30;
  ETD_Edge_Dll      = 31;
  ETD_Edge_Runtime  = 32;
  ETD_Reqs          = 33;

  ETD_GeoCode       = 40;
  ETD_OverPass      = 41;

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
