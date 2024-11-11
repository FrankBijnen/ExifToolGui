unit Main;
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
  BreadcrumbBar, // BreadcrumbBar
  UnitScaleForm, // Scale form from Commandline parm.
  UnitSingleApp, // Single Instance App.
  UnitColumnDefs, // Columndefs for file list
  ExifToolsGUI_ShellTree,   // Extension of ShellTreeView
  ExifToolsGUI_ShellList,   // Extension of ShellListView
  ExifToolsGUI_Thumbnails,  // Thumbnails
  ExifToolsGUI_ValEdit,     // MetaData
  ExifToolsGUI_OpenPicture, // OpenPicture dialog
  ExifToolsGUI_Utils,       // Various
  Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup, Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.VirtualImageList,
  System.Win.TaskbarCore, Vcl.Taskbar, Vcl.ToolWin;

const
  CM_ActivateWindow = WM_USER + 100;

type

  TFMain = class(TScaleForm)
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
    AdvPanelETdirect: TPanel;
    AdvPanelMetaTop: TPanel;
    AdvPanelMetaBottom: TPanel;
    ShellTree: ExifToolsGUI_ShellTree.TShellTreeView; // Need to create our own version!
    ShellList: ExifToolsGUI_ShellList.TShellListView; // Need to create our own version!
    MetadataList: ExifToolsGui_ValEdit.TValueListEditor; // Need to create our own version!
    OpenPictureDlg: ExifToolsGUI_OpenPicture.TOpenPictureDialog; // Need to create our own version!
    SpeedBtnExif: TSpeedButton;
    SpeedBtnIptc: TSpeedButton;
    SpeedBtnXmp: TSpeedButton;
    SpeedBtnMaker: TSpeedButton;
    SpeedBtnALL: TSpeedButton;
    SpeedBtnCustom: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    EditETdirect: TLabeledEdit;
    SpeedBtn_ETdirect: TSpeedButton;
    CBoxETdirect: TComboBox;
    SpeedBtn_ETedit: TSpeedButton;
    EditETcmdName: TLabeledEdit;
    SpeedBtnQuick: TSpeedButton;
    MemoQuick: TMemo;
    SpeedBtnLarge: TSpeedButton;
    EditQuick: TEdit;
    SpeedBtnShowLog: TSpeedButton;
    SpeedBtnQuickSave: TSpeedButton;
    SpeedBtnETdirectDel: TSpeedButton;
    SpeedBtnETdirectReplace: TSpeedButton;
    SpeedBtnETdirectAdd: TSpeedButton;
    AdvTabOSMMap: TTabSheet;
    AdvPanel_MapTop: TPanel;
    SpeedBtn_ShowOnMap: TSpeedButton;
    AdvPanel_MapBottom: TPanel;
    SpeedBtn_Geotag: TSpeedButton;
    EditMapFind: TLabeledEdit;
    SpeedBtn_MapHome: TSpeedButton;
    SpeedBtn_MapSetHome: TSpeedButton;
    OpenFileDlg: TOpenDialog;
    SaveFileDlg: TSaveDialog;
    AdvTabChart: TTabSheet;
    AdvPanel1: TPanel;
    SpeedBtnChartRefresh: TSpeedButton;
    AdvCheckBox_Subfolders: TCheckBox;
    AdvRadioGroup1: TRadioGroup;
    AdvRadioGroup2: TRadioGroup;
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
    EditFindMeta: TLabeledEdit;
    EditMapBounds: TLabeledEdit;
    PnlBreadCrumb: TPanel;
    MainActionManager: TActionManager;
    MaAbout: TAction;
    MaPreferences: TAction;
    MaQuickManager: TAction;
    MaGUIStyle: TAction;
    MaExit: TAction;
    MaWorkspaceLoad: TAction;
    MaWorkspaceSave: TAction;
    ActionMainMenuBar: TActionMainMenuBar;
    MaDontBackup: TAction;
    MaPreserveDateMod: TAction;
    MaIgnoreErrors: TAction;
    MaShowGPSdecimal: TAction;
    MaShowSorted: TAction;
    MaShowComposite: TAction;
    MaNotDuplicated: TAction;
    MaShowNumbers: TAction;
    MaShowHexID: TAction;
    MaGroup_g4: TAction;
    MaAPIWindowsWideFile: TAction;
    MaCustomOptions: TAction;
    MaExportMetaTXT: TAction;
    MaExportMetaMIE: TAction;
    MaExportMetaXMP: TAction;
    MaExportMetaEXIF: TAction;
    MaExportMetaHTML: TAction;
    MaImportMetaSingle: TAction;
    MaImportMetaSelected: TAction;
    MaImportRecursiveAll: TAction;
    MaImportGPS: TAction;
    MaImportGPSLog: TAction;
    MaImportXmpLog: TAction;
    MaGenericExtractPreviews: TAction;
    MaGenericImportPreview: TAction;
    MaExifDateTimeshift: TAction;
    MaExifDateTimeEqualize: TAction;
    MaExifLensFromMaker: TAction;
    MaRemoveMeta: TAction;
    MaUpdateLocationfromGPScoordinates: TAction;
    MaFileDateFromExif: TAction;
    MaFileNameDateTime: TAction;
    MaJPGGenericlosslessautorotate: TAction;
    MaOnlineDocumentation: TAction;
    QuickPopUpMenu: TPopupMenu;
    QuickPopUp_FillQuickAct: TMenuItem;
    ImageCollectionMetadata: TImageCollection;
    QuickPopUp_UndoEditAct: TMenuItem;
    QuickPopUp_AddQuickAct: TMenuItem;
    QuickPopUp_DelQuickAct: TMenuItem;
    N1: TMenuItem;
    QuickPopUp_AddCustomAct: TMenuItem;
    QuickPopUp_DelCustomAct: TMenuItem;
    QuickPopUp_AddDetailsUserAct: TMenuItem;
    QuickPopUp_MarkTagAct: TMenuItem;
    N4: TMenuItem;
    QuickPopUp_CopyTagAct: TMenuItem;
    VirtualImageListMetadata: TVirtualImageList;
    TrayIcon: TTrayIcon;
    TrayPopupMenu: TPopupMenu;
    Tray_Resetwindowsize: TMenuItem;
    ImgListTray_TaskBar: TImageList;
    Tray_ExifToolGui: TMenuItem;
    N2: TMenuItem;
    Taskbar: TTaskbar;
    ActLstTaskbar: TActionList;
    TaskBarResetWindow: TAction;
    MaAPILargeFileSupport: TAction;
    MaCheckVersions: TAction;
    MaETDirectLoad: TAction;
    MaEtDirectSave: TAction;
    MaUserDefSave: TAction;
    MaUserDefLoad: TAction;
    MaCustomViewSave: TAction;
    MaCustomViewLoad: TAction;
    MaPredefinedSave: TAction;
    MaPredefinedLoad: TAction;
    AdvPanelBrowser: TPanel;
    TbFileList: TToolBar;
    TbFlRefresh: TToolButton;
    TbFlView: TToolButton;
    ImageCollectionFileList: TImageCollection;
    VirtualImageListFileList: TVirtualImageList;
    FileListViewMenu: TPopupMenu;
    TbFlFilter: TToolButton;
    FileListFilterMenu: TPopupMenu;
    TbFlExport: TToolButton;
    ExportMenu: TPopupMenu;
    Csv1: TMenuItem;
    SpbRecord: TSpeedButton;
    Json1: TMenuItem;
    TbFlSelect: TToolButton;
    SelectMenu: TPopupMenu;
    Selectall2: TMenuItem;
    Selectnone2: TMenuItem;
    AdvCheckBox_Zeroes: TCheckBox;
    BvlChartFunc: TBevel;
    AdvCheckBox_Legend: TCheckBox;
    MaAPIWindowsLongPath: TAction;
    procedure ShellListClick(Sender: TObject);
    procedure ShellListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpeedBtnExifClick(Sender: TObject);
    procedure ShellListAddItem(Sender: TObject; AFolder: TShellFolder; var CanAdd: boolean);
    procedure FormShow(Sender: TObject);
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
    procedure MetadataListDrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
    procedure MetadataListSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
    procedure MetadataListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MetadataListExit(Sender: TObject);
    procedure MetadataListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure MetadataListCtrlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditQuickEnter(Sender: TObject);
    procedure EditQuickExit(Sender: TObject);
    procedure EditQuickKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnQuickSaveClick(Sender: TObject);
    procedure MPreferencesClick(Sender: TObject);
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
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI, NewDPI: Integer);
    procedure Tray_ResetwindowsizeClick(Sender: TObject);
    procedure TrayPopupMenuPopup(Sender: TObject);
    procedure TaskbarThumbButtonClick(Sender: TObject; AButtonID: Integer);
    procedure ApplicationMinimize(Sender: TObject);
    procedure TrayIconMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TrayIconBalloonClick(Sender: TObject);
    procedure MaAPILargeFileSupportExecute(Sender: TObject);
    procedure MaCheckVersionsExecute(Sender: TObject);
    procedure ShellListEnter(Sender: TObject);
    procedure MaETDirectLoadExecute(Sender: TObject);
    procedure MaEtDirectSaveExecute(Sender: TObject);
    procedure MaUserDefLoadExecute(Sender: TObject);
    procedure MaUserDefSaveExecute(Sender: TObject);
    procedure MaCustomViewLoadExecute(Sender: TObject);
    procedure MaCustomViewSaveExecute(Sender: TObject);
    procedure MaPredefinedLoadExecute(Sender: TObject);
    procedure MaPredefinedSaveExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ShellTreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ShellListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TbFlRefreshClick(Sender: TObject);
    procedure StyledDraw(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure Small1MeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure FileListViewMenuPopup(Sender: TObject);
    procedure SpeedBtnFilterEditClick(Sender: TObject);
    procedure FileListFilterMenuPopup(Sender: TObject);
    procedure Csv1Click(Sender: TObject);
    procedure SpbRecordClick(Sender: TObject);
    procedure Json1Click(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
    procedure Selectnone1Click(Sender: TObject);
    procedure Selectall2Click(Sender: TObject);
    procedure Selectnone2Click(Sender: TObject);
    procedure ChartCheckClick(Sender: TObject);
    procedure MaAPIWindowsLongPathExecute(Sender: TObject);
    procedure EditETdirectKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    ETBarSeriesFocal: TBarSeries;
    ETBarSeriesFnum: TBarSeries;
    ETBarSeriesIso: TBarSeries;
    BreadcrumbBar: TDirBreadcrumbBar;
    EdgeZoom: double;
    MinFileListWidth: integer;
    MenusEnabled: boolean;
    procedure AlignStatusBar;
    procedure ImageDrop(var Msg: TWMDROPFILES); message WM_DROPFILES;
    procedure SetCaption(AnItem: string = '');
    procedure ShowMetadata;
    procedure ShowPreview;
    procedure RestoreGUI;
    procedure ShellListSetFolders;
    procedure SelectAll;
    procedure EnableMenus(Enable: boolean);
    procedure EnableMenuItems;

    procedure CMActivateWindow(var Message: TMessage); message CM_ActivateWindow;
    procedure WMEndSession(var Msg: TWMEndSession); message WM_ENDSESSION;
    function TranslateTagName(xMeta, xName: string): string;

    procedure BreadCrumbClick(Sender: TObject);
    procedure BreadCrumbHome(Sender: TObject);
    procedure RefreshSelected(Sender: TObject);
    procedure ShellTreeBeforeContext(Sender: TObject);
    procedure ShellTreeAfterContext(Sender: TObject);
    procedure ShellTreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);

    procedure ShellistThumbError(Sender: TObject; Item: TListItem; E: Exception);
    procedure ShellistThumbGenerate(Sender: TObject; Item: TListItem; Status: TThumbGenStatus; Total, Remaining: integer);

    procedure ShellListCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);

    procedure ShellListBeforeEnumColumns(Sender: TObject; var ReadModeOptions: TReadModeOptions; var ColumnDefs: TColumnsArray);
    procedure ShellListAfterEnumColumns(Sender: TObject);
    procedure ShellListPathChange(Sender: TObject);
    procedure ShellListItemsLoaded(Sender: TObject);
    procedure ShellListOwnerDataFetch(Sender: TObject; Item: TListItem; Request: TItemRequest; AFolder: TShellFolder);
    procedure ShellListColumnResized(Sender: TObject);
    procedure ShellListMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure CounterETEvent(Counter: integer);
    procedure ResetRootShowAll;
    procedure SetCaptionAndImage;
    procedure ViewPopupDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure ViewPopupClick(Sender: TObject);
    procedure FilterPopupDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure FilterPopupClick(Sender: TObject);
    procedure EditFileLists(Sender: TObject);
    procedure EditFileFilter(Sender: TObject);

  protected
    function GetDefWindowSizes: TRect; override;
  public
    GUIBorderWidth, GUIBorderHeight: integer;
    GUIColorWindow: TColor;
    GUIColorShellTree: TColor;
    GUIColorShellList: TColor;

    { Public declarations }
    function GetFirstSelectedFile: string;
    function GetFirstSelectedFilePath: string;
    function GetFullPath(MustExpandPath: boolean): string;
    function GetFileNameForArgs(FileName: string; MustExpandPath: boolean): string;
    function GetSelectedFile(FileName: string; MustExpandPath: boolean): string; overload;
    function GetSelectedFile(FileName: string): string; overload;
    function GetSelectedFiles(MustExpandPath: boolean): string; overload;
    function GetSelectedFiles: string; overload;
    procedure ExecETEvent_Done(ExecNum: word; EtCmds, EtOuts, EtErrs, StatusLine: string; PopupOnError: boolean);
    procedure ExecRestEvent_Done(Url, Response: string; Succes: boolean);
    procedure UpdateStatusBar_FilesShown;
    procedure GetColorsFromStyle;
    procedure SetColorsFromStyle;
    function GetFormOffset(AddFileList: boolean = true): TPoint;

  end;

