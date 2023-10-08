{ sdJpegCoder

  Author: Nils Haeck M.Sc.

  Copyright (c) 2007 SimDesign B.V.
  More information: www.simdesign.nl or n.haeck@simdesign.nl

  This software may ONLY be used or replicated in accordance with
  the LICENSE found in this source distribution.

}
unit sdJpegCoder;

interface

uses
  System.Classes, System.Contnrs, System.SysUtils,
  sdJpegTypes, sdJpegBitstream, sdJpegHuffman, sdJpegMarkers,
  sdMapIterator;

type

  // entropy coding classes for NativeJpg

  // Generic coder class. This is the base class for special coders, like
  // TsdJpegBaselineCoder and TsdJpegProgressiveCoder.
  TsdJpegCoder = class(TPersistent)
  protected
    FInfo: TsdJpegInfo; // reference to jpeg coding info
    FMethod: TsdJpegDCTCodingMethod; // fast or accurate
    FHasCoefficients: boolean;
    FHasSamples: boolean;
    FScale: TsdJpegScale;
    FTileMode: boolean;
  public
    constructor Create(AOwner: TComponent; AInfo: TsdJpegInfo); virtual;
    procedure Clear; virtual;
    procedure Initialize(AScale: TsdJpegScale); virtual;
    procedure Encode(S: TStream; Iteration: cardinal); virtual; abstract;
    procedure Decode(S: TStream; Iteration: cardinal); virtual; abstract;
    procedure DecodeBlock(S: TStream; XStart, YStart, XCount, YCount: integer); virtual; abstract;
    procedure Finalize; virtual;
    procedure ForwardDCT; virtual; abstract;
    procedure InverseDCT; virtual; abstract;
    function CreateDHTMarker: TsdDHTMarker; virtual;
    property Method: TsdJpegDCTCodingMethod read FMethod write FMethod;
    property HasCoefficients: boolean read FHasCoefficients write FHasCoefficients;
    property HasSamples: boolean read FHasSamples write FHasSamples;
    property Scale: TsdJpegScale read FScale;
    property TileMode: boolean read FTileMode write FTileMode;
  end;

  // Common ancestor for blockbased jpeg codecs like baseline and progressive. It
  // contains a list of blockmaps, which contain DCT coefficients and raw samples
  // for each frame component in the image. We do not reuse the coefficient memory
  // for the samples, so we can still do operations on the coefficients after
  // doing the IDCT.
  TsdJpegBlockCoder = class(TsdJpegCoder)
  private
    FMaps: TsdBlockMapList;
    FBuffer: array of byte;
    FBufferCellStride: integer;
    FBufferScanStride: integer;
  protected
    FBlockStride: integer;
    procedure CorrectBlockStride;
    function BlockstrideForScale(AScale: TsdJpegScale): integer; virtual;
    procedure GetBlockstrideParams(ABlockstride: integer;
      var ABlockWidth, AMcuWidth, AMcuHeight: integer);
    procedure McuRowFromBuffer(McuY: integer; ABlockWidth: integer);
    procedure McuRowToBuffer(McuY: integer; ABlockWidth: integer);
    procedure SetupMaps(SpecialSize: boolean; AHorzMcuCount, AVertMcuCount: integer);
  public
    constructor Create(AOwner: TComponent; AInfo: TsdJpegInfo); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure ForwardDCT; override;
    procedure InverseDCT; override;
    property Maps: TsdBlockMapList read FMaps;
    property BlockStride: integer read FBlockStride;
  end;

  // The Jpeg Baseline coder implements the baseline huffman DC and AC decoding
  // and encoding
  TsdJpegBaselineCoder = class(TsdJpegBlockCoder)
  private
  protected
    FDCCoders: TsdEntropyCoderList;
    FACCoders: TsdEntropyCoderList;
    FMcu: array of TsdMcuBlock;
    FMcuBlockCount: integer;
    FBitReader: TsdBitReader;
    FBitWriter: TsdBitWriter;
    FMcuIndex: integer;
    FHorzMcuCount, FVertMcuCount: integer;
    FRstIndex: integer;
    FZigZag: PsdZigZagArray;
    FIsDryRun: boolean;
    FTiles: TsdJpegTileList;
    procedure DoMcuBlockCount;
    procedure InitializeDecoderTables; virtual;
    procedure InitializeEncoderTables; virtual;
    procedure DecodeMcu(AMcuX, AMcuY: integer; Skip: boolean); virtual;
    procedure EncodeMcu(AMcuX, AMcuY: integer); virtual;
    procedure ResetDecoder;
    procedure ResetEncoder;
    procedure HandleEndOfStreamError(S: TStream); virtual;
    procedure HandleRestartInterval(S: TStream; Warn: boolean); virtual;
    procedure HandleHitMarkerError(S: TStream); virtual;
    function HandleDNLMarker(AMcuY: integer; S: TStream): boolean; virtual;
    procedure ResizeVerticalMcu(NewVertMcuCount: integer); virtual;
  public
    constructor Create(AOwner: TComponent; AInfo: TsdJpegInfo); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Initialize(AScale: TsdJpegScale); override;
    procedure Decode(S: TStream; Iteration: cardinal); override;
    procedure DecodeBlock(S: TStream; XStart, YStart, XCount, YCount: integer); override;
    procedure Encode(S: TStream; Iteration: cardinal); override;
    procedure EncodeStripStart(S: TStream);
    procedure EncodeStrip(S: TStream);
    procedure EncodeStripClose;
    function CreateDHTMarker: TsdDHTMarker; override;
  end;

  TsdJpegProgressiveCoder = class(TsdJpegBaselineCoder)
  private
    FEOBRun: integer;
    FIsDCBand: boolean;
    FIsFirst: boolean;
  protected
    procedure DecodeMcu(AMcuX, AMcuY: integer; Skip: boolean); override;
    procedure InitializeDecoderTables; override;
    function BlockstrideForScale(AScale: TsdJpegScale): integer; override;
    procedure HandleRestartInterval(S: TStream; Warn: boolean); override;
  public
    procedure Decode(S: TStream; Iteration: cardinal); override;
    procedure Finalize; override;
  end;

  // Same as baseline coder
  TsdJpegExtendedCoder = class(TsdJpegBaselineCoder)
  end;

