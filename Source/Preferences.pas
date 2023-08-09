unit Preferences;
{$WARN SYMBOL_PLATFORM OFF}

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
    RgStartupFolder: TRadioGroup;
    EdStartupFolder: TEdit;
    BtnStartupFolder: TButton;
    RgExportMetaFolder: TRadioGroup;
    EdExportMetaFolder: TEdit;
    BtnExportMetaFolder: TButton;
    LabeledEdit1: TLabeledEdit;
    RadioGroup3: TRadioGroup;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    AdvTabSheet2: TTabSheet;
    CheckBox4: TCheckBox;
    RgETOverride: TRadioGroup;
    EdETOverride: TEdit;
    BtnETOverride: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnBrowseFolder(Sender: TObject);
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
    DefStartupDir := EdStartupFolder.Text;
    DefStartupUse := (RgStartupFolder.ItemIndex = 1);
    DefExportDir := EdExportMetaFolder.Text;
    DefExportUse := (RgExportMetaFolder.ItemIndex = 1);
    ETOverrideDir := '';
    if (RgETOverride.ItemIndex = 1) then
      ETOverrideDir := IncludeTrailingBackslash(EdETOverride.Text);
  end;
  with LabeledEdit1 do
  begin
    if (Text = '') or (Text = ' ') then
      Text := '*';
    ET_Options.ETSeparator := '-sep' + CRLF + Text + CRLF;
  end;

  case RadioGroup3.ItemIndex of
    0: i := 96;
    1: i := 128;
    2: i := 160;
  end;
  FMain.ShellList.ThumbNailSize := i;
  GUIsettings.ThumbSize := RadioGroup3.ItemIndex;
  GUIsettings.EnableGMap := CheckBox2.Checked;
  GUIsettings.UseExitDetails := CheckBox3.Checked;
  GUIsettings.AutoIncLine := CheckBox4.Checked;
end;

procedure TFPreferences.BtnBrowseFolder(Sender: TObject);
var xDir: string;
begin
  if Sender = BtnStartupFolder then
  begin
    xDir := BrowseFolderDlg('Select default startup folder', 0);
    if xDir <> '' then
      EdStartupFolder.Text := xDir;
  end;
  if Sender = BtnExportMetaFolder then
  begin
    xDir := BrowseFolderDlg('Select default export folder', 0);
    if xDir <> '' then
      EdExportMetaFolder.Text := xDir;
  end;
  if Sender = BtnETOverride then
  begin
    xDir := BrowseFolderDlg('Select ExifTool folder to use', 0);
    if xDir <> '' then
      EdETOverride.Text := xDir;
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
      EdStartupFolder.Text := DefStartupDir;
      EdExportMetaFolder.Text := DefExportDir;
      with RgStartupFolder do
      begin
        if DefStartupUse then
          ItemIndex := 1
        else
          ItemIndex := 0;
        RadioGroupClick(RgStartupFolder);
      end;
      with RgExportMetaFolder do
      begin
        if DefExportUse then
          ItemIndex := 1
        else
          ItemIndex := 0;
        RadioGroupClick(RgExportMetaFolder);
      end;
      with RgETOverride do
      begin
        EdETOverride.Text := ETOverrideDir;
        if (Trim(ETOverrideDir) <> '') then
          ItemIndex := 1
        else
          ItemIndex := 0;
        RadioGroupClick(RgETOverride);
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
  if Sender = RgStartupFolder then
  begin
    EdStartupFolder.Enabled := RgStartupFolder.ItemIndex = 1;
    BtnStartupFolder.Enabled := EdStartupFolder.Enabled;
  end;
  if Sender = RgExportMetaFolder then
  begin
    EdExportMetaFolder.Enabled := RgExportMetaFolder.ItemIndex = 1;
    BtnExportMetaFolder.Enabled := EdExportMetaFolder.Enabled;
  end;
  if Sender = RgETOverride then
  begin
    EdETOverride.Enabled := RgETOverride.ItemIndex = 1;
    BtnETOverride.Enabled := EdETOverride.Enabled;
  end;
end;

end.
