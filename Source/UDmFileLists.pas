unit UDmFileLists;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  vcl.Shell.ShellCtrls,
  Data.DB, Datasnap.DBClient,
  ExifToolsGui_ShellList;

type
  TSampleData = TDictionary<string, string>;

  TDmFileLists = class(TDataModule)
    DsFileListDef: TDataSource;
    CdsFileListDef: TClientDataSet;
    CdsFileListDefId: TIntegerField;
    CdsFileListDefName: TStringField;
    CdsFileListDefDescription: TStringField;
    CdsFileListDefType: TStringField;
    CdsFileListDefReadMode: TIntegerField;
    CdsFileListDefReadModeLookup: TStringField;
    DsColumnSet: TDataSource;
    CdsColumnSet: TClientDataSet;
    CdsColumnSetFileListName: TStringField;
    CdsColumnSetName: TStringField;
    CdsColumnSetCommand: TStringField;
    CdsColumnSetOption: TStringField;
    CdsColumnSetAlignR: TIntegerField;
    CdsColumnSetWidth: TStringField;
    CdsColumnSetSeq: TFloatField;
    CdsReadMode: TClientDataSet;
    CdsReadModeKey: TIntegerField;
    CdsReadModeDesc: TStringField;
    CdsBackup: TClientDataSet;
    CdsBackupKey: TIntegerField;
    CdsBackupDesc: TStringField;
    CdsColumnSetBackup: TIntegerField;
    CdsColumnSetBackupLookUp: TStringField;
    CdsOption: TClientDataSet;
    CdsOptionKey: TIntegerField;
    CdsOptionDesc: TStringField;
    CdsColumnSetOptionLookUp: TStringField;
    CdsColumnSetSampleValue: TStringField;
    CdsTagNames: TClientDataSet;
    CdsTagNamesTagName: TStringField;
    DsTagNames: TDataSource;
    CdsColumnSetCommandLookup: TStringField;
    CdsTagNamesSampleValue: TStringField;
    procedure CdsColumnSetBeforeInsert(DataSet: TDataSet);
    procedure CdsColumnSetAfterInsert(DataSet: TDataSet);
    procedure CdsFileListDefAfterInsert(DataSet: TDataSet);
    procedure DataModuleCreate(Sender: TObject);
    procedure CdsColumnSetCalcFields(DataSet: TDataSet);
    procedure DataModuleDestroy(Sender: TObject);
    procedure CdsTagNamesFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure CdsTagNamesCalcFields(DataSet: TDataSet);
    procedure CdsFileListDefBeforeScroll(DataSet: TDataSet);
    procedure CdsColumnSetCommandValidate(Sender: TField);
  private
    { Private declarations }
    ColumnSeq: Double;
    FListName: string;
    FListReadMode: integer;
    FSample: TShellFolder;
    FSampleValues: TSampleData;
    FSystemTagNames: TStringlist;
    FOnFileListChanged: TNotifyEvent;
    FOnFilterTag: TFilterRecordEvent;
    procedure PrepTagNames;
    procedure AddTagName(ATagName: string);
    procedure CalcSampleValue(DataSet: TDataSet; Command, Sample: string);

    procedure GetSampleValues(AListName: string; AListReadMode: integer);
    procedure SetupLookUps;
  public
    { Public declarations }
    SelectedSet: integer;
    procedure LoadFromColumnSets(ASample: TShellFolder);
    procedure SaveToColumnSets;
    property OnFileListChanged: TNotifyEvent read FOnFileListChanged write FOnFileListChanged;
    property OnFilterTag: TFilterRecordEvent read FOnFilterTag write FOnFilterTag;
  end;

var
  DmFileLists: TDmFileLists;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  System.StrUtils, System.Variants,
  Winapi.Windows,
  UnitColumnDefs, ExifInfo, ExifTool, ExifToolsGUI_Utils;

{$R *.dfm}

const
  ListSystem    = 'System';
  ListInternal  = 'Internal';
  ListUser      = 'User';

  ReadSystem    = 'System';
  ReadInternal  = 'Internal';
  ReadExifTool  = 'ExifTool';

  OptionBackup  = 'Backup';
  OptionSys     = 'Sys';
  OptionDecimal = 'Decimal';
  OptionYesNo   = 'Yes/No';
  OptionHorVer  = 'Hor/Ver';
  OptionFlash   = 'Flash';
  OptionCountry = 'Country';