implementation

uses
  sdDebug, sdJpegDCT;

{ TsdJpegCoder }

procedure TsdJpegCoder.Clear;
begin
  FHasCoefficients := False;
  FHasSamples := False;
  FScale := jsFull;
end;

constructor TsdJpegCoder.Create(AOwner: TComponent; AInfo: TsdJpegInfo);
begin
  inherited Create;
//  FOwner := AOwner;
  FInfo := AInfo;
end;

function TsdJpegCoder.CreateDHTMarker: TsdDHTMarker;
begin
  Result := nil;
end;

procedure TsdJpegCoder.Finalize;
begin
// default does nothing
end;

procedure TsdJpegCoder.Initialize(AScale: TsdJpegScale);
begin
  FScale := AScale;
end;

{ TsdJpegBlockCoder }

function TsdJpegBlockCoder.BlockstrideForScale(AScale: TsdJpegScale): integer;
begin
  case AScale of
  jsFull: Result := 64;
  jsDiv2: Result := 16;
  jsDiv4: Result := 4;
  jsDiv8: Result := 1;
  else
    Result := 0;
  end;
end;

procedure TsdJpegBlockCoder.Clear;
var
  i: integer;
begin
  inherited;
  // We only clear the backup coefficents, not the data itself, so that any new
  // SetSize may reuse already allocated memory
  for i := 0 to Maps.Count - 1 do
    Maps[i].ClearCoefBackup;
end;

procedure TsdJpegBlockCoder.CorrectBlockStride;
var
  i, NewSize: integer;
begin
  if (FBlockStride = 64) and (FScale <> jsFull) then
  begin
    // We must reduce the map blockstrides first
    NewSize := 0;
    case FScale of
    jsDiv2: NewSize := 4;
    jsDiv4: NewSize := 2;
    jsDiv8: NewSize := 1;
    end;
    for i := 0 to FMaps.Count - 1 do
      FMaps[i].ReduceBlockSize(NewSize);
    FBlockStride := NewSize * NewSize;
  end;
end;

constructor TsdJpegBlockCoder.Create(AOwner: TComponent; AInfo: TsdJpegInfo);
begin
  inherited;
  FMaps := TsdBlockMapList.Create;
end;

destructor TsdJpegBlockCoder.Destroy;
begin
  FreeAndNil(FMaps);
  inherited;
end;

procedure TsdJpegBlockCoder.ForwardDCT;
var
  i: integer;
  FDCT: TsdJpegFDCT;
begin
  FDCT := TsdJpegFDCT.Create;
  try
    for i := 0 to FInfo.FFrameCount - 1 do
    begin
      FDCT.Map := FMaps[i];
      FDCT.PerformFDCT(FInfo.FQuantizationTables[FInfo.FFrames[i].FQTable]);
    end;
  finally
    FDCT.Free;
  end;
end;

procedure TsdJpegBlockCoder.GetBlockstrideParams(ABlockstride: integer;
  var ABlockWidth, AMcuWidth, AMcuHeight: integer);
begin
  case ABlockStride of
  64:
    begin
      ABlockWidth := 8;
      AMcuWidth := FInfo.FMcuWidth;
      AMcuHeight := FInfo.FMcuHeight;
    end;
  16:
    begin
      ABlockWidth := 4;
      AMcuWidth := FInfo.FMcuWidth div 2;
      AMcuHeight := FInfo.FMcuHeight div 2;
    end;
   4:
    begin
      ABlockWidth := 2;
      AMcuWidth := FInfo.FMcuWidth div 4;
      AMcuHeight := FInfo.FMcuHeight div 4;
    end;
   1:
    begin
      ABlockWidth := 1;
      AMcuWidth := FInfo.FMcuWidth div 8;
      AMcuHeight := FInfo.FMcuHeight div 8;
    end;
  else
    ABlockWidth := 0; // avoid warnings
    AMcuWidth := 0;
    AMcuHeight := 0;
  end;
end;

procedure TsdJpegBlockCoder.InverseDCT;
var
  i: integer;
  IDCT: TsdJpegIDCT;
begin
  IDCT := TsdJpegIDCT.Create;
  try
    IDCT.Method := FMethod;
    for i := 0 to FInfo.FFrameCount - 1 do
    begin
      IDCT.Map := FMaps[i];
      IDCT.BuildQuantTableFrom(FInfo.FQuantizationTables[FInfo.FFrames[i].FQTable]);
      IDCT.PerformIDCT;
    end;
  finally
    IDCT.Free;
  end;
end;

procedure TsdJpegBlockCoder.McuRowFromBuffer(McuY, ABlockWidth: integer);
var
  i, j, row, col, xblock, yblock, yi, m, V: integer;
  XRepeat, YRepeat, XYArea: integer;
  PixBlockStride: integer;
  Map: TsdJpegBlockMap;
  Frame: TsdFrameComponent;
  PFirst, PScan, PBlock, PPixel, PCopy, PValue: Pbyte;
