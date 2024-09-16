unit ExifToolsGUI_Utils;

{$DEFINE GETELEVATION}
{$DEFINE GETWINDOWSADMIN}

interface

uses Winapi.ShlObj, Winapi.ActiveX, Winapi.Wincodec, Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils, System.Variants, System.StrUtils, System.Math, System.Threading,
  System.Generics.Collections,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Shell.ShellCtrls, Vcl.Graphics, Vcl.Themes,
  Vcl.Controls,
  Geomap;

type
  TPreviewInfo = record
    GroupName: string;
    TagName: string;
    SizeString: string;
    SizeInt: integer;
  end;
  TPreviewInfoList = TList<TPreviewInfo>;

  TTagInfo = record
    GroupName: string;
    TagName: string;
    TagValue: string;
  end;
  TTagInfoList = TList<TTagInfo>;

// Debug
procedure BreakPoint;
procedure DebugMsg(const Msg: array of variant);

// Version
function GetFileVersionNumber(FName: string): string;
function GetFileVersionNumberPlatForm(FName: string): string;

// Shell
function GetIShellFolder(IFolder: IShellFolder; PIDL: PItemIDList): IShellFolder;

// FileSystem
function ValidDir(ADir: string): boolean;
function ValidFile(AFolder: TShellFolder): boolean;
function GetINIPath(AllowCreate: boolean = false): string;
function GetAppPath: string;
function GetGeoPath: string;
function GetTempDirectory: string;
function GetExifToolTmp(const Id: integer): string;
function GetHtmlTmp: string;
function GetTrackTmp: string;
function GetPreviewTmp: string;
function GetEdgeUserData: string;
function GetNrOfFiles(StartDir, FileMask: string; subDir: boolean): integer;
function GetComSpec: string;
function PasteDirectory(ADir, TargetDir: string; Cut: boolean = false): boolean;

// Swap
procedure Swap(var A, B: integer);

// String
function NextField(var AString: string; const ADelimiter: string): string;
function QuotedArg(FileName: string): string;
function ReplaceLastChar(const AString: string; AFrom, ATo: Char): string;
function EndsWithCRLF(const AString: string): string;
function ArgsFromDirectCmd(const CmdIn: string): string;
function DirectCmdFromArgs(const ArgsIn: string): string;
procedure WriteArgsFile(const ETInp, ArgsFile: string; Preamble: boolean = false);

// Date
function DateDiff(ODate, NDate: TDateTime; var Increment: boolean): string;

// Image
function IsJpeg(Filename: string): boolean;
function GetBitmapFromWic(const FWicBitmapSource: IWICBitmapSource): TBitmap;
function WicPreview(AImg: string; Rotate, MaxW, MaxH: cardinal): IWICBitmapSource;
procedure ResizeBitmapCanvas(Bitmap: TBitmap; MaxW, MaxH: integer;
                             BackColor: TColor; Stretch: boolean = true);
function BitMapFromHBitMap(ABmp: HBITMAP; W, H: Integer; BkColor: TColor): TBitMap;

// Message dialog that allows for caption and doesn't wrap lines at spaces.
function MessageDlgEx(const AMsg, ACaption: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons; UseTaskMessage: boolean = false): integer;

// Previews in Raw/Jpeg files
function GetPreviews(ETResult: TStringList; var Biggest: integer): TPreviewInfoList;
procedure FillPreviewInListView(SelectedFile: string; LvPreviews: TListView);
procedure StyledDrawListviewItem(FstyleServices: TCustomStyleServices;
                                 ListView: TCustomListView;
                                 Item: TlistItem;
                                 State: TCustomDrawState);

