unit UnitColumnDefs;

interface

uses
  System.Classes, System.IniFiles, System.Generics.Collections,
  WinApi.Windows,
  Vcl.Shell.ShellCtrls,
  UnitLangResources;

const
  toSys     = $0001;
  toDecimal = $0002;
  toYesNo   = $0004;
  toHorVer  = $0008;
  toFlash   = $0010;
  toCountry = $0020;
  toBackup  = $0100;

  CommandCountryCode = '-XMP-iptcExt:LocationShownCountryCode';
  CommandCountryName = '-XMP-iptcExt:LocationShownCountryName';

type

  TFileListOptions = (floSystem, floInternal, floUserDef);
  TReadModeOption = (rmInternal = $0001, rmExifTool = $0002);
  TReadModeOptions = set of TReadModeOption;

  TFileListColumn = record
    Command: string;
    Width: integer;
    AlignR: integer;
    Options: Word;
    function GetSysColumn: integer;
    procedure SetCaption(ACaption: string);
    case integer of
      0: (Caption: array[0..255] of WideChar);
      1: (XlatedCaption: PResStringRec);
  end;

  TColumnsArray = array of TFileListColumn;

  TColumnSet = class(TObject)
  private
    FName: string;
    FOptions: TFileListOptions;
    FReadMode: TReadModeOptions;
    FColumnDefs: TColumnsArray;
    function GetReadModeInt: integer;
  public
    constructor Create(AName: string;
                       AOptions: TFileListOptions;
                       AReadMode: TReadModeOptions;
                       AColumnDefs: TColumnsArray); overload;
    constructor Create(AName: string;
                       AOptions: TFileListOptions;
                       AReadMode: integer;
                       AColumnDefs: TColumnsArray); overload;
    destructor Destroy; override;

    property Name: string read FName write FName;
    property Options: TFileListOptions read FOptions;
    property ReadMode: TReadModeOptions read FReadMode;
    property ReadModeInt: integer read GetReadModeInt;
    property ColumnDefs: TColumnsArray read FColumnDefs write FColumnDefs;
  end;
  TColumnSetList = TObjectlist<TColumnSet>;

function ReadFileListColumns(LVHandle: HWND; GUIini: TMemIniFile): boolean;
procedure WriteFileListColumns(GUIini: TMemIniFile);
procedure ResetAllColumnWidths(LVHandle: HWND);
function GetFileListDefCount: integer;
function GetFileListDefs: TColumnSetList;
function GetFileListColumnDefs(Index: integer): TColumnsArray;
procedure SetFileListColumnDefs(Index: integer; AColumnDefs: TColumnsArray);
procedure UpdateSysCaptions(ARootFolder: TShellFolder);
function UnsupportedEnabled: boolean;

implementation

uses
  System.SysUtils, System.Math,
  Winapi.CommCtrl,
  ExifToolsGui_ShellList, ExifToolsGUI_Utils, MainDef;

