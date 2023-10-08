{ unit sdJpegLossless

  Author: Nils Haeck M.Sc.
  Copyright (c) 2007 SimDesign B.V.
  More information: www.simdesign.nl or n.haeck@simdesign.nl

  This software may ONLY be used or replicated in accordance with
  the LICENSE found in this source distribution.
}
unit sdJpegLossless;

interface

uses
  System.Classes, System.SysUtils, sdJpegTypes, sdJpegMarkers;

type

  TsdLosslessAction = (laNoAction, laRotateLeft, laRotateRight, laRotate180, laFlipHor, laFlipVer);

const

  cLosslessActionMsg: array[TsdLosslessAction] of string =
    ('No Action', 'Rotate Left', 'Rotate Right', 'Rotate 180', 'Flip Hor', 'Flip Ver');

type

  TsdLosslessOperation = class(TPersistent)
  private
    FOwner: TObject; // pointer to TsdJpegFormat
    FUpdateMetadata: boolean;
    FBuffer: array of smallint;
    FHasContrastChange: boolean;
    FContrast: double;
    FOnBeforeLossless: TNotifyEvent;
    FOnAfterLossless: TNotifyEvent;
  protected
    procedure DoBeforeLossless;
    procedure DoAfterLossless;
    function GetBlockCoder: TObject;
    function GetIntensityMapCount: integer;
    procedure InfoTranspose;
    procedure MapFlipHorz;
    procedure MapFlipVert;
    procedure MapTranspose;
    procedure MapAdjustDCCoef(AMap: TsdJpegBlockMap; const ABrightness: double);
    procedure MapAdjustDCandACCoef(AMap: TsdJpegBlockMap; const ABrightness, AContrast: double);
    procedure MapCropMcuBlocks(AMap: TsdJpegBlockMap; AMcuX, AMcuY, AMcuWidth, AMcuHeight: integer);
    procedure CoefFlipHorz(var Coef: TsdCoefBlock);
    procedure CoefFlipVert(var Coef: TsdCoefBlock);
    procedure CoefTranspose(var Coef: TsdCoefBlock);
    procedure RemoveDHTMarkers;
  public
    constructor Create(AOwner: TObject); virtual;
    procedure Clear; virtual;
    // Crop the image to the window given with ALeft/ATop/ARight/ABottom. If the
    // left/top coordinates do not fall exactly on a block boundary (multiples of
    // 8 or 16, depending on encoding), then they'll be lowered to fall on the
    // closest boundary. The coordinates are also checked for image size and
    // updated accordingly.
    procedure Crop(var ALeft, ATop, ARight, ABottom: integer);
    // Flip the image horizontally
    procedure FlipHorizontal;
    // Flip the image vertically
    procedure FlipVertical;
    // Rotate the image 90 degrees clockwise
    procedure Rotate90;
    // Rotate the image 180 degrees
    procedure Rotate180;
    // Rotate the image 270 degrees clockwise (aka 90 degrees counter-clockwise)
    procedure Rotate270;
    // Transpose the image: lowerleft corner becomes upperright corner
    procedure Transpose;
    // Touch doesn't actually change the image in any way, it just causes removal
    // of the original huffman encoding tables, so new ones (generally more optimized)
    // will be created when the image is saved.
    procedure Touch;
    // Adjust the brightness of the image. For YCbCr images only the Y component
    // is adjusted. For RGB and CMYK images, the 3 color components are each
    // adjusted. Brightness adjustment only involves the DC coefficient (addition);
    // the AC coefficients are left alone.
    procedure AdjustBrightness(ABrightness: double);
    // Adjust the brightness and contrast of the image. The brightness adjustment
    // only influences the DC coefficients. If AContrast <> 1.0, the AC coefficients
    // are also adjusted (multiplied by AContrast).
    procedure AdjustBrightnessContrast(ABrightness: double; AContrast: double);
    // Set UpdateMetadata to true to force the software to update the metadata. This
    // includes e.g. the Exif rotation flag, JFIF/EXIF width/height, and JFIF thumbnail
    // (not implemented at this moment).
    property UpdateMetadata: boolean read FUpdateMetadata write FUpdateMetadata;
    // connect to this event to process code before a lossless operation
    property OnBeforeLossless: TNotifyEvent read FOnBeforeLossless write FOnBeforeLossless;
    // connect to this event to process code after a lossless operation
    property OnAfterLossless: TNotifyEvent read FOnAfterLossless write FOnAfterLossless;
  end;

