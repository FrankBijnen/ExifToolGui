unit FFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses Main;
{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
var i,n:smallint;
begin
  i:=FMain.CBoxFileFilter.Items.Count;
  for n:=0 to i-1 do ListBox1.Items.Append(FMain.CBoxFileFilter.Items[n]);
end;

end.
