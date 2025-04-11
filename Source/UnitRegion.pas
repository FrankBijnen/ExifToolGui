unit UnitRegion;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TRegionRect = record
    W,H,Y,X: double;
    function IsEmpty: boolean;
    procedure SetCenterX(CX: Double);
    procedure SetCenterY(CY: Double);
    function GetCenterX: Double;
    function GetCenterY: Double;
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
    property RegionName: string read FName write FName;
    property RegionDescription: string read FDescription write FDescription;
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
    FLoading: boolean;
  public
    constructor Create(ADimW, AImgW, ADimH, AImgH: integer; AUnits: string);
    destructor Destroy; override;
    procedure Clear;
    function Add(ARegion: TRegion): TRegion;
    class function LoadFromFile(AFile: string): TRegions;
    procedure SaveToFile(AFile: string);
    property Items: TRegionList read FItems;
    property Loading: boolean read FLoading write FLoading;
  end;

implementation

uses
  System.SysUtils,
  ExifTool, ExifToolsGUI_Utils;

const ListSep = #255; // Dont want a separator char that can be in a string. Like *, or :, #255 is unlikely

function TRegionRect.IsEmpty: boolean;
begin
  result := (X < 0) or (Y < 0) or (W < 0) or (H < 0);
end;

procedure TRegionRect.SetCenterX(CX: Double);
begin
  X := CX - (W / 2);
end;

procedure TRegionRect.SetCenterY(CY: Double);
begin
  Y := CY - (H / 2);
end;

function TRegionRect.GetCenterX: Double;
begin
  result := X + (W / 2);
end;

function TRegionRect.GetCenterY: Double;
begin
  result := Y + (H / 2);
end;

constructor TRegion.Create(ARegionRect: TRegionRect; AUnit, AName, ADescription, ARegionType: string);
begin
  inherited Create;

  FRegionRect := ARegionRect;
  FUnit := AUnit;
  FName := AName;
  FDescription := ADescription;
  FRegionType := ARegionType;
end;

constructor TRegions.Create(ADimW, AImgW, ADimH, AImgH: integer; AUnits: string);
begin
  inherited Create;
  Floading := true;

  if (ADimW <> 0) then
    FDimW := ADimW
  else
    FDimW := AImgW;
  if (ADimH <> 0) then
    FDimH := ADimH
  else
    FDimH := AImgH;
  if (AUnits <> '-') then
    FUnits := AUnits
  else
    FUnits := 'Pixels';
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
  RegionRectangle: string;
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
             '-ImageWidth' + CRLF +
             '-RegionAppliedToDimensionsH' + CRLF +
             '-ImageHeight' + CRLF +
             '-RegionAppliedToDimensionsUnit' + CRLF +
             '-RegionName' + CRLF +
             '-RegionDescription' + CRLF +
             '-RegionType' + CRLF +
             '-RegionAreaUnit' + CRLF +
             '-RegionAreaW' + CRLF +
             '-RegionAreaH' + CRLF +
             '-RegionAreaX' + CRLF +
             '-RegionAreaY' + CRLF +
             '-RegionRectangle' + CRLF;
    if (not ET.OpenExec(ETcmd, AFile, ETouts, false)) then
      exit;
    if (Etouts.Count < 14) then
      exit;

    result := TRegions.Create(StrToIntDef(ETOuts[0], 0),
                              StrToIntDef(ETOuts[1], 0),
                              StrToIntDef(ETOuts[2], 0),
                              StrToIntDef(ETOuts[3], 0),
                              ETOuts[4]);

    while (ETouts[5] <> '') do // Name is mandatory. For us.
    begin
      AName           := NextItem(ETOuts, 5);
      ADescription    := NextItem(ETOuts, 6);
      ARegionType     := NextItem(ETOuts, 7);
      AUnit           := NextItem(ETOuts, 8);
      // Prefer RegionAreax, but fallback to RegionRectangle
      ARegion.W       := StrToFloatDef(NextItem(ETOuts,  9), -1, ExifToolsGUI_Utils.FloatFormatSettings);
      ARegion.H       := StrToFloatDef(NextItem(ETOuts, 10), -1, ExifToolsGUI_Utils.FloatFormatSettings);
      ARegion.SetCenterX(StrToFloatDef(NextItem(ETOuts, 11), -1, ExifToolsGUI_Utils.FloatFormatSettings));
      ARegion.SetCenterY(StrToFloatDef(NextItem(ETOuts, 12), -1, ExifToolsGUI_Utils.FloatFormatSettings));
      RegionRectangle := NextItem(ETOuts, 13);
      if (ARegion.IsEmpty) then
      begin
        ARegion.X       := StrToFloatDef(NextField(RegionRectangle, ','), -1, ExifToolsGUI_Utils.FloatFormatSettings);
        ARegion.Y       := StrToFloatDef(NextField(RegionRectangle, ','), -1, ExifToolsGUI_Utils.FloatFormatSettings);
        ARegion.W       := StrToFloatDef(NextField(RegionRectangle, ','), -1, ExifToolsGUI_Utils.FloatFormatSettings);
        ARegion.H       := StrToFloatDef(RegionRectangle, -1, ExifToolsGUI_Utils.FloatFormatSettings);
      end;
      if (ARegion.IsEmpty = false) then
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

  AName, APersonName, ADescription, ARegionType, AUnit: string;
  ARegionW, ARegionH, ARegionX, ARegionY: string;
  RegionRect: string;
  Sep: string;
  Index: integer;
