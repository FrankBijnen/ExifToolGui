{
  Unit sdSortedLists
  Author: Nils Haeck M.Sc.
  Copyright (c) 2003-2010 SimDesign B.V.
  Creation Date: 02Aug2003
  This software may ONLY be used or replicated in accordance with
  the LICENSE found in this source distribution.
  Description:
  Implements a TObjectList descendant that can sort items using
  the quicksort algorithm, as well as find items using a binary
  tree algorithm.
  Version: 1.0
}
unit sdSortedLists;

interface

uses
  System.Contnrs, System.SysUtils;

type
  TItemCompareEvent = function(Item1, Item2: TObject; Info: pointer): integer of object;
  TItemCompareMethod = function(Item1, Item2: TObject; Info: pointer): integer;
  TPointerCompareMethod = function(Ptr1, Ptr2: pointer): integer;
  // TCustomSortedList is a TObjectList descendant providing easy sorting
  // capabilities, while keeping simplicity. Override the DoCompare method
  // to compare two items.
  TCustomSortedList = class(TObjectList)
  private
    FSorted: boolean;
    procedure SetSorted(AValue: boolean);
  protected
    // Override this method to implement the object comparison between two
    // items. The default just compares the item pointers
    function DoCompare(Item1, Item2: TObject): integer; virtual;
  public
    constructor Create(AOwnsObjects: boolean = true);
    function Add(AItem: TObject): integer;
    function Find(Item: TObject; out Index: integer): boolean; virtual;
    procedure Sort; virtual;
    property Sorted: boolean read FSorted write SetSorted default true;
  end;

  // TSortedList is an object list that provides an events or method template
  // to compare items. Assign either OnCompare (for an event) or CompareMethod
  // (for a method template) to do the comparison of items. Additional information
  // required for the compare method can be passed with the CompareInfo pointer.
  TSortedList = class(TCustomSortedList)
  private
    FCompareInfo: pointer;
    FOnCompare: TItemCompareEvent;
    FCompareMethod: TItemCompareMethod;
  protected
    function DoCompare(Item1, Item2: TObject): integer; override;
  public
    property CompareInfo: pointer read FCompareInfo write FCompareInfo;
    // Use CompareMethod if you want to specify a compare method as stand-alone method
    property CompareMethod: TItemCompareMethod read FCompareMethod write FCompareMethod;
    // Use OnCompare if you want to specify a compare method as a method of a class
    property OnCompare: TItemCompareEvent read FOnCompare write FOnCompare;
  end;


implementation

uses System.Classes;

function ComparePointer(Item1, Item2: pointer): integer;
begin
  if NativeInt(Item1) < NativeInt(Item2) then
    Result := -1
  else
    if NativeInt(Item1) > NativeInt(Item2) then
      Result := 1
    else
      Result := 0;
end;

{ TCustomSortedList }
function TCustomSortedList.Add(AItem: TObject): integer;
begin
  if Sorted then
  begin
    Find(AItem, Result);
    Insert(Result, AItem);
  end else
    Result := inherited Add(AItem);
end;

constructor TCustomSortedList.Create(AOwnsObjects: boolean);
begin
  inherited Create(AOwnsObjects);
  FSorted := True;
end;

function TCustomSortedList.DoCompare(Item1, Item2: TObject): integer;
begin
  Result := ComparePointer(Item1, Item2);
end;

function TCustomSortedList.Find(Item: TObject; out Index: integer): boolean;
var
  AMin, AMax: integer;
begin
  Result := False;
  if Sorted then
  begin
    // Find position for insert - binary method
    Index := 0;
    AMin := 0;
    AMax := Count;
    while AMin < AMax do
    begin
      Index := (AMin + AMax) div 2;
      case DoCompare(List[Index], Item) of
      -1: AMin := Index + 1;
       0: begin
            Result := True;
            exit;
          end;
       1: AMax := Index;
      end;
    end;
    Index := AMin;
  end else
  begin
    // If not a sorted list, then find it with the IndexOf() method
    Index := IndexOf(Item);
    if Index >= 0 then
    begin
      Result := True;
      exit;
    end;
    // Not found: set it to Count
    Index := Count;
  end;
end;

procedure TCustomSortedList.SetSorted(AValue: boolean);
begin
  if AValue <> FSorted then
  begin
    FSorted := AValue;
    if FSorted then
      Sort;
  end;
end;

procedure TCustomSortedList.Sort;

  //local
  procedure QuickSort(iLo, iHi: Integer);
  var
    Lo, Hi, Mid: longint;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid:= (Lo + Hi) div 2;
    repeat
      while DoCompare(List[Lo], List[Mid]) < 0 do
        Inc(Lo);
      while DoCompare(List[Hi], List[Mid]) > 0 do
        Dec(Hi);
      if Lo <= Hi then
      begin
        // Swap pointers;
        Exchange(Lo, Hi);
        if Mid = Lo then
          Mid := Hi
        else
          if Mid = Hi then
            Mid := Lo;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      QuickSort(iLo, Hi);
    if Lo < iHi then
      QuickSort(Lo, iHi);
  end;

// main
begin
  if Count > 1 then
  begin
    QuickSort(0, Count - 1);
  end;
  FSorted := True;
end;

{ TSortedList }
function TSortedList.DoCompare(Item1, Item2: TObject): integer;
begin
  if Assigned(FOnCompare) then
    Result := FOnCompare(Item1, Item2, FCompareInfo)
  else if Assigned(FCompareMethod) then
    Result := FCompareMethod(Item1, Item2, FCompareInfo)
  else
    Result := ComparePointer(Item1, Item2);
end;

end.