begin
  PFirst := @FBuffer[0];
  // Loop through all maps
  for m := 0 to FInfo.FFrameCount - 1 do
  begin
    // Process Map
    Map := FMaps[m];
    Frame := FInfo.FFrames[m];
    PScan := PFirst;
    XRepeat := FInfo.FHorzSamplingMax div Frame.FHorzSampling;
    YRepeat := FInfo.FVertSamplingMax div Frame.FVertSampling;
    XYArea := XRepeat * YRepeat;
    PixBlockStride := ABlockWidth * XRepeat * FBufferCellStride;
    // We process VertSampling rows
    for yi := 0 to Frame.FVertSampling - 1 do
    begin
      // y is the block row-index into the map
      yblock := McuY * Frame.FVertSampling + yi;
      // Reset the block pointer to the start of the scanline
      PBlock := PScan;
      // We process a row of DCT blocks
      for xblock := 0 to Map.HorzBlockCount - 1 do
      begin
        // Pointer to the samples in this block
        PValue := Map.GetSamplePointer(xblock, yblock);
        // Reset the pixel pointer to the start of the block
        PPixel := PBlock;
        // Rows of block
        for row := 0 to ABlockWidth - 1 do
        begin
          // Check for optimized version
          if (XRepeat = 1) and (YRepeat = 1) then
          begin
            // Optimized version for no repeats
            // Columns of block
            for col := 0 to ABlockWidth - 1 do
            begin
              // Copy pixel to value
              PValue^ := PPixel^;
              inc(PPixel, FBufferCellStride);
              inc(PValue);
            end;
          end else
          begin
            // Repeats in at least one direction
            for col := 0 to ABlockWidth - 1 do
            begin
              // Copy pixel(s) to value and average
              V := 0;
              for i := 0 to XRepeat - 1 do
              begin
                inc(V, PPixel^);
                // vertical repeats?
                PCopy := PPixel;
                for j := 1 to YRepeat - 1 do
                begin
                  inc(PCopy, FBufferScanStride);
                  inc(V, PCopy^);
                end;
                inc(PPixel, FBufferCellStride);
              end;
              PValue^ := V div XYArea;
              inc(PValue);
            end;
          end;
          // Go to the next row in the block. Since we ran through the row, we
          // must also undo the blockstride
          inc(PPixel, FBufferScanStride * YRepeat - PixBlockStride);
        end;
        //
        inc(PBlock, PixBlockStride);
      end;
      inc(PScan, FBufferScanStride * ABlockWidth * YRepeat);
    end;
    inc(PFirst);
  end;
end;

procedure TsdJpegBlockCoder.McuRowToBuffer(McuY: integer; ABlockWidth: integer);
var
  i, j, row, col, xblock, yblock, yi, m: integer;
  XRepeat, YRepeat: integer;
  PixBlockStride: integer;
  Map: TsdJpegBlockMap;
  Frame: TsdFrameComponent;
  PFirst, PScan, PBlock, PPixel, PCopy, PValue: Pbyte;
begin
  PFirst := @FBuffer[0];
  // Loop through all maps
  for m := 0 to FInfo.FFrameCount - 1 do
  begin
    // Process Map
    Map := FMaps[m];
    Frame := FInfo.FFrames[m];
    PScan := PFirst;
    XRepeat := FInfo.FHorzSamplingMax div Frame.FHorzSampling;
    YRepeat := FInfo.FVertSamplingMax div Frame.FVertSampling;
    PixBlockStride := ABlockWidth * XRepeat * FBufferCellStride;
    // We process VertSampling rows
    for yi := 0 to Frame.FVertSampling - 1 do
    begin
      // y is the block row-index into the map
      yblock := McuY * Frame.FVertSampling + yi;
      // Reset the block pointer to the start of the scanline
      PBlock := PScan;
      // We process a row of DCT blocks
      for xblock := 0 to Map.HorzBlockCount - 1 do
      begin
        // Pointer to the samples in this block
        PValue := Map.GetSamplePointer(xblock, yblock);
        // Reset the pixel pointer to the start of the block
        PPixel := PBlock;
        // Rows of block
        for row := 0 to ABlockWidth - 1 do
        begin
          // Check for optimized version
          if (XRepeat = 1) and (YRepeat = 1) then
          begin
            // Optimized version for no repeats
            // Columns of block
            for col := 0 to ABlockWidth - 1 do
            begin
              // Copy value to pixel
              PPixel^ := PValue^;
              inc(PPixel, FBufferCellStride);
              inc(PValue);
            end;
          end else
          begin
            // Repeats in at least one direction
            for col := 0 to ABlockWidth - 1 do
            begin
              // Copy value to pixel(s)
              for i := 0 to XRepeat - 1 do
              begin
                PPixel^ := PValue^;
                // vertical repeats?
                PCopy := PPixel;
                for j := 1 to YRepeat - 1 do
                begin
                  inc(PCopy, FBufferScanStride);
                  PCopy^ := PValue^;
                end;
                inc(PPixel, FBufferCellStride);
              end;
              inc(PValue);
            end;
          end;
          // Go to the next row in the block. Since we ran through the row, we
          // must also undo the blockstride
          inc(PPixel, FBufferScanStride * YRepeat - PixBlockStride);
        end;
        //
        inc(PBlock, PixBlockStride);
      end;
      inc(PScan, FBufferScanStride * ABlockWidth * YRepeat);
    end;
    inc(PFirst);
  end;
end;

procedure TsdJpegBlockCoder.SetupMaps(SpecialSize: boolean; AHorzMcuCount, AVertMcuCount: integer);
var
  i, HorzSampling, VertSampling: integer;
begin
  // Calculate Hmax, Vmax
  FInfo.FHorzSamplingMax := 0;
  FInfo.FVertSamplingMax := 0;
  for i := 0 to FInfo.FFrameCount - 1 do
  begin
    HorzSampling := FInfo.FFrames[i].FHorzSampling;
    if HorzSampling >= Finfo.FHorzSamplingMax then
      FInfo.FHorzSamplingMax := HorzSampling;
    VertSampling := FInfo.FFrames[i].FVertSampling;
    if VertSampling >= Finfo.FVertSamplingMax then
      FInfo.FVertSamplingMax := VertSampling;
  end;

  // MCU size in pixels
  FInfo.FMcuWidth := FInfo.FHorzSamplingMax * 8;
  FInfo.FMcuHeight := FInfo.FVertSamplingMax * 8;

  // MCU count
  FInfo.FHorzMcuCount :=  (FInfo.FWidth  + FInfo.FMcuWidth  - 1) div FInfo.FMcuWidth;
  FInfo.FVertMcuCount :=  (FInfo.FHeight + FInfo.FMcuHeight - 1) div FInfo.FMcuHeight;

  // create maps with given counts
  if SpecialSize then
    for i := 0 to FInfo.FFrameCount - 1 do
      FMaps[i].SetSize(AHorzMcuCount, AVertMcuCount, FInfo.FFrames[i], FBlockStride)
  else
  begin
    for i := 0 to FInfo.FFrameCount - 1 do
      FMaps[i].SetSize(FInfo.FHorzMcuCount, FInfo.FVertMcuCount, FInfo.FFrames[i], FBlockStride);
  end;