var
  FMain: TFMain;

implementation

uses System.StrUtils, System.Math, System.Masks, System.Types, System.UITypes,
  Vcl.ClipBrd, Winapi.ShlObj, Winapi.ShellAPI, Winapi.CommCtrl, Vcl.Shell.ShellConsts, Vcl.Themes, Vcl.Styles,
  ExifTool, ExifInfo, ExifToolsGui_LossLess, ExifTool_PipeStream, ExifToolsGui_ResourceStrings,
  ExifToolsGUI_MultiContextMenu, ExifToolsGUI_StringList, ExifToolsGui_FileListColumns,
  UDmFileLists,
  MainDef, LogWin, Preferences, EditFFilter, EditFCol, UFrmStyle, UFrmAbout, UFrmCheckVersions,
  QuickMngr, DateTimeShift, DateTimeEqual, CopyMeta, RemoveMeta, Geotag, Geomap, CopyMetaSingle, FileDateTime,
  UFrmGenericExtract, UFrmGenericImport, UFrmLossLessRotate, UFrmGeoTagFiles, UFrmGeoSetup, UFrmGenerate,
  UnitLangResources;

{$R *.dfm}

var FStyleServices: TCustomStyleServices;


function TFMain.GetDefWindowSizes: TRect;
begin
  result := Rect(40, 60, 1024, 660);
end;

function TFMain.GetFormOffset(AddFileList: boolean = true): TPoint;
begin
  result.X := Left + GUIBorderWidth;
  if (AddFileList) then
    result.X := result.X + AdvPageFilelist.Left;

  result.Y := Top + GUIBorderHeight;
  if (AddFileList) then
    result.Y := result.Y + AdvPageFilelist.Top;
end;

procedure TFMain.ResetRootShowAll;
begin
  ShellList.Enabled := false;
  try
    GUIsettings.FilterSel := 0;
    ShellList.IncludeSubFolders := false;
    SetCaptionAndImage;
    ShellList.Refresh;
  finally
    ShellList.Enabled := true;
  end;

  ShellTree.Root := ShellTree.PreferredRoot;
  // Setting ObjectTypes will always call RootChanged, even if the value has not changed.
  ShellTree.ObjectTypes := ShellTree.ObjectTypes;
  ShellTree.Refresh(ShellTree.TopItem);
end;

procedure TFMain.WMEndSession(var Msg: TWMEndSession);
begin // for Windows Shutdown/Log-off while GUI is open
  if Msg.EndSession = true then
    SaveGUIini;
  inherited;
end;

procedure TFMain.CMActivateWindow(var Message: TMessage);
var
  NewSharedDir: string;
begin
  RestoreGUI;

  NewSharedDir := FSharedMem.NewDirectory;
  if (ValidDir(NewSharedDir)) then
    ShellTree.Path := NewSharedDir;

  Message.Result := 0;
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

procedure TFMain.ChartCheckClick(Sender: TObject);
begin
  with ETChart do
  begin
    UndoZoom;
    ETChart.Title.Visible := true;
    Legend.Visible := AdvCheckBox_Legend.Checked;
    RemoveAllSeries;
  end;
end;

procedure TFMain.AdvRadioGroup2Click(Sender: TObject);
var
  LeftInc: double;
begin

  ChartCheckClick(Sender);

  with ETChart.LeftAxis do
  begin
    Title.Text := StrNrOfPhotos;
    Visible := true;
    Automatic := false;
    AutomaticMaximum := false;
    AutomaticMinimum := false;
    Minimum := 0; // Cannot have a negative nr of photos!
  end;

  case AdvRadioGroup2.ItemIndex of
    0:
      begin
        ETChart.LeftAxis.Maximum := Round(ETBarSeriesFocal.MaxYValue * 1.1);
        ETChart.Title.Text.Text := StrFocalLength;
        ETChart.AddSeries(ETBarSeriesFocal);
      end;
    1:
      begin
        ETChart.LeftAxis.Maximum := Round(ETBarSeriesFnum.MaxYValue * 1.1);
        ETChart.Title.Text.Text := StrFNumber;
        ETChart.AddSeries(ETBarSeriesFnum);
      end;
    2:
      begin
        ETChart.LeftAxis.Maximum := Round(ETBarSeriesIso.MaxYValue * 1.1);
        ETChart.Title.Text.Text := StrISO;
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

procedure TFMain.EditFileLists(Sender: TObject);
begin
  DmFileLists.SelectedSet := GUIsettings.DetailsSel +1;
  FEditFColumn.PrepareShow(ShellList.GetSelectedFolder(-1)); // If SelectedFolder = nil, no sample values, but it should work.
  if FEditFColumn.ShowModal = mrOK then
  begin
    UpdateSysColumns(ShellList.RootFolder);
    GUIsettings.DetailsSel := DmFileLists.SelectedSet -1;
    ShellList.ViewStyle := TViewStyle.vsReport;
    SetCaptionAndImage;
    if (ShellList.Enabled) then
    begin
      ShellList.Refresh;
      ShellList.SetFocus;
    end;
  end;
  ShowMetadata;
end;

procedure TFMain.BtnETdirectAddClick(Sender: TObject);
begin
  EditETdirect.Text := trim(EditETdirect.Text);
  ETdirectCmdList.Append(EditETdirect.Text); // store command
  EditETcmdName.Text := trim(EditETcmdName.Text);
  CBoxETdirect.ItemIndex := CBoxETdirect.Items.Add(EditETcmdName.Text);
  // store name
  CBoxETdirectChange(Sender);
end;

procedure TFMain.BtnETdirectDelClick(Sender: TObject);
var
  Indx: integer;
begin
  Indx := CBoxETdirect.ItemIndex;
  CBoxETdirect.ItemIndex := -1;
  ETdirectCmdList.Delete(Indx);
  CBoxETdirect.Items.Delete(Indx);
  EditETcmdName.Text := '';
  EditETcmdName.Modified := false;
  EditETdirect.Modified := true;
  CBoxETdirectChange(Sender);
end;

procedure TFMain.BtnETdirectReplaceClick(Sender: TObject);
var
  Indx: integer;
begin
  Indx := CBoxETdirect.ItemIndex;
  CBoxETdirect.ItemIndex := -1;
  EditETdirect.Text := trim(EditETdirect.Text);
  ETdirectCmdList[Indx] := EditETdirect.Text;
  EditETcmdName.Text := trim(EditETcmdName.Text);
  CBoxETdirect.Items[Indx] := EditETcmdName.Text;
  CBoxETdirect.ItemIndex := Indx;
  CBoxETdirectChange(Sender);
end;

// set View and Filter buttons
procedure TFMain.SetCaptionAndImage;
begin
  if (ShellList.ViewStyle = vsIcon) then
  begin
    TbFlView.Caption := IntToStr(ShellList.ThumbNailSize) + ThumbNailPix;
    TbFlView.Hint := IntToStr(ShellList.ThumbNailSize) + ThumbNailPix;
    TbFlView.ImageIndex := Img_Thumb;
  end
  else if (GUIsettings.DetailsSel < GetFileListDefs.Count) then
  begin
    TbFlView.Caption := GetFileListDefs[GUIsettings.DetailsSel].Name;
    TbFlView.Hint := GetFileListDefs[GUIsettings.DetailsSel].Name;
    TbFlView.ImageIndex := Min(Img_FirstDetail + GUIsettings.DetailsSel, Img_LastDetail);
  end;
  TbFlFilter.Caption := GUIsettings.FileFilter;
  TbFlFilter.Hint := GUIsettings.FileFilter;
  TbFlFilter.ImageIndex := Img_Filter;
end;

procedure TFMain.EditFileFilter(Sender: TObject);
begin
  if FEditFFilter.ShowModal = mrOK then
  begin
    SetCaptionAndImage;
    Shelllist.IncludeSubFolders := ContainsText(GUIsettings.FileFilter, '/s');
    ShellList.Refresh;
  end;
end;

procedure TFMain.BtnQuickSaveClick(Sender: TObject);
var
  I, J, K: integer;
  SavedRow: integer;
  ETcmd, TagValue, Tx: string;
  ETout, ETerr: string;
begin
  if (SpeedBtnQuickSave.Enabled = false) then // If called from CTRL+S from metadatalist
    exit;

  SavedRow := MetadataList.Row;
  SpeedBtnQuickSave.Enabled := false;
  ETcmd := '';
  J := MetadataList.RowCount - 1;
  for I := 1 to J do
  begin
    if pos('*', MetadataList.Keys[I]) = 1 then
    begin
      TagValue := MetadataList.Cells[1, I];

      Tx := MetadataList.Keys[I];
      K := pos(#177, Tx); // is it multi-value tag?
      if (K = 0) or
         (TagValue = '') then
      begin // no: standard tag
        K := 0;
        if RightStr(Tx, 1) = '#' then
          Inc(K);
        Tx := LowerCase(QuickTags[I - 1].Command);
        if K > 0 then
        begin
          if RightStr(Tx, 1) <> '#' then
            Tx := Tx + '#';
        end;
        ETcmd := ETcmd + Tx + '=' + TagValue + CRLF;
      end
      else
      begin // it is multi-value tag (ie.keywords)
        repeat
          ETcmd := ETcmd + QuickTags[I - 1].Command;
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
          K := pos('+', TagValue);
          if K > 0 then
            Tx := Copy(TagValue, 1, K - 1)
          else
          begin
            K := pos('-', TagValue);
            if K > 0 then
              Tx := Copy(TagValue, 1, K - 1)
            else
              Tx := TagValue;
          end;
          if K > 0 then
            Delete(TagValue, 1, K - 1)
          else
            TagValue := '';
          ETcmd := ETcmd + Tx + CRLF;
        until Length(TagValue) = 0;
      end;
    end;
  end;

  if (ET.OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr)) then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
  MetadataList.SetFocus;
  Metadatalist.Row := SavedRow;
end;

procedure TFMain.BtnShowLogClick(Sender: TObject);
begin
  FLogWin.Show;
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
    result := ShellList.RelFileName + CRLF
  else if (ShellList.Items.Count > 0) then
    result := ShellList.RelFileName(0) + CRLF;
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
    result := IncludeTrailingPathDelimiter(ShellList.Path);
end;

function TFMain.GetFileNameForArgs(FileName: string; MustExpandPath: boolean): string;
const
  InvalidArgChars = [' ', '-', '#'];
begin
  if (MustExpandPath = false) and
     (Length(Filename) > 0) and
     (CharInSet(FileName[1], InvalidArgChars)) then
    result := '.\' + FileName
  else
    result := FileName;
end;

function TFMain.GetSelectedFile(FileName: string; MustExpandPath: boolean): string;
begin
  if (FileName = '') then
    result := ''
  else
    result := GetFullPath(MustExpandPath) + GetFileNameForArgs(FileName, MustExpandPath);
end;

function TFMain.GetSelectedFile(FileName: string): string;
begin
  result := GetSelectedFile(FileName, ET.Options.ETAPIWindowsWideFile = '');
end;

function TFMain.GetSelectedFiles(MustExpandPath: boolean): string;
var
  FullPath: string;
  Cnt: integer;
  Index: integer;
