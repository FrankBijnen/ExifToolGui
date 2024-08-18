unit UFrmPredefinedTags;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.ValEdit,
  ExifToolsGui_ValEdit, MainDef, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.ComCtrls;

const
  UnNamed = 'UnNamed';

type

  TFrmPredefinedTags = class(TScaleForm)
    PnlBottom: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    PnlButtons: TPanel;
    SGPredefinedTags: TStringGrid;
    SpbAddPred: TSpeedButton;
    SpbDelPred: TSpeedButton;
    SpbDefaults: TSpeedButton;
    ImageCollection: TImageCollection;
    VirtualImageList: TVirtualImageList;
    LvTagNames: TListView;
    Splitter1: TSplitter;
    PnlTags: TPanel;
    SpbAddTag: TSpeedButton;
    SpbDelTag: TSpeedButton;
    SpbEditTag: TSpeedButton;
    SpbEditPred: TSpeedButton;
    SpbDuplicate: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpbAddPredClick(Sender: TObject);
    procedure SpbDelPredClick(Sender: TObject);
    procedure SpbDefaultsClick(Sender: TObject);
    procedure SGPredefinedTagsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FormResize(Sender: TObject);
    procedure LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
    procedure SpbAddTagClick(Sender: TObject);
    procedure SpbDelTagClick(Sender: TObject);
    procedure SpbEditTagClick(Sender: TObject);
    procedure SGPredefinedTagsDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure SpbEditPredClick(Sender: TObject);
    procedure SGPredefinedTagsDblClick(Sender: TObject);
    procedure SpbDuplicateClick(Sender: TObject);
    procedure SGPredefinedTagsExit(Sender: TObject);
    procedure LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
  private
    { Private declarations }
    Sample: string;
    Caller: TIniTagsData;
    SelectedPredefined: string;
    procedure SetColumnWidths;
    function GetLVTagNames(Checked: boolean = false): string;
    procedure GetTagNames;
    procedure SetupStringGrid(Position: boolean = false);
    procedure SetupListView(ARow: integer);
    procedure SetEdit(EditMode: boolean);
    procedure AddPredefined(NewName, FromTags, FromSelTags: string);
  public
    { Public declarations }
    function GetSelectedPredefined: string;
    procedure PrepareShow(ASource: string; ACaller: TIniTagsData; ACallerPredefined: string);
  end;

var
  FrmPredefinedTags: TFrmPredefinedTags;

implementation

uses
  Vcl.Themes, ExifToolsGUI_Utils, UFrmTagNames, UnitLangResources, Main;

var FStyleServices: TCustomStyleServices;

{$R *.dfm}

procedure TFrmPredefinedTags.SetColumnWidths;
begin
  if (SGPredefinedTags.HandleAllocated) then
  begin
    SGPredefinedTags.ColWidths[0] := SGPredefinedTags.ClientWidth - GetSystemMetrics(SM_CXVSCROLL);
    SGPredefinedTags.ColWidths[1] := -1; // Hide column with Tag names
    SGPredefinedTags.ColWidths[2] := -1; // Hide column with Selected Tag names
  end;
end;

procedure TFrmPredefinedTags.SetEdit(EditMode: boolean);
var
  NewOptions: TGridOptions;
begin
  NewOptions := SGPredefinedTags.Options;

  if (EditMode) then
    Include(NewOptions, goAlwaysShowEditor)
  else
    Exclude(NewOptions, goAlwaysShowEditor);

  SetColumnWidths;
  SGPredefinedTags.Options := NewOptions;
end;

function TFrmPredefinedTags.GetLVTagNames(Checked: boolean = false): string;
var
  ANItem: TListItem;
begin
  result := '';
  for ANItem in LvTagNames.Items do
  begin
    if (Checked = false) or
       (ANItem.Checked) then
    result := result + ANItem.Caption + ' ';
  end;
end;

procedure TFrmPredefinedTags.GetTagNames;
var
  Indx: integer;
begin
  PredefinedTagList.Clear;
  SelPredefinedTagList.Clear;
  for Indx := SGPredefinedTags.FixedRows to SGPredefinedTags.RowCount -1 do
  begin
    PredefinedTagList.AddPair(SGPredefinedTags.Cells[0, Indx], SGPredefinedTags.Cells[1, Indx]);
    SelPredefinedTagList.AddPair(SGPredefinedTags.Cells[0, Indx], SGPredefinedTags.Cells[2, Indx]);
  end;
end;

procedure TFrmPredefinedTags.SetupStringGrid(Position: boolean = false);
var
  Indx: integer;
