unit RemoveMeta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls;

type
  TFRemoveMeta = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    AdvPanel2: TPanel;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox7Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    procedure SetExecuteButton;
    procedure CheckForRemoveAll;
  public
    { Public declarations }
  end;

var
  FRemoveMeta: TFRemoveMeta;

implementation

uses Main, ExifTool, UnitLangResources;

{$R *.dfm}

var
  // clLite,clDark:TColor;
  EventOn: boolean;

procedure TFRemoveMeta.SetExecuteButton;
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

procedure TFRemoveMeta.Button2Click(Sender: TObject);
var
  ETcmd, ETout, ETerr: string;
begin
  ETcmd := '';
  if CheckBox1.Checked then
    ETcmd := '-All='
  else
  begin
    if CheckBox2.Checked then
      ETcmd := '-Exif:All='
    else
    begin
      if CheckBox3.Checked then
        ETcmd := '-Makernotes:All=';
      if CheckBox4.Checked then
        ETcmd := ETcmd + CRLF + '-Gps:All=';
      if CheckBox5.Checked then
        ETcmd := ETcmd + CRLF + '-IFD1:All=';
    end;
    if CheckBox6.Checked then
      ETcmd := ETcmd + CRLF + '-Xmp:All='
    else
    begin
      if CheckBox7.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-exif:All=';
      if CheckBox8.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-Acdsee:All=';
      if CheckBox9.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-Mediapro:All=';
      if CheckBox10.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-Photoshop:All=';
      if CheckBox11.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-crs:All=';
      if CheckBox12.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-Microsoft:All=';
      if CheckBox17.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-pdf:All=';
      if CheckBox18.Checked then
        ETcmd := ETcmd + CRLF + '-Xmp-tiff:All=';
    end;
    if CheckBox13.Checked then
      ETcmd := ETcmd + CRLF + '-Iptc:All=';
    if CheckBox14.Checked then
      ETcmd := ETcmd + CRLF + '-Photoshop:All=';
    if CheckBox15.Checked then
      ETcmd := ETcmd + CRLF + '-Jfif:All=';
    if CheckBox16.Checked then
      ETcmd := ETcmd + CRLF + '-ICC_profile:All=';
  end;

  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFRemoveMeta.CheckBox1Click(Sender: TObject);
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

procedure TFRemoveMeta.CheckForRemoveAll;
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

procedure TFRemoveMeta.CheckBox2Click(Sender: TObject);
var
  IsChecked: boolean; // Exif,Xmp,Iptc,Photoshop,JFIF,ICC
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
      CheckBox5.Checked := IsChecked;
    end;
    if Sender = CheckBox6 then
    begin // Xmp:All
      CheckBox7.Checked := IsChecked;
      CheckBox8.Checked := IsChecked;
      CheckBox9.Checked := IsChecked;
      CheckBox10.Checked := IsChecked;
      CheckBox11.Checked := IsChecked;
      CheckBox12.Checked := IsChecked;
      CheckBox17.Checked := IsChecked;
      CheckBox18.Checked := IsChecked;
    end;
    CheckForRemoveAll;
    EventOn := true;
    SetExecuteButton;
  end;
end;

procedure TFRemoveMeta.CheckBox3Click(Sender: TObject);
begin
  if EventOn then
  begin
    EventOn := false;
    CheckBox2.Checked := false;
    CheckForRemoveAll;
    EventOn := true;
    SetExecuteButton;
  end;
end;

procedure TFRemoveMeta.CheckBox7Click(Sender: TObject);
begin
  if EventOn then
  begin
    EventOn := false;
    CheckBox6.Checked := false;
    CheckForRemoveAll;
    EventOn := true;
    SetExecuteButton;
  end;
end;

procedure TFRemoveMeta.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFRemoveMeta.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  Application.OnHint := DisplayHint;
  EventOn := true;
  CheckBox1.Checked := false;
  CheckBox1Click(Sender); // set all to unchecked
end;

end.
