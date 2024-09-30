unit UDmFileLists;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient;

type
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
    IntegerField1: TIntegerField;
    StringField1: TStringField;
    CdsColumnSetOptionLookUp: TStringField;
    procedure CdsColumnSetAfterInsert(DataSet: TDataSet);
    procedure CdsColumnSetBeforeInsert(DataSet: TDataSet);
    procedure CdsFileListDefAfterInsert(DataSet: TDataSet);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    var ColumnSeq: Double;
    procedure SetupLookUps;
  public
    { Public declarations }
    var SelectedSet: integer;
    procedure LoadFromColumnSets;
    procedure SaveToColumnSets;
  end;

var
  DmFileLists: TDmFileLists;

implementation
{%CLASSGROUP 'Vcl.Controls.TControl'}

uses UnitColumnDefs;

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

procedure TDmFileLists.CdsFileListDefAfterInsert(DataSet: TDataSet);
begin
  CdsFileListDefType.AsString := ListUser;
  CdsFileListDefReadMode.AsInteger := Ord(rmInternal);
  CdsFileListDefId.AsInteger := CdsFileListDef.RecordCount + 1;
end;


procedure TDmFileLists.DataModuleCreate(Sender: TObject);
begin
  SetupLookUps;
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

procedure TDmFileLists.LoadFromColumnSets;
var
  FileListDefs: TColumnSetList;
  AColumnSet: TColumnSet;
  AColumn: TFileListColumn;
  Index: integer;
  Id: integer;
begin
  CdsFileListDef.Close;
  CdsColumnSet.Close;

  CdsColumnSet.MasterSource := nil;
  CdsColumnSet.MasterFields := '';
  CdsFileListDef.DisableControls;
  CdsColumnSet.DisableControls;

  try
    CdsFileListDef.IndexFieldNames := 'Id';
    CdsFileListDef.CreateDataSet;

    CdsColumnSet.IndexFieldNames := 'FileListName;Seq';
    CdsColumnSet.CreateDataSet;

    FileListDefs := GetFileListDefs;
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
