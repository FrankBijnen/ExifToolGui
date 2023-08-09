unit ExifToolsGUI_Utils;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses Winapi.ShlObj, Winapi.ActiveX, Winapi.Wincodec, Winapi.Windows,
  System.Classes, System.SysUtils, System.Variants, System.StrUtils, System.Math,
  Vcl.Shell.ShellCtrls, Vcl.Graphics;

// Debug
procedure BreakPoint;
procedure DebugMsg(const Msg: array of variant);

// FileSystem
function ValidDir(ADir: string): boolean;
function ValidFile(AFolder: TShellFolder): boolean;
function GetINIPath: string;
function GetAppPath: string;
function GetTempDirectory: string;
function GetExifToolTmp: string;
function GetHtmlTmp: string;
function GetEdgeUserData: string;

// String
function NextField(var AString: string; const ADelimiter: string): string;

// Image
function GetThumbCache(AFilePath: string; var hBmp: HBITMAP; Flags: TSIIGBF;
                       AMaxX: longint = 120; AMaxY: longint = 120): HRESULT;
function IsJpeg(Filename: string): boolean;
function WicPreview(AImg: string; Rotate, MaxW, MaxH: cardinal): IWICBitmapSource;
function GetBitmapFromWic(const FWicBitmap: IWICBitmapSource): TBitmap;
procedure ResizeBitmapCanvas(Bitmap: TBitmap; W, H: Integer; BackColor: TColor);

implementation

uses Winapi.ShellAPI, Winapi.KnownFolders, System.IOUtils;

var GlobalImgFact: IWICImagingFactory;
    TempDirectory: string;

const TempPrefix = 'ExT';
const ExifToolTempFileName = 'ExifToolGUI.tmp';
const HtmlTempFileName     = 'ExifToolGUI.html';
const EdgeUserDataDir      = 'Edge';

procedure BreakPoint;
{$IFDEF DEBUG}
asm int 3
  {$ELSE}
begin
{$ENDIF}
end;

procedure DebugMsg(const Msg: array of variant);
{$IFDEF DEBUG}
var
  I: Integer;
  FMsg: string;
begin
  FMsg := Format('%s %s %s', ['ExiftoolGUI', Paramstr(0),
    IntToStr(GetCurrentThreadId)]);
  for I := 0 to high(Msg) do
    FMsg := Format('%s,%s', [FMsg, VarToStr(Msg[I])]);
  OutputDebugString(PChar(FMsg));
{$ELSE}
begin
{$ENDIF}
end;

// Directories
function ValidDir(ADir: string): boolean;
var
  AShell: IShellFolder;
  P: PWideChar;
  Flags, NumChars: LongWord;
  NewPIDL: PItemIDList;
begin
  SHGetDesktopFolder(AShell);
  P := StringToOleStr(ADir);
  NumChars := Length(ADir);
  Flags := 0;
  result := (AShell.ParseDisplayName(0, nil, P, NumChars, NewPIDL, Flags) = S_OK);
end;

function ValidFile(AFolder: TShellFolder): boolean;
var Flags: LongWord;
    PIDL: PitemIDlist;
begin
  PIDL := AFolder.RelativeID;
  Flags := SFGAO_FILESYSTEM;
  AFolder.ParentShellFolder.GetAttributesOf(1, PIDL, Flags);
  result := SFGAO_FILESYSTEM and Flags <> 0;
end;

function GetINIPath: string;
var NameBuffer: PChar;
begin
  result := '';
  if SUCCEEDED(SHGetKnownFolderPath(FOLDERID_RoamingAppData, 0, 0, NameBuffer)) then
  begin
    result := IncludeTrailingPathDelimiter(StrPas(NameBuffer)) +
              IncludeTrailingPathDelimiter(TPath.GetFileNameWithoutExtension(Application.ExeName));
    CoTaskMemFree(NameBuffer);
    if not DirectoryExists(result) then
      CreateDir(result);
  end;
end;

function GetAppPath: string;
begin
  result := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName));
end;

