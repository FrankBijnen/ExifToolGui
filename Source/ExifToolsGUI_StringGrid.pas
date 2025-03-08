unit ExifToolsGUI_StringGrid;

interface

uses
  Vcl.Grids;

type
  TStringGrid = class(Vcl.Grids.TStringGrid)
  public
    procedure DeleteRow(ARow: longint); override;
    function InsertRow(ARow: longint): longint;
    procedure MakeRowVisible(ARow: longint);
    procedure MoveUp(ARow: longint);
    procedure MoveDown(ARow: longint);
  end;

implementation

{ TStringGrid }

procedure TStringGrid.DeleteRow(ARow: longint);
var
  SavedSelect: TSelectCellEvent;
  SavedTopRow: integer;
  SavedRow: integer;
begin
  SavedSelect := OnSelectCell;
  SavedTopRow := TopRow;
  SavedRow := Row;
  OnSelectCell := nil;
  try
    inherited DeleteRow(ARow);
  finally
    TopRow := SavedTopRow;
    if (SavedRow > RowCount -1) then
      SavedRow := RowCount -1;
    Row := SavedRow;
    OnSelectCell := SavedSelect;
  end;
end;

function TStringGrid.InsertRow(ARow: longint): longint;
var
  SavedSelect: TSelectCellEvent;
begin
  SavedSelect := OnSelectCell;
  OnSelectCell := nil;
  try
    while ARow < FixedRows do
      Inc(ARow);
    RowCount := RowCount + 1;
    MoveRow(RowCount - 1, ARow);
    result := ARow;
  finally
    OnSelectCell := SavedSelect;
  end;
end;

procedure TStringGrid.MakeRowVisible(ARow: longint);
var
  T, N: integer;
begin
  T := TopRow;
  if (ARow < TopRow) then
    TopRow := ARow
  else
  begin
    N := Height div RowHeights[0]; // how many rows fit into grid
    if (ARow > T + N) then
      TopRow := ARow;
  end;
end;

procedure TStringGrid.MoveUp(ARow: longint);
begin
  if (ARow > 0) then
    MoveRow(ARow - 1, ARow);
end;

procedure TStringGrid.MoveDown(ARow: longint);
begin
  if (ARow < RowCount -1) then
    MoveRow(ARow + 1, ARow);
end;

end.
