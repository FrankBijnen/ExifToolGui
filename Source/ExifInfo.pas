unit ExifInfo;

// ****************************QUICK METADATA ACCESS*************************
// Not all formats supported. Check Value of 'Supported'

interface

uses System.Classes, System.SysUtils, Vcl.StdCtrls, ExifToolsGUI_StringList;

type

  IFDentryRec = packed record
    Tag: word;
    FieldType: word;
    TypeCount: longint;
    ValueOffs: longint;
  end;

  IPTCrec = packed record
    Supported: boolean;
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
    Supported: boolean;
    Make, Model: string;
    PreviewOffset, PreviewSize: longint;
    Orientation: word; // 1=Normal, 3=180, 6=90right, 8=90left, else=Mirror
    Xresolution, Yresolution: word;
    ResolutionUnit: string[5];
    Software: string;
    DateTimeModify: string[19];
    Artist: string;
    Copyright: string;
    procedure Clear;
  end;

  ExifIFDrec = packed record
    Supported: boolean;
    ExposureTime: string[7];
    FNumber: string[5];
    ExposureProgram: string;
    ISO: string[5];
    DateTimeOriginal, DateTimeDigitized: string[19];
    ExposureBias: string[7];
    Flash: word; // if (ExifIFD.Flash and 1)=1 then 'Flash=Yes'
    FocalLength: string[7];
    ColorSpace: string[13];
    FLin35mm: string[7];
    LensInfo: string;
    LensMake: string;
    LensModel: string;
    procedure Clear;
  end;

  InteropIFDrec = packed record
    Supported: boolean;
    InteropIndex: string[9];
    procedure Clear;
  end;

  GPSrec = packed record
    Supported: boolean;
    LatitudeRef: string[1]; // North/South
    Latitude: string[11];
    LongitudeRef: string[1]; // East/West
    Longitude: string[11];
    AltitudeRef: string[1]; // +/-
    Altitude: string[5];
    GeoLat, GeoLon: string[11]; // for OSM Map
    procedure Clear;
  end;

  MakernotesRec = packed record
    Supported: boolean;
    LensFocalRange: string[11]; // i.e."17-55"
    procedure Clear;
  end;

  XMPrec = packed record
    Supported: boolean;
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
    Supported: boolean;
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

  FotoRec = packed record
    IFD0: IFD0rec;
    ExifIFD: ExifIFDrec;
    InteropIFD: InteropIFDrec;
    GPS: GPSrec;
    IPTC: IPTCrec;
    XMP: XMPrec;
    ICC: ICCrec;
    
    Supported: boolean;
    FotoF: THandleStream;
    GetOptions: TGetOptions;
    FotoKeySep: string[3];
    IsMM: boolean;
    WordData: word;
    LongData: longint;
    XMPoffset, XMPsize, IPTCsize, IPTCoffset: int64;
    TIFFoffset, ExifIFDoffset, GPSoffset: int64;
    ICCoffset, InteropOffset, JPGfromRAWoffset: int64;
    ICCSize: word;

    procedure Clear;

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
    procedure ParseICCprofile;
    procedure GetIFDentry(var IFDentry: IFDentryRec);
    procedure ParseIfd(Offset: int64; ParseProc: TParseIFDProc);
    procedure ReadTIFF;
    procedure ReadJPEG;
    procedure ReadXMP;
    function SkipCr3Header: word;
    procedure ReadCr3;
    function SkipFujiHeader: word;
    procedure ReadFuji;

  end;

function GetMetadata(AName: string; AGetOptions: TGetOptions): FotoRec;
procedure ChartFindFiles(StartDir, FileMask: string; SubDir: boolean;
                         var ETFocal, ETFnum, ETIso: TNrSortedStringList);

implementation

uses
  System.StrUtils, Winapi.Windows, Vcl.Forms, Vcl.Dialogs,
  Main, ExifTool,
  Xml.VerySimple, // XML parsing for XMP
  SDJPegTypes;    // JPEG APP types

var
  Encoding: TEncoding;
  ExifFormatSettings: TFormatSettings; // for Formatfloat -see Initialization
  GpsFormatSettings: TFormatSettings; // for StrToFloatDef -see Initialization

