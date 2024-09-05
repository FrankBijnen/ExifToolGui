unit DateTimeShift;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFDateTimeShift = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    LblEdOriginal: TLabeledEdit;
    LblEdCreate: TLabeledEdit;
    LblEdModify: TLabeledEdit;
    ChkShiftOriginal: TCheckBox;
    ChkShiftCreate: TCheckBox;
    ChkShiftModify: TCheckBox;
    MeShiftAmount: TMaskEdit;
    Label2: TLabel;
    ChkIncrement: TCheckBox;
    ChkFileModified: TCheckBox;
    BtnCancel: TButton;
    BtnExecute: TButton;
    Label1: TLabel;
    ChkFileCreated: TCheckBox;
    DtPickDateResult: TDateTimePicker;
    Label3: TLabel;
    DtPickTimeResult: TDateTimePicker;
    procedure FormShow(Sender: TObject);
    procedure ChkShiftOriginalClick(Sender: TObject);
    procedure ChkIncrementClick(Sender: TObject);
    procedure MeShiftAmountChange(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure DtPickDateResultUserInput(Sender: TObject; const UserString: string; var DateAndTime: TDateTime; var AllowChange: Boolean);
    procedure DtPickResultChange(Sender: TObject);
    procedure DtPickTimeResultUserInput(Sender: TObject; const UserString: string; var DateAndTime: TDateTime;
      var AllowChange: Boolean);
  private
    { Private declarations }
    ETcmd: string;
    ETouts: string;
    ETerrs: string;
    DateSample: TDateTime;
    NewDateSample: TDateTime;
    DateTimeOK: boolean;
    procedure SetMaskEdit(Y, M, D, hh, mm, ss: integer);
    procedure ComputeDiff(NDate: TdateTime);
    procedure GetDateTimeOriginal;
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FDateTimeShift: TFDateTimeShift;

implementation

uses Main, ExifTool, ExifToolsGUI_Utils, System.DateUtils, UnitLangResources, System.Types;

{$R *.dfm}

const
  CmdDateOriginal = '-exif:DateTimeOriginal';
  CmdDateCreate = '-exif:CreateDate';
  CmdDateModify = '-exif:ModifyDate';


procedure TFDateTimeShift.BtnExecuteClick(Sender: TObject);
var
  PN: string[3];
begin
  if ChkIncrement.Checked then
    PN := '+='
  else
    PN := '-=';

  ETcmd := '';
  if (ChkShiftOriginal.Checked) and (ChkShiftCreate.Checked) and (ChkShiftModify.Checked) then
    ETcmd := '-exif:AllDates' + PN + MeShiftAmount.EditText + CRLF
  else
  begin
    if (CompareDateTime(NewDateSample, DateSample) <> EqualsValue)  then
    begin
      if ChkShiftOriginal.Checked then
        ETcmd := CmdDateOriginal + PN + MeShiftAmount.EditText;
      if ChkShiftCreate.Checked then
        ETcmd := EndsWithCRLF(ETcmd) + CmdDateCreate + PN + MeShiftAmount.EditText;
      if ChkShiftModify.Checked then
        ETcmd := EndsWithCRLF(ETcmd) + CmdDateModify + PN + MeShiftAmount.EditText;
    end;
  end;
  // ShiftDates in Exif?
  if (ETcmd <> '') then
    ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETouts, ETerrs);

  // Correct FileDates?
  ETcmd := '';
  if ChkFileModified.Checked then
    ETcmd := '-FileModifyDate<Exif:DateTimeOriginal';
  if ChkFileCreated.Checked then
    ETcmd := EndsWithCRLF(ETcmd) + '-FileCreateDate<Exif:DateTimeOriginal';
  if (ETcmd <> '') then
    ET_OpenExec(Etcmd, FMain.GetSelectedFiles);

  ModalResult := mrOK;
end;

procedure TFDateTimeShift.ChkShiftOriginalClick(Sender: TObject);
begin
  BtnExecute.Enabled := (ChkShiftOriginal.Checked) or (ChkShiftCreate.Checked) or (ChkShiftModify.Checked) or
                        (ChkFileModified.Checked) or (ChkFileCreated.Checked);
end;

procedure TFDateTimeShift.ChkIncrementClick(Sender: TObject);
begin

  if (ChkIncrement.Checked) then
    ChkIncrement.Caption := '=' + StrIncrement
  else
     ChkIncrement.Caption := '=' + StrDecrement;

  MeShiftAmountChange(Sender);
end;

procedure TFDateTimeShift.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFDateTimeShift.SetMaskEdit(Y, M, D, hh, mm, ss: integer);
begin
  MeShiftAmount.Tag := 1; // Dont call maskedit1 change
  try
    MeShiftAmount.EditText := Format('%.4d:%.2d:%.2d %.2d:%.2d:%.2d',
                                     [Y, M, D, hh, mm, ss]);
  finally
    MeShiftAmount.Tag := 0;
  end;
end;

procedure TFDateTimeShift.ComputeDiff(NDate: TdateTime);
var
  F, T: TDateTime;
  Y, M, D, hh, mm, ss: integer;
