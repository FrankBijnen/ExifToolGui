unit ExifToolsGui_ShellTree;

// Create eventhandlers Before and After contextmenu.
// Stop and start Exiftool, else it's impossible to remove the Directory

interface

uses System.Classes, System.SysUtils,
     Winapi.Windows, Winapi.ShlObj, Winapi.Messages, Winapi.CommCtrl,
     Vcl.Shell.ShellCtrls, Vcl.ComCtrls,
     ExifToolsGUI_MultiContextMenu;

type

  TShellTreeView = class(Vcl.Shell.ShellCtrls.TShellTreeView, IShellCommandVerbExifTool)
  private
    FPreferredRoot: string;
    FPaths2Refresh: TStringList;
    ICM2: IContextMenu2;
    FOnEditingEnded: TTVEditedEvent;
    FOnBeforeContextMenu: TNotifyEvent;
    FOnAfterContextMenu: TNotifyEvent;
  protected
    procedure Edit(const Item: TTVItem); override;
    procedure InitNode(NewNode: TTreeNode; ID: PItemIDList; ParentNode: TTreeNode); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: boolean); override;
    procedure ShowMultiContextMenu(MousePos: TPoint);
    procedure WndProc(var Message: TMessage); override;
    procedure RefreshParentPaths(const APaths: TStringList);
    function  GetPath: string;
    procedure SetPath(APath: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecuteCommandExif(Verb: string; var Handled: boolean);
    procedure CommandCompletedExif(Verb: String; Succeeded: Boolean);
    procedure FileNamesToClipboard(Cut: boolean = false);
    procedure PasteFilesFromClipboard;
    function NodeFromPath(const FromNode: TTreenode; const APath: string): TTreeNode;
    procedure RefreshPath(const APath: string);
    procedure SetPaths2Refresh;
    procedure RefreshAfterPaste;
    procedure SyncShellTreeFromShellList;

    property OnBeforeContextMenu: TNotifyEvent read FOnBeforeContextMenu write FOnBeforeContextMenu;
    property OnAfterContextMenu: TNotifyEvent read FOnAfterContextMenu write FOnAfterContextMenu;
    property OnCustomDrawItem;
    property OnEditingEnded: TTVEditedEvent read FOnEditingEnded write FOnEditingEnded;
    property Path: string read GetPath write SetPath;
    property PreferredRoot: string read FPreferredRoot write FPreferredRoot;
 end;

implementation

uses
  System.IOUtils,
  Winapi.ActiveX,
  Vcl.Shell.ShellConsts, Vcl.Controls,
  ExifToolsGUI_Thumbnails, ExiftoolsGui_ShellList, ExifToolsGUI_Utils, UnitFilesOnClipBoard;

constructor TShellTreeView.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  StyleElements := [seFont, seBorder];
  DoubleBuffered := true;

  FPaths2Refresh := TStringList.Create;
  FPaths2Refresh.Sorted := true;
  FPaths2Refresh.Duplicates := TDuplicates.dupIgnore;
  ICM2 := nil;
  FPreferredRoot := '';
end;

destructor TShellTreeView.Destroy;
begin
  FPaths2Refresh.Free;
  inherited Destroy;
end;

procedure TShellTreeView.ShowMultiContextMenu(MousePos: TPoint);
begin
  if (SelectedFolder = nil) then
    exit;
  InvokeMultiContextMenu(Self, SelectedFolder, MousePos, ICM2);
end;

procedure TShellTreeView.Edit(const Item: TTVItem);
var
  Node: TTreeNode;
  S: string;
begin
  inherited Edit(Item);

  // Need an event after the rename. To make sure ExifTool is restarted.
  // Note: S is a var parm, but any changes made by the event handler are ignored.
  if (Item.pszText <> '') and
     (Assigned(FOnEditingEnded)) then
  begin
    Node := Items.GetNode(Item.hItem);
    S := Node.Text;
    FOnEditingEnded(Self, Node, S);
  end;
end;

procedure TShellTreeView.InitNode(NewNode: TTreeNode; ID: PItemIDList; ParentNode: TTreeNode);
var
  NewFolder: IShellFolder;
  TempFolder: TShellFolder;
begin
  // Archives (TAR, ZIP TGZ etc.) may be reported as folders in TCustomShellTreeView.PopulateNode
  // Resulting in needlessly scanning large files
  if not (otNonFolders in ObjectTypes) then
  begin
    NewFolder := GetIShellFolder(TShellFolder(ParentNode.Data).ShellFolder, ID);
    TempFolder := TShellFolder.Create(TShellFolder(ParentNode.Data), ID, NewFolder);
    try
      if not (ValidDir(TempFolder.PathName)) then
      begin
        NewNode.Delete;
        exit;
      end;
    finally
      TempFolder.Free;
    end;
  end;

  inherited InitNode(NewNode, ID, ParentNode);
end;

procedure TShellTreeView.DoContextPopup(MousePos: TPoint; var Handled: boolean);
var
  RightClickSave: boolean;
begin

  // RightClickSelect needs to be disabled within this method.
  // 'Selected' will be set to FRClickNode, leading to all kind of AV's (Especially WIN64)
  // See Vcl.ComCtrls at around line 12240 CNNotify, Case NM_RCLICK:
  RightClickSave := RightClickSelect;
  RightClickSelect := false;
  try
    if Assigned(FOnBeforeContextMenu) then
      FOnBeforeContextMenu(Self);

    ShowMultiContextMenu(MousePos);

  //  inherited;
    if Assigned(FOnAfterContextMenu) then
      FOnAfterContextMenu(Self);
  finally
    RightClickSelect := RightClickSave;
  end;
end;

procedure TShellTreeView.ExecuteCommandExif(Verb: string; var Handled: boolean);
var
  MyShellList: ExiftoolsGui_ShellList.TShellListView;
begin
  // Need a selected node
  if (Selected <> nil) then
  begin
    if SameText(Verb, SCmdVerbRefresh) then
    begin
      Refresh(Selected);
      Handled := true;
    end;
  end;

  if (ShellListView is ExiftoolsGui_ShellList.TShellListView) then
  begin

    // Need an assigned listview with thumbnailsize
    MyShellList := ExiftoolsGui_ShellList.TShellListView(ShellListView);

    if SameText(Verb, SCmdVerbGenThumbs) then
    begin
      GenerateThumbs(Path, false, MyShellList.ThumbNailSize, MyShellList.ShellListOnGenerateReady);
      Handled := true;
    end;

    if SameText(Verb, SCmdVerbGenThumbsSub) then
    begin
      GenerateThumbs(Path, true, MyShellList.ThumbNailSize, MyShellList.ShellListOnGenerateReady);
      Handled := true;
    end;
  end;

  if SameText(Verb, SCmdVerbPaste) then
    SetPaths2Refresh;

  if SameText(Verb, SCmdSelLeft) then
  begin
    SelectLeftDir;
    Handled := true;
  end;

  if SameText(Verb, SCmdVerDiff) then
  begin
    ShowCompareDlg(Path);
    Handled := true;
  end;

end;

procedure TShellTreeView.CommandCompletedExif(Verb: String; Succeeded: Boolean);
begin
  if SameText(Verb, SCmdVerbPaste) then
    RefreshAfterPaste;
end;

// Copy files to clipboard
procedure TShellTreeView.FileNamesToClipboard(Cut: boolean = false);
var
  FileList: TStringList;
begin
  FileList := TStringList.Create;
  try
    FileList.Add(SelectedFolder.PathName);
    SetFileNamesOnClipboard(FileList, Cut);
  finally
    FileList.Free;
  end;
end;

procedure TShellTreeView.PasteFilesFromClipboard;
var
  FileList: TStringList;
  Cut: boolean;
begin
  FileList := TStringList.Create;
  try
    if not GetFileNamesFromClipboard(FileList, Cut) then
      exit;

    UnitFilesOnClipBoard.PasteFilesFromClipBoard(Self, FileList, SelectedFolder.PathName, Cut);
  finally
    FileList.Free;
  end;
end;

function TShellTreeView.NodeFromPath(const FromNode: TTreenode; const APath: string): TTreeNode;
var
  APidl: PItemIDList;
begin
  result := nil;
  APidl := GetPidlFromName(APath);
  if not Assigned(APidl) then
    exit;

  try
    result := NodeFromAbsoluteID(FromNode, APidl);
  finally
    CoTaskMemFree(APidl);
  end;
end;

procedure TShellTreeView.RefreshPath(const APath: string);
var
  ANode: TTreeNode;
begin
  ANode := NodeFromPath(Items[0], APath);
  if not Assigned(ANode) then
    exit;
  Refresh(ANode);
end;

procedure TShellTreeView.RefreshParentPaths(const APaths: TStringList);
var
  APath: string;
begin
  for APath in APaths do
    RefreshPath(APath);
end;

procedure TShellTreeView.SetPaths2Refresh;
var
  FileList: TStringList;
  AFile: string;
  Cut: boolean;
begin
  FPaths2Refresh.Clear;
  FileList := TStringList.Create;
  try
    GetFileNamesFromClipboard(FileList, Cut);
    if (Cut) then
    begin
      for AFile in FileList do
        FPaths2Refresh.Add(ExtractFileDir(ExcludeTrailingPathDelimiter(AFile)));
    end;
  finally
    FileList.Free;
  end;
end;

procedure TShellTreeView.RefreshAfterPaste;
var
  CrNormal, CrWait: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    RefreshParentPaths(FPaths2Refresh);
  finally
    FPaths2Refresh.Clear;
    SetCursor(CrNormal);
  end;
end;

function TShellTreeView.GetPath: string;
begin
  result := inherited Path;
end;

procedure TShellTreeView.SetPath(APath: string);
begin
  if TPath.IsUNCPath(APath) then
    Root := APath
  else
  begin
   if (FPreferredRoot <> '') and
      (Root <> FPreferredRoot) then
    Root := FPreferredRoot;
  end;

  inherited Path := APath;
end;

// Make the path, from the selected file in the FileList, visible in the Directory Treeview
// Notes: Without selecting. That would refresh the ShellList
//        Especially useful when subdirs are shown
procedure TShellTreeView.SyncShellTreeFromShellList;
var
  TempNode: TTreenode;
  NewNode: TTreenode;
  APath: string;
  ASub: string;
  ASubPath: string;
  Rect: TRect;
begin
  if (ShellListView.SelectedFolder = nil) then
    exit;

  Items.BeginUpdate;
  try
    NewNode := Items[0];
    APath := ExtractFilePath(ShellListView.SelectedFolder.PathName);
    // Break-up Path in pieces, and find them in the treeview.
    // Expand, if needed
    // Make top item
    ASubPath := '';
    while (APath <> '') do
    begin
      ASub := NextField(APath, PathDelim);

      if (ASub = '?') then // Check for long filenames. \\?\C:\blabla\
      begin
        ASubPath := '';
        continue;
      end;

      ASubPath := ASubPath + ASub + PathDelim;
      TempNode := NodeFromPath(NewNode, ASubPath);
      if (TempNode = nil) then
        continue;

      NewNode := TempNode;
      if (NewNode.Expanded = false) then
        NewNode.Expand(false);
    end;

    // Is node in View?
    TreeView_GetItemRect(Handle, NewNode.ItemId, Rect, True);
    if (Rect.Top < 0) or
       (Rect.Bottom > ClientHeight) then
      TopItem := NewNode; // No, make top item

  finally
    Items.EndUpdate;
  end;
end;

// to handle submenus of context menus.
procedure TShellTreeView.WndProc(var Message: TMessage);
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

end.
