unit UDmFileLists;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.UITypes,
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
    CdsFileListDefType: TStringField;
    CdsFileListDefReadMode: TIntegerField;
    CdsFileListDefReadModeLookup: TStringField;
    DsColumnSet: TDataSource;
    CdsColumnSet: TClientDataSet;
    CdsColumnSetCaption: TStringField;
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
    CdsFileListDefOptions: TIntegerField;
    CdsColumnSetId: TIntegerField;
    procedure CdsColumnSetBeforeInsert(DataSet: TDataSet);
    procedure CdsColumnSetAfterInsert(DataSet: TDataSet);
    procedure CdsFileListDefAfterInsert(DataSet: TDataSet);
    procedure DataModuleCreate(Sender: TObject);
    procedure CdsColumnSetCalcFields(DataSet: TDataSet);
    procedure DataModuleDestroy(Sender: TObject);
    procedure CdsTagNamesFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure CdsTagNamesCalcFields(DataSet: TDataSet);
    procedure CdsColumnSetCommandValidate(Sender: TField);
    procedure CdsFileListDefAfterScroll(DataSet: TDataSet);
    procedure CdsFileListDefBeforePost(DataSet: TDataSet);
    procedure CdsFileListDefBeforeDelete(DataSet: TDataSet);
    procedure CdsFileListDefAfterPost(DataSet: TDataSet);
    procedure CdsFileListDefBeforeInsert(DataSet: TDataSet);
    procedure CdsFileListDefReadModeChange(Sender: TField);
  private
    { Private declarations }
    ColumnSeq: Double;
    FListReadMode: integer;
    FSample: TShellFolder;
    FSampleValues: TSampleData;
    FSystemTagNames: TStringlist;
    FOnSetEditMode: TNotifyEvent;
    FOnFilterTag: TFilterRecordEvent;
    procedure DoSetEditMode;
    function CheckEmptyField(Sender: TField): boolean;
    procedure PrepTagNames;
    procedure AddTagName(ATagName: string; CheckExist: boolean);
    procedure CalcSampleValue(DataSet: TDataSet; Command, Sample: string);
    procedure GetSampleValues(AListReadMode: integer);
    procedure SetupLookUps;
  public
    { Public declarations }
    SelectedSet: integer;
    function GetSampleValue(Command: string; var Value: string): boolean;
    function ShowFieldExists(AField: string; AButtons: TMsgDlgButtons = [TMsgDlgBtn.mbOK]): integer;
    function NameExists(Name: string): boolean;
    procedure LoadFromColumnSets(ASample: TShellFolder);
    procedure SaveToColumnSets;
    procedure WriteAllXmpTags;
    procedure Duplicate(OldId: integer; NewName: string);
    property OnSetEditMode: TNotifyEvent read FOnSetEditMode write FOnSetEditMode;
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

function TDmFileLists.CheckEmptyField(Sender: TField): boolean;
begin
  result := (Sender.AsString <> '');
  if (not result) then
    MessageDlgEx(Format('%s is Mandatory', [Sender.FieldName]), '', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK]);
end;

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
  SampleValue: string;
begin
  if not (Dataset.State in [dsCalcFields, dsInsert, dsEdit]) then
    exit;
  if (Dataset.ControlsDisabled) then
    exit;

  GetSampleValues(CdsFileListDef.FieldByName('ReadMode').AsInteger);

  if GetSampleValue(Dataset.FieldByName(Command).AsString, SampleValue) then
    Dataset.FieldByName(Sample).AsString := SampleValue
  else
    Dataset.FieldByName(Sample).AsString := '-';
end;

procedure TDmFileLists.CdsColumnSetCalcFields(DataSet: TDataSet);
begin
  CalcSampleValue(DataSet, 'Command', 'SampleValue');
end;

procedure TDmFileLists.CdsColumnSetCommandValidate(Sender: TField);
var
  P: integer;
