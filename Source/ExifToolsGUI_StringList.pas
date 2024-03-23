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

implementation

uses System.SysUtils;

// Sort on stringlist with possibly integer in key.
function SortOnKey(List: TStringList; Index1, Index2: Integer): Integer;
var
  L1, l2: integer;
begin
  result := 0;
  if (TryStrToInt(List.KeyNames[Index1], L1)) and
     (TryStrToInt(List.KeyNames[Index2], L2)) then
  begin // Compare integers
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

end.
