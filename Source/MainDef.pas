unit MainDef;

interface

uses
  System.Classes, Winapi.Windows, Vcl.Dialogs, Vcl.ComCtrls, ExifTool, GEOMap, UnitLangResources, UnitScaleForm,
  ExifToolsGui_AutoComplete;

const

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

  DefDiffTags =
    '-System:All ';
  DefSelDiffTags =
    '-System:All ';

  DefFileFilter =
    '*.JPG;*.JPE;*.JPEG;*.TIF;*.TIFF|*.CRW;*.CR2;*.CR3|*.PEF|*.ARW;*.SR2;*.SRF|*.NEF;*.NRW|*.DNG|*.MP4|' +
    '*.JPG;*.CRW;*.CR2;*.CR3|*.JPG;*.PEF|*.JPG;*.ARW;*.SR2;*.SRF|*.JPG;*.NEF;*.NRW|*.JPG;*.DNG|' +
    '*.JPG;*.MP4;/s';

  DefThumbNailSizes: array of integer = [96, 128, 160, 256, 512];
  ThumbNailPix = 'pix';

  DefSelExcludeCopyTags = '';

type
  TIniTagsData = (idtWorkSpace, idtETDirect, idtFileLists, idtCustomView, idtPredefinedTags,
                  idtMarked, idtRemoveTags, idtCopySingleTags, idtCopyTags, idtDiffTags);

  TIniData = (idWorkSpace, idETDirect, idFileLists, idCustomView, idPredefinedTags);
  TSelIniData = set of TIniData;

  GUIsettingsRec = record
    Language: string[7];
    AutoRotatePreview: boolean;
    DefStartupUse: boolean;
    DefStartupDir: string;
    DefExportUse: boolean;
    DefExportDir: string;
    UseExitDetails: boolean;
    ThumbAutoGenerate: boolean;
    ThumbCleanSet: string[4];
    DetailsSel: integer;
    FileFilters: string;
    FilterStartup: integer;
    FilterSel: integer;
    AutoIncLine: boolean;
    EditLine: boolean;
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
    EnableUnsupported: boolean; // Deprecated.
    ShowBreadCrumb: boolean;
    MinimizeToTray: boolean;
    SingleInstanceApp: boolean;
    ShowBalloon: boolean;
    AllowNonMSWicCodec: boolean;
    SelIniData: TSelIniData;
    ETDAutoComp: TAutoCompRec;
    WSAutoComp: TAutoCompRec;
    function FileFilter: string;
    function SaveFileFilter: string;
    function CanShowHidden: boolean;
    function GetCustomConfig: string;
    function Fast3(const FileExt: string): string;
  end;

type
  TQuickTagRec = record
    Caption:    string;
    Command:    string;
    Help:       string;
    NoEdit:     boolean;
    AutoComp:   TAutoCompRec;
  end;

var
  GUIsettings: GUIsettingsRec;
  ETdirectCmdList: TStringList;

  QuickTags: array of TQuickTagRec;
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

  DiffTagListName: string;
  DiffTagList: string;
  SelDiffTagList: string;

function GetIniFilePath(AllowPrevVer: boolean): string;
procedure ReadFormSizes(AForm: TScaleForm; DefaultPos: TRect);
function ReadSingleInstanceApp: boolean;
procedure ResetWindowSizes;
procedure ReadGUIini;
function SaveGUIini: boolean;
function LoadIniDialog(OpenFileDlg: TOpenDialog): boolean;
function SaveIniDialog(SaveFileDlg: TSaveDialog; SelIniData: TSelIniData): boolean;

implementation

uses
  System.SysUtils, System.StrUtils, System.IniFiles,
  Vcl.Forms, Vcl.StdCtrls,
  Main, UnitColumnDefs, ExifToolsGUI_Utils, ExifToolsGui_FileListColumns, ExifInfo, LogWin;

