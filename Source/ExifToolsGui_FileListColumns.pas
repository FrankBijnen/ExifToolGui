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
  TPostProcess = (ppNotSup, ppNotOpen, ppFolder, ppInternal, ppExifTool);

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
      procedure GetAllMetaData;
    public
      constructor Create(AShellList: ExifToolsGui_ShellList.TShellListView; AFrmGenerate: TFrmGenerate);
      destructor Destroy; override;
  end;

  TMetaDataGetWorker = class(TTask, ITask)
    private
      FID: integer;
      FCurrentDir: string;
      FOptions: TReadModeOptions;
      FColumnDefs: TColumnsArray;
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
                         AOptions: TReadModeOptions;
                         AColumnDefs: TColumnsArray);
      destructor Destroy; override;
      function Start: ITask;
  end;

procedure SetupCountry(ColumnDefs: TColumnsArray; CountryCode: boolean);
procedure GetFileListColumns(AShellList: ExifToolsGui_ShellList.TShellListView;
                             ET: TExifTool;
                             ItemIndex: integer);
procedure GetAllFileListColumns(AShellList: ExifToolsGui_ShellList.TShellListView;
                                TFrmGenerate: TFrmGenerate);
procedure ExportToCsv(AShellList: ExifToolsGui_ShellList.TShellListView;
                      FileName: string);
procedure ExportToJson(AShellList: ExifToolsGui_ShellList.TShellListView;
                      FileName: string);

implementation

uses
  System.SysUtils, System.JSON,
  Winapi.Windows, Winapi.CommCtrl,
  Vcl.ComCtrls,
  ExifToolsGUI_Utils,
  ExifToolsGui_ThreadPool,
  MainDef;

procedure PostProcess(Folder: TShellFolder;
                      ColumnDefs: TColumnsArray;
                      DetailStrings: TStrings;
                      PostProcess: TPostProcess);
var
  Index: integer;
  ATag: TFileListColumn;
  OrientationTag: Char;
  FlashValue: SmallInt;
  BackupValue: string;
begin
  if (High(ColumnDefs) < 0) then // Nothing to do
    exit;

  // Make sure every column has a DetailString. Column sorting works better.
  for Index := DetailStrings.Count to High(ColumnDefs) do
    DetailStrings.Add('');

  BackupValue := '';
  for Index := High(ColumnDefs) downto 0 do // From High to Low, because of delete's
  begin
    ATag := ColumnDefs[Index];

    // PostProcess ET
    if (PostProcess = TPostProcess.ppExifTool) then
    begin
      if ((ATag.Options and toDecimal) = toDecimal) then
        DetailStrings[Index] := FormatExifDecimal(DetailStrings[Index], 1);

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

    // SysField ?
    if ((ATag.Options and toSys) = toSys) then
      DetailStrings[Index] := TSubShellFolder.GetSystemField_MT(Folder.Parent,
                                                                Folder.RelativeID,
                                                                ATag.SysColumn);

    // Yes/No
    if ((ATag.Options and toYesNo) = toYesNo) then
    begin
      if (DetailStrings[Index] = '') or
         (DetailStrings[Index] = '0') or
         (DetailStrings[Index] = '-') then
        DetailStrings[Index] := StrNo
      else
        DetailStrings[Index] := StrYes;
    end;

    // Padleft?
    if (ATag.AlignR > 0) then
      DetailStrings[Index] := DetailStrings[Index].PadLeft(ATag.AlignR);

    // Backup column?
    if ((ATag.Options and toBackup) = toBackup) then
    begin
      if ((DetailStrings[Index] <> '-') and
          (DetailStrings[Index] <> StrNo) and
          (DetailStrings[Index] <> '')) then
        BackupValue := DetailStrings[Index];
      DetailStrings.Delete(Index);
    end;

    if ((ATag.Options and toBackup) = 0) then
    begin
      if ((DetailStrings[Index] = '-') or
          (DetailStrings[Index] = StrNo) or
          (DetailStrings[Index] = '')) and
          (BackupValue <> '') then
        DetailStrings[Index] := BackupValue;
      BackupValue := '';
    end;

  end;

  case (PostProcess) of
    TPostProcess.ppNotSup:
      DetailStrings[0] := NotSupported;
    TPostProcess.ppNotOpen:
      DetailStrings[0] := NotOpened
  end;
end;

procedure SetupCountry(ColumnDefs: TColumnsArray; CountryCode: boolean);
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

