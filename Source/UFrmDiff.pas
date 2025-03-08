unit UFrmDiff;

interface

uses
  System.Classes, System.UITypes, System.ImageList,
  Winapi.Windows, Winapi.Messages,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Controls, Vcl.ExtCtrls, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.ImgList, Vcl.VirtualImageList, Vcl.Dialogs, Vcl.ComCtrls,
  UnitScaleForm,
  ExifToolsGui_Listview;  // TListView

type
  TFrmDiff = class(TScaleForm)
    pnlBottom: TPanel;
    PnlTop: TPanel;
    LVCompare: ExifToolsGui_Listview.TListView; // Need our own version
    VirtualImageList: TVirtualImageList;
    ImageCollection: TImageCollection;
    BtnClose: TBitBtn;
    PnlMerge: TPanel;
    PnlMergeTag: TPanel;
    PnlMergeLeft: TPanel;
    PnlMergeRight: TPanel;
    GrpTagSelection: TGroupBox;
    GrpMatchRight: TGroupBox;
    CmbExt: TComboBox;
    MemoExplain: TMemo;
    GrpOptions: TGroupBox;
    ChkGroupHeadings: TCheckBox;
    CmbFamily: TComboBox;
    PnlPredefined: TPanel;
    CmbPredefined: TComboBox;
    SpbPredefined: TSpeedButton;
    MemoTagSel: TMemo;
    BtnRemoveLeft: TButton;
    BtnRemoveRight: TButton;
    ChkVerbose: TCheckBox;
    ChkNoPrintConv: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LVCompareResize(Sender: TObject);
    procedure LVCompareCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SpbPredefinedClick(Sender: TObject);
    procedure CmbPredefinedChange(Sender: TObject);
    procedure CmbExtClick(Sender: TObject);
    procedure ChkGroupHeadingsClick(Sender: TObject);
    procedure CmbFamilyChange(Sender: TObject);
    procedure PnlMergeLeftClick(Sender: TObject);
    procedure PnlMergeRightClick(Sender: TObject);
    procedure BtnRemoveRightClick(Sender: TObject);
    procedure BtnRemoveLeftClick(Sender: TObject);
    procedure ChkVerboseClick(Sender: TObject);
    procedure ChkNoPrintConvClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CmbExtKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    RightIsFolder: boolean;
    PathL: TStringList;
    PathR: string;
    function TagSelection: string;
    procedure ListViewColumnResized(Sender: TObject);
    procedure SetupPredefined;
    procedure ResizePanels;
    function ValidatePaths: boolean;
    function GetSelectedFilesOrFolder: string;
    procedure SetMatchVisible;
    procedure RunMergeRemove(const LeftSource, Remove: boolean; FileIndex: integer; TagList: string);
    procedure RunCompare(const PopupOnError: boolean = true);
    procedure FormatListView(CompareResult: TStringList);
    procedure PrepareMergeRemove(const LeftSource, Remove: boolean);
    procedure MergeAndCompare(const LeftSource, Remove: boolean);
    function GetMergeFile(const Index: integer): integer;
  public
    { Public declarations }
    procedure SelectLeft;
    procedure SelectLeftDir;
    procedure ShowCompare(const APathR: string); overload;
    procedure ShowCompare(const APathL, APathR: string); overload;
  end;

var
  FrmDiff: TFrmDiff;

implementation

uses
  System.SysUtils, System.StrUtils, System.Math,
  Winapi.CommCtrl,
  Vcl.Themes,
  ExifTool, ExifToolsGUI_Utils, Main, MainDef, UFrmPredefinedTags, UnitLangResources;

{$R *.dfm}

const DefTagWidth = 150;

function TFrmDiff.TagSelection: string;
var
  ATag, AllTags: string;
begin
  result := '';
  AllTags := Trim(SelDiffTagList);
  while (AllTags <> '') do
  begin
    ATag := NextField(AllTags, ' ');
    result := result + '-' + ATag + CRLF;
  end;
end;

procedure TFrmDiff.SetupPredefined;
var
  Indx: integer;
begin
  CmbPredefined.Items.Clear;
  for Indx := 0 to PredefinedTagList.Count -1 do
    CmbPredefined.Items.Add(PredefinedTagList.KeyNames[Indx]);
  CmbPredefined.Text := DiffTagListName;
  MemoTagSel.Text := SelDiffTagList;
