{ unit sdJpegTypes

  Description:
  This unit provides lowlevel types, records, classes and constants for NativeJpg
  and is only dependent on Delphi units, plus Simdesign's sdDebug.pas

  Author: Nils Haeck M.Sc.
  Copyright (c) 2007 SimDesign B.V.
  More information: www.simdesign.nl or n.haeck@simdesign.nl

  This software may ONLY be used or replicated in accordance with
  the LICENSE found in this source distribution.

}
unit sdJpegTypes;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs;

type

  // allow external CMS to manage colors in the bitmap (client code needs to determine whether the
  // AMap is actually a TBitmap in Windows, in case of NativeJpg.pas)
  TsdJpegExternalCMSEvent = procedure (Sender: TObject; var AMap: TObject) of object;

  TsdJpegScale = (
    jsFull,  // Read the complete image (DC + AC 1..63)
    jsDiv2,  // Read only 1/2 of the image (DC + AC 1..15)
    jsDiv4,  // Read only 1/4 of the image (DC + AC 1..3)
    jsDiv8   // Read only 1/8 of the image (DC only)
  );

  TsdJpegColorSpace = (
    jcAutoDetect,   // Auto-detect the colorspace from the file
    jcGray,         // 1-Channel grayscale
    jcGrayA,        // 1-Channel grayscale with Alpha channel
    jcRGB,          // (standard) RGB
    jcRGBA,         // (standard) RGB with Alpha channel
    jcYCbCr,        // Jpeg Y-Cb-Cr
    jcYCbCrA,       // Jpeg Y-Cb-Cr with Alpha channel
    jcCMYK,         // CMYK
    jcYCbCrK,       // CMYK represented in 4 channels as YCbCrK
    jcYCCK,         // YCCK
    jcPhotoYCC,     // Photo YCC
    jcPhotoYCCA,    // Photo YCCA
    jcITUCieLAB     // ITU G3FAX CieLAB (for use in colour faxes)
  );

  TsdJpegDCTCodingMethod = (
    dmFast,
    dmAccurate
  );

  // Supported encoding methods in this implementation
  TsdJpegEncodingMethod = (
    emUnspecified,
    emBaselineDCT,
    emExtendedDCT,
    emProgressiveDCT
  );

  TsdQuantizationPrecision = (
    qp8bit,
    qp16bit
  );

  TsdJpegQuality = 1..100;

  TsdCoefBlock = array[0..63] of smallint;
  PsdCoefBlock = ^TsdCoefBlock;
  TsdSampleBlock = array[0..63] of byte;
  PsdSampleBlock = ^TsdSampleBlock;

  TsdZigZagArray = array[0..63 + 16] of byte;
  PsdZigZagArray = ^TsdZigZagArray;
  TsdIntArray64 = array[0..63] of integer;


  // Minimum Coded Unit block (MCU)
  TsdMCUBlock = record
    Values: PsdCoefBlock;
    PPred: Psmallint;
    DCTable: integer;
    ACTable: integer;
    BlockIdx: integer;
    MapIdx: integer;
  end;
  PsdMCUBlock = ^TsdMCUBlock;

  // Huffman code
  TsdHuffmanCode = record
    L: integer;    // Symbol length
    Code: integer; // Associated huffman code
    V: integer;    // Value for huffman code
  end;
  PsdHuffmanCode = ^TsdHuffmanCode;

  TsdDHTMarkerInfo = record
    BitLengths: array[0..15] of byte;
    BitValues: array of byte;
    Tc, Th: byte;
  end;
  PsdDHTMarkerInfo = ^TsdDHTMarkerInfo;

  // Lookup table for Huffman decoding. The Huffman code is left-aligned
  // in the table, Len indicates the number of bits to take out of the stream,
  // Value is the associated symbol. If Len = 0, Value indicates an index
  // to a follow-up table (for codelengths > 8)
  TsdHuffmanLookupTable = record
    Len:   array[0..255] of byte;
    Value: array[0..255] of smallint;
  end;
  PsdHuffmanLookupTable = ^TsdHuffmanLookupTable;

  // Used to construct a histogram (frequency count) of encoded huffman symbols
  Tsd8bitHuffmanHistogram = array[0..255] of integer;
  Psd8bitHuffmanHistogram = ^Tsd8bitHuffmanHistogram;

  // Quantization table specified in DQT marker
  TsdQuantizationTable = class(TPersistent)
  public
    // Quantization values Q
    FQuant: array[0..63] of word;
    // Precision P
    FPrecision: TsdQuantizationPrecision;
    // transpose
    procedure Transpose;
  end;

  TsdQuantizationTableList = class(TObjectList)
  private
    function GetItems(Index: integer): TsdQuantizationTable;
  public
    property Items[Index: integer]: TsdQuantizationTable read GetItems; default;
  end;

  // Frame component specified in SOF marker
  TsdFrameComponent = class(TPersistent)
  public
    // Horizontal sampling factor H
    FHorzSampling: integer;
    // Vertical sampling factor V
    FVertSampling: integer;
    // Component identifier C (can be ascii)
    FComponentID: integer;
    // Quantization table destination Tq
    FQTable: integer;
  end;

  TsdFrameComponentList = class(TObjectList)
  private
    function GetItems(Index: integer): TsdFrameComponent;
  public
    property Items[Index: integer]: TsdFrameComponent read GetItems; default;
  end;

  // Scan component specified in SOS marker
  TsdScanComponent = class(TPersistent)
  public
    // Index into frame components list, Cidx
    FComponent: integer;
    // DC entropy table destination Td
    FDCTable: integer;
    // AC entropy table destination Ta
    FACTable: integer;
    // Used as predictor in DC coding
    FPredictor: smallint;
  end;

  TsdScanComponentList = class(TObjectList)
  private
    function GetItems(Index: integer): TsdScanComponent;
  public
    property Items[Index: integer]: TsdScanComponent read GetItems; default;
  end;

  // Holds data for one image component in the frame, provides method
  // to add/extract samples to/from the MCU currently being decoded/encoded
  TsdJpegBlockMap = class(TPersistent)
  private
    FCoef: array of smallint;
    FCoefBackup: array of smallint; // used when adjusting brightness/contrast
    FSample: array of byte;
    FFrame: TsdFrameComponent; // Pointer to frame info
    FHorzBlockCount: integer; // Horizontal block count
    FVertBlockCount: integer; // Vertical block count
    FBlockStride: integer; // number of samples per block
    FScanStride: integer; // width of a scanline
  protected
    procedure CreateMap; virtual;
  public
    procedure SetSize(AHorzMcuCount, AVertMcuCount: integer;
      AFrame: TsdFrameComponent; ABlockStride: integer);
    procedure Resize(AHorzBlockCount, AVertBlockCount: integer);
    procedure ReduceBlockSize(ANewSize: integer);
    // Number of blocks in the MCU belonging to this image
    function McuBlockCount(AScanCount: integer): integer;
    // Total number of blocks in image (size / 8x8)
    function TotalBlockCount: integer;
    function GetCoefPointerMCU(AMcuX, AMcuY, AMcuIdx: integer): pointer;
    function GetCoefPointer(BlockX, BlockY: integer): pointer;
    function GetSamplePointer(BlockX, BlockY: integer): pointer;
    function FirstCoef: pointer;
    function FirstCoefBackup: pointer;
    function HasCoefBackup: boolean;
    procedure MakeCoefBackup;
    procedure ClearCoefBackup;
    procedure SaveRawValues(const AFileName: string);
    property HorzBlockCount: integer read FHorzBlockCount;
    property VertBlockCount: integer read FVertBlockCount;
    property BlockStride: integer read FBlockStride;
    property ScanStride: integer read FScanStride;
    property Frame: TsdFrameComponent read FFrame;
  end;

  TsdBlockMapList = class(TObjectList)
  private
    function GetItems(Index: integer): TsdJpegBlockMap;
  public
    property Items[Index: integer]: TsdJpegBlockMap read GetItems; default;
  end;

  TsdJpegTile = class
  public
    FMcuIndex: integer;
    FStreamPos: int64;
    FBits: cardinal;
    FBitsLeft: integer;
    FPredictors: array of smallint;
  end;

  TsdJpegTileList = class(TObjectList)
  private
    function GetItems(Index: integer): TsdJpegTile;
  public
    function IndexByMcuIndex(AMcuIndex: integer): integer;
    property Items[Index: integer]: TsdJpegTile read GetItems; default;
  end;

  // Collected component data from markers
  TsdJpegInfo = class(TPersistent)
  public
    // Repository of tables, are updated after DQT or DHT markers
    FDCHuffmanTables: TObjectList{TsdHuffmanTableList};
    FACHuffmanTables: TObjectList{TsdHuffmanTableList};
    FQuantizationTables: TsdQuantizationTableList;
    // List of frames
    FFrames: TsdFrameComponentList;
    // List of scans
    FScans: TsdScanComponentList;
    // Number of image components in frame, Nf
    FFrameCount: integer;
    // Number of image components in scan, Ns
    FScanCount: integer;
    // Maximum of all H_i in current scan, Hmax
    FHorzSamplingMax: integer;
    // Maximum of all V_i in current scan, Vmax
    FVertSamplingMax: integer;
    // Restart interval MCU count (0 means disabled), updated after RST marker, Ri
    FRestartInterval: integer;
    // Image width, X
    FWidth: integer;
    // Image Height, Y
    FHeight: integer;
    // Jpeg encoding method
    FEncodingMethod: TsdJpegEncodingMethod;
    // Sample precision in bits for samples, P;
    FSamplePrecision: integer;
    // Start of spectral selection, Ss
    FSpectralStart: integer;
    // End of spectral selection, Se
    FSpectralEnd: integer;
    // Succ Approximation high bitpos, Ah
    FApproxHigh: integer;
    // Succ Approximation low bitpos, Al
    FApproxLow: integer;
    // Width of the MCU block in pixels
    FMcuWidth: integer;
    // Height of the MCU block in pixels
    FMcuHeight: integer;
    // Horizontal MCU count
    FHorzMcuCount: integer;
    // Vertical MCU count
    FVertMcuCount: integer;
    //
    FWaitForDNL: boolean;
    // Width of a tile in pixels during TileMode
    FTileWidth: integer;
    // Height of a tile in pixels during TileMode
    FTileHeight: integer;
    //
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear;
  end;

  TsdJpegMarker = class(TPersistent)
  private
    FMarkerTag: byte;
    FOwner: TComponent;
  protected
    FStream: TMemoryStream;
    FCodingInfo: TsdJpegInfo;
    function GetMarkerName: string; virtual;
    procedure StoreData(S: TStream; Size: integer);
    procedure DebugSample(S: TStream; Size: integer);
  public
    constructor Create(ACodingInfo: TsdJpegInfo; ATag: byte); virtual;
    destructor Destroy; override;
    class function GetByte(S: TStream): byte;
    class function GetWord(S: TStream): word;
    class procedure PutByte(S: TStream; B: byte);
    class procedure PutWord(S: TStream; W: word);
    class function GetSignature: AnsiString; virtual;
    class function GetMarker: Byte; virtual;
    class function IsSegment(AMarker: Byte; AStream: TStream): Boolean; virtual;
    procedure LoadFromStream(S: TStream; Size: integer);
    procedure SaveToStream(S: TStream);
    procedure ReadMarker; virtual;
    procedure WriteMarker; virtual;
    // Any of the mkXXXX constants defined in sdJpegConsts
    property MarkerTag: byte read FMarkerTag;
    // 3letter description of the marker or the hex description
    property MarkerName: string read GetMarkerName;
    // marker data stored in its stream
    property Stream: TMemoryStream read FStream;
    // Reference to owner TsdJpegFormat, set when adding to the list, and used
    // for DoDebugOut not used anymore
    property Owner: TComponent read FOwner write FOwner;
  end;

  TsdJpegMarkerSet = set of byte;

  TsdJpegMarkerClass = class of TsdJpegMarker;

  TsdJpegMarkerList = class(TObjectList)
  private
    FOwner: TComponent;// Reference to owner TsdJpegFormat
    function GetItems(Index: integer): TsdJpegMarker;
  public
    constructor Create(AOwner: TComponent);
    function ByTag(AMarkerTag: byte): TsdJpegMarker;
    function ByClass(AClass: TsdJpegMarkerClass): TsdJpegMarker;
    function HasMarker(ASet: TsdJpegMarkerSet): boolean;
    procedure RemoveMarkers(ASet: TsdJpegMarkerSet);
    procedure InsertAfter(ASet: TsdJpegMarkerSet; AMarker: TsdJpegMarker);
    procedure Add(AItem: TObject);
    property Items[Index: integer]: TsdJpegMarker read GetItems; default;
  end;

  TsdAPPnMarker = class(TsdJpegMarker)
  protected
    function GetMarkerName: string; override;
  public
    procedure ReadMarker; override;
  end;

  TsdICCProfileMarker = class(TsdAppnMarker)
  private
    FIsValid: boolean;
    FCurrentMarker: byte;
    FMarkerCount: byte;
    function GetCurrentMarker: byte;
    function GetMarkerCount: byte;
    function GetData: pointer;
    function GetDataLength: integer;
    procedure SetDataLength(const Value: integer);
    procedure SetCurrentMarker(const Value: byte);
    procedure SetMarkerCount(const Value: byte);
  protected
    function GetIsValid: boolean;
    function GetMarkerName: string; override;
  public
    class function GetSignature: AnsiString; override;
    class function GetMarker: Byte; override;
    property IsValid: boolean read GetIsValid;
    property CurrentMarker: byte read GetCurrentMarker write SetCurrentMarker;
    property MarkerCount: byte read GetMarkerCount write SetMarkerCount;
    property Data: pointer read GetData;
    property DataLength: integer read GetDataLength write SetDataLength;
  end;

  // ICC color profile class
  TsdJpegICCProfile = class(TPersistent)
  private
    FData: array of byte;
    function GetData: pointer;
    function GetDataLength: integer;
  public
    procedure LoadFromStream(S: TStream);
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    procedure SaveToStream(S: TStream);
    procedure ReadFromMarkerList(AList: TsdJpegMarkerList);
    procedure WriteToMarkerList(AList: TsdJpegMarkerList);
    property Data: pointer read GetData;
    property DataLength: integer read GetDataLength;
  end;
