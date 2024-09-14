unit MainDef;

interface

uses System.Classes, Winapi.Windows, Vcl.Dialogs, ExifTool, GEOMap, UnitLangResources, UnitScaleForm;

const
  SHOWALL = 'Show All Files';

  DefRemoveTags =
    'Exif:All ' +
    'Exif:Makernotes ' +
    'Exif:Gps:All ' +
    'Exif:IFD1:All ' +
    'Xmp:All ' +
    'Xmp-exif:All ' +
    'Xmp-Acdsee:All ' +
    'Xmp-Mediapro:All ' +
    'Xmp-Photoshop:All ' +
    'Xmp-crs:All ' +
    'Xmp-Microsoft:All ' +
    'Xmp-pdf:All ' +
    'Xmp-tiff:All ' +
    'Iptc:All ' +
    'Photoshop:All ' +
    'Jfif:All ' +
    'ICC_profile:All ';

  DefSelRemoveTags =
    'Exif:All ' +
    'Xmp:All ' +
    'Iptc:All ' +
    'Photoshop:All ' +
    'Jfif:All ' +
    'ICC_profile:All ';

  DefCopySingleTags =
    'Exif:all ' +
    '-Exif:Makernotes ' +
    '-Exif:Gps:All ' +
    'Xmp:All ' +
    'IPTC:All ' +
    'ICC_Profile:All ' +
    'Gps:All ';

  DefSelCopySingleTags =
    'Exif:all ' +
    'Xmp:All ' +
    'IPTC:All ' +
    'ICC_Profile:All ' +
    'Gps:All ';

  DefExcludeCopyTags =
    'Exif:ExifImageWidth ' +
    'Exif:ExifImageHeight ' +
    'Exif:Orientation ' +
    'Exif:Xresolution ' +
    'Exif:Yresolution ' +
    'Exif:ResolutionUnit ' +
    'Exif:ColorSpace ' +
    'Exif:InteropIndex ' +
    'Makernotes:All ' +
    'Xmp-photoshop:All ' +
    'Xmp-crs:All ' +
    'Xmp-exif:All ';

  DefSelExcludeCopyTags = '';

type
  TIniTagsData = (idtWorkSpace, idtETDirect, idtUserDefined, idtCustomView, idtPredefinedTags,
                  idtMarked, idtRemoveTags, idtCopySingleTags, idtCopyTags);

  TIniData = (idWorkSpace, idETDirect, idUserDefined, idCustomView, idPredefinedTags);

  GUIsettingsRec = record
    Language: string[7];
    AutoRotatePreview: boolean;
    DefStartupUse: boolean;
    DefStartupDir: string;
    DefExportUse: boolean;
    DefExportDir: string;
    ThumbSize: integer;
    ThumbAutoGenerate: boolean;
    ThumbCleanSet: string[4];
    UseExitDetails: boolean;
    AutoIncLine: boolean;
    DblClickUpdTags: boolean;
    EnableGMap: boolean;
    DefGMapHome: string[23];
    GuiStyle: string;
    ETdirDefCmd: integer;
    ETdirMode: integer;
    InitialDir: string;
    ETOverrideDir: string;
    ETCustomConfig: string;
    ETTimeOut: integer;
  // Colors of the Bar charts. Not configurable in UI
    CLFNumber: integer;
    CLFocal: integer;
    CLISO: integer;
  // Filetype to use fast3 in filelist and metadata for. Not configurable in UI
    Fast3FileTypes: string;
    ShowFolders: boolean;
    ShowHidden: boolean;
    EnableUnsupported: boolean;
    ShowBreadCrumb: boolean;
    MinimizeToTray: boolean;
    SingleInstanceApp: boolean;
    ShowBalloon: boolean;
    function CanShowHidden: boolean;
    function GetCustomConfig: string;
    function Fast3(const FileExt: string): string;
  end;

  FListColUsrRec = record
    Caption: string;
    Command: string;
    Width: integer;
    AlignR: integer;
  end;

  FListColDefRec = record
    Caption: PResStringRec;
    Width: integer;
    AlignR: integer;
  end;

  QuickTagRec = record
    Caption: string;
    Command: string;
    Help: string;
    NoEdit: boolean;
  end;