begin
  if (LeftStr(Sender.AsString, 1) <> '-') then
  begin
    CdsColumnSetOption.AsInteger := Ord(toSys);
    CdsColumnSetCaption.AsString := FSystemTagNames.Values[Sender.AsString];
  end
  else
  begin
    CdsColumnSetOption.AsInteger := (CdsColumnSetOption.AsInteger and ($ffff - Ord(toSys)));
    if (CdsColumnSetCaption.AsString = '') then
    begin
      P := Pos(':', Sender.AsString);
      if (P > 0) then
        CdsColumnSetCaption.AsString := Copy(Sender.AsString, P +  1);
    end;
  end;
end;

procedure TDmFileLists.DoSetEditMode;
begin
  if (CdsFileListDef.ControlsDisabled) then
    exit;
  if Assigned(FOnSetEditMode) then
    FOnSetEditMode(Self);
end;

procedure TDmFileLists.CdsFileListDefAfterInsert(DataSet: TDataSet);
begin
  CdsFileListDefType.AsString := ListUser;
  CdsFileListDefOptions.AsInteger := Ord(floUserDef);
  CdsFileListDefReadMode.AsInteger := Ord(rmInternal);
  CdsFileListDefId.AsInteger := CdsFileListDef.RecordCount;
end;

procedure TDmFileLists.CdsFileListDefAfterPost(DataSet: TDataSet);
begin
  DoSetEditMode;
end;

procedure TDmFileLists.CdsFileListDefAfterScroll(DataSet: TDataSet);
begin
  DoSetEditMode;
end;

procedure TDmFileLists.CdsFileListDefBeforeInsert(DataSet: TDataSet);
begin
  DoSetEditMode;
end;

function TDmFileLists.GetSampleValue(Command: string; var Value: string): boolean;
var
  P: integer;
  LowerCommand: string;
begin
  LowerCommand := LowerCase(Command);
  P := Pos('#', LowerCommand);
  if (P > 1) then
    SetLength(LowerCommand, P -1);

  result := FSampleValues.TryGetValue(LowerCommand, Value);
end;

function TDmFileLists.ShowFieldExists(AField: string; AButtons: TMsgDlgButtons = [TMsgDlgBtn.mbOK]): integer;
begin
  result := MessageDlgEx(Format('%s Exists', [AField]), '', TMsgDlgType.mtError, AButtons);
end;

procedure TDmFileLists.CdsFileListDefBeforePost(DataSet: TDataSet);
begin
  if not (CheckEmptyField(Dataset.FieldByName('Name'))) then
    Abort;

  if (Dataset.State in [dsInsert]) and
     NameExists(Dataset.FieldByName('Name').AsString) then
  begin
    ShowFieldExists(Dataset.FieldByName('Name').AsString);
    Abort;
  end;
end;

procedure TDmFileLists.CdsFileListDefReadModeChange(Sender: TField);
begin
  if (CdsFileListDef.ControlsDisabled) then
    exit;
  GetSampleValues(Sender.AsInteger);
end;

procedure TDmFileLists.CdsFileListDefBeforeDelete(DataSet: TDataSet);
begin
  if CdsFileListDef.ReadOnly then
    Abort;
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
  CdsTagNames.Filtered := false;
  CdsTagNames.IndexFieldnames := 'TagName';
  CdsTagNames.CreateDataSet;
  CdsTagNames.LogChanges := false;
end;

procedure TDmFileLists.AddTagName(ATagName: string; CheckExist: boolean);
begin
  if not CheckExist or
     VarIsNull(CdsTagNames.Lookup('TagName', ATagName, 'TagName')) then
    CdsTagNames.AppendRecord([ATagName]);
end;