end;

{ TsdJpegBaselineCoder }

procedure TsdJpegBaselineCoder.Clear;
begin
  inherited;
  FDCCoders.Clear;
  FACCoders.Clear;
  FTiles.Clear;
end;

constructor TsdJpegBaselineCoder.Create(AOwner: TComponent; AInfo: TsdJpegInfo);
begin
  inherited;
  FDCCoders := TsdEntropyCoderList.Create;
  FACCoders := TsdEntropyCoderList.Create;
  FTiles := TsdJpegTileList.Create;
end;

function TsdJpegBaselineCoder.CreateDHTMarker: TsdDHTMarker;
var
  i: integer;
  C: Tsd8bitHuffmanEncoder;
  Item: PsdDHTMarkerInfo;
  ItemCount: integer;
begin
  Result := TsdDHTMarker.Create(FInfo, mkDHT);
  ItemCount := 0;

  // Loop through the DC tables
  for i := 0 to FDCCoders.Count - 1 do
  begin
    C := FDCCoders[i] as Tsd8bitHuffmanEncoder;
    if C is Tsd8bitHuffmanEncoder then
    begin
      SetLength(Result.FMarkerInfo, ItemCount + 1);
      Item := @Result.FMarkerInfo[ItemCount];
      Item.Tc := 0;
      Item.Th := i;
      inc(ItemCount);
      C.OptimiseHuffmanFromHistogram(Item^);
    end;
  end;

  // Loop through the AC tables
  for i := 0 to FACCoders.Count - 1 do
  begin
    C := FACCoders[i] as Tsd8bitHuffmanEncoder;
    if C is Tsd8bitHuffmanEncoder then
    begin
      SetLength(TsdDHTMarker(Result).FMarkerInfo, ItemCount + 1);
      Item := @TsdDHTMarker(Result).FMarkerInfo[ItemCount];
      Item.Tc := 1;
      Item.Th := i;
      inc(ItemCount);
      C.OptimiseHuffmanFromHistogram(Item^);
    end;
  end;
  if ItemCount = 0 then
    FreeAndNil(Result);
end;

procedure TsdJpegBaselineCoder.Decode(S: TStream; Iteration: cardinal);
var
  Tile: TsdJpegTile;
  i: integer;
  McuX, McuY: integer;
begin
  if Iteration = 0 then
  begin
    // reset position
    S.Position := 0;
  end;

  // Count number of blocks in MCU and number of MCU cycles
  DoMcuBlockCount;

  // Initialize the decoder tables for DC and AC in this scan
  InitializeDecoderTables;

  // Initialize bit reader
  if S is TMemoryStream then
    FBitReader := TsdMemoryBitReader.Create(S)
  else
    FBitReader := TsdStreamBitReader.Create(S);
  try

    FTiles.Clear;
    FMcuIndex := 0;
    FRstIndex := 0;
    McuX := 0;
    McuY := 0;
    repeat

      if (McuX = 0) and FInfo.FWaitForDNL then
      begin
        // Check if we have enough size vertically, in case of waiting for DNL marker
        if McuY >= FVertMcuCount then
          // Resize the maps, 16 MCU lines at a time. This 16 is an arbitrary number
          ResizeVerticalMcu(McuY + 16);
      end;

      // Tiled loading? Then we create the tile info for each 8 McuX blocks
      if FTileMode and (McuX mod 8 = 0)then
      begin
        Tile := TsdJpegTile.Create;
        Tile.FMcuIndex := FMcuIndex;
        Tile.FStreamPos := FBitReader.StreamPos;
        Tile.FBits := FBitReader.Bits;
        Tile.FBitsLeft := FBitReader.BitsLeft;
        SetLength(Tile.FPredictors, FInfo.FScans.Count);
        for i := 0 to FInfo.FScans.Count - 1 do
          Tile.FPredictors[i] := FInfo.FScans[i].FPredictor;
        FTiles.Add(Tile);
      end;

      // Decode one MCU, skip if tiled loading is in effect
      DecodeMcu(McuX, McuY, FTileMode);
      inc(FMcuIndex);
      inc(McuX);
      if McuX = FHorzMcuCount then
      begin
        McuX := 0;
        inc(McuY);
        if FInfo.FWaitForDNL then
          if HandleDNLMarker(McuY, S) then
            Break;
      end;

      // Check for errors
      if FBitReader.HitEndOfStream then
      begin
        HandleEndOfStreamError(S);
      end;

      // Check for restart interval
      if (FInfo.FRestartInterval > 0) and (FMcuIndex mod FInfo.FRestartInterval = 0) then
      begin
        HandleRestartInterval(S, True);
      end;

      // Check for markers
      if FBitReader.HitMarkerNoBitsLeft then
      begin
        HandleHitMarkerError(S);
        McuX := FMcuIndex mod FHorzMcuCount;
        McuY := FMcuIndex div FHorzMcuCount;
      end;

    until not FInfo.FWaitForDNL and (McuY = FVertMcuCount);

    // For good measure we add one more tile if in tilemode (without any data though)
    if FTileMode then
    begin
      Tile := TsdJpegTile.Create;
      Tile.FMcuIndex := FMcuIndex;
      FTiles.Add(Tile);
    end;

    ResetDecoder;

  finally
    FreeAndNil(FBitReader);
    FHasCoefficients := True;
    FHasSamples := False;
  end;
end;

procedure TsdJpegBaselineCoder.DecodeBlock(S: TStream; XStart, YStart, XCount, YCount: integer);
var
  x, y, i, Idx, McuIdx: integer;
  Tile: TsdJpegTile;
