unit RemoveMeta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Buttons, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TFRemoveMeta = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    BtnCancel: TButton;
    BtnExecute: TButton;
    Label1: TLabel;
    ChkRemoveAll: TCheckBox;
    LvTagNames: TListView;
    BtnPreview: TButton;
    PnlButtons: TPanel;
    SpbAdd: TSpeedButton;
    SpbDel: TSpeedButton;
    SpbEdit: TSpeedButton;
    SpbReset: TSpeedButton;
    ImageCollection: TImageCollection;
    VirtualImageList: TVirtualImageList;
    procedure FormShow(Sender: TObject);

    procedure BtnExecuteClick(Sender: TObject);
    procedure ChkRemoveAllClick(Sender: TObject);
    procedure BtnPreviewClick(Sender: TObject);
    procedure LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SpbAddClick(Sender: TObject);
    procedure SpbDelClick(Sender: TObject);
    procedure SpbEditClick(Sender: TObject);
    procedure SpbResetClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
    procedure LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
  private
    { Private declarations }
    FSample: string;
    procedure SetupListView;
    procedure GetSelectedTags;
    procedure GetTagNames;
    procedure CheckSelection;
    procedure DisplayHint(Sender: TObject);
  public
    { Public declarations }
    procedure SetSample(ASample: string);
    function TagSelection(const DoRemove: string = ''): string;
  end;

var
  FRemoveMeta: TFRemoveMeta;

implementation

uses
  Main, MainDef, ExifToolsGUI_Utils, ExifTool, LogWin, UFrmTagNames, UnitLangResources,
  Vcl.Themes;

{$R *.dfm}

var FStyleServices: TCustomStyleServices;

procedure TFRemoveMeta.SetupListView;
var
  ATag, AllTags: string;
  ANItem: TListItem;
begin
  LvTagNames.Tag := 1;
  LvTagNames.Items.BeginUpdate;
  try
    LvTagNames.Items.Clear;
    if (ChkRemoveAll.Checked = false) then
    begin
      AllTags := RemoveTagList;
      while (AllTags <> '') do
      begin
        ATag := NextField(AllTags, ' ');
        ANItem := LvTagNames.Items.Add;
        ANitem.Caption := ATag;
        ANItem.ImageIndex := TagImageIndex(ANitem.Caption);
        ANItem.Checked := (Pos(' ' + ATag + ' ', ' ' + SelRemoveTagList) > 0);
      end;
    end;
  finally
    LvTagNames.Items.EndUpdate;
    LvTagNames.Tag := 0;
  end;
end;

procedure TFRemoveMeta.SpbAddClick(Sender: TObject);
begin
  FrmTagNames.SetSample(FSample);
  if (FrmTagNames.ShowModal = IDOK) then
  begin
    with LvTagNames.Items.Add do
    begin
      Caption := FrmTagNames.SelectedTag(true);
      ImageIndex := TagImageIndex(Caption);
    end;
  end;
end;

procedure TFRemoveMeta.SpbResetClick(Sender: TObject);
begin
  RemoveTagList := DefRemoveTags;
  SelRemoveTagList := '';
  SetupListView;
end;

procedure TFRemoveMeta.SpbDelClick(Sender: TObject);
begin
  if (LvTagNames.Selected <> nil) then
    LvTagNames.Selected.Delete;
end;

procedure TFRemoveMeta.SpbEditClick(Sender: TObject);
begin
  if (LvTagNames.Selected <> nil) then
  begin
    BtnExecute.Default := false;
    LvTagNames.Selected.Checked := false;
    LvTagNames.Selected.EditCaption;
  end;
end;

procedure TFRemoveMeta.GetTagNames;
var
  ANItem: TListItem;
begin
  RemoveTagList := '';
  for ANItem in LvTagNames.Items do
    RemoveTagList := RemoveTagList + ANItem.Caption + ' ';
end;

procedure TFRemoveMeta.GetSelectedTags;
var
  ANItem: TListItem;
begin
  SelRemoveTagList := '';
  for ANItem in LvTagNames.Items do
  begin
    if (ANitem.Checked) then
      SelRemoveTagList := SelRemoveTagList + ANItem.Caption + ' ';
  end;
end;

procedure TFRemoveMeta.SetSample(ASample: string);
begin
  FSample := ASample;
end;

function TFRemoveMeta.TagSelection(const DoRemove: string = ''): string;
var
  ANItem: TListItem;
begin
  if (ChkRemoveAll.Checked) then
    result := '-All:all' + DoRemove
  else
  begin
    // Save selection. Will be stored in INI
    GetTagNames;
    GetSelectedTags;

    result := '';
    for ANItem in LvTagNames.Items do
    begin
      if (ANitem.Checked) then
        result := result + '-' + RemoveInvalidTags(ANItem.Caption, true) + DoRemove + CRLF;
    end;
  end;
end;

procedure TFRemoveMeta.BtnExecuteClick(Sender: TObject);
var
  ETcmd, ETout, ETerr: string;
begin
  ETcmd := TagSelection('=');
  ET_OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFRemoveMeta.BtnPreviewClick(Sender: TObject);
var
  ETcmd: string;
begin
  ETcmd := '-G0:1' + CRLF + '-a' + CRLF + '-s1' + CRLF + TagSelection;
  FLogWin.Show;
  ET_OpenExec(ETcmd, FSample);
end;

procedure TFRemoveMeta.ChkRemoveAllClick(Sender: TObject);
begin
  LvTagNames.Enabled := not ChkRemoveAll.Checked;
  PnlButtons.Enabled := not ChkRemoveAll.Checked;
  SetupListView;
  CheckSelection;
end;

procedure TFRemoveMeta.CheckSelection;
begin
  BtnExecute.Enabled := TagSelection <> '';
  BtnPreview.Enabled := BtnExecute.Enabled;
end;

procedure TFRemoveMeta.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFRemoveMeta.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FLogWin.Close;
end;

procedure TFRemoveMeta.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  SetupListView;
  Application.OnHint := DisplayHint;
  ChkRemoveAll.Checked := false;
  ChkRemoveAllClick(Sender);
end;

procedure TFRemoveMeta.LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  StyledDrawListviewItem(FStyleServices, Sender, Item, State);
end;

procedure TFRemoveMeta.LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
begin
  S := RemoveInvalidTags(S, true);
  Item.ImageIndex := TagImageIndex(S);
  BtnExecute.Default := true;
end;

procedure TFRemoveMeta.LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
begin
  if (LvTagNames.Tag = 0) then
    CheckSelection;
end;

end.