begin
  Cnt := 0;
  result := '';
  FullPath := GetFullPath(MustExpandPath);
  for Index := 0 to ShellList.Items.Count -1 do
  begin
    if (ListView_GetItemState(ShellList.Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) and
       (TSubShellFolder.GetIsFolder(ShellList.Folders[Index]) = false) then
    begin
      result := result + FullPath + GetFileNameForArgs(ShellList.RelFileName(Index), MustExpandPath) + CRLF;
      Inc(Cnt);
    end;
  end;
  if (Cnt > 1) then
    ET.SetCounter(CounterETEvent, Cnt);
end;

function TFMain.GetSelectedFiles: string;
begin
  result := GetSelectedFiles(ET.Options.ETAPIWindowsWideFile = '');
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

    // Selecting a style with subfolders enabled takes to long
    ResetRootShowAll;

    Show;
  end;
end;

procedure TFMain.MAboutClick(Sender: TObject);
begin
  FrmAbout.ShowModal;
end;

procedure TFMain.MaCheckVersionsExecute(Sender: TObject);
begin
  FrmCheckVersions.ShowModal;
end;

procedure TFMain.MaETDirectLoadExecute(Sender: TObject);
begin
  if (LoadIniDialog(OpenFileDlg, TIniData.idETDirect, SpeedBtn_ETdirect.Down = false)) then
    SpeedBtn_ETdirect.Down := true;
end;

procedure TFMain.MaEtDirectSaveExecute(Sender: TObject);
begin
  SaveIniDialog(SaveFileDlg, TIniData.idETDirect, true);
end;

procedure TFMain.MAPIWindowsWideFileClick(Sender: TObject);
begin
  with ET.Options do
    SetApiWindowsWideFile(MaAPIWindowsWideFile.Checked);
end;

procedure TFMain.MaAPIWindowsLongPathExecute(Sender: TObject);
begin
  with ET.Options do
    SetApiWindowsLongPath(MaAPIWindowsLongPath.Checked);
end;

procedure TFMain.MaAPILargeFileSupportExecute(Sender: TObject);
begin
  with ET.Options do
    SetApiLargeFileSupport(MaAPILargeFileSupport.Checked);
end;

procedure TFMain.MaUserDefLoadExecute(Sender: TObject);
begin
  if (LoadIniDialog(OpenFileDlg, TIniData.idFileLists, false)) then
    EditFileLists(Sender)
end;

procedure TFMain.MaUserDefSaveExecute(Sender: TObject);
begin
  SaveIniDialog(SaveFileDlg, TIniData.idFileLists, true);
end;

procedure TFMain.MaCustomViewLoadExecute(Sender: TObject);
begin
  if (LoadIniDialog(OpenFileDlg, TIniData.idCustomView, SpeedBtnCustom.Down = false)) then
    ShowMetadata;
end;

procedure TFMain.MaCustomViewSaveExecute(Sender: TObject);
begin
  SaveIniDialog(SaveFileDlg, TIniData.idCustomView, true);
end;

procedure TFMain.MaPredefinedLoadExecute(Sender: TObject);
begin
  if (LoadIniDialog(OpenFileDlg, TIniData.idPredefinedTags, False)) then
    ShowMetadata;
end;

procedure TFMain.MaPredefinedSaveExecute(Sender: TObject);
begin
  SaveIniDialog(SaveFileDlg, TIniData.idPredefinedTags, true);
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
  CellTx, KeyTx, WorkTx: string;
  NewColor, TxtColor: TColor;
  I, N, X: integer;
begin
  if (ARow = 0) then
    exit;

  N := length(QuickTags) - 1;
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
        Delete(KeyTx, 1, pos(' ', KeyTx)); // -in case of Show HexID prefix
        TxtColor := clWindowText;
        if pos(KeyTx + ' ', MarkedTagList) > 0 then
          TxtColor := $0000FF; // tag is marked
        // check if tag is defined in Workspace
        KeyTx := UpperCase(KeyTx);
        for I := 0 to N do
        begin
          WorkTx := UpperCase(QuickTags[I].Command);
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

procedure TFMain.MetadataListExit(Sender: TObject);
begin // remember last selected row
  if SpeedBtnQuick.Down then
    MetadataList.Tag := MetadataList.Row;
end;

procedure TFMain.MetadataListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I: integer;
begin
  I := MetadataList.Row;
  if (Key = VK_Return) and SpeedBtnQuick.Down and not(QuickTags[I - 1].NoEdit) then
  begin
    if SpeedBtnLarge.Down then
      MemoQuick.SetFocus
    else
      EditQuick.SetFocus;
  end;
end;

// Event handler for CTRL Keydown.
// Allows intercepting CTRL/VK_UP CTRL/VK_DOWN
procedure TFMain.MetadataListCtrlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  function CheckIndex(var Indx: integer): boolean;
  begin
    result := (ShellList.Items.Count > 0);
    if (Indx < 0) then
      Indx := 0;
    if (Indx > ShellList.Items.Count -1) then
      Indx := ShellList.Items.Count -1;
  end;

  procedure SelectPrevNext(const Down: boolean);
  var
    Old: integer;
    New: integer;
    MetaDataRow: integer;
  begin
    // Save MetaData Row
    MetaDataRow := MetadataList.Row;

    // Current
    if Assigned(ShellList.Selected) then
      Old := ShellList.Selected.Index
    else
      Old := ShellList.ItemIndex;
    if not CheckIndex(Old) then
      exit;

    If (Down) then
      New := Old + 1
    else
      New := Old - 1;
    if (New < 0) then
      New := 0;
    if not CheckIndex(New) then
      exit;

    // Select only the item, and make that visible
    ShellList.Refresh;
    ShellList.Items[New].Selected := true;
    ShellList.Items[New].MakeVisible(false);

    // Simulate a click on the new item, will load Metadata etc.
    ShellListClick(ShellList);

    // Focus back on original Metadata Row
    MetadataList.SetFocus;
    if (MetadataList.RowCount >= MetaDataRow) then
      MetadataList.Row := MetaDataRow;
  end;

begin
  case Key of
    Ord('C'):
      Clipboard.AsText := MetadataList.Cells[1, MetadataList.Row];
    Ord('S'):
      BtnQuickSaveClick(Sender);
    VK_UP, VK_DOWN:
      begin
        SelectPrevNext(Key = VK_DOWN);
        Key := 0; // Dont want the inherited code. Scrolls to begin/end of Metadatalist
      end;
    end;
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
     (ARow <= TValueListEditor(Sender).RowCount) then
    Hint := TValueListEditor(Sender).Cells[1, ARow]
  else
    Hint := '';

  if (TValueListEditor(Sender).Tag <> ARow) then  // Need to activate hint already?
  begin
    TValueListEditor(Sender).Tag := ARow;         // Remember the row that has the hint.
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
    ShellList.RefreshSelected;
    ShowMetadata;
  end;
end;

procedure TFMain.MExifLensFromMakerClick(Sender: TObject);
var
  ETcmd, ETout, ETerr: string;
begin
  if MessageDlg(StrThisWillFillExif1 + #10 +
                StrThisWillFillExif2 + #10#10 +
                StrOKToProceed, mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    ETcmd := '-Exif:LensInfo<LensID' + CRLF + '-Exif:LensModel<LensID' + CRLF;
    ET.OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr);
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
  Indx: integer;
  ETcmd, XDir, ETout, ETerr: string;
begin
  if (ET.Options.ETAPIWindowsWideFile <> '') then
    XDir := '.\%d\'
  else
    XDir := '%d\';

  if GUIsettings.DefExportUse then
  begin
    XDir := GUIsettings.DefExportDir;
    Indx := length(XDir);
    if Indx > 0 then
      if XDir[Indx] <> '\' then
        XDir := XDir + '\';
  end;

  if Sender = MaExportMetaTXT then
    ETcmd := '-w' + CRLF + XDir + '%f.txt' + CRLF + '-g0' + CRLF + '-a' + CRLF + '-All:All';
  if Sender = MaExportMetaMIE then
    ETcmd := '-o' + CRLF + XDir + '%f.mie' + CRLF + '-All:All';
  if Sender = MaExportMetaXMP then
    ETcmd := '-o' + CRLF + XDir + '%f.xmp' + CRLF + '-Xmp:All';
  if Sender = MaExportMetaEXIF then
    ETcmd := '-TagsFromFile' + CRLF + '@' + CRLF + '-All:All' + CRLF + '-o' + CRLF + '%f.exif';
  if Sender = MaExportMetaHTML then
    ETcmd := '-w' + CRLF + XDir + '%f.html' + CRLF + '-htmldump';

  ET.OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr);
  if XDir = '' then
    TbFlRefreshClick(Sender);
end;

const
  Group = 'exif';

procedure TFMain.MFileDateFromExifClick(Sender: TObject);
var
  ETout, ETerr: string;
begin
  if MessageDlg(FileDateFromExif1 + #10 +
                Format(FileDateFromExif2, [CmdCreateDate(Group), CmdModifyDate(Group)]) + #10#10 +
                StrOKToProceed, mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    ET.OpenExec('-FileCreateDate<' + CmdCreateDate(Group) + CRLF +
                '-FileModifyDate<' + CmdModifyDate(Group),
                GetSelectedFiles, ETout, ETerr);
    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
end;

procedure TFMain.MFileNameDateTimeClick(Sender: TObject);
begin
  if (FFileDateTime.ShowModal = idOK) then
    ShellList.RefreshSelected;
end;

procedure TFMain.MDontBackupClick(Sender: TObject);
begin
  ET.Options.SetBackupMode(MaDontBackup.Checked);
end;

procedure TFMain.MIgnoreErrorsClick(Sender: TObject);
begin
  ET.Options.SetMinorError(MaIgnoreErrors.Checked);
end;

procedure TFMain.MImportMetaSelectedClick(Sender: TObject);
var
  DstExt: string[7];
  ETcmd, ETout, ETerr: string;
  J: integer;
begin
  DstExt := UpperCase(ExtractFileExt(ShellList.SelectedFolder.PathName));
  Delete(DstExt, 1, 1);

  if (DstExt = 'JPG') or (DstExt = 'TIF') then
  begin
    J := ShellList.SelCount;
    if J > 1 then // message appears only if multiple files selected
      if MessageDlg(ImportMetaSel1 + #10 +
                    Format(ImportMetaSel2, [DstExt]) + #10 +
                    ImportMetaSel3 + #10 +
                    ImportMetaSel4 + #10#10 +
                    ImportMetaSel5 + #10 +
                    StrOKToProceed,
                    mtInformation, [mbOk, mbCancel], 0) <> mrOK then
        J := 0;
    if J <> 0 then
    begin
      with OpenPictureDlg do
      begin
        AutoRotatePreview := GUIsettings.AutoRotatePreview;
        InitialDir := ShellList.Path;
        Filter := 'Image & Metadata files|*.*';
        Options := [ofFileMustExist];
        Title := 'Select any of source files';
        FileName := '';
      end;
      if OpenPictureDlg.Execute then
      begin
        ETcmd := OpenPictureDlg.FileName; // single file selected
        if J > 1 then
          ETcmd := IncludeTrailingPathDelimiter(ExtractFileDir(ETcmd)) + '%f' + ExtractFileExt(ETcmd);
        // multiple files
        ETcmd := '-TagsFromFile' + CRLF + ETcmd + CRLF + '-All:All' + CRLF;

        FCopyMetadata.PrepareShow(OpenPictureDlg.FileName);
        if FCopyMetadata.ShowModal = mrOK then
        begin
          ETcmd := ETcmd + FCopyMetadata.TagSelection;
          ETcmd := ETcmd + '-ext' + CRLF + DstExt;
          if (ET.OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr)) then
          begin
            RefreshSelected(Sender);
            ShowMetadata;
          end;
        end;
      end;
    end;
  end
  else
    ShowMessage(StrSelectedDestination);
end;

