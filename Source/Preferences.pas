unit Preferences;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.Buttons;

type
  TFPreferences = class(TScaleForm)
    AdvPageControl1: TPageControl;
    AdvTabGeneral: TTabSheet;
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
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    AdvTabOther: TTabSheet;
    CheckBox4: TCheckBox;
    RgETOverride: TRadioGroup;
    EdETOverride: TEdit;
    BtnETOverride: TButton;
    AdvTabSheetThumbs: TTabSheet;
    RadioGroup3: TRadioGroup;
    ChkThumbAutoGenerate: TCheckBox;
    BtnSetupClean: TBitBtn;
    EdThumbCleanset: TMaskEdit;
    Label2: TLabel;
    BtnClean: TBitBtn;
    GpxCleanThumbNails: TGroupBox;
    BtnGenThumbs: TBitBtn;
    CheckBox5: TCheckBox;
    GrpGeoCode: TGroupBox;
    EdGeoCodeUrl: TLabeledEdit;
    UpdThrottleGeoCode: TUpDown;
    EdThrottleGeoCode: TLabeledEdit;
    GrpOverPass: TGroupBox;
    GrpGeoCodeGeneral: TGroupBox;
    ChkGeoCodeDialog: TCheckBox;
    ChkReverseGeoCodeDialog: TCheckBox;
    Label3: TLabel;
    TabGeoCoding: TTabSheet;
    EdThrottleOverPass: TLabeledEdit;
    Label4: TLabel;
    UpdThrottleOverpass: TUpDown;
    EdOverPassUrl: TLabeledEdit;
    ChkGeoCodingEnable: TCheckBox;
    CheckBox6: TCheckBox;
    Label5: TLabel;
    HintPause: TEdit;
    UpDHintPause: TUpDown;
    CheckBox7: TCheckBox;
    EdGeoCodeApiKey: TLabeledEdit;
    CheckBox8: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnBrowseFolder(Sender: TObject);
    procedure RadioGroupClick(Sender: TObject);
    procedure BtnSetupCleanClick(Sender: TObject);
    procedure BtnCleanClick(Sender: TObject);
    procedure BtnGenThumbsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPreferences: TFPreferences;

implementation

uses Main, ExifTool, MainDef, GeoMap,
     ExifToolsGUI_Utils, ExifToolsGUI_Thumbnails;

{$R *.dfm}

procedure TFPreferences.BtnSaveClick(Sender: TObject);
var
  i: integer;
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
    0:
      i := 96;
    1:
      i := 128;
    2:
      i := 160;
  end;
  FMain.ShellList.ThumbNailSize := i;
  GUIsettings.ThumbSize := RadioGroup3.ItemIndex;

  FMain.ShellList.ThumbAutoGenerate := ChkThumbAutoGenerate.Checked;
  GUIsettings.ThumbAutoGenerate := ChkThumbAutoGenerate.Checked;
  GUIsettings.ThumbCleanSet := EdThumbCleanset.EditText;

  GUIsettings.EnableGMap := CheckBox2.Checked;
  GUIsettings.UseExitDetails := CheckBox3.Checked;
  GUIsettings.AutoIncLine := CheckBox4.Checked;
  GUIsettings.DblClickUpdTags := CheckBox5.Checked;
  GUIsettings.ShowFolders := CheckBox6.Checked;
  GUIsettings.ShowHidden := CheckBox8.Checked;
  GUIsettings.ShowBreadCrumb := CheckBox7.Checked;
  Application.HintHidePause := UpDHintPause.Position;

  //GeoCode
  GeoSettings.GeoCodeUrl := EdGeoCodeUrl.Text;
  GeoSettings.GeoCodeApiKey := EdGeoCodeApiKey.Text;
  GeoSettings.ThrottleGeoCode := UpdThrottleGeoCode.Position;
  GeoSettings.OverPassUrl := EdOverPassUrl.Text;
  GeoSettings.ThrottleOverPass := UpdThrottleOverpass.Position;
  GeoSettings.GeoCodeDialog := ChkGeoCodeDialog.Checked;
  GeoSettings.GeoCodingEnable := ChkGeoCodingEnable.Checked;
  GeoSettings.ReverseGeoCodeDialog := ChkReverseGeoCodeDialog.Checked;

  if (GeoSettings.GeoCodingEnable) and
      ((GeoSettings.GeoCodeApiKey = '') or
       (GeoSettings.ThrottleGeoCode < 1000)) then
    ShowMessage('Check the GeoCode requirements. (Apikey required. Max 1 call per second for a free account)');
end;

procedure TFPreferences.BtnSetupCleanClick(Sender: TObject);
var
  SetupOK: boolean;
  Parm: string;