const
  CRLF = #13#10;
  Ini_ETGUI = 'ExifToolGUI';
  Ini_Settings = 'GUIsettings';
  Ini_Options = 'EToptions';
  IniVersion = 'V6';
  PrevIniVersion = 'V5';
  WorkSpaceTags = 'WorkSpaceTags';
  ETDirectCmd = 'ETdirectCmd';
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
  DiffTags = 'DiffTags';
  SelDiffTags = 'SelDiffTags';

  // Check for IniPath commandLine param. See initialization.
  INIPATHSWITCH = 'IniPath';

var
  GUIini: TMemIniFile;

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

function GUIsettingsRec.FileFilter: string;
begin
  result := StrShowAllFiles;
  with TStringList.Create do
  begin
    Text := FileFilters;
    if (FilterSel < Count) then
      result := Strings[FilterSel];
    Free;
  end;
end;

function GUIsettingsRec.SaveFileFilter: string;
begin
  with TStringList.Create do
  begin
    Text := FileFilters;
    if (Count > 0) then
      Delete(0);
      result := ReplaceAll(Text, [CRLF], ['|']);
    Free;
  end;
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

function SetQuickTag(const AIndex: integer;
                     const ACaption, ACommand: string;
                     const AHelp: string = '';
                     const AOptions: word = 0;
                     const AcList: string = ''): integer;
begin
  result := AIndex +1;

  // Resize Array?
  if (result > Length(QuickTags)) then
    SetLength(QuickTags, result);

  QuickTags[AIndex].Caption   := ACaption;
  QuickTags[AIndex].Command   := Trim(ACommand);
  QuickTags[AIndex].Help      := AHelp;
  QuickTags[AIndex].AutoComp.AcOptions := AOptions;
  QuickTags[AIndex].AutoComp.SetAcList(AcList);
  // Set NoEdit
  QuickTags[AIndex].NoEdit    := (RightStr(ACaption, 1) = '?');
  QuickTags[AIndex].NoEdit    := QuickTags[result -1].NoEdit or
                                 (SameText(LeftStr(ACommand, 4), '-GUI'));
end;

