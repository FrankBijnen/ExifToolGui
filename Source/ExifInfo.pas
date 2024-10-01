unit ExifInfo;
{.DEFINE DEBUG_XMP}

// ****************************QUICK METADATA ACCESS*************************
// Not all formats supported. Check Value of 'Supported'

(*

Formats known to work:

Manufacturer independent (usually)
                Tif                      
                Jpg                       E.G.: Nokia Lumia 920, Samsung SM-G920F, SM-G960F
                Dng                       E.G.: Pentax K-x, K5II, K3. All DNG's Converted by Dng converter

Pentax          Pef                       K100D, K-x, K5-IIs, K-3
Nikon           Nef                       D50, D70
Canon           Crw (partial)             EOS DIGITAL REBEL, EOS 10D
                    Crw has no Exif.
                    Data needed for the filelist is taken from the Canon makernotes and put in the Ifd0 ExifIfd records
                    XMP can be read.
                Cr2                       EOS 40D, EOS 700D, EOS 1100D
                Cr3                       EOS R, EOS M50
Sony            Arw                       ILCE-6000
FujiFilm        Raf                       X-T20, FinePix S5Pro, FinePix 2400Zoom
Olympus         Orf                       E-300
Panasonic       Rw2                       DMC-FZ70, DMC-LX3
Google          Jpg                       Pixel 7 Pro
PhaseOne        Iiq                       Credo 40
*)

interface

uses System.Classes, System.SysUtils, System.Generics.Collections, System.Types,
     Vcl.StdCtrls, ExifToolsGUI_StringList;

type
  TMetaInfo = variant;
  TVarData = TObjectDictionary<string, TMetaInfo>;

  IFDentryRec = packed record
    Tag: word;
    FieldType: word;
    TypeCount: longint;
    ValueOffs: longint;
  end;

  IPTCrec = packed record
    HasData: boolean;
    ObjectName: string;
    Category: string;
    SuppCategories: string;
    Keywords: string;
    By_line, By_lineTitle: string;
    Country, Province_State, City, Sub_location: string;
    Headline: string;
    CopyrightNotice: string;
    Caption_Abstract: string;
    Writer_Editor: string;
    procedure Clear;
  end;

  IFD0rec = packed record
    HasData: boolean;
    Make, Model: string;
    PreviewOffset, PreviewSize: longint;
    OrientationValue: word; // 1=Normal, 3=180, 6=90right, 8=90left, else=Mirror
    Orientation: string[4];
    Xresolution, Yresolution: word;
    ResolutionUnit: string[5];
    Software: string;
    DateTimeModify: string[19];
    Artist: string;
    Copyright: string;
    procedure Clear;
  end;

  ExifIFDrec = packed record
    HasData: boolean;
    ExposureTime: string[7];
    FNumber: string[5];
    ExposureProgram: string;
    ISO: string[5];
    DateTimeOriginal, DateTimeDigitized, CreateDate: string[19];
    ExposureCompensation: string[7];
    FlashValue: word; // if (ExifIFD.Flash and 1)=1 then 'Flash=Yes'
    Flash: string[3];
    FocalLength: string[7];
    ColorSpace: string[13];
    FLin35mm: string[7];
    LensInfo: string;
    LensMake: string;
    LensModel: string;
    procedure Clear;
  end;

  InteropIFDrec = packed record
    HasData: boolean;
    InteropIndex: string[9];
    procedure Clear;
  end;

  GPSrec = packed record
    HasData: boolean;
    GpsLatitudeRef: string[1];  // North/South
    GpsLatitude: string[11];
    GpsLongitudeRef: string[1]; // East/West
    GpsLongitude: string[11];
    GpsAltitudeRef: string[1];  // +/-
    GpsAltitude: string[5];
    GeoLat: string[11];         // for OSM Map
    GeoLon: string[11];         // for OSM Map
    GpsPosition: string;        // For GPS Tagged?
    procedure Clear;
  end;

  MakernotesRec = packed record
    HasData: boolean;
    LensFocalRange: string[11]; // i.e."17-55"
    procedure Clear;
  end;

  XMPrec = packed record
    HasData: boolean;
    Creator, Rights: string;
    Date: string[19];
    PhotoType: string;
    Title, Event: string;
    CountryCodeShown, CountryNameShown, ProvinceShown, CityShown, LocationShown: string;
    PersonInImage: string;
    Keywords: string; // =Subject
    Rating: string[1];
    procedure Clear;
  end;

  ICCrec = packed record
    HasData: boolean;
    ProfileCMMType: string[4];
    ProfileClass: string[4];
    ColorSpaceData: string[4];
    ProfileConnectionSpace: string[4];
    PrimaryPlatform: string[4];
    DeviceManufacturer: string[4];
    ProfileCreator: string[4];
    ProfileDescription: string[31];
    procedure Clear;
  end;

  TParseIFDProc = procedure(IFDentry: IFDentryRec) of object;
  TGetOption = (gmXMP, gmIPTC, gmGPS, gmICC);
  TGetOptions = set of TGetOption;
  TSupportedType = (supJPEG, supTIFF, supCRW, supCR3);
  TSupportedTypes = set of TSupportedType;

  FotoRec = packed record
    IFD0: IFD0rec;
    ExifIFD: ExifIFDrec;
    InteropIFD: InteropIFDrec;
    GPS: GPSrec;
    IPTC: IPTCrec;
    XMP: XMPrec;
    ICC: ICCrec;
    GroupName: string;
    VarData: TVarData;
    FieldNames: TStrings;
    Supported: TSupportedTypes;
    ErrNotOpen: boolean;
    FotoF: TBufferedFileStream;
    GetOptions: TGetOptions;
    FotoKeySep: string[3];
    IsMM: boolean;
    WordData: word;
    DWordData: dword;
    XMPoffset: array of int64;
    XMPsize: array of int64;
    IPTCsize, IPTCoffset: int64;
    TIFFoffset, ExifIFDoffset, GPSoffset: int64;
    ICCoffset, InteropOffset, JPGfromRAWoffset: int64;
    ICCSize: word;
    FileName: string;
    FileSize: int64;
    procedure Clear;
    procedure AddXmpBlock(AnOffset, ASize: int64);
    procedure SetVarData(const InVarData: TVarData; InFieldNames: TStrings);
    procedure AddBag(var BagData: TMetaInfo; const ANode: TMetaInfo);
    function GetETTagName(ATagName: string): string;
    function GetKeyName(const AKey: string): string;
    function AddVarData(const AKey: string; AValue: TMetaInfo; AllowBag: boolean = false): TMetaInfo;

    procedure AdvanceNulls(Count: integer);
    function DecodeASCII(IFDentry: IFDentryRec; MaxLen: integer = 255): string;
    function DecodeWord(IFDentry: IFDentryRec): word;
    function DecodeRational(IFDentry: IFDentryRec): word;
    function DecodeExifLens(IFDentry: IFDentryRec): string;
    function ConvertRational(IFDentry: IFDentryRec; Signed: boolean): string;
    function GetRational(IFDentry: IFDentryRec): single;
    function DecodeGPS(IFDentry: IFDentryRec; IsLat: boolean): string;
    procedure ParseIPTC;
    procedure ParseIFD0(IFDentry: IFDentryRec);
    procedure ParseExifIFD(IFDentry: IFDentryRec);
    procedure ParseInterop(IFDentry: IFDentryRec);
    procedure ParseGPS(IFDentry: IFDentryRec);
    procedure CorrectGps;
    procedure ParseICCprofile;
    procedure GetIFDentry(var IFDentry: IFDentryRec);
    procedure ParseIfd(Offset: int64; ParseProc: TParseIFDProc);
    procedure ParseXMPBlock(TmpStream: TMemoryStream);
    procedure ReadCanonVrd;
    function GetCRWString(ALength: word): string;
    function CanonEv(AEV: smallint): double;
    procedure ReadCiff(AOffset, ALength: int64; Depth: integer);

    procedure ReadTIFF;
    procedure ReadJPEG;
    procedure ReadXMP;
    function SkipCr3Header: word;
    procedure ReadCr3;
    function SkipFujiHeader: word;
    procedure ReadFuji;

  end;

  TMetaData = class(TObject)
    FieldNames: TStringList;
    VarData: TVarData;
    FileName: string;
    Foto: Fotorec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReadMeta(const AName: string; AGetOptions: TGetOptions);
    function FieldData(FieldName: string): string;
  end;

function GetMetadata(AName: string; AGetOptions: TGetOptions; VarData: TVarData = nil; FieldNames: TStrings = nil): FotoRec;
procedure ChartFindFiles(StartDir, FileMask: string; SubDir: boolean;
                         var ETFocal, ETFnum, ETIso: TNrSortedStringList);

implementation

uses
  System.StrUtils, System.Variants, System.Math, System.DateUtils,
  Winapi.Windows, Vcl.Forms, Vcl.Dialogs,
  Main, ExifTool,
  ExifToolsGUI_Utils,
  UnitLangResources, // Language
  Xml.VerySimple,    // XML parsing for XMP
  SDJPegTypes;       // JPEG APP types

var
  Encoding: TEncoding;
  GpsFormatSettings: TFormatSettings;  // for StrToFloatDef -see Initialization

constructor TMetaData.Create;
begin
  inherited Create;
  VarData := TVarData.Create;
  FieldNames := TStringList.Create;
  FieldNames.Sorted := true;
  FieldNames.Duplicates := TDuplicates.dupIgnore;
end;

destructor TMetaData.Destroy;
begin
  VarData.Free;
  FieldNames.Free;

  inherited Destroy;
end;

procedure TMetaData.ReadMeta(const AName: string; AGetOptions: TGetOptions);
begin
  VarData.Clear;
  FieldNames.Clear;
  Foto := GetMetadata(AName, AGetOptions, VarData, FieldNames);
