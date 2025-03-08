unit QuickMngr;

interface

uses
  System.SysUtils, System.Variants, System.Classes,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Grids, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask, Vcl.Buttons,
  MainDef, UnitScaleForm,
  ExifToolsGUI_StringGrid;    // StringGrid

type
  TFQuickManager = class(TScaleForm)
    AdvPanel1: TPanel;
    SgWorkSpace: ExifToolsGUI_StringGrid.TStringGrid; // Need our own version
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
    PnlSort: TPanel;
    BtnColumnDown: TButton;
    BtnColumnUp: TButton;
    SpbDefaults: TSpeedButton;
    PnlFiller: TPanel;
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
    procedure BtnColumnDownClick(Sender: TObject);
    procedure BtnColumnUpClick(Sender: TObject);
    procedure SpbDefaultsClick(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    procedure CreateDefaults;
    procedure UpdateButtons;
    procedure UpdateLabels(const ARow: integer);
    procedure UpdateGrid(FocusRow: integer);
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
  System.StrUtils, System.IniFiles, Vcl.Themes,
  Main, ExifTool, ExifToolsGUI_Utils, ExifToolsGui_AutoComplete, UFrmTagNames, UnitLangResources;

{$R *.dfm}

procedure TFQuickManager.CreateDefaults;
var
  GUIini: TMemIniFile;
begin
  GUIini := TMemIniFile.Create('NUL', TEncoding.UTF8);
  try
    ReadWorkSpaceTags(GUIini, true);
    UpdateGrid(1);
  finally
    GUIini.Free;
  end;
end;

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
// acDefault not used
  GUIsettings.WSAutoComp.SetAcOptions(TAutoCompleteMode(CmbDefAutoCompleteMode.ItemIndex +1),
                                      ChkDefAutoCorrect.Checked,
                                      true);
end;

procedure TFQuickManager.BtnColumnUpClick(Sender: TObject);
begin
  SgWorkSpace.MoveUp(SgWorkSpace.Row);
end;

procedure TFQuickManager.BtnColumnDownClick(Sender: TObject);
begin
  SgWorkSpace.MoveDown(SgWorkSpace.Row);
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
  result.Command            := ReplaceVetoTag(SgWorkSpace.Cells[1, ARow]);
  result.NoEdit             := (RightStr(result.Caption, 1) = '?') or
                               (StartsText(GUI_PREF, result.Command));
  result.Help               := SgWorkSpace.Cells[2, ARow];
  result.AutoComp.AcOptions := word(SgWorkSpace.Objects[3, ARow]);
  result.AutoComp.SetAcList(SgWorkSpace.Cells[3, ARow]);
end;

procedure TFQuickManager.UpdateLabels(const ARow: integer);
var
  AQuickRec: TQuickTagRec;
begin
// acDefault not used
  CmbDefAutoCompleteMode.ItemIndex := Ord(GUIsettings.WSAutoComp.GetAutoCompleteMode) -1;
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

procedure TFQuickManager.UpdateGrid(FocusRow: integer);
var
  Index: integer;
begin
  SgWorkSpace.BeginUpdate;
  try
    SgWorkSpace.RowCount := Length(QuickTags);
    for Index := 0 to SgWorkSpace.RowCount - 1 do
    begin
      SgWorkSpace.Cells[0, Index] := QuickTags[Index].Caption;
      SgWorkSpace.Cells[1, Index] := QuickTags[Index].Command;
      SgWorkSpace.Cells[2, Index] := QuickTags[Index].Help;
      SgWorkSpace.Cells[3, Index] := QuickTags[Index].AutoComp.AcString;
      SgWorkSpace.Objects[3, Index] := pointer(QuickTags[Index].AutoComp.AcOptions);
    end;
    if (FocusRow < SgWorkSpace.RowCount) then
      SgWorkSpace.Row := FocusRow
    else
      SgWorkSpace.Row := SgWorkSpace.RowCount;
  finally
    SgWorkSpace.EndUpdate;
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

procedure TFQuickManager.SpbDefaultsClick(Sender: TObject);
begin
  if (MessageDlgEx(StrDeleteCustom, '', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel]) = IdCancel) then
    exit;

  CreateDefaults;
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
  X: integer;
begin
  Application.OnHint := DisplayHint;
  Left := FMain.GetFormOffset(false).X;
  Top := FMain.GetFormOffset(false).Y;
  SgWorkSpace.ColWidths[1] := 220;
  SgWorkSpace.ColWidths[2] := 220;
  SgWorkSpace.ColWidths[3] := 0;

  if FMain.SpeedBtnQuick.Down then
    X := FMain.MetadataList.Row - 1
  else
    X := 0;

  UpdateGrid(X);
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
  if (StartsText(GUI_PREF, AText)) then
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
