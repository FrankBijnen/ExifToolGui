unit ExifInfo;

interface

uses Classes, StdCtrls;

type
  IFDentryRec = packed record
    Tag: word;
    FieldType: word;
    TypeCount: longint;
    ValueOffs: longint;
    procedure Clear;
  end;

  IPTCrec = packed record
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
    InteropIndex: string[9];
    procedure Clear;
  end;

  GPSrec = packed record
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
    LensFocalRange: string[11]; // i.e."17-55"
    procedure Clear;
  end;

  XMPrec = packed record
    Creator, Rights: string;
    Date: string[19];
    PhotoType: string;
    Title, Event: string;
    CountryShown, ProvinceShown, CityShown, LocationShown: string;
    PersonInImage: string;
    Keywords: string; // =Subject
    Rating: string[1];
    procedure Clear;
  end;

  ICCrec = packed record
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

  FotoRec = packed record
    IFD0: IFD0rec;
    ExifIFD: ExifIFDrec;
    InteropIFD: InteropIFDrec;
    GPS: GPSrec;
    IPTC: IPTCrec;
    XMP: XMPrec;
    ICC: ICCrec;
    procedure Clear;
  end;

  TParseIFDProc = procedure(IFDentry: IFDentryRec);

var
  Foto: FotoRec;
  FotoKeySep: string[3] = '*';
  ETgps: string[15] = '-c "%d°%.4f" ';
  QuickGPSdec: boolean;

  ChartFLength: array [40 .. 3000] of word; // 4-300mm (Flength*10)
  ChartFNumber: array [12 .. 220] of word; // 1.2-22 (FNumber*10)
  ChartISO: array [5 .. 640] of word; // 50-6400 (ISO/10)
  ChartMaxFLength, ChartMaxFNumber, ChartMaxISO: word;

procedure GetMetadata(FName: string; GetXMP, GetIPTC, GetGPS, GetICC: boolean);
function GetOrientationValue(FName: string): word;

implementation

uses Main, SysUtils, Forms, Dialogs, Windows;

var
  Encoding: TEncoding;
  GpsFormatSettings: TFormatSettings; // for StrToFloatDef -see Initialization
  FotoF: THandleStream;
  IsMM, doIPTC, doGPS, doICC: boolean;
  Wdata: word;
  Ldata: longint;
  XMPoffset, XMPsize, IPTCsize, IPTCoffset: int64;
  TIFFoffset, ExifIFDoffset, GPSoffset: int64; // MakernoteOffset: longint;
  ICCoffset, InteropOffset, JPGfromRAWoffset: int64;

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

procedure IFDentryRec.Clear;
begin
  Self := Default(IFDentryRec);
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


// ****************************QUICK METADATA ACCESS*************************
function SwapL(L: longword): longword;
asm
  mov eax,L
  bswap eax
end;

function DecodeASCII(IFDentry: IFDentryRec; MaxLen: smallint = 255): string;
var
  Bytes: TBytes;
  W1: word;
  L1: longint;
begin
  W1 := IFDentry.TypeCount - 1; // last byte is #0
  SetLength(Bytes, W1);
  SetLength(Result, W1);
  L1 := IFDentry.ValueOffs;
  if W1 > 3 then
  begin
    FotoF.Seek(TIFFoffset + L1, TSeekOrigin.soBeginning);
    FotoF.Read(Bytes[0], W1);
    result := '';
    if (Encoding.GetCharCount(Bytes) > 0) then
      Result := Encoding.GetString(Bytes);
    W1 := Pos(Char(0), Result);
    if W1 > 0 then
      SetLength(Result, W1 - 1); // only if UserComment is ASCII!
  end
  else
  begin
    if IsMM then
      L1 := SwapL(L1);
    Move(L1, Result[1], W1);
    if Pos(Char(0), Result) = 1 then
      Result := '-'; // in case tag is defined and empty
  end;
end;

function DecodeWord(IFDentry: IFDentryRec): word;
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

function DecodeRational(IFDentry: IFDentryRec): word;
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

function DecodeExifLens(IFDentry: IFDentryRec): string;
var
  L1, L2, L3, L4: longint;
  i: smallint;
  tx: string[23];
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
      i := 0
    else
      i := 1;
    tx := FloatToStrF(L1 / L2, ffFixed, 7, i);
    if (L1 / L2) <> (L3 / L4) then
      tx := tx + '-' + FloatToStrF(L3 / L4, ffFixed, 7, i);
  end
  else
    tx := 'err!';
  tx := tx + 'mm f/';
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
    tx := tx + FloatToStrF(L1 / L2, ffFixed, 7, 1);
    if (L1 / L2) <> (L3 / L4) then
      tx := tx + '-' + FloatToStrF(L3 / L4, ffFixed, 7, 1);
  end
  else
    tx := tx + 'err!';
  i := Pos(',', tx);
  while i > 0 do
  begin
    tx[i] := '.';
    i := Pos(',', tx);
  end;
  Result := tx;
