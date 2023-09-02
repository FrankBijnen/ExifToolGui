unit ExiftoolsGui_ShellList;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Threading,
  Winapi.Windows, Winapi.Messages,
  Vcl.Shell.ShellCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Controls,
  ExifToolsGUI_Thumbnails;

// Extend ShellListview, keeping the same Type. So we dont have to register it in the IDE
// Extended to support:
// Thumbnails.
// User defined columns.
// Column sorting.
// Multi-select context menu
// Copy selected files to and from Clipboard
// You need to make some modifications to the Embarcadero source. See the readme in the Vcl.ShellCtrls dir.

type
  THeaderSortState = (hssNone, hssAscending, hssDescending);

  TThumbGenStatus = (Started, Ended);
  TThumbErrorEvent = procedure(Sender: TObject; Item: TListItem; E: Exception) of object;
  TThumbGenerateEvent = procedure(Sender: TObject; Item: TListItem; Status: TThumbGenStatus; Total, Remaining: integer) of object;
  TPopulateBeforeEvent = procedure(Sender: TObject; var DoDefault: boolean) of object;
  TOwnerDataFetchEvent = procedure(Sender: TObject; Item: TListItem; Request: TItemRequest; Afolder: TShellFolder) of object;

  TShellListView = class(Vcl.Shell.ShellCtrls.TShellListView)
  private
    FThreadPool: TThreadPool;
    FThumbTasks: Tlist;
    FDoDefault: boolean;

    FonColumnResized: TNotifyEvent;
    FColumnSorted: boolean;
    FSortColumn: integer;
    FSortState: THeaderSortState;

    FIConPopup: TPopupMenu;
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
    FOnEnumColumnsBeforeEvent: TNotifyEvent;
    FOnEnumColumnsAfterEvent: TNotifyEvent;
    FOnOwnerDataFetchEvent: TOwnerDataFetchEvent;
    procedure SetColumnSorted(AValue: boolean);
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
    procedure EnumColumns; override;
    procedure GetThumbNails; virtual;
    procedure DoContextPopup(MousePos: TPoint; var Handled: boolean); override;
    procedure Populate; override;
    function OwnerDataFetch(Item: TListItem; Request: TItemRequest): boolean; override;
    procedure Add2ThumbNails(ABmp: HBITMAP; ANitemIndex: integer; NeedsGenerating: boolean);
    procedure CancelThumbTasks;
    procedure RemoveThumbTask(ItemIndex: integer);
    procedure ShowMultiContextMenu(MousePos: TPoint);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    function FileName(ItemIndex: integer = -1): string;
    function FileExt(ItemIndex: integer = -1): string;
    procedure ColumnClick(Column: TListColumn);
    procedure FileNamesToClipboard(Cut: boolean = false);
    procedure PasteFilesFromClipboard;

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
    property OnEnumColumnsBeforeEvent: TNotifyEvent read FOnEnumColumnsBeforeEvent write FOnEnumColumnsBeforeEvent;
    property OnEnumColumnsAfterEvent: TNotifyEvent read FOnEnumColumnsAfterEvent write FOnEnumColumnsAfterEvent;
    property OnOwnerDataFetchEvent: TOwnerDataFetchEvent read FOnOwnerDataFetchEvent write FOnOwnerDataFetchEvent;
    property IconPopup: TPopupMenu read FIConPopup write FIConPopup;
  end;

implementation

uses System.AnsiStrings, System.Win.ComObj, System.UITypes,
     Winapi.CommCtrl, Winapi.ShlObj, Vcl.Graphics, ExifToolsGUI_Utils,
     UnitFilesOnClipBoard;

// res file contains the ?

{$R ShellList.res}

const
  QUESTIONMARK = 'QUESTIONMARK';

  // Contextmenu supporting multi select

procedure InvokeMultiContextMenu(Owner: TWinControl; AFolder: TShellFolder; AFileList: TStrings; MousePos: TPoint);
var
  chEaten, dwAttributes: ULONG;
  FilePIDL: PItemIDList;
  CM: IContextMenu;
  Menu: HMenu;
  Command: LongBool;
  ICM2: IContextMenu2;
  ICI: TCMInvokeCommandInfo;
  ICmd: integer;
  ZVerb: array [0..255] of AnsiChar;
  Verb: string;
  Handled: boolean;
  SCV: IShellCommandVerb;
  HR: HResult;
  ItemIDListArray: array of PItemIDList;
  Index: integer;