const

  // Jpeg markers defined in Table B.1
  mkNone  = 0;

  mkSOF0  = $c0; // Baseline DCT + Huffman encoding
  mkSOF1  = $c1; // Extended Sequential DCT + Huffman encoding
  mkSOF2  = $c2; // Progressive DCT + Huffman encoding
  mkSOF3  = $c3; // Lossless (sequential) + Huffman encoding

  mkSOF5  = $c5; // Differential Sequential DCT + Huffman encoding
  mkSOF6  = $c6; // Differential Progressive DCT + Huffman encoding
  mkSOF7  = $c7; // Differential Lossless (sequential) + Huffman encoding

  mkJPG   = $c8; // Reserved for Jpeg extensions
  mkSOF9  = $c9; // Extended Sequential DCT + Arithmetic encoding
  mkSOF10 = $ca; // Progressive DCT + Arithmetic encoding
  mkSOF11 = $cb; // Lossless (sequential) + Arithmetic encoding

  mkSOF13 = $cd; // Differential Sequential DCT + Arithmetic encoding
  mkSOF14 = $ce; // Differential Progressive DCT + Arithmetic encoding
  mkSOF15 = $cf; // Differential Lossless (sequential) + Arithmetic encoding

  mkDHT   = $c4; // Define Huffman Table

  mkDAC   = $cc; // Define Arithmetic Coding

  mkRST0  = $d0; // Restart markers
  mkRST1  = $d1;
  mkRST2  = $d2;
  mkRST3  = $d3;
  mkRST4  = $d4;
  mkRST5  = $d5;
  mkRST6  = $d6;
  mkRST7  = $d7;

  mkSOI   = $d8; // Start of Image
  mkEOI   = $d9; // End of Image
  mkSOS   = $da; // Start of Scan
  mkDQT   = $db; // Define Quantization Table
  mkDNL   = $dc; // Define Number of Lines
  mkDRI   = $dd; // Define Restart Interval
  mkDHP   = $de; // Define Hierarchical Progression
  mkEXP   = $df; // Expand reference components

  // For APPn markers see:
  // http://www.ozhiker.com/electronics/pjmt/jpeg_info/app_segments.html

  mkAPP0  = $e0; // APPn markers - APP0 = JFIF
  mkAPP1  = $e1; //                APP1 = EXIF or XMP
  mkAPP2  = $e2; //                ICC colour profile
  mkAPP3  = $e3;
  mkAPP4  = $e4;
  mkAPP5  = $e5;
  mkAPP6  = $e6;
  mkAPP7  = $e7;
  mkAPP8  = $e8;
  mkAPP9  = $e9;
  mkAPP10 = $ea;
  mkAPP11 = $eb;
  mkAPP12 = $ec;
  mkAPP13 = $ed; //                APP13 = IPTC or Adobe IRB
  mkAPP14 = $ee; //                APP14 = Adobe
  mkAPP15 = $ef;

  mkJPG0  = $f0; // JPGn markers - reserved for JPEG extensions
  mkJPG13 = $fd;
  mkCOM   = $fe; // Comment

  mkTEM   = $01; // Reserved for temporary use

  cColorSpaceNames: array[TsdJpegColorSpace] of AnsiString =
  ('AutoDetect', 'Gray', 'GrayA', 'RGB', 'RGBA', 'YCbCr', 'YCbCrA',
   'CMYK', 'CMYK as YCbCrK', 'YCCK', 'PhotoYCC', 'PhotoYCCA', 'ITU CieLAB');

   cDefaultJpgCompressionQuality = 80;

  // This matrix maps zigzag position to the left/right
  // top/down normal position inside the 8x8 block.
  cJpegInverseZigZag1x1: TsdZigZagArray =
    ( 0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0);

  cJpegInverseZigZag2x2: TsdZigZagArray =
    ( 0,  1,  2,  0,  3,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0);

  cJpegInverseZigZag4x4: TsdZigZagArray =
    ( 0,  1,  4,  8,  5,  2,  3,  6,
      9, 12,  0, 13, 10,  7,  0,  0,
      0, 11, 14,  0,  0,  0,  0,  0,
     15,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0);

  cJpegInverseZigZag8x8: TsdZigZagArray =
    ( 0,  1,  8, 16,  9,  2,  3, 10,
     17, 24, 32, 25, 18, 11,  4,  5,
     12, 19, 26, 33, 40, 48, 41, 34,
     27, 20, 13,  6,  7, 14, 21, 28,
     35, 42, 49, 56, 57, 50, 43, 36,
     29, 22, 15, 23, 30, 37, 44, 51,
     58, 59, 52, 45, 38, 31, 39, 46,
     53, 60, 61, 54, 47, 55, 62, 63,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0);

  cJpegForwardZigZag8x8: TsdZigZagArray =
    ( 0,  1,  5,  6, 14, 15, 27, 28,
      2,  4,  7, 13, 16, 26, 29, 42,
      3,  8, 12, 17, 25, 30, 41, 43,
      9, 11, 18, 24, 31, 40, 44, 53,
     10, 19, 23, 32, 39, 45, 52, 54,
     20, 22, 33, 38, 46, 51, 55, 60,
     21, 34, 37, 47, 50, 56, 59, 61,
     35, 36, 48, 49, 57, 58, 62, 63,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0);

  cJpegNaturalZigZag8x8: TsdZigZagArray =
    ( 0,  1,  2,  3,  4,  5,  6,  7,
      8,  9, 10, 11, 12, 13, 14, 15,
     16, 17, 18, 19, 20, 21, 22, 23,
     24, 25, 26, 27, 28, 29, 30, 31,
     32, 33, 34, 35, 36, 37, 38, 39,
     40, 41, 42, 43, 44, 45, 46, 47,
     48, 49, 50, 51, 52, 53, 54, 55,
     56, 57, 58, 59, 60, 61, 62, 63,
      0,  0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,  0);

  // entry n equals 1 shl (n-1)
  cExtendTest: array[0..15] of integer =
    ($0000, $0001, $0002, $0004, $0008, $0010, $0020, $0040,
     $0080, $0100, $0200, $0400, $0800, $1000, $2000, $4000);

  // entry n equals (-1 shl n) + 1
  cExtendOffset: array[0..15] of integer =
   (0, ((-1) shl 1 ) + 1, ((-1) shl 2 ) + 1, ((-1) shl 3 ) + 1, ((-1) shl 4 ) + 1,
       ((-1) shl 5 ) + 1, ((-1) shl 6 ) + 1, ((-1) shl 7 ) + 1, ((-1) shl 8 ) + 1,
       ((-1) shl 9 ) + 1, ((-1) shl 10) + 1, ((-1) shl 11) + 1, ((-1) shl 12) + 1,
       ((-1) shl 13) + 1, ((-1) shl 14) + 1, ((-1) shl 15) + 1);

  // These are the sample quantization tables given in JPEG spec section K.1.
  // The spec says that the values given produce "good" quality, and
  // when divided by 2, "very good" quality.
  cStdLuminanceQuantTbl: TsdIntArray64 =
   (16,  11,  10,  16,  24,  40,  51,  61,
    12,  12,  14,  19,  26,  58,  60,  55,
    14,  13,  16,  24,  40,  57,  69,  56,
    14,  17,  22,  29,  51,  87,  80,  62,
    18,  22,  37,  56,  68, 109, 103,  77,
    24,  35,  55,  64,  81, 104, 113,  92,
    49,  64,  78,  87, 103, 121, 120, 101,
    72,  92,  95,  98, 112, 100, 103,  99);

  cStdChrominanceQuantTbl: TsdIntArray64 =
   (17,  18,  24,  47,  99,  99,  99,  99,
    18,  21,  26,  66,  99,  99,  99,  99,
    24,  26,  56,  99,  99,  99,  99,  99,
    47,  66,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99);

  // These are standard Huffman tables for general use
  cHuffmanBitsDcLum: array[0..15] of byte =
    (0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0);
  cHuffmanValDCLum: array[0..11] of byte =
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);

  cHuffmanBitsDCChrom: array[0..15] of byte =
    (0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0);
  cHuffmanValDCChrom: array[0..11] of byte =
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 );

  const cHuffmanBitsACLum: array[0..15] of byte =
    (0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, $7d);
  const cHuffmanValACLum: array[0..161] of byte =
    ( $01, $02, $03, $00, $04, $11, $05, $12,
      $21, $31, $41, $06, $13, $51, $61, $07,
      $22, $71, $14, $32, $81, $91, $a1, $08,
      $23, $42, $b1, $c1, $15, $52, $d1, $f0,
      $24, $33, $62, $72, $82, $09, $0a, $16,
      $17, $18, $19, $1a, $25, $26, $27, $28,
      $29, $2a, $34, $35, $36, $37, $38, $39,
      $3a, $43, $44, $45, $46, $47, $48, $49,
      $4a, $53, $54, $55, $56, $57, $58, $59,
      $5a, $63, $64, $65, $66, $67, $68, $69,
      $6a, $73, $74, $75, $76, $77, $78, $79,
      $7a, $83, $84, $85, $86, $87, $88, $89,
      $8a, $92, $93, $94, $95, $96, $97, $98,
      $99, $9a, $a2, $a3, $a4, $a5, $a6, $a7,
      $a8, $a9, $aa, $b2, $b3, $b4, $b5, $b6,
      $b7, $b8, $b9, $ba, $c2, $c3, $c4, $c5,
      $c6, $c7, $c8, $c9, $ca, $d2, $d3, $d4,
      $d5, $d6, $d7, $d8, $d9, $da, $e1, $e2,
      $e3, $e4, $e5, $e6, $e7, $e8, $e9, $ea,
      $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8,
      $f9, $fa );

  cHuffmanBitsACChrom: array[0..15] of byte =
    (0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, $77);
  cHuffmanValACChrom: array[0..161] of byte =
    ( $00, $01, $02, $03, $11, $04, $05, $21,
      $31, $06, $12, $41, $51, $07, $61, $71,
      $13, $22, $32, $81, $08, $14, $42, $91,
      $a1, $b1, $c1, $09, $23, $33, $52, $f0,
      $15, $62, $72, $d1, $0a, $16, $24, $34,
      $e1, $25, $f1, $17, $18, $19, $1a, $26,
      $27, $28, $29, $2a, $35, $36, $37, $38,
      $39, $3a, $43, $44, $45, $46, $47, $48,
      $49, $4a, $53, $54, $55, $56, $57, $58,
      $59, $5a, $63, $64, $65, $66, $67, $68,
      $69, $6a, $73, $74, $75, $76, $77, $78,
      $79, $7a, $82, $83, $84, $85, $86, $87,
      $88, $89, $8a, $92, $93, $94, $95, $96,
      $97, $98, $99, $9a, $a2, $a3, $a4, $a5,
      $a6, $a7, $a8, $a9, $aa, $b2, $b3, $b4,
      $b5, $b6, $b7, $b8, $b9, $ba, $c2, $c3,
      $c4, $c5, $c6, $c7, $c8, $c9, $ca, $d2,
      $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da,
      $e2, $e3, $e4, $e5, $e6, $e7, $e8, $e9,
      $ea, $f2, $f3, $f4, $f5, $f6, $f7, $f8,
      $f9, $fa );

  // Motion Jpeg DHT segment
  cMjpgDHTSeg: packed array[0..415] of byte = (
    $00, $00, $01, $05, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00,
    $00, $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $01,
    $00, $03, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00,

    $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $10, $00,
    $02, $01, $03, $03, $02, $04, $03, $05, $05, $04, $04, $00, $00, $01, $7D,
    $01, $02, $03, $00, $04, $11, $05, $12, $21, $31, $41, $06, $13, $51, $61,
    $07, $22, $71, $14, $32, $81, $91, $A1, $08, $23, $42, $B1, $C1, $15, $52,
    $D1, $F0, $24, $33, $62, $72, $82, $09, $0A, $16, $17, $18, $19, $1A, $25,
    $26, $27, $28, $29, $2A, $34, $35, $36, $37, $38, $39, $3A, $43, $44, $45,
    $46, $47, $48, $49, $4A, $53, $54, $55, $56, $57, $58, $59, $5A, $63, $64,

    $65, $66, $67, $68, $69, $6A, $73, $74, $75, $76, $77, $78, $79, $7A, $83,
    $84, $85, $86, $87, $88, $89, $8A, $92, $93, $94, $95, $96, $97, $98, $99,
    $9A, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $B2, $B3, $B4, $B5, $B6,
    $B7, $B8, $B9, $BA, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $D2, $D3,
    $D4, $D5, $D6, $D7, $D8, $D9, $DA, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8,
    $E9, $EA, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $11, $00, $02,
    $01, $02, $04, $04, $03, $04, $07, $05, $04, $04, $00, $01, $02, $77, $00,

    $01, $02, $03, $11, $04, $05, $21, $31, $06, $12, $41, $51, $07, $61, $71,
    $13, $22, $32, $81, $08, $14, $42, $91, $A1, $B1, $C1, $09, $23, $33, $52,
    $F0, $15, $62, $72, $D1, $0A, $16, $24, $34, $E1, $25, $F1, $17, $18, $19,
    $1A, $26, $27, $28, $29, $2A, $35, $36, $37, $38, $39, $3A, $43, $44, $45,
    $46, $47, $48, $49, $4A, $53, $54, $55, $56, $57, $58, $59, $5A, $63, $64,
    $65, $66, $67, $68, $69, $6A, $73, $74, $75, $76, $77, $78, $79, $7A, $82,
    $83, $84, $85, $86, $87, $88, $89, $8A, $92, $93, $94, $95, $96, $97, $98,

    $99, $9A, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $B2, $B3, $B4, $B5,
    $B6, $B7, $B8, $B9, $BA, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $D2,
    $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $E2, $E3, $E4, $E5, $E6, $E7, $E8,
    $E9, $EA, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA);

