unit ExifInfo;

interface

uses Classes, StdCtrls;

type
  IFDentryRec = packed record
    Tag: word;
    FieldType: word;
    TypeCount: longint;
    ValueOffs: longint;
  end;

  IPTCrec = packed record
    ObjectName: ShortString;
    Category: ShortString;
    SuppCategories: ShortString;
    Keywords: ShortString;
    By_line, By_lineTitle: ShortString;
    Country, Province_State, City, Sub_location: ShortString;
    Headline: ShortString;
    CopyrightNotice: ShortString;
    Caption_Abstract: ShortString;
    Writer_Editor: ShortString;
  end;

  IFD0rec = packed record
    // ImageWidth,ImageHeight: word;
    // DocumentName: string[64];
    // ImageDescription: string[64];
    Make, Model: String[64];
    PreviewOffset, PreviewSize: longint;
    Orientation: word; // 1=Normal, 3=180, 6=90right, 8=90left, else=Mirror
    Xresolution, Yresolution: word;
    ResolutionUnit: string[5];
    Software: string[64];
    DateTimeModify: string[19];
    Artist: String[64];
    Copyright: String[64];
  end;

  ExifIFDrec = packed record
    ExposureTime: string[7];
    FNumber: string[5];
    ExposureProgram: string[7];
    ISO: string[5];
    DateTimeOriginal, DateTimeDigitized: string[19];
    ExposureBias: string[7];
    // MaxAperture: string[5];
    Flash: word; // if (ExifIFD.Flash and 1)=1 then 'Flash=Yes'
    FocalLength: string[7];
    // UserComment: string[63];
    // SubSecTime,SubSecTimeOriginal,SubSecTimeDigitized: string[3];
    ColorSpace: string[13];
    // ExifImageWidth,ExifImageHeight: word;
    // ExposureMode,WhiteBalance: string[7];
    FLin35mm: string[7];
    LensInfo: string[23];
    LensMake: string[23];
    LensModel: string[47];
  end;

  InteropIFDrec = packed record
    InteropIndex: string[9];
  end;

  GPSrec = packed record
    LatitudeRef: string[1]; // North/South
    Latitude: string[11];
    LongitudeRef: string[1]; // East/West
    Longitude: string[11];
    AltitudeRef: string[1]; // +/-
    Altitude: string[5];
    GeoLat, GeoLon: string[11]; // for OSM Map
  end;

  MakernotesRec = packed record
    LensFocalRange: string[11]; // i.e."17-55"
  end;

  XMPrec = packed record
    Creator, Rights: AnsiString;
    Date: string[19];
    PhotoType: AnsiString;
    Title, Event: AnsiString;
    // Description: AnsiString;
    CountryShown, ProvinceShown, CityShown, LocationShown: ShortString;
    PersonInImage: ShortString;
    Keywords: ShortString; // =Subject
    Rating: string[1];
    (*
      Headline, Category: AnsiString;
      Country,State,City,Location: AnsiString;
      DateCreated: string[19];
    *)
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
  end;

  FotoRec = packed record
    IFD0: IFD0rec;
    ExifIFD: ExifIFDrec;
    InteropIFD: InteropIFDrec;
    GPS: GPSrec;
    IPTC: IPTCrec;
    XMP: XMPrec;
    ICC: ICCrec;
  end;

var
  Foto: FotoRec;
  FotoKeySep: string[3] = '*';
  ETgps: string[15] = '-c "%d°%.4f" ';
  QuickGPSdec: boolean;

  ChartFLength: array [40 .. 3000] of word; // 4-300mm (Flength*10)
  ChartFNumber: array [12 .. 220] of word; // 1.2-22 (FNumber*10)
  ChartISO: array [5 .. 640] of word; // 50-6400 (ISO/10)
  ChartMaxFLength, ChartMaxFNumber, ChartMaxISO: word;

procedure GetMetadata(fName: string; GetXMP, GetIPTC, GetGPS, GetICC: boolean);
function GetOrientationValue(fName: string): byte;
procedure GetJPGsize(const sFile: string; var wWidth, wHeight: word);

