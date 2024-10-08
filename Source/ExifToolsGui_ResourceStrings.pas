unit ExifToolsGui_ResourceStrings;

// Note. The resources created here will show up in Better translation manager,
//       But translation will not succeed, because ReadResourceId does not use the language DLL's.
//       This is by intention!

interface

const
  ETD_Latest_Gui        = 101;
  ETD_Latest_PH         = 102;
  ETD_Latest_OBetz      = 103;

  ETD_Credits_GUI       = 105;
  ETD_Credits_ET        = 106;
  ETD_GNUGPL            = 107;

  ETD_Home_Gui          = 110;
  ETD_Home_PH           = 111;
  ETD_Home_OBetz        = 112;

  ETD_Online_Doc        = 120;
  ETD_Edge_Dll          = 121;
  ETD_Edge_Runtime      = 122;
  ETD_Reqs              = 123;

  ETD_GeoCode           = 130;
  ETD_OverPass          = 131;

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
