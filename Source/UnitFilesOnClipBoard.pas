unit UnitFilesOnClipBoard;

// Details needed for creating this unit obtained from:
// https://github.com/landrix/The-Drag-and-Drop-Component-Suite-for-Delphi
// https://www.freepascal.org/~michael/articles/dragdrop2/dragdrop2.pdf
// Many thanks!

{$WRITEABLECONST ON}

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Winapi.ActiveX,
  Vcl.Shell.ShellCtrls,
  ExifToolsGui_ShellTree;


procedure SetFileNamesOnClipboard(const FileNames: TStrings; Cut: boolean = false);
function GetFileNamesFromClipboard(const FileNames: TStrings; var Cut: boolean): boolean;
procedure PasteFilesFromClipBoard(const ShellTree: TCustomShellTreeView; FileList: TStrings; TargetDir: string; Cut: boolean = false);

implementation

uses
  System.UITypes,
  Winapi.ShlObj, Winapi.UrlMon, Winapi.ShellAPI,
  ExifToolsGUI_Utils, UnitLangResources;

var
  CF_PREFERREDDROPEFFECT: TClipFormat = 0;

// Only 2 formats needed.
type TSupportedFormats = array[0..1] of TFormatEtc;

const SupportedFormats: TSupportedFormats =
(
      (cfFormat: 0;        ptd: nil; dwAspect: DVASPECT_CONTENT; lindex: -1; tymed: TYMED_HGLOBAL),  //cfFormat needs registering
      (cfFormat: CF_HDROP; ptd: nil; dwAspect: DVASPECT_CONTENT; lindex: -1; tymed: TYMED_HGLOBAL)
);

 	IdFormatCut = 0;
	IdFormatCopy = 1;

function Format2Id(Fmt: TClipFormat): integer;
begin
  result := -1;
  if (Fmt = CF_PREFERREDDROPEFFECT) then
    result := IdFormatCut
  else if (Fmt = CF_HDROP) then
    result := IdFormatCopy;
end;

type
  TDataObjectFiles = class(TinterfacedObject, IDataObject)
    FMedia: array of TStgMedium;
    // IDataObject implementation
    function GetData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const FormatEtc: TFormatEtc; out Medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const FormatEtc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const FormatEtc: TFormatEtc; out FormatEtcout: TFormatEtc): HResult; stdcall;
    function SetData(const FormatEtc: TFormatEtc; var Medium: TStgMedium; fRelease: Bool): HResult; stdcall;
    function EnumFormatEtc(dwDirection: LongInt; out EnumFormatEtc: IEnumFormatEtc): HResult; stdcall;
    function dAdvise(const FormatEtc: TFormatEtc; advf: LongInt; const advsink: IAdviseSink;
                     out dwConnection: LongInt): HResult; stdcall;
    function dUnadvise(dwConnection: LongInt): HResult; stdcall;
    function EnumdAdvise(out EnumAdvise: IEnumStatData): HResult; stdcall;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TEnumFormatEtc = class(TinterfacedObject, IEnumFormatEtc)
  private
    FIndex: integer;
  protected
    constructor CreateClone(AIndex: integer);
  public
    constructor Create;
    destructor Destroy; override;

    { IEnumFormatEtc implentation }
    function Next(Celt: LongInt; out Elt; pCeltFetched: pLongInt): HResult; stdcall;
    function Skip(Celt: LongInt): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumFormatEtc): HResult; stdcall;
  end;

constructor TEnumFormatEtc.Create;
begin
  inherited Create;
  FIndex := 0;
end;

constructor TEnumFormatEtc.CreateClone(AIndex: integer);
begin
  Create;
  FIndex := AIndex;
end;

destructor TEnumFormatEtc.Destroy;
begin
  inherited Destroy;
end;

function TEnumFormatEtc.Next(Celt: LongInt; out Elt; pCeltFetched: pLongInt): HResult;
var
  i: integer;
  FormatEtc: PFormatEtc;
begin
  i := 0;
  FormatEtc := PFormatEtc(@Elt);
  while (i < Celt) and (FIndex <= High(SupportedFormats)) do
  begin
    FormatEtc^ := SupportedFormats[FIndex];
    Inc(FormatEtc);
    Inc(i);
    Inc(FIndex);
  end;

  if (pCeltFetched <> nil) then
    pCeltFetched^ := i;

  if (i = Celt) then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TEnumFormatEtc.Skip(Celt: LongInt): HResult;
begin
  Result := E_NOTIMPL;
end;

function TEnumFormatEtc.Reset: HResult;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumFormatEtc.Clone(out Enum: IEnumFormatEtc): HResult;
begin
  Enum := TEnumFormatEtc.CreateClone(FIndex);
  Result := S_OK;
end;

/// DataObject

