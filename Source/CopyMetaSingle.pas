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
    ChkNoOverWrite: TCheckBox;
    PnlButtons: TPanel;
    SpbPredefined: TSpeedButton;
    LvTagNames: TListView;
    ImageCollection: TImageCollection;
    VirtualImageList: TVirtualImageList;
    CmbPredefined: TComboBox;
    PnlRight: TPanel;
    BtnCancel: TButton;
    BtnPreview: TButton;
    Label1: TLabel;
    BtnExecute: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure ChkImportAllClick(Sender: TObject);
    procedure LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure BtnPreviewClick(Sender: TObject);
    procedure LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
    procedure SpbPredefinedClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CmbPredefinedChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    SrcFile: string;
    FShowLogWindow: boolean;
    procedure DisplayHint(Sender: TObject);
    procedure SetupPredefined;
    procedure SetupListView;
    procedure GetSelectedTags;
    procedure GetTagNames;
    procedure CheckSelection;
  protected
    function GetDefWindowSizes: TRect; override;
  public
    { Public declarations }
    procedure PrepareShow(ASource: string);
    function TagSelection: string;
  end;

var
  FCopyMetaSingle: TFCopyMetaSingle;

implementation

uses
  Main, ExifTool, UnitLangResources, ExifToolsGUI_Utils, LogWin, UFrmPredefinedTags, MainDef,
  VCL.Themes;

{$R *.dfm}

var FStyleServices: TCustomStyleServices;

function TFCopyMetaSingle.GetDefWindowSizes: TRect;
begin
  result := DesignRect;
  result.Offset(FMain.GetFormOffset.X,
                FMain.GetFormOffset.Y);
end;

procedure TFCopyMetaSingle.SetupPredefined;
var
  Indx: integer;
begin
  CmbPredefined.Items.Clear;
  for Indx := 0 to PredefinedTagList.Count -1 do
    CmbPredefined.Items.Add(PredefinedTagList.KeyNames[Indx]);
  CmbPredefined.Text := CopySingleTagListName;
end;

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

procedure TFCopyMetaSingle.SpbPredefinedClick(Sender: TObject);
begin
  GetTagNames;

  FrmPredefinedTags.PrepareShow(SrcFile, TIniTagsData.idtCopySingleTags, CmbPredefined.Text);
  if (FrmPredefinedTags.ShowModal = IDOK) then
  begin
    CopySingleTagListName := FrmPredefinedTags.GetSelectedPredefined;
    SetupPredefined;
    CmbPredefinedChange(CmbPredefined);
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

procedure TFCopyMetaSingle.CmbPredefinedChange(Sender: TObject);
begin
  CopySingleTagListName := CmbPredefined.Text;
  CopySingleTagList := PredefinedTagList.Values[CopySingleTagListName];
  SelCopySingleTagList := SelPredefinedTagList.Values[CopySingleTagListName];
  SetupListView;
end;

procedure TFCopyMetaSingle.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimpleText := GetShortHint(Application.Hint);
end;

procedure TFCopyMetaSingle.FormCreate(Sender: TObject);
begin
  ReadFormSizes(Self, Self.DefWindowSizes);
end;

procedure TFCopyMetaSingle.FormResize(Sender: TObject);
begin
  if LvTagNames.HandleAllocated then
    LvTagNames.Columns[0].Width := LvTagNames.ClientWidth;
end;

procedure TFCopyMetaSingle.FormShow(Sender: TObject);
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

procedure TFCopyMetaSingle.LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
begin
  if (LvTagNames.Tag = 0) then
    CheckSelection;
end;

end.
