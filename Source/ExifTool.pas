unit ExifTool;

interface

uses Classes, StdCtrls;

type
  TExecETEvent = procedure (ExecNum: integer; EtCmds, EtOuts, EtErrs: string; PopupOnError: boolean) of object;

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
    ETCharset: string;
    ETVerbose: string;
    procedure SetGpsFormat(UseDecimal: boolean);
    function GetOptions(Charset: boolean = true): string;
  end;

const
  CRLF = #13#10;

var
  ExecETEvent: TExecETEvent;
  ETCounterLabel: TLabel = nil;
  ETCounter: integer = 0;
  ET_Options: ET_OptionsRec = (ETLangDef: '';
    ETBackupMode: '-overwrite_original' + CRLF;   // or ='' or='overwrite_original_in_place'
    ETFileDate: '';                               // or '-P'+CRLF (preserve FileModify date)
    ETSeparator: '-sep' + CRLF + '*' + CRLF;      // or '' (for keywords etc.)
    ETMinorError: '';                             // or '-m'+CRLF
    ETGpsFormat: '';                              // See SetGpsFormat
    ETShowNumber: '';                             // or '-n'+CRLF
    ETCharset: '-CHARSET' + CRLF + 'FILENAME=UTF8' + CRLF + '-CHARSET' + CRLF + 'UTF8'; // UTF8 it is. No choice
    ETVerbose: '-v0' );                           // For file counter

function ET_StayOpen(WorkDir: string): boolean;
function ET_OpenExec(ETcmd: string; FNames: string; var ETouts, ETErrs: string; PopupOnError: boolean = true): boolean; overload;
function ET_OpenExec(ETcmd: string; FNames: string; ETout: TStringList; PopupOnError: boolean = true): boolean; overload;
function ET_OpenExec(ETcmd: string; FNames: string; PopupOnError: boolean = true): boolean; overload;
procedure ET_OpenExit;

function ExecET(ETcmd, FNames, WorkDir: string; var ETouts, ETErrs: string; CreateArgs: boolean): boolean; overload;
function ExecET(ETcmd, FNames, WorkDir: string; var ETouts: string): boolean; overload;

function ExecCMD(xCmd, WorkDir: string; var ETouts, ETErrs: string): boolean; overload;
function ExecCMD(xCmd, WorkDir: string): boolean; overload;

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
    ETGpsFormat := '-c' + CRLF + '%.6f' + #$B0 + CRLF
  else
    ETGpsFormat := '-c' + CRLF + '%d' + #$B0 + '%.4f' + CRLF;
end;

function ET_OptionsRec.GetOptions(Charset: boolean = true): string;
begin
  result := '';
  if (Charset) then
    result := ETCharset + CRLF;
  result := result + ETVerbose + CRLF; // -for file counter!
  if ETLangDef <> '' then
    result := result + '-lang' + CRLF + ETLangDef;
  result := result + ETBackupMode;
  result := result + ETSeparator;
  result := result + ETMinorError + ETFileDate;
  result := result + ETGpsFormat + ETShowNumber;
  // +further options...
end;

procedure UpdateExecNum;
begin
  inc(ExecNum);
  if (ExecNum > $39) then
    ExecNum := $31;
end;