procedure TDmFileLists.GetSampleValues(AListReadMode: integer);
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

  // Already have the tagnames?
  if (FListReadMode = AListReadMode) then
    exit;
  FListReadMode := AListReadMode;

  // Clear
  PrepTagNames;
  FSampleValues.Clear;

  if not Assigned(FSample) then   // Need a ShellFolder
    exit;

  CdsTagNames.DisableControls;
  try
    for Index := 0 to FSystemTagNames.Count -1 do
    begin
      TagName := FSystemTagNames.KeyNames[Index];
      Sample  := TSubShellFolder.GetSystemField(FSample.Parent, FSample.RelativeID, Index);
      FSampleValues.Add(TagName, Sample);
      AddTagName(TagName, false);
    end;

    case FListReadMode of
      0:;   // Limit to System Fields
      1,3:  // Limit to Internal fields
        begin
          // Load all internal fields
          for TagName in TMetaData.AllInternalFields do
          begin
            KeyName := '-' + TagName;
            AddTagName(KeyName, false);
          end;

          // Load sample values found in file. Can be XMP!
          MetaData := TMetaData.Create;
          try
            MetaData.ReadMeta(FSample.PathName, [gmXMP, gmGPS]);
            for TagName in MetaData.FieldNames do
            begin
              KeyName := '-' + TagName;
              if (FSampleValues.ContainsKey(LowerCase(KeyName))) then
                continue;
              FSampleValues.Add(LowerCase(KeyName), MetaData.FieldData(TagName));
              AddTagName(KeyName, true);
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
            AddTagName(KeyName, true);
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

// Create txt file to include in resource
procedure TDmFileLists.WriteAllXmpTags;
var
  GroupNames: TStringList;
  TagNames: TStringList;
  GroupName: string;
  TagName: string;
  F:TExtFile;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);

  GroupNames := TStringList.Create;
  TagNames := TStringList.Create;

  try
    FillGroupsInStrings('', GroupNames, '1');
    AssignFile(F, IncludeTrailingPathDelimiter(GetAppPath) +  'Xmp_Tags.txt');
    Rewrite(F);

    for GroupName in GroupNames do
    begin
      if (StartsText('Xmp-', GroupName)) then
      begin
        FillTagsInStrings('', TagNames, '1', GroupName, false);
        for TagName in TagNames do
          Writeln(F, GroupName + ':' + TagName);
      end;
    end;
    CloseFile(F);
  finally
    GroupNames.Free;
    TagNames.Free;
    SetCursor(CrNormal);
  end;
end;

procedure TDmFileLists.Duplicate(OldId: integer; NewName: string);
var
  Orig: TColumnsArray;
  Acolumn: TFileListColumn;
  Index: integer;
begin
  CdsFileListDef.DisableControls;
  CdsColumnSet.DisableControls;
  CdsFileListDef.ReadOnly := false;
  CdsColumnSet.ReadOnly := false;
  try
    CdsFileListDef.Insert;
    CdsFileListDefName.AsString := NewName;
    CdsFileListDef.Post;
    Orig := GetFileListColumnDefs(OldId);
    ColumnSeq := 0;
    for Index := 0 to High(Orig) do
    begin
      AColumn := Orig[Index];
      ColumnSeq := ColumnSeq + 1;
      CdsColumnSet.Insert;
      CdsColumnSetCaption.AsString        := AColumn.Caption;
      CdsColumnSetCommand.AsString        := AColumn.Command;
      CdsColumnSetOption.AsInteger        := Ord(AColumn.Options) and $00ff;
      CdsColumnSetBackup.AsInteger        := Ord(AColumn.Options) and $ff00;
      CdsColumnSetWidth.AsInteger         := AColumn.Width;
      CdsColumnSetAlignR.AsInteger        := AColumn.AlignR;
      CdsColumnSet.Post;
    end;
  finally
    CdsFileListDef.EnableControls;
    CdsColumnSet.EnableControls;
    DoSetEditMode;
  end;
end;

