{ sdStreams.pas

  - TsdFastMemStream with improved capacity setting
  - TsdStringStream
  - TsdBufferWriter

  Author: Nils Haeck M.Sc.
  copyright (c) 2002 - 2011 SimDesign BV (www.simdesign.nl)
}
unit sdStreams;

interface

uses
  System.Classes, System.SysUtils;

type

  // TsdFastMemStream deals differently with capacity compared to a normal
  // TMemoryStream; it increases the capacity with the natural growing function
  // (fibonacci) each time, and has an initial capacity of $1000. The initial
  // capacity is configurable with the create parameter.
  TsdFastMemStream = class(TStream)
  private
    FMemory: Pointer;
    FPosition: Int64;
    FFib1: Int64;
    FCapacity: Int64;
    FSize: Int64;
  protected
    procedure SetCapacity(Value: Int64);
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(InitialCapacity: Int64 = $1000);
    destructor Destroy; override;
    procedure Clear;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    procedure LoadFromFile(AFilename: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(AFilename: string);
    procedure SaveToStream(Stream: TStream);
    property Memory: Pointer read FMemory;
    property Size: Int64 read FSize write SetSize;
  end;

implementation

{ TsdFastMemStream }

procedure TsdFastMemStream.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

constructor TsdFastMemStream.Create(InitialCapacity: Int64);
begin
  inherited Create;
  FFib1 := InitialCapacity div 2;
  FCapacity := InitialCapacity;
  if FFib1 < 4 then
    FFib1 := 4;
  if FCapacity < 4 then
    FCapacity := 4;
  ReallocMem(FMemory, FCapacity);
end;

destructor TsdFastMemStream.Destroy;
begin
  ReallocMem(FMemory, 0);
  inherited;
end;

procedure TsdFastMemStream.LoadFromFile(AFilename: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TsdFastMemStream.LoadFromStream(Stream: TStream);
var
  Count: Int64;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then
    Stream.ReadBuffer(FMemory^, Count);
end;

function TsdFastMemStream.Read(var Buffer; Count: LongInt): LongInt;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := Count;
    if (Result > (FSize- FPosition)) then
      Result := FSize - FPosition;
    Move(Pointer(NativeInt(FMemory) + FPosition)^, Buffer, Result);
    Inc(FPosition, Result);
    Exit;
  end;
  Result := 0;
end;

procedure TsdFastMemStream.SaveToFile(AFilename: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TsdFastMemStream.SaveToStream(Stream: TStream);
begin
  if FSize <> 0 then Stream.WriteBuffer(FMemory^, FSize);
end;

function TsdFastMemStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soBeginning: FPosition := Offset;
    soCurrent: Inc(FPosition, Offset);
    soEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

procedure TsdFastMemStream.SetCapacity(Value: Int64);
// Fibonacci 0,1,1,2,3,5,8,...  FCapacity is Fib2.
// Fibonacci is a natural growing function where
// 0 + 1 = 1; 1 + 1 = 2; 1 + 2 = 3; 2 + 3 = 5; etc
var
  Fib3: Int64;
begin
  while FCapacity < Value do
  begin
    Fib3 := FFib1 + FCapacity;
    FFib1 := FCapacity;
    FCapacity := Fib3;
  end;
  ReallocMem(FMemory, FCapacity);
end;

procedure TsdFastMemStream.SetSize(const NewSize: Int64);
var
  OldPosition: Int64;
begin
  OldPosition := FPosition;
  SetCapacity(NewSize);
  FSize := NewSize;
  if OldPosition > NewSize then
    Seek(0, soFromEnd);
end;

function TsdFastMemStream.Write(const Buffer; Count: LongInt): LongInt;
var
  NewPos: Int64;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    NewPos := FPosition + Count;
    if NewPos > 0 then
    begin
      if NewPos > FSize then
      begin
        if NewPos > FCapacity then
          SetCapacity(NewPos);
        FSize := NewPos;
      end;
      System.Move(Buffer, Pointer(NativeInt(FMemory) + FPosition)^, Count);
      FPosition := NewPos;
      Result := Count;
      Exit;
    end;
  end;
  Result := 0;
end;

end.