implementation

uses
  sdJpegImage, sdJpegCoder, sdDebug;

{ TsdLosslessOperation }

procedure TsdLosslessOperation.AdjustBrightness(ABrightness: double);
var
  i, MapCount: integer;
  Coder: TsdJpegBlockCoder;
  Map: TsdJpegBlockMap;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  if FHasContrastChange then
  begin
    AdjustBrightnessContrast(ABrightness, FContrast);
    exit;
  end;
  MapCount := GetIntensityMapCount;
  Coder := TsdJpegBlockCoder(GetBlockCoder);
  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;
  // Multiply the brightness adjustment by 8 (since the coefficient for DC is
  // a factor 8 too high)
  ABrightness := ABrightness * 8;
  for i := 0 to MapCount - 1 do
  begin
    Map := Coder.Maps[i];
    if Map.TotalBlockCount <= 0 then
      continue;
    MapAdjustDCCoef(Map, ABrightness);
  end;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.AdjustBrightnessContrast(ABrightness, AContrast: double);
var
  i, MapCount: integer;
  Coder: TsdJpegBlockCoder;
  Map: TsdJpegBlockMap;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  FHasContrastChange := True;
  FContrast := AContrast;
  MapCount := GetIntensityMapCount;
  Coder := TsdJpegBlockCoder(GetBlockCoder);
  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;
  // Multiply the brightness adjustment by 8 (since the coefficient for DC is
  // a factor 8 too high)
  ABrightness := ABrightness * 8;
  for i := 0 to MapCount - 1 do
  begin
    Map := Coder.Maps[i];
    if Map.TotalBlockCount <= 0 then
      continue;
    MapAdjustDCandACCoef(Map, ABrightness, AContrast);
  end;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.Clear;
begin
  FHasContrastChange := False;
end;

procedure TsdLosslessOperation.CoefFlipHorz(var Coef: TsdCoefBlock);
var
  i, Idx: integer;
begin
  // Invert all odd indices
  for i := 0 to 31 do
  begin
    Idx := i * 2 + 1;
    Coef[Idx] := -Coef[Idx];
  end;
end;

procedure TsdLosslessOperation.CoefFlipVert(var Coef: TsdCoefBlock);
var
  y, row, i: integer;
begin
  // invert all odd rows
  for y := 0 to 3 do
  begin
    Row := (y * 2 + 1) * 8;
    for i := Row to Row + 7 do
      Coef[i] := -Coef[i];
  end;
end;

procedure TsdLosslessOperation.CoefTranspose(var Coef: TsdCoefBlock);
var
  x, y, i, j: integer;
  Temp: smallint;
begin
  // transpose indices
  for y := 0 to 6 do
    for x := y + 1 to 7 do
    begin
      i := x + y * 8;
      j := x * 8 + y;
      Temp := Coef[i];
      Coef[i] := Coef[j];
      Coef[j] := Temp;
    end;
end;

constructor TsdLosslessOperation.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := TComponent(AOwner);
end;

procedure TsdLosslessOperation.Crop(var ALeft, ATop, ARight, ABottom: integer);
var
  i: integer;
  Coder: TsdJpegBlockCoder;
  Info: TsdJpegInfo;
  L, T, W, H: integer;
  Map: TsdJpegBlockMap;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  Coder := TsdJpegBlockCoder(GetBlockCoder);

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;
  Info := TsdJpegImage(FOwner).JpegInfo;
  if ALeft < 0 then
    ALeft := 0;
  if ATop < 0 then
    ATop := 0;
  if ARight > Info.FWidth then
    ARight := Info.FWidth;
  if ABottom > Info.FHeight then
    ABottom := Info.FHeight;
  L := (ALeft div Info.FMcuWidth);
  T := (ATop div Info.FMcuHeight);
  ALeft := L * Info.FMcuWidth;
  ATop := T * Info.FMcuHeight;

  // Determine number of mcu blocks to copy
  W := (ARight - ALeft + Info.FMcuWidth - 1) div Info.FMcuWidth;
  H := (ABottom - ATop + Info.FMcuHeight - 1) div Info.FMcuHeight;
  if (W <= 0) or (H <= 0) then
    exit;

  // Update Info
  Info.FHorzMcuCount := W;
  Info.FVertMcuCount := H;
  Info.FWidth := ARight - ALeft;
  Info.FHeight := ABottom - ATop;

  // Crop each map
  for i := 0 to Info.FFrameCount - 1 do
  begin
    Map := Coder.Maps[i];
    if not assigned(Map) then continue;
    MapCropMcuBlocks(Map, L, T, W, H);
  end;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.DoBeforeLossless;
