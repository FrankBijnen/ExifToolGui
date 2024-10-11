unit EditFFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFEditFFilter = class(TScaleForm)
    AdvPanel1: TPanel;
    EdFilter: TEdit;
    BtnAdd: TButton;
    LbFilter: TListBox;
    BtnCancel: TButton;
    BtnSave: TButton;
    BtnUp: TButton;
    BtnDown: TButton;
    BtnDel: TButton;
    BtnUpdate: TButton;
    procedure FormShow(Sender: TObject);
    procedure EdFilterChange(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure LbFilterClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnUpdateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FEditFFilter: TFEditFFilter;

implementation

uses Main, MainDef, ExifToolsGUI_Utils;

{$R *.dfm}

procedure TFEditFFilter.BtnAddClick(Sender: TObject);
begin
  LbFilter.Items.Append(EdFilter.Text);
  EdFilter.Text := '';
end;

procedure TFEditFFilter.BtnDelClick(Sender: TObject);
var
  Indx: integer;
begin
  Indx := LbFilter.ItemIndex;
  if Indx > 0 then
  begin
    LbFilter.DeleteSelected;
    Dec(Indx);
    LbFilter.ItemIndex := Indx;
    BtnDel.Enabled := (Indx > 0);
  end;
end;

procedure TFEditFFilter.BtnSaveClick(Sender: TObject);
begin
  GUIsettings.FilterSel := LbFilter.ItemIndex;
  GUIsettings.FileFilters := LbFilter.Items.Text;
  ModalResult := mrOK;
end;

procedure TFEditFFilter.BtnUpClick(Sender: TObject);
var
  I, X: integer;
begin
  with LbFilter do
  begin
    I := ItemIndex;
    X := Items.Count - 1;
    if I > 0 then
    begin
      if Sender = BtnUp then
      begin
        if I > 1 then
          Items.Exchange(I, I - 1); // Up
      end
      else
      begin
        if I < X then
          Items.Exchange(I, I + 1); // Down
      end;
    end;
  end;
end;

procedure TFEditFFilter.BtnUpdateClick(Sender: TObject);
begin
  LbFilter.Items[LbFilter.ItemIndex] := EdFilter.Text;
  EdFilter.Text := '';
end;

procedure TFEditFFilter.EdFilterChange(Sender: TObject);
begin
  BtnAdd.Enabled := (Length(Trim(EdFilter.Text)) > 2);
  BtnUpdate.Enabled := BtnAdd.Enabled;
end;

procedure TFEditFFilter.FormShow(Sender: TObject);
begin
  Left := FMain.GetFormOffset(false).X;
  Top := FMain.GetFormOffset(false).Y;
  LbFilter.Items.Text := GUIsettings.FileFilters;
  LbFilter.ItemIndex := -1;
  EdFilter.Text := '';
  if (GUIsettings.FilterSel > -1) and
     (GUIsettings.FilterSel < LbFilter.Items.Count) then
    LbFilter.ItemIndex := GUIsettings.FilterSel;
  LbFilterClick(Sender);
end;

procedure TFEditFFilter.LbFilterClick(Sender: TObject);
begin
  BtnAdd.Enabled := false;
  BtnUpdate.Enabled := false;
  BtnDel.Enabled := (LbFilter.ItemIndex > 0);
  EdFilter.OnChange := nil;
  if LbFilter.ItemIndex > 0 then
    EdFilter.Text := LbFilter.Items[LbFilter.ItemIndex]
  else
    EdFilter.Text := SHOWALL;
  EdFilter.OnChange := EdFilterChange;
end;

end.
