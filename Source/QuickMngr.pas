unit QuickMngr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask;

type
  TFQuickManager = class(TScaleForm)
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
  Indx: integer;
begin
  Indx := Row;
  while ARow < FixedRows do
    Inc(ARow);
  RowCount := RowCount + 1;
  MoveRow(RowCount - 1, ARow);
  Row := Indx;
  Rows[Row].Clear;
end;

procedure TFQuickManager.Button1Click(Sender: TObject);
var
  I, T, N: integer; // Delete row
begin
  with StringGrid1 do
  begin
    N := Height div RowHeights[0]; // how many rows fit into grid
    T := TopRow;
    I := Row;
    if RowCount > 1 then
      TMyGrid(StringGrid1).DeleteRow(Row); // keep one line
    if I = RowCount then
      dec(I);
    if T > I then
    begin // scroll for one page
      dec(T, N);
      if T < 0 then
        T := 0;
    end;
    TopRow := T;
    Row := I;
    Button1.Enabled := (RowCount > 1);
  end;
end;

procedure TFQuickManager.Button2Click(Sender: TObject);
var
  I: integer;
  Tx: string; // Save changes
begin
  Tx := Trim(LabeledEdit1.Text);
  LabeledEdit1.Text := Tx;
  if (Length(Tx) = 0) or (pos('*', Tx) = 1) then
    LabeledEdit1.SetFocus
  else
  begin
    Tx := Trim(LabeledEdit2.Text);
    LabeledEdit2.Text := Tx;
    if (Length(Tx) < 4) or (LeftStr(Tx, 1) <> '-') or (RightStr(Tx, 1) = '=') then
      LabeledEdit2.SetFocus
    else
      with StringGrid1 do
      begin
        I := Row;
        Cells[0, I] := LabeledEdit1.Text;
        Cells[1, I] := LabeledEdit2.Text;
        Cells[2, I] := Trim(LabeledEdit3.Text);
      end;
  end;
end;

procedure TFQuickManager.Button3Click(Sender: TObject);
var
  I: integer;
  Tx: string; // Insert row
begin
  Tx := Trim(LabeledEdit1.Text);
  LabeledEdit1.Text := Tx;
  if (Length(Tx) = 0) or (pos('*', Tx) = 1) then
    LabeledEdit1.SetFocus
  else
  begin
    Tx := Trim(LabeledEdit2.Text);
    LabeledEdit2.Text := Tx;
    if (Length(Tx) < 4) or (pos('-', Tx) <> 1) then
      LabeledEdit2.SetFocus
    else
      with StringGrid1 do
      begin
        I := Row;
        OnSelectCell := nil;
        TMyGrid(StringGrid1).InsertRow(I);
        OnSelectCell := StringGrid1SelectCell;
        Cells[0, I] := LabeledEdit1.Text;
        Cells[1, I] := LabeledEdit2.Text;
        Cells[2, I] := Trim(LabeledEdit3.Text);
      end;
  end;
end;

procedure TFQuickManager.Button5Click(Sender: TObject);
var
  I, N: integer;
  Tx: string;
begin
  with StringGrid1 do
  begin
    I := RowCount;
    SetLength(QuickTags, I);
    for N := 0 to I - 1 do
    begin
      Tx := Cells[0, N];
      QuickTags[N].Caption := Tx;
      QuickTags[N].NoEdit := (RightStr(Tx, 1) = '?');
      Tx := Cells[1, N];
      QuickTags[N].Command := Tx;
      Tx := UpperCase(LeftStr(Tx, 4));
      QuickTags[N].NoEdit := QuickTags[N].NoEdit or (Tx = '-GUI');
      QuickTags[N].Help := Cells[2, N];
    end;
  end;
  ModalResult := mrOK;
end;

procedure TFQuickManager.FormShow(Sender: TObject);
var
  I, N, X: integer;
begin
//TODO
  Left := FMain.Left + 8;
  Top := FMain.Top + 56;
  if FMain.SpeedBtnQuick.Down then
    X := FMain.MetadataList.Row - 1
  else
    X := 0;
  I := Length(QuickTags);
  with StringGrid1 do
  begin
    ColWidths[1] := 220;
    ColWidths[2] := 220;
    RowCount := I;
    for N := 0 to I - 1 do
    begin
      Cells[0, N] := QuickTags[N].Caption;
      Cells[1, N] := QuickTags[N].Command;
      Cells[2, N] := QuickTags[N].Help;
    end;
    Row := X;
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
