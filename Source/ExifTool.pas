unit ExifTool;

interface

uses System.Classes, System.Types;

type
  TExecETEvent = procedure(ExecNum: word; EtCmds, EtOuts, EtErrs, StatusLine: string; PopupOnError: boolean) of object;

  // don't define '-a' (because of Filelist custom columns)
  // don't define '-e' (because of extracting previews)
  ET_OptionsRec = record
    ETLangDef: string;
    ETBackupMode: string;
    ETFileDate: string;
    ETSeparator: string;
    ETMinorError: string;
    ETGpsFormat: string;
    ETShowNumber: string;
    ETCharset: string;
    ETVerbose: integer;
    ETAPIWindowsWideFile: string;
    ETAPILargeFileSupport: string;
    ETGeoDir: string;
    ETCustomOptions: string;
    procedure SetGpsFormat(UseDecimal: boolean);
    procedure SetVerbose(Level: integer);
    procedure SetApiWindowsWideFile(UseWide: boolean);
    procedure SetApiLargeFileSupport(UseLarge: boolean);
    procedure SetGeoDir(GeoDir: string);
    procedure SetCustomOptions(Custom: string);
    procedure SetSeparator(const Sep: string);

    function GetVerbose: integer;
    function GetGeoDir: string;
    function GetCustomOptions: string;
    function GetOptions(Charset: boolean = true): string;
    function GetSeparator: string;
  end;

const
  CRLF = #13#10;

var
  ExecETEvent: TExecETEvent;

  ET_Options: ET_OptionsRec = (ETLangDef: '';
    ETBackupMode: '-overwrite_original' + CRLF;   // or ='' or='overwrite_original_in_place'
    ETFileDate: '';                               // or '-P'+CRLF (preserve FileModify date)
    ETSeparator: '-sep' + CRLF + '*' + CRLF;      // or '' (for keywords etc.)
    ETMinorError: '';                             // or '-m'+CRLF
    ETGpsFormat: '';                              // See SetGpsFormat
    ETShowNumber: '';                             // or '-n'+CRLF
    ETCharset: '-CHARSET' + CRLF + 'FILENAME=UTF8' + CRLF + '-CHARSET' + CRLF + 'UTF8'; // UTF8 it is. No choice
    ETVerbose: 0;                                 // For file counter
    ETGeoDir: '';                                 // Alternate GeoLocation Database
    ETCustomOptions: '');                         // or -u + CRLF Unknown Tags

function ETWorkDir: string;

function ET_StayOpen(WorkDir: string): boolean;

function ET_OpenExec(ETcmd: string; FNames: string; var ETouts, ETErrs: string; PopupOnError: boolean = true): boolean; overload;
function ET_OpenExec(ETcmd: string; FNames: string; ETout: TStrings; PopupOnError: boolean = true): boolean; overload;
function ET_OpenExec(ETcmd: string; FNames: string; PopupOnError: boolean = true): boolean; overload;

procedure ET_OpenExit(WaitForClose: boolean = false);

function ExecET(ETcmd, FNames, WorkDir: string; var ETouts, ETErrs: string): boolean; overload;
function ExecET(ETcmd, FNames, WorkDir: string; var ETouts: string): boolean; overload;

implementation

uses
  System.SysUtils, System.SyncObjs, Winapi.Windows, Main, MainDef, ExifToolsGUI_Utils, ExifTool_PipeStream,
  UnitLangResources;

const
  SizePipeBuffer = 65535;

var
  ETprocessInfo: TProcessInformation;
  EtOutPipe: TPipeStream;
  EtErrPipe: TPipeStream;
  PipeInRead, PipeInWrite: THandle;
  PipeOutRead, PipeOutWrite: THandle;
  PipeErrRead, PipeErrWrite: THandle;
  FETWorkDir: string;
  ETEvent: TEvent;
  ExecNum: word;

procedure ET_OptionsRec.SetGpsFormat(UseDecimal: boolean);
begin
  if UseDecimal then
    ETGpsFormat := '-c' + CRLF + '%.6f' + #$B0 + CRLF
  else
    ETGpsFormat := '-c' + CRLF + '%d' + #$B0 + '%.4f' + CRLF;
end;

procedure ET_OptionsRec.SetVerbose(Level: integer);
begin
  ETVerbose := Level;
end;

procedure ET_OptionsRec.SetApiWindowsWideFile(UseWide: boolean);
begin
  if UseWide then
    ETAPIWindowsWideFile := '-API' + CRLF + 'WindowsWideFile=1' + CRLF
  else
    ETAPIWindowsWideFile := '';