begin
  if assigned(FOnBeforeLossless) then
    FOnBeforeLossless(Self);
end;

procedure TsdLosslessOperation.DoAfterLossless;
begin
  if assigned(FOnAfterLossless) then
    FOnAfterLossless(Self);
end;

procedure TsdLosslessOperation.FlipHorizontal;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  MapFlipHorz;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.FlipVertical;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  MapFlipVert;
  DoAfterLossless;
end;

function TsdLosslessOperation.GetBlockCoder: TObject;
var
  FCoder: TsdJpegCoder;
begin
  Result := nil;
  if not (FOwner is TsdJpegImage) then
    exit;
  FCoder := TsdJpegImage(FOwner).Coder;
  if not (FCoder is TsdJpegBlockCoder) or not FCoder.HasCoefficients then
  begin
    DoDebugOut(Self, wsFail, sNoDCTCoefficentsAvailable);
    exit;
  end;
  if FCoder.Scale <> jsFull then
  begin
    DoDebugOut(Self, wsFail, sOperationOnlyFor8x8);
    exit;
  end;
  Result := TsdJpegBlockCoder(FCoder);
end;

function TsdLosslessOperation.GetIntensityMapCount: integer;
var
  Space: TsdJpegColorSpace;
begin
  Result := 1;
  Space := TsdJpegImage(FOwner).DetectInternalColorSpace;
  case Space of
  jcRGB, jcRGBA, jcCMYK:
    Result := 3;
  end;
end;

procedure TsdLosslessOperation.InfoTranspose;
var
  i: integer;
  Info: TsdJpegInfo;
  Temp: integer;
begin
  // Transpose parameters contained in info
  // we cannot create a global swap func since these are properties
  Info := TsdJpegImage(FOwner).JpegInfo;

  // Swap width/height
  Temp := Info.FWidth;
  Info.FWidth := Info.FHeight;
  Info.FHeight := Temp;

  // Swap horz/vert sampling
  Temp := Info.FHorzSamplingMax;
  Info.FHorzSamplingMax := Info.FVertSamplingMax;
  Info.FVertSamplingMax := Temp;

  // swap mcuwidth/height
  Temp := Info.FMcuWidth;
  Info.FMcuWidth := Info.FMcuHeight;
  Info.FMcuHeight := Temp;

  // Make sure to match the restart interval (if any) to new horz mcu count
  if Info.FRestartInterval = Info.FHorzMcuCount then
    Info.FRestartInterval := Info.FVertMcuCount;
// the "else" should not be used! Can also be 0!
{  else
    Info.RestartInterval := Info.HorzMcuCount;}

  // swap horz/vert mcu count
  Temp := Info.FHorzMcuCount;
  Info.FHorzMcuCount := Info.FVertMcuCount;
  Info.FVertMcuCount := Temp;

  // We must also transpose quantization tables, since some software writes
  // non-axisymmetric quant tables
  for i := 0 to Info.FQuantizationTables.Count - 1 do
    Info.FQuantizationTables[i].Transpose;
end;

procedure TsdLosslessOperation.MapAdjustDCandACCoef(AMap: TsdJpegBlockMap;
  const ABrightness, AContrast: double);
var
  i, j, Quant: integer;
  Table: TsdQuantizationTable;
  PSrc, PDst: PsdCoefBlock;