procedure TDmFileLists.CdsColumnSetAfterInsert(DataSet: TDataSet);
begin
  CdsColumnSetWidth.AsInteger := 80;
  CdsColumnSetAlignR.AsInteger := 0;
  CdsColumnSetSeq.AsFloat := ColumnSeq;
  CdsColumnSetOption.AsInteger := 0;
end;

procedure TDmFileLists.CdsColumnSetBeforeInsert(DataSet: TDataSet);
begin
  if (CdsColumnSet.MasterSource = nil) then
    exit;

  if (CdsColumnSet.RecNo = 1) then
    ColumnSeq := CdsColumnSetSeq.AsFloat - 0.01
  else if (CdsColumnSet.RecNo = CdsColumnSet.RecordCount) then
    ColumnSeq := CdsColumnSetSeq.AsFloat + 0.01
  else
  begin
    CdsColumnSet.Prior;
    ColumnSeq := CdsColumnSetSeq.AsFloat;
    CdsColumnSet.Next;
    ColumnSeq := ColumnSeq + ((CdsColumnSetSeq.AsFloat - ColumnSeq) / 2);
  end;
end;

procedure TDmFileLists.CalcSampleValue(DataSet: TDataSet; Command, Sample: string);
var
  LowerCommand: string;
  SampleValue: string;
begin
  if not (Dataset.State in [dsCalcFields, dsInsert, dsEdit]) then
    exit;
  if (Dataset.ControlsDisabled) then
    exit;
  GetSampleValues(CdsFileListDef.FieldByName('Name').AsString,
                  CdsFileListDef.FieldByName('ReadMode').AsInteger);

  LowerCommand := LowerCase(Dataset.FieldByName(Command).AsString);
  if (FSampleValues.TryGetValue(LowerCommand, SampleValue)) then
    Dataset.FieldByName(Sample).AsString := SampleValue
  else
    Dataset.FieldByName(Sample).AsString := '-';
end;

procedure TDmFileLists.CdsColumnSetCalcFields(DataSet: TDataSet);
begin
  CalcSampleValue(DataSet, 'Command', 'SampleValue');
end;

procedure TDmFileLists.CdsColumnSetCommandValidate(Sender: TField);
begin
  if (LeftStr(Sender.AsString, 1) <> '-') then
  begin
    CdsColumnSetOption.AsInteger := Ord(toSys);
    CdsColumnSetName.AsString := FSystemTagNames.Values[Sender.AsString];
  end
  else
    CdsColumnSetOption.AsInteger := (CdsColumnSetOption.AsInteger and ($ffff - Ord(toSys)));
end;

procedure TDmFileLists.CdsFileListDefAfterInsert(DataSet: TDataSet);
begin
  CdsFileListDefType.AsString := ListUser;
  CdsFileListDefReadMode.AsInteger := Ord(rmInternal);
  CdsFileListDefId.AsInteger := CdsFileListDef.RecordCount + 1;
end;

procedure TDmFileLists.CdsFileListDefBeforeScroll(DataSet: TDataSet);
begin
  if Assigned(FOnFileListChanged) then
    FOnFileListChanged(Self);
end;

procedure TDmFileLists.CdsTagNamesCalcFields(DataSet: TDataSet);
begin
  CalcSampleValue(DataSet, 'TagName', 'SampleValue');
end;

procedure TDmFileLists.CdsTagNamesFilterRecord(DataSet: TDataSet; var Accept: Boolean);
begin
  if Assigned(FOnFilterTag) then
    FOnFilterTag(Dataset, Accept);
end;

procedure TDmFileLists.DataModuleCreate(Sender: TObject);
begin
  FSampleValues := TSampleData.Create;
  FSystemTagNames := TStringList.Create;
  SetupLookUps;
end;

procedure TDmFileLists.DataModuleDestroy(Sender: TObject);
begin
  FSampleValues.Free;
  FSystemTagNames.Free;
end;

procedure TDmFileLists.PrepTagNames;
begin
  CdsTagNames.Close;
  CdsTagNames.IndexFieldnames := 'TagName';
  CdsTagNames.CreateDataSet;
end;

procedure TDmFileLists.AddTagName(ATagName: string);
begin
  if VarIsNull(CdsTagNames.Lookup('TagName', ATagName, 'TagName')) then
    CdsTagNames.AppendRecord([ATagName]);
end;

procedure TDmFileLists.GetSampleValues(AListName: string; AListReadMode: integer);
var
  MetaData: TMetaData;
  Index: integer;
  KeyName: string;
  ETLine: string;
  GroupName: string;
  TagName: string;
  Sample: string;
  ETcmd: string;
  ETOut: TStringList;