begin
  NewDateSample := NDate;
  if (CompareDateTime(DateSample, NewDateSample) = GreaterThanValue)  then
  begin
    F := DateSample;
    T := NewDateSample;
    ChkIncrement.Checked := false;
  end
  else
  begin
    F := NewDateSample;
    T := DateSample;
    ChkIncrement.Checked := true;
  end;

  Y := YearsBetween(F, T);
  T := IncYear(T, Y);

  M := MonthsBetween(F, T);
  T := IncMonth(T, M);

  D := DaysBetween(F, T);
  T := IncDay(T, D);

  hh := HoursBetween(F, T);
  T := IncHour(T, hh);

  mm := MinutesBetween(F, T);
  T := IncMinute(T, mm);

  ss := SecondsBetween(F, T);

  SetMaskEdit(Y, M, D, hh, mm, ss);
end;

procedure TFDateTimeShift.DtPickResultChange(Sender: TObject);
begin
  ComputeDiff(DtPickDateResult.Date + DtPickTimeResult.Time);
end;

procedure TFDateTimeShift.DtPickDateResultUserInput(Sender: TObject; const UserString: string; var DateAndTime: TDateTime;
  var AllowChange: Boolean);
begin
  ComputeDiff(DateAndTime + DtPickTimeResult.Time);
end;

procedure TFDateTimeShift.DtPickTimeResultUserInput(Sender: TObject; const UserString: string; var DateAndTime: TDateTime;
  var AllowChange: Boolean);
begin
  ComputeDiff(DtPickDateResult.Date + DateAndTime);
end;

procedure TFDateTimeShift.GetDateTimeOriginal;
var
  DTstr: string;
  Y, M, D, hh, mm, ss: integer;
begin
  DTstr := LblEdOriginal.Text; // Check DateTimeOriginal
  Y := StrToIntDef(Copy(DTstr, 1, 4), 0);
  M := StrToIntDef(Copy(DTstr, 6, 2), 0);
  D := StrToIntDef(Copy(DTstr, 9, 2), 0);
  hh := StrToIntDef(Copy(DTstr, 12, 2), 0);
  mm := StrToIntDef(Copy(DTstr, 15, 2), 0);
  ss := StrToIntDef(Copy(DTstr, 18, 2), 0);
  DateTimeOK := (Y * M * D <> 0);
  if DateTimeOK then
  begin
    DateSample := EncodeDateTime(Y, M, D, hh, mm, ss, 0);
    DtPickDateResult.Date := DateSample;
    DtPickTimeResult.Date := DateSample;
  end;
end;

procedure TFDateTimeShift.FormShow(Sender: TObject);
var
  ETResult: TStringList;
begin
  ETResult := TStringList.Create;
  try
    Left := FMain.GetFormOffset.X;
    Top := FMain.GetFormOffset.Y;
    if FMain.MaDontBackup.Checked then
      Label1.Caption := StrBackupOFF
    else
      Label1.Caption := StrBackupON;

    ChkFileModified.Checked := FMain.MaPreserveDateMod.Checked;
    ChkFileCreated.Checked := true;

    Application.OnHint := DisplayHint;

    ETcmd := '-s3' + CRLF + '-f' + CRLF + CmdDateOriginal + CRLF + CmdDateCreate + CRLF + CmdDateModify;
    ET_OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETResult, false);
    if (ETResult.Count > 2) then
    begin
      LblEdOriginal.Text := ETResult[0];
      LblEdCreate.Text := ETResult[1];
      LblEdModify.Text := ETResult[2];
    end;
    GetDateTimeOriginal;
    ChkIncrementClick(Sender);
    MeShiftAmount.Clear;
    MeShiftAmount.SetFocus;
  finally
    ETResult.Free;
  end;
end;

procedure TFDateTimeShift.MeShiftAmountChange(Sender: TObject);
var
  Yd, Md, Dd, hhd, mmd, ssd, I: integer;
  NewDT: TDateTime;
  DTstr: string;
begin
  if not DateTimeOK then
    exit;

  if ChkIncrement.Checked then
    I := 1
  else
    I := -1;

  DTstr := MeShiftAmount.EditText;
  Yd := StrToIntDef(Copy(DTstr, 1, 4), 0) * I;
  Md := StrToIntDef(Copy(DTstr, 6, 2), 0) * I;
  Dd := StrToIntDef(Copy(DTstr, 9, 2), 0) * I;
  hhd := StrToIntDef(Copy(DTstr, 12, 2), 0) * I;
  mmd := StrToIntDef(Copy(DTstr, 15, 2), 0) * I;
  ssd := StrToIntDef(Copy(DTstr, 18, 2), 0) * I;

  NewDT := IncYear(DateSample, Yd); // get original DateTime here
  NewDT := IncMonth(NewDT, Md);
  NewDT := IncDay(NewDT, Dd);
  NewDT := IncHour(NewDT, hhd);
  NewDT := IncMinute(NewDT, mmd);
  NewDT := IncSecond(NewDT, ssd);

  if (MeShiftAmount.Tag = 0) then
  begin
    if (NewDT > DtPickDateResult.MinDate) then
      DtPickDateResult.Date := NewDT;
    DtPickTimeResult.Time := NewDT;
  end;
end;

end.