begin
  // Setup maps with this special count
  SetupMaps(True, XCount, YCount);

  // Initialize bit reader
  if S is TMemoryStream then
    FBitReader := TsdMemoryBitReader.Create(S)
  else
    FBitReader := TsdStreamBitReader.Create(S);
  try

    for y := 0 to YCount - 1 do
    begin
      if y + YStart >= FVertMcuCount then
        break;
      FMcuIndex := (y + YStart) * FHorzMcuCount + XStart;

      // Find tile that has equal or smaller mcuindex
      Idx := FTiles.IndexByMcuIndex(FMcuIndex); // index in tilelist
      if Idx = FTiles.Count then
      begin
        DoDebugOut(Self, wsFail, sRangeErrorInTileLoading);
        exit;
      end;
      if FTiles[Idx].FMcuIndex > FMcuIndex then
        dec(Idx);

      // Position bitreader and reset predictors
      Tile := FTiles[Idx];
      FBitReader.StreamPos := Tile.FStreamPos;
      FBitReader.Bits := Tile.FBits;
      FBitReader.BitsLeft := Tile.FBitsLeft;
      for i := 0 to length(Tile.FPredictors) - 1 do
        FInfo.FScans[i].FPredictor := Tile.FPredictors[i];

      // Skip preceding mcu's
      McuIdx := Tile.FMcuIndex;
      while McuIdx < FMcuIndex do
      begin
        DecodeMcu(0, 0, True);
        inc(McuIdx);
        if (FInfo.FRestartInterval > 0) and (McuIdx mod FInfo.FRestartInterval = 0) then
          HandleRestartInterval(S, False);
      end;

      for x := 0 to XCount - 1 do
      begin
        if x + XStart >= FHorzMcuCount then
          break;
        // Now don't skip
        DecodeMcu(x, y, False);
        inc(FMcuIndex);
        // Check for restart interval
        if (FInfo.FRestartInterval > 0) and (FMcuIndex mod FInfo.FRestartInterval = 0) then
          HandleRestartInterval(S, False);
      end;
    end;

  finally
    FreeAndNil(FBitReader);
    FHasCoefficients := True;
    FHasSamples := False;
  end;
end;

procedure TsdJpegBaselineCoder.DecodeMcu(AMcuX, AMcuY: integer; Skip: boolean);
var
  i: integer;
  McuBlock: PsdMCUBlock;
  Dummy: TsdCoefBlock;
begin
  for i := 0 to FMcuBlockCount - 1 do
  begin
    // The current MCU block
    McuBlock := @FMcu[i];

    // Initialize MCU values pointer
    if Skip then
      McuBlock.Values := @Dummy[0]
    else
      McuBlock.Values := Maps[McuBlock.MapIdx].GetCoefPointerMCU(AMcuX, AMcuY, McuBlock.BlockIdx);

    // Each MCU block has an index to a DC and AC table, use it to do the decoding
    TsdDCBaselineHuffmanDecoder(FDCCoders[McuBlock.DCTable]).DecodeMcuBlock(McuBlock^, FBitReader);
    if (FScale = jsDiv8) or Skip then
      TsdACBaselineHuffmanDecoder(FACCoders[McuBlock.ACTable]).DecodeMcuBlockSkip(FBitReader)
    else
      TsdACBaselineHuffmanDecoder(FACCoders[McuBlock.ACTable]).DecodeMcuBlock(McuBlock^, FBitReader, FZigZag);
    if FBitReader.HitEndOfStream then
      exit;
  end;
end;

destructor TsdJpegBaselineCoder.Destroy;
begin
  FreeAndNil(FDCCoders);
  FreeAndNil(FACCoders);
  FreeAndNil(FTiles);
  inherited;
end;

procedure TsdJpegBaselineCoder.DoMcuBlockCount;
var
  HSize, VSize: integer;
  i: integer;
  Frame: TsdFrameComponent;
begin
  if FInfo.FScanCount = 1 then
  begin
    // Single channel: spec tells there can only be one MCU block
    FMcuBlockCount := 1;
    // calculate # blocks in horz and vert direction
    Frame := FInfo.FFrames[FInfo.FScans[0].FComponent];
    HSize := 8 * FInfo.FHorzSamplingMax div Frame.FHorzSampling;
    VSize := 8 * FInfo.FVertSamplingMax div Frame.FVertSampling;
    FHorzMcuCount := (FInfo.FWidth + HSize - 1) div HSize;
    FVertMcuCount := (FInfo.FHeight + VSize - 1) div VSize;
  end else
  begin
    // Multi channel
    FHorzMcuCount := FInfo.FHorzMcuCount;
    FVertMcuCount := FInfo.FVertMcuCount;
    FMcuBlockCount := 0;
    for i := 0 to FInfo.FScanCount - 1 do
      inc(FMcuBlockCount, Maps[FInfo.FScans[i].FComponent].McuBlockCount(FInfo.FScanCount));
  end;
  SetLength(FMcu, FMcuBlockCount);
end;

procedure TsdJpegBaselineCoder.Encode(S: TStream; Iteration: cardinal);
var
  B: byte;
  McuX, McuY: integer;
begin
  FIsDryRun := (S = nil);

  // Count number of blocks in MCU and number of MCU cycles
  DoMcuBlockCount;

  // Initialize the encoder tables for DC and AC in this scan
  InitializeEncoderTables;

  // Initialize bit reader
  if FIsDryRun then
    FBitWriter := TsdDryRunBitWriter.Create(S)
  else
    FBitWriter := TsdBitWriter.Create(S);
  try

    FMcuIndex := 0;
    FRstIndex := 0;
    McuX := 0;
    McuY := 0;
    repeat

      // Encode one MCU
      EncodeMcu(McuX, McuY);
      inc(FMcuIndex);
      inc(McuX);
      if McuX = FHorzMcuCount then
      begin
        McuX := 0;
        inc(McuY);
      end;

      if McuY = FVertMcuCount then break;

      // Check for restart interval
      if (FInfo.FRestartInterval > 0) and (FMcuIndex mod FInfo.FRestartInterval = 0) then
      begin
        // Restart interval
        ResetEncoder;
        if not FIsDryRun then
        begin
          // write RST
          B := $FF;
          S.Write(B, 1);
          B := (FRstIndex mod 8) + mkRST0;
          S.Write(B, 1);
        end;
        inc(FRstIndex);
      end;

    until (McuY = FVertMcuCount);
    ResetEncoder;

  finally
    FreeAndNil(FBitWriter);
  end;
