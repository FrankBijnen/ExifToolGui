; -- ExifToolGUI_install.iss --
;
; Install the 32 and 64 bits versions of ExifToolGui

#define ExifToolGUI "ExifToolGUI"
#define ExifToolGUIPublisher "FrankB"
; URl's
#define ExifToolGUIUpdatesURL "https://github.com/FrankBijnen/ExifToolGui/releases"
#define PHUrl "https://exiftool.org/"
#define OBetzUrl "https://oliverbetz.de/cms/files/Artikel/ExifTool-for-Windows/"
; _32 or _64
#define ETPlatform "{code:Platform}"
; empty or _X64
#define ETPlatformSuffix "{code:Platform_Suffix}"
; E.G. 6.3.0.0
; Note: Uses the version of the 32 Bit exe.
#define ExifToolGUIVersion GetVersionNumbersString('Win32\ExiftoolGui.exe')
; E.G. 6.3.0.0_32 or 6.3.0.0_64
#define ExifToolGUIVersionPlatform ExifToolGUIVersion + "{code:PlatForm}"
; ExifTool.exe or ExifToolGUI_X64.exe
#define ExifToolGUIExeName ExifToolGUI + ETPlatformSuffix + ".exe"
; Output name of installer.
#define ExifToolGuiInstaller ExifToolGUI + "_install_" + ExifToolGUIVersion
; Default directory to install
#define DefaultDirName "{code:DefaultDir}\" + ExifToolGUI
; Additional tasks
; Enable only 1!
#define EnableAutoDownload "Yes"
#define EnableAutoDownloadPH "No"
#define EnableAutoDownloadOBetz "No"
;
#define DownloadExifToolManual "DownloadExifToolManual"
#define DownloadExifToolAuto "DownloadExifToolAuto"
; Change the tasks options.
#if EnableAutoDownload == "Yes"
#define BackSlash "\"           ; Hierarchy
#define Exclusive "exclusive"   ; Radio button
#else
#define BackSlash ""            ; No Hierarchy
#define Exclusive ""            ; Checkbox
#endif
;
#define TaskPH "PH"
#define TaskOBETZ "OBETZ"
#define DownloadExifToolAutoPH DownloadExifToolAuto + BackSlash + TaskPH
#define DownloadExifToolAutoOBETZ DownloadExifToolAuto + BackSlash+ TaskOBETZ
#define ByPhilHarvey "By Phil Harvey (" + PHUrl + ")"
#define ByOliverBetz "By Oliver Betz (" + OBetzUrl + ")"

