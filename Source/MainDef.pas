unit MainDef;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses System.Classes, ExifTool, GEOMap, UnitLangResources;

const
  SHOWALL = 'Show All Files';

type
  GUIsettingsRec = record
    Language: string[7];
    AutoRotatePreview: boolean;
    DefStartupUse: boolean;
    DefStartupDir: string;
    DefExportUse: boolean;
    DefExportDir: string;
    ThumbSize: smallint;
    ThumbAutoGenerate: boolean;
    ThumbCleanSet: string[4];
    UseExitDetails: boolean;
    AutoIncLine: boolean;
    DblClickUpdTags: boolean;
    EnableGMap: boolean;
    DefGMapHome: string[23];
    GuiStyle: string;
    ETdirDefCmd: smallint;
    ETdirMode: smallint;
    InitialDir: string;
    ETOverrideDir: string;
    ETCustomConfig: string;
    ETTimeOut: integer;
  // Colors of the Bar charts. Not configurable in UI
    CLFNumber: integer;
    CLFocal: integer;
    CLISO: integer;

    ShowFolders: boolean;
    ShowHidden: boolean;
    EnableUnsupported: boolean;
    ShowBreadCrumb: boolean;
    MinimizeToTray: boolean;
    SingleInstanceApp: boolean;
    ShowBalloon: boolean;
    function CanShowHidden: boolean;
    function GetCustomConfig: string;
  end;

  FListColUsrRec = record
    Caption: string;
    Command: string;
    Width: smallint;
    AlignR: smallint;
  end;

  FListColDefRec = record
    Caption: PResStringRec;
    Width: smallint;
    AlignR: smallint;
  end;

  QuickTagRec = record
    Caption: string;
    Command: string;
    Help: string;
    NoEdit: boolean;
  end;

var
  FListStdColWidth: array [0 .. 3] of smallint; // [Filename][Size][Type][Date modified]

  // Note: Default widths are in ReadGui
  // Captions will be loaded at runtime from resourcestrings
  FListColDef1: array [0 .. 7] of FListColDefRec = (
    (
      Caption: @StrFLExpTime; AlignR: 6), (Caption: @StrFLFNumber; AlignR: 4), (Caption: @StrFLISO; AlignR: 5), (Caption: @StrFLExpComp; AlignR: 4),
    (Caption: @StrFLFLength; AlignR: 8), (Caption: @StrFLFlash; AlignR: 0), (Caption: @StrFLExpProgram; AlignR: 0), (Caption: @StrFLOrientation; AlignR: 0));

  FListColDef2: array [0 .. 5] of FListColDefRec = (
    (
      Caption: @StrFLDateTime; AlignR: 0), (Caption: @StrFLGPS; AlignR: 0), (Caption: @StrFLCountry; AlignR: 0), (Caption: @StrFLProvince; AlignR: 0),
    (Caption: @StrFLCity; AlignR: 0), (Caption: @StrFLLocation; AlignR: 0));

  FListColDef3: array [0 .. 4] of FListColDefRec = (
    (
      Caption: @StrFLArtist; AlignR: 0), (Caption: @StrFLRating; AlignR: 0), (Caption: @StrFLType; AlignR: 0), (Caption: @StrFLEvent; AlignR: 0),
    (Caption: @StrFLPersonInImage; AlignR: 0));

  FListColUsr: array of FListColUsrRec;

  GUIsettings: GUIsettingsRec;
  ETdirectCmd: TStringList;
  QuickTags: array of QuickTagRec;
  MarkedTags: string;
  CustomViewTags: string;
  GpsXmpDir: string = '';
  WrkIniDir: string = '';
  DontSaveIni: boolean;

function GetIniFilePath(AllowPrevVer: boolean): string;
procedure ReadGUILog;
function ReadSingleInstanceApp: boolean;
procedure ResetWindowSizes;
procedure ReadGUIini;
procedure SaveGUIini;
function LoadWorkspaceIni(IniFName: string): boolean;
function SaveWorkspaceIni(IniFName: string): boolean;
function BrowseFolderDlg(const Title: string; iFlag: integer; const StartFolder: string = ''): string;
procedure ChartFindFiles(StartDir, FileMask: string; subDir: boolean);

implementation

uses System.SysUtils, System.StrUtils, System.IniFiles,
  Winapi.Windows, Winapi.ShellAPI, Winapi.ShlObj,
  Vcl.Forms, Vcl.ComCtrls, Vcl.Dialogs,
  Main, LogWin, ExifToolsGUI_Utils, ExifInfo;

const
  CRLF = #13#10;
  Ini_ETGUI = 'ExifToolGUI';
  Ini_Settings = 'GUIsettings';
  Ini_Options = 'EToptions';
  IniVersion = 'V6';
  PrevIniVersion = 'V5';
  WorkSpaceTags = 'WorkSpaceTags';

var
  GUIini: TMemIniFile;
  lg_StartFolder: string;

  // This function returns the name of the INI file.
  // If it doesn't exist, but a previous version exists it returns that name.
function GetIniFilePath(AllowPrevVer: boolean): string;
var
  CurVer, PrevVer, PrevPath: string;