var
  FListStdColWidth: array [0 .. 4] of integer; // [Filename][Size][Type][Date modified][Date created]

  // Note: Default widths are in ReadGui
  // Captions will be loaded at runtime from resourcestrings
  FListColDef1: array [0 .. 9] of FListColDefRec =
  (
    (Caption: @StrFLModel; AlignR: 0),
    (Caption: @StrFLLensModel; AlignR: 0),
    (Caption: @StrFLExpTime; AlignR: 6),
    (Caption: @StrFLFNumber; AlignR: 4),
    (Caption: @StrFLISO; AlignR: 5),
    (Caption: @StrFLExpComp; AlignR: 4),
    (Caption: @StrFLFLength; AlignR: 8),
    (Caption: @StrFLFlash; AlignR: 0),
    (Caption: @StrFLExpProgram; AlignR: 0),
    (Caption: @StrFLOrientation; AlignR: 0)
  );

  FListColDef2: array [0 .. 5] of FListColDefRec =
  (
    (Caption: @StrFLDateTime; AlignR: 0),
    (Caption: @StrFLGPS; AlignR: 0),
    (Caption: @StrFLCountry; AlignR: 0),
    (Caption: @StrFLProvince; AlignR: 0),
    (Caption: @StrFLCity; AlignR: 0),
    (Caption: @StrFLLocation; AlignR: 0)
  );

  FListColDef3: array [0 .. 4] of FListColDefRec =
  (
    (Caption: @StrFLArtist; AlignR: 0),
    (Caption: @StrFLRating; AlignR: 0),
    (Caption: @StrFLType; AlignR: 0),
    (Caption: @StrFLEvent; AlignR: 0),
    (Caption: @StrFLPersonInImage; AlignR: 0)
  );

  FListColUsr: array of FListColUsrRec;

  GUIsettings: GUIsettingsRec;
  ETdirectCmdList: TStringList;
  QuickTags: array of QuickTagRec;
  MarkedTagList: string;
  CustomViewTagList: string;
  GpsXmpDir: string = '';
  WrkIniDir: string = '';
  ParmIniPath: string = '';
  DontSaveIni: boolean;
  PredefinedTagList: TStringList;
  SelPredefinedTagList: TStringList;

  ExcludeCopyTagListName: string;
  ExcludeCopyTagList: string;

  RemoveTagListName: string;
  RemoveTagList: string;

  CopySingleTagListName: string;
  CopySingleTagList: string;

  SelExcludeCopyTagList: string;
  SelRemoveTagList: string;
  SelCopySingleTagList: string;

function GetIniFilePath(AllowPrevVer: boolean): string;
procedure ReadFormSizes(AForm: TScaleForm; DefaultPos: TRect);
function ReadSingleInstanceApp: boolean;
procedure ResetWindowSizes;
procedure ReadGUIini;
function SaveGUIini: boolean;
function LoadIniDialog(OpenFileDlg: TOpenDialog; AIniData: TIniData; ShowMsg: boolean = true): boolean;
function SaveIniDialog(SaveFileDlg: TSaveDialog; AIniData: TIniData; ShowMsg: boolean = true): boolean;
function BrowseFolderDlg(const Title: string; iFlag: integer; const StartFolder: string = ''): string;

implementation

uses System.SysUtils, System.StrUtils, System.IniFiles,
  Winapi.ShellAPI, Winapi.ShlObj,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls,
  Main, ExifToolsGUI_Utils, ExifInfo, LogWin;

const
  CRLF = #13#10;
  Ini_ETGUI = 'ExifToolGUI';
  Ini_Settings = 'GUIsettings';
  Ini_Options = 'EToptions';
  IniVersion = 'V6';
  PrevIniVersion = 'V5';
  WorkSpaceTags = 'WorkSpaceTags';
  ETDirectCmd = 'ETdirectCmd';
  UserDefTags = 'FListUserDefColumn';
  FormSizes = 'FormSizes';
  TagList = 'TagList';
  CustomView = 'CustomView';
  PredefinedTags = 'PredefinedTags';
  SelPredefinedTags = 'SelPredefinedTags';
  MarkedTags = 'MarkedTags';
  ExcludeCopyTags = 'ExcludeCopyTags';
  SelExcludeCopyTags = 'SelExcludeCopyTags';
  RemoveTags = 'RemoveTags';
  SelRemoveTags = 'SelRemoveTags';
  CopySingleTags = 'CopySingleTags';
  SelCopySingleTags = 'SelCopySingleTags';

  // Check for IniPath commandLine param. See initialization.
  INIPATHSWITCH = 'IniPath';

var
  GUIini: TMemIniFile;
  lg_StartFolder: string;

function GetParmIniPath: string;
begin
  result := '';
  if (FindCmdLineSwitch(INIPATHSWITCH, result, true)) then
  begin
    result := Copy(result, Pos('=', result) +1);
    if (SameText(result, '%P')) or
       (result = '.') or
       (result = '') then
      result := GetAppPath;
    if (SameText(result, '%T')) then
      result := GetTempDirectory;
    if (SameText(result, '%W')) then
      result := GetCurrentDir;
    result := IncludeTrailingPathDelimiter(result);
  end;
