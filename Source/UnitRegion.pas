unit UnitRegion;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TRegionRect = record
    W,H,Y,X: double;
  end;

  TRegion = class(TObject)
  private
    FRegionRect: TRegionRect;
    FName: string;
    FDescription: string;
    FRegionType: string;
    FUnit: string;
  public
    constructor Create(ARegionRect: TRegionRect; AUnit, AName, ADescription, ARegionType: string);
    property RegionRect: TRegionRect read FRegionRect write FRegionRect;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property RegionType: string read FRegionType write FRegionType;
    property RegionUnit: string read FUnit write FUnit;
  end;
  TRegionList = TList<TRegion>;

  TRegions = class(TObject)
  private
    FItems: TRegionList;
    FDimW: integer;
    FDimH: integer;
    FUnits: string;
  public
    constructor Create(ADimW, ADimH: integer; AUnits: string);
    destructor Destroy; override;
    procedure Clear;
    function Add(ARegion: TRegion): TRegion;
    class function LoadFromFile(AFile: string): TRegions;
    procedure SaveToFile(AFile: string);
    property Items: TRegionList read FItems;
  end;

implementation

uses
  System.SysUtils,
  ExifTool, ExifToolsGUI_Utils;

const ListSep = #255; // Dont want a separator char that can be in a string. Like *, or :, #255 is unlikely

constructor TRegion.Create(ARegionRect: TRegionRect; AUnit, AName, ADescription, ARegionType: string);
begin
  inherited Create;

  FRegionRect := ARegionRect;
  FUnit := AUnit;
  FName := AName;
  FDescription := ADescription;
  FRegionType := ARegionType;
end;

constructor TRegions.Create(ADimW, ADimH: integer; AUnits: string);
begin
  inherited Create;

  FDimW := ADimW;
  FDimH := ADimH;
  FUnits := AUnits;
  FItems := TRegionList.Create;
end;

destructor TRegions.Destroy;
begin
  Clear;
  FItems.Free;

  inherited Destroy;
end;

procedure TRegions.Clear;
var
  ARegion: TRegion;
begin
  if (Assigned(Items)) then
  begin
    for ARegion in Items do
      ARegion.Free;

    Items.Clear;
  end;
end;

function TRegions.Add(ARegion: TRegion): TRegion;
begin
  Items.Add(ARegion);
  result := ARegion;
end;

class function TRegions.LoadFromFile(AFile: string): TRegions;
var
  ETcmd: string;
  ETOuts: TStringList;
  SavedSep: string;
  AName, ADescription, ARegionType, AUnit: string;
  ARegion: TRegionRect;

  function NextItem(AList: TStringList; Index: integer): string;
  var
    Tmp: string;
  begin
    Tmp := AList[Index];
    result := NextField(Tmp, ListSep);
    if (result = '') then
      result := '-';
    Alist[Index] := Tmp;
  end;

begin
  result := nil;
  ETOuts := TStringList.Create;
  SavedSep := ET.Options.GetSeparatorChar;
  try
    ET.Options.SetSeparator(ListSep);
    ETCmd := '-f' + CRLF + '-s3' + CRLF +
             '-RegionAppliedToDimensionsW' + CRLF +
             '-RegionAppliedToDimensionsH' + CRLF +
             '-RegionAppliedToDimensionsUnit' + CRLF +
             '-RegionName' + CRLF +
             '-RegionDescription' + CRLF +
             '-RegionType' + CRLF +
             '-RegionAreaUnit' + CRLF +
             '-RegionAreaW' + CRLF +
             '-RegionAreaH' + CRLF +
             '-RegionAreaX' + CRLF +
             '-RegionAreaY';
    if (not ET.OpenExec(ETcmd, AFile, ETouts, false)) then
      exit;
    if (Etouts.Count < 11) then
      exit;

    result := TRegions.Create(StrToIntDef(ETOuts[0], 0),
                              StrToIntDef(ETOuts[1], 0),
                              ETOuts[2]);

    while (ETouts[3] <> '') do // Name is mandatory. For us.
    begin
      AName         := NextItem(ETOuts, 3);
      ADescription  := NextItem(ETOuts, 4);
      ARegionType   := NextItem(ETOuts, 5);
      AUnit         := NextItem(ETOuts, 6);
      ARegion.W     := StrToFloatDef(NextItem(ETOuts,  7), 0, ExifToolsGUI_Utils.FloatFormatSettings);
      ARegion.H     := StrToFloatDef(NextItem(ETOuts,  8), 0, ExifToolsGUI_Utils.FloatFormatSettings);
      ARegion.X     := StrToFloatDef(NextItem(ETOuts,  9), 0, ExifToolsGUI_Utils.FloatFormatSettings);
      ARegion.Y     := StrToFloatDef(NextItem(ETOuts, 10), 0, ExifToolsGUI_Utils.FloatFormatSettings);
      result.Add(TRegion.Create(ARegion, AUnit, AName, ADescription, ARegionType));
    end;

  finally
    ET.Options.SetSeparator(SavedSep);
    ETOuts.Free;
  end;
end;

procedure TRegions.SaveToFile(AFile: string);
var
  ETcmd: string;
  Region: TRegion;
  SavedSep: string;

  AName, ADescription, ARegionType, AUnit: string;
  ARegionW, ARegionH, ARegionX, ARegionY: string;
  Sep: string;
  Index: integer;
begin
  SavedSep := ET.Options.GetSeparatorChar;
  try
    ET.Options.SetSeparator(ListSep);
    AName := '-RegionName=';
    ADescription := '-RegionDescription=';
    ARegionType := '-RegionType=';
    AUnit := '-RegionAreaUnit=';
    ARegionW := '-RegionAreaW=';
    ARegionH := '-RegionAreaH=';
    ARegionX := '-RegionAreaX=';
    ARegionY := '-RegionAreaY=';

    Sep := ListSep;
    for Index := 0 to Items.Count -1 do
    begin
      Region := Items[Index];
      if (Index = Items.Count -1) then
        Sep := '';

      AName         := AName + Region.Name + Sep;
      ADescription  := ADescription + Region.Description + Sep;
      ARegionType   := ARegionType + Region.RegionType + Sep;
      AUnit         := AUnit + Region.RegionUnit + Sep;
      ARegionW      := ARegionW + FloatToStr(Region.RegionRect.W, ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
      ARegionH      := ARegionH + FloatToStr(Region.RegionRect.H, ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
      ARegionX      := ARegionX + FloatToStr(Region.RegionRect.X, ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
      ARegionY      := ARegionY + FloatToStr(Region.RegionRect.Y, ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
    end;

    ETCmd :=
             '-RegionAppliedToDimensionsW='     + IntToStr(FDimW) + CRLF +
             '-RegionAppliedToDimensionsH='     + IntToStr(FDimH) + CRLF +
             '-RegionAppliedToDimensionsUnit='  + FUnits + CRLF +
             AName + CRLF +
             ADescription + CRLF +
             ARegionType + CRLF +
             AUnit + CRLF +
             ARegionW + CRLF +
             ARegionH + CRLF +
             ARegionX + CRLF +
             ARegionY + CRLF;

    ET.OpenExec(ETcmd, AFile);

  finally
    ET.Options.SetSeparator(SavedSep);
  end;
end;

end.