resourcestring

  sInternalError                   = 'Internal error';
  sUnsupportedEncoding             = 'Unsupported encoding: SOF%d';
  sMarkerExpected                  = 'Jpeg Marker expected';
  sUnsupportedBitsPerSample        = 'Unsupported bits per sample';
  sInvalidTableClass               = 'Invalid table class in DHT marker';
  sInputStreamChopped              = 'Input stream prematurely chopped';
  sUnexpectedMarkerInEncodedStream = 'Unexpected marker in encoded stream';
  sInvalidFrameRef                 = 'Invalid frame reference in scan component';
  sNoColorTransformation           = 'No color transformation available for current settings';
  sNoDCTCoefficentsAvailable       = 'No DCT coefficients available (compress first)';
  sOperationOnlyFor8x8             = 'Operation can only be performed with LoadScale = jsFull';
  sBitmapIsEmptyCannotSave         = 'Bitmap is empty; cannot save';
  sInvalidFormatForSelectedCS      = 'Invalid bitmap format for selected color space';
  sCommentCannotBeSet              = 'Comment cannot be set before assigning bitmap';
  sDNLMarkerExpected               = 'DNL marker expected';
  sUnsupportedColorSpace           = 'Unsupported color space';
  sOnProvideStripMustBeAssigned    = 'OnProvideStrip must be assigned';
  sOnCreateMapMustBeAssigned       = 'OnCreateMap must be assigned';
  sCannotUseTileMode               = 'Cannot use tilemode with progressive jpeg';
  sRangeErrorInTileLoading         = 'Range error in tiled loading: make sure to select tilemode';