begin
  SetupOK := ExistsSageSet(EdThumbCleanset.EditText);
  if not SetupOK then
    SetupOK := (MessageDlgEx(Format('Overwrite Existing setting %s?', [EdThumbCleanset.EditText]), '', TMsgDlgType.mtWarning,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = idYes)
  else
    MessageDlgEx('Make sure that you only check ''Thumbnails'' in the next dialog.', '', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK]);
  if (SetupOK) then
  begin
    Parm := Format('CleanMgr /sageset:%s', [EdThumbCleanset.EditText]);
    if not RunAsAdmin(Handle, GetComSpec, '/c' + Parm, SW_HIDE) then
      MessageDlgEx(Format('Run ''%s'' as Admin failed.', [Parm]), '', TMsgDlgType.mtError, [mbOK]);
  end;
end;

procedure TFPreferences.BtnCleanClick(Sender: TObject);
var
  Parm: string;
begin
  Parm := Format('CleanMgr /sagerun:%s', [EdThumbCleanset.EditText]);
  if not RunAsAdmin(Handle, GetComSpec, '/c' + Parm, SW_HIDE) then
    MessageDlgEx(Format('Run ''%s'' as Admin failed.', [Parm]), '', TMsgDlgType.mtError, [mbOK]);
end;

procedure TFPreferences.BtnGenThumbsClick(Sender: TObject);
var
  xDir: string;
begin
  xDir := BrowseFolderDlg('Folder, including subfolders, to generate thumbnails for.' + #10 +
                          'Generating will be done in the background.', 0,
                           FMain.ShellList.Path);
  if (xDir <> '') then
  begin
    GenerateThumbs(xDir, true, FMain.ShellList.ThumbNailSize);
    Close;
  end;
end;

procedure TFPreferences.BtnBrowseFolder(Sender: TObject);
var
  xDir: string;
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
  I, N: smallint;
  Tx: string;
  ETResult: TStringList;
begin
  ETResult := TStringList.Create;
  try
    Left := FMain.Left + 8;
    Top := FMain.Top + 56;
    ET_OpenExec('-lang', '', ETResult, false);
    with ComboBox1 do
    begin
      Items.Clear;
      Items.Append('ExifTool standard (short)');
      I := ETResult.Count;
      if I > 0 then
      begin
        ETResult.Delete(0);
        dec(I);
      end;
      if I > 0 then
        for N := 0 to I - 1 do
          Items.Append(TrimLeft(ETResult[N]));
      Tx := GUIsettings.Language;
      if Tx = '' then
        ItemIndex := 0
      else
      begin
        I := Items.Count;
        N := 1;
        while N < I do
        begin
          if pos(Tx, Items[N]) = 1 then
            ItemIndex := N;
          inc(N);
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
    Tx := ET_Options.ETSeparator;
    Delete(Tx, 1, 6);
    SetLength(Tx, 1);
    LabeledEdit1.Text := Tx;
    RadioGroup3.ItemIndex := GUIsettings.ThumbSize;
    ChkThumbAutoGenerate.Checked := GUIsettings.ThumbAutoGenerate;
    EdThumbCleanset.Text := GUIsettings.ThumbCleanSet;

    CheckBox2.Checked := GUIsettings.EnableGMap;
    CheckBox3.Checked := GUIsettings.UseExitDetails;
    CheckBox4.Checked := GUIsettings.AutoIncLine;
    CheckBox5.Checked := GUIsettings.DblClickUpdTags;
    CheckBox6.Checked := GUIsettings.ShowFolders;
    CheckBox8.Checked := GUIsettings.ShowHidden;
    CheckBox8.Enabled := IsElevated;
    CheckBox7.Checked := GUIsettings.ShowBreadCrumb;
    UpDHintPause.Position := Application.HintHidePause;

    // GeoCode
    EdGeoCodeUrl.Text := GeoSettings.GeoCodeUrl;
    EdGeoCodeApiKey.Text := GeoSettings.GeoCodeApiKey;
    UpdThrottleGeoCode.Position := GeoSettings.ThrottleGeoCode;
    EdOverPassUrl.Text := GeoSettings.OverPassUrl;
    UpdThrottleOverpass.Position := GeoSettings.ThrottleOverPass;
    ChkGeoCodingEnable.Checked := GeoSettings.GeoCodingEnable;
    ChkGeoCodeDialog.Checked := GeoSettings.GeoCodeDialog;
    ChkReverseGeoCodeDialog.Checked := GeoSettings.ReverseGeoCodeDialog;

    AdvPageControl1.ActivePage := AdvTabGeneral;
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
