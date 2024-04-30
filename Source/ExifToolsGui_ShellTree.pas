unit ExifToolsGui_ShellTree;

// Create eventhandlers Before and After contextmenu.
// Stop and start Exiftool, else it's impossible to remove the Directory

interface

uses System.Classes, System.SysUtils,
     Winapi.Windows, Winapi.ShlObj, Winapi.Messages,
     Vcl.Shell.ShellCtrls, Vcl.ComCtrls,
     ExifToolsGUI_MultiContextMenu;

type

  TShellTreeView = class(Vcl.Shell.ShellCtrls.TShellTreeView, IShellCommandVerbExifTool)
  private
    FPaths2Refresh: TStringList;
    ICM2: IContextMenu2;
    FOnBeforeContextMenu: TNotifyEvent;
    FOnAfterContextMenu: TNotifyEvent;
  protected
    procedure DoContextPopup(MousePos: TPoint; var Handled: boolean); override;
    procedure ShowMultiContextMenu(MousePos: TPoint);
    procedure WndProc(var Message: TMessage); override;
    procedure RefreshParentPaths(const APaths: TStringList);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecuteCommandExif(Verb: string; var Handled: boolean);
    procedure CommandCompletedExif(Verb: String; Succeeded: Boolean);
    procedure FileNamesToClipboard(Cut: boolean = false);
    procedure PasteFilesFromClipboard;
    function NodeFromPath(const APath: string): TTreeNode;
    procedure RefreshPath(const APath: string);
    procedure SetPaths2Refresh;
    procedure RefreshAfterPaste;
    property OnBeforeContextMenu: TNotifyEvent read FOnBeforeContextMenu write FOnBeforeContextMenu;
    property OnAfterContextMenu: TNotifyEvent read FOnAfterContextMenu write FOnAfterContextMenu;
    property OnCustomDrawItem;
 end;

implementation

uses
  Winapi.ActiveX,
  Vcl.Shell.ShellConsts,
  ExifToolsGUI_Thumbnails, ExiftoolsGui_ShellList, UnitFilesOnClipBoard;

constructor TShellTreeView.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FPaths2Refresh := TStringList.Create;
  FPaths2Refresh.Sorted := true;
  FPaths2Refresh.Duplicates := TDuplicates.dupIgnore;
  ICM2 := nil;
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
    if (Verb = SCmdVerbRefresh) then
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

function TShellTreeView.NodeFromPath(const APath: string): TTreeNode;
var
  APidl: PItemIDList;
begin
  APidl := GetPidlFromName(APath);
  try
    result := NodeFromAbsoluteID(Items[0], APidl);
  finally
    CoTaskMemFree(APidl);
  end;
end;

procedure TShellTreeView.RefreshPath(const APath: string);
var
  ANode: TTreeNode;
begin
  ANode := NodeFromPath(APath);
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
