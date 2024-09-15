unit DateTimeEqual;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Mask;

type
  TFDateTimeEqual = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
  var
    ETout, ETerr: string;
  end;

var
  FDateTimeEqual: TFDateTimeEqual;

implementation

uses Main, ExifTool, UnitLangResources;

{$R *.dfm}

const
  CmdDateOriginal = '-exif:DateTimeOriginal';
  CmdDateCreate = '-exif:CreateDate';
  CmdDateModify = '-exif:ModifyDate';

var
  ETcmd: string;

procedure TFDateTimeEqual.Button2Click(Sender: TObject);
begin
  ETcmd := '';
  if RadioButton1.Checked then
    ETcmd := '-exif:DateTimeOriginal>exif:ModifyDate' + CRLF + '-exif:DateTimeOriginal>exif:CreateDate';
  if RadioButton2.Checked then
    ETcmd := '-exif:CreateDate>exif:ModifyDate' + CRLF + '-exif:CreateDate>exif:DateTimeOriginal';
  if RadioButton3.Checked then
    ETcmd := '-exif:ModifyDate>exif:DateTimeOriginal' + CRLF + '-exif:ModifyDate>exif:CreateDate';

  ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFDateTimeEqual.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFDateTimeEqual.FormShow(Sender: TObject);
var
  ETresult: TStringList;
begin
  ETresult := TStringList.Create;
  try
    Left := FMain.GetFormOffset.X;
    Top := FMain.GetFormOffset.Y;

    RadioButton1Click(Sender);

    if FMain.MaDontBackup.Checked then
      Label1.Caption := StrBackupOFF
    else
      Label1.Caption := StrBackupON;
    Application.OnHint := DisplayHint;

    ETcmd := '-s3' + CRLF + '-f' + CRLF + CmdDateOriginal + CRLF + CmdDateCreate + CRLF + CmdDateModify;
    ET.OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETresult, false);
    if (ETresult.Count > 2) then
    begin
      LabeledEdit1.Text := ETresult[0];
      LabeledEdit2.Text := ETresult[1];
      LabeledEdit3.Text := ETresult[2];
    end;
    RadioButton1.SetFocus;
  finally
    ETresult.Free;
  end;
end;

procedure TFDateTimeEqual.RadioButton1Click(Sender: TObject);
begin
  if Sender = RadioButton1 then
  begin
    RadioButton1.Caption := StrUseSrc;
    RadioButton2.Caption := StrUseDest;
    RadioButton3.Caption := StrUseDest;
  end;
  if Sender = RadioButton2 then
  begin
    RadioButton1.Caption := StrUseDest;
    RadioButton2.Caption := StrUseSrc;
    RadioButton3.Caption := StrUseDest;
  end;
  if Sender = RadioButton3 then
  begin
    RadioButton1.Caption := StrUseDest;
    RadioButton2.Caption := StrUseDest;
    RadioButton3.Caption := StrUseSrc;
  end;
end;

end.