procedure TFMain.MImportMetaSingleClick(Sender: TObject);
begin
  if MessageDlg(ImportMetaSingle1 + #10 +
                ImportMetaSingle2 + #10#10 +
                ImportMetaSingle3 + #10 +
                StrOKToProceed, mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    with OpenPictureDlg do
    begin
      AutoRotatePreview := GUIsettings.AutoRotatePreview;
      InitialDir := ShellList.Path;
      Filter := 'Image & Metadata files|*.jpg;*.jpeg;*.cr2;*.dng;*.nef;*.tif;*.tiff;*.mie;*.xmp;*.rw2|*.*|*.*';
      Options := [ofFileMustExist];
      Title := StrSelectSourceFile;
      FileName := '';
    end;
    if OpenPictureDlg.Execute then
    begin
      FCopyMetaSingle.PrepareShow(OpenPictureDlg.FileName);
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
  I: integer;
  DstExt: string[5];
  ETcmd, ETout, ETerr: string;
begin
  DstExt := LowerCase(ShellList.FileExt);
  Delete(DstExt, 1, 1);
  if (DstExt = 'jpg') or (DstExt = 'tif') then
  begin
    I := MessageDlg(ImportRecursive1 + #10 +
                    Format(ImportRecursive2, [UpperCase(DstExt)]) + #10 +
                    ImportRecursive3 + #10 +
                    ImportRecursive4 + #10#10 +
                    ImportRecursive5, mtInformation,
                    [mbYes, mbNo, mbCancel], 0);
    if I <> mrCancel then
    begin
      with OpenPictureDlg do
      begin
        AutoRotatePreview := GUIsettings.AutoRotatePreview;
        InitialDir := ShellList.Path;
        Filter := 'Image & Metadata files|*.*';
        Options := [ofFileMustExist];
        Title := StrSelectAnyOfSource;
        FileName := '';
      end;
      if OpenPictureDlg.Execute then
      begin
        ETcmd := '-TagsFromFile' + CRLF + IncludeTrailingPathDelimiter(ExtractFileDir(OpenPictureDlg.FileName)); // incl. slash
        if I = mrYes then
          ETcmd := ETcmd + '%d\';
        ETcmd := ETcmd + '%f' + ExtractFileExt(OpenPictureDlg.FileName);
        if I = mrYes then
          ETcmd := ETcmd + CRLF + '-r';
        ETcmd := ETcmd + CRLF + '-All:All' + CRLF;

        FCopyMetadata.PrepareShow(OpenPictureDlg.FileName);
        if FCopyMetadata.ShowModal = mrOK then
        begin
          ETcmd := ETcmd + FCopyMetadata.TagSelection;
          ETcmd := ETcmd + '-ext' + CRLF + DstExt;
          ET.SetCounter(CounterETEvent, GetNrOfFiles(ShellList.Path, '*.' + DstExt, (I = mrYes)));
          if (ET.OpenExec(ETcmd, '.', ETout, ETerr)) then
          begin
            RefreshSelected(Sender);
            ShowMetadata;
          end;
        end;
      end;
    end;
  end
  else
    ShowMessage(StrSelectedDestination);
end;

procedure TFMain.MImportXMPLogClick(Sender: TObject);
const
  XmpExt = '.Xmp';

var
  SrcDir, ETcmd, ETout, ETerr: string;
  XmpMask: string;
begin
  if MessageDlg(ImportXMP1 + #10+
                ImportXMP2 + #10 +
                ImportXMP3 + #10 +
                ImportXMP4 + #10#10 +
                ImportXMP5 + #10#10 +
                StrOKToProceed,
                mtInformation, [mbOk, mbCancel], 0) = mrOK then
  begin
    if GpsXmpDir <> '' then
      SrcDir := GpsXmpDir
    else
      SrcDir := ShellList.Path;
    SrcDir := BrowseFolderDlg(StrChooseFolderContai, 1, SrcDir);
    if SrcDir <> '' then
    begin
      SrcDir := IncludeTrailingPathDelimiter(SrcDir);
      GpsXmpDir := SrcDir;
      XmpMask := '%f' + XmpExt;
      if (FileExists(SrcDir + ExtractFileName(GetFirstSelectedFilePath) + XmpExt)) then
        XmpMask := '%f.%e' + XmpExt;
      ETcmd := '-TagsFromFile' + CRLF + SrcDir + XmpMask + CRLF;
      ETcmd := ETcmd + '-GPS:GPSLatitude<Xmp-exif:GPSLatitude' + CRLF + '-GPS:GPSLongitude<Xmp-exif:GPSLongitude' + CRLF;
      ETcmd := ETcmd + '-GPS:GPSLatitudeRef<Composite:GPSLatitudeRef' + CRLF + '-GPS:GPSLongitudeRef<Composite:GPSLongitudeRef' + CRLF;
      ETcmd := ETcmd + '-GPS:GPSDateStamp<XMP-exif:GPSDateTime' + CRLF + '-GPS:GPSTimeStamp<XMP-exif:GPSDateTime';
      if (ET.OpenExec(ETcmd, GetSelectedFiles, ETout, ETerr)) then
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

procedure TFMain.Json1Click(Sender: TObject);
begin
  with SaveFileDlg do
  begin
    DefaultExt := 'json';
    if GUIsettings.DefExportUse then
      InitialDir := GUIsettings.DefExportDir
    else
      InitialDir := ShellList.Path;
    Filter := 'Json file|*.json';
    Title := 'Export';
    if Execute then
      ExportToJson(ShellList, FileName);
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
    ET.OpenExit(true); // Force restart of ExifTool. CustomConfig could have changed
    EnableMenus(ET.StayOpen(ShellList.Path)); // Recheck Exiftool.exe.
    ShellListSetFolders;
    ShellList.Refresh;
    ShowMetadata;
  end;
end;

procedure TFMain.MPreserveDateModClick(Sender: TObject);
begin
  ET.Options.SetFileDate(MaPreserveDateMod.Checked);
end;

procedure TFMain.MQuickManagerClick(Sender: TObject);
var
  Indx: integer;
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
  FRemoveMeta.PrepareShow(GetFirstSelectedFilePath);
  if FRemoveMeta.ShowModal = mrOK then
  begin
    RefreshSelected(Sender);
    ShowMetadata;
  end;
end;

procedure TFMain.MShowNumbersClick(Sender: TObject);
begin
  if Sender = MaShowNumbers then
    ET.Options.SetShowNumber(MaShowNumbers.Checked);
  if Sender = MaShowGPSdecimal then
    ET.Options.SetGpsFormat(MaShowGPSdecimal.Checked);
  // + used by MaShowHexID, MaGroup_g4, MaShowComposite, MaShowSorted, MaNotDuplicated
  RefreshSelected(Sender);
  ShowMetadata;
end;

procedure TFMain.MCustomOptionsClick(Sender: TObject);
begin
  ET.Options.SetCustomOptions(InputBox(StrSpecifyCustomOptio,
                                       StrCustomOptions,
                                       ET.Options.ETCustomOptions));
end;

procedure TFMain.MWorkspaceLoadClick(Sender: TObject);
begin
  if (LoadIniDialog(OpenFileDlg, TIniData.idWorkSpace, SpeedBtnQuick.Down = false)) then
    ShowMetadata;
end;

procedure TFMain.MWorkspaceSaveClick(Sender: TObject);
begin
  SaveIniDialog(SaveFileDlg, TIniData.idWorkSpace, true);
end;

procedure TFMain.OnlineDocumentation1Click(Sender: TObject);
begin
  ShellExecute(0, 'Open', PWideChar(StringResource(ETD_Online_Doc)), '', '', SW_SHOWNORMAL);
end;

procedure TFMain.QuickPopUpMenuPopup(Sender: TObject);
var
  I: integer;
  IsSep: boolean;
  Tx: string;
begin
  I := MetadataList.Row;
  Tx := MetadataList.Keys[I];
  QuickPopUp_UndoEditAct.Visible := (pos('*', Tx) = 1);
  IsSep := (Length(Tx) = 0);

  QuickPopUp_AddQuickAct.Visible := not(SpeedBtnQuick.Down or SpeedBtnCustom.Down or IsSep);
  QuickPopUp_AddCustomAct.Visible := not(SpeedBtnQuick.Down or SpeedBtnCustom.Down or IsSep);
  QuickPopUp_DelCustomAct.Visible := SpeedBtnCustom.Down and not(IsSep);
  QuickPopUp_AddDetailsUserAct.Visible := not(SpeedBtnQuick.Down or SpeedBtnCustom.Down or IsSep) and
                                          (GetFileListDefs[GUIsettings.DetailsSel].Options = floUserDef);
  QuickPopUp_MarkTagAct.Visible := not(SpeedBtnQuick.Down or SpeedBtnCustom.Down or IsSep);
  QuickPopUp_DelQuickAct.Visible := not(IsSep) and SpeedBtnQuick.Down;
  QuickPopUp_FillQuickAct.Visible := QuickPopUp_DelQuickAct.Visible;
  QuickPopUp_CopyTagAct.Visible := not IsSep;
end;

procedure TFMain.TaskbarThumbButtonClick(Sender: TObject; AButtonID: Integer);
begin
  case (AButtonID) of
    0: Tray_ResetwindowsizeClick(Sender);
  end;
end;

procedure TFMain.TbFlRefreshClick(Sender: TObject);
begin
  ShellList.Refresh;
  ShellList.SetFocus;
end;

function TFMain.TranslateTagName(xMeta, xName: string): string;
var
  Indx: integer; // xMeta~'-Exif:' or '-IFD0:' or ...
  ETout: TStringList;
begin
  ETout := TStringList.Create;
  try
    if ET.Options.ETLangDef <> '' then
    begin
      ET.OpenExec('-X' + CRLF + '-l' + CRLF + xMeta + 'All', GetSelectedFile(ShellList.RelFileName), ETout);
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

procedure TFMain.RestoreGUI;
begin
  Application.Restore;
  Application.BringToFront;
  Show;

  TrayIcon.Visible := false;
end;

procedure TFMain.TrayIconBalloonClick(Sender: TObject);
begin
  GUIsettings.ShowBalloon := false;
end;

procedure TFMain.TrayIconMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = TMouseButton.mbRight) then
    TrayPopupMenu.Popup(X, Y)
  else
    RestoreGUI;
end;

procedure TFMain.TrayPopupMenuPopup(Sender: TObject);
begin
  Tray_ExifToolGui.Caption := TrayIcon.Hint;
end;

procedure TFMain.QuickPopUp_AddCustomClick(Sender: TObject);
var
  Indx: integer;
  Tx, Ts: string;
  IsVRD: boolean;
begin
  Indx := MetadataList.Row;
  Tx := MetadataList.Keys[Indx];
  if LeftStr(Tx, 2) = '0x' then
    Delete(Tx, 1, 7)
  else if LeftStr(Tx, 2) = '- ' then
    Delete(Tx, 1, 2);
  Tx := TrimRight(Tx);
  if SpeedBtnExif.Down then
    Ts := '-Exif:'
  else if SpeedBtnXmp.Down then
    Ts := '-Xmp:'
  else if SpeedBtnIptc.Down then
    Ts := '-Iptc:'
  else if SpeedBtnMaker.Down then
  begin
    repeat
      dec(Indx);
      IsVRD := (pos('CanonVRD', MetadataList.Cells[1, Indx]) > 0);
    until IsVRD or (Indx = 0);
    if IsVRD then
      Ts := '-CanonVRD:'
    else
      Ts := '-Makernotes:';
  end
  else
    Ts := '-';
  Tx := Ts + TranslateTagName(Ts, Tx) + ' ';
  if Pos(Tx, CustomViewTagList) > 0 then
    ShowMessage(StrTagAlreadyExistsI)
  else
    CustomViewTagList := CustomViewTagList + Tx;
end;

procedure TFMain.QuickPopUp_AddDetailsUserClick(Sender: TObject);
var
  I, N, X: integer;
  Tx, Tk: string;
  PrevSel, PrevRow: integer;
  FListUserDef: TColumnsArray;
begin
  if (GetFileListDefs[GUIsettings.DetailsSel].Options <> floUserDef) then
    exit;
  FListUserDef := GetFileListColumnDefs(GUIsettings.DetailsSel);
  I := Length(FListUserDef);
  SetLength(FListUserDef, I + 1);
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

  FListUserDef[I].SetCaption(Tk);
  Tk := TranslateTagName(Tx, Tk);
  FListUserDef[I].Command := Tx + Tk;  // ='-IFD0:Make'
  FListUserDef[I].Width := 96;
  FListUserDef[I].AlignR := 0;

  SetFileListColumnDefs(GUIsettings.DetailsSel, FListUserDef);

  if GUIsettings.DetailsSel > 0 then
  begin
    PrevSel := ShellList.Selected.Index;
    PrevRow := MetadataList.Row;
    try
      ShellList.Refresh;
    finally
      ShellList.ClearSelection;
      ShellList.Items[PrevSel].Selected := true;
      ShellListClick(ShellList);
      if (PrevRow < MetadataList.RowCount) then
        MetadataList.Row := PrevRow;
    end;
  end;
end;

procedure TFMain.QuickPopUp_AddQuickClick(Sender: TObject);
var
  I, N, X: integer;
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

    if MaGroup_g4.Checked then
      Tx := Tz
    else
    begin // find group
      X := N;
      repeat
        Dec(X);
        Tx := MetadataList.Keys[X];
      until (X = 1) or (length(Tx) = 0);
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
  I, J: Integer;
  Tx, T1: string;
begin
  I := MetadataList.Row;
  if ET.Options.ETLangDef <> '' then
  begin
    T1 := ET.Options.ETLangDef;
    ET.Options.SetLangDef('');
    ShowMetadata;
    Tx := MetadataList.Keys[I];
    ET.Options.SetLangDef(T1);
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
    I := pos(Tx, CustomViewTagList);
    J := I;
    repeat
      dec(I);
    until CustomViewTagList[I] = '-';
    repeat
      inc(J);
    until CustomViewTagList[J] = ' ';
    Delete(CustomViewTagList, I, J - I + 1);
  end;
  ShowMetadata;
end;

procedure TFMain.QuickPopUp_DelQuickClick(Sender: TObject);
var
  I, N: integer;
begin
  N := MetadataList.Row - 1;
  I := length(QuickTags) - 1;
  while N < I do
  begin
    QuickTags[N].Caption := QuickTags[N + 1].Caption;
    QuickTags[N].Command := QuickTags[N + 1].Command;
    QuickTags[N].Help := QuickTags[N + 1].Help;
    QuickTags[N].NoEdit := QuickTags[N + 1].NoEdit;
    inc(N);
  end;
  SetLength(QuickTags, I);
  ShowMetadata;
end;