{$IFDEF DEBUG}
  Filename:string;
{$ENDIF}

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
    Tx := 'err!';
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
    Tx := Tx + 'err!';
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
  Ty := Ty + ',' + Sec;

  R := StrToFloatDef(Ty, 0, GpsFormatSettings) / 60;
  Ty := FloatToStrF(Rd + R, ffFixed, 8, 6);
  L1 := Pos(',', Ty);
  if L1 > 0 then
    Ty[L1] := '.';
  if IsLat then
    GPS.GeoLat := Ty
  else
    GPS.GeoLon := Ty;

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
    Supported := true;
    case IPTCtagID of
      5:
        ObjectName := StripLen(Tx, 32);
      15:
        Category := StripLen(Tx, 3);
      20:
        SuppCategories := SuppCategories + Tx + FotoKeySep;
      25:
        Keywords := Keywords + Tx + FotoKeySep;
      80:
        By_line := StripLen(Tx, 32);
      85:
        By_lineTitle := StripLen(Tx, 32);
      90:
        City := StripLen(Tx, 31);
      92:
        Sub_location := StripLen(Tx, 31);
      95:
        Province_State := StripLen(Tx, 31);
      101:
        Country := StripLen(Tx, 31);
      105:
        Headline := StripLen(Tx, 64);
      116:
        CopyrightNotice := StripLen(Tx, 64);
      120:
        Caption_Abstract := StripLen(Tx, 128);
      122:
        Writer_Editor := StripLen(Tx, 32);
    end;
  end;
end;

// ------------------------------------------------------------------------------
procedure FotoRec.ParseIFD0(IFDentry: IFDentryRec);
var
  SavePos: int64;
begin
  SavePos := FotoF.Position;
  with IFD0 do
  begin
    Supported := true;
    case IFDentry.Tag of
      $002E:
        JPGfromRAWoffset := IFDentry.ValueOffs; // Panasonic RW2
      $010F:
        Make := DecodeASCII(IFDentry, 64);
      $0110:
        Model := DecodeASCII(IFDentry, 64);
      $0111:
        PreviewOffset := IFDentry.ValueOffs;
      $0112:
        Orientation := DecodeWord(IFDentry);
      $0117:
        PreviewSize := IFDentry.ValueOffs;
      $011A:
        Xresolution := DecodeRational(IFDentry);
      $011B:
        Yresolution := DecodeRational(IFDentry);
      $0128:
        case DecodeWord(IFDentry) of
          2:
            ResolutionUnit := 'dpi';
          3:
            ResolutionUnit := 'dpcm';
        else
          ResolutionUnit := '-'
        end;
      $0131:
        Software := DecodeASCII(IFDentry, 64);
      $0132:
        DateTimeModify := DecodeASCII(IFDentry);
      $013B:
        Artist := DecodeASCII(IFDentry, 64);
      $02BC:
        begin
          XMPsize := IFDentry.TypeCount;
          XMPoffset := IFDentry.ValueOffs;
        end;
      $8298:
        Copyright := DecodeASCII(IFDentry, 64);
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
  SavePos := FotoF.Position;
  with ExifIFD do
  begin
    Supported := true;
    case IFDentry.Tag of
      $829A:
        ExposureTime := ConvertRational(IFDentry, false);
      $829D:
        FNumber := FloatToStrF(GetRational(IFDentry), ffFixed, 7, 1, ExifFormatSettings);
      $8822:
        case DecodeWord(IFDentry) of
          0:
            ExposureProgram := 'Undef.';
          1:
            ExposureProgram := 'M mode';
          2:
            ExposureProgram := 'P mode';
          3:
            ExposureProgram := 'A mode';
          4:
            ExposureProgram := 'T mode';
        else
          ExposureProgram := 'Unknown';
        end;
      $8827:
        ISO := IntToStr(DecodeWord(IFDentry));
      $9003:
        DateTimeOriginal := DecodeASCII(IFDentry);
      $9004:
        DateTimeDigitized := DecodeASCII(IFDentry);
      $9204:
        ExposureBias := ConvertRational(IFDentry, true);
      $9209:
        Flash := DecodeWord(IFDentry) or $FF00; // $FFnn=tag exist indicator
      $920A:
        FocalLength := FloatToStrF(GetRational(IFDentry), ffFixed, 7, 1, ExifFormatSettings);
      $A001:
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
      $A005:
        InteropOffset := IFDentry.ValueOffs;
      $A405:
        FLin35mm := IntToStr(DecodeWord(IFDentry));
      $A432:
        LensInfo := DecodeExifLens(IFDentry);
      $A433:
        LensMake := DecodeASCII(IFDentry, 23);
      $A434:
        LensModel := DecodeASCII(IFDentry, 47);
    end;
  end;
  FotoF.Seek(SavePos, TSeekOrigin.soBeginning);