end;

function ConvertRational(IFDentry: IFDentryRec; Signed: boolean): string;
var
  L1, L2: longint;
  tx: string[15];
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
      tx := FloatToStrF(L1 / L2, ffFixed, 7, 2);
      if L1 > 0 then
        tx := '+' + tx;
      L1 := Pos(',', tx);
      if L1 > 0 then
        tx[L1] := '.';
      L1 := length(tx);
      SetLength(tx, L1 - 1);
      Result := tx;
    end
    else
    begin // for Exp.Time values [2s, 1/25s, 1/800s,..]
      if L2 = 1 then
        Result := IntToStr(L1) // i.e. for 2/1s -> 2s
      else
      begin
        if L1 > L2 then
        begin // i.e. for 2.5s
          tx := FloatToStrF(L1 / L2, ffFixed, 7, 1);
          L1 := Pos(',', tx);
          if L1 > 0 then
            tx[L1] := '.';
          Result := tx;
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

function GetRational(IFDentry: IFDentryRec): single;
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

function DecodeGPS(IFDentry: IFDentryRec; IsLat: boolean): string;
var
  R, Rd: double;
  L1, L2: longint;
  tx, Ty: string[11];
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
    tx := IntToStr(L1 div L2) + '°'
  else
    tx := '0°';
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
    tx := tx + IntToStr(L1 div L2) + '.'
  else
    tx := tx + '0.';
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
  tx := tx + Sec;
  Ty := Ty + ',' + Sec;

  R := StrToFloatDef(Ty, 0, GpsFormatSettings) / 60;
  Ty := FloatToStrF(Rd + R, ffFixed, 8, 6);
  L1 := Pos(',', Ty);
  if L1 > 0 then
    Ty[L1] := '.';
  if IsLat then
    Foto.GPS.GeoLat := Ty
  else
    Foto.GPS.GeoLon := Ty;
  Ty := Ty + '°';

  if QuickGPSdec then
    Result := Ty
  else
    Result := tx;
end;

// =================================PARSING======================================
procedure ParseIPTC;
var
  IPTCtagID: byte;
  IPTCtagSz: word;
  tx: string;
  Bytes: Tbytes;

  function StripLen(MaxLen: smallint = 255): string;
  begin
    if length(tx) > MaxLen then
    begin
      tx[MaxLen] := '…';
      SetLength(tx, MaxLen);
    end;
    Result := tx;
  end;

begin
  FotoF.Read(IPTCtagID, 1);
  FotoF.Read(IPTCtagSz, 2);
  IPTCtagSz := Swap(IPTCtagSz);
  Dec(IPTCsize, 3);
  SetLength(Bytes, IPTCtagSz);
  FotoF.Read(Bytes[0], IPTCtagSz);
  tx := '';
  if (Encoding.GetCharCount(Bytes) > 0) then
    tx := Encoding.GetString(Bytes);
  Dec(IPTCsize, IPTCtagSz);
  with Foto.IPTC do
  begin
    case IPTCtagID of
      5:
        ObjectName := StripLen(32);
      15:
        Category := StripLen(3);
      20:
        SuppCategories := SuppCategories + tx + FotoKeySep;
      25:
        Keywords := Keywords + tx + FotoKeySep;
      80:
        By_line := StripLen(32);
      85:
        By_lineTitle := StripLen(32);
      90:
        City := StripLen(31);
      92:
        Sub_location := StripLen(31);
      95:
        Province_State := StripLen(31);
      101:
        Country := StripLen(31);
      105:
        Headline := StripLen(64);
      116:
        CopyrightNotice := StripLen(64);
      120:
        Caption_Abstract := StripLen(128);
      122:
        Writer_Editor := StripLen(32);
    end;
  end;
end;

// ------------------------------------------------------------------------------
procedure ParseIFD0(IFDentry: IFDentryRec);
var
  FposBak: int64;
begin
  FposBak := FotoF.Position;
  with Foto.IFD0 do
  begin
    case IFDentry.Tag of
      $002E:
        JPGfromRAWoffset := IFDentry.ValueOffs; // Panasonic RW2
      // $0100: ImageWidth:=IFDentry.ValueOffs;
      // $0101: ImageHeight:=IFDentry.ValueOffs;
      // $010D: DocumentName:=DecodeASCII(IFDentry,64);
      // $010E: ImageDescription:=DecodeASCII(IFDentry,64);
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
  FotoF.Seek(FposBak, TSeekOrigin.soBeginning);
end;

// ------------------------------------------------------------------------------
procedure ParseExifIFD(IFDentry: IFDentryRec);
var
  tx: string[13];
  FposBak: int64;