end;

// This function returns the name of the INI file.
// If it doesn't exist, but a previous version exists it returns that name.
function GetIniFilePath(AllowPrevVer: boolean): string;
var
  CurVer, PrevVer, PrevPath: string;
begin
  // Default is ExifToolGuiV6.ini in Profile %AppData%\ExifToolGui
  CurVer := Application.Title + IniVersion + '.ini';

  if (ParmIniPath <> '') then
  begin
    result := ParmIniPath + CurVer;
    exit;
  end;

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

function GUIsettingsRec.Fast3(const FileExt: string): string;
begin
  result := '';
  if (Fast3FileTypes <> '') and
     (Containstext(Fast3FileTypes, FileExt)) then
    result := '-fast3' + CRLF;
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

function ReadWorkSpaceTags(GUIini: TMemIniFile):integer;
var
  Indx, WSCnt: integer;
  Name, Cmd, Help : string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.ReadSectionValues(WorkSpaceTags, TmpItems);
    WSCnt := TmpItems.Count;
    result := WSCnt;
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

function ReadETdirectCmds(CbETDirect: TComboBox; GUIini: TMemIniFile): integer;
var
  Indx, ETcnt: integer;
begin

  ETdirectCmdList.Clear;
  GUIini.ReadSection(ETDirectCmd, CbETDirect.Items);
  ETcnt := CbETDirect.Items.Count;
  result := ETcnt;
  if ETcnt = 0 then
  begin
    CbETDirect.Items.Append('Set Exif:Copyright to [©Year by MyName]');
    ETdirectCmdList.Append('-d %Y "-Exif:Copyright<©$DateTimeOriginal by MyName"');
  end
  else
  begin
    for Indx := 0 to ETcnt - 1 do
      ETdirectCmdList.Append(GUIini.ReadString(ETDirectCmd, CbETDirect.Items[Indx], '?'));
  end;

  // Setup default ET Direct command
  if GUIsettings.ETdirDefCmd > ETdirectCmdList.Count then
    GUIsettings.ETdirDefCmd := -1;
  CbETDirect.ItemIndex := GUIsettings.ETdirDefCmd;
  CbETDirect.OnChange(CbETDirect);
end;

function ReadUserDefTags(GUIini: TMemIniFile): integer;
var
  Indx, UDCnt: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.ReadSectionValues(UserDefTags, TmpItems);
    UDCnt := TmpItems.Count;
    result := UDCnt;
    if (UDCnt = 0) and
       (GUIini.SectionExists(UserDefTags) = false) then
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
    end
    else
    begin
      SetLength(FListColUsr, UDCnt);
      for Indx := 0 to UDCnt - 1 do
      begin
        Tx := TmpItems[Indx];
        FListColUsr[Indx].Caption := NextField(Tx, '=');
        FListColUsr[Indx].Command := NextField(Tx, ' ');
        FListColUsr[Indx].Width := StrToIntDef(Tx, 80);
        FListColUsr[Indx].AlignR := 0;
      end;
    end;
  finally
    TmpItems.Free;
  end;
end;

function ReadCustomViewTags(GUIini: TMemIniFile): integer;
begin
  CustomViewTagList := ReplaceLastChar(GUIini.ReadString(TagList, CustomView, '<'), '<', ' ');
  result := Length(CustomViewTagList);
end;

function ReadPredefinedTags(GUIini: TMemIniFile): integer;
var
  Indx: integer;
begin
  GUIini.ReadSectionValues(PredefinedTags, PredefinedTagList);
  for Indx := 0 to PredefinedTagList.Count -1 do
    PredefinedTagList[Indx] := ReplaceLastChar(PredefinedTagList[Indx], '<', ' ');

  GUIini.ReadSectionValues(SelPredefinedTags, SelPredefinedTagList);
  for Indx := 0 to SelPredefinedTagList.Count -1 do
    SelPredefinedTagList[Indx] := ReplaceLastChar(SelPredefinedTagList[Indx], '<', ' ');

  result := PredefinedTagList.Count;
end;

function ReadMarkedTags(GUIini: TMemIniFile): integer;
begin
  MarkedTagList := ReplaceLastChar(GUIini.ReadString(TagList, MarkedTags, '<'), '<', ' ');
  result := Length(MarkedTagList);
end;

