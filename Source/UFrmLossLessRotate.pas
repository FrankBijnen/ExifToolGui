unit UFrmLossLessRotate;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFLossLessRotate = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    BtnCancel: TButton;
    BtnExecute: TButton;
    LvPreviews: TListView;
    LblPreview: TLabel;
    CmbCrop: TComboBox;
    LblSample: TLabel;
    CmbRotate: TComboBox;
    CmbResetOrientation: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function DoRotate(Sender: TObject): boolean;
  public
    { Public declarations }
    var
      ETcmd, ETouts, ETerrs: string;
  end;

var
  FLossLessRotate: TFLossLessRotate;

implementation

uses
  System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils, ExifToolsGui_LossLess, MainDef,
  UnitLangResources;

{$R *.dfm}

function TFLossLessRotate.DoRotate(Sender: TObject): boolean;
var
  ANitem: TListItem;
  Preview: string;
  FullPathName: string;
  FileName: string;
  Modulo: integer;
  N: integer;
  Angle: integer;
  ASize: TSize;
begin
  result := true;

  // Get selected Preview
  Preview := '';
  for ANitem in LvPreviews.Items do
  begin
    if (ANitem.Checked) then
    begin
      Preview := '-' + ANitem.Caption + ':' + ANitem.SubItems[0];
      break;
    end;
  end;

  // Crop?
  Modulo := 0;
  case CmbCrop.ItemIndex of
    1: Modulo := 8;
    2: Modulo := 16;
  end;

  for AnItem in Fmain.ShellList.Items do
  begin
    if (AnItem.Selected = false) then
      continue;
    FileName := Fmain.ShellList.RelFileName(AnItem.Index);
    FullPathName := Fmain.ShellList.Folders[AnItem.Index].PathName;
    if (IsJpeg(FullPathName) = false) then
      continue;

    // Angle to rotate
    Angle := 0;
    case CmbRotate.ItemIndex of
      1:  begin
          // Read current Orientation
            ET_OpenExec('-s3' + CRLF + '-exif:Orientation#', FileName, ETouts, ETerrs);
            result := result and (ETerrs = '');
            N := StrToIntDef(LeftStr(ETouts, 1), 1);
            case N of
              3: Angle := 180;
              6: Angle := 90;
              8: Angle := 270;
            end;
          end;
       2: Angle := 90;
       3: Angle := 180;
       4: Angle := 270;
    end;

    // Rotate and or Crop as requested.
    if (Angle <> 0) or
       (Modulo <> 0) then
    begin
      StatusBar1.SimpleText := Format(StrRotatingSAngle, [FullPathName, Angle, Modulo]);
      ASize := PerformLossLess(FullPathName, Angle, Modulo);
    end;

    // reset orientation and modified date
    ETcmd := '';
    case CmbResetOrientation.ItemIndex of
      1: ETcmd := '1';
      2: ETcmd := '3';
      3: ETcmd := '6';
      4: ETcmd := '8';
    end;
    if (ETcmd <> '') then
      ETcmd := '-exif:Orientation#=' + ETcmd;

    // Modified date
    if Fmain.MaPreserveDateMod.Checked then
      ETcmd := ETcmd + CRLF + '-FileModifyDate<Exif:DateTimeOriginal' + CRLF;

    if (Etcmd <> '') then
    begin
      StatusBar1.SimpleText := Format(StrResettingOrient, [FileName]);
      ET_OpenExec(ETcmd, FileName, ETouts, ETerrs);
      result := result and (ETerrs = '');
    end;

    // Rotate preview?
    if (Preview <> '') then
    begin
      ETcmd := '-b' + CRLF + '-W!' + CRLF + GetPreviewTmp + CRLF;
      ETcmd := ETcmd + Preview;
      StatusBar1.SimpleText := Format(StrExtractingPreviewF, [FileName]);
      ET_OpenExec(ETcmd, FileName, ETouts, ETerrs);
      result := result and (ETerrs = '');

      StatusBar1.SimpleText := Format(StrRotatingPreviewS, [GetPreviewTmp, Angle, Modulo]);
      ASize := PerformLossLess(GetPreviewTmp, Angle, 0);

      ETcmd := Preview + '<=' + GetPreviewTmp + CRLF;
      StatusBar1.SimpleText := Format(StrImportingPreviewIn, [FileName]);
      ET_OpenExec(ETcmd, FileName, ETouts, ETerrs);
      result := result and (ETerrs = '');
    end;
  end;
end;

procedure TFLossLessRotate.BtnExecuteClick(Sender: TObject);
var
  RotateStatus: boolean;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    RotateStatus := DoRotate(Sender);
    StatusBar1.SimpleText := StrAllDone;
  finally
    SetCursor(CrNormal);
  end;
  if (RotateStatus) then
    ModalResult := mrOK;
end;

procedure TFLossLessRotate.FormCreate(Sender: TObject);
begin
  CmbResetOrientation.ItemIndex := 1;
  CmbRotate.ItemIndex := 1;
  CmbCrop.ItemIndex := 0;
end;

procedure TFLossLessRotate.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  StatusBar1.SimpleText := '';
  LblSample.Caption := Format(StrSampleS, [ExtractFileName(Fmain.GetFirstSelectedFile)]);
  FillPreviewInListView(FMain.GetFirstSelectedFile, LvPreviews);
end;

end.