procedure TFMain.QuickPopUp_FillQuickClick(Sender: TObject);
var
  I, N: integer;
  Tx: string;
begin
  N := length(QuickTags);
  with MetadataList do
  begin
    for I := 0 to N - 1 do
    begin
      Tx := QuickTags[I].Caption;
      if RightStr(Tx, 1) = '*' then
      begin
        Insert('*', Tx, 1);
        Keys[I + 1] := Tx;
        Cells[1, I + 1] := QuickTags[I].Help;
      end;
    end;
    SpeedBtnQuickSave.Enabled := true;
  end;
end;

procedure TFMain.QuickPopUp_MarkTagClick(Sender: TObject);
var
  I, J: integer;
  Tx: string;
begin
  with MetadataList do
    Tx := Keys[Row];
  I := pos(' ', Tx);
  if I > 0 then
    Delete(Tx, 1, I); // if Show HexID exist
  if Length(Tx) > 0 then
  begin
    I := pos(Tx, MarkedTagList);
    if I > 0 then
    begin // tag allready marked: unmark it
      J := I;
      repeat
        inc(J);
      until MarkedTagList[J] = ' ';
      Delete(MarkedTagList, I, J - I + 1);
    end
    else
      MarkedTagList := MarkedTagList + Tx + ' '; // mark tag
  end;
end;

procedure TFMain.QuickPopUp_UndoEditClick(Sender: TObject);
var
  I, N, X: integer;
  Tx, ETouts, ETerrs: string;
begin
  I := MetadataList.Row;
  MetadataList.Keys[I] := QuickTags[I - 1].Caption;
  Tx := '-s3' + CRLF + '-f' + CRLF + QuickTags[I - 1].Command;
  ET.OpenExec(Tx, GetSelectedFile(ShellList.RelFileName), ETouts, ETerrs);
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
  ErrStatus: string;
begin
  with FLogWin do
  begin
    ErrStatus := '-';
    if (PopupOnError) then
    begin
      if (ETerrs = '') then
        ErrStatus := StrOK
      else
      begin
        ErrStatus := StrNotOK;
        Show; // Popup Log window when there's an error.
      end;
      // Try to show 'xxx image files read'.
      StatusBar.Panels[1].Text := StatusLine;
    end;

    if (Showing) and
       ((ChkShowAll.Checked) or (ErrStatus <> '-')) then
    begin
      AddToLog(Format(StrExecuteDSUpdat, [ExecNum, TimeToStr(now), ErrStatus]),
               EtCmds, EtOuts, EtErrs);
    end;
  end;
end;

procedure TFmain.ExecRestEvent_Done(Url, Response: string; Succes: boolean);
var
  ErrStatus: string;
begin
  with FLogWin do
  begin
    if (Showing) then
    begin
      if (Succes) then
        ErrStatus := StrOk
      else
        ErrStatus := StrNOTOk;
      AddToLog(Format(StrRestRequestSUpd, [TimeToStr(now), ErrStatus]),
               Url, Response);
    end;
  end;
end;

procedure TFMain.UpdateLocationfromGPScoordinatesClick(Sender: TObject);
var
  CrWait, CrNormal: HCURSOR;
  Foto: FotoRec;
  SelectedFiles: TStringList;
  ETCmd, AFile: string;
  MIMEType, GPSCoordinates: string;
  IsQuickTime: boolean;
  SavedLang: string;
