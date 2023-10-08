unit UFrmGenericExtract;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFGenericExtract = class(TForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    LvPreviews: TListView;
    Label1: TLabel;
    ChkSubdirs: TCheckBox;
    ChkAutoRotate: TCheckBox;
    CmbCrop: TComboBox;
    ChkOverWrite: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayHint(Sender: TObject);
    procedure AfterExtract(Sender: TObject);
  public
    { Public declarations }
    var
      ETcmd, ETouts, ETerrs: string;
  end;

var
  FGenericExtract: TFGenericExtract;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils, ExifToolsGui_LossLess;

{$R *.dfm}

procedure TFGenericExtract.AfterExtract(Sender: TObject);
var SelFiles: TstringList;
    AFile: string;
    AnExtract: string;
    N: integer;
    Angle: integer;
    Modulo: integer;
    ANitem: TListItem;
    Sep: Char;
begin
  SelFiles := TStringList.Create;
  SelFiles.Text := Fmain.GetSelectedFiles('', false);
  try
    for ANitem in LvPreviews.Items do
    begin
      if (ANitem.Checked = false) then
        continue;

      for Afile in SelFiles do
      begin
        if (ChkSubdirs.Checked) then
          Sep := PathDelim
        else
          Sep := '#';

        // Only care about JPG
        AnExtract := IncludeTrailingPathDelimiter(Fmain.ShellList.Path) + ANitem.Caption + Sep + Anitem.SubItems[0] + Sep + ChangeFileExt(Afile, '.jpg');
        if not FileExists(AnExtract) then
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
            6: Angle := 90;
            8: Angle := 270;
          end;
        end;
        PerformLossLess(AnExtract, Angle, Modulo);
      end;
    end;
  finally
    SelFiles.Free;
  end;
end;

procedure TFGenericExtract.Button2Click(Sender: TObject);
var 
  ANitem: TListItem;
  Previews: string;
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
    if ChkSubdirs.Checked then
      ETcmd := ETcmd + '%g\%t\%f.%s' + CRLF
    else
      ETcmd := ETcmd + '%g#%t#%f.%s' + CRLF;
    Previews := '';
    for ANitem in LvPreviews.Items do
    begin
      if ANitem.Checked then
        Previews := Previews + '-' + ANitem.Caption + ':' + ANitem.SubItems[0] + CRLF;
    end;
    if (Previews = '') then
    begin
      ShowMessage('Check at least 1 preview to extract');
      exit;
    end;
    ETcmd := ETcmd + Previews;
    ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETouts, ETerrs);

    AfterExtract(Sender);
    
  finally
    SetCursor(CrNormal);
  end;
  
  if (ETerrs = '') then
    ModalResult := mrOK;
end;

procedure TFGenericExtract.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFGenericExtract.FormCreate(Sender: TObject);
begin
  ChkSubdirs.Checked := true;
  ChkOverWrite.Checked := true;
  ChkAutoRotate.Checked := true;
  CmbCrop.ItemIndex := 0;
end;

procedure TFGenericExtract.FormShow(Sender: TObject);
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