end;

function TMetaData.FieldData(FieldName: string): string;
var
  LowerFieldName: string;
  P: integer;
begin
  result := '';

  LowerFieldName := LowerCase(FieldName);
  P := Pos('#', LowerFieldName);
  if (P > 0) then
    SetLength(LowerFieldName, P -1);

  if (LeftStr(LowerFieldName, 1) = '-') then
    LowerFieldName := Copy(LowerFieldName, 2);

  if (VarData.ContainsKey(LowerFieldName)) then
    result := VarData[LowerFieldName];
end;

procedure XMPrec.Clear;
begin
  Self := Default(XMPrec);
end;

procedure MakernotesRec.Clear;
begin
  Self := Default(MakernotesRec);
end;

procedure GPSrec.Clear;
begin
  Self := Default(GPSrec);
end;

procedure InteropIFDrec.Clear;
begin
  Self := Default(InteropIFDrec);
end;

procedure ExifIFDrec.Clear;
begin
  Self := Default(ExifIFDrec);
end;

procedure IFD0rec.Clear;
begin
  Self := Default(IFD0rec);
end;

procedure IPTCrec.Clear;
begin
  Self := Default(IPTCrec);
end;

procedure ICCrec.Clear;
begin
  Self := Default(ICCrec);
end;

procedure FotoRec.Clear;
begin
  IFD0.Clear;
  ExifIFD.Clear;
  InteropIFD.Clear;
  GPS.Clear;
  IPTC.Clear;
  XMP.Clear;
  ICC.Clear;

  Self := Default(FotoRec);
  SetLength(XmpSize, 0);
  SetLength(XMPoffset, 0);
end;

procedure FotoRec.AddXmpBlock(AnOffset, ASize: int64);
begin
  XMPoffset := XMPoffset + [AnOffset];
  XmpSize := XmpSize + [ASize];
end;

procedure FotoRec.SetVarData(const InVarData: TVarData; InFieldNames: TStrings);
begin
  VarData := InVarData;
  if (Assigned(VarData)) then
    VarData.Clear;

  FieldNames := InFieldNames;
  if (Assigned(FieldNames)) then
    FieldNames.Clear;
end;

function SwapL(L: Cardinal): Cardinal;
type
  TCardinalAsBytes = array[0..3] of byte;
begin
  TCardinalAsBytes(result)[0] := TCardinalAsBytes(L)[3];
  TCardinalAsBytes(result)[1] := TCardinalAsBytes(L)[2];
  TCardinalAsBytes(result)[2] := TCardinalAsBytes(L)[1];
  TCardinalAsBytes(result)[3] := TCardinalAsBytes(L)[0];
end;

function StripLen(const Tx: string; MaxLen: integer = 255): string;
begin
  result := Tx;
  if Length(result) > MaxLen then
  begin
    result[MaxLen] := '…';
    SetLength(result, MaxLen);
  end;
end;

function IsValidMarker(APPType: byte): boolean;
begin
  case APPType of
    mkSOF0 , mkSOF1 , mkSOF2 , mkSOF3 , mkSOF5 , mkSOF6 , mkSOF7 , mkJPG ,
    mkSOF9 , mkSOF10 , mkSOF11 , mkSOF13 , mkSOF14 , mkSOF15,

    mkDHT , mkDAC , mkRST0 , mkRST1 , mkRST2 , mkRST3 , mkRST4 , mkRST5 ,
    mkRST6 , mkRST7 , mkSOI , mkEOI , mkSOS , mkDQT , mkDNL , mkDRI ,
    mkDHP , mkEXP,

    mkAPP0 , mkAPP1 , mkAPP2 , mkAPP3 , mkAPP4 , mkAPP5 , mkAPP6 , mkAPP7,
    mkAPP8 , mkAPP9 , mkAPP10 , mkAPP11 , mkAPP12 , mkAPP13 , mkAPP14,
    mkAPP15,

    mkJPG0 , mkJPG13 , mkCOM:
      result := true;
    else
      result := false;
  end;
end;

procedure FotoRec.AddBag(var BagData: TMetaInfo; const ANode: TMetaInfo);
begin
  if (VarType(BagData) <> varString) then // Should only be allowed for strings!
    BagData := ANode
  else
  begin
    if (BagData = '') then
      BagData := ANode
    else
      BagData := BagData + FotoKeySep + ANode;
  end;
end;

function FotoRec.GetETTagName(ATagName: string): string;
begin
  result := StringReplace(ATagName, 'Xmp-Iptc4xmpExt:',  'Xmp-IptcExt:',  [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(result,   'Xmp-Iptc4xmpCore:', 'XMP-iptcCore:', [rfReplaceAll, rfIgnoreCase]);
end;

function FotoRec.GetKeyName(const AKey: string): string;
begin
  if EndsText('-', GroupName) then
    result := GetETTagName(GroupName + AKey)
  else
    result := (GetETTagName(GroupName) + ':' + AKey);
end;

function FotoRec.AddVarData(const AKey: string; AValue: TMetaInfo; AllowBag: boolean = false): TMetaInfo;
var
  KeyName: string;
begin
  if Assigned(VarData) then
  begin
    KeyName := GetKeyName(AKey);
    if (Assigned(FieldNames)) then
      FieldNames.Add(KeyName);
    KeyName := LowerCase(KeyName);

    if (VarData.ContainsKey(KeyName)) then
    begin
      if (AllowBag) then
      begin
        result := VarData.Items[KeyName];
        AddBag(result, AValue);
        VarData[KeyName] := result;
      end
      else
      begin
        result := AValue;
        VarData[KeyName] := result;
      end;
    end
    else
    begin
      result := AValue;
      VarData.Add(KeyName, result);
    end;
  end
  else
    result := AValue;
end;

procedure FotoRec.AdvanceNulls(Count: integer);
var
  Cnt: integer;
  AppByte: byte;
begin
  for Cnt := 1 to Count do
  begin
    AppByte := $ff;
    while (AppByte <> $00) do
      FotoF.Read(AppByte, SizeOf(AppByte));
  end;
end;

function FotoRec.DecodeASCII(IFDentry: IFDentryRec; MaxLen: integer = 255): string;
var
  Bytes: TBytes;
  W1: word;
  L1: longint;
begin
  W1 := IFDentry.TypeCount - 1; // last byte is #0
  SetLength(Bytes, W1);
  L1 := IFDentry.ValueOffs;
  if W1 > 3 then
  begin
    FotoF.Seek(TIFFoffset + L1, TSeekOrigin.soBeginning);
    FotoF.Read(Bytes[0], W1);
  end
  else
  begin
    if IsMM then
      L1 := SwapL(L1);
    Move(L1, Bytes[0], W1);
  end;
  result := '';
  if (Encoding.GetCharCount(Bytes) > 0) then
  begin
    result := Encoding.GetString(Bytes);
    if (result[1] = #0) then
      result := '-'; // in case tag is defined and empty
  end;
end;

function FotoRec.DecodeWord(IFDentry: IFDentryRec): word;
var
  L1: longint;
begin
  L1 := IFDentry.ValueOffs;
  if IsMM then
    L1 := SwapL(L1);
  Result := L1;
  if IsMM then
    Result := Swap(Result);
end;

function FotoRec.DecodeRational(IFDentry: IFDentryRec): word;
var
  L1, L2: longint;
begin
  FotoF.Seek(TIFFoffset + IFDentry.ValueOffs, TSeekOrigin.soBeginning);
  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4);
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
  end;
  if L2 > 0 then
    Result := L1 div L2
  else
    Result := 0;
end;

function FotoRec.DecodeExifLens(IFDentry: IFDentryRec): string;
var
  L1, L2, L3, L4: longint;
  Digits: integer;
  Tx: string[23];
begin
  FotoF.Seek(TIFFoffset + IFDentry.ValueOffs, TSeekOrigin.soBeginning);
  // Min-Max focal length
  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4);
  FotoF.Read(L3, 4);
  FotoF.Read(L4, 4);
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
    L3 := SwapL(L3);
    L4 := SwapL(L4);
  end;
  if (L2 <> 0) and (L4 <> 0) then
  begin
    if (L1 / L2) = int(L1 / L2) then
      Digits := 0
    else
      Digits := 1;
    Tx := FloatToStrF(L1 / L2, ffFixed, 7, Digits);
    if (L1 / L2) <> (L3 / L4) then
      Tx := Tx + '-' + FloatToStrF(L3 / L4, ffFixed, 7, Digits);
  end
  else
    Tx := '?';
  Tx := Tx + 'mm f/';
  // Min-Max aperture
  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4);
  FotoF.Read(L3, 4);
  FotoF.Read(L4, 4);
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
    L3 := SwapL(L3);
    L4 := SwapL(L4);
  end;
  if (L2 <> 0) and (L4 <> 0) then
  begin
    Tx := Tx + FloatToStrF(L1 / L2, ffFixed, 7, 1);
    if (L1 / L2) <> (L3 / L4) then
      Tx := Tx + '-' + FloatToStrF(L3 / L4, ffFixed, 7, 1);
  end
  else
    Tx := Tx + '?';
  Result := StringReplace(Tx, ',', '.', [rfReplaceAll]);
end;

function FotoRec.ConvertRational(IFDentry: IFDentryRec; Signed: boolean): string;
var
  L1, L2: longint;
  Tx: string[15];