end;

procedure ET_OptionsRec.SetApiLargeFileSupport(UseLarge: boolean);
begin
  if UseLarge then
    ETAPILargeFileSupport  := '-API' + CRLF + 'LargeFileSupport=1' + CRLF
  else
    ETAPILargeFileSupport := '';
end;

procedure ET_OptionsRec.SetGeoDir(GeoDir: string);
begin
  if (GeoDir <> '') then
    ETGeoDir := '-API' + CRLF + 'GeoDir=' + GeoDir + CRLF
  else
    ETGeoDir := '';
end;

procedure ET_OptionsRec.SetCustomOptions(Custom: string);
begin
  ETCustomOptions := Custom;
end;

function ET_OptionsRec.GetVerbose: integer;
begin
  result := ETVerbose;
end;

function ET_OptionsRec.GetCustomOptions: string;
begin
  result := EndsWithCRLF(ArgsFromDirectCmd(ETCustomOptions));
end;

function ET_OptionsRec.GetGeoDir: string;
begin
  result := ETGeoDir;
end;

function ET_OptionsRec.GetOptions(Charset: boolean = true): string;
begin
  result := '';
  if (Charset) then
    result := ETCharset + CRLF;
  result := result + Format('-v%d', [ETVerbose]) + CRLF; // -for file counter!
  if ETLangDef <> '' then
    result := result + '-lang' + CRLF + ETLangDef + CRLF;
  result := result + ETBackupMode;
  result := result + ETSeparator;
  result := result + ETMinorError + ETFileDate;
  result := result + ETGpsFormat + ETShowNumber;
  result := result + ETAPIWindowsWideFile;
  result := result + ETAPILargeFileSupport;
  result := result + GetGeoDir;
  result := result + GetCustomOptions;
  // +further options...
end;

function ET_OptionsRec.GetSeparator: string;
var
  ETSep: string;
