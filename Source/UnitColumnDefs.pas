unit UnitColumnDefs;

interface

uses
  System.Classes, System.IniFiles, System.Generics.Collections,
  WinApi.Windows,
  UnitLangResources;

const
  toDecimal = $0001;
  toYesNo   = $0002;
  toHorVer  = $0004;
  toFlash   = $0008;
  toMain    = $0010;
  toBackup  = $0020;
  toCountry = $0040;
  toSys     = $0080;

  CommandCountryCode = '-XMP-iptcExt:LocationShownCountryCode';
  CommandCountryName = '-XMP-iptcExt:LocationShownCountryName';

type

  TFileListOptions = set of (floSystem, floInternal, floExifTool, floUserDef);

  TFileListColumnXlat = record
    Caption: PResStringRec;
    Command: string;
    Width: integer;
    AlignR: integer;
    Options: Word;
  end;
  TFileListColumn = record
    Caption: string;
    Command: string;
    Width: integer;
    AlignR: integer;
    Options: Word;
  end;
  TColumnsArray = array of TFileListColumn;

  TColumnSet = class(TObject)
  private
    FName: string;
    FDesc: string;
    FOptions: TFileListOptions;
    FColumnDefs: TColumnsArray;
  public
    constructor Create(AName, ADesc: string; AOptions: TFileListOptions; AColumnDefs: TColumnsArray);
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Desc: string read FDesc write FDesc;
    property Options: TFileListOptions read FOptions;
    property ColumnDefs: TColumnsArray read FColumnDefs write FColumnDefs;
  end;
  TColumnSetList = TObjectlist<TColumnSet>;

function ReadFileListColumns(LVHandle: HWND; GUIini: TMemIniFile): boolean;
procedure WriteFileListColumns(GUIini: TMemIniFile);
procedure ResetAllColumnWidths(LVHandle: HWND);
function GetFileListColumnDefCount: integer;
procedure GetFileListDefs(AList: TStrings);
function GetFileListColumnDefs(Index: integer): TColumnsArray;
procedure SetFileListColumnDefs(Index: integer; AColumnDefs: TColumnsArray);

implementation

uses
  System.SysUtils, System.Math,
  Winapi.CommCtrl,
  ExifToolsGUI_Utils;

const
  // This definition is used only to store the Widths
  // Name, Size, File type, Date modified, Date created
  StandardTags = 'StandardColumns';
  StandardDefaults: array [0..4] of TFileListColumnXlat =
  (
    (Caption: @StrFilename;      Command: '0'; Width: 200;                            Options: toSys),
    (Caption: @StrFLFilTyp;      Command: '1'; Width: 88;                             Options: toSys),
    (Caption: @StrFLSize;        Command: '2'; Width: 80;                             Options: toSys),
    (Caption: @StrFLDatMod;      Command: '3'; Width: 120;                            Options: toSys),
    (Caption: @StrFLDatCre;      Command: '4'; Width: 120;                            Options: toSys)
  );

  CameraTags = 'CameraColumns';
  CameraDefaults: array [0..9] of TFileListColumnXlat =
  (
    (Caption: @StrFLModel;       Command: '-IFD0:Model';                   ),
    (Caption: @StrFLLensModel;   Command: '-exifIFD:LensModel';            ),
    (Caption: @StrFLExpTime;     Command: '-exifIFD:ExposureTime';         AlignR: 6),
    (Caption: @StrFLFNumber;     Command: '-exifIFD:FNumber';              AlignR: 4),
    (Caption: @StrFLISO;         Command: '-exifIFD:ISO';                  AlignR: 5),
    (Caption: @StrFLExpComp;     Command: '-exifIFD:ExposureCompensation'; AlignR: 4; Options: toDecimal),
    (Caption: @StrFLFLength;     Command: '-exifIFD:FocalLength#';         AlignR: 8; Options: toDecimal),
    (Caption: @StrFLFlash;       Command: '-exifIFD:Flash#';                          Options: toFlash),
    (Caption: @StrFLExpProgram;  Command: '-exifIFD:ExposureProgram'),
    (Caption: @StrFLOrientation; Command: '-IFD0:Orientation#';                       Options: toHorVer)
  );

  LocationTags = 'LocationColumns';
  LocationDefaults: array [0..6] of TFileListColumnXlat =
  (
    (Caption: @StrFLDateTime;    Command: '-ExifIFD:DateTimeOriginal';                Options: toMain),
    (Caption: @StrFLDateTime;    Command: '-QuickTime:CreateDate';                    Options: toBackup),
    (Caption: @StrFLGPS;         Command: '-Composite:GpsPosition#';                  Options: toYesNo),
    (Caption: @StrFLCountry;     Command: CommandCountryCode;                         Options: toCountry),
    (Caption: @StrFLProvince;    Command: '-XMP-iptcExt:LocationShownProvinceState'),
    (Caption: @StrFLCity;        Command: '-XMP-iptcExt:LocationShownCity'),
    (Caption: @StrFLLocation;    Command: '-XMP-iptcExt:LocationShownSublocation')
  );

  AboutTags = 'AboutColumns';
  AboutDefaults: array [0..4] of TFileListColumnXlat =
  (
    (Caption: @StrFLArtist;        Command: '-IFD0:Artist'),
    (Caption: @StrFLRating;        Command: '-XMP-xmp:Rating'),
    (Caption: @StrFLType;          Command: '-XMP-dc:Type'),
    (Caption: @StrFLEvent;         Command: '-XMP-iptcExt:Event'),
    (Caption: @StrFLPersonInImage; Command: '-XMP-iptcExt:PersonInImage')
  );

  UserDef = 'UserDef_';                   // Prefix in INI sections
  UserDefined = 'User defined';           // internal name
  UserDefLists = 'UserDefLists';          // List with userdefined names
  OldUserDefTags = 'FListUserDefColumn';  // Pre 6.3.6
  DefaultUserDef: array [0..2] of TFileListColumnXlat =
  (
    (Caption: @StrFLDateTime;      Command: '-exifIfd:DateTimeOriginal'),
    (Caption: @StrFLRating;        Command: '-xmp-xmp:Rating'),
    (Caption: @StrFLPhotoTitle;    Command: '-xmp-dc:Title')
  );

