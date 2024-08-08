unit ExifToolsGui_ShellList;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Threading,
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, Winapi.ShlObj,
  Vcl.Shell.ShellCtrls, Vcl.Shell.ShellConsts, Vcl.ComCtrls, Vcl.Menus, Vcl.Controls,
  ExifToolsGUI_Thumbnails, ExifToolsGUI_MultiContextMenu;

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
  TPopulateBeforeEvent = procedure(Sender: TObject; var DoDefault: boolean) of object;
  TOwnerDataFetchEvent = procedure(Sender: TObject; Item: TListItem; Request: TItemRequest; AFolder: TShellFolder) of object;

  TSubShellFolder = class(TShellFolder)
    FRelativePath: string;
    function RelativePath: string;
  public
    destructor Destroy; override;
    class function HasParentShellFolder(Folder: TShellFolder): boolean;
    class function GetIsFolder(Folder: TShellFolder): boolean;
    class function GetName(Folder: TShellFolder; ForDisplay: boolean): string;
    class function GetRelativeName(Folder: TShellFolder; ForDisplay: boolean = true): string;
  end;

  TShellListView = class(Vcl.Shell.ShellCtrls.TShellListView, IShellCommandVerbExifTool)
  private
    FHiddenFolders: TList;
    FThreadPool: TThreadPool;
    FThumbTasks: Tlist;
    FDoDefault: boolean;
    FSubFolders: WPARAM;
    FIncludeSubFolders: boolean;

    FonColumnResized: TNotifyEvent;
    FColumnSorted: boolean;
    FSortColumn: integer;
    FSortState: THeaderSortState;

    FThumbNails: TImageList;
    FThumbNailSize: integer;
    FGenerating: integer;
    FThumbAutoGenerate: boolean;
    // Thumbnail cache. An index for every item in FThumbNails
    //
    // > 1 The index to use for FThumbNails. Minus 1!
    // = 0 The index needs to be generated. Displayed as a ?
    // < 1 A temporary icon to display, until the thumbnail is generated. The actual index in FThumbNails is * -1
    FThumbNailCache: array of integer;
    FOnNotifyErrorEvent: TThumbErrorEvent;
    FOnNotifyGenerateEvent: TThumbGenerateEvent;
    FOnPopulateBeforeEvent: TPopulateBeforeEvent;
    FOnEnumColumnsAfterEvent: TNotifyEvent;
    FOnPathChange: TNotifyEvent;
    FOnItemsLoaded: TNotifyEvent;
    FOnOwnerDataFetchEvent: TOwnerDataFetchEvent;
    ICM2: IContextMenu2;
    FRefreshAfterContext: boolean;
    procedure SetColumnSorted(AValue: boolean);
    procedure ClearHiddenItems;
    procedure InitThumbNails;

    procedure SetThumbNailSize(AValue: integer);
    procedure CMThumbStart(var Message: TMessage); message CM_ThumbStart;
    procedure CMThumbEnd(var Message: TMessage); message CM_ThumbEnd;
    procedure CMThumbError(var Message: TMessage); message CM_ThumbError;
    procedure CMThumbRefresh(var Message: TMessage); message CM_ThumbRefresh;
    function CreateSelectedFileList(FullPaths: boolean): TStringList;
  protected
    procedure WMNotify(var Msg: TWMNotify); message WM_NOTIFY;
    procedure InitSortSpec(SortColumn: integer; SortState: THeaderSortState);
    procedure ColumnSort; virtual;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure EnumColumns; override;
    procedure GetThumbNails; virtual;
    procedure DoContextPopup(MousePos: TPoint; var Handled: boolean); override;
    procedure Edit(const Item: TLVItem); override;
    procedure PopulateSubDirs(FRootFolder, FRelativeFolder: TSubShellFolder); overload;
    procedure Populate; override;
    function OwnerDataFetch(Item: TListItem; Request: TItemRequest): boolean; override;
    procedure Add2ThumbNails(ABmp: HBITMAP; ANitemIndex: integer; NeedsGenerating: boolean);
    procedure CancelThumbTasks;
    procedure RemoveThumbTask(ItemIndex: integer);
    procedure ShowMultiContextMenu(MousePos: TPoint);
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    procedure ClearSelectionRefresh;

    function Path: string;
    function GetSelectedFolder(ItemIndex: integer): TShellFolder;
    function FilePath(ItemIndex: integer = -1): string;
    function RelFileName(ItemIndex: integer = -1): string;
    function FileExt(ItemIndex: integer = -1): string;
    procedure ColumnClick(Column: TListColumn);
    procedure FileNamesToClipboard(Cut: boolean = false);
    procedure PasteFilesFromClipboard;
    procedure PopulateSubDirs(FRootFolder: TSubShellFolder); overload;
    procedure ExecuteCommandExif(Verb: string; var Handled: boolean);
    procedure CommandCompletedExif(Verb: String; Succeeded: Boolean);
    procedure ShellListOnGenerateReady(Sender: TObject);
    function GetIconSpacing: dword;
    procedure SetIconSpacing(Cx, Cy: word); overload;
    procedure SetIconSpacing(Cx, Cy: integer); overload;

    property OnColumnResized: TNotifyEvent read FonColumnResized write FonColumnResized;
    property ColumnSorted: boolean read FColumnSorted write SetColumnSorted;
    property SortColumn: integer read FSortColumn write FSortColumn;
    property SortState: THeaderSortState read FSortState write FSortState;

    property ThumbNailSize: integer read FThumbNailSize write SetThumbNailSize;
    property ThumbAutoGenerate: boolean read FThumbAutoGenerate write FThumbAutoGenerate;
    property OnThumbError: TThumbErrorEvent read FOnNotifyErrorEvent write FOnNotifyErrorEvent;
    property OnThumbGenerate: TThumbGenerateEvent read FOnNotifyGenerateEvent write FOnNotifyGenerateEvent;
    property Generating: integer read FGenerating;
    property OnPopulateBeforeEvent: TPopulateBeforeEvent read FOnPopulateBeforeEvent write FOnPopulateBeforeEvent;
    property OnEnumColumnsAfterEvent: TNotifyEvent read FOnEnumColumnsAfterEvent write FOnEnumColumnsAfterEvent;
    property OnPathChange: TNotifyEvent read FOnPathChange write FOnPathChange;
    property OnItemsLoaded: TNotifyEvent read FOnItemsLoaded write FOnItemsLoaded;
    property OnOwnerDataFetchEvent: TOwnerDataFetchEvent read FOnOwnerDataFetchEvent write FOnOwnerDataFetchEvent;
    property OnMouseWheel;
    property OnCustomDrawItem;
    property IncludeSubFolders: boolean read FIncludeSubFolders write FIncludeSubFolders;
  end;