begin
  FotoF.Seek(TIFFoffset + IFDentry.ValueOffs, TSeekOrigin.soBeginning);
  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4);
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
  end;
  if L1 = 0 then
    Result := '0.0'
  else
  begin
    if Signed then
    begin // for Exp.Compensation values
      Tx := FloatToStrF(L1 / L2, ffFixed, 7, 2);
      if L1 > 0 then
        Tx := '+' + Tx;
      L1 := Pos(',', Tx);
      if L1 > 0 then
        Tx[L1] := '.';
      L1 := length(Tx);
      SetLength(Tx, L1 - 1);
      Result := Tx;
    end
    else
    begin // for Exp.Time values [2s, 1/25s, 1/800s,..]
      if L2 = 1 then
        Result := IntToStr(L1) // i.e. for 2/1s -> 2s
      else
      begin
        if L1 > L2 then
        begin // i.e. for 2.5s
          Tx := FloatToStrF(L1 / L2, ffFixed, 7, 1);
          L1 := Pos(',', Tx);
          if L1 > 0 then
            Tx[L1] := '.';
          Result := Tx;
        end
        else
        begin
          L1 := round(1 / (L1 / L2));
          Result := '1/' + IntToStr(L1);
        end;
      end;
    end;
  end;
end;

function FotoRec.GetRational(IFDentry: IFDentryRec): single;
var
  L1, L2: longint;
begin
  FotoF.Seek(TIFFoffset + IFDentry.ValueOffs, TSeekOrigin.soBeginning);
  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4);
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
  end;
  if L2 = 0 then
    Result := 0
  else
    Result := L1 / L2;
end;

function FotoRec.DecodeGPS(IFDentry: IFDentryRec; IsLat: boolean): string;
var
  R, Rd: double;
  L1, L2: longint;
  Tx, Ty: string[11];
  Sec: string[7]; // Tx=Deg°Min.Sec, Ty=Deg.min°
begin
  GroupName := 'Gps';
  FotoF.Seek(TIFFoffset + IFDentry.ValueOffs, TSeekOrigin.soBeginning);
  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4); // =Deg
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
  end;
  if L2 > 0 then
    Tx := IntToStr(L1 div L2) + '°'
  else
    Tx := '0°';
  if L2 > 0 then
    Rd := L1 div L2
  else
    Rd := 0; // <-DecDeg

  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4); // =Min
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
  end;
  if L2 > 0 then
    Tx := Tx + IntToStr(L1 div L2) + '.'
  else
    Tx := Tx + '0.';
  if L2 > 0 then
    Ty := IntToStr(L1 div L2)
  else
    Ty := '0'; // <-DecMin

  FotoF.Read(L1, 4);
  FotoF.Read(L2, 4); // =Sec
  if IsMM then
  begin
    L1 := SwapL(L1);
    L2 := SwapL(L2);
  end;
  if L2 > 0 then
    R := L1 / L2 / 60
  else
    R := 0;
  Sec := FloatToStrF(R, ffFixed, 7, 4);
  Delete(Sec, 1, 2);
  Tx := Tx + Sec;

  // Compute decimal coordinate. For OsmMap
  Ty := Ty + ',' + Sec;
  R := RD + StrToFloatDef(Ty, 0, GpsFormatSettings) / 60;
  if (R <> 0) then
  begin
    Ty := FloatToStrF(R, ffFixed, 8, 6, FloatFormatSettings);
    if IsLat then
      GPS.GeoLat := AddVarData('GeoLat', Ty)
    else
      GPS.GeoLon := AddVarData('GeoLon', Ty);
  end;
  Result := Tx;
end;

// =================================PARSING======================================
// Note: Not used in ExifToolGui
procedure FotoRec.ParseIPTC;
var
  IPTCtagID: byte;
  IPTCtagSz: word;
  Tx: string;
  Bytes: Tbytes;

begin
  GroupName := 'Iptc';
  FotoF.Read(IPTCtagID, 1);
  FotoF.Read(IPTCtagSz, 2);
  IPTCtagSz := Swap(IPTCtagSz);
  Dec(IPTCsize, 3);
  SetLength(Bytes, IPTCtagSz);
  FotoF.Read(Bytes[0], IPTCtagSz);
  Tx := '';
  if (Encoding.GetCharCount(Bytes) > 0) then
    Tx := Encoding.GetString(Bytes);
  Dec(IPTCsize, IPTCtagSz);
  with IPTC do
  begin
    HasData := true;
    case IPTCtagID of
      5:
        ObjectName := AddVarData('ObjectName', StripLen(Tx, 32));
      15:
        Category := AddVarData('Category', StripLen(Tx, 3));
      20:
        SuppCategories := AddVarData('SuppCategories', Tx, true);
      25:
        Keywords := AddVarData('Keywords', Tx, true);
      80:
        By_line := AddVarData('By_line', StripLen(Tx, 32));
      85:
        By_lineTitle := AddVarData('By_lineTitle', StripLen(Tx, 32));
      90:
        City := AddVarData('City', StripLen(Tx, 31));
      92:
        Sub_location := AddVarData('Sub_location', StripLen(Tx, 31));
      95:
        Province_State := AddVarData('Province_State', StripLen(Tx, 31));
      101:
        Country := AddVarData('Country', StripLen(Tx, 31));
      105:
        Headline := AddVarData('Headline', StripLen(Tx, 64));
      116:
        CopyrightNotice := AddVarData('CopyrightNotice', StripLen(Tx, 64));
      120:
        Caption_Abstract := AddVarData('Caption_Abstract', StripLen(Tx, 128));
      122:
        Writer_Editor := AddVarData('Writer_Editor', StripLen(Tx, 32));
    end;
  end;
end;

// ------------------------------------------------------------------------------
procedure FotoRec.ParseIFD0(IFDentry: IFDentryRec);
var
  SavePos: int64;
begin
  GroupName := 'Ifd0';
  SavePos := FotoF.Position;
  with IFD0 do
  begin
    HasData := true;
    case IFDentry.Tag of
      $002E:
        JPGfromRAWoffset := IFDentry.ValueOffs; // Panasonic RW2
      $010F:
        Make := AddVarData('Make', DecodeASCII(IFDentry, 64));
      $0110:
        Model := AddVarData('Model', DecodeASCII(IFDentry, 64));
      $0111:
        PreviewOffset := IFDentry.ValueOffs;
      $0112:
        begin
          OrientationValue := AddVarData('OrientationValue', DecodeWord(IFDentry));
          case (OrientationValue) of
            1,2:
              Orientation := StrHor;
            3:
              Orientation := StrRot;
            4..8:
              Orientation := StrVer;
          else
            Orientation:= '-';
          end;
          AddVarData('Orientation', Orientation);
        end;
      $0117:
        PreviewSize := AddVarData('PreviewSize', IFDentry.ValueOffs);
      $011A:
        Xresolution := AddVarData('Xresolution', DecodeRational(IFDentry));
      $011B:
        Yresolution := AddVarData('Yresolution', DecodeRational(IFDentry));
      $0128:
        begin
          case DecodeWord(IFDentry) of
            2:
              ResolutionUnit := 'dpi';
            3:
              ResolutionUnit := 'dpcm';
          else
            ResolutionUnit := '-';
          end;
          AddVarData('ResolutionUnit', ResolutionUnit);
        end;
      $0131:
        Software := AddVarData('Software', DecodeASCII(IFDentry, 64));
      $0132:
        DateTimeModify := AddVarData('DateTimeModify', DecodeASCII(IFDentry));
      $013B:
        Artist := AddVarData('Artist', DecodeASCII(IFDentry, 64));
      $02BC:
          AddXmpBlock(IFDentry.ValueOffs + TIFFoffset, IFDentry.TypeCount);
      $8298:
        Copyright := AddVarData('Copyright', DecodeASCII(IFDentry, 64));
      $83BB:
        begin
          if IFDentry.FieldType = 1 then
            IPTCsize := IFDentry.TypeCount // used by DPP
          else if IFDentry.FieldType = 4 then
            IPTCsize := IFDentry.TypeCount * 4; // used by Exiftool
          if IPTCsize > 0 then
            IPTCoffset := IFDentry.ValueOffs;
        end;
      $8769:
        ExifIFDoffset := IFDentry.ValueOffs;
      $8773:
        ICCoffset := IFDentry.ValueOffs;
      $8825:
        GPSoffset := IFDentry.ValueOffs;
    end;
  end;
  FotoF.Seek(SavePos, TSeekOrigin.soBeginning);
end;

// ------------------------------------------------------------------------------
procedure FotoRec.ParseExifIFD(IFDentry: IFDentryRec);
var
  SavePos: int64;
