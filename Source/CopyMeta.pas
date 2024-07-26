unit CopyMeta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons;

type
  TFCopyMetadata = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    Label2: TLabel;
    BtnCancel: TButton;
    Label1: TLabel;
    BtnExecute: TButton;
    Label3: TLabel;
    LvTagNames: TListView;
    BtnPreview: TButton;
    PnlButtons: TPanel;
    SpbAdd: TSpeedButton;
    SpbDel: TSpeedButton;
    SpbEdit: TSpeedButton;
    SpbReset: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SpbEditClick(Sender: TObject);
    procedure SpbDelClick(Sender: TObject);
    procedure SpbAddClick(Sender: TObject);
    procedure SpbResetClick(Sender: TObject);
    procedure BtnPreviewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
  private
    { Private declarations }
    FSample: string;
    procedure SetupListView;
    procedure GetSelectedTags;
    procedure GetTagNames;
    procedure DisplayHint(Sender: TObject);
  public
    procedure SetSample(ASample: string);
    function TagSelection: string;
    { Public declarations }
  end;

var
  FCopyMetadata: TFCopyMetadata;

implementation

uses
  Main, MainDef, ExifToolsGUI_Utils, ExifTool, LogWin, UnitLangResources, UFrmTagNames,
  Vcl.Themes;

{$R *.dfm}

var FStyleServices: TCustomStyleServices;

procedure TFCopyMetadata.SetupListView;
var
  ATag, AllTags: string;
  ANItem: TListItem;
begin
  LvTagNames.Items.BeginUpdate;
  try
    LvTagNames.Items.Clear;
    AllTags := ExcludeCopyTagList;
    while (AllTags <> '') do
    begin
      ATag := NextField(AllTags, ' ');
      ANItem := LvTagNames.Items.Add;
      ANitem.Caption := ATag;
      ANItem.Checked := (Pos(' ' + ATag + ' ', ' ' + SelExcludeCopyTagList) > 0);
    end;
  finally
    LvTagNames.Items.EndUpdate;
  end;
end;

procedure TFCopyMetadata.SpbAddClick(Sender: TObject);
begin
  FrmTagNames.SetSample(FSample);
  if (FrmTagNames.ShowModal = IDOK) then
    LvTagNames.Items.Add.Caption := FrmTagNames.SelectedTag;
end;

procedure TFCopyMetadata.SpbResetClick(Sender: TObject);
begin
  ExcludeCopyTagList := DefExcludeCopyTags;
  SelExcludeCopyTagList := '';
  SetupListView;
end;

procedure TFCopyMetadata.SpbEditClick(Sender: TObject);
begin
  if (LvTagNames.Selected <> nil) then
  begin
    BtnExecute.Default := false;
    LvTagNames.Selected.EditCaption;
  end;
end;

procedure TFCopyMetadata.SpbDelClick(Sender: TObject);
begin
  if (LvTagNames.Selected <> nil) then
    LvTagNames.Selected.Delete;
end;

procedure TFCopyMetadata.GetTagNames;
var
  ANItem: TListItem;
begin
  ExcludeCopyTagList := '';
  for ANItem in LvTagNames.Items do
    ExcludeCopyTagList := ExcludeCopyTagList + ANItem.Caption + ' ';
end;

procedure TFCopyMetadata.GetSelectedTags;
var
  ANItem: TListItem;
begin
  SelExcludeCopyTagList := '';
  for ANItem in LvTagNames.Items do
  begin
    if (ANitem.Checked) then
      SelExcludeCopyTagList := SelExcludeCopyTagList + ANItem.Caption + ' ';
  end;
end;

function TFCopyMetadata.TagSelection: string;
var
  ANItem: TListItem;
begin
  // Save selection. Will be stored in INI
  GetTagNames;
  GetSelectedTags;

  result := '';
  for ANItem in LvTagNames.Items do
  begin
    if (ANitem.Checked = false) then
      result := result + '--' + RemoveInvalidTags(ANItem.Caption) + CRLF;
  end;
end;

procedure TFCopyMetadata.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FlogWin.Close;
end;

procedure TFCopyMetadata.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  SetupListView;

  Application.OnHint := DisplayHint;
end;

procedure TFCopyMetadata.SetSample(ASample: string);
begin
  FSample := ASample;
end;

procedure TFCopyMetadata.BtnPreviewClick(Sender: TObject);
var
  ETcmd: string;
begin
  ETcmd := '-G0:1' + CRLF + '-a' + CRLF + '-All:all' + CRLF + '-s1' + CRLF + TagSelection;
  FLogWin.Show;
  ET_OpenExec(ETcmd, FSample);
end;

procedure TFCopyMetadata.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFCopyMetadata.LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  StyledDrawListviewItem(FStyleServices, Sender, Item, State);
end;

procedure TFCopyMetadata.LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
begin
  S := RemoveInvalidTags(S);
  BtnExecute.Default := true;
end;

end.
