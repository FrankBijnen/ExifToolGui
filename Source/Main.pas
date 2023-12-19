unit Main;
{$WARN SYMBOL_PLATFORM OFF}
// Note all code formatted with Delphi formatter, Right margin 80->150
// Note about the Path.
// - To change: Set ShellTree.Path
// - To read:   Get ShellList.Path
interface

uses
  Winapi.Windows, Winapi.Messages, System.ImageList, System.SysUtils,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.Mask,
  Vcl.ValEdit, Vcl.ImgList,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtDlgs,
  Vcl.Shell.ShellCtrls, // Embarcadero ShellTreeView and ShellListView
  Winapi.WebView2, Winapi.ActiveX, Winapi.EdgeUtils, Vcl.Edge, // Edgebrowser
  VclTee.TeeGDIPlus, VclTee.TeEngine, VclTee.TeeProcs, VclTee.Chart,
  VclTee.Series, // Chart
  BreadcrumbBar,
  UnitScaleForm,
  ExifToolsGUI_ShellTree, // Extension of ShellTreeView
  ExifToolsGUI_ShellList, // Extension of ShellListView
  ExifToolsGUI_Thumbnails, // Thumbnails
  ExifToolsGUI_Utils; // Various

type
  TFMain = class(TScaleForm)
    MainMenu: TMainMenu;
    MProgram: TMenuItem;
    MAbout: TMenuItem;
    StatusBar: TStatusBar;
    AdvPanelBrowse: TPanel;
    AdvPageBrowse: TPageControl;
    AdvTabBrowse: TTabSheet;
    AdvPagePreview: TPageControl;
    AdvTabPreview: TTabSheet;
    AdvPageMetadata: TPageControl;
    AdvTabMetadata: TTabSheet;
    AdvPageFilelist: TPageControl;
    AdvTabFilelist: TTabSheet;
    AdvPanelFileTop: TPanel;
    AdvPanelETdirect: TPanel;
    AdvPanelMetaTop: TPanel;
    AdvPanelMetaBottom: TPanel;
    ShellTree: ExifToolsGUI_ShellTree.TShellTreeView; // Need to create our own version!
    ShellList: ExifToolsGUI_ShellList.TShellListView; // Need to create our own version!
    MetadataList: TValueListEditor;
    SpeedBtnExif: TSpeedButton;
    SpeedBtnIptc: TSpeedButton;
    SpeedBtnXmp: TSpeedButton;
    SpeedBtnMaker: TSpeedButton;
    SpeedBtnALL: TSpeedButton;
    SpeedBtnCustom: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    SpeedBtnDetails: TSpeedButton;
    CBoxDetails: TComboBox;
    EditETdirect: TLabeledEdit;
    SpeedBtn_ETdirect: TSpeedButton;
    CBoxETdirect: TComboBox;
    SpeedBtn_ETedit: TSpeedButton;
    EditETcmdName: TLabeledEdit;
    CBoxFileFilter: TComboBox;
    SpeedBtnQuick: TSpeedButton;
    MPreferences: TMenuItem;
    MOptions: TMenuItem;
    MDontBackup: TMenuItem;
    MPreserveDateMod: TMenuItem;
    MIgnoreErrors: TMenuItem;
    N1: TMenuItem;
    MShowGPSdecimal: TMenuItem;
    MShowNumbers: TMenuItem;
    QuickPopUpMenu: TPopupMenu;
    QuickPopUp_UndoEdit: TMenuItem;
    QuickPopUp_MarkTag: TMenuItem;
    QuickPopUp_AddCustom: TMenuItem;
    QuickPopUp_DelCustom: TMenuItem;
    QuickPopUp_AddQuick: TMenuItem;
    MQuickManager: TMenuItem;
    N5: TMenuItem;
    MExit: TMenuItem;
    MemoQuick: TMemo;
    SpeedBtnLarge: TSpeedButton;
    QuickPopUp_DelQuick: TMenuItem;
    MModify: TMenuItem;
    MExifDateTimeshift: TMenuItem;
    EditQuick: TEdit;
    MShowHexID: TMenuItem;
    MGroup_g4: TMenuItem;
    SpeedBtnFListRefresh: TSpeedButton;
    SpeedBtnFilterEdit: TSpeedButton;
    SpeedBtnColumnEdit: TSpeedButton;
    SpeedBtnShowLog: TSpeedButton;
    SpeedBtnQuickSave: TSpeedButton;
    SpeedBtnETdirectDel: TSpeedButton;
    SpeedBtnETdirectReplace: TSpeedButton;
    SpeedBtnETdirectAdd: TSpeedButton;
    MGUIStyle: TMenuItem;
    MExportImport: TMenuItem;
    MExportMeta: TMenuItem;
    MExportMetaTXT: TMenuItem;
    MExportMetaMIE: TMenuItem;
    MExportMetaXMP: TMenuItem;
    MExportMetaHTM: TMenuItem;
    MImportMetaSelected: TMenuItem;
    OpenPictureDlg: TOpenPictureDialog;
    MImportGPS: TMenuItem;
    MImportGPSLog: TMenuItem;
    MImportXMPLog: TMenuItem;
    N7: TMenuItem;
    MExifDateTimeEqualize: TMenuItem;
    N8: TMenuItem;
    MRemoveMeta: TMenuItem;
    MExifLensFromMaker: TMenuItem;
    MVarious: TMenuItem;
    MFileDateFromExif: TMenuItem;
    MExportMetaEXIF: TMenuItem;
    MShowSorted: TMenuItem;
    N6: TMenuItem;
    QuickPopUp_FillQuick: TMenuItem;
    MShowComposite: TMenuItem;
    AdvTabOSMMap: TTabSheet;
    AdvPanel_MapTop: TPanel;
    SpeedBtn_ShowOnMap: TSpeedButton;
    AdvPanel_MapBottom: TPanel;
    SpeedBtn_Geotag: TSpeedButton;
    EditMapFind: TLabeledEdit;
    SpeedBtn_MapHome: TSpeedButton;
    SpeedBtn_MapSetHome: TSpeedButton;
    N2: TMenuItem;
    QuickPopUp_AddDetailsUser: TMenuItem;
    MImportMetaSingle: TMenuItem;
    MNotDuplicated: TMenuItem;
    N3: TMenuItem;
    QuickPopUp_CopyTag: TMenuItem;
    MFileNameDateTime: TMenuItem;
    MWorkspace: TMenuItem;
    MWorkspaceLoad: TMenuItem;
    MWorkspaceSave: TMenuItem;
    OpenFileDlg: TOpenDialog;
    SaveFileDlg: TSaveDialog;
    AdvTabChart: TTabSheet;
    AdvPanel1: TPanel;
    SpeedBtnChartRefresh: TSpeedButton;
    AdvCheckBox_Subfolders: TCheckBox;
    AdvRadioGroup1: TRadioGroup;
    AdvRadioGroup2: TRadioGroup;
    MImportRecursiveAll: TMenuItem;
    SpeedBtn_ETdSetDef: TSpeedButton;
    SpeedBtn_ETclear: TSpeedButton;
    RotateImg: TImage;
    ETChart: TChart;
    Series1: TBarSeries;
    EdgeBrowser1: TEdgeBrowser;
    Spb_GoBack: TSpeedButton;
    Spb_Forward: TSpeedButton;
    SpeedBtn_GetLoc: TSpeedButton;
    CmbETDirectMode: TComboBox;
    N4: TMenuItem;
    MAPIWindowsWideFile: TMenuItem;
    EditFindMeta: TLabeledEdit;
    GenericExtractPreviews: TMenuItem;
    GenericImportPreview: TMenuItem;
    JPGGenericlosslessautorotate1: TMenuItem;
    EditMapBounds: TLabeledEdit;
    N10: TMenuItem;
    UpdateLocationfromGPScoordinates: TMenuItem;
    Help1: TMenuItem;
    OnlineDocumentation1: TMenuItem;
    MCustomOptions: TMenuItem;
    N11: TMenuItem;
    PnlBreadCrumb: TPanel;
    procedure ShellListClick(Sender: TObject);
    procedure ShellListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpeedBtnExifClick(Sender: TObject);
    procedure CBoxDetailsChange(Sender: TObject);
    procedure ShellListAddItem(Sender: TObject; AFolder: TShellFolder; var CanAdd: boolean);
    procedure FormShow(Sender: TObject);
    procedure SpeedBtnDetailsClick(Sender: TObject);
    procedure RotateImgResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditETdirectKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpeedBtn_ETdirectClick(Sender: TObject);
    procedure CBoxETdirectChange(Sender: TObject);
    procedure SpeedBtn_ETeditClick(Sender: TObject);
    procedure EditETdirectChange(Sender: TObject);
    procedure EditETcmdNameChange(Sender: TObject);
    procedure BtnETdirectDelClick(Sender: TObject);
    procedure BtnETdirectReplaceClick(Sender: TObject);
    procedure BtnETdirectAddClick(Sender: TObject);
    procedure BtnFListRefreshClick(Sender: TObject);
    procedure CBoxFileFilterChange(Sender: TObject);
    procedure MetadataListDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
    procedure MetadataListSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
    procedure MetadataListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MetadataListExit(Sender: TObject);
    procedure EditQuickEnter(Sender: TObject);
    procedure EditQuickExit(Sender: TObject);
    procedure EditQuickKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnQuickSaveClick(Sender: TObject);
    procedure MPreferencesClick(Sender: TObject);
    procedure BtnFilterEditClick(Sender: TObject);
    procedure CBoxFileFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnColumnEditClick(Sender: TObject);
    procedure BtnShowLogClick(Sender: TObject);
    procedure ShellListDeletion(Sender: TObject; Item: TListItem);
    procedure MDontBackupClick(Sender: TObject);
    procedure MPreserveDateModClick(Sender: TObject);
    procedure MIgnoreErrorsClick(Sender: TObject);
    procedure MShowNumbersClick(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: integer; var Accept: boolean);
    procedure Splitter2CanResize(Sender: TObject; var NewSize: integer; var Accept: boolean);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: integer; var Resize: boolean);
    procedure ShellListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure QuickPopUpMenuPopup(Sender: TObject);
    procedure QuickPopUp_UndoEditClick(Sender: TObject);
    procedure QuickPopUp_MarkTagClick(Sender: TObject);
    procedure QuickPopUp_AddCustomClick(Sender: TObject);
    procedure QuickPopUp_DelCustomClick(Sender: TObject);
    procedure QuickPopUp_AddQuickClick(Sender: TObject);
    procedure MQuickManagerClick(Sender: TObject);
    procedure MExitClick(Sender: TObject);
    procedure SpeedBtnLargeClick(Sender: TObject);
    procedure QuickPopUp_DelQuickClick(Sender: TObject);
    procedure MExifDateTimeshiftClick(Sender: TObject);
    procedure MExportMetaTXTClick(Sender: TObject);
    procedure MImportGPSLogClick(Sender: TObject);
    procedure MImportXMPLogClick(Sender: TObject);
    procedure MExifDateTimeEqualizeClick(Sender: TObject);
    procedure MRemoveMetaClick(Sender: TObject);
    procedure MExifLensFromMakerClick(Sender: TObject);
    procedure MFileDateFromExifClick(Sender: TObject);
    procedure MAboutClick(Sender: TObject);
    procedure QuickPopUp_FillQuickClick(Sender: TObject);
    procedure SpeedBtn_GeotagClick(Sender: TObject);
    procedure SpeedBtn_ShowOnMapClick(Sender: TObject);
    procedure SpeedBtn_MapHomeClick(Sender: TObject);
    procedure EditMapFindKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpeedBtn_MapSetHomeClick(Sender: TObject);
    procedure QuickPopUp_AddDetailsUserClick(Sender: TObject);
    procedure MImportMetaSingleClick(Sender: TObject);
    procedure QuickPopUp_CopyTagClick(Sender: TObject);
    procedure MFileNameDateTimeClick(Sender: TObject);
    procedure MetadataListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure MWorkspaceLoadClick(Sender: TObject);
    procedure MWorkspaceSaveClick(Sender: TObject);
    procedure SpeedBtnChartRefreshClick(Sender: TObject);
    procedure AdvRadioGroup2Click(Sender: TObject);
    procedure MImportRecursiveAllClick(Sender: TObject);
    procedure MImportMetaSelectedClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedBtn_ETdSetDefClick(Sender: TObject);
    procedure SpeedBtn_ETclearClick(Sender: TObject);
    procedure MGUIStyleClick(Sender: TObject);
    procedure ShellListColumnClick(Sender: TObject; Column: TListColumn);
    procedure AdvRadioGroup1Click(Sender: TObject);
    procedure Spb_GoBackClick(Sender: TObject);
    procedure EdgeBrowser1WebMessageReceived(Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
    procedure Spb_ForwardClick(Sender: TObject);
    procedure SpeedBtn_GetLocClick(Sender: TObject);
    procedure CmbETDirectModeChange(Sender: TObject);
    procedure ShellTreeChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure MAPIWindowsWideFileClick(Sender: TObject);
    procedure MetadataListDblClick(Sender: TObject);
    procedure EditFindMetaKeyPress(Sender: TObject; var Key: Char);
    procedure GenericExtractPreviewsClick(Sender: TObject);
    procedure GenericImportPreviewClick(Sender: TObject);
    procedure JPGGenericlosslessautorotate1Click(Sender: TObject);
    procedure UpdateLocationfromGPScoordinatesClick(Sender: TObject);
    procedure EdgeBrowser1CreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
    procedure OnlineDocumentation1Click(Sender: TObject);
    procedure MetadataListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MCustomOptionsClick(Sender: TObject);
    procedure EdgeBrowser1ZoomFactorChanged(Sender: TCustomEdgeBrowser; AZoomFactor: Double);
    procedure EdgeBrowser1NavigationStarting(Sender: TCustomEdgeBrowser; Args: TNavigationStartingEventArgs);
    procedure Splitter2Moved(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure AdvPagePreviewResize(Sender: TObject);
  private
    { Private declarations }
    ETBarSeriesFocal: TBarSeries;
    ETBarSeriesFnum: TBarSeries;
    ETBarSeriesIso: TBarSeries;
    BreadcrumbBar: TDirBreadcrumbBar;
    EdgeZoom: double;
    MinFileListWidth: integer;
    procedure AlignStatusBar;
    procedure ImageDrop(var Msg: TWMDROPFILES); message WM_DROPFILES;
    procedure ShowMetadata;
    procedure ShowPreview;
    procedure ShellListSetFolders;
    procedure EnableMenus(Enable: boolean);
    procedure WMEndSession(var Msg: TWMEndSession); message WM_ENDSESSION;
    function TranslateTagName(xMeta, xName: string): string;

    procedure BreadCrumbClick(Sender: TObject);
    procedure BreadCrumbHome(Sender: TObject);
    procedure RefreshSelected(Sender: TObject);
    procedure ShellTreeBeforeContext(Sender: TObject);
    procedure ShellTreeAfterContext(Sender: TObject);

    procedure ShellistThumbError(Sender: TObject; Item: TListItem; E: Exception);
    procedure ShellistThumbGenerate(Sender: TObject; Item: TListItem; Status: TThumbGenStatus; Total, Remaining: integer);
    procedure ShellListBeforePopulate(Sender: TObject; var DoDefault: boolean);
    procedure ShellListAfterEnumColumns(Sender: TObject);
    procedure ShellListPathChange(Sender: TObject);
    procedure ShellListItemsLoaded(Sender: TObject);
    procedure ShellListOwnerDataFetch(Sender: TObject; Item: TListItem; Request: TItemRequest; AFolder: TShellFolder);
    procedure ShellListColumnResized(Sender: TObject);
    procedure ShellListMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure CounterETEvent(Counter: integer);
  public
    { Public declarations }
    function GetFirstSelectedFile: string;
    function GetFirstSelectedFilePath: string;
    function GetFullPath(MustExpandPath: boolean): string;
    function GetSelectedFile(FileName: string; MustExpandPath: boolean): string; overload;
    function GetSelectedFile(FileName: string): string; overload;
    function GetSelectedFiles(MustExpandPath: boolean): string; overload;
    function GetSelectedFiles: string; overload;
    procedure ExecETEvent_Done(ExecNum: word; EtCmds, EtOuts, EtErrs, StatusLine: string; PopupOnError: boolean);
    procedure ExecRestEvent_Done(Url, Response: string; Succes: boolean);
    procedure UpdateStatusBar_FilesShown;
    procedure SetGuiStyle;
    var GUIBorderWidth, GUIBorderHeight: integer;
    var GUIColorWindow: TColor;
  end;

var
  FMain: TFMain;

implementation

uses System.StrUtils, System.Math, System.Masks, System.Types, System.UITypes,
  Vcl.ClipBrd, Winapi.ShlObj, Winapi.ShellAPI, Vcl.Shell.ShellConsts, Vcl.Themes, Vcl.Styles,
  ExifTool, ExifInfo, ExifToolsGui_LossLess, ExifTool_PipeStream,
  MainDef, LogWin, Preferences, EditFFilter, EditFCol, UFrmStyle, UFrmAbout,
  QuickMngr, DateTimeShift, DateTimeEqual, CopyMeta, RemoveMeta, Geotag, Geomap, CopyMetaSingle, FileDateTime,
  UFrmGenericExtract, UFrmGenericImport, UFrmLossLessRotate, UFrmGeoTagFiles, UFrmGeoSetup;

{$R *.dfm}

const
  GUI_SEP = '-GUI-SEP';
{$IFDEF DEBUG}
  ONLINE_DOC_URL = 'https://github.com/FrankBijnen/ExifToolGui/blob/Development/Docs/ExifToolGUI_V6.md';
{$ELSE}
  ONLINE_DOC_URL = 'https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md';
{$ENDIF}

procedure TFMain.WMEndSession(var Msg: TWMEndSession);
begin // for Windows Shutdown/Log-off while GUI is open
  if Msg.EndSession = true then
    SaveGUIini;
  inherited;
end;

procedure TFMain.QuickPopUp_CopyTagClick(Sender: TObject);
begin
  Clipboard.AsText := MetadataList.Cells[1, MetadataList.Row];
end;

procedure TFMain.AdvRadioGroup1Click(Sender: TObject);
begin
  SpeedBtnChartRefreshClick(Sender);
end;

procedure TFMain.AdvRadioGroup2Click(Sender: TObject);
var
  LeftInc: double;
begin
  with ETChart do
  begin
    UndoZoom;
    ETChart.Title.Visible := true;
    Legend.Visible := false;
    RemoveAllSeries;
  end;

  with ETChart.LeftAxis do
  begin
    Title.Text := 'Nr of photos';
    Visible := true;
    Automatic := false;
    AutomaticMaximum := false;
    AutomaticMinimum := false;
    Minimum := 0; // Cannot have a negative nr of photos!
  end;

  case AdvRadioGroup2.ItemIndex of
    0:
      begin
        ETChart.LeftAxis.Maximum := ChartMaxFLength;
        ETChart.Title.Text.Text := 'Focal length';
        ETChart.AddSeries(ETBarSeriesFocal);
      end;
    1:
      begin
        ETChart.LeftAxis.Maximum := ChartMaxFNumber;
        ETChart.Title.Text.Text := 'F-Number';
        ETChart.AddSeries(ETBarSeriesFnum);
      end;
    2:
      begin
        ETChart.LeftAxis.Maximum := ChartMaxISO;
        ETChart.Title.Text.Text := 'ISO';
        ETChart.AddSeries(ETBarSeriesIso);
      end;
  end;

  if (ETChart.LeftAxis.Maximum < 5) then
    ETChart.LeftAxis.Maximum := 5;
  LeftInc := ETChart.LeftAxis.CalcIncrement;
  if (LeftInc < 1) then
    LeftInc := 1;
  ETChart.LeftAxis.Increment := LeftInc;
end;

procedure TFMain.BtnColumnEditClick(Sender: TObject);
begin
  if FEditFColumn.ShowModal = mrOK then
    with ShellList do
    begin
      Refresh;
      SetFocus;
    end;
  ShowMetadata;
end;

procedure TFMain.BtnETdirectAddClick(Sender: TObject);
begin
  EditETdirect.Text := trim(EditETdirect.Text);
  ETdirectCmd.Append(EditETdirect.Text); // store command
  EditETcmdName.Text := trim(EditETcmdName.Text);
  CBoxETdirect.ItemIndex := CBoxETdirect.Items.Add(EditETcmdName.Text);
  // store name
  CBoxETdirectChange(Sender);
end;

procedure TFMain.BtnETdirectDelClick(Sender: TObject);
var
  i: smallint;
begin
  i := CBoxETdirect.ItemIndex;
  CBoxETdirect.ItemIndex := -1;
  ETdirectCmd.Delete(i);
  CBoxETdirect.Items.Delete(i);
  EditETcmdName.Text := '';
  EditETcmdName.Modified := false;
  EditETdirect.Modified := true;
  CBoxETdirectChange(Sender);
end;

procedure TFMain.BtnETdirectReplaceClick(Sender: TObject);
var
  i: smallint;
begin
  i := CBoxETdirect.ItemIndex;
  CBoxETdirect.ItemIndex := -1;
  EditETdirect.Text := trim(EditETdirect.Text);
  ETdirectCmd[i] := EditETdirect.Text;
  EditETcmdName.Text := trim(EditETcmdName.Text);
  CBoxETdirect.Items[i] := EditETcmdName.Text;
  CBoxETdirect.ItemIndex := i;
  CBoxETdirectChange(Sender);
end;

procedure TFMain.BtnFilterEditClick(Sender: TObject);
var
  i, n, X: smallint;
begin
  if FEditFFilter.ShowModal = mrOK then
    with CBoxFileFilter do
    begin
      X := ItemIndex;
      OnChange := nil;
      i := FEditFFilter.ListBox1.Items.Count - 1;
      Items.Clear;
      for n := 0 to i do
        Items.Append(FEditFFilter.ListBox1.Items[n]);
      OnChange := CBoxFileFilterChange;
      ItemIndex := 0;
      if X <> 0 then
        CBoxFileFilterChange(Sender);
    end;
end;

procedure TFMain.BtnFListRefreshClick(Sender: TObject);
begin
  ShellList.Refresh; // -use this (to be sure)
  ShellList.SetFocus;
end;

procedure TFMain.BtnQuickSaveClick(Sender: TObject);
var
  i, j, k: smallint;
  ETcmd, TagValue, Tx: string;
  ETout, ETerr: string;
begin
  ETcmd := '';
  SpeedBtnQuickSave.Enabled := false;
  j := MetadataList.RowCount - 1; // Rotated:=false;
  for i := 1 to j do
  begin
    if pos('*', MetadataList.Keys[i]) = 1 then
    begin
      TagValue := MetadataList.Cells[1, i];

      Tx := MetadataList.Keys[i];
      k := pos(#177, Tx); // is it multi-value tag?
      if (k = 0) or (TagValue = '') then
      begin // no: standard tag

        k := 0;
        if RightStr(Tx, 1) = '#' then
          inc(k);
        Tx := LowerCase(QuickTags[i - 1].Command);
        if k > 0 then
        begin
          if RightStr(Tx, 1) <> '#' then
            Tx := Tx + '#';
        end;
        ETcmd := ETcmd + Tx + '=' + TagValue + CRLF;
      end
      else
      begin // it is multi-value tag (ie.keywords)
        repeat
          ETcmd := ETcmd + QuickTags[i - 1].Command;
          case TagValue[1] of
            '+':
              begin
                ETcmd := ETcmd + '+=';
                Delete(TagValue, 1, 1);
              end;
            '-':
              begin
                ETcmd := ETcmd + '-=';
                Delete(TagValue, 1, 1);
              end;
          else
            ETcmd := ETcmd + '=';
          end;
          k := pos('+', TagValue);
          if k > 0 then
            Tx := Copy(TagValue, 1, k - 1)
          else
          begin
            k := pos('-', TagValue);
            if k > 0 then
              Tx := Copy(TagValue, 1, k - 1)
            else
              Tx := TagValue;
          end;
          if k > 0 then
            Delete(TagValue, 1, k - 1)
          else
            TagValue := '';
          ETcmd := ETcmd + Tx + CRLF;
        until length(TagValue) = 0;
      end;
    end;
  end;

  if (ET_OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr)) then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
  MetadataList.SetFocus;
end;

procedure TFMain.BtnShowLogClick(Sender: TObject);
begin
  FLogWin.Show;
end;

procedure TFMain.CBoxDetailsChange(Sender: TObject);
begin
  with CBoxDetails do
    SpeedBtnColumnEdit.Enabled := SpeedBtnDetails.Down and (ItemIndex = Items.Count - 1);

  with ShellList do
  if (Enabled) then
  begin
    Refresh;
    ShowMetadata;
    ShowPreview;
    SetFocus;
  end;
end;

procedure TFMain.GenericExtractPreviewsClick(Sender: TObject);
begin
  if FGenericExtract.ShowModal = mrOK then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
end;

procedure TFMain.GenericImportPreviewClick(Sender: TObject);
begin
  if FGenericImport.ShowModal = mrOK then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
end;

function TFMain.GetFirstSelectedFile: string;
begin
  result := '';
  if (ShellList.Selected <> nil) then
    result := ShellList.FileName + CRLF
  else if (ShellList.Items.Count > 0) then
    result := ShellList.FileName(0) + CRLF;
end;

function TFMain.GetFirstSelectedFilePath: string;
begin
  result := '';
  if (ShellList.Selected <> nil) then
    result := ShellList.FilePath
  else if (ShellList.Items.Count > 0) then
    result := ShellList.FilePath(0);
end;

function TFMain.GetFullPath(MustExpandPath: boolean): string;
begin
  result := '';
  if (MustExpandPath) then
    result := IncludeTrailingBackslash(ShellList.Path);
end;

function TFMain.GetSelectedFile(FileName: string; MustExpandPath: boolean): string;
begin
  if (FileName = '') then
    result := ''
  else
    result := GetFullPath(MustExpandPath) + FileName;
end;

function TFMain.GetSelectedFile(FileName: string): string;
begin
  result := GetSelectedFile(FileName, ET_Options.ETAPIWindowsWideFile = '');
end;

function TFMain.GetSelectedFiles(MustExpandPath: boolean): string;
var
  AnItem: TListItem;
  FullPath: string;
begin
  result := '';
  FullPath := GetFullPath(MustExpandPath);
  for AnItem in ShellList.Items do
  begin
    if (AnItem.Selected) and
       (ShellList.Folders[AnItem.Index].IsFolder = false) then
      result := result + FullPath +ShellList.FileName(AnItem.Index) + CRLF;
  end;
end;

function TFMain.GetSelectedFiles: string;
begin
  result := GetSelectedFiles(ET_Options.ETAPIWindowsWideFile = '');
end;

procedure TFMain.EditMapFindKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_Return) and
     (EditMapFind.Text <> '') then
    EditMapFind.Text := MapGotoPlace(EdgeBrowser1, EditMapFind.Text, EditMapBounds.Text, '', InitialZoom_Out);
end;

procedure TFMain.MGUIStyleClick(Sender: TObject);
begin
  ShellTree.SetFocus;
  with FrmStyle do
  begin
    CurPath := ShellList.Path;
    CurStyle := GUIsettings.GuiStyle;
    Show;
  end;
end;

procedure TFMain.MAboutClick(Sender: TObject);
begin
  FrmAbout.ShowModal;
end;

procedure TFMain.MAPIWindowsWideFileClick(Sender: TObject);
begin
  with ET_Options do
    SetApiWindowsWideFile(MAPIWindowsWideFile.Checked);
end;

procedure TFMain.MDontBackupClick(Sender: TObject);
begin
  with ET_Options do
    if MDontBackup.Checked then
      ETBackupMode := '-overwrite_original' + CRLF
    else
      ETBackupMode := '';
end;

procedure TFMain.MetadataListDblClick(Sender: TObject);
var
  tx: string;
  IsSep: boolean;
begin
  if (GUIsettings.DblClickUpdTags = false) then
    exit;

  tx := MetadataList.Keys[MetadataList.Row];
  IsSep := (length(tx) = 0);
  if (IsSep) then
    exit;

  if SpeedBtnQuick.Down then
    QuickPopUp_DelQuickClick(Sender)
  else
    QuickPopUp_AddQuickClick(Sender);
end;

procedure TFMain.MetadataListDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
var
  CellTx, KeyTx, WorkTx: string[127];
  NewColor, TxtColor: TColor;
  i, n, X: smallint;
begin
  n := length(QuickTags) - 1;
  if (ARow > 0) then
    with MetadataList do
    begin
      CellTx := Cells[ACol, ARow];
      KeyTx := Cells[0, ARow];
      if (KeyTx = '') then
        with Canvas do
        begin // =Group line
          Brush.Style := bsSolid;
          if ACol = 0 then
          begin
            Brush.Color := clWindow; // $F0F0F0;
            FillRect(Rect);
          end
          else
          begin // ACol=1
            Brush.Color := clWindow;
            Font.Style := [fsBold];
            Font.Color := clWindowText;
            TextRect(Rect, Rect.Left + 4, Rect.Top + 2, CellTx);
          end;
        end
      else if (ACol = 0) then
      begin // -remove "if ACol=0 then" to change both columns
        NewColor := clWindow;
        if SpeedBtnQuick.Down then
        begin // =Edited tag
          if (KeyTx[1] = '*') then
            NewColor := $BBFFFF;
          if NewColor <> clWindow then
            with Canvas do
            begin
              Brush.Style := bsSolid;
              Brush.Color := NewColor;
              Font.Color := $BB0000;
              TextRect(Rect, Rect.Left + 4, Rect.Top + 2, CellTx);
            end;
        end
        else
        begin
          if GUIsettings.Language = '' then
          begin // =Marked tag
            Delete(KeyTx, 1, pos(' ', KeyTx)); // -in case of Show HexID prefix
            TxtColor := clWindowText;
            if pos(KeyTx + ' ', MarkedTags) > 0 then
              TxtColor := $0000FF; // tag is marked
            // check if tag is defined in Workspace
            KeyTx := UpperCase(KeyTx);
            for i := 0 to n do
            begin
              WorkTx := UpperCase(QuickTags[i].Command);
              X := pos(':', WorkTx);
              if X > 0 then
                Delete(WorkTx, 1, X);
              if KeyTx = WorkTx then
              begin
                NewColor := $EEFFDD;
                break;
              end;
            end;
            if (NewColor <> clWindow) or (TxtColor <> clWindowText) then
              with Canvas do
              begin
                Brush.Style := bsSolid;
                Brush.Color := NewColor;
                Font.Color := TxtColor;
                TextRect(Rect, Rect.Left + 4, Rect.Top + 2, CellTx);
              end;
          end;
        end;
      end;
    end;
end;

procedure TFMain.MetadataListExit(Sender: TObject);
begin // remember last selected row
  if SpeedBtnQuick.Down then
    MetadataList.Tag := MetadataList.Row;
end;

procedure TFMain.MetadataListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: smallint;
begin
  i := MetadataList.Row;
  if (Key = VK_Return) and SpeedBtnQuick.Down and not(QuickTags[i - 1].NoEdit) then
  begin
    if SpeedBtnLarge.Down then
      MemoQuick.SetFocus
    else
      EditQuick.SetFocus;
  end;
  if (Shift = [ssCTRL]) and (Key = Ord('C')) then
    Clipboard.AsText := MetadataList.Cells[1, i];
end;

procedure TFMain.MetadataListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  XCol, XRow: integer;
begin
  if Button = mbRight then
    with MetadataList do
    begin
      MouseToCell(X, Y, XCol, XRow);
      Row := XRow;
    end;
end;

procedure TFMain.MetadataListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: integer;
begin
  TValueListEditor(Sender).MouseToCell(X, Y, ACol, ARow);
  if (ARow >= 1) and
     (ARow <= TValueListEditor(Sender).RowCount) and
     (TValueListEditor(Sender).Tag <> ARow) then  // Hint already shown?
  begin
    TValueListEditor(Sender).Tag := ARow;         // Remember the row that has the hint.

    Hint := TValueListEditor(Sender).Cells[1, ARow];
    Application.ActivateHint(TValueListEditor(Sender).ClientToScreen(Point(X, Y))); // Force hint display
  end;
end;

procedure TFMain.MetadataListSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
var EditText: string;
begin
  EditQuick.Text := '';
  MemoQuick.Text := '';
  if (ARow - 1 > High(QuickTags)) then
    exit;
  if SpeedBtnQuick.Down and
     not(QuickTags[ARow - 1].NoEdit) then
  begin
    if RightStr(TValueListEditor(Sender).Keys[ARow], 1) = #177 then
      EditText := '+'
    else
      EditText := TValueListEditor(Sender).Cells[1, ARow];
    if SpeedBtnLarge.Down then
      MemoQuick.Text := EditText
    else
      EditQuick.Text := EditText;
  end;
end;

procedure TFMain.MExifDateTimeEqualizeClick(Sender: TObject);
begin
  if FDateTimeEqual.ShowModal = mrOK then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
  end;
end;

procedure TFMain.MExifDateTimeshiftClick(Sender: TObject);
begin
  if FDateTimeShift.ShowModal = mrOK then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
  end;
end;

procedure TFMain.MExifLensFromMakerClick(Sender: TObject);
var
  ETcmd, ETout, ETerr: string;
begin
  if MessageDlg('This will fill Exif:LensInfo of selected files with relevant' + #10#13 +
                'values from Makernotes data (where possible).' + #10#13#10#13 +
                'OK to proceed?', mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    ETcmd := '-Exif:LensInfo<LensID' + CRLF + '-Exif:LensModel<LensID' + CRLF;
    ET_OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr);
    RefreshSelected(Sender);
    ShowMetadata;
  end;
end;

procedure TFMain.MExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFMain.MExportMetaTXTClick(Sender: TObject);
var
  i: smallint;
  ETcmd, xDir, ETout, ETerr: string;
begin
  xDir := '';
  if GUIsettings.DefExportUse then
  begin
    xDir := GUIsettings.DefExportDir;
    i := length(xDir);
    if i > 0 then
      if xDir[i] <> '\' then
        xDir := xDir + '\';
  end;

  if Sender = MExportMetaTXT then
    ETcmd := '-w' + CRLF + xDir + '%f.txt' + CRLF + '-g0' + CRLF + '-a' + CRLF + '-All:All';
  if Sender = MExportMetaMIE then
    ETcmd := '-o' + CRLF + xDir + '%f.mie' + CRLF + '-All:All';
  if Sender = MExportMetaXMP then
    ETcmd := '-o' + CRLF + xDir + '%f.xmp' + CRLF + '-Xmp:All';
  if Sender = MExportMetaEXIF then
    ETcmd := '-TagsFromFile' + CRLF + '@' + CRLF + '-All:All' + CRLF + '-o' + CRLF + '%f.exif';
  if Sender = MExportMetaHTM then
    ETcmd := '-w' + CRLF + xDir + '%f.html' + CRLF + '-htmldump';

  ET_OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr);
  if xDir = '' then
    BtnFListRefreshClick(Sender);