begin
  GroupName := 'ExifIfd';
  SavePos := FotoF.Position;
  with ExifIFD do
  begin
    HasData := true;
    case IFDentry.Tag of
      $829A:
        ExposureTime := AddVarData('ExposureTime', ConvertRational(IFDentry, false));
      $829D:
        FNumber := AddVarData('FNumber', FormatExifDecimal(GetRational(IFDentry), 1));
      $8822:
        begin
          case DecodeWord(IFDentry) of
            0:
              ExposureProgram := 'Not Defined';
            1:
              ExposureProgram := 'Manual';
            2:
              ExposureProgram := 'Program AE';
            3:
              ExposureProgram := 'Aperture-priority AE';
            4:
              ExposureProgram := 'Shutter speed priority AE';
            5:
              ExposureProgram := 'Creative (Slow speed)';
            6:
              ExposureProgram := 'Action (High speed)';
            7:
              ExposureProgram := 'Portrait';
            8:
              ExposureProgram := 'Landscape';
            9:
              ExposureProgram := 'Bulb';
          else
            ExposureProgram := 'Unknown';
          end;
          AddVarData('ExposureProgram', ExposureProgram);
        end;
      $8827:
        ISO := AddVarData('ISO', IntToStr(DecodeWord(IFDentry)));
      $9003:
        DateTimeOriginal := AddVarData('DateTimeOriginal', DecodeASCII(IFDentry));
      $9004:
        begin
          DateTimeDigitized := AddVarData('DateTimeDigitized', DecodeASCII(IFDentry));
          CreateDate := AddVarData('CreateDate', DateTimeDigitized);
        end;
      $9204:
        ExposureCompensation := AddVarData('ExposureCompensation', ConvertRational(IFDentry, true));
      $9209:
        begin
          FlashValue := AddVarData('FlashValue', DecodeWord(IFDentry) or $FF00); // $FFnn=tag exist indicator
          if (FlashValue and $FF00) <> 0 then
          begin
            if (FlashValue and 1) = 1 then
              Flash := StrYes
            else
              Flash := StrNo;
          end
          else
            Flash := '-';
          AddVarData('Flash', Flash);
        end;
      $920A:
        FocalLength := AddVarData('FocalLength', FormatExifDecimal(GetRational(IFDentry), 1));
      $A001:
        begin
          case DecodeWord(IFDentry) of
            $0001:
              ColorSpace := 'sRGB';
            $0002:
              ColorSpace := 'AdobeRGB';
            $FFFD:
              ColorSpace := 'WideRGB';
            $FFFE:
              ColorSpace := 'ICCprofile';
            $FFFF:
              ColorSpace := 'Uncalibrated';
          end;
          AddVarData('ColorSpace', ColorSpace);
        end;
      $A005:
        InteropOffset := IFDentry.ValueOffs;
      $A405:
        FLin35mm := AddVarData('FLin35mm', IntToStr(DecodeWord(IFDentry)));
      $A432:
        LensInfo := AddVarData('LensInfo', DecodeExifLens(IFDentry));
      $A433:
        LensMake := AddVarData('LensMake', DecodeASCII(IFDentry, 23));
      $A434:
        LensModel := AddVarData('LensModel', DecodeASCII(IFDentry, 47));
    end;
  end;
  FotoF.Seek(SavePos, TSeekOrigin.soBeginning);
end;

// ------------------------------------------------------------------------------
procedure FotoRec.ParseInterop(IFDentry: IFDentryRec);
var
  SavePos: int64;
begin
  GroupName := 'InterOp';
  SavePos := FotoF.Position;
  with InteropIFD do
  begin
    HasData := true;
    case IFDentry.Tag of
      $0001:
        begin
          InteropIndex := DecodeASCII(IFDentry);
          if InteropIndex = 'R03' then
            InteropIndex := 'R03=Adobe'
          else if InteropIndex = 'R98' then
            InteropIndex := 'R98=sRGB';
          AddVarData('InteropIndex', InteropIndex);
        end;
    end;
  end;
  FotoF.Seek(SavePos, TSeekOrigin.soBeginning);
end;

// ------------------------------------------------------------------------------
procedure FotoRec.ParseGPS(IFDentry: IFDentryRec);
var
  SavePos: int64;
begin
  GroupName := 'Gps';
  SavePos := FotoF.Position;
  with GPS do
  begin
    HasData := true;
    case IFDentry.Tag of
      $01:
        GpsLatitudeRef := AddVarData('GpsLatitudeRef', DecodeASCII(IFDentry));
      $02:
        GpsLatitude := AddVarData('GpsLatitude', DecodeGPS(IFDentry, true));
      $03:
        GpsLongitudeRef := AddVarData('GpsLongitudeRef', DecodeASCII(IFDentry));
      $04:
        GpsLongitude := AddVarData('GpsLongitude', DecodeGPS(IFDentry, false));
      $05:
        begin
          if IFDentry.ValueOffs = 0 then
            GpsAltitudeRef := '+'
          else
            GpsAltitudeRef := '-';
          AddVarData('GpsAltitudeRef', GpsAltitudeRef);
        end;
      $06:
        GpsAltitude := AddVarData('GpsAltitude', IntToStr(DecodeRational(IFDentry)) + 'm');
    end;
  end;
  FotoF.Seek(SavePos, TSeekOrigin.soBeginning);
end;

// For FileList
procedure FotoRec.CorrectGps;
begin
  with Gps do
  begin
    if (GpsLatitudeRef = 'S') and (GeoLat <> '') then
      GeoLat := '-' + GeoLat;
    if (GpsLongitudeRef = 'W') and (GeoLon <> '') then
      GeoLon := '-' + GeoLon;
    GroupName := 'Composite';
    if (GeoLat <> '') or
       (GeoLon <> '') then
      GpsPosition := AddVarData('GpsPosition', StrYes)
    else
      GpsPosition := AddVarData('GpsPosition', StrNo);
  end;
end;

// ==============================================================================
// Note: Not used in ExifToolGui
procedure FotoRec.ParseICCprofile;
var
  XLong: int64;
  Remain: int64;
  XWord: word;
  Tx: string[31];
begin
  GroupName := 'ICCProfile';
  FotoF.Seek(ICCoffset, TSeekOrigin.soBeginning);

  ICC.HasData := true;
  FotoF.Read(ICC.ProfileCMMType[1], 4);
  ICC.ProfileCMMType[0] := #4;
  AddVarData('ProfileCMMType', ICC.ProfileCMMType);

  FotoF.Read(Tx[1], 4); // skip ProfileVersion
  FotoF.Read(ICC.ProfileClass[1], 4);
  ICC.ProfileClass[0] := #4;
  AddVarData('ProfileClass', ICC.ProfileClass);

  FotoF.Read(ICC.ColorSpaceData[1], 4);
  ICC.ColorSpaceData[0] := #4;
  AddVarData('ColorSpaceData', ICC.ColorSpaceData);

  FotoF.Read(ICC.ProfileConnectionSpace[1], 4);
  ICC.ProfileConnectionSpace[0] := #4;
  AddVarData('ProfileConnectionSpace', ICC.ProfileConnectionSpace);

  FotoF.Read(Tx[1], 16); // skip ProfileDateTime & ProfileFileSignature
  FotoF.Read(ICC.PrimaryPlatform[1], 4);
  ICC.PrimaryPlatform[0] := #4;
  AddVarData('PrimaryPlatform', ICC.PrimaryPlatform);

  FotoF.Read(Tx[1], 4); // skip CMMFlags
  FotoF.Read(ICC.DeviceManufacturer[1], 4);
  ICC.DeviceManufacturer[0] := #4;
  AddVarData('DeviceManufacturer', ICC.DeviceManufacturer);

  FotoF.Read(Tx[1], 28); // skip DeviceModel... goto ProfileCreator
  FotoF.Read(ICC.ProfileCreator[1], 4);
  ICC.ProfileCreator[0] := #4;
  AddVarData('ProfileCreator', ICC.ProfileCreator);

  Remain := (ICCoffset + ICCSize) - FotoF.Position; // End of the ICC profile
  Tx := '????';
  while (Remain > 0) and
        (Tx <> 'desc') do
  begin
    Dec(Remain, 4);
    FotoF.Read(Tx[1], 4);
  end;
  FotoF.Read(XLong, 4);
  XLong := SwapL(XLong);
  FotoF.Seek(ICCoffset - 4 + XLong, TSeekOrigin.soBeginning);
  FotoF.Read(Tx[1], 4);
  if Tx = 'desc' then
  begin
    FotoF.Read(Tx[1], 6); // skip zeroes
    FotoF.Read(XWord, 2);
    XWord := Swap(XWord);
    XWord := XWord and $FF;
    Dec(XWord);
    if XWord > 31 then
      XWord := 31;
    FotoF.Read(ICC.ProfileDescription[1], XWord);
    ICC.ProfileDescription[0] := AnsiChar(XWord);
  end;
  AddVarData('ProfileDescription', ICC.ProfileDescription);
end;

procedure FotoRec.GetIFDentry(var IFDentry: IFDentryRec);
begin
  FotoF.Read(IFDentry, SizeOf(IFDentry));
  if IsMM then
  begin
    with IFDentry do
    begin
      Tag := Swap(Tag);
      FieldType := Swap(FieldType);
      TypeCount := SwapL(TypeCount);
      ValueOffs := SwapL(ValueOffs);
    end;
  end;
end;

procedure FotoRec.ParseIfd(Offset: int64; ParseProc: TParseIFDProc);
var
  IFDcount: word;
  IFDentry: IFDentryRec;
begin
  FotoF.Seek(Offset, TSeekOrigin.soBeginning);
  FotoF.Read(IFDcount, 2);
  if IsMM then
    IFDcount := Swap(IFDcount);
  while IFDcount > 0 do
  begin
    GetIFDentry(IFDentry);
    ParseProc(IFDentry);
    Dec(IFDcount);
  end;
end;

// ==============================================================================
// Read CanonVrd, and see if there is an XMP block.
const
  CRWMagic          = 'HEAPCCDR';

  TrailerSize       = $40;
  CanonTrailerSize  = $18;
  CanonVrdMagic     = 'CANON OPTIONAL DATA';
  XMPTag            = $f600ffff;

procedure FotoRec.ReadCanonVrd;
var
  EndCanonVrd: int64;
  CanonVrd: array[0..19] of ansichar;
  CanonVrdLen: integer;
  TagData, TagLen: DWORD;