begin
  FposBak := FotoF.Position;
  with Foto.ExifIFD do
  begin
    case IFDentry.Tag of
      $829A:
        ExposureTime := ConvertRational(IFDentry, false);
      $829D:
        begin
          tx := FloatToStrF(GetRational(IFDentry), ffFixed, 7, 1);
          if Pos(',', tx) > 0 then
            tx[Pos(',', tx)] := '.';
          FNumber := tx;
        end;
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
      (* $9205: begin
        Tx:=FloatToStrF(GetRational(IFDentry),ffFixed,7,1);
        if Pos(',',Tx)>0 then Tx[Pos(',',Tx)]:='.';
        MaxAperture:=Tx;
        end; *)
      $9209:
        Flash := DecodeWord(IFDentry) or $FF00; // $FFnn=tag exist indicator
      $920A:
        begin
          tx := FloatToStrF(GetRational(IFDentry), ffFixed, 7, 1);
          if Pos(',', tx) > 0 then
            tx[Pos(',', tx)] := '.';
          FocalLength := tx;
        end;
      // $927C: MakernoteOffset:=IFDentry.ValueOffs;
      (* $9286: begin
        Dec(IFDentry.TypeCount,7); //do not count starting 'ASCII...'
        BlockRead(FotoF,Tx[1],4); Tx[0]:=#4; //"ASCI", "UNIC", etc.
        Inc(IFDentry.ValueOffs,8); //skip starting 'ASCII...'
        if Tx='ASCI' then UserComment:=DecodeASCII(IFDentry)
        else UserComment:='non-ASCII content';
        end; *)
      // $9290: SubSecTime:=DecodeASCII(IFDentry);
      // $9291: SubSecTimeOriginal:=DecodeASCII(IFDentry);
      // $9292: SubSecTimeDigitized:=DecodeASCII(IFDentry);
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
      // $A002: ExifImageWidth:=IFDentry.ValueOffs;
      // $A003: ExifImageHeight:=IFDentry.ValueOffs;
      $A005:
        InteropOffset := IFDentry.ValueOffs;
      // $A402: if DecodeWord(IFDentry)=0 then ExposureMode:='Auto' else ExposureMode:='Manual';
      // $A403: if DecodeWord(IFDentry)=0 then WhiteBalance:='Auto' else WhiteBalance:='Manual';
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
  FotoF.Seek(FposBak, TSeekOrigin.soBeginning);
end;

// ------------------------------------------------------------------------------
procedure ParseGPS(IFDentry: IFDentryRec);
var
  FposBak: int64;
begin
  FposBak := FotoF.Position;
  with Foto.GPS do
  begin
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
  FotoF.Seek(FposBak, TSeekOrigin.soBeginning);
end;

// ==============================================================================
procedure ParseICCprofile;
var
  StartOfICC, xLong: int64;
  xWord: word;
  tx: string[31];
begin
  StartOfICC := FotoF.Position;
  FotoF.Read(tx[1], 4); // skip ICC size
  with Foto do
  begin
    FotoF.Read(ICC.ProfileCMMType[1], 4);
    ICC.ProfileCMMType[0] := #4;
    FotoF.Read(tx[1], 4); // skip ProfileVersion
    FotoF.Read(ICC.ProfileClass[1], 4);
    ICC.ProfileClass[0] := #4;
    FotoF.Read(ICC.ColorSpaceData[1], 4);
    ICC.ColorSpaceData[0] := #4;
    FotoF.Read(ICC.ProfileConnectionSpace[1], 4);
    ICC.ProfileConnectionSpace[0] := #4;
    FotoF.Read(tx[1], 16); // skip ProfileDateTime & ProfileFileSignature
    FotoF.Read(ICC.PrimaryPlatform[1], 4);
    ICC.PrimaryPlatform[0] := #4;
    FotoF.Read(tx[1], 4); // skip CMMFlags
    FotoF.Read(ICC.DeviceManufacturer[1], 4);
    ICC.DeviceManufacturer[0] := #4;
    FotoF.Read(tx[1], 28); // skip DeviceModel... goto ProfileCreator
    FotoF.Read(ICC.ProfileCreator[1], 4);
    ICC.ProfileCreator[0] := #4;
    tx := '????';
    while tx <> 'desc' do
      FotoF.Read(tx[1], 4); // <---What if desc doesn't exist??!!
    FotoF.Read(xLong, 4);
    xLong := SwapL(xLong);
    FotoF.Seek(StartOfICC + xLong, TSeekOrigin.soBeginning);
    FotoF.Read(tx[1], 4);
    if tx = 'desc' then
    begin
      FotoF.Read(tx[1], 6); // skip zeroes
      FotoF.Read(xWord, 2);
      xWord := Swap(xWord);
      xWord := xWord and $FF;
      Dec(xWord);
      if xWord > 31 then
        xWord := 31;
      FotoF.Read(ICC.ProfileDescription[1], xWord);
      ICC.ProfileDescription[0] := AnsiChar(xWord);
    end;
  end;
end;