implementation

uses System.Win.ComObj, System.UITypes,
     Vcl.Graphics,
     ExifToolsGUI_Utils, UnitFilesOnClipBoard, UFrmGenerate;

// res file contains the ?

{$R ShellList.res}

const
  HOURGLASS = 'HOURGLASS';


  // Listview Sort

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
        Column.Caption := Column.Caption + ' ' + #$25b2; // Add an arrow to the caption. Using styles doesn't show the arrows in the header
        Item.fmt := Item.fmt or HDF_SORTUP;
      end;
    hssDescending:
      begin
        Column.Caption := Column.Caption + ' ' + #$25bc; // Add an arrow to the caption.
        Item.fmt := Item.fmt or HDF_SORTDOWN;
      end;
  end;
  Header_SetItem(Header, Column.Index, Item);
end;

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
  result := (Folder.ParentShellFolder <> nil);
end;

class function TSubShellFolder.GetIsFolder(Folder: TShellFolder): boolean;
begin
  result := true; // Assume a folder, if ParentShellFolder = nil
  if (TSubShellFolder.HasParentShellFolder(Folder)) then
    result := Folder.IsFolder;
end;

class function TSubShellFolder.GetName(Folder: TShellFolder; ForDisplay: boolean): string;
begin
  if (ForDisplay) then
    // For Display in the ShellList
    result := Folder.DisplayName
  else
    // For File IO functions
    // This call is much slower, it keeps getting DesktopFolder
    result := ExtractFilename(ExcludeTrailingPathDelimiter(Folder.PathName));
end;

class function TSubShellFolder.GetRelativeName(Folder: TShellFolder; ForDisplay: boolean = true): string;
begin
  result := '';

  // Need at least a valid TShellFolder
  if not Assigned(Folder) then
    exit;

  // Need a ParentShellFolder
  if (TSubShellFolder.HasParentShellFolder(Folder) = false) then
    exit;

  // Get Filename
  result := TSubShellFolder.GetName(Folder, ForDisplay);

  // Prepend (relative) directory name?
  if (Folder.IsFolder = false) and    // Folders? Dont add RelativePath
     (Folder is TSubShellFolder) then // The RelativePath needs a TSubShellFolder
    result := TSubShellFolder(Folder).RelativePath + result;
end;

procedure TShellListView.WMNotify(var Msg: TWMNotify);
var
  Column: TListColumn;
  ResizedColumn: integer;
