unit FileDateTime;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.NumberBox;

type
  TFFileDateTime = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    AdvPanel2: TPanel;
    Button1: TButton;
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
    RadDuplicates: TRadioGroup;
    PnlCustomSeq: TPanel;
    EdSeqPref: TEdit;
    EdSeqPerc: TEdit;
    NbSeqStart: TNumberBox;
    UdSeqStart: TUpDown;
    EdSeqColon: TEdit;
    NbSeqWidth: TNumberBox;
    UdWidth: TUpDown;
    EdSeqSuf: TEdit;
    RadioGroup1: TRadioGroup;
    CmbGroup: TComboBox;
    GroupBox1: TGroupBox;
    LblSampleDate: TLabel;
    ChkSeparate: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure RadioGroup3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure EdPreviewChange(Sender: TObject);
    procedure RadDuplicatesClick(Sender: TObject);
    procedure CmbGroupClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure EdSeparateChange(Sender: TObject);
    procedure ChkSeparateClick(Sender: TObject);
  private
    { Private declarations }
    Separator: string;
    FSample: string;
    Group: string;
    YYYY, MM, DD, HH, MIN, SS: string;
    function GetRenameSample: string;
    function GetStandardFormat: string;
    function GetCustomFormat: string;
    procedure UpdatePreview;
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FFileDateTime: TFFileDateTime;

implementation

uses
  Winapi.CommCtrl,
  Main, ExifTool, UnitLangResources, ExifToolsGui_ShellList, ExifToolsGUI_Utils;

{$R *.dfm}

function TFFileDateTime.GetRenameSample: string;
begin
  result := '';
  case RadDuplicates.ItemIndex of
    1: result := '-1';
    2: result := Format('%s%s%s', [EdSeqPref.Text,
                                   Format('%.*d', [NbSeqWidth.ValueInt, NbSeqStart.ValueInt]),
                                   EdSeqSuf.Text]);
  end;
end;

function TFFileDateTime.GetStandardFormat: string;
begin
  result := '%-c';
end;

//%2:4C = Start from 2, 4 positions width = 0002
function TFFileDateTime.GetCustomFormat: string;
begin
  result := Format('%s%s%d%s%dC%s', [EdSeqPref.Text,
                                     EdSeqPerc.Text,
                                     NbSeqStart.ValueInt,
                                     EdSeqColon.Text,
                                     NbSeqWidth.ValueInt,
                                     EdSeqSuf.Text]);
end;

procedure TFFileDateTime.Button2Click(Sender: TObject);
var
  Ds, Ts: string[1];
  ETcmd, ETout, ETerr: string;

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
        ETcmd := ETcmd + '${' + CmdDateTimeOriginal(Group) + '}';
      1:
        ETcmd := ETcmd + '${' + CmdCreateDate(Group) + '}';
      2:
        ETcmd := ETcmd + '${' + CmdModifyDate(Group) + '}';
    end;
  end;

  procedure AddSeq;
  begin
    case RadDuplicates.ItemIndex of
      1: ETcmd := ETcmd + GetStandardFormat;
      2: ETcmd := ETcmd + GetCustomFormat;
    end;
  end;

begin
  ETcmd := '';
  if (ET.Options.ETBackupMode = '') then  // Dont add twice!
    ETcmd := '-overwrite_original' + CRLF;

  if (RadioGroup4.Enabled) and
     (RadioGroup4.ItemIndex = 0) then
    ETcmd := ETcmd + '-Exif:DocumentName<filename' + CRLF;

  ETcmd := ETcmd + '-filename<';
  if ChkDateFirst.Checked then
  begin
    AddDateTime;
    ETcmd := ETcmd + Separator;
    AddName;
  end
  else
  begin
    AddName;
    ETcmd := ETcmd + Separator;
    AddDateTime;
  end;

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
 ETCmd, ETout, ETerr: string;
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
  ETcmd: string;
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
  ETcmd: string;
  ETouts: string;
  ETerrs: string;
  SampleFileName: string;
  SampleFileExt: string;