var
  FColumnSetList: TColumnSetList;

constructor TColumnSet.Create(AName, ADesc: string; AOptions: TFileListOptions; AColumnDefs: TColumnsArray);
begin
  inherited Create;
  FName := AName;
  FDesc := ADesc;
  FOptions := AOptions;
  FColumnDefs := AColumnDefs;
end;

destructor TColumnSet.Destroy;
begin
  SetLength(FName, 0);
  inherited Destroy;
end;

function DefaultColumnWidth(LVHandle: HWND; AColumn: TFileListColumn): integer;
begin
// MS States that it needs padding, but how much? I use 2 WW.
  result := ListView_GetStringWidth(LVHandle, PWideChar(AColumn.Caption + 'WW'));
end;

function ReadColumnDefs(LVHandle: HWND;
                        GUIini: TMemIniFile;
                        ASection: string;
                        ADefaults: array of TFileListColumnXLat): TColumnsArray;
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
        result[Indx].Caption  := LoadResString(ADefaults[Indx].Caption);
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
      SetLength(result, DefCnt);
      for Indx := 0 to DefCnt - 1 do
      begin
        Tx := TmpItems[Indx];
        result[Indx].Caption  := NextField(Tx, '=');
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

procedure WriteColumnDefs(GUIini: TMemIniFile; ASection: string; ColumnDefs: TColumnsArray);
var
  Indx: integer;
  Tx: string;
  TmpItems: TStringList;
begin
  TmpItems := TStringList.Create;
  try
    GUIini.GetStrings(TmpItems); // Get strings written so far.
    TmpItems.Add(Format('[%s]', [ASection]));
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
begin
  result := ReadColumnDefs(LVHandle, GUIini, StandardTags, StandardDefaults);
  FColumnSetList.Add(TColumnSet.Create(StandardTags,
                                       StrStandardList,
                                       [floSystem], result));
end;

function ReadCameraTags(LVHandle: HWND; GUIini: TMemIniFile): TColumnsArray;
begin
  result := ReadColumnDefs(LVHandle, GUIini, CameraTags, CameraDefaults);
  FColumnSetList.Add(TColumnSet.Create(CameraTags,
                                       StrCameraList,
                                       [floSystem, floInternal, floExifTool], result));
end;

function ReadLocationTags(LVHandle: HWND; GUIini: TMemIniFile): TColumnsArray;
begin
  result := ReadColumnDefs(LVHandle, GUIini, LocationTags, LocationDefaults);
  FColumnSetList.Add(TColumnSet.Create(LocationTags,
                                       StrLocationList,
                                       [floSystem, floInternal, floExifTool], result));