const
  ReadMode  = 'ReadMode';
  StdColDef = 'StdColDef_';
  UsrColDef = 'UsrColDef_';

  // This definition is used only to store the Widths
  StandardId = '0';
  StandardDefaults: array [0..4] of TFileListColumn =
  (
    (Command: '0';                              Width: 200; Options: toSys),  // Name
    (Command: '1';                              Width: 88;  Options: toSys),  // Size
    (Command: '2';                              Width: 80;  Options: toSys),  // File type
    (Command: '3';                              Width: 120; Options: toSys),  // Date modified
    (Command: '4';                              Width: 120; Options: toSys)   // Date created
  );

  CameraId = '1';
  CameraDefaults: array [0..9] of TFileListColumn =
  (
    (Command: '-IFD0:Model';                                                    XlatedCaption: @StrFLModel),
    (Command: '-exifIFD:LensModel';                                             XlatedCaption: @StrFLLensModel),
    (Command: '-exifIFD:ExposureTime';          AlignR: 6;                      XlatedCaption: @StrFLExpTime),
    (Command: '-exifIFD:FNumber';               AlignR: 4;                      XlatedCaption: @StrFLFNumber),
    (Command: '-exifIFD:ISO';                   AlignR: 5;                      XlatedCaption: @StrFLISO),
    (Command: '-exifIFD:ExposureCompensation';  AlignR: 4;  Options: toDecimal; XlatedCaption: @StrFLExpComp),
    (Command: '-exifIFD:FocalLength#';          AlignR: 8;  Options: toDecimal; XlatedCaption: @StrFLFLength),
    (Command: '-exifIFD:Flash#';                            Options: toFlash;   XlatedCaption: @StrFLFlash),
    (Command: '-exifIFD:ExposureProgram';                                       XlatedCaption: @StrFLExpProgram),
    (Command: '-IFD0:Orientation#';                         Options: toHorVer;  XlatedCaption: @StrFLOrientation)
  );

  LocationId = '2';
  LocationDefaults: array [0..6] of TFileListColumn =
  (
    (Command: '-ExifIFD:DateTimeOriginal';                                      XlatedCaption: @StrFLDateTime),
    (Command: '-QuickTime:CreateDate';                      Options: toBackup;  XlatedCaption: @StrFLDateTime),
    (Command: '-Composite:GpsPosition#';                    Options: toYesNo;   XlatedCaption: @StrFLGPS),
    (Command: CommandCountryCode;                           Options: toCountry; XlatedCaption: @StrFLCountry),
    (Command: '-XMP-iptcExt:LocationShownProvinceState';                        XlatedCaption: @StrFLProvince),
    (Command: '-XMP-iptcExt:LocationShownCity';                                 XlatedCaption: @StrFLCity),
    (Command: '-XMP-iptcExt:LocationShownSublocation';                          XlatedCaption: @StrFLLocation)
  );

  AboutId = '3';
  AboutDefaults: array [0..4] of TFileListColumn =
  (
    (Command: '-IFD0:Artist';                                                   XlatedCaption: @StrFLArtist),
    (Command: '-XMP-xmp:Rating';                                                XlatedCaption: @StrFLRating),
    (Command: '-XMP-dc:Type';                                                   XlatedCaption: @StrFLType),
    (Command: '-XMP-iptcExt:Event';                                             XlatedCaption: @StrFLEvent),
    (Command: '-XMP-iptcExt:PersonInImage';                                     XlatedCaption: @StrFLPersonInImage)
  );

  UserDefLists = 'UserDefLists';          // List with userdefined names
  OldUserDefTags = 'FListUserDefColumn';  // Pre 6.3.6
  DefaultUserDef: array [0..2] of TFileListColumn =
  (
    (Command: '-exifIfd:DateTimeOriginal';                                      XlatedCaption: @StrFLDateTime),
    (Command: '-xmp-xmp:Rating';                                                XlatedCaption: @StrFLRating),
    (Command: '-xmp-dc:Title';                                                  XlatedCaption: @StrFLPhotoTitle)
  );

var
  FColumnSetList: TColumnSetList;

function DefInternalMode: TReadModeOptions;
begin
  result := [TReadModeOption.rmInternal];
  if (GUIsettings.EnableUnsupported) then
    Include(Result, TReadModeOption.rmExifTool);
end;

function TFileListColumn.GetSysColumn: integer;
var
  P: integer;
begin
  result := -1;
  if ((Options and toSys) = toSys) then
  begin
    P := Pos(':', Command);
    if (P < 1) then
      P := Length(Command) +1;
    result := StrToIntDef(Copy(Command, 1, P -1), -1);
  end;
end;

procedure TFileListColumn.SetCaption(ACaption: string);
begin
  StrPLCopy(Caption, ACaption, SizeOf(Caption) -1);
end;

constructor TColumnSet.Create(AName: string;
                              AOptions: TFileListOptions;
                              AReadMode: TReadModeOptions;
                              AColumnDefs: TColumnsArray);
begin
  inherited Create;
  FName := AName;
  FOptions := AOptions;
  FReadMode := AReadMode;
  FColumnDefs := AColumnDefs;
end;

constructor TColumnSet.Create(AName: string;
                              AOptions: TFileListOptions;
                              AReadMode: integer;
                              AColumnDefs: TColumnsArray);
var
  FReadMode: TReadModeOptions;
begin
  FReadMode := [];
  if ((AReadMode and Ord(rmInternal)) <> 0) then
    Include(FReadMode, rmInternal);
  if ((AReadMode and Ord(rmExifTool)) <> 0) then
    Include(FReadMode, rmExifTool);
  Create(AName, AOptions, FReadMode, AColumnDefs);
end;

destructor TColumnSet.Destroy;
begin
  SetLength(FName, 0);
  inherited Destroy;