end;

procedure TFMain.MFileDateFromExifClick(Sender: TObject);
var
  ETout, ETerr: string;
begin
  if MessageDlg('This will set "Date modified" of selected files' + #10#13 +
                'according to Exif:DateTimeOriginal value.' + #10#13#10#13 +
                'OK to proceed?', mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    ET_OpenExec('-FileModifyDate<Exif:DateTimeOriginal', GetSelectedFiles, ETout, ETerr);
    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
end;

procedure TFMain.MFileNameDateTimeClick(Sender: TObject);
begin
  FFileDateTime.ShowModal;
end;

procedure TFMain.MIgnoreErrorsClick(Sender: TObject);
begin
  with ET_Options do
    if MIgnoreErrors.Checked then
      ETMinorError := '-m' + CRLF
    else
      ET_Options.ETMinorError := '';
end;

procedure TFMain.MImportMetaSelectedClick(Sender: TObject);
var
  DstExt: string[7];
  ETcmd, ETout, ETerr: string;
  j: smallint;
begin
  // if Sender=MImportMetaIntoJPG then DstExt:='JPG' else DstExt:='TIF';
  DstExt := UpperCase(ExtractFileExt(ShellList.SelectedFolder.PathName));
  Delete(DstExt, 1, 1);

  if (DstExt = 'JPG') or (DstExt = 'TIF') then
  begin
    j := ShellList.SelCount;
    if j > 1 then // message appears only if multi files selected
      if MessageDlg('This will copy ALL metadata from any source into' + #10#13 +
                    'currently *selected* ' + DstExt + ' files.' + #10#13 +
                    'Only those selected files will be processed,' + #10#13 +
                    'where source and destination filename is equal.' + #10#13#10#13 +
                    'Next: Select source file. OK to proceed?',
                    mtInformation, [mbOk, mbCancel], 0) <> mrOK then
        j := 0;
    if j <> 0 then
    begin
      with OpenPictureDlg do
      begin
        InitialDir := ShellList.Path;
        Filter := 'Image & Metadata files|*.*';
        Options := [ofFileMustExist];
        Title := 'Select any of source files';
        FileName := '';
      end;
      if OpenPictureDlg.Execute then
      begin
        ETcmd := OpenPictureDlg.FileName; // single file selected
        if j > 1 then
          ETcmd := ExtractFileDir(ETcmd) + '\%f' + ExtractFileExt(ETcmd);
        // multiple files
        ETcmd := '-TagsFromFile' + CRLF + ETcmd + CRLF + '-All:All' + CRLF;
        if FCopyMetadata.ShowModal = mrOK then
        begin
          with FCopyMetadata do
          begin
            if not CheckBox1.Checked then
              ETcmd := ETcmd + '--exif:ExifImageWidth' + CRLF + '--exif:ExifImageHeight' + CRLF;
            if not CheckBox2.Checked then
              ETcmd := ETcmd + '--exif:Orientation' + CRLF;
            if not CheckBox3.Checked then
              ETcmd := ETcmd + '--exif:Xresolution' + CRLF + '--exif:Yresolution' + CRLF + '--exif:ResolutionUnit' + CRLF;
            if not CheckBox4.Checked then
              ETcmd := ETcmd + '--exif:ColorSpace' + CRLF + '--exif:InteropIndex' + CRLF;
            if not CheckBox5.Checked then
              ETcmd := ETcmd + '--Makernotes' + CRLF;
            if not CheckBox6.Checked then
              ETcmd := ETcmd + '--Xmp-photoshop' + CRLF;
            if not CheckBox7.Checked then
              ETcmd := ETcmd + '--Xmp-crs' + CRLF;
            if not CheckBox8.Checked then
              ETcmd := ETcmd + '--Xmp-exif' + CRLF;
          end;
          ETcmd := ETcmd + '-ext' + CRLF + DstExt;
          if (ET_OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr)) then
          begin
            RefreshSelected(Sender);
            ShowMetadata;
          end;
        end;
      end;
    end;
  end
  else
    ShowMessage('Selected destination file must be JPG or TIF!');
