unit CopyMeta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFCopyMetadata = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FCopyMetadata: TFCopyMetadata;

implementation

uses Main, UnitLangResources;

{$R *.dfm}

procedure TFCopyMetadata.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  Application.OnHint := DisplayHint;
end;

procedure TFCopyMetadata.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

end.
