unit Preferences;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Mask;

type
  TFPreferences = class(TForm)
    AdvPageControl1: TPageControl;
    AdvTabSheet1: TTabSheet;
    Label1: TLabel;
    ComboBox1: TComboBox;
    BtnCancel: TButton;
    BtnSave: TButton;
    CheckBox1: TCheckBox;
    RadioGroup1: TRadioGroup;
    Edit1: TEdit;
    Button1: TButton;
    RadioGroup2: TRadioGroup;
    Edit2: TEdit;
    Button2: TButton;
    LabeledEdit1: TLabeledEdit;
    RadioGroup3: TRadioGroup;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    AdvTabSheet2: TTabSheet;
    CheckBox4: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure RadioGroupClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPreferences: TFPreferences;

implementation

uses Main, ExifTool, MainDef;

{$R *.dfm}

procedure TFPreferences.BtnSaveClick(Sender: TObject);
var
  i: smallint;
  tx: string[7];
begin
  i := ComboBox1.ItemIndex;
  if i = 0 then
  begin
    GUIsettings.Language := '';
    ET_Options.ETLangDef := '';
  end
  else
  begin
    tx := ComboBox1.Items[i];
    i := pos(' ', tx);
    SetLength(tx, i - 1);
    GUIsettings.Language := tx;
    ET_Options.ETLangDef := tx + CRLF;
  end;
  with GUIsettings do
  begin
    AutoRotatePreview := CheckBox1.Checked;
    DefStartupDir := Edit1.Text;
    DefStartupUse := (RadioGroup1.ItemIndex = 1);
    DefExportDir := Edit2.Text;
    DefExportUse := (RadioGroup2.ItemIndex = 1);
  end;
  with LabeledEdit1 do
  begin
    if (Text = '') or (Text = ' ') then
      Text := '*';
    ET_Options.ETSeparator := '-sep' + CRLF + Text + CRLF;
  end;

  case RadioGroup3.ItemIndex of
    0:
      i := 96;
    1:
      i := 128;
    2:
      i := 160;
  end;
  FMain.ShellList.ThumbNailSize := i;
  GUIsettings.ThumbSize := RadioGroup3.ItemIndex;
  GUIsettings.EnableGMap := CheckBox2.Checked;
  GUIsettings.UseExitDetails := CheckBox3.Checked;
  GUIsettings.AutoIncLine := CheckBox4.Checked;
end;

procedure TFPreferences.Button1Click(Sender: TObject);
var
  xDir: string;
begin
  if Sender = Button1 then
  begin
    xDir := BrowseFolderDlg('Select default startup folder', 0);
    if xDir <> '' then
      Edit1.Text := xDir;
  end;
  if Sender = Button2 then
  begin
    xDir := BrowseFolderDlg('Select default export folder', 0);
    if xDir <> '' then
      Edit2.Text := xDir;
  end;
end;

procedure TFPreferences.FormShow(Sender: TObject);
var
  i, n: smallint;
  tx: AnsiString;
  ETResult: TStringList;
begin
  ETResult := TStringList.Create;
  try
    Left := FMain.Left + 8;
    Top := FMain.Top + 56;
    ET_OpenExec('-lang', '', ETResult);
    with ComboBox1 do
    begin
      Items.Clear;
      Items.Append('ExifTool standard (short)');
      i := ETResult.Count;
      if i > 0 then
      begin
        ETResult.Delete(0);
        dec(i);
      end;
      if i > 0 then
        for n := 0 to i - 1 do
          Items.Append(TrimLeft(ETResult[n]));
      tx := GUIsettings.Language;
      if tx = '' then
        ItemIndex := 0
      else
      begin
        i := Items.Count;
        n := 1;
        while n < i do
        begin
          if pos(tx, Items[n]) = 1 then
            ItemIndex := n;
          inc(n);
        end;
      end;
    end;
    ETResult.Clear;
    with GUIsettings do
    begin
      CheckBox1.Checked := AutoRotatePreview;
      Edit1.Text := DefStartupDir;
      Edit2.Text := DefExportDir;
      with RadioGroup1 do
      begin
        if DefStartupUse then
          ItemIndex := 1
        else
          ItemIndex := 0;
        RadioGroupClick(RadioGroup1);
      end;
      with RadioGroup2 do
      begin
        if DefExportUse then
          ItemIndex := 1
        else
          ItemIndex := 0;
        RadioGroupClick(RadioGroup2);
      end;
    end;
    tx := ET_Options.ETSeparator;
    Delete(tx, 1, 6);
    SetLength(tx, 1);
    LabeledEdit1.Text := tx;
    RadioGroup3.ItemIndex := GUIsettings.ThumbSize;
    CheckBox2.Checked := GUIsettings.EnableGMap;
    CheckBox3.Checked := GUIsettings.UseExitDetails;
    CheckBox4.Checked := GUIsettings.AutoIncLine;
    AdvPageControl1.ActivePage := AdvTabSheet1;
  finally
    ETResult.Free;
  end;
end;

procedure TFPreferences.RadioGroupClick(Sender: TObject);
begin
  if Sender = RadioGroup1 then
    Edit1.Enabled := RadioGroup1.ItemIndex = 1;
  if Sender = RadioGroup2 then
    Edit2.Enabled := RadioGroup2.ItemIndex = 1;
end;

end.