begin
  FotoF.Seek(-TrailerSize, TSeekOrigin.soEnd);
  EndCanonVrd := FotoF.Position;
  FotoF.Read(CanonVrd, SizeOf(CanonVrd));

  // Have CANON OPTIONAL DATA?
  if (CanonVrd <> CanonVrdMagic) then
    exit;

  // Length CanonVrd
  FotoF.Read(CanonVrdLen, SizeOf(CanonVrdLen));
  CanonVrdLen := SwapL(CanonVrdLen);

  // Seek to begin of block
  FotoF.Seek( -CanonVrdLen -CanonTrailerSize, TSeekOrigin.soCurrent);

  // Loop until we find an XMP tag
  // Note:
  // In my testfiles I have only VRD blocks consisting of one XMP block.
  // Dont know if the loop works.
  FotoF.Read(TagData, 4);
  while (TagData <> XMPTag) do  // XMPTag should also be swapped. $ffff00f6 and not $f600ffff
  begin
    FotoF.Read(TagLen, 4);
    TagLen := SwapL(Taglen);
    if ((FotoF.Position + TagLen) >= EndCanonVrd) then // End of CanonVrd?
      exit;

    FotoF.Read(TagData, 4);     // Next tag
  end;

  // We have an XMP block
  FotoF.Read(TagLen, 4);
  AddXmpBlock(FotoF.Position, SwapL(Taglen));
end;

// CRW strings are only ANSI?
function FotoRec.GetCRWString(ALength: word): string;
var
  P: array of AnsiChar;
begin
  SetLength(P, ALength +1);
  FotoF.Read(P[0], ALength);
  result := PAnsiChar(P);
end;

function FotoRec.CanonEv(AEV: smallint): double;
var
  Frac: WORD;
  EV: smallint;
  Neg: double;
begin
  EV := AEV;
  if (EV < 0) then
    Neg := -1
  else
    Neg := 1;
  EV := Abs(EV);

  Frac := EV and $1f;
  Dec(EV, Frac);
  if (Frac = $0c) then
    result := Neg * (EV + $20 / 3) / $20
  else if (Frac = $14) then
    result := Neg * (EV + $40 / 3) / $20
  else
    result := Neg * (EV + Frac) / $20;
end;

procedure FotoRec.ReadCiff(AOffset, ALength: int64; Depth: integer);
var
  TBoff: int64;
  Save: int64;
  NRecs: SmallInt;
  SData: SmallInt;
  TagType, TempType: WORD;
  TagSize: DWORD;
  TagOffset: DWORD;
  DWData: DWORD;
  WData: WORD;
  AReal: double;
  AShutter: double;
  MinFocal, MaxFocal: double;
  FocalUnits: SmallInt;
  MaxAperture: double;
  LensInfo: string;

begin
  FotoF.Seek(AOffset + ALength -4, TSeekOrigin.soBeginning);
  FotoF.Read(DWData, 4);
  TBoff := DWData + AOffset;
  FotoF.Seek(TBoff, TSeekOrigin.soBeginning);
  FotoF.Read(NRecs, 2);
  if ((NRecs or Depth) > 127) then
    exit;

  while (NRecs > 0) do
  begin
    Dec(NRecs);
    FotoF.Read(TagType, 2);
    FotoF.Read(TagSize, 4);
    Save := FotoF.Position + 4;
    FotoF.Read(TagOffset, 4);

    FotoF.Seek(AOffset + TagOffset, TSeekOrigin.soBeginning);

    GroupName := 'IFD0';
    case (TagType) of
      $0805:
        IFD0.CopyRight := AddVarData('CopyRight', GetCRWString(TagSize));
      $080a:
        begin
          IFD0.Make := AddVarData('Make', GetCRWString(TagSize));
          FotoF.Seek(Int64(Length(IFD0.Make)) +1 -TagSize, TSeekOrigin.soCurrent);
          IFD0.Model := AddVarData('Model', GetCRWString(TagSize));
        end;
      $080b:
        begin
          IFD0.Software := AddVarData('Software', GetCRWString(TagSize));
        end;
      $0810:
        IFD0.Artist := AddVarData('Artist', GetCRWString(TagSize));
      $1810:
        begin
          FotoF.Read(DWData, SizeOf(DWData)); // ImageWidth
          FotoF.Read(DWData, SizeOf(DWData)); // ImageHeight
          FotoF.Read(DWData, SizeOf(DWData)); // PixelAspectRatio
          FotoF.Read(DWData, SizeOf(DWData)); // Rotation
          case (DWData) of
            90:
              begin
                IFD0.OrientationValue := AddVarData('OrientationValue', 6);
                IFD0.Orientation := AddVarData('Orientation', StrVer);
              end;
            180:
              begin
                IFD0.OrientationValue := AddVarData('OrientationValue', 3);
                IFD0.Orientation := AddVarData('Orientation', StrVer);
              end;
            270:
              begin
                IFD0.OrientationValue := AddVarData('OrientationValue', 5);
                IFD0.Orientation := AddVarData('Orientation', StrVer);
              end;
            else
              begin
                IFD0.OrientationValue := AddVarData('OrientationValue', 0);
                IFD0.Orientation := AddVarData('Orientation', StrHor);
              end;
          end;
        end;
    end;

    GroupName := 'ExifIfd';
    case (TagType) of
      $102a:
        begin
          FotoF.Read(WData, SizeOf(WData)); // Len
          FotoF.Read(WData, SizeOf(WData)); // AutoIso

          FotoF.Read(WData, SizeOf(WData)); // BaseIso
          AReal := Power(2, WData/32.0 - 4) * 50;
          ExifIFD.ISO := AddVarData('ISO', IntToStr(Round(AReal)));

          FotoF.Read(WData, SizeOf(WData)); // MeasuredEv
          FotoF.Read(WData, SizeOf(WData)); // TargetAperture
          FotoF.Read(SData, SizeOf(SData)); // TargetExposureTime

          FotoF.Read(SData, SizeOf(SData)); // ExposureCompensation
          ExifIFD.ExposureCompensation := AddVarData('ExposureCompensation', FormatExifDecimal(CanonEv(SData), 1));

          FotoF.Read(SData, SizeOf(SData)); // WhiteBalance
          FotoF.Read(SData, SizeOf(SData)); // SlowShutter
          FotoF.Read(SData, SizeOf(SData)); // SequenceNumber
          FotoF.Read(SData, SizeOf(SData)); // OpticalZoomCode
          FotoF.Read(SData, SizeOf(SData)); // Unused
          FotoF.Read(SData, SizeOf(SData)); // CameraTemperature
          FotoF.Read(SData, SizeOf(SData)); // FlashGuideNumber
          FotoF.Read(SData, SizeOf(SData)); // AFPointsInFocus
          FotoF.Read(SData, SizeOf(SData)); // FlashExposureComp
          FotoF.Read(SData, SizeOf(SData)); // AutoExposureBracketing
          FotoF.Read(SData, SizeOf(SData)); // AEBBracketValue
          FotoF.Read(SData, SizeOf(SData)); // ControlMode
          FotoF.Read(WData, SizeOf(WData)); // FocusDistanceUpper
          FotoF.Read(WData, SizeOf(WData)); // FocusDistanceLower

          FotoF.Read(SData, SizeOf(SData)); // FNumber
          ExifIFD.FNumber := AddVarData('FNumber', FormatExifDecimal(Exp(CanonEv(SData) * LN(2) / 2), 1));

          FotoF.Read(SData, SizeOf(SData)); // ExposureTime
          AShutter := Exp(-CanonEv(SData) * LN(2));
          if (AShutter > 0) and
             (AShutter < 0.25001) then
          begin
            AShutter := Trunc(0.5 + (1 / AShutter));
            ExifIFD.ExposureTime := AddVarData('ExposureTime', '1/' + FormatExifDecimal(AShutter, 0));
          end
          else
            ExifIFD.ExposureTime := AddVarData('ExposureTime', FormatExifDecimal(AShutter, 0));
        end;
      $102d:
        begin
          FotoF.Read(SData, SizeOf(SData)); // Len
          FotoF.Read(SData, SizeOf(SData)); // MacroMode
          FotoF.Read(SData, SizeOf(SData)); // SelfTimer
          FotoF.Read(SData, SizeOf(SData)); // Quality

          FotoF.Read(WData, SizeOf(WData)); // CanonFlashMode
          ExifIFD.FlashValue := AddVarData('FlashValue', WData);
          if (WData = 0) then
            ExifIFD.Flash := AddVarData('Flash', StrNo)
          else if (WData <= 16) then // Note: Doc states that -1 is undef. Unsigned => Greater than 16!
            ExifIFD.Flash := AddVarData('Flash', StrYes);

          FotoF.Read(SData, SizeOf(SData)); // ContinuousDrive
          FotoF.Read(SData, SizeOf(SData)); // Unused
          FotoF.Read(SData, SizeOf(SData)); // FocusMode
          FotoF.Read(SData, SizeOf(SData)); // Unused
          FotoF.Read(SData, SizeOf(SData)); // RecordMode
          FotoF.Read(SData, SizeOf(SData)); // CanonImageSize
          FotoF.Read(SData, SizeOf(SData)); // EasyMode
          FotoF.Read(SData, SizeOf(SData)); // DigitalZoom
          FotoF.Read(SData, SizeOf(SData)); // Contrast
          FotoF.Read(SData, SizeOf(SData)); // Saturation
          FotoF.Read(SData, SizeOf(SData)); // Sharpness
          FotoF.Read(SData, SizeOf(SData)); // CameraISO
          FotoF.Read(SData, SizeOf(SData)); // MeteringMode
          FotoF.Read(SData, SizeOf(SData)); // FocusRange
          FotoF.Read(SData, SizeOf(SData)); // AFPoint

          FotoF.Read(SData, SizeOf(SData)); // CanonExposureMode
          case (SData) of
            0: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'Easy');
            1: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', ' Program AE');
            2: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'Shutter speed priority AE');
            3: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'Aperture-priority AE');
            4: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'Manual');
            5: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'Depth-of-field AE');
            6: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'M-Dep');
            7: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'Bulb');
            8: ExifIFD.ExposureProgram := AddVarData('ExposureProgram', 'Flexible-priority AE');
          end;
          FotoF.Read(WData, SizeOf(WData)); // Unused
          FotoF.Read(WData, SizeOf(WData)); // LensType
          FotoF.Read(WData, SizeOf(WData)); // MaxFocalLength
          MaxFocal := WData;
          FotoF.Read(WData, SizeOf(WData)); // MinFocalLength
          MinFocal := WData;
          FotoF.Read(SData, SizeOf(SData)); // FocalUnits
          FocalUnits := SData;

          FotoF.Read(SData, SizeOf(SData)); // MaxAperture
          MaxAperture := Exp(CanonEv(SData) * LN(2) / 2);

          if (MaxFocal = MinFocal) then
            LensInfo := Format('%smm F%s', [FormatExifDecimal(MaxFocal * FocalUnits, 0),
                                            FormatExifDecimal(MaxAperture, 1)])
          else
            LensInfo := Format('%s-%smm F%s', [FormatExifDecimal(MinFocal * FocalUnits, 0),
                                               FormatExifDecimal(MaxFocal * FocalUnits, 0),
                                               FormatExifDecimal(MaxAperture, 1)]);

          ExifIFD.LensInfo := AddVarData('LensInfo', LensInfo);
          ExifIFD.LensModel := AddVarData('LensModel', LensInfo);
        end;
      $5029:
        begin
          ExifIFD.FocalLength := AddVarData('FocalLength', FormatExifDecimal(TagSize shr 16, 1));
        end;
      $180e:
        begin
          FotoF.Read(DWData, SizeOf(DWData));
          // All 3 the same
          ExifIFD.DateTimeOriginal := AddVarData('DateTimeoriginal',
                                      FormatDateTime('yyyy:mm:dd hh:nn:ss', UnixToDateTime(DWData, true)));
          ExifIFD.DateTimeDigitized := AddVarData('DateTimeDigitized', ExifIFD.DateTimeOriginal);
          ExifIFD.CreateDate := AddVarData('CreateDate', ExifIFD.DateTimeOriginal);
        end;
    end;

    TempType := (TagType shr 8) + 8;
    if ((TempType or 8) = $38) then // Subdir
      ReadCiff(FotoF.Position, TagSize, Depth +1);

    FotoF.Seek(Save, TSeekOrigin.soBeginning);
  end;
