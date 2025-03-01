unit QuickMngr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask, Vcl.Buttons;

type
  // TODO separate unit?
  TStringGrid = class(Vcl.Grids.TStringGrid)
  public // because DeleteRow isn't published in TStringGrid
    procedure DeleteRow(ARow: longint); override;
    function InsertRow(ARow: longint): longint;
    procedure MakeRowVisible(ARow: longint);
  end;

  TFQuickManager = class(TScaleForm)
    AdvPanel1: TPanel;
    SgWorkSpace: TStringGrid;
    StatusBar1: TStatusBar;
    PnlDetail: TPanel;
    EdTagDesc: TLabeledEdit;
    EdTagDef: TLabeledEdit;
    EdTagHint: TLabeledEdit;
    PnlBottom: TPanel;
    PnlFuncTop: TPanel;
    Splitter1: TSplitter;
    BtnCancel: TBitBtn;
    BtnOK: TBitBtn;
    SpbAddTag: TSpeedButton;
    SpbDelTag: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure SgWorkSpaceSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure LabeledEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpbAddTagClick(Sender: TObject);
    procedure SpbDelTagClick(Sender: TObject);
    procedure PnlDetailResize(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    procedure UpdateButtons;
    procedure UpdateLabels(const ARow: integer);
    procedure SaveSettings;
  public
    { Public declarations }
  end;

var
  FQuickManager: TFQuickManager;

implementation

uses
  StrUtils, Main, MainDef, ExifToolsGUI_Utils, UFrmTagNames;

{$R *.dfm}

{ TStringGrid }

procedure TStringGrid.DeleteRow(ARow: longint);
var
  SavedSelect: TSelectCellEvent;
  SavedTopRow: integer;
  SavedRow: integer;
begin
  SavedSelect := Self.OnSelectCell;
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
  SavedSelect := Self.OnSelectCell;
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

{ QuickManager }
procedure TFQuickManager.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFQuickManager.UpdateButtons;
begin
  SpbDelTag.Enabled := (SgWorkSpace.RowCount > 1);
end;

procedure TFQuickManager.UpdateLabels(const ARow: integer);
begin
  EdTagDesc.Text    := SgWorkSpace.Cells[0, ARow];
  EdTagDef.Text     := SgWorkSpace.Cells[1, ARow];
  EdTagHint.Text    := SgWorkSpace.Cells[2, ARow];
end;

procedure TFQuickManager.SaveSettings;
var
  I, N: integer;
  Tx: string;
begin
  I := SgWorkSpace.RowCount;
  SetLength(QuickTags, I);
  for N := 0 to I - 1 do
  begin
    Tx := SgWorkSpace.Cells[0, N];
    QuickTags[N].Caption := Tx;
    QuickTags[N].NoEdit := (RightStr(Tx, 1) = '?');
    Tx := SgWorkSpace.Cells[1, N];
    QuickTags[N].Command := Tx;
    Tx := UpperCase(LeftStr(Tx, 4));
    QuickTags[N].NoEdit := QuickTags[N].NoEdit or (Tx = '-GUI');
    QuickTags[N].Help := SgWorkSpace.Cells[2, N];
  end;
end;

procedure TFQuickManager.SpbAddTagClick(Sender: TObject);
var
  S: string;
begin
  FrmTagNames.SetSample(Fmain.GetFirstSelectedFile);

  // Delete hyphen from tag when searching
  S := Trim(EdTagDef.Text);
  if (LeftStr(S, 1) = '-') then
    S := Copy(S, 2);

  FrmTagNames.SetSearchString(S);
  FrmTagNames.EnableExclude(false);
  if (FrmTagNames.ShowModal = IDOK) then
  begin
    SgWorkSpace.Row := SgWorkSpace.InsertRow(SgWorkSpace.Row +1);
    SgWorkSpace.Cells[0, SgWorkSpace.Row] := FrmTagNames.SelectedTag(false);
    SgWorkSpace.Cells[1, SgWorkSpace.Row] := '-' + FrmTagNames.SelectedTag(false);
    SgWorkSpace.Cells[2, SgWorkSpace.Row] := '';

    SgWorkSpace.MakeRowVisible(SgWorkSpace.Row);

    UpdateButtons;
    UpdateLabels(SgWorkSpace.Row);
  end;
end;

procedure TFQuickManager.SpbDelTagClick(Sender: TObject);
begin
  if (SgWorkSpace.RowCount > 1) then
    SgWorkSpace.DeleteRow(SgWorkSpace.Row); // keep one line

  UpdateButtons;
  UpdateLabels(SgWorkSpace.Row);
end;

procedure TFQuickManager.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOk then
    SaveSettings;
end;

procedure TFQuickManager.FormShow(Sender: TObject);
var
  I, N, X: integer;
begin
  Application.OnHint := DisplayHint;
  Left := FMain.GetFormOffset(false).X;
  Top := FMain.GetFormOffset(false).Y;

  if FMain.SpeedBtnQuick.Down then
    X := FMain.MetadataList.Row - 1
  else
    X := 0;
  I := Length(QuickTags);

  SgWorkSpace.BeginUpdate;
  try
    SgWorkSpace.ColWidths[1] := 220;
    SgWorkSpace.ColWidths[2] := 220;
    SgWorkSpace.RowCount := I;
    for N := 0 to I - 1 do
    begin
      SgWorkSpace.Cells[0, N] := QuickTags[N].Caption;
      SgWorkSpace.Cells[1, N] := QuickTags[N].Command;
      SgWorkSpace.Cells[2, N] := QuickTags[N].Help;
    end;
    SgWorkSpace.Row := X;
  finally
    SgWorkSpace.EndUpdate;
  end;

  UpdateButtons;
  UpdateLabels(SgWorkSpace.Row);
end;

procedure TFQuickManager.LabeledEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Tx: string;
begin
  Tx := Trim(EdTagDesc.Text);
  // Tag would always be marked as modified
  if (LeftStr(Tx, 1) = '*') then
    Tx := Copy(Tx, 2);
  SgWorkSpace.Cells[0, SgWorkSpace.Row] := Tx;

  // Tag would trigger a modification
  Tx := RemoveInvalidTags(Trim(EdTagDef.Text), true);
  EdTagDef.Text := Tx;
  // Needs to start with a hypen
  if (Leftstr(Tx, 1) <> '-') then
    Tx := '-' + Tx;
  SgWorkSpace.Cells[1, SgWorkSpace.Row] := Tx;

  SgWorkSpace.Cells[2, SgWorkSpace.Row] := Trim(EdTagHint.Text);
end;

procedure TFQuickManager.PnlDetailResize(Sender: TObject);
const
  Margin = 25;
begin
  EdTagDesc.Width := PnlDetail.Width - Margin;
  EdTagDef.Width  := PnlDetail.Width - Margin;
  EdTagHint.Width := PnlDetail.Width - Margin;
end;

procedure TFQuickManager.SgWorkSpaceSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  UpdateButtons;
  UpdateLabels(ARow);
end;

end.