begin
  Foto := GetMetadata(GetFirstSelectedFilePath, [TGetOption.gmGPS]);
  if (Foto.GPS.HasData) then
  begin
    FGeoSetup.Lat := Foto.GPS.GeoLat;
    FGeoSetup.Lon := Foto.GPS.GeoLon;
  end
  else
  begin
    GPSCoordinates := GetGpsCoordinates(GetFirstSelectedFilePath);
    AnalyzeGPSCoords(GPSCoordinates, FGeoSetup.Lat, FGeoSetup.Lon, MIMEType, IsQuickTime);
  end;

  if not (ValidLatLon(FGeoSetup.Lat, FGeoSetup.Lon)) then
  begin
    MessageDlgEx(StrSelectedFileHasNo, '',
                 TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
    exit;
  end;

  if (FGeoSetup.ShowModal = MROK) then
  begin
    CrWait := LoadCursor(0, IDC_WAIT);
    CrNormal := SetCursor(CrWait);
    SelectedFiles := TStringList.Create;
    try
      if (GeoSettings.GetPlaceProvider = gpExifTool) then
      begin
        SavedLang := ET.Options.ETLangDef;
        if (GeoSettings.ReverseGeoCodeLang <> PlaceDefault) and
           (GeoSettings.ReverseGeoCodeLang <> PlaceLocal) then
          ET.Options.SetLangDef(GeoSettings.ReverseGeoCodeLang)
        else
          ET.Options.SetLangDef('');

        try
          ETCmd := '-XMP-photoshop:XMP-iptcCore:XMP-iptcExt:geolocate<GPSPosition' + CRLF;
          ET.OpenExec(ETcmd, GetSelectedFiles);
        finally
          ET.Options.SetLangDef(SavedLang);
        end;

      end
      else
      begin
        SelectedFiles.Text := GetSelectedFiles(true);   // Need full pathname
        for AFile in SelectedFiles do
        begin
          StatusBar.Panels[1].Text := AFile;
          StatusBar.Update;
          FillLocationInImage(AFile);
        end;
      end;
    finally
      SelectedFiles.Free;
      RefreshSelected(Sender);
      ShowMetadata;
      SetCursor(CrNormal);
    end;
  end;
  StatusBar.Panels[1].Text := '';
end;

procedure TFMain.UpdateStatusBar_FilesShown;
begin
  StatusBar.Panels[0].Text := Format(StrFiles, [ShellList.Items.Count]);
end;

procedure TFMain.EdgeBrowser1CreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
var Url: string;
begin
  if (AResult <> S_OK) then
  begin
    Url := '';
    if not CheckWebView2Loaded then
    begin
      if (MessageDlgEx(StrTheWebView2Loaderd + #10 +
                       StrShowOnlineHelp,
                       '', TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = ID_YES) then
        Url := StringResource(ETD_Edge_Dll);
    end
    else
    begin
      if (MessageDlgEx(StrUnableToStartEdge +#10 +
                       StrShowOnlineHelp,
                       '', TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = ID_YES) then
        Url := StringResource(ETD_Edge_Runtime);
    end;
    if (Url <> '') then
      ShellExecute(0, 'Open', PWideChar(StringResource(ETD_Online_Doc)  + Url), '', '', SW_SHOWNORMAL);
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
  I: integer;
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
  if (Key = VK_Return) and
     (length(ETtx) > 1) then
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
      ET.SetCounter(CounterETEvent, GetNrOfFiles(ShellList.Path, ETtx, true));
      SelectedFiles := '';
    end
    else
      SelectedFiles := GetSelectedFiles;

    // Call ETDirect or ET.OpenExec
    case CmbETDirectMode.ItemIndex of
      0: ETResult := ET.OpenExec(ArgsFromDirectCmd(ETprm), SelectedFiles, ETout, ETerr);
      1: ETResult := TExifTool.ExecET(ETprm, SelectedFiles, ShellList.Path, ETout, ETerr);
      else
        ETResult := false; // Make compiler happy
    end;

    if not ETResult then
      ShowMessage(StrExifToolNotExecute);

    RefreshSelected(Sender);
    ShowMetadata;
    ShowPreview;
  end;
end;

procedure TFMain.EditETdirectKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
    Key := #0; // No Bell
end;

procedure TFMain.EditFindMetaKeyPress(Sender: TObject; var Key: Char);
var NewRow: Integer;
begin
  StatusBar.Panels[1].Text := '';
  if (Key = #13) then
  begin
    Key := #0;
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
    StatusBar.Panels[1].Text := StrNoMoreMatchesFo;
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
  Indx: integer;
  Tx: string;
begin
  Indx := MetadataList.Row;

  if (Key = VK_Return) and
      not(QuickTags[Indx - 1].NoEdit) then
  begin
    Tx := Trim(TCustomEdit(Sender).Text);
    MetadataList.Cells[1, Indx] := Tx;
    Tx := MetadataList.Keys[Indx];
    if TCustomEdit(Sender).Modified and
       (Tx[1] <> '*') then
      MetadataList.Keys[Indx] := '*' + Tx; // mark tag value changed
    if GUIsettings.AutoIncLine and // select next row
      (Indx < MetadataList.RowCount - 1) then
      MetadataList.Row := Indx + 1;
    MetadataList.Refresh;
    MetadataList.SetFocus;
    SpeedBtnQuickSave.Enabled := true;
  end;

  if Key = VK_ESCAPE then
  begin
    if QuickTags[Indx - 1].NoEdit then
      TCustomEdit(Sender).Text := ''
    else
    begin
      if RightStr(MetadataList.Keys[Indx], 1) = #177 then
        TCustomEdit(Sender).Text := '+'
      else
        TCustomEdit(Sender).Text := MetadataList.Cells[1, Indx];
    end;
    MetadataList.SetFocus;
  end;
end;

procedure TFMain.ShowPreview;
var
{$IFDEF DEBUG}
  MetaData: TMetaData;
  Tag: string;
{$ENDIF}
  Foto: FotoRec;
  Rotate: integer;
  FPath: string;
  ABitMap: TBitmap;
  CrWait, CrNormal: HCURSOR;
begin
  RotateImg.Picture.Bitmap := nil;
  ABitMap := nil;
  if ShellList.SelCount > 0 then
  begin
    CrWait := LoadCursor(0, IDC_WAIT);
    CrNormal := SetCursor(CrWait);
    try
      FPath := ShellList.FilePath;
      Rotate := 0;
      if GUIsettings.AutoRotatePreview then
      begin
        Foto := GetMetadata(FPath, []);
        case Foto.IFD0.OrientationValue of
          0, 1:
            Rotate := 0; // no tag or don't rotate
          3:
            Rotate := 180;
          6:
            Rotate := 90;
          8:
            Rotate := 270;
        end;
 {$IFDEF DEBUG}
        MetaData := TMetaData.Create;
        try
          MetaData.ReadMeta(FPath, [gmXMP, gmGPS]);
          DebugMsg(['***', FPath, '***']);
          for Tag in MetaData.FieldNames do
            DebugMsg([Tag, MetaData.FieldData(Tag)]);
          DebugMsg(['=====================================']);
        finally
        MetaData.Free;
        end;
 {$ENDIF}
      end;
      ABitMap := GetBitmapFromWic(WicPreview(FPath, Rotate, RotateImg.Width, RotateImg.Height));
      if (ABitMap <> nil) then
        ResizeBitmapCanvas(ABitMap, RotateImg.Width, RotateImg.Height, GUIColorWindow)
      else
        ABitMap := ShellList.GetThumbNail(ShellList.Selected.Index, RotateImg.Width, RotateImg.Height);
      RotateImg.Picture.Bitmap := ABitMap;
    finally
      ABitMap.Free;
      SetCursor(CrNormal);
    end;
  end;
end;

procedure TFMain.Small1MeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
begin
  Height := 1;
end;

procedure TFMain.ViewPopupDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  StyledDrawMenuItem(Sender as TMenuItem, ACanvas, ARect, Selected,
                     FStyleServices, GUIsettings.GuiStyle <> cSystemStyleName, VirtualImageListFileList);
end;

procedure TFMain.ViewPopupClick(Sender: TObject);
var
  SavedPath: string;
begin
  with TMenuItem(Sender) do
  begin
    if (Tag < 0) then
    begin
      if (GroupIndex = 3) then
        EditFileLists(Sender);
      exit;
    end;
    SavedPath := ShellTree.Path;
    ShellList.Enabled := false;
    try
      Shelllist.ViewStyle := vsReport;
      ShellList.SortColumn := 0;
      ShellList.SortState := THeaderSortState.hssNone;
      if (GroupIndex = 1) then
      begin
        ShellList.ThumbNailSize := Tag;
        ShellList.ViewStyle := vsIcon;
      end
      else
      begin
        GUIsettings.DetailsSel := Tag;
      end;
      SetCaptionAndImage;
    finally
      ShellTree.Path := SavedPath;
      ShellList.Enabled := true;
      ShellList.Refresh;
      ShellList.SetFocus;
    end;
  end;
end;

procedure TFMain.FilterPopupDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  StyledDrawMenuItem(Sender as TMenuItem, ACanvas, ARect, Selected,
                     FStyleServices, GUIsettings.GuiStyle <> cSystemStyleName, VirtualImageListFileList);
end;

procedure TFMain.FilterPopupClick(Sender: TObject);
begin
  with TMenuItem(Sender) do
  begin
    if (Tag < 0) then
    begin
      EditFileFilter(Sender);
      exit;
    end;
    GUIsettings.FilterSel := Tag;
    Shelllist.IncludeSubFolders := ContainsText(GUIsettings.FileFilter, '/s');
    SetCaptionAndImage;
    ShellList.Refresh;
    ShellList.SetFocus;
  end;
end;

procedure TFMain.AdvPagePreviewResize(Sender: TObject);
begin
  ShowPreview;
end;

procedure TFMain.CBoxETdirectChange(Sender: TObject);
var
  Indx: integer;
begin
  Indx := CBoxETdirect.ItemIndex;
  if Indx >= 0 then
  begin
    EditETdirect.Text := ETdirectCmdList[Indx];
    EditETdirect.Modified := false;
    EditETcmdName.Text := CBoxETdirect.Text;
    EditETcmdName.Modified := false;
    SpeedBtnETdirectDel.Enabled := true; // Delete
  end
  else
    SpeedBtnETdirectDel.Enabled := false;
  SpeedBtnETdirectReplace.Enabled := false;
  SpeedBtnETdirectAdd.Enabled := false;
  if (EditETdirect.Showing) then
    EditETdirect.SetFocus;
end;

procedure TFMain.Selectnone1Click(Sender: TObject);
begin
  ShellList.ClearSelection;
end;

procedure TFMain.Selectnone2Click(Sender: TObject);
begin
  ShellList.ClearSelection;
end;

procedure TFMain.AlignStatusBar;
begin
  StatusBar.Panels[0].Width := AdvPageBrowse.Width + Splitter1.Width;
  StatusBar.Panels[1].Width := AdvPageFilelist.Width + Splitter2.Width;
end;

procedure TFMain.ApplicationMinimize(Sender: TObject);
begin
  if (GUIsettings.MinimizeToTray) then
  begin
    Application.Minimize;
    Hide;

    if (GUIsettings.ShowBalloon) then
    begin
      TrayIcon.ShowBalloonHint;
      TrayIcon.BalloonHint := StrMinimizedToTray + #10 +
                              StrClickToDisableThi;
    end
    else
      TrayIcon.BalloonHint := '';

    TrayIcon.Visible := true;
  end;
end;

procedure TFMain.FileListFilterMenuPopup(Sender: TObject);
var
  P: TPopupMenu;
  Filters: TStringList;
  Index: integer;

  function NewMenuItem(ACaption: string;
                       ATag: integer;
                       AGroup: integer;
                       AImageIndex: integer;
                       ACheck: boolean = false): TMenuItem;
  begin
    result := TMenuItem.Create(P);
    result.Caption := ACaption;
    result.Tag := ATag;
    result.GroupIndex := AGroup;
    result.ImageIndex := AImageIndex;
    if (ATag > -1) then
    begin
      result.AutoCheck := true;
      result.RadioItem := true;
    end;
    result.Checked := ACheck;
    if (GUIsettings.GuiStyle <> cSystemStyleName) then
      result.OnDrawItem := FilterPopupDrawItem;
    result.OnClick := FilterPopupClick;
    P.Items.Add(result);
  end;

begin
  if (ShellList.Enabled = false) then
    exit;

  P := Sender as TPopupMenu;
  P.Items.Clear;
  Filters := TStringList.Create;
  Filters.Text := GUIsettings.FileFilters;
  try
    for Index := 0 to Filters.Count -1 do
      NewMenuItem(Filters[Index], Index, 1, Img_Filter, (GUIsettings.FilterSel = Index));

    NewMenuItem('-',             -1, 0, Img_None);
    NewMenuItem(strConfigure,    -1, 1, Img_Configure);
  finally
    Filters.free;
  end;
end;

procedure TFMain.FileListViewMenuPopup(Sender: TObject);
var
  P: TPopupMenu;
  Index: integer;
  ImageIndex: integer;
  ThumbSize: integer;
  FileListDefs: TColumnSetList;
  AColumnSet: TColumnSet;

  function NewMenuItem(ACaption: string;
                       ATag: integer;
                       AGroup: integer;
                       AImageIndex: integer;
                       ACheck: boolean = false): TMenuItem;
  begin
    result := TMenuItem.Create(P);
    result.Caption := ACaption;
    result.Tag := ATag;
    result.GroupIndex := AGroup;
    result.ImageIndex := AImageIndex;
    if (ATag > -1) then
    begin
      result.AutoCheck := true;
      result.RadioItem := true;
    end;
    result.Checked := ACheck;
    if (GUIsettings.GuiStyle <> cSystemStyleName) then
      result.OnDrawItem := ViewPopupDrawItem;
    result.OnClick := ViewPopupClick;
    P.Items.Add(result);
  end;

begin
  if (ShellList.Enabled = false) then
    exit;

  P := Sender as TPopupMenu;
  P.Items.Clear;
  ImageIndex := Img_Thumb;
  NewMenuItem(StrThumbnails,  -1, 1, Img_None);
  NewMenuItem('-',            -1, 0, Img_None);

  for ThumbSize in DefThumbNailSizes do
    NewMenuItem(IntToStr(ThumbSize) + ThumbNailPix,
                ThumbSize, 1, ImageIndex,
                (ShellList.ViewStyle = vsIcon) and (ShellList.ThumbNailSize = ThumbSize));
  NewMenuItem('-',            -1, 0, Img_None);
  NewMenuItem(StrDetails,     -1, 2, Img_None);
  NewMenuItem('-',            -1, 0, Img_None);

  FileListDefs := GetFileListDefs;
  Index := 0;
  for AColumnSet in FileListDefs do
  begin
    if (ImageIndex < Img_LastDetail) then
      Inc(ImageIndex);
    NewMenuItem(AColumnSet.Name,       Index, 2, ImageIndex, (ShellList.ViewStyle = vsReport) and (GUIsettings.DetailsSel = Index));
    Inc(Index);
  end;

  NewMenuItem('-',             -1, 0, Img_None);
  NewMenuItem(strConfigure,    -1, 3, Img_Configure);
end;

procedure TFMain.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI, NewDPI: Integer);
begin
  GUIBorderWidth := Width - ClientWidth;
  GUIBorderHeight := Height - ClientHeight;

  AdvPanelETdirect.Height := ScaleDesignDpi(32);
  AdvPanelMetaBottom.Height := ScaleDesignDpi(32);
  Splitter2.MinSize := ScaleDesignDpi(320);

  MakeFullyVisible;
end;

procedure TFMain.FormCanResize(Sender: TObject; var NewWidth, NewHeight: integer; var Resize: boolean);
var
  N: integer;
begin
  if (WindowState <> wsMinimized) and
     (Showing) then
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

  SaveGUIini;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  Application.OnMinimize := ApplicationMinimize;

  ReadFormSizes(Self, Self.DefWindowSizes);
  ReadGUIini;

  // AdvPageFilelist.Constraints.MinWidth only used at design time. Form does not align well.
  // We check for MinFileListWidth in code.
  MinFileListWidth := AdvPageFilelist.Constraints.MinWidth;
  AdvPageFilelist.Constraints.MinWidth := 0;

  // Tray Icon
  TrayIcon.Hint := GetFileVersionNumberPlatForm(Application.ExeName);

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

  GetColorsFromStyle;
  SetColorsFromStyle;

  TStyleManager.TrySetStyle(GUIsettings.GuiStyle, false);

  // EdgeBrowser
  EdgeBrowser1.UserDataFolder := GetEdgeUserData;

  // Set properties of ShellTree in code.
  ShellTree.OnBeforeContextMenu := ShellTreeBeforeContext;
  ShellTree.OnAfterContextMenu := ShellTreeAfterContext;
  ShellTree.OnCustomDrawItem := ShellTreeCustomDrawItem;
  ShellTree.PreferredRoot := ShellTree.Root;

  // Set properties of Shelllist in code.
  ShellList.OnEnumColumnsBeforeEvent := ShellListBeforeEnumColumns;
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
  ShellList.OnCustomDrawItem := ShellListCustomDrawItem;
  Shelllist.IncludeSubFolders := ContainsText(GUIsettings.FileFilter, '/s');

  SetCaptionAndImage;

  // Metadatalist Ctrl handler
  MetadataList.OnCtrlKeyDown := MetadataListCtrlKeyDown;
  MetadataList.ProportionalVScroll := true;

  ET.ExecETEvent := ExecETEvent_Done;
  Geomap.ExecRestEvent := ExecRestEvent_Done;
end;

procedure TFMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCTRL in Shift) then
  begin
    case Key of
      Ord('A'):
      begin
        ShellListKeyDown(Sender, Key, Shift);
        Key := 0;
      end;
    end;
  end;
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
  FName: string;
  Index: integer;
begin
  NumFiles := DragQueryFile(Msg.Drop, UINT(-1), nil, 0);
  if NumFiles > 1 then
    ShowMessage(StrDropOnlyOneFileA)
  else
  begin
    LBuffer := DragQueryFile(Msg.Drop, 0, nil, 0) +1;
    SetLength(Buffer, LBuffer);
    DragQueryFile(Msg.Drop, 0, PBuffer, LBuffer);
    FName := PBuffer;

    ShellList.ItemIndex := -1;
    if (DirectoryExists(FName)) then
      ShellTree.Path := FName
    else
    begin
      ShellTree.Path := ExtractFileDir(FName);
      FName := ExtractFileName(FName);
      ShellList.Refresh;
      for Index := 0 to ShellList.Items.Count -1 do
      begin
        if ShellList.RelFileName(Index) = FName then
        begin
          ShellList.ItemIndex := Index;
          break;
        end;
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
  Param: string;
  Lat, Lon: string;
  Index: integer;
  PathFromParm: boolean;
begin

  if (ParmIniPath <> '') then
  begin
    if not SaveGUIini then
      Halt;
  end;

  if TrayIcon.Visible then
    exit;

  FSharedMem.RegisterOwner(Self.Handle, CM_ActivateWindow);

  SetCaption;

  OnAfterMonitorDpiChanged(Sender, 0, 0); // DPI Values are not used

  AdvPageMetadata.ActivePage := AdvTabMetadata;
  AdvPageFilelist.ActivePage := AdvTabFilelist;

  MaUpdateLocationfromGPScoordinates.Enabled := false;
  AdvTabOSMMap.Enabled := false;
  EdgeBrowser1.Visible := false;
  if GUIsettings.EnableGMap then
  begin
    try
      MaUpdateLocationfromGPScoordinates.Enabled := true;
      ParseLatLon(GUIsettings.DefGMapHome, Lat, Lon);
      OSMMapInit(EdgeBrowser1, Lat, Lon, OSMHome, InitialZoom_Out);
      AdvTabOSMMap.Enabled := true;
      EdgeBrowser1.Visible := true;
    except
      on E:Exception do
        MessageDlgEx(E.Message, StrErrorPositioningHo, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK]);
    end;
  end;

  // Init Chart
  AdvRadioGroup2Click(Sender);

  WrkIniDir := GetAppPath;
  DontSaveIni := FindCmdLineSwitch('DontSaveIni', true);

  // The shellList is initally disabled. Now enable and refresh
  PathFromParm := false;
  SetColorsFromStyle;
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
        for Index := 0 to ShellList.Items.Count -1 do
        begin
          if SameText(ShellList.RelFileName(Index), Param) then
          begin
            ShellList.ItemIndex := Index;
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

// Clicking Home for Desktop with IncludeSubfolders takes to long.
  ResetRootShowAll;

end;

procedure TFMain.ShellListAddItem(Sender: TObject; AFolder: TShellFolder; var CanAdd: boolean);
var
  FolderName: string;
  FilterItem, Filter: string;
  FilterMatches: boolean;
  CopyFolder: TSubShellFolder;
begin
  CanAdd := TShellListView(Sender).Enabled and not FrmStyle.Showing and ValidFile(AFolder);

  if (TShellListView(Sender).IncludeSubFolders) and
     (TSubShellFolder.GetIsFolder(AFolder)) then
  begin
    CanAdd := false;
    CopyFolder := TSubShellFolder.Create(AFolder.Parent, AFolder.RelativeID, AFolder.ShellFolder);
    CopyFolder.FRelativePath := TSubShellFolder.GetRelativeDisplayNameWithExt(AFolder);

    TShellListView(Sender).FoldersList.Add(CopyFolder);
    TShellListView(Sender).PopulateSubDirs(CopyFolder);
    exit;
  end;

  ProcessMessages;
  FolderName := TSubShellFolder.GetRelativeDisplayNameWithExt(AFolder);
  if (GUIsettings.FileFilter <> StrShowAllFiles) then
  begin
    Filter := GUIsettings.FileFilter;
    FilterMatches := TSubShellFolder.GetIsFolder(AFolder);
    while (FilterMatches = false) and (Filter <> '') do
    begin
      FilterItem := NextField(Filter, ';');
      if (LeftStr(FilterItem, 1) <> '/') then
        FilterMatches := MatchesMask(FolderName, FilterItem);
    end;
    CanAdd := CanAdd and FilterMatches;
  end;
end;

procedure TFMain.ShellListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  UpdateStatusBar_FilesShown;
end;

procedure TFMain.ShellListClick(Sender: TObject);
begin
  ShowPreview;
  ShowMetadata;
  SpeedBtnQuickSave.Enabled := false;

  EnableMenuItems;

  if (ShellList.IncludeSubFolders) then
    ShellTree.SyncShellTreeFromShellList;
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
  ListIndex: integer;
begin
  ColIndex := TListColumn(Sender).Tag;
  if (ColIndex < 1) then  // Name Field
    ListIndex := 0
  else
  begin
    ListIndex := GUIsettings.DetailsSel;
    if (ListIndex > 0) then
      Dec(ColIndex);
  end;

  if (ListIndex > GetFileListDefCount -1) then
    exit;
  if (ColIndex > High(GetFileListColumnDefs(ListIndex))) then
    exit;

  GetFileListColumnDefs(ListIndex)[ColIndex].Width := TListColumn(Sender).Width;
end;

procedure TFMain.ShellListCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  StyledDrawListviewItem(FStyleServices, Sender, Item, State);
end;

procedure TFMain.ShellListBeforeEnumColumns(Sender: TObject; var ReadModeOptions: TReadModeOptions; var ColumnDefs: TColumnsArray);
begin
  ReadModeOptions := GetFileListDefs[GUIsettings.DetailsSel].ReadMode;
  ColumnDefs := GetFileListDefs[GUIsettings.DetailsSel].ColumnDefs;
end;

procedure TFMain.ShellListAfterEnumColumns(Sender: TObject);

  procedure AdjustColumns(ColumnDefs: TColumnsArray);
  var
    I, J: integer;
  begin
    J := Min(High(ColumnDefs), ShellList.Columns.Count - 1);
    for I := 0 to J do
    begin
      ShellList.Columns[I].Width := ColumnDefs[I].Width;
      ShellList.Columns[I].Tag := I;
    end;
  end;

  procedure AddColumn(const ACaption: string; ATag, AWidth: integer; const AAlignment: integer = 0);
  begin
    with TShellListView(Sender).Columns.Add do
    begin
      Caption := ACaption;
      Width := AWidth;
      Tag := ATag;
      if (AAlignment > 0) then
        Alignment := taRightJustify;
    end;
  end;

  procedure AddColumns(ColumnDefs: TColumnsArray);
  var
    I: integer;
  begin
    with ShellList do
    begin
      Columns.Clear;
      AddColumn(TSubShellFolder.GetSystemField(ShellList.RootFolder, nil, 0), 0, GetFileListColumnDefs(0)[0].Width); // Name field
      for I := 0 to High(ColumnDefs) do
      begin
        if ((ColumnDefs[I].Options and toBackup) = toBackup) then
          continue;
        AddColumn(ColumnDefs[I].Caption, I +1, ColumnDefs[I].Width, ColumnDefs[I].AlignR);
      end;
    end;
  end;

begin

  if (ShellList.DetailsNeeded) then
    AddColumns(ShellList.ColumnDefs)
  else
  begin
    ShellList.AddDate;
    AdjustColumns(ShellList.ColumnDefs);
  end;

  // Update Sys and Country Columns
  UpdateSysColumns(ShellList.RootFolder);

  SetupCountry(ShellList.ColumnDefs, GeoSettings.CountryCodeLocation);

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
    if (LeftStr(ShellTree.PreferredRoot,2) = 'rf') then
      BreadcrumbBar.Home := Copy(ShellTree.PreferredRoot, 3)
    else
      BreadcrumbBar.Home := ShellTree.Items[0].Text;
    BreadcrumbBar.Directory := TShellListView(Sender).Path;
  end;

  // Start ExifTool in this directory
  ET_Active := ET.StayOpen(TShellListView(Sender).Path);

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
  EnableMenuItems;
end;

procedure TFMain.ShellListOwnerDataFetch(Sender: TObject; Item: TListItem; Request: TItemRequest; AFolder: TShellFolder);
var
  AShellList: TShellListView;
  ADetail: string;
  Details: TStrings;
begin
  AShellList := TShellListView(Sender);
  if not ShellList.Enabled then
    exit;

  if (AShellList.ViewStyle <> vsReport) then
    exit;

  // Need a valid TShellListFolder
  if not Assigned(AFolder) then
    exit;

  // The Item.ImageIndex (for small icons) should always be set
  if (irImage in Request) then
    Item.ImageIndex := AFolder.ImageIndex(false);

  // Get possibly cached Details
  Details := AFolder.DetailStrings;

  if (Details.Count = 0) then   // Only get details once
    GetFileListColumns(ShellList, ET, Item.Index);

  // Now add to Listview
  for ADetail in Details do
    Item.SubItems.Append(ADetail);

end;

procedure TFMain.ShellListDeletion(Sender: TObject; Item: TListItem);
begin // event is executed for each deleted file -so make it fast!
  RotateImg.Picture.Bitmap.Handle := 0;
  MetadataList.Strings.Clear;
end;

//Remove focus rectangle
procedure TFMain.ShellListEnter(Sender: TObject);
begin
// Keep for future use.
//  SendMessage(ShellList.Handle, WM_CHANGEUISTATE, UIS_Set + ($10000 * UISF_HIDEFOCUS), 0);
end;

procedure TFMain.ShellListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  procedure DeleteSelected;
  var
    Index: integer;
    CurIndex: integer;
    CrWait, CrNormal: HCURSOR;
  begin
    if (ShellList.SelCount = 0) then
      exit;

    CrWait := LoadCursor(0, IDC_WAIT);
    CrNormal := SetCursor(CrWait);
    ShellList.Items.BeginUpdate;
    try
      CurIndex := ShellList.Selected.Index -1;
      for Index := 0 to ShellList.Items.Count -1 do
      begin
        if (ListView_GetItemState(ShellList.Handle, Index, LVIS_SELECTED) <> LVIS_SELECTED) then
            Continue;
        DoContextMenuVerb(ShellList.Folders[Index], SCmdVerbDelete);
      end;

      ShellList.Refresh;
      if (CurIndex < 0) then
        CurIndex := 0;
      if (CurIndex > ShellList.Items.Count -1) then
        CurIndex := ShellList.Items.Count -1;
      ShellList.Selected := ShellList.Items[CurIndex];
      ShellList.ItemFocused := ShellList.Items[CurIndex];
    finally
      ShellList.Items.EndUpdate;
      SetCursor(CrNormal);
    end;
  end;

begin
  if (Key = Ord('A')) and (ssCTRL in Shift) then // Ctrl+A
    SelectAll;
  if (Key = Ord('C')) and (ssCTRL in Shift) then // Ctrl+C
    ShellList.FileNamesToClipboard;
  if (Key = Ord('X')) and (ssCTRL in Shift) then // Ctrl+X
    ShellList.FileNamesToClipboard(True);
  if (Key = Ord('V')) and (ssCTRL in Shift) then // Ctrl+V
    ShellList.PasteFilesFromClipboard;

  if (Key = VK_ADD) and (ssCtrl in Shift) then
    ShellList.SetIconSpacing(1, 0);
  if (Key = VK_SUBTRACT) and (ssCtrl in Shift) then
    ShellList.SetIconSpacing(-1, 0);
  if ((Key = Ord('0')) or (Key = VK_NUMPAD0)) and (ssCtrl in Shift) then
    ShellList.SetIconSpacing(0, 0);
  if (Key = VK_F2) and (ShellList.Selected <> nil) then
    ShellList.Selected.EditCaption;
{$IFDEF NOTYET}
  if (Key = VK_DELETE) and (ssCtrl in Shift) then
    DeleteSelected;
{$ENDIF}
end;

procedure TFMain.ShellListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_HOME,
    VK_END,
    VK_UP,
    VK_DOWN,
    VK_LEFT,
    VK_RIGHT,
    VK_PRIOR,
    VK_NEXT:
      ShellListClick(Sender);
  end;
end;

procedure TFMain.ShellListSetFolders;
var Value: TShellObjectTypes;

  function AddHiddenIfAllowed(ObjectTypes: TShellObjectTypes): TShellObjectTypes;
  begin
    result := ObjectTypes;
    if GUIsettings.CanShowHidden then
      include(result, TShellObjectType.otHidden)
    else
      exclude(result, TShellObjectType.otHidden);
  end;

begin
  Value := AddHiddenIfAllowed(ShellList.ObjectTypes);
  if (GUIsettings.ShowFolders) then
    include(Value, TShellObjectType.otFolders)
  else
    exclude(Value, TShellObjectType.otFolders);
  if (Value <> ShellList.ObjectTypes) then
    ShellList.ObjectTypes := Value;

  Value := AddHiddenIfAllowed(ShellTree.ObjectTypes);
  if (Value <> ShellTree.ObjectTypes) then
    ShellTree.ObjectTypes := Value;

  PnlBreadCrumb.Visible := GUIsettings.ShowBreadCrumb;
  BreadcrumbBar.ShowHiddenDirs := GUIsettings.CanShowHidden;
end;

procedure TFMain.EnableMenus(Enable: boolean);
begin
  MenusEnabled := Enable;
  EnableMenuItems;

  AdvPageMetadata.Enabled := Enable;
  AdvPanelETdirect.Enabled := Enable;
  TbFileList.Enabled := Enable;

  if not Enable then
    if (MessageDlgEx(StrERRORExifTool1 + #10 +  #10 +
        StrERRORExifTool2 + #10 +
        StrERRORExifTool3 + GetAppPath + #10 +
        StrERRORExifTool4 + #10 + #9 +
        StrERRORExifTool5 + #10 + #9 +
        StrERRORExifTool6 + #10 +
        StrERRORExifTool7 + #10 + #10 +
        StrERRORExifTool8 + #10 + #10 +
        StrERRORExifTool9 + #10 + #10 +
        StrShowOnlineHelp, '',
        TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]) = ID_YES) then
      ShellExecute(0, 'Open', PWideChar(StringResource(ETD_Online_Doc) + StringResource(ETD_Reqs)), '', '', SW_SHOWNORMAL);

