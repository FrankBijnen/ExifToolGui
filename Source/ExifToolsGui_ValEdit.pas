unit ExifToolsGui_ValEdit;

// Allow all Ctrl+Key events to be used by the app.
// If the app eventhandler sets Key to 0, that disables standard processing

interface

uses System.Classes, Winapi.Messages, Vcl.ValEdit, Vcl.Controls;

type

  TValueListEditor = class(Vcl.ValEdit.TValueListEditor)
  private
    FProportionalVScroll: boolean;
    FRowsInGrid: integer;
    FOnCtrlKeyDown: TkeyEvent;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function GetRowsInGrid: integer;
    procedure SetProportionalVScroll(Value: boolean);
    procedure UpdateScrollBar;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure SizeChanged(OldColCount, OldRowCount: Longint); override;
    procedure TopLeftChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    property OnCtrlKeyDown: TkeyEvent read FOnCtrlKeyDown write FOnCtrlKeyDown;
    property ProportionalVScroll: boolean read FProportionalVScroll write SetProportionalVScroll default false;
  end;

implementation

uses Winapi.Windows, System.UITypes;

constructor TValueListEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProportionalVScroll := false;
  FRowsInGrid := 0;
end;

procedure TValueListEditor.KeyDown(var Key: Word; Shift: TShiftState);
begin

  if (Assigned(FOnCtrlKeyDown)) and
     (Shift = [ssCtrl]) then
    FOnCtrlKeyDown(Self, Key, Shift);

  inherited KeyDown(Key, Shift);
end;

// This function calculates the #rows possible in the grid. Used for nPage in Scrollbar.
// In contrast to VisibleRowCount. That returns the rows actually in the grid.
// E.G.: RowCount = 200, Toprow = 199. => VisibleRowCount = 2. We would get a scrollbar with nPage = 2!

function TValueListEditor.GetRowsInGrid: integer;
begin
  if (DefaultRowHeight = 0) then
    exit(0);
  result := (ClientHeight div DefaultRowHeight) - FixedRows;
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

  FRowsInGrid := GetRowsInGrid;

  FillChar(Si, SizeOf(Si), Chr(0));
  Si.cbSize := SizeOf(Si);
  Si.fMask := SIF_POS;              // Get current pos from scrollbar. Other fields remain zero.
  GetScrollInfo(Self.Handle, SB_VERT, Si);

  if (FRowsInGrid < RowCount) then  // We can have a proportional scrollbar
  begin
    Si.nMin := 1;
    Si.nMax := RowCount;
    Si.nPage := FRowsInGrid;
  end;
  if (Si.nPos > Si.nMax) then       // Verify Position within bounds
    Si.nPos := Si.nMax;

  Si.fMask := SIF_ALL;              // Update all fields
  SetScrollInfo(Self.Handle, SB_VERT, Si, true);
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
  if (Si.nPos > Si.nMax + 1 - FRowsInGrid) then
    Si.nPos := Si.nMax + 1 - FRowsInGrid;
  if (Si.nPos < Si.nMin) then
    Si.nPos := Si.nMin;

  // TopleftChanged is called, updating the scrollbar
  TopRow := Si.nPos;

  Msg.Result := 0; // Handled
end;

procedure TValueListEditor.CMShowingChanged(var Message: TMessage);
begin
  inherited;

  if (FProportionalVScroll) then
    UpdateScrollBar;
end;

procedure TValueListEditor.WMSize(var Msg: TWMSize);
begin
  inherited;

  if (FProportionalVScroll) then
    UpdateScrollBar;
end;

procedure TValueListEditor.SizeChanged(OldColCount, OldRowCount: Longint);
begin

  inherited;

  if (FProportionalVScroll) then
  begin
    // Must hide first, else thumb is not drawn correctly
    SetScrollRange(Self.Handle, SB_VERT, 0, 0, false);
    UpdateScrollBar;
  end;
end;

procedure TValueListEditor.TopLeftChanged;
begin
  inherited;

  if (FProportionalVScroll) then
    SetScrollPos(Self.Handle, SB_VERT, TopRow, true);
end;

end.