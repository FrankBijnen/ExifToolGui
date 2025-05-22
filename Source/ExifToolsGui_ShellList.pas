unit ExifToolsGui_ShellList;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Threading, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, Winapi.ShlObj, Winapi.ActiveX,
  Vcl.Shell.ShellCtrls, Vcl.Shell.ShellConsts, Vcl.ComCtrls, Vcl.Menus, Vcl.Controls, Vcl.Graphics,
  ExifToolsGUI_Thumbnails, ExifToolsGUI_MultiContextMenu, UnitColumnDefs;

// Extend ShellListview, keeping the same Type. So we dont have to register it in the IDE
// Extended to support:
// Thumbnails.
// User defined columns.
// Column sorting.
// Multi-select context menu, with custom menu items. (For Refresh and generate thumbs)
// Copy selected files to and from Clipboard
// You need to make some modifications to the Embarcadero source. See the readme in the Vcl.ShellCtrls dir.

type
  THeaderSortState = (hssNone, hssAscending, hssDescending);
  TThumbGenStatus = (Started, Ended);

  TThumbErrorEvent = procedure(Sender: TObject; Item: TListItem; E: Exception) of object;
  TThumbGenerateEvent = procedure(Sender: TObject; Item: TListItem; Status: TThumbGenStatus; Total, Remaining: integer) of object;
  TOwnerDataFetchEvent = procedure(Sender: TObject; Item: TListItem; Request: TItemRequest; AFolder: TShellFolder) of object;
  TEnumColumnsEvent = procedure(Sender: TObject; var FileListOptions: TReadModeOptions; var ColumnDefs: TColumnsArray) of object;

  TRelativeNameType = (rnDisplay, rnFile, rnSort, rnShellPath);

  TSubShellFolder = class(TShellFolder)
    FRelativePath: string;
    function RelativePath: string;
    class function GetName(Folder: TShellFolder;
                                   RelativeNameType: TRelativeNameType): string;
    class function GetRelativeName(Folder: TShellFolder;
                                   RelativeNameType: TRelativeNameType): string;
  public
    destructor Destroy; override;
    // Safe versions, to prevent AV's.
    class function HasParentShellFolder(Folder: TShellFolder): boolean;
    class function GetIsFolder(Folder: TShellFolder): boolean;
    // Get File names:
    // For display. Respect the Explorer option 'Hide extensions for known file types'
    class function GetRelativeDisplayName(Folder: TShellFolder): string;
    // For File I/O. Includes the etension.
    class function GetRelativeFileName(Folder: TShellFolder): string;
    // For Sorting. The files in the root folder are prefixed with a space, so they will be first.
    class function GetRelativeSortName(Folder: TShellFolder): string;
    // Query System fields. (Name, Size, Type, Date modified, Date created etc.)
    class procedure AllFastSystemFields(RootFolder: TShellFolder; FieldList: TStrings);
    class function SystemFieldIsDate(RootFolder: TShellFolder; Column: integer): boolean;
    // Get a system field
    class function GetSystemField(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
    // Same, but for multi-threading.
    class function GetSystemField_MT(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
    // Not used
    class function GetSystemFieldEx(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
  end;

  TShellListView = class(Vcl.Shell.ShellCtrls.TShellListView, IShellCommandVerbExifTool, IDropSource)
  private
    FHiddenFolders: TList;
    FThreadPool: TThreadPool;
    FThumbTasks: Tlist;
    FPopulating: boolean;
    FDoDefault: boolean;
    FSubFolders: WPARAM;
    FIncludeSubFolders: boolean;

    FColumnDefs: TColumnsArray;
    FReadModeOptions: TReadModeOptions;
    FOnColumnResized: TNotifyEvent;
    FColumnSorted: boolean;
    FSortColumn: integer;
    FSortState: THeaderSortState;

    FBkColor: TColor;
    FHourGlassId: integer;
    FThumbNails: TImageList;
    FThumbNailSize: integer;
    FGenerating: integer;
    FThumbAutoGenerate: boolean;
    // Thumbnail cache. An index for every item in FThumbNails
    //
    // > 1 The index to use for FThumbNails. Minus 1!
    // = 0 The index needs to be generated. Displayed as an hourglass
    // < 1 A temporary icon to display, until the thumbnail is generated. The actual index in FThumbNails is * -1
    FThumbNailCache: array of integer;
    FOnNotifyErrorEvent: TThumbErrorEvent;
    FOnNotifyGenerateEvent: TThumbGenerateEvent;
    FOnPopulateBeforeEvent: TNotifyEvent;
    FOnEnumColumnsBeforeEvent: TEnumColumnsEvent;
    FOnEnumColumnsAfterEvent: TNotifyEvent;
    FOnPathChange: TNotifyEvent;
    FOnItemsLoaded: TNotifyEvent;
    FOnOwnerDataFetchEvent: TOwnerDataFetchEvent;
    ICM2: IContextMenu2;
    FDragStartPos: TPoint;
    FDragSource: boolean;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;
    function QueryContinueDrag(fEscapePressed: BOOL; grfKeyState: Longint): HResult; stdcall;

    procedure SetColumnSorted(AValue: boolean);
    procedure ClearHiddenItems;
    procedure InitThumbNails;
    procedure SetThumbNailSize(AValue: integer);
    procedure SetBkColor(Value: TColor);

    procedure CMThumbStart(var Message: TMessage); message CM_ThumbStart;
    procedure CMThumbEnd(var Message: TMessage); message CM_ThumbEnd;
    procedure CMThumbError(var Message: TMessage); message CM_ThumbError;
    procedure CMThumbRefresh(var Message: TMessage); message CM_ThumbRefresh;
    procedure RefreshTreeViewAfterContext;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure WMNotify(var Msg: TWMNotify); message WM_NOTIFY;
    procedure InitSortSpec(SortColumn: integer; SortState: THeaderSortState);
    procedure ColumnSort; virtual;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure EnumColumns; override;
    procedure GetThumbNails; virtual;
    procedure DoContextPopup(MousePos: TPoint; var Handled: boolean); override;
    procedure Edit(const Item: TLVItem); override;
    procedure Populate; override;
    function OwnerDataFetch(Item: TListItem; Request: TItemRequest): boolean; override;
    function OwnerDataFind(Find: TItemFind; const FindString: string;
      const FindPosition: TPoint; FindData: Pointer; StartIndex: Integer;
      Direction: TSearchDirection; Wrap: Boolean): Integer; override;
    procedure Add2ThumbNails(ABitMap: TBitmap; ANitemIndex: integer; NeedsGenerating: boolean); overload;
    procedure Add2ThumbNails(ABmp: HBITMAP; ANitemIndex: integer; NeedsGenerating: boolean); overload;
    procedure CancelThumbTasks;
    procedure RemoveThumbTask(ItemIndex: integer);
    procedure ShowMultiContextMenu(MousePos: TPoint);
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    function DetailsNeeded: boolean;
    procedure ClearSelection; override;
    procedure SelectAll; override;
    procedure SaveSelection(SaveSelection: Tlist<integer>);
    procedure RestoreSelection(SaveSelection: Tlist<integer>);
    procedure Refresh;
    procedure RefreshSelected;
    procedure AddDate; // Adds next columns if it is a Date.
    function Path: string;
    function ShellPath: string;
    function GetSelectedFolder(ItemIndex: integer): TShellFolder;
    function FilePath(ItemIndex: integer = -1): string;
    function RelDisplayName(ItemIndex: integer = -1): string;
    function RelFileName(ItemIndex: integer = -1): string;
    function FileExt(ItemIndex: integer = -1): string;
    procedure ColumnClick(Column: TListColumn);
    function CreateSelectedFoldersList(FullPaths: boolean): TStringList;
    procedure FileNamesToClipboard(Cut: boolean = false);
    procedure PasteFilesFromClipboard;
    procedure PopulateSubDirs(FRelativeFolder: TSubShellFolder);
    procedure ExecuteCommandExif(Verb: string; var Handled: boolean);
    procedure CommandCompletedExif(Verb: String; Succeeded: Boolean);
    procedure ShellListOnGenerateReady(Sender: TObject);
    function GetIconSpacing: dword;
    procedure SetIconSpacing(Cx, Cy: word); overload;
    procedure SetIconSpacing(Cx, Cy: integer); overload;
    function GetThumbNailSize(ItemIndex, W, H: integer; DefThumbType: TThumbType = ttThumbBiggerCache): TPoint;
    function GetThumbNail(ItemIndex, W, H: integer; DefThumbType: TThumbType = ttThumbBiggerCache): TBitmap;
    procedure SetFocus; override;

    property OnColumnResized: TNotifyEvent read FOnColumnResized write FOnColumnResized;
    property ColumnSorted: boolean read FColumnSorted write SetColumnSorted;
    property SortColumn: integer read FSortColumn write FSortColumn;
    property SortState: THeaderSortState read FSortState write FSortState;
    property BkColor: TColor read FBkColor write SetBkColor;
    property ThumbNailSize: integer read FThumbNailSize write SetThumbNailSize;
    property ThumbAutoGenerate: boolean read FThumbAutoGenerate write FThumbAutoGenerate;
    property OnThumbError: TThumbErrorEvent read FOnNotifyErrorEvent write FOnNotifyErrorEvent;
    property OnThumbGenerate: TThumbGenerateEvent read FOnNotifyGenerateEvent write FOnNotifyGenerateEvent;
    property Generating: integer read FGenerating;
    property OnPopulateBeforeEvent: TNotifyEvent read FOnPopulateBeforeEvent write FOnPopulateBeforeEvent;
    property OnEnumColumnsBeforeEvent: TEnumColumnsEvent read FOnEnumColumnsBeforeEvent write FOnEnumColumnsBeforeEvent;
    property OnEnumColumnsAfterEvent: TNotifyEvent read FOnEnumColumnsAfterEvent write FOnEnumColumnsAfterEvent;
    property ColumnDefs: TColumnsArray read FColumnDefs write FColumnDefs;
    property ReadModeOptions: TReadModeOptions read FReadModeOptions write FReadModeOptions;
    property OnPathChange: TNotifyEvent read FOnPathChange write FOnPathChange;
    property OnItemsLoaded: TNotifyEvent read FOnItemsLoaded write FOnItemsLoaded;
    property OnOwnerDataFetchEvent: TOwnerDataFetchEvent read FOnOwnerDataFetchEvent write FOnOwnerDataFetchEvent;
    property OnMouseWheel;
    property OnCustomDrawItem;
    property IncludeSubFolders: boolean read FIncludeSubFolders write FIncludeSubFolders;
    property DragSource: boolean read FDragSource write FDragSource;
  end;

implementation

uses System.Win.ComObj, System.UITypes, System.StrUtils, System.Math,
     Vcl.ImgList,
     ExifToolsGUI_Utils, ExifToolsGui_ThreadPool, ExifToolsGui_FileListColumns,
     UnitFilesOnClipBoard, UnitLangResources, UFrmGenerate;

// res file contains the Hourglass

{$R ShellList.res}

const
  HOURGLASS = 'HOURGLASS';
  HOURGLASS_TRANSPARENT = $ff00ff;

{$IFDEF VER350}
  Arrow_Up = #$25b2;
  Arrow_Down = #$25bc;
{$ENDIF}

{ Listview Sort helpers }

function GetListHeaderSortState(HeaderLView: TCustomListView; Column: TListColumn): THeaderSortState;
var
  Header: HWND;
  Item: THDItem;
begin
  Header := ListView_GetHeader(HeaderLView.Handle);
  ZeroMemory(@Item, SizeOf(Item));
  Item.Mask := HDI_FORMAT;
  Header_GetItem(Header, Column.Index, Item);
  if Item.fmt and HDF_SORTUP <> 0 then
    Result := hssAscending
  else if Item.fmt and HDF_SORTDOWN <> 0 then
    Result := hssDescending
  else
    Result := hssNone;
end;

procedure SetListHeaderSortState(HeaderLView: TCustomListView; Column: TListColumn; Value: THeaderSortState);
var
  Header: HWND;
  Item: THDItem;
begin
  Header := ListView_GetHeader(HeaderLView.Handle);
  ZeroMemory(@Item, SizeOf(Item));
  Item.Mask := HDI_FORMAT;
  Header_GetItem(Header, Column.Index, Item);
  Item.fmt := Item.fmt and not(HDF_SORTUP or HDF_SORTDOWN); // remove both flags
  case Value of
    hssAscending:
      begin
        // Add an arrow to the caption. Using styles doesn't show the arrows in the header
{$IFDEF VER350}
        if (Column.Caption[Length(Column.Caption)] <> Arrow_Up) then
          Column.Caption := Column.Caption + ' ' + Arrow_Up;
{$ENDIF}
        Item.fmt := Item.fmt or HDF_SORTUP;
      end;
    hssDescending:
      begin
        // Add an arrow to the caption.
{$IFDEF VER350}
        if (Column.Caption[Length(Column.Caption)] <> Arrow_Down) then
          Column.Caption := Column.Caption + ' ' + Arrow_Down;
{$ENDIF}
        Item.fmt := Item.fmt or HDF_SORTDOWN;
      end;
  end;
  Header_SetItem(Header, Column.Index, Item);
end;

{ TSubShellFolder helpers }

function StrRetToStr(StrRet: TStrRet; PIDL: PItemIDList): string;
var
  P: PAnsiChar;
begin
  result := '';
  case StrRet.uType of
    STRRET_WSTR:
      if Assigned(StrRet.pOleStr) then
      begin
        Result := StrRet.pOleStr;
        CoTaskMemFree(StrRet.pOleStr); // Need to free!
      end;
    STRRET_OFFSET:  // Not used. is Ansi.
      begin
        P := @PIDL.mkid.abID[StrRet.uOffset - SizeOf(PIDL.mkid.cb)];
        SetString(Result, P, PIDL.mkid.cb - StrRet.uOffset);
      end;
    STRRET_CSTR:    // Not used. is Ansi.
      SetString(Result, StrRet.cStr, lStrLenA(StrRet.cStr));
  end;
end;

// This function returns a filename + ext. We need this for File I/O functions.
// Contrary to Folder.GetDisplayName, that will only return the ext if the Explorer option
// 'Hide extensions for known file types' is unchecked.
function GetFileNameFromFindData(ParentFolder: IShellFolder; PIDL: PItemIDList): string;
var
  FindData: WIN32_FIND_DATA;
begin
  result := '';
  if (ParentFolder <> nil) and
     (SHGetDataFromIDList(ParentFolder, PIDL, SHGDFIL_FINDDATA, @FindData, SizeOf(WIN32_FIND_DATA)) = S_OK) then
    result := FindData.cFileName;
end;

{ TSubShellFolder }

destructor TSubShellFolder.Destroy;
begin
  FRelativePath := '';
  inherited;
end;

function TSubShellFolder.RelativePath: string;
begin
  result := FRelativePath;
  if not (TSubShellFolder.GetIsFolder(Self)) and
     (result <> '') then
    result := IncludeTrailingPathDelimiter(result);
end;

class function TSubShellFolder.HasParentShellFolder(Folder: TShellFolder): boolean;
begin
  result := (Folder <> nil) and
            (Folder.Parent <> nil) and
            (Folder.ParentShellFolder <> nil);
end;

// Safe version of IsFolder. (Prevent Access Violations)
class function TSubShellFolder.GetIsFolder(Folder: TShellFolder): boolean;
begin
  result := true; // Assume a folder, if ParentShellFolder = nil
  if (TSubShellFolder.HasParentShellFolder(Folder)) then
    result := Folder.IsFolder;
end;

class function TSubShellFolder.GetName(Folder: TShellFolder;
                                       RelativeNameType: TRelativeNameType): string;
var
  StrRet: TStrRet;
begin
  case (RelativeNameType) of
    TRelativeNameType.rnDisplay:
      // For Display in the ShellList
      result := Folder.DisplayName;
    TRelativeNameType.rnFile:
      // For File IO functions
      result := GetFileNameFromFindData(Folder.ParentShellFolder, Folder.RelativeID);
    TRelativeNameType.rnSort:
      // For Sorting
      // Use the DisplayName, but prepend a space for items in the root, so they will be first
      begin
        if (Folder is TSubShellFolder) then
          result := Folder.DisplayName
        else
          result := ' ' + Folder.DisplayName;
      end;
    TRelativeNameType.rnShellPath:
    begin
      // For Saving the Shell path. Can contain ::{ etc.
      FillChar(StrRet, SizeOf(StrRet), 0);
      Folder.ParentShellFolder.GetDisplayNameOf(Folder.RelativeID, SHGDN_FORPARSING, StrRet);
      Result := StrRetToStr(StrRet, Folder.RelativeID);
    end;
  end;
end;

class function TSubShellFolder.GetRelativeName(Folder: TShellFolder;
                                               RelativeNameType: TRelativeNameType): string;
begin
  result := '';

  // Need at least a valid TShellFolder
  if not Assigned(Folder) then
    exit;

  // Need a ParentShellFolder
  if (TSubShellFolder.HasParentShellFolder(Folder) = false) then
    exit;

  // Get Filename
  result := TSubShellFolder.GetName(Folder, RelativeNameType);

  // Prepend (relative) directory name?
  if (Folder.IsFolder = false) and    // Folders? Dont add RelativePath
     (Folder is TSubShellFolder) then // The RelativePath needs a TSubShellFolder
    result := TSubShellFolder(Folder).RelativePath + result;
end;

class function TSubShellFolder.GetRelativeDisplayName(Folder: TShellFolder): string;
begin
  result := TSubShellFolder.GetRelativeName(Folder, TRelativeNameType.rnDisplay);
end;

class function TSubShellFolder.GetRelativeFileName(Folder: TShellFolder): string;
begin
  result := TSubShellFolder.GetRelativeName(Folder, TRelativeNameType.rnFile);
end;

class function TSubShellFolder.GetRelativeSortName(Folder: TShellFolder): string;
begin
  result := TSubShellFolder.GetRelativeName(Folder, TRelativeNameType.rnSort);
end;

class procedure TSubShellFolder.AllFastSystemFields(RootFolder: TShellFolder; FieldList: TStrings);
var
  HasField: boolean;
  Column: integer;
  ColFlags: LongWord;
begin
  FieldList.Clear;
  if Assigned(RootFolder) and
     Assigned(RootFolder.Parent) and
     Assigned(RootFolder.ShellFolder2) then
  begin
    Column := 0;
    HasField := true;
    while HasField do
    begin
      HasField := (RootFolder.ShellFolder2.GetDefaultColumnState(Column, ColFlags) = S_OK) and
                  ((ColFlags and SHCOLSTATE_SLOW) = 0);
      if (HasField) then
        FieldList.AddPair(IntToStr(Column), TSubShellFolder.GetSystemField(RootFolder, nil, Column));
      Inc(Column);
    end;
  end;
end;

class function TSubShellFolder.SystemFieldIsDate(RootFolder: TShellFolder; Column: integer): boolean;
var
  ColFlags: LongWord;
begin
  result := false;
  if Assigned(RootFolder) and
     Assigned(RootFolder.ShellFolder2) and
     (RootFolder.ShellFolder2.GetDefaultColumnState(Column, ColFlags) = S_OK) and
     ((ColFlags and SHCOLSTATE_TYPE_DATE) = SHCOLSTATE_TYPE_DATE) then
    result := true;
end;

class function TSubShellFolder.GetSystemField(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
var
  SD: TShellDetails;
begin
  result := '';
  if Assigned(RootFolder) and
     Assigned(RootFolder.ShellFolder2) and
     (RootFolder.ShellFolder2.GetDetailsOf(RelativeID, Column, SD) = S_OK) then
    result := StrRetToStr(SD.str, RelativeID);
end;

class function TSubShellFolder.GetSystemField_MT(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
begin
  TMonitor.Enter(RootFolder);
  try
    result := TSubShellFolder.GetSystemField(RootFolder, RelativeID, Column);
  finally
    TMonitor.Exit(RootFolder);
  end;
end;

class function TSubShellFolder.GetSystemFieldEx(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
var
  pscid: TShColumnID;
  pv: OleVariant;
begin
  result := '';
  if Assigned(RootFolder) and
     Assigned(RootFolder.ShellFolder2) then
  begin
    if (RootFolder.ShellFolder2.MapColumnToSCID(Column, pscid) = S_OK) then
    begin
      RootFolder.ShellFolder2.GetDetailsEx(RelativeID, pscid, @pv);
      result := pv;
    end;
  end;
end;

{ TShellListView }

procedure TShellListView.WMNotify(var Msg: TWMNotify);
var
  Column: TListColumn;
  ResizedColumn: integer;
begin
  inherited;

  case Msg.NMHdr^.code of
    HDN_ENDTRACK,
    HDN_DIVIDERDBLCLICK:
      begin
        ResizedColumn := pHDNotify(Msg.NMHdr)^.Item;
        Column := Columns[ResizedColumn];
        if (Column.Index = FSortColumn) then
        begin
          case (FSortState) of
            THeaderSortState.hssAscending:
              SetListHeaderSortState(Self, Column, hssAscending);
            THeaderSortState.hssDescending:
              SetListHeaderSortState(Self, Column, hssDescending);
          end;
        end;
        if (Assigned(FOnColumnResized)) then
          FOnColumnResized(Column);
      end;
    HDN_BEGINTRACK:
      ;
    HDN_TRACK:
      ;
  end;
end;

procedure TShellListView.InitSortSpec(SortColumn: integer; SortState: THeaderSortState);
begin
  FSortColumn := SortColumn;
  FSortState := SortState;
end;

procedure TShellListView.ColumnSort;
var
  LocalCustomSortNeeded: boolean;
  LocalDescending: boolean;
  LocalIncludeSubFolders: boolean;
  LocalUseDecimal: boolean;
  LocalCompareColumn: integer;
  LocalDecimal1, LocalDecimal2: Double;
  TempColumn: integer;
begin
  // Need to sort on column?
  if (ColumnSorted = false) then
    exit;

  // When Including subfolders the file is displayed as a relative path. Requires special sorting.
  LocalIncludeSubFolders := IncludeSubFolders;

  // Descending?
  LocalDescending := (FSortState = THeaderSortState.hssDescending);

  // Custom sort?
  LocalCustomSortNeeded := ((FDoDefault = false) and (SortColumn <> 0)) or  // A column from the non standard list, not name.
                            (LocalIncludeSubFolders and (SortColumn = 0));  // Including subfolders, need to sort on the relative name

  // Column?
  // Is the sort field from the non standard list a system field?
  // Better to use the standard compare. EG: Size sorts wrong as text, because 'Bytes, KB, MB'
  LocalUseDecimal := false;
  LocalCompareColumn := SortColumn;
  if (FDoDefault = false) and
     (LocalCompareColumn > 0) and
     (LocalCompareColumn < Columns.Count) then      // When not in vsReport mode
  begin
    TempColumn := Columns[LocalCompareColumn].Tag -1;
    if (TempColumn >= 0) and
       (TempColumn <= High(ColumnDefs)) then
    begin
      if ((ColumnDefs[TempColumn].Options and toSys) = toSys) then   // Yes, a system field
      begin
        LocalCompareColumn := StrToIntDef(ColumnDefs[TempColumn].Command, 0);
        LocalCustomSortNeeded := false;
      end;
      LocalUseDecimal := (ColumnDefs[TempColumn].Options and toDecimal) = toDecimal;
    end;
  end;

  // Need to get all details? GetAllFileListColumns uses multi-threading to get the data.
  if (LocalCustomSortNeeded) and
     (LocalCompareColumn <> 0) then
    GetAllFileListColumns(Self, FrmGenerate);

  // Use an anonymous method. So we can test for FDoDefault, CompareColumn and SortState
  // Use only 'local variables' within this procedure
  // See also method ListSortFunc in Vcl.Shell.ShellCtrls.pas
  FoldersList.SortList(
    function(Item1, Item2: Pointer): integer
    const
      R: array [boolean] of Byte = (0, 1);
    begin
      result := R[TSubShellFolder.GetIsFolder(Item2)] - R[TSubShellFolder.GetIsFolder(Item1)];
      if (result = 0) then
      begin
        if (LocalCustomSortNeeded) then
        begin
          if (LocalCompareColumn = 0) then // Compare the relative name, not just the filename.
            result := CompareText(TSubShellFolder.GetRelativeSortName(Item1), TSubShellFolder.GetRelativeSortName(Item2),
                                  TLocaleOptions.loUserLocale)
          else
          begin // Compare the values from DetailStrings. Decimal if specified else text.
            if (LocalCompareColumn <= TShellFolder(Item1).DetailStrings.Count) and
               (LocalCompareColumn <= TShellFolder(Item2).DetailStrings.Count) then
            begin
              if LocalUseDecimal then
              begin
                if not TryStrToFloat(TShellFolder(Item1).Details[LocalCompareColumn], LocalDecimal1, FloatFormatSettings) then
                  LocalDecimal1 := -MaxDouble;
                if not TryStrToFloat(TShellFolder(Item2).Details[LocalCompareColumn], LocalDecimal2, FloatFormatSettings) then
                  LocalDecimal2 := -MaxDouble;
                result := CompareValue(LocalDecimal1, LocalDecimal2);
              end
              else
                result := CompareText(TShellFolder(Item1).Details[LocalCompareColumn], TShellFolder(Item2).Details[LocalCompareColumn],
                                      TLocaleOptions.loUserLocale);
            end;
          end;
        end
        else
        begin // Use the standard compare
          if (TShellFolder(Item1).ParentShellFolder <> nil) then
            result := Smallint(TShellFolder(Item1).ParentShellFolder.CompareIDs(LocalCompareColumn,
                                                                                TShellFolder(Item1).RelativeID,
                                                                                TShellFolder(Item2).RelativeID));
        end;
      end;

      // Sort on Filename (Column 0), within CompareColumn
      if (result = 0) and
         (LocalCompareColumn <> 0) then
      begin
        if (LocalIncludeSubFolders) then
          result := CompareText(TSubShellFolder.GetRelativeSortName(Item1), TSubShellFolder.GetRelativeSortName(Item2),
                                TLocaleOptions.loUserLocale)
        else
          result := Smallint(TShellFolder(Item1).ParentShellFolder.CompareIDs(0,
                                                                              TShellFolder(Item1).RelativeID,
                                                                              TShellFolder(Item2).RelativeID));
      end;

      // Reverse order
      if (LocalDescending) then
        result := result * -1;
    end);
end;

// Copy files to clipboard
procedure TShellListView.FileNamesToClipboard(Cut: boolean = false);
var
  FileList: TStringList;
begin
  FileList := CreateSelectedFoldersList(true);
  try
    SetFileNamesOnClipboard(FileList, Cut);
  finally
    FileList.Free;
  end;
end;

procedure TShellListView.PasteFilesFromClipboard;
var
  FileList: TStringList;
  Cut: boolean;
begin
  FileList := TStringList.Create;
  try
    if not GetFileNamesFromClipboard(FileList, Cut) then
      exit;

    UnitFilesOnClipBoard.PasteFilesFromClipBoard(ShellTreeView, FileList, RootFolder.PathName, Cut);
  finally
    FileList.Free;
    Refresh;
  end;
end;

procedure TShellListView.RefreshTreeViewAfterContext;
begin
  if (Assigned(ShellTreeView)) and
     (Assigned(ShellTreeView.Selected)) then
  begin
    Self.Enabled := false;
    try
      ShellTreeView.Refresh(ShellTreeView.Selected);
    finally
      Self.Enabled := true;
    end;
  end;
end;

procedure TShellListView.ExecuteCommandExif(Verb: string; var Handled: boolean);
var
  FileList: TStringList;
begin

  if (Verb = SCmdVerbRefresh) then
  begin
    Refresh;
    Handled := true;
  end;

  if SameText(Verb, SCmdVerbGenThumbs) then
  begin
    GenerateThumbs(RootFolder.PathName, false, ThumbNailSize, ShellListOnGenerateReady);
    Handled := true;
  end;

  if SameText(Verb, SCmdVerbGenThumbsSub) then
  begin
    GenerateThumbs(RootFolder.PathName, true, ThumbNailSize, ShellListOnGenerateReady);
    Handled := true;
  end;

  if SameText(Verb, SCmdSelLeft) then
    SelectLeft;

  if SameText(Verb, SCmdVerDiff) then
  begin
    FileList := CreateSelectedFoldersList(true);
    try
      ShowCompareDlg(FileList);
    finally
      FileList.Free;
    end;
  end;

end;

procedure TShellListView.CommandCompletedExif(Verb: String; Succeeded: Boolean);
begin
  if SameText(Verb, SCmdVerbDelete) then
  begin
    ClearSelection;
    RefreshTreeViewAfterContext;
  end;

  if SameText(Verb, SCmdVerbPaste) then
  begin
    ClearSelection;
    RefreshTreeViewAfterContext;
  end;

  if (not Succeeded) and (Verb = '') then
    MessageDlgEx(StrContextMenuFailed, '', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK]);
end;

procedure TShellListView.ShowMultiContextMenu(MousePos: TPoint);
var
  FileList: TStringList;
begin
  if (SelectedFolder = nil) then
    exit;

  FileList := CreateSelectedFoldersList(false);
  try
    InvokeMultiContextMenu(Self, SelectedFolder, MousePos, ICM2, FileList);
  finally
    FileList.Free;
  end;
end;

// to handle submenus of context menus.
procedure TShellListView.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_INITMENUPOPUP,
    WM_DRAWITEM,
    WM_MENUCHAR,
    WM_MEASUREITEM:
      if Assigned(ICM2) then
      begin
        ICM2.HandleMenuMsg(Message.Msg, Message.wParam, Message.lParam);
        Message.Result := 0;
      end;
  end;
  inherited;
end;

// Calling Invalidate creates a new window handle. We must store that handle in the Folders.
// In the standard it is done in LoadColumnDetails.
// See also: OnEnumColumnsAfterEvent
procedure TShellListView.Invalidate;
var
  Indx: integer;
begin
  inherited;

  for Indx := 0 to Items.Count - 1 do
    Folders[Indx].ViewHandle := Handle;

  // Set sorting indicator. The Invalidate also clears that.
  if (ColumnSorted) and
     (SortColumn < Columns.Count) then
    SetListHeaderSortState(Self, Columns[SortColumn], FSortState);
end;

// Prevent Calling OwnerData fetch
procedure TShellListView.ClearSelection;
var
  Indx: integer;
begin
  for Indx := 0 to Items.Count -1 do
    ListView_SetItemState(Handle, Indx, 0, LVIS_SELECTED);
end;

procedure TShellListView.SaveSelection(SaveSelection: Tlist<integer>);
var
  Index: integer;
begin
  for Index := 0 to Items.Count -1 do
    if (ListView_GetItemState(Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) then
      SaveSelection.Add(Index);
end;

procedure TShellListView.RestoreSelection(SaveSelection: Tlist<integer>);
var
  Index: integer;
begin
  ListView_SetItemState(Handle, 0, 0, LVIS_SELECTED); // First Item is usually selected. Clear
  for Index := 0 to SaveSelection.Count -1 do
    ListView_SetItemState(Handle, integer(SaveSelection[Index]), LVIS_SELECTED, LVIS_SELECTED);
end;

procedure TShellListView.SelectAll;
var
  Indx: integer;
begin
  for Indx := 0 to Items.Count -1 do
    ListView_SetItemState(Handle, Indx, LVIS_SELECTED, LVIS_SELECTED);
end;

procedure TShellListView.Refresh;
begin
  ClearSelection;

  inherited Refresh;
end;

function TShellListView.DetailsNeeded: boolean;
begin
  result := (ViewStyle = TViewStyle.vsReport) and
            (ReadModeOptions <> []);
end;

procedure TShellListView.RefreshSelected;
var
  Index: integer;
  SavedSel: Tlist<integer>;
begin
  if not Enabled then
    exit;
  SavedSel := Tlist<integer>.Create;
  Enabled := false;
  try
    SaveSelection(SavedSel);
    if (DetailsNeeded) then
    begin
      for Index := 0 to SavedSel.Count -1 do
      begin
        Folders[SavedSel[Index]].DetailStrings.Clear;
        Items[SavedSel[Index]].Update;
      end;
    end
    else
    begin
      Refresh;
      RestoreSelection(SavedSel);
    end;
  finally
    SavedSel.Free;
    Enabled := true;
  end;
end;

procedure TShellListView.AddDate;
var
  Column: integer;
begin
  Column := Columns.Count;
  if (TSubShellFolder.SystemFieldIsDate(RootFolder, Column)) then
    Columns.Add.Caption := TSubShellFolder.GetSystemField(RootFolder, nil, Column); // Nil gets fieldname
end;

procedure TShellListView.EnumColumns;
begin
  LockDrawing;

  try
    FColumnDefs := nil;
    if Assigned(FOnEnumColumnsBeforeEvent) then
      FOnEnumColumnsBeforeEvent(Self, FReadModeOptions, FColumnDefs);

    // Call standard OwnerDataFetch?
    FDoDefault := not DetailsNeeded;

    Selected := nil;
    ItemFocused := nil;
    ClearSelection;

    if (FDoDefault) then
      inherited;

    if Assigned(FOnEnumColumnsAfterEvent) then
      FOnEnumColumnsAfterEvent(Self);

    if Enabled and
       (ViewStyle = vsReport) then // EnumColumns only called for ViewStyle=vsReport
    begin

      // Allow starting exiftool
      if (Assigned(FOnPathChange)) then
        FOnPathChange(Self);

      if (FIncludeSubFolders) and
         (FDoDefault = false) then
      begin
        FrmGenerate.Show;
        SendMessage(FrmGenerate.Handle, CM_SubFolderSort, Items.Count, LPARAM(Path));
      end;

      try
        ColumnSort;
      finally
        if (FIncludeSubFolders) and
           (FDoDefault = false) then
          FrmGenerate.Close;
      end;

      // All data loaded
      if (Assigned(FOnItemsLoaded)) then
        FOnItemsLoaded(Self);

    end;
  finally
    UnlockDrawing;
    Invalidate; // Creates new window handle!
  end;
end;

procedure TShellListView.CMThumbStart(var Message: TMessage);
begin
  if (Assigned(FOnNotifyGenerateEvent)) and
     (Message.WParam < WParam(Items.Count)) then
    FOnNotifyGenerateEvent(Self, Items[Message.WParam], TThumbGenStatus.Started, Items.Count, FGenerating);
end;

procedure TShellListView.CMThumbEnd(var Message: TMessage);
begin
  RemoveThumbTask(Message.WParam);
  if (Assigned(FOnNotifyGenerateEvent)) and
     (Message.WParam < WParam(Items.Count)) then
    FOnNotifyGenerateEvent(Self, Items[Message.WParam], TThumbGenStatus.Ended, Items.Count, FGenerating);
end;

procedure TShellListView.CMThumbError(var Message: TMessage);
begin
  RemoveThumbTask(Message.WParam);
  if (Assigned(FOnNotifyErrorEvent)) and
     (Message.WParam < WParam(Items.Count)) then
    FOnNotifyErrorEvent(Self, Items[Message.WParam], Exception(Message.LParam));
end;

procedure TShellListView.CMThumbRefresh(var Message: TMessage);
begin
  if (Message.WParam < WParam(Items.Count)) then
  begin
    Add2ThumbNails(Message.LParam, Message.WParam, false);
    Items[Message.WParam].Update;
  end;
end;

procedure TShellListView.GetThumbNails;
var
  Hr: HRESULT;
  HBmp: HBITMAP;
  ItemIndx: integer;
begin
  if (ViewStyle = vsIcon) and (FThumbNailSize > 0) then
  begin

    InitThumbNails;

    // Adjust the size of the cache
    SetLength(FThumbNailCache, 0);
    SetLength(FThumbNailCache, Items.Count);

    // Add the Thumbnails that Windows has already cached to our imagelist.
    // If not in cache, we show an Icon, and mark it in the cache as negative *-1  (Needs generating = true)
    // Only the thumbnails in view (visible) are generated. See: OwnerDataFetch
    CancelThumbTasks;

    FGenerating := 0;
    SendMessage(Self.Handle, CM_ThumbEnd, -1, 0);

    for ItemIndx := 0 to FoldersList.Count -1 do
    begin
      Hr := S_FALSE;
      if (TSubShellFolder.GetIsFolder(Folders[ItemIndx])) then // Only get icons for folders
        Hr := GetThumbCache(Folders[ItemIndx].AbsoluteID, TThumbType.ttIcon, FThumbNails.Width, FThumbNails.Height, HBmp)
      else if (FIncludeSubFolders = false) then // Defer loading thumbnails when including subfolders.
      begin
        Hr := GetThumbCache(Folders[ItemIndx].AbsoluteID, TThumbType.ttThumbCache, FThumbNails.Width, FThumbNails.Height, HBmp);
        if (Hr <> S_OK) then
          Hr := GetThumbCache(Folders[ItemIndx].AbsoluteID, TThumbType.ttIcon, FThumbNails.Width, FThumbNails.Height, HBmp);
      end;

      if (Hr = S_OK) then
        Add2ThumbNails(HBmp, ItemIndx, true)
      else
        Items[ItemIndx].ImageIndex := FHourGlassId;
    end;
  end;
end;

function TShellListView.CreateSelectedFoldersList(FullPaths: boolean): TStringList;
var
  Index: integer;
  SelectedParent: TShellFolder;
begin
  SelectedParent := nil;
  if (SelectedFolder <> nil) then
    SelectedParent := SelectedFolder.Parent;

  Result := TStringList.Create;
  for Index := 0 to Items.Count -1 do
  begin
    // Prevent calling OwnerDataFetch
    if (ListView_GetItemState(Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) then
    begin

      if (Folders[Index].Parent <> SelectedParent) then
      begin
        MessageDlgEx(StrMultipleDirsInContext, '', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK]);
        Result.Clear;
        exit;
      end;

      if (FullPaths) then
        Result.AddObject(Folders[Index].PathName, Folders[Index])
      else
        Result.AddObject(RelFileName(Index), Folders[Index]);
    end;
  end;

end;

procedure TShellListView.DoContextPopup(MousePos: TPoint; var Handled: boolean);
begin
  ShowMultiContextMenu(MousePos);
  Handled := true;

//  inherited;
end;

procedure TShellListView.Edit(const Item: TLVItem);
begin
  inherited Edit(Item);

  if Assigned(ShellTreeView) and
     Assigned(ShellTreeView.Selected) and
     TSubShellFolder.GetIsFolder(Folders[Item.iItem]) then
    ShellTreeView.Refresh(ShellTreeView.Selected);
end;

procedure TShellListView.PopulateSubDirs(FRelativeFolder: TSubShellFolder);
var
  ID: PItemIDList;
  EnumList: IEnumIDList;
  NumIDs: LongWord;
  HR: HResult;
  CanAdd: Boolean;
  NewShellFolder: IShellFolder;
  NewRelativeFolder: TSubShellFolder;
begin

  if (FRelativeFolder.ShellFolder = nil) then
    exit;

  Inc(FSubFolders);
  SendMessage(FrmGenerate.Handle, CM_SubFolderScan, FSubFolders, LPARAM(FRelativeFolder.PathName));

  HR := FRelativeFolder.ShellFolder.EnumObjects(0, SHCONTF_FOLDERS + SHCONTF_NONFOLDERS, EnumList); // No user input
  if HR <> S_OK then
   exit;

  while EnumList.Next(1, ID, NumIDs) = S_OK do
  begin
    if boolean(SendMessage(FrmGenerate.Handle, CM_WantsToClose, 0, 0)) then
      exit;
    NewShellFolder := GetIShellFolder(FRelativeFolder.ShellFolder, ID);
    NewRelativeFolder := TSubShellFolder.Create(FRelativeFolder, ID, NewShellFolder);
    // Avoid memory leaks
    CoTaskMemFree(ID);
    //
    if (TSubShellFolder.GetIsFolder(NewRelativeFolder)) then
    begin
      NewRelativeFolder.FRelativePath := IncludeTrailingPathDelimiter(FRelativeFolder.FRelativePath) +
                                         TSubShellFolder.GetName(NewRelativeFolder, TRelativeNameType.rnFile);
      PopulateSubDirs(NewRelativeFolder);
      FHiddenFolders.Add(NewRelativeFolder); // We dont want subfoldernames visible. But keep a reference, so we can free them
      Continue;
    end;

    NewRelativeFolder.FRelativePath := FRelativeFolder.FRelativePath;

    CanAdd := True;
    if Assigned(OnAddFolder) then OnAddFolder(Self, NewRelativeFolder, CanAdd);

    if CanAdd then
      FoldersList.Add(NewRelativeFolder)
    else
      NewRelativeFolder.Free;
  end;
end;

procedure TShellListView.Populate;
begin
  // Prevent flicker by skipping populate when not yet needed.
  if (csLoading in ComponentState) then
    exit;
  if not HandleAllocated then
    exit;
  if not Enabled then
    exit;
  // until here

  if FPopulating then
    exit;
  FPopulating := true;

  Items.BeginUpdate;
  try
    // Not used.
    if Assigned(FOnPopulateBeforeEvent) then
      FOnPopulateBeforeEvent(Self);

    // Force initialization of array with zeroes
    SetLength(FThumbNailCache, 0);
    ClearHiddenItems;

    if (FIncludeSubFolders) then
    begin
      FSubFolders := 0;
      FrmGenerate.Show;
      SendMessage(FrmGenerate.Handle, CM_SubFolderScan, FSubFolders, LPARAM(Path));
    end;

    inherited;
    Items.Count := FoldersList.Count; // Make sure Item count is updated. Can include subfolders!

    // Optimize memory allocation
    ListView_SetItemCountEx(Handle, Items.Count, LVSICF_NOINVALIDATEALL + LVSICF_NOSCROLL);

    if (ViewStyle = vsReport) then
      exit;

    // Allow starting exiftool
    if (Assigned(FOnPathChange)) then
      FOnPathChange(Self);

    // Sort may not be needed for files, but the directories need to go first.
    FSortColumn := 0;
    SortState := THeaderSortState.hssNone;
    ColumnSort;

    // Get Thumbnails and load in imagelist.
    if (FIncludeSubFolders) then
      SendMessage(FrmGenerate.Handle, CM_IconStart, Items.Count, LPARAM(Path));

    GetThumbNails;

    // All data loaded
    if (Assigned(FOnItemsLoaded)) then
      FOnItemsLoaded(Self);

  finally
    if (FIncludeSubFolders) then
      FrmGenerate.Close;

    FPopulating := false;
    Items.EndUpdate;
  end;
end;

// When in vsReport mode, calls the OwnerDataFetch event to get the item.caption and subitems.
//
// Sets the Item.ImageIndex when the listview is in vsIcon mode. When not avail (<0) it starts generating.
function TShellListView.OwnerDataFetch(Item: TListItem; Request: TItemRequest): boolean;

  procedure DoIcon;
  var
    ItemIndx, TaskId: integer;
  begin
    if not(irImage in Request) then
      exit;
    ItemIndx := Item.Index;

    // Index not in cache?
    if (ItemIndx > High(FThumbNailCache)) then
      exit;

    // Update the item with the imageindex of our cached thumbnail (-1 here)
    if (FThumbNailCache[ItemIndx] > 0) then
    begin // The bitmap in the cache is a thumbnail
      Item.ImageIndex := FThumbNailCache[ItemIndx];
      exit;
    end;

    Item.ImageIndex := FThumbNailCache[ItemIndx] * -1;
    FThumbNailCache[ItemIndx] := Item.ImageIndex; // Just try it once.

    // Allowed to generate?

    // Folders, never.
    if (TSubShellFolder.GetIsFolder(Folders[ItemIndx])) then
      exit;

    // AutoGenerate?
    if (FThumbAutoGenerate = false) then
      exit;

    // Generate the thumbnail asynchronously
    System.TMonitor.Enter(FThumbTasks);
    try
      inc(FGenerating);
      // Add to list of thumbnails to generate
      TaskId := FThumbTasks.Add(nil);
      FThumbTasks[TaskId] := TThumbTask.Create(ItemIndx, Self, FThreadPool, FThumbNailSize);
    finally
      System.TMonitor.Exit(FThumbTasks);
    end;

    // Actually start the task. It will create a HBITMAP, and send a message to the ShellListView window.
    // Updating the imagelist must be done in the main thread.
    TThumbTask(FThumbTasks[TaskId]).Start;

    // Send a message that generating begins.
    PostMessage(Self.Handle, CM_ThumbStart, 0, 0);
  end;

begin
  Result := true; // The inherited always return true!

  // Dont interupt now. Still populating.
  if FPopulating then
    exit;

  if (not(FDoDefault) and
      not(csDesigning in ComponentState) and Assigned(FOnOwnerDataFetchEvent)) then
    FOnOwnerDataFetchEvent(Self, Item, Request, Folders[Item.Index])
  else if TSubShellFolder.HasParentShellFolder(Folders[Item.Index]) then
    Result := inherited;

  // Set the Item.caption. Could be a relative filename. E.g. Subdir\file1.jpg
  if (irText in Request) and
     (Item.Index >= 0) and
     (Item.Index < FoldersList.Count) then
    Item.Caption := TSubShellFolder.GetRelativeDisplayName(Folders[Item.Index]);

  if (ViewStyle = vsIcon) then
    DoIcon;
end;

// The inherited has 2 problems.
// 1. The last item is not found
// 2. It does not check if StartIndex > Folders.Count -1
function TShellListView.OwnerDataFind(Find: TItemFind; const FindString: string;
  const FindPosition: TPoint; FindData: Pointer; StartIndex: Integer;
  Direction: TSearchDirection; Wrap: Boolean): Integer;
var
  I: Integer;
  Found: Boolean;
begin
  Result := -1;
  I := StartIndex;
  if (Find = ifExactString) or
     (Find = ifPartialString) then
  begin
    repeat
      if (I > FoldersList.Count -1) then // The inherited checks for =
      begin
        if Wrap then
          I := 0
        else
          Exit;
      end;
      Found := StartsText(FindString, TSubShellFolder.GetRelativeDisplayName(Folders[I]));
      Inc(I);
    until Found or (I = StartIndex);
    if Found then
      Result := I -1;
  end;
end;

constructor TShellListView.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  ICM2 := nil;

  FPopulating := false;
  DoubleBuffered := true;
{$IFNDEF VER350}
  DoubleBufferedMode := TDoubleBufferedMode.dbmRequested;
{$ENDIF}
  StyleElements := [seFont, seBorder];
  FThumbNailSize := 0;
  FGenerating := 0;
  FDragSource := false;
  FHiddenFolders := Tlist.Create;
  FIncludeSubFolders := false;
  InitSortSpec(0, THeaderSortState.hssNone);
  FThumbTasks := Tlist.Create;
  FThumbNails := TImageList.Create(Self);
  SetLength(FThumbNailCache, 0);
  ResetPool(FThreadPool);
end;

procedure TShellListView.CreateWnd;
begin
  inherited;

  SetColumnSorted(FColumnSorted); // Disable inherited Sorted?  Note: Populate will not be called when Enabled = false
end;

destructor TShellListView.Destroy;
begin
  CancelThumbTasks;
  FThumbTasks.Free;
  FThumbNails.Free;
  SetLength(FThumbNailCache, 0);
  FreeAndNil(FThreadPool);
  ClearHiddenItems;
  FHiddenFolders.Free;

  inherited;
end;

procedure TShellListView.DestroyWnd;
begin
  ClearHiddenItems;
  inherited DestroyWnd;
end;

procedure TShellListView.CancelThumbTasks;
var
  ATask: TThumbTask;
begin
  System.TMonitor.Enter(FThumbTasks);
  try
    for ATask in FThumbTasks do
      if Assigned(ATask) and // Checks to avoid AV's generating thumbs
        ATask.IsQueued then
        ATask.Cancel;
  finally
    FThumbTasks.Clear;
    FGenerating := 0;
    System.TMonitor.Exit(FThumbTasks);
  end;
end;

procedure TShellListView.RemoveThumbTask(ItemIndex: integer);
var
  Indx: integer;
begin
  System.TMonitor.Enter(FThumbTasks);
  try
    if (ItemIndex >= 0) then
    begin
      Dec(FGenerating);
      for Indx := 0 to FThumbTasks.Count - 1 do
      begin
        if (TThumbTask(FThumbTasks[Indx]).ItemIndex = ItemIndex) then
        begin
          FThumbTasks.Delete(Indx);
          break;
        end;
      end;
    end;
  finally
    System.TMonitor.Exit(FThumbTasks);
  end;
end;

procedure TShellListView.ShellListOnGenerateReady(Sender: TObject);
var
  AnItem: TListItem;
begin
  if (ViewStyle = vsIcon) and (FThumbNailSize > 0) then
  begin
    GetThumbNails;
    for AnItem in Items do
      AnItem.Update;
  end;
end;

function TShellListView.Path: string;
begin
  result := RootFolder.PathName;
end;

function TShellListView.ShellPath: string;
begin
  result := TSubShellFolder.GetRelativeName(RootFolder, TRelativeNameType.rnShellPath);
end;

function TShellListView.GetSelectedFolder(ItemIndex: integer): TShellFolder;
var
  SelIndex: integer;
begin
  result := nil;

  SelIndex := ItemIndex;
  if (SelIndex = -1) and
     (Selected <> nil) then
    SelIndex := Selected.Index;

  if (SelIndex < 0) or
     (SelIndex >= Items.Count) then
    exit;

  result := Folders[SelIndex];
end;

function TShellListView.FilePath(ItemIndex: integer = -1): string;
var
  AFolder: TShellFolder;
begin
  Result := '';

  AFolder := GetSelectedFolder(ItemIndex);
  if (AFolder = nil) then
    exit;

  if (TSubShellFolder.GetIsFolder(AFolder) = false) then
  begin
    if (AFolder is TSubShellFolder) then
      result := TSubShellFolder(AFolder).PathName
    else
      result := AFolder.PathName;
  end;
end;

function TShellListView.RelDisplayName(ItemIndex: integer = -1): string;
var
  AFolder: TShellFolder;
begin
  result := '';

  AFolder := GetSelectedFolder(ItemIndex);
  if (AFolder <> nil) and
     (TSubShellFolder.GetIsFolder(AFolder) = false) then
    result := TSubShellFolder.GetRelativeDisplayName(AFolder);
end;

function TShellListView.RelFileName(ItemIndex: integer = -1): string;
var
  AFolder: TShellFolder;
begin
  result := '';

  AFolder := GetSelectedFolder(ItemIndex);
  if (AFolder <> nil) and
     (TSubShellFolder.GetIsFolder(AFolder) = false) then
    result := TSubShellFolder.GetRelativeFileName(AFolder);
end;

function TShellListView.FileExt(ItemIndex: integer = -1): string;
begin
  Result := ExtractFileExt(FilePath(ItemIndex));
end;

procedure TShellListView.ColumnClick(Column: TListColumn);
var
  I: integer;
  Ascending: boolean;
  State: THeaderSortState;
begin
  if (FColumnSorted = false) then
    exit;

  Ascending := GetListHeaderSortState(Self, Column) <> hssAscending;
  for I := 0 to Columns.Count - 1 do
  begin
    if Columns[I] = Column then
    begin
      if Ascending then
        State := hssAscending
      else
        State := hssDescending;
      InitSortSpec(Column.Index, State);
    end
    else
      State := hssNone;
    SetListHeaderSortState(Self, Columns[I], State);
  end;
  EnumColumns;
end;

procedure TShellListView.SetColumnSorted(AValue: boolean);
begin
  if (FColumnSorted <> AValue) then
    FColumnSorted := AValue;
  if (FColumnSorted) and
     (Sorted) then
    Sorted := false;
end;

function TShellListView.GetIconSpacing: dword;
begin
  result := ListView_SetIconSpacing(Handle, WORD(-1), WORD(-1));
end;

procedure TShellListView.SetIconSpacing(Cx, Cy: word);
var
  Spacing: DWORD;
begin
  Spacing := GetIconSpacing;
  if (Cx <> 0) or
     (Cy <> 0) then
    ListView_SetIconSpacing(Handle, LoWord(Spacing) + Cx, HiWord(Spacing) + Cy);
  GetThumbNails;
end;

procedure TShellListView.SetIconSpacing(Cx, Cy: integer);

  function Delta(AValue:integer): word;
  begin
    result := 0;
    if (Avalue > 0) then
      result := 2
    else if (AValue < 0) then
      result := word(-2);
  end;

begin
  SetIconSpacing(Delta(Cx), Delta(Cy));
end;

procedure TShellListView.ClearHiddenItems;
var
  I: Integer;
begin
  for I := 0 to FHiddenFolders.Count-1 do
    if Assigned(FHiddenFolders[I]) then
      TSubShellFolder(FHiddenFolders[I]).Free;

  FHiddenFolders.Clear;
end;

procedure TShellListView.InitThumbNails;
var
  AnHourGlass: TBitmap;
begin
  FThumbNails.Clear;
  if (FThumbNailSize <> 0) then
  begin
    FThumbNails.Width := FThumbNailSize;
    FThumbNails.Height := FThumbNailSize;
    FThumbNails.BkColor := FBkColor;
    AnHourGlass := TBitmap.Create;
    try
      AnHourGlass.LoadFromResourceName(HInstance, HOURGLASS);
      ResizeBitmapCanvas(AnHourGlass, FThumbNails.Width, FThumbNails.Height, HOURGLASS_TRANSPARENT, false);
      // FHourGlassId Will normally be zero!
      FHourGlassId := FThumbNails.AddMasked(AnHourGlass, HOURGLASS_TRANSPARENT);
    finally
      AnHourGlass.Free;
    end;
    // Set the imagelist to our thumbnail list.
    SendMessage(Handle, LVM_SETIMAGELIST, LVSIL_NORMAL, FThumbNails.Handle);
  end;
end;

procedure TShellListView.SetThumbNailSize(AValue: integer);
begin
  if (FThumbNailSize <> AValue) then
  begin
    FThumbNailSize := AValue;
    InitThumbNails;
  end;
end;

procedure TShellListView.SetBkColor(Value: TColor);
begin
  if (Value <> FBkColor) then
    FBkColor := Value;
  if (Value <> FThumbNails.BkColor) then
    FThumbNails.BkColor := Value;
end;

procedure TShellListView.SetFocus;
begin
// Avoid cannot focus a disabled or invisible window
  if Enabled then
    inherited SetFocus;
end;

function TShellListView.GetThumbNailSize(ItemIndex, W, H: integer; DefThumbType: TThumbType = ttThumbBiggerCache): TPoint;
var
  Hr: HRESULT;
  HBmp: HBITMAP;
  Bm: BITMAP;
begin
  result := Point(W, H);
  Hr := GetThumbCache(Folders[ItemIndex].AbsoluteID, DefThumbType, W, H, HBmp);
  if (HR = S_OK) then
  begin
    GetObject(HBmp, sizeof(BITMAP), @Bm);
    NewSizeRetainRatio(Bm.bmWidth, Bm.bmHeight, W, H, result.X, result.Y);
    DeleteObject(HBmp);
  end;
end;

function TShellListView.GetThumbNail(ItemIndex, W, H: integer; DefThumbType: TThumbType = ttThumbBiggerCache): TBitmap;
var
  Hr: HRESULT;
  HBmp: HBITMAP;
begin
  result := nil;

  if (ItemIndex > Items.Count -1) then
    exit;

  // Get the cached (by Windows) thumbnail if avail
  Hr := GetThumbCache(Folders[ItemIndex].AbsoluteID, DefThumbType, W, H, HBmp);
  if (HR = S_OK) then
  begin
    result := BitMapFromHBitMap(HBmp, W, H, FBkColor);
    exit;
  end;

  // Need to increase the cache?
  if (ItemIndex > High(FThumbNailCache)) then
    SetLength(FThumbNailCache, Items.Count);

  // In the cache there is no thumbnail, or it needs generating.
  // Get the thumbnail, return that and save it resized in the cache.
  if (FThumbNailCache[ItemIndex] <= 0) then
  begin
    Hr := GetThumbCache(Folders[ItemIndex].AbsoluteID, TThumbType.ttThumb, FThumbNailSize, FThumbNailSize, HBmp);

    // Use Icon as fallback, if generating thumbnail failed.
    if (Hr <> S_OK) then
      Hr := GetThumbCache(Folders[ItemIndex].AbsoluteID, TThumbType.ttIcon, FThumbNailSize, FThumbNailSize, HBmp);

    // We have something
    if (Hr = S_OK) then
    begin
      // Create a Bitmap to save in the cache.
      result := BitMapFromHBitMap(HBmp, FThumbNailSize, FThumbNailSize, FBkColor);
      Add2ThumbNails(result, ItemIndex, false);
      // Resize to desired.
      ResizeBitmapCanvas(result, W, H, FBkColor);
      exit;
    end;
  end;

  // Use what's in our cache.
  if (FThumbNailCache[ItemIndex] > 0) then
  begin
    result := TBitmap.Create;
    FThumbNails.GetBitmap(Abs(FThumbNailCache[ItemIndex]), result);
    ResizeBitmapCanvas(result, W, H, FBkColor);
  end;
end;

procedure TShellListView.Add2ThumbNails(ABitMap: TBitmap; ANitemIndex: integer; NeedsGenerating: boolean);
begin
  Items[ANitemIndex].ImageIndex := FThumbNails.AddMasked(ABitMap, FBkColor);
  if (NeedsGenerating) then
    FThumbNailCache[ANitemIndex] := Items[ANitemIndex].ImageIndex * -1
  else
    FThumbNailCache[ANitemIndex] := Items[ANitemIndex].ImageIndex;
end;

procedure TShellListView.Add2ThumbNails(ABmp: HBITMAP; ANitemIndex: integer; NeedsGenerating: boolean);
var
  ABitMap: TBitmap;
begin
  ABitMap := BitMapFromHBitMap(ABmp, FThumbNails.Width, FThumbNails.Height, FBkColor);
  try
    Add2ThumbNails(ABitMap, ANitemIndex, NeedsGenerating);
  finally
    ABitMap.Free;
  end;
end;

function TShellListView.GiveFeedback(dwEffect: Longint): HResult; stdcall;
begin
  Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;

function TShellListView.QueryContinueDrag(fEscapePressed: BOOL; grfKeyState: Longint): HResult; stdcall;
begin
  if fEscapePressed or (grfKeyState and MK_RBUTTON = MK_RBUTTON) then
    Result := DRAGDROP_S_CANCEL
  else if grfKeyState and MK_LBUTTON = 0 then
    Result := DRAGDROP_S_DROP
  else
    Result := S_OK;
end;

procedure TShellListView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (FDragSource) and
     (Button = mbLeft) then
  begin
    FDragStartPos.X := X;
    FDragStartPos.Y := Y;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TShellListView.MouseMove(Shift: TShiftState; X, Y: Integer);
const
  Threshold = 3;
var
  HR: HResult;
  ItemIDListArray: array of PItemIDList;
  Index, Cnt: integer;
  DataObject: IDataObject;
  Effect: Longint;
begin
  inherited MouseMove(Shift, X, Y);

  if (FDragSource = false) then
    exit;

  if (SelCount > 0) and
     (csLButtonDown in ControlState) and
     ((Abs(X - FDragStartPos.X) >= Threshold) or (Abs(Y - FDragStartPos.Y) >= Threshold)) then
  begin
    Perform(WM_LBUTTONUP, 0, MakeLong(X, Y));
    SetLength(ItemIDListArray, SelCount);
    Cnt := 0;
    for Index := 0 to Items.Count - 1 do
    begin
      if (ListView_GetItemState(Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) then
      begin
        ItemIDListArray[Cnt] := Folders[Index].RelativeID;
        Inc(Cnt);
      end;
    end;

    HR := RootFolder.ShellFolder.GetUIObjectOf(0, SelCount, ItemIDListArray[0], IDataObject, nil, DataObject);
    if (HR = S_OK) then
    begin
      Effect := DROPEFFECT_NONE;
      DoDragDrop(DataObject, Self, DROPEFFECT_COPY, Effect);
    end;
  end;
end;

end.