// general functions

function IntMin(i1, i2: integer): integer;

// comparison function
function CompareInteger(Int1, Int2: integer): integer;

// divisor based on scale
function sdGetDivisor(AScale: TsdJpegScale): integer;

implementation

{ TsdQuantizationTable }

procedure TsdQuantizationTable.Transpose;
var
  x, y, i, j: integer;
  Temp: word;
begin
  // transpose indices in table, but we must do this with the forward zigzag
  for y := 0 to 6 do
    for x := y + 1 to 7 do
    begin
      i := cJpegForwardZigZag8x8[x + y * 8];
      j := cJpegForwardZigZag8x8[x * 8 + y];
      Temp := FQuant[i];
      FQuant[i] := FQuant[j];
      FQuant[j] := Temp;
    end;
end;

{ TsdQuantizationTableList }

function TsdQuantizationTableList.GetItems(Index: integer): TsdQuantizationTable;
begin
  if Index >= Count then Count := Index + 1;
  Result := Get(Index);
  if not assigned(Result) then
  begin
    Result := TsdQuantizationTable.Create;
    Put(Index, Result);
  end;
end;

{ TsdFrameComponentList }

function TsdFrameComponentList.GetItems(Index: integer): TsdFrameComponent;
begin
  if Index >= Count then Count := Index + 1;
  Result := Get(Index);
  if not assigned(Result) then
  begin
    Result := TsdFrameComponent.Create;
    Put(Index, Result);
  end;