end;

procedure TFrmDiff.SpbPredefinedClick(Sender: TObject);
begin
  FrmPredefinedTags.PrepareShow(PathL[0], TIniTagsData.idtDiffTags, CmbPredefined.Text);
  if (FrmPredefinedTags.ShowModal = IDOK) then
  begin
    DiffTagListName := FrmPredefinedTags.GetSelectedPredefined;
    SetupPredefined;
    DiffTagList := PredefinedTagList.Values[DiffTagListName];
    SelDiffTagList := SelPredefinedTagList.Values[DiffTagListName];
    MemoTagSel.Text := SelDiffTagList;
    RunCompare;
  end;
end;

procedure TFrmDiff.CmbPredefinedChange(Sender: TObject);
begin
  DiffTagListName := CmbPredefined.Text;
  DiffTagList := PredefinedTagList.Values[DiffTagListName];
  SelDiffTagList := SelPredefinedTagList.Values[DiffTagListName];
  MemoTagSel.Text := SelDiffTagList;
  RunCompare;
end;

procedure TFrmDiff.ChkGroupHeadingsClick(Sender: TObject);
begin
  RunCompare;
end;

procedure TFrmDiff.ChkNoPrintConvClick(Sender: TObject);
begin
  RunCompare;
end;

procedure TFrmDiff.ChkVerboseClick(Sender: TObject);
begin
  RunCompare;
end;

procedure TFrmDiff.CmbExtClick(Sender: TObject);
begin
  RunCompare;
end;

procedure TFrmDiff.CmbExtKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = Chr_Return) then
  begin
    RunCompare;
    Key := #0;
  end;
end;

procedure TFrmDiff.CmbFamilyChange(Sender: TObject);
begin
  RunCompare;
end;

function TFrmDiff.GetSelectedFilesOrFolder: string;
begin
  result := FMain.GetSelectedFiles(true);
  if (result = '') and
     (FMain.ShellList.SelCount = 1) then
    result := FMain.ShellList.GetSelectedFolder(-1).PathName + CRLF;
end;

procedure TFrmDiff.SetMatchVisible;
begin
  GrpMatchRight.Visible := (PathL.Count <> 1) or
                           (RightIsFolder);
  CmbExt.ItemIndex := 0;
end;

procedure TFrmDiff.LVCompareCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if (Item.ImageIndex > -1) then
    Sender.Canvas.Font.Style := [TFontStyle.fsBold];
  StyledDrawListviewItem(FMain.FStyleServices, Sender, Item, State);
end;

procedure TFrmDiff.ResizePanels;
var
  SpaceLeft: integer;
begin
  if (LVCompare.Columns.Count < 3) then
    exit;

  PnlMergeTag.Width := LVCompare.Columns[0].Width;
  PnlMergeLeft.Width := LVCompare.Columns[1].Width;
  SpaceLeft := PnlMerge.ClientWidth - (PnlMergeTag.Width + PnlMergeLeft.Width);
  PnlMergeRight.Width := Min(SpaceLeft, LVCompare.Columns[2].Width);
end;

procedure TFrmDiff.LVCompareResize(Sender: TObject);
var
  SpaceLeft: integer;
begin
  if (LVCompare.Columns.Count < 3) then
    exit;

  SpaceLeft := LVCompare.ClientWidth - LVCompare.Columns[0].Width;
  if (SpaceLeft < DefTagWidth) then // Need some room to play with
  begin
    LVCompare.Columns[0].Width := DefTagWidth;
    SpaceLeft := LVCompare.ClientWidth - LVCompare.Columns[0].Width;
  end;

  LVCompare.Columns[1].Width := SpaceLeft div 2;
  LVCompare.Columns[2].Width := LVCompare.Columns[1].Width;
  ResizePanels;
end;

function TFrmDiff.GetMergeFile(const Index: integer): integer;
var
  GroupIndex: integer;
