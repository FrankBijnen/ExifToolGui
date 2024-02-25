unit ExifToolsGUI_Utils;
{$WARN SYMBOL_PLATFORM OFF}

{$DEFINE GETELEVATION}
{$DEFINE GETWINDOWSADMIN}

interface

uses Winapi.ShlObj, Winapi.ActiveX, Winapi.Wincodec, Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Variants, System.StrUtils, System.Math, System.Threading,
  System.Generics.Collections,
  Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Shell.ShellCtrls, Vcl.Graphics,
  Geomap;

type
  TPreviewInfo = record
    GroupName: string;
    TagName: string;
    SizeString: string;
    SizeInt: integer;
  end;
  TPreviewInfoList = TList<TPreviewInfo>;

// Debug
procedure BreakPoint;
procedure DebugMsg(const Msg: array of variant);

// Version
function GetFileVersionNumber(Fname: string): string;

// FileSystem
function ValidDir(ADir: string): boolean;
function ValidFile(AFolder: TShellFolder): boolean;
function GetINIPath(AllowCreate: boolean = false): string;
function GetAppPath: string;
function GetTempDirectory: string;
function GetExifToolTmp: string;
function GetHtmlTmp: string;
function GetPreviewTmp: string;
function GetEdgeUserData: string;
function GetNrOfFiles(StartDir, FileMask: string; subDir: boolean): integer;
function GetComSpec: string;

// Swap
procedure Swap(var A, B: Cardinal);

// String
function NextField(var AString: string; const ADelimiter: string): string;
function QuotedFileName(FileName: string): string;
function EndsWithCRLF(const AString: string): string;
function ArgsFromDirectCmd(const CmdIn: string): string;
function DirectCmdFromArgs(const ArgsIn: string): string;
procedure WriteArgsFile(const ETInp, ArgsFile: string; Preamble: boolean = false);

// Image
function IsJpeg(Filename: string): boolean;
function GetBitmapFromWic(const FWicBitmapSource: IWICBitmapSource): TBitmap;
function WicPreview(AImg: string; Rotate, MaxW, MaxH: cardinal): IWICBitmapSource;
procedure ResizeBitmapCanvas(Bitmap: TBitmap; W, H: integer; BackColor: TColor);

// Message dialog that allows for caption and doesn't wrap lines at spaces.
function MessageDlgEx(const AMsg, ACaption: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons; AParent: TForm = nil): integer;

// Previews in Raw/Jpeg files
function GetPreviews(ETResult: TStringList; var Biggest: integer): TPreviewInfoList;
procedure FillPreviewInListView(SelectedFile: string; LvPreviews: TListView);

// GeoCoding
function GetGpsCoordinates(const Images: string): string;
function AnalyzeGPSCoords(var ETout, Lat, Lon: string; var IsQuickTime: boolean): string;
procedure FillLocationInImage(const ANImage: string);
function GetIsQuickTime(const AFile: string): boolean;

// Context menu
function ContextInstalled(const AppTitle: string): string;
procedure Add2Context(const AppTitle, Description: string);
procedure RemoveFromContext(const AppTitle: string);

// Running elevated or admin?
var
  IsElevated: boolean;
  IsAdminUser: boolean;

implementation

uses
  Winapi.ShellAPI, Winapi.KnownFolders, System.Win.Registry, System.UITypes, UFrmGenerate, MainDef, ExifTool, ExifInfo,
  UnitLangResources;

var
  GlobalImgFact: IWICImagingFactory;
  TempDirectory: string;
  UTF8Encoding: TEncoding;

const
  TempPrefix = 'ExT';

const
  ExifToolTempFileName = 'ExifToolGUI.tmp';

const
  HtmlTempFileName = 'ExifToolGUI.html';

const
  PreviewTempFileName = 'ExifToolGui_Preview.jpg';

const
  EdgeUserDataDir = 'Edge';

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
  I: integer;
  FMsg: string;
