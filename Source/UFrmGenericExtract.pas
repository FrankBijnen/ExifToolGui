unit UFrmGenericExtract;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFGenericExtract = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    BtnCancel: TButton;
    BtnExecute: TButton;
    LvPreviews: TListView;
    Label1: TLabel;
    ChkSubdirs: TCheckBox;
    ChkAutoRotate: TCheckBox;
    CmbCrop: TComboBox;
    ChkOverWrite: TCheckBox;
    LblSample: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure AfterExtract(Sender: TObject);
  public
    { Public declarations }
    var
      ETcmd, ETouts, ETerrs: string;
  end;

var
  FGenericExtract: TFGenericExtract;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils, ExifToolsGui_LossLess, UnitLangResources;

{$R *.dfm}

procedure TFGenericExtract.AfterExtract(Sender: TObject);
var SelFiles: TstringList;
    AFile: string;
    ExtractDir: string;
    AnExtract: string;
    N: integer;
    Angle: integer;
    Modulo: integer;
    ANitem: TListItem;
    Sep: Char;
begin
  SelFiles := TStringList.Create;
  SelFiles.Text := Fmain.GetSelectedFiles(false); //Only filename
  try
    // Crop?
    Modulo := 0;
    case CmbCrop.ItemIndex of
      1: Modulo := 8;
      2: Modulo := 16;
    end;

    for ANitem in LvPreviews.Items do
    begin
      if (ANitem.Checked = false) then
        continue;

      if (ChkSubdirs.Checked) then
        Sep := PathDelim
      else
        Sep := '#';
      ExtractDir := IncludeTrailingPathDelimiter(Fmain.ShellList.Path) + ANitem.Caption + Sep + Anitem.SubItems[0] + Sep;

      for AFile in SelFiles do
      begin

        // Only care about JPG
        AnExtract := ExtractDir + ChangeFileExt(AFile, '.jpg');
        if not FileExists(AnExtract) then
          continue;

        Angle := 0;
        if (ChkAutoRotate.Checked) then
        begin
          ET.OpenExec('-s3' + CRLF + '-exif:Orientation#', FMain.GetSelectedFile(AFile), ETouts, ETerrs);
          N := StrToIntDef(LeftStr(ETouts, 1), 1);
          case N of
            3: Angle := 180;
            6: Angle := 90;
            8: Angle := 270;
          end;
        end;
        StatusBar1.SimpleText := Format(StrRotatingSAngle, [AnExtract, Angle, Modulo]);
        PerformLossLess(AnExtract, Angle, Modulo);
      end;
    end;
  finally
    SelFiles.Free;
  end;
end;

procedure TFGenericExtract.BtnExecuteClick(Sender: TObject);
var
  ANitem: TListItem;
  HasChecks: boolean;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    ETcmd := '-b' + CRLF;
    if ChkOverWrite.Checked then
      ETcmd := ETcmd  + '-W!' + CRLF
    else
      ETcmd := ETcmd  + '-W' + CRLF;

    if (ET.Options.ETAPIWindowsWideFile <> '') then
      ETcmd := ETcmd + '.\%d\'
    else
      ETcmd := ETcmd + '%d\';

    if ChkSubdirs.Checked then
      ETcmd := ETcmd + '%g1\%t\%f.%s' + CRLF
    else
      ETcmd := ETcmd + '%g1#%t#%f.%s' + CRLF;

    HasChecks := false;
    for ANitem in LvPreviews.Items do
    begin
      if ANitem.Checked then
      begin
        ETcmd := ETcmd + '-' + ANitem.Caption + ':' + ANitem.SubItems[0] + CRLF;
        HasChecks := true;
      end;
    end;
    if (HasChecks = false) then
    begin
      ShowMessage(StrCheckAtLeast1Pre);
      exit;
    end;

    StatusBar1.SimpleText := StrExtractingPreviews;
    ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETouts, ETerrs);

    // Do AfterExtract always, even if errors occurred.
    AfterExtract(Sender);

    StatusBar1.SimpleText := StrAllDone;
  finally
    SetCursor(CrNormal);
  end;

  if (ETerrs = '') then
    ModalResult := mrOK;
end;

procedure TFGenericExtract.FormCreate(Sender: TObject);
begin
  ChkSubdirs.Checked := true;
  ChkOverWrite.Checked := true;
  ChkAutoRotate.Checked := true;
  CmbCrop.ItemIndex := 0;
end;

procedure TFGenericExtract.FormShow(Sender: TObject);
begin
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  StatusBar1.SimpleText := '';
  LblSample.Caption := Format(StrSampleS, [ExtractFileName(Fmain.GetFirstSelectedFile)]);
  FillPreviewInListView(FMain.GetFirstSelectedFile, LvPreviews);
  BtnExecute.Enabled := LvPreviews.Items.Count > 0;
end;

end.