implementation

uses Main, SysUtils, Forms, Dialogs, Windows;

var
  GpsFormatSettings: TFormatSettings; // for StrToFloatDef -see Initialization
  FotoF: file of byte;
  IsMM, doIPTC, doGPS, doICC: boolean;
  Wdata: word;
  Ldata: longint;
  XMPoffset, XMPsize, IPTCsize, IPTCoffset: longint;
  TIFFoffset, ExifIFDoffset, GPSoffset: longint; // MakernoteOffset: longint;
  ICCoffset, InteropOffset, JPGfromRAWoffset: longint;

  // ****************************QUICK METADATA ACCESS*************************
function SwapL(L: longword): longword;
asm
  mov eax,L
  bswap eax
end;

function DecodeASCII(IFDentry: IFDentryRec; MaxLen: smallint = 255): AnsiString;
var
  Txt: AnsiString;
  W1: word;
  L1: longint;
begin
  W1 := IFDentry.TypeCount - 1; // last byte is #0
  SetLength(Txt, W1);
  L1 := IFDentry.ValueOffs;
  if W1 > 3 then
  begin
    Seek(FotoF, TIFFoffset + L1);
    BlockRead(FotoF, Txt[1], W1);
    W1 := Pos(AnsiChar(0), Txt);
    if W1 > 0 then
      SetLength(Txt, W1 - 1); // only if UserComment is ASCII!
  end
  else
  begin
    if IsMM then
      L1 := SwapL(L1);
    Move(L1, Txt[1], W1);
    if Pos(AnsiChar(0), Txt) = 1 then
      Txt := '-'; // in case tag is defined and empty
  end;
  Result := Utf8ToAnsi(Txt);
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
  Seek(FotoF, TIFFoffset + IFDentry.ValueOffs);
  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4);
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
  Seek(FotoF, TIFFoffset + IFDentry.ValueOffs);
  // Min-Max focal length
  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4);
  BlockRead(FotoF, L3, 4);
  BlockRead(FotoF, L4, 4);
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
  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4);
  BlockRead(FotoF, L3, 4);
  BlockRead(FotoF, L4, 4);
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
  Seek(FotoF, TIFFoffset + IFDentry.ValueOffs);
  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4);
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
  Seek(FotoF, TIFFoffset + IFDentry.ValueOffs);
  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4);
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
  Seek(FotoF, TIFFoffset + IFDentry.ValueOffs);
  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4); // =Deg
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

  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4); // =Min
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

  BlockRead(FotoF, L1, 4);
  BlockRead(FotoF, L2, 4); // =Sec
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
  tx: string[255];

  function StripLen(MaxLen: smallint = 255): AnsiString;
  begin
    if length(tx) > MaxLen then
    begin
      tx[MaxLen] := '…';
      SetLength(tx, MaxLen);
    end;
    Result := tx;
  end;

begin
  BlockRead(FotoF, IPTCtagID, 1);
  BlockRead(FotoF, IPTCtagSz, 2);
  IPTCtagSz := Swap(IPTCtagSz);
  Dec(IPTCsize, 3);
  if IPTCtagSz < 256 then
  begin
    BlockRead(FotoF, tx[1], IPTCtagSz);
    tx[0] := AnsiChar(IPTCtagSz); // Chr(Lo(IPTCtagSz));
  end
  else
  begin
    BlockRead(FotoF, tx[1], 255);
    Seek(FotoF, FilePos(FotoF) + IPTCtagSz - 255);
    tx[0] := #255;
  end;
  tx := Utf8ToAnsi(tx);
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
  FposBak: longword;
begin
  FposBak := FilePos(FotoF);
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
  Seek(FotoF, FposBak);
end;

// ------------------------------------------------------------------------------
procedure ParseExifIFD(IFDentry: IFDentryRec);
var
  tx: string[13];
  FposBak: longword;
begin
  FposBak := FilePos(FotoF);
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
  Seek(FotoF, FposBak);