function ReadWorkSpaceTags(GUIini: TMemIniFile):integer;
var
  Indx, WSCnt: integer;
  Name, Cmd, Help, Tmp: string;
  AcOptions: Word;
  AcList: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIsettings.WSAutoComp.AcOptions := GUIini.ReadInteger('WorkSpaceAutoComplete',
                                                           'Options',
                                                           Ord(TAutoCompleteMode.acAutoSuggestAppend) + acAutoCorrect + acAutoPopulate);
    GUIini.ReadSectionValues(WorkSpaceTags, TmpItems);
    WSCnt := TmpItems.Count;
    result := WSCnt;

    if (WSCnt = 0) and
       (GUIini.SectionExists(WorkSpaceTags) = false) then
    begin
      WSCnt :=  SetQuickTag(WSCnt, 'EXIF', GUI_SEP);
      WSCnt :=  SetQuickTag(WSCnt, 'Make', '-exif:Make');
      WSCnt :=  SetQuickTag(WSCnt, 'Model', '-exif:Model');
      WSCnt :=  SetQuickTag(WSCnt, 'LensModel', '-exif:LensModel');
      WSCnt :=  SetQuickTag(WSCnt, 'ExposureTime', '-exif:ExposureTime', '[1/50] or [0.02]',
                Ord(acAutoSuggestAppend), '1/15/n1/30/n1/60/n1/90/n1/125/n/1/250/n1/500/n1/1000/n1/2000/n1/4000/n');
      WSCnt :=  SetQuickTag(WSCnt, 'FNumber', '-exif:FNumber','',
                Ord(acAutoSuggestAppend), '1.4/n2.0/n2.8/n4.0/n5.6/n8.0/n11.0/n16.0/n22.0/n');
      WSCnt :=  SetQuickTag(WSCnt, 'ISO', '-exif:ISO', '',
                Ord(acAutoSuggestAppend), '25/n50/n100/n200/n400/n800/n1600/n3200/n6400/n');
      WSCnt :=  SetQuickTag(WSCnt, 'FocalLength', '-exif:FocalLength', '[28] -mm not necessary',
                Ord(acAutoSuggestAppend), '15/n18/n20/n28/n35/n40/n50/n70/n85/n100/n135/n150/n200/n300/n400/n');
      WSCnt :=  SetQuickTag(WSCnt, 'Flash#', '-exif:Flash', '[ 0 ]=No flash, [ 1 ]=Flash fired');
      WSCnt :=  SetQuickTag(WSCnt, 'Orientation#', '-exif:Orientation', '[ 1 ]=0°, [ 3 ]=180°, [ 6 ]=+90°, [ 8 ]=-90°');
      WSCnt :=  SetQuickTag(WSCnt, 'DateTimeOriginal', '-exif:DateTimeOriginal', '[2012:01:14 20:00:00]');
      WSCnt :=  SetQuickTag(WSCnt, 'CreateDate', '-exif:CreateDate', '[2012:01:14 20:00:00]');
      WSCnt :=  SetQuickTag(WSCnt, 'Artist*', '-exif:Artist', 'Bogdan Hrastnik');
      WSCnt :=  SetQuickTag(WSCnt, 'Copyright', '-exif:Copyright', 'Use Alt+0169 to get © character');
      WSCnt :=  SetQuickTag(WSCnt, 'Software', '-exif:Software');
      WSCnt :=  SetQuickTag(WSCnt, 'Geotagged?', '-Gps:GPSLatitude');

      WSCnt :=  SetQuickTag(WSCnt, 'About photo', GUI_SEP);
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
        Tmp   := TmpItems[Indx];
        Name  := NextField(Tmp, '=');
        Cmd   := NextField(Tmp, '^');
        Help  := NextField(Tmp, '^');
        // AutoComplete options available?
        if (Pos('^', Tmp) > 0) then
          AcOptions := StrToIntDef(NextField(Tmp, '^'), 0)
        else
          AcOptions := 0;
        // AutoComplete list available?
        if (Pos('^', Tmp) > 0) then
          AcList := NextField(Tmp, '^')
        else
          AcList := Tmp;
        SetQuickTag(Indx, Name, Cmd, Help, AcOptions, AcList);
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
  GUIsettings.ETDAutoComp.AcOptions := GUIini.ReadInteger('ETDirectAutoComplete',
                                                          'Options',
                                                          Ord(TAutoCompleteMode.acAutoSuggestAppend) + acAutoCorrect);

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

    PredefinedTagList.AddPair(ExcludeCopyTagListName, DefExcludeCopyTags);
    SelPredefinedTagList.AddPair(DiffTagListName, DefSelExcludeCopyTags);
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

    PredefinedTagList.AddPair(RemoveTagListName, DefRemoveTags);
    SelPredefinedTagList.AddPair(RemoveTagListName, DefSelRemoveTags);
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

    PredefinedTagList.AddPair(CopySingleTagListName, DefCopySingleTags);
    SelPredefinedTagList.AddPair(CopySingleTagListName, DefSelCopySingleTags);
  end;
end;

