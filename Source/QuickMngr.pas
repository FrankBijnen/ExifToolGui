unit QuickMngr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask;

type
  TFQuickManager = class(TForm)
    AdvPanel1: TPanel;
    StringGrid1: TStringGrid;
    Button1: TButton;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    LabeledEdit3: TLabeledEdit;
    StatusBar1: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
  end;

  TMyGrid = class(TStringGrid)
  public // because DeleteRow isn't published in TStringGrid
    procedure DeleteRow(ARow: longint); override;
    procedure InsertRow(ARow: longint);
  end;

var
  FQuickManager: TFQuickManager;

implementation

uses StrUtils, Main, MainDef;
{$R *.dfm}

procedure TFQuickManager.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TMyGrid.DeleteRow(ARow: longint);
begin
  inherited DeleteRow(ARow);
end;

procedure TMyGrid.InsertRow(ARow: Integer);
var
  i: smallint;
begin
  i := Row;
  while ARow < FixedRows do
    Inc(ARow);
  RowCount := RowCount + 1;
  MoveRow(RowCount - 1, ARow);
  Row := i;
  Rows[Row].Clear;
end;

procedure TFQuickManager.Button1Click(Sender: TObject);
var
  i, t, n: smallint; // Delete row
begin
  with StringGrid1 do
  begin
    n := Height div RowHeights[0]; // how many rows fit into grid
    t := TopRow;
    i := Row;
    if RowCount > 1 then
      TMyGrid(StringGrid1).DeleteRow(Row); // keep one line
    if i = RowCount then
      dec(i);
    if t > i then
    begin // scroll for one page
      dec(t, n);
      if t < 0 then
        t := 0;
    end;
    TopRow := t;
    Row := i;
    Button1.Enabled := (RowCount > 1);
  end;
end;

procedure TFQuickManager.Button2Click(Sender: TObject);
var
  i: smallint;
  tx: string; // Save changes
begin
  tx := Trim(LabeledEdit1.Text);
  LabeledEdit1.Text := tx;
  if (Length(tx) = 0) or (pos('*', tx) = 1) then
    LabeledEdit1.SetFocus
  else
  begin
    tx := Trim(LabeledEdit2.Text);
    LabeledEdit2.Text := tx;
    if (Length(tx) < 4) or (LeftStr(tx, 1) <> '-') or (RightStr(tx, 1) = '=') then
      LabeledEdit2.SetFocus
    else
      with StringGrid1 do
      begin
        i := Row;
        Cells[0, i] := LabeledEdit1.Text;
        Cells[1, i] := LabeledEdit2.Text;
        Cells[2, i] := Trim(LabeledEdit3.Text);
      end;
  end;
end;

procedure TFQuickManager.Button3Click(Sender: TObject);
var
  i: smallint;
  tx: string; // Insert row
begin
  tx := Trim(LabeledEdit1.Text);
  LabeledEdit1.Text := tx;
  if (Length(tx) = 0) or (pos('*', tx) = 1) then
    LabeledEdit1.SetFocus
  else
  begin
    tx := Trim(LabeledEdit2.Text);
    LabeledEdit2.Text := tx;
    if (Length(tx) < 4) or (pos('-', tx) <> 1) then
      LabeledEdit2.SetFocus
    else
      with StringGrid1 do
      begin
        i := Row;
        OnSelectCell := nil;
        TMyGrid(StringGrid1).InsertRow(i);
        OnSelectCell := StringGrid1SelectCell;
        Cells[0, i] := LabeledEdit1.Text;
        Cells[1, i] := LabeledEdit2.Text;
        Cells[2, i] := Trim(LabeledEdit3.Text);
      end;
  end;
end;

procedure TFQuickManager.Button5Click(Sender: TObject);
var
  i, n: smallint;
  tx: string;
begin
  with StringGrid1 do
  begin
    i := RowCount;
    SetLength(QuickTags, i);
    for n := 0 to i - 1 do
    begin
      tx := Cells[0, n];
      QuickTags[n].Caption := tx;
      QuickTags[n].NoEdit := (RightStr(tx, 1) = '?');
      tx := Cells[1, n];
      QuickTags[n].Command := tx;
      tx := UpperCase(LeftStr(tx, 4));
      QuickTags[n].NoEdit := QuickTags[n].NoEdit or (tx = '-GUI');
      QuickTags[n].Help := Cells[2, n];
    end;
  end;
  ModalResult := mrOK;
end;

procedure TFQuickManager.FormShow(Sender: TObject);
var
  i, n, x: smallint; // clLite,clDark:TColor;
begin
  Left := FMain.Left + 8;
  Top := FMain.Top + 56;
  if FMain.SpeedBtnQuick.Down then
    x := FMain.MetadataList.Row - 1
  else
    x := 0;
  i := Length(QuickTags);
  with StringGrid1 do
  begin
    ColWidths[1] := 220;
    ColWidths[2] := 220;
    RowCount := i;
    for n := 0 to i - 1 do
    begin
      Cells[0, n] := QuickTags[n].Caption;
      Cells[1, n] := QuickTags[n].Command;
      Cells[2, n] := QuickTags[n].Help;
    end;
    Row := x;
    Button1.Enabled := (RowCount > 1);
  end;
  Application.OnHint := DisplayHint;
end;

procedure TFQuickManager.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  with StringGrid1 do
  begin
    LabeledEdit1.Text := Cells[0, ARow];
    LabeledEdit2.Text := Cells[1, ARow];
    LabeledEdit3.Text := Cells[2, ARow];
  end;
end;

end.