procedure ParseIfd(Offset: int64; ParseProc: TParseIFDProc);
var
  IFDcount: word;
  IFDentry: IFDentryRec;

  procedure GetIFDentry;
  begin
    FotoF.Read(IFDentry, 12);
    if IsMM then
      with IFDentry do
      begin
        Tag := Swap(Tag);
        FieldType := Swap(FieldType);
        TypeCount := SwapL(TypeCount);
        ValueOffs := SwapL(ValueOffs);
      end;
  end;

begin
  FotoF.Seek(Offset, TSeekOrigin.soBeginning);
  FotoF.Read(IFDcount, 2);
  if IsMM then
    IFDcount := Swap(IFDcount);
  while IFDcount > 0 do
  begin
    GetIFDentry;
    ParseProc(IFDentry);
    Dec(IFDcount);
  end;

end;

// ==============================================================================
procedure ReadTIFF;
var
  IFDcount: word;
  i: smallint;
  IFDentry: IFDentryRec;

  procedure GetIFDentry;
  begin
    FotoF.Read(IFDentry, 12);
    if IsMM then
      with IFDentry do
      begin
        Tag := Swap(Tag);
        FieldType := Swap(FieldType);
        TypeCount := SwapL(TypeCount);
        ValueOffs := SwapL(ValueOffs);
      end;
  end;

begin
  TIFFoffset := FotoF.Position - 2;
  ExifIFDoffset := 0;
  GPSoffset := 0;
  IPTCoffset := 0;
  ICCoffset := 0;
  InteropOffset := 0; // MakernoteOffset:=0;
  IsMM := (Wdata = $4D4D);
  FotoF.Read(Wdata, 2);
  if IsMM then
    Wdata := Swap(Wdata);
  if (Wdata = $002A) or (Wdata = $0055) or (Wdata = $4F52) then
  begin // $002A=TIFF, $0055=PanasonicRW2, $4F52=OlympusORF
    IFDcount := 0;
    FotoF.Read(Ldata, 4);
    if IsMM then
      Ldata := SwapL(Ldata); // Read IFD0offset

    ParseIfd(TIFFoffset + Ldata, ParseIFD0);

    if ExifIFDoffset > 0 then
      ParseIFD(TIFFoffset + ExifIFDoffset, ParseExifIFD);

    if InteropOffset > 0 then
    begin
      FotoF.Seek(TIFFoffset + InteropOffset, TSeekOrigin.soBeginning);
      FotoF.Read(IFDcount, 2);
      if IsMM then
        IFDcount := Swap(IFDcount);
      GetIFDentry;
      if IFDentry.Tag = $0001 then
        with Foto.InteropIFD do
        begin
          InteropIndex := DecodeASCII(IFDentry);
          if InteropIndex = 'R03' then
            InteropIndex := 'R03=Adobe'
          else if InteropIndex = 'R98' then
            InteropIndex := 'R98=sRGB';
        end;
    end;

    if doGPS and (GPSoffset > 0) then
    begin
      ParseIFD(TIFFoffset + GPSoffset, ParseGPS);
      // for OSM Map
      with Foto.GPS do
      begin
        if (LatitudeRef = 'S') and (GeoLat <> '') then
          GeoLat := '-' + GeoLat;
        if (LongitudeRef = 'W') and (GeoLon <> '') then
          GeoLon := '-' + GeoLon;
      end;
      // -------------
    end;

    if doIPTC and (IPTCoffset > 0) then
    begin
      FotoF.Seek(TIFFoffset + IPTCoffset, TSeekOrigin.soBeginning);
      while IPTCsize > 1 do
      begin // one padded byte possible!
        FotoF.Read(Wdata, 2);
        Dec(IPTCsize, 2); // Skip $1C02
        if Wdata <> $021C then
          break;
        ParseIPTC;
      end;
      with Foto.IPTC do
      begin
        i := length(Keywords);
        if i > 1 then
          SetLength(Keywords, i - 1); // delete last separator
        if length(Keywords) = 127 then
          Keywords[127] := '…';
        i := length(SuppCategories);
        if i > 1 then
          SetLength(SuppCategories, i - 1);
        if length(SuppCategories) = 63 then
          SuppCategories[63] := '…';
      end;
    end;

    if doICC and (ICCoffset > 0) then
    begin
      FotoF.Seek(TIFFoffset + ICCoffset, TSeekOrigin.soBeginning);
      ParseICCprofile;
    end;

  end;
end;

// ==============================================================================
procedure ReadJPEG;
var
  APPmark, APPsize: word;
  APPmarkNext: int64;
  tx: string[15];
  i: smallint;
