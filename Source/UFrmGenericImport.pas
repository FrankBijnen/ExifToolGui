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
    Button1: TButton;
    Button2: TButton;
    LvPreviews: TListView;
    Label1: TLabel;
    ChkAutoRotate: TCheckBox;
    CmbCrop: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    var
      Preview: string;
    procedure DisplayHint(Sender: TObject);
    procedure BeforeImport(Sender: TObject; ADirJpg: string);
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

procedure TFGenericImport.BeforeImport(Sender: TObject; ADirJpg: string);
var SelFiles: TstringList;
    AFile: string;
    AnImport: string;
    N: integer;
    Modulo: integer;
    Angle: integer;
    ANitem: TListItem;
begin
  SelFiles := TStringList.Create;
  SelFiles.Text := Fmain.GetSelectedFiles('', false);
  ETcmd := '';
  try
    for ANitem in LvPreviews.Items do
    begin
      if (ANitem.Checked = false) then
        continue;

      for Afile in SelFiles do
      begin

        // Only care about JPG
        AnImport := IncludeTrailingPathDelimiter(ADirJpg) + ChangeFileExt(Afile, '.jpg');
        if not FileExists(AnImport) then
          continue;

        Modulo := 0;
        case CmbCrop.ItemIndex of
          1: Modulo := 8;
          2: Modulo := 16;
        end;

        Angle := 0;
        if (ChkAutoRotate.Checked) then
        begin
          ET_OpenExec('-s3' + CRLF + '-exif:Orientation#', FMain.GetSelectedFiles(Afile, true), ETouts, ETerrs);
          N := StrToIntDef(LeftStr(ETouts, 1), 1);
          case N of
            3: Angle := 180;
            6: Angle := 270;
            8: Angle := 90;
          end;
        end;
        PerformLossLess(AnImport, Angle, Modulo);

        ETcmd := ETcmd + Preview + AnImport + CRLF + FMain.GetSelectedFiles(Afile, true) + CRLF + '-execute' + CRLF;
      end;
    end;
  finally
    SelFiles.Free;
  end;
end;

procedure TFGenericImport.Button2Click(Sender: TObject);
var
  ANitem: TListItem;
  DirJpg: string;
  CrWait, CrNormal: HCURSOR;
begin
  for ANitem in LvPreviews.Items do
  begin
    if ANitem.Checked then
    begin
      Preview := ET_Options.GetOptions(true) + '-' + ANitem.Caption + ':' + ANitem.SubItems[0] + '<=';
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

  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    BeforeImport(Sender, DirJpg);

    ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETouts, ETerrs);
  finally
    SetCursor(CrNormal);
  end;

  if (ETerrs = '') then
    ModalResult := mrOK;
end;

procedure TFGenericImport.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFGenericImport.FormCreate(Sender: TObject);
begin
  ChkAutoRotate.Checked := true;
  CmbCrop.ItemIndex := 1;
end;

procedure TFGenericImport.FormShow(Sender: TObject);
var
  ETResult: TStringList;
  AMaxPos: integer;
  AListItem: TListItem;
  APreviewList: TPreviewInfoList;
  APreviewInfo: TPreviewInfo;
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  Application.OnHint := DisplayHint;

  ETResult := TStringList.Create;
  try
    LvPreviews.Items.Clear;
    ETcmd := '-s1' + CRLF + '-a' + CRLF + '-G' + CRLF + '-Preview:All';
    ET_OpenExec(ETcmd, FMain.GetFirstSelectedFile, ETResult);
    APreviewList := GetPreviews(ETResult, AMaxPos);
    try
      for APreviewInfo in APreviewList do
      begin
        AListItem := LvPreviews.Items.Add;
        AListItem.Caption := APreviewInfo.GroupName;
        AListItem.SubItems.Add(APreviewInfo.TagName);
        AListItem.SubItems.Add(APreviewInfo.SizeString);
      end;
    finally
      APreviewList.Free;
    end;

    // Check the greatest
    if (AMaxPos >= 0) then
      LvPreviews.Items[AMaxPos].Checked := true;

  finally
    Button2.Enabled := LvPreviews.Items.Count > 0;
    ETResult.Free;
  end;
end;

end.