begin
  // Default is ExifToolGuiV6.ini in Profile %AppData%\ExifToolGui
  CurVer := Application.Title + IniVersion + '.ini';
  result := GetINIPath(not AllowPrevVer) + CurVer;
  if (FileExists(result)) then
    exit;

  // Allow import of previous version. Used when reading ini file
  if not AllowPrevVer then
    exit;

  PrevVer := Application.Title + PrevIniVersion + '.ini';
  // Maybe in AppDir V6 ?
  PrevPath := GetAppPath + CurVer;
  if (FileExists(PrevPath)) then
    exit(PrevPath);

  // Maybe in AppDir V5 ?
  PrevPath := GetAppPath + PrevVer;
  if (FileExists(PrevPath)) then
    exit(PrevPath);

  // If we get here, the default result is returned.
end;

function GUIsettingsRec.CanShowHidden: boolean;
begin
  result := (ShowHidden and IsAdminUser) or IsElevated;
end;

function GUIsettingsRec.GetCustomConfig: string;
begin
  result := '';
  if (ETCustomConfig <> '') then
    result := Format('-config "%s"', [ETCustomConfig]);
end;

function SetQuickTag(const AIndex: integer; const ACaption, ACommand: string; const AHelp: string = ''): integer;
begin
  result := AIndex +1;

  // Resize Array?
  if (result > Length(QuickTags)) then
    SetLength(QuickTags, result);

  QuickTags[AIndex].Caption := ACaption;
  QuickTags[AIndex].Command := ACommand;
  QuickTags[AIndex].Help := AHelp;

  // Set NoEdit
  QuickTags[AIndex].NoEdit := (RightStr(ACaption, 1) = '?');
  QuickTags[AIndex].NoEdit := QuickTags[result -1].NoEdit or
                             (UpperCase(LeftStr(ACommand, 4)) = '-GUI');

end;

procedure ReadWorkSpaceTags(GUIini: TMemIniFile);
var
  Indx, WSCnt: integer;
  Name, Cmd, Help : string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.ReadSectionValues(WorkSpaceTags, TmpItems);
    WSCnt := TmpItems.Count;
    SetLength(QuickTags, WSCnt);

    if (WSCnt = 0) and
       (GUIini.SectionExists(WorkSpaceTags) = false) then
    begin
      WSCnt :=  SetQuickTag(WSCnt, 'EXIF', '-GUI-SEP');
      WSCnt :=  SetQuickTag(WSCnt, 'Make', '-exif:Make');
      WSCnt :=  SetQuickTag(WSCnt, 'Model', '-exif:Model');
      WSCnt :=  SetQuickTag(WSCnt, 'LensModel', '-exif:LensModel');
      WSCnt :=  SetQuickTag(WSCnt, 'ExposureTime', '-exif:ExposureTime', '[1/50] or [0.02]');
      WSCnt :=  SetQuickTag(WSCnt, 'FNumber', '-exif:FNumber');
      WSCnt :=  SetQuickTag(WSCnt, 'ISO', '-exif:ISO');
      WSCnt :=  SetQuickTag(WSCnt, 'FocalLength', '-exif:FocalLength', '[28] -mm not necessary');
      WSCnt :=  SetQuickTag(WSCnt, 'Flash#', '-exif:Flash', '[ 0 ]=No flash, [ 1 ]=Flash fired');
      WSCnt :=  SetQuickTag(WSCnt, 'Orientation#', '-exif:Orientation', '[ 1 ]=0°, [ 3 ]=180°, [ 6 ]=+90°, [ 8 ]=-90°');
      WSCnt :=  SetQuickTag(WSCnt, 'DateTimeOriginal', '-exif:DateTimeOriginal', '[2012:01:14 20:00:00]');
      WSCnt :=  SetQuickTag(WSCnt, 'CreateDate', '-exif:CreateDate', '[2012:01:14 20:00:00]');
      WSCnt :=  SetQuickTag(WSCnt, 'Artist*', '-exif:Artist', 'Bogdan Hrastnik');
      WSCnt :=  SetQuickTag(WSCnt, 'Copyright', '-exif:Copyright', 'Use Alt+0169 to get © character');
      WSCnt :=  SetQuickTag(WSCnt, 'Software', '-exif:Software');
      WSCnt :=  SetQuickTag(WSCnt, 'Geotagged?', '-Gps:GPSLatitude');

      WSCnt :=  SetQuickTag(WSCnt, 'About photo', '-GUI-SEP');
      WSCnt :=  SetQuickTag(WSCnt, 'Type±', '-xmp-dc:Type', '[Landscape] or [Studio+Portrait] ..');
      WSCnt :=  SetQuickTag(WSCnt, 'Rating', '-xmp-xmp:Rating', 'Integer value [ 0 ] .. [ 5 ]');

      WSCnt :=  SetQuickTag(WSCnt, 'Event', '-xmp-iptcExt:Event', '[Vacations] or [Trip] ..');
      WSCnt :=  SetQuickTag(WSCnt, 'PersonInImage±', '-xmp:PersonInImage', '[Phil] or [Harry+Sally] or [-Peter] ..');
      WSCnt :=  SetQuickTag(WSCnt, 'Keywords±', '-xmp-dc:Subject', '[tree] or [flower+rose] or [-fish] or [+bird-fish] ..');
      WSCnt :=  SetQuickTag(WSCnt, 'Country', '-xmp:LocationShownCountryName');
      WSCnt :=  SetQuickTag(WSCnt, 'Province', '-xmp:LocationShownProvinceState');
      WSCnt :=  SetQuickTag(WSCnt, 'City', '-xmp:LocationShownCity');
                SetQuickTag(WSCnt, 'Location', '-xmp:LocationShownSublocation');
    end
    else
    begin
      for Indx := 0 to WSCnt - 1 do
      begin
        Help :=  TmpItems[Indx];
        Name := NextField(Help, '=');
        Cmd := NextField(Help, '^');
        SetQuickTag(Indx, Name, Cmd, Help);
      end;
    end;
 finally
    TmpItems.Free;
  end;