begin
  repeat
    FotoF.Read(APPmark, 2);
    APPmark := Swap(APPmark);
    if (APPmark = $FFE0) or (APPmark = $FFE1) or (APPmark = $FFE2) or (APPmark = $FFED) then
    begin
      FotoF.Read(APPsize, 2);
      APPsize := Swap(APPsize);
      APPmarkNext := FotoF.Position + APPsize - 2;
      // ------------------$FFE0=APP0:JFIF-----------------------
      // -don't parse
      // ------------------$FFE1=APP1:EXIF or XMP----------------
      if APPmark = $FFE1 then
      begin
        FotoF.Read(tx[1], 6);
        tx[0] := #4;
        if tx = 'Exif' then
        begin
          FotoF.Read(Wdata, 2);
          if (Wdata = $4949) or (Wdata = $4D4D) then
            ReadTIFF; // 'MM' or 'II'
        end
        else if tx = 'http' then
        begin
          FotoF.Seek(23, TSeekOrigin.soCurrent); // skip '://ns.adobe.com/xap/...'
          XMPoffset := FotoF.Position; // point to '<?xpacket...'
          XMPsize := APPsize - 31;
        end;
      end;
      // -----------------$FFE2=APP2:ICC_Profile-----------------
      if doICC and (APPmark = $FFE2) then
      begin
        FotoF.Read(tx[1], 14);
        tx[0] := #11;
        if tx = 'ICC_PROFILE' then
          ParseICCprofile;
      end;
      // -----------------$FFED=APP13:IPTC-----------------------
      if doIPTC and (APPmark = $FFED) then
      begin
        FotoF.Read(tx[1], 14);
        tx[0] := #13;
        if tx = 'Photoshop 3.0' then
        begin
          FotoF.Read(tx[1], 4);
          tx[0] := #4; // Tx='8BIM'
          FotoF.Read(Wdata, 2);
          if Wdata = $0404 then
          begin // $0404=IPTCData Photoshop tag
            FotoF.Read(Ldata, 4); // Ldata=0=dummy
            FotoF.Read(Wdata, 2);
            Wdata := Swap(Wdata);
            IPTCsize := Wdata;
            while IPTCsize > 1 do
            begin // one padded byte possible!
              FotoF.Read(Wdata, 2);
              Dec(IPTCsize, 2); // Skip $1C02
              ParseIPTC;
            end;
            with Foto.IPTC do
            begin
              i := length(Keywords);
              if i > 1 then
                SetLength(Keywords, i - 1); // delete last separator
              if length(Keywords) = 127 then
                Keywords[127] := '…';
              i := length(SuppCategories);
              if i > 1 then
                SetLength(SuppCategories, i - 1);
              if length(SuppCategories) = 63 then
                SuppCategories[63] := '…';
            end;
          end;
        end;
      end;
      // ---------------------------------------------------
      FotoF.Seek(APPmarkNext, TSeekOrigin.soBeginning);
    end;
  until (APPmark <> $FFE0) and (APPmark <> $FFE1) and (APPmark <> $FFE2) and (APPmark <> $FFED);
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

function SkipFujiHeader: word;
var
  SavePos: Int64;
  FujiMagic:array[0..7] of AnsiChar;
  JpegOffset: longword;
const
  JpegOffsetOffset = 16 + 4 + 8 + 32 + 4 + (5*4);
begin
  SavePos := FotoF.Position;
  FotoF.Seek(0, TSeekOrigin.soBeginning);
  FotoF.Read(FujiMagic, SizeOf(FujiMagic));

  if (FujiMagic = 'FUJIFILM') then
  begin
    FotoF.Seek(JpegOffsetOffset, TSeekOrigin.soBeginning);
    FotoF.Read(JpegOffset, SizeOf(JpegOffset));      // Offset to JpegImage
    JpegOffset := SwapL(JpegOffset);
    FotoF.Seek(JpegOffset, TSeekOrigin.soBeginning); // Set File pointer
  end
  else
    FotoF.Seek(SavePos, TSeekOrigin.soBeginning);    // Restore file pointer, no FujiFilm

// Return first word.
  FotoF.Read(result, SizeOf(result));
  result := Swap(result);
end;

procedure ReadFuji;
begin
  if (SkipFujiHeader = $FFD8) then
    ReadJpeg;
end;