begin
  if (FListName = AListName) and
     (FListReadMode = AListReadMode) then
    exit;

  FListName := AListName;
  FListReadMode := AListReadMode;

  PrepTagNames;
  CdsTagNames.DisableControls;
  FSampleValues.Clear;

  try
    for Index := 0 to FSystemTagNames.Count -1 do
    begin
      TagName := FSystemTagNames.KeyNames[Index];
      Sample  := TSubShellFolder.GetSystemField(FSample.Parent, FSample.RelativeID, Index);
      FSampleValues.Add(TagName, Sample);
      AddTagName(TagName);
    end;
    case FListReadMode of
      0:;   // Limit to System Fields
      1:    // Limit to Internal fields
        begin
          MetaData := TMetaData.Create;
          try
            MetaData.ReadMeta(FSample.PathName, [gmXMP, gmGPS]);
            for TagName in MetaData.FieldNames do
            begin
              KeyName := '-' + TagName;
              if (FSampleValues.ContainsKey(LowerCase(KeyName))) then
                continue;
              FSampleValues.Add(LowerCase(KeyName), MetaData.FieldData(TagName));
              AddTagName(KeyName);
            end;
          finally
            MetaData.Free;
          end;
        end
      else
      begin
        if (TSubShellFolder.GetIsFolder(FSample)) then
          exit;
        ETOut := TStringList.Create;
        try
          ETCmd := '-G1' + CRLF + '-s';
          ET.OpenExec(Etcmd, FSample.PathName, EtOut);
          for Index := 0 to ETOut.Count -1 do
          begin
            ETLine    := ETOut[Index];
            GroupName := NextField(ETLine, '[');             // Strip Leading [
            GroupName := NextField(ETLine, ']');             // Group name
            TagName   := Trim(NextField(ETLine, ':'));       // Tag Name
            KeyName := '-' + GroupName + ':' + TagName;
            if (FSampleValues.ContainsKey(LowerCase(KeyName))) then
              continue;
            FSampleValues.Add(LowerCase(KeyName), Trim(ETLine));
            AddTagName(KeyName);
          end;
        finally
          ETOut.Free;
        end;
      end;
    end;
  finally
    CdsTagNames.EnableControls;
  end;
end;

procedure TDmFileLists.SetupLookUps;

  procedure PrepLookUP(ADS: TClientDataSet);
  begin
    ADS.Close;
    ADS.IndexFieldNames := 'Key';
    ADS.CreateDataSet;
  end;

  procedure AddLookUP(ADS: TClientDataSet; AKey: integer; AValue: string);
  begin
    ADS.Insert;
    ADS.FieldByName('Key').AsInteger := AKey;
    ADS.FieldByName('Desc').AsString := AValue;
    ADS.Post;
  end;
begin
// ReadMode
  PrepLookUP(CdsReadMode);
  AddLookUP(CdsReadMode, 0,         ReadSystem);
  AddLookUP(CdsReadMode, 1,         ReadInternal);
  AddLookUP(CdsReadMode, 2,         ReadExifTool);
  AddLookUP(CdsReadMode, 3,         ReadInternal + '+' + ReadExifTool);

// Backup
  PrepLookUP(CdsBackup);
  AddLookUP(CdsBackup, 0,           '');
  AddLookUP(CdsBackup, toBackup,    OptionBackup);

// Option
  PrepLookUP(CdsOption);
  AddLookUP(CdsOption, 0, '');
  AddLookUP(CdsOption, toSys,       Optionsys);
  AddLookUP(CdsOption, toDecimal,   OptionDecimal);
  AddLookUP(CdsOption, toYesNo,     OptionYesNo);
  AddLookUP(CdsOption, toHorVer,    OptionHorVer);
  AddLookUP(CdsOption, toFlash,     OptionFlash);
  AddLookUP(CdsOption, toCountry,   OptionCountry);
end;

procedure TDmFileLists.SaveToColumnSets;
var
  FileListDefs: TColumnSetList;
  AColumnSet: TColumnsArray;
  AFileOption: TFileListOptions;
