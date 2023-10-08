{ unit sdJpegDCT

  Discrete Cosine Transform (DCT) methods

  Author: Nils Haeck M.Sc.
  Copyright (c) 2007 SimDesign B.V.
  More information: www.simdesign.nl or n.haeck@simdesign.nl

  This software may ONLY be used or replicated in accordance with
  the LICENSE found in this source distribution.
}
unit sdJpegDCT;

interface

uses
  System.Classes, sdJpegTypes, sdJpegImage;

type

  TsdJpegDCT = class(TPersistent)
  private
    FQuant: TsdIntArray64;
    FMap: TsdJpegBlockMap;
    FMethod: TsdJpegDCTCodingMethod;
  public
    procedure BuildQuantTableFrom(ATable: TsdQuantizationTable);
    property Map: TsdJpegBlockMap read FMap write FMap;
    property Method: TsdJpegDCTCodingMethod read FMethod write FMethod;
  end;

  // Forward DCT
  TsdJpegFDCT = class(TsdJpegDCT)
  public
    procedure PerformFDCT(ATable: TsdQuantizationTable);
  end;

  // Inverse DCT
  TsdJpegIDCT = class(TsdJpegDCT)
  public
    procedure PerformIDCT;
  end;

  // Method definition for forward DCT on one block of samples
  TFDCTMethod = procedure(const Sample: TsdSampleBlock; out Coef: TsdCoefBlock;
    var Wrksp: TsdIntArray64);

  // Method definition for inverse DCT on one block of coefficients
  TIDCTMethod = procedure(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
    const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);

{ from unit sdJpegDCTFast;

  Based in part on original code: jidctfst.c

  Copyright (C) 1994-1998, Thomas G. Lane.
  This file is part of the Independent JPEG Group's software.
  for more information see www.ijg.org

  This file contains a fast, not so accurate integer implementation of the
  inverse DCT (Discrete Cosine Transform).  In the IJG code, this routine
  must also perform dequantization of the input coefficients.

  A 2-D IDCT can be done by 1-D IDCT on each column followed by 1-D IDCT
  on each row (or vice versa, but it's more convenient to emit a row at
  a time).  Direct algorithms are also available, but they are much more
  complex and seem not to be any faster when reduced to code.

  This implementation is based on Arai, Agui, and Nakajima's algorithm for
  scaled DCT.  Their original paper (Trans. IEICE E-71(11):1095) is in
  Japanese, but the algorithm is described in the Pennebaker & Mitchell
  JPEG textbook (see REFERENCES section in file README).  The following code
  is based directly on figure 4-8 in P&M.
  While an 8-point DCT cannot be done in less than 11 multiplies, it is
  possible to arrange the computation so that many of the multiplies are
  simple scalings of the final outputs.  These multiplies can then be
  folded into the multiplications or divisions by the JPEG quantization
  table entries.  The AA&N method leaves only 5 multiplies and 29 adds
  to be done in the DCT itself.
  The primary disadvantage of this method is that with fixed-point math,
  accuracy is lost due to imprecise representation of the scaled
  quantization values.  The smaller the quantization table entry, the less
  precise the scaled value, so this implementation does worse with high-
  quality-setting files than with low-quality ones.

  Delphi translation: (c) 2007 by Nils Haeck M.Sc. (www.simdesign.nl)
  Changes:
  - We use 9 bits of precision in the integer arithmetic.

}
procedure InverseDCTIntFast8x8(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);

