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
    Edit1: TEdit;
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure FormShow(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FEditFFilter: TFEditFFilter;

implementation

uses Main;

{$R *.dfm}

procedure TFEditFFilter.Button1Click(Sender: TObject);
begin
  ListBox1.Items.Append(Edit1.Text);
  Edit1.Text := '';
  Button4.Enabled := true;
end;

procedure TFEditFFilter.Button2Click(Sender: TObject);
var
  Indx: integer;
begin
  Indx := ListBox1.ItemIndex;
  if Indx > 0 then
  begin
    ListBox1.DeleteSelected;
    dec(Indx);
    ListBox1.ItemIndex := Indx;
    Button2.Enabled := (Indx > 0);
    Button4.Enabled := true;
  end;
end;

procedure TFEditFFilter.Button4Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TFEditFFilter.Button5Click(Sender: TObject);
var
  I, X: integer;
begin
  with ListBox1 do
  begin
    I := ItemIndex;
    X := Items.Count - 1;
    if I > 0 then
    begin
      if Sender = Button5 then
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

procedure TFEditFFilter.Edit1Change(Sender: TObject);
begin
  Button1.Enabled := (Length(Trim(Edit1.Text)) > 2);
end;

procedure TFEditFFilter.FormShow(Sender: TObject);
var
  I, N: integer;
begin
  Left := FMain.GetFormOffset(false).X;
  Top := FMain.GetFormOffset(false).Y;
  ListBox1.Items.Clear;
  I := FMain.CBoxFileFilter.Items.Count;
  for N := 0 to I - 1 do
    ListBox1.Items.Append(FMain.CBoxFileFilter.Items[N]);
  I := FMain.CBoxFileFilter.ItemIndex;
  ListBox1.ItemIndex := -1;
  Edit1.Text := '';
  if I <> 0 then
  begin
    Edit1.Text := FMain.CBoxFileFilter.Text;
    ListBox1.ItemIndex := I;
  end;
  Button1.Enabled := (I = -1);
  Button2.Enabled := (I > 0);
  Button4.Enabled := false;
end;

procedure TFEditFFilter.ListBox1Click(Sender: TObject);
var
  Indx: integer;
begin
  Indx := ListBox1.ItemIndex;
  Button1.Enabled := false;
  Button2.Enabled := (Indx > 0);
  Edit1.OnChange := nil;
  if Indx > 0 then
    Edit1.Text := ListBox1.Items[Indx];
  Edit1.OnChange := Edit1Change;
end;

end.
