unit UFrmGenericImport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFGenericImport = class(TForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    BtnCancel: TButton;
    BtnExecute: TButton;
    LvPreviews: TListView;
    Label1: TLabel;
    ChkAutoRotate: TCheckBox;
    CmbCrop: TComboBox;
    LblSample: TLabel;
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
begin
  result := false;

  Preview := '';
  for ANitem in LvPreviews.Items do
  begin
    if ANitem.Checked then
    begin
      Preview := '-' + ANitem.Caption + ':' + ANitem.SubItems[0];
      break;
    end;
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
    SelFiles.Text := Fmain.GetSelectedFiles('', false);

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
          ET_OpenExec('-s3' + CRLF + '-exif:Orientation#', FMain.GetSelectedFiles(AFile, true), ETouts, ETerrs);
          N := StrToIntDef(LeftStr(ETouts, 1), 1);
          case N of
            3: Angle := 180;
            6: Angle := 270;
            8: Angle := 90;
          end;
        end;

        if (Modulo = 0) and
           (Angle = 0) then                  // Jpeg does not need to be cropped or rotated
          ETcmd := Preview + '=' + CRLF +    // Removing preview first works more reliable when sizes are different. E.G.: Jpeg is cropped
                   Preview + '<=' + AnImport
        else
        begin
          StatusBar1.SimpleText := Format('Rotating %s Angle: %d Modulo: %d', [GetPreviewTmp, Angle, Modulo]);
          PerformLossLess(AnImport, Angle, Modulo, GetPreviewTmp);
          ETcmd := Preview + '=' + CRLF +    // Removing preview first works more reliable when sizes are different. E.G.: Jpeg is cropped
                   Preview + '<=' + GetPreviewTmp;
        end;

        StatusBar1.SimpleText := Format('Updating preview in: %s', [AFile]);
        ET_OpenExec(ETcmd, FMain.GetSelectedFiles(AFile, true), ETouts, ETerrs);
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
