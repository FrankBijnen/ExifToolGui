unit ExifToolsGUI_Thumbnails;

interface

uses Winapi.ShlObj, Winapi.ActiveX, Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Threading,
  Vcl.Forms, Vcl.Dialogs, Vcl.Shell.ShellCtrls;

const
  VolumeCachesKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches';
  StateFlag = 'StateFlags';

type
  TStateFlagId = string[4];

const
  CM_ThumbStart = WM_USER + 1;

const
  CM_ThumbEnd = WM_USER + 2;

const
  CM_ThumbError = WM_USER + 3;

const
  CM_ThumbRefresh = WM_USER + 4;

type
  TThumbType = (ttIcon, ttThumb, ttThumbCache, ttThumbBiggerCache, ttThumbBiggerNoCache);

  TThumbTask = class(TTask, ITask)
  private
    FHandle: HWND;
    FItemIndex: integer;
    FMax: integer;
    FListView: TShellListView;
    FPitemIDListItem: pointer;
    FPitemIDListRoot: pointer;
    FThreadPool: TThreadPool;
    FPathName: string;
    procedure DoExecuteListView;
    procedure DoExecuteBackground;
  public
    constructor Create(const AItemIndex: integer; const AListView: TShellListView;
                       const AThreadPool: TThreadPool; const AMax: integer); overload;
    constructor Create(const AItemIndex: integer; const AHandle: HWND; const APathName: string; const AMax: integer); overload;
    destructor Destroy; override;
    function Start: ITask;
    procedure Cancel;

    property IsQueued;
    property ItemIndex: integer read FItemIndex write FItemIndex;
  end;

  // Image thumbnails
function GetThumbCache(APIdl: PItemIDList; ThumbType: TThumbType; AMaxX, AMaxY: longint;
                       var hBmp: HBITMAP): HRESULT; overload;
function GetThumbCache(APath: string; ThumbType: TThumbType; AMaxX, AMaxY: longint;
                       var hBmp: HBITMAP): HRESULT; overload;
procedure GenerateThumbs(AFilePath: string; Subdirs: boolean; AMax: longint; FOnReady: TNotifyEvent = nil);

// Functions for CleanMgr.exe
function ExistsSageSet(const StateFlagId: TStateFlagId): boolean;
function RunAsAdmin(const Handle: HWND; const Path, Params: string; Show: integer): boolean;

implementation

uses Winapi.ShellAPI, System.Win.Registry, System.UITypes, System.Win.ComObj,
  ExifToolsGUI_Utils, UFrmGenerate;


// TThumbTask. Generates Thumbnail in a separate thread.

// Constructor for use in Listview
constructor TThumbTask.Create(const AItemIndex: integer; const AListView: TShellListView;
                              const AThreadPool: TThreadPool; const AMax: integer);
begin
  FItemIndex := AItemIndex;
  FListView := AListView;
  FHandle := FListView.Handle;
  FPitemIDListRoot := AListView.RootFolder.AbsoluteID;
  FPitemIDListItem := AListView.Folders[FItemIndex].AbsoluteID;
  FThreadPool := AThreadPool;
  FMax := AMax;
  FPathName := AListView.Folders[FItemIndex].PathName;

  inherited Create(nil, TNotifyEvent(nil), DoExecuteListView, FThreadPool, nil, []);
end;

// Constructor for background use. Shows a form with progressbar
constructor TThumbTask.Create(const AItemIndex: integer; const AHandle: HWND; const APathName: string; const AMax: integer);
begin
  FItemIndex := AItemIndex;
  FHandle := AHandle;
  FPathName := APathName;
  FMax := AMax;
  inherited Create(nil, TNotifyEvent(nil), DoExecuteBackground, Threadpool.Default, nil, []);
end;

destructor TThumbTask.Destroy;
begin
  SetLength(FPathName, 0);
  inherited;
end;

procedure TThumbTask.DoExecuteListView;
var
  hBmp: HBITMAP;
  Hr: HRESULT;
