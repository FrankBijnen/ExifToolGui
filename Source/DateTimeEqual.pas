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

uses Main, ExifTool;

{$R *.dfm}

const
  CmdDateOriginal = '-exif:DateTimeOriginal';
  CmdDateCreate = '-exif:CreateDate';
  CmdDateModify = '-exif:ModifyDate';
  srcTx: string[23] = '-use as source';
  dstTx: string[23] = '-and copy here';

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

  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
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
    Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
    Top := FMain.Top + FMain.GUIBorderHeight;

    if FMain.MaDontBackup.Checked then
      Label1.Caption := 'Backup: OFF'
    else
      Label1.Caption := 'Backup: ON';
    Application.OnHint := DisplayHint;

    ETcmd := '-s3' + CRLF + '-f' + CRLF + CmdDateOriginal + CRLF + CmdDateCreate + CRLF + CmdDateModify;
    ET_OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETresult);
    LabeledEdit1.Text := ETresult[0];
    LabeledEdit2.Text := ETresult[1];
    LabeledEdit3.Text := ETresult[2];
    RadioButton1.SetFocus;
  finally
    ETresult.Free;
  end;
end;

procedure TFDateTimeEqual.RadioButton1Click(Sender: TObject);
begin
  if Sender = RadioButton1 then
  begin
    RadioButton1.Caption := srcTx;
    RadioButton2.Caption := dstTx;
    RadioButton3.Caption := dstTx;
  end;
  if Sender = RadioButton2 then
  begin
    RadioButton1.Caption := dstTx;
    RadioButton2.Caption := srcTx;
    RadioButton3.Caption := dstTx;
  end;
  if Sender = RadioButton3 then
  begin
    RadioButton1.Caption := dstTx;
    RadioButton2.Caption := dstTx;
    RadioButton3.Caption := srcTx;
  end;
end;

end.
