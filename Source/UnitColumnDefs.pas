unit UnitColumnDefs;

interface

uses
  System.Classes, System.IniFiles,
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

  TFileListOptions = set of (floSystem, floInternal, floExifTool);

  TFileListColumn = record
    Caption: string;
    Command: string;
    Width: integer;
    AlignR: integer;
    Options: Word;
  end;
  TColumnsArray = array of TFileListColumn;

var
  FListStdColWidth: TColumnsArray; // [Filename][Size][Type][Date modified] Can be extended

  // Note: Default widths are computed from length of caption
  // Captions ware taken from resourcestrings
  FListCamera: TColumnsArray;
  FlistLocation: TColumnsArray;
  FListAbout: TColumnsArray;
  FListUserDef: TColumnsArray;

function ReadCameraTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
procedure WriteCameraTags(GUIini: TMemIniFile);

function ReadLocationTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
procedure WriteLocationTags(GUIini: TMemIniFile);

function ReadAboutTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
procedure WriteAboutTags(GUIini: TMemIniFile);

function ReadUserDefTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
procedure WriteUserDefTags(GUIini: TMemIniFile);

procedure ResetAllColumnWidths(LVHandle: HWND);

implementation

uses
  System.SysUtils,
  Winapi.CommCtrl,
  ExifToolsGUI_Utils;

const

  CameraTags = 'CameraColumns';
  CameraDefaults: array [0..9] of TFileListColumn =
  (
    (Caption: StrFLModel;       Command: '-IFD0:Model';                   ),
    (Caption: StrFLLensModel;   Command: '-exifIFD:LensModel';            ),
    (Caption: StrFLExpTime;     Command: '-exifIFD:ExposureTime';         AlignR: 6),
    (Caption: StrFLFNumber;     Command: '-exifIFD:FNumber';              AlignR: 4),
    (Caption: StrFLISO;         Command: '-exifIFD:ISO';                  AlignR: 5),
    (Caption: StrFLExpComp;     Command: '-exifIFD:ExposureCompensation'; AlignR: 4; Options: toDecimal),
    (Caption: StrFLFLength;     Command: '-exifIFD:FocalLength#';         AlignR: 8; Options: toDecimal),
    (Caption: StrFLFlash;       Command: '-exifIFD:Flash#';                          Options: toFlash),
    (Caption: StrFLExpProgram;  Command: '-exifIFD:ExposureProgram'),
    (Caption: StrFLOrientation; Command: '-IFD0:Orientation#';                       Options: toHorVer)
  );

  LocationTags = 'LocationColumns';
  LocationDefaults: array [0..6] of TFileListColumn =
  (
    (Caption: StrFLDateTime;    Command: '-ExifIFD:DateTimeOriginal';                Options: toMain),
    (Caption: StrFLDateTime;    Command: '-QuickTime:CreateDate';                    Options: toBackup),
    (Caption: StrFLGPS;         Command: '-Composite:GpsPosition#';                  Options: toYesNo),
    (Caption: StrFLCountry;     Command: CommandCountryCode;                         Options: toCountry),
    (Caption: StrFLProvince;    Command: '-XMP-iptcExt:LocationShownProvinceState'),
    (Caption: StrFLCity;        Command: '-XMP-iptcExt:LocationShownCity'),
    (Caption: StrFLLocation;    Command: '-XMP-iptcExt:LocationShownSublocation')
  );

  AboutTags = 'AboutColumns';
  AboutDefaults: array [0..4] of TFileListColumn =
  (
    (Caption: StrFLArtist;        Command: '-IFD0:Artist'),
    (Caption: StrFLRating;        Command: '-XMP-xmp:Rating'),
    (Caption: StrFLType;          Command: '-XMP-dc:Type'),
    (Caption: StrFLEvent;         Command: '-XMP-iptcExt:Event'),
    (Caption: StrFLPersonInImage; Command: '-XMP-iptcExt:PersonInImage')
  );

  UserDefTags = 'UserDefColumns';
  DefaultUserDef: array [0..2] of TFileListColumn =
  (
    (Caption: StrFLDateTime;    Command: '-exifIfd:DateTimeOriginal'),
    (Caption: StrFLRating;      Command: '-xmp-xmp:Rating'),
    (Caption: StrFLPhotoTitle;  Command: '-xmp-dc:Title')
  );

function DefaultColumnWidth(LVHandle: HWND; AColumn: TFileListColumn): integer;
begin
// MS States that it needs padding, but how much? I use 2 WW.
  result := ListView_GetStringWidth(LVHandle, PWideChar(AColumn.Caption + 'WW'));
end;

function ReadColumnDefs(LVHandle: HWND;
                        GUIini: TMemIniFile;
                        ASection: string;
                        ADefaults: array of TFileListColumn): TColumnsArray;
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
        result[Indx] := ADefaults[Indx] ;
        result[Indx].Width := DefaultColumnWidth(LVHandle, result[Indx]);
      end;
    end
    else
    begin
      SetLength(result, DefCnt);
      for Indx := 0 to DefCnt - 1 do
      begin
        Tx := TmpItems[Indx];
        result[Indx].Caption := NextField(Tx, '=');
        result[Indx].Command := NextField(Tx, ' ');
        result[Indx].Width := StrToIntDef(NextField(Tx, ','), DefaultColumnWidth(LVHandle, result[Indx]));
        result[Indx].AlignR := StrToIntDef(NextField(Tx, ';'), 0);
        result[Indx].Options := StrToIntDef(Tx, 0);
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

function ReadCameraTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
begin
  FListCamera := ReadColumnDefs(LVHandle, GUIini, CameraTags, CameraDefaults);
  result := Length(FListCamera);
end;

function ReadLocationTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
begin
  FlistLocation := ReadColumnDefs(LVHandle, GUIini, LocationTags, LocationDefaults);
  result := Length(FlistLocation);
end;

function ReadAboutTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
begin
  FListAbout := ReadColumnDefs(LVHandle, GUIini, AboutTags, AboutDefaults);
  result := Length(FListAbout);
end;

function ReadUserDefTags(LVHandle: HWND; GUIini: TMemIniFile): integer;
begin
  FListUserDef := ReadColumnDefs(LVHandle, GUIini, UserDefTags, DefaultUserDef);
  result := Length(FListUserDef);
end;

procedure WriteCameraTags(GUIini: TMemIniFile);
begin
  WriteColumnDefs(GUIini, CameraTags, FListCamera);
end;

procedure WriteLocationTags(GUIini: TMemIniFile);
begin
  WriteColumnDefs(GUIini, LocationTags, FlistLocation);
end;

procedure WriteAboutTags(GUIini: TMemIniFile);
begin
  WriteColumnDefs(GUIini, AboutTags, FListAbout);
end;

procedure WriteUserDefTags(GUIini: TMemIniFile);
begin
  WriteColumnDefs(GUIini, UserDefTags, FListUserDef);
end;

procedure ResetAllColumnWidths(LVHandle: HWND);
begin
  ResetColumnWidths(LVHandle, FListCamera);
  ResetColumnWidths(LVHandle, FListLocation);
  ResetColumnWidths(LVHandle, FListAbout);
  ResetColumnWidths(LVHandle, FListUserDef);
end;

end.
