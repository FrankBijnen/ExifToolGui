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
    AdvTabIntegration: TTabSheet;
    CheckBox9: TCheckBox;
    GrpContextMenu: TGroupBox;
    BtnAdd2Context: TBitBtn;
    BtnRemoveFromContextMenu: TBitBtn;
    CheckBox10: TCheckBox;
    EdCommand: TLabeledEdit;
    MemoWin11: TMemo;
    CheckBox11: TCheckBox;
    GrpConfig: TGroupBox;
    EdETCustomConfig: TEdit;
    BtnEtCustomConfig: TButton;
    ChkCountryLocation: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnBrowseFolder(Sender: TObject);
    procedure RadioGroupClick(Sender: TObject);
    procedure BtnSetupCleanClick(Sender: TObject);
    procedure BtnCleanClick(Sender: TObject);
    procedure BtnGenThumbsClick(Sender: TObject);
    procedure BtnAdd2ContextClick(Sender: TObject);
    procedure BtnRemoveFromContextMenuClick(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
  private
    { Private declarations }
    var InstalledContext: boolean;
    procedure SetContextButtons;
  public
    { Public declarations }
  end;

var
  FPreferences: TFPreferences;

implementation

uses Main, ExifTool, MainDef, GeoMap,
     ExifToolsGUI_Utils, ExifToolsGUI_Thumbnails, UnitLangResources;

{$R *.dfm}

procedure TFPreferences.SetContextButtons;
var
  InstalledVerb: string;
begin
  InstalledVerb := ContextInstalled(Application.Title);
  InstalledContext := (InstalledVerb <> '');
  if (InstalledContext) then
    EdCommand.Text := InstalledVerb
  else
    EdCommand.Text := StrNotInstalled;

  BtnAdd2Context.Enabled := IsElevated and not InstalledContext;
  BtnRemoveFromContextMenu.Enabled := IsElevated and InstalledContext;
end;

procedure TFPreferences.BtnSaveClick(Sender: TObject);
var
  I: integer;
  Tx: string;
begin
  GUIsettings.Language := '';
  ET_Options.ETLangDef := '';
  I := ComboBox1.ItemIndex;
  if I > 0 then
  begin
    Tx := ComboBox1.Items[I];
    I := Pos(' ', Tx);
    SetLength(Tx, I - 1);
    GUIsettings.Language := Tx;
    ET_Options.ETLangDef := Tx + CRLF;
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
    ETCustomConfig := EdETCustomConfig.Text;
  end;
  with LabeledEdit1 do
  begin
    if (Trim(Text) = '') then
      Text := '*';
    ET_Options.ETSeparator := '-sep' + CRLF + Text + CRLF;
  end;

  case RadioGroup3.ItemIndex of
    0:
      I := 96;
    1:
      I := 128;
    2:
      I := 160;
  end;
  FMain.ShellList.ThumbNailSize := I;
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
  GUIsettings.EnableUnsupported := CheckBox11.Checked;
  GUIsettings.ShowBreadCrumb := CheckBox7.Checked;
  GUIsettings.MinimizeToTray := CheckBox9.Checked;
  GUIsettings.SingleInstanceApp := CheckBox10.Checked;
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
  GeoSettings.CountryCodeLocation := ChkCountryLocation.Checked;

  if (GeoSettings.GeoCodingEnable) and
      ((GeoSettings.GeoCodeApiKey = '') or
       (GeoSettings.ThrottleGeoCode < 1000)) then
    ShowMessage(StrCheckTheGeoCodeRe);

  // Make sure changes made by user are saved.
  SaveGUIini;
end;

procedure TFPreferences.BtnSetupCleanClick(Sender: TObject);
var
  SetupOK: boolean;
  Parm: string;
begin
  SetupOK := ExistsSageSet(EdThumbCleanset.EditText);
  if not SetupOK then
    SetupOK := (MessageDlgEx(Format(StrOverwriteExistingS, [EdThumbCleanset.EditText]), '', TMsgDlgType.mtWarning,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = idYes)
  else
    MessageDlgEx(StrMakeSureThatYouO, '', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK]);
  if (SetupOK) then
  begin
    Parm := Format('CleanMgr /sageset:%s', [EdThumbCleanset.EditText]);
    if not RunAsAdmin(Handle, GetComSpec, '/c' + Parm, SW_HIDE) then
      MessageDlgEx(Format(StrRunSAsAdminFail, [Parm]), '', TMsgDlgType.mtError, [mbOK]);
  end;
end;

procedure TFPreferences.CheckBox9Click(Sender: TObject);
begin
  GUIsettings.ShowBalloon := Checkbox9.Checked;
end;

procedure TFPreferences.BtnAdd2ContextClick(Sender: TObject);
var
  Verb: string;
begin
  Verb := StrOpenWith + Application.Title;
  Verb := InputBox(StrVerbToAddToContext, 'Verb', Verb);
  if (Verb = '') then
    MessageDlgEx(StrAVerbIsRequired, '', TMsgDlgType.mtError, [mbOK])
  else
    Add2Context(Application.Title, Verb);
  SetContextButtons;
end;

procedure TFPreferences.BtnRemoveFromContextMenuClick(Sender: TObject);
begin
  RemoveFromContext(Application.Title);
  SetContextButtons;
end;

procedure TFPreferences.BtnCleanClick(Sender: TObject);
var
  Parm: string;
begin
  Parm := Format('CleanMgr /sagerun:%s', [EdThumbCleanset.EditText]);
  if not RunAsAdmin(Handle, GetComSpec, '/c' + Parm, SW_HIDE) then
    MessageDlgEx(Format(StrRunSAsAdminFail, [Parm]), '', TMsgDlgType.mtError, [mbOK]);
end;

procedure TFPreferences.BtnGenThumbsClick(Sender: TObject);
var
  xDir: string;
begin
  xDir := BrowseFolderDlg(StrFolderIncludingSub + #10 +
                          StrGeneratingBackgr, 0,
                           FMain.ShellList.Path);
  if (xDir <> '') then
  begin
    GenerateThumbs(xDir, true, FMain.ShellList.ThumbNailSize);
    Close;
  end;
end;

procedure TFPreferences.BtnBrowseFolder(Sender: TObject);
var
  XDir: string;
begin
  if Sender = BtnStartupFolder then
  begin
    XDir := BrowseFolderDlg(StrSelectDefaultStart, 0);
    if XDir <> '' then
      EdStartupFolder.Text := XDir;
  end;
  if Sender = BtnExportMetaFolder then
  begin
    XDir := BrowseFolderDlg(StrSelectDefaultExpor, 0);
    if XDir <> '' then
      EdExportMetaFolder.Text := XDir;
  end;
  if Sender = BtnETOverride then
  begin
    XDir := BrowseFolderDlg(StrSelectExifToolFold, 0);
    if XDir <> '' then
      EdETOverride.Text := XDir;
  end;
  if Sender = BtnEtCustomConfig then
  begin
    FMain.OpenFileDlg.Filter := 'Config Files|*_config;*.cfg;*.config|*.*|*.*';
    if FMain.OpenFileDlg.Execute then
    begin
      XDir := FMain.OpenFileDlg.FileName;
      if XDir <> '' then
        EdETCustomConfig.Text := XDir;
    end;
  end;
end;

procedure TFPreferences.FormShow(Sender: TObject);
var
  I, N: smallint;
  Tx: string;
  ETResult: TStringList;
begin
  Left := FMain.Left + FMain.GUIBorderWidth;
  Top := FMain.Top + FMain.GUIBorderHeight;

  MemoWin11.Visible := CheckWin32Version(10, 0) and
                       (TOSversion.Build >= 22000); //WIN11

  ETResult := TStringList.Create;
  try
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
      EdETCustomConfig.Text := ETCustomConfig;
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
    CheckBox11.Checked := GUIsettings.EnableUnsupported;
    CheckBox8.Enabled := IsAdminUser or IsElevated;
    CheckBox7.Checked := GUIsettings.ShowBreadCrumb;
    CheckBox9.Checked := GUIsettings.MinimizeToTray;
    CheckBox10.Checked := GUIsettings.SingleInstanceApp;
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
    ChkCountryLocation.Checked := GeoSettings.CountryCodeLocation;

    AdvPageControl1.ActivePage := AdvTabGeneral;

    GrpContextMenu.Enabled := IsElevated;
    SetContextButtons;

    BtnSetupClean.Enabled := IsAdminUser;
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
