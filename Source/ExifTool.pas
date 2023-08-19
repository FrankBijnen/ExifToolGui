unit ExifTool;

interface

uses Classes, StdCtrls;

type
  ET_OptionsRec = record
    // don't define '-a' (because of Filelist custom columns)
    // don't define '-e' (because of extracting previews)
    ETLangDef: string;
    ETBackupMode: string;
    ETFileDate: string;
    ETSeparator: string;
    ETMinorError: string;
    ETGpsFormat: string;
    ETShowNumber: string;
    procedure SetGpsFormat(UseDecimal: boolean);
  end;

const
  CRLF = #13#10;

var
  ETCounterLabel: TLabel = nil;
  ETCounter: smallint = 0;
  ET_Options: ET_OptionsRec = (ETLangDef: '';
    ETBackupMode: '-overwrite_original' + CRLF;   // or ='' or='overwrite_original_in_place'
    ETFileDate: '';                               // or '-P'+CRLF (preserve FileModify date)
    ETSeparator: '-sep' + CRLF + '*' + CRLF;      // or '' (for keywords etc.)
    ETMinorError: '';                             // or '-m'+CRLF
    ETGpsFormat: '-c' + CRLF + '%d°%.4f' + CRLF;  // or '-c'+CRLF+'%.6f°'+CRLF (for decimal)
    ETShowNumber: '');                            // or '-n'+CRLF

function ET_StayOpen(WorkDir: string): boolean;
function ET_OpenExec(ETcmd: string; FNames: AnsiString; var ETouts, ETErrs: string; TagsFromFile: boolean = false): boolean; overload;
function ET_OpenExec(ETcmd: string; FNames: AnsiString; ETout: TStringList; TagsFromFile: boolean = false): boolean; overload;
function ET_OpenExec(ETcmd: string; FNames: AnsiString; TagsFromFile: boolean = false): boolean; overload;
procedure ET_OpenExit;

function ExecET(ETcmd, FNames, WorkDir: AnsiString; var ETouts, ETErrs: string; UseUtf8: boolean = true): boolean; overload;
function ExecET(ETcmd, FNames, WorkDir: AnsiString; var ETouts: string; UseUtf8: boolean = true): boolean; overload;

function ExecCMD(xCmd, WorkDir: AnsiString; var ETouts, ETErrs: string): boolean; overload;
function ExecCMD(xCmd, WorkDir: AnsiString): boolean; overload;

implementation

uses Main, MainDef, Windows, Forms, SysUtils, ExifToolsGUI_Utils, System.SyncObjs;

const
  szPipeBuffer = 65535;

var
  ETprocessInfo: TProcessInformation;
  PipeInRead, PipeInWrite: THandle;
  PipeOutRead, PipeOutWrite: THandle;
  PipeErrRead, PipeErrWrite: THandle;
  ETrunning: boolean = false;
  ETShowCounter: boolean = false;
  ETEvent: TEvent;
  ExecNum: byte;

procedure ET_OptionsRec.SetGpsFormat(UseDecimal: boolean);
begin
  if UseDecimal then
    ETGpsFormat := '-c' + CRLF + '%.6f' + #$C2#$B0 + CRLF
  else
    ETGpsFormat := '-c' + CRLF + '%d' + #$C2#$B0 + '%.4f' + CRLF;
end;

// ============================== ET_Open mode ==================================
function ET_StayOpen(WorkDir: string): boolean;
var
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  PWorkDir: PChar;
  ETcmd: WideString;
