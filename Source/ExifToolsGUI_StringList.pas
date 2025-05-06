unit ExifToolsGUI_StringList;

interface

uses System.Classes;

type

  TNrSortedStringList = class(TStringList)
  public
    procedure Sort; reintroduce;
    function GetValue(const Key: integer): integer; overload;
    function GetValue(const Key: string): integer; overload;
    procedure IncValue(const Key: string);
  end;

function GetSortedStringList: TStringList;

implementation

uses
  System.SysUtils,
  ExifToolsGUI_Utils;

// Sort on stringlist with possibly decimals/integers in key.
function SortOnKey(List: TStringList; Index1, Index2: Integer): Integer;
var
  L1, l2: Double;
begin
  result := 0;
  if (TryStrToFloat(List.KeyNames[Index1], L1, FloatFormatSettings)) and
     (TryStrToFloat(List.KeyNames[Index2], L2, FloatFormatSettings)) then
  begin // Compare decimals
    if (L1 < L2) then
      result := -1
    else if (L1 > L2) then
      result := 1;
  end
  else
  begin // Compare strings
    if (List.KeyNames[Index1] < List.KeyNames[Index2]) then
      result := -1
    else if (List.KeyNames[Index1] > List.KeyNames[Index2]) then
      result := 1;
  end;
end;

procedure TNrSortedStringList.Sort;
begin
  CustomSort(SortOnKey);
end;

function TNrSortedStringList.GetValue(const Key: integer): integer;
begin
  if not TryStrToInt(ValueFromIndex[Key], result) then
    result := 0;
end;

function TNrSortedStringList.GetValue(const Key: string): integer;
begin
  if not TryStrToInt(Values[Key], result) then
    result := 0;
end;

procedure TNrSortedStringList.IncValue(const Key: string);
var
  Indx: integer;
begin
  if (Key <> '') then
  begin
    Indx := IndexOfName(Key);
    Values[Key] := IntToStr(GetValue(Indx) + 1);
  end;
end;

function GetSortedStringList: TStringList;
begin
  result := TStringList.Create;
  result.Sorted := true;
  result.Duplicates := TDuplicates.dupIgnore;
  result.CaseSensitive := false;
end;

end.