end;

procedure FotoRec.ReadTIFF;
var
  I: integer;
  CRWHeader: record
    LenHI: word;  // High order of the length. Low order has already been read.
    Magic: array[0..7] of ansichar;
  end;
begin
  TIFFoffset := FotoF.Position - SizeOf(WordData);

  IsMM := (WordData = $4D4D);
  FotoF.Read(WordData, 2);
  if IsMM then
    WordData := Swap(WordData);

  case (WordData) of
    $001A:  // $001A=CRW (Old Canon format)
      begin
        FotoF.Read(CRWHeader, SizeOf(CRWHeader));
        if (CRWHeader.Magic = CRWMagic) then
        begin
          Include(Supported, supCRW);
          ReadCiff(WordData, FileSize - WordData, 0);
          ReadCanonVrd;
        end;
      end;
    $002A,  // $002A=TIFF
    $0055,  // $0055=PanasonicRW2
    $4F52:  // $4F52=OlympusORF
      begin
        // We have a TIFF IFD
        Include(Supported, TSupportedType.supTIFF);

        FotoF.Read(DWordData, 4);
        if IsMM then
          DWordData := SwapL(DWordData);

        ParseIfd(TIFFoffset + DWordData, ParseIFD0);

        if ExifIFDoffset > 0 then
          ParseIFD(TIFFoffset + ExifIFDoffset, ParseExifIFD);

        if InteropOffset > 0 then
          ParseIFD(TIFFoffset + InteropOffset, ParseInterop);

        if (TGetOption.gmGPS in GetOptions) and
           (GPSoffset > 0) then
          ParseIFD(TIFFoffset + GPSoffset, ParseGPS);

        if (TGetOption.gmIPTC in GetOptions) and
           (IPTCoffset > 0) then
        begin
          FotoF.Seek(TIFFoffset + IPTCoffset, TSeekOrigin.soBeginning);
          while IPTCsize > 1 do
          begin // one padded byte possible!
            FotoF.Read(WordData, 2);
            Dec(IPTCsize, 2); // Skip $1C02
            if WordData <> $021C then
              break;
            ParseIPTC;
          end;
          with IPTC do
          begin
            I := length(Keywords);
            if I > 1 then
              SetLength(Keywords, I - 1); // delete last separator
            if length(Keywords) = 127 then
              Keywords[127] := '…';
            I := length(SuppCategories);
            if I > 1 then
              SetLength(SuppCategories, I - 1);
            if length(SuppCategories) = 63 then
              SuppCategories[63] := '…';
          end;
        end;

        if (TGetOption.gmICC in GetOptions) and
           (ICCoffset > 0) then
        begin
          FotoF.Seek(TIFFoffset + ICCoffset +2, TSeekOrigin.soBeginning); // Size is only word
          FotoF.Read(ICCSize, 2);
          ICCoffset := FotoF.Position;
          ParseICCprofile;
        end;
      end;
  end;
end;

// ==============================================================================
procedure FotoRec.ReadJPEG;
var
  APPSize: WORD;
  XXmpGUID: array[0..31] of AnsiChar;
  XXmpFullLength: DWORD;
  XXmpChunkOffset: DWORD;
  APPmarkNext: int64;
  SaveAppPos: int64;
  APPmark, APPType: Byte;
  Tx: string[15];
  XMPType: array[0..2] of AnsiChar; // xap, or xmp
  I: integer;

begin
  while (true) do // Loop thru all markers.
  begin
    FotoF.Read(APPmark, 1);
    if (APPmark <> $ff) then
      break;

    FotoF.Read(APPType, 1);
    if not (IsValidMarker(APPType)) then
      break;

    // We at least have something
    Include(Supported, TSupportedType.supJPEG);

    SaveAppPos := FotoF.Position;
    FotoF.Read(APPSize, 2);
    APPSize := Swap(APPSize);
    APPmarkNext := FotoF.Position + APPSize - 2;
    if (APPmarkNext >= FileSize) then // Past file?
      break;

    // APP1 = EXIF or XMP
    if APPType = mkAPP1 then
    begin
      FotoF.Read(Tx[1], 6);
      Tx[0] := #4;
      if Tx = 'Exif' then
      begin
        FotoF.Read(WordData, 2);
        if (WordData = $4949) or   // 'MM'
           (WordData = $4D4D) then // 'II'
          ReadTIFF;
      end
      else if Tx = 'http' then
      begin
//Read XMP block. Can be extended
        FotoF.Seek(14, TSeekOrigin.soCurrent); // Skip to xap or xmp
        FillChar(XMPType, SizeOf(XMPType), chr(0));
        FotoF.Read(XMPType[0], 3);
        AdvanceNulls(1);
        if (XMPType = 'xap') then             //http://ns.adobe.com/xap/1.0/ #0
          AddXmpBlock(FotoF.Position, APPSize - (FotoF.Position - SaveAppPos))
        else if (XMPType = 'xmp') then        //http://ns.adobe.com/xmp/extension/ #0 GUID FullLength ChunkOffset
        begin                                 //1234567890123456789012345678901234 +1  +32    +4            +4    = 75
// Xxmp Variables are 'future-use'
          FotoF.Read(XXmpGUID, SizeOf(XXmpGUID));
          FotoF.Read(XXmpFullLength, SizeOf(XXmpFullLength));
          FotoF.Read(XXmpChunkOffset, SizeOf(XXmpChunkOffset));
          AddXmpBlock(FotoF.Position, APPSize - (FotoF.Position - SaveAppPos));
        end;
      end;
    end;

    // APP1 = ICC colour profile
    if (TGetOption.gmICC in GetOptions) and
       (APPType = mkAPP2) then
    begin
      FotoF.Read(Tx[1], 14);
      Tx[0] := #11;
      if Tx = 'ICC_PROFILE' then
      begin
        ICCoffset := FotoF.Position +4;
        ICCSize := APPSize;
        ParseICCprofile;
      end;
    end;

    // APP13 = IPTC or Adobe IRB
    if (TGetOption.gmIPTC in GetOptions) and
       (APPType = mkAPP13) then
    begin
      FotoF.Read(Tx[1], 14);
      Tx[0] := #13;
      if Tx = 'Photoshop 3.0' then
      begin
        FotoF.Read(Tx[1], 4);
        Tx[0] := #4; // Tx='8BIM'
        FotoF.Read(WordData, 2);
        if WordData = $0404 then
        begin // $0404=IPTCData Photoshop tag
          FotoF.Read(DWordData, 4); // Ldata=0=dummy
          FotoF.Read(WordData, 2);
          WordData := Swap(WordData);
          IPTCsize := WordData;
          while IPTCsize > 1 do
          begin // one padded byte possible!
            FotoF.Read(WordData, 2);
            Dec(IPTCsize, 2); // Skip $1C02
            ParseIPTC;
          end;
          with IPTC do
          begin
            I := length(Keywords);
            if I > 1 then
              SetLength(Keywords, I - 1); // delete last separator
            if length(Keywords) = 127 then
              Keywords[127] := '…';
            I := length(SuppCategories);
            if I > 1 then
              SetLength(SuppCategories, I - 1);
            if length(SuppCategories) = 63 then
              SuppCategories[63] := '…';
          end;
        end;
      end;

    end;
    FotoF.Seek(APPmarkNext, TSeekOrigin.soBeginning);
  end;
end;

// ==============================================================================
const
  XMPMINSIZE          = 25;
  XMPMETA             = 'x:xmpmeta';
  RDF                 = 'rdf:RDF';