// ==============================================================================
procedure ReadXMP;
var
  i, k, n: integer;
  XMPdata, tmpXMP, tx: string;
  Bytes: TBytes;
  xTx: string;

  function GetTagData(TagName: string; MaxLen: smallint = 255): string;
  begin
    i := Pos(TagName, XMPdata);
    if i > 0 then
    begin
      k := length(TagName);
      insert('/', TagName, 2);
      n := Pos(TagName, XMPdata);
      xTx := copy(XMPdata, i + k, n - i - k);
      if length(xTx) > MaxLen then
      begin
        xTx[MaxLen] := '…';
        SetLength(xTx, MaxLen);
      end;
      Result := xTx;
    end
    else
      Result := '';
  end;

  function GetBagData(BagName: string; MaxLen: smallint = 255): string;
  begin
    i := Pos(BagName, XMPdata);
    if i > 0 then
    begin
      k := length(BagName);
      insert('/', BagName, 2);
      n := Pos(BagName, XMPdata);
      tmpXMP := copy(XMPdata, i + k, n - i - k);
      xTx := '';
      while Pos('<rdf:li>', tmpXMP) > 0 do
      begin
        i := Pos('<rdf:li>', tmpXMP);
        n := Pos('</rdf:li>', tmpXMP);
        tx := copy(tmpXMP, i + 8, n - i - 8);
        xTx := xTx + tx + FotoKeySep;
        // result:=result+tx+FotoKeySep;
        Delete(tmpXMP, 1, n);
      end;
      i := length(xTx);
      if i > 1 then
        SetLength(xTx, i - 1); // delete last separator
      if length(xTx) > MaxLen then
      begin
        xTx[MaxLen] := '…';
        SetLength(xTx, MaxLen);
      end;
      Result := xTx;
    end
    else
      Result := '';
  end;

  function GetAltData(AltName: string; MaxLen: smallint = 255): string;
  begin
    i := Pos(AltName, XMPdata);
    Result := '';
    if i > 0 then
    begin
      k := length(AltName);
      insert('/', AltName, 2);
      n := Pos(AltName, XMPdata);
      tmpXMP := copy(XMPdata, i + k, n - i - k);
      i := Pos('<rdf:li', tmpXMP);
      if i > 0 then
      begin
        Delete(tmpXMP, 1, i);
        i := Pos('>', tmpXMP);
        Delete(tmpXMP, 1, i);
        i := Pos('<', tmpXMP);
        xTx := copy(tmpXMP, 1, i - 1);
        if length(xTx) > MaxLen then
        begin
          xTx[MaxLen] := '…';
          SetLength(xTx, MaxLen);
        end;
        Result := xTx;
      end;
    end;
  end;

  function GetStructTag(StructName, TagName: string): string;
  var
    z: smallint;
    TagEnd: string;
  begin
    i := Pos(StructName, XMPdata);
    if i > 0 then
    begin
      k := length(StructName);
      insert('/', StructName, 2);
      n := Pos(StructName, XMPdata);
      tmpXMP := copy(XMPdata, i + k, n - k);
      xTx := '';
      z := length(TagName);
      TagEnd := TagName;
      insert('/', TagEnd, 2);
      while Pos(TagName, tmpXMP) > 0 do
      begin
        i := Pos(TagName, tmpXMP);
        n := Pos(TagEnd, tmpXMP);
        tx := copy(tmpXMP, i + z, n - i - z);
        xTx := xTx + tx + FotoKeySep;
        Delete(tmpXMP, 1, n);
      end;
      i := length(xTx);
      if i > 1 then
        SetLength(xTx, i - 1); // delete last separator
      Result := xTx;
    end
    else
      Result := '';
  end;

