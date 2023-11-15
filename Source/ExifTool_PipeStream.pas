unit ExifTool_PipeStream;

interface

uses System.Classes, Winapi.Windows;

type
  TCounterETEvent = procedure(Counter: integer) of object;

  TET_Counter = record
    CounterEvent: TCounterETEvent;
    Counter: integer;
  end;

{ TPipeStream }

// Stream for handling reads from a Pipe written to by ExifTool.
// A Pipe is Ansi, but ExifTool writes UTF8.

  TPipeStream = class(TBytesStream)
  private
    HFile: THandle;
    FBufSize: integer;
    FileBuffer: array of byte;
    FETCounterLast: integer;
    FETCounter: TET_Counter;
    function BeforeLineEnds(CurPos: PByte): PByte;
    function PrevLineStart(FromPos: PByte): PByte;
    function GetLastLinePosition(var StartPos, EndPos: PByte): boolean;
    function GetPipe(StartPos: PByte = nil; EndPos: PByte = nil): Utf8String;
  public
    constructor Create(AFile: THandle; ABufSize: integer);
    function PipeHasData: boolean;
    function PipeHasReady(const ExecNum: word): boolean;
    procedure CheckFilesProcessed;
    procedure ClearCounter;
    procedure SetCounter(ACounter: TET_Counter);
    function ReadPipe: DWORD;
    function AsString: string;
    function AnalyseResult(var StatusLine: string; var LengthReady: integer): string;
    function AnalyseError: string;
  end;

// Reads the PipeStream in a separate thread
  TReadPipeThread = class(TThread)
  protected
    FPipeStream: TPipeStream;
    procedure Execute; override;
  public
    constructor Create(AFile: THandle; ABufSize: integer);
    destructor Destroy; override;
    property PipeStream: TPipeStream read FPipeStream;
  end;

// Reads the PipeStream in a separate thread, for Stay Open
  TSOReadPipeThread = class(TThread)
  protected
    FExecNum: word;
    FPipeStream: TPipeStream;
    procedure Execute; override;
  public
    constructor Create(APipeStream: TPipeStream; AExecNum: word);
  end;

  procedure SetCounter(ACounterEvent: TCounterETEvent; ACounter: integer);
  function GetCounter: TET_Counter;

implementation

uses System.SysUtils;

const
  CR = 13;
  LF = 10;
  ReadyPrompt: Utf8string = '{ready';
  FilePrompt: Utf8string  = '========';

var
  ET_Counter: TET_Counter;

procedure SetCounter(ACounterEvent: TCounterETEvent; ACounter: integer);
begin
  ET_Counter.CounterEvent := ACounterEvent;
  ET_Counter.Counter := ACounter;
end;

function GetCounter: TET_Counter;
begin
  result := ET_Counter;
end;

constructor TPipeStream.Create(AFile: THandle; ABufSize: integer);
begin
  inherited Create;
  HFile := AFile;
  FBufSize := ABufSize;
  SetLength(FileBuffer, FBufSize);
  ClearCounter;
end;

// Position before CRLF. If present.
function TPipeStream.BeforeLineEnds(CurPos: PByte): PByte;
begin
  result := CurPos;
  if (result > PByte(Memory)) and
     (result^ = LF) then
    dec(result);
  if (result > PByte(Memory)) and
     (result^ = CR) then
    dec(result);
end;

// Position right after previous LF
function TPipeStream.PrevLineStart(FromPos: PByte): PByte;
begin
  result := FromPos;
  while (result > PByte(Memory)) and  // Move backward until a LF
        (result^ <> LF) do
    dec(result);

  if (result^ = LF) then              // Position after LF
    inc(result);
end;

// Scan backward in Memory, from Startpos, to find the previous LF.
function TPipeStream.GetLastLinePosition(var StartPos, EndPos: PByte): boolean;
begin
  if not Assigned(Memory) then
    exit(false);
  if Assigned(StartPos) then
    EndPos := StartPos
  else
    EndPos := PByte(Memory) + Size -1;
  if (EndPos < PByte(Memory)) then    // Empty string, only Line Ends
    exit(false);

  EndPos := BeforeLineEnds(EndPos);
  StartPos := PrevLineStart(EndPos);
  result := true;
end;

// Gets (part of) the Stream as an UTF8String. Does not alter position, like read or write.
function TPipeStream.GetPipe(StartPos: PByte = nil; EndPos: PByte = nil): Utf8String;
var P: PByte;
    L: integer;