end;

// Writing the workspace tags this way allows duplicate tag names.
// Not what's intended by MS, but hey....
procedure WriteWorkSpaceTags(GUIini: TMemIniFile);
var
  Indx: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.
    TmpItems.Add(Format('[%s]', [WorkSpaceTags]));
    for Indx := 0 to Length(QuickTags) - 1 do
    begin
      Tx := Format('%s=%s^%s', [QuickTags[Indx].Caption, QuickTags[Indx].Command, QuickTags[Indx].Help]);
      TmpItems.Add(Tx);
    end;
    GUIini.SetStrings(TmpItems);
  finally
    TmpItems.Free;
  end;
end;

procedure ReadMainWindowSizes(const AIniFile: TMemIniFile);
var
  N: integer;
begin
  with AIniFile, FMain do
  begin
    // First do the Panels
    AdvPanelBrowse.Width := ReadInteger(Ini_ETGUI, 'BrowseWidth', ScaleDesignDpi(240));
    AdvPagePreview.Height := ReadInteger(Ini_ETGUI, 'PreviewHeight', 220);
    AdvPageMetadata.Width := ReadInteger(Ini_ETGUI, 'MetadataWidth', ScaleDesignDpi(322));
    MetadataList.ColWidths[0] := ReadInteger(Ini_ETGUI, 'MetadataTagWidth', ScaleDesignDpi(144));

    FListStdColWidth[0] := ReadInteger(Ini_ETGUI, 'StdColWidth0', 200);
    FListStdColWidth[1] := ReadInteger(Ini_ETGUI, 'StdColWidth1', 88);
    FListStdColWidth[2] := ReadInteger(Ini_ETGUI, 'StdColWidth2', 80);
    FListStdColWidth[3] := ReadInteger(Ini_ETGUI, 'StdColWidth3', 120);

    // Column widths Camera settings
    FListColDef1[0].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth0', 64);
    FListColDef1[1].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth1', 64);
    FListColDef1[2].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth2', 48);
    FListColDef1[3].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth3', 73);
    FListColDef1[4].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth4', 73);
    FListColDef1[5].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth5', 56);
    FListColDef1[6].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth6', 88);
    FListColDef1[7].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth7', 80);

    // Column widths Location info
    FListColDef2[0].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth0', 120);
    FListColDef2[1].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth1', 48);
    FListColDef2[2].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth2', 80);
    FListColDef2[3].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth3', 80);
    FListColDef2[4].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth4', 120);
    FListColDef2[5].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth5', 120);

    // Column widths About photo
    FListColDef3[0].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth0', 120);
    FListColDef3[1].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth1', 48);
    FListColDef3[2].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth2', 120);
    FListColDef3[3].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth3', 120);
    FListColDef3[4].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth4', 120);

    // When the panels have been resized, we can resize the Main Form.
    // The constraints of the panels, and or the minsize of the splitters, can prevent resizing the main form
    N := 0;
    if WindowState = wsMaximized then
      inc(N); // check shortcut setting
    if ReadBool(Ini_ETGUI, 'StartMax', false) then
      inc(N);
    Top := ReadInteger(Ini_ETGUI, 'WinTop', 40);
    Left := ReadInteger(Ini_ETGUI, 'WinLeft', 60);
    Width := ReadInteger(Ini_ETGUI, 'WinWidth', 1024);
    Height := ReadInteger(Ini_ETGUI, 'WinHeight', 660);
    if N > 0 then
      WindowState := wsMaximized;
  end;
end;

procedure ReadLogWindowSizes(const AIniFile: TMemIniFile);
begin
  with AIniFile, FLogWin do
  begin
    Top := ReadInteger(Ini_ETGUI, 'LogWinTop', 106);
    Left := ReadInteger(Ini_ETGUI, 'LogWinLeft', 108);
    Width := ReadInteger(Ini_ETGUI, 'LogWinWidth', ScaleDesignDpi(580));
    Height := ReadInteger(Ini_ETGUI, 'LogWinHeight', ScaleDesignDpi(580));
  end;
end;