begin
  result := -1;
  case (LVCompare.Items[Index].ImageIndex) of
    0:
      result := Index;
    1:
      result := LVCompare.Items[Index].GroupID;
    else
      begin
        GroupIndex := LVCompare.Items[Index].GroupID;
        if (GroupIndex > -1) and
           (GroupIndex < LVCompare.Items.Count) then
        begin
          case (LVCompare.Items[GroupIndex].ImageIndex) of
            0: result := GroupIndex;
            1: result := LVCompare.Items[GroupIndex].GroupID;
          end;
        end;
      end;
  end;
end;

procedure TFrmDiff.ListViewColumnResized(Sender: TObject);
begin
  ResizePanels;
end;

procedure TFrmDiff.FormatListView(CompareResult: TStringList);
var
  ALine: string;
  Tag, ALeft, ARight: string;
  CurrentFile, CurrentGroup: integer;
  CurrentItem: TListItem;

  function GetSubItem(ETLine: string; var OTag, OValue: string): boolean;
  var
    SaveValue: string;
  begin
    OValue := Copy(Aline, 3);
    result := (OValue[1] <> ' ');
    if result then
    begin
      if (OValue[1] <> '[') then // -g
        OTag := Trim(NextField(OValue, ': '))
      else
      begin                      // -G
        SaveValue := NextField(OValue, '[');
        SaveValue := NextField(OValue, ']');
        OTag      := Format('%s:%s', [SaveValue, Trim(NextField(OValue, ': '))]);
      end;
    end
    else
    begin
      SaveValue := Trim(NextField(OValue, ': '));
      // If the tag and value where not separated by ': ', restore from SaveValue
      // Fixed in ExifTool 13.13.
      if (OValue = '') and
         (SaveValue <> '') then
        OValue := SaveValue;
    end;
  end;

  function AddItem(ACaption: string; ImgIndex: integer; Sub1: string = '-'; Sub2: string = '-'): integer;
  begin
    CurrentItem := LVCompare.Items.Add;
    CurrentItem.ImageIndex := ImgIndex;
    CurrentItem.Caption := ACaption;
    CurrentItem.SubItems.Add(Sub1);
    CurrentItem.SubItems.Add(Sub2);
    result := CurrentItem.Index;
  end;

begin
  CurrentFile := -1;
  CurrentGroup := -1;
  for ALine in CompareResult do
  begin
    if (Aline = '') then
      Continue;
    case (Aline[1]) of
      '=':  // File
        begin
          ARight := ALine;
          ALeft := NextField(ARight, '<');
          ALeft := NextField(ARight, '>');
          CurrentFile := AddItem('File', 0, Trim(ALeft), Trim(ARight));
          CurrentGroup := CurrentFile;
        end;
      '-': // Tag group
        begin
          ALeft := ALine;
          Tag := NextField(ALeft, '(');
          ALeft := NextField(ALeft, ')');
          Tag := ReplaceAll(Tag, ['---- ', ' ----'], ['', '']);
          CurrentGroup := AddItem(Tag, 1, ALeft, '');
          CurrentItem.GroupID := CurrentFile; // -G
        end;
      '<': // Left
        begin
          if (GetSubItem(ALine, Tag, ALeft)) then
            AddItem(Tag, -1);
          CurrentItem.SubItems[0] := ALeft;
          CurrentItem.GroupID := CurrentGroup;
        end;
      '>': // Right
        begin
          if (GetSubItem(ALine, Tag, ARight)) then
            AddItem(Tag, -1);
          CurrentItem.SubItems[1] := ARight;
          CurrentItem.GroupID := CurrentGroup;
        end;
      ' ',  // Info/Verbose
      '(':
        begin
          ALeft := ALine;
          Tag := NextField(ALeft, '(');
          ALeft := NextField(ALeft, ')');
          AddItem(Tag, 3, ALeft, '');
        end;
    end;
  end;
end;