end;

{ TsdScanComponentList }

function TsdScanComponentList.GetItems(Index: integer): TsdScanComponent;
begin
  if Index >= Count then Count := Index + 1;
  Result := Get(Index);
  if not assigned(Result) then
  begin
    Result := TsdScanComponent.Create;
    Put(Index, Result);
  end;
end;

{ TsdJpegBlockMap }

procedure TsdJpegBlockMap.ClearCoefBackup;
begin
  SetLength(FCoefBackup, 0);
end;

procedure TsdJpegBlockMap.CreateMap;
var
  Count: integer;
begin
  FScanStride := FHorzBlockCount * FBlockStride;
  Count := FScanStride * FVertBlockCount;
  SetLength(FCoef, Count);
  SetLength(FSample, Count);
  // Clear the coefficients (since the decoder doesn't always reset them to 0)
  if Count > 0 then
    FillChar(FCoef[0], Count * SizeOf(smallint), 0);
  // Clear backup
  ClearCoefBackup;  
end;

function TsdJpegBlockMap.FirstCoef: pointer;
begin
  Result := @FCoef[0];
end;

function TsdJpegBlockMap.FirstCoefBackup: pointer;
begin
  Result := @FCoefBackup[0];
end;

function TsdJpegBlockMap.GetCoefPointer(BlockX, BlockY: integer): pointer;
begin
  Result := @FCoef[BlockX * FBlockStride + BlockY * FScanStride];
