unit ExifToolsGui_FileListColumns;

interface

uses
  System.Classes, System.Threading, System.SyncObjs,
  Winapi.ShlObj,
  vcl.Shell.ShellCtrls,
  ExifToolsGui_ShellList,
  ExifInfo,
  ExifTool,
  UnitColumnDefs, UnitLangResources,
  UFrmGenerate;

const
  WorkerIntervalCheck = 250;

type

  TGetWorkerFolderFunc = function: TShellFolder of object;

  TMetaDataGetController = class(TObject)
    private
      FShellList: ExifToolsGui_ShellList.TShellListView;
      FThreadPool: TThreadPool;
      FCurrentIndex: integer;
      FItemCount: integer;
      FThreads: integer;
      FFrmGenerate: TFrmGenerate;
    protected
      function GetWorkerFolder: TShellFolder;
    public
      procedure GetAllMetaData;
      constructor Create(AShellList: ExifToolsGui_ShellList.TShellListView; AFrmGenerate: TFrmGenerate);
      destructor Destroy; override;
  end;

  TMetaDataGetWorker = class(TTask, ITask)
    private
      FID: integer;
      FCurrentDir: string;
      FColumnDefs: TArrayColRec;
      FGetWorker: TGetWorkerFolderFunc;
      FFolder: TShellFolder;
      FMetaData: TMetaData;
      FET: TexifTool;
      FETCmd: string;
      procedure DoGetMeta;
    protected
    public
      constructor Create(AID: integer;
                         AGetWorker: TGetWorkerFolderFunc;
                         ACurrentDir: string;
                         AColumnDefs: TArrayColRec);
      destructor Destroy; override;
      function Start: ITask;
  end;