begin
  SavedSep := ET.Options.GetSeparatorChar;
  try
    ET.Options.SetSeparator(ListSep);
    APersonName     := '-RegionPersonDisplayName=';
    AName           := '-RegionName=';
    ADescription    := '-RegionDescription=';
    ARegionType     := '-RegionType=';
    AUnit           := '-RegionAreaUnit=';
    ARegionW        := '-RegionAreaW=';
    ARegionH        := '-RegionAreaH=';
    ARegionX        := '-RegionAreaX=';
    ARegionY        := '-RegionAreaY=';

    Sep := ListSep;
    RegionRect := '-RegionRectangle=';
    for Index := 0 to Items.Count -1 do
    begin
      Region := Items[Index];
      if (Index = Items.Count -1) then
        Sep := '';

      AName         := AName + Region.RegionName + Sep;
      APersonName   := APersonName + Region.RegionName + Sep;
      ADescription  := ADescription + Region.RegionDescription + Sep;
      ARegionType   := ARegionType + Region.RegionType + Sep;
      AUnit         := AUnit + Region.RegionUnit + Sep;
      ARegionW      := ARegionW + FloatToStr(Region.RegionRect.W,           ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
      ARegionH      := ARegionH + FloatToStr(Region.RegionRect.H,           ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
      ARegionX      := ARegionX + FloatToStr(Region.RegionRect.GetCenterX,  ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
      ARegionY      := ARegionY + FloatToStr(Region.RegionRect.GetCenterY,  ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
      RegionRect    := RegionRect +
                       FloatToStr(Region.RegionRect.X, ExifToolsGUI_Utils.FloatFormatSettings) + ', ' +
                       FloatToStr(Region.RegionRect.Y, ExifToolsGUI_Utils.FloatFormatSettings) + ', ' +
                       FloatToStr(Region.RegionRect.W, ExifToolsGUI_Utils.FloatFormatSettings) + ', ' +
                       FloatToStr(Region.RegionRect.H, ExifToolsGUI_Utils.FloatFormatSettings) + Sep;
    end;

    ETCmd :=
             '-RegionAppliedToDimensionsW='     + IntToStr(FDimW) + CRLF +
             '-RegionAppliedToDimensionsH='     + IntToStr(FDimH) + CRLF +
             '-RegionAppliedToDimensionsUnit='  + FUnits + CRLF +
             APersonName + CRLF +
             AName + CRLF +
             ADescription + CRLF +
             ARegionType + CRLF +
             AUnit + CRLF +
             ARegionW + CRLF +
             ARegionH + CRLF +
             ARegionX + CRLF +
             ARegionY + CRLF +
             RegionRect + CRLF;

    ET.OpenExec(ETcmd, AFile);

  finally
    ET.Options.SetSeparator(SavedSep);
  end;
end;

end.