end;

// ------------------------------------------------------------------------------
procedure FotoRec.ParseInterop(IFDentry: IFDentryRec);
var
  SavePos: int64;
begin
  SavePos := FotoF.Position;
  with InteropIFD do
  begin
    Supported := true;
    case IFDentry.Tag of
      $0001:
        begin
          InteropIndex := DecodeASCII(IFDentry);
          if InteropIndex = 'R03' then
            InteropIndex := 'R03=Adobe'
          else if InteropIndex = 'R98' then
            InteropIndex := 'R98=sRGB';
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
  SavePos := FotoF.Position;
  with GPS do
  begin
    Supported := true;
    case IFDentry.Tag of
      $01:
        LatitudeRef := DecodeASCII(IFDentry);
      $02:
        Latitude := DecodeGPS(IFDentry, true);
      $03:
        LongitudeRef := DecodeASCII(IFDentry);
      $04:
        Longitude := DecodeGPS(IFDentry, false);
      $05:
        if IFDentry.ValueOffs = 0 then
          AltitudeRef := '+'
        else
          AltitudeRef := '-';
      $06:
        Altitude := IntToStr(DecodeRational(IFDentry)) + 'm';
    end;
  end;
  FotoF.Seek(SavePos, TSeekOrigin.soBeginning);
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
  FotoF.Seek(ICCoffset, TSeekOrigin.soBeginning);

  ICC.Supported := true;
  FotoF.Read(ICC.ProfileCMMType[1], 4);
  ICC.ProfileCMMType[0] := #4;
  FotoF.Read(Tx[1], 4); // skip ProfileVersion
  FotoF.Read(ICC.ProfileClass[1], 4);
  ICC.ProfileClass[0] := #4;
  FotoF.Read(ICC.ColorSpaceData[1], 4);
  ICC.ColorSpaceData[0] := #4;
  FotoF.Read(ICC.ProfileConnectionSpace[1], 4);
  ICC.ProfileConnectionSpace[0] := #4;
  FotoF.Read(Tx[1], 16); // skip ProfileDateTime & ProfileFileSignature
  FotoF.Read(ICC.PrimaryPlatform[1], 4);
  ICC.PrimaryPlatform[0] := #4;
  FotoF.Read(Tx[1], 4); // skip CMMFlags
  FotoF.Read(ICC.DeviceManufacturer[1], 4);
  ICC.DeviceManufacturer[0] := #4;
  FotoF.Read(Tx[1], 28); // skip DeviceModel... goto ProfileCreator
  FotoF.Read(ICC.ProfileCreator[1], 4);
  ICC.ProfileCreator[0] := #4;
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
procedure FotoRec.ReadTIFF;
var
  I: integer;
begin
  TIFFoffset := FotoF.Position - SizeOf(WordData);

  IsMM := (WordData = $4D4D);
  FotoF.Read(WordData, 2);
  if IsMM then
    WordData := Swap(WordData);
  if (WordData = $002A) or   // $002A=TIFF
     (WordData = $0055) or   // $0055=PanasonicRW2
     (WordData = $4F52) then // $4F52=OlympusORF
  begin
    FotoF.Read(LongData, 4);
    if IsMM then
      LongData := SwapL(LongData);

    ParseIfd(TIFFoffset + LongData, ParseIFD0);

    if ExifIFDoffset > 0 then
      ParseIFD(TIFFoffset + ExifIFDoffset, ParseExifIFD);

    if InteropOffset > 0 then
      ParseIFD(TIFFoffset + InteropOffset, ParseInterop);

    if (TGetOption.gmGPS in GetOptions) and
       (GPSoffset > 0) then
    begin
      ParseIFD(TIFFoffset + GPSoffset, ParseGPS);
      with GPS do
      begin
        if (LatitudeRef = 'S') and (GeoLat <> '') then
          GeoLat := '-' + GeoLat;
        if (LongitudeRef = 'W') and (GeoLon <> '') then
          GeoLon := '-' + GeoLon;
      end;
    end;

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

