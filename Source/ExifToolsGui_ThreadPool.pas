unit ExifToolsGui_ThreadPool;

interface

uses
  System.Threading;

function GetPool: TThreadPool;
procedure ResetPool(var AThreadPool: TThreadPool; const Threads: integer = -1);

implementation

uses
  System.Sysutils;

var
  FThreadPool: TThreadPool;

function GetPool: TThreadPool;
begin
  result := FThreadPool;
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


initialization

begin
  ResetPool(FThreadPool);
end;

finalization

begin
  FThreadPool.Free;
end;

end.
