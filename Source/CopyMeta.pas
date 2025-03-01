unit CopyMeta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus;

type
  TFCopyMetadata = class(TScaleForm)
    StatusBar1: TStatusBar;
    AdvPanel1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    LvTagNames: TListView;
    PnlButtons: TPanel;
    SpbPredefined: TSpeedButton;
    CmbPredefined: TComboBox;
    PnlRight: TPanel;
    BtnCancel: TButton;
    BtnPreview: TButton;
    Label1: TLabel;
    BtnExecute: TButton;
    PopupMenuLv: TPopupMenu;
    Groupview1: TMenuItem;
    N1: TMenuItem;
    Checkgroup1: TMenuItem;
    Uncheckgroup1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure BtnPreviewClick(Sender: TObject);
    procedure SpbPredefinedClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CmbPredefinedChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Groupview1Click(Sender: TObject);
    procedure Checkgroup1Click(Sender: TObject);
    procedure PopupMenuLvPopup(Sender: TObject);
  private
    { Private declarations }
    FSample: string;
    FShowLogWindow: boolean;
    procedure SetupPredefined;
    procedure SetupListView;
    procedure GetSelectedTags;
    procedure GetTagNames;
    procedure DisplayHint(Sender: TObject);
  protected
    function GetDefWindowSizes: TRect; override;
  public
    procedure PrepareShow(ASample: string);
    function TagSelection: string;
    { Public declarations }
  end;

var
  FCopyMetadata: TFCopyMetadata;

implementation

uses
  Main, MainDef, ExifToolsGUI_Utils, ExifTool, LogWin, UnitLangResources, UFrmPredefinedTags,
  Vcl.Themes;

{$R *.dfm}

function TFCopyMetadata.GetDefWindowSizes: TRect;
begin
  result := DesignRect;
  result.Offset(FMain.GetFormOffset.X,
                FMain.GetFormOffset.Y);
end;

procedure TFCopyMetadata.SetupPredefined;
var
  Indx: integer;
begin
  CmbPredefined.Items.Clear;
  for Indx := 0 to PredefinedTagList.Count -1 do
    CmbPredefined.Items.Add(PredefinedTagList.KeyNames[Indx]);
  CmbPredefined.Text := ExcludeCopyTagListName;
end;

procedure TFCopyMetadata.SetupListView;
var
  ATag, AllTags: string;
  ANItem: TListItem;
  NewGroupId: integer;
begin
  LvTagNames.Items.BeginUpdate;
  try
    LvTagNames.Groups.Clear;
    LvTagNames.Items.Clear;
    AllTags := ExcludeCopyTagList;
    while (AllTags <> '') do
    begin
      ATag := NextField(AllTags, ' ');
      NewGroupId := GetGroupIdForLv(LvTagNames, GetGroupNameFromTag(ATag));

      ANItem := LvTagNames.Items.Add;
      ANitem.Caption := ATag;
      ANItem.Checked := (Pos(' ' + ATag + ' ', ' ' + SelExcludeCopyTagList) > 0);
      ANitem.GroupID := NewGroupId;
    end;
  finally
    LvTagNames.Items.EndUpdate;
  end;
end;

procedure TFCopyMetadata.SpbPredefinedClick(Sender: TObject);
begin
  GetTagNames;

  FrmPredefinedTags.PrepareShow(FSample, TIniTagsData.idtCopyTags, CmbPredefined.Text);
  if (FrmPredefinedTags.ShowModal = IDOK) then
  begin
    ExcludeCopyTagListName := FrmPredefinedTags.GetSelectedPredefined;
    SetupPredefined;
    CmbPredefinedChange(CmbPredefined);
    SetupListView;
  end;
end;

procedure TFCopyMetadata.GetTagNames;
var
  ANItem: TListItem;
begin
  ExcludeCopyTagList := '';
  for ANItem in LvTagNames.Items do
    ExcludeCopyTagList := ExcludeCopyTagList + ANItem.Caption + ' ';
end;

procedure TFCopyMetadata.Groupview1Click(Sender: TObject);
begin
  LvTagNames.GroupView := Groupview1.Checked;
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

procedure TFCopyMetadata.PopupMenuLvPopup(Sender: TObject);
begin
  Checkgroup1.Enabled := LvTagNames.GroupView;
  UnCheckgroup1.Enabled := LvTagNames.GroupView;
end;

procedure TFCopyMetadata.PrepareShow(ASample: string);
begin
  FSample := ASample;

  FShowLogWindow := FLogWin.Showing;
  FLogWin.Close;
end;

procedure TFCopyMetadata.BtnPreviewClick(Sender: TObject);
var
  ETcmd: string;
begin
  ETcmd := '-G0:1' + CRLF + '-a' + CRLF + '-All:all' + CRLF + '-s1' + CRLF + TagSelection;
  FLogWin.Show;
  ET.OpenExec(ETcmd, FSample);
end;

procedure TFCopyMetadata.LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  StyledDrawListviewItem(Fmain.FStyleServices, Sender, Item, State);
end;

procedure TFCopyMetadata.Checkgroup1Click(Sender: TObject);
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

procedure TFCopyMetadata.CmbPredefinedChange(Sender: TObject);
begin
  ExcludeCopyTagListName := CmbPredefined.Text;
  ExcludeCopyTagList := PredefinedTagList.Values[ExcludeCopyTagListName];
  SelExcludeCopyTagList := SelPredefinedTagList.Values[ExcludeCopyTagListName];
  SetupListView;
end;

procedure TFCopyMetadata.FormCreate(Sender: TObject);
begin
  ReadFormSizes(Self, Self.DefWindowSizes);
end;

procedure TFCopyMetadata.FormResize(Sender: TObject);
begin
  if LvTagNames.HandleAllocated then
    LvTagNames.Columns[0].Width := LvTagNames.ClientWidth;
end;

procedure TFCopyMetadata.FormShow(Sender: TObject);
begin
  Application.OnHint := DisplayHint;
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  if FMain.MaDontBackup.Checked then
    Label1.Caption := StrBackupOFF
  else
    Label1.Caption := StrBackupON;
  SetupPredefined;
  SetupListView;

  if (FShowLogWindow) then
    FLogWin.Show;
end;

procedure TFCopyMetadata.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

end.
