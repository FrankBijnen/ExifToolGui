unit UnitRegion;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TRegionRect = record
    W,H,Y,X: double;
    function IsEmpty: boolean;
    procedure SetFromCenterX(CX: Double);
    procedure SetFromCenterY(CY: Double);
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
    FShow: boolean;
    FSelected: boolean;
  public
    constructor Create(ARegionRect: TRegionRect; AUnit, AName, ADescription, ARegionType: string);
    property RegionRect: TRegionRect read FRegionRect write FRegionRect;
    property RegionName: string read FName write FName;
    property RegionDescription: string read FDescription write FDescription;
    property RegionType: string read FRegionType write FRegionType;
    property RegionUnit: string read FUnit write FUnit;
    property Show: boolean read FShow write FShow;
    property Selected: boolean read FSelected write FSelected;
  end;
  TRegionList = TList<TRegion>;

  TRegions = class(TObject)
  private
    FItems: TRegionList;
    FDimW: integer;
    FDimH: integer;
    FUnits: string;
    FUpdating: boolean;
    FModified: boolean;
  public
    constructor Create(ADimW, AImgW, ADimH, AImgH: integer; AUnits: string);
    destructor Destroy; override;
    procedure Clear;
    function Add(ARegion: TRegion): TRegion;
    function Delete(Index: integer): boolean;
    class function LoadFromFile(AFile: string): TRegions;
    procedure SaveToFile(AFile: string);
    property Items: TRegionList read FItems;
    property Updating: boolean read FUpdating write FUpdating;
    property Modified: boolean read FModified write FModified;
  end;

var
  RegionNameList: TStringList;

implementation

uses
  System.SysUtils,
  ExifTool, ExifToolsGUI_Utils, ExifToolsGUI_StringList;

// Dont want a separator char that can be in a string. Like *, or :, #255 is unlikely
const
  ListSep = #255;

function TRegionRect.IsEmpty: boolean;
begin
  result := (X < 0) or (Y < 0) or (W < 0) or (H < 0);
end;

procedure TRegionRect.SetFromCenterX(CX: Double);
begin
  X := CX - (W / 2);
end;

procedure TRegionRect.SetFromCenterY(CY: Double);
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
  FShow := true;
end;

constructor TRegions.Create(ADimW, AImgW, ADimH, AImgH: integer; AUnits: string);
begin
  inherited Create;
  FUpdating := true;
  FModified := false;

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
  FModified := true;
  Items.Add(ARegion);
  result := ARegion;
end;

function TRegions.Delete(Index: integer): boolean;
begin
  result := false;
  if (Index > -1) and
   (Index < Items.Count) then
  begin
    Items[Index].Free;
    Items.Delete(Index);
    result := true;
    FModified := true;
  end;
end;

class function TRegions.LoadFromFile(AFile: string): TRegions;
var
  ETcmd: string;
  ETOuts: TStringList;
  SavedSep: string;
  AName, ADescription, ARegionType, AUnit: string;
  RegionRectangle: string;
  ARegion: TRegionRect;
  Cnt: integer;

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
             '-ImageWidth' + CRLF +               // Fallback
             '-RegionAppliedToDimensionsH' + CRLF +
             '-ImageHeight' + CRLF +              // Fallback
             '-RegionAppliedToDimensionsUnit' + CRLF +
             '-RegionName' + CRLF +
             '-RegionPersonDisplayName' + CRLF +  // Fallback
             '-RegionDescription' + CRLF +
             '-RegionType' + CRLF +
             '-RegionAreaUnit' + CRLF +
             '-RegionAreaW' + CRLF +
             '-RegionAreaH' + CRLF +
             '-RegionAreaX' + CRLF +
             '-RegionAreaY' + CRLF +
             '-RegionRectangle' + CRLF;           // Fallback
    if (not ET.OpenExec(ETcmd, AFile, ETouts, false)) then
      exit;
    if (Etouts.Count < 15) then
      exit;

    // Create
    result := TRegions.Create(StrToIntDef(ETOuts[0], 0),
                              StrToIntDef(ETOuts[1], 0),  // Fallback
                              StrToIntDef(ETOuts[2], 0),
                              StrToIntDef(ETOuts[3], 0),  // Fallback
                              ETOuts[4]);

    // Take RegionName if avail, else RegionPersonDisplayName
    if (ETOuts[5] = '-') then
      ETOuts.Delete(5)
    else
      ETOuts.Delete(6);

    Cnt := 0;
    while (ETouts[7] <> '') do // RegionType is mandatory. For us.
    begin
      Inc(Cnt);
      AName           := NextItem(ETOuts, 5);

      if (AName <> '-') then
        RegionNameList.Add(AName)
      else
        AName := Format('#%d', [Cnt]);

      ADescription    := NextItem(ETOuts, 6);
      ARegionType     := NextItem(ETOuts, 7);
      AUnit           := NextItem(ETOuts, 8);

      // Prefer RegionAreaW, H, X and Y
      // Note: RegionAreaY and X are the center of the Rectangle. The record uses Top Left.
      ARegion.W       := StrToFloatDef(     NextItem(ETOuts,  9), -1, ExifToolsGUI_Utils.FloatFormatSettings);
      ARegion.H       := StrToFloatDef(     NextItem(ETOuts, 10), -1, ExifToolsGUI_Utils.FloatFormatSettings);
      ARegion.SetFromCenterX(StrToFloatDef( NextItem(ETOuts, 11), -1, ExifToolsGUI_Utils.FloatFormatSettings));
      ARegion.SetFromCenterY(StrToFloatDef( NextItem(ETOuts, 12), -1, ExifToolsGUI_Utils.FloatFormatSettings));

      // Fallback to RegionRectangle ?
      RegionRectangle := NextItem(ETOuts, 13);
      if (ARegion.IsEmpty) then
      begin
        ARegion.X       := StrToFloatDef(NextField(RegionRectangle, ','), -1, ExifToolsGUI_Utils.FloatFormatSettings);
        ARegion.Y       := StrToFloatDef(NextField(RegionRectangle, ','), -1, ExifToolsGUI_Utils.FloatFormatSettings);
        ARegion.W       := StrToFloatDef(NextField(RegionRectangle, ','), -1, ExifToolsGUI_Utils.FloatFormatSettings);
        ARegion.H       := StrToFloatDef(RegionRectangle, -1, ExifToolsGUI_Utils.FloatFormatSettings);
      end;

      // Add Region
      if (ARegion.IsEmpty = false) then
        result.Add(TRegion.Create(ARegion, AUnit, AName, ADescription, ARegionType));
    end;
    result.Modified := false;
    result.Updating := false;

  finally
    ET.Options.SetSeparator(SavedSep);
    ETOuts.Free;
  end;
end;

procedure TRegions.SaveToFile(AFile: string);
var
  ETcmd: string;
  Region: TRegion;
  Sep: string;
  SavedSep: string;
  AName, APersonName, ADescription, ARegionType, AUnit: string;
  ARegionW, ARegionH, ARegionX, ARegionY: string;
  RegionRect: string;
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

    // Write both XMP-MP:Region* and XMP-mwg-rs:region*
    ETCmd := '-RegionAppliedToDimensionsW='     + IntToStr(FDimW) + CRLF +
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

    Modified := false;
    Updating := false;

  finally
    ET.Options.SetSeparator(SavedSep);
  end;
end;

initialization
begin
  RegionNameList := GetSortedStringList;
end;

finalization
begin
  RegionNameList.Free;
end;

end.