end;

// ------------------------------------------------------------------------------
procedure ParseGPS(IFDentry: IFDentryRec);
var
  FposBak: longword;
begin
  FposBak := FilePos(FotoF);
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
  Seek(FotoF, FposBak);
end;

// ==============================================================================
procedure ParseICCprofile;
var
  StartOfICC, xLong: longword;
  xWord: word;
  tx: string[31];
begin
  StartOfICC := FilePos(FotoF);
  BlockRead(FotoF, tx[1], 4); // skip ICC size
  with Foto do
  begin
    BlockRead(FotoF, ICC.ProfileCMMType[1], 4);
    ICC.ProfileCMMType[0] := #4;
    BlockRead(FotoF, tx[1], 4); // skip ProfileVersion
    BlockRead(FotoF, ICC.ProfileClass[1], 4);
    ICC.ProfileClass[0] := #4;
    BlockRead(FotoF, ICC.ColorSpaceData[1], 4);
    ICC.ColorSpaceData[0] := #4;
    BlockRead(FotoF, ICC.ProfileConnectionSpace[1], 4);
    ICC.ProfileConnectionSpace[0] := #4;
    BlockRead(FotoF, tx[1], 16); // skip ProfileDateTime & ProfileFileSignature
    BlockRead(FotoF, ICC.PrimaryPlatform[1], 4);
    ICC.PrimaryPlatform[0] := #4;
    BlockRead(FotoF, tx[1], 4); // skip CMMFlags
    BlockRead(FotoF, ICC.DeviceManufacturer[1], 4);
    ICC.DeviceManufacturer[0] := #4;
    BlockRead(FotoF, tx[1], 28); // skip DeviceModel... goto ProfileCreator
    BlockRead(FotoF, ICC.ProfileCreator[1], 4);
    ICC.ProfileCreator[0] := #4;
    tx := '????';
    while tx <> 'desc' do
      BlockRead(FotoF, tx[1], 4); // <---What if desc doesn't exist??!!
    BlockRead(FotoF, xLong, 4);
    xLong := SwapL(xLong);
    Seek(FotoF, StartOfICC + xLong);
    BlockRead(FotoF, tx[1], 4);
    if tx = 'desc' then
    begin
      BlockRead(FotoF, tx[1], 6); // skip zeroes
      BlockRead(FotoF, xWord, 2);
      xWord := Swap(xWord);
      xWord := xWord and $FF;
      Dec(xWord);
      if xWord > 31 then
        xWord := 31;
      BlockRead(FotoF, ICC.ProfileDescription[1], xWord);
      ICC.ProfileDescription[0] := AnsiChar(xWord);
    end;
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
    BlockRead(FotoF, IFDentry, 12);
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
  TIFFoffset := FilePos(FotoF) - 2;
  ExifIFDoffset := 0;
  GPSoffset := 0;
  IPTCoffset := 0;
  ICCoffset := 0;
  InteropOffset := 0; // MakernoteOffset:=0;
  IsMM := (Wdata = $4D4D);
  BlockRead(FotoF, Wdata, 2);
  if IsMM then
    Wdata := Swap(Wdata);
  if (Wdata = $002A) or (Wdata = $0055) or (Wdata = $4F52) then
  begin // $002A=TIFF, $0055=PanasonicRW2, $4F52=OlympusORF
    IFDcount := 0;
    BlockRead(FotoF, Ldata, 4);
    if IsMM then
      Ldata := SwapL(Ldata); // Read IFD0offset
    if Ldata > 0 then
    begin
      Seek(FotoF, TIFFoffset + Ldata);
      BlockRead(FotoF, IFDcount, 2);
      if IsMM then
        IFDcount := Swap(IFDcount);
      while IFDcount > 0 do
      begin
        GetIFDentry;
        ParseIFD0(IFDentry);
        Dec(IFDcount);
      end;
    end;

    if ExifIFDoffset > 0 then
    begin
      Seek(FotoF, TIFFoffset + ExifIFDoffset);
      BlockRead(FotoF, IFDcount, 2);
      if IsMM then
        IFDcount := Swap(IFDcount);
      while IFDcount > 0 do
      begin
        GetIFDentry;
        ParseExifIFD(IFDentry);
        Dec(IFDcount);
      end;
    end;

    if InteropOffset > 0 then
    begin
      Seek(FotoF, TIFFoffset + InteropOffset);
      BlockRead(FotoF, IFDcount, 2);
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
      Seek(FotoF, TIFFoffset + GPSoffset);
      BlockRead(FotoF, IFDcount, 2);
      if IsMM then
        IFDcount := Swap(IFDcount);
      while IFDcount > 0 do
      begin
        GetIFDentry;
        ParseGPS(IFDentry);
        Dec(IFDcount);
      end;
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
      Seek(FotoF, TIFFoffset + IPTCoffset);
      while IPTCsize > 1 do
      begin // one padded byte possible!
        BlockRead(FotoF, Wdata, 2);
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
      Seek(FotoF, TIFFoffset + ICCoffset);
      ParseICCprofile;
    end;

  end;