begin
  inherited;

  case Msg.NMHdr^.code of
    HDN_ENDTRACK:
      begin
        if (Assigned(FonColumnResized)) then
        begin
          ResizedColumn := pHDNotify(Msg.NMHdr)^.Item;
          Column := Columns[ResizedColumn];
          FonColumnResized(Column);
        end;
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
  ANitem: TListItem;
  DetailsNeeded: boolean;
  CustomSortNeeded: boolean;
begin
  if (ViewStyle = vsReport) and
     (FColumnSorted) then
  begin
    if (SortColumn < Columns.Count) then
      SetListHeaderSortState(Self, Columns[SortColumn], FSortState);

    CustomSortNeeded := (FDoDefault = false) or (FDoDefault and FIncludeSubFolders and (SortColumn = 0));
    DetailsNeeded := (SortColumn <> 0);

    if (DetailsNeeded) then
    begin
      for ANitem in Items do // Need to get all the details of the items. This will trigger the OwnerDataFetch event!
      begin
        if (FIncludeSubFolders) then
        begin
          if boolean(SendMessage(FrmGenerate.Handle, CM_WantsToClose, 0, 0)) then
            exit;
          if (ANitem.Index mod FrmGenerate.ModCount = 0) then
            SendMessage(FrmGenerate.Handle,
                        CM_SubFolderSortProgress,
                        ANitem.Index,
                        LPARAM(TSubShellFolder.GetRelativeName(Folders[ANitem.Index])));
        end;
      end;
    end;

    // Use an anonymous method. So we can test for FDoDefault, SortColumn and SortState
    // See also method ListSortFunc in Vcl.Shell.ShellCtrls.pas
    FoldersList.SortList(
      function(Item1, Item2: Pointer): integer
      const
        R: array [boolean] of Byte = (0, 1);

       begin
        Result := R[TSubShellFolder.GetIsFolder(Item2)] - R[TSubShellFolder.GetIsFolder(Item1)];
        if (Result = 0) then
        begin
          if (CustomSortNeeded) then
          begin
            if (SortColumn = 0) then // Compare the relative name, not just the filename.
              Result := CompareText(TSubShellFolder.GetRelativeName(Item1), TSubShellFolder.GetRelativeName(Item2))
            else
            begin // Compare the values from DetailStrings. Always text.
              if (SortColumn <= TShellFolder(Item1).DetailStrings.Count) and
                 (SortColumn <= TShellFolder(Item2).DetailStrings.Count) then
                Result := CompareText(TShellFolder(Item1).Details[SortColumn], TShellFolder(Item2).Details[SortColumn]);
            end;
          end
          else
          begin // Use the standard compare
            if (TShellFolder(Item1).ParentShellFolder <> nil) then
              Result := Smallint(TShellFolder(Item1).ParentShellFolder.CompareIDs(SortColumn,
                                                                                  TShellFolder(Item1).RelativeID,
                                                                                  TShellFolder(Item2).RelativeID));
          end;
        end;

        // Sort on Filename (Column 0), within SortColumn
        if (Result = 0) and
           (SortColumn <> 0) then
          Result := CompareText(TSubShellFolder.GetRelativeName(Item1), TSubShellFolder.GetRelativeName(Item2));

        // Reverse order
        if (SortState = THeaderSortState.hssDescending) then
          Result := Result * -1;
      end);
  end;
end;

// Copy files to clipboard
procedure TShellListView.FileNamesToClipboard(Cut: boolean = false);
var
  FileList: TStringList;
begin
  FileList := CreateSelectedFileList(true);
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

procedure TShellListView.ExecuteCommandExif(Verb: string; var Handled: boolean);
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

  if SameText(Verb, SCmdVerbRename) then
    FRefreshAfterContext := false;
end;

procedure TShellListView.CommandCompletedExif(Verb: String; Succeeded: Boolean);
begin
  if (not Succeeded) and (Verb = '') then
  begin
    FRefreshAfterContext := false;
    MessageDlgEx('Context menu failed', '', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK]);
  end;
end;

procedure TShellListView.ShowMultiContextMenu(MousePos: TPoint);
var
  FileList: TStringList;
begin
//TODO: Decide which items need a refresh. Not which items dont need it.
  FRefreshAfterContext := false;
  FileList := CreateSelectedFileList(false);
  try
    if (SelectedFolder <> nil) then
    begin
      FRefreshAfterContext := not FIncludeSubFolders;
      InvokeMultiContextMenu(Self, SelectedFolder, MousePos, ICM2, FileList);
    end;
  finally
    FileList.Free;
    if FRefreshAfterContext then
    begin
      ClearSelectionRefresh;
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
end;