end;

procedure TsdJpegBaselineCoder.EncodeMcu(AMcuX, AMcuY: integer);
var
  i: integer;
  McuBlock: PsdMCUBlock;
  DC: TsdDCBaselineHuffmanEncoder;
  AC: TsdACBaselineHuffmanEncoder;
begin
  for i := 0 to FMcuBlockCount - 1 do
  begin
    // The current MCU block
    McuBlock := @FMcu[i];
    // Initialize MCU values pointer
    McuBlock.Values := Maps[McuBlock.MapIdx].GetCoefPointerMCU(AMcuX, AMcuY, McuBlock.BlockIdx);
    // Each MCU block has an index to a DC and AC table, use it to do the encoding
    DC := TsdDCBaselineHuffmanEncoder(FDCCoders[McuBlock.DCTable]);
    AC := TsdACBaselineHuffmanEncoder(FACCoders[McuBlock.ACTable]);
    if FIsDryRun then
      TsdDryRunBitWriter(FBitWriter).Histogram := DC.Histogram;
    DC.EncodeMcuBlock(McuBlock^, FBitWriter);
    if FIsDryRun then
      TsdDryRunBitWriter(FBitWriter).Histogram := AC.Histogram;
    AC.EncodeMcuBlock(McuBlock^, FBitWriter);
  end;
end;

procedure TsdJpegBaselineCoder.EncodeStrip(S: TStream);
var
  McuX: integer;
  B: byte;
begin
  McuX := 0;
  repeat

    // Encode one MCU
    EncodeMcu(McuX, 0);
    inc(FMcuIndex);
    inc(McuX);
    if McuX = FHorzMcuCount then
      break;

    // Check for restart interval
    if (FInfo.FRestartInterval > 0) and (FMcuIndex mod FInfo.FRestartInterval = 0) then
    begin
      // Restart interval
      ResetEncoder;
      // write RST
      B := $FF;
      S.Write(B, 1);
      B := (FRstIndex mod 8) + mkRST0;
       S.Write(B, 1);
      inc(FRstIndex);
    end;

  until False;
end;

procedure TsdJpegBaselineCoder.EncodeStripClose;
begin
  ResetEncoder;
  FreeAndNil(FBitWriter);
end;

procedure TsdJpegBaselineCoder.EncodeStripStart(S: TStream);
begin
  // Setup maps to the size of one strip
  SetupMaps(True, FInfo.FHorzMCUCount, 1);

  // Count number of blocks in MCU and number of MCU cycles
  DoMcuBlockCount;

  // Initialize the encoder tables for DC and AC in this scan
  InitializeEncoderTables;

  // Initialize bit writer
  FBitWriter := TsdBitWriter.Create(S);

  FMcuIndex := 0;
  FRstIndex := 0;
end;

function TsdJpegBaselineCoder.HandleDNLMarker(AMcuY: integer; S: TStream): boolean;
var
  ReadBytes: integer;
  B, Tag: byte;
begin
  Result := False;
  if FBitReader.HitMarker then
  begin
    // It should be a DNL marker
    ResetDecoder;
    ReadBytes := S.Read(B, 1);
    if not (ReadBytes = 1) or (B <> $FF) then
    begin
      DoDebugOut(Self, wsFail, sDNLMarkerExpected);
      exit;
    end;
    S.Read(Tag, 1);
    if Tag <> mkDNL then
    begin
      DoDebugOut(Self, wsWarn, sDNLMarkerExpected);
      exit;
    end;
    FInfo.FWaitForDNL := False;
    ResizeVerticalMcu(AMcuY);
    Result := True;
  end;
end;

procedure TsdJpegBaselineCoder.HandleEndOfStreamError(S: TStream);
begin
  // Serious error: there weren't enough bits in the stream
  if FBitReader.HitMarkerNoBitsLeft then
    DoDebugOut(Self, wsFail, Format('Error: Hit Marker $%s', [IntToHex(FBitReader.MarkerTag, 2)]));
  ResetDecoder;
  DoDebugOut(Self, wsFail, Format('Error: Premature stream end at position %d', [S.Position]));
end;

procedure TsdJpegBaselineCoder.HandleHitMarkerError(S: TStream);
begin
  case FBitReader.MarkerTag of
  mkRST0..mkRST7:
    begin
      // We found a restart too early, set McuIndex to the correct value
      DoDebugOut(Self, wsWarn, Format('Restart interval %d (too early)', [FRstIndex]));
      inc(FRstIndex);
      FMcuIndex := FRstIndex * FInfo.FRestartInterval;
      ResetDecoder;
      S.Seek(2, soFromCurrent);
      FBitReader.Reload;
    end;
  end;//case
end;

procedure TsdJpegBaselineCoder.HandleRestartInterval(S: TStream; Warn: boolean);
// Restart interval
var
  SuperfluousCount, ReadBytes: integer;
  B: byte;
  Tag: byte;
begin
  ResetDecoder;
  // find + skip restart
  SuperfluousCount := 0;
  repeat
    ReadBytes := S.Read(B, 1);
    if B = $FF then
    begin
      S.Read(Tag, 1);
      case Tag of
      mkRST0..mkRST7:
        begin
          // Check restart interval
          if Warn then
            if (Tag - mkRST0) <> (FRstIndex mod 8) then
              DoDebugOut(Self, wsWarn, Format('WARNING: Restart interval error (expected: %d, found: %d)',
                [Tag - mkRST0, FRstIndex mod 8]));
          break;
        end;
      mkEOI:
        begin
          S.Seek(-2, soFromCurrent);
          break;
        end;
      else
        // Any other tag is an error
        if Warn then
          DoDebugOut(Self, wsWarn, sUnexpectedMarkerInEncodedStream);
        break;
      end;
    end;
    // If we're here, we had superfluous bytes in the stream
    if ReadBytes > 0 then
      inc(SuperfluousCount);
  until ReadBytes = 0;
  if SuperfluousCount > 0 then
    DoDebugOut(Self, wsWarn, Format('WARNING: %d superfluous bytes found at pos %d', [SuperfluousCount, S.Position - SuperfluousCount]));
  inc(FRstIndex);
  FBitReader.Reload;
