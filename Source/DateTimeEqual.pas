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
    ChkFileModified: TCheckBox;
    ChkFileCreated: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CmbGroupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Group: string;
    OrigChkFileModified: string;
    OrigChkFileCreated: string;
    procedure DisplayHint(Sender: TObject);
    procedure GetCurrentValues;
  public
    { Public declarations }
    ETout, ETerr: string;
  end;

var
  FDateTimeEqual: TFDateTimeEqual;

implementation

uses
  Main, ExifTool, ExifToolsGUI_Utils, UnitLangResources;

{$R *.dfm}

procedure TFDateTimeEqual.GetCurrentValues;
var
  ETcmd: string;
  ETresult: TStringList;
begin
  Group := CmbGroup.Text;
  ChkFileModified.Caption := OrigChkFileModified + '<' + CmdStr + CmdModifyDate(Group);
  ChkFileCreated.Caption := OrigChkFileCreated + '<' + CmdStr + CmdCreateDate(Group);
  RadioButton1.Enabled := CmbGroup.ItemIndex <> 2;   // QuickTime
  RadioButton1.Checked := RadioButton1.Enabled;      // QuickTime
  RadioButton2.Checked := not RadioButton1.Enabled;  // QuickTime

  ETresult := TStringList.Create;
  try
    ETcmd := '-s3' + CRLF + '-f' + CRLF + CmdStr + CmdDateTimeOriginal(Group) + CRLF +
                                          CmdStr + CmdCreateDate(Group) + CRLF +
                                          CmdStr + CmdModifyDate(Group);
    ET.OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETresult, false);
    if (ETresult.Count > 2) then
    begin
      ChkFileCreated.Checked := true;
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
  begin
    if (RadioButton1.Enabled) then
      ETcmd := CmdStr + CmdCreateDate(Group) + '>' + CmdModifyDate(Group) + CRLF +
               CmdStr + CmdCreateDate(Group) + '>' + CmdDateTimeOriginal(Group)
    else
      ETcmd := CmdStr + CmdCreateDate(Group) + '>' + CmdModifyDate(Group); // QuickTime
  end;

  if RadioButton3.Checked then
  begin
    if (RadioButton1.Enabled) then
      ETcmd := CmdStr + CmdModifyDate(Group) + '>' + CmdDateTimeOriginal(Group) + CRLF +
               CmdStr + CmdModifyDate(Group) + '>' + CmdCreateDate(Group)
    else
      ETcmd := CmdStr + CmdModifyDate(Group) + '>' + CmdCreateDate(Group); // QuickTime
  end;
  ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);

  // Correct FileDates?
  ETcmd := '';
  if ChkFileModified.Checked then
    ETcmd := '-FileModifyDate<' + CmdModifyDate(Group);
  if ChkFileCreated.Checked then
    ETcmd := EndsWithCRLF(ETcmd) + '-FileCreateDate<' + CmdCreateDate(Group);
  if (ETcmd <> '') then
    ET.OpenExec(Etcmd, FMain.GetSelectedFiles);

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

procedure TFDateTimeEqual.FormCreate(Sender: TObject);
begin
  OrigChkFileModified := ChkFileModified.Caption;
  OrigChkFileCreated := ChkFileCreated.Caption;

  ChkFileCreated.Checked := false;
end;

procedure TFDateTimeEqual.FormShow(Sender: TObject);
begin
  Application.OnHint := DisplayHint;
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  ChkFileModified.Checked := FMain.MaPreserveDateMod.Checked;

  GetCurrentValues;
  RadioButtonClick(Sender);

  if (RadioButton1.Enabled) then
    RadioButton1.SetFocus
  else
    RadioButton2.SetFocus;
end;

procedure TFDateTimeEqual.RadioButtonClick(Sender: TObject);
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