procedure SetupCountry(ColumnDefs: TArrayColRec; CountryCode: boolean);
function GetSystemField(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
function SystemFieldIsDate(RootFolder: TShellFolder; Column: integer): boolean;
function GetFileListColumns(AShellList: ExifToolsGui_ShellList.TShellListView;
                            ET: TExifTool;
                            ItemIndex: integer;
                            ColumnDefs: TArrayColRec): boolean;
procedure GetAllFileListColumns(AShellList: ExifToolsGui_ShellList.TShellListView;
                                TFrmGenerate: TFrmGenerate);

implementation

uses
  System.SysUtils,
  Winapi.Windows,
  ExifToolsGUI_Utils,
  ExifToolsGui_ThreadPool,
  MainDef;

procedure PostProcess(ColumnDefs: TArrayColRec;
                      DetailStrings: TStrings;
                      ETColumns: boolean);
var
  Index: integer;
  ATag: TListColRec;
  OrientationTag: Char;
  FlashValue: SmallInt;
  BackupValue: string;
begin
  if (DetailStrings.Count <= High(ColumnDefs)) then
    exit;
  BackupValue := '';
  for Index := High(ColumnDefs) downto 0 do // From High to Low, because of delete's
  begin
    ATag := ColumnDefs[Index];

    // PostProcess ET
    if (ETColumns = true) then
    begin
      if ((ATag.Options and toDecimal) = toDecimal) then
        DetailStrings[Index] := FormatExifDecimal(DetailStrings[Index], 1);

      if ((ATag.Options and toYesNo) = toYesNo) then
      begin
        if (DetailStrings[Index] = '0') or
           (DetailStrings[Index] = '-') then
          DetailStrings[Index] := StrNo
        else
          DetailStrings[Index] := StrYes;
      end;

      if ((ATag.Options and toFlash) = toFlash) then
      begin
        FlashValue := StrToIntDef(DetailStrings[Index], -1);
        if (FlashValue > -1) then
        begin
          if (FlashValue and 1) = 1 then
            DetailStrings[Index] := StrYes
          else
            DetailStrings[Index] := StrNo;
        end
        else
          DetailStrings[Index] := '-';
      end;

      if ((ATag.Options and toHorVer) = toHorVer) then
      begin
        if (Length(DetailStrings[Index]) < 1) then
          OrientationTag := ' '
        else
          OrientationTag := DetailStrings[Index][1];
        case (OrientationTag) of
          '1','2':
            DetailStrings[Index] := StrHor;
          '3':
            DetailStrings[Index] := StrRot;
          '4'..'8':
            DetailStrings[Index] := StrVer;
        else
          DetailStrings[Index] := '-';
        end;
      end;
    end;

    // Common
    if (ATag.AlignR > 0) then
      DetailStrings[Index] := DetailStrings[Index].PadLeft(ATag.AlignR);

    if ((ATag.Options and toBackup) = toBackup) then
    begin
      if ((DetailStrings[Index] <> '-') and (DetailStrings[Index] <> '')) then
        BackupValue := DetailStrings[Index];
      DetailStrings.Delete(Index);
    end;

    if ((ATag.Options and toMain) = toMain) then
    begin
      if ((DetailStrings[Index] = '-') or (DetailStrings[Index] = '')) and
         (BackupValue <> '') then
        DetailStrings[Index] := BackupValue;
      BackupValue := '';
    end;
  end;
end;

function SystemFieldIsDate(RootFolder: TShellFolder; Column: integer): boolean;
var
  ColFlags: LongWord;
begin
  result := false;
  if Assigned(RootFolder) and
     Assigned(RootFolder.ShellFolder2) and
     (RootFolder.ShellFolder2.GetDefaultColumnState(Column, ColFlags) = S_OK) and
     ((ColFlags and SHCOLSTATE_TYPE_DATE) = SHCOLSTATE_TYPE_DATE) then
    result := true;
end;

procedure SetupCountry(ColumnDefs: TArrayColRec; CountryCode: boolean);
var
  Index: integer;
begin
  for Index := 0 to High(ColumnDefs) do
  begin
    if ((ColumnDefs[Index].Options and toCountry) = toCountry) then
    begin
      if (CountryCode) then
        ColumnDefs[Index].Command := CommandCountryCode
      else
        ColumnDefs[Index].Command := CommandCountryName;
    end;
  end;
end;

function GetSystemField(RootFolder: TShellFolder; RelativeID: PItemIDList; Column: integer): string;
var
  SD: TShellDetails;
begin
  result := '';
  if Assigned(RootFolder) and
     Assigned(RootFolder.ShellFolder2) and
     (RootFolder.ShellFolder2.GetDetailsOf(RelativeID, Column, SD) = S_OK) then
    case SD.str.uType of
      STRRET_CSTR:
        SetString(Result, SD.str.cStr, lStrLenA(SD.str.cStr));
      STRRET_WSTR:
        if Assigned(SD.str.pOleStr) then
          Result := SD.str.pOleStr;
    end;
end;

function GetETCmd(ColumnDefs: TArrayColRec): string;
var
  ATag: TListColRec;
begin
  result := '-s3' + CRLF + '-f';
  for ATag in ColumnDefs do
    result := result + CRLF + ATag.Command;
end;

function ProcessFolder(AFolder: TShellFolder;
                       AMetaData: TMetaData;
                       AET: TExifTool;
                       AWorkingDir: string;
                       AETCmd: string;
                       AColumnDefs: TArrayColRec): boolean;
var
  DetailStrings: TStrings;
  APath: string;
  AExt: string;
  ATag: TListColRec;
begin

  if (TSubShellFolder.GetIsFolder(AFolder)) then    // Dont get info for folders (directories)
    exit(false);

  DetailStrings := AFolder.DetailStrings;           // Already have details
  if (DetailStrings.Count > 0) then
    exit(false);

  APath := AFolder.PathName;                        // Note: This is the complete path, not the relative path.
  AMetaData.ReadMeta(APath, [gmXMP, gmGPS]);        // Internal mode

  if (AMetaData.Foto.ErrNotOpen) then               // File in use
    exit(false);

  if (AMetaData.Foto.Supported = []) then           // Internal mode not supported, have to call ExifTool
  begin
    if (AET.ETWorkingDir = '') then                 // Need to start ET?
      AET.StayOpen(AWorkingDir);
    AExt := ExtractFileExt(APath);

    AET.OpenExec(GUIsettings.Fast3(AExt) + AETCmd,  // Get DetailStrings from EExifTool
                 APath,
                 DetailStrings,
                 False);
    PostProcess(AColumnDefs, DetailStrings, true);  // PostProcess ExifTool mode
  end
  else
  begin
    for ATag in AColumnDefs do
      DetailStrings.Add(AMetaData.FieldData(ATag.Command));
    PostProcess(AColumnDefs, DetailStrings, false); // PostProcess internal mode
  end;
  result := true;
end;

function GetFileListColumns(AShellList: ExifToolsGui_ShellList.TShellListView;
                           ET: TExifTool;
                           ItemIndex: integer;
                           ColumnDefs: TArrayColRec): boolean;
var
  MetaData: TMetaData;
  AFolder: TShellFolder;
begin
  AFolder := AShellList.Folders[ItemIndex];
  MetaData := TMetaData.Create;
  try
    result := ProcessFolder(AFolder,
                            MetaData,
                            ET,
                            ET.ETWorkingDir, // Not used, ET will be open
                            GetETCmd(ColumnDefs),
                            ColumnDefs);
  finally
    MetaData.Free;
  end;
end;

{ TMetaDataGetController }

constructor TMetaDataGetController.Create(AShellList: ExifToolsGui_ShellList.TShellListView; AFrmGenerate: TFrmGenerate);
begin
  inherited Create;
  FShellList := AShellList;
  FFrmGenerate := AFrmGenerate;
  FCurrentIndex := 0;
  FItemCount := FShellList.Items.Count;
  FThreadPool := GetPool;
  FThreads := FThreadPool.MaxWorkerThreads;
end;

destructor TMetaDataGetController.Destroy;
begin
  inherited Destroy;
end;

function TMetaDataGetController.GetWorkerFolder: TShellFolder;
begin
  result := nil;
  System.TMonitor.Enter(FShellList.FoldersList);
  try
    if (FCurrentIndex > FItemCount -1) then
      exit;
    result := FShellList.Folders[FCurrentIndex];
    Inc(FCurrentIndex);
  finally
    System.TMonitor.Exit(FShellList.FoldersList);
  end;
end;

procedure TMetaDataGetController.GetAllMetaData;
var
  Index: integer;
  Tasks: array of ITask;
begin
  SetLength(Tasks, FThreads);
  for Index := 0 to High(Tasks) do
    Tasks[Index] := TMetaDataGetWorker.Create(Index,
                                              GetWorkerFolder,
                                              FShellList.Path, // Working Directory
                                              FShellList.ColumnDefs).Start;

  while not TTask.WaitForAll(Tasks, WorkerIntervalCheck) do
  begin
    if boolean(SendMessage(FFrmGenerate.Handle, CM_WantsToClose, 0, 0)) then
    begin
      for Index := 0 to High(Tasks) do
        Tasks[Index].Cancel;
      break;
    end;

    if (FCurrentIndex < FItemCount) then
      SendMessage(FFrmGenerate.Handle,
                  CM_SubFolderSortProgress,
                  FCurrentIndex,
                  LPARAM(TSubShellFolder.GetRelativeDisplayName(FShellList.Folders[FCurrentIndex])));
  end;
end;

{ TMetaDataGetWorker }

constructor TMetaDataGetWorker.Create(AID: integer;
                                      AGetWorker: TGetWorkerFolderFunc;
                                      ACurrentDir: string;
                                      AColumnDefs: TArrayColRec);
begin
  FID := AID;
  FGetWorker := AGetWorker;
  FCurrentDir := ACurrentDir;
  FColumnDefs := AColumnDefs;
  FMetaData := TMetaData.Create;
  FET := TExifTool.Create(FID);
  FETCmd := GetETCmd(AColumnDefs);

  inherited Create(nil, TNotifyEvent(nil), DoGetMeta, ThreadPool.Default, nil, []);
end;

function TMetaDataGetWorker.Start: ITask;
begin
  result := inherited;
end;

procedure TMetaDataGetWorker.DoGetMeta;
begin
  while (true) do
  begin
    if (IsCanceled) then
      break;

    FFolder := FGetWorker;
    if (FFolder = nil) then                           // No more work
      break;

    if not ProcessFolder(FFolder,
                         FMetaData,
                         FET,
                         FCurrentDir,
                         FETCmd,
                         FColumnDefs) then
      continue;
  end;
end;

destructor TMetaDataGetWorker.Destroy;
begin
  FMetaData.Free;
  FET.OpenExit;
  FET.Free;
  inherited Destroy;
end;

procedure GetAllFileListColumns(AShellList: ExifToolsGui_ShellList.TShellListView;
                               TFrmGenerate: TFrmGenerate);
begin
  with TMetaDataGetController.Create(AShellList, FrmGenerate) do
  begin
    GetAllMetaData;
    Free;
  end;
end;

end.