end;

function TColumnSet.GetReadModeInt: integer;
begin
  result := 0;
  if (rmInternal in FReadMode) then
    Inc(result, Ord(rmInternal));
  if (rmExifTool in FReadMode) then
    Inc(result, Ord(rmExifTool));
end;

function DefaultColumnWidth(LVHandle: HWND; AColumn: TFileListColumn): integer;
begin
// MS States that it needs padding, but how much? I use 2 WW.
  result := ListView_GetStringWidth(LVHandle, PWideChar(AColumn.Caption + 'WW'));
end;

function ReadReadModeDefs(ALine: string): TReadModeOptions;
var
  ReadModeInt: integer;
begin
  result := [];
  ReadModeInt := Pos('=', ALine);
  ReadModeInt := StrToIntDef(Copy(ALine, ReadModeInt +1), 0);

  if ((ReadModeInt and Ord(rmInternal)) <> 0) then
    include(Result, rmInternal);
  if ((ReadModeInt and Ord(rmExifTool)) <> 0) then
    include(Result, rmExifTool);
end;

procedure WriteReadModeDefs(TmpItems: TStrings;
                            AReadMode: TReadModeOptions);
var
  ReadModeInt: integer;
begin
  ReadModeInt := 0;
  if (rmInternal in AReadMode) then
    Inc(ReadModeInt, Ord(rmInternal));
  if (rmExifTool in AReadMode) then
    Inc(ReadModeInt, Ord(rmExifTool));
  TmpItems.Add(Format('%s=%d', [ReadMode, ReadModeInt]));
end;

function ReadColumnDefs(LVHandle: HWND;
                        GUIini: TMemIniFile;
                        ASection: string;
                        ADefaults: array of TFileListColumn;
                        var OReadMode: TReadModeOptions): TColumnsArray;
var
  Indx, DefCnt: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.ReadSectionValues(ASection, TmpItems);
    DefCnt := TmpItems.Count;
    if (DefCnt = 0) and
       (GUIini.SectionExists(ASection) = false) then
    begin
      SetLength(result, Length(ADefaults));
      for Indx := 0 to High(ADefaults) do
      begin
        result[Indx].SetCaption(LoadResString(ADefaults[Indx].XlatedCaption));
        result[Indx].Command  := ADefaults[Indx].Command;
        if (ADefaults[Indx].Width = 0) then
          result[Indx].Width  := DefaultColumnWidth(LVHandle, result[Indx])
        else
          result[Indx].Width  := ADefaults[Indx].Width;
        result[Indx].AlignR   := ADefaults[Indx].AlignR;
        result[Indx].Options  := ADefaults[Indx].Options;
      end;
    end
    else
    begin
      OReadMode := ReadReadModeDefs(TmpItems[0]);
      Dec(DefCnt);
      SetLength(result, DefCnt);
      for Indx := 0 to DefCnt - 1 do
      begin
        Tx := TmpItems[Indx +1];
        result[Indx].SetCaption(NextField(Tx, '='));
        result[Indx].Command  := NextField(Tx, ' ');
        result[Indx].Width    := StrToIntDef(NextField(Tx, ','), DefaultColumnWidth(LVHandle, result[Indx]));
        result[Indx].AlignR   := StrToIntDef(NextField(Tx, ';'), 0);
        result[Indx].Options  := StrToIntDef(Tx, 0);
      end;
    end;
  finally
    TmpItems.Free;
  end;
end;

procedure ResetColumnWidths(LVHandle: HWND; var ColumnDefs: TColumnsArray);
var
  Indx: integer;
begin
  for Indx := 0 to High(ColumnDefs) do
    ColumnDefs[Indx].Width := DefaultColumnWidth(LVHandle, ColumnDefs[Indx]);
end;

procedure WriteColumnDefs(GUIini: TMemIniFile; ASection: string; AReadMode: TReadModeOptions; ColumnDefs: TColumnsArray);
var
  Indx: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.
    TmpItems.Add(Format('[%s]', [ASection]));
    WriteReadModeDefs(TmpItems, AReadMode);

    for Indx := 0 to High(ColumnDefs) do
    begin
      Tx := Format('%s=%s %d,%d;%d', [ColumnDefs[Indx].Caption,
                                      ColumnDefs[Indx].Command,
                                      ColumnDefs[Indx].Width,
                                      ColumnDefs[Indx].AlignR,
                                      integer(ColumnDefs[Indx].Options)]);
      TmpItems.Add(Tx);
    end;
    GUIini.SetStrings(TmpItems);
  finally
    TmpItems.Free;
  end;
