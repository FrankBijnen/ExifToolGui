unit UFrmGenericImport;
//TODO Decide if we want to enable. For now to dangerous.
{.$DEFINE ENABLEREMOVEOTHERS}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFGenericImport = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    BtnCancel: TButton;
    BtnExecute: TButton;
    LvPreviews: TListView;
    Label1: TLabel;
    ChkAutoRotate: TCheckBox;
    CmbCrop: TComboBox;
    LblSample: TLabel;
    ChkRemoveOthers: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function DoImportPreview(Sender: TObject): boolean;
  public
    { Public declarations }
    var
      ETcmd, ETouts, ETerrs: string;
  end;

var
  FGenericImport: TFGenericImport;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils, ExifToolsGui_LossLess, MainDef;

{$R *.dfm}

function TFGenericImport.DoImportPreview(Sender: TObject): boolean;
var SelFiles: TstringList;
    DirJpg: string;
    AFile: string;
    AnImport: string;
    N: integer;
    Modulo: integer;
    Angle: integer;
    ANitem: TListItem;
    Preview: string;
    IFD: string;
    ASize: TSize;
begin
  result := false;

  Preview := '';
  IFD := '';
  for ANitem in LvPreviews.Items do
  begin
    if (ANitem.Checked) and
       (Preview = '') then
    begin
      IFD := ANitem.Caption;
      Preview := '-' + IFD + ':' + ANitem.SubItems[0]; // Suppress ifd0 bytestripcount
      break;
    end
  end;

  if (Preview = '') then
  begin
    ShowMessage('Check 1 preview to import');
    exit;
  end;

  DirJPG := BrowseFolderDlg('Select folder containing JPG images', 1, Fmain.ShellList.Path);
  if (DirJpg = '') then
    exit;

  result := true;
  SelFiles := TStringList.Create;
  try
    SelFiles.Text := Fmain.GetSelectedFiles(false); // Only Filename

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

      for AFile in SelFiles do
      begin

        // Only care about JPG
        AnImport := IncludeTrailingPathDelimiter(DirJPG) + ChangeFileExt(AFile, '.jpg');
        if not FileExists(AnImport) then
          continue;

        Angle := 0;
        if (ChkAutoRotate.Checked) then
        begin
          ET_OpenExec('-s3' + CRLF + '-exif:Orientation#', FMain.GetSelectedFile(AFile), ETouts, ETerrs);
          N := StrToIntDef(LeftStr(ETouts, 1), 1);
          case N of
            3: Angle := 180;
            6: Angle := 270;
            8: Angle := 90;
          end;
        end;

        StatusBar1.SimpleText := Format('Rotating %s Angle: %d Modulo: %d', [GetPreviewTmp, Angle, Modulo]);
        ASize := PerformLossLess(AnImport, Angle, Modulo, GetPreviewTmp);
        ETcmd := '';
        if (ChkRemoveOthers.Checked) then // Remove others?
        begin
          EtCmd := '-a' + CRLF + '-Preview:All=' + CRLF;
          StatusBar1.SimpleText := Format('Updating preview in: %s', [AFile]);
          ET_OpenExec(ETcmd, FMain.GetSelectedFile(AFile), ETouts, ETerrs);
          result := result and (ETerrs = '');
        end;

        ETcmd := Preview + '<=' + GetPreviewTmp + CRLF +
                 '-' + IFD + ':ImageWidth=' + IntToStr(ASize.cx) + CRLF +
                 '-' + IFD + ':ImageHeight=' + IntToStr(ASize.cy);
        StatusBar1.SimpleText := Format('Updating preview in: %s', [AFile]);
        ET_OpenExec(ETcmd, FMain.GetSelectedFile(AFile), ETouts, ETerrs);
        result := result and (ETerrs = '');
      end;
    end;
  finally
    SelFiles.Free;
  end;
end;

procedure TFGenericImport.BtnExecuteClick(Sender: TObject);
var
  ImportStatus: boolean;
  CrWait, CrNormal: HCURSOR;
begin

  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    ImportStatus := DoImportPreview(Sender);
    StatusBar1.SimpleText := 'All Done';
  finally
    SetCursor(CrNormal);
  end;

  if (ImportStatus) then
    ModalResult := mrOK;
end;

procedure TFGenericImport.FormCreate(Sender: TObject);
begin
  ChkAutoRotate.Checked := true;
  ChkRemoveOthers.Visible := false;
  ChkRemoveOthers.Checked := false;
{$IFDEF ENABLEREMOVEOTHERS}
  ChkRemoveOthers.Visible := true;
{$ENDIF}
  CmbCrop.ItemIndex := 0;
end;

procedure TFGenericImport.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  StatusBar1.SimpleText := '';
  LblSample.Caption := Format('Sample: %s', [ExtractFileName(Fmain.GetFirstSelectedFile)]);
  FillPreviewInListView(FMain.GetFirstSelectedFile, LvPreviews);
  BtnExecute.Enabled := LvPreviews.Items.Count > 0;
end;

end.