[Setup]
AppPublisher={#ExifToolGUIPublisher}
AppUpdatesURL={#ExifToolGUIUpdatesURL}
AppName={#ExifToolGUI}
AppVersion={#ExifToolGUIVersionPlatform}
VersionInfoTextVersion={#ExifToolGUIVersionPlatform}
VersionInfoProductTextVersion={#ExifToolGUIVersionPlatform}
WizardStyle=modern
DefaultDirName={#DefaultDirName}
DefaultGroupName={#ExifToolGUI}
UninstallDisplayIcon={app}\{#ExifToolGUIExeName}
OutputDir=.
OutputBaseFilename={#ExifToolGuiInstaller}
UsePreviousTasks=No
UsePreviousSetupType=No
UsePreviousLanguage=No
Compression=lzma2/normal
LZMANumBlockThreads=16
LZMAUseSeparateProcess=yes
SolidCompression=no
RestartIfNeededByRun=no
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
SetupIconFile=ExifToolGUI.ico
WizardSmallImageFile=ExifToolGUI.Bmp
DisableProgramGroupPage=yes
; Will be overriden
InfoAfterFile=InfoComplete.rtf

[Messages]
FinishedHeadingLabel=[name] has been installed. Exiftool will be installed using the Oliver Betz installer.
FinishedLabel=It is recommended to keep the default settings. In particular 'Add Exiftool to Path'.
ClickFinish=(Un)Check Install Exiftool and click Finish to continue.

[Components]
Name: ExecutableWin32;                  Description: "Install Executable (Win32)";            types: compact full;  Check: Win32;
Name: MapFileWin32;                     Description: "Install Map file (Win32)";              types: full;          Check: Win32;
Name: WebView2LoaderDLLWin32;           Description: "Install WebView2Loader.DLL (Win32)";    types: full;          Check: Win32;
Name: LanguagesWin32;                   Description: "Install Language DLL's (Win32)";        types: full;          Check: Win32;

Name: ExecutableWin64;                  Description: "Install Executable (Win64)";            types: compact full;  Check: Win64;
Name: MapFileWin64;                     Description: "Install Map file (Win64)";              types: full;          Check: Win64;
Name: WebView2LoaderDLLWin64;           Description: "Install WebView2Loader.DLL (Win64)";    types: full;          Check: Win64;
Name: LanguagesWin64;                   Description: "Install Language DLL's (Win64)";        types: full;          Check: Win64;

[Tasks]
Name: desktopicon;                      Description: "Create a &desktop icon"; \
                                          GroupDescription: "Icons";
Name: {#DownloadExifToolManual};        Description: "&Manual. Download links will be presented after installing.";  \
                                          GroupDescription: "Download ExifTool. (Currently installed: {code:ShowInstalledVersion})"; \
                                                                                              Flags: exclusive;               Check: EnableAutoDownload;
Name: {#DownloadExifToolAuto};          Description: "&Automatic download and install of ExifTool. (Select will check available versions. Internet required.)"; \
                                          GroupDescription: "Download ExifTool. (Currently installed: {code:ShowInstalledVersion})"; \
                                                                                              Flags: exclusive unchecked;     Check: EnableAutoDownload;
Name: {#DownloadExifToolAutoPH};        Description: "{#ByPhilHarvey}"; \
                                          GroupDescription: "Download and install ExifTool:"; Flags: {#Exclusive} unchecked;  Check: EnableAutoDownload or EnableAutoDownloadPH;
Name: {#DownloadExifToolAutoOBETZ};     Description: "{#ByOliverBetz}"; \
                                          GroupDescription: "Download and install ExifTool:"; Flags: {#Exclusive} unchecked;  Check: EnableAutoDownload or EnableAutoDownloadOBetz;

[Files]
; Executable
Source: "Win32\ExifToolGui.exe";        DestDir: "{app}"; Components: ExecutableWin32;        flags: replacesameversion;
Source: "Win64\ExifToolGui_X64.exe";    DestDir: "{app}"; Components: ExecutableWin64;        flags: replacesameversion;

; Map File
Source: "Win64\ExifToolGui_X64.map";    DestDir: "{app}"; Components: MapFileWin64;           flags: replacesameversion;
Source: "Win32\ExifToolGui.map";        DestDir: "{app}"; Components: MapFileWin32;           flags: replacesameversion;

; WebView2Loader
Source: "Win64\WebView2Loader.dll";     DestDir: "{app}"; Components: WebView2LoaderDLLWin64; flags: replacesameversion;
Source: "Win32\WebView2Loader.dll";     DestDir: "{app}"; Components: WebView2LoaderDLLWin32; flags: replacesameversion;

; Language Files
Source: "..\Translation\ExifToolGui_X64.DEU"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.ENU"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.ESP"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.FRA"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.ITA"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.NLD"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.PTB"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;

Source: "..\Translation\ExifToolGui.DEU";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.ENU";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.ESP";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.FRA";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.ITA";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.NLD";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.PTB";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;

; These files will be downloaded
Source: "{tmp}\exiftool_version.txt";   DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;
Source: "{tmp}\exiftool.exe";           DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;
Source: "{code:OBetzInstaller|{tmp}}";  DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;

[Icons]
Name: "{group}\{#ExifToolGUI}";         Filename: "{app}\{#ExifToolGUIExeName}"
Name: "{userdesktop}\{#ExifToolGUI}";   Filename: "{app}\{#ExifToolGUIExeName}";              tasks: desktopicon;

[run]
Filename: "{code:OBetzInstaller|{app}}";Description: {code:InstallOBetzMsg};                  flags: postinstall skipifdoesntexist waituntilterminated; StatusMsg: "Installing ExifTool"; \
  Check: OBetzSelected;

[Code]

var

  DownloadPageET: TDownloadWizardPage;
  CURVer: AnsiString;
  ETVerPH: AnsiString;
  ETVerOBetz: AnsiString;
  ETFile: AnsiString;

  ISCustomPage1: TWizardPage;
  RichEditViewer1: TRichEditViewer;

const
  NeverDownload             = false;
  SHCONTCH_NOPROGRESSBOX    = $4;
  SHCONTCH_RESPONDYESTOALL  = $10;

  // Current version of ExifTool
  CURVER_TXT                = 'curver.txt';
  CURVER_UNAVAIL            = 'Unavail';
  AVAILVER_ERROR            = 'Error';

  // Constants for OBetz installer
  OBETZURL                  = '{#OBetzUrl}';
  OBETZVER                  = 'exiftool_latest_version.txt';
  OBETZINSTALL              = 'ExifTool_install';

  // Constants for Phil Harvey's ExifTool
  PHURL                     = '{#PHUrl}';
  VER_TXT                   = 'ver.txt';
  ZIP                       = '.zip';
  EXE                       = '.exe';
  ET_K                      = 'exiftool(-k)';
  ET                        = 'exiftool';

function GetInstalledVersionInPath(const Path: string): AnsiString;
var
  Version_file: string;
  TmpDir: string;
  Params: string;
  P: integer;
  ErrorCode: integer;
  Rc: boolean;
begin
  TmpDir := ExpandConstant('{tmp}');
  Version_file := AddQuotes(ExpandConstant('{tmp}') + '\' + CURVER_TXT);
  Params := '/c' + AddQuotes(Path + 'exiftool') + ' -ver > ' + Version_file;
  Rc := ExecAsOriginalUser(GetEnv('COMSPEC'), Params, TmpDir, SW_HIDE, ewWaitUntilTerminated, ErrorCode);
  if (not Rc) or 
     (ErrorCode <> 0) then
  begin
    result := CURVER_UNAVAIL;
    exit;
  end;

  if not (LoadStringFromFile(Version_file, result)) then
  begin
    result := CURVER_UNAVAIL;
    exit;
  end;

  P := Pos(#13, result);
  if (P > 0) then
    result := Copy(result, 1, P -1); // Line is terminated with CR(LF)
end;

// Get installed version of exiftool. 
function GetInstalledVersion: AnsiString;
begin
  result := GetInstalledVersionInPath('');
  if (result = CURVER_UNAVAIL) then
    result := GetInstalledVersionInPath(AddBackslash(ExpandConstant('{app}')));
end;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

function GetCurrentVersion(const VersionUrl: string): AnsiString;
var
  Version_file: string;
  P: integer;
begin
  // First get Version to download. Dont show in Download page. Only a few bytes!
  try
    DownloadTemporaryFile(VersionUrl, VER_TXT, '' , @OnDownloadProgress);
  except
    result := AVAILVER_ERROR;
    exit;
  end;

  Version_file := ExpandConstant('{tmp}\' + VER_TXT);
  if not (LoadStringFromFile(Version_file, result)) then
  begin
    result := AVAILVER_ERROR;
    exit;
  end;

  P := Pos(#13, result);
  if (P > 0) then
    result := Copy(result, 1, P -1); // Line is terminated with CR(LF)
end;

{ @TLama's function from https://stackoverflow.com/q/14392921/850848 }
function CmdLineParamExists(const Value: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if CompareText(ParamStr(I), Value) = 0 then
    begin
      Result := True;
      Exit;
    end;
end;

//convert Ansi String to String
function ConvertToString(AString: AnsiString): String;
var
 I : Integer;
 IChar : Integer;
begin
  Result :='';
  for I := 1 to Length(AString) do
  begin
    IChar := Ord(AString[I]); //get int value
    Result := Result + Chr(IChar);
  end;
end;

function Win32: boolean;
begin
  result := (not IsWin64) or CmdLineParamExists('/Win32');
end;

function Win64: boolean;
begin
  result := not Win32;
end;

// 1 param seems to be mandatory
function Platform(Param: string): string;
begin
  if (Win32) then
    result := '_32'
  else
    result := '_64';
end;

// 1 param seems to be mandatory
function Platform_Suffix(Param: string): string;
begin
  if (Win32) then
    result := ''
  else
    result := '_X64';
end;

function EnableAutoDownload: boolean;
begin
  result := (UpperCase(ExpandConstant('{#EnableAutoDownload}')) = 'YES');
end;

function EnableAutoDownloadPH: boolean;
begin
  result := (EnableAutoDownload = false) and
            (UpperCase(ExpandConstant('{#EnableAutoDownloadPH}')) = 'YES');
end;

function EnableAutoDownloadOBetz: boolean;
begin
  result := (EnableAutoDownload = false) and
            (UpperCase(ExpandConstant('{#EnableAutoDownloadOBetz}')) = 'YES');
end;

function ObetzSelected: boolean;
begin
  result := (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolAutoOBETZ}')));
end;

function PHSelected: boolean;
begin
  result := (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolAutoPH}')));
end;

// 1 param seems to be mandatory
function DefaultDir(Param: string): string;
begin
  result := ExpandConstant('{autopf}');
  if (IsWin64) and
     (CmdLineParamExists('/Win32')) then
    result := ExpandConstant('{autopf32}');
end;

procedure unzip(ZipFile, TargetFldr: PAnsiChar);
var
  shellobj: variant;
  ZipFileV, TargetFldrV: variant;
  SrcFldr, DestFldr: variant;
  shellfldritems: variant;
begin
  if FileExists(ZipFile) then
  begin
    ForceDirectories(TargetFldr);
    shellobj := CreateOleObject('Shell.Application');
    ZipFileV := string(ZipFile);
    TargetFldrV := string(TargetFldr);
    SrcFldr := shellobj.NameSpace(ZipFileV);
    DestFldr := shellobj.NameSpace(TargetFldrV);
    shellfldritems := SrcFldr.Items;
    DestFldr.CopyHere(shellfldritems, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
  end;
end;

procedure TaskOnClick(Sender: TObject); 
var
  I: Integer;
begin
  for I := 0 to WizardForm.TasksList.Items.Count - 1 do
  begin
    if (WizardForm.TasksList.ItemCaption[I] = ExpandConstant('{#ByPhilHarvey}')) then
    begin
      if (ETVerPH = '') then
        ETVerPH := GetCurrentVersion(PHURL + VER_TXT);
      WizardForm.TasksList.ItemCaption[I] := WizardForm.TasksList.ItemCaption[I] + ' Available: ' + ConvertToString(ETVerPH);
    end;
    if (WizardForm.TasksList.ItemCaption[I] = ExpandConstant('{#ByOliverBetz}')) then
    begin
      if (ETVerOBetz = '') then
        ETVerOBetz := GetCurrentVersion(OBETZURL + OBETZVER);
      WizardForm.TasksList.ItemCaption[I] := WizardForm.TasksList.ItemCaption[I] + ' Available: ' + ConvertToString(ETVerOBetz);
    end;
  end;
end;

procedure initializewizard;
begin
  { Creates custom wizard page }
  ISCustomPage1 := CreateCustomPage(wpInfoAfter, 'Information', 'Please read the following information before using ' + ExpandConstant('{#ExifToolGUI}'));

  { RichEditViewer1 }
  RichEditViewer1 := TRichEditViewer.Create(WizardForm);
  with RichEditViewer1 do
  begin
    ScrollBars := ssVertical;
    Parent := ISCustomPage1.Surface;
    TabOrder := 0;
    Left := ScaleX(0);
    Top := ScaleY(0);
    Width := ScaleX(500);
    Height := ScaleY(241);
    ReadOnly := True;
  end;
  CURver := '';
  ETVerPH := '';
  ETVerOBetz := '';

  WizardForm.TasksList.OnClickCheck := @TaskOnClick;
end;

procedure SetupRichText;
begin
  if (PHSelected or OBetzSelected) then
    RichEditViewer1.RTFText := // InfoNoDownload.rtf
      '{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}' + #13 + #10 +
      '{\colortbl ;\red0\green0\blue255;}' + #13 + #10 +
      '{\*\generator Riched20 10.0.19041}\viewkind4\uc1 ' + #13 + #10 +
      '\pard\sl276\slmult1\f0\fs22\lang9 If you wish to see thumbnails of raw image files, you will need to install a codec adapted for the RAW files you use. FastPictureViewer provides free codecs for personal use: \tab {{\field{\*\fldinst{HYPERLINK https://www.fastpictureviewer.com/codecs/ }}{\fldrslt{https://www.fastpictureviewer.com/codecs/\ul0\cf0}}}}\f0\fs22\par' + #13 + #10 +
      '}' + #13 + #10
  else
    RichEditViewer1.RTFText := //InfoComplete.rtf
      '{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}' + #13 + #10 +
      '{\colortbl ;\red0\green0\blue255;}' + #13 + #10 +
      '{\*\generator Riched20 10.0.19041}\viewkind4\uc1 ' + #13 + #10 +
      '\pard\sl240\slmult1\f0\fs22\lang9 You can download ExifTool here:\par' + #13 + #10
      + #13 + #10
      '\pard{\pntext\f1\''B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\''B7}}\fi-360\li720\sl276\slmult1 The original version by Phil Harvey: \par' + #13 + #10 +
      + #13 + #10
      '\pard\sl276\slmult1\tab {{\field{\*\fldinst{HYPERLINK https://exiftool.org/ }}{\fldrslt{https://exiftool.org/\ul0\cf0}}}}\f0\fs22\par' + #13 + #10 +
      + #13 + #10
      '\pard{\pntext\f1\''B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\''B7}}\fi-360\li720\sl276\slmult1 An installer provider by Oliver Betz:\par' + #13 + #10 +
      + #13 + #10
      '\pard\sl276\slmult1\tab {{\field{\*\fldinst{HYPERLINK https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows }}{\fldrslt{https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows\ul0\cf0}}}}\f0\fs22\par' + #13 + #10 +
      + #13 + #10 +
      '\pard\sl276\slmult1\par' + #13 + #10 +
      'To enable thumbnails of RAW image files, you will need to install a codec adapted for the RAW files you use. FastPictureViewer provides free codecs for personal use: \tab {{\field{\*\fldinst{HYPERLINK https://www.fastpictureviewer.com/codecs/ }}{\fldrslt{https://www.fastpictureviewer.com/codecs/\ul0\cf0}}}}\f0\fs22\par' + #13 + #10 +
      '}' + #13 + #10;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Now we know what info to show.
  if (PageId = wpInfoAfter) then
  begin
    SetupRichText;
    result := true;
  end;
  // Skip Finishing page, with option to install installer from OBetz, if not selected
  if (PageId = wpFinished) then
     result := (OBetzSelected = false);
end;

function OBetzInstaller(const Path: string): string;
begin
  result := Path;
  if (result <> '') then
    result := result + '\';
  result := result + OBETZINSTALL + '_' + ETVerOBetz +  ExpandConstant('{#ETPlatform}') + EXE
end;

function InstallOBetzMsg(const Param: string):string;
begin
  result := 'Install Exiftool' + #10 + ' from: ' + OBetzInstaller(ExpandConstant('{app}'));
  if (ConvertToString(CurVer) <> CURVER_UNAVAIL) then
    result := result + #10 + 'Please uninstall existing version:' + CurVer +' first!'
end;

function ShowInstalledVersion(const Param: string): String;
begin
  result := ConvertToString(CurVer);
end;

// Show in Download page
function ShowDownLoadPage(const Remote, Local:string): boolean;
begin
  DownloadPageET := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
  DownloadPageET.Add(Remote, Local, '');
  DownloadPageET.Show;

  try
    try
      DownloadPageET.Download; // This downloads the files to {tmp}
      Result := True;
    except
      if DownloadPageET.AbortedByUser then
        Log('Aborted by user.')
      else
        SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
      Result := False;
    end;
  finally
    DownloadPageET.Hide;
  end;
end;

function DownloadETOBetz: boolean;
begin
  ETFile := OBETZURL + OBetzInstaller('');
  if (NeverDownload) then
  begin
    result := true;
    exit;
  end;
  result := ShowDownLoadPage(ETFile, OBetzInstaller(''));
end;

function DownloadETPH: boolean;
begin
  ETFile := PHURL + ET + '-' + ETVerPH + ZIP;
  if (NeverDownload) then
  begin
    result := true;
    exit;
  end;

  result := ShowDownLoadPage(ETFile, ET + ZIP);

  if (result) then
  begin
    // These operations all take place in TMP folder.
    result := false; // In case actions in TMP folder should fail

    // Delete existing files. Dont check, dont need to be there
    DeleteFile(ExpandConstant('{tmp}\' + ET_K + EXE));
    DeleteFile(ExpandConstant('{tmp}\' + ET + EXE));

    // Unzip Exiftool(-k).exe in app folder and rename to exiftool.exe
    unzip(ExpandConstant('{tmp}\' + ET + ZIP), ExpandConstant('{tmp}'));

    // unzip has no result. Check if file exists.
    if not FileExists(ExpandConstant('{tmp}\' + ET_K + EXE)) then
      RaiseException('Unzipping ' + ET + ZIP + ' failed');

    // Rename
    if not RenameFile(ExpandConstant('{tmp}\' + ET_K + EXE), ExpandConstant('{tmp}\' + ET + EXE)) then
      RaiseException('Rename to ' +  ET + EXE + ' failed');

     result := true;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := true;

  // We know the AppDir
  if (CurPageID = wpSelectComponents) then
    CurVer := GetInstalledVersion;

  if (CurPageID  = wpSelectTasks) then
  begin
    if (CurVer = CURVER_UNAVAIL) and
       (OBetzSelected = false) and
       (PHSelected = false) then
      result := (SuppressibleMsgBox('ExifTool is not found, and you did not select to install it. Continue?',  \
                                    mbConfirmation, MB_YESNO, IDYES) = IDYES);
    if ((OBetzSelected) and
        (CurVer = ETVEROBetz)) or
       ((PHSelected) and
        (CurVer = ETVERPH)) then
      result := (SuppressibleMsgBox('Your selected ExifTool version is already installed. Continue?',  \
                                    mbConfirmation, MB_YESNO, IDYES) = IDYES);
  end;

  if (CurPageID = wpReady) then
  begin
    if OBetzSelected then
      result := DownLoadETOBetz
    else if PHSelected then
      result := DownLoadETPH;
  end;

end;