function TFrmDiff.ValidatePaths: boolean;
begin
  // Get Left
  if (PathL.Count = 0) then
    PathL.Text := GetSelectedFilesOrFolder;

  // We must have a left. (The menu items will normally not allow this)
  if (PathL.Count = 0) then
    exit(false);

  // Should Right be a folder?
  RightIsFolder := (PathL.Count > 1) or
                   (DirectoryExists(PathL[0]));

  // Get Right
  if (PathR = '') then
  begin
    if (RightIsFolder) then
      PathR := FMain.ShellList.Path             // User navigated to different directory?
    else
      PathR := FMain.GetFirstSelectedFilePath;  // User selected a different file?

    if StartsText(PathR, PathL[0]) then         // No, still the same.
    begin
      if (RightIsFolder) then
        PathR := BrowseFolderDlg(StrSelectRight, Fmain.ShellList.Path)
      else
      with FMain.OpenFileDlg do
      begin
        InitialDir := FMain.ShellList.Path;
        Filter := Format('%s File|*%s|Any file|*.*', [ExtractFileExt(PathL[0]), ExtractFileExt(PathL[0])]);
        Title := StrSelectRight;
        if Execute then
          PathR := FileName;
      end;
    end;
  end;

  result := (PathL.Count > 0) and
            (PathR <> '');
end;