procedure ReadGUIini;
var
  I, N, X: integer;
  Tx, DefaultDir: string;
  TmpItems: TStringList;
begin
  try
    GUIini := TMemIniFile.Create(GetIniFilePath(True), TEncoding.UTF8);
  except
    // Ini saved in Ansi?
    GUIini := TMemIniFile.Create(GetIniFilePath(True));
  end;

  TmpItems := TStringList.Create;
  try
    with GUIini, FMain do
    begin
      DefaultDir := ReadString(Ini_ETGUI, 'DefaultDir', 'c:\');
      if (ValidDir(DefaultDir)) then
        GUIsettings.InitialDir := DefaultDir;

      ReadMainWindowSizes(GUIini);

      with GUIsettings do
      begin
        Language := ReadString(Ini_Settings, 'Language', '');
        ET_Options.ETLangDef := Language + CRLF;;
        if Language = '' then
          ET_Options.ETLangDef := '';
        AutoRotatePreview := ReadBool(Ini_Settings, 'AutoRotatePreview', false);
        Tx := ReadString(Ini_Settings, 'FileFilters', '*.JPG|*.CR2|*.JPG;*.CR2|*.JPG;*.DNG|*.JPG;*.PEF');
        CBoxFileFilter.Items.Text := SHOWALL;
        repeat
          I := pos('|', Tx);
          if I > 0 then
          begin
            CBoxFileFilter.Items.Append(LeftStr(Tx, I - 1));
            Delete(Tx, 1, I);
          end
          else
            CBoxFileFilter.Items.Append(Tx);
        until I = 0;
        DefStartupUse := ReadBool(Ini_Settings, 'DefStartupUse', false);
        DefStartupDir := ReadString(Ini_Settings, 'DefStartupDir', 'c:\');
        if DefStartupUse and ValidDir(DefStartupDir) then
          GUIsettings.InitialDir := DefStartupDir;
        GUIsettings.ETOverrideDir := ReadString(Ini_Settings, 'ETOverrideDir', '');
        GUIsettings.ETCustomConfig := ReadString(Ini_Settings, 'ETCustomConfig', '');
        // Note: Not configurable by user, only in INI
        GUIsettings.ETTimeOut := ReadInteger(Ini_Settings, 'ETTimeOut', 5000);
        DefExportUse := ReadBool(Ini_Settings, 'DefExportUse', false);
        DefExportDir := ReadString(Ini_Settings, 'DefExportDir', '');
        ThumbSize := ReadInteger(Ini_Settings, 'ThumbsSize', 0);
        case ThumbSize of
          0:
            I := 96;
          1:
            I := 128;
          2:
            I := 160;
        else
          I := 96;
        end;
        FMain.ShellList.ThumbNailSize := I;
        ThumbAutoGenerate := ReadBool(Ini_Settings, 'ThumbAutoGenerate', True);
        FMain.ShellList.ThumbAutoGenerate := ThumbAutoGenerate;
        ThumbCleanSet := ReadString(Ini_Settings, 'ThumbCleanSet', '0000');

        EnableGMap := ReadBool(Ini_Settings, 'EnableGMap', false);
        DefGMapHome := ReadString(Ini_Settings, 'DefGMapHome', '46.55738,15.64608');
        if (pos('.', DefGMapHome) = 0) or (pos(',', DefGMapHome) = 0) then
          DefGMapHome := '46.55738,15.64608';
        GuiStyle := ReadString(Ini_Settings, 'GUIStyle', 'Silver');
        UseExitDetails := ReadBool(Ini_Settings, 'UseExitDetails', false);
        if UseExitDetails then
        begin
          FMain.CBoxDetails.ItemIndex := ReadInteger(Ini_Settings, 'DetailsSel', 0);
          FMain.SpeedBtnDetails.Down := ReadBool(Ini_Settings, 'DetailsDown', True);
        end;
        AutoIncLine := ReadBool(Ini_Settings, 'AutoIncLine', True);
        DblClickUpdTags := ReadBool(Ini_Settings, 'DblClickUpdTags', False);
        ETdirDefCmd := ReadInteger(Ini_Settings, 'ETdirDefCmd', -1);
        ETdirMode := ReadInteger(Ini_Settings, 'ETdirMode', 0);
        CmbETDirectMode.ItemIndex := GUIsettings.ETdirMode;
        // Colors of the Bar charts. Only editable in INI file
        TryStrToInt(ReadString(Ini_Settings, 'CLFnumber', '$C0DCC0'), CLFnumber);
        TryStrToInt(ReadString(Ini_Settings, 'CLFocal', '$FFDAB6'), CLFocal);
        TryStrToInt(ReadString(Ini_Settings, 'CLISO', '$D0D0D0'), CLISO);

        ShowFolders := ReadBool(Ini_Settings, 'ShowFolders', false);
        ShowHidden := ReadBool(Ini_Settings, 'ShowHidden', false);
        EnableUnsupported := ReadBool(Ini_Settings, 'EnableUnsupported', false);
        ShowBreadCrumb := ReadBool(Ini_Settings, 'ShowBreadCrumb', true);
        MinimizeToTray := ReadBool(Ini_Settings, 'MinimizeToTray', false);
        SingleInstanceApp := ReadBool(Ini_Settings, 'SingleInstanceApp', false);
        ShowBalloon := ReadBool(Ini_Settings, 'ShowBalloon', true);

        Application.HintHidePause := ReadInteger(Ini_Settings, 'HintHidePause', 5000);
      end;

      with ET_Options do
      begin
        MaDontBackup.Checked := ReadBool(Ini_Options, 'DontBackup', True);
        if not MaDontBackup.Checked then
          ETBackupMode := '';
        MaPreserveDateMod.Checked := ReadBool(Ini_Options, 'PreserveDateMod', false);
        if MaPreserveDateMod.Checked then
          ETFileDate := '-P' + CRLF;
        ETSeparator := '-sep' + CRLF + ReadString(Ini_Options, 'KeySeparator', '*') + CRLF;
        MaIgnoreErrors.Checked := ReadBool(Ini_Options, 'IgnoreErrors', false);
        if MaIgnoreErrors.Checked then
          ETMinorError := '-m' + CRLF;
        MaShowGPSdecimal.Checked := ReadBool(Ini_Options, 'GPSinDecimal', True);
        ET_Options.SetGpsFormat(MaShowGPSdecimal.Checked);
        MaShowSorted.Checked := ReadBool(Ini_Options, 'ShowSorted', false);
        MaShowComposite.Checked := ReadBool(Ini_Options, 'ShowComposite', false);
        MaNotDuplicated.Checked := ReadBool(Ini_Options, 'NotDuplicated', false);
        MaAPIWindowsWideFile.Checked := ReadBool(Ini_Options, 'APIWindowsWideFile', true);
        SetApiWindowsWideFile(MaAPIWindowsWideFile.Checked);
        MaAPILargeFileSupport.Checked := ReadBool(Ini_Options, 'APILargeFileSupport', false);
        SetApiLargeFileSupport(MaAPILargeFileSupport.Checked);
        SetCustomOptions(ReadString(Ini_Options, 'CustomOptions', ''));
      end;

      // Custom FList columns
      ReadSectionValues('FListUserDefColumn', TmpItems);
      I := TmpItems.Count;
      if I > 0 then
      begin
        SetLength(FListColUsr, I);
        for N := 0 to I - 1 do
          with FListColUsr[N] do
          begin
            Tx := TmpItems[N];
            X := pos('=', Tx);
            Caption := LeftStr(Tx, X - 1);
            Delete(Tx, 1, X);
            X := pos(' ', Tx);
            if X = 0 then
            begin
              Command := Tx;
              Width := 80;
            end
            else
            begin
              Command := LeftStr(Tx, X - 1);
              Delete(Tx, 1, X);
              Width := StrToIntDef(Tx, 80);
            end;
            AlignR := 0;
          end;
      end
      else
      begin
        SetLength(FListColUsr, 3);
        with FListColUsr[0] do
        begin
          Caption := 'DateTime';
          Command := '-exif:DateTimeOriginal';
          Width := 120;
          AlignR := 0;
        end;
        with FListColUsr[1] do
        begin
          Caption := 'Rating';
          Command := '-xmp-xmp:Rating';
          Width := 60;
          AlignR := 0;
        end;
        with FListColUsr[2] do
        begin
          Caption := 'Photo title';
          Command := '-xmp-dc:Title';
          Width := 160;
          AlignR := 0;
        end;
      end;

      // --- ETdirect commands---
      ETdirectCmd.Clear;
      ReadSection('ETdirectCmd', CBoxETdirect.Items);
      N := CBoxETdirect.Items.Count;
      if N = 0 then
        with CBoxETdirect.Items do
        begin
          Append('Set Exif:Copyright to [©Year by MyName]');
          ETdirectCmd.Append('-d %Y "-Exif:Copyright<©$DateTimeOriginal by MyName"');
          N := 2;
        end
      else
      begin
        for I := 0 to N - 1 do
          ETdirectCmd.Append(ReadString('ETdirectCmd', CBoxETdirect.Items[I], '?'));
      end;
      I := GUIsettings.ETdirDefCmd;
      if I < N then
      begin
        CBoxETdirect.ItemIndex := I;
        if I <> -1 then
        begin
          EditETdirect.Text := ETdirectCmd[I];
          SpeedBtnETdirectDel.Enabled := True;
        end;
      end
      else
        GUIsettings.ETdirDefCmd := -1;

      // --- WorkSpace tags---
      ReadWorkSpaceTags(GUIini);

      // --- Marked tags---
      MarkedTags := ReadString('TagList', 'MarkedTags', '<');
      N := length(MarkedTags);
      if MarkedTags[N] = '<' then
        MarkedTags[N] := ' '
      else
        MarkedTags := ' ';

      // --- CustomView tags---
      CustomViewTags := ReadString('TagList', 'CustomView', '<');
      N := Length(CustomViewTags);
      if CustomViewTags[N] = '<' then
        CustomViewTags[N] := ' '
      else
        CustomViewTags := ' ';

      ReadGeoCodeSettings(GUIini);
    end;
  finally
    GUIini.Free;
    TmpItems.Free;
  end;
end;

procedure ReadGUILog;
begin
  try
    GUIini := TMemIniFile.Create(GetIniFilePath(True), TEncoding.UTF8);
  except
    GUIini := TMemIniFile.Create(GetIniFilePath(True));
  end;

  try
    ReadLogWindowSizes(GUIini);
  finally
    GUIini.Free;
  end;
end;

function ReadSingleInstanceApp: boolean;
begin
  try
    GUIini := TMemIniFile.Create(GetIniFilePath(True), TEncoding.UTF8);
  except
    GUIini := TMemIniFile.Create(GetIniFilePath(True));
  end;

  try
    result := GUIini.ReadBool(Ini_Settings, 'SingleInstanceApp', false);
  finally
    GUIini.Free;
  end;
end;

procedure ResetWindowSizes;
var TempIni: TMemIniFile;
begin
  TempIni := TMemIniFile.Create('NUL'); // Should not exist, forcing all values to default
  try
    ReadMainWindowSizes(TempIni);
    ReadLogWindowSizes(TempIni);
  finally
    TempIni.Free;
  end;
end;

procedure SaveGUIini;
var
  I, N: integer;
  Tx: string;
begin
  if (DontSaveIni) then
    exit;
  try
    // Recreate the INI file, by deleting first
    System.SysUtils.DeleteFile(GetIniFilePath(false));
    GUIini := TMemIniFile.Create(GetIniFilePath(false), TEncoding.UTF8);
    try
      GUIini.AutoSave := true;
      with GUIini, FMain do
      begin
        if WindowState <> wsMaximized then
        begin
          WriteBool(Ini_ETGUI, 'StartMax', false);
          WriteInteger(Ini_ETGUI, 'WinTop', Top);
          WriteInteger(Ini_ETGUI, 'WinLeft', Left);
          WriteInteger(Ini_ETGUI, 'WinWidth', Width);
          WriteInteger(Ini_ETGUI, 'WinHeight', Height);
        end
        else
          WriteBool(Ini_ETGUI, 'StartMax', True);
        WriteInteger(Ini_ETGUI, 'BrowseWidth', AdvPanelBrowse.Width);
        WriteInteger(Ini_ETGUI, 'PreviewHeight', AdvPagePreview.Height);
        WriteInteger(Ini_ETGUI, 'MetadataWidth', AdvPageMetadata.Width);
        WriteInteger(Ini_ETGUI, 'MetadataTagWidth', MetadataList.ColWidths[0]);
        WriteString(Ini_ETGUI, 'DefaultDir', ShellList.path);
        with FLogWin do
        begin
          WriteInteger(Ini_ETGUI, 'LogWinTop', Top);
          WriteInteger(Ini_ETGUI, 'LogWinLeft', Left);
          WriteInteger(Ini_ETGUI, 'LogWinWidth', Width);
          WriteInteger(Ini_ETGUI, 'LogWinHeight', Height);
        end;

        // Std (file list) col widths
        WriteInteger(Ini_ETGUI, 'StdColWidth0', FListStdColWidth[0]);
        WriteInteger(Ini_ETGUI, 'StdColWidth1', FListStdColWidth[1]);
        WriteInteger(Ini_ETGUI, 'StdColWidth2', FListStdColWidth[2]);
        WriteInteger(Ini_ETGUI, 'StdColWidth3', FListStdColWidth[3]);

        // Column widths Camera settings
        WriteInteger(Ini_ETGUI, 'Def1ColWidth0', FListColDef1[0].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth1', FListColDef1[1].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth2', FListColDef1[2].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth3', FListColDef1[3].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth4', FListColDef1[4].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth5', FListColDef1[5].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth6', FListColDef1[6].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth7', FListColDef1[7].Width);

        // Column widths Location info
        WriteInteger(Ini_ETGUI, 'Def2ColWidth0', FListColDef2[0].Width);
        WriteInteger(Ini_ETGUI, 'Def2ColWidth1', FListColDef2[1].Width);
        WriteInteger(Ini_ETGUI, 'Def2ColWidth2', FListColDef2[2].Width);
        WriteInteger(Ini_ETGUI, 'Def2ColWidth3', FListColDef2[3].Width);
        WriteInteger(Ini_ETGUI, 'Def2ColWidth4', FListColDef2[4].Width);
        WriteInteger(Ini_ETGUI, 'Def2ColWidth5', FListColDef2[5].Width);

        // Column widths About photo
        WriteInteger(Ini_ETGUI, 'Def3ColWidth0', FListColDef3[0].Width);
        WriteInteger(Ini_ETGUI, 'Def3ColWidth1', FListColDef3[1].Width);
        WriteInteger(Ini_ETGUI, 'Def3ColWidth2', FListColDef3[2].Width);
        WriteInteger(Ini_ETGUI, 'Def3ColWidth3', FListColDef3[3].Width);
        WriteInteger(Ini_ETGUI, 'Def3ColWidth4', FListColDef3[4].Width);

        with GUIsettings do
        begin
          WriteString(Ini_Settings, 'Language', Language);
          WriteBool(Ini_Settings, 'AutoRotatePreview', AutoRotatePreview);
          I := CBoxFileFilter.Items.Count - 1;
          Tx := '';
          if I > 0 then
          begin
            for N := 1 to I do
            begin
              Tx := Tx + CBoxFileFilter.Items[N];
              if N < I then
                Tx := Tx + '|';
            end;
          end;
          WriteString(Ini_Settings, 'FileFilters', Tx);
          WriteBool(Ini_Settings, 'DefStartupUse', DefStartupUse);
          WriteString(Ini_Settings, 'DefStartupDir', DefStartupDir);
          WriteString(Ini_Settings, 'ETOverrideDir', ETOverrideDir);
          WriteString(Ini_Settings, 'ETCustomConfig', ETCustomConfig);

          WriteInteger(Ini_Settings, 'ETTimeOut', ETTimeOut);
          WriteBool(Ini_Settings, 'DefExportUse', DefExportUse);
          WriteString(Ini_Settings, 'DefExportDir', DefExportDir);
          WriteInteger(Ini_Settings, 'ThumbsSize', ThumbSize);
          WriteBool(Ini_Settings, 'ThumbAutoGenerate', ThumbAutoGenerate);
          WriteString(Ini_Settings, 'ThumbCleanSet', ThumbCleanSet);

          WriteBool(Ini_Settings, 'EnableGMap', EnableGMap);
          WriteString(Ini_Settings, 'DefGMapHome', DefGMapHome);
          WriteString(Ini_Settings, 'GUIStyle', GuiStyle);

          WriteBool(Ini_Settings, 'UseExitDetails', UseExitDetails);
          WriteInteger(Ini_Settings, 'DetailsSel', FMain.CBoxDetails.ItemIndex);
          WriteBool(Ini_Settings, 'DetailsDown', FMain.SpeedBtnDetails.Down);
          WriteBool(Ini_Settings, 'AutoIncLine', AutoIncLine);
          WriteBool(Ini_Settings, 'DblClickUpdTags', DblClickUpdTags);
          WriteInteger(Ini_Settings, 'ETdirDefCmd', ETdirDefCmd);
          WriteInteger(Ini_Settings, 'ETdirMode', ETdirMode);
          WriteString(Ini_Settings, 'CLFnumber', '$' + IntToHex(CLFNumber, 8));
          WriteString(Ini_Settings, 'CLFocal', '$' + IntToHex(CLFocal, 8));
          WriteString(Ini_Settings, 'CLISO', '$' + IntToHex(CLISO, 8));
          WriteBool(Ini_Settings, 'ShowFolders', ShowFolders);
          WriteBool(Ini_Settings, 'ShowHidden', ShowHidden);
          WriteBool(Ini_Settings, 'EnableUnsupported', EnableUnsupported);
          WriteBool(Ini_Settings, 'ShowBreadCrumb', ShowBreadCrumb);
          WriteBool(Ini_Settings, 'MinimizeToTray', MinimizeToTray);
          WriteBool(Ini_Settings, 'SingleInstanceApp', SingleInstanceApp);
          WriteBool(Ini_Settings, 'ShowBalloon', ShowBalloon);

          WriteInteger(Ini_Settings, 'HintHidePause', Application.HintHidePause);
        end;

        WriteBool(Ini_Options, 'DontBackup', MaDontBackup.Checked);
        WriteBool(Ini_Options, 'PreserveDateMod', MaPreserveDateMod.Checked);
        Tx := ET_Options.ETSeparator;
        Delete(Tx, 1, 6);
        SetLength(Tx, 1);
        WriteString(Ini_Options, 'KeySeparator', Tx);
        WriteBool(Ini_Options, 'IgnoreErrors', MaIgnoreErrors.Checked);
        WriteBool(Ini_Options, 'GPSinDecimal', MaShowGPSdecimal.Checked);
        WriteBool(Ini_Options, 'ShowSorted', MaShowSorted.Checked);
        WriteBool(Ini_Options, 'ShowComposite', MaShowComposite.Checked);
        WriteBool(Ini_Options, 'NotDuplicated', MaNotDuplicated.Checked);
        WriteBool(Ini_Options, 'APIWindowsWideFile', MaAPIWindowsWideFile.Checked);
        WriteBool(Ini_Options, 'APILargeFileSupport', MaAPILargeFileSupport.Checked);
        WriteString(Ini_Options, 'CustomOptions', ET_Options.ETCustomOptions);

        I := length(FListColUsr) - 1;
        for N := 0 to I do
        begin
          Tx := FListColUsr[N].Command + ' ' + IntToStr(FListColUsr[N].Width);
          WriteString('FListUserDefColumn', FListColUsr[N].Caption, Tx);
        end;

        for N := 0 to ETdirectCmd.Count - 1 do
          WriteString('ETdirectCmd', CBoxETdirect.Items[N], ETdirectCmd[N]);

        WriteWorkSpaceTags(GuiIni);

        N := length(MarkedTags);
        if (N > 0) then
          MarkedTags[N] := '<'
        else
          MarkedTags := '<';
        WriteString('TagList', 'MarkedTags', MarkedTags);

        N := length(CustomViewTags);
        if (N > 0) then
          CustomViewTags[N] := '<'
        else
          CustomViewTags := '<';
        WriteString('TagList', 'CustomView', CustomViewTags);

      end;
      WriteGeoCodeSettings(GUIini);
    finally
      GUIini.Free;
    end;

  except
    on E: Exception do
    begin
      ShowMessage(StrCannotSaveGUI + #10 + E.Message);
    end;
  end;
end;

function LoadWorkspaceIni(IniFName: string): boolean;
var
  TmpItems: TStringList;
begin
  result := false;
  if not FileExists(IniFName) then
    exit;

  TmpItems := TStringList.Create;
  GUIini := TMemIniFile.Create(IniFName, TEncoding.UTF8);
  try
    ReadWorkSpaceTags(GuiIni);
    result := true;
  finally
    GUIini.Free;
    TmpItems.Free;
  end;
end;

function SaveWorkspaceIni(IniFName: string): boolean;
begin
  result := true;
  try
    System.SysUtils.DeleteFile(IniFName);
    GUIini := TMemIniFile.Create(IniFName, TEncoding.UTF8);
    try
      GUIini.AutoSave := true;
      WriteWorkSpaceTags(GuiIni);
    finally
      GUIini.Free;
    end;
  except
    result := false;
  end;
end;

// ------------------------------------------------------------------------------
function BrowseFolderCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam): integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
    SendMessage(Wnd, BFFM_SETSELECTION, 1, NativeInt(@lg_StartFolder[1]));
  result := 0;
end;

function BrowseFolderDlg(const Title: string; iFlag: integer; const StartFolder: string = ''): string;
var
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array [0 .. MAX_PATH] of Char;
begin
  result := '';
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  lg_StartFolder := StartFolder;
  with BrowseInfo do
  begin
    hwndOwner := Application.Handle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar(Title);
    ulFlags := iFlag;
    if StartFolder <> '' then
      BrowseInfo.lpfn := BrowseFolderCallBack;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  // -we got folder name (without path) into DisplayName
  if lpItemID <> nil then
  begin // get full path
    SHGetPathFromIDList(lpItemID, DisplayName);
    result := DisplayName; // =without final dash
    GlobalFreePtr(lpItemID);
  end;
end;
// ------------------------------------------------------------------------------

procedure ChartFindFiles(StartDir, FileMask: string; subDir: boolean);
var
  SR: TSearchRec;
  DirList: TStringList;
  IsFound, DoSub: boolean;
  I: integer;
  W: word;
begin
  StartDir := IncludeTrailingBackslash(StartDir);
  DoSub := subDir;
  // Build a list of the files in directory StartDir -not the directories!
  IsFound := FindFirst(StartDir + FileMask, faAnyFile - faDirectory, SR) = 0;
  while IsFound do
  begin
    GetMetadata(StartDir + SR.Name, false, false, false, false);
    with Foto do
    begin
      // focal length:
      W := pos('.', ExifIFD.FocalLength);
      if W > 0 then
        Delete(ExifIFD.FocalLength, W, 1); // 5.8->58
      W := StrToIntDef(ExifIFD.FocalLength, 0);
      if W > 0 then
      begin
        if (W >= Low(ChartFLength)) and (W <= High(ChartFLength)) then
          inc(ChartFLength[W]);
      end;
      // aperture:
      W := pos('.', ExifIFD.FNumber);
      if W > 0 then
        Delete(ExifIFD.FNumber, W, 1); // 4.0->40
      W := StrToIntDef(ExifIFD.FNumber, 0);
      if W > 0 then
      begin
        if (W >= Low(ChartFNumber)) and (W <= High(ChartFNumber)) then
          inc(ChartFNumber[W]);
      end;
      // ISO:
      W := StrToIntDef(ExifIFD.ISO, 0) div 10; // 800->80
      if W > 0 then
      begin
        if (W >= Low(ChartISO)) and (W <= High(ChartISO)) then
          inc(ChartISO[W]);
      end;
    end;
    IsFound := FindNext(SR) = 0;
  end;

  System.SysUtils.FindClose(SR);
  // Build a list of subdirectories
  if DoSub then
  begin
    DirList := TStringList.Create;
    IsFound := FindFirst(StartDir + '*.*', faAnyFile, SR) = 0;
    while IsFound do
    begin
      if ((SR.Attr and faDirectory) <> 0) and (SR.Name[1] <> '.') then
        DirList.Add(StartDir + SR.Name);
      IsFound := FindNext(SR) = 0;
    end;
    System.SysUtils.FindClose(SR);
    // Scan the list of subdirectories
    for I := 0 to DirList.Count - 1 do
      ChartFindFiles(DirList[I], FileMask, DoSub);
    DirList.Free;
  end;
end;

initialization

begin
  ETdirectCmd := TStringList.Create;
end;

finalization

begin
  ETdirectCmd.Free;
end;

end.
