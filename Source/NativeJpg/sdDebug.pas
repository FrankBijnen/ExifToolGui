unit sdDebug;

interface

uses System.SysUtils, System.Variants, Winapi.Windows;

type TsdWarnStyle = (wsWarn, wsFail);

procedure DoDebugOut(Sender: TObject; WarnStyle: TsdWarnStyle; const AMessage: string);

implementation

procedure DebugMsg(const Msg: array of variant);
{$IFDEF DEBUG}
var
  I: integer;
  FMsg: string;
begin
  FMsg := Format('%s %s %s', ['NativeJpg', Paramstr(0), IntToStr(GetCurrentThreadId)]);
  for I := 0 to high(Msg) do
    FMsg := Format('%s,%s', [FMsg, VarToStr(Msg[I])]);
  OutputDebugString(PChar(FMsg));
{$ELSE}
begin
{$ENDIF}
end;

procedure DoDebugOut(Sender: TObject; WarnStyle: TsdWarnStyle; const AMessage: string);
var ClassName: string;
begin
  ClassName := '';
  if (Assigned(Sender)) then
    ClassName := Sender.ClassName;
  case WarnStyle of
    TsdWarnStyle.wsFail:
      begin
        raise Exception.Create(Format('Class: %s, Message: %s', [ClassName, AMessage]));
      end;
    TsdWarnStyle.wsWarn:
      begin
        DebugMsg([ClassName, AMessage]);
      end;
  end;

end;

end.