function GetTempDirectory: string;
begin
  result := TempDirectory;
end;

function GetExifToolTmp: string;
begin
  result := GetTempDirectory + ExifToolTempFileName;
end;

function GetHtmlTmp: string;
begin
  result := GetTempDirectory + HtmlTempFileName;
end;

function GetEdgeUserData: string;
begin
  result := GetTempDirectory + EdgeUserDataDir;
end;

function TempFilename(const Prefix: string): string;
var AName, ADir: array [0 .. MAX_PATH] of char;
begin
  GetTempPath(MAX_PATH, ADir);
  GetTempFilename(ADir, PChar(Prefix), 0, AName);
  result := StrPas(AName);
end;

function CreateTempPath(const Prefix: string): string;
begin
  result := TempFilename(Prefix);
  if FileExists(result) then
    DeleteFile(result);
  MkDir(result);
end;

function RemovePath(const ADir: string; const AFlags: FILEOP_FLAGS = FOF_NO_UI): boolean;
var ShOp: TSHFileOpStruct;
    ShResult: Integer;
begin
  result := false;
  if not(DirectoryExists(ADir)) then
    exit;

  ShOp.Wnd := Application.Handle;
  ShOp.wFunc := FO_DELETE;
  ShOp.pFrom := PChar(ADir + #0);
  ShOp.pTo := nil;
  ShOp.fFlags := AFlags;

  ShResult := SHFileOperation(ShOp);
  if (ShResult <> 0) and
     (ShOp.fAnyOperationsAborted = false) then
    raise Exception.Create(Format('Remove directory failed code %u', [ShResult]));
  result := (ShResult = 0);
end;

// String
function NextField(var AString: string; const ADelimiter: string): string;
var Indx: Integer;
    L: integer;
begin
  L := Length(ADelimiter);
  Indx := Pos(ADelimiter, AString);
  if Indx < 1 then
  begin
    result := AString;
    AString := '';
  end
  else
  begin
    result := Copy(AString, 1, Indx -1);
    Delete(AString, 1, Indx +L -1);
  end;
end;

// Image
function IsJpeg(Filename: string): boolean;
var Ext: string;
begin
  Ext := ';' + ExtractFileExt(Filename) + ';';
  result := (ContainsText(';.jpg;.jpeg;', Ext));
end;

function GetThumbCache(AFilePath: string; var hBmp: HBITMAP; Flags: TSIIGBF;
                       AMaxX: longint = 120; AMaxY: longint = 120): HRESULT;
var FileShellItemImage: IShellItemImageFactory;
    S: TSize;
begin
  result := SHCreateItemFromParsingName(PChar(AFilePath), nil,
    IShellItemImageFactory, FileShellItemImage);

  if Succeeded(result) then
  begin
    S.cx := AMaxX;
    S.cy := AMaxY;
    result := FileShellItemImage.GetImage(S, Flags, hBmp);
  end;
end;

function WicPreview(AImg: string; Rotate, MaxW, MaxH: cardinal): IWICBitmapSource;
var
  IwD: IWICBitmapDecoder;
  IwdR: IWICBitmapFlipRotator;
  IwdS: IWICBitmapScaler;
  W, H, NewW, NewH: cardinal;
begin
  result := nil;
  GlobalImgFact.CreateDecoderFromFilename(PWideChar(AImg),
    GUID_VendorMicrosoftBuiltIn,
    // Use only buitln codecs. No additional installs needed.
    GENERIC_READ, WICDecodeMetadataCacheOnDemand, IwD);
  if IwD = nil then
    exit;

  IwD.GetPreview(result);
  if (result = nil) then // Preview not supported, get real
    IwD.GetFrame(0, IWICBitmapFrameDecode(result));
  if (result = nil) then
    exit;

  GlobalImgFact.CreateBitmapScaler(IwdS);
  if (IwdS = nil) then
    exit;

  result.GetSize(W, H);
  if (W = 0) or (H = 0) then
    exit;
  if (H < W) then
  begin
    NewW := MaxW;
    NewH := Round((MaxW * H) / W);
  end
  else
  begin
    NewH := MaxH;
    NewW := Round((MaxH * W) / H);
  end;
  IwdS.Initialize(result, NewW, NewH,
    WICBitmapInterpolationModeNearestNeighbor);
  result := IwdS;

  if (Rotate <> 0) then
  begin
    GlobalImgFact.CreateBitmapFlipRotator(IwdR);
    if (IwdR = nil) then
      exit;
    case Rotate of
      90:
        IwdR.Initialize(result, WICBitmapTransformRotate90);
      180:
        IwdR.Initialize(result, WICBitmapTransformRotate180);
      270:
        IwdR.Initialize(result, WICBitmapTransformRotate270);
    end;
    result := IwdR;
  end;
end;

function GetBitmapFromWic(const FWicBitmap: IWICBitmapSource): TBitmap;
var
  LWicBitmap: IWICBitmapSource;
  Stride: cardinal;
  Buffer: array of Byte;
  BitmapInfo: TBitmapInfo;
  FWidth, FHeight: UINT;
  prc: WICRect;

  procedure copyPixels;
  begin
    LWicBitmap.copyPixels(@prc, Stride, Length(Buffer), @Buffer[0]);
  end;

  procedure setDibBits;
  begin
    SetDIBits(result.Canvas.Handle, result.Handle, 0, FHeight, @Buffer[0],
      BitmapInfo, DIB_RGB_COLORS);
  end;

begin
  result := nil;
  if (FWicBitmap = nil) then
    exit;

  result := TBitmap.Create;
  FWicBitmap.GetSize(FWidth, FHeight);
  FWidth := FWidth - (FWidth mod 4); // Ensure Width is modulo 4!
  Stride := FWidth * 3;

  if (FWidth = 0) or // Causes AV!
    (FHeight = 0) then
    exit;

  SetLength(Buffer, Stride * FHeight);
  with prc do
  begin
    X := 0;
    Y := 0;
    Width := FWidth;
    Height := FHeight;
  end;

  WICConvertBitmapSource(GUID_WICPixelFormat24bppBGR, FWicBitmap, LWicBitmap);

  copyPixels;

  FillChar(BitmapInfo, sizeof(BitmapInfo), 0);
  with BitmapInfo do
  begin
    bmiHeader.biSize := sizeof(BitmapInfo);
    bmiHeader.biWidth := FWidth;
    bmiHeader.biHeight := -FHeight;
    bmiHeader.biPlanes := 1;
    bmiHeader.biBitCount := 24;
  end;

  result.PixelFormat := pf24bit;

  result.SetSize(FWidth, FHeight);
  setDibBits;
  SetLength(Buffer, 0);
  result.AlphaFormat := afDefined;
end;

procedure ResizeBitmapCanvas(Bitmap: TBitmap; W, H: Integer; BackColor: TColor);
var
  Bmp: TBitmap;
  Source, Dest: TRect;
  Xshift, Yshift: Integer;
begin
  Xshift := (Bitmap.Width - W) div 2;
  Yshift := (Bitmap.Height - H) div 2;

  Source.Left := Max(0, Xshift);
  Source.Top := Max(0, Yshift);
  Source.Width := Min(W, Bitmap.Width);
  Source.Height := Min(H, Bitmap.Height);

  Dest.Left := Max(0, -Xshift);
  Dest.Top := Max(0, -Yshift);
  Dest.Width := Source.Width;
  Dest.Height := Source.Height;

  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(W, H);
    Bmp.Canvas.Brush.Style := bsSolid;
    Bmp.Canvas.Brush.Color := BackColor;
    Bmp.Canvas.FillRect(Rect(0, 0, W, H));
    Bmp.Canvas.CopyRect(Dest, Bitmap.Canvas, Source);
    Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

initialization
begin
  TempDirectory := IncludeTrailingBackslash(CreateTempPath(TempPrefix));
  CoCreateInstance(CLSID_WICImagingFactory, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, GlobalImgFact);
end;

finalization
begin
  RemovePath(TempDirectory);
end;

end.