function GetRDF(const Xml: TXmlVerySimple): TXmlNode;
begin
  result := Xml.ChildNodes.Find(XMPMETA);
  if (result <> nil) then
    result := result.ChildNodes.Find(RDF);
end;

procedure FotoRec.ParseXMPBlock(TmpStream: TMemoryStream);
var
  Xml: TXmlVerySimple;
  RDF, RDFDesc: TXmlNode;
  RDFDescNodes: TXmlNodeList;

(*
Possible encodings in XMP. Sadly the UTF32 encodings are not supported.
utf8    ef bb bf
utf16be fe ff
utf16le ff fe
utf32be 00 00 fe ff
utf32le ff fe 00 00
*)

  function DetectEncoding: string;
  const
    XMPEncoding_utf8    = 'utf-8';
    XMPEncoding_utf16   = 'utf-16';
    XMPEncoding_utf16be = 'utf-16be';
    XPacketMagic        = '<?xpacket begin=';

    UTF8_BOM:     array[0..3] of byte = ($ef, $bb, $bf, $00);
    UTF16BE_BOM:  array[0..3] of byte = ($fe, $ff, $00, $00);
    UTF16LE_BOM:  array[0..3] of byte = ($ff, $fe, $00, $00);
  var
    BOM: array[0..3] of byte;
    Quote: byte;
    AByte: PByte;
    Index: integer;

    // Scan for XPacket
    function ReadXpacket: boolean;
    var
      XPacket: array[0..15] of AnsiChar;
    begin
      AByte := PByte(TmpStream.Memory);
      Index := 0;
      while (Index <= High(XPacket)) do
      begin
        while (Abyte^ = 0) do
          Inc(AByte);
        XPacket[Index] := AnsiChar(Abyte^);
        Inc(Index);
        Inc(AByte);
      end;

      result := (XPacket = XPacketMagic);
    end;

    // Scan for ' or "
    function ScanQuote: boolean;
    begin
      while (Abyte^ = 0) do
        Inc(AByte);
      Quote := AByte^;
      result := (Quote = $22) or
                (Quote = $27);
    end;

    // Get the BOM
    procedure ReadBOM;
    begin
      // Read max 4 Bytes, until quote.
      FillChar(BOM, SizeOf(BOM), 0);
      Index := 0;
      Inc(AByte);
      while (Index < High(BOM)) and
            (AByte^ <> Quote) do
      begin
        BOM[Index] := AByte^;
        Inc(Index);
        Inc(AByte);
      end;
    end;

  begin
    result := XMPEncoding_utf8; // UTF8 is default!

    if not ReadXpacket then
      exit;

    if not ScanQuote then
      exit;

    ReadBom;

    if CompareMem(@BOM, @UTF16BE_BOM, SizeOf(BOM)) then
      exit(XMPEncoding_utf16be);
    if CompareMem(@BOM, @UTF16LE_BOM, SizeOf(BOM)) then
      exit(XMPEncoding_utf16);
  end;

  procedure Add2Xmp(const AKey, AValue: string; const isList: boolean);
  var
    UnEscaped: string;
    MetaInfo: variant;
  begin
    GroupName := 'Xmp-';

    // ExifTool escapes (needlessly) ' and " in XML.
    // VerySimpleXML does not UnEscape '&#39;' .
    UnEscaped := StringReplace(AValue, '&#39;', '''', [rfReplaceAll]);

    // For XMP add every node found.
    MetaInfo := AddVarData(AKey, AValue, true);

    // Only Fill the record if needed
    if (StartsText('Iptc4xmpExt:LocationShownCountryCode', AKey)) then
      XMP.CountryCodeShown := MetaInfo
    else if (StartsText('Iptc4xmpExt:LocationShownCountryName', AKey)) then
      XMP.CountryNameShown := MetaInfo
    else if (StartsText('Iptc4xmpExt:LocationShownProvinceState', AKey)) then
      XMP.ProvinceShown := MetaInfo
    else if (StartsText('Iptc4xmpExt:LocationShownCity', AKey)) then
      XMP.CityShown := MetaInfo
    else if (StartsText('Iptc4xmpExt:LocationShownSublocation', AKey)) then
      XMP.LocationShown := MetaInfo
    else if (StartsText('Iptc4xmpExt:PersonInImage', AKey)) then
      XMP.PersonInImage := MetaInfo

    else if (StartsText('dc:creator', AKey)) then
      XMP.Creator := MetaInfo
    else if (StartsText('dc:rights', AKey)) then
      XMP.Rights := MetaInfo
    else if (StartsText('dc:date', AKey)) then
      XMP.Date := MetaInfo
    else if (StartsText('dc:type', AKey)) then
      XMP.PhotoType := MetaInfo
    else if (StartsText('dc:title', AKey)) then
      XMP.Title := MetaInfo
    else if (StartsText('dc:subject', AKey)) then
      XMP.Keywords := MetaInfo

    else if (StartsText('Iptc4xmpExt:Event', AKey)) then
      XMP.Event := MetaInfo

    else if (StartsText('xmp:Rating', AKey)) or
            (StartsText('xap:Rating', AKey)) then
      XMP.Rating := MetaInfo
  end;

  function GetNodeKey(ThisNode, SubNode: string; var ParmIsList: boolean): string;
  var
    P: integer;
  begin
    result := ThisNode;

    if (Trim(result) = '') then
      result := SubNode
    else if (ParmIsList) then
    begin
      P := Pos(':', SubNode);
      if (P > 0) then
        result := result + Copy(SubNode, P +1);
    end;

    ParmIsList := ParmIsList or
                  SameText('rdf:li', SubNode);
  end;

  procedure LevelDeeper(const ANode: TXmlNode; AParent: string = ''; ParentIsList: boolean = false);
  var
    ANodeList: TXmlNodeList;
    ASubNode: TXmlNode;
    Attribute: TXmlAttribute;
    SelNode: string;
    ThisIsList: boolean;
  begin
    SelNode := Trim(AParent);

    if (ANode.NodeValue <> '') then
      Add2Xmp(SelNode, ANode.NodeValue, ThisIsList);

    // Look in Attributes of Node
    for Attribute in ANode.AttributeList do
    begin
      // Skip xml:lang etc.
      if StartsText('xml:', Attribute.Name) then
        continue;
      if StartsText('xmlns:', Attribute.Name) then
        continue;
      if StartsText('rdf:About', Attribute.Name) then
        continue;

      ThisIsList := false; // Attribute cant be a list
      Add2Xmp(GetNodeKey(SelNode, Attribute.Name, ThisIsList), Attribute.Value, ThisIsList);
    end;

    // Look in Childnodes
    ANodeList := ANode.ChildNodes;
    for ASubNode in ANodeList do
    begin
      ThisIsList := ParentIsList;
      LevelDeeper(ASubNode, GetNodeKey(SelNode, ASubNode.NodeName, ThisIsList), ThisIsList);
    end;
  end;

begin
  Xml:= TXmlVerySimple.Create;
  try
    TmpStream.Position := 0;
    Xml.Encoding := DetectEncoding;
    try
      Xml.LoadFromStream(TmpStream);
    except on E:Exception do
      begin
{$IFDEF DEBUG_XMP}
        allocconsole;
        writeln('File:', FileName, ' Error:', e.Message);
{$ENDIF}
        exit;
      end;
    end;

    RDF := GetRDF(Xml);
    if (RDF = nil) then
      exit;

    RDFDescNodes := RDF.ChildNodes;
    Xmp.HasData := Xmp.HasData or (RDFDescNodes.Count > 0);

    // Recurse thru all subnodes, and look in attributes and node names
    for RDFDesc in RDFDescNodes do
      LevelDeeper(RDFDesc);
  finally
    Xml.Free;
  end;
end;

procedure FotoRec.ReadXMP;
var
  Index: integer;
  Bytes: TBytes;
  TmpStream: TMemoryStream;
begin
  TmpStream := TMemoryStream.Create;
  try
    for Index := 0 to High(XMPoffset) do
    begin
      FotoF.Seek(XMPoffset[Index], TSeekOrigin.soBeginning);
      Setlength(Bytes, XMPsize[Index]);
      FotoF.Read(Bytes[0], XMPsize[Index]);
      TmpStream.WriteData(Bytes, XMPsize[Index]);
      if (Index = 0) and
         (TmpStream.Size > XMPMINSIZE)then // Process standard XMP
      begin
{$IFDEF DEBUG_XMP}
        TmpStream.SaveToFile(ChangeFileExt(Self.FileName, '_XML'));
{$ENDIF}
        ParseXMPBlock(TmpStream);
        TmpStream.Clear;
      end;
    end;

    if (TmpStream.Size > XMPMINSIZE) then  // Process Extended XMP
    begin
{$IFDEF DEBUG_XMP}
      TmpStream.SaveToFile(ChangeFileExt(Self.FileName, '_XML_EXT'));
{$ENDIF}
      ParseXMPBlock(TmpStream);
    end;

  finally
    TmpStream.Free;
  end;
end;

// https://github.com/lclevy/canon_cr3/blob/master/readme.md
// If it's a CR3, skip until we see a CMT1. Thats the IFD0
function FotoRec.SkipCr3Header: word;
var
  SavePos, EndPos: Int64;
  Cr3Magic:array[0..6] of AnsiChar;
  TagLen: DWORD;
  TagName:array[0..3] of AnsiChar;

const
  MoovSize = 24;
  TiffHeader = 8;
begin
  result := WordData;
  SavePos := FotoF.Position;
  FotoF.Seek(4, TSeekOrigin.soBeginning);
  FotoF.Read(Cr3Magic, SizeOf(Cr3Magic));

  if (Cr3Magic = 'ftypcrx') then
  begin
    FotoF.Seek(0, TSeekOrigin.soBeginning);
    FotoF.Read(TagLen, SizeOf(TagLen));
    TagLen := SwapL(TagLen) - SizeOf(TagLen) - SizeOf(TagName);
    FotoF.Read(TagName, SizeOf(TagName));
    EndPos := FileSize;
    while (FotoF.Position + TagLen <  EndPos) do
    begin
      if (TagName = 'moov') then
      begin
        EndPos := Fotof.Position + TagLen;
        Fotof.Seek(MoovSize, TSeekOrigin.soCurrent);
      end
      else
        FotoF.Seek(TagLen, TSeekOrigin.soCurrent);

      FotoF.Read(TagLen, SizeOf(TagLen));
      TagLen := SwapL(TagLen) - SizeOf(TagLen) - SizeOf(TagName);
      FotoF.Read(TagName, SizeOf(TagName));

      if (TagName = 'CMT1') then
      begin
        FotoF.Read(result, SizeOf(result)); // Return first word.
        result := Swap(result);
        break;
      end;
    end;
  end
  else
    FotoF.Seek(SavePos, TSeekOrigin.soBeginning); // No CR3
end;

// Loop thru the tag names
// CMT1, CMT2, CMT4 are TIFF IFD's
// uuid with magic #$be + #$7a + #$cf + #$cb is XMP
procedure FotoRec.ReadCr3;
var
  EndPos: Int64;
  XmpMagic:array[0..3] of AnsiChar;
  TagLen: DWORD;
  TagName:array[0..3] of AnsiChar;

const
  TiffHeaderLen = 8;
  UuidLen = 16;
  CMT1Len = 10;
begin
  if (SkipCr3Header <> $4949) then // No CR3
    exit;
  IsMM := false;

  Include(Supported, TSupportedType.supCR3);
  FotoF.Seek(-CMT1Len, TSeekOrigin.soCurrent); //position before CMT1 to get the len

  FotoF.Read(TagLen, SizeOf(TagLen));
  TagLen := SwapL(TagLen) - SizeOf(TagLen) - SizeOf(TagName);
  FotoF.Read(TagName, SizeOf(TagName));
  EndPos := FileSize;
  while (FotoF.Position + TagLen < EndPos) do
  begin
    TIFFoffset := FotoF.Position;
    FotoF.Read(WordData, SizeOf(WordData));
    if (TagName = 'CMT1') then
      ParseIfd(TIFFoffset + TiffHeaderLen, ParseIFD0);
    if (TagName = 'CMT2') then
      ParseIfd(TIFFoffset + TiffHeaderLen, ParseExifIFD);
    if (TGetOption.gmGPS in GetOptions) and
       (TagName = 'CMT4') then
      ParseIfd(TIFFoffset + TiffHeaderLen, ParseGPS);
    if (TGetOption.gmXMP in GetOptions)and
       (TagName = 'uuid') then
    begin
      FotoF.Seek(-SizeOf(WordData), TSeekOrigin.soCurrent);
      FotoF.Read(XmpMagic, SizeOf(XmpMagic));
      if XmpMagic = #$be + #$7a + #$cf + #$cb then
        AddXmpBlock(UuidLen + TIFFoffset, TagLen - UuidLen);
    end;

    FotoF.Seek(TIFFoffset + TagLen, TSeekOrigin.soBeginning);
    FotoF.Read(TagLen, SizeOf(TagLen));
    FotoF.Read(TagName, SizeOf(TagName));

    TagLen := SwapL(TagLen);
    if (TagLen > (SizeOf(TagLen) + SizeOf(TagName))) then
      TagLen := TagLen - SizeOf(TagLen) - SizeOf(TagName)
    else
      TagLen := EndPos;
  end;
end;

(*
Fuji Raw File (RAF)

RAF File Header

0x00    16    'FUJIFILMCCD-RAW ' Magic word
0x10    4     '020x' Format version
              0200: Fuji S2
              0201: Fuji S3
0x14    8     Camera number ID
0x1C    32    Camera body name

RAF File subHeader (01.00)

0x00    4     '0100' Version
0x04    5*4   Unknown
0x18    4     Jpeg Image data offset <== This is the pointer we need
0x1C    4     Jpeg Image data byte size
0x20    4     First RAW image header offset
0x24    4     First RAW image header byte size;
0x28    4     First RAW image data offset
0x2c    4     First RAW image data byte size
0x30    3*4   Unknown
0x3c    4     Second RAW image header offset
0x40    4     Second RAW image header byte size;
0x44    4     Second RAW image data offset
0x48    4     Second RAW image data byte size
0x4c    3*4   Unknown
*)

function FotoRec.SkipFujiHeader: word;
var
  SavePos: Int64;
  FujiMagic:array[0..7] of AnsiChar;
  JpegOffset: longword;
const
  JpegOffsetOffset = 16 + 4 + 8 + 32 + 4 + (5*4);
begin
  result := WordData;
  SavePos := FotoF.Position;
  FotoF.Seek(0, TSeekOrigin.soBeginning);
  FotoF.Read(FujiMagic, SizeOf(FujiMagic));

  if (FujiMagic = 'FUJIFILM') then
  begin
    FotoF.Seek(JpegOffsetOffset, TSeekOrigin.soBeginning);
    FotoF.Read(JpegOffset, SizeOf(JpegOffset));      // Offset to JpegImage
    JpegOffset := SwapL(JpegOffset);
    FotoF.Seek(JpegOffset, TSeekOrigin.soBeginning); // Set File pointer
    FotoF.Read(result, SizeOf(result));              // Return first word.
    result := Swap(result);
  end
  else
    FotoF.Seek(SavePos, TSeekOrigin.soBeginning);    // Restore file pointer, no FujiFilm
end;

// Fuji Raf has its own header. Skip that and we can use ReadJpeg
procedure FotoRec.ReadFuji;
begin
  if (SkipFujiHeader = $FFD8) then
    ReadJpeg;
end;

// ======================================== MAIN ==============================================
function GetMetadata(AName: string; AGetOptions: TGetOptions; VarData: TVarData = nil; FieldNames: TStrings = nil): FotoRec;
begin
  result.Clear;  // Clear all variables
  result.FileName := AName;
  result.SetVarData(VarData, FieldNames);

  if (result.FileName = '') then
    exit;

  with result do
  begin

    // Get parameters
    GetOptions := AGetOptions;
    FotoKeySep := ET.Options.GetSeparator;

    try
      //  There is no TBufferedHandleStream. So try to create, and handle the exception
      FotoF := TBufferedFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      try
        FileSize := FotoF.Size;
        if (FileSize > 31) then
        begin // size must be at least 32 bytes
          FotoF.Read(WordData, 2);
          WordData := Swap(WordData);
          case WordData of
            $0000:
              ReadCr3;  // CR3
            $4655:
              ReadFuji; // RAF
            $FFD8:
              ReadJPEG; // JPG
            $4949:
              ReadTIFF; // 'II'=TIF,DNG,CR2,CRW,RW2,ORF
            $4D4D:
              ReadTIFF; // 'MM'=NEF,PEF
          end;
          if JPGfromRAWoffset > 0 then
          begin // in case of RW2
            FotoF.Seek(JPGfromRAWoffset, TSeekOrigin.soBeginning);
            FotoF.Read(WordData, 2);
            WordData := Swap(WordData);
            if WordData = $FFD8 then
              ReadJPEG;
          end;
          if (TGetOption.gmXMP in result.GetOptions) and
              (Length(XMPoffset) > 0) and
              (Length(XMPsize) > 0) then
          begin
            ReadXMP;
            // Add a dummy GPSPosition if no GPS was found, but something is in XMP
            if (GPS.HasData = false) and
               (VarData.ContainsKey(LowerCase('Xmp-exif:GPSLatitude'))) then
            begin
              GroupName := 'Composite';
              GPS.GpsPosition := AddVarData('GpsPosition', StrYes);
            end;
          end;

          // Update Gps record.
          if (TGetOption.gmGPS in result.GetOptions) and
             (Gps.HasData) then
            result.CorrectGps;

        end;
      finally
        FotoF.Free;
      end;
    except
      result.ErrNotOpen := true;
    end;
  end;
end;

procedure ChartFindFiles(StartDir, FileMask: string; SubDir: boolean;
                         var ETFocal, ETFnum, ETIso: TNrSortedStringList);
var
  Foto: FotoRec;
  SR: TSearchRec;
  DirList: TStringList;
  IsFound, DoSub: boolean;
  Indx: integer;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    StartDir := IncludeTrailingPathDelimiter(StartDir);
    DoSub := SubDir;

    // Build a list of the files in directory StartDir -not the directories!
    IsFound := FindFirst(StartDir + FileMask, faAnyFile - faDirectory, SR) = 0;
    while IsFound do
    begin
      Foto := GetMetadata(StartDir + SR.Name, []);
      with Foto do
      begin
        if (ExifIFD.HasData) then
        begin

          // focal length:
          ETFocal.IncValue(ExifIFD.FocalLength);

          // aperture:
          ETFnum.IncValue(ExifIFD.FNumber);

          // ISO:
          ETIso.IncValue(ExifIFD.ISO);
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
      for Indx := 0 to DirList.Count - 1 do
        ChartFindFiles(DirList[Indx], FileMask, DoSub,
                       ETFocal, ETFnum, ETIso);
      DirList.Free;
    end;

  finally
    SetCursor(CrNormal);
  end;
end;

// ==================================================
initialization

begin
  // for StrToFloatDef -see function DecodeGPS
  GpsFormatSettings.ThousandSeparator := '.';
  GpsFormatSettings.DecimalSeparator := ',';

  Encoding := TEncoding.GetEncoding(CP_UTF8)
end;

finalization

begin
  Encoding.Free;
end;

end.
