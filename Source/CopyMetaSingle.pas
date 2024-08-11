unit CopyMetaSingle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TFCopyMetaSingle = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    ChkImportAll: TCheckBox;
    BtnCancel: TButton;
    BtnExecute: TButton;
    Label1: TLabel;
    ChkNoOverWrite: TCheckBox;
    PnlButtons: TPanel;
    SpbAdd: TSpeedButton;
    SpbDel: TSpeedButton;
    SpbEdit: TSpeedButton;
    SpbPredefined: TSpeedButton;
    LvTagNames: TListView;
    BtnPreview: TButton;
    ImageCollection: TImageCollection;
    VirtualImageList: TVirtualImageList;
    procedure FormShow(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure ChkImportAllClick(Sender: TObject);
    procedure LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure BtnPreviewClick(Sender: TObject);
    procedure SpbAddClick(Sender: TObject);
    procedure SpbDelClick(Sender: TObject);
    procedure SpbEditClick(Sender: TObject);
    procedure LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
    procedure LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
    procedure SpbPredefinedClick(Sender: TObject);
  private
    { Private declarations }
    SrcFile: string;
    FShowLogWindow: boolean;
    procedure DisplayHint(Sender: TObject);
    procedure SetupListView;
    procedure GetSelectedTags;
    procedure GetTagNames;
    procedure CheckSelection;
  public
    { Public declarations }
    procedure PrepareShow(ASource: string);
    function TagSelection: string;
  end;

var
  FCopyMetaSingle: TFCopyMetaSingle;

implementation

uses
  Main, ExifTool, UnitLangResources, ExifToolsGUI_Utils, LogWin, UFrmTagNames, UFrmPredefinedTags, MainDef,
  VCL.Themes;

{$R *.dfm}

var FStyleServices: TCustomStyleServices;

procedure TFCopyMetaSingle.SetupListView;
var
  ATag, AllTags: string;
  ANItem: TListItem;
begin
  LvTagNames.Tag := 1;
  LvTagNames.Items.BeginUpdate;
  try
    LvTagNames.Items.Clear;
    if (ChkImportAll.Checked = false) then
    begin
      AllTags := CopySingleTagList;
      while (AllTags <> '') do
      begin
        ATag := NextField(AllTags, ' ');
        ANItem := LvTagNames.Items.Add;
        ANItem.Checked := (Pos(' ' + ATag + ' ', ' ' + SelCopySingleTagList) > 0);
        SetTagItem(ANItem, ATag);
      end;
    end;
  finally
    LvTagNames.Items.EndUpdate;
    LvTagNames.Tag := 0;
  end;
end;

procedure TFCopyMetaSingle.SpbAddClick(Sender: TObject);
var
  AnItem: TlistItem;
begin
  FrmTagNames.SetSample(SrcFile);
  if (FrmTagNames.ShowModal = IDOK) then
  begin
    AnItem := LvTagNames.Items.Add;
    SetTagItem(AnItem, FrmTagNames.SelectedTag(true));
  end;
end;

procedure TFCopyMetaSingle.SpbDelClick(Sender: TObject);
begin
  if (LvTagNames.Selected <> nil) then
    LvTagNames.Selected.Delete;
end;

procedure TFCopyMetaSingle.SpbEditClick(Sender: TObject);
begin
  if (LvTagNames.Selected <> nil) then
  begin
    BtnExecute.Default := false;
    LvTagNames.Selected.Checked := false;
    LvTagNames.Selected.EditCaption;
  end;
end;

procedure TFCopyMetaSingle.SpbPredefinedClick(Sender: TObject);
begin
  GetTagNames;

  FrmPredefinedTags.Caller := TIniTagsData.idtCopySingleTags;
  FrmPredefinedTags.CallerTags := CopySingleTagList;
  if (FrmPredefinedTags.ShowModal = IDOK) then
  begin
    CopySingleTagList := FrmPredefinedTags.CallerTags;
    SelCopySingleTagList := '';
    SetupListView;
  end;
end;

procedure TFCopyMetaSingle.GetTagNames;
var
  ANItem: TListItem;
begin
  CopySingleTagList := '';
  for ANItem in LvTagNames.Items do
    CopySingleTagList := CopySingleTagList + ANItem.Caption + ' ';
end;

procedure TFCopyMetaSingle.CheckSelection;
begin
  BtnExecute.Enabled := TagSelection <> '';
  BtnPreview.Enabled := BtnExecute.Enabled;
end;

procedure TFCopyMetaSingle.GetSelectedTags;
var
  ANItem: TListItem;
begin
  SelCopySingleTagList := '';
  for ANItem in LvTagNames.Items do
  begin
    if (ANitem.Checked) then
      SelCopySingleTagList := SelCopySingleTagList + ANItem.Caption + ' ';
  end;
end;

function TFCopyMetaSingle.TagSelection: string;
var
  ANItem: TListItem;
begin
  if (ChkImportAll.Checked) then
    result := '-All:all'
  else
  begin
    // Save selection. Will be stored in INI
    GetTagNames;
    GetSelectedTags;

    result := '';
    for ANItem in LvTagNames.Items do
    begin
      SetTagItem(ANItem);
      if (ANitem.Checked) then
        result := result + '-' + RemoveInvalidTags(ANItem.Caption, true) + CRLF;
    end;
  end;
end;

procedure TFCopyMetaSingle.PrepareShow(ASource: string);
begin
  SrcFile := ASource;

  FShowLogWindow := FLogWin.Showing;
  FLogWin.Close;
end;

procedure TFCopyMetaSingle.BtnExecuteClick(Sender: TObject);
var
  ETcmd, ETout, ETerr: string;
begin
  ETcmd := '-TagsFromFile' + CRLF + SrcFile + CRLF + TagSelection;
  if ChkNoOverWrite.Checked then
    ETcmd := ETcmd + CRLF + '-wm' + CRLF + 'cg';

  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFCopyMetaSingle.BtnPreviewClick(Sender: TObject);
var
  ETcmd: string;
begin
  ETcmd := '-G0:1' + CRLF + '-a' + CRLF + '-s1' + CRLF + TagSelection;
  FLogWin.Show;
  ET_OpenExec(ETcmd, SrcFile);
end;

procedure TFCopyMetaSingle.ChkImportAllClick(Sender: TObject);
begin
  LvTagNames.Enabled := not ChkImportAll.Checked;
  PnlButtons.Enabled := not ChkImportAll.Checked;
  SetupListView;
  CheckSelection;
end;

procedure TFCopyMetaSingle.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFCopyMetaSingle.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  Application.OnHint := DisplayHint;
  SetupListView;
  ChkImportAll.Checked := false;
  ChkImportAllClick(Sender);
  ChkNoOverWrite.Checked := false;

  if (FShowLogWindow) then
    FLogWin.Show;
end;

procedure TFCopyMetaSingle.LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  StyledDrawListviewItem(FStyleServices, Sender, Item, State);
end;

procedure TFCopyMetaSingle.LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
begin
  S := RemoveInvalidTags(S, true);
  SetTagItem(Item, S);
  BtnExecute.Default := true;
end;

procedure TFCopyMetaSingle.LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
begin
  if (LvTagNames.Tag = 0) then
    CheckSelection;
end;

end.