procedure TShellListView.ClearSelectionRefresh;
var
  Indx: integer;
begin
  // Prevent calling OwnerDataFetch
  for Indx := 0 to Items.Count -1 do
    ListView_SetItemState(Handle, Indx, 0, LVIS_SELECTED);
  Refresh;
end;

procedure TShellListView.EnumColumns;
var
  MustLockWindow: boolean;
begin
  MustLockWindow := (not FDoDefault) or
                    (FColumnSorted);
  if (MustLockWindow) then
    SendMessage(Handle, WM_SETREDRAW, 0, 0);
  try
    if (FDoDefault) then
      inherited;

    if Assigned(FOnEnumColumnsAfterEvent) then
      FOnEnumColumnsAfterEvent(Self);

    if Enabled and
       ValidDir(Path) and
       (ViewStyle = vsReport) then // EnumColumns only called for ViewStyle=vsReport
    begin

      // Allow starting exiftool
      if (Assigned(FOnPathChange)) then
        FOnPathChange(Self);

      if (FIncludeSubFolders) then
      begin
        FrmGenerate.Show;
        SendMessage(FrmGenerate.Handle, CM_SubFolderSort, Items.Count, LPARAM(Path));
      end;

      try
        ColumnSort;
      finally
        if (FIncludeSubFolders) then
          FrmGenerate.Close;
      end;

      // All data loaded
      if (Assigned(FOnItemsLoaded)) then
        FOnItemsLoaded(Self);

    end;
  finally
    if (MustLockWindow) then
    begin
      SendMessage(Handle, WM_SETREDRAW, 1, 0);
      Invalidate; // Creates new window handle!
    end;
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

      if (FIncludeSubFolders) then // Only get icons for folders
      begin
        if (TSubShellFolder.GetIsFolder(Folders[ItemIndx])) then
        begin
          Hr := GetThumbCache(Folders[ItemIndx].AbsoluteID, HBmp, SIIGBF_ICONONLY, FThumbNails.Width, FThumbNails.Height);
          if (Hr = S_OK) then
            Add2ThumbNails(HBmp, ItemIndx, false);
        end;
        continue;
      end;

      Hr := GetThumbCache(Folders[ItemIndx].AbsoluteID, HBmp, SIIGBF_THUMBNAILONLY or SIIGBF_INCACHEONLY, FThumbNails.Width, FThumbNails.Height);
      if (Hr = S_OK) then
        Add2ThumbNails(HBmp, ItemIndx, false)
      else
      begin
        // No thumbnail in cache.
        // Show the Icon. That is reasonably fast.
        Hr := GetThumbCache(Folders[ItemIndx].AbsoluteID, HBmp, SIIGBF_ICONONLY, FThumbNails.Width, FThumbNails.Height);
        if (Hr = S_OK) then
          Add2ThumbNails(HBmp, ItemIndx, true);
      end;
    end;
  end;
end;

function TShellListView.CreateSelectedFileList(FullPaths: boolean): TStringList;
var
  AnItem: TListItem;
begin
  Result := TStringList.Create;
  for AnItem in Items do
    if (AnItem.Selected) then
    begin
      if (FullPaths) then
        Result.AddObject(Folders[AnItem.Index].PathName, Pointer(Folders[AnItem.Index].RelativeID))
      else
        Result.AddObject(RelFileName(AnItem.Index), Pointer(Folders[AnItem.Index].RelativeID));
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

procedure TShellListView.PopulateSubDirs(FRootFolder, FRelativeFolder: TSubShellFolder);
var
  ID: PItemIDList;
  EnumList: IEnumIDList;
  NumIDs: LongWord;
  HR: HResult;
  CanAdd: Boolean;
  NewFolder: IShellFolder;
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

    NewFolder := GetIShellFolder(FRelativeFolder.ShellFolder, ID);
    NewRelativeFolder := TSubShellFolder.Create(FRelativeFolder, ID, NewFolder);
    NewRelativeFolder.FRelativePath := FRelativeFolder.FRelativePath;
    if (TSubShellFolder.GetIsFolder(NewRelativeFolder)) then
    begin
      NewRelativeFolder.FRelativePath := IncludeTrailingPathDelimiter(NewRelativeFolder.FRelativePath) +
                                         TSubShellFolder.GetName(NewRelativeFolder, false);

      PopulateSubDirs(FRootFolder, NewRelativeFolder);
      FHiddenFolders.Add(NewRelativeFolder); // We dont want subfoldernames visible. But keep a reference, so we can free them
      Continue;
    end;

    CanAdd := True;
    if Assigned(OnAddFolder) then OnAddFolder(Self, NewRelativeFolder, CanAdd);

    if CanAdd then
      FoldersList.Add(NewRelativeFolder)
    else
      NewRelativeFolder.Free;
  end;