function ReadCopyTags(GUIini: TMemIniFile): integer;
begin
  ExcludeCopyTagListName := GUIini.ReadString(TagList, ExcludeCopyTags, '');

  ExcludeCopyTagList := ReplaceLastChar(PredefinedTagList.Values[ExcludeCopyTagListName], '<', ' ');
  SelExcludeCopyTagList := ReplaceLastChar(GUIini.ReadString(TagList, SelExcludeCopyTags, '<'), '<', ' ');

  result := Length(Trim(ExcludeCopyTagList));
  if (result = 0) then
  begin
    ExcludeCopyTagListName := FMain.MaImportMetaSelected.Caption;
    ExcludeCopyTagList := DefExcludeCopyTags;
    SelExcludeCopyTagList := DefSelExcludeCopyTags;
  end;
end;

function ReadRemoveTags(GUIini: TMemIniFile): integer;
begin
  RemoveTagListName := GUIini.ReadString(TagList, RemoveTags, '');

  RemoveTagList := ReplaceLastChar(PredefinedTagList.Values[RemoveTagListName], '<', ' ');
  SelRemoveTagList := ReplaceLastChar(GUIini.ReadString(TagList, SelRemoveTags, '<'), '<', ' ');

  result := Length(Trim(RemoveTagList));
  if (result = 0) then
  begin
    RemoveTagListName := FMain.MaRemoveMeta.Caption;
    RemoveTagList := DefRemoveTags;
    SelRemoveTagList := DefSelRemoveTags;
  end;
end;

function ReadCopySingleTags(GUIini: TMemIniFile): integer;
begin
  CopySingleTagListName := GUIini.ReadString(TagList, CopySingleTags, '');

  CopySingleTagList := ReplaceLastChar(PredefinedTagList.Values[CopySingleTagListName], '<', ' ');
  SelCopySingleTagList := ReplaceLastChar(GUIini.ReadString(TagList, SelCopySingleTags, '<'), '<', ' ');

  result := Length(Trim(CopySingleTagList));
  if (result = 0) then
  begin
    CopySingleTagListName := FMain.MaImportMetaSingle.Caption;
    CopySingleTagList := DefCopySingleTags;
    SelCopySingleTagList := DefSelCopySingleTags;
  end;
end;

procedure WriteAllFormSizes(GUIini: TMemIniFile);
var
  Indx: integer;
  AForm: TScaleForm;
begin
  for Indx := 0 to Screen.FormCount -1 do
  begin
    if (Screen.Forms[Indx] is TScaleForm) then
    begin
      AForm := Screen.Forms[Indx] as TScaleForm;
      if (AForm.DefWindowSizes.Width <> 0) and
         (AForm.DefWindowSizes.Height <> 0) then
      begin
        GUIini.WriteInteger(FormSizes, AForm.Name + '_Left',   AForm.Left);
        GUIini.WriteInteger(FormSizes, AForm.Name + '_Top',    AForm.Top);
        GUIini.WriteInteger(FormSizes, AForm.Name + '_Width',  AForm.Width);
        GUIini.WriteInteger(FormSizes, AForm.Name + '_Height', AForm.Height);
      end;
    end;
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

// Writing the ET Direct commands
procedure WriteEtDirectCmds(CbETDirect: TComboBox; GUIini: TMemIniFile);
var
  Indx: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.
    TmpItems.Add(Format('[%s]', [ETDirectCmd]));
    for Indx := 0 to ETdirectCmdList.Count -1 do
    begin
      Tx := Format('%s=%s', [CbETDirect.Items[Indx], ETdirectCmdList[Indx]]);
      TmpItems.Add(Tx);
    end;
    GUIini.SetStrings(TmpItems);
  finally
    TmpItems.Free;
  end;
end;

// Writing the User defined fields
procedure WriteUserDefTags(GUIini: TMemIniFile);
var
  Indx: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.
    TmpItems.Add(Format('[%s]', [UserDefTags]));
    for Indx := 0 to Length(FListColUsr) -1 do
    begin
      Tx := Format('%s=%s %d', [FListColUsr[Indx].Caption, FListColUsr[Indx].Command, FListColUsr[Indx].Width]);
      TmpItems.Add(Tx);
    end;
    GUIini.SetStrings(TmpItems);
  finally
    TmpItems.Free;
  end;
end;

procedure WriteTagList(GUIini: TMemIniFile; const AKey, AValue: string);
var
  SectionIndx: integer;
  Section, Value: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.

    Value := Format('%s=%s', [AKey, ReplaceLastChar(AValue, ' ', '<')]);
    Section := Format('[%s]', [TagList]);

    SectionIndx := TmpItems.IndexOf(Section);
    if (SectionIndx > -1) then
      TmpItems.Insert(SectionIndx +1, Value)
    else
    begin
      TmpItems.Add(Section);
      TmpItems.Add(Value);
    end;
    GUIini.SetStrings(TmpItems);
  finally
    TmpItems.Free;
  end;
