unit FileDateTime;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls;

type
  TFFileDateTime = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    AdvPanel2: TPanel;
    Button1: TButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    RadioGroup4: TRadioGroup;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Button2: TButton;
    AdvPanel3: TPanel;
    RadioButton1: TRadioButton;
    Button3: TButton;
    AdvPanel4: TPanel;
    RadioButton2: TRadioButton;
    Button4: TButton;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure RadioGroup3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FFileDateTime: TFFileDateTime;

implementation

uses Main, ExifTool, UnitLangResources;

{$R *.dfm}

var
  ETcmd: string;

procedure TFFileDateTime.Button2Click(Sender: TObject);
var
  Ds, Ts: string[1];
  ETout, ETerr: string;
begin
  ETcmd := '-overwrite_original' + CRLF;
  if RadioGroup4.ItemIndex = 0 then
    ETcmd := ETcmd + '-Exif:DocumentName<filename' + CRLF;
  case RadioGroup1.ItemIndex of
    0:
      ETcmd := ETcmd + '-filename<${Exif:DateTimeOriginal}';
    1:
      ETcmd := ETcmd + '-filename<${Exif:CreateDate}';
    2:
      ETcmd := ETcmd + '-filename<${Exif:ModifyDate}';
  end;
  if RadioGroup3.ItemIndex = 0 then
    ETcmd := ETcmd + ' %f.%e'
  else
    ETcmd := ETcmd + ' ' + Edit1.Text + '.%e';
  ETcmd := ETcmd + CRLF + '-d' + CRLF;
  Ds := '';
  Ts := '';
  if CheckBox1.Checked then
    Ds := '-';
  if CheckBox2.Checked then
    Ts := '-';
  case RadioGroup2.ItemIndex of
    0:
      ETcmd := ETcmd + '%Y' + Ds + '%m' + Ds + '%d_%H' + Ts + '%M' + Ts + '%S';
    1:
      ETcmd := ETcmd + '%Y' + Ds + '%m' + Ds + '%d_%H' + Ts + '%M';
    2:
      ETcmd := ETcmd + '%Y' + Ds + '%m' + Ds + '%d';
  end;
  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFFileDateTime.Button3Click(Sender: TObject);
var
  ETout, ETerr: string;
begin
  ETcmd := '-filename<Exif:DocumentName';
  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFFileDateTime.Button4Click(Sender: TObject);
var
  k, renamed: integer;
  NewFname: string;
  ANitem: TListItem;
begin
  renamed := 0;
  SetCurrentDir(FMain.ShellList.Path);
  for ANitem in FMain.ShellList.Items do
  begin
    if ANitem.Selected then
    begin
      ETcmd := FMain.ShellList.FileName(ANitem.Index);
      k := pos(' ', ETcmd);
      if k > 0 then
      begin
        NewFname := ETcmd;
        Delete(NewFname, 1, k);
        if RenameFile(ETcmd, NewFname) then
          inc(renamed);
      end;
    end;
  end;
  ShowMessage(intToStr(renamed) + StrFilesRenamed);
  ModalResult := mrOK;
end;

procedure TFFileDateTime.CheckBox1Click(Sender: TObject);
begin
  with RadioGroup2 do
  begin
    if CheckBox1.Checked then
    begin
      if CheckBox2.Checked then
      begin
        Items[0] := 'YYYY-MM-DD_HH-MM-SS ' + StrFilename;
        Items[1] := 'YYYY-MM-DD_HH-MM ' + StrFilename;
      end
      else
      begin
        Items[0] := 'YYYY-MM-DD_HHMMSS ' + StrFilename;
        Items[1] := 'YYYY-MM-DD_HHMM ' + StrFilename;
      end;
      Items[2] := 'YYYY-MM-DD ' + StrFilename;
    end
    else
    begin
      if CheckBox2.Checked then
      begin
        Items[0] := 'YYYYMMDD_HH-MM-SS ' + StrFilename;
        Items[1] := 'YYYYMMDD_HH-MM ' + StrFilename;
      end
      else
      begin
        Items[0] := 'YYYYMMDD_HHMMSS ' + StrFilename;
        Items[1] := 'YYYYMMDD_HHMM ' + StrFilename;
      end;
      Items[2] := 'YYYYMMDD ' + StrFilename;
    end;
  end;
end;

procedure TFFileDateTime.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFFileDateTime.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  RadioGroup3Click(Sender);
  CheckBox1Click(Sender);
  Application.OnHint := DisplayHint;
end;

procedure TFFileDateTime.RadioGroup3Click(Sender: TObject);
begin
  Edit1.Enabled := (RadioGroup3.ItemIndex = 0);
end;

end.