begin
  CdsFileListDef.DisableControls;
  CdsColumnSet.DisableControls;

  SelectedSet := CdsFileListDef.RecNo;
  FileListDefs := GetFileListDefs;
  FileListDefs.Clear;
  try
    CdsFileListDef.First;

    while not CdsFileListDef.Eof do
    begin
      AFileOption := floSystem;
      if (SameText(CdsFileListDefType.AsString, ListInternal)) then
        AFileOption := floInternal
      else if (SameText(CdsFileListDefType.AsString, ListUser)) then
        AFileOption := floUserDef;

      CdsColumnSet.SetRange([CdsFileListDefName.AsString], [CdsFileListDefName.AsString]);
      CdsColumnSet.First; // Not needed
      SetLength(AColumnSet, CdsColumnSet.RecordCount);
      while not CdsColumnSet.Eof do
      begin
        AColumnSet[CdsColumnSet.RecNo -1].SetCaption(CdsColumnSetName.AsString);
        AColumnSet[CdsColumnSet.RecNo -1].Command := CdsColumnSetCommand.AsString;
        AColumnSet[CdsColumnSet.RecNo -1].Width   := CdsColumnSetWidth.AsInteger;
        AColumnSet[CdsColumnSet.RecNo -1].AlignR  := CdsColumnSetAlignR.AsInteger;
        // Merge options from fields Backup and Option
        AColumnSet[CdsColumnSet.RecNo -1].Options := 0;
        AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + CdsColumnSetOption.AsInteger;
        AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + CdsColumnSetBackup.AsInteger;
        CdsColumnSet.Next;
      end;
      FileListDefs.Add(TColumnSet.Create(CdsFileListDefName.AsString,
                                         CdsFileListDefDescription.AsString,
                                         AFileOption,
                                         CdsFileListDefReadMode.AsInteger,
                                         AColumnSet));
      CdsFileListDef.Next;
    end;
  finally
    CdsFileListDef.Close;
    CdsColumnSet.Close;
    CdsFileListDef.EnableControls;
    CdsColumnSet.EnableControls;
  end;
end;

procedure TDmFileLists.LoadFromColumnSets(ASample: TShellFolder);
var
  FileListDefs: TColumnSetList;
  AColumnSet: TColumnSet;
  AColumn: TFileListColumn;
  Index: integer;
  Id: integer;
begin
  FSample := ASample;
  TSubShellFolder.AllFastSystemFields(ASample.Parent, FSystemTagNames);
  FListName := '';
  FListReadMode := -1;

  CdsFileListDef.Close;
  CdsColumnSet.Close;

  CdsColumnSet.MasterSource := nil;
  CdsColumnSet.MasterFields := '';
  CdsFileListDef.DisableControls;
  CdsColumnSet.DisableControls;

  try
    PrepTagNames;

    FileListDefs := GetFileListDefs;

    CdsFileListDef.IndexFieldNames := 'Id';
    CdsFileListDef.CreateDataSet;

    CdsColumnSet.IndexFieldNames := 'FileListName;Seq';
    CdsColumnSet.CreateDataSet;

    Id := 0;
    for AColumnSet in FileListDefs do
    begin
      Inc(Id);

      CdsFileListDef.Insert;
      CdsFileListDefId.AsInteger := Id;
      CdsFileListDefName.AsString := AColumnSet.Name;
      CdsFileListDefDescription.AsString := AColumnSet.Desc;
      case (AColumnSet.Options) of
        TFileListOptions.floSystem:
          CdsFileListDefType.AsString := ListSystem;
        TFileListOptions.floInternal:
          CdsFileListDefType.AsString := ListInternal;
        else
          CdsFileListDefType.AsString := ListUser;
      end;
      CdsFileListDefReadMode.AsInteger := AColumnSet.ReadModeInt;
      CdsFileListDefDescription.AsString := AColumnSet.Desc;
      CdsFileListDef.Post;

      ColumnSeq := 0;
      for Index := 0 to High(AColumnSet.ColumnDefs) do
      begin
        AColumn := AColumnSet.ColumnDefs[Index];
        ColumnSeq := ColumnSeq + 1;
        CdsColumnSet.Insert;
        CdsColumnSetFileListName.AsString   := AColumnSet.Name;
        CdsColumnSetName.AsString           := AColumn.Caption;
        CdsColumnSetCommand.AsString        := AColumn.Command;
        CdsColumnSetOption.AsInteger        := Ord(AColumn.Options) and $00ff;
        CdsColumnSetBackup.AsInteger        := Ord(AColumn.Options) and $ff00;
        CdsColumnSetWidth.AsInteger         := AColumn.Width;
        CdsColumnSetAlignR.AsInteger        := AColumn.AlignR;
        CdsColumnSet.Post;
      end;
    end;
  finally
    CdsFileListDef.EnableControls;
    CdsColumnSet.EnableControls;
    CdsColumnSet.MasterFields := 'Name';
    CdsColumnSet.MasterSource := DsFileListDef;
    CdsFileListDef.RecNo := SelectedSet;
  end;
end;

end.
