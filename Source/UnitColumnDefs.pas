unit UnitColumnDefs;

interface

uses
  System.Classes, System.IniFiles,
  UnitLangResources;

const
  toDecimal = $0001;
  toYesNo   = $0002;
  toHorVer  = $0004;
  toFlash   = $0008;
  toMain    = $0010;
  toBackup  = $0020;
  toCountry = $0040;

  CommandCountryCode = '-XMP-iptcExt:LocationShownCountryCode';
  CommandCountryName = '-XMP-iptcExt:LocationShownCountryName';


type
  TListColRec = record
    Caption: string;
    Command: string;
    Width: integer;
    AlignR: integer;
    Options: Word;
  end;
  TArrayColRec = array of TListColRec;

var
  FListStdColWidth: TArrayColRec; // [Filename][Size][Type][Date modified] Can be extended

  // Note: Default widths are in ReadGui
  // Captions will be loaded at runtime from resourcestrings
  FListCamera: TArrayColRec;
  FlistLocation: TArrayColRec;
  FListAbout: TArrayColRec;
  FListUserDef: TArrayColRec;

function ReadCameraTags(GUIini: TMemIniFile): integer;
procedure WriteCameraTags(GUIini: TMemIniFile);

function ReadLocationTags(GUIini: TMemIniFile): integer;
procedure WriteLocationTags(GUIini: TMemIniFile);

function ReadAboutTags(GUIini: TMemIniFile): integer;
procedure WriteAboutTags(GUIini: TMemIniFile);

function ReadUserDefTags(GUIini: TMemIniFile): integer;
procedure WriteUserDefTags(GUIini: TMemIniFile);

implementation

uses
  System.SysUtils,
  ExifToolsGUI_Utils;

const

  CameraTags = 'CameraColumns';
  CameraDefaults: array [0..9] of TListColRec =
  (
    (Caption: StrFLModel;       Command: '-IFD0:Model';                   Width: 80),
    (Caption: StrFLLensModel;   Command: '-exifIFD:LensModel';            Width: 80),
    (Caption: StrFLExpTime;     Command: '-exifIFD:ExposureTime';         Width: 64; AlignR: 6),
    (Caption: StrFLFNumber;     Command: '-exifIFD:FNumber';              Width: 64; AlignR: 4),
    (Caption: StrFLISO;         Command: '-exifIFD:ISO';                  Width: 48; AlignR: 5),
    (Caption: StrFLExpComp;     Command: '-exifIFD:ExposureCompensation'; Width: 73; AlignR: 4; Options: toDecimal),
    (Caption: StrFLFLength;     Command: '-exifIFD:FocalLength#';         Width: 73; AlignR: 8; Options: toDecimal),
    (Caption: StrFLFlash;       Command: '-exifIFD:Flash#';               Width: 56;            Options: toFlash),
    (Caption: StrFLExpProgram;  Command: '-exifIFD:ExposureProgram';      Width: 88),
    (Caption: StrFLOrientation; Command: '-IFD0:Orientation#';            Width: 80;            Options: toHorVer)
  );

  LocationTags = 'LocationColumns';
  LocationDefaults: array [0..6] of TListColRec =
  (
    (Caption: StrFLDateTime;    Command: '-ExifIFD:DateTimeOriginal';               Width: 120; Options: toMain),
    (Caption: StrFLDateTime;    Command: '-QuickTime:CreateDate';                               Options: toBackup),
    (Caption: StrFLGPS;         Command: '-Composite:GpsPosition#';                 Width: 48;  Options: toYesNo),
    (Caption: StrFLCountry;     Command: CommandCountryCode;                        Width: 80;  Options: toCountry),
    (Caption: StrFLProvince;    Command: '-XMP-iptcExt:LocationShownProvinceState'; Width: 80),
    (Caption: StrFLCity;        Command: '-XMP-iptcExt:LocationShownCity';          Width: 120),
    (Caption: StrFLLocation;    Command: '-XMP-iptcExt:LocationShownSublocation';   Width: 120)
  );

  AboutTags = 'AboutColumns';
  AboutDefaults: array [0..4] of TListColRec =
  (
    (Caption: StrFLArtist;        Command: '-IFD0:Artist';                          Width: 120),
    (Caption: StrFLRating;        Command: '-XMP-xmp:Rating';                       Width: 48),
    (Caption: StrFLType;          Command: '-XMP-dc:Type';                          Width: 120),
    (Caption: StrFLEvent;         Command: '-XMP-iptcExt:Event';                    Width: 120),
    (Caption: StrFLPersonInImage; Command: '-XMP-iptcExt:PersonInImage';            Width: 120)
  );

  UserDefTags = 'UserDefColumns';
  DefaultUserDef: array [0..2] of TListColRec =
  (
    (Caption: StrFLDateTime;    Command: '-exifIfd:DateTimeOriginal'; Width: 120),
    (Caption: StrFLRating;      Command: '-xmp-xmp:Rating';           Width: 60),
    (Caption: StrFLPhotoTitle;  Command: '-xmp-dc:Title';             Width: 160)
  );

function ReadColumnDefs(GUIini: TMemIniFile; ASection: string; Defaults: array of TListColRec): TArrayColRec;
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
      SetLength(result, Length(Defaults));
      for Indx := 0 to High(Defaults) do
        result[Indx] := Defaults[Indx]
    end
    else
    begin
      SetLength(result, DefCnt);
      for Indx := 0 to DefCnt - 1 do
      begin
        Tx := TmpItems[Indx];
        result[Indx].Caption := NextField(Tx, '=');
        result[Indx].Command := NextField(Tx, ' ');
        result[Indx].Width := StrToIntDef(NextField(Tx, ','), 80);
        result[Indx].AlignR := StrToIntDef(NextField(Tx, ';'), 0);
        result[Indx].Options := StrToIntDef(Tx, 0);
      end;
    end;
  finally
    TmpItems.Free;
  end;
end;

procedure WriteColumnDefs(GUIini: TMemIniFile; ASection: string; ColumnDefs: array of TListColRec);
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

function ReadCameraTags(GUIini: TMemIniFile): integer;
begin
  FListCamera := ReadColumnDefs(GUIini, CameraTags, CameraDefaults);
  result := Length(FListCamera);
end;

function ReadLocationTags(GUIini: TMemIniFile): integer;
begin
  FlistLocation := ReadColumnDefs(GUIini, LocationTags, LocationDefaults);
  result := Length(FlistLocation);
end;

function ReadAboutTags(GUIini: TMemIniFile): integer;
begin
  FListAbout := ReadColumnDefs(GUIini, AboutTags, AboutDefaults);
  result := Length(FListAbout);
end;

function ReadUserDefTags(GUIini: TMemIniFile): integer;
begin
  FListUserDef := ReadColumnDefs(GUIini, UserDefTags, DefaultUserDef);
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

end.