end;

procedure WriteCustomViewTags(GUIini: TMemIniFile);
begin
  WriteTagList(GUIini, CustomView, CustomViewTagList);
end;

procedure WritePredefinedTags(GUIini: TMemIniFile);
var
  Indx: integer;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.

    // Predefined tags
    TmpItems.Add(Format('[%s]', [PredefinedTags]));
    for Indx := 0 to PredefinedTagList.Count -1 do
      TmpItems.Add(ReplaceLastChar(PredefinedTagList[Indx], ' ', '<'));

    // Predefined Selected tags
    TmpItems.Add(Format('[%s]', [SelPredefinedTags]));
    for Indx := 0 to SelPredefinedTagList.Count -1 do
      TmpItems.Add(ReplaceLastChar(SelPredefinedTagList[Indx], ' ', '<'));

    GUIini.SetStrings(TmpItems);
  finally
    TmpItems.Free;
  end;
end;

procedure WriteMarkedTags(GUIini: TMemIniFile);
begin
  WriteTagList(GUIini, MarkedTags, MarkedTagList);
end;

procedure WriteCopyTags(GUIini: TMemIniFile);
begin
  GUIini.WriteString(TagList, ExcludeCopyTags, ExcludeCopyTagListName);
  WriteTagList(GUIini, SelExcludeCopyTags, SelExcludeCopyTagList);
end;

procedure WriteRemoveTags(GUIini: TMemIniFile);
begin
  GUIini.WriteString(TagList, RemoveTags, RemoveTagListName);
  WriteTagList(GUIini, SelRemoveTags, SelRemoveTagList);
end;

procedure WriteCopySingleTags(GUIini: TMemIniFile);
begin
  GUIini.WriteString(TagList, CopySingleTags, CopySingleTagListName);
  WriteTagList(GUIini, SelCopySingleTags, SelCopySingleTagList);
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
    FListStdColWidth[4] := ReadInteger(Ini_ETGUI, 'StdColWidth4', 120);

    // Column widths Camera settings
    FListColDef1[0].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth0', 80);
    FListColDef1[1].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth1', 80);
    FListColDef1[2].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth2', 64);
    FListColDef1[3].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth3', 64);
    FListColDef1[4].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth4', 48);
    FListColDef1[5].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth5', 73);
    FListColDef1[6].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth6', 73);
    FListColDef1[7].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth7', 56);
    FListColDef1[8].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth8', 88);
    FListColDef1[9].Width := ReadInteger(Ini_ETGUI, 'Def1ColWidth9', 80);

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

    if N > 0 then
      WindowState := wsMaximized;
  end;
end;

procedure ReadWindowSizes(const AIniFile: TMemIniFile; AForm: TScaleForm; DefaultPos: TRect);
begin
  with AIniFile do
  begin
    AForm.Left    := ReadInteger(FormSizes, AForm.Name + '_Left',   DefaultPos.Left);
    AForm.Top     := ReadInteger(FormSizes, AForm.Name + '_Top',    DefaultPos.Top);
    AForm.Width   := ReadInteger(FormSizes, AForm.Name + '_Width',  DefaultPos.Width);
    AForm.Height  := ReadInteger(FormSizes, AForm.Name + '_Height', DefaultPos.Height);
  end;
end;

procedure ReadGUIini;
var
  Indx: integer;
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
          Indx := pos('|', Tx);
          if Indx > 0 then
          begin
            CBoxFileFilter.Items.Append(LeftStr(Tx, Indx - 1));
            Delete(Tx, 1, Indx);
          end
          else
            CBoxFileFilter.Items.Append(Tx);
        until Indx = 0;
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
            Indx := 96;
          1:
            Indx := 128;
          2:
            Indx := 160;
          3:
            Indx := 256;
          4:
            Indx := 512;
        else
          Indx := 96;
        end;
        FMain.ShellList.ThumbNailSize := Indx;
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
        // Fast3FileTypes. Used for filelist and metadata panel. Only editable in INI file
        Fast3FileTypes := ReadString(Ini_Settings, 'Fast3FileTypes','*.GPX|*.KML');

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
        SetSeparator(ReadString(Ini_Options, 'KeySeparator', '*'));
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
      ReadUserDefTags(GUIini);

      // --- ETdirect commands---
      ReadEtDirectCmds(CBoxETdirect, GUIini);

      // --- WorkSpace tags---
      ReadWorkSpaceTags(GUIini);

      // --- CustomView tags---
      ReadCustomViewTags(GUIini);

      // --- Predefined tags---
      ReadPredefinedTags(GUIini);

      // --- Marked tags---
      ReadMarkedTags(GUIini);

      // -- ExcludeCopyTags & SelExcludeCopyTags
      ReadCopyTags(GUIini);

      // -- RemoveTags & SelRemoveTags
      ReadRemoveTags(GUIini);

      // -- CopySingleTags & SelCopySingleTags
      ReadCopySingleTags(GUIini);

      // ---GeoCode
      ReadGeoCodeSettings(GUIini);
    end;
  finally
    GUIini.Free;
    TmpItems.Free;
  end;
