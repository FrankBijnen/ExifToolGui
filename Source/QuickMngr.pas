unit QuickMngr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask, Vcl.Buttons,
  MainDef;

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
    PnlBottom: TPanel;
    PnlFuncTop: TPanel;
    Splitter1: TSplitter;
    BtnCancel: TBitBtn;
    BtnOK: TBitBtn;
    PnlAutoComplete: TPanel;
    PnlQuickTags: TPanel;
    EdTagDesc: TLabeledEdit;
    EdTagDef: TLabeledEdit;
    EdTagHint: TLabeledEdit;
    PctAutoOptions: TPageControl;
    TabAutoCompleteOptions: TTabSheet;
    CmbAutoCompleteMode: TComboBox;
    ChkAutoPopulate: TCheckBox;
    ChkAutoCorrect: TCheckBox;
    GrpCustomList: TGroupBox;
    MemoAutoLines: TMemo;
    GrpDefAutoComplete: TGroupBox;
    PnlAddDel: TPanel;
    SpbAddTag: TSpeedButton;
    SpbDelTag: TSpeedButton;
    CmbDefAutoCompleteMode: TComboBox;
    ChkDefAutoCorrect: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure SgWorkSpaceSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpbAddTagClick(Sender: TObject);
    procedure SpbDelTagClick(Sender: TObject);
    procedure PnlDetailResize(Sender: TObject);
    procedure EdTagKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MemoAutoLinesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SgWorkSpaceDrawCell(Sender: TObject; ACol, ARow: LongInt; Rect: TRect; State: TGridDrawState);
    procedure CmbAutoCompleteModeChange(Sender: TObject);
    procedure ChkAutoCorrectClick(Sender: TObject);
    procedure ChkAutoOptionsClick(Sender: TObject);
    procedure ChkDefAutoCorrectClick(Sender: TObject);
    procedure CmbDefAutoCompleteModeChange(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    procedure UpdateButtons;
    procedure UpdateLabels(const ARow: integer);
    procedure SetAutoCompleteOptions;
    procedure SetDefAutoCompleteOptions;
    function QuickRec(ARow: Longint): TQuickTagRec;
    procedure SaveSettings;
  public
    { Public declarations }
  end;

var
  FQuickManager: TFQuickManager;

implementation

uses
  Vcl.Themes,
  StrUtils, Main, ExifToolsGUI_Utils, UFrmTagNames, ExifToolsGui_AutoComplete;

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

procedure TFQuickManager.SetAutoCompleteOptions;
var
  AQuickRec: TQuickTagRec;
begin
  AQuickRec := QuickRec(SgWorkSpace.Row);
  if (AQuickRec.NoEdit) then
    SgWorkSpace.Objects[3, SgWorkSpace.Row] := nil
  else
  begin
    AQuickRec.AutoComp.SetAcOptions(TAutoCompleteMode(CmbAutoCompleteMode.ItemIndex),
                                    ChkAutoCorrect.Checked,
                                    ChkAutoPopulate.Checked);
    SgWorkSpace.Objects[3, SgWorkSpace.Row] := pointer(AQuickRec.AutoComp.AcOptions);
  end;
end;

procedure TFQuickManager.SetDefAutoCompleteOptions;
begin
  GUIsettings.WSAutoComp.SetAcOptions(TAutoCompleteMode(CmbDefAutoCompleteMode.ItemIndex),
                                      ChkDefAutoCorrect.Checked,
                                      true);
end;

procedure TFQuickManager.ChkAutoCorrectClick(Sender: TObject);
begin
  SetAutoCompleteOptions;
end;

procedure TFQuickManager.ChkAutoOptionsClick(Sender: TObject);
begin
  if (TCheckBox(Sender).Tag = 0) then
    SetAutoCompleteOptions;
end;

procedure TFQuickManager.ChkDefAutoCorrectClick(Sender: TObject);
begin
  SetDefAutoCompleteOptions;
end;

procedure TFQuickManager.CmbAutoCompleteModeChange(Sender: TObject);
begin
  SetAutoCompleteOptions;
end;

procedure TFQuickManager.CmbDefAutoCompleteModeChange(Sender: TObject);
begin
  SetDefAutoCompleteOptions;
end;

procedure TFQuickManager.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFQuickManager.UpdateButtons;
begin
  SpbDelTag.Enabled := (SgWorkSpace.RowCount > 1);
end;

function TFQuickManager.QuickRec(ARow: Longint): TQuickTagRec;
begin
  result.Caption            := SgWorkSpace.Cells[0, ARow];
  result.Command            := SgWorkSpace.Cells[1, ARow];
  result.NoEdit             := (RightStr(result.Caption, 1) = '?') or
                               (SameText(LeftStr(result.Command, 4), '-GUI'));
  result.Help               := SgWorkSpace.Cells[2, ARow];
  result.AutoComp.AcOptions := word(SgWorkSpace.Objects[3, ARow]);
  result.AutoComp.SetAcList(SgWorkSpace.Cells[3, ARow]);
end;

procedure TFQuickManager.UpdateLabels(const ARow: integer);
var
  AQuickRec: TQuickTagRec;
begin
  CmbDefAutoCompleteMode.ItemIndex := Ord(GUIsettings.WSAutoComp.GetAutoCompleteMode);
  ChkDefAutoCorrect.Checked        := GUIsettings.WSAutoComp.GetAutoCorrect;
  AQuickRec := QuickRec(ARow);

  MemoAutoLines.Lines.BeginUpdate;
  ChkAutoCorrect.Tag := 1;
  ChkAutoPopulate.Tag := 1;
  try
    EdTagDesc.Text          := AQuickRec.Caption;
    EdTagDef.Text           := AQuickRec.Command;
    EdTagHint.Text          := AQuickRec.Help;
    CmbAutoCompleteMode.ItemIndex := Ord(AQuickRec.AutoComp.GetAutoCompleteMode);
    ChkAutoCorrect.Checked  := AQuickRec.AutoComp.GetAutoCorrect;
    ChkAutoPopulate.Checked := AQuickRec.AutoComp.GetAutoPopulate;
    AQuickRec.AutoComp.GetAcList(MemoAutoLines.Lines);
  finally
    MemoAutoLines.Lines.EndUpdate;
    ChkAutoCorrect.Tag := 0;
    ChkAutoPopulate.Tag := 0;
  end;
end;

procedure TFQuickManager.SaveSettings;
var
  N: integer;
begin
  SetLength(QuickTags, SgWorkSpace.RowCount);
  for N := 0 to SgWorkSpace.RowCount - 1 do
    QuickTags[N] := QuickRec(N);
end;

procedure TFQuickManager.SpbAddTagClick(Sender: TObject);
var
  P: integer;
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
    P := Pos(':', SgWorkSpace.Cells[0, SgWorkSpace.Row] );
    if (P > 0) then
      SgWorkSpace.Cells[0, SgWorkSpace.Row] := Copy(SgWorkSpace.Cells[0, SgWorkSpace.Row], P +  1);
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

procedure TFQuickManager.EdTagKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    SgWorkSpace.ColWidths[3] := 0;
    SgWorkSpace.RowCount := I;
    for N := 0 to I - 1 do
    begin
      SgWorkSpace.Cells[0, N] := QuickTags[N].Caption;
      SgWorkSpace.Cells[1, N] := QuickTags[N].Command;
      SgWorkSpace.Cells[2, N] := QuickTags[N].Help;
      SgWorkSpace.Cells[3, N] := QuickTags[N].AutoComp.AcString;
      SgWorkSpace.Objects[3, N] := pointer(QuickTags[N].AutoComp.AcOptions);
    end;
    SgWorkSpace.Row := X;
  finally
    SgWorkSpace.EndUpdate;
  end;

  UpdateButtons;
  UpdateLabels(SgWorkSpace.Row);
end;

procedure TFQuickManager.MemoAutoLinesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SgWorkSpace.Cells[3, SgWorkSpace.Row] := ReplaceAll(MemoAutoLines.Lines.Text, [#13#10, #10], ['/n', '/n'], [rfReplaceAll]);
end;

procedure TFQuickManager.PnlDetailResize(Sender: TObject);
const
  Margin = 25;
begin
  EdTagDesc.Width := PnlDetail.Width - Margin;
  EdTagDef.Width  := PnlDetail.Width - Margin;
  EdTagHint.Width := PnlDetail.Width - Margin;
end;

procedure TFQuickManager.SgWorkSpaceDrawCell(Sender: TObject; ACol, ARow: LongInt; Rect: TRect; State: TGridDrawState);
var
  ACanvas: TCanvas;
  AText: string;
begin
  AText := TStringGrid(Sender).Cells[1, ARow];
  if (SameText(LeftStr(AText, 4), '-GUI')) then
  begin
    ACanvas := TStringGrid(Sender).Canvas;
    // See MetadataListDrawCell in Main
    ACanvas.Brush.Color := clWindow;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := clWindowText;
    // Draw ourselves
    AText := TStringGrid(Sender).Cells[ACol, ARow];
    ACanvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, AText);
  end;
end;

procedure TFQuickManager.SgWorkSpaceSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  UpdateButtons;
  UpdateLabels(ARow);
end;

end.