end;

// ==============================================================================
procedure ReadJPEG;
var
  APPmark, APPsize: word;
  APPmarkNext: longint;
  tx: string[15];
  i: smallint;
begin
  repeat
    BlockRead(FotoF, APPmark, 2);
    APPmark := Swap(APPmark);
    if (APPmark = $FFE0) or (APPmark = $FFE1) or (APPmark = $FFE2) or
      (APPmark = $FFED) then
    begin
      BlockRead(FotoF, APPsize, 2);
      APPsize := Swap(APPsize);
      APPmarkNext := FilePos(FotoF) + APPsize - 2;
      // ------------------$FFE0=APP0:JFIF-----------------------
      // -don't parse
      // ------------------$FFE1=APP1:EXIF or XMP----------------
      if APPmark = $FFE1 then
      begin
        BlockRead(FotoF, tx[1], 6);
        tx[0] := #4;
        if tx = 'Exif' then
        begin
          BlockRead(FotoF, Wdata, 2);
          if (Wdata = $4949) or (Wdata = $4D4D) then
            ReadTIFF; // 'MM' or 'II'
        end
        else if tx = 'http' then
        begin
          Seek(FotoF, FilePos(FotoF) + 23); // skip '://ns.adobe.com/xap/...'
          XMPoffset := FilePos(FotoF); // point to '<?xpacket...'
          XMPsize := APPsize - 31;
        end;
      end;
      // -----------------$FFE2=APP2:ICC_Profile-----------------
      if doICC and (APPmark = $FFE2) then
      begin
        BlockRead(FotoF, tx[1], 14);
        tx[0] := #11;
        if tx = 'ICC_PROFILE' then
          ParseICCprofile;
      end;
      // -----------------$FFED=APP13:IPTC-----------------------
      if doIPTC and (APPmark = $FFED) then
      begin
        BlockRead(FotoF, tx[1], 14);
        tx[0] := #13;
        if tx = 'Photoshop 3.0' then
        begin
          BlockRead(FotoF, tx[1], 4);
          tx[0] := #4; // Tx='8BIM'
          BlockRead(FotoF, Wdata, 2);
          if Wdata = $0404 then
          begin // $0404=IPTCData Photoshop tag
            BlockRead(FotoF, Ldata, 4); // Ldata=0=dummy
            BlockRead(FotoF, Wdata, 2);
            Wdata := Swap(Wdata);
            IPTCsize := Wdata;
            while IPTCsize > 1 do
            begin // one padded byte possible!
              BlockRead(FotoF, Wdata, 2);
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
      Seek(FotoF, APPmarkNext);
    end;
  until (APPmark <> $FFE0) and (APPmark <> $FFE1) and (APPmark <> $FFE2) and
    (APPmark <> $FFED);
end;