function ReadDiffTags(GUIini: TMemIniFile): integer;
begin
  DiffTagListName := GUIini.ReadString(TagList, DiffTags, '');

  DiffTagList := ReplaceLastChar(PredefinedTagList.Values[DiffTagListName], '<', ' ');
  SelDiffTagList := ReplaceLastChar(GUIini.ReadString(TagList, SelDiffTags, '<'), '<', ' ');

  result := Length(Trim(DiffTagList));
  if (result = 0) then
  begin
    DiffTagListName := SrCmdVerbDiff;
    DiffTagList := DefDiffTags;
    SelDiffTagList := DefSelDiffTags;

    PredefinedTagList.AddPair(DiffTagListName, DefDiffTags);
    SelPredefinedTagList.AddPair(DiffTagListName, DefSelDiffTags);
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
    GUIini.WriteInteger('WorkSpaceAutoComplete',
                        'Options',
                        GUIsettings.WSAutoComp.AcOptions);

    GUIini.GetStrings(TmpItems); // Get strings written so far.
    TmpItems.Add(Format('[%s]', [WorkSpaceTags]));
    for Indx := 0 to Length(QuickTags) - 1 do
    begin
      Tx := Format('%s=%s^%s^%d^%s', [QuickTags[Indx].Caption,
                                      QuickTags[Indx].Command,
                                      QuickTags[Indx].Help,
                                      QuickTags[Indx].AutoComp.AcOptions,
                                      QuickTags[Indx].AutoComp.AcString]);
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
  GUIini.WriteInteger('ETDirectAutoComplete',
                      'Options',
                      GUIsettings.ETDAutoComp.AcOptions);

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