procedure TDmFileLists.SetupLookUps;

  procedure PrepLookUP(ADS: TClientDataSet);
  begin
    ADS.Close;
    ADS.IndexFieldNames := 'Key';
    ADS.CreateDataSet;
    ADS.LogChanges := false;
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
begin
  if (CdsFileListDef.State in [dsEdit, dsInsert]) then
    CdsFileListDef.Post;
  if (CdsColumnSet.State in [dsEdit, dsInsert]) then
    CdsColumnSet.Post;

  CdsFileListDef.DisableControls;
  CdsColumnSet.DisableControls;

  SelectedSet := CdsFileListDef.RecNo;
  FileListDefs := GetFileListDefs;
  FileListDefs.Clear;
  try
    CdsFileListDef.First;

    while not CdsFileListDef.Eof do
    begin
      CdsColumnSet.SetRange([CdsFileListDefId.AsInteger], [CdsFileListDefId.AsInteger]);
      CdsColumnSet.First; // Not needed
      SetLength(AColumnSet, CdsColumnSet.RecordCount);
      while not CdsColumnSet.Eof do
      begin
        AColumnSet[CdsColumnSet.RecNo -1].SetCaption(CdsColumnSetCaption.AsString);
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
                                         TFileListOptions(CdsFileListDefOptions.AsInteger),
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

function TDmFileLists.NameExists(Name: string): boolean;
var
  ACds: TClientDataSet;
begin
  ACds := TClientDataSet.Create(Self);
  try
    ACds.CloneCursor(CdsFileListDef, true, false);
    result := ACds.Locate('Name', Name, [TLocateOption.loCaseInsensitive]);
  finally
    ACds.Free;
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

  FListReadMode := -1;

  CdsFileListDef.Close;
  CdsColumnSet.Close;

  CdsFileListDef.DisableControls;
  CdsFileListDef.ReadOnly := false;

  CdsColumnSet.MasterSource := nil;
  CdsColumnSet.MasterFields := '';
  CdsColumnSet.DisableControls;
  CdsColumnSet.ReadOnly := false;
  try
    // Get Captions for 'fast' system fields
    TSubShellFolder.AllFastSystemFields(FSample.Parent, FSystemTagNames);

    //
    PrepTagNames;

    FileListDefs := GetFileListDefs;

    CdsFileListDef.IndexFieldNames := 'Id';
    CdsFileListDef.CreateDataSet;
    CdsFileListDef.LogChanges := false;

    CdsColumnSet.IndexFieldNames := 'Id;Seq';
    CdsColumnSet.CreateDataSet;
    CdsColumnSet.LogChanges := false;

    Id := 0;
    for AColumnSet in FileListDefs do
    begin
      CdsFileListDef.Insert;
      CdsFileListDefId.AsInteger := Id;
      CdsFileListDefName.AsString := AColumnSet.Name;
      CdsFileListDefOptions.AsInteger := Ord(AColumnSet.Options);
      case (AColumnSet.Options) of
        TFileListOptions.floSystem:
          CdsFileListDefType.AsString := ListSystem;
        TFileListOptions.floInternal:
          CdsFileListDefType.AsString := ListInternal;
        else
          CdsFileListDefType.AsString := ListUser;
      end;
      CdsFileListDefReadMode.AsInteger := AColumnSet.ReadModeInt;
      CdsFileListDef.Post;

      ColumnSeq := 0;
      for Index := 0 to High(AColumnSet.ColumnDefs) do
      begin
        AColumn := AColumnSet.ColumnDefs[Index];
        ColumnSeq := ColumnSeq + 1;
        CdsColumnSet.Insert;
        CdsColumnSetId.AsInteger            := Id;
        CdsColumnSetCaption.AsString        := AColumn.Caption;
        CdsColumnSetCommand.AsString        := AColumn.Command;
        CdsColumnSetOption.AsInteger        := Ord(AColumn.Options) and $00ff;
        CdsColumnSetBackup.AsInteger        := Ord(AColumn.Options) and $ff00;
        CdsColumnSetWidth.AsInteger         := AColumn.Width;
        CdsColumnSetAlignR.AsInteger        := AColumn.AlignR;
        CdsColumnSet.Post;
      end;

      Inc(Id);
    end;
  finally
    if (SelectedSet > CdsFileListDef.RecordCount) then
      SelectedSet := CdsFileListDef.RecordCount;
    CdsFileListDef.RecNo := SelectedSet;

    CdsFileListDef.EnableControls;
    CdsColumnSet.EnableControls;

    CdsColumnSet.MasterFields := 'Id';
    CdsColumnSet.MasterSource := DsFileListDef;

    DoSetEditMode;  // Now filter tagnames
  end;
end;

end.