function GetETCmd(ColumnDefs: TColumnsArray): string;
var
  ATag: TFileListColumn;
begin
  result := '-s3' + CRLF + '-f';
  for ATag in ColumnDefs do
  begin
    if ((ATag.Options and toSys) = toSys) then
      result := result + CRLF + GUI_SEP
    else
      result := result + CRLF + ATag.Command;
  end;
end;

procedure ProcessFolder(AFolder: TShellFolder;
                        AMetaData: TMetaData;
                        AET: TExifTool;
                        AWorkingDir: string;
                        AETCmd: string;
                        AOptions: TReadModeOptions;
                        AColumnDefs: TColumnsArray);
var
  DetailStrings: TStrings;
  ETOuts: string;
  ETErr: string;
  APath: string;
  AExt: string;
  ATag: TFileListColumn;
  PostProcessMethod: TPostProcess;
begin
  DetailStrings := AFolder.DetailStrings;               // Already have details
  if (DetailStrings.Count > 0) then
    exit;

  PostProcessMethod := TPostProcess.ppNotSup;
  try
    if (TSubShellFolder.GetIsFolder(AFolder)) then      // Dont get info for folders (directories)
    begin
      PostProcessMethod := TPostProcess.ppFolder;
      exit;
    end;

    if (rmInternal in AOptions) then
    begin
      APath := TSubShellFolder.GetLongPath(AFolder);    // Note: This is the complete path, possibly prefixed with \\?\
      AMetaData.ReadMeta(APath, [gmXMP, gmGPS]);        // Internal mode

      if (AMetaData.Foto.ErrNotOpen) then               // File in use
      begin
        PostProcessMethod := TPostProcess.ppNotOpen;
        exit;
      end;

      if (AMetaData.Foto.Supported <> []) then
      begin
        for ATag in AColumnDefs do
          DetailStrings.Add(AMetaData.FieldData(ATag.Command));
        PostProcessMethod := TPostProcess.ppInternal;
      end;
    end;

    if (PostProcessMethod <> TPostProcess.ppInternal) and
       (rmExifTool in AOptions) then                    // Internal mode not supported, have to call ExifTool. If allowed
    begin
      if (AET.ETWorkingDir = '') then                   // Need to start ET?
        AET.StayOpen(AWorkingDir);

      // Get Path and Ext for ExifTool. ET will prepend if needed.
      if (AET.Options.ETAPIWindowsWideFile = '') then
        APath := IncludeTrailingPathDelimiter(AWorkingDir)
      else
        APath := '';
      APath := APath + TSubShellFolder.GetRelativeFileName(AFolder, (AET.Options.ETAPIWindowsLongPath <> ''));
      AExt := ExtractFileExt(APath);

      AET.OpenExec(GUIsettings.Fast3(AExt) + AETCmd,    // Get DetailStrings from ExifTool
                   APath,
                   ETOuts,
                   ETErr,
                   False);
      DetailStrings.Text := ETOuts;
{$IFDEF DEBUG}
      if (ETErr <> '') then
        DebugMsg(['ProcessFolder', APath, ETErr]);
{$ENDIF}
      PostProcessMethod := TPostProcess.ppExifTool;     // ExifTool requires special Post Processing
    end;

  finally
    PostProcess(AFolder,                                // Post Process.
                AColumnDefs,
                DetailStrings,
                PostProcessMethod);
  end;
end;

procedure GetFileListColumns(AShellList: ExifToolsGui_ShellList.TShellListView;
                             ET: TExifTool;
                             ItemIndex: integer);
var
  MetaData: TMetaData;
  AFolder: TShellFolder;
  AColumnDefs: TColumnsArray;
  AOptions: TReadModeOptions;
begin
  if not AShellList.DetailsNeeded then
    exit;

  AFolder := AShellList.Folders[ItemIndex];
  if (AFolder = nil) then
    exit;

  AOptions := AShellList.ReadModeOptions;
  AColumnDefs := AShellList.ColumnDefs;

  MetaData := TMetaData.Create;
  try
    ProcessFolder(AFolder,
                  MetaData,
                  ET,
                  ET.ETWorkingDir,
                  GetETCmd(AColumnDefs),
                  AOptions,
                  AColumnDefs);
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
  FCurrentIndex := 0;
  SetLength(Tasks, FThreads);
  for Index := 0 to High(Tasks) do
    Tasks[Index] := TMetaDataGetWorker.Create(Index,
                                              GetWorkerFolder,
                                              FShellList.Path, // Working Directory
                                              FShellList.ReadModeOptions,
                                              FShellList.ColumnDefs).Start;

  while not TTask.WaitForAll(Tasks, WorkerIntervalCheck) do
  begin
    if boolean(SendMessage(FFrmGenerate.Handle, CM_WantsToClose, 0, 0)) then
    begin
      System.TMonitor.Enter(FShellList.FoldersList);
      try
        FCurrentIndex := FItemCount +1; // Pretend all work done
      finally
        System.TMonitor.Exit(FShellList.FoldersList);
      end;
      continue;
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
                                      AOptions: TReadModeOptions;
                                      AColumnDefs: TColumnsArray);