begin
  if not Showing then
    exit;

  ETcmd := '-s3' + CRLF + '-f';
  case RadioGroup1.ItemIndex of
    0: ETcmd := ETcmd + CRLF + CmdStr + CmdDateTimeOriginal(Group);
    1: ETcmd := ETcmd + CRLF + CmdStr + CmdCreateDate(Group);
    2: ETcmd := ETcmd + CRLF + CmdStr + CmdModifyDate(Group);
  end;
  ET.OpenExec(ETcmd, FSample, ETouts, ETerrs, false);

  if (RadioGroup3.ItemIndex = 1) then
    SampleFileName := Edit1.Text
  else
    SampleFileName := ChangeFileExt(ExtractFileName(FSample), '');
  SampleFileExt := ExtractFileExt(FSample);

  ETouts := ReplaceAll(ETouts, [CRLF], [' ']);
  LblSampleDate.Caption := FSample + ' ' + ETouts;
  YYYY := NextField(ETouts, ':');
  MM   := NextField(ETouts, ':');
  DD   := NextField(ETouts, ' ');
  HH   := NextField(ETouts, ':');
  MIN  := NextField(ETouts, ':');
  SS   := Trim(NextField(ETouts, '+'));

  with RadioGroup2 do
  begin
    Items.BeginUpdate;
    try
      Items[0] := '';
      Items[1] := '';
      Items[2] := '';
      if not ChkDateFirst.Checked then
      begin
        Items[0] := SampleFileName + Separator;
        Items[1] := SampleFileName + Separator;
        Items[2] := SampleFileName + Separator;
      end;
      if CheckBox1.Checked then
      begin
        if CheckBox2.Checked then
        begin
          Items[0] := Items[0] + Format('%s-%s-%s_%s-%s-%s', [YYYY, MM, DD, HH, MIN, SS]);
          Items[1] := Items[1] + Format('%s-%s-%s_%s-%s', [YYYY, MM, DD, HH, MIN]);
        end
        else
        begin
          Items[0] := Items[0] + Format('%s-%s-%s_%s%s%s', [YYYY, MM, DD, HH, MIN, SS]);
          Items[1] := Items[1] + Format('%s-%s-%s_%s%s', [YYYY, MM, DD, HH, MIN]);
        end;
        Items[2] := Items[2] + Format('%s-%s-%s', [YYYY, MM, DD]);
      end
      else
      begin
        if CheckBox2.Checked then
        begin
          Items[0] := Items[0] + Format('%s%s%s_%s-%s-%s', [YYYY, MM, DD, HH, MIN, SS]);
          Items[1] := Items[1] + Format('%s%s%s_%s-%s', [YYYY, MM, DD, HH, MIN]);
        end
        else
        begin
          Items[0] := Items[0] + Format('%s%s%s_%s%s%s', [YYYY, MM, DD, HH, MIN, SS]);
          Items[1] := Items[1] + Format('%s%s%s_%s%s', [YYYY, MM, DD, HH, MIN]);
        end;
        Items[2] := Items[2] + Format('%s%s%s', [YYYY, MM, DD]);
      end;
      if ChkDateFirst.Checked then
      begin
        Items[0] := Items[0] + Separator + SampleFileName;
        Items[1] := Items[1] + Separator + SampleFileName;
        Items[2] := Items[2] + Separator + SampleFileName;
      end;
      case RadDuplicates.ItemIndex of
        1:
          begin
            Items[0] := Items[0] + '-1';
            Items[1] := Items[1] + '-1';
            Items[2] := Items[2] + '-1';
          end;
        2:
          begin
            Items[0] := Items[0] + GetRenameSample;
            Items[1] := Items[1] + GetRenameSample;
            Items[2] := Items[2] + GetRenameSample;
          end;
      end;
      Items[0] := Items[0] + SampleFileExt;
      Items[1] := Items[1] + SampleFileExt;
      Items[2] := Items[2] + SampleFileExt;
    finally
      Items.EndUpdate;
    end;
  end;
  RadDuplicates.Items.BeginUpdate;
  try
    RadDuplicates.Items[0] := StrUseNone;
    RadDuplicates.Items[1] := StrUseStandardSeq + ' ' + GetStandardFormat;
    RadDuplicates.Items[2] := StrUseCustomSeq + ' ' + GetCustomFormat;
  finally
    RadDuplicates.Items.EndUpdate;
  end;
end;

procedure TFFileDateTime.CheckBox1Click(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TFFileDateTime.ChkSeparateClick(Sender: TObject);
begin
  if (ChkSeparate.Checked) then
    Separator := ' '
  else
    Separator := '';
  UpdatePreview;
end;

procedure TFFileDateTime.CmbGroupClick(Sender: TObject);
begin
  RadioGroup1.Buttons[0].Enabled := CmbGroup.ItemIndex <> 2;            // QuickTime
  RadioGroup1.Buttons[0].Checked := RadioGroup1.Buttons[0].Enabled;     // QuickTime
  RadioGroup1.Buttons[1].Checked := not RadioGroup1.Buttons[0].Enabled; // QuickTime
  Group := CmbGroup.Text;

  // Xmp:DocumentName does not exist
  RadioGroup4.Enabled := (CmbGroup.ItemIndex = 0);
  Button3.Enabled := (CmbGroup.ItemIndex = 0);

  UpdatePreview;
end;

procedure TFFileDateTime.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFFileDateTime.EdPreviewChange(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TFFileDateTime.EdSeparateChange(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TFFileDateTime.FormShow(Sender: TObject);
begin
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;
  FSample := ReplaceAll(FMain.GetFirstSelectedFile, [CRLF], ['']);
  PnlCustomSeq.Visible := (RadDuplicates.ItemIndex = 2);
  Edit1.Enabled := (RadioGroup3.ItemIndex <> 0);
  CmbGroup.ItemIndex := 0;
  CmbGroupClick(CmbGroup);
  ChkSeparate.Checked := true;

  UpdatePreview;
  Application.OnHint := DisplayHint;
end;

procedure TFFileDateTime.RadDuplicatesClick(Sender: TObject);
begin
  PnlCustomSeq.Visible := (RadDuplicates.ItemIndex = 2);
  UpdatePreview;
end;

procedure TFFileDateTime.RadioGroup1Click(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TFFileDateTime.RadioGroup3Click(Sender: TObject);
begin
  Edit1.Enabled := (RadioGroup3.ItemIndex <> 0);
  UpdatePreview;
end;

end.
