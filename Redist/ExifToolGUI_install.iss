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
#define DownloadExifToolManual "DownloadExifToolManual"
#define DownloadExifToolAuto "DownloadExifToolAuto"
#define DownloadExifToolAutoPH DownloadExifToolAuto + "\PH"
#define DownloadExifToolAutoOBETZ DownloadExifToolAuto + "\OBETZ"

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
UsePreviousPrivileges=No
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
InfoAfterFile=DownLoadInfo.rtf

[CustomMessages]
InstallOBetzMsg=Install ExifTool using the Oliver Betz installer.%n(Please uninstall any existing versions first!)

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
Name: desktopicon;                      Description: "Create a &desktop icon";                                      GroupDescription: "Icons";
Name: {#DownloadExifToolManual};        Description: "&Manual. Download links will be presented after installing."; GroupDescription: "Download ExifTool";  Flags: exclusive;
Name: {#DownloadExifToolAuto};          Description: "&Automatic download and install of ExifTool.";                GroupDescription: "Download ExifTool";  Flags: exclusive unchecked; 
Name: {#DownloadExifToolAutoPH};        Description: "By Phil Harvey ({#PHUrl})";                                   GroupDescription: "Other tasks:";       Flags: exclusive unchecked;
Name: {#DownloadExifToolAutoOBETZ};     Description: "By Oliver Betz ({#OBetzUrl})";                                GroupDescription: "Other tasks:";       Flags: exclusive unchecked;

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
Source: "Win64\ExifToolGui_X64.DEU";    DestDir: "{app}"; Components: LanguagesWin64;         flags: replacesameversion;
Source: "Win64\ExifToolGui_X64.ENU";    DestDir: "{app}"; Components: LanguagesWin64;         flags: replacesameversion;
Source: "Win64\ExifToolGui_X64.ESP";    DestDir: "{app}"; Components: LanguagesWin64;         flags: replacesameversion;
Source: "Win64\ExifToolGui_X64.FRA";    DestDir: "{app}"; Components: LanguagesWin64;         flags: replacesameversion;
Source: "Win64\ExifToolGui_X64.ITA";    DestDir: "{app}"; Components: LanguagesWin64;         flags: replacesameversion;
Source: "Win64\ExifToolGui_X64.NLD";    DestDir: "{app}"; Components: LanguagesWin64;         flags: replacesameversion;
Source: "Win64\ExifToolGui_X64.PTB";    DestDir: "{app}"; Components: LanguagesWin64;         flags: replacesameversion;

Source: "Win32\ExifToolGui.DEU";        DestDir: "{app}"; Components: LanguagesWin32;         flags: replacesameversion;
Source: "Win32\ExifToolGui.ENU";        DestDir: "{app}"; Components: LanguagesWin32;         flags: replacesameversion;
Source: "Win32\ExifToolGui.ESP";        DestDir: "{app}"; Components: LanguagesWin32;         flags: replacesameversion;
Source: "Win32\ExifToolGui.FRA";        DestDir: "{app}"; Components: LanguagesWin32;         flags: replacesameversion;
Source: "Win32\ExifToolGui.ITA";        DestDir: "{app}"; Components: LanguagesWin32;         flags: replacesameversion;
Source: "Win32\ExifToolGui.NLD";        DestDir: "{app}"; Components: LanguagesWin32;         flags: replacesameversion;
Source: "Win32\ExifToolGui.PTB";        DestDir: "{app}"; Components: LanguagesWin32;         flags: replacesameversion;

; These files will be downloaded
Source: "{tmp}\exiftool_version.txt";   DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;
Source: "{tmp}\exiftool.exe";           DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;
Source: "{code:OBetzInstaller|{tmp}}";  DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;

[Icons]
Name: "{group}\{#ExifToolGUI}";         Filename: "{app}\{#ExifToolGUIExeName}"
Name: "{userdesktop}\{#ExifToolGUI}";   Filename: "{app}\{#ExifToolGUIExeName}";              tasks: desktopicon;

[run]
Filename: "{code:OBetzInstaller|{app}}";  Description: {cm:InstallOBetzMsg};                  flags: postinstall skipifdoesntexist; StatusMsg: "Installing ExifTool";

[Code]

var

  DownloadPageET: TDownloadWizardPage;
  ETVer: AnsiString;
  ETFile: AnsiString;

const

  SHCONTCH_NOPROGRESSBOX    = $4;
  SHCONTCH_RESPONDYESTOALL  = $10;

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

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if (PageId = wpFinished) then
     result := (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolAutoOBETZ}')) = false);

  if (PageID = wpInfoAfter) then
    result := (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolManual}')) = false);
end;

function OBetzInstaller(const Path: string): string;
begin
  result := Path;
  if (result <> '') then
    result := result + '\';
  result := result + OBETZINSTALL + '_' + ETVer +  ExpandConstant('{#ETPlatform}') + EXE
end;

function GetCurrentVersion(const VersionUrl: string): AnsiString;
var
  Version_file: string;
  P: integer;
begin
  // First get Version to download. Dont show in Download page. Only a few bytes!
  if (DownloadTemporaryFile(VersionUrl, VER_TXT, '' , @OnDownloadProgress) = 0) then
    RaiseException('Could not download ' + VER_TXT);

  // Read version in variable ETver
  Version_file := ExpandConstant('{tmp}\' + VER_TXT);
  if not (LoadStringFromFile(Version_file, result)) then
    RaiseException('Could not read ' + VER_TXT);
  P := Pos(#13, result);
  if (P > 0) then
    result := Copy(result, 1, P -1); // Line is terminated with CR(LF)
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
  ETVer := GetCurrentVersion(OBETZURL + OBETZVER);
  ETFile := OBETZURL + OBetzInstaller('');

  result := ShowDownLoadPage(ETFile, OBetzInstaller(''));
end;

function DownloadETPH: boolean;
begin
  ETVer := GetCurrentVersion(PHURL + VER_TXT);
  ETFile := PHURL + ET + '-' + ETVer + ZIP;

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

  if (CurPageID = wpReady) then
  begin
    if (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolAutoOBETZ}'))) then
      result := DownLoadETOBetz
    else if (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolAutoPH}'))) then
      result := DownLoadETPH;
  end;

end;