begin
  // Make a backup of the coefficients
  if not AMap.HasCoefBackup then
    AMap.MakeCoefBackup;

  // Quantization table
  Table := TsdJpegImage(FOwner).JpegInfo.FQuantizationTables[AMap.Frame.FQTable];
  Quant := Table.FQuant[0];

  // First value is DC value
  PSrc := AMap.FirstCoefBackup;
  PDst := AMap.FirstCoef;
  for i := 0 to AMap.TotalBlockCount - 1 do
  begin
    // Adjust DC
    PDst[0] := round((PSrc[0] * Quant * AContrast + ABrightness) / Quant);
    // Adjust AC
    for j := 1 to 63 do
    begin
      if PSrc[j] = 0 then continue;
      PDst[j] := round(PSrc[j] * AContrast);
    end;
    inc(PSrc);
    inc(PDst);
  end;
end;

procedure TsdLosslessOperation.MapAdjustDCCoef(AMap: TsdJpegBlockMap; const ABrightness: double);
var
  i, Quant: integer;
  Table: TsdQuantizationTable;
  PSrc, PDst: PsdCoefBlock;
begin
  // Make a backup of the coefficients
  if not AMap.HasCoefBackup then
    AMap.MakeCoefBackup;

  // Quantization table
  Table := TsdJpegImage(FOwner).JpegInfo.FQuantizationTables[AMap.Frame.FQTable];
  Quant := Table.FQuant[0];

  // First value is DC value
  PSrc := AMap.FirstCoefBackup;
  PDst := AMap.FirstCoef;
  for i := 0 to AMap.TotalBlockCount - 1 do
  begin
    PDst[0] := round((PSrc[0] * Quant + ABrightness) / Quant);
    inc(PSrc);
    inc(PDst);
  end;
end;

procedure TsdLosslessOperation.MapCropMcuBlocks(AMap: TsdJpegBlockMap;
  AMcuX, AMcuY, AMcuWidth, AMcuHeight: integer);
var
  Frame: TsdFrameComponent;
  X, Y, W, H, Row: integer;
  PSrc, PDst, PFirst: PsdCoefBlock;
begin
  Frame := AMap.Frame;
  X := AMcuX * Frame.FHorzSampling;
  Y := AMcuY * Frame.FVertSampling;
  W := AMcuWidth * Frame.FHorzSampling;
  H := AMcuHeight * Frame.FVertSampling;
  PFirst := AMap.FirstCoef;

  // Copy the rows
  for Row := 0 to H - 1 do
  begin
    PDst := PFirst;
    inc(PDst, Row * W);
    PSrc := AMap.GetCoefPointer(X, Y + Row);
    Move(PSrc^, PDst^, W * AMap.BlockStride * SizeOf(smallint));
  end;

  // Now set the new size
  AMap.Resize(W, H);
end;

procedure TsdLosslessOperation.MapFlipHorz;
var
  x, y, i: integer;
  Coder: TsdJpegBlockCoder;
  Info: TsdJpegInfo;
  Map: TsdJpegBlockMap;
  PCoef, PBuf, PNew: PsdCoefBlock;
begin
  Coder := TsdJpegBlockCoder(GetBlockCoder);
  if not assigned(Coder) then
    exit;
  Info := TsdJpegImage(FOwner).JpegInfo;

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;

  // Process each map
  for i := 0 to Info.FFrameCount - 1 do
  begin
    Map := Coder.Maps[i];
    if Map.TotalBlockCount <= 0 then
      continue;
    Map.ClearCoefBackup;
    SetLength(FBuffer, Map.ScanStride);
    PBuf := @FBuffer[0];
    for y := 0 to Map.VertBlockCount - 1 do
    begin
      for x := 0 to Map.HorzBlockCount - 1 do
      begin
        PCoef := Map.GetCoefPointer(x, y);
        CoefFlipHorz(PCoef^);

        // copy to the buffer, inverted
        PNew := PBuf;
        inc(PNew, Map.HorzBlockCount - x - 1);
        Move(PCoef^, PNew^, Map.BlockStride * SizeOf(smallint));
      end;
      // Now we copy the buffer back
      Move(PBuf^, Map.GetCoefPointer(0, y)^, Map.ScanStride * SizeOf(smallint));
    end;
  end;
end;

procedure TsdLosslessOperation.MapFlipVert;
var
  y, i, j: integer;
  Coder: TsdJpegBlockCoder;
  Info: TsdJpegInfo;
  Map: TsdJpegBlockMap;
  PCoef, PBuf, PNew: PsdCoefBlock;