// ==============================================================================
procedure ReadXMP;
var
  P: AnsiChar;
  i, k, n: integer;
  XMPdata, tmpXMP, tx: AnsiString;
  xTx: string[255];

  function GetTagData(TagName: string; MaxLen: smallint = 255): AnsiString;
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

  function GetBagData(BagName: string; MaxLen: smallint = 255): AnsiString;
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

  function GetAltData(AltName: string; MaxLen: smallint = 255): AnsiString;
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

  function GetStructTag(StructName, TagName: AnsiString): AnsiString;
  var
    z: smallint;
    TagEnd: AnsiString;
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
      xTx[255] := '…';
      Result := xTx;
    end
    else
      Result := '';
  end;

begin
  XMPdata := '';
  Seek(FotoF, XMPoffset);
  while XMPsize > 0 do
  begin
    BlockRead(FotoF, P, 1);
    XMPdata := XMPdata + P;
    Dec(XMPsize);
  end;
  XMPdata := Utf8ToAnsi(XMPdata);
  XMPdata := StringReplace(XMPdata, '&amp;', '&', [rfReplaceAll]);
  with Foto.XMP do
  begin
    Creator := GetAltData('<dc:creator>');
    Rights := GetAltData('<dc:rights>');
    Date := GetAltData('<dc:date>');
    PhotoType := GetBagData('<dc:type>');
    Title := GetAltData('<dc:title>');
    Event := GetAltData('<Iptc4xmpExt:Event>');
    // Description:=GetAltData('<dc:description>');
    CountryShown := GetStructTag('<Iptc4xmpExt:LocationShown>',
      '<Iptc4xmpExt:CountryName>');
    ProvinceShown := GetStructTag('<Iptc4xmpExt:LocationShown>',
      '<Iptc4xmpExt:ProvinceState>');
    CityShown := GetStructTag('<Iptc4xmpExt:LocationShown>',
      '<Iptc4xmpExt:City>');
    LocationShown := GetStructTag('<Iptc4xmpExt:LocationShown>',
      '<Iptc4xmpExt:Sublocation>');
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

