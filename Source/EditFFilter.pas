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
  i: smallint;
begin
  i := ListBox1.ItemIndex;
  if i > 0 then
  begin
    ListBox1.DeleteSelected;
    dec(i);
    ListBox1.ItemIndex := i;
    Button2.Enabled := (i > 0);
    Button4.Enabled := true;
  end;
end;

procedure TFEditFFilter.Button4Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TFEditFFilter.Button5Click(Sender: TObject);
var
  i, x: smallint;
begin
  with ListBox1 do
  begin
    i := ItemIndex;
    x := Items.Count - 1;
    if i > 0 then
    begin
      if Sender = Button5 then
      begin
        if i > 1 then
          Items.Exchange(i, i - 1); // Up
      end
      else
      begin
        if i < x then
          Items.Exchange(i, i + 1); // Down
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
  i, n: smallint;
begin
  Left := FMain.Left + 8;
  Top := FMain.Top + 56;
  ListBox1.Items.Clear;
  i := FMain.CBoxFileFilter.Items.Count;
  for n := 0 to i - 1 do
    ListBox1.Items.Append(FMain.CBoxFileFilter.Items[n]);
  i := FMain.CBoxFileFilter.ItemIndex;
  ListBox1.ItemIndex := -1;
  Edit1.Text := '';
  if i <> 0 then
  begin
    Edit1.Text := FMain.CBoxFileFilter.Text;
    ListBox1.ItemIndex := i;
  end;
  Button1.Enabled := (i = -1);
  Button2.Enabled := (i > 0);
  Button4.Enabled := false;
end;

procedure TFEditFFilter.ListBox1Click(Sender: TObject);
var
  i: smallint;
begin
  i := ListBox1.ItemIndex;
  Button1.Enabled := false;
  Button2.Enabled := (i > 0);
  Edit1.OnChange := nil;
  if i > 0 then
    Edit1.Text := ListBox1.Items[i];
  Edit1.OnChange := Edit1Change;
end;

end.
