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
    ChkDateFirst: TCheckBox;
    ChkSequence: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure RadioGroup3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private
    { Private declarations }
    procedure UpdatePreview;
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FFileDateTime: TFFileDateTime;

implementation

uses Main, ExifTool, UnitLangResources, ExifToolsGui_ShellList, Winapi.CommCtrl;

{$R *.dfm}

var
  ETcmd: string;

procedure TFFileDateTime.Button2Click(Sender: TObject);
var
  Ds, Ts: string[1];
  ETout, ETerr: string;

  procedure AddName;
  begin
  if RadioGroup3.ItemIndex = 0 then
    ETcmd := ETcmd + '%f'
  else
    ETcmd := ETcmd + Edit1.Text;
  end;

  procedure AddDateTime;
  begin
    case RadioGroup1.ItemIndex of
      0:
        ETcmd := ETcmd + '${Exif:DateTimeOriginal}';
      1:
        ETcmd := ETcmd + '${Exif:CreateDate}';
      2:
        ETcmd := ETcmd + '${Exif:ModifyDate}';
    end;
  end;

  procedure AddSeq;
  begin
    if (ChkDateFirst.Checked = false) then
      ETcmd := ETcmd + ' ';
    ETcmd := ETcmd + '%-c';
  end;

begin
  ETcmd := '';
  if (ET.Options.ETBackupMode = '') then  // Dont add twice!
    ETcmd := '-overwrite_original' + CRLF;

  if RadioGroup4.ItemIndex = 0 then
    ETcmd := ETcmd + '-Exif:DocumentName<filename' + CRLF;

  ETcmd := ETcmd + '-filename<';
  if ChkDateFirst.Checked then
  begin
    AddDateTime;
    ETcmd := ETcmd + ' ';
    AddName;
  end
  else
  begin
    AddName;
    ETcmd := ETcmd + ' ';
    AddDateTime;
  end;
  if (ChkSequence.Checked) then
    AddSeq;

  ETcmd := ETcmd + '.%e';

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
  ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFFileDateTime.Button3Click(Sender: TObject);
var
  ETout, ETerr: string;
begin
  ETcmd := '-filename<Exif:DocumentName';
  ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFFileDateTime.Button4Click(Sender: TObject);
var
  Index: integer;
  P: integer;
  Renamed: integer;
  NewFname: string;
begin
  Renamed := 0;
  SetCurrentDir(FMain.ShellList.Path);

  for Index := 0 to FMain.ShellList.Items.Count -1 do
  begin
    if (ListView_GetItemState(FMain.ShellList.Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) and
       (TSubShellFolder.GetIsFolder(FMain.ShellList.Folders[Index]) = false) then
    begin
      ETcmd := FMain.ShellList.RelFileName(Index);
      P := Pos(' ', ETcmd);
      if P > 0 then
      begin
        NewFname := ETcmd;
        Delete(NewFname, 1, P);
        if RenameFile(ETcmd, NewFname) then
          Inc(Renamed);
      end;
    end;
  end;
  ShowMessage(intToStr(Renamed) + StrFilesRenamed);
  ModalResult := mrOK;
end;

procedure TFFileDateTime.UpdatePreview;
var
  SampleFileName: string;
begin
  SampleFileName := StrFilename;
  if (RadioGroup3.ItemIndex = 1) then
    SampleFileName := Edit1.Text;

  with RadioGroup2 do
  begin
    Items[0] := '';
    Items[1] := '';
    Items[2] := '';
    if not ChkDateFirst.Checked then
    begin
      Items[0] := SampleFileName + ' ';
      Items[1] := SampleFileName + ' ';
      Items[2] := SampleFileName + ' ';
    end;
    if CheckBox1.Checked then
    begin
      if CheckBox2.Checked then
      begin
        Items[0] := Items[0] + 'YYYY-MM-DD_HH-MM-SS';
        Items[1] := Items[1] + 'YYYY-MM-DD_HH-MM';
      end
      else
      begin
        Items[0] := Items[0] + 'YYYY-MM-DD_HHMMSS';
        Items[1] := Items[1] + 'YYYY-MM-DD_HHMM';
      end;
      Items[2] := Items[2] + 'YYYY-MM-DD';
    end
    else
    begin
      if CheckBox2.Checked then
      begin
        Items[0] := Items[0] + 'YYYYMMDD_HH-MM-SS';
        Items[1] := Items[1] + 'YYYYMMDD_HH-MM';
      end
      else
      begin
        Items[0] := Items[0] + 'YYYYMMDD_HHMMSS';
        Items[1] := Items[1] + 'YYYYMMDD_HHMM';
      end;
      Items[2] := Items[2] + 'YYYYMMDD';
    end;
    if ChkDateFirst.Checked then
    begin
      Items[0] := Items[0] + ' ' + SampleFileName;
      Items[1] := Items[1] + ' ' + SampleFileName;
      Items[2] := Items[2] + ' ' + SampleFileName;
    end
    else
    begin
      Items[0] := Items[0] + ' ';
      Items[1] := Items[1] + ' ';
      Items[2] := Items[2] + ' ';
    end;
    if (ChkSequence.Checked) then
    begin
      Items[0] := Items[0] + '-1';
      Items[1] := Items[1] + '-1';
      Items[2] := Items[2] + '-1';
    end;
  end;
end;

procedure TFFileDateTime.CheckBox1Click(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TFFileDateTime.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFFileDateTime.Edit1Change(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TFFileDateTime.FormCreate(Sender: TObject);
begin
  ChkDateFirst.Checked := true;
  ChkSequence.Checked := true;
end;

procedure TFFileDateTime.FormShow(Sender: TObject);
begin
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  RadioGroup3Click(Sender);
  Application.OnHint := DisplayHint;
end;

procedure TFFileDateTime.RadioGroup3Click(Sender: TObject);
begin
  Edit1.Enabled := (RadioGroup3.ItemIndex <> 0);
  UpdatePreview;
end;

end.