function TDataObjectFiles.GetData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium): HResult;
var FmtId: integer;
begin
  Result := S_OK;
  FmtId := Format2Id(FormatEtcIn.cfFormat);
  if (FmtId >= 0) then
    CopyStgMedium(FMedia[FmtId], Medium)
  else
    Result := S_FALSE;
end;

function TDataObjectFiles.GetDataHere(const FormatEtc: TFormatEtc; out Medium: TStgMedium): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TDataObjectFiles.QueryGetData(const FormatEtc: TFormatEtc): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TDataObjectFiles.GetCanonicalFormatEtc(const FormatEtc: TFormatEtc; out FormatEtcout: TFormatEtc): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TDataObjectFiles.EnumFormatEtc(dwDirection: LongInt; out EnumFormatEtc: IEnumFormatEtc): HResult; stdcall;
begin
  EnumFormatEtc := TEnumFormatEtc.Create as IEnumFormatEtc;
  Result := S_OK;
end;

function TDataObjectFiles.dAdvise(const FormatEtc: TFormatEtc; advf: LongInt; const advsink: IAdviseSink;
                                   out dwConnection: LongInt): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TDataObjectFiles.dUnadvise(dwConnection: LongInt): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TDataObjectFiles.EnumdAdvise(out EnumAdvise: IEnumStatData): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TDataObjectFiles.SetData(const FormatEtc: TFormatEtc; var Medium: TStgMedium; fRelease: Bool): HResult;
var FmtId: integer;
begin
  try
    Result := S_OK;
    FmtId := Format2Id(FormatEtc.cfFormat);
    if (FmtId >= 0) then
      CopyStgMedium(Medium, FMedia[FmtId])
    else
      Result := S_FALSE;
  finally
    if (fRelease) then
      ReleaseStgMedium(Medium);
  end;
end;

constructor TDataObjectFiles.Create;
begin
  inherited;
  SetLength(FMedia, Length(SupportedFormats));
end;

destructor TDataObjectFiles.Destroy;
var AMedium: TStgMedium;
    Index: integer;
begin
  for Index := 0 to High(FMedia) do
  begin
    AMedium := FMedia[Index];
    ReleaseStgMedium(AMedium);
  end;
  SetLength(FMedia, 0);

  inherited;
end;

procedure ClipboardError;
begin
  raise Exception.Create(StrCouldNotCompleteC);
end;

procedure CheckHR(Hr: HResult);
begin
  if (Hr <> S_OK) then
    ClipboardError;
end;

procedure CheckClipboardHandle(Handle: HGLOBAL);
begin
  if (Handle = 0) then
    ClipboardError;
end;

procedure PutOnClipboard(Buffer: Pointer; Count: integer; Cut: boolean);
var
  Handle: HGLOBAL;
  Ptr: Pointer;
  Fmt: tagformatetc;
  StgMedium2: STGMEDIUM;
  DataObject: IDataObject;

  procedure SetupStgMedium(const APointer: pointer);
  begin
    FillChar(StgMedium2, sizeof(StgMedium2), 0);
    StgMedium2.tymed := TYMED_HGLOBAL;
    StgMedium2.unkForRelease := nil;
    StgMedium2.HGLOBAL := NativeInt(APointer);
  end;

begin

  Handle := GlobalAlloc(GMEM_MOVEABLE, Count);
  try
    CheckClipboardHandle(Handle);
    Fmt := SupportedFormats[IdFormatCopy];

    Ptr := GlobalLock(Handle);
    SetupStgMedium(Ptr);
    Move(Buffer^, Ptr^, Count);
    GlobalUnlock(StgMedium2.HGLOBAL);

    DataObject := TDataObjectFiles.Create as IDataObject;
    CheckHR(DataObject.SetData(Fmt, StgMedium2, true));
  except
    GlobalFree(StgMedium2.HGLOBAL);
    raise;
  end;

  if (Cut) then
  begin
    Handle := GlobalAlloc(GMEM_MOVEABLE, sizeof(DWord));

    Ptr := GlobalLock(Handle);
    SetupStgMedium(Ptr);

    try
      DWord(Ptr^) := DROPEFFECT_MOVE;
      GlobalUnlock(stgmedium2.HGLOBAL);

      Fmt := SupportedFormats[IdFormatCut];
      CheckHR(DataObject.SetData(Fmt, stgmedium2, true));
    Except
      GlobalFree(StgMedium2.HGLOBAL);
      raise;
    End;
  end;
  CheckHR(OleSetClipboard(DataObject));
  DataObject := nil;
end;

function FileList2String(const Values: TStrings): string;
var AFile: string;
begin
  result := '';
  for AFile in Values do
    result := result + AFile + #0;
  result := result + #0;
end;

procedure DropFiles2FileList(const Values: HDROP; FileNames: TStrings);
var Files: array of Char;
    PFiles: PChar absolute Files;
    LFiles: integer;
    Index: integer;
    FilesCount: integer;