end;

function ReadStandardTags(LVHandle: HWND; GUIini: TMemIniFile): TColumnsArray;
var
  ReadMode: TReadModeOptions;
begin
  ReadMode := [];
  result := ReadColumnDefs(LVHandle, GUIini, StdColDef + StandardId, StandardDefaults, ReadMode);
  FColumnSetList.Add(TColumnSet.Create(StrStandardList,
                                       floSystem,
                                       ReadMode,
                                       result));
end;

function ReadCameraTags(LVHandle: HWND; GUIini: TMemIniFile): TColumnsArray;
var
  ReadMode: TReadModeOptions;
begin
  ReadMode := DefInternalMode;
  result := ReadColumnDefs(LVHandle, GUIini, StdColDef + CameraId, CameraDefaults, ReadMode);
  FColumnSetList.Add(TColumnSet.Create(StrCameraList,
                                       floInternal,
                                       ReadMode,
                                       result));
end;

function ReadLocationTags(LVHandle: HWND; GUIini: TMemIniFile): TColumnsArray;
var
  ReadMode: TReadModeOptions;
begin
  ReadMode := DefInternalMode;
  result := ReadColumnDefs(LVHandle, GUIini, StdColDef + LocationId, LocationDefaults, ReadMode);
  FColumnSetList.Add(TColumnSet.Create(StrLocationList,
                                       floInternal,
                                       ReadMode,
                                       result));
end;

function ReadAboutTags(LVHandle: HWND; GUIini: TMemIniFile): TColumnsArray;
var
  ReadMode: TReadModeOptions;
begin
  ReadMode := DefInternalMode;
  result := ReadColumnDefs(LVHandle, GUIini, StdColDef + AboutId, AboutDefaults, ReadMode);
  FColumnSetList.Add(TColumnSet.Create(StrAboutList,
                                       floInternal,
                                       ReadMode,
                                       result));
end;

function ReadUserDefTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
var
  UserDefList: TStringList;
  AUserDefName: string;
  AColumnDefs: TColumnsArray;
  ReadMode: TReadModeOptions;
  Indx: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  result := 0;

  // Convert Pre 6.3.6 definitions?
  if (not GUIini.SectionExists(UserDefLists)) and
     (GUIini.SectionExists(OldUserDefTags)) then
  begin
    TmpItems := TStringList.Create;
    try
      GUIini.ReadSectionValues(OldUserDefTags, TmpItems);
      SetLength(AColumnDefs, TmpItems.Count);
      for Indx := 0 to High(AColumnDefs) do
      begin
        Tx := TmpItems[Indx];
        AColumnDefs[Indx].SetCaption(NextField(Tx, '='));
        AColumnDefs[Indx].Command := NextField(Tx, ' ');
        AColumnDefs[Indx].Width := StrToIntDef(Tx, 80);
        AColumnDefs[Indx].AlignR := 0;
      end;
      FColumnSetList.Add(TColumnSet.Create(StrUserList,
                                           floUserDef,
                                           [rmExifTool], // Default Pre 6.3.6
                                           AColumnDefs));
    finally
      TmpItems.Free;
    end;
  end
  else
  begin
    // Read all User defined lists
    UserDefList := TStringList.Create;
    try
      GUIini.ReadSectionValues(UserDefLists, UserDefList);
      if (UserDefList.Count = 0) then
        UserDefList.AddPair('0', StrUserList);
      for Indx := 0 to UserDefList.Count -1 do
      begin
        AUserDefName := UserDefList.ValueFromIndex[Indx];
        ReadMode := [rmExifTool];
        AColumnDefs := ReadColumnDefs(LVHandle, GUIini, UsrColDef + UserDefList.KeyNames[Indx], DefaultUserDef, ReadMode);
        result := result + Length(AColumnDefs);
        FColumnSetList.Add(TColumnSet.Create(AUserDefName,
                                             floUserDef,
                                             ReadMode,
                                             AColumnDefs));
      end;
    finally
      UserDefList.Free;
    end;
  end;
end;

