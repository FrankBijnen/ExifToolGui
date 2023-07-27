unit LogWin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFLogWin = class(TForm)
    MemoLog: TMemo;
    procedure FormCreate(Sender: TObject);
  protected
    // procedure CreateParams(var Params: TCreateParams); override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FLogWin: TFLogWin;

implementation

uses Main, MainDef;

{$R *.dfm}

procedure TFLogWin.FormCreate(Sender: TObject);
begin
  ReadGUILog;
end;

end.
