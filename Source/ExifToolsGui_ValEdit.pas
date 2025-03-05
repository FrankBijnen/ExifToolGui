unit ExifToolsGui_ValEdit;

// Allow all Ctrl+Key events to be used by the app.
// If the app eventhandler sets Key to 0, that disables standard processing

interface

uses
  System.Classes, Winapi.Messages, Vcl.ValEdit, Vcl.Controls, Vcl.Grids,
  Winapi.ShlObj, Winapi.ActiveX, ExifToolsGui_AutoEdit, ExifToolsGui_AutoComplete;

type
  TValueListEditor = class;

  TETGuiInplaceEdit = class(Vcl.Grids.TInplaceEdit, IWordSelEdit, IAutoCompleteEdit)
  private
    FAutoCompleteEdit: IAutoCompleteEdit;
    FWordSelEdit: IWordSelEdit;
    procedure ConvertToGridPoint(var X, Y: integer);
    function ValueListEditor: TValueListEditor;
  protected
    procedure CreateWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property WordSelEdit: IWordSelEdit read FWordSelEdit implements IWordSelEdit;
    property AutoCompleteEdit: IAutoCompleteEdit read FAutoCompleteEdit implements IAutoCompleteEdit;
  end;

  TValueListEditor = class(Vcl.ValEdit.TValueListEditor)
  private
    FProportionalVScroll: boolean;
    FDataRows: integer;
    FRowsPossible: integer;
    FOnCtrlKeyDown: TkeyEvent;
    FInplaceEdit: TETGuiInplaceEdit;
    FEditRow: integer;
    FHistoryList: TStringList;
  protected
    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;
    function CreateEditor: TInplaceEdit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function GetRowsPossible: integer;
    procedure SetProportionalVScroll(Value: boolean);
    procedure UpdateScrollBar;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure SizeChanged(OldColCount, OldRowCount: Longint); override;
    procedure TopLeftChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetFocus; override;
    procedure SetStringsCount(NewCount: integer);
    property OnCtrlKeyDown: TkeyEvent read FOnCtrlKeyDown write FOnCtrlKeyDown;
    property ProportionalVScroll: boolean read FProportionalVScroll write SetProportionalVScroll default false;
    property FixedRows;
    property InplaceEdit: TETGuiInplaceEdit read FInplaceEdit;
    property EditRow: integer read FEditRow;
    property HistoryList: TStringList read FHistoryList;
  end;

implementation

uses
  System.Types, System.UITypes, System.Win.ComObj, System.SysUtils, Winapi.Windows;

constructor TETGuiInplaceEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FWordSelEdit := TWordSelEdit.Create;
  FAutoCompleteEdit := TAutoCompleteEdit.Create;
end;

destructor TETGuiInplaceEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TETGuiInplaceEdit.CreateWnd;
begin
  inherited CreateWnd;
  FAutoCompleteEdit.InstallAutoComplete(Handle);
end;

procedure TETGuiInplaceEdit.ConvertToGridPoint(var X, Y: integer);
var
  Pt: TPoint;
begin
  Pt := Self.ClientToScreen(Point(X, Y));
  Pt := Grid.ScreenToClient(Pt);
  X := Pt.X;
  Y := Pt.Y;
end;

function TETGuiInplaceEdit.ValueListEditor: TValueListEditor;
begin
  result := TValueListEditor(Grid);
end;

procedure TETGuiInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_END:
      SelLength := 0;
    VK_UP,
    VK_DOWN:
      FAutoCompleteEdit.EnableAutoComplete(false);
    else
      if (not (ssCtrl in Shift)) then
        FAutoCompleteEdit.EnableAutoComplete(FAutoCompleteEdit.GetAutoCompleteMode <> TAutoCompleteMode.acNone);
  end;

  if (ssCtrl in Shift) then
    ValueListEditor.KeyDown(Key, Shift);

  inherited KeyDown(Key, Shift);
end;

procedure TETGuiInplaceEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);

  case Key of
    VK_RETURN,
    VK_ESCAPE:
      FAutoCompleteEdit.EnableAutoComplete(false);
  end;
end;

procedure TETGuiInplaceEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if (Button = TMouseButton.mbRight) then
  begin
    ConvertToGridPoint(X, Y);
    ValueListEditor.MouseDown(Button, Shift, X, Y);
  end;

  inherited MouseDown(Button, Shift, X, Y);
end;

constructor TValueListEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProportionalVScroll := false;
  FDataRows := 0;
  FRowsPossible := 0;
  FHistoryList := TStringList.Create;
  FHistoryList.Sorted := true;
  FHistoryList.Duplicates := TDuplicates.dupIgnore;
end;

destructor TValueListEditor.Destroy;
begin
  FHistoryList.Free;
  inherited Destroy;
end;

function TValueListEditor.CreateEditor: TInplaceEdit;
begin
  FInplaceEdit := TETGuiInplaceEdit.Create(Self);
  result := FInplaceEdit;
end;

procedure TValueListEditor.SetEditText(ACol, ARow: Longint; const Value: string);
begin
  FEditRow := ARow;

  inherited SetEditText(Acol, Arow, Value);
end;

procedure TValueListEditor.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Assigned(FOnCtrlKeyDown)) and
     (ssCtrl in Shift) then
    FOnCtrlKeyDown(Self, Key, Shift);

  inherited KeyDown(Key, Shift);
end;