function ReadFileListColumns(LVHandle: HWND; GUIini: TMemIniFile): boolean;
begin
  FColumnSetList.Clear;
  ReadStandardTags(LVHandle, GUIini);
  ReadCameraTags(LVHandle, GUIini);
  ReadLocationTags(LVHandle, GUIini);
  ReadAboutTags(LVHandle, GUIini);
  result := (ReadUserDefTags(LVHandle, GUIini) > 0);
end;

procedure WriteFileListColumns(GUIini: TMemIniFile);
var
  OldUserDefSaved: boolean;
  ColumnIndex: integer;
  Index: integer;
  AColumnSet: TColumnSet;
  UserDefList: TStringList;
  OldUserDef: string;
  ColDefName: string;
begin
  UserDefList := TStringList.Create;
  try
    OldUserDefSaved := false;
    for ColumnIndex := 0 to FColumnSetList.Count -1 do
    begin
      AColumnSet := FColumnSetList[ColumnIndex];
      ColDefName := Format('%s%d', [StdColDef, ColumnIndex]);
      if (AColumnSet.Options = floUserDef) then
      begin
        ColDefName := Format('%s%d', [UsrColDef, UserDefList.Count]);
        UserDefList.Add(AColumnSet.Name);
        if (OldUserDefSaved = false) then
        begin
          OldUserDefSaved := true;
          for Index := 0 to High(AColumnSet.ColumnDefs) do
          begin
            if ((AColumnSet.ColumnDefs[Index].Options and toSys) = toSys) then
              continue;
            OldUserDef := AColumnSet.ColumnDefs[Index].Caption;
            GUIini.WriteString(OldUserDefTags,
                               OldUserDef,
                               Format('%s %d', [AColumnSet.ColumnDefs[Index].Command, AColumnSet.ColumnDefs[Index].Width]));
          end;
        end;
      end;
      WriteColumnDefs(GUIini, ColDefName, AColumnSet.ReadMode, AColumnSet.ColumnDefs);
    end;
    for Index := 0 to UserDefList.Count -1 do
      GUIini.WriteString(UserDefLists, Format('%d', [Index]), UserDefList[Index]);
  finally
    UserDefList.Free;
  end;
end;

procedure ResetAllColumnWidths(LVHandle: HWND);
var
  AColumnSet: TColumnSet;
  Index: integer;
begin
  for AColumnSet in FColumnSetList do
  begin
    if (AColumnSet.Options = floSystem) then
      for Index := 0 to Min(High(AColumnSet.ColumnDefs), High(StandardDefaults))  do
        AColumnSet.ColumnDefs[Index].Width := StandardDefaults[Index].Width
    else
      ResetColumnWidths(LVHandle, AColumnSet.FColumnDefs);
  end;
end;

function GetFileListDefCount: integer;
begin
  result := FColumnSetList.Count;
end;

function GetFileListColumnDefs(Index: integer): TColumnsArray;
begin
  SetLength(result, 0);
  if (Index > -1) and
     (Index < FColumnSetList.Count) then
    result := FColumnSetList[Index].ColumnDefs;
end;

function GetFileListDefs: TColumnSetList;
begin
  result := FColumnSetList;
end;

procedure SetFileListColumnDefs(Index: integer; AColumnDefs: TColumnsArray);
begin
  if (Index > 0) and
     (Index < FColumnSetList.Count) then
    FColumnSetList[Index].ColumnDefs := AColumnDefs;
end;

procedure UpdateSysCaptions(ARootFolder: TShellFolder);
var
  FileDef: integer;
  Index: integer;
  ColumnDefs: TColumnsArray;
begin
  for FileDef := 0 to GetFileListDefCount -1 do
  begin
    ColumnDefs := GetFileListDefs[FileDef].ColumnDefs;
    for Index := 0 to High(ColumnDefs) do
      if ((ColumnDefs[Index].Options and toSys) = toSys) then
        ColumnDefs[Index].SetCaption(TSubShellFolder.GetSystemField(ARootFolder, nil, ColumnDefs[Index].GetSysColumn));
  end;
end;

function UnsupportedEnabled: boolean;
var
  AColumnSet: TColumnSet;
begin
  result := false;
  for AColumnSet in FColumnSetList do
    if (AColumnSet.Options <> floUserDef) and
       (rmExifTool in AColumnSet.ReadMode) then
      exit(true);
end;

initialization
begin
  FColumnSetList := TColumnSetList.Create;
end;

finalization
begin
  FColumnSetList.Free;
end;

end.