end;

function ReadAboutTags(LVHandle: HWND; GUIini: TMemIniFile): TColumnsArray;
begin
  result := ReadColumnDefs(LVHandle, GUIini, AboutTags, AboutDefaults);
  FColumnSetList.Add(TColumnSet.Create(AboutTags,
                                       StrAboutList,
                                       [floSystem, floInternal, floExifTool], result));
end;

function ReadUserDefTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
var
  UserDefList: string;
  AUserDefName: string;
  AUserDefDesc: string;
  AColumnDefs: TColumnsArray;

  Indx: integer;
  Tx: string;
  TmpItems: TStringList;

begin
  result := 0;

  // Convert Pre 6.3.6 definitions?
  if (not GUIini.ValueExists(UserDefLists, UserDefLists)) and
     (GUIini.SectionExists(OldUserDefTags)) then
  begin
    TmpItems := TStringList.Create;
    try
      GUIini.ReadSectionValues(OldUserDefTags, TmpItems);
      SetLength(AColumnDefs, TmpItems.Count);
      for Indx := 0 to High(AColumnDefs) do
      begin
        Tx := TmpItems[Indx];
        AColumnDefs[Indx].Caption := NextField(Tx, '=');
        AColumnDefs[Indx].Command := NextField(Tx, ' ');
        AColumnDefs[Indx].Width := StrToIntDef(Tx, 80);
        AColumnDefs[Indx].AlignR := 0;
      end;
      FColumnSetList.Add(TColumnSet.Create(UserDefined,
                                           StrUserList,
                                           [floSystem, floInternal, floExifTool, floUserDef], AColumnDefs));
    finally
      TmpItems.Free;
    end;
  end
  else
  begin
    // Read all User defined lists
    UserDefList := GUIini.ReadString(UserDefLists, UserDefLists, UserDefined + '^' + StrUserList);
    while (UserDefList <> '') do
    begin
      AUserDefDesc := NextField(UserDefList, '|');
      AUserDefName := NextField(AUserDefDesc, '^');
      AColumnDefs := ReadColumnDefs(LVHandle, GUIini, UserDef + AUserDefName, DefaultUserDef);
      result := result + Length(AColumnDefs);
      FColumnSetList.Add(TColumnSet.Create(AUserDefName,
                                           AUserDefDesc,
                                           [floSystem, floInternal, floExifTool, floUserDef], AColumnDefs));
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
  AColumnSet: TColumnSet;
  UserDefList: string;
  ColumnSetName: string;
begin
  for AColumnSet in FColumnSetList do
  begin
    ColumnSetName := AColumnSet.Name;
    if (floUserDef in AColumnSet.Options) then
    begin
      ColumnSetName := UserDef + ColumnSetName;
      if (UserDefList <> '') then
        UserDefList := UserDefList + '|';
      UserDefList := UserDefList + AColumnSet.Name + '^' + AColumnSet.Desc;
    end;
    WriteColumnDefs(GUIini, ColumnSetName, AColumnSet.ColumnDefs);
  end;
  GUIini.WriteString(UserDefLists, UserDefLists, UserDefList);
end;

procedure ResetAllColumnWidths(LVHandle: HWND);
var
  AColumnSet: TColumnSet;
  Index: integer;
begin
  for AColumnSet in FColumnSetList do
  begin
    if (AColumnSet.Options = [floSystem]) then
      for Index := 0 to Min(High(AColumnSet.ColumnDefs), High(StandardDefaults))  do
        AColumnSet.ColumnDefs[Index].Width := StandardDefaults[Index].Width
    else
      ResetColumnWidths(LVHandle, AColumnSet.FColumnDefs);
  end;
end;

function GetFileListColumnDefCount: integer;
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

procedure GetFileListDefs(AList: TStrings);
var
  ASet: TColumnSet;
begin
  Alist.BeginUpdate;
  try
    Alist.Clear;
    for ASet in FColumnSetList do
      AList.Add(Aset.Desc);
  finally
    Alist.EndUpdate;
  end;
end;

procedure SetFileListColumnDefs(Index: integer; AColumnDefs: TColumnsArray);
begin
  if (Index > 0) and
     (Index < FColumnSetList.Count) then
    FColumnSetList[Index].ColumnDefs := AColumnDefs;
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
