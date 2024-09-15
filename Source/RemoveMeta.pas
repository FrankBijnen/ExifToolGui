unit RemoveMeta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Buttons, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.Menus;

type
  TFRemoveMeta = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    LvTagNames: TListView;
    PnlButtons: TPanel;
    ImageCollection: TImageCollection;
    VirtualImageList: TVirtualImageList;
    SpbPredefined: TSpeedButton;
    CmbPredefined: TComboBox;
    PnlRight: TPanel;
    BtnCancel: TButton;
    BtnPreview: TButton;
    Label1: TLabel;
    BtnExecute: TButton;
    PnlRemoveAll: TPanel;
    ChkRemoveAll: TCheckBox;
    PopupMenuLv: TPopupMenu;
    Groupview1: TMenuItem;
    N1: TMenuItem;
    Checkgroup1: TMenuItem;
    Uncheckgroup1: TMenuItem;
    procedure FormShow(Sender: TObject);

    procedure BtnExecuteClick(Sender: TObject);
    procedure ChkRemoveAllClick(Sender: TObject);
    procedure BtnPreviewClick(Sender: TObject);
    procedure LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
    procedure SpbPredefinedClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CmbPredefinedChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Groupview1Click(Sender: TObject);
    procedure CheckGroup1Click(Sender: TObject);
    procedure PopupMenuLvPopup(Sender: TObject);
  private
    { Private declarations }
    FSample: string;
    FShowLogWindow: boolean;
    procedure SetupPredefined;
    procedure SetupListView;
    procedure GetSelectedTags;
    procedure GetTagNames;
    procedure CheckSelection;
    procedure DisplayHint(Sender: TObject);
  protected
    function GetDefWindowSizes: TRect;  override;
  public
    { Public declarations }
    procedure PrepareShow(ASample: string);
    function TagSelection(const DoRemove: string = ''): string;
  end;

var
  FRemoveMeta: TFRemoveMeta;

implementation

uses
  Main, MainDef, ExifToolsGUI_Utils, ExifTool, LogWin, UFrmPredefinedTags, UnitLangResources,
  Vcl.Themes;

{$R *.dfm}

var FStyleServices: TCustomStyleServices;

function TFRemoveMeta.GetDefWindowSizes: TRect;
begin
  result := DesignRect;
  result.Offset(FMain.GetFormOffset.X,
                FMain.GetFormOffset.Y);
end;

procedure TFRemoveMeta.SetupPredefined;
var
  Indx: integer;
begin
  CmbPredefined.Items.Clear;
  for Indx := 0 to PredefinedTagList.Count -1 do
    CmbPredefined.Items.Add(PredefinedTagList.KeyNames[Indx]);
  CmbPredefined.Text := RemoveTagListName;
end;

procedure TFRemoveMeta.SetupListView;
var
  ATag, AllTags: string;
  ANItem: TListItem;
  NewGroupId: integer;
begin
  LvTagNames.Tag := 1;
  LvTagNames.Items.BeginUpdate;
  try
    LvTagNames.Groups.Clear;
    LvTagNames.Items.Clear;
    if (ChkRemoveAll.Checked = false) then
    begin
      AllTags := RemoveTagList;
      while (AllTags <> '') do
      begin
        ATag := NextField(AllTags, ' ');
        NewGroupId := GetGroupIdForLv(LvTagNames, GetGroupNameFromTag(ATag));

        ANItem := LvTagNames.Items.Add;
        ANItem.Checked := (Pos(' ' + ATag + ' ', ' ' + SelRemoveTagList) > 0);
        ANItem.GroupID := NewGroupId;
        SetTagItem(ANitem, ATag);
      end;
    end;
  finally
    LvTagNames.Items.EndUpdate;
    LvTagNames.Tag := 0;
  end;
end;