end;

procedure TFMain.StyledDraw(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  StyledDrawMenuItem(Sender as TMenuItem, ACanvas, ARect, Selected,
                     FStyleServices, GUIsettings.GuiStyle <> cSystemStyleName, VirtualImageListFileList);
end;

procedure TFMain.EnableMenuItems;
var
  EnableItem: boolean;
  Indx: integer;
begin
//  0: Program (Has also 99, never disable)
// 10: Options
// 20: Export/Import
// 25: Export/Import, Only if not include sub folders
// 30: Modify
// 40: Various
// 50: Help

  EnableItem := (ShellList.SelCount > 0);
  for Indx := 0 to MainActionManager.ActionCount -1 do
  begin

    case MainActionManager.Actions[Indx].Tag of
      50, 99:
        continue;
      20, 30, 40:
        MainActionManager.Actions[Indx].Enabled := MenusEnabled and EnableItem;
      25:
        MainActionManager.Actions[Indx].Enabled := MenusEnabled and EnableItem and (ShellList.IncludeSubFolders = false);
      else
        MainActionManager.Actions[Indx].Enabled := MenusEnabled;
    end;
  end;
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

procedure TFMain.ShellTreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if (Node.Selected ) then
    Sender.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsBold];
end;

procedure TFMain.ShellTreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('C')) then
    ShellTree.FileNamesToClipboard(false);
  if (ssCtrl in Shift) and (Key = Ord('X')) then
    ShellTree.FileNamesToClipboard(true);
  if (ssCtrl in Shift) and (Key = Ord('V')) then
    ShellTree.PasteFilesFromClipboard;
end;

procedure TFMain.RefreshSelected(Sender: TObject);
begin
  ShellList.RefreshSelected;
end;

procedure TFMain.Tray_ResetwindowsizeClick(Sender: TObject);
begin
  RestoreGUI;
  ResetWindowSizes;
  Realign;
end;

// Close Exiftool before context menu. Delete directory fails
procedure TFMain.ShellTreeBeforeContext(Sender: TObject);
begin
  ET.OpenExit;
end;

// Restart Exiftool when context menu done.
procedure TFMain.ShellTreeAfterContext(Sender: TObject);
begin
  if (ValidDir(ShellList.Path)) then
    ET.StayOpen(ShellList.Path);
end;

procedure TFMain.SelectAll;
var
  ClosedByUser: boolean;
begin
  FrmGenerate.Show;
  SendMessage(FrmGenerate.Handle, CM_SubFolderSort, ShellList.Items.Count, LPARAM(ShellList.Path));
  try
    GetAllFileListColumns(ShellList, FrmGenerate);
  finally
    ClosedByUser := boolean(SendMessage(FrmGenerate.Handle, CM_WantsToClose, 0, 0));
    FrmGenerate.Close;
  end;

  if not ClosedByUser then
    ShellList.SelectAll;
end;

procedure TFMain.Selectall1Click(Sender: TObject);
begin
  SelectAll;
end;

procedure TFMain.Selectall2Click(Sender: TObject);
begin
  SelectAll;
end;

procedure TFMain.SetCaption(AnItem: string = '');
var
  NewCaption: string;