end;

procedure ReadFormSizes(AForm: TScaleForm; DefaultPos: TRect);
begin
  try
    GUIini := TMemIniFile.Create(GetIniFilePath(True), TEncoding.UTF8);
  except
    GUIini := TMemIniFile.Create(GetIniFilePath(True));
  end;

  try
    ReadWindowSizes(GUIini, AForm, DefaultPos);
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
var
  TempIni: TMemIniFile;
  Indx: integer;
  AForm: TScaleForm;
  DefSize: TRect;
begin
  TempIni := TMemIniFile.Create('NUL'); // Should not exist, forcing all values to default
  try
    ReadMainWindowSizes(TempIni);

    // First do Main form.
    if (Application.MainForm is TScaleForm) then
    begin
      AForm := Application.MainForm as TScaleForm;
      ReadWindowSizes(TempIni, AForm, AForm.DefWindowSizes);
    end;

    // Now others
    for Indx := 0 to Screen.FormCount -1 do
    begin
      if (Screen.Forms[Indx] is TScaleForm) then
      begin
        AForm := Screen.Forms[Indx] as TScaleForm;
        DefSize := AForm.DefWindowSizes;
        if (AForm.Name <> Application.MainForm.Name) and
           (DefSize.Width <> 0) and
           (DefSize.Height <> 0) then
          ReadWindowSizes(TempIni, AForm, DefSize);
      end;
    end;

  finally
    TempIni.Free;
  end;
end;

function SaveGUIini: boolean;
var
  I, N: integer;
  Tx: string;
