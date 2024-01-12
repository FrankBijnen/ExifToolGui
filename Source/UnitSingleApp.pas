unit UnitSingleApp;

interface

uses
  Winapi.Windows, WInapi.Messages;

const AppGuid  = '{29D8E36F-9AC8-4B6A-BA34-9BE3FDBF7724}';

type
  TSharedData = record
    Wnd: HWND;
    MessageId: Cardinal;
    NewDirectory: array[0..MAX_PATH] of char;
  end;
  PSharedData = ^TSharedData;

  TSharedMem = class
  private
    FFileMapping: THandle;
    FAppId: string;
    FIsOwner: boolean;
    FSharedData: PSharedData;
    function GetNewDirectory: string;
  public
    constructor Create(AppId: string);
    destructor Destroy; override;
    procedure LockSharedData;
    procedure UnlockSharedData;
    procedure RegisterOwner(AWnd: HWND; AMessageid: Cardinal);
    procedure ActivateCurrentWindow;

    property IsOwner: boolean read FIsOwner;
    property SharedData: PSharedData read FSharedData;
    property NewDirectory: string read GetNewDirectory;
  end;

var FSharedMem: TSharedMem;

implementation

uses
  System.SysUtils, ExifToolsGUI_Utils;

constructor TSharedMem.Create(AppId: string);
var
  FileMappingHandle: THandle;
begin
  inherited Create;
  FAppId := AppId;
  FSharedData := nil;
  FFileMapping := 0;
  FileMappingHandle := CreateFileMapping(INVALID_HANDLE_VALUE,
                                         nil,
                                         PAGE_READWRITE,
                                         0,
                                         SizeOf(TSharedData),
                                         PChar(FAppId));
  // Should not happen
  if (FileMappingHandle = 0) then
    RaiseLastOSError;

  FIsOwner := (GetLastError <> ERROR_ALREADY_EXISTS);
end;

destructor TSharedMem.Destroy;
begin
  FAppId := '';
  FFileMapping := OpenFileMapping(FILE_MAP_ALL_ACCESS, TRUE, PWideChar(FAppId));
  if (FFileMapping <> 0) then
    CloseHandle(FFileMapping);
  inherited;
end;

procedure TSharedMem.LockSharedData;
begin
  FFileMapping := OpenFileMapping(FILE_MAP_ALL_ACCESS, TRUE, PWideChar(FAppId));
  FSharedData := MapViewOfFile(FFileMapping, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TSharedData));
end;

procedure TSharedMem.UnlockSharedData;
begin
  if (FSharedData <> nil) then
      UnmapViewOfFile(FSharedData);
  if (FFileMapping <> 0) then
    CloseHandle(FFileMapping);
end;

procedure TSharedMem.RegisterOwner(AWnd: HWND; AMessageid: Cardinal);
begin
  LockSharedData;
  try
    SharedData.Wnd := AWnd;
    SharedData.MessageId := AMessageid;
  finally
    UnlockSharedData;
  end;
end;

function TSharedMem.GetNewDirectory: string;
begin
  LockSharedData;
  try
    result := SharedData.NewDirectory;
  finally
    UnlockSharedData;
  end;
end;

procedure TSharedMem.ActivateCurrentWindow;
begin
  LockSharedData;
  try
    if (not IsWindow(SharedData.Wnd)) then
      exit;

    StrPCopy(SharedData.NewDirectory, '');
    if (Length(ParamStr(1)) < MAX_PATH) then
      StrPCopy(SharedData.NewDirectory, ParamStr(1));

    SetForegroundWindow(SharedData.Wnd);

    SendMessage(SharedData.Wnd, SharedData.MessageId, 0, 0);

  finally
    UnlockSharedData;
  end;
end;

initialization

  FSharedMem := TSharedMem.Create(AppGuid);

finalization

  FSharedMem.Free;

end.