procedure TFRemoveMeta.SpbPredefinedClick(Sender: TObject);
begin
  SetupPredefined;
  GetTagNames;

  FrmPredefinedTags.PrepareShow(FSample, TIniTagsData.idtRemoveTags, CmbPredefined.Text);
  if (FrmPredefinedTags.ShowModal = IDOK) then
  begin
    RemoveTagListName := FrmPredefinedTags.GetSelectedPredefined;
    SetupPredefined;
    CmbPredefinedChange(CmbPredefined);
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

procedure TFRemoveMeta.Groupview1Click(Sender: TObject);
begin
  LvTagNames.GroupView := Groupview1.Checked;
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

procedure TFRemoveMeta.PopupMenuLvPopup(Sender: TObject);
begin
  Checkgroup1.Enabled := LvTagNames.GroupView;
  UnCheckgroup1.Enabled := LvTagNames.GroupView;
end;

procedure TFRemoveMeta.PrepareShow(ASample: string);
begin
  FSample := ASample;

  FShowLogWindow := FLogWin.Showing;
  FLogWin.Close;
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
      SetTagItem(ANItem);
      if (ANitem.Checked) then
        result := result + '-' + RemoveInvalidTags(ANItem.Caption, true) + DoRemove + CRLF;
    end;
  end;
end;

procedure TFRemoveMeta.CheckGroup1Click(Sender: TObject);
var
  AnItem: TlistItem;
begin
  if (LvTagNames.Selected = nil) then
    exit;
  for AnItem in LvTagNames.Items do
  begin
    if (AnItem.GroupID <> LvTagNames.Selected.GroupID) then
      continue;
    AnItem.Checked := TMenuItem(Sender).Tag = 0;
  end;
end;

procedure TFRemoveMeta.BtnExecuteClick(Sender: TObject);
var
  ETcmd, ETout, ETerr: string;
begin
  ETcmd := TagSelection('=');
  ET.OpenExec(ETcmd, FMain.GetSelectedFiles, ETout, ETerr);
  ModalResult := mrOK;
end;

procedure TFRemoveMeta.BtnPreviewClick(Sender: TObject);
var
  ETcmd: string;
begin
  ETcmd := '-G0:1' + CRLF + '-a' + CRLF + '-s1' + CRLF + TagSelection;
  FLogWin.Show;
  ET.OpenExec(ETcmd, FSample);
end;

procedure TFRemoveMeta.ChkRemoveAllClick(Sender: TObject);
begin
  LvTagNames.Enabled := not ChkRemoveAll.Checked;
  PnlButtons.Enabled := not ChkRemoveAll.Checked;
  SetupListView;
  CheckSelection;
end;

procedure TFRemoveMeta.CmbPredefinedChange(Sender: TObject);
begin
  RemoveTagListName := CmbPredefined.Text;
  RemoveTagList := PredefinedTagList.Values[RemoveTagListName];
  SelRemoveTagList := SelPredefinedTagList.Values[RemoveTagListName];
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

procedure TFRemoveMeta.FormCreate(Sender: TObject);
begin
  ReadFormSizes(Self, DefWindowSizes);
end;

procedure TFRemoveMeta.FormResize(Sender: TObject);
begin
  if LvTagNames.HandleAllocated then
    LvTagNames.Columns[0].Width := LvTagNames.ClientWidth;
end;

procedure TFRemoveMeta.FormShow(Sender: TObject);
begin
  Application.OnHint := DisplayHint;
  FStyleServices := TStyleManager.Style[GUIsettings.GuiStyle];
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;

  SetupPredefined;
  SetupListView;
  ChkRemoveAll.Checked := false;
  ChkRemoveAllClick(Sender);

  if (FShowLogWindow) then
    FLogWin.Show;
end;

procedure TFRemoveMeta.LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  StyledDrawListviewItem(FStyleServices, Sender, Item, State);
end;

procedure TFRemoveMeta.LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
begin
  if (LvTagNames.Tag = 0) then
    CheckSelection;
end;

end.
