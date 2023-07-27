unit DateTimeShift;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFDateTimeShift = class(TForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    MaskEdit1: TMaskEdit;
    Label2: TLabel;
    CheckBox4: TCheckBox;
    LabeledEdit4: TLabeledEdit;
    CheckBox5: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure MaskEdit1Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
    var ETouts, ETerrs: string;
  end;

var
  FDateTimeShift: TFDateTimeShift;

implementation

uses Main, ExifTool, DateUtils;
{$R *.dfm}

const
  CmdDateOriginal = '-exif:DateTimeOriginal';
  CmdDateCreate = '-exif:CreateDate';
  CmdDateModify = '-exif:ModifyDate';

var
  ETcmd: string;
  DTstr: string[23];
  DTx: TDateTime;
  Y, M, D, hh, mm, ss, tt: word;
  DateTimeOK: boolean;

procedure TFDateTimeShift.Button2Click(Sender: TObject);
var
  PN: string[3];
begin
  if CheckBox4.Checked then
    PN := '+='
  else
    PN := '-=';
  if (CheckBox1.Checked) and (CheckBox2.Checked) and (CheckBox3.Checked) then
    ETcmd := '-exif:AllDates' + PN + MaskEdit1.EditText + CRLF
  else
  begin
    ETcmd := '';
    if CheckBox1.Checked then
      ETcmd := CmdDateOriginal + PN + MaskEdit1.EditText + CRLF;
    if CheckBox2.Checked then
      ETcmd := ETcmd + CmdDateCreate + PN + MaskEdit1.EditText + CRLF;
    if CheckBox3.Checked then
      ETcmd := ETcmd + CmdDateModify + PN + MaskEdit1.EditText + CRLF;
  end;

  Y := length(ETcmd);
  SetLength(ETcmd, Y - 2); // remove last CRLF
  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETouts, ETerrs);
  FMain.UpdateLogWin(ETouts, ETerrs);
  if CheckBox5.Checked then
    ET_OpenExec('-FileModifyDate<Exif:DateTimeOriginal', FMain.GetSelectedFiles);
  ModalResult := mrOK;
end;

procedure TFDateTimeShift.CheckBox1Click(Sender: TObject);
begin
  Button2.Enabled := (CheckBox1.Checked) or (CheckBox2.Checked) or
    (CheckBox3.Checked);
end;

procedure TFDateTimeShift.CheckBox4Click(Sender: TObject);
begin
  with CheckBox4 do
    if Checked then
      Caption := '=Increment'
    else
      Caption := '=Decrement';
  MaskEdit1Change(Sender);
end;

procedure TFDateTimeShift.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFDateTimeShift.FormShow(Sender: TObject);
var
  ETResult: TStringList;
begin
  ETResult := TStringList.Create;
  try
    Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
    Top := FMain.Top + FMain.GUIBorderHeight;

    if FMain.MDontBackup.Checked then
      Label1.Caption := 'Backup: OFF'
    else
      Label1.Caption := 'Backup: ON';
    Application.OnHint := DisplayHint;

    ETcmd := '-s3' + CRLF + '-f' + CRLF + CmdDateOriginal + CRLF + CmdDateCreate
      + CRLF + CmdDateModify;
    ET_OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETResult);
    // .SelectedFiles[0]);

    LabeledEdit1.Text := ETResult[0];
    LabeledEdit2.Text := ETResult[1];
    LabeledEdit3.Text := ETResult[2];

    DTstr := LabeledEdit1.Text; // Check DateTimeOriginal
    Y := StrToIntDef(Copy(DTstr, 1, 4), 0);
    M := StrToIntDef(Copy(DTstr, 6, 2), 0);
    D := StrToIntDef(Copy(DTstr, 9, 2), 0);
    hh := StrToIntDef(Copy(DTstr, 12, 2), 0);
    mm := StrToIntDef(Copy(DTstr, 15, 2), 0);
    ss := StrToIntDef(Copy(DTstr, 18, 2), 0);
    DateTimeOK := (Y * M * D <> 0);
    if DateTimeOK then
    begin
      DTx := EncodeDateTime(Y, M, D, hh, mm, ss, 0);
      LabeledEdit4.Text := LabeledEdit1.Text;
    end
    else
      LabeledEdit4.Clear;
    MaskEdit1.Clear;
    MaskEdit1.SetFocus;
  finally
    ETResult.Free;
  end;
end;

procedure TFDateTimeShift.MaskEdit1Change(Sender: TObject);
var
  Yd, Md, Dd, hhd, mmd, ssd, i: smallint;
  NewDT: TDateTime;
begin
  if DateTimeOK then
  begin
    if CheckBox4.Checked then
      i := 1
    else
      i := -1;
    DTstr := MaskEdit1.EditText;
    Yd := StrToIntDef(Copy(DTstr, 1, 4), 0) * i;
    Md := StrToIntDef(Copy(DTstr, 6, 2), 0) * i;
    Dd := StrToIntDef(Copy(DTstr, 9, 2), 0) * i;
    hhd := StrToIntDef(Copy(DTstr, 12, 2), 0) * i;
    mmd := StrToIntDef(Copy(DTstr, 15, 2), 0) * i;
    ssd := StrToIntDef(Copy(DTstr, 18, 2), 0) * i;

    NewDT := IncYear(DTx, Yd); // get original DateTime here
    NewDT := IncMonth(NewDT, Md);
    NewDT := IncDay(NewDT, Dd);
    NewDT := IncHour(NewDT, hhd);
    NewDT := IncMinute(NewDT, mmd);
    NewDT := IncSecond(NewDT, ssd);

    DecodeDateTime(NewDT, Y, M, D, hh, mm, ss, tt);
    DTstr := IntToStr(Y) + ':';
    if M < 10 then
      DTstr := DTstr + '0';
    DTstr := DTstr + IntToStr(M) + ':';
    if D < 10 then
      DTstr := DTstr + '0';
    DTstr := DTstr + IntToStr(D) + ' ';
    if hh < 10 then
      DTstr := DTstr + '0';
    DTstr := DTstr + IntToStr(hh) + ':';
    if mm < 10 then
      DTstr := DTstr + '0';
    DTstr := DTstr + IntToStr(mm) + ':';
    if ss < 10 then
      DTstr := DTstr + '0';
    DTstr := DTstr + IntToStr(ss);
    LabeledEdit4.Text := DTstr;
  end;
end;

end.