begin
  P := Memory;
  L := Size;
  if Assigned(StartPos) and
     Assigned(EndPos) then
  begin
    P := StartPos;
    L := EndPos + 1 - StartPos;
  end;
  SetLength(result, L);
  if (L > 0) then
    Move(P^, result[1], L);
end;

function TPipeStream.PipeHasData: boolean;
var BytesAvail: DWORD;
begin
  result := PeekNamedPipe(HFile, nil, 0, nil, @BytesAvail, nil);
  result := result and (BytesAvail > 0);
end;

// Note: {Readynn} can occur on multiple lines, only the last line is checked!
function TPipeStream.PipeHasReady(const ExecNum: word): boolean;
var StartPos, EndPos: PByte;
    ReadyLine: UTF8String;
begin
  if (Size = 0) then
    exit(false);

  StartPos := nil;
  if not GetLastLinePosition(StartPos, EndPos) then
    exit(false);

  ReadyLine := GetPipe(StartPos, EndPos);
  result := (Pos(ReadyPrompt + IntToStr(ExecNum) + '}', ReadyLine) > 0);
end;

// Scan for ===== (New file processed by ExifTool)
procedure TPipeStream.CheckFilesProcessed;
var PipeBuffer: UTF8String;
    P: integer;
begin
  if (FETCounter.Counter < 1) then
    exit;
  PipeBuffer := GetPipe;
  P := Pos(FilePrompt, PipeBuffer, FETCounterLast);
  while (P > 0) do
  begin
    FETCounterLast := P + Length(FilePrompt);
    Dec(FETCounter.Counter);
    if (Assigned(FETCounter.CounterEvent)) then
      FETCounter.CounterEvent(FETCounter.Counter);
    P := Pos(FilePrompt, PipeBuffer, FETCounterLast);
  end;
end;

procedure TPipeStream.ClearCounter;
begin
  FillChar(FETCounter, SizeOf(FETCounter), 0);
  FETCounterLast := 1;
end;

procedure TPipeStream.SetCounter(ACounter: TET_Counter);
begin
  FETCounter := ACounter;
  FETCounterLast := 1;
end;

function TPipeStream.ReadPipe: DWORD;
begin
  if (Winapi.Windows.ReadFile(HFile, FileBuffer[0], FBufSize, result, nil)) then
    Self.Write(FileBuffer[0], result);
  if (result > 0) then
    CheckFilesProcessed;
end;

function TPipeStream.AsString: string;
begin
  result := UTF8ToString(GetPipe);
end;

function TPipeStream.AnalyseResult(var StatusLine: string; var LengthReady: integer): string;
var StartPos, EndPos: PByte;
begin
  result := AsString;
  StatusLine := '';
  LengthReady := 0;

  StartPos := nil;
  if not GetLastLinePosition(StartPos, EndPos) then
    exit;
  StatusLine := UTF8ToString(GetPipe(StartPos, EndPos));

  if (Pos(ReadyPrompt, StatusLine) = 1) then // {Readyxx}
  begin
    LengthReady := (PByte(Memory) + Size) - PByte(StartPos);

    Dec(StartPos);
    if GetLastLinePosition(StartPos, EndPos) then
      StatusLine := UTF8ToString(GetPipe(StartPos, EndPos));
  end;
end;

// Dont need the statusline, just the data.
function TPipeStream.AnalyseError: string;
var StatusLine: string;
    LengthReady: integer;
begin
  result := AnalyseResult(StatusLine, LengthReady);
  SetLength(result, Length(result) - LengthReady);
end;

{ TReadPipeThread }
// Read Pipe in separate thread

constructor TReadPipeThread.Create(AFile: THandle; ABufSize: integer);
begin
  FPipeStream := TPipeStream.Create(AFile, ABufSize);
  inherited Create(false); // start running
end;

destructor TReadPipeThread.Destroy;
begin
  FPipeStream.Free;
  inherited Destroy;
end;

procedure TReadPipeThread.Execute;
begin
  while FPipeStream.ReadPipe > 0 do;
end;

{ TSOReadPipeThread }
// Read Pipe in separate thread for Stay Open
constructor TSOReadPipeThread.Create(APipeStream: TPipeStream; AExecNum: word);
begin
  FPipeStream := APipeStream;
  FExecNum := AExecNum;
  inherited Create(False); // start running;
end;

procedure TSOReadPipeThread.Execute;
begin
  // Continue until we see our execnum
  // -executexx and -echo4 CRLF xx need to be set for this to work
  while (not FPipeStream.PipeHasReady(FExecNum)) do
    FPipeStream.ReadPipe;
end;

initialization
begin
  SetCounter(nil, 0);
end;

end.
