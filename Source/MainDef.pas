unit MainDef;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses Classes;

const
  SHOWALL = 'Show All Files';

type
  GUIsettingsRec = record
    Language: string[7];
    AutoRotatePreview: boolean;
    DefStartupUse: boolean;
    DefStartupDir: AnsiString;
    DefExportUse: boolean;
    DefExportDir: AnsiString;
    ThumbSize: smallint;
    UseExitDetails: boolean;
    AutoIncLine: boolean;
    EnableGMap: boolean;
    DefGMapHome: string[23];
    GuiStyle: string;
    ETdirDefCmd: smallint;
    InitialDir: AnsiString;
    ETOverrideDir: AnsiString;
    ETTimeOut: integer;
  end;

  FListColUsrRec = record
    Caption: string;
    Command: string;
    Width: smallint;
    AlignR: smallint;
  end;

  FListColDefRec = record
    Caption: string;
    Width: smallint;
    AlignR: smallint;
    constructor Create(AListColUsrRec: FListColUsrRec);
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
  FListColDef1: array [0 .. 7] of FListColDefRec =
  (
    (Caption: 'ExpTime';        AlignR: 6),
    (Caption: 'FNumber';        AlignR: 4),
    (Caption: 'ISO';            AlignR: 5),
    (Caption: 'ExpComp.';       AlignR: 4),
    (Caption: 'FLength';        AlignR: 8),
    (Caption: 'Flash';          AlignR: 0),
    (Caption: 'ExpProgram';     AlignR: 0),
    (Caption: 'Orientation';    AlignR: 0)
  );

  FListColDef2: array [0 .. 5] of FListColDefRec =
  (
    (Caption: 'DateTime';       AlignR: 0),
    (Caption: 'GPS';            AlignR: 0),
    (Caption: 'Country';        AlignR: 0),
    (Caption: 'Province';       AlignR: 0),
    (Caption: 'City';           AlignR: 0),
    (Caption: 'Location';       AlignR: 0)
  );


  FListColDef3: array [0 .. 4] of FListColDefRec =
  (
    (Caption: 'Artist';         AlignR: 0),
    (Caption: 'Rating';         AlignR: 0),
    (Caption: 'Type';           AlignR: 0),
    (Caption: 'Event';          AlignR: 0),
    (Caption: 'PersonInImage';  AlignR: 0)
  );

  FListColUsr: array of FListColUsrRec;

  GUIsettings: GUIsettingsRec;
  ETdirectCmd: TStringList;
  QuickTags: array of QuickTagRec;
  MarkedTags: string;
  CustomViewTags: string;
  GpsXmpDir: string = '';
  WrkIniDir: string = '';

function GetIniFilePath(AllowPrevVer: boolean): string;
procedure ReadGUILog;
procedure ReadGUIini;
procedure SaveGUIini;
function LoadWorkspaceIni(IniFName: string): boolean;
function SaveWorkspaceIni(IniFName: string): boolean;
function BrowseFolderDlg(const Title: string; iFlag: integer;
  const StartFolder: string = ''): string;
procedure ChartFindFiles(StartDir, FileMask: string; subDir: boolean);
function GetNrOfFiles(StartDir, FileMask: string; subDir: boolean): integer;

implementation

uses Main, IniFiles, LogWin, SysUtils, Forms, StrUtils, Dialogs, ExifTool,
  Windows, ExifInfo, ShellAPI, ShlObj,
  Vcl.ComCtrls, ExifToolsGUI_Utils;

const
  CRLF = #13#10;
  Ini_ETGUI = 'ExifToolGUI';
  Ini_Settings = 'GUIsettings';
  Ini_Options = 'EToptions';
  IniVersion = 'V6';
  PrevIniVersion = 'V5';

var
  GUIini: TIniFile;
  TmpItems: TStrings;
  lg_StartFolder: string;

// This function returns the name of the INI file.
// If it doesn't exist, but a previous version exists it returns that name.
function GetIniFilePath(AllowPrevVer: boolean): string;
var CurVer, PrevVer, PrevPath: string;
begin
// Default is ExifToolGuiV6.ini in Profile %AppData%\ExifToolGui
  CurVer := ChangeFileExt(ExtractFileName(Application.ExeName), IniVersion + '.ini');
  result := GetINIPath + CurVer;
  if (FileExists(result)) then
    exit;

// Allow import of previous version. Used when reading ini file
  if not AllowPrevVer then
    exit;

  PrevVer := ChangeFileExt(ExtractFileName(Application.ExeName), PrevIniVersion + '.ini');
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