// ============================== ET_Open mode ==================================
function ET_StayOpen(WorkDir: string): boolean;
var
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  PWorkDir: PChar;
  ETcmd: string;
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
  if CreateProcess(nil, PChar(ETcmd), nil, nil, true,
                   CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                   nil, PWorkDir,
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

function ET_OpenExec(ETcmd: string; FNames: string; var ETouts, ETErrs: string; PopupOnError: boolean = true): boolean;
var
  ETstream: TMemoryStream;
  PipeBuffer: array [0 .. szPipeBuffer] of byte;
  ETout, ETerr: TStringList;
  FinalCmd: string;
  TempFile: string;
  Call_ET: AnsiString; // Needs to be AnsiString. Only holds the -@ <argsfilename>
  BytesCount: Dword;
  I: word;
  BuffContent: ^word;
  BuffAddress: ^Dword;
  CanUseUtf8: boolean;
  EndReady: boolean;
  ThisExecNum: byte;
  CheckNum: word;
  Wr: TWaitResult;
begin
  result := false;

  // Update Execnum
  UpdateExecNum;
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

    Screen.Cursor := -11; // crHourglass
    try
      ETShowCounter := (ETCounterLabel <> nil) and (ETCounter > 1);
      ETCounterLabel.Visible := ETShowCounter;

      // Create TempFile with commands and filenames
      if pos('||', ETcmd) > 0 then
        ETcmd := StringReplace(ETcmd, '||', CRLF, [rfReplaceAll]);
      CanUseUtf8 := (pos('-L' + CRLF, ETcmd) = 0);
      FinalCmd := ET_Options.GetOptions(CanUseUtf8) + ETcmd + CRLF;
      if FNames <> '' then
        FinalCmd := FinalCmd + FNames; // FNames should end with a CRLF. By calling GetSelectedFiles!
      FinalCmd := FinalCmd + '-execute' + Char(ThisExecNum) + CRLF;

      // Create tempfile
      TempFile := GetExifToolTmp;
      WriteArgsFile(FinalCmd, TempFile);
      Call_ET := '-@' + CRLF + TempFile + CRLF;

      // Write command to Pipe. Triggers ExifTool execution
      WriteFile(PipeInWrite, Call_ET[1], ByteLength(Call_ET), BytesCount, nil);
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

      // Convert ExifTool output from UTF8 to String
      ETout.Text := UTF8ToString(ETout.Text);
      // ========= Cleanup ETout ======================
      I := 0;
      while I < ETout.Count do
      begin
        if pos('{r', ETout[I]) > 0 then
          ETout.Delete(I) // delete '{ready..}' lines
        else
          inc(I);
      end;
      ETouts := ETout.Text;

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

      // ----------------------------------------------
      if ETShowCounter then
        ETCounterLabel.Visible := false;
      ETCounter := 0;

      // Callback for Logging
      if Assigned(ExecETEvent) then
        ExecETEvent(ExecNum, FinalCmd, ETouts, ETErrs, PopupOnError);

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

function ET_OpenExec(ETcmd: string; FNames: string; ETout: TStringList; PopupOnError: boolean = true): boolean;
var
  ETouts, ETErrs: string;
begin
  result := ET_OpenExec(ETcmd, FNames, ETouts, ETErrs, PopupOnError);
  ETout.Text := ETouts;
end;

function ET_OpenExec(ETcmd: string; FNames: string; PopupOnError: boolean = true): boolean;
var
  ETouts, ETErrs: string;
begin
  result := ET_OpenExec(ETcmd, FNames, ETouts, ETErrs, PopupOnError);
end;

procedure ET_OpenExit;
const
  ExitCmd: AnsiString = '-stay_open' + CRLF + 'False' + CRLF; // Needs to be AnsiString.
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
function ExecET(ETcmd, FNames, WorkDir: string; var ETouts, ETErrs: string; CreateArgs: boolean): boolean;
var
  ETstream: TMemoryStream;
  PipeBuffer: array [0 .. szPipeBuffer] of byte;
  ETout, ETerr: TStringList;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfoA;
  PipeOutRead, PipeOutWrite: THandle;
  PipeErrRead, PipeErrWrite: THandle;
  FinalCmd: string;
  TempFile: string;
  Call_ET: UTF8String;
  PWorkDir: PAnsiChar;
  BytesCount: Dword;
  BuffContent: ^word;
  CanUseUtf8: boolean;
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
      PWorkDir := PAnsiChar(AnsiString(WorkDir));

    UpdateExecNum;
    ETShowCounter := (ETCounterLabel <> nil) and (ETCounter > 1);
    ETCounterLabel.Visible := ETShowCounter;
    CanUseUtf8 := (pos('-L ', ETcmd) = 0);
    if CreateArgs then
    begin
      FinalCmd := ET_Options.GetOptions(CanUseUtf8) + ArgsFromDirectCmd(ETcmd) + CRLF + FNames;
      TempFile := GetExifToolTmp;
      WriteArgsFile(FinalCmd, TempFile);
      Call_ET := GUIsettings.ETOverrideDir + 'exiftool -@ "' + TempFile + '"';
    end
    else
    begin
      FinalCmd := ET_Options.GetOptions(CanUseUtf8) + CRLF + ETcmd + CRLF + FNames;
      FinalCmd := StringReplace(FinalCmd, CRLF, ' ', [rfReplaceAll]);
      Call_ET := Guisettings.ETOverrideDir + 'exiftool ' + FinalCmd;
    end;
    result := CreateProcessA(nil, PansiChar(Call_ET), nil, nil, true,
                            CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                            nil, PWorkDir, StartupInfo, ProcessInfo);

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
      ETstream.Clear;
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
          end;
          ETstream.Write(PipeBuffer, BytesCount);
        end;
      until BytesCount = 0;

      ETstream.Position := 0;
      ETout.LoadFromStream(ETstream);
      ETouts := UTF8ToString(ETout.Text);
      CloseHandle(PipeOutRead);

      // ========= Read StdErr =======================
      ETstream.Clear;
      repeat
        ReadFile(PipeErrRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
        ETstream.Write(PipeBuffer, BytesCount);
      until (BytesCount = 0);
      ETstream.Position := 0;
      ETerr.LoadFromStream(ETstream);
      ETErrs := UTF8ToString(ETerr.Text);
      CloseHandle(PipeErrRead);

      // ----------------------------------------------
      WaitForSingleObject(ProcessInfo.hProcess, GUIsettings.ETTimeOut); // msec=5sec /or INFINITE
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);

      // Callback for Logging
      if Assigned(ExecETEvent) then
        ExecETEvent(ExecNum, FinalCmd, ETouts, ETErrs, true);

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

function ExecET(ETcmd, FNames, WorkDir: string; var ETouts: string): boolean;
var
  ETErrs: string;
begin
  result := ExecET(ETcmd, FNames, WorkDir, ETouts, ETErrs, false);
end;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^ End of ET Classic mode ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
// ==============================================================================
function ExecCMD(xCmd, WorkDir: string; var ETouts, ETErrs: string): boolean;
var
  ETstream: TMemoryStream;
  PipeBuffer: array [0 .. szPipeBuffer] of byte;
  ETout, ETerr: TStringList;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  PipeOutRead, PipeOutWrite: THandle;
  PipeErrRead, PipeErrWrite: THandle;
  PWorkDir: PChar;
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
    PWorkDir := PChar(WorkDir);

  ETout := TStringList.Create;
  ETerr := TStringList.Create;
  ETstream := TMemoryStream.Create;
  Screen.Cursor := -11; // =crHourGlass
  try
    UniqueString(xCmd); // Required by CreateprocessW
    result := CreateProcess(nil, PChar(xCmd), nil, nil, true,
                            CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                            nil, PWorkDir, StartupInfo, ProcessInfo);

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
      ETouts := UTF8ToString(ETout.Text);
      CloseHandle(PipeOutRead);
      // ========= Read StdErr =======================
      ETstream.Clear;
      repeat
        ReadFile(PipeErrRead, PipeBuffer, szPipeBuffer, BytesCount, nil);
        ETstream.Write(PipeBuffer, BytesCount);
      until (BytesCount = 0);
      ETstream.Position := 0;
      ETerr.LoadFromStream(ETstream);
      ETErrs := UTF8ToString(ETerr.Text);
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

function ExecCMD(xCmd, WorkDir: string): boolean;
var
  ETout, ETerr: string;
begin
  result := ExecCMD(xCmd, WorkDir, ETout, ETerr);
end;
// ==============================================================================

initialization

begin
  ETCounterLabel := nil;
  ETEvent := TEvent.Create(nil, true, true, ExtractFileName(Paramstr(0)));
  ExecNum := $30;
end;

finalization

begin
  ET_OpenExit;
  ETEvent.Free;
end;

end.