begin
  FMsg := Format('%s %s %s', ['ExiftoolGUI', Paramstr(0), IntToStr(GetCurrentThreadId)]);
  for I := 0 to high(Msg) do
    FMsg := Format('%s,%s', [FMsg, VarToStr(Msg[I])]);
  OutputDebugString(PChar(FMsg));
{$ELSE}
begin
{$ENDIF}
end;

// Version
function GetFileVersionNumber(Fname: string): string;
var
  V, VerInfoSize, VerValueSize: cardinal;
  VerInfo: pointer;
  VerValue: PVSFixedFileInfo;
begin
  result := 'No version info';
  VerInfoSize := GetFileVersionInfoSize(@Fname[1], V);
  if VerInfoSize = 0 then
    exit;

  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(@Fname[1], 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    result := IntToStr(dwFileVersionMS shr 16);
    result := result + '.' + IntToStr(dwFileVersionMS and $FFFF);
    result := result + '.' + IntToStr(dwFileVersionLS shr 16);
    result := result + '.' + IntToStr(dwFileVersionLS and $FFFF);
    if (dwFileFlags and VS_FF_PRERELEASE <> 0) then
      result := result + ' Pre.';
  end;
  FreeMem(VerInfo, VerInfoSize);

  result := Application.Title + ' V' + result +
{$IFDEF WIN32}
    ' 32 Bits'
{$ENDIF}
{$IFDEF WIN64}
    ' 64 Bits'
{$ENDIF}
  ;
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
var
  Flags: LongWord;
  PIDL: PItemIDList;
begin
  PIDL := AFolder.RelativeID;
  Flags := SFGAO_FILESYSTEM;
  AFolder.ParentShellFolder.GetAttributesOf(1, PIDL, Flags);
  result := SFGAO_FILESYSTEM and Flags <> 0;
end;

function IsDesktop(AFolder: TShellFolder): boolean;
var
  DesktopPIDL: PItemIDList;
  DesktopShellFolder: IShellFolder;
begin
  SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, DesktopPIDL);
  try
    SHGetDesktopFolder(DesktopShellFolder);
    result := DesktopShellFolder = AFolder.ShellFolder;
  finally
    CoTaskMemFree(DesktopPIDL);
  end;
end;

function GetINIPath(AllowCreate: boolean = false): string;
var
  NameBuffer: PChar;
begin
  result := '';
  if SUCCEEDED(SHGetKnownFolderPath(FOLDERID_RoamingAppData, 0, 0, NameBuffer)) then
  begin
    result := IncludeTrailingPathDelimiter(StrPas(NameBuffer)) + IncludeTrailingPathDelimiter(Application.Title);
    CoTaskMemFree(NameBuffer);
    if (AllowCreate) and
       not DirectoryExists(result) then
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

function GetPreviewTmp: string;
begin
  result := GetTempDirectory + PreviewTempFileName;
end;

function GetEdgeUserData: string;
begin
  result := GetTempDirectory + EdgeUserDataDir;
end;

function TempFilename(const Prefix: string): string;
var
  AName, ADir: array [0 .. MAX_PATH] of char;
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

function RemovePath(const ADir: string; const AFlags: FILEOP_FLAGS = FOF_NO_UI; Retries: integer = 3): boolean;
var
  ShOp: TSHFileOpStruct;
  ShResult: integer;
  CurrentTry: integer;