{ from unit sdJpegDCTAccurate;

  Based in part on original code: jidctint.c

  Copyright (C) 1991-1998, Thomas G. Lane.
  Modification developed 2002 by Guido Vollbeding
  This file is part of the Independent JPEG Group's software.
  for more information see www.ijg.org

  This file contains a slow-but-accurate integer implementation of the
  inverse DCT (Discrete Cosine Transform).  In the IJG code, this routine
  must also perform dequantization of the input coefficients.

  A 2-D IDCT can be done by 1-D IDCT on each column followed by 1-D IDCT
  on each row (or vice versa, but it's more convenient to emit a row at
  a time).  Direct algorithms are also available, but they are much more
  complex and seem not to be any faster when reduced to code.

  This implementation is based on an algorithm described in
    C. Loeffler, A. Ligtenberg and G. Moschytz, "Practical Fast 1-D DCT
    Algorithms with 11 Multiplications", Proc. Int'l. Conf. on Acoustics,
    Speech, and Signal Processing 1989 (ICASSP '89), pp. 988-991.
  The primary algorithm described there uses 11 multiplies and 29 adds.
  We use their alternate method with 12 multiplies and 32 adds.
  The advantage of this method is that no data path contains more than one
  multiplication; this allows a very simple and accurate implementation in
  scaled fixed-point arithmetic, with a minimal number of shifts.

  We also provide IDCT routines with various output sample block sizes for
  direct resolution reduction or enlargement and for direct resolving the
  common 2x1 and 1x2 subsampling cases without additional resampling: NxN
  (N=1...16), 2NxN, and Nx2N (N=1...8) pixels for one 8x8 input DCT block.

  For N<8 we simply take the corresponding low-frequency coefficients of
  the 8x8 input DCT block and apply an NxN point IDCT on the sub-block
  to yield the downscaled outputs.
  This can be seen as direct low-pass downsampling from the DCT domain
  point of view rather than the usual spatial domain point of view,
  yielding significant computational savings and results at least
  as good as common bilinear (averaging) spatial downsampling.

  For N>8 we apply a partial NxN IDCT on the 8 input coefficients as
  lower frequencies and higher frequencies assumed to be zero.
  It turns out that the computational effort is similar to the 8x8 IDCT
  regarding the output size.
  Furthermore, the scaling and descaling is the same for all IDCT sizes.

  CAUTION: We rely on the FIX() macro except for the N=1,2,4,8 cases
  since there would be too many additional constants to pre-calculate.

  Delphi translation: (c) 2007 by Nils Haeck M.Sc. (www.simdesign.nl)
  Changes:
  - This unit also provides the forward DCT int accurate method
  - The int accurate IDCT is also adapted to make reduced size
    IDCT methods (4x4, 2x2 and 1x1).
}
procedure ForwardDCTIntAccurate8x8(const Sample: TsdSampleBlock; out Coef: TsdCoefBlock;
  var Wrksp: TsdIntArray64);

procedure InverseDCTIntAccurate8x8(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
procedure InverseDCTIntAccurate4x4(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
procedure InverseDCTIntAccurate2x2(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
procedure InverseDCTIntAccurate1x1(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);

implementation

const

  // For AA&N IDCT method, multipliers are equal to quantization
  // coefficients scaled by scalefactor[row]*scalefactor[col], where
  //    scalefactor[0] := 1
  //    scalefactor[k] := cos(k*PI/16) * sqrt(2)    for k=1..7
  // To get integer precision, the multiplier table is scaled by 14 bits
  cIFastQuantScales : array[0..63] of integer =
    ({ precomputed values scaled up by 14 bits }
     16384, 22725, 21407, 19266, 16384, 12873,  8867,  4520,
     22725, 31521, 29692, 26722, 22725, 17855, 12299,  6270,
     21407, 29692, 27969, 25172, 21407, 16819, 11585,  5906,
     19266, 26722, 25172, 22654, 19266, 15137, 10426,  5315,
     16384, 22725, 21407, 19266, 16384, 12873,  8867,  4520,
     12873, 17855, 16819, 15137, 12873, 10114,  6967,  3552,
      8867, 12299, 11585, 10426,  8867,  6967,  4799,  2446,
      4520,  6270,  5906,  5315,  4520,  3552,  2446,  1247);

const
  // Fast IDCT: we use 9 bits of precision, so must multiply by 2^9
  cIFastConstBits = 9;
  cIFastRangeBits = cIFastConstBits + 3;
  cIFastConstScale = 1 shl cIFastConstBits;

const
  FIX_1_082392200F = integer(Round(cIFastConstScale * 1.082392200));
  FIX_1_414213562F = integer(Round(cIFastConstScale * 1.414213562));
  FIX_1_847759065F = integer(Round(cIFastConstScale * 1.847759065));
  FIX_2_613125930F = integer(Round(cIFastConstScale * 2.613125930));

const
  // Accurate FDCT
  cConstBits = 13;
  cConstScaleA = 1 SHL cConstBits;
  cPass1Bits = 2;

const
  // Constants used in forward DCT
  FIX_0_298631336AF = Round(cConstScaleA * 0.298631336);
  FIX_0_390180644AF = Round(cConstScaleA * 0.390180644);
  FIX_0_541196100AF = Round(cConstScaleA * 0.541196100);
  FIX_0_765366865AF = Round(cConstScaleA * 0.765366865);
  FIX_0_899976223AF = Round(cConstScaleA * 0.899976223);
  FIX_1_175875602AF = Round(cConstScaleA * 1.175875602);
  FIX_1_501321110AF = Round(cConstScaleA * 1.501321110);
  FIX_1_847759065AF = Round(cConstScaleA * 1.847759065);
  FIX_1_961570560AF = Round(cConstScaleA * 1.961570560);
  FIX_2_053119869AF = Round(cConstScaleA * 2.053119869);
  FIX_2_562915447AF = Round(cConstScaleA * 2.562915447);
  FIX_3_072711026AF = Round(cConstScaleA * 3.072711026);

const
  // Accurate IDCT
  cIAccConstBits = 9;
  cIAccRangeBits = cIAccConstBits + 3;
  // we use 9 bits of precision, so must multiply by 2^9
  cIAccConstScale = 1 shl cIAccConstBits;
  cCenterSample = 128;
  cMaxSample    = 255;

const
  // Constants used in Inverse DCT accurate
  FIX_0_298631336AI = Round(cIAccConstScale * 0.298631336);
  FIX_0_390180644AI = Round(cIAccConstScale * 0.390180644);
  FIX_0_541196100AI = Round(cIAccConstScale * 0.541196100);
  FIX_0_765366865AI = Round(cIAccConstScale * 0.765366865);
  FIX_0_899976223AI = Round(cIAccConstScale * 0.899976223);
  FIX_1_175875602AI = Round(cIAccConstScale * 1.175875602);
  FIX_1_501321110AI = Round(cIAccConstScale * 1.501321110);
  FIX_1_847759065AI = Round(cIAccConstScale * 1.847759065);
  FIX_1_961570560AI = Round(cIAccConstScale * 1.961570560);
  FIX_2_053119869AI = Round(cIAccConstScale * 2.053119869);
  FIX_2_562915447AI = Round(cIAccConstScale * 2.562915447);
  FIX_3_072711026AI = Round(cIAccConstScale * 3.072711026);


{ TsdJpegDCT }

procedure TsdJpegDCT.BuildQuantTableFrom(ATable: TsdQuantizationTable);
// we must use the inverse zig-zag
var
  i: integer;
begin
  if (FMethod = dmAccurate) or (FMap.BlockStride < 64) then
  begin
    // Get the quantization values from the table (and undo zigzag)
    for i := 0 to 63 do
      FQuant[cJpegInverseZigZag8x8[i]] := ATable.FQuant[i];
    // Premultiply the quantization factors
    for i := 0 to 63 do
      // give correct bit precision
      FQuant[i] := FQuant[i] * cIAccConstScale;
  end else
  begin
    // Get the quantization values from the table (and undo zigzag)
    for i := 0 to 63 do
      FQuant[cJpegInverseZigZag8x8[i]] := ATable.FQuant[i];
    // Premultiply the quantization factors
    for i := 0 to 63 do
      // scales are with 14 bits of precision, we only want 9 so divide
      // by 5 bits of precision
      FQuant[i] := (FQuant[i] * cIFastQuantScales[i]) div (1 shl (14 - cIFastConstBits));
  end;
end;

{ TsdJpegFDCT }

procedure TsdJpegFDCT.PerformFDCT(ATable: TsdQuantizationTable);
var
  i, j, k: integer;
  PCoef: PsdCoefBlock;
  PSample: PsdSampleBlock;
  Work: TsdIntArray64;
  FFDctMethod: TFDCTMethod;
  CVal, QVal: SmallInt;
begin
  // Quantization coefficients, unzigzagged
  for i := 0 to 63 do
    // We multiply divisors by 8 because the FDCT will create values that
    // are multiplied by 8 (shl 3) versus what they should be according
    // to theoretical DCT.
    FQuant[cJpegInverseZigZag8x8[i]] := ATable.FQuant[i] * 8;

  // Forward DCT method (we always use this one)
  FFDctMethod := ForwardDCTIntAccurate8x8;

  for j := 0 to FMap.VertBlockCount - 1 do
  begin
    for i := 0 to FMap.HorzBlockCount - 1 do
    begin
      // DCT the samples into coefficients
      PSample := FMap.GetSamplePointer(i, j);
      PCoef := FMap.GetCoefPointer(i, j);
      FFDctMethod(PSample^, PCoef^, Work);

      // Quantize the coefficients
      for k := 0 to 63 do
      begin
        CVal := PCoef[k];
        QVal := FQuant[k];
        if CVal < 0 then
        begin
          CVal := -CVal;
          inc(CVal, QVal shr 1); // rounding
          if CVal >= QVal then
            CVal := - (CVal div QVal)
          else
            CVal := 0;
        end else
        begin
          inc(CVal, QVal shr 1); // rounding
          if CVal >= QVal then
            CVal := CVal div QVal
          else
            CVal := 0;
        end;
        PCoef[k] := CVal;
      end;
    end;
  end;
end;

{ TsdJpegIDCT }

procedure TsdJpegIDCT.PerformIDCT;
var
  i, j: integer;
  PCoef: PsdCoefBlock;
  PSample: PsdSampleBlock;
  Work: TsdIntArray64;
  FIDctMethod: TIDCTMethod;
begin
  // Select method
  FIDctMethod := nil;
  case FMethod of
  dmFast:
    begin
      case FMap.BlockStride of
      64: FIDctMethod := InverseDCTIntFast8x8; // 8x8
      16: FIDctMethod := InverseDCTIntAccurate4x4; // 4x4
       4: FIDctMethod := InverseDCTIntAccurate2x2; // 2x2
       1: FIDctMethod := InverseDCTIntAccurate1x1; // 1x1
      end;
    end;
  dmAccurate:
    begin
      case FMap.BlockStride of
      64: FIDctMethod := InverseDCTIntAccurate8x8; // 8x8
      16: FIDctMethod := InverseDCTIntAccurate4x4; // 4x4
       4: FIDctMethod := InverseDCTIntAccurate2x2; // 2x2
       1: FIDctMethod := InverseDCTIntAccurate1x1; // 1x1
      end;
    end;
  end;

  if not assigned(FIDctMethod) then exit;
  for j := 0 to FMap.VertBlockCount - 1 do
    for i := 0 to FMap.HorzBlockCount - 1 do
    begin
      PCoef := FMap.GetCoefPointer(i, j);
      PSample := FMap.GetSamplePointer(i, j);
      FIDctMethod(PCoef^, PSample^, FQuant, Work);
    end;
end;

// integer multiply with shift arithmetic right
function MultiplyF(A, B: integer): integer;
begin
  // Delphi seems to convert the "div" here to SAR just fine (D7), so we
  // don't use ASM but plain pascal
  Result := (A * B) div cIFastConstScale;
end;

// Descale and range limit to byte domain. We shift right over
// 13 bits: 10 bits to remove precision, and 3 bits to get rid of the additional
// factor 8 introducted by the IDCT transform.
function RangeLimitF(A: integer): integer;
begin
  // Delphi seems to convert the "div" here to SAR just fine (D7), so we
  // don't use ASM but plain pascal
  Result := A div (1 shl cIFastRangeBits) + 128;
  if Result < 0 then
    Result := 0
  else
    if Result > 255 then
      Result := 255;
end;

procedure InverseDCTIntFast8x8(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
var
  i, QIdx: integer;
  dci: integer;
  dcs: byte;
  p0, p1, p2, p3, p4, p5, p6, p7: Psmallint;
  w0, w1, w2, w3, w4, w5, w6, w7: Pinteger;
  s0, s1, s2, s3, s4, s5, s6, s7: Pbyte;
  tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7: integer;
  tmp10, tmp11, tmp12, tmp13: integer;
  z5, z10, z11, z12, z13: integer;
begin
  QIdx := 0;
  // First do the columns
  p0 := @Coef[ 0]; p1 := @Coef[ 8]; p2 := @Coef[16]; p3 := @Coef[24];
  p4 := @Coef[32]; p5 := @Coef[40]; p6 := @Coef[48]; p7 := @Coef[56];
  w0 := @Wrksp[ 0]; w1 := @Wrksp[ 8]; w2 := @Wrksp[16]; w3 := @Wrksp[24];
  w4 := @Wrksp[32]; w5 := @Wrksp[40]; w6 := @Wrksp[48]; w7 := @Wrksp[56];
  for i := 0 to 7 do
  begin
    if (p1^ = 0) and (p2^ = 0) and (p3^ = 0) and (p4^ = 0) and
       (p5^ = 0) and (p6^ = 0) and (p7^ = 0) then
    begin
      dci := p0^ * Quant[QIdx];
      w0^ := dci; w1^ := dci; w2^ := dci; w3^ := dci;
      w4^ := dci; w5^ := dci; w6^ := dci; w7^ := dci;
    end else
    begin
      // Even part

      tmp0 := p0^ * Quant[QIdx     ];
      tmp1 := p2^ * Quant[QIdx + 16];
      tmp2 := p4^ * Quant[QIdx + 32];
      tmp3 := p6^ * Quant[QIdx + 48];

      tmp10 := tmp0 + tmp2;	// phase 3
      tmp11 := tmp0 - tmp2;

      tmp13 := tmp1 + tmp3;	// phases 5-3
      tmp12 := MultiplyF(tmp1 - tmp3, FIX_1_414213562F) - tmp13; // 2*c4

      tmp0 := tmp10 + tmp13;	// phase 2
      tmp3 := tmp10 - tmp13;
      tmp1 := tmp11 + tmp12;
      tmp2 := tmp11 - tmp12;

      // Odd part

      tmp4 := p1^ * Quant[QIdx +  8];
      tmp5 := p3^ * Quant[QIdx + 24];
      tmp6 := p5^ * Quant[QIdx + 40];
      tmp7 := p7^ * Quant[QIdx + 56];

      z13 := tmp6 + tmp5;		// phase 6
      z10 := tmp6 - tmp5;
      z11 := tmp4 + tmp7;
      z12 := tmp4 - tmp7;

      tmp7 := z11 + z13;		// phase 5
      tmp11 := MultiplyF(z11 - z13, FIX_1_414213562F); // 2*c4

      z5    := MultiplyF(z10 + z12, FIX_1_847759065F); // 2*c2
      tmp10 := MultiplyF(z12, FIX_1_082392200F) - z5; // 2*(c2-c6)
      tmp12 := MultiplyF(z10, - FIX_2_613125930F) + z5; // -2*(c2+c6)

      tmp6 := tmp12 - tmp7;	// phase 2
      tmp5 := tmp11 - tmp6;
      tmp4 := tmp10 + tmp5;

      w0^ := tmp0 + tmp7;
      w7^ := tmp0 - tmp7;
      w1^ := tmp1 + tmp6;
      w6^ := tmp1 - tmp6;
      w2^ := tmp2 + tmp5;
      w5^ := tmp2 - tmp5;
      w4^ := tmp3 + tmp4;
      w3^ := tmp3 - tmp4;

    end;
    // Advance block pointers
    inc(p0); inc(p1); inc(p2); inc(p3); inc(p4); inc(p5); inc(p6); inc(p7);
    inc(w0); inc(w1); inc(w2); inc(w3); inc(w4); inc(w5); inc(w6); inc(w7);
    inc(QIdx);
  end;

  // Next do the rows
  w0 := @Wrksp[0]; w1 := @Wrksp[1]; w2 := @Wrksp[2]; w3 := @Wrksp[3];
  w4 := @Wrksp[4]; w5 := @Wrksp[5]; w6 := @Wrksp[6]; w7 := @Wrksp[7];
  s0 := @Sample[0]; s1 := @Sample[1]; s2 := @Sample[2]; s3 := @Sample[3];
  s4 := @Sample[4]; s5 := @Sample[5]; s6 := @Sample[6]; s7 := @Sample[7];
  for i := 0 to 7 do
  begin
    if (w1^ = 0) and (w2^ = 0) and (w3^ = 0) and (w4^ = 0) and
       (w5^ = 0) and (w6^ = 0) and (w7^ = 0) then
    begin
      dcs := RangeLimitF(w0^);
      s0^ := dcs; s1^ := dcs; s2^ := dcs; s3^ := dcs;
      s4^ := dcs; s5^ := dcs; s6^ := dcs; s7^ := dcs;
    end else
    begin

      // Even part

      tmp10 := w0^ + w4^;
      tmp11 := w0^ - w4^;

      tmp13 := w2^ + w6^;
      tmp12 := MultiplyF(w2^ - w6^, FIX_1_414213562F) - tmp13;

      tmp0 := tmp10 + tmp13;
      tmp3 := tmp10 - tmp13;
      tmp1 := tmp11 + tmp12;
      tmp2 := tmp11 - tmp12;

      // Odd part

      z13 := w5^ + w3^;
      z10 := w5^ - w3^;
      z11 := w1^ + w7^;
      z12 := w1^ - w7^;

      tmp7 := z11 + z13;		// phase 5
      tmp11 := MultiplyF(z11 - z13, FIX_1_414213562F); // 2*c4

      z5    := MultiplyF(z10 + z12, FIX_1_847759065F); // 2*c2
      tmp10 := MultiplyF(z12, FIX_1_082392200F) - z5; // 2*(c2-c6)
      tmp12 := MultiplyF(z10, - FIX_2_613125930F) + z5; // -2*(c2+c6)

      tmp6 := tmp12 - tmp7;	// phase 2
      tmp5 := tmp11 - tmp6;
      tmp4 := tmp10 + tmp5;

      // Final output stage: scale down by a factor of 8 and range-limit

      s0^ := RangeLimitF(tmp0 + tmp7);
      s7^ := RangeLimitF(tmp0 - tmp7);
      s1^ := RangeLimitF(tmp1 + tmp6);
      s6^ := RangeLimitF(tmp1 - tmp6);
      s2^ := RangeLimitF(tmp2 + tmp5);
      s5^ := RangeLimitF(tmp2 - tmp5);
      s4^ := RangeLimitF(tmp3 + tmp4);
      s3^ := RangeLimitF(tmp3 - tmp4);

    end;
    // Advance block pointers
    inc(s0, 8); inc(s1, 8); inc(s2, 8); inc(s3, 8);
    inc(s4, 8); inc(s5, 8); inc(s6, 8); inc(s7, 8);
    inc(w0, 8); inc(w1, 8); inc(w2, 8); inc(w3, 8);
    inc(w4, 8); inc(w5, 8); inc(w6, 8); inc(w7, 8);
  end;
end;

procedure ForwardDCTIntAccurate8x8(const Sample: TsdSampleBlock; out Coef: TsdCoefBlock;
  var Wrksp: TsdIntArray64);
var
  i: integer;
  s0, s1, s2, s3, s4, s5, s6, s7: Pbyte;
  p0, p1, p2, p3, p4, p5, p6, p7: Psmallint;
  w0, w1, w2, w3, w4, w5, w6, w7: Pinteger;
  z1, z2, z3, z4, z5: integer;
  tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp10, tmp11, tmp12, tmp13: integer;

  // local
  function DescaleMin(x: integer): integer;
  begin
    // Delphi seems to convert the "div" here to SAR just fine (D7), so we
    // don't use ASM but plain pascal
    Result := x div (1 shl (cConstBits - cPass1Bits));
  end;

  function DescalePlus(x: integer): integer;
  begin
    // Delphi seems to convert the "div" here to SAR just fine (D7), so we
    // don't use ASM but plain pascal
    Result := x div (1 shl (cConstBits + cPass1Bits));
  end;

  function DescalePass(x: integer): integer;
  begin
    // Delphi seems to convert the "div" here to SAR just fine (D7), so we
    // don't use ASM but plain pascal
    Result := x div (1 shl cPass1Bits);
  end;

// main
begin

  // Pass 1: process rows.
  // Note results are scaled up by sqrt(8) compared to a true DCT;
  // furthermore, we scale the results by 2**PASS1_BITS.
  s0 := @Sample[0]; s1 := @Sample[1]; s2 := @Sample[2]; s3 := @Sample[3];
  s4 := @Sample[4]; s5 := @Sample[5]; s6 := @Sample[6]; s7 := @Sample[7];
  w0 := @Wrksp[0]; w1 := @Wrksp[1]; w2 := @Wrksp[2]; w3 := @Wrksp[3];
  w4 := @Wrksp[4]; w5 := @Wrksp[5]; w6 := @Wrksp[6]; w7 := @Wrksp[7];

  for i := 0 to 7 do
  begin
    // Samples are in range 0..255, but we must put them in range -128..127
    // So if two samples are added, we should substract 2 times the centersample
    // value, and if two samples are substracted, we do not have to correct.
    tmp0 := s0^ + s7^ - 2 * cCenterSample;
    tmp1 := s1^ + s6^ - 2 * cCenterSample;
    tmp2 := s2^ + s5^ - 2 * cCenterSample;
    tmp3 := s3^ + s4^ - 2 * cCenterSample;
    tmp7 := s0^ - s7^;
    tmp6 := s1^ - s6^;
    tmp5 := s2^ - s5^;
    tmp4 := s3^ - s4^;

    // Even part per LL&M figure 1 --- note that published figure is faulty;
    // rotator "sqrt(2)*c1" should be "sqrt(2)*c6".

    tmp10 := tmp0 + tmp3;
    tmp13 := tmp0 - tmp3;
    tmp11 := tmp1 + tmp2;
    tmp12 := tmp1 - tmp2;

    w0^ := (tmp10 + tmp11) shl cPass1Bits;
    w4^ := (tmp10 - tmp11) shl cPass1Bits;

    z1 := (tmp12 + tmp13) * FIX_0_541196100AF;
    w2^ := DescaleMin(z1 + tmp13 * FIX_0_765366865AF);
    w6^ := DescaleMin(z1 - tmp12 * FIX_1_847759065AF);

    // Odd part per figure 8 --- note paper omits factor of sqrt(2).
    // cK represents cos(K*pi/16).
    // i0..i3 in the paper are tmp4..tmp7 here.

    z1 := tmp4 + tmp7;
    z2 := tmp5 + tmp6;
    z3 := tmp4 + tmp6;
    z4 := tmp5 + tmp7;
    z5 := (z3 + z4) * FIX_1_175875602AF; // sqrt(2) * c3

    tmp4 := tmp4 * FIX_0_298631336AF; // sqrt(2) * (-c1+c3+c5-c7)
    tmp5 := tmp5 * FIX_2_053119869AF; // sqrt(2) * ( c1+c3-c5+c7)
    tmp6 := tmp6 * FIX_3_072711026AF; // sqrt(2) * ( c1+c3+c5-c7)
    tmp7 := tmp7 * FIX_1_501321110AF; // sqrt(2) * ( c1+c3-c5-c7)
    z1 := - z1 * FIX_0_899976223AF; // sqrt(2) * (c7-c3)
    z2 := - z2 * FIX_2_562915447AF; // sqrt(2) * (-c1-c3)
    z3 := - z3 * FIX_1_961570560AF; // sqrt(2) * (-c3-c5)
    z4 := - z4 * FIX_0_390180644AF; // sqrt(2) * (c5-c3)

    Inc(z3, z5);
    Inc(z4, z5);

    w7^ := DescaleMin(tmp4 + z1 + z3);
    w5^ := DescaleMin(tmp5 + z2 + z4);
    w3^ := DescaleMin(tmp6 + z2 + z3);
    w1^ := DescaleMin(tmp7 + z1 + z4);

    // Advance block pointers
    inc(s0, 8); inc(s1, 8); inc(s2, 8); inc(s3, 8);
    inc(s4, 8); inc(s5, 8); inc(s6, 8); inc(s7, 8);
    inc(w0, 8); inc(w1, 8); inc(w2, 8); inc(w3, 8);
    inc(w4, 8); inc(w5, 8); inc(w6, 8); inc(w7, 8);
  end;

  // Pass 2: process columns.
  // We remove the PASS1_BITS scaling, but leave the results scaled up
  // by an overall factor of 8.

  p0 := @Coef[ 0]; p1 := @Coef[ 8]; p2 := @Coef[16]; p3 := @Coef[24];
  p4 := @Coef[32]; p5 := @Coef[40]; p6 := @Coef[48]; p7 := @Coef[56];
  w0 := @Wrksp[ 0]; w1 := @Wrksp[ 8]; w2 := @Wrksp[16]; w3 := @Wrksp[24];
  w4 := @Wrksp[32]; w5 := @Wrksp[40]; w6 := @Wrksp[48]; w7 := @Wrksp[56];
  for i := 0 to 7 do
  begin
    tmp0 := w0^ + w7^;
    tmp7 := w0^ - w7^;
    tmp1 := w1^ + w6^;
    tmp6 := w1^ - w6^;
    tmp2 := w2^ + w5^;
    tmp5 := w2^ - w5^;
    tmp3 := w3^ + w4^;
    tmp4 := w3^ - w4^;

    // Even part per LL&M figure 1 --- note that published figure is faulty;
    // rotator "sqrt(2)*c1" should be "sqrt(2)*c6".

    tmp10 := tmp0 + tmp3;
    tmp13 := tmp0 - tmp3;
    tmp11 := tmp1 + tmp2;
    tmp12 := tmp1 - tmp2;

    p0^ := DescalePass(tmp10 + tmp11);
    p4^ := DescalePass(tmp10 - tmp11);

    z1 := (tmp12 + tmp13) * FIX_0_541196100AF;
    p2^ := DescalePlus(z1 + tmp13 * FIX_0_765366865AF);
    p6^ := DescalePlus(z1 - tmp12 * FIX_1_847759065AF);

    // Odd part per figure 8 --- note paper omits factor of sqrt(2).
    // cK represents cos(K*pi/16).
    // i0..i3 in the paper are tmp4..tmp7 here.

    z1 := tmp4 + tmp7;
    z2 := tmp5 + tmp6;
    z3 := tmp4 + tmp6;
    z4 := tmp5 + tmp7;
    z5 := (z3 + z4) * FIX_1_175875602AF; // sqrt(2) * c3 }

    tmp4 := tmp4 * FIX_0_298631336AF; // sqrt(2) * (-c1+c3+c5-c7)
    tmp5 := tmp5 * FIX_2_053119869AF; // sqrt(2) * ( c1+c3-c5+c7)
    tmp6 := tmp6 * FIX_3_072711026AF; // sqrt(2) * ( c1+c3+c5-c7)
    tmp7 := tmp7 * FIX_1_501321110AF; // sqrt(2) * ( c1+c3-c5-c7)
    z1 := - z1 * FIX_0_899976223AF; // sqrt(2) * (c7-c3)
    z2 := - z2 * FIX_2_562915447AF; // sqrt(2) * (-c1-c3)
    z3 := - z3 * FIX_1_961570560AF; // sqrt(2) * (-c3-c5)
    z4 := - z4 * FIX_0_390180644AF; // sqrt(2) * (c5-c3)

    Inc(z3, z5);
    Inc(z4, z5);

    p7^ := DescalePlus(tmp4 + z1 + z3);
    p5^ := DescalePlus(tmp5 + z2 + z4);
    p3^ := DescalePlus(tmp6 + z2 + z3);
    p1^ := DescalePlus(tmp7 + z1 + z4);

    // Advance block pointers
    inc(p0); inc(p1); inc(p2); inc(p3); inc(p4); inc(p5); inc(p6); inc(p7);
    inc(w0); inc(w1); inc(w2); inc(w3); inc(w4); inc(w5); inc(w6); inc(w7);
  end;
end;

// integer multiply with shift arithmetic right
function MultiplyA(A, B: integer): integer;
begin
  // Delphi seems to convert the "div" here to SAR just fine (D7), so we
  // don't use ASM but plain pascal
  Result := (A * B) div cIAccConstScale;
end;

// Descale and range limit to byte domain. We shift right over
// 12 bits: 9 bits to remove precision, and 3 bits to get rid of the additional
// factor 8 introducted by the IDCT transform.
function RangeLimitA(A: integer): integer;
begin
  // Delphi seems to convert the "div" here to SAR just fine (D7), so we
  // don't use ASM but plain pascal
  Result := A div (1 shl cIAccRangeBits) + cCenterSample;
  if Result < 0 then
    Result := 0
  else
    if Result > cMaxSample then
      Result := cMaxSample;
end;

procedure InverseDCTIntAccurate8x8(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
var
  i, QIdx: integer;
  dci: integer;
  dcs: byte;
  p0, p1, p2, p3, p4, p5, p6, p7: Psmallint;
  w0, w1, w2, w3, w4, w5, w6, w7: Pinteger;
  s0, s1, s2, s3, s4, s5, s6, s7: Pbyte;
  z1, z2, z3, z4, z5: integer;
  tmp0, tmp1, tmp2, tmp3, tmp10, tmp11, tmp12, tmp13: integer;
begin
  QIdx := 0;
  // First do the columns
  p0 := @Coef[ 0]; p1 := @Coef[ 8]; p2 := @Coef[16]; p3 := @Coef[24];
  p4 := @Coef[32]; p5 := @Coef[40]; p6 := @Coef[48]; p7 := @Coef[56];
  w0 := @Wrksp[ 0]; w1 := @Wrksp[ 8]; w2 := @Wrksp[16]; w3 := @Wrksp[24];
  w4 := @Wrksp[32]; w5 := @Wrksp[40]; w6 := @Wrksp[48]; w7 := @Wrksp[56];
  for i := 0 to 7 do
  begin
    if (p1^ = 0) and (p2^ = 0) and (p3^ = 0) and (p4^ = 0) and
       (p5^ = 0) and (p6^ = 0) and (p7^ = 0) then
    begin
      dci := p0^ * Quant[QIdx];
      w0^ := dci; w1^ := dci; w2^ := dci; w3^ := dci;
      w4^ := dci; w5^ := dci; w6^ := dci; w7^ := dci;
    end else
    begin
      // Even part

      z2 := p2^ * Quant[QIdx + 2 * 8];
      z3 := p6^ * Quant[QIdx + 6 * 8];

      z1 := MultiplyA(z2 + z3, FIX_0_541196100AI);
      tmp2 := z1 + MultiplyA(z3, - FIX_1_847759065AI);
      tmp3 := z1 + MultiplyA(z2, FIX_0_765366865AI);

      z2 := p0^ * Quant[QIdx + 0 * 8];
      z3 := p4^ * Quant[QIdx + 4 * 8];

      tmp0 := (z2 + z3);
      tmp1 := (z2 - z3);

      tmp10 := tmp0 + tmp3;
      tmp13 := tmp0 - tmp3;
      tmp11 := tmp1 + tmp2;
      tmp12 := tmp1 - tmp2;

      // Odd part

      tmp0 := p7^ * Quant[QIdx + 7 * 8];
      tmp1 := p5^ * Quant[QIdx + 5 * 8];
      tmp2 := p3^ * Quant[QIdx + 3 * 8];
      tmp3 := p1^ * Quant[QIdx + 1 * 8];

      z1 := tmp0 + tmp3;
      z2 := tmp1 + tmp2;
      z3 := tmp0 + tmp2;
      z4 := tmp1 + tmp3;
      z5 := MultiplyA(z3 + z4, FIX_1_175875602AI);

      tmp0 := MultiplyA(tmp0, FIX_0_298631336AI);
      tmp1 := MultiplyA(tmp1, FIX_2_053119869AI);
      tmp2 := MultiplyA(tmp2, FIX_3_072711026AI);
      tmp3 := MultiplyA(tmp3, FIX_1_501321110AI);
      z1 := MultiplyA(z1, - FIX_0_899976223AI);
      z2 := MultiplyA(z2, - FIX_2_562915447AI);
      z3 := MultiplyA(z3, - FIX_1_961570560AI);
      z4 := MultiplyA(z4, - FIX_0_390180644AI);

      Inc(z3, z5);
      Inc(z4, z5);

      Inc(tmp0, z1 + z3);
      Inc(tmp1, z2 + z4);
      Inc(tmp2, z2 + z3);
      Inc(tmp3, z1 + z4);

      w0^ := tmp10 + tmp3;
      w7^ := tmp10 - tmp3;
      w1^ := tmp11 + tmp2;
      w6^ := tmp11 - tmp2;
      w2^ := tmp12 + tmp1;
      w5^ := tmp12 - tmp1;
      w3^ := tmp13 + tmp0;
      w4^ := tmp13 - tmp0;

    end;
    // Advance block pointers
    inc(p0); inc(p1); inc(p2); inc(p3); inc(p4); inc(p5); inc(p6); inc(p7);
    inc(w0); inc(w1); inc(w2); inc(w3); inc(w4); inc(w5); inc(w6); inc(w7);
    inc(QIdx);
  end;

  // Next do the rows
  w0 := @Wrksp[0]; w1 := @Wrksp[1]; w2 := @Wrksp[2]; w3 := @Wrksp[3];
  w4 := @Wrksp[4]; w5 := @Wrksp[5]; w6 := @Wrksp[6]; w7 := @Wrksp[7];
  s0 := @Sample[0]; s1 := @Sample[1]; s2 := @Sample[2]; s3 := @Sample[3];
  s4 := @Sample[4]; s5 := @Sample[5]; s6 := @Sample[6]; s7 := @Sample[7];
  for i := 0 to 7 do
  begin
    if (w1^ = 0) and (w2^ = 0) and (w3^ = 0) and (w4^ = 0) and
       (w5^ = 0) and (w6^ = 0) and (w7^ = 0) then
    begin
      dcs := RangeLimitA(w0^);
      s0^ := dcs; s1^ := dcs; s2^ := dcs; s3^ := dcs;
      s4^ := dcs; s5^ := dcs; s6^ := dcs; s7^ := dcs;
    end else
    begin

      // Even part:
      z2 := w2^;
      z3 := w6^;

      z1 := MultiplyA(z2 + z3, FIX_0_541196100AI);
      tmp2 := z1 + MultiplyA(z3, - FIX_1_847759065AI);
      tmp3 := z1 + MultiplyA(z2, FIX_0_765366865AI);

      tmp0 := w0^ + w4^;
      tmp1 := w0^ - w4^;

      tmp10 := tmp0 + tmp3;
      tmp13 := tmp0 - tmp3;
      tmp11 := tmp1 + tmp2;
      tmp12 := tmp1 - tmp2;

      // Odd part:
      tmp0 := w7^;
      tmp1 := w5^;
      tmp2 := w3^;
      tmp3 := w1^;

      z1 := tmp0 + tmp3;
      z2 := tmp1 + tmp2;
      z3 := tmp0 + tmp2;
      z4 := tmp1 + tmp3;
      z5 := MultiplyA(z3 + z4, FIX_1_175875602AI);

      tmp0 := MultiplyA(tmp0, FIX_0_298631336AI);
      tmp1 := MultiplyA(tmp1, FIX_2_053119869AI);
      tmp2 := MultiplyA(tmp2, FIX_3_072711026AI);
      tmp3 := MultiplyA(tmp3, FIX_1_501321110AI);
      z1 := MultiplyA(z1, - FIX_0_899976223AI);
      z2 := MultiplyA(z2, - FIX_2_562915447AI);
      z3 := MultiplyA(z3, - FIX_1_961570560AI);
      z4 := MultiplyA(z4, - FIX_0_390180644AI);

      Inc(z3, z5);
      Inc(z4, z5);

      Inc(tmp0, z1 + z3);
      Inc(tmp1, z2 + z4);
      Inc(tmp2, z2 + z3);
      Inc(tmp3, z1 + z4);

      s0^ := RangeLimitA(tmp10 + tmp3);
      s7^ := RangeLimitA(tmp10 - tmp3);
      s1^ := RangeLimitA(tmp11 + tmp2);
      s6^ := RangeLimitA(tmp11 - tmp2);
      s2^ := RangeLimitA(tmp12 + tmp1);
      s5^ := RangeLimitA(tmp12 - tmp1);
      s3^ := RangeLimitA(tmp13 + tmp0);
      s4^ := RangeLimitA(tmp13 - tmp0);

    end;
    // Advance block pointers
    inc(s0, 8); inc(s1, 8); inc(s2, 8); inc(s3, 8);
    inc(s4, 8); inc(s5, 8); inc(s6, 8); inc(s7, 8);
    inc(w0, 8); inc(w1, 8); inc(w2, 8); inc(w3, 8);
    inc(w4, 8); inc(w5, 8); inc(w6, 8); inc(w7, 8);
  end;
end;

procedure InverseDCTIntAccurate4x4(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
var
  i, QIdx: integer;
  dci: integer;
  dcs: byte;
  p0, p1, p2, p3: Psmallint;
  w0, w1, w2, w3: Pinteger;
  s0, s1, s2, s3: Pbyte;
  z1, z2, z3, z4, z5: integer;
  tmp0, tmp1, tmp2, tmp3, tmp10, tmp11, tmp12, tmp13: integer;
begin
  QIdx := 0;

  // First do the columns
  p0 := @Coef[ 0]; p1 := @Coef[ 4]; p2 := @Coef[ 8]; p3 := @Coef[12];
  w0 := @Wrksp[ 0]; w1 := @Wrksp[ 4]; w2 := @Wrksp[ 8]; w3 := @Wrksp[12];
  for i := 0 to 3 do
  begin
    if (p1^ = 0) and (p2^ = 0) and (p3^ = 0) then
    begin
      dci := p0^ * Quant[QIdx];
      w0^ := dci; w1^ := dci; w2^ := dci; w3^ := dci;
    end else
    begin
      // Even part:

      z2 := p2^ * Quant[QIdx + 2 * 8];

      z1 := MultiplyA(z2, FIX_0_541196100AI);
      tmp3 := z1 + MultiplyA(z2, FIX_0_765366865AI);

      z2 := p0^ * Quant[QIdx + 0 * 8];

      tmp10 := z2 + tmp3;
      tmp13 := z2 - tmp3;
      tmp11 := z2 + z1;
      tmp12 := z2 - z1;

      // Odd part:

      z3 := p3^ * Quant[QIdx + 3 * 8];
      z4 := p1^ * Quant[QIdx + 1 * 8];

      z5 := MultiplyA(z3 + z4, FIX_1_175875602AI);

      tmp2 := MultiplyA(z3, FIX_3_072711026AI);
      tmp3 := MultiplyA(z4, FIX_1_501321110AI);
      z1 := MultiplyA(z4, - FIX_0_899976223AI);
      z2 := MultiplyA(z3, - FIX_2_562915447AI);
      z3 := MultiplyA(z3, - FIX_1_961570560AI);
      z4 := MultiplyA(z4, - FIX_0_390180644AI);

      Inc(z3, z5);
      Inc(z4, z5);

      tmp0 := z1 + z3;
      tmp1 := z2 + z4;
      Inc(tmp2, z2 + z3);
      Inc(tmp3, z1 + z4);

      w0^ := tmp10 + tmp3;
      w3^ := tmp11 - tmp2;
      w1^ := tmp12 + tmp1;
      w2^ := tmp13 - tmp0;

    end;
    // Advance block pointers
    inc(p0); inc(p1); inc(p2); inc(p3);
    inc(w0); inc(w1); inc(w2); inc(w3);
    inc(QIdx);
  end;

  // Next do the rows
  w0 := @Wrksp[0]; w1 := @Wrksp[1]; w2 := @Wrksp[2]; w3 := @Wrksp[3];
  s0 := @Sample[0]; s1 := @Sample[1]; s2 := @Sample[2]; s3 := @Sample[3];
  for i := 0 to 3 do
  begin
    if (w1^ = 0) and (w2^ = 0) and (w3^ = 0) then
    begin
      dcs := RangeLimitA(w0^);
      s0^ := dcs; s1^ := dcs; s2^ := dcs; s3^ := dcs;
    end else
    begin
      // Even part:

      z2 := w2^;

      z1 := MultiplyA(z2, FIX_0_541196100AI);
      tmp3 := z1 + MultiplyA(z2, FIX_0_765366865AI);

      tmp0 := w0^;

      tmp10 := tmp0 + tmp3;
      tmp13 := tmp0 - tmp3;
      tmp11 := tmp0 + z1;
      tmp12 := tmp0 - z1;

      // Odd part:

      tmp2 := w3^;
      tmp3 := w1^;

      z3 := tmp2;
      z4 := tmp3;
      z5 := MultiplyA(z3 + z4, FIX_1_175875602AI);

      tmp2 := MultiplyA(tmp2, FIX_3_072711026AI);
      tmp3 := MultiplyA(tmp3, FIX_1_501321110AI);
      z1 := MultiplyA(z4, - FIX_0_899976223AI);
      z2 := MultiplyA(z3, - FIX_2_562915447AI);
      z3 := MultiplyA(z3, - FIX_1_961570560AI);
      z4 := MultiplyA(z4, - FIX_0_390180644AI);

      Inc(z3, z5);
      Inc(z4, z5);

      tmp0 := z1 + z3;
      tmp1 := z2 + z4;
      Inc(tmp2, z2 + z3);
      Inc(tmp3, z1 + z4);

      s0^ := RangeLimitA(tmp10 + tmp3);
      s3^ := RangeLimitA(tmp11 - tmp2);
      s1^ := RangeLimitA(tmp12 + tmp1);
      s2^ := RangeLimitA(tmp13 - tmp0);

    end;

    // Advance block pointers
    inc(s0, 4); inc(s1, 4); inc(s2, 4); inc(s3, 4);
    inc(w0, 4); inc(w1, 4); inc(w2, 4); inc(w3, 4);
  end;
end;

procedure InverseDCTIntAccurate2x2(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
var
  i, QIdx: integer;
  dci: integer;
  dcs: byte;
  p0, p1: Psmallint;
  w0, w1: Pinteger;
  s0, s1: Pbyte;
  z1, z2, z4, z5: integer;
  tmp0, tmp3, tmp10: integer;
begin
  QIdx := 0;
  // First do the columns
  p0 := @Coef[ 0]; p1 := @Coef[ 2];
  w0 := @Wrksp[ 0]; w1 := @Wrksp[ 2];
  for i := 0 to 1 do
  begin
    if p1^ = 0 then
    begin
      dci := p0^ * Quant[QIdx];
      w0^ := dci; w1^ := dci;
    end else
    begin
      z2 := p0^ * Quant[QIdx + 0 * 8];

      z4 := p1^ * Quant[QIdx + 1 * 8];

      z5 := MultiplyA(z4, FIX_1_175875602AI);

      tmp3 := MultiplyA(z4, FIX_1_501321110AI);
      z1 := MultiplyA(z4, - FIX_0_899976223AI);
      z4 := MultiplyA(z4, - FIX_0_390180644AI);

      Inc(z4, z5);

      tmp0 := z1 + z5;
      Inc(tmp3, z1 + z4);

      w0^ := z2 + tmp3;
      w1^ := z2 - tmp0;

    end;
    // Advance block pointers
    inc(p0); inc(p1);
    inc(w0); inc(w1);
    inc(QIdx);
  end;

  // Next do the rows
  w0 := @Wrksp[0]; w1 := @Wrksp[1];
  s0 := @Sample[0]; s1 := @Sample[1];
  for i := 0 to 1 do
  begin
    if w1^ = 0 then
    begin
      dcs := RangeLimitA(w0^);
      s0^ := dcs; s1^ := dcs;
    end else
    begin
      tmp10 := w0^;

      z4 := w1^;

      z5 := MultiplyA(z4, FIX_1_175875602AI);

      tmp3 := MultiplyA(z4, FIX_1_501321110AI);
      z1 := MultiplyA(z4, - FIX_0_899976223AI);
      z4 := MultiplyA(z4, - FIX_0_390180644AI);

      Inc(z4, z5);

      tmp0 := z1 + z5;
      Inc(tmp3, z1 + z4);

      s0^ := RangeLimitA(tmp10 + tmp3);
      s1^ := RangeLimitA(tmp10 - tmp0);

    end;
    // Advance block pointers
    inc(s0, 2); inc(s1, 2);
    inc(w0, 2); inc(w1, 2);
  end;
end;

procedure InverseDCTIntAccurate1x1(const Coef: TsdCoefBlock; out Sample: TsdSampleBlock;
  const Quant: TsdIntArray64; var Wrksp: TsdIntArray64);
begin
  // Just the DC value to process
  Sample[0] := RangeLimitA(Coef[0] * Quant[0]);
end;

end.
