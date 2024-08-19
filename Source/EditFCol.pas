unit EditFCol;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask;

type
  TFEditFColumn = class(TScaleForm)
    AdvPanel1: TPanel;
    StringGrid1: TStringGrid;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
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
  public // because DeleteColumn isn't published in TStringGrid
    procedure DeleteColumn(AColumn: longint); override;
    procedure InsertColumn(AColumn: longint);
  end;

var
  FEditFColumn: TFEditFColumn;

implementation

uses Main, MainDef;

{$R *.dfm}

procedure TFEditFColumn.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TMyGrid.DeleteColumn(AColumn: longint);
begin
  inherited DeleteColumn(AColumn);
end;

procedure TMyGrid.InsertColumn(AColumn: Integer);
var
  I: integer;
begin
  I := Col;
  while AColumn < FixedCols do
    Inc(AColumn);
  ColCount := ColCount + 1;
  MoveColumn(ColCount - 1, AColumn);
  Col := I;
  Cols[Col].Clear;
end;

procedure TFEditFColumn.Button1Click(Sender: TObject);
var
  I: integer; // Delete column
begin

  with StringGrid1 do
  begin
    I := LeftCol;
    if ColCount > 1 then
      TMyGrid(StringGrid1).DeleteColumn(Col);
    LeftCol := I;
    Button1.Enabled := (ColCount > 1);
  end;
end;

procedure TFEditFColumn.Button2Click(Sender: TObject);
var
  I: integer;
  Tx: string; // Save changes
begin
  Tx := Trim(LabeledEdit1.Text);
  LabeledEdit1.Text := Tx;
  if Length(Tx) = 0 then
    LabeledEdit1.SetFocus
  else
  begin
    Tx := Trim(LabeledEdit2.Text);
    LabeledEdit2.Text := Tx;
    if (Length(Tx) < 4) or (pos('-', Tx) <> 1) or (pos(' ', Tx) > 0) then
      LabeledEdit2.SetFocus
    else
      with StringGrid1 do
      begin
        i := Col;
        Cells[i, 0] := LabeledEdit1.Text;
        Cells[i, 1] := LabeledEdit2.Text;
      end;
  end;
end;

procedure TFEditFColumn.Button3Click(Sender: TObject);
var
  I: integer;
  Tx: string; // Add column
begin
  Tx := Trim(LabeledEdit1.Text);
  LabeledEdit1.Text := Tx;
  if Length(Tx) = 0 then
    LabeledEdit1.SetFocus
  else
  begin
    Tx := Trim(LabeledEdit2.Text);
    LabeledEdit2.Text := Tx;
    if (Length(Tx) < 4) or (pos('-', Tx) <> 1) or (pos(' ', Tx) > 0) then
      LabeledEdit2.SetFocus
    else
      with StringGrid1 do
      begin
        i := Col;
        OnSelectCell := nil;
        TMyGrid(StringGrid1).InsertColumn(i);
        OnSelectCell := StringGrid1SelectCell;
        Cells[i, 0] := LabeledEdit1.Text;
        Cells[i, 1] := LabeledEdit2.Text;
      end;
  end;
end;

procedure TFEditFColumn.Button5Click(Sender: TObject);
var
  I, N: integer;
begin
  with StringGrid1 do
  begin
    I := ColCount;
    SetLength(FListColUsr, I);
    for N := 0 to I - 1 do
    begin
      FListColUsr[N].Caption := Cells[N, 0];
      FListColUsr[N].Command := Cells[N, 1];
      FListColUsr[N].Width := ColWidths[N];
      FListColUsr[N].AlignR := 0;
    end;
  end;
  ModalResult := mrOK;
end;

procedure TFEditFColumn.FormShow(Sender: TObject);
var
  I, N: integer;
  CanSelect: boolean;
begin
  Left := FMain.GetFormOffset(false).X;
  Top := FMain.GetFormOffset(false).Y;
  Width := FMain.Width - FMain.GUIBorderWidth;

  I := Length(FListColUsr);
  with StringGrid1 do
  begin
    ColCount := I;
    for N := 0 to I - 1 do
    begin
      ColWidths[N] := FListColUsr[N].Width;
      Cells[N, 0] := FListColUsr[N].Caption;
      Cells[N, 1] := FListColUsr[N].Command;
    end;
    Button1.Enabled := (ColCount > 1);
  end;
  StringGrid1SelectCell(Sender, 0, 0, CanSelect);
  Application.OnHint := DisplayHint;
end;

procedure TFEditFColumn.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  with StringGrid1 do
  begin
    LabeledEdit1.Text := Cells[ACol, 0];
    LabeledEdit2.Text := Cells[ACol, 1];
  end;
end;

end.