begin
  FileNames.Clear;
  FilesCount := DragQueryFile(Values, UINT(-1), nil, 0);       // nr. of files
  for Index := 0 to FilesCount -1 do
  begin
    LFiles := DragQueryFile(Values, Index, nil, 0) +1;          // Required size +1 for #0
    SetLength(Files, LFiles);                                   // Resize array
    DragQueryFile(Values, Index, PFiles, LFiles);               // Get Filename
    FileNames.Add(PFiles);                                      // Add to Strings
  end;
end;

procedure SetFileNamesOnClipboard(const FileNames: TStrings; Cut: boolean = false);
var
  Size: integer;
  FileList: string;
  DropFiles: PDropFiles;
begin
  FileList := FileList2String(FileNames);
  Size := SizeOf(TDropFiles) + ByteLength(FileList);
  DropFiles := AllocMem(Size);
  try
    DropFiles.pFiles := sizeof(TDropFiles);
    DropFiles.fWide := true;
    Move(Pointer(FileList)^, (PByte(DropFiles) + sizeof(TDropFiles))^, ByteLength(FileList));
    PutOnClipboard(DropFiles, Size, Cut);

  finally
    OleFlushClipboard;
    FreeMem(DropFiles);
  end;
end;

function GetFileNamesFromClipboard(const FileNames: TStrings; var Cut: boolean): boolean;
var P: PDword;
    Handle: THandle;
begin
  Result := false;
  FileNames.Clear;
  Cut := false;
  if IsClipboardFormatAvailable(CF_HDROP) then
  begin
    Result := true;
    OpenClipboard(0);
    try
      Handle := GetClipboardData(CF_HDROP);
      DropFiles2FileList(Handle, FileNames);
      if IsClipboardFormatAvailable(CF_PREFERREDDROPEFFECT) then
      begin
        P := PDword(GetClipboardData(CF_PREFERREDDROPEFFECT));
        if (Assigned(P)) and
           (P^ = DROPEFFECT_MOVE) then
          Cut := true;
      end;
    finally
      CloseClipboard;
    end;
  end;
end;

procedure PasteFilesFromClipBoard(const ShellTree: TCustomShellTreeView; FileList: TStrings; TargetDir: string; Cut: boolean = false);
var
  AFile: string;
  TargetFile: string;
  Succes: boolean;
  WriteFile: boolean;
  OverWriteAll: boolean;
  Confirmation: integer;
  CrNormal, CrWait: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  OverWriteAll := false;
  try
    for AFile in FileList do
    begin
      // Let SHFileOperation handle directories
      if (DirectoryExists(AFile, false)) then
      begin
        if not PasteDirectory(AFile, TargetDir, Cut) then
          raise Exception.Create(Format(StrOverwriteSFailed, [AFile]));
        continue;
      end;

      // Dont copy to same directory.
      TargetFile := IncludeTrailingPathDelimiter(TargetDir) + ExtractFileName(AFile);
      if (CompareText(TargetFile, AFile) = 0) then
        raise Exception.Create(StrSourceAndTargetSh);

      // Overwrite ?
      WriteFile := OverWriteAll;
      if not WriteFile then
        WriteFile := not FileExists(TargetFile);
      if not WriteFile then
      begin
        Confirmation := MessageDlgEx(Format(StrFileSExistsOver, [TargetFile]), '',
                                     TMsgDlgType.mtWarning,
                                     [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel, TMsgDlgBtn.mbYesToAll]
                                    );
        case Confirmation of
          MrYes:
            WriteFile := true;
          MrNo:
            WriteFile := false;
          MrCancel:
            exit;
          mrYesToAll:
          begin
            WriteFile := true;
            OverWriteAll := true;
          end;
        end;
      end;

      // Write file?
      if not (WriteFile) then
        continue;

      SetCursor(CrWait);  // Set cursor again. Confirmation dialog could have reset it.
      if (Cut) then
        Succes := MoveFile(PWideChar(AFile), PWideChar(TargetFile))
      else
        Succes := CopyFile(PWideChar(AFile), PWideChar(TargetFile), false);
      if not Succes then
        raise Exception.Create(Format(StrOverwriteSFailed, [AFile]));
    end;

    // Refresh Treeview
    if (Assigned(ShellTree)) and
       (ShellTree is ExifToolsGui_ShellTree.TShellTreeView) then
    with ExifToolsGui_ShellTree.TShellTreeView(ShellTree) do
    begin
      SetPaths2Refresh;
      RefreshAfterPaste;
      if Assigned(Selected) then
        Refresh(Selected);
    end;
  finally
    SetCursor(CrNormal);
  end;
end;

initialization

begin
  OleInitialize(nil);
  // Setup supported Formats
  CF_PREFERREDDROPEFFECT := RegisterClipboardFormat(CFSTR_PREFERREDDROPEFFECT);
  SupportedFormats[IdFormatCut].cfFormat := CF_PREFERREDDROPEFFECT;
end;

finalization

begin
  OleUninitialize;
end;

end.
