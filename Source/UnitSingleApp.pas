unit UnitSingleApp;

interface

uses
  Winapi.Windows, WInapi.Messages;

const AppGuid  = '{29D8E36F-9AC8-4B6A-BA34-9BE3FDBF7724}';
      CM_ActivateWindow = WM_USER + 100;

type
  TSharedData = record
    Wnd: HWnd;
    NewDirectory: array[0..MAX_PATH] of char;
  end;
  PSharedData = ^TSharedData;

function CreateMapping: boolean;
procedure WriteWindowHandle(const AWnd: HWND);
procedure WriteNewDir(const ADir: string);
function ReadWindowHandle: HWnd;
function ReadNewDir: string;
procedure ActivateCurrentWindow;

implementation

uses
  System.SysUtils, ExifToolsGUI_Utils;


function CreateMapping: boolean;
var
  FileMappingHandle: THandle;
begin
  FileMappingHandle := CreateFileMapping(INVALID_HANDLE_VALUE,
                                         nil,
                                         PAGE_READWRITE,
                                         0,
                                         SizeOf(TSharedData),
                                         PChar(AppGuid));
  // Should not happen
  if (FileMappingHandle = 0) then
    RaiseLastOSError;

  result := (GetLastError <> ERROR_ALREADY_EXISTS);
end;

procedure CloseFileMapping;
var
  FileMappingHandle: THandle;
begin
  FileMappingHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, TRUE, PWideChar(AppGuid));
  if (FileMappingHandle <> 0) then
    CloseHandle(FileMappingHandle);
end;

function LockSharedData(var FileMapping: THandle): PSharedData;
begin
  FileMapping := OpenFileMapping(FILE_MAP_ALL_ACCESS, TRUE, PWideChar(AppGuid));
  result := MapViewOfFile(FileMapping, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TSharedData));
end;

procedure UnlockSharedData(const FileMapping: THandle; SharedData: PSharedData);
begin
  if (SharedData <> nil) then
      UnmapViewOfFile(SharedData);
  if (FileMapping <> 0) then
    CloseHandle(FileMapping);
end;

function ReadShared: TSharedData;
var
  HFileMapping: THandle;
  SharedData: PSharedData;
begin
  SharedData := LockSharedData(HFileMapping);
  try
    result := SharedData^;
  finally
    UnlockSharedData(HFileMapping, SharedData);
  end;
end;

procedure WriteShared(const AShared: TSharedData);
var
  SharedData: PSharedData;
  HFileMapping: THandle;
begin
  SharedData := LockSharedData(HFileMapping);
  try
    SharedData^ := AShared;
  finally
    UnlockSharedData(HFileMapping, SharedData);
  end;
end;

procedure WriteWindowHandle(const AWnd: HWND);
var
  Shared: TSharedData;
begin
  Shared := ReadShared;
  Shared.Wnd := AWnd;
  WriteShared(Shared);
end;

procedure WriteNewDir(const ADir: string);
var
  Shared: TSharedData;
begin
  Shared := ReadShared;
  StrPCopy(Shared.NewDirectory, Adir);
  WriteShared(Shared);
end;

function ReadWindowHandle: HWnd;
var
  Shared: TSharedData;
begin
  Shared := ReadShared;
  result := Shared.Wnd;
end;

function ReadNewDir: string;
var
  Shared: TSharedData;
begin
  Shared := ReadShared;
  result := Strpas(Shared.NewDirectory);
end;

procedure ActivateCurrentWindow;
var
  Handle: THandle;
begin
  Handle := ReadWindowHandle;
  if (not IsWindow(Handle)) then
    exit;

  ShowWindow(Handle, SW_RESTORE And SW_SHOW);
  SetForegroundWindow(Handle);
  WriteNewDir(Paramstr(1));
  SendMessage(Handle, CM_ActivateWindow, 0, 0);
end;

initialization

finalization

  CloseFileMapping;

end.