// ======================================== MAIN ==============================================
procedure GetMetadata(fName: string; GetXMP, GetIPTC, GetGPS, GetICC: boolean);
begin
  if (fName = '') then
    exit;

  FillChar(Foto, SizeOf(Foto), #0);
  doIPTC := GetIPTC;
  doGPS := GetGPS;
  doICC := GetICC;
  XMPoffset := 0;
  XMPsize := 0;
  JPGfromRAWoffset := 0; // for Panasonic RW2

  AssignFile(FotoF, fName);
  FileMode := 0; // read only
  Reset(FotoF); // open existing file
  try
    if FileSize(FotoF) > 31 then
    begin // size must be at least 32 bytes
      BlockRead(FotoF, Wdata, 2);
      Wdata := Swap(Wdata);
      case Wdata of
        $FFD8:
          ReadJPEG;
        $4949:
          ReadTIFF; // 'II'=TIF,DNG,CR2,CRW,RW2,ORF
        $4D4D:
          ReadTIFF; // 'MM'=NEF,PEF
      end;
      if JPGfromRAWoffset > 0 then
      begin // in case of RW2
        Seek(FotoF, JPGfromRAWoffset);
        BlockRead(FotoF, Wdata, 2);
        Wdata := Swap(Wdata);
        if Wdata = $FFD8 then
          ReadJPEG;
      end;
      if GetXMP and (XMPoffset > 0) and (XMPsize > 0) then
        ReadXMP;
    end;
  finally
    CloseFile(FotoF);
  end;
end;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// ============================================================================================
function GetOrientationValue(fName: string): byte;
var
  IFDentry: IFDentryRec;
  Wdata, AppMarker, APPsize, IFDcount, Rotate: word;
  Ldata, TIFFoffset, NextAPPmarker: longword;
  IsMM: boolean;
  TmpTxt: string[7];

  procedure ReadTIFF;
  begin
    IsMM := (Wdata = $4D4D);
    TIFFoffset := FilePos(FotoF) - 2;
    BlockRead(FotoF, Wdata, 2);
    if IsMM then
      Wdata := Swap(Wdata);
    if Wdata = $002A then
    begin
      BlockRead(FotoF, Ldata, 4);
      if IsMM then
        Ldata := SwapL(Ldata); // Read IFD0offset
      if Ldata > 0 then
      begin
        Seek(FotoF, TIFFoffset + Ldata);
        BlockRead(FotoF, IFDcount, 2);
        if IsMM then
          IFDcount := Swap(IFDcount);
        while IFDcount > 0 do
        begin
          BlockRead(FotoF, IFDentry, 12);
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
            Rotate := Ldata;
            if IsMM then
              Rotate := Swap(Rotate);
            IFDcount := 1;
          end;
          Dec(IFDcount);
        end;
      end;
    end;
  end;

// --------------------------------------------------------------
begin
  Rotate := 0;
  AssignFile(FotoF, fName);
  FileMode := 0;
  Reset(FotoF);
  if FileSize(FotoF) > 31 then
  begin // size must be at least 32 bytes
    BlockRead(FotoF, Wdata, 2);
    Wdata := Swap(Wdata);
    if (Wdata = $4949) or (Wdata = $4D4D) then
      ReadTIFF
    else
    begin
      if Wdata = $FFD8 then
      begin
        repeat
          BlockRead(FotoF, AppMarker, 2);
          AppMarker := Swap(AppMarker);
          if (AppMarker = $FFE0) or (AppMarker = $FFE1) or (AppMarker = $FFED)
          then
          begin
            BlockRead(FotoF, APPsize, 2);
            APPsize := Swap(APPsize);
            NextAPPmarker := FilePos(FotoF) + APPsize - 2;
            if AppMarker = $FFE1 then
            begin
              BlockRead(FotoF, TmpTxt[1], 6);
              TmpTxt[0] := #4;
              BlockRead(FotoF, Wdata, 2);
              if (TmpTxt = 'Exif') and ((Wdata = $4949) or (Wdata = $4D4D)) then
                ReadTIFF;
            end;
            if Rotate <> 0 then
              break;
            Seek(FotoF, NextAPPmarker);
          end;
        until (AppMarker <> $FFE0) and (AppMarker <> $FFE1) and
          (AppMarker <> $FFED);
      end;
    end;
  end;
  CloseFile(FotoF);
  Result := Rotate;
end;

// =============================== GetJPGsize =================================================
procedure GetJPGsize(const sFile: string; var wWidth, wHeight: word);
const
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var
  f: TFileStream;
  Seg: byte;
  Len, w: word;
  ReadLen, dummy: longint;
begin
  wWidth := 0;
  wHeight := 0;
  if FileExists(sFile) then
  begin
    f := TFileStream.Create(sFile, fmOpenRead);
    try
      w := 0;
      f.Read(w, 2);
      w := Swap(w);
      if w = $FFD8 then
      begin
        ReadLen := f.Read(Seg, 1);
        while (Seg = $FF) and (ReadLen > 0) do
        begin
          ReadLen := f.Read(Seg, 1);
          if Seg <> $FF then
          begin
            if (Seg = $C0) or (Seg = $C1) then
            begin
              ReadLen := f.Read(dummy, 3); { don't need these bytes }
              f.Read(wHeight, 2);
              wHeight := Swap(wHeight);
              f.Read(wWidth, 2);
              wWidth := Swap(wWidth);
            end
            else
            begin
              if not(Seg in Parameterless) then
              begin
                f.Read(Len, 2);
                Len := Swap(Len);
                f.Seek(Len - 2, 1);
                f.Read(Seg, 1);
              end
              else
                Seg := $FF; { Fake it to keep looping. }
            end;
          end;
        end;
      end;
    finally
      f.Free;
    end;
  end;
end;

// ==================================================
initialization

begin
  // for StrToFloatDef -see function DecodeGPS
  GpsFormatSettings.ThousandSeparator := '.';
  GpsFormatSettings.DecimalSeparator := ',';
end;

end.