begin
  FID := AID;
  FGetWorker := AGetWorker;
  FCurrentDir := ACurrentDir;
  FOptions := AOptions;
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

    try
      FFolder := FGetWorker;
    except on E:Exception do
      begin
        DebugMsg(['DoGetMeta GetWorker', E.Message]);
        FFolder := nil;
      end;
    end;

    if (FFolder = nil) then                           // No more work
      break;

    try
      ProcessFolder(FFolder,
                    FMetaData,
                    FET,
                    FCurrentDir,
                    FETCmd,
                    FOptions,
                    FColumnDefs);
    except on E:Exception do
      begin
        DebugMsg(['DoGetMeta ProcessFolder', FFolder.PathName, E.Message]);
      end;
    end;
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
var
  SaveEnabled: boolean;
  Controller: TMetaDataGetController;
begin
  if not AShellList.DetailsNeeded then
    exit;

  SaveEnabled := AShellList.Enabled;
  AShellList.Enabled := false;
  Controller := TMetaDataGetController.Create(AShellList, FrmGenerate);
  try
    Controller.GetAllMetaData;
  finally
    Controller.Free;
    AShellList.Enabled := SaveEnabled;
  end;
end;

procedure ExportToCsv(AShellList: ExifToolsGui_ShellList.TShellListView;
                      FileName: string);
var
  Writer: TTextWriter;
  Lst: TStringList;
  Index: integer;
begin
  Writer := TStreamWriter.Create(FileName, false, TEncoding.UTF8);
  try
    Lst := TStringList.Create;
    try
      Lst.QuoteChar := '"';
      Lst.Delimiter := ';';

      for Index := 0  to AShellList.Columns.Count -1 do
        Lst.AddStrings(AShellList.Columns[Index].Caption);
      Writer.WriteLine(Lst.DelimitedText);

      for Index := 0 to AShellList.Items.Count -1 do
      begin
        if (ListView_GetItemState(AShellList.Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) and
           (TSubShellFolder.GetIsFolder(AShellList.Folders[Index]) = false) then
        begin
          Lst.Clear;
          Lst.AddStrings(TSubShellFolder.GetRelativeDisplayName(AShellList.Folders[Index]));
          Lst.AddStrings(AShellList.Folders[Index].DetailStrings);
          Writer.WriteLine(Lst.DelimitedText);
        end;
      end;
    finally
      lst.Free;
    end;
  finally
    Writer.Free;
  end;
end;

procedure ExportToJson(AShellList: ExifToolsGui_ShellList.TShellListView;
                      FileName: string);
var
  Writer: TTextWriter;
  JSONObj: TJSONObject;
  Index: integer;
  Column: integer;
  First: boolean;
begin
  Writer := TStreamWriter.Create(FileName, false, TEncoding.UTF8);
  try
    Writer.WriteLine('[');
    First := true;
    for Index := 0 to AShellList.Items.Count -1 do
    begin
      if (ListView_GetItemState(AShellList.Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) and
           (TSubShellFolder.GetIsFolder(AShellList.Folders[Index]) = false) then
      begin
        JSONObj := TJSONObject.Create;
        try
          for Column := 0 to AShellList.Columns.Count -1 do
          begin
            if (Column = 0) then
              JSONObj.AddPair(AShellList.Columns[Column].Caption,
                              TSubShellFolder.GetRelativeDisplayName(AShellList.Folders[Index]))
            else
              JSONObj.AddPair(AShellList.Columns[Column].Caption,
                              AShellList.Folders[Index].DetailStrings[Column -1]);
          end;
          if not First then
            Writer.WriteLine(',')
          else
            First := false;
          Writer.Write(JSONObj.ToString);
        finally
          JSONObj.Free;
        end;
      end;
    end;
    Writer.WriteLine;
    Writer.WriteLine(']');
  finally
    Writer.Free;
  end;
end;

end.