begin
  XMPdata := '';
  FotoF.Seek(XMPoffset, TSeekOrigin.soBeginning);
  Setlength(Bytes, XMPsize);
  FotoF.Read(Bytes[0], XMPsize);
  XMPdata := '';
  if (Encoding.GetCharCount(Bytes) > 0) then
    XMPdata := Encoding.GetString(Bytes);
  XMPdata := StringReplace(XMPdata, '&amp;', '&', [rfReplaceAll]);
  XMPdata := StringReplace(XMPdata, '&quot;', '"', [rfReplaceAll]);
  XMPdata := StringReplace(XMPdata, '&#39;', '''', [rfReplaceAll]);
  XMPdata := StringReplace(XMPdata, '&lt;', '<', [rfReplaceAll]);
  XMPdata := StringReplace(XMPdata, '&gt;', '>', [rfReplaceAll]);

  with Foto.XMP do
  begin
    Creator := GetAltData('<dc:creator>');
    Rights := GetAltData('<dc:rights>');
    Date := GetAltData('<dc:date>');
    PhotoType := GetBagData('<dc:type>');
    Title := GetAltData('<dc:title>');
    Event := GetAltData('<Iptc4xmpExt:Event>');
    // Description:=GetAltData('<dc:description>');
    CountryShown := GetStructTag('<Iptc4xmpExt:LocationShown>', '<Iptc4xmpExt:CountryName>');
    ProvinceShown := GetStructTag('<Iptc4xmpExt:LocationShown>', '<Iptc4xmpExt:ProvinceState>');
    CityShown := GetStructTag('<Iptc4xmpExt:LocationShown>', '<Iptc4xmpExt:City>');
    LocationShown := GetStructTag('<Iptc4xmpExt:LocationShown>', '<Iptc4xmpExt:Sublocation>');
    PersonInImage := GetBagData('<Iptc4xmpExt:PersonInImage>');
    Keywords := GetBagData('<dc:subject>');
    Rating := GetTagData('<xmp:Rating>');
    if Rating = '' then
      Rating := GetTagData('<xap:Rating>'); // stupid DNG uses that
    (*
      Headline:=GetTagData('<photoshop:Headline>');
      Category:=GetTagData('<photoshop:Category>',31);
      Country:=GetTagData('<photoshop:Country>',31);
      State:=GetTagData('<photoshop:State>',31);
      City:=GetTagData('<photoshop:City>',31);
      Location:=GetTagData('<Iptc4xmpCore:Location>',31);
      tx:=GetTagData('<photoshop:DateCreated>',19); tx:=StringReplace(tx,'T',' ',[]);
      DateCreated:=StringReplace(tx,'-',':',[rfReplaceAll]);
    *)
  end;
  XMPdata := '';
end;

// https://github.com/lclevy/canon_cr3/blob/master/readme.md
function SkipCr3Header: word;
var
  SavePos, EndPos: Int64;
  Cr3Magic:array[0..6] of AnsiChar;
  TagLen: DWORD;
  TagName:array[0..3] of AnsiChar;

const
  MoovSize = 24;
  TiffHeader = 8;
begin
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
        fotoF.Seek(TagLen, TSeekOrigin.soCurrent);

      FotoF.Read(TagLen, SizeOf(TagLen));
      TagLen := SwapL(TagLen) - Sizeof(TagLen) - Sizeof(TagName);
      FotoF.Read(TagName, SizeOf(TagName));

      if (TagName = 'CMT1') then
        break;
    end;
  end
  else
    FotoF.Seek(SavePos, TSeekOrigin.soBeginning); // No CR3

// Return first word.
  FotoF.Read(result, SizeOf(result));
  result := Swap(result);
end;

procedure ReadCr3;
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
  SkipCr3Header;
  FotoF.Seek(-CMT1Len, TSeekOrigin.soCurrent); //position before CMT1 to get the len

  FotoF.Read(TagLen, SizeOf(TagLen));
  TagLen := SwapL(TagLen) - Sizeof(TagLen) - Sizeof(TagName);
  FotoF.Read(TagName, SizeOf(TagName));
  EndPos := FotoF.Size;
  while (FotoF.Position + TagLen < EndPos) do
  begin
    TIFFoffset := FotoF.Position;
    FotoF.Read(Wdata, SizeOf(Wdata));
    if (TagName = 'CMT1') then
      ParseIfd(TIFFoffset + TiffHeaderLen, ParseIFD0);
    if (TagName = 'CMT2') then
      ParseIfd(TIFFoffset + TiffHeaderLen, ParseExifIFD);
    if (doGPS) and (TagName = 'CMT4') then
      ParseIfd(TIFFoffset + TiffHeaderLen, ParseGPS);
    if (TagName = 'uuid') then
    begin
      FotoF.Seek(-SizeOf(Wdata), TSeekOrigin.soCurrent);
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

// ======================================== MAIN ==============================================
procedure GetMetadata(FName: string; GetXMP, GetIPTC, GetGPS, GetICC: boolean);
var
  FotoHandle: THandle;
begin
  if (FName = '') then
    exit;

  Foto.Clear;
  doIPTC := GetIPTC;
  doGPS := GetGPS;
  doICC := GetICC;
  XMPoffset := 0;
  XMPsize := 0;
  JPGfromRAWoffset := 0; // for Panasonic RW2

  if not FileExists(FName) then
    exit;

  // Open the file ourselves. We dont want an exception
  FotoHandle := FileOpen(FName, fmOpenRead or fmShareDenyNone);
  if (FotoHandle = INVALID_HANDLE_VALUE) then
    exit;

  FotoF := THandleStream.Create(FotoHandle);
  try
    if (FotoF.Size > 31) then
    begin // size must be at least 32 bytes
      FotoF.Read(Wdata, 2);
      Wdata := Swap(Wdata);
      case Wdata of
        $0000:
          ReadCr3;
        $4655:
          ReadFuji;
        $FFD8:
          ReadJPEG;
        $4949:
          ReadTIFF; // 'II'=TIF,DNG,CR2,CRW,RW2,ORF
        $4D4D:
          ReadTIFF; // 'MM'=NEF,PEF
      end;
      if JPGfromRAWoffset > 0 then
      begin // in case of RW2
        FotoF.Seek(JPGfromRAWoffset, TSeekOrigin.soBeginning);
        FotoF.Read(Wdata, 2);
        Wdata := Swap(Wdata);
        if Wdata = $FFD8 then
          ReadJPEG;
      end;
      if GetXMP and (XMPoffset > 0) and (XMPsize > 0) then
        ReadXMP;
    end;
  finally
    FotoF.Free;
    FileClose(FotoHandle);
  end;
end;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// ============================================================================================
function GetOrientationValue(FName: string): word;
var
  IFDentry: IFDentryRec;
  Wdata, AppMarker, APPsize, IFDcount: word;
  Ldata: longword;
  TIFFoffset, NextAPPmarker: int64;
  IsMM: boolean;
  TmpTxt: string[7];
  FotoHandle: THandle;

  procedure ReadTIFFOrient;
  begin
    IsMM := (Wdata = $4D4D);
    TIFFoffset := FotoF.Position - 2;
    FotoF.Read(Wdata, 2);
    if IsMM then
      Wdata := Swap(Wdata);
    if Wdata = $002A then
    begin
      FotoF.Read(Ldata, 4);
      if IsMM then
        Ldata := SwapL(Ldata); // Read IFD0offset
      if Ldata > 0 then
      begin
        FotoF.Seek(TIFFoffset + Ldata, TSeekOrigin.soBeginning);
        FotoF.Read(IFDcount, 2);
        if IsMM then
          IFDcount := Swap(IFDcount);
        while IFDcount > 0 do
        begin
          FotoF.Read(IFDentry, 12);
          if IsMM then
            with IFDentry do
            begin
              Tag := Swap(Tag);
              ValueOffs := SwapL(ValueOffs);
            end;
          if IFDentry.Tag = $0112 then
          begin
            Ldata := IFDentry.ValueOffs;
            if IsMM then
              Ldata := SwapL(Ldata);
            result := Ldata;
            if IsMM then
              result := Swap(result);
            IFDcount := 1;
          end;
          Dec(IFDcount);
        end;
      end;
    end;
  end;

// --------------------------------------------------------------
begin
  result := 0;

  // Could be directory. Skip.
  if not FileExists(FName) then
    exit;

  // Open the file ourselves. We dont want an exception
  FotoHandle := FileOpen(FName, fmOpenRead or fmShareDenyNone);
  if (FotoHandle = INVALID_HANDLE_VALUE) then
    exit;

  FotoF := THandleStream.Create(FotoHandle);
  try
    if (FotoF.Size > 31) then
    begin // size must be at least 32 bytes
      FotoF.Read(Wdata, 2);
      Wdata := Swap(Wdata);

      if Wdata = $0000 then
        Wdata := SkipCr3Header;

      if (Wdata = $4949) or (Wdata = $4D4D) then
        ReadTIFFOrient
      else
      begin
        if Wdata = $4655 then
          Wdata := SkipFujiHeader;

        if Wdata = $FFD8 then
        begin
          repeat
            FotoF.Read(AppMarker, 2);
            AppMarker := Swap(AppMarker);
            if (AppMarker = $FFE0) or (AppMarker = $FFE1) or (AppMarker = $FFED) then
            begin
              FotoF.Read(APPsize, 2);
              APPsize := Swap(APPsize);
              NextAPPmarker := FotoF.Position + APPsize - 2;
              if AppMarker = $FFE1 then
              begin
                FotoF.Read(TmpTxt[1], 6);
                TmpTxt[0] := #4;
                FotoF.Read(Wdata, 2);
                if (TmpTxt = 'Exif') and ((Wdata = $4949) or (Wdata = $4D4D)) then
                  ReadTIFFOrient;
              end;
              if result <> 0 then
                break;
              FotoF.Seek(NextAPPmarker, TSeekOrigin.soBeginning);
            end;
          until (AppMarker <> $FFE0) and (AppMarker <> $FFE1) and (AppMarker <> $FFED);
        end;
      end;
    end;
  finally
    FotoF.Free;
    FileClose(FotoHandle);
  end;
end;

// =============================== GetJPGsize =================================================
// Not used
procedure GetJPGsize(const sFile: string; var wWidth, wHeight: word);
const
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var
  Seg: byte;
  Len, w: word;
  ReadLen, dummy: longint;
begin
  wWidth := 0;
  wHeight := 0;
  if FileExists(sFile) then
  begin
    FotoF := TFileStream.Create(sFile, fmOpenRead or fmShareDenyNone);
    try
      w := 0;
      FotoF.Read(w, 2);
      w := Swap(w);
      if w = $FFD8 then
      begin
        ReadLen := FotoF.Read(Seg, 1);
        while (Seg = $FF) and (ReadLen > 0) do
        begin
          ReadLen := FotoF.Read(Seg, 1);
          if Seg <> $FF then
          begin
            if (Seg = $C0) or (Seg = $C1) then
            begin
              ReadLen := FotoF.Read(dummy, 3); { don't need these bytes }
              FotoF.Read(wHeight, 2);
              wHeight := Swap(wHeight);
              FotoF.Read(wWidth, 2);
              wWidth := Swap(wWidth);
            end
            else
            begin
              if not(Seg in Parameterless) then
              begin
                FotoF.Read(Len, 2);
                Len := Swap(Len);
                FotoF.Seek(Len - 2, 1);
                FotoF.Read(Seg, 1);
              end
              else
                Seg := $FF; { Fake it to keep looping. }
            end;
          end;
        end;
      end;
    finally
      FotoF.Free;
    end;
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