end;

procedure TsdJpegBaselineCoder.Initialize(AScale: TsdJpegScale);
begin
  inherited;

  // Determine blockstride
  FBlockStride := BlockStrideForScale(Scale);

  // Setup image maps in frame
  if FTileMode then
    // In tilemode, we create maps with zero size, size will be set later
    SetupMaps(True, 0, 0)
  else
    // otherwise we create maps at full-size
    SetupMaps(False, 0, 0);
end;

procedure TsdJpegBaselineCoder.InitializeDecoderTables;
var
  i, j, Idx: integer;
  Scan: TsdScanComponent;
  DC: TsdDCBaselineHuffmanDecoder;
  AC: TsdACBaselineHuffmanDecoder;
begin
  // Zigzag array that is used
  case BlockStride of
  64: FZigZag := @cJpegInverseZigZag8x8;
  16: FZigZag := @cJpegInverseZigZag4x4;
   4: FZigZag := @cJpegInverseZigZag2x2;
   1: FZigZag := @cJpegInverseZigZag1x1;
  end;

  // Initialize used tables
  FDCCoders.Clear;
  FACCoders.Clear;
  Idx := 0;

  // Loop through image components in scan
  for i := 0 to FInfo.FScanCount - 1 do
  begin
    // Scan's i-th image component info
    Scan := FInfo.FScans[i];
    // Create DC and AC decoders for i-th image
    if not assigned(FDCCoders[Scan.FDCTable])
       and (TsdHuffmanTableList(FInfo.FDCHuffmanTables)[Scan.FDCTable].Count > 0) then
    begin
      DC := TsdDCBaselineHuffmanDecoder.Create;
      FDCCoders[Scan.FDCTable] := DC;
      DC.GenerateLookupTables(TsdHuffmanTableList(FInfo.FDCHuffmanTables)[Scan.FDCTable]);
    end;
    if not assigned(FACCoders[Scan.FACTable])
       and (TsdHuffmanTableList(FInfo.FACHuffmanTables)[Scan.FACTable].Count > 0) then
    begin
      AC := TsdACBaselineHuffmanDecoder.Create;
      FACCoders[Scan.FACTable] := AC;
      AC.GenerateLookupTables(TsdHuffmanTableList(FInfo.FACHuffmanTables)[Scan.FACTable]);
    end;
    // Assign table numbers to MCU blocks
    for j := 0 to Maps[Scan.FComponent].McuBlockCount(FInfo.FScanCount) - 1 do
    begin
      FMcu[Idx].DCTable := Scan.FDCTable;
      FMcu[Idx].ACTable := Scan.FACTable;
      FMcu[Idx].PPred := @Scan.FPredictor;
      FMcu[Idx].BlockIdx := j;
      FMcu[Idx].MapIdx := Scan.FComponent;
      inc(Idx);
    end;
  end;
end;

procedure TsdJpegBaselineCoder.InitializeEncoderTables;
var
  i, j, Idx: integer;
  Scan: TsdScanComponent;
  DC: TsdDCBaselineHuffmanEncoder;
  AC: TsdACBaselineHuffmanEncoder;
begin
  // Initialize used tables
  FDCCoders.Clear;
  FACCoders.Clear;
  Idx := 0;

  // Loop through image components in scan
  for i := 0 to FInfo.FScanCount - 1 do
  begin
    // Scan's i-th image component info
    Scan := FInfo.FScans[i];
    // Create DC and AC decoders for i-th image
    if not assigned(FDCCoders[Scan.FDCTable])
       and ((TsdHuffmanTableList(FInfo.FDCHuffmanTables)[Scan.FDCTable].Count > 0) or FIsDryRun) then
    begin
      DC := TsdDCBaselineHuffmanEncoder.Create;
      FDCCoders[Scan.FDCTable] := DC;
      DC.GenerateCodeTable(TsdHuffmanTableList(FInfo.FDCHuffmanTables)[Scan.FDCTable]);
    end;
    if not assigned(FACCoders[Scan.FACTable])
       and ((TsdHuffmanTableList(FInfo.FACHuffmanTables)[Scan.FACTable].Count > 0) or FIsDryRun) then
    begin
      AC := TsdACBaselineHuffmanEncoder.Create;
      FACCoders[Scan.FACTable] := AC;
      AC.GenerateCodeTable(TsdHuffmanTableList(FInfo.FACHuffmanTables)[Scan.FACTable]);
    end;
    // Assign table numbers to MCU blocks
    for j := 0 to Maps[Scan.FComponent].McuBlockCount(FInfo.FScanCount) - 1 do
    begin
      FMcu[Idx].DCTable := Scan.FDCTable;
      FMcu[Idx].ACTable := Scan.FACTable;
      FMcu[Idx].PPred := @Scan.FPredictor;
      FMcu[Idx].BlockIdx := j;
      FMcu[Idx].MapIdx := Scan.FComponent;
      inc(Idx);
    end;
  end;
end;

procedure TsdJpegBaselineCoder.ResetDecoder;
var
  i: integer;
begin
  FBitReader.Reset;
  // Also reset the DC PRED values
  for i := 0 to FInfo.FScanCount - 1 do
    FInfo.FScans[i].FPredictor := 0;
end;

procedure TsdJpegBaselineCoder.ResetEncoder;
var
  i: integer;
begin
  if assigned(FBitWriter) then
    FBitWriter.Restart;
  // Also reset the DC PRED values
  for i := 0 to FInfo.FScanCount - 1 do
    FInfo.FScans[i].FPredictor := 0;
end;

