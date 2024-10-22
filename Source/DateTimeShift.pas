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
    LblDebug: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ChkShiftClick(Sender: TObject);
    procedure ChkIncrementClick(Sender: TObject);
    procedure MeShiftAmountChange(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure DtPickDateResultUserInput(Sender: TObject; const UserString: string; var DateAndTime: TDateTime; var AllowChange: Boolean);
    procedure DtPickResultChange(Sender: TObject);
    procedure DtPickTimeResultUserInput(Sender: TObject; const UserString: string; var DateAndTime: TDateTime;
      var AllowChange: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    ETcmd: string;
    ETouts: string;
    ETerrs: string;
    DateSample: TDateTime;
    NewDateSample: TDateTime;
    DateTimeOK: boolean;
    procedure ComputeDiff(NewDT: TdateTime);
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
  Group = 'exif';

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
        ETcmd := CmdStr + CmdDateTimeOriginal(Group) + PN + MeShiftAmount.EditText;
      if ChkShiftCreate.Checked then
        ETcmd := EndsWithCRLF(ETcmd) + CmdStr + CmdCreateDate(Group) + PN + MeShiftAmount.EditText;
      if ChkShiftModify.Checked then
        ETcmd := EndsWithCRLF(ETcmd) + CmdStr + CmdModifyDate(Group) + PN + MeShiftAmount.EditText;
    end;
  end;
  // ShiftDates in Exif?
  if (ETcmd <> '') then
    ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETouts, ETerrs);

  // Correct FileDates?
  ETcmd := '';
  if ChkFileModified.Checked then
    ETcmd := '-FileModifyDate<' + CmdModifyDate(Group);
  if ChkFileCreated.Checked then
    ETcmd := EndsWithCRLF(ETcmd) + '-FileCreateDate<' + CmdDateTimeOriginal(Group);
  if (ETcmd <> '') then
    ET.OpenExec(Etcmd, FMain.GetSelectedFiles);

  ModalResult := mrOK;
end;

procedure TFDateTimeShift.ChkShiftClick(Sender: TObject);
begin
  GetDateTimeOriginal;
  BtnExecute.Enabled := (ChkShiftOriginal.Checked) or (ChkShiftCreate.Checked) or (ChkShiftModify.Checked) or
                        (ChkFileModified.Checked) or (ChkFileCreated.Checked);
end;

procedure TFDateTimeShift.ChkIncrementClick(Sender: TObject);
begin
  if (ChkIncrement.Tag <> 0) then
    exit;

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

procedure TFDateTimeShift.ComputeDiff(NewDT: TdateTime);
var
  Increment: boolean;
begin
  NewDateSample := NewDT;
  // Prevent eventhandlers from firing
  MeShiftAmount.Tag := 1;
  ChkIncrement.Tag := 1;
  try
    MeShiftAmount.EditText := DateDiff(DateSample, NewDateSample, Increment);
    ChkIncrement.Checked := Increment;
  finally
    MeShiftAmount.Tag := 0;
    ChkIncrement.Tag := 0;
  end;
end;

procedure TFDateTimeShift.DtPickResultChange(Sender: TObject);
begin
  ComputeDiff(DtPickDateResult.Date + DtPickTimeResult.Time);
end;

procedure TFDateTimeShift.DtPickDateResultUserInput(Sender: TObject; const UserString: string; var DateAndTime: TDateTime;
  var AllowChange: Boolean);
begin
  if (AllowChange) then
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
  DtPickDateResult.Date := Now;
  DtPickTimeResult.Date := Now;

  DTstr := LblEdOriginal.Text;  // If none checked
  if (ChkShiftOriginal.Checked = true) then
    DTstr := LblEdOriginal.Text
  else if (ChkShiftCreate.Checked = true)  then
      DTstr := LblEdCreate.Text
  else if (ChkShiftModify.Checked = true) then
    DTstr := LblEdModify.Text;

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

  ChkIncrement.Tag := 1;
  try
    ChkIncrement.Checked := true;
    MeShiftAmountChange(MeShiftAmount);
  finally
    ChkIncrement.Tag := 0;
  end;
end;

procedure TFDateTimeShift.FormCreate(Sender: TObject);
begin
  ChkFileCreated.Caption := ChkFileCreated.Caption + '<' + CmdStr + CmdCreateDate(Group);
  ChkFileModified.Caption := ChkFileModified.Caption + '<' + CmdStr + CmdModifyDate(Group);
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

    ChkShiftOriginal.Checked := false;
    ChkShiftCreate.Checked := false;
    ChkShiftModify.Checked := FMain.MaPreserveDateMod.Checked;
    ChkFileModified.Checked := FMain.MaPreserveDateMod.Checked;
    ChkFileCreated.Checked := false;

    Application.OnHint := DisplayHint;

    ETcmd := '-s3' + CRLF + '-f' + CRLF +
             CmdStr + CmdDateTimeOriginal(Group) + CRLF +
             CmdStr + CmdCreateDate(Group) + CRLF +
             CmdStr + CmdModifyDate(Group);
    ET.OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETResult, false);
    if (ETResult.Count > 2) then
    begin
      ChkShiftOriginal.Checked := true;
      ChkShiftCreate.Checked := true;
      ChkFileCreated.Checked := true;
      LblEdOriginal.Text := ETResult[0];
      LblEdCreate.Text := ETResult[1];
      LblEdModify.Text := ETResult[2];
    end;
    GetDateTimeOriginal;
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
  NewDateSample := NewDT;

  if (MeShiftAmount.Tag = 0) then
  begin
    if (NewDT > DtPickDateResult.MinDate) then
    begin
      DtPickDateResult.Date := NewDT;
      DtPickTimeResult.Time := NewDT;
      StatusBar1.SimpleText := '';
    end
    else
      StatusBar1.SimpleText := Format('Warning: Computed date %s can not be shown' , [FormatDateTime('YYYY:MM:DD hh:mm:ss', NewDT)]);
  end;
  {$IFDEF DEBUG}
  LblDebug.Visible := true;
  LblDebug.Caption := FormatDateTime('YYYY:MM:DD hh:mm:ss', NewDT);
  {$ENDIF}
end;

end.
