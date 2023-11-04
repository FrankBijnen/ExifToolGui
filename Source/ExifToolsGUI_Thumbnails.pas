unit ExifToolsGUI_Thumbnails;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses Winapi.ShlObj, Winapi.ActiveX, Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Threading,
  Vcl.Forms, Vcl.Dialogs, Vcl.Shell.ShellCtrls;

const
  VolumeCachesKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches';
  StateFlag = 'StateFlags';
  ThumbnailCache = 'Thumbnail Cache';

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
  TThumbTask = class(TTask, ITask)
  private
    FHandle: HWND;
    FItemIndex: integer;
    FMax: integer;
    FListView: TShellListView;
    FPitemIDList: pointer;
    FThreadPool: TThreadPool;
    FPathName: string;
    procedure DoExecuteListView;
    procedure DoExecuteBackground;
  public
    constructor Create(const AItemIndex: integer; const AListView: TShellListView; const APitemIDList: pointer; const AThreadPool: TThreadPool;
      const AMax: integer); overload;
    constructor Create(const AItemIndex: integer; const AHandle: HWND; const APathName: string; const AMax: integer); overload;
    destructor Destroy; override;
    function Start: ITask;
    procedure Cancel;

    property IsQueued;
    property ItemIndex: integer read FItemIndex write FItemIndex;
  end;

  // Image thumbnails
function GetThumbCache(AFilePath: string; var hBmp: HBITMAP; Flags: TSIIGBF; AMaxX: longint; AMaxY: longint): HRESULT;
procedure GenerateThumbs(AFilePath: string; Subdirs: boolean; AMax: longint; FOnReady: TNotifyEvent = nil);

// Functions for CleanMgr.exe
procedure ResetPool(var AThreadPool: TThreadPool; const Threads: integer = -1);
function ExistsSageSet(const StateFlagId: TStateFlagId): boolean;
function RunAsAdmin(const Handle: HWND; const Path, Params: string; Show: integer): boolean;

implementation

uses Winapi.ShellAPI, System.Win.Registry, System.UITypes,
  ExifToolsGUI_Utils, UFrmGenerate;

var
  FThreadPool: TThreadPool;

  // TThumbTask. Generates Thumbnail in a separate thread.

  // Constructor for use in Listview
constructor TThumbTask.Create(const AItemIndex: integer; const AListView: TShellListView; const APitemIDList: pointer; const AThreadPool: TThreadPool;
  const AMax: integer);
begin
  FItemIndex := AItemIndex;
  FListView := AListView;
  FHandle := FListView.Handle;
  FPitemIDList := APitemIDList;
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
  Flags: TSIIGBF;
  hBmp: HBITMAP;
  Hr: HRESULT;
  Tries: integer;
begin
  CoInitialize(nil);
  try
    try
      Hr := S_FALSE;
      Flags := SIIGBF_THUMBNAILONLY;

      // TODO: Figure out why a retry is needed.
      Tries := 2; // Try a few times.
      while (Tries > 0) and (Hr <> S_OK) and (GetStatus <> TTaskStatus.Canceled) do
      begin
        dec(Tries);
        Hr := GetThumbCache(FPathName, hBmp, Flags, FMax, FMax);
        if (Hr <> S_OK) then
        begin
          DeleteObject(hBmp); // Not sure if this is needed
          Sleep(50);
        end;
      end;

      // The task is canceled, or the current path has changed.
      // Dont send any messages, but delete bitmap. If the handle is invalid, doesn't matter
      if (GetStatus = TTaskStatus.Canceled) or (FPitemIDList <> FListView.RootFolder.AbsoluteID) then
      begin
        DeleteObject(hBmp);
        exit;
      end;

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
  Flags: TSIIGBF;
  hBmp: HBITMAP;
  Hr: HRESULT;
begin
  CoInitialize(nil);
  try
    if (GetStatus = TTaskStatus.Canceled) or (boolean(SendMessage(FHandle, CM_ThumbGenWantsToClose, 0, 0))) then
      exit;

    Flags := SIIGBF_THUMBNAILONLY;
    Hr := GetThumbCache(FPathName, hBmp, Flags, FMax, FMax);

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

function GetThumbCache(AFilePath: string; var hBmp: HBITMAP; Flags: TSIIGBF; AMaxX: longint; AMaxY: longint): HRESULT;
var
  FileShellItemImage: IShellItemImageFactory;
  S: TSize;
begin
  result := SHCreateItemFromParsingName(PChar(AFilePath), nil, IShellItemImageFactory, FileShellItemImage);

  if Succeeded(result) then
  begin
    S.cx := AMaxX;
    S.cy := AMaxY;
    result := FileShellItemImage.GetImage(S, Flags, hBmp);
  end;
end;

function InternalGenerateThumbs(AFilePath: string; AForm: TCustomForm; Subdirs: boolean; Level, AMax: longint; FOnReady: TNotifyEvent): boolean;
var
  Fs: TSearchRec;
  Rc, NrOfFiles, Indx: integer;
  ThisThumb: string;
  Tasks: array of ITask;
begin
  result := not boolean(SendMessage(AForm.Handle, CM_ThumbGenWantsToClose, 0, 0));
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

  Rc := FindFirst(IncludeTrailingBackslash(AFilePath) + '*.*', faAnyFile - (faHidden or faSysFile), Fs);
  while (Rc = 0) and (result) do
  begin
    result := not boolean(SendMessage(AForm.Handle, CM_ThumbGenWantsToClose, 0, 0));
    if (result = false) then
      break;

    if (Fs.Name <> '.') and (Fs.Name <> '..') then
    begin
      ThisThumb := IncludeTrailingBackslash(AFilePath) + Fs.Name;
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

// Create a thread pool using nr. of cores available
procedure ResetPool(var AThreadPool: TThreadPool; const Threads: integer = -1);
var
  MinThreads, MaxThreads: integer;
begin
  if (Assigned(AThreadPool)) then
    FreeAndNil(AThreadPool);
  AThreadPool := TThreadPool.Create;

  MinThreads := (Threads + 1) div 2;
  MaxThreads := Threads;
  if (Threads = -1) then
  begin
    MinThreads := (CPUCount + 1) div 2;
    MaxThreads := CPUCount;
  end;

  AThreadPool.SetMinWorkerThreads(MinThreads);
  AThreadPool.SetMaxWorkerThreads(MaxThreads);
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
        CheckKeys.OpenKeyReadOnly(IncludeTrailingBackslash(VolumeCachesKey) + SubKey);
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

initialization

begin
  ResetPool(FThreadPool);
end;

finalization

begin
  FThreadPool.Free;
end;

end.