procedure WriteDiffTags(GUIini: TMemIniFile);
begin
  GUIini.WriteString(TagList, DiffTags, DiffTagListName);
  WriteTagList(GUIini, SelDiffTags, SelDiffTagList);
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
  DefaultDir: string;
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
      GUIsettings.InitialDir := DefaultDir;

      ReadMainWindowSizes(GUIini);

      with GUIsettings do
      begin
        Language := ReadString(Ini_Settings, 'Language', '');
        ET.Options.SetLangDef(Language);
        AutoRotatePreview := ReadBool(Ini_Settings, 'AutoRotatePreview', false);
        FileFilters := StrShowAllFiles + #10 +
                       ReplaceAll(ReadString(Ini_Settings, 'FileFilters', DefFileFilter), ['|'], [#10]);
        FilterStartup := ReadInteger(Ini_Settings, 'FilterStartup', 0);
        DefStartupUse := ReadBool(Ini_Settings, 'DefStartupUse', false);
        DefStartupDir := ReadString(Ini_Settings, 'DefStartupDir', 'c:\');
        if DefStartupUse then
          GUIsettings.InitialDir := DefStartupDir;
        GUIsettings.ETOverrideDir := ReadString(Ini_Settings, 'ETOverrideDir', '');
        GUIsettings.ETCustomConfig := ReadString(Ini_Settings, 'ETCustomConfig', '');
        // Note: Not configurable by user, only in INI
        GUIsettings.ETTimeOut := ReadInteger(Ini_Settings, 'ETTimeOut', 5000);
        DefExportUse := ReadBool(Ini_Settings, 'DefExportUse', false);
        DefExportDir := ReadString(Ini_Settings, 'DefExportDir', '');
        FMain.ShellList.ThumbNailSize := ReadInteger(Ini_Settings, 'ThumbsSize', 96);
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
          DetailsSel := ReadInteger(Ini_Settings, 'DetailsSel', 0);
          FilterSel := FilterStartup;
          FMain.ShellList.ViewStyle := TviewStyle(ReadInteger(Ini_Settings, 'ViewStyle', 3));
        end
        else
        begin
          DetailsSel := 0;
          FilterSel := 0;
          FMain.ShellList.ViewStyle := TViewStyle.vsReport;
        end;
        AutoIncLine := ReadBool(Ini_Settings, 'AutoIncLine', True);
        EditLine := ReadBool(Ini_Settings, 'EditLine', False);
        DblClickUpdTags := ReadBool(Ini_Settings, 'DblClickUpdTags', False);
        ETdirDefCmd := ReadInteger(Ini_Settings, 'ETdirDefCmd', -1);
        ETdirMode := ReadInteger(Ini_Settings, 'ETdirMode', 0);
        CmbETDirectMode.ItemIndex := GUIsettings.ETdirMode;

        // Colors of the Bar charts. Only editable in INI file
        TryStrToInt(ReadString(Ini_Settings, 'CLFnumber', '$C0DCC0'), CLFnumber);
        TryStrToInt(ReadString(Ini_Settings, 'CLFocal', '$FFDAB6'), CLFocal);
        TryStrToInt(ReadString(Ini_Settings, 'CLISO', '$D0D0D0'), CLISO);
        // Fast3FileTypes. Used for filelist and metadata panel. Only editable in INI file
        Fast3FileTypes := ReadString(Ini_Settings, 'Fast3FileTypes', '*.GPX|*.KML');

        ShowFolders := ReadBool(Ini_Settings, 'ShowFolders', false);
        ShowHidden := ReadBool(Ini_Settings, 'ShowHidden', false);
        EnableUnsupported := GUIini.ReadBool(Ini_Settings, 'EnableUnsupported', false);

        ShowBreadCrumb := ReadBool(Ini_Settings, 'ShowBreadCrumb', true);
        MinimizeToTray := ReadBool(Ini_Settings, 'MinimizeToTray', false);
        SingleInstanceApp := ReadBool(Ini_Settings, 'SingleInstanceApp', false);
        ShowBalloon := ReadBool(Ini_Settings, 'ShowBalloon', true);
        AllowNonMSWicCodec := ReadBool(Ini_Settings, 'AllowNonMSWicCodec', false);
        // The set TselIniData should be byte set!
        Byte(SelIniData) := ReadInteger(Ini_Settings, 'SelIniData', 0);
        Application.HintHidePause := ReadInteger(Ini_Settings, 'HintHidePause', 5000);
      end;

      with ET.Options do
      begin
        MaDontBackup.Checked := ReadBool(Ini_Options, 'DontBackup', True);
        SetBackupMode(MaDontBackup.Checked);
        MaPreserveDateMod.Checked := ReadBool(Ini_Options, 'PreserveDateMod', false);
        SetFileDate(MaPreserveDateMod.Checked);
        SetSeparator(ReadString(Ini_Options, 'KeySeparator', '*'));
        MaIgnoreErrors.Checked := ReadBool(Ini_Options, 'IgnoreErrors', false);
        SetMinorError(MaIgnoreErrors.Checked);
        MaShowGPSdecimal.Checked := ReadBool(Ini_Options, 'GPSinDecimal', True);
        ET.Options.SetGpsFormat(MaShowGPSdecimal.Checked);
        MaShowSorted.Checked := ReadBool(Ini_Options, 'ShowSorted', false);
        MaShowComposite.Checked := ReadBool(Ini_Options, 'ShowComposite', false);
        MaNotDuplicated.Checked := ReadBool(Ini_Options, 'NotDuplicated', false);
        MaAPIWindowsWideFile.Checked := ReadBool(Ini_Options, 'APIWindowsWideFile', true);
        SetApiWindowsWideFile(MaAPIWindowsWideFile.Checked);
        MaAPIWindowsLongPath.Checked := ReadBool(Ini_Options, 'APIWindowsLongPath', true);
        SetApiWindowsLongPath(MaAPIWindowsLongPath.Checked);
        MaAPILargeFileSupport.Checked := ReadBool(Ini_Options, 'APILargeFileSupport', false);
        SetApiLargeFileSupport(MaAPILargeFileSupport.Checked);
        SetCustomOptions(ReadString(Ini_Options, 'CustomOptions', ''));
      end;

      // Standard, Camera, Location, About and UserDef settings
      ReadFileLists(FMain.ShellList.Handle, GUIini);

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

      // -- Diff
      ReadDiffTags(GUIini);

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
    ResetAllColumnWidths(FMain.ShellList.Handle);

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

// First write everything to stream. If all OK write stream to disk.
// Prevents losing ini file, in case an exception occurs.
function SaveGUIini: boolean;
var
  IniStream: TMemoryStream;
begin
  result := true;
  if (DontSaveIni) then
    exit;

  try
    IniStream := TMemoryStream.Create;
    GUIini := TMemIniFile.Create(IniStream, TEncoding.UTF8);
    try
      with GUIini, FMain do
      begin
        // Main form settings, Except Form self
        WriteBool(Ini_ETGUI, 'StartMax', (WindowState = wsMaximized));
        WriteInteger(Ini_ETGUI, 'BrowseWidth', AdvPanelBrowse.Width);
        WriteInteger(Ini_ETGUI, 'PreviewHeight', AdvPagePreview.Height);
        WriteInteger(Ini_ETGUI, 'MetadataWidth', AdvPageMetadata.Width);
        WriteInteger(Ini_ETGUI, 'MetadataTagWidth', MetadataList.ColWidths[0]);
        WriteString(Ini_ETGUI, 'DefaultDir', ShellList.ShellPath);

        // Write all form sizes to INI
        WriteAllFormSizes(GUIini);

        with GUIsettings do
        begin
          EnableUnsupported := UnsupportedEnabled;

          WriteString(Ini_Settings, 'Language', Language);
          WriteBool(Ini_Settings, 'AutoRotatePreview', AutoRotatePreview);
          WriteString(Ini_Settings, 'FileFilters', SaveFileFilter);
          WriteInteger(Ini_Settings, 'FilterStartup', FilterStartup);
          WriteBool(Ini_Settings, 'DefStartupUse', DefStartupUse);
          WriteString(Ini_Settings, 'DefStartupDir', DefStartupDir);
          WriteString(Ini_Settings, 'ETOverrideDir', ETOverrideDir);
          WriteString(Ini_Settings, 'ETCustomConfig', ETCustomConfig);

          WriteInteger(Ini_Settings, 'ETTimeOut', ETTimeOut);
          WriteBool(Ini_Settings, 'DefExportUse', DefExportUse);
          WriteString(Ini_Settings, 'DefExportDir', DefExportDir);
          WriteInteger(Ini_Settings, 'ThumbsSize', FMain.ShellList.ThumbNailSize);
          WriteBool(Ini_Settings, 'ThumbAutoGenerate', ThumbAutoGenerate);
          WriteString(Ini_Settings, 'ThumbCleanSet', ThumbCleanSet);

          WriteBool(Ini_Settings, 'EnableGMap', EnableGMap);
          WriteString(Ini_Settings, 'DefGMapHome', DefGMapHome);
          WriteString(Ini_Settings, 'GUIStyle', GuiStyle);

          WriteBool(Ini_Settings, 'UseExitDetails', UseExitDetails);
          WriteInteger(Ini_Settings, 'DetailsSel', DetailsSel);
          WriteInteger(Ini_Settings, 'ViewStyle', Ord(Fmain.ShellList.ViewStyle));
          WriteBool(Ini_Settings, 'AutoIncLine', AutoIncLine);
          WriteBool(Ini_Settings, 'EditLine', EditLine);
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
          WriteBool(Ini_Settings, 'AllowNonMSWicCodec', AllowNonMSWicCodec);
          // Next Typecast works only for byte sets!
          WriteInteger(Ini_Settings, 'SelIniData', byte(SelIniData));

          WriteInteger(Ini_Settings, 'HintHidePause', Application.HintHidePause);
        end;

        WriteBool(Ini_Options, 'DontBackup', MaDontBackup.Checked);
        WriteBool(Ini_Options, 'PreserveDateMod', MaPreserveDateMod.Checked);
        WriteString(Ini_Options, 'KeySeparator', ET.Options.GetSeparator);
        WriteBool(Ini_Options, 'IgnoreErrors', MaIgnoreErrors.Checked);
        WriteBool(Ini_Options, 'GPSinDecimal', MaShowGPSdecimal.Checked);
        WriteBool(Ini_Options, 'ShowSorted', MaShowSorted.Checked);
        WriteBool(Ini_Options, 'ShowComposite', MaShowComposite.Checked);
        WriteBool(Ini_Options, 'NotDuplicated', MaNotDuplicated.Checked);
        WriteBool(Ini_Options, 'APIWindowsWideFile', MaAPIWindowsWideFile.Checked);
        WriteBool(Ini_Options, 'APIWindowsLongPath', MaAPIWindowsLongPath.Checked);
        WriteBool(Ini_Options, 'APILargeFileSupport', MaAPILargeFileSupport.Checked);
        WriteString(Ini_Options, 'CustomOptions', ET.Options.ETCustomOptions);

        // Standard, Camera, Location, About and UserDef settings
        WriteFileLists(GUIini);

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

        // -- Diff
        WriteDiffTags(GUIini);

      end;

      WriteGeoCodeSettings(GUIini);

      // Write to stream
      GUIini.UpdateFile;

      //Write Stream to disk. Will raise exception if unsuccesful.
      IniStream.SaveToFile(GetIniFilePath(false));

    finally
      GUIini.Free;
      IniStream.Free;
    end;

  except
    on E: Exception do
    begin
      result := false;
      ShowMessage(StrCannotSaveGUI + #10 + E.Message);
    end;
  end;
end;

function GetHrIniData(AllIniData: array of TIniData): string;
var
  AIniData: TIniData;
begin
  result := '';
  for AIniData in AllIniData do
  begin
    if (result <> '') then
      result := result + #10;
    case (AIniData) of
      TIniData.idWorkSpace:
        result := result + StrWorkspace;
      TIniData.idETDirect:
        result := result + StrETDirect;
      TIniData.idFileLists:
        result := result + StrFileLists;
      TIniData.idCustomView:
        result := result + StrCustomView;
      TIniData.idPredefinedTags:
        result := result + StrPredefinedTags;
    end;
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
        TIniTagsData.idtFileLists:        LoadOK := (ReadFileLists(FMain.ShellList.Handle, GuiIni));
        TIniTagsData.idtCustomView:       LoadOK := (ReadCustomViewTags(GuiIni) <> 0);
        TIniTagsData.idtMarked:           LoadOK := (ReadMarkedTags(GuiIni) <> 0);
        TIniTagsData.idtPredefinedTags:   LoadOK := (ReadPredefinedTags(GUIini) <> 0);
        TIniTagsData.idtRemoveTags:       LoadOK := (ReadRemoveTags(GuiIni) <> 0);
        TIniTagsData.idtCopySingleTags:   LoadOK := (ReadCopySingleTags(GuiIni) <> 0);
        TIniTagsData.idtCopyTags:         LoadOK := (ReadCopyTags(GuiIni) <> 0);
        TIniTagsData.idtDiffTags:         LoadOK := (ReadDiffTags(GuiIni) <> 0);
      else
        LoadOK := false;
      end;
      result := result or LoadOK;
    end;
  finally
    GUIini.Free;
  end;
end;

function LoadIniDialog(OpenFileDlg: TOpenDialog): boolean;
var
  HrIniData: string;
  IniLoaded: boolean;
  AIniData: TIniData;
begin
  result := false;
  IniLoaded := false;

  with OpenFileDlg do
  begin
    InitialDir := WrkIniDir;
    Filter := 'Ini file|*.ini';
    Title := StrImportIni;
    if Execute then
    begin
      HrIniData := '';
      for AIniData := Low(TIniData) to High(TIniData) do
      begin
        case AIniData of
          TIniData.idWorkSpace:
            IniLoaded := LoadIni(FileName, [TIniTagsData.idtWorkSpace]);
          TIniData.idETDirect:
            IniLoaded := LoadIni(FileName, [TIniTagsData.idtETDirect]);
          TIniData.idFileLists:
            IniLoaded := LoadIni(FileName, [TIniTagsData.idtFileLists]);
          TIniData.idCustomView:
            IniLoaded := LoadIni(FileName, [TIniTagsData.idtCustomView]);
          TIniData.idPredefinedTags:
            IniLoaded := LoadIni(FileName, [TIniTagsData.idtPredefinedTags,
                                            TIniTagsData.idtMarked,
                                            TIniTagsData.idtRemoveTags,
                                            TIniTagsData.idtCopySingleTags,
                                            TIniTagsData.idtCopyTags,
                                            TIniTagsData.idtDiffTags]);
        end;
        if (IniLoaded) then
          HrIniData := HRiniData + #10 + GetHrIniData(AIniData);
      end;
      if (HrIniData <> '') then
        ShowMessage(Format('%s%s%s', [Format(StrIniImported, [FileName]),
                                      #10,
                                      Format(StrIniDefContaining, [HrIniData])]))
      else
        ShowMessage(StrIniFileNotChanged);
      WrkIniDir := ExtractFileDir(FileName);
    end;
  end;
end;

function SaveIniDialogFilename(SaveFileDlg: TSaveDialog): string;
var
  DoSave: boolean;
  IsOk: boolean;
begin
  result := '';
  with SaveFileDlg do
  begin
    DefaultExt := 'ini';
    InitialDir := WrkIniDir;
    Filter := 'Ini file|*.ini';
    Title := StrExportIni;
    repeat
      IsOK := false;
      DoSave := Execute;
      InitialDir := ExtractFileDir(FileName);
      if DoSave then
      begin
        IsOK := (ExtractFileName(FileName) <> ExtractFileName(GetIniFilePath(false)));
        if not IsOK then
          ShowMessage(StrUseAnotherNameForIni);
      end;
    until not DoSave or IsOK;
    if (DoSave) and (IsOk) then
      result := FileName;
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
          TIniTagsData.idtFileLists:      WriteFileLists(GuiIni);
          TIniTagsData.idtCustomView:     WriteCustomViewTags(GuiIni);
          TIniTagsData.idtPredefinedTags: WritePredefinedTags(GuiIni);
          TIniTagsData.idtMarked:         WriteMarkedTags(GuiIni);
          TIniTagsData.idtRemoveTags:     WriteRemoveTags(GuiIni);
          TIniTagsData.idtCopySingleTags: WriteCopySingleTags(GuiIni);
          TIniTagsData.idtCopyTags:       WriteCopyTags(GuiIni);
          TIniTagsData.idtDiffTags:       WriteDiffTags(GuiIni);
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

function SaveIniDialog(SaveFileDlg: TSaveDialog; SelIniData: TSelIniData): boolean;
var
  HrIniData: string;
  FileName: string;
  AIniData: TIniData;
  AllIniData: array of TIniTagsData;
begin
  result := false;
  FileName := SaveIniDialogFilename(SaveFileDlg);
  if (FileName = '') then
    exit;

  HrIniData := '';
  SetLength(AllIniData, 0);
  for AIniData := Low(TIniData) to High(TIniData) do
  begin
    if (AIniData in SelIniData) then
    begin
      HrIniData := HrIniData + #10 + GetHrIniData([AIniData]);
      case AIniData of
        TIniData.idWorkSpace:
          AllIniData := AllIniData + [TIniTagsData.idtWorkSpace];
        TIniData.idETDirect:
          AllIniData := AllIniData + [TIniTagsData.idtETDirect];
        TIniData.idFileLists:
          AllIniData := AllIniData + [TIniTagsData.idtFileLists];
        TIniData.idCustomView:
          AllIniData := AllIniData + [TIniTagsData.idtCustomView];
        TIniData.idPredefinedTags:
          AllIniData := AllIniData + [TIniTagsData.idtPredefinedTags,
                                      TIniTagsData.idtMarked,
                                      TIniTagsData.idtRemoveTags,
                                      TIniTagsData.idtCopySingleTags,
                                      TIniTagsData.idtCopyTags];
      end;
    end;
  end;

  result := SaveIni(FileName, AllIniData);
  if result then
    ShowMessage(Format('%s%s%s', [Format(StrIniExported, [FileName]),
                                  #10,
                                  Format(StrIniDefContaining, [HrIniData])]))
  else
    ShowMessage(Format(StrIniDefNotSaved, [Filename]));
end;

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