constructor FListColDefRec.Create(AListColUsrRec: FListColUsrRec);
begin
  Caption := AListColUsrRec.Caption;
  Width := AListColUsrRec.Width;
  AlignR := AListColUsrRec.AlignR;
end;

procedure ReadGUIini;
var
  i, n, x: smallint;
  tx, DefaultDir: string;

  procedure SetQuickTag(var x: smallint; const Name: string; Cmd: string);
  begin
    with QuickTags[x] do
    begin
      Caption := Name;
      n := pos('^', Cmd);
      if n = 0 then
      begin
        Command := Cmd;
        SetLength(Help, 0);
      end
      else
      begin
        Command := LeftStr(Cmd, n - 1);
        Delete(Cmd, 1, n);
        Help := Cmd;
      end;
    end;
    inc(x);
  end;

begin
  TmpItems := TStringList.Create;
  GUIini := TIniFile.Create(GetIniFilePath(True));
  try
    with GUIini, FMain do
    begin
      n := 0;
      if WindowState = wsMaximized then
        inc(n); // check shortcut setting
      if ReadBool(Ini_ETGUI, 'StartMax', false) then
        inc(n);
      Top := ReadInteger(Ini_ETGUI, 'WinTop', 40);
      Left := ReadInteger(Ini_ETGUI, 'WinLeft', 60);
      Width := ReadInteger(Ini_ETGUI, 'WinWidth', 1024);
      Height := ReadInteger(Ini_ETGUI, 'WinHeight', 660);
      if n > 0 then
        WindowState := wsMaximized;
      AdvPanelBrowse.Width := ReadInteger(Ini_ETGUI, 'BrowseWidth', 240);
      AdvPagePreview.Height := ReadInteger(Ini_ETGUI, 'PreviewHeight', 220);
      AdvPageMetadata.Width := ReadInteger(Ini_ETGUI, 'MetadataWidth', 322);
      MetadataList.ColWidths[0] := ReadInteger(Ini_ETGUI, 'MetadataTagWidth', 144);
      StatusBar.Panels[0].Width := AdvPanelBrowse.Width + 5;
      DefaultDir := ReadString(Ini_ETGUI, 'DefaultDir', 'c:\');
      if (ValidDir(DefaultDir)) then
        GUIsettings.InitialDir := DefaultDir;

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
      FListColDef2[1].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth1',  48);
      FListColDef2[2].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth2',  80);
      FListColDef2[3].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth3',  80);
      FListColDef2[4].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth4', 120);
      FListColDef2[5].Width := ReadInteger(Ini_ETGUI, 'Def2ColWidth5', 120);

      // Column widths About photo
      FListColDef3[0].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth0', 120);
      FListColDef3[1].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth1',  48);
      FListColDef3[2].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth2', 120);
      FListColDef3[3].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth3', 120);
      FListColDef3[4].Width := ReadInteger(Ini_ETGUI, 'Def3ColWidth4', 120);

      with GUIsettings do
      begin
        Language := ReadString(Ini_Settings, 'Language', '');
        ET_Options.ETLangDef := Language + CRLF;;
        if Language = '' then
          ET_Options.ETLangDef := '';
        AutoRotatePreview := ReadBool(Ini_Settings, 'AutoRotatePreview', false);
        tx := ReadString(Ini_Settings, 'FileFilters', '*.JPG|*.CR2|*.JPG;*.CR2|*.JPG;*.DNG|*.JPG;*.PEF');
        CBoxFileFilter.Items.Text := SHOWALL;
        repeat
          i := pos('|', tx);
          if i > 0 then
          begin
            CBoxFileFilter.Items.Append(LeftStr(tx, i - 1));
            Delete(tx, 1, i);
          end
          else
            CBoxFileFilter.Items.Append(tx);
        until i = 0;
        DefStartupUse := ReadBool(Ini_Settings, 'DefStartupUse', false);
        DefStartupDir := ReadString(Ini_Settings, 'DefStartupDir', 'c:\');
        if DefStartupUse and ValidDir(DefStartupDir) then
          GUIsettings.InitialDir := DefStartupDir;
        GUIsettings.ETOverrideDir := ReadString(Ini_Settings, 'ETOverrideDir', '');
        // Note: Not configurable by user, only in INI
        GUIsettings.ETTimeOut := ReadInteger(Ini_Settings, 'ETTimeOut', 5000);
        DefExportUse := ReadBool(Ini_Settings, 'DefExportUse', false);
        DefExportDir := ReadString(Ini_Settings, 'DefExportDir', '');
        ThumbSize := ReadInteger(Ini_Settings, 'ThumbsSize', 0);
        case ThumbSize of
          0: i := 96;
          1: i := 128;
          2: i := 160;
        else
          i := 96;
        end;
        FMain.ShellList.ThumbNailSize := i;

        EnableGMap := ReadBool(Ini_Settings, 'EnableGMap', false);
        DefGMapHome := ReadString(Ini_Settings, 'DefGMapHome', '46.55738,15.64608');
        if (pos('.', DefGMapHome) = 0) or (pos(',', DefGMapHome) = 0) then
          DefGMapHome := '46.55738,15.64608';
        GuiStyle := ReadString(Ini_Settings, 'GUIStyle', 'Silver');
        UseExitDetails := ReadBool(Ini_Settings, 'UseExitDetails', false);
        if UseExitDetails then
        begin
          FMain.CBoxDetails.ItemIndex := ReadInteger(Ini_Settings, 'DetailsSel', 0);
          FMain.SpeedBtnDetails.Down :=
            ReadBool(Ini_Settings, 'DetailsDown', true);
        end;
        AutoIncLine := ReadBool(Ini_Settings, 'AutoIncLine', true);
        ETdirDefCmd := ReadInteger(Ini_Settings, 'ETdirDefCmd', -1);
      end;

      with ET_Options do
      begin
        MDontBackup.Checked := ReadBool(Ini_Options, 'DontBackup', true);
        if not MDontBackup.Checked then
          ETBackupMode := '';
        MPreserveDateMod.Checked := ReadBool(Ini_Options, 'PreserveDateMod', false);
        if MPreserveDateMod.Checked then
          ETFileDate := '-P' + CRLF;
        ETSeparator := '-sep' + CRLF + ReadString(Ini_Options, 'KeySeparator', '*') + CRLF;
        MIgnoreErrors.Checked := ReadBool(Ini_Options, 'IgnoreErrors', false);
        if MIgnoreErrors.Checked then
          ETMinorError := '-m' + CRLF;
        MShowGPSdecimal.Checked := ReadBool(Ini_Options, 'GPSinDecimal', true);
        ET_Options.SetGpsFormat(MShowGPSdecimal.Checked);
        MShowSorted.Checked := ReadBool(Ini_Options, 'ShowSorted', false);
        MShowComposite.Checked := ReadBool(Ini_Options, 'ShowComposite', false);
        MNotDuplicated.Checked := ReadBool(Ini_Options, 'NotDuplicated', false);
      end;

      // Custom FList columns
      ReadSectionValues('FListUserDefColumn', TmpItems);
      i := TmpItems.Count;
      if i > 0 then
      begin
        SetLength(FListColUsr, i);
        for n := 0 to i - 1 do
          with FListColUsr[n] do
          begin
            tx := TmpItems[n];
            x := pos('=', tx);
            Caption := LeftStr(tx, x - 1);
            Delete(tx, 1, x);
            x := pos(' ', tx);
            if x = 0 then
            begin
              Command := tx;
              Width := 80;
            end
            else
            begin
              Command := LeftStr(tx, x - 1);
              Delete(tx, 1, x);
              Width := StrToIntDef(tx, 80);
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
      n := CBoxETdirect.Items.Count;
      if n = 0 then
        with CBoxETdirect.Items do
        begin
          Append('Set Exif:Copyright to [©Year by MyName]');
          ETdirectCmd.Append('-d %Y "-Exif:Copyright<©$DateTimeOriginal by MyName"');
          n := 2;
        end
      else
      begin
        for i := 0 to n - 1 do
          ETdirectCmd.Append(ReadString('ETdirectCmd', CBoxETdirect.Items[i], '?'));
      end;
      i := GUIsettings.ETdirDefCmd;
      if i < n then
      begin
        CBoxETdirect.ItemIndex := i;
        if i <> -1 then
        begin
          EditETdirect.Text := ETdirectCmd[i];
          SpeedBtnETdirectDel.Enabled := true;
        end;
      end
      else
        GUIsettings.ETdirDefCmd := -1;
      // ---------------------
      ReadSectionValues('WorkspaceTags', TmpItems);
      i := TmpItems.Count;
      if i > 0 then
      begin
        SetLength(QuickTags, i);
        for n := 0 to i - 1 do
          with QuickTags[n] do
          begin
            tx := TmpItems[n];
            x := pos('=', tx);
            Caption := LeftStr(tx, x - 1);
            Delete(tx, 1, x);
            x := pos('^', tx);
            if x = 0 then
            begin
              Command := tx;
              SetLength(Help, 0);
            end
            else
            begin
              Command := LeftStr(tx, x - 1);
              Delete(tx, 1, x);
              Help := tx;
            end;
          end;
      end
      else
      begin
        SetLength(QuickTags, 27);
        i := 0;
        SetQuickTag(i, 'EXIF', '-GUI-SEP');
        SetQuickTag(i, 'Make', '-exif:Make');
        SetQuickTag(i, 'Model', '-exif:Model');
        SetQuickTag(i, 'LensModel', '-exif:LensModel');
        SetQuickTag(i, 'ExposureTime', '-exif:ExposureTime^[1/50] or [0.02]');
        SetQuickTag(i, 'FNumber', '-exif:FNumber');
        SetQuickTag(i, 'ISO', '-exif:ISO');
        SetQuickTag(i, 'FocalLength', '-exif:FocalLength^[28] -mm not necessary');
        SetQuickTag(i, 'Flash#', '-exif:Flash^[ 0 ]=No flash, [ 1 ]=Flash fired');
        SetQuickTag(i, 'Orientation#', '-exif:Orientation^[ 1 ]=0°, [ 3 ]=180°, [ 6 ]=+90°, [ 8 ]=-90°');
        SetQuickTag(i, 'DateTimeOriginal', '-exif:DateTimeOriginal^[2012:01:14 20:00:00]');
        SetQuickTag(i, 'CreateDate', '-exif:CreateDate^[2012:01:14 20:00:00]');
        SetQuickTag(i, 'Artist*', '-exif:Artist^Bogdan Hrastnik');
        SetQuickTag(i, 'Copyright', '-exif:Copyright^Use Alt+0169 to get © character');
        SetQuickTag(i, 'Software', '-exif:Software');
        SetQuickTag(i, 'Geotagged?', '-Gps:GPSLatitude');

        SetQuickTag(i, 'About photo', '-GUI-SEP');
        SetQuickTag(i, 'Type±', '-xmp-dc:Type^[Landscape] or [Studio+Portrait] ..');
        SetQuickTag(i, 'Rating','-xmp-xmp:Rating^Integer value [ 0 ] .. [ 5 ]');
        SetQuickTag(i, 'Subject','-xmp-xmp:Subject');
        SetQuickTag(i, 'Event', '-xmp-iptcExt:Event^[Vacations] or [Trip] ..');
        SetQuickTag(i, 'PersonInImage±', '-xmp:PersonInImage^[Phil] or [Harry+Sally] or [-Peter] ..');
        SetQuickTag(i, 'Keywords±', '-xmp-dc:Subject^[tree] or [flower+rose] or [-fish] or [+bird-fish] ..');
        SetQuickTag(i, 'Country', '-xmp:LocationShownCountryName');
        SetQuickTag(i, 'Province', '-xmp:LocationShownProvinceState');
        SetQuickTag(i, 'City', '-xmp:LocationShownCity');
        SetQuickTag(i, 'Location', '-xmp:LocationShownSublocation');
      end;
      for i := 0 to length(QuickTags) - 1 do
      begin
        tx := QuickTags[i].Caption;
        QuickTags[i].NoEdit := (RightStr(tx, 1) = '?');
        tx := UpperCase(LeftStr(QuickTags[i].Command, 4));
        QuickTags[i].NoEdit := QuickTags[i].NoEdit or (tx = '-GUI');
      end;
      // --------------------
      MarkedTags := ReadString('TagList', 'MarkedTags', 'Artist ');
      n := length(MarkedTags);
      if MarkedTags[n] = '<' then
        MarkedTags[n] := ' '
      else
        MarkedTags := 'Artist ';
      // --------------------
      CustomViewTags := ReadString('TagList', 'CustomView', '-Exif:Artist ');
      n := length(CustomViewTags);
      if CustomViewTags[n] = '<' then
        CustomViewTags[n] := ' '
      else
        CustomViewTags := '-Exif:Artist ';

    end;
  finally
    GUIini.Free;
    TmpItems.Free;
  end;
end;

procedure ReadGUILog;
begin
  GUIini := TIniFile.Create(GetIniFilePath(false));
  try
    with GUIini, FLogWin do
      begin
        Top := ReadInteger(Ini_ETGUI, 'LogWinTop', 106);
        Left := ReadInteger(Ini_ETGUI, 'LogWinLeft', 108);
        Width := ReadInteger(Ini_ETGUI, 'LogWinWidth', 580);
        Height := ReadInteger(Ini_ETGUI, 'LogWinHeight', 200);
      end;
  finally
    GUIini.Free;
  end;
end;

procedure SaveGUIini;
var I, N: smallint;
    Tx: string;
begin
  // ^- EraseSection used instead
  try
    GUIini := TIniFile.Create(GetIniFilePath(false));
    try
      with GUIini, FMain do
      begin
        EraseSection(Ini_ETGUI);
        if WindowState <> wsMaximized then
        begin
          WriteBool(Ini_ETGUI, 'StartMax', false);
          WriteInteger(Ini_ETGUI, 'WinTop', Top);
          WriteInteger(Ini_ETGUI, 'WinLeft', Left);
          WriteInteger(Ini_ETGUI, 'WinWidth', Width);
          WriteInteger(Ini_ETGUI, 'WinHeight', Height);
        end
        else
          WriteBool(Ini_ETGUI, 'StartMax', true);
        WriteInteger(Ini_ETGUI, 'BrowseWidth', AdvPanelBrowse.Width);
        WriteInteger(Ini_ETGUI, 'PreviewHeight', AdvPagePreview.Height);
        WriteInteger(Ini_ETGUI, 'MetadataWidth', AdvPageMetadata.Width);
        WriteInteger(Ini_ETGUI, 'MetadataTagWidth', MetadataList.ColWidths[0]);
        WriteString(Ini_ETGUI, 'DefaultDir', ShellTree.path);
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

        EraseSection(Ini_Settings);
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
          WriteInteger(Ini_Settings, 'ETTimeOut', ETTimeOut);
          WriteBool(Ini_Settings, 'DefExportUse', DefExportUse);
          WriteString(Ini_Settings, 'DefExportDir', DefExportDir);
          WriteInteger(Ini_Settings, 'ThumbsSize', ThumbSize);

          WriteBool(Ini_Settings, 'EnableGMap', EnableGMap);
          WriteString(Ini_Settings, 'DefGMapHome', DefGMapHome);
          WriteString(Ini_Settings, 'GUIStyle', GuiStyle);

          WriteBool(Ini_Settings, 'UseExitDetails', UseExitDetails);
          WriteInteger(Ini_Settings, 'DetailsSel', FMain.CBoxDetails.ItemIndex);
          WriteBool(Ini_Settings, 'DetailsDown', FMain.SpeedBtnDetails.Down);
          WriteBool(Ini_Settings, 'AutoIncLine', AutoIncLine);
          WriteInteger(Ini_Settings, 'ETdirDefCmd', ETdirDefCmd);
        end;

        EraseSection(Ini_Options);
        WriteBool(Ini_Options, 'DontBackup', MDontBackup.Checked);
        WriteBool(Ini_Options, 'PreserveDateMod', MPreserveDateMod.Checked);
        Tx := ET_Options.ETSeparator;
        Delete(Tx, 1, 6);
        SetLength(Tx, 1);
        WriteString(Ini_Options, 'KeySeparator', Tx);
        WriteBool(Ini_Options, 'IgnoreErrors', MIgnoreErrors.Checked);
        WriteBool(Ini_Options, 'GPSinDecimal', MShowGPSdecimal.Checked);
        WriteBool(Ini_Options, 'ShowSorted', MShowSorted.Checked);
        WriteBool(Ini_Options, 'ShowComposite', MShowComposite.Checked);
        WriteBool(Ini_Options, 'NotDuplicated', MNotDuplicated.Checked);

        EraseSection('FListUserDefColumn');
        I := length(FListColUsr) - 1;
        for N := 0 to I do
        begin
          Tx := FListColUsr[N].Command + ' ' + IntToStr(FListColUsr[N].Width);
          WriteString('FListUserDefColumn', FListColUsr[N].Caption, Tx);
        end;

        EraseSection('ETdirectCmd');
        for N := 0 to ETdirectCmd.Count - 1 do
          WriteString('ETdirectCmd', CBoxETdirect.Items[N], ETdirectCmd[N]);

        EraseSection('WorkspaceTags');
        for N := 0 to length(QuickTags) - 1 do
          with QuickTags[N] do
          begin
            Tx := Command;
            if length(Help) > 0 then
              Tx := Tx + '^' + Help;
            WriteString('WorkspaceTags', Caption, Tx);
          end;

        EraseSection('TagList');
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

    finally
      GUIini.Free;
    end;

  except
    on e: Exception do
    begin
      showmessage('Cannot save GUI settings.' + #10 + e.Message);
    end;
  end;
end;

function LoadWorkspaceIni(IniFName: string): boolean;
var
  i, n, x: smallint;
  tx: string;
begin
  result := false;
  if FileExists(IniFName) then
  begin
    TmpItems := TStringList.Create;
    GUIini := TIniFile.Create(IniFName);
    with GUIini do
    begin
      ReadSectionValues('WorkspaceTags', TmpItems);
      i := TmpItems.Count;
      if i > 0 then
      begin
        SetLength(QuickTags, i);
        for n := 0 to i - 1 do
          with QuickTags[n] do
          begin
            tx := TmpItems[n];
            x := pos('=', tx);
            Caption := LeftStr(tx, x - 1);
            Delete(tx, 1, x);
            x := pos('^', tx);
            if x = 0 then
            begin
              Command := tx;
              SetLength(Help, 0);
            end
            else
            begin
              Command := LeftStr(tx, x - 1);
              Delete(tx, 1, x);
              Help := tx;
            end;
          end;
        for i := 0 to length(QuickTags) - 1 do
        begin
          tx := QuickTags[i].Caption;
          QuickTags[i].NoEdit := (RightStr(tx, 1) = '?');
          tx := UpperCase(LeftStr(QuickTags[i].Command, 4));
          QuickTags[i].NoEdit := QuickTags[i].NoEdit or (tx = '-GUI');
        end;
        result := true;
      end;
    end;
    GUIini.Free;
    TmpItems.Free;
  end;
end;

function SaveWorkspaceIni(IniFName: string): boolean;
var
  n: smallint;
  tx: string;
  F: TextFile;
begin
  try
    AssignFile(F, IniFName);
    Rewrite(F);
    Close(F);
    GUIini := TIniFile.Create(IniFName);
    with GUIini do
    begin
      for n := 0 to length(QuickTags) - 1 do
        with QuickTags[n] do
        begin
          tx := Command;
          if length(Help) > 0 then
            tx := tx + '^' + Help;
          WriteString('WorkspaceTags', Caption, tx);
        end;
    end;
    GUIini.Free;
    result := true;
  except
    else
      GUIini.Free;
    result := false;
  end;
end;

// ------------------------------------------------------------------------------
function BrowseFolderCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam)
  : integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
    SendMessage(Wnd, BFFM_SETSELECTION, 1, integer(@lg_StartFolder[1]));
  result := 0;
end;

function BrowseFolderDlg(const Title: string; iFlag: integer;
  const StartFolder: string = ''): string;
var
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array [0 .. MAX_PATH] of char;
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
var SR: TSearchRec;
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

  SysUtils.FindClose(SR);
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
    SysUtils.FindClose(SR);
    // Scan the list of subdirectories
    for I := 0 to DirList.Count - 1 do
      ChartFindFiles(DirList[I], FileMask, DoSub);
    DirList.Free;
  end;
end;

function GetNrOfFiles(StartDir, FileMask: string; subDir: boolean): integer;
var
  SR: TSearchRec;
  DirList: TStringList;
  IsFound, doSub: boolean;
  i, x: integer;
begin
  if StartDir[length(StartDir)] <> '\' then
    StartDir := StartDir + '\';
  doSub := subDir;
  x := 0;
  // Count files in directory
  IsFound := FindFirst(StartDir + FileMask, faAnyFile - faDirectory, SR) = 0;
  while IsFound do
  begin
    inc(x);
    IsFound := FindNext(SR) = 0;
  end;
  SysUtils.FindClose(SR);

  // Build a list of subdirectories
  if doSub then
  begin
    DirList := TStringList.Create;
    IsFound := FindFirst(StartDir + '*.*', faAnyFile, SR) = 0;
    while IsFound do
    begin
      if ((SR.Attr and faDirectory) <> 0) and (SR.Name[1] <> '.') then
        DirList.Add(StartDir + SR.Name);
      IsFound := FindNext(SR) = 0;
    end;
    SysUtils.FindClose(SR);
    // Scan the list of subdirectories
    for i := 0 to DirList.Count - 1 do
      x := x + GetNrOfFiles(DirList[i], FileMask, doSub);
    DirList.Free;
  end;
  result := x;
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