end;

function TsdJpegBlockMap.GetCoefPointerMCU(AMcuX, AMcuY, AMcuIdx: integer): pointer;
var
  X, Y: integer;
begin
  X := FFrame.FHorzSampling * AMcuX;
  Y := FFrame.FVertSampling * AMcuY;
  while AMcuIdx >= FFrame.FHorzSampling do
  begin
    inc(Y);
    dec(AMcuIdx, FFrame.FHorzSampling);
  end;
  inc(X, AMcuIdx);
  Result := @FCoef[X * FBlockStride + Y * FScanStride];
end;

function TsdJpegBlockMap.GetSamplePointer(BlockX, BlockY: integer): pointer;
begin
  Result := @FSample[BlockX * FBlockStride + BlockY * FScanStride];
end;

function TsdJpegBlockMap.HasCoefBackup: boolean;
begin
  Result := length(FCoefBackup) > 0;
end;

procedure TsdJpegBlockMap.MakeCoefBackup;
var
  Count: integer;
begin
  Count := length(FCoef);
  if Count <= 0 then exit;
  SetLength(FCoefBackup, Count);
  Move(FCoef[0], FCoefBackup[0], Count * SizeOf(smallint));
end;

function TsdJpegBlockMap.McuBlockCount(AScanCount: integer): integer;
begin
  if AScanCount = 1 then
    Result := 1
  else
    Result := FFrame.FHorzSampling * FFrame.FVertSampling;
end;

procedure TsdJpegBlockMap.ReduceBlockSize(ANewSize: integer);
var
  i, j, Count, Stride: integer;
  Sc, Dc: Psmallint;
  Ss, Ds: Pbyte;
begin
  if FBlockstride <> 64 then
    exit;

  Count := FHorzBlockCount * FVertBlockCount;

  // coefs
  Sc := @FCoef[0]; Dc := Sc;
  Stride := ANewSize * SizeOf(smallint);
  for i := 0 to Count - 1 do
  begin
    for j := 0 to 7 do
    begin
      if j < ANewSize then
      begin
        Move(Sc^, Dc^, Stride);
        inc(Dc, ANewSize);
      end;
      inc(Sc, 8);
    end;
  end;

  // samples
  Ss := @FSample[0]; Ds := Ss;
  Stride := ANewSize * SizeOf(byte);
  for i := 0 to Count - 1 do
  begin
    for j := 0 to 7 do
    begin
      if j < ANewSize then
      begin
        Move(Ss^, Ds^, Stride);
        inc(Ds, ANewSize);
      end;
      inc(Ss, 8);
    end;
  end;
  FBlockStride := ANewSize * ANewSize;
  Resize(FHorzBlockCount, FVertBlockCount);
end;

procedure TsdJpegBlockMap.Resize(AHorzBlockCount, AVertBlockCount: integer);
var
  Count: integer;
begin
  FHorzBlockCount := AHorzBlockCount;
  FVertBlockCount := AVertBlockCount;
  FScanStride := FHorzBlockCount * FBlockStride;
  Count := FScanStride * FVertBlockCount;
  SetLength(FCoef, Count);
  SetLength(FSample, Count);
  SetLength(FCoefBackup, 0);
end;

procedure TsdJpegBlockMap.SaveRawValues(const AFileName: string);
var
  i, x, y: integer;
  F: TFileStream;
  Block: PsdCoefBlock;

  procedure WriteS(const S: string);
  begin
    F.Write(S[1], ByteLength(S));
  end;