end;

procedure TFMain.MImportMetaSingleClick(Sender: TObject);
begin
  if MessageDlg('This will copy metadata from single source file,' + #10 + #13 + 'into currently selected files.' + #10 + #13 + #10 + #13 +
    'Next: 1.Select source file,  2.Select metadata to copy' + #10 + #13 + 'OK to proceed?', mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    with OpenPictureDlg do
    begin
      InitialDir := ShellList.Path;
      Filter := 'Image & Metadata files|*.jpg;*.jpeg;*.cr2;*.dng;*.nef;*.tif;*.tiff;*.mie;*.xmp;*.rw2';
      Options := [ofFileMustExist];
      Title := 'Select source file';
      FileName := '';
    end;
    if OpenPictureDlg.Execute then
    begin
      FCopyMetaSingle.SrcFile := OpenPictureDlg.FileName;
      if FCopyMetaSingle.ShowModal = mrOK then
      begin
        RefreshSelected(Sender);
        ShowMetadata;
      end;
    end;
  end;
end;

procedure TFMain.MImportRecursiveAllClick(Sender: TObject);
var
  i: integer;
  DstExt: string[5];
  ETcmd, ETout, ETerr: string;
begin
  DstExt := LowerCase(ShellList.FileExt);
  Delete(DstExt, 1, 1);
  if (DstExt = 'jpg') or (DstExt = 'tif') then
  begin
    i := MessageDlg('This will copy metadata from files in another folder' + #10#13 +
                    'into *all* ' + UpperCase(DstExt) +
                    ' files inside currently *selected* folder.' + #10#13 +
                    'Only those files will be processed, where' + #10#13 +
                    'source and destination filename is equal.' + #10#13#10#13 +
                    'Should files in subfolders also be processed?', mtInformation,
                    [mbYes, mbNo, mbCancel], 0);
    if i <> mrCancel then
    begin
      with OpenPictureDlg do
      begin
        InitialDir := ShellList.Path;
        Filter := 'Image & Metadata files|*.*';
        Options := [ofFileMustExist];
        Title := 'Select any of source files';
        FileName := '';
      end;
      if OpenPictureDlg.Execute then
      begin
        ETcmd := '-TagsFromFile' + CRLF + ExtractFilePath(OpenPictureDlg.FileName); // incl. slash
        if i = mrYes then
          ETcmd := ETcmd + '%d\';
        ETcmd := ETcmd + '%f' + ExtractFileExt(OpenPictureDlg.FileName);
        if i = mrYes then
          ETcmd := ETcmd + CRLF + '-r';
        ETcmd := ETcmd + CRLF + '-All:All' + CRLF;
        if FCopyMetadata.ShowModal = mrOK then
        begin
          with FCopyMetadata do
          begin
            if not CheckBox1.Checked then
              ETcmd := ETcmd + '--exif:ExifImageWidth' + CRLF + '--exif:ExifImageHeight' + CRLF;
            if not CheckBox2.Checked then
              ETcmd := ETcmd + '--exif:Orientation' + CRLF;
            if not CheckBox3.Checked then
              ETcmd := ETcmd + '--exif:Xresolution' + CRLF + '--exif:Yresolution' + CRLF + '--exif:ResolutionUnit' + CRLF;
            if not CheckBox4.Checked then
              ETcmd := ETcmd + '--exif:ColorSpace' + CRLF + '--exif:InteropIndex' + CRLF;
            if not CheckBox5.Checked then
              ETcmd := ETcmd + '--Makernotes' + CRLF;
            if not CheckBox6.Checked then
              ETcmd := ETcmd + '--Xmp-photoshop' + CRLF;
            if not CheckBox7.Checked then
              ETcmd := ETcmd + '--Xmp-crs' + CRLF;
            if not CheckBox8.Checked then
              ETcmd := ETcmd + '--Xmp-exif' + CRLF;
          end;
          ETcmd := ETcmd + '-ext' + CRLF + DstExt;
          SetCounter(CounterETEvent, GetNrOfFiles(ShellList.Path, '*.' + DstExt, (i = mrYes)));
          if (ET_OpenExec(ETcmd, '.', ETout, ETerr)) then
          begin
            RefreshSelected(Sender);
            ShowMetadata;
          end;
        end;
      end;
    end;
  end
  else
    ShowMessage('Selected destination file must be JPG or TIF!');
end;

procedure TFMain.MImportXMPLogClick(Sender: TObject);
var
  SrcDir, ETcmd, ETout, ETerr: string;
begin
  if MessageDlg('This will import GPS data from XMP sidecar files into' + #10#13 +
                'Exif GPS region of currently selected files.' + #10#13 +
                'Only those selected files will be processed, where' + #10#13 +
                'source and destination filename is equal.' + #10#13#10#13 +
                'Next: Select folder containing XMP files. OK to proceed?',
                mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    if GpsXmpDir <> '' then
      SrcDir := GpsXmpDir
    else
      SrcDir := ShellList.Path;
    SrcDir := BrowseFolderDlg('Choose folder containing XMP sidecar files', 1, SrcDir);
    if SrcDir <> '' then
    begin
      if SrcDir[length(SrcDir)] <> '\' then
        SrcDir := SrcDir + '\';
      GpsXmpDir := SrcDir;
      ETcmd := '-TagsFromFile' + CRLF + SrcDir + '%f.xmp' + CRLF;
      ETcmd := ETcmd + '-GPS:GPSLatitude<Xmp-exif:GPSLatitude' + CRLF + '-GPS:GPSLongitude<Xmp-exif:GPSLongitude' + CRLF;
      ETcmd := ETcmd + '-GPS:GPSLatitudeRef<Composite:GPSLatitudeRef' + CRLF + '-GPS:GPSLongitudeRef<Composite:GPSLongitudeRef' + CRLF;
      ETcmd := ETcmd + '-GPS:GPSDateStamp<XMP-exif:GPSDateTime' + CRLF + '-GPS:GPSTimeStamp<XMP-exif:GPSDateTime';
      if (ET_OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr)) then
      begin
        RefreshSelected(Sender);
        ShowMetadata;
      end;
    end;
  end;
end;

procedure TFMain.JPGGenericlosslessautorotate1Click(Sender: TObject);
begin
  if FLossLessRotate.ShowModal = mrOK then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
end;

procedure TFMain.MImportGPSLogClick(Sender: TObject);
begin
  if FGeotag.ShowModal = mrOK then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
  end;
end;

procedure TFMain.MPreferencesClick(Sender: TObject);
begin
  if FPreferences.ShowModal = mrOK then
  begin
    EnableMenus(ET_StayOpen(ShellList.Path)); // Recheck Exiftool.exe.
    ShellListSetFolders;
    ShellList.Refresh;
    ShowMetadata;
  end;
end;

procedure TFMain.MPreserveDateModClick(Sender: TObject);
begin
  with ET_Options do
    if MPreserveDateMod.Checked then
      ETFileDate := '-P' + CRLF
    else
      ETFileDate := '';
end;

procedure TFMain.MQuickManagerClick(Sender: TObject);
var
  Indx: smallint;
begin
  if FQuickManager.ShowModal = mrOK then
  begin
    Indx := FQuickManager.StringGrid1.Row;
    if SpeedBtnQuick.Down then
    begin
      ShowMetadata;
      if ShellList.ItemIndex >= 0 then
        MetadataList.Row := Indx + 1;
    end;
  end;
end;

procedure TFMain.MRemoveMetaClick(Sender: TObject);
begin
  if FRemoveMeta.ShowModal = mrOK then
    ShowMetadata;
end;

procedure TFMain.MShowNumbersClick(Sender: TObject);
begin
  if Sender = MShowNumbers then
    with ET_Options do
      if MShowNumbers.Checked then
        ETShowNumber := '-n' + CRLF
      else
        ETShowNumber := '';
  if Sender = MShowGPSdecimal then
    ET_Options.SetGpsFormat(MShowGPSdecimal.Checked); // + used by MShowHexID, MGroup_g4, MShowComposite, MShowSorted, MNotDuplicated
  RefreshSelected(Sender);
  ShowMetadata;
end;

procedure TFMain.MCustomOptionsClick(Sender: TObject);
begin
  ET_Options.ETCustomOptions := InputBox('Specify Custom options to add to Exiftool args',
                                         'Custom options',
                                         ET_Options.ETCustomOptions);
end;

procedure TFMain.MWorkspaceLoadClick(Sender: TObject);
begin
  with OpenFileDlg do
  begin
    // DefaultExt:='ini';
    InitialDir := WrkIniDir;
    Filter := 'Ini file|*.ini';
    Title := 'Load Workspace definition file';
    if Execute then
    begin
      if LoadWorkspaceIni(FileName) then
      begin
        if SpeedBtnQuick.Down then
          ShowMetadata
        else
          ShowMessage('New Workspace loaded.');
      end
      else
        ShowMessage('Ini file doesn''t contain Workspace data -nothing changed.');
      WrkIniDir := ExtractFileDir(FileName);
    end;
  end;
end;

procedure TFMain.MWorkspaceSaveClick(Sender: TObject);
var
  DoSave, IsOK: boolean;
begin
  with SaveFileDlg do
  begin
    DefaultExt := 'ini';
    InitialDir := WrkIniDir;
    Filter := 'Ini file|*.ini';
    Title := 'Save Worspace definition file';
    repeat
      IsOK := false;
      DoSave := Execute;
      InitialDir := ExtractFileDir(FileName);
      if DoSave then
      begin
        IsOK := (ExtractFileName(FileName) <> ExtractFileName(GetIniFilePath(false)));
        if not IsOK then
          ShowMessage('Use another name for Workspace definition file!');
      end;
    until not DoSave or IsOK;
    if DoSave then
    begin
      if SaveWorkspaceIni(FileName) then
        ShowMessage('Workspace definition file saved.')
      else
        ShowMessage('Workspace definition file couldn''t be saved!?');
      WrkIniDir := ExtractFileDir(FileName);
    end;
  end;
end;

procedure TFMain.OnlineDocumentation1Click(Sender: TObject);
begin
  ShellExecute(0, 'Open', PWideChar(ONLINE_DOC_URL), '', '', SW_SHOWNORMAL);
end;

procedure TFMain.QuickPopUpMenuPopup(Sender: TObject);
var
  i: smallint;
  IsSep, Other: boolean;
  tx: string;
begin
  i := MetadataList.Row;
  tx := MetadataList.Keys[i];
  QuickPopUp_UndoEdit.Visible := (pos('*', tx) = 1);
  IsSep := (length(tx) = 0);

  QuickPopUp_AddQuick.Visible := not(SpeedBtnQuick.Down or SpeedBtnCustom.Down or IsSep);
  QuickPopUp_AddCustom.Visible := not(SpeedBtnQuick.Down or SpeedBtnCustom.Down or IsSep);
  QuickPopUp_DelCustom.Visible := SpeedBtnCustom.Down and not(IsSep);
  QuickPopUp_AddDetailsUser.Visible := not IsSep and (SpeedBtnExif.Down or SpeedBtnXmp.Down or SpeedBtnIptc.Down);

  Other := (GUIsettings.Language <> '') or IsSep;

  QuickPopUp_MarkTag.Visible := not(SpeedBtnQuick.Down or SpeedBtnCustom.Down or Other);

  QuickPopUp_DelQuick.Visible := not(IsSep) and SpeedBtnQuick.Down;
  QuickPopUp_FillQuick.Visible := QuickPopUp_DelQuick.Visible;
  QuickPopUp_CopyTag.Visible := not IsSep;
end;

function TFMain.TranslateTagName(xMeta, xName: string): string;
var
  Indx: integer; // xMeta~'-Exif:' or '-IFD0:' or ...
  ETout: TStringList;
begin
  ETout := TStringList.Create;
  try
    if ET_Options.ETLangDef <> '' then
    begin
      ET_OpenExec('-X' + CRLF + '-l' + CRLF + xMeta + 'All', GetSelectedFile(ShellList.FileName), ETout);
      Indx := ETout.Count;
      while Indx > 1 do
      begin
        dec(Indx);
        if pos('desc>' + xName + '</et:', ETout[Indx]) > 0 then
          break;
      end;
      dec(Indx);
      if Indx >= 0 then
      begin
        xName := ETout[Indx];
        Indx := pos(':', xName);
        Delete(xName, 1, Indx);
        Indx := pos(' ', xName);
        SetLength(xName, Indx - 1);
      end;
    end;
    result := xName;
  finally
    ETout.Free;
  end;
end;

procedure TFMain.QuickPopUp_AddCustomClick(Sender: TObject);
var
  i: smallint;
  tx, ts: string;
  IsVRD: boolean;
begin
  i := MetadataList.Row;
  tx := MetadataList.Keys[i];
  if LeftStr(tx, 2) = '0x' then
    Delete(tx, 1, 7)
  else if LeftStr(tx, 2) = '- ' then
    Delete(tx, 1, 2);
  tx := TrimRight(tx);
  if SpeedBtnExif.Down then
    ts := '-Exif:'
  else if SpeedBtnXmp.Down then
    ts := '-Xmp:'
  else if SpeedBtnIptc.Down then
    ts := '-Iptc:'
  else if SpeedBtnMaker.Down then
  begin
    repeat
      dec(i);
      IsVRD := (pos('CanonVRD', MetadataList.Cells[1, i]) > 0);
    until IsVRD or (i = 0);
    if IsVRD then
      ts := '-CanonVRD:'
    else
      ts := '-Makernotes:';
  end
  else
    ts := '-';
  tx := ts + TranslateTagName(ts, tx);
  if pos(tx, CustomViewTags) > 0 then
    ShowMessage('Tag already exists in Custom view.')
  else
    CustomViewTags := CustomViewTags + tx + ' ';
end;

procedure TFMain.QuickPopUp_AddDetailsUserClick(Sender: TObject);
var
  I, N, X: smallint;
  Tx, Tk: string;
begin
  I := length(FListColUsr);
  SetLength(FListColUsr, I + 1);
  N := MetadataList.Row;
  X := N;
  repeat // find group
    Dec(X);
    Tx := MetadataList.Keys[X];
  until length(Tx) = 0;
  Tx := MetadataList.Cells[1, X];     // eg '---- IFD0 ----'
  Delete(Tx, 1, 5);                   // ='IFD0 ----'
  X := pos(' ', Tx);
  SetLength(Tx, X - 1);               // ='IFD0'
  Tx := '-' + Tx + ':';               // ='-IFD0:'

  Tk := MetadataList.Keys[N];         // 'Make'
  if LeftStr(Tk, 2) = '0x' then
    Delete(Tk, 1, 7)
  else if LeftStr(Tk, 2) = '- ' then
    Delete(Tk, 1, 2);
  Tk := TrimRight(Tk);

  FListColUsr[I].Caption := Tk;
  Tk := TranslateTagName(Tx, Tk);
  FListColUsr[I].Command := Tx + Tk;  // ='-IFD0:Make'
  FListColUsr[I].Width := 96;
  FListColUsr[I].AlignR := 0;

  with CBoxDetails do
  begin
    I := ItemIndex;
    N := Items.Count - 1;
  end;
  if I = N then
    ShellList.Refresh;
end;

procedure TFMain.QuickPopUp_AddQuickClick(Sender: TObject);
var
  I, N, X: smallint;
  Tx, Ty, Tz, T1: string;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    I := Length(QuickTags);
    SetLength(QuickTags, I + 1);
    N := MetadataList.Row;
    if SpeedBtnExif.Down then
      Tz := 'Exif:'
    else if SpeedBtnXmp.Down then
      Tz := 'Xmp:'
    else if SpeedBtnIptc.Down then
      Tz := 'Iptc:'
    else
      Tz := '';

    if MGroup_g4.Checked then
      Tx := Tz
    else
    begin // find group
      X := N;
      repeat
        Dec(X);
        Tx := MetadataList.Keys[X];
      until length(Tx) = 0;
      Tx := MetadataList.Cells[1, X]; // eg '---- IFD0 ----'
      Delete(Tx, 1, 5);               // -> 'IFD0 ----'
      X := pos(' ', Tx);
      SetLength(Tx, X - 1);           // -> 'IFD0'
      Tx := Tx + ':';                 // -> 'IFD0:'
    end;

    Ty := MetadataList.Keys[N];       // e.g. 'Make' or '0x010f Make' or '- Rating'
    if LeftStr(Ty, 2) = '0x' then
      Delete(Ty, 1, 7)
    else if LeftStr(Ty, 2) = '- ' then
      Delete(Ty, 1, 2);
    Ty := TrimRight(Ty);
    T1 := Ty;                         // tl=language specific tag name
    Ty := TranslateTagName('-' + Tz, Ty);
    with QuickTags[I] do
    begin
      Caption := Tz + T1;
      Command := '-' + Tx + Ty;       // ='-IFD0:Make'
      Help := 'No Hint defined';
    end;
  finally
    MetadataList.Refresh;
    SetCursor(CrNormal);
  end;
end;

procedure TFMain.QuickPopUp_DelCustomClick(Sender: TObject);
var
  I, J: smallint;
  Tx, T1: string;
begin
  I := MetadataList.Row;
  if ET_Options.ETLangDef <> '' then
  begin
    T1 := ET_Options.ETLangDef;
    ET_Options.ETLangDef := '';
    ShowMetadata;
    Tx := MetadataList.Keys[I];
    ET_Options.ETLangDef := T1;
  end
  else
    Tx := MetadataList.Keys[I];

  if LeftStr(Tx, 2) = '0x' then
    Delete(Tx, 1, 7)
  else if LeftStr(Tx, 2) = '- ' then
    Delete(Tx, 1, 2);
  Tx := TrimRight(Tx); // =tag name

  if Length(Tx) > 0 then
  begin // should be always true!
    I := pos(Tx, CustomViewTags);
    J := I;
    repeat
      dec(I);
    until CustomViewTags[I] = '-';
    repeat
      inc(J);
    until CustomViewTags[J] = ' ';
    Delete(CustomViewTags, I, J - I + 1);
  end;
  ShowMetadata;
end;

procedure TFMain.QuickPopUp_DelQuickClick(Sender: TObject);
var
  i, n: smallint;
begin
  n := MetadataList.Row - 1;
  i := length(QuickTags) - 1;
  while n < i do
  begin
    QuickTags[n].Caption := QuickTags[n + 1].Caption;
    QuickTags[n].Command := QuickTags[n + 1].Command;
    QuickTags[n].Help := QuickTags[n + 1].Help;
    QuickTags[n].NoEdit := QuickTags[n + 1].NoEdit;
    inc(n);
  end;
  SetLength(QuickTags, i);
  ShowMetadata;
end;

procedure TFMain.QuickPopUp_FillQuickClick(Sender: TObject);
var
  i, n: smallint;
  tx: string;
begin
  n := length(QuickTags);
  with MetadataList do
  begin
    for i := 0 to n - 1 do
    begin
      tx := QuickTags[i].Caption;
      if RightStr(tx, 1) = '*' then
      begin
        Insert('*', tx, 1);
        Keys[i + 1] := tx;
        Cells[1, i + 1] := QuickTags[i].Help;
      end;
    end;
    SpeedBtnQuickSave.Enabled := true;
  end;
end;

procedure TFMain.QuickPopUp_MarkTagClick(Sender: TObject);
var
  I, J: smallint;
  Tx: string;
begin
  with MetadataList do
    Tx := Keys[Row];
  I := pos(' ', Tx);
  if I > 0 then
    Delete(Tx, 1, I); // if Show HexID exist
  if Length(Tx) > 0 then
  begin
    I := pos(Tx, MarkedTags);
    if I > 0 then
    begin // tag allready marked: unmark it
      J := I;
      repeat
        inc(J);
      until MarkedTags[J] = ' ';
      Delete(MarkedTags, I, J - I + 1);
    end
    else
      MarkedTags := MarkedTags + Tx + ' '; // mark tag
  end;
end;

procedure TFMain.QuickPopUp_UndoEditClick(Sender: TObject);
var
  I, N, X: smallint;
  Tx, ETouts, ETerrs: string;
begin
  I := MetadataList.Row;
  MetadataList.Keys[I] := QuickTags[I - 1].Caption;
  Tx := '-s3' + CRLF + '-f' + CRLF + QuickTags[I - 1].Command;
  ET_OpenExec(Tx, GetSelectedFile(ShellList.FileName), ETouts, ETerrs);
  MetadataList.Cells[1, I] := ETouts;
  N := MetadataList.RowCount - 1;
  X := 0;
  for I := 1 to N do
    if pos('*', MetadataList.Keys[I]) = 1 then
      inc(X);
  SpeedBtnQuickSave.Enabled := (X > 0);
end;

procedure TFMain.ExecETEvent_Done(ExecNum: word; EtCmds, EtOuts, EtErrs, StatusLine: string; PopupOnError: boolean);
var
  Indx: Integer;
  ErrStatus: string;
begin
  with FLogWin do
  begin
    ErrStatus := '-';
    if (PopupOnError) then
    begin
      if (ETerrs = '') then
        ErrStatus := 'OK'
      else
      begin
        ErrStatus := 'Not OK';
        Show; // Popup Log window when there's an error.
      end;
      // Try to show 'xxx image files read'.
      StatusBar.Panels[1].Text := StatusLine;
    end;

    if (Showing) and
       ((ChkShowAll.Checked) or (ErrStatus <> '-')) then
    begin
      Indx := NextLogId;
      FExecs[Indx] := Format('Execute: %d %s Update/ET Direct status: %s', [ExecNum, TimeToStr(now), ErrStatus]);
      FCmds[Indx] := EtCmds;
      FEtOuts[Indx] := EtOuts;
      FEtErrs[Indx] := EtErrs;

      LBExecs.Items.Assign(Fexecs);
      LBExecs.ItemIndex := Indx;
      LBExecsClick(LBExecs);
    end;
  end;
end;

procedure TFmain.ExecRestEvent_Done(Url, Response: string; Succes: boolean);
var
  Indx: integer;
  ErrStatus: string;
begin
  with FLogWin do
  begin
    if (Showing) then
    begin
      Indx := NextLogId;
      if (Succes) then
        ErrStatus := 'Ok'
      else
        ErrStatus := 'NOT Ok';
      FExecs[Indx] := Format('Rest request: %s Update/ET Direct status: %s', [TimeToStr(now), ErrStatus]);
      FCmds[Indx] := Url;
      FEtOuts[Indx] := Response;

      LBExecs.Items.Assign(Fexecs);
      LBExecs.ItemIndex := Indx;
      LBExecsClick(LBExecs);
    end;
  end;
end;

procedure TFMain.UpdateLocationfromGPScoordinatesClick(Sender: TObject);
var
  CrWait, CrNormal: HCURSOR;
  SelectedFiles: TStringList;
  AFile: string;
begin
  GetMetadata(GetFirstSelectedFilePath, false, false, true, false);
  FGeoSetup.Lat := Foto.GPS.GeoLat;
  FGeoSetup.Lon := Foto.GPS.GeoLon;

  if not (ValidLatLon(FGeoSetup.Lat, FGeoSetup.Lon)) then
  begin
    MessageDlgEx('Selected file has no valid Lat Lon coordinates.', '',
                 TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
    exit;
  end;

  if (FGeoSetup.ShowModal = MROK) then
  begin
    CrWait := LoadCursor(0, IDC_WAIT);
    CrNormal := SetCursor(CrWait);
    SelectedFiles := TStringList.Create;
    try
      SelectedFiles.Text := GetSelectedFiles(true);   // Need full pathname
      for AFile in SelectedFiles do
      begin
        StatusBar.Panels[1].Text := AFile;
        StatusBar.Update;
        FillLocationInImage(AFile);
      end;
    finally
      SelectedFiles.Free;
      RefreshSelected(Sender);
      SetCursor(CrNormal);
    end;
  end;
  StatusBar.Panels[1].Text := '';
end;

procedure TFMain.UpdateStatusBar_FilesShown;
var
  I: smallint;
begin
  I := ShellList.Items.Count;
  StatusBar.Panels[0].Text := 'Files: ' + IntToStr(I);
end;

procedure TFMain.EdgeBrowser1CreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
var Url: string;
begin
  if (AResult <> S_OK) then
  begin
    Url := '';
    if not CheckWebView2Loaded then
    begin
      if (MessageDlgEx('The WebView2Loader.dll could not be loaded.' + #10 +
                       'Show Online help?',
                       '', TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = ID_YES) then
        Url := '/#m_edge_dll';
    end
    else
    begin
      if (MessageDlgEx('Unable to start Edge browser.' +#10 +
                       'Show Online help?',
                       '', TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = ID_YES) then
        Url := '/#m_edge_runtime';
    end;
    if (Url <> '') then
      ShellExecute(0, 'Open', PWideChar(ONLINE_DOC_URL + Url), '', '', SW_SHOWNORMAL);
  end;

end;

// Retain zoomfactor
procedure TFMain.EdgeBrowser1NavigationStarting(Sender: TCustomEdgeBrowser; Args: TNavigationStartingEventArgs);
begin
  Sender.ZoomFactor := EdgeZoom;
end;

procedure TFMain.EdgeBrowser1ZoomFactorChanged(Sender: TCustomEdgeBrowser; AZoomFactor: Double);
begin
  EdgeZoom := AZoomFactor;
end;

procedure TFMain.EdgeBrowser1WebMessageReceived(Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
var
  Message: PChar;
  Msg, Parm1, Parm2, Lat, Lon: string;
begin
  Args.ArgsInterface.Get_webMessageAsJson(Message);
  ParseJsonMessage(Message, Msg, Parm1, Parm2);

  if (Msg = OSMGetBounds) then
  begin
    EditMapBounds.Text := Parm1;

    ParseLatLon(Parm2, Lat, Lon);
    AdjustLatLon(Lat, Lon, Coord_Decimals);
    EditMapFind.Text := Lat + ', ' + Lon;

    exit;
  end;

  AdjustLatLon(Parm1, Parm2, Coord_Decimals);
  EditMapFind.Text := Parm1 + ', ' + Parm2;
  if (Msg = OSMCtrlClick) then
  begin
    MapGotoPlace(EdgeBrowser1, EditMapFind.Text, '', OSMCtrlClick, InitialZoom_In);

    exit;
  end;

  if (Msg = OSMGetLocation) then
  begin
    MapGotoPlace(EdgeBrowser1, EditMapFind.Text, '', OSMGetLocation, InitialZoom_Out);

    exit;
  end;

end;

procedure TFMain.EditETcmdNameChange(Sender: TObject);
begin
  if (EditETdirect.Text <> '') and (EditETcmdName.Text <> '') then
  begin
    SpeedBtnETdirectReplace.Enabled := (CBoxETdirect.ItemIndex >= 0);
    SpeedBtnETdirectAdd.Enabled := EditETdirect.Modified;
  end
  else
  begin
    SpeedBtnETdirectReplace.Enabled := false;
    SpeedBtnETdirectAdd.Enabled := false;
  end;
end;

procedure TFMain.EditETdirectChange(Sender: TObject);
begin
  if (EditETdirect.Text <> '') and (EditETcmdName.Text <> '') then
  begin
    SpeedBtnETdirectReplace.Enabled := (CBoxETdirect.ItemIndex >= 0);
    SpeedBtnETdirectAdd.Enabled := EditETcmdName.Modified;
  end
  else
  begin
    SpeedBtnETdirectReplace.Enabled := false;
    SpeedBtnETdirectAdd.Enabled := false;
  end;
end;

procedure TFMain.CmbETDirectModeChange(Sender: TObject);
begin
  GUIsettings.ETdirMode := CmbETDirectMode.ItemIndex;
end;

procedure TFMain.EditETdirectKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  IsRecursive, ETResult: boolean;
  I: smallint;
  ETtx, ETout, ETerr: string;
  ETprm: string;
  SelectedFiles: string;
begin
  if (Key = VK_ESCAPE) and
     (SpeedBtn_ETdirect.Down) then
  begin
    SpeedBtn_ETdirect.Down := not SpeedBtn_ETdirect.Down;
    SpeedBtn_ETdirectClick(Sender);
    exit;
  end;

  ETtx := EditETdirect.Text;
  if (Key = VK_Return) and (length(ETtx) > 1) then
  begin
    IsRecursive := (pos('-r ', ETtx) > 0);
    ETprm := ETtx;
    if IsRecursive then
    begin // init ETcounter:
      ETprm := ETprm + ' "' + ExcludeTrailingPathDelimiter(ShellList.Path) + '"'; // If pathname ends with \, it would be escaping a "
      I := pos('-ext ', ETtx); // ie. '-ext jpg ...'
      if I = 0 then
        ETtx := '*.*'
      else
      begin
        inc(I, 4);
        Delete(ETtx, 1, I);
        ETtx := TrimLeft(ETtx); // ='jpg ...'
        I := pos(' ', ETtx);
        if I > 0 then
          ETtx := LeftStr(ETtx, I - 1);
        ETtx := '*.' + ETtx;
      end;
      SetCounter(CounterETEvent, GetNrOfFiles(ShellList.Path, ETtx, true));
      SelectedFiles := '';
    end
    else
      SelectedFiles := GetSelectedFiles;

    // Call ETDirect or ET_OpenExec
    case CmbETDirectMode.ItemIndex of
      0: ETResult := ET_OpenExec(ArgsFromDirectCmd(ETprm), SelectedFiles, ETout, ETerr);
      1: ETResult := ExecET(ETprm, SelectedFiles, ShellList.Path, ETout, ETerr);
      else
        ETResult := false; // Make compiler happy
    end;

    if not ETResult then
      ShowMessage('ExifTool not executed!?');

    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
end;

procedure TFMain.EditFindMetaKeyPress(Sender: TObject; var Key: Char);
var NewRow: Integer;
begin
  StatusBar.Panels[1].Text := '';
  if (Key = #13) then
  begin
    NewRow := MetadataList.Row;
    while (NewRow < Metadatalist.RowCount -1) do
    begin
      if (MetadataList.Keys[NewRow +1] <> '') and // Dont look in group names
         (ContainsText(MetadataList.Strings[NewRow], TLabeledEdit(Sender).Text)) then
      begin
        MetadataList.Row := NewRow +1;
        Exit;
      end;
      Inc(NewRow);
    end;
    StatusBar.Panels[1].Text := 'No (more) matches found.';
  end;
  MetadataList.Row := 1;
end;

procedure TFMain.EditQuickEnter(Sender: TObject);
begin
  with MetadataList do
  begin
    if Sender = EditQuick then
    begin
      if QuickTags[Row - 1].NoEdit then
        EditQuick.Color := $9090FF
      else
        EditQuick.Color := $BBFFFF;
    end
    else
    begin
      if QuickTags[Row - 1].NoEdit then
        MemoQuick.Color := $9090FF
      else
        MemoQuick.Color := $BBFFFF;
      MemoQuick.SelectAll;
    end;
    StatusBar.Panels[2].Text := QuickTags[Row - 1].Help;
  end;
end;

procedure TFMain.EditQuickExit(Sender: TObject);
begin
  if Sender = EditQuick then
    EditQuick.Color := clWindow
  else
    MemoQuick.Color := clWindow;
  StatusBar.Panels[2].Text := '';
end;

procedure TFMain.EditQuickKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: smallint;
  tx: string;
begin
  i := MetadataList.Row;
  if (Key = VK_Return) and not(QuickTags[i - 1].NoEdit) then
    with MetadataList do
    begin
      if Sender = EditQuick then
        tx := trim(EditQuick.Text) // delete leading and trailing
      else
        tx := trim(MemoQuick.Text);
      Cells[1, i] := tx;
      tx := Keys[i];
      if tx[1] <> '*' then
        Keys[i] := '*' + tx; // mark tag value changed
      if GUIsettings.AutoIncLine and // select next row
        (i < RowCount - 1) then
        Row := i + 1;
      Refresh;
      SetFocus;
      SpeedBtnQuickSave.Enabled := true;
    end;

  if Key = VK_ESCAPE then
    with MetadataList do
    begin
      if Sender = EditQuick then
      begin
        if QuickTags[i - 1].NoEdit then
          EditQuick.Text := ''
        else
        begin
          if RightStr(Keys[i], 1) = #177 then
            EditQuick.Text := '+'
          else
            EditQuick.Text := Cells[1, i];
        end;
      end
      else
      begin
        if QuickTags[i - 1].NoEdit then
          MemoQuick.Text := ''
        else
        begin
          if RightStr(Keys[i], 1) = #177 then
            MemoQuick.Text := '+'
          else
            MemoQuick.Text := Cells[1, i];
        end;
      end;
      SetFocus;
    end;
end;

procedure TFMain.ShowPreview;
var
  Rotate: integer;
  FPath: string;
  ABitMap: TBitmap;
  HBmp: HBITMAP;
  CrWait, CrNormal: HCURSOR;
begin
  RotateImg.Picture.Bitmap := nil;
  if ShellList.SelCount > 0 then
  begin
    CrWait := LoadCursor(0, IDC_WAIT);
    CrNormal := SetCursor(CrWait);
    try
      FPath := ShellList.FilePath;
      Rotate := 0;
      if GUIsettings.AutoRotatePreview then
      begin
        case GetOrientationValue(FPath) of
          0, 1:
            Rotate := 0; // no tag or don't rotate
          3:
            Rotate := 180;
          6:
            Rotate := 90;
          8:
            Rotate := 270;
        end;
      end;

      ABitMap := GetBitmapFromWic(WicPreview(FPath, Rotate, RotateImg.Width, RotateImg.Height));
      if (ABitMap = nil) then
      begin
        if (GetThumbCache(FPath, HBmp, SIIGBF_THUMBNAILONLY, RotateImg.Width, RotateImg.Height) = S_OK) then
        begin
          ABitMap := TBitmap.Create;
          ABitMap.Handle := HBmp;
        end;
      end;
      if (ABitMap <> nil) then
      begin
        ResizeBitmapCanvas(ABitMap, RotateImg.Width, RotateImg.Height, GUIColorWindow);
        RotateImg.Picture.Bitmap := ABitMap;
        ABitMap.Free;
      end;
    finally
      SetCursor(CrNormal);
    end;
  end;
end;

procedure TFMain.AdvPagePreviewResize(Sender: TObject);
begin
  ShowPreview;
end;

procedure TFMain.CBoxETdirectChange(Sender: TObject);
var
  i: smallint;
begin
  i := CBoxETdirect.ItemIndex;
  if i >= 0 then
  begin
    EditETdirect.Text := ETdirectCmd[i];
    EditETdirect.Modified := false;
    EditETcmdName.Text := CBoxETdirect.Text;
    EditETcmdName.Modified := false;
    SpeedBtnETdirectDel.Enabled := true; // Delete
  end
  else
    SpeedBtnETdirectDel.Enabled := false;
  SpeedBtnETdirectReplace.Enabled := false;
  SpeedBtnETdirectAdd.Enabled := false;
  EditETdirect.SetFocus;
end;

procedure TFMain.CBoxFileFilterChange(Sender: TObject);
var
  i: smallint;
begin
  i := CBoxFileFilter.ItemIndex;
  if i >= 0 then
  begin
    SpeedBtnFilterEdit.Enabled := (i <> 0);
    ShellList.Refresh;
    ShellList.SetFocus;
  end;
end;

procedure TFMain.CBoxFileFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_Return then
  begin
    CBoxFileFilter.Text := trim(CBoxFileFilter.Text);
    ShellList.Refresh;
    ShellList.SetFocus;
  end;
end;

procedure TFMain.AlignStatusBar;
begin
  StatusBar.Panels[0].Width := AdvPageBrowse.Width + Splitter1.Width;
  StatusBar.Panels[1].Width := AdvPageFilelist.Width + Splitter2.Width;
end;

procedure TFMain.FormCanResize(Sender: TObject; var NewWidth, NewHeight: integer; var Resize: boolean);
var
  N: integer;
begin
  if (WindowState <> wsMinimized) then
  begin
    N := GUIBorderWidth + AdvPanelBrowse.Width + Splitter1.Width +
                          MinFileListWidth + Splitter2.Width +
                          AdvPageMetadata.Width;
    if (NewWidth < N) then
      NewWidth := N;
  end;
  AlignStatusBar;
end;

procedure TFMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  EdgeBrowser1.CloseBrowserProcess; // Close Edge. Else we can not remove the tempdir.
  EdgeBrowser1.CloseWebView;
  SaveGUIini;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  // AdvPageFilelist.Constraints.MinWidth only used at design time. Form does not align well.
  // We check for MinFileListWidth in code.
  MinFileListWidth := AdvPageFilelist.Constraints.MinWidth;
  AdvPageFilelist.Constraints.MinWidth := 0;

  ReadGUIini;

  // Create Bread Crumb
  BreadcrumbBar := TDirBreadcrumbBar.Create(Self);
  BreadcrumbBar.Parent := PnlBreadCrumb;
  BreadcrumbBar.Font := PnlBreadCrumb.Font;
  BreadcrumbBar.Align := alClient;
  BreadcrumbBar.OnChange := BreadCrumbClick;
  BreadcrumbBar.OnHome := BreadCrumbHome;

  // Create Bar Chart series
  ETBarSeriesFocal := TBarSeries.Create(ETChart);
  ETBarSeriesFocal.Marks.Visible := false;

  ETBarSeriesFnum := TBarSeries.Create(ETChart);
  ETBarSeriesFnum.Marks.Visible := false;

  ETBarSeriesIso := TBarSeries.Create(ETChart);
  ETBarSeriesIso.Marks.Visible := false;

  // Set Style
  TStyleManager.TrySetStyle(GUIsettings.GuiStyle, false);
  SetGuiStyle;

  // EdgeBrowser
  EdgeBrowser1.UserDataFolder := GetEdgeUserData;

  // Set properties of ShellTree in code.
  ShellTree.OnBeforeContextMenu := ShellTreeBeforeContext;
  ShellTree.OnAfterContextMenu := ShellTreeAfterContext;

  // Set properties of Shelllist in code.
  ShellList.OnPopulateBeforeEvent := ShellListBeforePopulate;
  ShellList.OnEnumColumnsAfterEvent := ShellListAfterEnumColumns;
  ShellList.OnPathChange := ShellListPathChange;
  ShellList.OnItemsLoaded := ShellListItemsLoaded;
  ShellList.OnOwnerDataFetchEvent := ShellListOwnerDataFetch;
  ShellList.OnColumnResized := ShellListColumnResized;
  ShellList.OnThumbGenerate := ShellistThumbGenerate;
  ShellList.OnThumbError := ShellistThumbError;
  ShellList.OnMouseWheel := ShellListMouseWheel;
  // Enable Column sorting if Sorted = true. Disables Sorted.
  ShellList.ColumnSorted := ShellList.Sorted;

  CBoxFileFilter.Text := SHOWALL;
  ExifTool.ExecETEvent := ExecETEvent_Done;
  Geomap.ExecRestEvent := ExecRestEvent_Done;
end;

procedure TFMain.ShellListMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := false;
  if (ssCtrl in Shift) then
    ShellList.SetIconSpacing(WheelDelta, 0);
  if (ssAlt in shift) then
    ShellList.SetIconSpacing(0, 0);
end;

// ---------------Drag_Drop procs --------------------
procedure TFMain.ImageDrop(var Msg: TWMDROPFILES);
var
  NumFiles: integer;
  Buffer: array of Char;
  PBuffer: PChar absolute Buffer;
  LBuffer: integer;
  Fname: string;
  AnItem: TListItem;
begin
  NumFiles := DragQueryFile(Msg.Drop, UINT(-1), nil, 0);
  if NumFiles > 1 then
    ShowMessage('Drop only one file at a time!')
  else
  begin
    LBuffer := DragQueryFile(Msg.Drop, 0, nil, 0) +1;
    SetLength(Buffer, LBuffer);
    DragQueryFile(Msg.Drop, 0, PBuffer, LBuffer);
    ShellTree.Path := ExtractFileDir(PBuffer);
    Fname := ExtractFileName(PBuffer);
    ShellList.ItemIndex := -1;
    for AnItem in ShellList.Items do
    begin
      if ShellList.FileName(AnItem.Index) = Fname then
      begin
        ShellList.ItemIndex := AnItem.Index;
        break;
      end;
    end;
    ShowPreview;
    ShowMetadata;
    Application.BringToFront;
  end;
end;

// ------------- ^ Enf of Drag_Drop procs ^-------------------------------

procedure TFMain.FormShow(Sender: TObject);
var
  AnItem: TListItem;
  Param: string;
  Lat, Lon: string;
  I: integer;
  PathFromParm: boolean;
begin
  AdvPanelETdirect.Height := MulDiv(32, Screen.PixelsPerInch, GetDesignDpi);
  AdvPanelMetaBottom.Height := MulDiv(32, Screen.PixelsPerInch, GetDesignDpi);
  MetadataList.DefaultRowHeight := MulDiv(19, Screen.PixelsPerInch, GetDesignDpi);
//
  // This must be in OnShow event -for OnCanResize event (probably bug in XE2):
  GUIBorderWidth := Width - ClientWidth;
  GUIBorderHeight := Height - ClientHeight;

  AdvPageMetadata.ActivePage := AdvTabMetadata;
  AdvPageFilelist.ActivePage := AdvTabFilelist;

  UpdateLocationfromGPScoordinates.Enabled := false;
  AdvTabOSMMap.Enabled := false;
  if GUIsettings.EnableGMap then
  begin
    try
      UpdateLocationfromGPScoordinates.Enabled := true;
      ParseLatLon(GUIsettings.DefGMapHome, Lat, Lon);
      OSMMapInit(EdgeBrowser1, Lat, Lon, OSMHome, InitialZoom_Out);
      AdvTabOSMMap.Enabled := true;
    except
      on E:Exception do
        MessageDlgEx(E.Message, 'Error positioning Home', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK]);
    end;
  end;

  // Init Chart
  AdvRadioGroup2Click(Sender);

  if not SpeedBtnDetails.Down then
  begin
    ShellList.ViewStyle := vsIcon;
    CBoxDetails.Enabled := false;
  end;

  I := CBoxDetails.Items.Count - 1;
  SpeedBtnColumnEdit.Enabled := (CBoxDetails.ItemIndex = I);
  WrkIniDir := GetAppPath;
  if GUIsettings.UseExitDetails then
    CBoxDetailsChange(Sender);

  DontSaveIni := FindCmdLineSwitch('DontSaveIni', true);

  // The shellList is initally disabled. Now enable and refresh
  PathFromParm := false;
  ShellListSetFolders;
  ShellList.Enabled := true;

  // GUI started as "Send to" or "Open with":
  if ParamCount > 0 then
  begin
    Param := ParamStr(1);
    if DirectoryExists(Param) then
    begin
      PathFromParm := true;
      ShellTree.Path := Param; // directory only
    end
    else
    begin
      if FileExists(Param) then
      begin // file specified
        PathFromParm := true;
        ShellTree.Path := ExtractFileDir(Param);
        Param := ExtractFileName(Param);
        ShellList.ItemIndex := -1;
        for AnItem in ShellList.Items do
        begin
          if SameText(ShellList.FileName(AnItem.Index), Param) then
          begin
            ShellList.ItemIndex := AnItem.Index;
            break;
          end;
        end;
        if (ShellList.ItemIndex <> -1) then
        begin
          ShellList.SetFocus;
          ShellListClick(Sender);
        end
        else
          ShellTree.SetFocus;
      end;
    end;
  end;

  // If Path was not set from parm, use the setting
  if (PathFromParm = false) and
     ValidDir(GUIsettings.InitialDir) then
  begin
    ShellTree.Path := GUIsettings.InitialDir;
    ShellList.SetFocus;
  end;

  // Scroll in view. Select initial
  if (ShellTree.Selected <> nil) then
    ShellTree.Selected.MakeVisible;

  // --------------------------
  DragAcceptFiles(Self.Handle, true);
end;

procedure TFMain.RotateImgResize(Sender: TObject);
begin
  ShowPreview;
end;

procedure TFMain.BreadCrumbClick(Sender: TObject);
begin
  if FrmStyle.Showing then
    exit;
  ShellTree.Path := BreadcrumbBar.Directory;
  if (ShellTree.Selected <> nil) then
    ShellTree.Selected.MakeVisible;
end;

procedure TFMain.BreadCrumbHome(Sender: TObject);
begin
  if FrmStyle.Showing then
    exit;

  // Setting ObjectTypes will always call RootChanged, even if the value has not changed.
  ShellTree.ObjectTypes := ShellTree.ObjectTypes;
  ShellTree.Refresh(ShellTree.TopItem);
end;

procedure TFMain.ShellListAddItem(Sender: TObject; AFolder: TShellFolder; var CanAdd: boolean);
var
  FolderName: string;
  FilterItem, Filter: string;
  FilterMatches: boolean;
begin
  CanAdd := TShellListView(Sender).Enabled and not FrmStyle.Showing and ValidFile(AFolder);
  FolderName := ExtractFileName(AFolder.PathName);
  if (CBoxFileFilter.Text <> SHOWALL) then
  begin
    Filter := CBoxFileFilter.Text;
    FilterMatches := Afolder.IsFolder;
    while (FilterMatches = false) and (Filter <> '') do
    begin
      FilterItem := NextField(Filter, ';');
      FilterMatches := MatchesMask(FolderName, FilterItem);
    end;
    CanAdd := CanAdd and FilterMatches;
  end;
end;

procedure TFMain.ShellListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  // This event isn't executed when/after deleting files! -after deletion,
  // as soon some remained file is clicked, event is execuded.
  UpdateStatusBar_FilesShown;
end;

procedure TFMain.ShellListClick(Sender: TObject);
var
  I: integer;
begin
  ShowPreview;
  ShowMetadata;

  if (ETWorkDir = '') then
    exit;

  I := ShellList.SelCount;
  MExportImport.Enabled := (I > 0);
  MModify.Enabled := (I > 0);
  MVarious.Enabled := (I > 0);
  SpeedBtnQuickSave.Enabled := false;
end;

procedure TFMain.ShellListColumnClick(Sender: TObject; Column: TListColumn);
begin
  ShellList.ColumnClick(Column);
  ShowMetadata;
  ShowPreview;
end;

procedure TFMain.ShellListColumnResized(Sender: TObject);
var
  ColIndex: integer;
begin
  ColIndex := TListColumn(Sender).Index;
  if (ColIndex = 0) then // Name field
    FListStdColWidth[ColIndex] := TListColumn(Sender).Width
  else
  begin
    case CBoxDetails.ItemIndex of
      0:
        FListStdColWidth[ColIndex] := TListColumn(Sender).Width;
      1:
        FListColDef1[ColIndex - 1].Width := TListColumn(Sender).Width;
      2:
        FListColDef2[ColIndex - 1].Width := TListColumn(Sender).Width;
      3:
        FListColDef3[ColIndex - 1].Width := TListColumn(Sender).Width;
      4:
        FListColUsr[ColIndex - 1].Width := TListColumn(Sender).Width;
    end;
  end;
end;

procedure TFMain.ShellListBeforePopulate(Sender: TObject; var DoDefault: boolean);
begin
  DoDefault := (ShellList.ViewStyle <> vsReport) or (CBoxDetails.ItemIndex = 0);
end;

procedure TFMain.ShellListAfterEnumColumns(Sender: TObject);

  procedure AdjustColumns(ColumnDefs: array of smallint);
  var
    i, j: integer;
  begin
    j := Min(High(ColumnDefs), ShellList.Columns.Count - 1);
    for i := 0 to j do
      ShellList.Columns[i].Width := ColumnDefs[i];
  end;

  procedure AddColumn(const ACaption: string; AWidth: integer; const AAlignment: smallint = 0);
  begin
    with TShellListView(Sender).Columns.Add do
    begin
      Caption := ACaption;
      Width := AWidth;
      if (AAlignment > 0) then
        Alignment := taRightJustify;
    end;
  end;

  procedure AddColumns(ColumnDefs: array of FListColDefRec); overload;
  var
    i: integer;
  begin
    with ShellList do
    begin
      Columns.Clear;
      AddColumn(SShellDefaultNameStr, FListStdColWidth[0]); // Name field
      for i := 0 to High(ColumnDefs) do
        AddColumn(ColumnDefs[i].Caption, ColumnDefs[i].Width, ColumnDefs[i].AlignR);
    end;
  end;

  procedure AddColumns(ColumnDefs: array of FListColUsrRec); overload;
  var
    DefRecords: array of FListColDefRec;
    i: integer;
  begin
    SetLength(DefRecords, length(ColumnDefs));
    for i := 0 to length(DefRecords) - 1 do
      DefRecords[i] := FListColDefRec.Create(ColumnDefs[i]);

    AddColumns(DefRecords);
  end;

begin

  case CBoxDetails.ItemIndex of
    0:
      AdjustColumns(FListStdColWidth);
    1:
      AddColumns(FListColDef1);
    2:
      AddColumns(FListColDef2);
    3:
      AddColumns(FListColDef3);
    4:
      AddColumns(FListColUsr);
  end;

end;

// Path is about to change. Need to restart ExiftTool and setup the menu's
procedure TFMain.ShellListPathChange(Sender: TObject);
var
  ET_Active: boolean;
begin
  if FrmStyle.Showing then
    exit;

  if PnlBreadCrumb.Visible then
  begin
    BreadcrumbBar.Home := ShellTree.Items[0].Text;
    BreadcrumbBar.Directory := TShellListView(Sender).Path;
  end;

  // Start ExifTool in this directory
  ET_Active := ET_StayOpen(TShellListView(Sender).Path);

  // Dis/Enable menus
  EnableMenus(ET_Active);
end;

// Items are loaded and possibly sorted. Select the first
procedure TFMain.ShellListItemsLoaded(Sender: TObject);
var
  AShellList: TShellListView;
begin
  AShellList := TShellListView(Sender);

  // Select 1st Item rightaway
  if (AShellList.Items.Count > 0) then
  begin
    AShellList.Items[0].Selected := true;
    if (Assigned(AShellList.OnClick)) then
      AShellList.OnClick(Sender);
  end;
end;

procedure TFMain.ShellListOwnerDataFetch(Sender: TObject; Item: TListItem; Request: TItemRequest; AFolder: TShellFolder);
var
  AShellList: TShellListView;
  ETcmd, Tx, ADetail: String;
  Indx: integer;
  Details: TStrings;
begin
  if (Item.Index < 0) then
    exit;

  AShellList := TShellListView(Sender);
  if (AShellList.ViewStyle <> vsReport) then
    exit;

  AFolder := AShellList.Folders[Item.Index];
  if not Assigned(AFolder) then
    exit;

  // The Item.Caption and Item.ImageIndex (for small icons) should always be set
  if (irText in Request) then
    Item.Caption := AFolder.DisplayName;
  if (irImage in Request) then
    Item.ImageIndex := AFolder.ImageIndex(AShellList.ViewStyle = vsIcon);

  Details := AFolder.DetailStrings;
  if (Details.Count = 0) and
     (Afolder.IsFolder = false) then
  begin
    with Foto do
    begin
      case CBoxDetails.ItemIndex of
        1:
          begin
            GetMetadata(AFolder.PathName, false, false, false, false);

            Tx := ExifIFD.ExposureTime;
            Tx.PadLeft(7);
            Details.Add(Tx);
            Tx := ExifIFD.FNumber;
            Tx.PadLeft(4);
            Details.Add(Tx);
            Tx := ExifIFD.ISO;
            Tx.PadLeft(5);
            Details.Add(Tx);
            Tx := ExifIFD.ExposureBias;
            Tx.PadLeft(4);
            Details.Add(Tx);
            Tx := ExifIFD.FocalLength;
            Tx.PadLeft(6);
            Details.Add(Tx);
            if (ExifIFD.Flash and $FF00) <> 0 then
            begin
              if (ExifIFD.Flash and 1) = 1 then
                Details.Add('Yes')
              else
                Details.Add('No');
            end
            else
              Details.Add('');
            Details.Add(ExifIFD.ExposureProgram);
            if IFD0.Orientation > 0 then
            begin
              if (IFD0.Orientation and 1) = 1 then
                Details.Add('Hor.')
              else
                Details.Add('Ver.');
            end
            else
              Details.Add('');
          end;
        2:
          begin
            GetMetadata(AFolder.PathName, true, false, true, false);
            Details.Add(ExifIFD.DateTimeOriginal);
            if GPS.Latitude <> '' then
              Details.Add('Yes')
            else
              Details.Add('No');
            Details.Add(Xmp.CountryShown);
            Details.Add(Xmp.ProvinceShown);
            Details.Add(Xmp.CityShown);
            Details.Add(Xmp.LocationShown);
          end;
        3:
          begin
            GetMetadata(AFolder.PathName, true, false, false, false);
            Details.Add(IFD0.Artist);
            Details.Add(Xmp.Rating);
            Details.Add(Xmp.PhotoType);
            Details.Add(Xmp.Event);
            Details.Add(Xmp.PersonInImage);
          end;
        4:
          begin
            ETcmd := '-s3' + CRLF + '-f';
            for Indx := 0 to High(FListColUsr) do
              ETcmd := ETcmd + CRLF + FListColUsr[Indx].Command;
            ET_OpenExec(ETcmd, GetSelectedFile(ShellList.FileName(Item.Index)), Details, False); // Dont care about errors
          end;
      end;
    end;
  end;
  for ADetail in Details do
    Item.SubItems.Append(ADetail);
end;

procedure TFMain.ShellListDeletion(Sender: TObject; Item: TListItem);
begin // event is executed for each deleted file -so make it fast!
  RotateImg.Picture.Bitmap.Handle := 0;
  MetadataList.Strings.Clear;
end;

procedure TFMain.ShellListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) or (Key = VK_DOWN) then // Up-Down arrow
    ShellListClick(Sender);
  if (Key = Ord('A')) and (ssCTRL in Shift) then // Ctrl+A
    ShellList.SelectAll;
  if (Key = Ord('C')) and (ssCTRL in Shift) then // Ctrl+C
    ShellList.FileNamesToClipboard;
  if (Key = Ord('X')) and (ssCTRL in Shift) then // Ctrl+X
    ShellList.FileNamesToClipboard(True);
  if (Key = Ord('V')) and (ssCTRL in Shift) then // Ctrl+V
    ShellList.PasteFilesFromClipboard;
  if (Key = VK_PRIOR) or (Key = VK_NEXT) then // PageUp/Down
    ShellListClick(Sender);

  if (Key = VK_ADD) and (ssCtrl in Shift) then
    ShellList.SetIconSpacing(1, 0);
  if (Key = VK_SUBTRACT) and (ssCtrl in Shift) then
    ShellList.SetIconSpacing(-1, 0);
  if ((Key = Ord('0')) or (Key = VK_NUMPAD0)) and (ssCtrl in Shift) then
    ShellList.SetIconSpacing(0, 0);
end;

procedure TFMain.ShellListSetFolders;
var Value: TShellObjectTypes;
begin
  Value := ShellList.ObjectTypes;
  if (GUIsettings.ShowFolders) then
    include(Value, TshellObjectType.otFolders)
  else
    exclude(Value, TshellObjectType.otFolders);
  if (Value <> ShellList.ObjectTypes) then
    ShellList.ObjectTypes := Value;
  PnlBreadCrumb.Visible := GUIsettings.ShowFolders;
end;

procedure TFMain.EnableMenus(Enable: boolean);
var
  i: integer;
begin
  AdvPageMetadata.Enabled := Enable;
  AdvPanelETdirect.Enabled := Enable;
  AdvPanelFileTop.Enabled := Enable;
  MOptions.Enabled := Enable;
  MExportImport.Enabled := Enable;
  MModify.Enabled := Enable;
  MVarious.Enabled := Enable;
  for i := 0 to MProgram.Count - 1 do
  begin // dont disable About, Exit or Preferences menu
    if (MProgram.Items[i].Tag <> 0) then
      continue;
    MProgram.Items[i].Enabled := Enable;
  end;

  if not Enable then
    if (MessageDlgEx('ERROR: ExifTool could not be started!' + #10 +  #10 +
        'To resolve this you can:' + #10 +
        '- Install Exiftool in: ' + GetAppPath + #10 +
        '- Install Exiftool in a directory in the Windows search sequence.' + #10 + #9 +
        'For example in a directory specified in the PATH environment variable.' + #10 + #9 +
        'For more info see the documentation on the CreateProcess function.' + #10 +
        '- Locate Exiftool.exe and specify the location in Preferences/Other.' + #10 + #10 +
        'Metadata operations disabled.' + #10 + #10 +
        'Note: This error can also occur if you browse to an invalid folder. A DVD/CD drive without media for example.' + #10 + #10 +
        'Show Online help?', '',
        TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = ID_YES) then
      ShellExecute(0, 'Open', PWideChar(ONLINE_DOC_URL + '/#m_reqs_exiftool'), '', '', SW_SHOWNORMAL);

end;

procedure TFMain.ShellTreeChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
begin
  RotateImg.Picture.Bitmap := nil;
  if Assigned(ETBarSeriesFocal) then
    ETBarSeriesFocal.Clear;
  if Assigned(ETBarSeriesFnum) then
    ETBarSeriesFnum.Clear;
  if Assigned(ETBarSeriesIso) then
    ETBarSeriesIso.Clear;
end;

procedure TFMain.RefreshSelected(Sender: TObject);
var AnItem: TListItem;
begin
  for AnItem in ShellList.Items do
  begin
    if AnItem.Selected then
    begin
      ShellList.Folders[AnItem.Index].DetailStrings.Clear;
      AnItem.Update;
    end;
  end;
end;

// Close Exiftool before context menu. Delete directory fails
procedure TFMain.ShellTreeBeforeContext(Sender: TObject);
begin
  ET_OpenExit;
end;

// Restart Exiftool when context menu done.
procedure TFMain.ShellTreeAfterContext(Sender: TObject);
begin
  if (ValidDir(ShellList.Path)) then
    ET_StayOpen(ShellList.Path);
end;

// =========================== Show Metadata ====================================
procedure TFMain.ShowMetadata;
var
  E, N: integer;
  ETcmd, Item, Tx: string;
  ETResult: TStringList;
begin
  MetadataList.Tag := -1; // Reset hint row
  Item := GetSelectedFile(ShellList.FileName);
  if (Item = '') then
  begin
    Caption := 'ExifToolGUI';
    with MetadataList do
    begin
      Row := 1;
      Strings.Clear;
    end;
    EditQuick.Text := '';
    MemoQuick.Text := '';
    exit;
  end;

  ETResult := TStringList.Create;
  try
    Caption := 'ExifToolGUI - ' + Item;
    if SpeedBtnQuick.Down then
    begin
      N := Length(QuickTags) - 1;
      ETcmd := '-s3' + CRLF + '-f';

      for E := 0 to N do
      begin
        tx := QuickTags[E].Command;
        if UpperCase(LeftStr(tx, Length(GUI_SEP))) = GUI_SEP then
          Tx := GUI_SEP;
        ETcmd := ETcmd + CRLF + Tx;
      end;
      ET_OpenExec(ETcmd, Item, ETResult, false);
      N := Min(N, ETResult.Count - 1);
      with MetadataList do
      begin
        Strings.Clear;
        if (ETResult.Count < Length(QuickTags)) and
           (ETResult.Count > 0) then
          Strings.Append(Format('=Warning. Only %d results returned from %d workspace commands.',
                                [ETResult.Count, Length(QuickTags)]));
        for E := 0 to N do
        begin
          Tx := QuickTags[E].Command;
          if UpperCase(LeftStr(tx, length(GUI_SEP))) = GUI_SEP then
            Tx := '=' + QuickTags[E].Caption
          else
          begin
            Tx := QuickTags[E].Caption;
            if RightStr(Tx, 1) = '?' then
            begin
              if ETResult[E] = '-' then
                Tx := Tx + '=*NO*'
              else
                Tx := Tx + '=*YES*';
            end
            else
              Tx := QuickTags[E].Caption + '=' + ETResult[E];
          end;
          Strings.Append(Tx);
        end;
      end;
    end
    else
    begin
      if MGroup_g4.Checked then
        ETcmd := '-g4' + CRLF
      else
        ETcmd := '-g1' + CRLF;
      if not MNotDuplicated.Checked then
        ETcmd := ETcmd + '-a' + CRLF;
      if MShowSorted.Checked then
        ETcmd := ETcmd + '-sort' + CRLF;
      if MShowHexID.Checked then
        ETcmd := ETcmd + '-H' + CRLF;
      if ET_Options.ETLangDef = '' then
        ETcmd := ETcmd + '-S' + CRLF;
      if SpeedBtnExif.Down then
        ETcmd := ETcmd + '-Exif:All';
      if SpeedBtnIptc.Down then
        ETcmd := ETcmd + '-Iptc:All';
      if SpeedBtnXmp.Down then
        ETcmd := ETcmd + '-Xmp:All';
      if SpeedBtnMaker.Down then
        ETcmd := ETcmd + '-Makernotes:All' + CRLF + '-CanonVRD:All';
      if SpeedBtnALL.Down then
      begin
        ETcmd := ETcmd + '-All:All'; // +CRLF+'-e';
        if not MShowComposite.Checked then
          ETcmd := ETcmd + CRLF + '-e';
      end;

      if SpeedBtnCustom.Down then
      begin
        if (Trim(CustomViewTags) = '') then
        begin
          // Show only message, no data.
          ETcmd := ETcmd + '-f' + CRLF + EmptyCustomview;
          Item := '';
        end
        else
        begin
          ETcmd := ETcmd + '-f' + CRLF + CustomViewTags;
          E := Length(ETcmd);
          SetLength(ETcmd, E - 1); // remove last space char
          ETcmd := StringReplace(ETcmd, ' ', CRLF, [rfReplaceAll]);
        end;
      end;

      ET_OpenExec(ETcmd, Item, ETResult, false);
      E := 0;
      if ETResult.Count = 0 then
      begin
        ETResult.Append('=ExifTool executed');
        ETResult.Append('=No data');
      end
      else
      begin
        while E < ETResult.Count do
        begin
          ETResult[E] := StringReplace(ETResult[E], ': ', '=', []);
          inc(E);
        end;
      end;

      with MetadataList do
      begin
        E := Row;
        Row := 1;
        Strings.Clear;
        Strings.AddStrings(ETResult);
        if RowCount > E then
          Row := E
        else
          Row := RowCount - 1;
      end;
    end;
  finally
    ETResult.Free;
  end;
end;

// ==============================================================================
procedure TFMain.Spb_ForwardClick(Sender: TObject);
begin
  EdgeBrowser1.GoForward;
end;

procedure TFMain.SpeedBtn_GetLocClick(Sender: TObject);
begin
  MapGetLocation(EdgeBrowser1);
end;

procedure TFMain.Spb_GoBackClick(Sender: TObject);
begin
  EdgeBrowser1.GoBack;
end;

procedure TFMain.SpeedBtnChartRefreshClick(Sender: TObject);
var
  Ext: string;
  I: integer;
  CrWait, CrNormal: HCURSOR;
begin
  for I := Low(ChartFLength) to High(ChartFLength) do
    ChartFLength[I] := 0;
  for I := Low(ChartFNumber) to High(ChartFNumber) do
    ChartFNumber[I] := 0;
  for I := Low(ChartISO) to High(ChartISO) do
    ChartISO[I] := 0;
  Ext := '*.*';
  if AdvRadioGroup1.ItemIndex > 0 then
    Ext := '*.' + AdvRadioGroup1.Items[AdvRadioGroup1.ItemIndex];
  ETBarSeriesFocal.Clear;
  ETBarSeriesFnum.Clear;
  ETBarSeriesIso.Clear;

  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    ChartFindFiles(ShellList.Path, Ext, AdvCheckBox_Subfolders.Checked);
  finally
    SetCursor(CrNormal);
  end;

  ChartMaxFLength := 0;
  for I := Low(ChartFLength) to High(ChartFLength) do
  begin
    if ChartFLength[I] > 0 then
    begin
      if ChartFLength[I] > ChartMaxFLength then
        ChartMaxFLength := ChartFLength[I];
      Ext := IntToStr(I);
      if I < 100 then
        Insert('.', Ext, length(Ext)) // 58->5.8
      else
        SetLength(Ext, length(Ext) - 1);
      ETBarSeriesFocal.AddBar(ChartFLength[I], Ext, GUIsettings.CLFocal);
    end;
  end;
  ChartMaxFLength := Round(ChartMaxFLength * 1.1);

  ChartMaxFNumber := 0;
  for I := Low(ChartFNumber) to High(ChartFNumber) do
  begin
    if ChartFNumber[I] > 0 then
    begin
      if ChartFNumber[I] > ChartMaxFNumber then
        ChartMaxFNumber := ChartFNumber[I];
      Ext := IntToStr(I);
      Insert('.', Ext, length(Ext)); // 40->4.0
      ETBarSeriesFnum.AddBar(ChartFNumber[I], Ext, GUIsettings.CLFNumber);
    end;
  end;
  ChartMaxFNumber := Round(ChartMaxFNumber * 1.1);

  ChartMaxISO := 0;
  for I := Low(ChartISO) to High(ChartISO) do
  begin
    if ChartISO[I] > 0 then
    begin
      if ChartISO[I] > ChartMaxISO then
        ChartMaxISO := ChartISO[I];
      Ext := IntToStr(I) + '0'; // 80->800
      ETBarSeriesIso.AddBar(ChartISO[I], Ext, GUIsettings.CLISO);
    end;
  end;
  ChartMaxISO := Round(ChartMaxISO * 1.1);

  AdvRadioGroup2Click(Sender);
end;

procedure TFMain.SpeedBtnDetailsClick(Sender: TObject);
var
  SavedPath: string;
begin
  with ShellList do
  begin
    SavedPath := ShellTreeView.Path;
    Enabled := false;
    if SpeedBtnDetails.Down then
      ViewStyle := vsReport
    else
      ViewStyle := vsIcon;
    Enabled := true;
    ShellTreeView.Path := SavedPath;
  end;
  ShowMetadata;
  ShowPreview;
  CBoxDetails.Enabled := SpeedBtnDetails.Down;
end;

procedure TFMain.SpeedBtnExifClick(Sender: TObject);
begin
  AdvPanelMetaBottom.Visible := SpeedBtnQuick.Down;
  SpeedBtnQuickSave.Enabled := false;
  ShowMetadata;
end;

procedure TFMain.SpeedBtnLargeClick(Sender: TObject);
var
  I, F: integer;
begin
  I := Screen.PixelsPerInch;
  F := ShellList.ItemIndex;
  if SpeedBtnLarge.Down then
  begin
    MemoQuick.Clear;
    MemoQuick.Text := EditQuick.Text;
    EditQuick.Visible := false;
    AdvPanelMetaBottom.Height := MulDiv(105, I, GetDesignDpi);
    if F <> -1 then
      MemoQuick.SetFocus;
  end
  else
  begin
    EditQuick.Text := MemoQuick.Text;
    AdvPanelMetaBottom.Height := MulDiv(32, I, GetDesignDpi);
    EditQuick.Visible := true;
    if F <> -1 then
      EditQuick.SetFocus;
  end;
end;

procedure TFMain.SpeedBtn_ETclearClick(Sender: TObject);
begin
  CBoxETdirect.ItemIndex := -1;
  CBoxETdirect.Repaint;
  CBoxETdirectChange(Sender);
end;

procedure TFMain.SpeedBtn_ETdirectClick(Sender: TObject);
var
  I, H: smallint;
begin
  I := Screen.PixelsPerInch;
  if SpeedBtn_ETdirect.Down then
  begin
    if SpeedBtn_ETedit.Down then
      H := 184 // min 181
    else
      H := 105;
    AdvPanelETdirect.Height := MulDiv(H, I, GetDesignDpi);
    EditETdirect.SetFocus;
  end
  else
  begin
    AdvPanelETdirect.Height := MulDiv(32, I, GetDesignDpi);
    ShellList.SetFocus;
  end;
end;

procedure TFMain.SpeedBtn_ETdSetDefClick(Sender: TObject);
begin
  GUIsettings.ETdirDefCmd := CBoxETdirect.ItemIndex;
end;

procedure TFMain.SpeedBtn_ETeditClick(Sender: TObject);
var
  H: smallint;
begin
  if SpeedBtn_ETedit.Down then
    H := 181
  else
    H := 105;
  AdvPanelETdirect.Height := MulDiv(H, Screen.PixelsPerInch, GetDesignDpi);
end;

procedure TFMain.SpeedBtn_GeotagClick(Sender: TObject);
begin
  ParseLatLon(EditMapFind.Text, FGeotagFiles.Lat, FGeotagFiles.Lon);
  if not (ValidLatLon(FGeotagFiles.Lat, FGeotagFiles.Lon)) then
  begin
    MessageDlgEx('No valid Lat Lon coordinates selected.', '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
    exit;
  end;

  if ShellList.SelectedFolder = nil then
  begin
    MessageDlgEx('No files selected.', '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
    exit;
  end;

  if (Geosettings.ReverseGeoCodeDialog = false) then
  begin
    FGeotagFiles.FillPreview;
    FGeotagFiles.Execute;
  end
  else
    FGeotagFiles.ShowModal;
  RefreshSelected(Sender);
  ShowMetadata;
  ShowPreview;
end;

procedure TFMain.SpeedBtn_MapHomeClick(Sender: TObject);
begin
  MapGotoPlace(EdgeBrowser1, GUIsettings.DefGMapHome, '', OSMHome, InitialZoom_Out);
end;

procedure TFMain.SpeedBtn_MapSetHomeClick(Sender: TObject);
begin
  GUIsettings.DefGMapHome := EditMapFind.Text;
end;

procedure TFMain.SpeedBtn_ShowOnMapClick(Sender: TObject);
var
  ETcmd: string;
  ETouts, ETerrs: string;
begin
  if ShellList.SelectedFolder <> nil then
  begin
    ETcmd := '-s3' + CRLF + '-f' + CRLF + '-n' + CRLF + '-q';
    ETcmd := ETcmd + CRLF + '-Filename';
    ETcmd := ETcmd + CRLF + '-GPS:GpsLatitude' + CRLF + '-GPS:GpsLatitudeRef';
    ETcmd := ETcmd + CRLF + '-GPS:GpsLongitude' + CRLF + '-GPS:GpsLongitudeRef';
    ET_OpenExec(ETcmd, GetSelectedFiles, ETouts, ETerrs, False);
    ShowImagesOnMap(EdgeBrowser1, ShellList.Path, ETouts);
  end
  else
    ShowMessage('No file selected.');
end;

procedure TFMain.Splitter1CanResize(Sender: TObject; var NewSize: integer; var Accept: boolean);
begin
  Accept := ((Splitter2.Left - Splitter2.Width - Splitter1.Width - NewSize) > MinFileListWidth);
end;

procedure TFMain.Splitter1Moved(Sender: TObject);
begin
  AlignStatusBar;
end;

procedure TFMain.Splitter2CanResize(Sender: TObject; var NewSize: integer; var Accept: boolean);
begin
  Accept := ((ClientWidth - Splitter1.Left - Splitter1.Width - Splitter2.Width - NewSize) > MinFileListWidth);
end;

procedure TFMain.Splitter2Moved(Sender: TObject);
begin
  AlignStatusBar;
end;

procedure TFMain.SetGuiStyle;
var
  AStyleService: TCustomStyleServices;
begin
  GUIColorWindow := clBlack;
  AStyleService := TStyleManager.Style[GUIsettings.GuiStyle];
  if Assigned(AStyleService) then
    GUIColorWindow := AStyleService.GetStyleColor(scWindow);

  BreadcrumbBar.Style := GUIsettings.GuiStyle;
  BreadcrumbBar.DesignDPI := GetDesignDpi;
  BreadcrumbBar.ScreenDPI := Screen.PixelsPerInch;
end;

procedure TFMain.ShellistThumbError(Sender: TObject; Item: TListItem; E: Exception);
begin
  raise Exception.Create(Format('Error %s %s creating thumbnail for : %s', [E.Message, #10, ShellList.Folders[Item.Index].PathName]));
end;

procedure TFMain.ShellistThumbGenerate(Sender: TObject; Item: TListItem; Status: TThumbGenStatus; Total, Remaining: integer);
begin
  if (Remaining > 0) then
    StatusBar.Panels[1].Text := 'Remaining Thumbnails to generate: ' + IntToStr(Remaining)
  else
    StatusBar.Panels[1].Text := '';
end;

procedure TFMain.CounterETEvent(Counter: integer);
begin
  StatusBar.Panels[1].Text := Format('%d Files remaining', [Counter]);
  StatusBar.Update;
end;

end.