procedure TFrmDiff.RunCompare(const PopupOnError: boolean = true);
var
  ETCmd: string;
  ETResult: TStringList;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  ETResult := TStringList.Create;
  LVCompare.Enabled := false;
  LVCompare.Items.BeginUpdate;

  try
    LVCompare.Items.Clear;
    if (ET.ETWorkingDir = '') then
      ET.StayOpen(FMain.ShellList.Path);
    if (ChkGroupHeadings.Checked) then
      ETCmd := '-g'
    else
      ETCmd := '-G';
    ETcmd := ETCmd + IntToStr(CmbFamily.ItemIndex);
    if (ChkVerbose.Checked) then
      ETCmd := ETCmd + CRLF + '-v';
    if (ChkNoPrintConv.Checked) then
      ETCmd := ETCmd + CRLF + '-n';
    ETCmd := ETCmd + CRLF + '-s' + CRLF + PATHL.Text + TagSelection + '-diff' + CRLF ;

    if (GrpMatchRight.Visible) then
      ETcmd := ETcmd + Format('%s%s',
                              [ReplaceAll(IncludeTrailingPathDelimiter(PathR), ['\'], ['/']), CmbExt.Text])
    else
      ETcmd := ETcmd + ReplaceAll(PathR, ['\'], ['/']);

    if (ET.OpenExec(ETcmd, '', ETResult, PopupOnError)) then
      FormatListView(ETResult);

  finally
    LVCompare.Items.EndUpdate;
    LVCompare.Enabled := true;
    ETResult.Free;
    SetCursor(CrNormal);
  end;
end;

procedure TFrmDiff.RunMergeRemove(const LeftSource, Remove: boolean; FileIndex: integer; TagList: string);
var
  SourceIndex, DestIndex: integer;
  ETCmd: string;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);

  try
    SourceIndex := 0;
    DestIndex := 1;
    if not LeftSource then
    begin
      SourceIndex := 1;
      DestIndex := 0;
    end;
    if (ET.ETWorkingDir = '') then
      ET.StayOpen(FMain.ShellList.Path);
    if (Remove) then
    begin
      ETcmd := TagList;
      ET.OpenExec(ETcmd, LVCompare.Items[FileIndex].SubItems[SourceIndex], true);
    end
    else
    begin
      ETcmd := '-TagsFromFile' + CRLF + LVCompare.Items[FileIndex].SubItems[SourceIndex];
      if (TagList <> '') then
        ETcmd := ETcmd + CRLF + TagList;
      ET.OpenExec(ETcmd, LVCompare.Items[ FileIndex].SubItems[DestIndex], true);
    end;

  finally
    SetCursor(CrNormal);
  end;
end;

procedure TFrmDiff.PrepareMergeRemove(const LeftSource, Remove: boolean);
var
  Index, CurrentFileIndex, FileIndex, GroupIndex: integer;
  TagList, Tag: string;
begin
  TagList := '';
  CurrentFileIndex := -1;
  for Index := 0 to LVCompare.Items.Count -1 do
  begin
    if (ListView_GetItemState(LVCompare.Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) then
    begin
      Tag := '';
      case LVCompare.Items[Index].ImageIndex of
        0:
          Tag := 'All:All';
        1:
          Tag := LVCompare.Items[Index].Caption + ':All';
        else
        begin
          GroupIndex := LVCompare.Items[Index].GroupID;
          if (GroupIndex > -1) and
             (GroupIndex < LVCompare.Items.Count) then
          begin
            case (LVCompare.Items[GroupIndex].ImageIndex) of
              0: Tag := LVCompare.Items[Index].Caption;
              1: Tag := LVCompare.Items[GroupIndex].Caption + ':' + LVCompare.Items[Index].Caption;
            end;
          end;
        end;
      end;
      FileIndex := GetMergeFile(Index);
      if CurrentFileIndex = -1 then
        CurrentFileIndex := FileIndex
      else
      begin
        if (CurrentFileIndex <> FileIndex) then
        begin
          RunMergeRemove(LeftSource, Remove, CurrentFileIndex, TagList);
          CurrentFileIndex := FileIndex;
          TagList := '';
        end;
      end;
      if (Tag <> '') then
      begin
        if (Remove) then
          TagList := TagList + '-' + Tag + '=' + CRLF
        else
          TagList := TagList + '-' + Tag + CRLF;
      end;
    end;
  end;
  // Process last file?
  if (TagList <> '') and
     (CurrentFileIndex <> -1) then
    RunMergeRemove(LeftSource, Remove, CurrentFileIndex, TagList);
end;

procedure TFrmDiff.MergeAndCompare(const LeftSource, Remove: boolean);
var
  SavedTopRow, SavedSelected: integer;
  CrWait, CrNormal: HCURSOR;
begin
  SavedTopRow := LVCompare.TopItem.Index;
  SavedSelected := SavedTopRow;
  if (LVCompare.Selected <> nil) then
    SavedSelected := LVCompare.Selected.Index;

  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    PrepareMergeRemove(LeftSource, Remove);
    RunCompare(false);

    // Try to reposition Listview
    if (SavedSelected < LVCompare.Items.Count) then
    begin
      LVCompare.Items[SavedSelected].Selected := true;
      LVCompare.Items[SavedSelected].Focused := true;
    end;
    if (SavedTopRow < LVCompare.Items.Count) then
      LVCompare.ScrollToItem(SavedTopRow);

  finally
    SetCursor(CrNormal);
  end;
end;

procedure TFrmDiff.PnlMergeLeftClick(Sender: TObject);
begin
  MergeAndCompare(true, false);
end;

procedure TFrmDiff.PnlMergeRightClick(Sender: TObject);
begin
  MergeAndCompare(false, false);
end;

procedure TFrmDiff.BtnRemoveLeftClick(Sender: TObject);
begin
  MergeAndCompare(true, true);
end;

procedure TFrmDiff.BtnRemoveRightClick(Sender: TObject);
begin
  MergeAndCompare(false, true);
end;

procedure TFrmDiff.SelectLeft;
begin
  PathL.Text := GetSelectedFilesOrFolder;
end;

procedure TFrmDiff.SelectLeftDir;
begin
  PathL.Text := FMain.ShellList.Path;
end;

procedure TFrmDiff.ShowCompare(const APathR: string);
begin
  if (PathL.Text = '') then
    PathL.Text := APathR
  else
  begin
    PathR := APathR;
    // Left side has a) multiple files, or b) is directory. Right side must also be a dir
    // Set PathR to ''. See ValidatePaths
    if ((PathL.Count > 1) or
        (DirectoryExists(PathL[0]))) and
       not DirectoryExists(APathR) then
      PathR := '';
  end;
  Show;
end;

procedure TFrmDiff.ShowCompare(const APathL, APathR: string);
begin
  PathL.Text := APathL;
  PathR := APathR;
  Show;
end;

procedure TFrmDiff.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PathL.Clear;
  PathR := '';
  RightIsFolder := false;
  LVCompare.Items.Clear;
end;

procedure TFrmDiff.FormCreate(Sender: TObject);
begin
  PathL := TStringList.Create;
  LVCompare.OnColumnResized := ListViewColumnResized;
end;

procedure TFrmDiff.FormDestroy(Sender: TObject);
begin
  PathL.Free;
end;

procedure TFrmDiff.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TFrmDiff.FormShow(Sender: TObject);
var
  CanCompare: boolean;
begin
  if (LVCompare.Columns[0].Width < DefTagWidth) then
    LVCompare.Columns[0].Width := DefTagWidth;

  SetupPredefined;

  CanCompare := ValidatePaths;

  SetMatchVisible;

  if (CanCompare) then
    RunCompare;
end;

end.

