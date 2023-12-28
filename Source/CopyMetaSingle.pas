unit CopyMetaSingle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFCopyMetaSingle = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    CheckBox1: TCheckBox;
    AdvPanel2: TPanel;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    procedure SetExecuteButton;
    procedure CheckForImportAll;
  public
    { Public declarations }
    SrcFile: string;
  end;

var
  FCopyMetaSingle: TFCopyMetaSingle;

implementation

uses Main, ExifTool;

{$R *.dfm}

var
  EventOn: boolean;

procedure TFCopyMetaSingle.CheckForImportAll;
var
  i: smallint;
  AllChecked: boolean;
begin
  AllChecked := true;
  with AdvPanel2 do
    for i := 0 to ControlCount - 1 do
    begin
      AllChecked := AllChecked and (Controls[i] as TCheckBox).Checked;
    end;
  EventOn := false;
  CheckBox1.Checked := AllChecked;
  EventOn := true;
end;

procedure TFCopyMetaSingle.SetExecuteButton;
var
  i: integer;
  CheckedExist: boolean;
begin
  CheckedExist := CheckBox1.Checked;
  if not CheckedExist then
  begin
    with AdvPanel2 do
      for i := 0 to ControlCount - 1 do
      begin
        if Controls[i] is TCheckBox then
          CheckedExist := CheckedExist or (Controls[i] as TCheckBox).Checked;
      end;
  end;
  Button2.Enabled := CheckedExist;
end;

procedure TFCopyMetaSingle.Button2Click(Sender: TObject);
var
  ETcmd, ETout, ETerr: string;
begin
  ETcmd := '-TagsFromFile' + CRLF + SrcFile;
  if CheckBox1.Checked then
    ETcmd := ETcmd + CRLF + '-All:all' + CRLF + '-ICC_Profile'
  else
  begin
    if CheckBox2.Checked then
    begin
      ETcmd := ETcmd + CRLF + '-Exif:all';
      if not CheckBox3.Checked then
        ETcmd := ETcmd + CRLF + '--Makernotes';
      if not CheckBox4.Checked then
        ETcmd := ETcmd + CRLF + '--GPS:all';
    end;
    if CheckBox5.Checked then
      ETcmd := ETcmd + CRLF + '-XMP:all';
    if CheckBox6.Checked then
      ETcmd := ETcmd + CRLF + '-IPTC:all';
    if CheckBox7.Checked then
      ETcmd := ETcmd + CRLF + '-ICC_Profile';
    if CheckBox8.Checked then
      ETcmd := ETcmd + CRLF + '-Gps:All';
  end;
  if CheckBox9.Checked then
    ETcmd := ETcmd + CRLF + '-wm' + CRLF + 'cg';

  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFCopyMetaSingle.CheckBox1Click(Sender: TObject);
var
  i: smallint;
begin
  if EventOn then
  begin
    EventOn := false;
    with AdvPanel2 do
      for i := 0 to ControlCount - 1 do
      begin
        if Controls[i] is TCheckBox then
          (Controls[i] as TCheckBox).Checked := CheckBox1.Checked;
      end;
    EventOn := true;
    SetExecuteButton;
  end;
end;

procedure TFCopyMetaSingle.CheckBox2Click(Sender: TObject);
var
  IsChecked: boolean; // Exif,Xmp,Iptc,ICC
begin
  if EventOn then
  begin
    EventOn := false;
    IsChecked := (Sender as TCheckBox).Checked;
    if not IsChecked then
      CheckBox1.Checked := false; // RemoveAll

    if Sender = CheckBox2 then
    begin // Exif:All
      CheckBox3.Checked := IsChecked;
      CheckBox4.Checked := IsChecked;
    end;
    CheckForImportAll;
    EventOn := true;
    SetExecuteButton;
  end;
end;

procedure TFCopyMetaSingle.CheckBox3Click(Sender: TObject);
begin
  if EventOn then
  begin
    EventOn := false;
    with Sender as TCheckBox do
      if Checked then
        CheckBox2.Checked := true;
    CheckForImportAll;
    EventOn := true;
    SetExecuteButton;
  end;
end;

procedure TFCopyMetaSingle.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFCopyMetaSingle.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;

  if FMain.MDontBackup.Checked then
    Label1.Caption := 'Backup: OFF'
  else
    Label1.Caption := 'Backup: ON';
  Application.OnHint := DisplayHint;
  EventOn := true;
  CheckBox1.Checked := true;
  CheckBox1Click(Sender); // set all to checked
  CheckBox9.Checked := false;
end;

end.
