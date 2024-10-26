unit EditFFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.CheckLst;

type
  TFEditFFilter = class(TScaleForm)
    AdvPanel1: TPanel;
    EdFilter: TEdit;
    BtnAdd: TButton;
    LbFilter: TCheckListBox;
    BtnUp: TButton;
    BtnDown: TButton;
    BtnDel: TButton;
    BtnUpdate: TButton;
    PnlBottom: TPanel;
    BtnCancel: TBitBtn;
    BtnOK: TBitBtn;
    Label1: TLabel;
    BevStartupUse: TBevel;
    BtnDefault: TButton;
    procedure FormShow(Sender: TObject);
    procedure EdFilterChange(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure LbFilterClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnUpdateClick(Sender: TObject);
    procedure LbFilterClickCheck(Sender: TObject);
    procedure BtnDefaultClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadListBox;
  public
    { Public declarations }
  end;

var
  FEditFFilter: TFEditFFilter;

implementation

uses
  System.StrUtils,
  Main, MainDef, ExifToolsGUI_Utils, UnitLangResources;

{$R *.dfm}

procedure TFEditFFilter.LoadListBox;
begin
  LbFilter.Items.Text := GUIsettings.FileFilters;
  LbFilter.ItemIndex := -1;
  if (GUIsettings.FilterStartup < LbFilter.Items.Count) then
    LbFilter.Checked[GUIsettings.FilterStartup] := true;
  EdFilter.Text := '';

  if (GUIsettings.FilterSel > -1) and
     (GUIsettings.FilterSel < LbFilter.Items.Count) then
    LbFilter.ItemIndex := GUIsettings.FilterSel;
  LbFilterClick(LbFilter);
end;

procedure TFEditFFilter.BtnAddClick(Sender: TObject);
begin
  LbFilter.Items.Append(EdFilter.Text);
  EdFilter.Text := '';
end;

procedure TFEditFFilter.BtnDefaultClick(Sender: TObject);
begin
  GUIsettings.FileFilters := StrShowAllFiles + #10 + StringReplace(DefFileFilter, '|', #10, [rfReplaceAll]);
  GUIsettings.FilterStartup := 0;
  LoadListBox;
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

procedure TFEditFFilter.BtnOkClick(Sender: TObject);
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
        begin
          Items.Exchange(I, I - 1); // Up
          if (I = GUIsettings.FilterStartup) then
            Dec(GUIsettings.FilterStartup);
        end;
      end
      else
      begin
        if I < X then
        begin
          Items.Exchange(I, I + 1); // Down
          if (I = GUIsettings.FilterStartup) then
            Inc(GUIsettings.FilterStartup);
        end;
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
  LoadListBox;
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
    EdFilter.Text := StrShowAllFiles;
  EdFilter.OnChange := EdFilterChange;
end;

procedure TFEditFFilter.LbFilterClickCheck(Sender: TObject);
var
  Index: integer;
begin
  if (LbFilter.ItemIndex < 0) or
     (LbFilter.ItemIndex > LbFilter.Items.Count -1) then
    exit;

  if (ContainsText(LbFilter.Items[LbFilter.ItemIndex], '/s')) then
    MessageDlgEx('Setting this item as startup could potentially increase startup time', '',
                 TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK]);

  GUIsettings.FilterStartup := LbFilter.ItemIndex;
  LbFilter.Items.BeginUpdate;
  try
    for Index := 0 to LbFilter.Items.Count -1 do
    begin
      if (Index <> GUIsettings.FilterStartup) then
        LbFilter.Checked[Index] := false;
    end;
  finally
    LbFilter.Items.EndUpdate;
  end;
end;

end.