begin
  CoInitialize(nil);
  try
    try
      Hr := GetThumbCache(FPitemIDListItem, TThumbType.ttThumb, FMax, FMax, hBmp);

      // The task is canceled, or the current path has changed.
      // Dont send any messages, but delete bitmap. If the handle is invalid, doesn't matter
      if (GetStatus = TTaskStatus.Canceled) or
         (FPitemIDListRoot <> FListView.RootFolder.AbsoluteID) then
      begin
        if (Hr = S_OK) then
          DeleteObject(hBmp); // Delete the Bitmap, The caller will not!
        exit;
      end;

      // Getting a thumbnail failed. return an Icon
      if (HR <> S_OK) then
        Hr := GetThumbCache(FPitemIDListItem, TThumbType.ttIcon, FMax, FMax, hBmp);

      if (Hr = S_OK) then
        // We must update the imagelist in the main thread, send a message

        PostMessage(FHandle, CM_ThumbRefresh, FItemIndex, hBmp);

      // Sendmessage that task has finished.
      // We must wait for this message, to be sure that the Task object does not get freed to soon.
      SendMessage(FHandle, CM_ThumbEnd, FItemIndex, 0);

    except
      on E: Exception do
      begin
        // Sendmessage that task is in error
        SendMessage(FHandle, CM_ThumbError, FItemIndex, LPARAM(E));
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TThumbTask.DoExecuteBackground;
var
  hBmp: HBITMAP;
  Hr: HRESULT;
begin
  CoInitialize(nil);
  try
    if (GetStatus = TTaskStatus.Canceled) or (boolean(SendMessage(FHandle, CM_WantsToClose, 0, 0))) then
      exit;

    Hr := GetThumbCache(FPathName, TThumbType.ttThumb, FMax, FMax, hBmp);
    // We must update the form in the main thread, send a message
    if (Hr = S_OK) then
      SendMessage(FHandle, CM_ThumbGenProgress, FItemIndex, LPARAM(ExtractFileName(FPathName)));

    DeleteObject(hBmp);
  finally
    CoUninitialize;
  end;
end;

function TThumbTask.Start: ITask;
begin
  result := inherited;
end;

procedure TThumbTask.Cancel;
begin
  inherited;
end;

function GetThumbCache(APIdl: PItemIDList; ThumbType: TThumbType; AMaxX, AMaxY: longint;
                       var hBmp: HBITMAP): HRESULT; overload;
var
  Tries: integer;
  FileShellItemImage: IShellItemImageFactory;
  S: TSize;
  Flags: TSIIGBF;
begin
  result := S_FALSE;
  hBmp := 0;

  case ThumbType of
    TThumbType.ttIcon:
      Flags := SIIGBF_ICONONLY;
    TThumbType.ttThumb:
      Flags := SIIGBF_THUMBNAILONLY;
    TThumbType.ttThumbCache:
      Flags := SIIGBF_THUMBNAILONLY or SIIGBF_INCACHEONLY;
    TThumbType.ttThumbBiggerCache:
      Flags := SIIGBF_THUMBNAILONLY or SIIGBF_BIGGERSIZEOK or SIIGBF_INCACHEONLY;
    TThumbType.ttThumbBiggerNoCache:
      Flags := SIIGBF_THUMBNAILONLY or SIIGBF_BIGGERSIZEOK;
    else
      exit;
  end;
  result := SHCreateItemFromIDList(APIdl, IShellItemImageFactory, FileShellItemImage);

  if Succeeded(result) then
  begin
    S.cx := AMaxX;
    S.cy := AMaxY;
    result := FileShellItemImage.GetImage(S, Flags, hBmp);

    // TODO: Figure out why a retry is needed.
    Tries := 2;
    while (ThumbType = TThumbType.ttThumb) and
          (Tries > 0) and
          not Succeeded(result) do
    begin
      Dec(Tries);
      Sleep(50);
      result := FileShellItemImage.GetImage(S, Flags, hBmp);
    end;
  end;
end;

function GetThumbCache(APath: string; ThumbType: TThumbType; AMaxX, AMaxY: longint;
                       var hBmp: HBITMAP): HRESULT; overload;
var APidl: PItemIDList;
begin
  result := S_FALSE;
  APidl := GetPidlFromName(APath);
  if not Assigned(APidl) then
    exit;

  try
    result := GetThumbCache(APidl, ThumbType, AMaxX, AMaxY, hBmp);
  finally
    CoTaskMemFree(APidl);
  end;
end;

function InternalGenerateThumbs(AFilePath: string; AForm: TCustomForm; Subdirs: boolean; Level, AMax: longint; FOnReady: TNotifyEvent): boolean;
var
  Fs: TSearchRec;
  Rc, NrOfFiles, Indx: integer;
  ThisThumb: string;
  Tasks: array of ITask;