// This function calculates the #rows possible in the grid. Used for nPage in Scrollbar.
// In contrast to VisibleRowCount. That returns the rows actually in the grid.
// E.G.: RowCount = 200, Toprow = 199. => VisibleRowCount = 2. We would get a scrollbar with nPage = 2!
// Assumed that all rows are the same height.
function TValueListEditor.GetRowsPossible: integer;
var
  DrawInfo: TGridDrawInfo;
begin
  if (FDataRows < 1) then  // Need at least 1 DataRow
    exit(0);

  CalcDrawInfo(DrawInfo);
  result := ClientHeight div (DrawInfo.Vert.GetExtent(FixedRows) + DrawInfo.Vert.EffectiveLineWidth) - FixedRows;
end;

procedure TValueListEditor.SetProportionalVScroll(Value: boolean);
begin
  if (Value = FProportionalVScroll) then
    exit;
  FProportionalVScroll := Value;

  if FProportionalVScroll then
  begin
    case ScrollBars of
      TScrollStyle.ssNone,
      TScrollStyle.ssHorizontal:
        ;  // No Action
      TScrollStyle.ssVertical:
        ScrollBars := TScrollStyle.ssNone;
      TScrollStyle.ssBoth:
        ScrollBars := TScrollStyle.ssHorizontal;
    end;
  end
  else
  // Dont restore original ScrollBars. (We cant!)
  ;
end;

procedure TValueListEditor.UpdateScrollBar;
var
  Si: tagSCROLLINFO;
begin
  FillChar(Si, SizeOf(Si), Chr(0));
  Si.cbSize := SizeOf(Si);
  Si.fMask := SIF_POS;              // Get current pos from scrollbar. Other fields remain zero.
  GetScrollInfo(Self.Handle, SB_VERT, Si);

  if (FRowsPossible < FDataRows) then
  begin
    Si.nMin := 1;                   // We can have a proportional scrollbar
    Si.nMax := FDataRows;
    Si.nPage := FRowsPossible;
  end;

  if (Si.nPos > Si.nMax) then       // Verify Position within bounds
    Si.nPos := Si.nMax;

  Si.fMask := SIF_ALL;              // Update all fields
  SetScrollInfo(Self.Handle, SB_VERT, Si, false); // Redraw not needed?
end;

procedure TValueListEditor.WMVScroll(var Msg: TWMVScroll);
var
  Si: tagSCROLLINFO;
begin
  if not (FProportionalVScroll) then
  begin
    inherited;
    exit;
  end;

// We handle the WMVScroll ourselves. Min Max and Page are setup
  FillChar(Si, SizeOf(Si), Chr(0));
  Si.cbSize := SizeOf(Si);
  Si.fMask := SIF_ALL;
  GetScrollInfo(Self.Handle, SB_VERT, Si);

  case Msg.ScrollCode of
    SB_LINEUP:
      Dec(Si.nPos, 1);
    SB_LINEDOWN:
      Inc(Si.nPos, 1);
    SB_PAGEUP:
      Dec(Si.nPos, Si.nPage);
    SB_PAGEDOWN:
      Inc(Si.nPos, Si.nPage);
    SB_THUMBPOSITION, SB_THUMBTRACK:
      Si.nPos := Si.nTrackPos;
    SB_BOTTOM:
      Si.nPos := Si.nMax;
    SB_TOP:
      Si.nPos := Si.nMin;
  end;

  // Sanity checks on nPos
  if (Si.nPos > FDataRows +1 - FRowsPossible) then
    Si.nPos := FDataRows +1 - FRowsPossible;
  if (Si.nPos < Si.nMin) then
    Si.nPos := Si.nMin;

  // TopleftChanged is called, updating the scrollbar
  TopRow := Si.nPos;

  Msg.Result := 0; // Handled
end;

procedure TValueListEditor.WMSize(var Msg: TWMSize);
begin
  inherited;

  if (FProportionalVScroll) then
  begin
    FRowsPossible := GetRowsPossible;
    UpdateScrollBar;
    Perform(WM_NCPAINT, 0, 0);
  end;
end;

procedure TValueListEditor.SizeChanged(OldColCount, OldRowCount: Longint);
begin
  if (FProportionalVScroll) then
  begin
    FDataRows := RowCount - FixedRows;
    UpdateScrollBar;
    Perform(WM_NCPAINT, 0, 0);
  end
  else
    inherited;
end;

procedure TValueListEditor.TopLeftChanged;
begin
  if (FProportionalVScroll) then
  begin
    SetScrollPos(Self.Handle, SB_VERT, TopRow, true);
    Perform(WM_NCPAINT, 0, 0);
  end
  else
    inherited;
end;

procedure TValueListEditor.SetFocus;
begin
  if CanFocus then
    inherited SetFocus;
end;

procedure TValueListEditor.SetStringsCount(NewCount: integer);
begin
  if (Strings.Count = NewCount) then
    exit;

  if (NewCount < FixedRows) then
    NewCount := FixedRows;

  if (Row > NewCount) then
  begin
    Row := NewCount;
    if ((Row - TopRow) > FRowsPossible) then
      TopRow := Row - FRowsPossible
    else
      TopRow := 1;
  end;

  Strings.Clear;
  Strings.Text := StringOfChar(#10, NewCount);
end;

// Failsafe if no SelectCell is fired
procedure TValueListEditor.CMEnter(var Message: TCMEnter);
begin
  if (Supports(FInplaceEdit,IAutoCompleteEdit)) then
    (FInplaceEdit as IAutoCompleteEdit).EnableAutoComplete(false);

  inherited;
end;

end.