begin
  NewCaption := '';
  if (IsElevated) then
    NewCaption := StrAdministrator + ' ';
  NewCaption := NewCaption + Application.Title;
  if (AnItem <> '') then
    NewCaption := NewCaption + ' - ' + AnItem;
  Caption := NewCaption
end;

// =========================== Show Metadata ====================================
procedure TFMain.ShowMetadata;
var
  E, N, SavedRow: integer;
  ETcmd, Item, Value, Tx: string;
  ETResult: TStringList;
  NoChars:  TSysCharSet;
begin
  MetadataList.Tag := -1; // Reset hint row
  Item := GetSelectedFile(ShellList.RelFileName);
  SetCaption(Item);
  if (Item = '') then
  begin
    with MetadataList do
    begin
      Row := 1;
      Strings.Clear;
    end;
    EditQuick.Text := '';
    MemoQuick.Text := '';
    exit;
  end;

  SavedRow := MetadataList.Row;
  MetadataList.Row := 1;

  ETResult := TStringList.Create;
  try
    if SpeedBtnQuick.Down then
    begin
      N := Length(QuickTags) - 1;
      ETcmd := GUIsettings.Fast3(ShellList.FileExt) + '-s3' + CRLF + '-f';

      for E := 0 to N do
      begin
        Tx := QuickTags[E].Command;
        if UpperCase(LeftStr(tx, Length(GUI_SEP))) = GUI_SEP then
          Tx := GUI_SEP;
        ETcmd := ETcmd + CRLF + Tx;
      end;
      ET.OpenExec(ETcmd, Item, ETResult, false);
      N := Min(N, ETResult.Count - 1);
      with MetadataList do
      begin
        Strings.BeginUpdate;
        try
          Strings.Clear;
          if (ETResult.Count < Length(QuickTags)) and
             (ETResult.Count > 0) then
            Strings.Append(Format('=' + StrWarningOnlyDRes,
                                  [ETResult.Count, Length(QuickTags)]));
          for E := 0 to N do
          begin
            Tx := QuickTags[E].Command;
            if UpperCase(LeftStr(Tx, Length(GUI_SEP))) = GUI_SEP then
              Tx := '=' + QuickTags[E].Caption
            else
            begin
              Tx := QuickTags[E].Caption;
              if (Pos('?', Tx) > 0) then
              begin
                Include(NoChars, '-');
                if (Pos('??', Tx) > 0) then
                  Include(NoChars, '0');

                if (Length(ETResult[E]) < 1) or
                   (CharInSet(ETResult[E][1], NoChars)) then
                 Tx := Tx + '='+ StrNOAst
                else
                  Tx := Tx + '=' + StrYESAst;
              end
              else
                Tx := QuickTags[E].Caption + '=' + ETResult[E];
            end;
            Strings.Append(Tx);
          end;
        finally
          Strings.EndUpdate;
        end;
      end;
    end
    else
    begin
      ETcmd := GUIsettings.Fast3(ShellList.FileExt);
      if MaGroup_g4.Checked then
        ETcmd := ETcmd + '-g4' + CRLF
      else
        ETcmd := ETcmd + '-g1' + CRLF;
      if not MaNotDuplicated.Checked then
        ETcmd := ETcmd + '-a' + CRLF;
      if MaShowSorted.Checked then
        ETcmd := ETcmd + '-sort' + CRLF;
      if MaShowHexID.Checked then
        ETcmd := ETcmd + '-H' + CRLF;
      if ET.Options.ETLangDef = '' then
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
        if not MaShowComposite.Checked then
          ETcmd := ETcmd + CRLF + '-e';
      end;

      if SpeedBtnCustom.Down then
      begin
        if (Trim(CustomViewTagList) = '') then
        begin
          // Show only message, no data.
          ETcmd := ETcmd + '-f' + CRLF +  '-Echo' + CRLF + StrNoCustomTags;
          Item := '';
        end
        else
        begin
          ETcmd := ETcmd + '-f' + CRLF + CustomViewTagList;
          E := Length(ETcmd);
          SetLength(ETcmd, E - 1); // remove last space char
          ETcmd := ReplaceAll(ETcmd, [' '], [CRLF]);
        end;
      end;

      ET.OpenExec(ETcmd, Item, ETResult, false);
      E := 0;
      if ETResult.Count = 0 then
      begin
        ETResult.Append('=' + StrExifToolExecuted);
        ETResult.Append('=' + StrNoData);
      end
      else
      begin
        while E < ETResult.Count do
        begin
          Value := ETResult[E];
          N := Pos(': ', Value);
          if (N < 1) then
            ETResult[E] := '=' + Value // Header
          else
            ETResult[E] := Trim(Copy(Value, 1, N -1)) + '=' + Copy(Value, N +2); // Normal Tag
          Inc(E);
        end;
      end;

      with MetadataList do
      begin
        Strings.BeginUpdate;
        try
          Strings.Clear;
          Strings.AddStrings(ETResult);
        finally
          Strings.EndUpdate;
        end;
      end;
    end;
    if MetadataList.RowCount > SavedRow then
      MetadataList.Row := SavedRow
    else
      MetadataList.Row := MetadataList.RowCount - 1;
  finally
    ETResult.Free;
  end;
end;

// ==============================================================================
procedure TFMain.SpbRecordClick(Sender: TObject);
begin
  if (ET.RecordingFile <> '') then
    ET.RecordingFile := ''
  else
  begin
    with SaveFileDlg do
    begin
      InitialDir := ShellList.Path;
      DefaultExt := 'txt';
      Filter := 'Txt file (*.txt)|*.txt|' +
                'Csv file (*.csv)|*.csv|' +
                'Html file (*.html)|*.html|' +
                'Any file (*.*)|*.*';
      Title := 'Record ExifTool output';

      if (Execute) then
        ET.RecordingFile := FileName;
    end;
  end;
  if (ET.RecordingFile = '') then
    TSpeedButton(Sender).ImageIndex := 15
  else
    TSpeedButton(Sender).ImageIndex := 16;
end;

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
  Indx: integer;
  ETFocal, ETFnum, ETISO: TNrSortedStringList;

  CrWait, CrNormal: HCURSOR;
begin
  Ext := '*.*';
  if AdvRadioGroup1.ItemIndex > 0 then
    Ext := '*.' + AdvRadioGroup1.Items[AdvRadioGroup1.ItemIndex];
  ETBarSeriesFocal.Clear;
  ETBarSeriesFnum.Clear;
  ETBarSeriesIso.Clear;

  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  ETFocal := TNrSortedStringList.Create;
  ETFnum := TNrSortedStringList.Create;
  ETISO := TNrSortedStringList.Create;
  try
    ChartFindFiles(ShellList.Path, Ext,
                   AdvCheckBox_Subfolders.Checked,
                   AdvCheckBox_Zeroes.Checked,
                   ETFocal, ETFnum, ETISO);

    ETFocal.Sort;
    for Indx := 0 to ETFocal.Count -1 do
      ETBarSeriesFocal.AddBar(ETFocal.GetValue(Indx), ETFocal.KeyNames[Indx], GUIsettings.CLFocal);

    ETFnum.Sort;
    for Indx := 0 to ETFnum.Count -1 do
      ETBarSeriesFnum.AddBar(ETFnum.GetValue(Indx), ETFnum.KeyNames[Indx], GUIsettings.CLFNumber);

    ETISO.Sort;
    for Indx := 0 to ETISO.Count -1 do
      ETBarSeriesIso.AddBar(ETISO.GetValue(Indx), ETISO.KeyNames[Indx], GUIsettings.CLISO);

  finally
    ETFocal.Free;
    ETFnum.Free;
    ETISO.Free;
    SetCursor(CrNormal);
  end;

  AdvRadioGroup2Click(Sender);
end;

procedure TFMain.SpeedBtnExifClick(Sender: TObject);
begin
  AdvPanelMetaBottom.Visible := SpeedBtnQuick.Down;
  SpeedBtnQuickSave.Enabled := false;
  ShowMetadata;
end;

procedure TFMain.SpeedBtnFilterEditClick(Sender: TObject);
begin
  EditFileFilter(Sender);
end;

procedure TFMain.SpeedBtnLargeClick(Sender: TObject);
var
  F: integer;
begin
  F := ShellList.ItemIndex;
  if SpeedBtnLarge.Down then
  begin
    MemoQuick.Clear;
    MemoQuick.Text := EditQuick.Text;
    EditQuick.Visible := false;
    AdvPanelMetaBottom.Height := ScaleDesignDpi(105);
    if F <> -1 then
      MemoQuick.SetFocus;
  end
  else
  begin
    EditQuick.Text := MemoQuick.Text;
    AdvPanelMetaBottom.Height := ScaleDesignDpi(32);
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
  H: integer;
begin
  if SpeedBtn_ETdirect.Down then
  begin
    if SpeedBtn_ETedit.Down then
      H := 184 // min 181
    else
      H := 105;
    AdvPanelETdirect.Height := ScaleDesignDpi(H);
    EditETdirect.SetFocus;
  end
  else
  begin
    AdvPanelETdirect.Height := ScaleDesignDpi(32);
    ShellList.SetFocus;
  end;
end;

procedure TFMain.SpeedBtn_ETdSetDefClick(Sender: TObject);
begin
  GUIsettings.ETdirDefCmd := CBoxETdirect.ItemIndex;
end;

procedure TFMain.SpeedBtn_ETeditClick(Sender: TObject);
var
  H: integer;
begin
  if SpeedBtn_ETedit.Down then
    H := 181
  else
    H := 105;
  AdvPanelETdirect.Height := ScaleDesignDpi(H);
end;

procedure TFMain.SpeedBtn_GeotagClick(Sender: TObject);
begin
  ParseLatLon(EditMapFind.Text, FGeotagFiles.Lat, FGeotagFiles.Lon);
  if not (ValidLatLon(FGeotagFiles.Lat, FGeotagFiles.Lon)) then
  begin
    MessageDlgEx(StrNoValidLatLon, '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
    exit;
  end;

  if ShellList.SelectedFolder = nil then
  begin
    MessageDlgEx(StrNoFilesSelected, '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
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
  DeleteFile(GetTrackTmp);
  MapGotoPlace(EdgeBrowser1, GUIsettings.DefGMapHome, '', OSMHome, InitialZoom_Out);
end;

procedure TFMain.SpeedBtn_MapSetHomeClick(Sender: TObject);
begin
  GUIsettings.DefGMapHome := EditMapFind.Text;
end;

procedure TFMain.SpeedBtn_ShowOnMapClick(Sender: TObject);
begin
  if ShellList.SelectedFolder <> nil then
    ShowImagesOnMap(EdgeBrowser1, ShellList.Path, GetGpsCoordinates(GetSelectedFiles))
  else
    ShowMessage(StrNoFilesSelected);
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

procedure TFMain.GetColorsFromStyle;
begin
  GUIColorWindow := clWhite;
  GUIColorShellTree := GUIColorWindow;
  GUIColorShellList := GUIColorWindow;

  FStyleServices := TStyleManager.Style[GUIsettings.GuiStyle];
  if Assigned(FStyleServices) then
  begin
    GUIColorWindow := FStyleServices.GetStyleColor(scWindow);
    GUIColorShellTree := FStyleServices.GetStyleColor(scTreeView);;
    GUIColorShellList :=  FStyleServices.GetStyleColor(scListView);
  end;
end;

procedure TFMain.SetColorsFromStyle;
begin
  BreadcrumbBar.Style := GUIsettings.GuiStyle;
  BreadcrumbBar.Color := GUIColorWindow;
  ShellTree.Color := GUIColorShellTree;
  ShellList.Color := GUIColorShellList;
  ShellList.BkColor := GUIColorWindow;
end;

procedure TFMain.ShellistThumbError(Sender: TObject; Item: TListItem; E: Exception);
begin
  raise Exception.Create(Format(StrErrorSSCreating, [E.Message, #10, ShellList.Folders[Item.Index].PathName]));
end;

procedure TFMain.ShellistThumbGenerate(Sender: TObject; Item: TListItem; Status: TThumbGenStatus; Total, Remaining: integer);
begin
  if (Remaining > 0) then
    StatusBar.Panels[1].Text := Format(StrRemainingThumbnails, [Remaining])
  else
    StatusBar.Panels[1].Text := '';
end;

procedure TFMain.CounterETEvent(Counter: integer);
begin
  StatusBar.Panels[1].Text := Format(StrDFilesRemaining, [Counter]);
  StatusBar.Update;
end;

procedure TFMain.Csv1Click(Sender: TObject);
begin
  with SaveFileDlg do
  begin
    DefaultExt := 'csv';
    if GUIsettings.DefExportUse then
      InitialDir := GUIsettings.DefExportDir
    else
      InitialDir := ShellList.Path;
    Filter := 'Csv file|*.csv';
    Title := 'Export';
    if Execute then
      ExportToCsv(ShellList, FileName);
  end;
end;

end.