procedure TsdJpegBaselineCoder.ResizeVerticalMcu(NewVertMcuCount: integer);
var
  i: integer;
  HorzBlockCount, VertBlockCount: integer;
begin
  FVertMcuCount := NewVertMcuCount;
  FInfo.FVertMcuCount :=  NewVertMcuCount;

  // Resize maps
  for i := 0 to FInfo.FFrameCount - 1 do
  begin
    HorzBlockCount := FInfo.FHorzMcuCount * FInfo.FFrames[i].FHorzSampling;
    VertBlockCount := FInfo.FVertMcuCount * FInfo.FFrames[i].FVertSampling;
    Maps[i].Resize(HorzBlockCount, VertBlockCount);
  end;
end;

{ TsdJpegProgressiveCoder }

function TsdJpegProgressiveCoder.BlockstrideForScale(AScale: TsdJpegScale): integer;
begin
  // Blockstride is *always* 64 for progressive coding, because the coder depends
  // on AC coefficents being set.
  Result := 64;
end;

procedure TsdJpegProgressiveCoder.Decode(S: TStream; Iteration: cardinal);
begin
  // Decide which band (DC or AC) and whether first scan
  FIsDCBand := FInfo.FSpectralStart = 0;
  FIsFirst := FInfo.FApproxHigh = 0;
  FEOBRun := 0;

  if FTileMode then
    raise Exception.Create(sCannotUseTileMode);

  // Use the standard decoder, with overridden methods
  inherited Decode(S, Iteration);
end;

procedure TsdJpegProgressiveCoder.DecodeMcu(AMcuX, AMcuY: integer; Skip: boolean);
var
  i: integer;
  McuBlock: PsdMCUBlock;
begin

  for i := 0 to FMcuBlockCount - 1 do
  begin
    // The current MCU block
    McuBlock := @FMcu[i];

    // Initialize MCU values pointer
    if FInfo.FScanCount > 1 then
      McuBlock.Values := Maps[McuBlock.MapIdx].GetCoefPointerMCU(AMcuX, AMcuY, McuBlock.BlockIdx)
    else
      McuBlock.Values := Maps[McuBlock.MapIdx].GetCoefPointer(AMcuX, AMcuY);

    // Each MCU block has an index to a DC and AC table, use it to do the decoding
    if FIsDCBand and assigned(FDCCoders[McuBlock.DCTable]) then
    begin
      if FIsFirst then
        TsdDCProgressiveHuffmanDecoder(FDCCoders[McuBlock.DCTable]).DecodeProgFirst(McuBlock^,
          FBitReader, FInfo.FApproxLow)
      else
        TsdDCProgressiveHuffmanDecoder(FDCCoders[McuBlock.DCTable]).DecodeProgRefine(McuBlock^,
          FBitReader, FInfo.FApproxLow);
    end;
    if not FIsDCBand and assigned(FACCoders[McuBlock.ACTable]) then
    begin
      if FIsFirst then
        TsdACProgressiveHuffmanDecoder(FACCoders[McuBlock.ACTable]).DecodeProgFirst(McuBlock^,
          FBitReader, FEOBRun, FInfo.FSpectralStart, FInfo.FSpectralEnd, FInfo.FApproxLow)
      else
        TsdACProgressiveHuffmanDecoder(FACCoders[McuBlock.ACTable]).DecodeProgRefine(McuBlock^,
          FBitReader, FEOBRun, FInfo.FSpectralStart, FInfo.FSpectralEnd, FInfo.FApproxLow);
    end;

    if FBitReader.HitEndOfStream then
    begin
      exit;
    end;
  end;
end;

procedure TsdJpegProgressiveCoder.Finalize;
begin
  CorrectBlockStride;
end;

procedure TsdJpegProgressiveCoder.HandleRestartInterval(S: TStream; Warn: boolean);
begin
  inherited;
  // Reset EOB run
  FEOBRun := 0;
end;

procedure TsdJpegProgressiveCoder.InitializeDecoderTables;
var
  i, j, Idx: integer;
  Scan: TsdScanComponent;
  DC: TsdDCProgressiveHuffmanDecoder;
  AC: TsdACProgressiveHuffmanDecoder;
begin
  // Initialize tables to use (max 4 per AC/DC)
  FDCCoders.Clear;
  FACCoders.Clear;
  Idx := 0;

  // Loop through image components in scan
  for i := 0 to FInfo.FScanCount - 1 do
  begin
    // Scan's i-th image component info
    Scan := FInfo.FScans[i];

    // Create DC and AC decoders for i-th image
    if FIsDCBand
       and not assigned(FDCCoders[Scan.FDCTable])
       and (TsdHuffmanTableList(FInfo.FDCHuffmanTables)[Scan.FDCTable].Count > 0) then
    begin
      DC := TsdDCProgressiveHuffmanDecoder.Create;
      FDCCoders[Scan.FDCTable] := DC;
      DC.GenerateLookupTables(TsdHuffmanTableList(FInfo.FDCHuffmanTables)[Scan.FDCTable]);
    end;
    if not FIsDCBand
       and not assigned(FACCoders[Scan.FACTable])
       and (TsdHuffmanTableList(FInfo.FACHuffmanTables)[Scan.FACTable].Count > 0) then
    begin
      AC := TsdACProgressiveHuffmanDecoder.Create;
      FACCoders[Scan.FACTable] := AC;
      AC.GenerateLookupTables(TsdHuffmanTableList(FInfo.FACHuffmanTables)[Scan.FACTable]);
    end;

    // Assign table numbers to MCU blocks
    for j := 0 to Maps[Scan.FComponent].McuBlockCount(FInfo.FScanCount) - 1 do
    begin
      FMcu[Idx].DCTable := Scan.FDCTable;
      FMcu[Idx].ACTable := Scan.FACTable;
      FMcu[Idx].PPred := @Scan.FPredictor;
      FMcu[Idx].BlockIdx := j;
      FMcu[Idx].MapIdx := Scan.FComponent;
      inc(Idx);
    end;
  end;
end;

end.