end;

procedure TShellListView.PopulateSubDirs(FRootFolder: TSubShellFolder);
begin
  PopulateSubDirs(FRootFolder, FRootFolder);
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

  if Assigned(FOnPopulateBeforeEvent) then
    FOnPopulateBeforeEvent(Self, FDoDefault);

  // Force initialization of array with zeroes
  SetLength(FThumbNailCache, 0);
  ClearHiddenItems;

  Items.BeginUpdate;
  if (FIncludeSubFolders) then
  begin
    FSubFolders := 0;
    FrmGenerate.Show;
    SendMessage(FrmGenerate.Handle, CM_SubFolderScan, FSubFolders, LPARAM(Path));
  end;

  try
    try
      inherited;
    finally
      Items.Count := FoldersList.Count;
      Items.EndUpdate;
    end;

    // Optimize memory allocation
    AllocBy := Items.Count;

    if (ViewStyle = vsReport) then
      exit;

    // Allow starting exiftool
    if (Assigned(FOnPathChange)) then
      FOnPathChange(Self);

    // Get Thumbnails and load in imagelist.

    if (FIncludeSubFolders) then
      SendMessage(FrmGenerate.Handle, CM_IconStart, Items.Count, LPARAM(Path));

    GetThumbNails;

  finally
    if (FIncludeSubFolders) then
      FrmGenerate.Close;
  end;

  // All data loaded
  if (Assigned(FOnItemsLoaded)) then
    FOnItemsLoaded(Self);

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

  if (not(FDoDefault) and
      not(csDesigning in ComponentState) and Assigned(FOnOwnerDataFetchEvent)) then
    FOnOwnerDataFetchEvent(Self, Item, Request, Folders[Item.Index])
  else
    Result := inherited;

  // Set the Item.caption. Could be a relative filename. E.g. Subdir\file1.jpg
  if (irText in Request) and
     (Item.Index >= 0) and
     (Item.Index < FoldersList.Count) and
     (Item.Caption = '') then
    Item.Caption := TSubShellFolder.GetRelativeName(Folders[Item.Index]);

  if (ViewStyle = vsIcon) then
    DoIcon;
end;

constructor TShellListView.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  ICM2 := nil;

  DoubleBuffered := true;
  FThumbNailSize := 0;
  FGenerating := 0;
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
  GetThumbNails;
  for AnItem in Items do
    AnItem.Update;
end;

function TShellListView.Path: string;
begin
  result := RootFolder.PathName;
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

function TShellListView.RelFileName(ItemIndex: integer = -1): string;
var
  AFolder: TShellFolder;
begin
  result := '';

  AFolder := GetSelectedFolder(ItemIndex);
  if (AFolder <> nil) and
     (TSubShellFolder.GetIsFolder(AFolder) = false) then
    result := TSubShellFolder.GetRelativeName(AFolder, false);
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
    FThumbNails.BlendColor := clBlack;
    FThumbNails.BkColor := clBlack;
    AnHourGlass := TBitmap.Create;
    try
      AnHourGlass.LoadFromResourceName(HInstance, HOURGLASS);
      ResizeBitmapCanvas(AnHourGlass, FThumbNailSize, FThumbNailSize, clWhite);
      FThumbNails.Add(AnHourGlass, nil);
    finally
      AnHourGlass.Free
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

procedure TShellListView.Add2ThumbNails(ABmp: HBITMAP; ANitemIndex: integer; NeedsGenerating: boolean);
var
  ABitMap: TBitmap;
begin
  ABitMap := TBitmap.Create;
  ABitMap.Canvas.Lock;
  try
    ABitMap.TransparentColor := FThumbNails.BkColor;
    ABitMap.Handle := ABmp;
    ResizeBitmapCanvas(ABitMap, FThumbNails.Width, FThumbNails.Height, FThumbNails.BkColor);
    Items[ANitemIndex].ImageIndex := FThumbNails.AddMasked(ABitMap, FThumbNails.BkColor);
    if (NeedsGenerating) then
      FThumbNailCache[ANitemIndex] := Items[ANitemIndex].ImageIndex * -1
    else
      FThumbNailCache[ANitemIndex] := Items[ANitemIndex].ImageIndex;
  finally
    ABitMap.Canvas.Unlock;
    DeleteObject(ABmp);
    ABitMap.Free;
  end;
end;

end.