begin
  result := false;
  if not(DirectoryExists(ADir)) then
    exit;

  ShOp.Wnd := Application.Handle;
  ShOp.wFunc := FO_DELETE;
  ShOp.pFrom := PChar(ADir + #0);
  ShOp.pTo := nil;
  ShOp.fFlags := AFlags;
  CurrentTry := Retries;
  repeat
    ShResult := SHFileOperation(ShOp);
    if (ShResult = 0) then
      break;

    dec(CurrentTry);
    sleep(100);
    Application.ProcessMessages;

  until (CurrentTry < 1);

  if (ShResult <> 0) and (ShOp.fAnyOperationsAborted = false) then
    raise Exception.Create(Format(StrRemDirectoryFail, [ShResult]));
  result := (ShResult = 0);
end;

function GetNrOfFiles(StartDir, FileMask: string; subDir: boolean): integer;
var
  SR: TSearchRec;
  DirList: TStringList;
  IsFound, DoSub: boolean;
  I, X: integer;
  CrNormal, CrWait: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  try
    if StartDir[Length(StartDir)] <> '\' then
      StartDir := StartDir + '\';
    DoSub := subDir;
    X := 0;
    // Count files in directory
    IsFound := FindFirst(StartDir + FileMask, faAnyFile - faDirectory, SR) = 0;
    while IsFound do
    begin
      inc(X);
      IsFound := FindNext(SR) = 0;
    end;
    FindClose(SR);

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
      FindClose(SR);
      // Scan the list of subdirectories
      for I := 0 to DirList.Count - 1 do
        X := X + GetNrOfFiles(DirList[I], FileMask, DoSub);
      DirList.Free;
    end;
    result := X;
  finally
    SetCursor(CrNormal);
  end;
end;

procedure Swap(var A, B: Cardinal);
var
  Temp: Cardinal;
begin
  Temp := A;
  A := B;
  B := Temp;
end;

// String

function NextField(var AString: string; const ADelimiter: string): string;
var
  Indx: integer;
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
    result := Copy(AString, 1, Indx - 1);
    Delete(AString, 1, Indx + L - 1);
  end;
end;

function QuotedFileName(FileName: string): string;
begin
  Result := FileName;
  if (Pos(' ', Result) > 0) then
    Result := '"' + Result + '"';
end;

function EndsWithCRLF(const AString: string): string;
begin
  result := AString;
  if (result <> '') and
     (RightStr(result, Length(CRLF)) <> CRLF) then
    result := result + CRLF;
end;

function ArgsFromDirectCmd(const CmdIn: string): string;
var Indx: integer;
    DQuote: boolean;
begin
  DQuote := false;
  result := CmdIn;
  result := StringReplace(result, '\"', #0, [rfReplaceAll]);    // Put a double quote in data: -make="Pentax\"Ricoh\""
  for Indx := 1 to Length(result) do
  begin
    if (result[Indx] = '"') then
      DQuote := not DQuote;

    if (DQuote) then
      continue;

    if (result[Indx] = ' ') then
      result[Indx] := #10;                                      // Change a space to a LF, If not present within " "
  end;
  result := StringReplace(result, '"', '', [rfReplaceAll]);     // remove Double quotes
  result := StringReplace(result, #0, '"', [rfReplaceAll]);     // Put the DOuble quotes in, that belong to the data
  result := StringReplace(result, #10, #13#10, [rfReplaceAll]); // LF => CRLF
end;

function DirectCmdFromArgs(const ArgsIn: string): string;
var ArgsInList: TStringList;
    ALine: string;
    Sep: string;
    Indx: integer;
begin
  ArgsInList := TStringList.Create;
  ArgsInList.Text := ArgsIn;
  try
    Sep := '';
    result := '';
    for Indx := 0 to ArgsInList.Count -1 do
    begin
      Aline := StringReplace(ArgsInList[Indx], '"', '\"', [rfReplaceAll]);
      result := result + Sep + QuotedFileName(Aline);
      Sep := ' ';
    end;
  finally
    ArgsInList.Free;
  end;
end;

function CreateTempHandle(TempFile: string): THandle;
begin
  result := Winapi.Windows.CreateFile(PChar(TempFile),
                                      GENERIC_READ or GENERIC_WRITE,
                                      FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
                                      nil,
                                      CREATE_ALWAYS,
                                      FILE_ATTRIBUTE_TEMPORARY,// Tells Windows flushing to disk is not needed
                                      0);
  if (result = INVALID_HANDLE_VALUE) then
    raise exception.Create(Format('%s %s', [TempFile, SysErrorMessage(GetLastError)] ));
end;

procedure WriteArgsFile(const ETInp, ArgsFile: string; Preamble: boolean = false);
var Handle: THandle;
    S, W: DWORD;
    Bytes: TBytes;
begin
  Handle := CreateTempHandle(ArgsFile);
  try
    if (Preamble) then // Turns out not needed for Exiftool, and works better for ps1
    begin
      // Write BOM
      Bytes := UTF8Encoding.GetPreamble;
      S := Length(Bytes);
      if (S > 0) then
      begin
        WriteFile(Handle, Bytes[0], S, W, nil);
        if (W <> S) then
          raise Exception.Create(Format(StrWriteToSFailed, [Argsfile]));
      end;
    end;

    //Write UTF8
    Bytes := UTF8Encoding.GetBytes(ETInp);
    S := Length(Bytes);
    WriteFile(Handle, Bytes[0], S, W, nil);
    if (W <> S) then
      raise Exception.Create(Format(StrWriteToSFailed, [Argsfile]));

  finally
    CloseHandle(Handle);
  end;
end;

// Image
function IsJpeg(Filename: string): boolean;
var
  Ext: string;
begin
  Ext := ';' + ExtractFileExt(Filename) + ';';
  result := (ContainsText(';.jpg;.jpeg;', Ext));
end;

// Get a bitmap from WIC
function GetBitmapFromWic(const FWicBitmapSource: IWICBitmapSource): TBitmap;
var
  FWICBitmapConvert: IWICBitmapSource;
  FWICBitmap: IWICBitmap;
  LWicBitmap: IWICBitmapLock;
  BitmapInfo: TBitmapInfo;
  FWidth, FHeight: UINT;
  Prc: WICRect;
  LockedSize: UINT;
  LockedArea: WICInProcPointer;

  function LockBitmap: boolean;
  begin
    FWICBitmap.GetSize(FWidth, FHeight);
    with Prc do
    begin
      x := 0;
      Y := 0;
      Width := FWidth;
      Height := FHeight;
    end;

    result := (FWICBitmap.Lock(Prc, WICBitmapLockRead, LWicBitmap) = S_OK);
    if result then
      LWicBitmap.GetDataPointer(LockedSize, LockedArea);
  end;

begin
  result := nil;
  // Convert to 24 Bits
  WICConvertBitmapSource(GUID_WICPixelFormat24bppBGR, FWicBitmapSource, FWICBitmapConvert);

  // And create a bitmap
  GlobalImgFact.CreateBitmapFromSource(FWICBitmapConvert, WICBitmapNoCache, FWICBitmap);
  if (FWICBitmap = nil) then // Succeeded?
    exit;

  // Lock in Memory
  if not LockBitmap then
    exit;

  // Create a bitmap
  result := TBitmap.Create;

  // Set the info of the bitmap
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
  result.AlphaFormat := afDefined;

  // And set the bits
  SetDIBits(0, result.Handle, 0, FHeight, LockedArea, BitmapInfo, DIB_RGB_COLORS);
end;

function WicPreview(AImg: string; Rotate, MaxW, MaxH: cardinal): IWICBitmapSource;
var
  IwD: IWICBitmapDecoder;
  IwdR: IWICBitmapFlipRotator;
  IwdS: IWICBitmapScaler;
  W, H, NewW, NewH: cardinal;
  Portrait: boolean;
  ImgRatio: double;
begin
  result := nil;
  GlobalImgFact.CreateDecoderFromFilename(PWideChar(AImg), GUID_VendorMicrosoftBuiltIn, // Use only builtin codecs. No additional installs needed.
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

  Portrait :=(Rotate = 90) or
             (Rotate = 270);
  // Compute NewW, NewH.
  // Take largest Ratio possible
  if Portrait then
    ImgRatio := W / H
  else
    ImgRatio := H / W;

  if (MaxW = 0) and
     (MaxH = 0) then
  begin
    // Use sizes from image
    NewW := W;
    NewH := H;
  end
  else
  begin
    // Assume Preview Width is limiting
    NewW := MaxW;
    NewH := Round(MaxW * ImgRatio);
    if (NewH > MaxH) then
    begin  // No. Preview Height is limiting
      NewH := MaxH;
      NewW := Round(MaxH / ImgRatio);
    end;
  end;

  // Scaling occurs before Rotating (performs better).
  // In portrait mode swap NewW and NewH
  if Portrait then
    Swap(NewW, NewH);

  IwdS.Initialize(result, NewW, NewH, WICBitmapInterpolationModeNearestNeighbor);
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

// The image size of the Bitmap passed should not exceed W or H!
procedure ResizeBitmapCanvas(Bitmap: TBitmap; W, H: integer; BackColor: TColor);
var
  Bmp: TBitmap;
  Source, Dest: TRect;
  Xshift, Yshift: integer;
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

function MessageDlgEx(const AMsg, ACaption: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons; AParent: TForm = nil): integer;
var
  MsgFrm: TForm;
begin
  MsgFrm := CreateMessageDialog(AMsg, ADlgType, AButtons);
  try
    if (ACaption = '') then
      MsgFrm.Caption := Application.Title
    else
      MsgFrm.Caption := ACaption;
    MsgFrm.Position := poDefaultSizeOnly;
    MsgFrm.FormStyle := fsStayOnTop;
    if (AParent <> nil) then
    begin
      MsgFrm.Left := AParent.Left + (AParent.Width - MsgFrm.Width) div 2;
      MsgFrm.Top := AParent.Top + (AParent.Height - MsgFrm.Height) div 2;
    end;
    result := MsgFrm.ShowModal;
  finally
    MsgFrm.Free
  end;
end;

function GetEnvVarValue(const VarName: string): string;
var
  BufSize: integer; // buffer size required for value
begin
  result := '';
  // Get required buffer size (inc. terminating #0)
  BufSize := GetEnvironmentVariable(PChar(VarName), nil, 0);
  if BufSize > 0 then
  begin
    // Read env var value into result string
    SetLength(result, BufSize - 1);
    GetEnvironmentVariable(PChar(VarName), PChar(result), BufSize);
  end;
end;

function GetComSpec: string;
begin
  result := GetEnvVarValue('ComSpec');
  if (result = '') then
    result := 'cmd.exe';
end;

function GetPreviews(ETResult: TStringList; var Biggest: integer): TPreviewInfoList;
var
  Aline: string;
  AResult: string;
  ASizeInt: string;
  BiggestSize: integer;
  APreviewInfo: TPreviewInfo;
begin
  result := TPreviewInfoList.Create;
  BiggestSize := 0;
  Biggest := -1;
  for Aline in ETResult do
  begin
    AResult := ALine;
    with APreviewInfo do
    begin
      GroupName   := NextField(AResult, '[');             // Strip Leading [
      GroupName   := NextField(AResult, ']');             // Group name
      TagName     := Trim(NextField(AResult, ':'));       // Tag Name
      SizeString  := Nextfield(AResult, '(Binary data');  // Strip
      SizeString  := Nextfield(AResult, ', use -b');      // Size, including ' bytes'
      ASizeInt    := SizeString;
      TryStrToInt(NextField(ASizeInt, ' bytes'), SizeInt);
      if (SizeInt > BiggestSize) then
      begin
        Biggest := result.Count;
        BiggestSize := SizeInt;
      end;
    end;
    result.Add(APreviewInfo);
  end;
end;

procedure FillPreviewInListView(SelectedFile: string; LvPreviews: TListView);
var
  ETCmd: string;
  ETResult: TStringList;
  AMaxPos: integer;
  AListItem: TListItem;
  APreviewList: TPreviewInfoList;
  APreviewInfo: TPreviewInfo;
begin
  ETResult := TStringList.Create;
  try
    ETcmd := '-s1' + CRLF + '-a' + CRLF + '-G1' + CRLF + '-Preview:All';
    ET_OpenExec(ETcmd, SelectedFile, ETResult);
    LvPreviews.Items.Clear;
    APreviewList := GetPreviews(ETResult, AMaxPos);
    try
      for APreviewInfo in APreviewList do
      begin
        AListItem := LvPreviews.Items.Add;
        AListItem.Caption := APreviewInfo.GroupName;
        AListItem.SubItems.Add(APreviewInfo.TagName);
        AListItem.SubItems.Add(APreviewInfo.SizeString);
      end;
    finally
      APreviewList.Free;
    end;
    // Check the greatest
    if (AMaxPos >= 0) then
      LvPreviews.Items[AMaxPos].Checked := true;
  finally
    ETResult.Free;
  end;
end;

function GetGpsCoordinates(const Images: string): string;
var
  ETCmd: string;
  ETerrs: string;
begin
  ETcmd := '-s3' + CRLF + '-f' + CRLF + '-n' + CRLF + '-q';
  ETcmd := ETcmd + CRLF + '-Filename';
  ETcmd := ETcmd + CRLF + '-Composite:GpsLatitude';
  ETcmd := ETcmd + CRLF + '-Composite:GpsLongitude';
  ETcmd := ETcmd + CRLF + '-QuickTime:MajorBrand';
  ET_OpenExec(ETcmd, Images, result, ETerrs, false);
end;

function AnalyzeGPSCoords(var ETout, Lat, Lon: string; var IsQuickTime: boolean): string;
var
  QuickTimeMajorBrand: string;
begin
  result := NextField(ETout, CRLF);

  Lat := NextField(ETout, CRLF);
  Lon := NextField(ETout, CRLF);

  QuickTimeMajorBrand := NextField(ETout, CRLF);
  IsQuickTime := QuickTimeMajorBrand <> '-';
end;

procedure FillLocationInImage(const ANImage: string);
var
  ETCmd: string;
  APlace: TPlace;
  GPSCoordinates, Lat, Lon: string;
  IsQuickTime: boolean;
begin
  GetMetadata(ANImage, false, false, true, false);
  if (Foto.GPS.Supported) then
  begin
    Lat := Foto.GPS.GeoLat;
    Lon := Foto.GPS.GeoLon;
    IsQuickTime := false;
  end
  else
  begin
    GPSCoordinates := GetGpsCoordinates(ANImage);
    AnalyzeGPSCoords(GPSCoordinates, Lat, Lon, IsQuickTime);
  end;
  if (ValidLatLon(Lat, Lon)) then
  begin
    AdjustLatLon(Lat, Lon, Place_Decimals);
    APlace := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);
    if not Assigned(APlace) then
      exit;
    ETCmd := ETCmd + CRLF + '-xmp:LocationShownCountryName=' + APlace.CountryLocation;
    ETCmd := ETCmd + CRLF + '-xmp:LocationShownProvinceState=' + APlace.Province;
    ETCmd := ETCmd + CRLF + '-xmp:LocationShownCity=' + APlace.City;

    ET_OpenExec(ETcmd, ANImage);
  end;
end;

function GetIsQuickTime(const AFile: string): boolean;
var
  ETCmd, ETOuts, ETErrs: string;
begin
  ETcmd := '-s3' + CRLF + '-f' + CRLF + '-n' + CRLF + '-q' + CRLF + '-QuickTime:MajorBrand';
  ET_OpenExec(ETcmd, AFile, ETOuts, ETErrs, false);
  ETOuts := NextField(ETOuts, CRLF);
  result := ETOuts <> '-';
end;

function GetTokenHandle(var Tokenhandle: THandle): boolean;
begin
  result := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, Tokenhandle);
  if (not result) and
     (GetLastError = ERROR_NO_TOKEN) then
    result := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, Tokenhandle);
end;

function GetIsElevated: BOOL;
var
  TokenHandle: THandle;
  DwInfoBufferSize: DWORD;
  ATokenElevation: TOKEN_ELEVATION;
begin
  result := not CheckWin32Version(6, 0);  //Lower Windows versions run always elevated
  if not result then
  begin
    if not GetTokenHandle(TokenHandle) then
      exit;
    try
      if GetTokenInformation(TokenHandle,
                             TTokenInformationClass.TokenElevation,
                             @ATokenElevation,
                             SizeOf(ATokenElevation),
                             DwInfoBufferSize) then
        result := ATokenElevation.TokenIsElevated <> 0;
    finally
      CloseHandle(TokenHandle);
    end;
  end;
end;

function GetIsWindowsAdmin: BOOL;
var
   TokenHandle: THandle;
   PtgGroups: PTokenGroups;
   DwInfoBufferSize: DWORD;
   PsidAdministrators: PSID;
   Indx: Integer;

// Info from Inno Setup
const SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
      SUBAUTHORITYCOUNT: byte = 2;
      SECURITY_BUILTIN_DOMAIN_RID: cardinal = 32;
      DOMAIN_ALIAS_RID_ADMINS: cardinal = 544;
begin
  result := false;
  if not GetTokenHandle(TokenHandle) then
    exit;

  try
    // Get size of buffer required in DwInfoBufferSize
    // If we pass 0 for 4th parm, the function fails and the required size is passed in the 5th parm.
    DwInfoBufferSize := 0;
    GetTokenInformation(TokenHandle, TokenGroups, nil, 0, DwInfoBufferSize);
    if (DwInfoBufferSize = 0) then // We need a buffersize
      exit;

    // Allocate buffer
    GetMem(PtgGroups, DwInfoBufferSize);
    try
      // Now the call should succeed and return all the Sid's for the user.
      if not GetTokenInformation(TokenHandle, TokenGroups, PtgGroups, DwInfoBufferSize, DwInfoBufferSize) then
        exit;

      // Get Sid for BuiltIn local admin
      if not AllocateAndInitializeSid(SECURITY_NT_AUTHORITY,
                                      SUBAUTHORITYCOUNT,
                                      SECURITY_BUILTIN_DOMAIN_RID,
                                      DOMAIN_ALIAS_RID_ADMINS,
                                      0, 0, 0, 0, 0, 0,
                                      PsidAdministrators) then
        exit;
      try
        for Indx := 0 to PtgGroups.GroupCount -1 do
          if EqualSid(PsidAdministrators, PtgGroups.Groups[Indx].Sid) then
            exit(true);  // Found. The try finally  blocks ensure freeing resources allocated.
      finally
        FreeSid(PsidAdministrators);
      end;
    finally
      FreeMem(PtgGroups);
    end;
  finally
    CloseHandle(TokenHandle);
  end;
end;

const
  ETGContextKey = 'SOFTWARE\Classes\Folder\Shell\';
  ETGCommandKey = '\command';

function ContextInstalled(const AppTitle: string): string;
var
  Reg: TRegistry;
begin
  result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(ETGContextKey + AppTitle, false) then
      result := Reg.ReadString('');
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

procedure Add2Context(const AppTitle, Description: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.OpenKey(ETGContextKey + AppTitle, true);
    Reg.WriteString('', Description);
    Reg.CloseKey;

    Reg.OpenKey(ETGContextKey + AppTitle + ETGCommandKey, true);
    Reg.WriteString('', '"'+ ParamStr(0) + '" "%L"');
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

procedure RemoveFromContext(const AppTitle: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.DeleteKey(ETGContextKey + AppTitle + ETGCommandKey);
    Reg.DeleteKey(ETGContextKey + AppTitle);
  finally
    Reg.Free
  end;
end;

initialization

begin
  TempDirectory := IncludeTrailingBackslash(CreateTempPath(TempPrefix));
  CoCreateInstance(CLSID_WICImagingFactory, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, GlobalImgFact);
  UTF8Encoding := TEncoding.GetEncoding(CP_UTF8);

{$IFDEF GETELEVATION}
  IsElevated := GetIsElevated;
{$ELSE}
  IsElevated := false;
{$ENDIF}

{$IFDEF GETWINDOWSADMIN}
  IsAdminUser := GetIsWindowsAdmin;
{$ELSE}
  IsAdminUser := false;
{$ENDIF}
end;

finalization

begin
  UTF8Encoding.Free;
  RemovePath(TempDirectory);
end;

end.