begin
  F := TFileStream.Create(AFileName, fmCreate);
  try
    for y := 0 to FVertBlockCount - 1 do
    begin
      WriteS(Format('Line %d:', [y]) + #13#10);
      for x := 0 to FHorzBlockCount - 1 do
      begin
        WriteS(Format(' Block %d:', [x]) + #13#10);
        WriteS(' ');
        Block := GetCoefPointer(x, y);
        for i := 0 to 63 do
          WriteS(IntToStr(Block[i]) + ' ');
        WriteS(#13#10);
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TsdJpegBlockMap.SetSize(AHorzMcuCount, AVertMcuCount: integer;
  AFrame: TsdFrameComponent; ABlockStride: integer);
begin
  FFrame := AFrame;
  FBlockStride := ABlockStride;

  // Determine block dimensions
  FHorzBlockCount := AHorzMcuCount * FFrame.FHorzSampling;
  FVertBlockCount := AVertMcuCount * FFrame.FVertSampling;

  // Assume the data is valid, we can create the map
  CreateMap;
end;

function TsdJpegBlockMap.TotalBlockCount: integer;
begin
  Result := FHorzBlockCount * FVertBlockCount;
end;

{ TsdBlockMapList }

function TsdBlockMapList.GetItems(Index: integer): TsdJpegBlockMap;
begin
  if Index >= Count then
    Count := Index + 1;
  Result := Get(Index);
  if not assigned(Result) then
  begin
    Result := TsdJpegBlockMap.Create;
    Put(Index, Result);
  end;
end;

{ TsdJpegTileList }

function TsdJpegTileList.GetItems(Index: integer): TsdJpegTile;
begin
  Result := Get(Index);
end;

function TsdJpegTileList.IndexByMcuIndex(AMcuIndex: integer): integer;
var
  Min, Max: integer;
begin
  // Find position for insert - binary method
  Min := 0;
  Max := Count;
  while Min < Max do begin
    Result := (Min + Max) div 2;
    case CompareInteger(Items[Result].FMcuIndex, AMcuIndex) of
    -1: Min := Result + 1;
     0: exit;
     1: Max := Result;
    end;
  end;
  Result := Min;
end;

{ TsdJpegInfo }

procedure TsdJpegInfo.Clear;
begin
  // Clear all data in Info
  FDCHuffmanTables.Clear;
  FACHuffmanTables.Clear;
  FQuantizationTables.Clear;
  FFrames.Clear;
  FScans.Clear;

  FFrameCount := 0;
  FScanCount := 0;
  FHorzSamplingMax := 0;
  FVertSamplingMax := 0;
  FRestartInterval := 0;
  FWidth := 0;
  FHeight := 0;
  FEncodingMethod := emUnspecified;
  FSamplePrecision := 0;
  FSpectralStart := 0;
  FSpectralEnd := 0;
  FApproxHigh := 0;
  FApproxLow := 0;
  FWaitForDNL := False;
end;

constructor TsdJpegInfo.Create;
begin
  inherited Create;
  FDCHuffmanTables := TObjectList.Create;
  FACHuffmanTables := TObjectList.Create;
  FQuantizationTables := TsdQuantizationTableList.Create;
  FFrames := TsdFrameComponentList.Create;
  FScans := TsdScanComponentList.Create;
end;

destructor TsdJpegInfo.Destroy;
begin
  FreeAndNil(FDCHuffmanTables);
  FreeAndNil(FACHuffmanTables);
  FreeAndNil(FQuantizationTables);
  FreeAndNil(FFrames);
  FreeAndNil(FScans);
  inherited;
end;

{ TsdJpegMarker }

constructor TsdJpegMarker.Create(ACodingInfo: TsdJpegInfo; ATag: byte);
begin
  inherited Create;
  FCodingInfo := ACodingInfo;
  FMarkerTag := ATag;
  FStream := TMemoryStream.Create;
end;

//TODO: Needed?
procedure TsdJpegMarker.DebugSample(S: TStream; Size: integer);
var
  i: integer;
  B: byte;
  Msg: string;
begin
  Msg := '';
  S.Position := 0;
  for i := 0 to IntMin(Size, 32) - 1 do
  begin
    S.Read(B, 1);
    Msg := Msg + IntToHex(B, 2);
    if i mod 4 = 3 then
      Msg := Msg + '-';
  end;
  S.Position := 0;
end;

destructor TsdJpegMarker.Destroy;
begin
  FreeAndNil(FStream);
  inherited;
end;

class function TsdJpegMarker.GetByte(S: TStream): byte;
begin
  S.Read(Result, 1);
end;

function TsdJpegMarker.GetMarkerName: string;
begin
  Result := IntToHex(FMarkerTag, 2);
end;

class function TsdJpegMarker.GetWord(S: TStream): word;
var
  W: word;
begin
  S.Read(W, 2);
  Result := Swap(W);
end;

procedure TsdJpegMarker.LoadFromStream(S: TStream; Size: integer);
begin
  // by default, we copy the marker data to the marker stream,
  // overriding methods may use other means
  StoreData(S, Size);
  // Read the marker (default does nothing but is overridden in descendants)
  ReadMarker;
end;

class procedure TsdJpegMarker.PutByte(S: TStream; B: byte);
begin
  S.Write(B, 1);
end;

class procedure TsdJpegMarker.PutWord(S: TStream; W: word);
begin
  W := Swap(W);
  S.Write(W, 2);
end;

procedure TsdJpegMarker.ReadMarker;
begin
// default does nothing
end;

procedure TsdJpegMarker.SaveToStream(S: TStream);
begin
  // the default SaveToStream method. If the marker was modified, the FStream was already
  // updated with .WriteMarker
  if FStream.Size > 0 then
  begin
    FStream.Position := 0;
    S.CopyFrom(FStream, FStream.Size);
  end;
end;

procedure TsdJpegMarker.StoreData(S: TStream; Size: integer);
begin
  // We store the data for later use
  FStream.Clear;
  FStream.CopyFrom(S, Size);
  FStream.Position := 0;
end;

procedure TsdJpegMarker.WriteMarker;
begin
// default does nothing
end;

// Added by Dec begin
class function TsdJpegMarker.GetSignature: AnsiString;
begin
  Result := '';
end;

class function TsdJpegMarker.GetMarker: Byte;
begin
  Result := 0;
end;

class function TsdJpegMarker.IsSegment(AMarker: Byte; AStream: TStream): Boolean;
var
  S: Word;
  Sign: AnsiString;
begin
  Result := AMarker = GetMarker;
  if not Result then
    Exit;
  Sign := GetSignature;
  if Sign = '' then
    Exit;
  S := GetWord(AStream);
  Result := S >= Length(Sign);
  if not Result then
    Exit;
  AStream.ReadBuffer(Sign[1], Length(Sign));
  Result := Sign = GetSignature;
end;
// Added by Dec end

{ TsdJpegMarkerList }

procedure TsdJpegMarkerList.Add(AItem: TObject);
begin
  if not (AItem is TsdJpegMarker) then
  begin
    raise Exception.Create('not a TsdJpegMarker');
  end;
  inherited Add(AItem);
  TsdJpegMarker(AItem).Owner := FOwner;
end;

function TsdJpegMarkerList.ByTag(AMarkerTag: byte): TsdJpegMarker;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i].MarkerTag = AMarkerTag then
    begin
      Result := Items[i];
      exit;
    end;
  end;
end;

function TsdJpegMarkerList.ByClass(AClass: TsdJpegMarkerClass): TsdJpegMarker;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Items[i] is AClass then
    begin
      Result := Items[i];
      exit;
    end;
  end;
end;

constructor TsdJpegMarkerList.Create(AOwner: TComponent);
begin
  inherited Create(True);
  FOwner := AOwner;
end;

function TsdJpegMarkerList.GetItems(Index: integer): TsdJpegMarker;
begin
  Result := Get(Index);
end;

function TsdJpegMarkerList.HasMarker(ASet: TsdJpegMarkerSet): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    if Items[i].MarkerTag in ASet then
    begin
      Result := True;
      exit;
    end;
  end;
end;

procedure TsdJpegMarkerList.InsertAfter(ASet: TsdJpegMarkerSet; AMarker: TsdJpegMarker);
var
  i: integer;
begin
  for i := Count - 1 downto 0 do
  begin
    if Items[i].MarkerTag in ASet then
    begin
      Insert(i + 1, AMarker);
      exit;
    end;
  end;

  // If none found, just add the marker
  Add(AMarker);
end;

procedure TsdJpegMarkerList.RemoveMarkers(ASet: TsdJpegMarkerSet);
var
  i: integer;
begin
  for i := Count - 1 downto 0 do
    if Items[i].MarkerTag in ASet then
      Delete(i);
end;

{ TsdAPPnMarker }

procedure TsdAPPnMarker.ReadMarker;
begin
  // show first bytes as hex
  DebugSample(FStream, FStream.Size);
end;

function TsdAPPnMarker.GetMarkerName: string;
begin
  Result := Format('APP%d', [FMarkerTag and $0F]);
end;

{ TsdICCProfileMarker }

class function TsdICCProfileMarker.GetSignature: AnsiString;
begin
  Result := 'ICC_PROFILE'#0;
end;

class function TsdICCProfileMarker.GetMarker: Byte;
begin
  Result := $E2;
end;

function TsdICCProfileMarker.GetCurrentMarker: byte;
begin
  GetIsValid;
  Result := FCurrentMarker;
end;

function TsdICCProfileMarker.GetData: pointer;
var
  PData: PByte;
begin
  GetIsValid;
  if not FIsValid then
    Result := nil
  else
  begin
    PData := FStream.Memory;
    inc(PData, 14);
    Result := PData;
  end;
end;

function TsdICCProfileMarker.GetDataLength: integer;
begin
  GetIsValid;
  if not FIsValid then
    Result := 0
  else
    Result := FStream.Size - 14;
end;

function TsdICCProfileMarker.GetIsValid: boolean;
var
  Magic: array[0..11] of AnsiChar;
begin
  Result := False;
  if FIsValid then
  begin
    Result := True;
    exit;
  end;
  FStream.Position := 0;
  FStream.Read(Magic, 12);
  FIsValid := (Magic = 'ICC_PROFILE');
  if not FIsValid then
    exit;
  Result := True;
  FCurrentMarker := GetByte(FStream);
  FMarkerCount := GetByte(FStream);
  // ICC-Profile data follows
end;

function TsdICCProfileMarker.GetMarkerCount: byte;
begin
  GetIsValid;
  Result := FMarkerCount;
end;

procedure TsdICCProfileMarker.SetCurrentMarker(const Value: byte);
begin
  FStream.Position := 12;
  PutByte(FStream, Value);
  FCurrentMarker := Value;
end;

procedure TsdICCProfileMarker.SetDataLength(const Value: integer);
var
  Magic: AnsiString;
begin
  FStream.Size := Value + 14;
  FStream.Position := 0;
  Magic := 'ICC_PROFILE'#0;
  FStream.Write(Magic[1], 12);
end;

procedure TsdICCProfileMarker.SetMarkerCount(const Value: byte);
begin
  FStream.Position := 13;
  PutByte(FStream, Value);
  FMarkerCount := Value;
end;

function TsdICCProfileMarker.GetMarkerName: string;
begin
  Result := 'ICCProfile';
end;

{ TsdJpegICCProfile }

function TsdJpegICCProfile.GetData: pointer;
begin
  if length(FData) > 0 then
    Result := @FData[0]
  else
    Result := nil;
end;

function TsdJpegICCProfile.GetDataLength: integer;
begin
  Result := length(FData);
end;

procedure TsdJpegICCProfile.LoadFromFile(const AFileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TsdJpegICCProfile.LoadFromStream(S: TStream);
begin
  SetLength(FData, S.Size);
  S.Position := 0;
  S.Read(FData[0], S.Size);
end;

procedure TsdJpegICCProfile.ReadFromMarkerList(AList: TsdJpegMarkerList);
var
  i, j, DataLen, MarkerCount: integer;
  Markers: array of TsdICCProfileMarker;
  M: TsdICCProfileMarker;
  P: PByte;
begin
  // Determine total length and get list of markers
  DataLen := 0;
  MarkerCount := 0;
  SetLength(Markers, AList.Count);
  for i := 0 to AList.Count - 1 do
    if AList[i] is TsdICCProfileMarker then
    begin
      M := TsdICCProfileMarker(AList[i]);
      if not M.IsValid then continue;
      inc(DataLen, M.DataLength);
      Markers[MarkerCount] := M;
      inc(MarkerCount);
    end;
  if DataLen <= 0 then exit;
  // Sort markers by index
  for i := 0 to MarkerCount - 2 do
    for j := i + 1 to MarkerCount - 1 do
      if Markers[i].CurrentMarker > Markers[j].CurrentMarker then
      begin
        M := Markers[i];
        Markers[i] := Markers[j];
        Markers[j] := M;
      end;
  // Extract marker data into our data
  SetLength(FData, DataLen);
  P := @FData[0];
  for i := 0 to MarkerCount - 1 do
  begin
    Move(Markers[i].Data^, P^, Markers[i].DataLength);
    inc(P, Markers[i].DataLength);
  end;
end;

procedure TsdJpegICCProfile.SaveToFile(const AFileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TsdJpegICCProfile.SaveToStream(S: TStream);
begin
  if length(FData) > 0 then
    S.Write(FData[0], length(FData))
end;

procedure TsdJpegICCProfile.WriteToMarkerList(AList: TsdJpegMarkerList);
const
  cChunkSize = 60000;
var
  i, Count, Chunk, Left, Base: integer;
  Markers: array of TsdICCProfileMarker;
  P: Pbyte;
begin
  // Create an array of markers with the profile data
  Count := (DataLength + cChunkSize - 1) div cChunkSize;
  Left := DataLength;
  P := Data;
  SetLength(Markers, Count);
  for i := 0 to Count - 1 do
  begin
    Markers[i] := TsdICCProfileMarker.Create(nil, mkApp2);
    Chunk := IntMin(Left, cChunkSize);
    Markers[i].DataLength := Chunk;
    Move(P^, Markers[i].Data^, Chunk);
    Markers[i].CurrentMarker := i + 1;
    Markers[i].MarkerCount := Count;
    inc(P, Chunk);
    dec(Left, Chunk);
  end;
  // Insert them into the markerlist
  Base := IntMin(AList.Count, 2);
  for i := Count - 1 downto 0 do
    AList.Insert(Base, Markers[i]);
end;

function IntMin(i1, i2: integer): integer;
begin
  if i1 < i2 then
    Result := i1
  else
    Result := i2;
end;

function CompareInteger(Int1, Int2: integer): integer;
begin
  if Int1 < Int2 then
    Result := -1
  else
    if Int1 > Int2 then
      Result := 1
    else
      Result := 0;
end;

function sdGetDivisor(AScale: TsdJpegScale): integer;
begin
  case AScale of
  jsFull: Result := 1;
  jsDiv2: Result := 2;
  jsDiv4: Result := 4;
  jsDiv8: Result := 8;
  else
    Result := 1;
  end;
end;

end.

