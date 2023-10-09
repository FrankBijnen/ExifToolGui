unit UFrmLossLessRotate;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;
type
  TFLossLessRotate = class(TForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    LvPreviews: TListView;
    Label1: TLabel;
    ChkResetOrientation: TCheckBox;
    CmbCrop: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    function DoRotate(Sender: TObject): boolean;
  public
    { Public declarations }
    var
      ETcmd, ETouts, ETerrs: string;
  end;

var
  FLossLessRotate: TFLossLessRotate;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils, ExifToolsGui_LossLess, MainDef;

{$R *.dfm}

function TFLossLessRotate.DoRotate(Sender: TObject): boolean;
var
  APreviewItem: TListItem;
  ANitem: TListItem;
  FullPathName: string;
  FileName: string;
  Modulo: integer;
  N: integer;
  Angle: integer;
begin
  result := true;

  // Get selected Preview
  APreviewItem := nil;
  for ANitem in LvPreviews.Items do
  begin
    if (ANitem.Checked) then
    begin
      APreviewItem := ANitem;
      break;
    end;
  end;

  for AnItem in Fmain.ShellList.Items do
  begin
    if (AnItem.Selected = false) then
      continue;
    FileName := Fmain.ShellList.FileName(AnItem.Index);
    FullPathName := Fmain.ShellList.Folders[AnItem.Index].PathName;
    if (IsJpeg(FullPathName) = false) then
      continue;
    Modulo := 0;
    case CmbCrop.ItemIndex of
      1: Modulo := 8;
      2: Modulo := 16;
    end;
    // Read current Orientation
    ET_OpenExec('-s3' + CRLF + '-exif:Orientation#', FileName, ETouts, ETerrs);
    result := result and (ETerrs = '');
    N := StrToIntDef(LeftStr(ETouts, 1), 1);
    case N of
      3: Angle := 180;
      6: Angle := 90;
      8: Angle := 270;
      else
        continue;  // No need to modify
    end;
    // Rotate, to match orientation
    PerformLossLess(FullPathName, Angle, Modulo);
    // reset orientation and modified date
    ETcmd := '';
    if (ChkResetOrientation.Checked) then
      ETcmd := '-s3' + CRLF + '-exif:Orientation#=1';
    if Fmain.MPreserveDateMod.Checked then
      ETcmd := ETcmd + CRLF + '-FileModifyDate<Exif:DateTimeOriginal' + CRLF;
    if (Etcmd <> '') then
      ET_OpenExec(ETcmd, FileName, ETouts, ETerrs);
    result := result and (ETerrs = '');

    if (APreviewItem <> nil) then
    begin
      ETcmd := '-b' + CRLF + '-W!' + CRLF + GetPreviewTmp + CRLF;
      ETcmd := ETcmd + '-' + APreviewItem.Caption + ':' + APreviewItem.SubItems[0];
      ET_OpenExec(ETcmd, FileName, ETouts, ETerrs);
      result := result and (ETerrs = '');
      PerformLossLess(GetPreviewTmp, Angle, 0);
      ETcmd := '-' + APreviewItem.Caption + ':' + APreviewItem.SubItems[0] + '<=' + GetPreviewTmp + CRLF;
      ET_OpenExec(ETcmd, FileName, ETouts, ETerrs);
      result := result and (ETerrs = '');
    end;
  end;
end;

procedure TFLossLessRotate.Button2Click(Sender: TObject);
var
  RotateStatus: boolean;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    RotateStatus := DoRotate(Sender);
  finally
    SetCursor(CrNormal);
  end;
  if (RotateStatus) then
    ModalResult := mrOK;
end;

procedure TFLossLessRotate.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFLossLessRotate.FormCreate(Sender: TObject);
begin
  ChkResetOrientation.Checked := true;
  CmbCrop.ItemIndex := 1;
end;

procedure TFLossLessRotate.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  Application.OnHint := DisplayHint;
  FillPreviewInListView(FMain.GetFirstSelectedFile, LvPreviews);
  Button2.Enabled := LvPreviews.Items.Count > 0;
end;

end.