// ==============================================================================
procedure FotoRec.ReadJPEG;
var
  APPsize: word;
  APPmarkNext: int64;
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
    Supported := true;

    FotoF.Read(APPsize, 2);
    APPsize := Swap(APPsize);
    APPmarkNext := FotoF.Position + APPsize - 2;
    if (APPmarkNext >= FotoF.Size) then // Past file?
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
// Only XMP type 'xap' wanted. xmp has no usable info for us. (Google Pixel 7 Pro for example)
//http://ns.adobe.com/xap/1.0/#0
//http://ns.adobe.com/xmp/extension/
        FotoF.Seek(14, TSeekOrigin.soCurrent); // Skip to xap or xmp
        FillChar(XMPType, Sizeof(XMPType), chr(0));
        FotoF.Read(XMPType[0], 3);
        FotoF.Seek(6, TSeekOrigin.soCurrent);  // 14 + 3 + 6 = 23 as original code.
        if (XMPType = 'xap') then
        begin
          XMPoffset := FotoF.Position;         // Point to '<?xpacket...'
          XMPsize := APPsize - 31;
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
        ICCSize := APPsize;
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
          FotoF.Read(LongData, 4); // Ldata=0=dummy
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
  XMPEncoding = 'utf-8';
  XMPMETA     = 'x:xmpmeta';
  RDF         = 'rdf:RDF';

function GetRDF(const Xml: TXmlVerySimple): TXmlNode;
begin
  result := Xml.ChildNodes.Find(XMPMETA);
  if (result <> nil) then
    result := result.ChildNodes.Find(RDF);
end;