begin
  SGPredefinedTags.SetTextBuf('');
  SGPredefinedTags.Cols[0][0] := 'Predefined Name';
  if (PredefinedTagList.Count = 0) then
  begin
    SGPredefinedTags.RowCount := 2;
    SGPredefinedTags.Row := 1;
    SGPredefinedTags.Cells[0, 1] := UnNamed;
    SGPredefinedTags.Cells[1, 1] := '';
    SGPredefinedTags.Cells[2, 1] := '';
    LvTagNames.Items.Clear;
  end
  else
  begin
    SGPredefinedTags.RowCount := PredefinedTagList.Count +1;
    for Indx := SGPredefinedTags.FixedRows to PredefinedTagList.Count do
    begin
      SGPredefinedTags.Cells[0, Indx] := PredefinedTagList.KeyNames[Indx -1];
      SGPredefinedTags.Cells[1, Indx] := PredefinedTagList.ValueFromIndex[Indx -1];
      SGPredefinedTags.Cells[2, Indx] := SelPredefinedTagList.Values[PredefinedTagList.KeyNames[Indx -1]];
      if (Position) and
         (SGPredefinedTags.Cells[0, Indx] = SelectedPredefined) then
        SGPredefinedTags.Row := Indx;
    end;
    SGPredefinedTags.SetFocus;
    SetupListView(SGPredefinedTags.Row);
  end;
end;

procedure TFrmPredefinedTags.SetupListView(ARow: integer);
var
  ATag, AllTags, AllSelTags: string;
  ANItem: TListItem;
begin
  LvTagNames.Tag := 1;
  LvTagNames.Items.BeginUpdate;
  try
    LvTagNames.Items.Clear;
    AllTags := SGPredefinedTags.Cells[1, ARow];
    AllSelTags := ' ' + SGPredefinedTags.Cells[2, ARow] + ' ';
    while (AllTags <> '') do
    begin
      ATag := NextField(AllTags, ' ');
      ANItem := LvTagNames.Items.Add;
      ANItem.Checked := (Pos(' ' + ATag + ' ', AllSelTags) > 0);
      SetTagItem(ANItem, ATag);
    end;
  finally
    LvTagNames.Items.EndUpdate;
    LvTagNames.Tag := 0;
  end;
end;

procedure TFrmPredefinedTags.AddPredefined(NewName, FromTags, FromSelTags: string);

  function UnusedName(BaseName: string): string;
  var
    SubNum: integer;
    Used: boolean;
  begin
    Used := true;
    SubNum := 0;
    while Used do
    begin
      Inc(SubNum);
      result := BaseName + '_' + IntToStr(SubNum);
      Used := (PredefinedTagList.IndexOfName(result) >= 0);
    end;
  end;

begin
  SGPredefinedTags.RowCount := SGPredefinedTags.RowCount +1;
  SGPredefinedTags.Col := 0;

  // Setting Row in code will trigger OnSelectCell
  // But we dont want that here, because SetEdit(false) would be called
  // Setting Tag to 1 will prevent that
  SGPredefinedTags.Tag := 1;
  SGPredefinedTags.Row := SGPredefinedTags.RowCount -1;
  SetEdit(true);

  // Fill Data
  SGPredefinedTags.Cells[0, SGPredefinedTags.Row] := UnusedName(NewName);
  SGPredefinedTags.Cells[1, SGPredefinedTags.Row] := FromTags;
  SGPredefinedTags.Cells[2, SGPredefinedTags.Row] := FromSelTags;

  SetupListView(SGPredefinedTags.Row);
  SGPredefinedTags.SetFocus;

  GetTagNames;
end;

procedure TFrmPredefinedTags.SpbAddPredClick(Sender: TObject);
begin
  AddPredefined(UnNamed, '', '');
end;

procedure TFrmPredefinedTags.SpbDelPredClick(Sender: TObject);
begin
  GetTagNames;
  if (PredefinedTagList.Count > 0) then
  begin
    PredefinedTagList.Delete(SGPredefinedTags.Row -1);
    SelPredefinedTagList.Delete(SGPredefinedTags.Row -1);
    SetupStringGrid;
    SetupListView(SGPredefinedTags.Row);
    GetTagNames;
  end;
end;

procedure TFrmPredefinedTags.SpbEditPredClick(Sender: TObject);
begin
  SetEdit(true);
  SGPredefinedTags.SetFocus;
end;

procedure TFrmPredefinedTags.SpbDuplicateClick(Sender: TObject);
begin
  AddPredefined(SGPredefinedTags.Cells[0, SGPredefinedTags.Row],
                SGPredefinedTags.Cells[1, SGPredefinedTags.Row],
                SGPredefinedTags.Cells[2, SGPredefinedTags.Row]);
end;

procedure TFrmPredefinedTags.SpbDefaultsClick(Sender: TObject);
begin
  if (MessageDlgEx(StrDeleteCustom, '', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel]) = IdCancel) then
    exit;

  PredefinedTagList.Clear;
  SelPredefinedTagList.Clear;

  PredefinedTagList.AddPair(Fmain.MaRemoveMeta.Caption, DefRemoveTags);
  SelPredefinedTagList.AddPair(Fmain.MaRemoveMeta.Caption, DefRemoveTags);

  PredefinedTagList.AddPair(Fmain.MaImportMetaSingle.Caption, DefCopySingleTags);
  SelPredefinedTagList.AddPair(Fmain.MaImportMetaSingle.Caption, DefCopySingleTags);

  PredefinedTagList.AddPair(Fmain.MaImportMetaSelected.Caption, DefExcludeCopyTags);
  SelPredefinedTagList.AddPair(Fmain.MaImportMetaSelected.Caption, '');

  SetupStringGrid;

  case Caller of
    TIniTagsData.idtRemoveTags:
      SGPredefinedTags.Row := 1;
    TIniTagsData.idtCopySingleTags:
      SGPredefinedTags.Row := 2;
    TIniTagsData.idtCopyTags:
      SGPredefinedTags.Row := 3;
  end;
  SGPredefinedTags.SetFocus;
  SGPredefinedTags.Col := 0;
