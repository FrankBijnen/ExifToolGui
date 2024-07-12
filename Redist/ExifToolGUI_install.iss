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
#define DownloadGeoDB "DownloadGeoDB" 
#define DownloadGeoDBDesc "Download alternate (larger) GeoLocation database."
#define GeoLocationDir "Geolocation500"
;
#define AddToPath "AddToPath"

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
;Change compression to zip? An effort to please Windows Defender.
Compression=lzma2/normal
LZMANumBlockThreads=16
LZMAUseSeparateProcess=yes
;Compression=zip/9
SolidCompression=no
RestartIfNeededByRun=no
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
SetupIconFile=ExifToolGUI.ico
WizardSmallImageFile=ExifToolGUI.Bmp
DisableProgramGroupPage=yes
LicenseFile=License.rtf
; Will be overriden
InfoAfterFile=InfoDownload.rtf
ChangesEnvironment=true

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
Name: {#AddToPath};                     Description: "Add ExiftoolGUI to PATH"; \
                                          GroupDescription: "Environment";
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

Name: {#DownloadGeoDB};                 Description: "{#DownloadGeoDBDesc}";  \
                                          GroupDescription: "Optional downloads"; \
                                                                                              Flags: unchecked;
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
Source: "..\Translation\ExifToolGui_X64.CHS"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.DEU"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.ENU"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.ESP"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.FRA"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.ITA"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.NLD"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;
Source: "..\Translation\ExifToolGui_X64.PTB"; DestDir: "{app}";   Components: LanguagesWin64; flags: replacesameversion;

Source: "..\Translation\ExifToolGui.CHS";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.DEU";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.ENU";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.ESP";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.FRA";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.ITA";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.NLD";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;
Source: "..\Translation\ExifToolGui.PTB";     DestDir: "{app}";   Components: LanguagesWin32; flags: replacesameversion;

; These files will be downloaded
Source: "{tmp}\curver.txt";             DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;
Source: "{code:EtZipFile|{tmp}}\*";     DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion recursesubdirs;
Source: "{code:OBetzInstaller|{tmp}}";  DestDir: "{app}";                                     flags: external skipifsourcedoesntexist replacesameversion;
Source: "{tmp}\{#GeolocationDir}\*";    DestDir: "{code:GeoLocationDir}";                     flags: external skipifsourcedoesntexist replacesameversion recursesubdirs;

[Icons]
Name: "{group}\{#ExifToolGUI}";         Filename: "{app}\{#ExifToolGUIExeName}"
Name: "{userdesktop}\{#ExifToolGUI}";   Filename: "{app}\{#ExifToolGUIExeName}";              tasks: desktopicon;

[run]
Filename: "{code:OBetzInstaller|{app}}";Description: {code:InstallOBetzMsg};                  flags: postinstall skipifdoesntexist waituntilterminated; StatusMsg: "Installing ExifTool"; \
  Check: OBetzSelected;

[Code]

var

  DownloadPageET: TDownloadWizardPage;
  GeoLocationDirPage: TInputDirWizardPage;
  CURVer: AnsiString;
  ETVerPH: AnsiString;
  ETVerOBetz: AnsiString;
  ETFile: AnsiString;
  AlternateDBVer: AnsiString;
  DBFile: AnsiString;

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
  GEODBVER                  = 'geo.txt';
  EXIFTOOL_FILES            = '\exiftool_files';


const 
  RootKeyAdmin = HKEY_LOCAL_MACHINE;
  EnvironmentKeyAdmin = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
  RootKeyNonAdmin = HKEY_CURRENT_USER;
  EnvironmentKeyNonAdmin = 'Environment';

procedure SetRegKey(var RootKey: integer; var EnvironmentKey: string);
begin
  if (IsAdminInstallMode) then
  begin
    RootKey := RootKeyAdmin;
    EnvironmentKey := EnvironmentKeyAdmin;
  end
  else
  begin
    RootKey := RootKeyNonAdmin;
    EnvironmentKey := EnvironmentKeyNonAdmin;
  end;
end;

function AddSemiColons(Paths: string; Prefix, Suffix: boolean): string;
var 
  L: integer;
begin
  result := Paths;
  L := Length(result);
  if (L > 0) then
  begin
    if (Suffix) and
       (Copy(result, L, 1) <> ';') then
      result := result + ';';
    if (Prefix) and
       (Copy(result, 1, 1) <> ';') then
      result := ';' + result;
  end;    
end;
  
function RemoveSemiColons(Paths: string; Prefix, Suffix: boolean): string;
var 
  L: integer;
begin
  result := Paths;
  L := Length(result);
  if (L > 0) then
  begin
    if (Suffix) and
       (Copy(result, L, 1) = ';') then
      Delete(result, L, 1);
    if (Prefix) and
       (Copy(result, 1, 1) = ';') then
      Delete(result, 1, 1);
  end;    
end;  

procedure EnvAddPath(Path: string);
var
  RootKey: integer;
  EnvironmentKey: string;
  OrigPaths: string;
  Paths: string;
  NewPath: string;
begin
  SetRegKey(RootKey, EnvironmentKey);
  
  { Retrieve current path (use empty string if entry not exists) }
  if not RegQueryStringValue(RootKey, EnvironmentKey, 'Path', OrigPaths) then
    OrigPaths := '';
  Paths := AddSemiColons(OrigPaths, true, true);
  NewPath := AddSemiColons(Path, true, true);
  
  { Skip if string already found in path }
  if Pos(Uppercase(NewPath), Uppercase(Paths)) > 0 then 
    exit;

  { App string to the end of the path variable }
  Paths := AddSemiColons(OrigPaths, false, true) + Path;
  
  { Overwrite (or create if missing) path environment variable }
  if not RegWriteStringValue(RootKey, EnvironmentKey, 'Path', Paths) then
    Log(Format('Error while adding the [%s] to PATH: [%s]', [Path, Paths]));
end;

procedure EnvRemovePath(Path: string);
var
  Rootkey: integer;
  EnvironmentKey: string;
  OrigPaths: string;
  Paths: string;
  OldPath: string;
  P: Integer;
begin
  SetRegKey(RootKey, EnvironmentKey);
  
  { Skip if registry entry not exists }
  if not RegQueryStringValue(RootKey, EnvironmentKey, 'Path', OrigPaths) then
    exit;
  Paths := AddSemiColons(OrigPaths, true, true);  
  OldPath := AddSemiColons(Path, true, true);  

  { Skip if string not found in path }
  P := Pos(Uppercase(OldPath), Uppercase(Paths));
  if (P = 0) then
    exit;
    
  Delete(Paths, P, Length(OldPath) -1);
  Paths := RemoveSemiColons(Paths, true, true); // Remove unwanted ;
  
  { Overwrite path environment variable }
  if not RegWriteStringValue(RootKey, EnvironmentKey, 'Path', Paths) then
    Log(Format('Error while removing the [%s] from PATH: [%s]', [Path, Paths]));
end;

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

function AddToPathSelected: boolean;
begin
  result := (WizardIsTaskSelected(ExpandConstant('{#AddToPath}')));
end;

function ObetzSelected: boolean;
begin
  result := (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolAutoOBETZ}')));
end;

function PHSelected: boolean;
begin
  result := (WizardIsTaskSelected(ExpandConstant('{#DownloadExifToolAutoPH}')));
end;

function AltDbSelected: boolean;
begin
  result := (WizardIsTaskSelected(ExpandConstant('{#DownloadGeoDB}')));
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
    if (WizardForm.TasksList.ItemCaption[I] = ExpandConstant('{#DownloadGeoDBDesc}')) then
    begin
      if (AlternateDBVer = '') then
        AlternateDBVer := GetCurrentVersion(PHURL + GEODBVER);
      WizardForm.TasksList.ItemCaption[I] := WizardForm.TasksList.ItemCaption[I] + ' Available: ' + AlternateDBVer;
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
  AlternateDBVer := '';

  WizardForm.TasksList.OnClickCheck := @TaskOnClick;

end;

function GeoLocationDir(const Param: string):string;
begin
  result := ExpandConstant('{app}\{#GeoLocationDir}');
  if (GeoLocationDirPage <> nil) then
    result := GeoLocationDirPage.Values[0];
end;

procedure SetupRichText;
var RTFText: string;
    GeoDir: string;
begin
  // RTF Header
  RTFText := 
      '{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}{\f1\fnil\fcharset0 Courier New;}}' + #13 + #10 +
      '{\colortbl ;\red0\green0\blue255;}' + #13 + #10 +
      '{\*\generator Riched20 10.0.19041}\viewkind4\uc1 ' + #13 + #10; 

  if (PHSelected = false) and (OBetzSelected = false) then
    RTFText := RTFText + //InfoDownload.rtf
      '\pard\b\sl240\slmult1\f0\fs22\lang9 You can download ExifTool here: \b0\par' + #13 + #10
      + #13 + #10
      '\pard{\pntext\f1\''B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\''B7}}\fi-360\li720\sl276\slmult1 The original version by Phil Harvey: \par' + #13 + #10 +
      + #13 + #10
      '\pard\sl276\slmult1\tab {{\field{\*\fldinst{HYPERLINK https://exiftool.org/ }}{\fldrslt{https://exiftool.org/\ul0\cf0}}}}\f0\fs22\par' + #13 + #10 +
      + #13 + #10
      '\pard{\pntext\f1\''B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\''B7}}\fi-360\li720\sl276\slmult1 An installer provider by Oliver Betz:\par' + #13 + #10 +
      + #13 + #10
      '\pard\sl276\slmult1\tab {{\field{\*\fldinst{HYPERLINK https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows }}{\fldrslt{https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows\ul0\cf0}}}}\f0\fs22\par' + #13 + #10 +
      '\par' + #13 + #10;
  
  if AltDbSelected then
  begin
    // Escape \ in Directory
    GeoDir := GeoLocationDir('');
    StringChangeEx(Geodir, '\', '\\', true);   
     
    RTFText := RTFText + // InfoAlternateDB.rtf
      '\pard\b\sl276\slmult1\f0\fs22\lang9 The GeoLocation DB has been installed in: \b0\par' + #13 + #10 + 
      '\tab\f1\fs18 ' + GeoDir + '\f0\fs22\par' + #13 + #10 +
      '\par' + #13 + #10 +
      'If ExifToolGui does not select it automatically, you can select the folder in Preferences.\par' + #13 + #10 +
      '\par' + #13 + #10 +
      'If you wish to use it in ExifTool create, or update, a config file with this line: \par' + #13 + #10 + 
      '\tab\f1\fs18 $Image::ExifTool::Geolocation::geoDir = ''<DIR>'';\fs22\par' + #13 + #10 +
      '\par' + #13 + #10 +
      '\pard\sl276\slmult1\f0 For more info see: {{\field{\*\fldinst{HYPERLINK https://exiftool.org/geolocation.html }}{\fldrslt{https://exiftool.org/geolocation.html\ul0\cf0}}}}\f0\fs22\par' + #13 + #10 +
      '\par' + #13 + #10;
  end;
  
  RTFText := RTFText + // InfoRawCodec.rtf
    '\pard\b\sl276\slmult1\f0\fs22\lang9 If you wish to see thumbnails of raw image files \b0, you will need to install a codec adapted for the RAW files you use. ' + 
    'FastPictureViewer provides free codecs for personal use: \par\tab {{\field{\*\fldinst{HYPERLINK https://www.fastpictureviewer.com/codecs/ }}{\fldrslt{https://www.fastpictureviewer.com/codecs/\ul0\cf0}}}}\f0\fs22\par' + #13 + #10;

  RichEditViewer1.RTFText := RTFText + '}' + #13 + #10;
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

function ETZipFile(const Path: string): string;
begin
  result := Path;
  if (result <> '') then
    result := result + '\';
  result := result + ET + '-' + ETVerPH + ExpandConstant('{#ETPlatform}');
end;

function OBetzInstaller(const Path: string): string;
begin
  result := Path;
  if (result <> '') then
    result := result + '\';
  result := result + OBETZINSTALL + '_' + ETVerOBetz +  ExpandConstant('{#ETPlatform}') + EXE;
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

function AlternateDB(const Path: string): string;
begin
  result := Path;
  if (result <> '') then
    result := result + '\';
  result := result + AlternateDBVer;
end;

// Show in Download page
function ShowDownLoadPage(const Remote, Local, Msg1, Msg2: string): boolean;
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
    if (Msg1 <> '') or
       (Msg2 <> '') then
      DownLoadPageET.SetText(Msg1, Msg2)
    else    
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
  result := ShowDownLoadPage(ETFile, OBetzInstaller(''), '', '');
end;

function DownloadETPH: boolean;
var
  ETDir: AnsiString;
begin
  ETFile := PHURL + ETZipFile('') + ZIP;
  if (NeverDownload) then
  begin
    result := true;
    exit;
  end;

  result := ShowDownLoadPage(ETFile, ET + ZIP, 'Unzipping', ETFile);
  try
    if (result) then
    begin
      // These operations all take place in TMP folder.
      result := false; // In case actions in TMP folder should fail

      // Unzip Exiftool(-k).exe in app folder and rename to exiftool.exe
      unzip(ExpandConstant('{tmp}\' + ET + ZIP), ExpandConstant('{tmp}'));

      // unzip has no result. Check if file exists.
      ETDir := ETZipFile(ExpandConstant('{tmp}')) + '\';
      if not FileExists(ETDir + ET_K + EXE) then
        RaiseException('Unzipping ' + ETDir + ZIP + ' failed');

      // Rename
      if not RenameFile(ETDir + ET_K + EXE,  ETDir + ET + EXE) then
        RaiseException('Rename to ' +  ET + EXE + ' failed');

      result := true;
    end;
  finally  
    DownloadPageET.Hide;
  end;  
end;

function DownloadAltDb: boolean;
begin
  DBFile := PHURL + AlternateDB('');
  if (NeverDownload) then
  begin
    result := true;
    exit;
  end;

  result := ShowDownLoadPage(DBFile, AlternateDB(''), 'Unzipping', DBFile);
  try
    if (result) then
    begin

      // These operations all take place in TMP folder.
      result := false; // In case actions in TMP folder should fail

      // Unzip Exiftool(-k).exe in app folder and rename to exiftool.exe
      unzip(AlternateDB(ExpandConstant('{tmp}')), ExpandConstant('{tmp}'));

      // unzip has no result. Check if file exists.
      if not DirExists(ExpandConstant('{tmp}\{#GeoLocationDir}')) then
        RaiseException('Unzipping ' + ExpandConstant('{tmp}\{#GeoLocationDir}') + ' failed');

       result := true;
    end;
  finally
    DownloadPageET.Hide;
  end;  
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ExifTool_Files_Dir: AnsiString;
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

    if ((PHSelected) and
        (CurVer <> CURVER_UNAVAIL) and
        (CurVer <> ETVERPH)) then
    begin    
      ExifTool_Files_Dir := ExpandConstant('{app}') + EXIFTOOL_FILES;
      if (DirExists(ExifTool_Files_Dir)) then
      begin
        if (MsgBox('You are upgrading ExifTool to a newer version. Delete existing ExifTool_files found first?' + #10 + #10 +
                   ExifTool_Files_Dir,
                   mbConfirmation, MB_YESNO) = IDYES) then
          DelTree(ExifTool_Files_Dir, true, true, true);
      end;
    end;    

    if (AltDbSelected) then
    begin
      GeoLocationDirPage := CreateInputDirPage(wpSelectTasks, 
                              'Select directory for GeoLocation', 
                              'Note: If you dont accept the default value you have to setup the directory in ExifToolGui/Preferences/GeoCoding',
                              '', False, '');
      GeoLocationDirPage.Add('Directory:');
      GeoLocationDirPage.Values[0] := ExpandConstant('{app}\{#GeoLocationDir}');
    end;
  end;

  if (CurPageID = wpReady) then
  begin
    if OBetzSelected then
      result := DownLoadETOBetz
    else if PHSelected then
      result := DownLoadETPH;
    if AltDbSelected then
      result := DownloadAltDb;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep = ssPostInstall) and
     (AddToPathSelected) then 
    EnvAddPath(ExpandConstant('{app}'));
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
    EnvRemovePath(ExpandConstant('{app}'));
end;