procedure FotoRec.ReadXMP;
var Bytes: TBytes;
    Xml: TXmlVerySimple;
    RDF, RDFDesc: TXmlNode;
    RDFDescNodes: TXmlNodeList;
    TmpStream: TMemoryStream;

  procedure AddBag(var BagData: string; const ANode: string);
  begin
    if (BagData <> '') then
      BagData := BagData + FotoKeySep;
    BagData := BagData + ANode;
  end;

  procedure Add2Xmp(const AKey, AValue: string);
  var
    UnEscaped: string;
  begin
    // ExifTool escapes (needless) ' and " in XML.
    // VerySimpleXML does not UnEscape '&#39;' .
    UnEscaped := StringReplace(AValue, '&#39;', '''', [rfReplaceAll]);

    if (EndsText('Iptc4xmpExt:CountryCode', AKey)) then
      XMP.CountryCodeShown := UnEscaped
    else if (EndsText('Iptc4xmpExt:CountryName', AKey)) then
      XMP.CountryNameShown := UnEscaped
    else if (EndsText('Iptc4xmpExt:ProvinceState', AKey)) then
      XMP.ProvinceShown := UnEscaped
    else if (EndsText('Iptc4xmpExt:City', AKey)) then
      XMP.CityShown := UnEscaped
    else if (EndsText('Iptc4xmpExt:Sublocation', AKey)) then
      XMP.LocationShown := UnEscaped
    else if (StartsText('Iptc4xmpExt:PersonInImage.rdf:Bag', AKey)) then
      AddBag(XMP.PersonInImage, UnEscaped)

    else if (StartsText('dc:creator.rdf:Seq', AKey)) then
      AddBag(XMP.Creator, UnEscaped)
    else if (StartsText('dc:rights.rdf:Alt', AKey)) then
      XMP.Rights := UnEscaped
    else if (StartsText('dc:date.rdf:Seq', AKey)) then
      XMP.Date := UnEscaped // Hardly a Bag!
    else if (StartsText('dc:type.rdf', AKey)) then
      AddBag(XMP.PhotoType, UnEscaped)
    else if (StartsText('dc:title.rdf:Alt', AKey)) then
      AddBag(XMP.Title, UnEscaped)
    else if (StartsText('dc:subject.rdf:Bag', AKey)) then
      AddBag(XMP.Keywords, UnEscaped)

    else if (StartsText('Iptc4xmpExt:Event.rdf:Alt', AKey)) then
      XMP.Event := UnEscaped

    else if (StartsText('xmp:Rating', AKey)) or
            (StartsText('xap:Rating', AKey)) then
      XMP.Rating := UnEscaped;
  end;

  procedure LevelDeeper(const ANode: TXmlNode; AParent: string);
  var
    ANodeList: TXmlNodeList;
    ASubNode: TXmlNode;
    SelNode: string;
    Attribute: TXmlAttribute;
  begin
    SelNode := Trim(AParent);
    if (ANode.NodeValue <> '') then
      Add2Xmp(SelNode, ANode.NodeValue);

    // Add . , but not for first
    if (SelNode <> '') then
      SelNode := SelNode + '.';

    // Look in Attributes of Node
    for Attribute in ANode.AttributeList do
      Add2Xmp(SelNode + Attribute.Name, Attribute.Value);

    // Look in Childnodes
    ANodeList := ANode.ChildNodes;
    for ASubNode in ANodeList do
      LevelDeeper(ASubNode, SelNode + ASubNode.NodeName);
  end;

begin
  FotoF.Seek(XMPoffset, TSeekOrigin.soBeginning);
  Setlength(Bytes, XMPsize);
  FotoF.Read(Bytes[0], XMPsize);

  TmpStream := TMemoryStream.Create;
  TmpStream.WriteData(Bytes, XMPsize);
  if (TmpStream = nil) then
    exit;

  Xml:= TXmlVerySimple.Create;
  try
    TmpStream.Position := 0;
    Xml.Encoding := XMPEncoding;
    Xml.LoadFromStream(TmpStream);

    RDF := GetRDF(Xml);
    if (RDF = nil) then
      exit;

    RDFDescNodes := RDF.ChildNodes;
    Xmp.Supported := (RDFDescNodes.Count > 0);

    // Recurse thru all subnodes, and look in attributes and node names
    for RDFDesc in RDFDescNodes do
      LevelDeeper(RDFDesc, '');
  finally
    Xml.Free;
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
  fotoF.Seek(4, TSeekOrigin.soBeginning);
  FotoF.Read(Cr3Magic, SizeOf(Cr3Magic));

  if (Cr3Magic = 'ftypcrx') then
  begin
    fotoF.Seek(0, TSeekOrigin.soBeginning);
    FotoF.Read(TagLen, SizeOf(TagLen));
    TagLen := SwapL(TagLen) - Sizeof(TagLen) - Sizeof(TagName);
    FotoF.Read(TagName, SizeOf(TagName));
    EndPos := FotoF.Size;
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
      TagLen := SwapL(TagLen) - Sizeof(TagLen) - Sizeof(TagName);
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

  FotoF.Seek(-CMT1Len, TSeekOrigin.soCurrent); //position before CMT1 to get the len

  FotoF.Read(TagLen, SizeOf(TagLen));
  TagLen := SwapL(TagLen) - Sizeof(TagLen) - Sizeof(TagName);
  FotoF.Read(TagName, SizeOf(TagName));
  EndPos := FotoF.Size;
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
      begin
        XMPsize := TagLen - UuidLen;
        XMPoffset := TIFFoffset + UuidLen;
        ReadXMP;
      end;
    end;

    FotoF.Seek(TIFFoffset + TagLen, TSeekOrigin.soBeginning);
    FotoF.Read(TagLen, SizeOf(TagLen));
    TagLen := SwapL(TagLen) - Sizeof(TagLen) - Sizeof(TagName);
    FotoF.Read(TagName, SizeOf(TagName));

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
function GetMetadata(AName: string; AGetOptions: TGetOptions): FotoRec;
var
  FotoHandle: THandle;
begin
  result.Clear;  // Clear all variables
  if (AName = '') or
     not FileExists(AName) then
    exit;

{$IFDEF DEBUG}
  FileName := AName;
{$ENDIF}

  with result do
  begin

    // Get parameters
    GetOptions := AGetOptions;
    FotoKeySep := ET_Options.GetSeparator;

    // Open the file ourselves. We dont want an exception
    FotoHandle := FileOpen(AName, fmOpenRead or fmShareDenyNone);
    if (FotoHandle = INVALID_HANDLE_VALUE) then
      exit;

    FotoF := THandleStream.Create(FotoHandle);
    try
      if (FotoF.Size > 31) then
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
            (XMPoffset > 0) and
            (XMPsize > 0) then
          ReadXMP;
      end;
    finally
      FotoF.Free;
      FileClose(FotoHandle);
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
        if (ExifIFD.Supported) then
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

  ExiFFormatSettings.ThousandSeparator := ',';
  ExiFFormatSettings.DecimalSeparator := '.';

  Encoding := TEncoding.GetEncoding(CP_UTF8)
end;

finalization

begin
  Encoding.Free;
end;

end.
