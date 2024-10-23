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
    CmbGroup: TComboBox;
    LblGroup: TLabel;
    Bevel1: TBevel;
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CmbGroupClick(Sender: TObject);
  private
    { Private declarations }
    Group: string;
    procedure DisplayHint(Sender: TObject);
    procedure GetCurrentValues;
  public
    { Public declarations }
    ETout, ETerr: string;
  end;

var
  FDateTimeEqual: TFDateTimeEqual;

implementation

uses Main, ExifTool, UnitLangResources;

{$R *.dfm}

procedure TFDateTimeEqual.GetCurrentValues;
var
  ETcmd: string;
  ETresult: TStringList;
begin
  Group := CmbGroup.Text;

  ETresult := TStringList.Create;
  try
    ETcmd := '-s3' + CRLF + '-f' + CRLF + CmdStr + CmdDateTimeOriginal(Group) + CRLF +
                                          CmdStr + CmdCreateDate(Group) + CRLF +
                                          CmdStr + CmdModifyDate(Group);
    ET.OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETresult, false);
    if (ETresult.Count > 2) then
    begin
      LabeledEdit1.Text := ETresult[0];
      LabeledEdit2.Text := ETresult[1];
      LabeledEdit3.Text := ETresult[2];
    end;
  finally
    ETresult.Free;
  end;
end;

procedure TFDateTimeEqual.Button2Click(Sender: TObject);
var
  ETcmd: string;
begin
  ETcmd := '';
  if RadioButton1.Checked then
    ETcmd := CmdStr + CmdDateTimeOriginal(Group) + '>' + CmdModifyDate(Group) + CRLF +
             CmdStr + CmdDateTimeOriginal(Group) + '>' + CmdCreateDate(Group);
  if RadioButton2.Checked then
    ETcmd := CmdStr + CmdCreateDate(Group) + '>' + CmdModifyDate(Group) + CRLF +
             CmdStr + CmdCreateDate(Group) + '>' + CmdDateTimeOriginal(Group);
  if RadioButton3.Checked then
    ETcmd := CmdStr + CmdModifyDate(Group) + '>' + CmdDateTimeOriginal(Group) + CRLF +
             CmdStr + CmdModifyDate(Group) + '>' + CmdCreateDate(Group);

  ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFDateTimeEqual.CmbGroupClick(Sender: TObject);
begin
  GetCurrentValues;
end;

procedure TFDateTimeEqual.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFDateTimeEqual.FormShow(Sender: TObject);
begin
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  GetCurrentValues;
  RadioButton1Click(Sender);

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  Application.OnHint := DisplayHint;

  RadioButton1.SetFocus;
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