begin
  Coder := TsdJpegBlockCoder(GetBlockCoder);
  if not assigned(Coder) then
    exit;
  Info := TsdJpegImage(FOwner).JpegInfo;

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;

  // Process each map
  for i := 0 to Info.FFrameCount - 1 do
  begin
    Map := Coder.Maps[i];
    if Map.TotalBlockCount <= 0 then continue;
    Map.ClearCoefBackup;
    SetLength(FBuffer, Map.ScanStride);
    PBuf := @FBuffer[0];

    // First flip all the blocks vertically
    PCoef := Map.GetCoefPointer(0, 0);
    for j := 0 to Map.TotalBlockCount - 1 do
    begin
      CoefFlipVert(PCoef^);
      inc(PCoef);
    end;

    // exchange scanlines
    for y := 0 to Map.VertBlockCount div 2 - 1 do
    begin
      PCoef := Map.GetCoefPointer(0, y);
      PNew := Map.GetCoefPointer(0, Map.VertBlockCount - y - 1);
      // Coef -> Buf
      Move(PCoef^, PBuf^, Map.ScanStride * SizeOf(smallint));
      // New -> Coef
      Move(PNew^, PCoef^, Map.ScanStride * SizeOf(smallint));
      // Buf -> New
      Move(PBuf^, PNew^, Map.ScanStride * SizeOf(smallint));
    end;
  end;
end;

procedure TsdLosslessOperation.MapTranspose;
var
  x, y, i, j, Temp: integer;
  CoefCount: integer;
  Coder: TsdJpegBlockCoder;
  Info: TsdJpegInfo;
  Map: TsdJpegBlockMap;
  PCoef, PBuf, PNew: PsdCoefBlock;
  Frame: TsdFrameComponent;
begin
  Coder := TsdJpegBlockCoder(GetBlockCoder);
  if not assigned(Coder) then
    exit;
  Info := TsdJpegImage(FOwner).JpegInfo;

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;

  // Process each map
  for i := 0 to Info.FFrameCount - 1 do
  begin
    Map := Coder.Maps[i];
    Map.ClearCoefBackup;
    if Map.TotalBlockCount <= 0 then
      continue;

    CoefCount := Map.ScanStride * Map.VertBlockCount;
    SetLength(FBuffer, CoefCount);
    PBuf := @FBuffer[0];

    // First transpose all the blocks
    PCoef := Map.GetCoefPointer(0, 0);
    for j := 0 to Map.TotalBlockCount - 1 do
    begin
      CoefTranspose(PCoef^);
      inc(PCoef);
    end;

    // Copy map coefficients to buffer
    Move(Map.FirstCoef^, PBuf^, CoefCount * SizeOf(smallint));

    // Transpose map and its frame info
    Map.Resize(Map.VertBlockCount, Map.HorzBlockCount);
    Frame := Map.Frame;
    Temp := Frame.FHorzSampling;
    Frame.FHorzSampling := Frame.FVertSampling;
    Frame.FVertSampling := Temp;

    // copy blocks back in transposed way
    PNew := PBuf;
    for x := 0 to Map.HorzBlockCount - 1 do
      for y := 0 to Map.VertBlockCount - 1 do
      begin
        Move(PNew^, Map.GetCoefPointer(x, y)^, 64 * SizeOf(smallint));
        inc(PNew);
      end;
  end;
end;

procedure TsdLosslessOperation.RemoveDHTMarkers;
var
  Info: TsdJpegInfo;
begin
  // When encoding later, the current Huffman tables might not be complete, so
  // we remove them so they are regenerated.
  TsdJpegImage(FOwner).Markers.RemoveMarkers([mkDHT]);
  Info := TsdJpegImage(FOwner).JpegInfo;
  Info.FDCHuffmanTables.Clear;
  Info.FACHuffmanTables.Clear;
end;

procedure TsdLosslessOperation.Rotate180;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  MapFlipHorz;
  MapFlipVert;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.Rotate270;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  InfoTranspose;
  MapTranspose;
  MapFlipVert;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.Rotate90;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  InfoTranspose;
  MapTranspose;
  MapFlipHorz;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.Touch;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  DoAfterLossless;
end;

procedure TsdLosslessOperation.Transpose;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  // Transpose parameters contained in info
  InfoTranspose;
  // Transpose maps
  MapTranspose;
  DoAfterLossless;
end;

end.