begin
  ETcmd := GUIsettings.ETOverrideDir + 'exiftool -stay_open True -@ -';
  if ETrunning then
    ET_OpenExit; // -changing WorkDir OnTheFly requires Exit first
  FillChar(ETprocessInfo, SizeOf(TProcessInformation), #0);
  FillChar(SecurityAttr, SizeOf(TSecurityAttributes), #0);
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := true;
  SecurityAttr.lpSecurityDescriptor := nil;
  CreatePipe(PipeInRead, PipeInWrite, @SecurityAttr, 0);
  CreatePipe(PipeOutRead, PipeOutWrite, @SecurityAttr, 65535);
  CreatePipe(PipeErrRead, PipeErrWrite, @SecurityAttr, 32767);
  FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  with StartupInfo do
  begin
    hStdInput := PipeInRead;
    hStdOutput := PipeOutWrite;
    hStdError := PipeErrWrite;
    wShowWindow := SW_HIDE;
    dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  end;
  if WorkDir = '' then
    PWorkDir := nil
  else
    PWorkDir := PChar(WorkDir);
  if CreateProcess(nil, PChar(ETcmd), nil, nil, true, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, PWorkDir,
    StartupInfo, ETprocessInfo) then
  begin
    ETrunning := true;
    CloseHandle(PipeInRead);
    CloseHandle(PipeOutWrite);
    CloseHandle(PipeErrWrite);
  end
  else
  begin
    ETrunning := false;
    CloseHandle(PipeInRead);
    CloseHandle(PipeInWrite);
    CloseHandle(PipeOutRead);
    CloseHandle(PipeOutWrite);
    CloseHandle(PipeErrRead);
    CloseHandle(PipeErrWrite);
  end;
  result := ETrunning;
end;

function ET_OpenExec(ETcmd: string; FNames: AnsiString; var ETouts, ETErrs: string; TagsFromFile: boolean = false): boolean;
// -Fnames must be of AnsiString type here, otherwise some foreign
// characters in filenames might no be recognized by ExifTool!
var
  ETstream: TMemoryStream;
  PipeBuffer: array [0 .. szPipeBuffer] of byte;

  ETout, ETerr: TStringList;
  ETprm: AnsiString;
  FinalCmd: AnsiString;
  BytesCount: Dword;
  I: word;
  BuffContent: ^word;
  BuffAddress: ^Dword;
  EndReady: boolean;
  ThisExecNum: byte;
  CheckNum: word;
  Wr: TWaitResult;
begin
  result := false;

  // Update Execnum
  inc(ExecNum);
  if (ExecNum > $39) then
    ExecNum := $31;
  ThisExecNum := ExecNum;
  CheckNum := ($7D * 256) + ThisExecNum;

  if ETrunning and (Length(ETcmd) > 1) then
  begin
    Wr := ETEvent.WaitFor(GUIsettings.ETTimeOut);
    if (Wr <> wrSignaled) then
    begin
      ETEvent.SetEvent;
      result := false;
      ETouts := '';
      ETErrs := 'Time out waiting for Event' + CRLF;
      exit;
    end;
    ETEvent.ReSetEvent;

    ETout := TStringList.Create;
    ETerr := TStringList.Create;
    ETstream := TMemoryStream.Create;

    try
      if pos('||', ETcmd) > 0 then
        ETcmd := StringReplace(ETcmd, '||', CRLF, [rfReplaceAll]);
      ETcmd := ETcmd + CRLF;

      ETprm := '-v0' + CRLF; // -for file counter!
      with ET_Options do
      begin
        if ETLangDef <> '' then
          ETprm := ETprm + '-lang' + CRLF + ETLangDef;
        ETprm := ETprm + ETBackupMode;
        ETprm := ETprm + ETSeparator;
        ETprm := ETprm + ETMinorError + ETFileDate;
        ETprm := ETprm + ETGpsFormat + ETShowNumber;
        // +further options...
      end;

      // Only Utf8encode input parameters -but not if
      // TagsFromFile is used, because after TagsFromFile,
      // there can be a filename parameter:
      if TagsFromFile then
        FinalCmd := ETprm + ETcmd
      else
        FinalCmd := Utf8Encode(ETprm + ETcmd);

      // Add Ansi filenames:
      if FNames <> '' then
        FinalCmd := FinalCmd + FNames + CRLF;
      FinalCmd := FinalCmd + '-execute' + Char(ThisExecNum) + CRLF;

      ETShowCounter := (ETCounterLabel <> nil) and (ETCounter > 1);
      if ETShowCounter then
      begin
        ETCounterLabel.Visible := true;
      end;
      WriteFile(PipeInWrite, FinalCmd[1], Length(FinalCmd), BytesCount, nil);

      Screen.Cursor := -11; // crHourglass
      FlushFileBuffers(PipeInWrite);
      // ========= Read StdOut =======================
      ETstream.Clear;
      BuffAddress := Addr(BuffContent);
      EndReady := false;
      repeat
        ReadFile(PipeOutRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
        BuffContent := @PipeBuffer[0];
        if BytesCount > 1 then
        begin
          if BuffContent^ = $3D3D then
          begin
            Dec(ETCounter);
            if ETShowCounter then
              ETCounterLabel.Caption := IntToStr(ETCounter);
          end
          else
            ETstream.Write(PipeBuffer, BytesCount);
          for I := 0 to BytesCount - 1 do
          begin
            if BuffContent^ = CheckNum then
              EndReady := true; // line contains 'n}'
            inc(BuffAddress^, 1);
          end;
        end
        else
          break;
      until EndReady;
      ETstream.Position := 0;
      ETout.LoadFromStream(ETstream);

      // ========= Read StdErr =======================
      ETstream.Clear;
      I := 0;
      repeat
        PeekNamedPipe(PipeErrRead, nil, 0, nil, @BytesCount, nil);
        if BytesCount > 0 then
        begin
          ReadFile(PipeErrRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
          ETstream.Write(PipeBuffer, BytesCount);
        end;
        inc(I);
      until (BytesCount = 0) or (I > 5); // max 2 attempts observed
      ETstream.Position := 0;
      ETerr.LoadFromStream(ETstream);
      ETErrs := ETerr.Text;
      // ========= Cleanup ETout ======================
      I := 0;
      while I < ETout.Count do
      begin
        // no difference observed between UTF8ToString() and UTF8ToAnsi()
        ETout[I] := UTF8ToAnsi(ETout[I]);
        if pos('{r', ETout[I]) > 0 then
          ETout.Delete(I) // delete '{ready..}' lines
        else
          inc(I);
      end;
      ETouts := ETout.Text;
      ETErrs := ETerr.Text;
      // ----------------------------------------------
      if ETShowCounter then
        ETCounterLabel.Visible := false;
      ETCounter := 0;
      result := true;
    finally
      ETout.Free;
      ETerr.Free;
      ETstream.Free;
      Screen.Cursor := 0; // crDefault
      ETEvent.SetEvent;
    end;
  end;
end;

function ET_OpenExec(ETcmd: string; FNames: AnsiString; ETout: TStringList; TagsFromFile: boolean = false): boolean;
var
  ETouts, ETErrs: string;
begin
  result := ET_OpenExec(ETcmd, FNames, ETouts, ETErrs, TagsFromFile);
  ETout.Text := ETouts;
end;

function ET_OpenExec(ETcmd: string; FNames: AnsiString; TagsFromFile: boolean = false): boolean;
var
  ETouts, ETErrs: string;
begin
  result := ET_OpenExec(ETcmd, FNames, ETouts, ETErrs, TagsFromFile);
end;

procedure ET_OpenExit;
const
  ExitCmd: Utf8string = '-stay_open' + CRLF + 'False' + CRLF;
var
  BytesCount: Dword;
begin
  if ETrunning then
  begin
    WriteFile(PipeInWrite, ExitCmd[1], Length(ExitCmd), BytesCount, nil);
    FlushFileBuffers(PipeInWrite);
    CloseHandle(ETprocessInfo.hThread);
    CloseHandle(ETprocessInfo.hProcess);
    CloseHandle(PipeInWrite);
    CloseHandle(PipeOutRead);
    CloseHandle(PipeErrRead);
    ETrunning := false;
  end;
end;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^ End of ET_Open mode ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
// =========================== ET classic mode ==================================
function ExecET(ETcmd, FNames, WorkDir: AnsiString; var ETouts, ETErrs: string; UseUtf8: boolean = true): boolean;
var
  ETstream: TMemoryStream;
  PipeBuffer: array [0 .. szPipeBuffer] of byte;
  ETout, ETerr: TStringList;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfoA;
  PipeOutRead, PipeOutWrite: THandle;
  PipeErrRead, PipeErrWrite: THandle;
  ETprm: AnsiString;
  PWorkDir: PAnsiChar;
  BytesCount: Dword;
  BuffContent: ^word;
  I: integer;
begin
  Screen.Cursor := -11; // =crHourGlass
  ETout := TStringList.Create;
  ETerr := TStringList.Create;
  ETstream := TMemoryStream.Create;
  try
    FillChar(ProcessInfo, SizeOf(TProcessInformation), #0);
    FillChar(SecurityAttr, SizeOf(TSecurityAttributes), #0);
    SecurityAttr.nLength := SizeOf(SecurityAttr);
    SecurityAttr.bInheritHandle := true;
    SecurityAttr.lpSecurityDescriptor := nil;
    CreatePipe(PipeOutRead, PipeOutWrite, @SecurityAttr, 65535);
    CreatePipe(PipeErrRead, PipeErrWrite, @SecurityAttr, 32767);
    FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
    StartupInfo.cb := SizeOf(StartupInfo);
    with StartupInfo do
    begin
      hStdInput := 0;
      hStdOutput := PipeOutWrite;
      hStdError := PipeErrWrite;
      wShowWindow := SW_HIDE;
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    end;
    if WorkDir = '' then
      PWorkDir := nil
    else
      PWorkDir := PAnsiChar(WorkDir);

    ETprm := GUIsettings.ETOverrideDir + 'exiftool -v0 ';
    with ET_Options do
    begin
      if ETLangDef <> '' then
        ETprm := ETprm + '-lang' + CRLF + ETLangDef;
      ETprm := ETprm + ETBackupMode;
      ETprm := ETprm + ETSeparator + ETMinorError;
      ETprm := ETprm + ETFileDate + ETGpsFormat;
    end;
    ETprm := StringReplace(ETprm, CRLF, ' ', [rfReplaceAll]);

    if UseUtf8 then
      ETcmd := ETprm + Utf8Encode(ETcmd) + FNames
    else
      ETcmd := ETprm + ETcmd + FNames;
    ETShowCounter := (ETCounterLabel <> nil) and (ETCounter > 1);
    if ETShowCounter then
    begin
      ETCounterLabel.Visible := true;
    end;

    result := CreateProcessA(nil, PAnsiChar(ETcmd), nil, nil, true, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
      PWorkDir, StartupInfo, ProcessInfo);

    CloseHandle(PipeOutWrite);
    CloseHandle(PipeErrWrite);

    if not result then
    begin
      CloseHandle(PipeOutRead);
      CloseHandle(PipeErrRead);
    end
    else
    begin
      // ========= Read StdOut =======================
      ETstream.Clear; // BuffAddress:=Addr(BuffContent);
      repeat
        ReadFile(PipeOutRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
        BuffContent := @PipeBuffer[0];
        if BytesCount > 1 then
        begin
          if BuffContent^ = $3D3D then
          begin // line starts with '=='
            Dec(ETCounter);
            if ETShowCounter then
              ETCounterLabel.Caption := IntToStr(ETCounter);
          end; // else ETstream.Write(PipeBuffer, BytesCount);
          ETstream.Write(PipeBuffer, BytesCount);
        end;
        // Application.ProcessMessages;
      until BytesCount = 0;

      ETstream.Position := 0;
      ETout.LoadFromStream(ETstream);

      CloseHandle(PipeOutRead);
      // ========= Read StdErr =======================
      ETstream.Clear;
      repeat
        ReadFile(PipeErrRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
        ETstream.Write(PipeBuffer, BytesCount);
      until (BytesCount = 0);
      ETstream.Position := 0;
      ETerr.LoadFromStream(ETstream);
      ETErrs := ETerr.Text;

      CloseHandle(PipeErrRead);
      // ========= Cleanup ETout ======================
      if UseUtf8 then
      begin
        I := 0;
        while I < ETout.Count do
        begin
          ETout[I] := UTF8ToAnsi(ETout[I]);
          inc(I);
        end;
      end;
      ETouts := ETout.Text;
      // ----------------------------------------------
      WaitForSingleObject(ProcessInfo.hProcess, 5000); // msec=5sec /or INFINITE
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);
      result := true;
    end;
    if ETShowCounter then
      ETCounterLabel.Visible := false;
    ETCounter := 0;
  finally
    ETstream.Free;
    ETout.Free;
    ETerr.Free;
    Screen.Cursor := 0; // crDefault
  end;
end;

function ExecET(ETcmd, FNames, WorkDir: AnsiString; var ETouts: string; UseUtf8: boolean = true): boolean;
var
  ETErrs: string;
begin
  result := ExecET(ETcmd, FNames, WorkDir, ETouts, ETErrs, UseUtf8);
end;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^ End of ET Classic mode ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
// ==============================================================================
function ExecCMD(xCmd, WorkDir: AnsiString; var ETouts, ETErrs: string): boolean;
var
  ETstream: TMemoryStream;
  PipeBuffer: array [0 .. szPipeBuffer] of byte;
  ETout, ETerr: TStringList;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfoA;
  PipeOutRead, PipeOutWrite: THandle;
  PipeErrRead, PipeErrWrite: THandle;
  PWorkDir: PAnsiChar;
  BytesCount: Dword;
begin
  FillChar(ProcessInfo, SizeOf(TProcessInformation), #0);
  FillChar(SecurityAttr, SizeOf(TSecurityAttributes), #0);
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := true;
  SecurityAttr.lpSecurityDescriptor := nil;
  CreatePipe(PipeOutRead, PipeOutWrite, @SecurityAttr, 8192);
  CreatePipe(PipeErrRead, PipeErrWrite, @SecurityAttr, 8192);
  FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  with StartupInfo do
  begin
    hStdInput := 0;
    hStdOutput := PipeOutWrite;
    hStdError := PipeErrWrite;
    wShowWindow := SW_HIDE;
    dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  end;
  if WorkDir = '' then
    PWorkDir := nil
  else
    PWorkDir := PAnsiChar(WorkDir);

  ETout := TStringList.Create;
  ETerr := TStringList.Create;
  ETstream := TMemoryStream.Create;
  Screen.Cursor := -11; // =crHourGlass
  try
    result := CreateProcessA(nil, PAnsiChar(xCmd), nil, nil, true, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
      PWorkDir, StartupInfo, ProcessInfo);

    CloseHandle(PipeOutWrite);
    CloseHandle(PipeErrWrite);

    if not result then
    begin
      CloseHandle(PipeOutRead);
      CloseHandle(PipeErrRead);
    end
    else
    begin
      // ========= Read StdOut =======================
      ETstream.Clear; // BuffAddress:=Addr(BuffContent);
      repeat
        ReadFile(PipeOutRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
        if BytesCount > 1 then
          ETstream.Write(PipeBuffer, BytesCount);
        // Application.ProcessMessages;
      until BytesCount = 0;
      ETstream.Position := 0;
      ETout.LoadFromStream(ETstream);
      ETouts := ETout.Text;
      CloseHandle(PipeOutRead);
      // ========= Read StdErr =======================
      ETstream.Clear;
      repeat
        ReadFile(PipeErrRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
        ETstream.Write(PipeBuffer, BytesCount);
      until (BytesCount = 0);
      ETstream.Position := 0;
      ETerr.LoadFromStream(ETstream);
      ETErrs := ETerr.Text;

      CloseHandle(PipeErrRead);
      // ----------------------------------------------
      WaitForSingleObject(ProcessInfo.hProcess, GUIsettings.ETTimeOut); // msec=5sec /or INFINITE
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);
    end;
  finally
    ETout.Free;
    ETerr.Free;
    ETstream.Free;
    Screen.Cursor := 0; // crDefault
  end;
end;

function ExecCMD(xCmd, WorkDir: AnsiString): boolean;
var
  ETout, ETerr: string;
begin
  result := ExecCMD(xCmd, WorkDir, ETout, ETerr);
end;
// ==============================================================================

initialization

begin
  // ETstream:=TMemoryStream.Create;
  ETCounterLabel := nil;
  ETEvent := TEvent.Create(nil, true, true, ExtractFileName(Paramstr(0)));
  ExecNum := $30;
end;

finalization

begin
  ET_OpenExit;
  // ETstream.Free;
  ETEvent.Free;
end;

end.