// Tag names
function GetTags(ETResult: TStringList; CmbTags: TComboBox): TTagInfoList;
procedure FillGroupsInCombo(SelectedFile: string; CmbTags: TComboBox; const Family: string);
procedure FillTagsInCombo(SelectedFile: string; CmbTags: TComboBox; const Family, GroupName: string);
procedure DrawItemTagName(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
procedure SetTagItem(const AnItem: TlistItem; ACaption: string = '');
function RemoveInvalidTags(const Tag: string; AllowExclude: boolean = false): string;
function GetGroupNameFromTag(ATag: string): string;
function GetGroupIdForLv(AListView: TListView; AGroupName: string): integer;

// GeoCoding
function CreateTrkPoints(const LogPath: string; FirstGpx: boolean; var LastCoord: string): integer;
function GetGpsCoordinates(const Images: string): string;
function AnalyzeGPSCoords(var ETout, Lat, Lon, MIMEType: string; var IsQuickTime: boolean): string;
procedure FillLocationInImage(const ANImage: string);
function GetIsQuickTime(const AFile: string): boolean;
function GetExifToolLanguage(const ACombo: TComboBox): string;
procedure SetupLanguageCombo(const CmbLang: TComboBox; ALang: string);
procedure SetupExifToolLanguage(const ACombo: TComboBox; ALang: string);
procedure SetupGeoCodeLanguage(const ACombo: TComboBox; AProvider: TGeoCodeProvider; ALang: string);

function ExifToolGeoLocation(const Lat, Lon, Lang:string): TStringList; overload;
function ExifToolGeoLocation(const City, CountryRegion, Match, Lang: string; var ETErr:string): string; overload;
function ExifToolGetCountryList: TStringList;

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
  Winapi.ShellAPI, Winapi.KnownFolders, System.Win.Registry, System.UITypes, System.Types, System.DateUtils,
  UFrmGenerate, MainDef, ExifTool, ExifInfo, UnitLangResources;

var
  GlobalImgFact: IWICImagingFactory;
  TempDirectory: string;
  UTF8Encoding: TEncoding;

const
  TempPrefix = 'ExT';

const
  ExifToolTempFileName = 'ExifToolGUI%s.tmp';

const
  HtmlTempFileName = 'ExifToolGUI.html';

const
  TrackFileName = 'ExifToolGUI.track';

const
  PreviewTempFileName = 'ExifToolGui_Preview.jpg';

const
  EdgeUserDataDir = 'Edge';

const
  GeoLocation500 = 'GeoLocation500';

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
function GetFileVersionNumber(FName: string): string;
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
    result := 'V' + IntToStr(dwFileVersionMS shr 16);
    result := result + '.' + IntToStr(dwFileVersionMS and $FFFF);
    result := result + '.' + IntToStr(dwFileVersionLS shr 16);
    result := result + '.' + IntToStr(dwFileVersionLS and $FFFF);
    if (dwFileFlags and VS_FF_PRERELEASE <> 0) then
      result := result + ' Pre.';
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

function GetFileVersionNumberPlatForm(FName: string): string;
begin
  result := Application.Title + ' ' + GetFileVersionNumber(FName) +
{$IFDEF WIN32}
    ' 32 Bits'
{$ENDIF}
{$IFDEF WIN64}
    ' 64 Bits'
{$ENDIF}
  ;
end;

// ShellFolder
function GetIShellFolder(IFolder: IShellFolder; PIDL: PItemIDList): IShellFolder;
begin
  result := nil;
  if Assigned(IFolder) then
    IFolder.BindToObject(PIDL, nil, IID_IShellFolder, Pointer(Result));
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

function GetGeoPath: string;
begin
  result := GetAppPath + GeoLocation500;
end;

function GetTempDirectory: string;
begin
  result := TempDirectory;
end;

function GetExifToolTmp(const Id: integer): string;
var
  Seq: string;
begin
  Seq := '';
  if (Id > 0) then
    Seq := Format('-%d', [Id]);
  result := GetTempDirectory + Format(ExifToolTempFileName, [Seq]);
end;

function GetHtmlTmp: string;
begin
  result := GetTempDirectory + HtmlTempFileName;
end;

function GetTrackTmp: string;
begin
  result := GetTempDirectory + TrackFileName;
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
  AName, ADir: array [0 .. MAX_PATH] of Char;
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

  CurrentTry := Retries;
  repeat
    FillChar(ShOp, SizeOf(ShOp), 0);
    ShOp.Wnd := Application.Handle;
    ShOp.wFunc := FO_DELETE;
    ShOp.pFrom := PChar(ADir + #0);
    ShOp.pTo := nil;
    ShOp.fFlags := AFlags;
    ShResult := SHFileOperation(ShOp);
    if (ShResult = 0) then
      break;

    Dec(CurrentTry);
    Sleep(100);
    Application.ProcessMessages;
  until (CurrentTry < 1);

  if (ShResult <> 0) and (ShOp.fAnyOperationsAborted = false) then
    MessageDlgEx(Format(StrRemDirectoryFail, [ShResult]), '', TMsgDlgType.mtError, [TMsgDlgBtn.mbClose], true);
  result := (ShResult = 0);
end;

function PasteDirectory(ADir, TargetDir: string; Cut: boolean = false): boolean;
var
  ShOp: TSHFileOpStruct;
  ShResult: integer;
begin
  result := false;
  if not(DirectoryExists(ADir)) then
    exit;

  FillChar(ShOp, SizeOf(ShOp), 0);
  ShOp.Wnd := Application.Handle;
  if (Cut) then
    ShOp.wFunc := FO_MOVE
  else
    ShOp.wFunc := FO_COPY;
  ShOp.pFrom := PChar(ADir + #0);
  ShOp.pTo := PChar(TargetDir + #0);
  ShOp.fFlags := FOF_NO_UI;
  ShResult := SHFileOperation(ShOp);

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

procedure Swap(var A, B: integer);
var
  Temp: integer;
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

function QuotedArg(FileName: string): string;
begin
  Result := FileName;
  if (Pos(' ', Result) > 0) or
     (Pos('>', Result) > 0) or
     (Pos('<', Result) > 0) then
    Result := '"' + Result + '"';
end;

function ReplaceLastChar(const AString: string; AFrom, ATo: Char): string;
var
  Len: integer;
begin
  result := AString;
  Len := Length(result);
  if (Len = 0) then
    result := ATo
  else
    if (result[Len] = AFrom) then
      result[Len] := ATo;
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
  result := StringReplace(result, #0, '"', [rfReplaceAll]);     // Put the Double quotes in, that belong to the data
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
      result := result + Sep + QuotedArg(Aline);
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

// Date
function DateDiff(ODate, NDate: TDateTime; var Increment: boolean): string;
var
  LY, LM, LD, Lhh, Lmm, Lss, Lmss: word;      // The lowest Values
  HY, HM, HD, Hhh, Hmm, Hss, Hmss: word;      // The highest Values
  DY, DM, DD, Dhh, Dmm, Dss: integer;         // Difference, disregard mss);
  CY, CM: integer; // New year month, after correction. Used to get days in month

  procedure ChkYear(ChkOnly: boolean = true);
  begin
    if not ChkOnly then
      DY := HY - LY;
  end;

  procedure ChkMonth(ChkOnly: boolean = true);
  begin
    if not ChkOnly then
      DM := HM - LM;

    if (DM < 0) then
    begin
      Dec(DY); // Correct Year
      ChkYear;

      DM := DM + 12;
    end;
  end;

  procedure ChkDay(ChkOnly: boolean = true);
  begin
    if not ChkOnly then
      DD := HD - LD;
    if (DD < 0) then
    begin
      Dec(DM);  // Correct month
      ChkMonth;

      if (Increment) then
      begin
        Dec(CM);
        if (CM < 1) then
        begin
          CM := 12;
          Dec(CY);
        end;
      end;

      case CM of
        1,3,5,7,8,10,12:
           DD := DD + 31;
        2: if (IsLeapYear(CY)) then
             DD := DD + 29
           else
             DD := DD + 28;
        4,6,9,11:
            DD := DD + 30;
      end;
    end;
  end;

  procedure ChkHour(ChkOnly: boolean = true);
  begin
    if not ChkOnly then
      Dhh := Hhh - Lhh;
    if (Dhh < 0) then
    begin
      Dec(DD);
      ChkDay;

      Dhh := Dhh + 24;
    end;
  end;

  procedure ChkMin(ChkOnly: boolean = true);
  begin
    if not ChkOnly then
      Dmm := Hmm - Lmm;
    if (Dmm < 0) then
    begin
      Dec(Dhh);
      ChkHour;

      Dmm := Dmm + 60;
    end;
  end;

  procedure Chkss(ChkOnly: boolean = true);
  begin
    if not ChkOnly then
      Dss := Hss - Lss;
    if (Dss < 0) then
    begin
      Dec(Dmm);
      ChkMin;

      Dss := Dss + 60;
    end;
  end;

begin
  if (CompareDateTime(ODate, NDate) = GreaterThanValue)  then
  begin
    Increment := false;
    DecodeDateTime(NDate, LY, LM, LD, Lhh, Lmm, Lss, Lmss);
    DecodeDateTime(ODate, HY, HM, HD, Hhh, Hmm, Hss, Hmss);
    CY := LY;
    CM := LM;
  end
  else
  begin
    Increment := true;
    DecodeDateTime(ODate, LY, LM, LD, Lhh, Lmm, Lss, Lmss);
    DecodeDateTime(NDate, HY, HM, HD, Hhh, Hmm, Hss, Hmss);
    CY := HY;
    CM := HM;
  end;

  ChkYear(false);
  ChkMonth(false);
  ChkDay(false);
  ChkHour(false);
  ChkMin(false);
  Chkss(false);

  result := Format('%.4d:%.2d:%.2d %.2d:%.2d:%.2d',
                   [DY, DM, DD, Dhh, Dmm, Dss]);

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

procedure NewSizeRetainRatio(W, H, MaxW, MaxH: integer; var NewW, NewH: integer; Portrait: boolean = false);
var
  ImgRatio: Double;
begin
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
end;

function WicPreview(AImg: string; Rotate, MaxW, MaxH: cardinal): IWICBitmapSource;
var
  IwD: IWICBitmapDecoder;
  IwdR: IWICBitmapFlipRotator;
  IwdS: IWICBitmapScaler;
  W, H: cardinal;
  NewW, NewH: integer;
  Portrait: boolean;
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

  NewSizeRetainRatio(W, H, MaxW, MaxH, NewW, NewH, Portrait);

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

// Prepares a Bitmap
// - Centers Bitmap in Rectangle WxH
// - Stretch True/False. Uses maximum size, or keeps original
// - Retains aspect ratio.
// - Transparent using backcolor.
procedure ResizeBitmapCanvas(Bitmap: TBitmap; MaxW, MaxH: integer;
                             BackColor: TColor; Stretch: boolean = true);
var
  Bmp: TBitmap;
  Left, Top: integer;
  ActualW, ActualH: integer;
begin
  if (Stretch) then
  begin
    NewSizeRetainRatio(Bitmap.Width, Bitmap.Height, MaxW, MaxH, ActualW, ActualH);
    Left := (MaxW - ActualW) div 2;
    Top := (MaxH - ActualH) div 2;
  end
  else
  begin
    Left := (MaxW - Bitmap.Width) div 2;
    Top := (MaxH - Bitmap.Height) div 2;
  end;

  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(MaxW, MaxH);
    Bmp.Canvas.Brush.Style := bsSolid;
    Bmp.Canvas.Brush.Color := BackColor;
    Bmp.AlphaFormat := TAlphaFormat.afDefined;
    Bmp.Canvas.FillRect(Rect(0, 0, MaxW, MaxH));
    if (Stretch) then
      Bmp.Canvas.StretchDraw(Rect(Left, Top, Left + ActualW, Top + ActualH), BitMap)
    else
      Bmp.Canvas.Draw(Left, Top, BitMap);

    Bitmap.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

function BitMapFromHBitMap(ABmp: HBITMAP; W, H: Integer; BkColor: TColor): TBitMap;
begin
  result := TBitmap.Create;
  result.Canvas.Lock;
  try
    result.Handle := ABmp;
    result.AlphaFormat := TAlphaFormat.afDefined;
    ResizeBitmapCanvas(result, W, H, BkColor);
  finally
    result.Canvas.Unlock;
    DeleteObject(ABmp);
  end;
end;

function MessageDlgEx(const AMsg, ACaption: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons; UseTaskMessage: boolean = false): integer;
var
  MsgFrm: TForm;
  NCaption: string;
begin
  if (ACaption = '') then
    NCaption := Application.Title
  else
    NCaption := ACaption;
  if UseTaskMessage then // This dialog can be used after shutdown. E.G. in finalization
    result := TaskMessageDlg(NCaption, AMsg, ADlgType, AButtons, 0)
  else
  begin
    MsgFrm := CreateMessageDialog(AMsg, ADlgType, AButtons);
    try
      MsgFrm.Caption := NCaption;
      MsgFrm.Position := poDefaultSizeOnly;
      MsgFrm.FormStyle := fsStayOnTop;
      result := MsgFrm.ShowModal;
    finally
      MsgFrm.Free;
    end;
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
    ET.OpenExec(ETcmd, SelectedFile, ETResult);
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

procedure StyledDrawListviewItem(FstyleServices: TCustomStyleServices;
                                 ListView: TCustomListView;
                                 Item: TlistItem;
                                 State: TCustomDrawState);
begin
  if Assigned(FStyleServices) and
     (Item.Selected) then
  begin
    ListView.Canvas.Font.Color := FStyleServices.GetStyleFontColor(TStyleFont.sfGridItemSelected);
    if ([cdsSelected, cdsFocused, cdsHot] * State <> []) then
    begin
      ListView.Canvas.Brush.Color := FStyleServices.GetSystemColor(clHighlight);
      ListView.Canvas.FillRect(Item.DisplayRect(drBounds));
    end;
  end;
end;

function GetTags(ETResult: TStringList; CmbTags: TComboBox): TTagInfoList;
var
  Aline: string;
  AResult: string;
  ATagInfo: TTagInfo;
  First: boolean;
  ThisWidth: integer;
begin
  result := TTagInfoList.Create;
  CmbTags.Tag := -1;
  First := true;
  for Aline in ETResult do
  begin
    AResult := ALine;
    with ATagInfo do
    begin
      GroupName   := NextField(AResult, '[');             // Strip Leading [
      GroupName   := NextField(AResult, ']');             // Group name
      if (First) then
      begin
        TagName := 'All';
        TagValue := '';
        result.Add(ATagInfo);
        First := false;
      end;
      TagName    := Trim(NextField(AResult, ':'));
      TagValue   := Trim(AResult);

      ThisWidth  := CmbTags.Canvas.TextWidth(GroupName + ':' + TagName + '|');
      if (ThisWidth > CmbTags.Tag) then
        CmbTags.Tag := ThisWidth;

      result.Add(ATagInfo);
    end;
  end;
end;

procedure FillGroupsInCombo(SelectedFile: string; CmbTags: TComboBox; const Family: string);
var
  Indx: integer;
  ETCmd, AGroupLine: string;
  ETResult, ETUnSorted: TStringList;
  ANItem: string;
begin
  CmbTags.Items.BeginUpdate;
  ETResult := TStringList.Create;
  try
    CmbTags.Items.Clear;
    if (SelectedFile <> '') then
    begin
      CmbTags.Items.Add('All');
      ETUnSorted := TStringList.Create;
      try
        ETResult.Sorted := true;
        ETResult.Duplicates := TDuplicates.dupIgnore;
        ETCmd := '-sort' + CRLF + '-s1' + CRLF + '-G' + Family;
        ET.OpenExec(ETcmd, SelectedFile, ETUnSorted);
        for Indx := 0 to ETUnSorted.Count -1 do
        begin
          AGroupLine  := ETUnSorted[Indx];
          ANItem      := NextField(AGroupLine, '[');             // Strip Leading [
          ANItem      := NextField(AGroupLine, ']');             // Group name
          ETResult.Add(ANItem);
        end;
      finally
        ETUnSorted.Free;
      end;
    end
    else
    begin
      ETCmd := '-listg' + Family;
      ET.OpenExec(ETcmd, '', ETResult);
    end;

    for Indx := 1 to ETResult.Count -1 do
    begin
      AGroupLine := ETResult[Indx];
      while (AGroupLine <> '') do
      begin
        ANItem := NextField(AGroupLine, ' ');
        if (Trim(ANItem) <> '') then
          CmbTags.Items.Add(ANItem);
      end;

    end;
  finally
    ETResult.Free;
    CmbTags.Items.EndUpdate;
    CmbTags.Text := CmbTags.Items[0];
  end;
end;

procedure FillTagsInCombo(SelectedFile: string; CmbTags: TComboBox; const Family, GroupName: string);
var
  Indx: integer;
  ETCmd, AGroupLine: string;
  ETResult: TStringList;
  ANItem: string;
  ATagInfoList: TTagInfoList;
  ATagInfo: TTagInfo;
begin
  ETResult := TStringList.Create;
  CmbTags.Items.BeginUpdate;
  try
    CmbTags.Items.Clear;
    if (SelectedFile <> '') then
    begin
      ETCmd := '-sort' + CRLF + '-s1' + CRLF + '-a' + CRLF + '-G' + Family + CRLF + '-' + Groupname + ':All';
      ET.OpenExec(ETcmd, SelectedFile, ETResult);
      ATagInfoList := GetTags(ETResult, CmbTags);
      try
        for ATagInfo in ATagInfoList do
        begin
          ANItem := ATagInfo.GroupName + ':' + ATagInfo.TagName;
          if (ATagInfo.TagValue <> '') then
            ANItem := ANItem + '|' + ATagInfo.TagValue;
          CmbTags.Items.Add(ANItem);
        end;
      finally
        ATagInfoList.Free;
      end;
    end
    else
    begin
      ETCmd := '-listw' + CRLF + '-' + Groupname + ':All';
      ET.OpenExec(ETcmd, '', ETResult);
      CmbTags.Items.Add('All');
      for Indx := 1 to ETResult.Count -1 do
      begin
        AGroupLine := ETResult[Indx];
        while (AGroupLine <> '') do
        begin
          ANItem := NextField(AGroupLine, ' ');
          if (Trim(ANItem) <> '') then
            CmbTags.Items.Add(ANItem);
        end;
      end;
      CmbTags.Tag := CmbTags.Width;
    end;

  finally
    ETResult.Free;
    CmbTags.Items.EndUpdate;
    CmbTags.Text := CmbTags.Items[0];
  end;
end;

procedure DrawItemTagName(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  TagName, TagValue: string;
  ACanvas: TCanvas;
  DrawRect: TRect;
  LinePos: integer;
begin
  // Split item in Code and name
  TagValue := TComboBox(Control).Items[index];
  TagName := NextField(TagValue, '|');

  // Compute the position of the dividing line
  ACanvas := TComboBox(Control).Canvas;
  ACanvas.FillRect(Rect);
  LinePos := Control.Tag + Rect.Left;
  if (LinePos > Rect.Right) then
    LinePos := Rect.Width div 2;

  // Draw Tag Name
  DrawRect:= Rect;
  DrawRect.Right := LinePos;
  ACanvas.TextRect(DrawRect, TagName, [TTextFormats.tfLeft, TTextFormats.tfSingleLine]);

  if (TagValue <> '') then
  begin
    // Draw Line
    ACanvas.Pen.Color := TStyleManager.Style[GUIsettings.GuiStyle].GetStyleFontColor(TStyleFont.sfListItemTextNormal);
    ACanvas.MoveTo(LinePos, Rect.Top);
    ACanvas.LineTo(LinePos, Rect.Bottom);

    // Draw Tag Value
    DrawRect:= Rect;
    DrawRect.Left := LinePos + ACanvas.TextWidth('Q');
    ACanvas.TextRect(DrawRect, TagValue, [TTextFormats.tfLeft, TTextFormats.tfSingleLine]);
  end;

end;

procedure SetTagItem(const AnItem: TlistItem; ACaption: string = '');
var
  ImgIndex: integer;
begin
  if (ACaption <> '') then
    AnItem.Caption := ACaption;
  if (Pos('-', AnItem.Caption) = 1) then
    ImgIndex := 0
  else
    ImgIndex := 2;
  if (AnItem.Checked) then
    Inc(ImgIndex);
  AnItem.ImageIndex := ImgIndex;
end;

function RemoveInvalidTags(const Tag: string; AllowExclude: boolean = false): string;
const
  InvalidChars: array of Char = [' ', '<', '='];
var
  AChar: Char;
begin
  result := Tag;
  if (not AllowExclude) and
     (Pos('-', Tag) = 1) then
     Delete(result, 1, 1);

  for AChar in InvalidChars do
    result := StringReplace(result, AChar, '', [rfReplaceAll]);

  if result <> Tag then
    MessageDlgEx(Format(StrInvalidCharsRemoved, [Tag]), '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
end;

function GetGroupNameFromTag(ATag: string): string;
var
  P: integer;
begin
  result := '';

  // Group name ends with :
  P := Pos(':', ATag);
  if (P > 0) then
    result := Copy(ATag, 1 , P -1);

  // - In group name?
  P := Pos('-', result, 2);
  if (P > 0) then
    SetLength(result, P -1);

  // - Exclusion
  if (Length(result) > 1) and
     (result[1] = '-') then
    result := Copy(result, 2);
end;

function GetGroupIdForLv(AListView: TListView; AGroupName: string): integer;
var
  Indx: integer;
  AGroup: TListGroup;
begin
  for Indx := 0 to AListView.Groups.Count -1 do
  begin
    AGroup := AListView.Groups[Indx];
    if (AGroup.Header = AGroupName) then
    begin
      AGroup.State := [TListGroupState.lgsNormal];
      AGroup.Footer := '________';
      AGroup.FooterAlign := TAlignment.taCenter;
      exit(AGroup.GroupId);
    end;
  end;
  AGroup := AListView.Groups.Add;
  AGroup.Header := AGroupName;
  AGroup.State := [TListGroupState.lgsNoHeader];
  result := AGroup.GroupID;
end;

function CreateTrkPoints(const LogPath: string; FirstGpx: boolean; var LastCoord: string): integer;
const
  HasUTC = ' UTC ';
  HasLog = ' GPS track log file ';
var
  SavedVerbose: integer;
  ALine, Akey, ALon, Alat, ALogName, ETcmd: string;
  ETout: TStringList;
  P, Indx, PointNum: integer;
  F: textFile;
begin
  result := 0;
  PointNum := 0;

  SavedVerbose := ET.Options.GetVerbose;
  EtOut := TStringList.Create;
  AssignFile(F, GetTrackTmp);
  if not FileExists(GetTrackTmp) or
     FirstGpx then
    Rewrite(F)
  else
    Append(F);

  try
    ETcmd := '-geotag' + CRLF + LogPath + CRLF;
    ET.Options.SetVerbose(4);
    ET.OpenExec(ETcmd, 'NUL', ETout, false);
{$IFDEF DEBUG}
    ETout.SaveToFile(ChangeFileExt(GetTrackTmp, '.dbg'));
{$ENDIF}
    ALogName := '';
    for Indx := 0 to ETout.Count -1 do
    begin
      ALine := ETout[Indx];
      P := Pos(HasLog, ALine);
      if (P > 0) then
      begin
        if (ALogName <> '') then // Multiple Log's
        begin
          Writeln(F, 'CreateTrack(''' + ALogName + ''');');
          PointNum := 0;
        end;
        // Get the filename of the log.
        // Enclosed by quotes
        // Need to replace / by \ (E.G. If *.gpx is used)
        // Need to replace ' by \' for JavaScript
        ALogName := Copy(LeftStr(ALine, Length(Aline) -1), P + Length(HasLog) +1);
        ALogName := ExtractFileName(StringReplace(ALogName, '/', '\', [rfReplaceAll]));
        ALogName := StringReplace(ALogName, '''', '\''', [rfReplaceAll]);
        continue;
      end;
      P := Pos(HasUTC, ALine);
      if (P < 1) then
        continue;
      ALine := Copy(ALine, P  + Length(HasUTC));
      ALat := '';
      ALOn := '';
      while (ALine <> '') and
            ((ALat = '') or (ALon = '')) do
      begin
        AKey := StringReplace(NextField(ALine, ' '), ',', '.', [rfReplaceAll]);
        if (LeftStr(AKey, 4) = 'lat=') then
        begin
          Alat := AKey;
          AKey := NextField(Alat, '=');
        end;
        if (LeftStr(AKey, 4) = 'lon=') then
        begin
          ALon := AKey;
          AKey := NextField(ALon, '=');
        end;
      end;
      if (ValidLatLon(Alat, ALon)) then
      begin
        AdjustLatLon(ALat, ALon, Coord_Decimals);
        Inc(result);
        Inc(PointNum);
        Writeln(F, 'AddTrkPoint(', PointNum, ',', ALat, ',', ALon, ');');
      end;
    end;
  finally
    LastCoord := ALat + ', ' + ALon;
    if (PointNum > 0) then
      Writeln(F, 'CreateTrack(''' + ALogName + ''');');
    CloseFile(F);
    ET.Options.SetVerbose(SavedVerbose);
    ETout.Free;
  end;
end;

function GetGpsCoordinates(const Images: string): string;
var
  ETCmd: string;
  ETerrs: string;
begin
  ETcmd := '-s3' + CRLF + '-f' + CRLF + '-n' + CRLF + '-q';
  ETcmd := ETcmd + CRLF + '-Directory';
  ETcmd := ETcmd + CRLF + '-Filename';
  ETcmd := ETcmd + CRLF + '-Composite:GpsLatitude';
  ETcmd := ETcmd + CRLF + '-GpsLatitude';
  ETcmd := ETcmd + CRLF + '-Composite:GpsLongitude';
  ETcmd := ETcmd + CRLF + '-GpsLongitude';
  ETcmd := ETcmd + CRLF + '-MIMEType';
  ETcmd := ETcmd + CRLF + '-QuickTime:MajorBrand';
  ET.OpenExec(ETcmd, Images, result, ETerrs, false);
end;

function AnalyzeGPSCoords(var ETout, Lat, Lon, MIMEType: string; var IsQuickTime: boolean): string;
var
  QuickTimeMajorBrand: string;
  CompLat, CompLon: string;
begin
  result := NextField(ETout, CRLF);
  if (result = '.') then
    result := '';
  if (result <> '') then
    result := IncludeTrailingPathDelimiter(StringReplace(result, '/', '\', [rfReplaceAll]));
  result := result + NextField(ETout, CRLF);

  // Take Composite Lat & Lon. If not avail get without group.
  // Needed to get Lat & Lon for .XMP files. They are not avail in composite
  // Maybe better to read only without group, but kept for compatibility.
  CompLat := NextField(ETout, CRLF);
  Lat := NextField(ETout, CRLF);
  if (Lat = '-') then
    Lat := CompLat;

  CompLon := NextField(ETout, CRLF);
  Lon := NextField(ETout, CRLF);
  if (Lon = '-') then
    Lon := CompLon;

  MIMEType := NextField(ETout, CRLF);
  QuickTimeMajorBrand := NextField(ETout, CRLF);
  IsQuickTime := QuickTimeMajorBrand <> '-';
end;

procedure FillLocationInImage(const ANImage: string);
var
  Foto: FotoRec;
  ETCmd: string;
  APlace: TPlace;
  GPSCoordinates, Lat, Lon, MIMEType: string;
  IsQuickTime: boolean;
begin
  Foto := GetMetadata(ANImage, [TGetOption.gmGPS]);
  if (Foto.GPS.HasData) then
  begin
    Lat := Foto.GPS.GeoLat;
    Lon := Foto.GPS.GeoLon;
    IsQuickTime := false;
  end
  else
  begin
    GPSCoordinates := GetGpsCoordinates(ANImage);
    AnalyzeGPSCoords(GPSCoordinates, Lat, Lon, MIMEType, IsQuickTime);
  end;
  if (ValidLatLon(Lat, Lon)) then
  begin
    AdjustLatLon(Lat, Lon, Place_Decimals);
    APlace := GetPlaceOfCoords(Lat, Lon, GeoSettings.GetPlaceProvider);
    if not Assigned(APlace) then
      exit;

// Compatibility with exiftool -geolocation
    Etcmd := '-xmp:CountryCode=' + APlace.CountryCode;;
    Etcmd := Etcmd + CRLF + '-xmp:Country=' + APlace.CountryName;
    Etcmd := Etcmd + CRLF + '-xmp:State=' + APlace.Province;
    Etcmd := Etcmd + CRLF + '-xmp:City=' + APlace.City;
//
    ETCmd := ETCmd + CRLF + '-xmp:LocationShownCountryCode=' + APlace.CountryCode;
    ETCmd := ETCmd + CRLF + '-xmp:LocationShownCountryName=' + APlace.CountryName;
    ETCmd := ETCmd + CRLF + '-xmp:LocationShownProvinceState=' + APlace.Province;
    ETCmd := ETCmd + CRLF + '-xmp:LocationShownCity=' + APlace.City;

    ET.OpenExec(ETcmd, ANImage);
  end;
end;

function GetExifToolLanguage(const ACombo: TComboBox): string;
var
  AText: string;
begin
  result := '';
  if (ACombo.ItemIndex > 0) then // First entry is the default, return ''
  begin
    AText := ACombo.Items[ACombo.ItemIndex];
    result := NextField(AText, ' ');
  end;
end;

procedure ExifToolLanguages(const ACombo: TComboBox; Defaults: array of string);
var
  Indx: integer;
  SavedLang: string;
  ADefault: string;
begin
  SavedLang := ET.Options.ETLangDef;
  ET.Options.SetLangDef(''); // get list of languages in default lang.
  try
    ET.OpenExec('-lang', '', ACombo.Items, false);
    if ACombo.Items.Count > 0 then
      ACombo.Items.Delete(0);

    for ADefault in Defaults do
      ACombo.Items.Insert(0, Adefault);

    for Indx := 0 to ACombo.Items.Count - 1 do
      ACombo.Items[Indx] := TrimLeft(ACombo.Items[Indx]);
  finally
    ET.Options.SetLangDef(SavedLang);
  end;
end;

procedure SetupLanguageCombo(const CmbLang: TComboBox; ALang: string);
var
  Indx: integer;
begin
  CmbLang.ItemIndex := 0;

  // look up Selected language in dropdown list. DropDown list looks like:
  // de - German
  // en - English
  // etc.
  if (ALang <> '') then
  begin
    for Indx := 1 to CmbLang.Items.Count -1 do // Skip 'Default'
    begin
      if (StartsText(ALang, CmbLang.Items[Indx])) then
      begin
        CmbLang.ItemIndex := Indx;
        break;
      end;
    end;
  end;

  CmbLang.Text := CmbLang.Items[CmbLang.ItemIndex];
end;

procedure SetupExifToolLanguage(const ACombo: TComboBox; ALang: string);
begin
  ExifToolLanguages(ACombo, ['ExifTool standard (short)']);

  SetupLanguageCombo(ACombo, ALang);
end;

procedure SetupGeoCodeLanguage(const ACombo: TComboBox; AProvider: TGeoCodeProvider; ALang: string);
begin
  ACombo.Items.BeginUpdate;
  try
    case AProvider of
      TGeoCodeProvider.gpOverPass:
        begin
          ExifToolLanguages(ACombo, [PlaceLocal, PlaceDefault]);
          ACombo.Enabled := true;
        end;
      TGeoCodeProvider.gpExifTool:
        begin
          ExifToolLanguages(ACombo, [PlaceDefault]);
          ACombo.Enabled := true;
        end;
      else
      begin
        ACombo.Items.Clear;
        ACombo.Items.Add(PlaceDefault);
        ACombo.Enabled := false;
      end;
    end;

    SetupLanguageCombo(ACombo, ALang);

  finally
    ACombo.Items.EndUpdate;
  end;
end;

function ExifToolGeoLocation(const Lat, Lon, Lang:string): TStringList;
var
  ETCmd: string;
  SavedLang: string;
begin
  SavedLang := ET.Options.ETLangDef;
  if (Lang <> PlaceDefault) and
     (Lang <> PlaceLocal) then
    ET.Options.SetLangDef(Lang)
  else
    ET.Options.SetLangDef('');

  try
    result := TStringList.Create;
    ETcmd := '-short' + CRLF + '-f' + CRLF + '-n' + CRLF + '-q';
    ETcmd := ETCmd + CRLF + '-api' + CRLF + Format('geolocation=%s,%s', [Lat, Lon]);
    ETcmd := ETcmd + CRLF + '-GeolocationCountryCode';
    ETcmd := ETcmd + CRLF + '-GeolocationCountry';
    ETcmd := ETcmd + CRLF + '-GeolocationRegion';
    ETcmd := ETcmd + CRLF + '-GeolocationCity';
    ET.OpenExec(ETcmd, '', result, false);
  finally
    ET.Options.SetLangDef(SavedLang);
  end;
end;

function ExifToolGeoLocation(const City, CountryRegion, Match, Lang: string; var ETErr:string): string;
var
  ETCmd: string;
  SavedLang: string;
begin
  SavedLang := ET.Options.ETLangDef;
  if (Lang <> PlaceDefault) and
     (Lang <> PlaceLocal) then
    ET.Options.SetLangDef(Lang)
  else
    ET.Options.SetLangDef('');

  try
    ETcmd := '-m' + CRLF + '-a';
    ETcmd := ETCmd + CRLF + '-api' + CRLF + Format('geolocation=ci/%s/i', [City]);

    if (CountryRegion <> '') then
      ETcmd := ETCmd + Format(',%s/%s/i',[Match, CountryRegion]);

    ET.OpenExec(ETcmd, '', result, ETerr, false);
  finally
    ET.Options.SetLangDef(SavedLang);
  end;
end;

function ExifToolGetCountryList: TStringList;
var
  ETout: TStringList;
  ETcmd, Country, CountryName: string;
  Indx: integer;
begin
  result := TStringList.Create;
  result.Sorted := true;
  ETOut := TStringList.Create;
  try
    ETcmd := '-listgeo' + CRLF + '-api' + CRLF + 'GeoLocFeature=pplc';
    ET.OpenExec(ETcmd, '', ETOut, false);
    if (ETOut.Count > 2) then
    begin
      ETOut.Delete(0); // Delete some header lines
      ETOut.Delete(0);
      for Indx := 0 to ETOut.Count -1 do
      begin
        CountryName := ETOut[Indx];
        Country := NextField(CountryName, ',');
        Country := NextField(CountryName, ',');
        Country := NextField(CountryName, ',');
        Country := NextField(CountryName, ',');
        CountryName := NextField(CountryName, ',');
        result.AddPair(Country, CountryName);
      end;
    end;
  finally
    ETout.Free;
  end;
end;

function GetIsQuickTime(const AFile: string): boolean;
var
  ETCmd, ETOuts, ETErrs: string;
begin
  ETcmd := '-s3' + CRLF + '-f' + CRLF + '-n' + CRLF + '-q' + CRLF + '-QuickTime:MajorBrand';
  ET.OpenExec(ETcmd, AFile, ETOuts, ETErrs, false);
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
// PtgGroups is defined as Array[0..0] need $R- or you will get a range check!
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
    Reg.WriteString('Icon', '"'+ ParamStr(0) + '"');
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
  TempDirectory := IncludeTrailingPathDelimiter(CreateTempPath(TempPrefix));
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