begin
  result := true;
  if (DontSaveIni) then
    exit;
  try
    // Recreate the INI file, by deleting first
    System.SysUtils.DeleteFile(GetIniFilePath(false));

    GUIini := TMemIniFile.Create(GetIniFilePath(false), TEncoding.UTF8);
    try
      with GUIini, FMain do
      begin
        // Main form settings, Except Form self
        WriteBool(Ini_ETGUI, 'StartMax', (WindowState = wsMaximized));
        WriteInteger(Ini_ETGUI, 'BrowseWidth', AdvPanelBrowse.Width);
        WriteInteger(Ini_ETGUI, 'PreviewHeight', AdvPagePreview.Height);
        WriteInteger(Ini_ETGUI, 'MetadataWidth', AdvPageMetadata.Width);
        WriteInteger(Ini_ETGUI, 'MetadataTagWidth', MetadataList.ColWidths[0]);
        WriteString(Ini_ETGUI, 'DefaultDir', ShellList.path);

        // Write all form sizes to INI
        WriteAllFormSizes(GUIini);

        // Std (file list) col widths
        WriteInteger(Ini_ETGUI, 'StdColWidth0', FListStdColWidth[0]);
        WriteInteger(Ini_ETGUI, 'StdColWidth1', FListStdColWidth[1]);
        WriteInteger(Ini_ETGUI, 'StdColWidth2', FListStdColWidth[2]);
        WriteInteger(Ini_ETGUI, 'StdColWidth3', FListStdColWidth[3]);
        WriteInteger(Ini_ETGUI, 'StdColWidth4', FListStdColWidth[4]);

        // Column widths Camera settings
        WriteInteger(Ini_ETGUI, 'Def1ColWidth0', FListColDef1[0].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth1', FListColDef1[1].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth2', FListColDef1[2].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth3', FListColDef1[3].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth4', FListColDef1[4].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth5', FListColDef1[5].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth6', FListColDef1[6].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth7', FListColDef1[7].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth8', FListColDef1[8].Width);
        WriteInteger(Ini_ETGUI, 'Def1ColWidth9', FListColDef1[9].Width);

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
          WriteString(Ini_Settings, 'Fast3FileTypes', Fast3FileTypes);
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
        WriteString(Ini_Options, 'KeySeparator', ET_Options.GetSeparator);
        WriteBool(Ini_Options, 'IgnoreErrors', MaIgnoreErrors.Checked);
        WriteBool(Ini_Options, 'GPSinDecimal', MaShowGPSdecimal.Checked);
        WriteBool(Ini_Options, 'ShowSorted', MaShowSorted.Checked);
        WriteBool(Ini_Options, 'ShowComposite', MaShowComposite.Checked);
        WriteBool(Ini_Options, 'NotDuplicated', MaNotDuplicated.Checked);
        WriteBool(Ini_Options, 'APIWindowsWideFile', MaAPIWindowsWideFile.Checked);
        WriteBool(Ini_Options, 'APILargeFileSupport', MaAPILargeFileSupport.Checked);
        WriteString(Ini_Options, 'CustomOptions', ET_Options.ETCustomOptions);

        // Write User defined fields
        WriteUserDefTags(GUIini);

        // Write Et Direct commands
        WriteETDirectCmds(CBoxETdirect, GuiIni);

        // Workspace tags
        WriteWorkSpaceTags(GUIini);

        // Custom view tags
        WriteCustomViewTags(GUIini);

        // Predefined Tags
        WritePredefinedTags(GUIini);

        // Marked Tags
        WriteMarkedTags(GUIini);

        // -- ExcludeCopyTags & SelExcludeCopyTags
        WriteCopyTags(GUIini);

        // -- RemoveTags & SelRemoveTags
        WriteRemoveTags(GUIini);

        // -- CopySingleTags & SelCopySingleTags
        WriteCopySingleTags(GUIini);

      end;
      WriteGeoCodeSettings(GUIini);
      GUIini.UpdateFile;
    finally
      GUIini.Free;
    end;

  except
    on E: Exception do
    begin
      result := false;
      ShowMessage(StrCannotSaveGUI + #10 + E.Message);
    end;
  end;
end;

function GetHrIniData(AIniData: TIniData): string;
begin
  case (AIniData) of
    TIniData.idWorkSpace:
      result := StrWorkspace;
    TIniData.idETDirect:
      result := StrETDirect;
    TIniData.idUserDefined:
      result := StrUserDef;
    TIniData.idCustomView:
      result := StrCustomView;
    TIniData.idPredefinedTags:
      result := StrPredefinedTags;
  end;
end;

function LoadIni(IniFName: string; AIniData: array of TIniTagsData): boolean;
var
  LoadOK: boolean;
  ThisIniTag: TIniTagsData;
begin
  result := false;
  if not FileExists(IniFName) then
    exit;

  GUIini := TMemIniFile.Create(IniFName, TEncoding.UTF8);
  try
    for ThisIniTag in AIniData do
    begin
      case ThisIniTag of
        TIniTagsData.idtWorkSpace:        LoadOK := (ReadWorkSpaceTags(GuiIni) <> 0);
        TIniTagsData.idtETDirect:         LoadOK := (ReadETdirectCmds(Fmain.CBoxETdirect, GuiIni) <> 0);
        TIniTagsData.idtUserDefined:      LoadOK := (ReadUserDefTags(GuiIni) <> 0);
        TIniTagsData.idtCustomView:       LoadOK := (ReadCustomViewTags(GuiIni) <> 0);
        TIniTagsData.idtMarked:           LoadOK := (ReadMarkedTags(GuiIni) <> 0);
        TIniTagsData.idtPredefinedTags:   LoadOK := (ReadPredefinedTags(GUIini) <> 0);
        TIniTagsData.idtRemoveTags:       LoadOK := (ReadRemoveTags(GuiIni) <> 0);
        TIniTagsData.idtCopySingleTags:   LoadOK := (ReadCopySingleTags(GuiIni) <> 0);
        TIniTagsData.idtCopyTags:         LoadOK := (ReadCopyTags(GuiIni) <> 0);
      else
        LoadOK := false;
      end;
      result := result or LoadOK;
    end;
  finally
    GUIini.Free;
  end;
end;

function LoadIniDialog(OpenFileDlg: TOpenDialog; AIniData: TIniData; ShowMsg: boolean = true): boolean;
var
  HrIniData: string;
  IniLoaded: boolean;
begin
  result := false;
  IniLoaded := false;

  HrIniData := GetHrIniData(AIniData);
  with OpenFileDlg do
  begin
    InitialDir := WrkIniDir;
    Filter := 'Ini file|*.ini';
    Title := Format(StrLoadIniDefine, [HrIniData]);
    if Execute then
    begin
      case AIniData of
        TIniData.idWorkSpace:
          IniLoaded := LoadIni(FileName, [TIniTagsData.idtWorkSpace]);
        TIniData.idETDirect:
          IniLoaded := LoadIni(FileName, [TIniTagsData.idtETDirect]);
        TIniData.idUserDefined:
          IniLoaded := LoadIni(FileName, [TIniTagsData.idtUserDefined]);
        TIniData.idCustomView:
          IniLoaded := LoadIni(FileName, [TIniTagsData.idtCustomView]);
        TIniData.idPredefinedTags:
          IniLoaded := LoadIni(FileName, [TIniTagsData.idtPredefinedTags,
                                          TIniTagsData.idtMarked,
                                          TIniTagsData.idtRemoveTags,
                                          TIniTagsData.idtCopySingleTags,
                                          TIniTagsData.idtCopyTags]);
      end;
      if IniLoaded then
      begin
        if (ShowMsg) then
          ShowMessage(Format(StrNewIniLoaded, [HrIniData]))
        else
          result := true
      end
      else
        ShowMessage(StrIniFileNotChanged);
      WrkIniDir := ExtractFileDir(FileName);
    end;
  end;
end;

function SaveIni(IniFName: string; AIniData: array of TIniTagsData): boolean;
var
  ThisIniTag: TIniTagsData;
begin
  result := true;
  try
    System.SysUtils.DeleteFile(IniFName);
    GUIini := TMemIniFile.Create(IniFName, TEncoding.UTF8);
    try
      for ThisIniTag in AIniData do
      begin
        case ThisIniTag of
          TIniTagsData.idtWorkSpace:      WriteWorkSpaceTags(GuiIni);
          TIniTagsData.idtETDirect:       WriteEtDirectCmds(FMain.CBoxETdirect, GuiIni);
          TIniTagsData.idtUserDefined:    WriteUserDefTags(GuiIni);
          TIniTagsData.idtCustomView:     WriteCustomViewTags(GuiIni);
          TIniTagsData.idtPredefinedTags: WritePredefinedTags(GuiIni);
          TIniTagsData.idtMarked:         WriteMarkedTags(GuiIni);
          TIniTagsData.idtRemoveTags:     WriteRemoveTags(GuiIni);
          TIniTagsData.idtCopySingleTags: WriteCopySingleTags(GuiIni);
          TIniTagsData.idtCopyTags:       WriteCopyTags(GuiIni);
        end;
      end;
      GUIini.UpdateFile;
    finally
      GUIini.Free;
    end;
  except
    result := false;
  end;
end;

function SaveIniDialog(SaveFileDlg: TSaveDialog; AIniData: TIniData; ShowMsg: boolean = true): boolean;
var
  DoSave: boolean;
  IsOK: boolean;
  IniSaved: boolean;
  HrIniData: string;
begin
  result := false;
  IniSaved := false;

  HrIniData := GetHrIniData(AIniData);
  with SaveFileDlg do
  begin
    DefaultExt := 'ini';
    InitialDir := WrkIniDir;
    Filter := 'Ini file|*.ini';
    Title := Format(StrSaveIniDefine, [HrIniData]);
    repeat
      IsOK := false;
      DoSave := Execute;
      InitialDir := ExtractFileDir(FileName);
      if DoSave then
      begin
        IsOK := (ExtractFileName(FileName) <> ExtractFileName(GetIniFilePath(false)));
        if not IsOK then
          ShowMessage(Format(StrUseAnotherNameForIni, [HrIniData]));
      end;
    until not DoSave or IsOK;
    if DoSave then
    begin
      case AIniData of
        TIniData.idWorkSpace:
          IniSaved := SaveIni(FileName, [TIniTagsData.idtWorkSpace]);
        TIniData.idETDirect:
          IniSaved := SaveIni(FileName, [TIniTagsData.idtETDirect]);
        TIniData.idUserDefined:
          IniSaved := SaveIni(FileName, [TIniTagsData.idtUserDefined]);
        TIniData.idCustomView:
          IniSaved := SaveIni(FileName, [TIniTagsData.idtCustomView]);
        TIniData.idPredefinedTags:
          IniSaved := SaveIni(FileName, [TIniTagsData.idtPredefinedTags,
                                         TIniTagsData.idtMarked,
                                         TIniTagsData.idtRemoveTags,
                                         TIniTagsData.idtCopySingleTags,
                                         TIniTagsData.idtCopyTags]);
      end;
      if IniSaved then
      begin
        if (ShowMsg) then
          ShowMessage(Format(StrIniDefinition, [HrIniData]))
        else
          result := true;
      end
      else
        ShowMessage(Format(StrIniDefNotSaved, [HrIniData]));
      WrkIniDir := ExtractFileDir(FileName);
    end;
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

initialization

begin
  ETdirectCmdList := TStringList.Create;
  PredefinedTagList := TStringList.Create;
  SelPredefinedTagList := TStringList.Create;
  ParmIniPath := GetParmIniPath;
end;

finalization

begin
  ETdirectCmdList.Free;
  PredefinedTagList.Free;
  SelPredefinedTagList.Free;
end;

end.