begin
  if (AFileList.Count = 0) then
    exit;
  if (AFolder.ShellFolder = nil) then
    exit;

  // Setup ItemIDListArray.
  SetLength(ItemIDListArray, AFileList.Count);
  for Index := 0 to AFileList.Count - 1 do
  begin
    // Get the relative PItemIDList of each file in the list
    OleCheck(AFolder.ShellFolder.ParseDisplayName(Owner.Handle, nil, PWideChar(AFileList[Index]), chEaten, FilePIDL, dwAttributes));
    ItemIDListArray[Index] := FilePIDL;
  end;

  // get the IContextMenu Interface for the file array
  AFolder.ShellFolder.GetUIObjectOf(Owner.Handle, AFileList.Count, ItemIDListArray[0], IID_IContextMenu, nil, CM);
  if CM = nil then
    exit;

  Winapi.Windows.ClientToScreen(Owner.Handle, MousePos);
  Menu := CreatePopupMenu;
  try
    CM.QueryContextMenu(Menu, 0, 1, $7FFF, CMF_EXPLORE or CMF_CANRENAME);
    CM.QueryInterface(IID_IContextMenu2, ICM2); // To handle submenus.
    try
      Command := TrackPopupMenu(Menu,
                                TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON or TPM_RETURNCMD,
                                MousePos.X, MousePos.Y, 0, Owner.Handle, nil);
    finally
      ICM2 := nil;
    end;

    if Command then
    begin
      ICmd := LongInt(Command) - 1;
      HR := CM.GetCommandString(ICmd, GCS_VERBA, nil, ZVerb, SizeOf(ZVerb));
      Verb := string(System.AnsiStrings.StrPas(ZVerb));
      Handled := False;
      if Supports(Owner , IShellCommandVerb, SCV) then
      begin
        HR := 0;
        SCV.ExecuteCommand(Verb, Handled);
      end;

      if not Handled then
      begin
        FillChar(ICI, SizeOf(ICI), #0);
        with ICI do
        begin
          cbSize := SizeOf(ICI);
          HWND := 0;
          lpVerb := MakeIntResourceA(ICmd);
          nShow := SW_SHOWNORMAL;
        end;
        HR := CM.InvokeCommand(ICI);
      end;

      if Assigned(SCV) then
        SCV.CommandCompleted(Verb, HR = S_OK);
    end;
  finally
    DestroyMenu(Menu);
  end;
end;

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
begin
  if (ViewStyle = vsReport) and FColumnSorted then
  begin
    if (FSortColumn < Columns.Count) then
      SetListHeaderSortState(Self, Columns[FSortColumn], FSortState);

    if (SortColumn <> 0) then
      for ANitem in Items do; // Need to get all the details of the items
    // Use an anonymous method. So we can test for FDoDefault, SortColumn and SortState
    // See also method ListSortFunc in Vcl.Shell.ShellCtrls.pas
    FoldersList.SortList(
      function(Item1, Item2: Pointer): integer

      const
        R: array [boolean] of Byte = (0, 1);
      begin
        Result := R[TShellFolder(Item2).IsFolder] - R[TShellFolder(Item1).IsFolder];
        if (Result = 0) then
        begin
          if (FDoDefault) or (SortColumn = 0) then // Use the standard compare
          begin
            if (TShellFolder(Item1).ParentShellFolder <> nil) then
              Result := Smallint(TShellFolder(Item1).ParentShellFolder.CompareIDs(SortColumn, TShellFolder(Item1).RelativeID,
                TShellFolder(Item2).RelativeID));
          end
          else
          begin // Compare the values from DetailStrings. Always text.
            if (SortColumn <= TShellFolder(Item1).DetailStrings.Count) and (SortColumn <= TShellFolder(Item2).DetailStrings.Count) then
              Result := CompareText(TShellFolder(Item1).Details[SortColumn], TShellFolder(Item2).Details[SortColumn]);
          end;
        end;

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
  AFile: string;
  Rc: integer;
  Fs: TSearchRec;
  TargetDir: string;
  TargetFile: string;
  Cut: boolean;
  Succes: boolean;
  WriteFile: boolean;
  OverWriteAll: boolean;
  Confirmation: integer;
  CrNormal, CrWait: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);

  OverWriteAll := false;
  FileList := TStringList.Create;
  try
    if not GetFileNamesFromClipboard(FileList, Cut) then
      exit;

    TargetDir := RootFolder.PathName;
    for AFile in FileList do
    begin
      // No directories alllowed
      Rc := System.SysUtils.FindFirst(AFile, faAnyFile - faDirectory, Fs);
      System.SysUtils.FindClose(Fs);
      if (Rc <> 0) then
        continue;

      // Dont copy to ourselves.
      TargetFile := IncludeTrailingBackslash(TargetDir) + Fs.Name;
      if (CompareText(TargetFile, AFile) = 0) then
        raise Exception.Create('Source and target should be different!');

      // Overwrite ?
      WriteFile := OverWriteAll;
      if not WriteFile then
        WriteFile := not FileExists(TargetFile);
      if not WriteFile then
      begin
        Confirmation := MessageDlgEx(Format('File %s exists. Overwrite?', [TargetFile]), '',
                                     TMsgDlgType.mtWarning,
                                     [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel, TMsgDlgBtn.mbYesToAll]
                                    );
        case Confirmation of
          MrYes:
            WriteFile := true;
          MrNo:
            WriteFile := false;
          MrCancel:
            exit;
          mrYesToAll:
          begin
            WriteFile := true;
            OverWriteAll := true;
          end;
        end;
      end;

      // Write file?
      if not (WriteFile) then
        continue;

      SetCursor(CrWait);  // Set cursor again. Confirmation dialog could have reset it.
      if (Cut) then
        Succes := MoveFile(PWideChar(AFile), PWideChar(TargetFile))
      else
        Succes := CopyFile(PWideChar(AFile), PWideChar(TargetFile), false);
      if not Succes then
        raise Exception.Create(Format('Overwrite %s failed.', [AFile]));
    end;
  finally
    FileList.Free;
    SetCursor(CrNormal);
    Refresh;
  end;
end;

procedure TShellListView.ShowMultiContextMenu(MousePos: TPoint);
var FileList: TStringList;
begin
  FileList := CreateSelectedFileList(false);
  try
    InvokeMultiContextMenu(Self, RootFolder, FileList, MousePos);
  finally
    FileList.Free;
    Refresh;
  end;
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

procedure TShellListView.EnumColumns;
begin
  if Assigned(FOnEnumColumnsBeforeEvent) then
    FOnEnumColumnsBeforeEvent(Self);

  if (FDoDefault) then
    inherited;

  if Assigned(FOnEnumColumnsAfterEvent) then
    FOnEnumColumnsAfterEvent(Self);

  ColumnSort;
end;

procedure TShellListView.CMThumbStart(var Message: TMessage);
begin
  if (Assigned(FOnNotifyGenerateEvent)) then
    FOnNotifyGenerateEvent(Self, Items[Message.WParam], TThumbGenStatus.Started, Items.Count, FGenerating);
end;

procedure TShellListView.CMThumbEnd(var Message: TMessage);
begin
  RemoveThumbTask(Message.WParam);
  if (Assigned(FOnNotifyGenerateEvent)) then
    FOnNotifyGenerateEvent(Self, Items[Message.WParam], TThumbGenStatus.Ended, Items.Count, FGenerating);
end;

procedure TShellListView.CMThumbError(var Message: TMessage);
begin
  RemoveThumbTask(Message.WParam);
  if (Assigned(FOnNotifyErrorEvent)) then
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
  ANitem: TListItem;
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

    for ANitem in Items do
    begin
      ItemIndx := ANitem.Index;

      Hr := GetThumbCache(Folders[ItemIndx].PathName, HBmp, SIIGBF_THUMBNAILONLY or SIIGBF_INCACHEONLY, FThumbNails.Width, FThumbNails.Height);
      if (Hr = S_OK) then
        Add2ThumbNails(HBmp, ItemIndx, false)
      else
      begin
        // No thumbnail in cache.
        // Show the Icon. That is reasonably fast.
        Hr := GetThumbCache(Folders[ItemIndx].PathName, HBmp, SIIGBF_ICONONLY, FThumbNails.Width, FThumbNails.Height);
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
        Result.Add(Folders[AnItem.Index].PathName)
      else
        Result.Add(FileName(AnItem.Index));
    end;
end;

procedure TShellListView.DoContextPopup(MousePos: TPoint; var Handled: boolean);
begin
  if (ViewStyle = vsIcon) then
    FIConPopup.Popup(ClientToScreen(MousePos).X, ClientToScreen(MousePos).Y)
  else
    ShowMultiContextMenu(MousePos);
  Handled := true;
//  inherited;
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

  // Force initialization of array with zeroes
  SetLength(FThumbNailCache, 0);

  if Assigned(FOnPopulateBeforeEvent) then
    FOnPopulateBeforeEvent(Self, FDoDefault);

  inherited;

  // Optimize memory allocation
  AllocBy := Items.Count;

  // Get Thumbnails and load in imagelist.
  GetThumbNails;
end;

// When in vsReport mode, calls the OwnerDataFetch event to get the item.caption and subitems.
//
// Sets the Item.ImageIndex when the listview is in vsIcon mode. When not avail (<0) it start the generating.
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
    // The bitmap in the cache is a thumbnail
    begin
      Item.ImageIndex := FThumbNailCache[ItemIndx];
      exit;
    end;

    Item.ImageIndex := FThumbNailCache[ItemIndx] * -1;
    FThumbNailCache[ItemIndx] := Item.ImageIndex; // Just try it once.

    // Allowed to generate?
    if (FThumbAutoGenerate = false) then
      exit;

    // Generate the thumbnail asynchronously
    System.TMonitor.Enter(FThumbTasks);
    try
      inc(FGenerating);
      // Add to list of thumbnails to generate
      TaskId := FThumbTasks.Add(nil);
      FThumbTasks[TaskId] := TThumbTask.Create(ItemIndx, Self, Self.RootFolder.AbsoluteID, FThreadPool, FThumbNailSize);
    finally
      System.TMonitor.exit(FThumbTasks);
    end;

    // Actually start the task. It will create a HBITMAP, and send a message to the ShellListView window.
    // Updating the imagelist must be done in the main thread.
    TThumbTask(FThumbTasks[TaskId]).Start;

    // Send a message that generating begins.
    PostMessage(Self.Handle, CM_ThumbStart, 0, 0);
  end;

begin
  Result := true; // The inherited always return true!

  if not(FDoDefault) and not(csDesigning in ComponentState) and Assigned(FOnOwnerDataFetchEvent) then
    FOnOwnerDataFetchEvent(Self, Item, Request, Folders[Item.Index])
  else
    Result := inherited;

  if (ViewStyle = vsIcon) then
    DoIcon;
end;

constructor TShellListView.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  FThumbNailSize := 0;
  FGenerating := 0;

  InitSortSpec(0, THeaderSortState.hssNone);
  FThumbTasks := Tlist.Create;
  FThumbNails := TImageList.Create(Self);
  SetLength(FThumbNailCache, 0);
  ResetPool(FThreadPool);
end;

destructor TShellListView.Destroy;
begin
  CancelThumbTasks;
  FThumbTasks.Free;
  FThumbNails.Free;
  SetLength(FThumbNailCache, 0);
  FreeAndNil(FThreadPool);

  inherited;
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
    System.TMonitor.exit(FThumbTasks);
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
      dec(FGenerating);
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
    System.TMonitor.exit(FThumbTasks);
  end;
end;

function TShellListView.FileName(ItemIndex: integer = -1): string;
begin
  Result := '';
  if (ItemIndex = -1) and (Selected <> nil) then
    Result := ExtractFileName(Folders[Selected.Index].PathName)
  else if (ItemIndex > -1) and (ItemIndex < Items.Count) then
    Result := ExtractFileName(Folders[ItemIndex].PathName);
end;

function TShellListView.FileExt(ItemIndex: integer = -1): string;
begin
  Result := '';
  if (ItemIndex = -1) and (Selected <> nil) then
    Result := ExtractFileExt(Folders[Selected.Index].PathName)
  else if (ItemIndex > -1) and (ItemIndex < Items.Count) then
    Result := ExtractFileExt(Folders[ItemIndex].PathName);
end;

procedure TShellListView.ColumnClick(Column: TListColumn);
var
  I: integer;
  Ascending: boolean;
  State: THeaderSortState;
begin
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
  Refresh;
end;

procedure TShellListView.SetColumnSorted(AValue: boolean);
begin
  if (FColumnSorted <> AValue) then
  begin
    FColumnSorted := AValue;
  end;
  if FColumnSorted then
    Sorted := false;
end;

procedure TShellListView.InitThumbNails;
var
  AQuestionMark: TBitmap;
begin
  FThumbNails.Clear;
  if (FThumbNailSize <> 0) then
  begin
    FThumbNails.Width := FThumbNailSize;
    FThumbNails.Height := FThumbNailSize;
    FThumbNails.BlendColor := clBlack;
    FThumbNails.BkColor := clBlack;
    AQuestionMark := TBitmap.Create;
    try
      AQuestionMark.LoadFromResourceName(HInstance, QUESTIONMARK);
      ResizeBitmapCanvas(AQuestionMark, FThumbNailSize, FThumbNailSize, clWhite);
      FThumbNails.Add(AQuestionMark, nil);
    finally
      AQuestionMark.Free
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