begin
  ETSep := ETSeparator;
  result := NextField(ETSep, #10);
  result := NextField(ETSep, #13);
end;

procedure ET_OptionsRec.SetSeparator(const Sep: string);
var
  CorrectSep: string;
begin
  CorrectSep := Sep;
  if (Trim(CorrectSep) = '') then
    CorrectSep := '*';

  ETSeparator := '-sep' + CRLF + CorrectSep + CRLF;
end;

// Add ExecNum to FinalCmd
procedure AddExecNum(var FinalCmd: string);
begin
  // Update Execnum. From 10 to 99.
  Inc(ExecNum);
  if (ExecNum > 99) then
    ExecNum := 10;
              // '-echo4 CRLF {readyxx} CRLF'    Ensures that something is written to StdErr. TSOPipeStream relies on it.
  FinalCmd := Format('-echo4%s{ready%u}%s', [CRLF, ExecNum, CRLF]) +
              FinalCmd +
              // '-executexx CRLF'               The same for STDout.
              Format('-execute%u%s', [ExecNum, CRLF]);
end;

function ETWorkDir: string;
begin
  result := FETWorkDir;
end;

// ============================== ET_Open mode ==================================
function ET_StayOpen(WorkDir: string): boolean;
var
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  PWorkDir: PChar;
  ETcmd: string;
begin
  result := true;
  if (FETWorkDir = WorkDir) then
    exit;
  ET_OpenExit; // -changing WorkDir OnTheFly requires Exit first

  ETcmd := GUIsettings.ETOverrideDir + 'exiftool ' + GUIsettings.GetCustomConfig + ' -stay_open True -@ -';
  FillChar(ETprocessInfo, SizeOf(TProcessInformation), #0);
  FillChar(SecurityAttr, SizeOf(TSecurityAttributes), #0);
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := true;
  SecurityAttr.lpSecurityDescriptor := nil;
  CreatePipe(PipeInRead, PipeInWrite, @SecurityAttr, 0);
  CreatePipe(PipeOutRead, PipeOutWrite, @SecurityAttr, 0);
  CreatePipe(PipeErrRead, PipeErrWrite, @SecurityAttr, 0);
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
    CloseHandle(PipeInRead);
    CloseHandle(PipeOutWrite);
    CloseHandle(PipeErrWrite);

    if Assigned(EtOutPipe) then
      FreeAndNil(EtOutPipe);
    ETOutPipe := TPipeStream.Create(PipeOutRead, SizePipeBuffer);

    if Assigned(EtErrPipe) then
      FreeAndNil(EtErrPipe);
    ETErrPipe := TPipeStream.Create(PipeErrRead, SizePipeBuffer);

    FETWorkDir := WorkDir;
  end
  else
  begin
    CloseHandle(PipeInRead);
    CloseHandle(PipeInWrite);
    CloseHandle(PipeOutRead);
    CloseHandle(PipeOutWrite);
    CloseHandle(PipeErrRead);
    CloseHandle(PipeErrWrite);
  end;
  result := (FETWorkDir <> '');
end;

function ET_OpenExec(ETcmd: string; FNames: string; var ETouts, ETErrs: string; PopupOnError: boolean = true): boolean;
var
  ReadOut: TSOReadPipeThread;
  ReadErr: TSOReadPipeThread;
  FinalCmd: string;
  TempFile: string;
  StatusLine: string;
  LengthReady: integer;
  Call_ET: AnsiString; // Needs to be AnsiString. Only holds the -@ <argsfilename>
  BytesCount: Dword;
  CanUseUtf8: boolean;
  Wr: TWaitResult;
  CrWait, CrNormal: HCURSOR;
begin
  result := false;

  if (FETWorkDir <> '') and
     (Length(ETcmd) > 1) then
  begin
    Wr := ETEvent.WaitFor(GUIsettings.ETTimeOut);
    if (Wr <> wrSignaled) then
    begin
      ETEvent.SetEvent;
      result := false;
      ETouts := '';
      ETErrs := StrTimeOutWaitingFor + CRLF;
      exit;
    end;
    ETEvent.ReSetEvent;

    CrWait := LoadCursor(0, IDC_WAIT);
    CrNormal := SetCursor(CrWait);
    try
      // Create TempFile with commands and filenames
      if pos('||', ETcmd) > 0 then
        ETcmd := StringReplace(ETcmd, '||', CRLF, [rfReplaceAll]);
      CanUseUtf8 := (pos('-L' + CRLF, ETcmd) = 0);
      FinalCmd := EndsWithCRLF(ET_Options.GetOptions(CanUseUtf8) + ETcmd);
      if FNames <> '' then
        FinalCmd := EndsWithCRLF(FinalCmd + FNames);

      AddExecNum(FinalCmd);

      // Create tempfile
      TempFile := GetExifToolTmp;
      WriteArgsFile(FinalCmd, TempFile);
      Call_ET := EndsWithCRLF('-@' + CRLF + TempFile);

      // Write command to Pipe. Triggers ExifTool execution
      WriteFile(PipeInWrite, Call_ET[1], ByteLength(Call_ET), BytesCount, nil);
      FlushFileBuffers(PipeInWrite);

      // ========= Read StdOut and stdErr =======================
      EtOutPipe.SetCounter(GetCounter);
      ReadOut := TSOReadPipeThread.Create(EtOutPipe, ExecNum);
      ReadErr := TSOReadPipeThread.Create(EtErrPipe, ExecNum);
      try
        ReadOut.WaitFor;
        ReadErr.WaitFor;
      finally
        SetCounter(nil, 0);
        ReadOut.Free;
        ReadErr.Free;
      end;
      ETouts := ETOutPipe.AnalyseResult(StatusLine, LengthReady);
      ETOutPipe.Clear;

      ETErrs := ETErrPipe.AnalyseError;
      ETErrPipe.Clear;

      // Callback for Logging
      if Assigned(ExecETEvent) then
        ExecETEvent(ExecNum, FinalCmd, ETouts, ETErrs, StatusLine, PopupOnError);

      // Return result without {readyxx}#13#10
      SetLength(ETouts, Length(ETouts) - LengthReady);
      result := true;
    finally
      SetCursor(CrNormal);
      ETEvent.SetEvent;
    end;
  end;
end;

function ET_OpenExec(ETcmd: string; FNames: string; ETout: TStrings; PopupOnError: boolean = true): boolean;
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

procedure ET_OpenExit(WaitForClose: boolean = false);
const
  ExitCmd: AnsiString = '-stay_open' + CRLF + 'False' + CRLF; // Needs to be AnsiString.
var
  BytesCount: Dword;
begin
  if (FETWorkDir <> '') then
  begin
    WriteFile(PipeInWrite, ExitCmd[1], Length(ExitCmd), BytesCount, nil);
    FlushFileBuffers(PipeInWrite);

    if (WaitForClose) then
      WaitForSingleObject(ETprocessInfo.hProcess, GUIsettings.ETTimeOut);

    CloseHandle(ETprocessInfo.hThread);
    CloseHandle(ETprocessInfo.hProcess);
    CloseHandle(PipeInWrite);
    CloseHandle(PipeOutRead);
    CloseHandle(PipeErrRead);
    FETWorkDir := '';
  end;
end;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^ End of ET_Open mode ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
// =========================== ET classic mode ==================================
function ExecET(ETcmd, FNames, WorkDir: string; var ETouts, ETErrs: string): boolean;
var
  ReadOut: TReadPipeThread;
  ReadErr: TReadPipeThread;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  PipeOutRead, PipeOutWrite: THandle;
  PipeErrRead, PipeErrWrite: THandle;
  FinalCmd: string;
  TempFile: string;
  StatusLine: string;
  LengthReady: integer;
  Call_ET: string;
  PWorkDir: PChar;
  CanUseUtf8: boolean;
  CrWait, CrNormal: HCURSOR;
begin

  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);

  try
    FillChar(ProcessInfo, SizeOf(TProcessInformation), #0);
    FillChar(SecurityAttr, SizeOf(TSecurityAttributes), #0);
    SecurityAttr.nLength := SizeOf(SecurityAttr);
    SecurityAttr.bInheritHandle := true;
    SecurityAttr.lpSecurityDescriptor := nil;
    CreatePipe(PipeOutRead, PipeOutWrite, @SecurityAttr, 0);
    CreatePipe(PipeErrRead, PipeErrWrite, @SecurityAttr, 0);
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

    CanUseUtf8 := (pos('-L ', ETcmd) = 0);

    FinalCmd := EndsWithCRLF(ET_Options.GetOptions(CanUseUtf8) + ArgsFromDirectCmd(ETcmd));
    FinalCmd := EndsWithCRLF(FinalCmd + FNames);

    AddExecNum(FinalCmd);

    TempFile := GetExifToolTmp;
    WriteArgsFile(FinalCmd, TempFile);
    Call_ET := GUIsettings.ETOverrideDir + 'exiftool ' + GUIsettings.GetCustomConfig + ' -@ "' + TempFile + '"';

    result := CreateProcess(nil, PChar(Call_ET), nil, nil, true,
                            CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                            nil, PWorkDir, StartupInfo, ProcessInfo);
    CloseHandle(PipeOutWrite);
    CloseHandle(PipeErrWrite);
    if result then
    begin
      // ========= Read StdOut and stdErr =======================
      ReadOut := TReadPipeThread.Create(PipeOutRead, SizePipeBuffer);
      ReadOut.PipeStream.SetCounter(GetCounter);
      ReadErr := TReadPipeThread.Create(PipeErrRead, SizePipeBuffer);
      try
        ReadOut.WaitFor;
        ETouts := ReadOut.PipeStream.AnalyseResult(StatusLine, LengthReady);

        ReadErr.WaitFor;
        ETErrs := ReadErr.PipeStream.AnalyseError;
      finally
        ReadOut.Free;
        ReadErr.Free;
        SetCounter(nil, 0);
      end;

      // ----------------------------------------------
      WaitForSingleObject(ProcessInfo.hProcess, GUIsettings.ETTimeOut);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);

      // Callback for Logging
      if Assigned(ExecETEvent) then
        ExecETEvent(ExecNum, FinalCmd, ETouts, ETErrs, StatusLine, true);

      // Return result without {readyxx}#13#10
      // Although this call will never have it.
      SetLength(ETouts, Length(ETouts) - LengthReady);
      result := true;
    end;
  finally
    CloseHandle(PipeOutRead);
    CloseHandle(PipeErrRead);
    SetCursor(CrNormal);
  end;
end;

function ExecET(ETcmd, FNames, WorkDir: string; var ETouts: string): boolean;
var
  ETErrs: string;
begin
  result := ExecET(ETcmd, FNames, WorkDir, ETouts, ETErrs);
end;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^ End of ET Classic mode ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
// ==============================================================================

initialization

begin
  ETEvent := TEvent.Create(nil, true, true, ExtractFileName(Paramstr(0)));
  ExecNum := 10; // From 10 to 99
  FETWorkDir := '';
  EtOutPipe := nil;
  EtErrPipe := nil;
  if (DirectoryExists(GetGeoPath)) then
    ET_Options.SetGeoDir(GetGeoPath);
end;

finalization

begin
  ET_OpenExit(true);
  ETEvent.Free;
  if Assigned(EtOutPipe) then
    EtOutPipe.Free;
  if Assigned(EtErrPipe) then
    EtErrPipe.Free;
end;

end.