begin
  result := not boolean(SendMessage(AForm.Handle, CM_WantsToClose, 0, 0));
  if (result = false) then
    exit;

  // Count nr of files for the Dir.
  // Note: This is only an estimate. At the end of this function the array is reset to it's real length.
  NrOfFiles := GetNrOfFiles(AFilePath, '*.*', false);

  // Update progress form
  SendMessage(AForm.Handle, CM_ThumbGenStart, NrOfFiles, LPARAM(AFilePath));

  // Initial size of the Tasks array. Could be reset
  SetLength(Tasks, NrOfFiles);
  Indx := 0;

{$WARN SYMBOL_PLATFORM OFF}
  Rc := FindFirst(IncludeTrailingPathDelimiter(AFilePath) + '*.*', faAnyFile - (faHidden or faSysFile), Fs);
{$WARN SYMBOL_PLATFORM ON}

  while (Rc = 0) and (result) do
  begin
    result := not boolean(SendMessage(AForm.Handle, CM_WantsToClose, 0, 0));
    if (result = false) then
      break;

    if (Fs.Name <> '.') and (Fs.Name <> '..') then
    begin
      ThisThumb := IncludeTrailingPathDelimiter(AFilePath) + Fs.Name;
      if ((Fs.Attr and faDirectory) <> 0) then
      begin
        if (Subdirs) then
          result := result and InternalGenerateThumbs(ThisThumb, AForm, Subdirs, Level + 1, AMax, FOnReady);
      end
      else
      begin
        Tasks[Indx] := TThumbTask.Create(Indx, AForm.Handle, ThisThumb, AMax).Start;
        inc(Indx);
      end;
    end;
    Rc := FindNext(Fs);
  end;
  FindClose(Fs);

  SetLength(Tasks, Indx); // Only wait for Tasks actually created.
  TTask.WaitForAll(Tasks);

  if (Level = 0) then
  begin
    FrmGenerate.Close;
    if (Assigned(FOnReady)) then
      FOnReady(nil);
  end;
end;

procedure GenerateThumbs(AFilePath: string; Subdirs: boolean; AMax: longint; FOnReady: TNotifyEvent = nil);
begin
  // One at a time!
  if (FrmGenerate.Showing) then
    exit;

  FrmGenerate.Show;

  // Create a thread that creates the Thumbnail generating threads.
  // So the main (UI) thread is not blocked.
  TTask.Run(
    procedure
    begin
      InternalGenerateThumbs(AFilePath, FrmGenerate, Subdirs, 0, AMax, FOnReady);
    end);
end;


function RunAsAdmin(const Handle: HWND; const Path, Params: string; Show: integer): boolean;
var
  Sei: TShellExecuteInfo;
begin
  FillChar(Sei, SizeOf(Sei), 0);
  Sei.cbSize := SizeOf(Sei);
  Sei.Wnd := Handle;
  Sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  Sei.lpVerb := 'runas';
  Sei.lpFile := PChar(Path);
  Sei.lpParameters := PChar(Params);
  Sei.nShow := Show;
  result := ShellExecuteEx(@Sei);
end;

function ExistsSageSet(const StateFlagId: TStateFlagId): boolean;
var
  VolumeCaches: TRegistry;
  CheckKeys: TRegistry;
  SubKeys: TStringList;
  StateFlagsValues: TStringList;
  SubKey: string;
  StateFlagValue: string;
begin
  result := true;
  VolumeCaches := TRegistry.Create(KEY_READ);
  SubKeys := TStringList.Create;
  StateFlagsValues := TStringList.Create;
  try
    VolumeCaches.RootKey := HKEY_LOCAL_MACHINE;
    VolumeCaches.OpenKeyReadOnly(VolumeCachesKey);
    VolumeCaches.GetKeyNames(SubKeys);
    for SubKey in SubKeys do
    begin
      CheckKeys := TRegistry.Create(KEY_READ);
      try
        CheckKeys.RootKey := HKEY_LOCAL_MACHINE;
        CheckKeys.OpenKeyReadOnly(IncludeTrailingPathDelimiter(VolumeCachesKey) + SubKey);
        CheckKeys.GetValueNames(StateFlagsValues);
        for StateFlagValue in StateFlagsValues do
        begin
          if (StateFlagValue = StateFlag + StateFlagId) then
          begin
            result := false;
            exit;
          end;
        end
      finally
        CheckKeys.CloseKey;
        CheckKeys.Free;
      end;
    end;
  finally
    VolumeCaches.Free;
    SubKeys.Free;
    StateFlagsValues.Free;
  end;
end;

end.