end;

procedure TFrmPredefinedTags.SGPredefinedTagsDblClick(Sender: TObject);
begin
  ModalResult := MROK;
end;

procedure TFrmPredefinedTags.SGPredefinedTagsDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if not Assigned(FStyleServices) then
    exit;

  if (ARow = SGPredefinedTags.Row) then
    SGPredefinedTags.Canvas.Brush.Color := FStyleServices.GetSystemColor(clHighlight)
  else
    SGPredefinedTags.Canvas.Brush.Color := FStyleServices.GetSystemColor(clWindow);
end;

procedure TFrmPredefinedTags.SGPredefinedTagsExit(Sender: TObject);
begin
  SetEdit(false);
end;

procedure TFrmPredefinedTags.SGPredefinedTagsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  SetupListView(ARow);
  if (SGPredefinedTags.Tag = 0) then
    SetEdit(false)
  else
    SGPredefinedTags.Tag := 0;
end;

procedure TFrmPredefinedTags.LvTagNamesCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  StyledDrawListviewItem(FStyleServices, Sender, Item, State);
end;

procedure TFrmPredefinedTags.LvTagNamesEdited(Sender: TObject; Item: TListItem; var S: string);
begin
  S := RemoveInvalidTags(S, (Caller <> TIniTagsData.idtCopyTags));
  SetTagItem(Item, S);
  SGPredefinedTags.Cells[1, SGPredefinedTags.Row] := GetLVTagNames;
  GetTagNames;
  BtnOk.Default := true;
end;

procedure TFrmPredefinedTags.LvTagNamesItemChecked(Sender: TObject; Item: TListItem);
begin
  if (LvTagNames.Tag = 0) then
  begin
    SetTagItem(Item);
    SGPredefinedTags.Cells[2, SGPredefinedTags.Row] := GetLVTagNames(true);
    GetTagNames;
  end;
end;

procedure TFrmPredefinedTags.SpbAddTagClick(Sender: TObject);
var
  AnItem: TListItem;
begin
  FrmTagNames.SetSample(Sample);
  if (FrmTagNames.ShowModal = IDOK) then
  begin
    AnItem := LvTagNames.Items.Add;
    SetTagItem(AnItem, FrmTagNames.SelectedTag(Caller <> TIniTagsData.idtCopyTags));
    LvTagNames.Selected := AnItem;
    LvTagNames.Selected.MakeVisible(false);
  end;
  SGPredefinedTags.Cells[1, SGPredefinedTags.Row] := GetLVTagNames;
  GetTagNames;
  LvTagNames.SetFocus;
end;

procedure TFrmPredefinedTags.SpbDelTagClick(Sender: TObject);
var
  OldSel: integer;
begin
  if (LvTagNames.Selected <> nil) then
  begin
    OldSel := LvTagNames.Selected.Index;
    LvTagNames.Selected.Delete;
    if (OldSel < LvTagNames.Items.Count) then
      LvTagNames.ItemIndex := OldSel;
  end;
  SGPredefinedTags.Cells[1, SGPredefinedTags.Row] := GetLVTagNames;
  GetTagNames;
  LvTagNames.SetFocus;
end;

procedure TFrmPredefinedTags.SpbEditTagClick(Sender: TObject);
begin
  if (LvTagNames.Selected <> nil) then
  begin
    LvTagNames.Selected.EditCaption;
    BtnOk.Default := false;
  end;
end;

procedure TFrmPredefinedTags.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (ModalResult = IDOK) then
  begin
    GetTagNames;
    SelectedPredefined := SGPredefinedTags.Cells[0, SGPredefinedTags.Row];
  end;
end;

procedure TFrmPredefinedTags.FormResize(Sender: TObject);
begin
  if SGPredefinedTags.HandleAllocated then
    SetColumnWidths;

  if LvTagNames.HandleAllocated then
    LvTagNames.Columns[0].Width := LvTagNames.ClientWidth;
end;

procedure TFrmPredefinedTags.FormShow(Sender: TObject);
begin
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  FStyleServices := TStyleManager.Style[GUIsettings.GuiStyle];
  if (PredefinedTagList.Count = 0) then
    SpbDefaultsClick(Sender)
  else
    SetupStringGrid(true);
  SetEdit(false);
end;

procedure TFrmPredefinedTags.PrepareShow(ASource: string; ACaller: TIniTagsData; ACallerPredefined: string);
begin
  Sample := ASource;
  Caller := ACaller;
  SelectedPredefined := ACallerPredefined;
end;

function TFrmPredefinedTags.GetSelectedPredefined: string;
begin
  result := SelectedPredefined;
end;

end.

