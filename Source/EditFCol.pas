unit EditFCol;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.UITypes,
  System.Classes, Vcl.Controls, Vcl.ExtCtrls,
  UnitScaleForm, Vcl.StdCtrls, Vcl.Buttons, Data.DB, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls;

type
  TFEditFColumn = class(TScaleForm)
    PnlBottom: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    CdsColumnSet: TClientDataSet;
    CdsFileListDef: TClientDataSet;
    PnlRight: TPanel;
    PnlGrids: TPanel;
    PnlTop: TPanel;
    DbgFileListDef: TDBGrid;
    DbgColumnSet: TDBGrid;
    HSplitter: TSplitter;
    VSplitter: TSplitter;
    PnlMiddle: TPanel;
    DsFileListDef: TDataSource;
    DsColumnSet: TDataSource;
    CdsFileListDefName: TStringField;
    CdsFileListDefDescription: TStringField;
    CdsColumnSetFileListName: TStringField;
    CdsColumnSetName: TStringField;
    CdsColumnSetCommand: TStringField;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    CdsFileListDefId: TIntegerField;
    CdsFileListDefMode: TStringField;
    CdsColumnSetOption: TStringField;
    CdsColumnSetBackup: TStringField;
    CdsColumnSetAlignR: TIntegerField;
    CdsColumnSetWidth: TStringField;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CdsFileListDefAfterInsert(DataSet: TDataSet);
    procedure CdsColumnSetAfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
  protected
    function GetDefWindowSizes: TRect; override;
  public
    { Public declarations }
    var SelectedSet: integer;
  end;

var
  FEditFColumn: TFEditFColumn;

implementation

uses Main, MainDef, UnitColumnDefs, ExifToolsGUI_Utils;

{$R *.dfm}

function TFEditFColumn.GetDefWindowSizes: TRect;
begin
  result := Rect(108, 106, 880, 515);
end;

procedure TFEditFColumn.CdsColumnSetAfterInsert(DataSet: TDataSet);
begin
  CdsColumnSetWidth.AsInteger := 80;
  CdsColumnSetAlignR.AsInteger := 0;
end;

procedure TFEditFColumn.CdsFileListDefAfterInsert(DataSet: TDataSet);
begin
  CdsFileListDefMode.AsString := 'User';
  CdsFileListDefId.AsInteger := CdsFileListDef.RecordCount + 1;
end;

procedure TFEditFColumn.FormClose(Sender: TObject; var Action: TCloseAction);
var
  FileListDefs: TColumnSetList;
  AColumnSet: TColumnsArray;
  AFileOption: TFileListOptions;
begin

  if (ModalResult = IDOK) then
  begin
    SelectedSet := CdsFileListDef.RecNo;
    FileListDefs := GetFileListDefs;
    FileListDefs.Clear;
    try
      CdsFileListDef.First;

      while not CdsFileListDef.Eof do
      begin

        AFileOption := [floSystem];
        if (CdsFileListDefMode.AsString = 'User') then
          Include(AFileOption, floUserDef)
        else
          Include(AFileOption, floInternal);

        CdsColumnSet.First;
        SetLength(AColumnSet, CdsColumnSet.RecordCount);
        while not CdsColumnSet.Eof do
        begin
          AColumnSet[CdsColumnSet.RecNo -1].SetCaption(CdsColumnSetName.AsString);
          AColumnSet[CdsColumnSet.RecNo -1].Command := CdsColumnSetCommand.AsString;
          AColumnSet[CdsColumnSet.RecNo -1].Width := CdsColumnSetWidth.AsInteger;
          AColumnSet[CdsColumnSet.RecNo -1].AlignR := CdsColumnSetAlignR.AsInteger;

          AColumnSet[CdsColumnSet.RecNo -1].Options := 0;

          if (CdsColumnSetOption.AsString = 'Sys') then
            AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + toSys;
          if (CdsColumnSetOption.AsString = 'Decimal') then
            AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + toDecimal;
          if (CdsColumnSetOption.AsString = 'YesNo') then
            AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + toYesNo;
          if (CdsColumnSetOption.AsString = 'HorVer') then
            AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + toHorVer;
          if (CdsColumnSetOption.AsString = 'Flash') then
            AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + toFlash;
          if (CdsColumnSetOption.AsString = 'Country') then
            AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + toCountry;

          if (CdsColumnSetBackup.AsString = 'Backup') then
            AColumnSet[CdsColumnSet.RecNo -1].Options := AColumnSet[CdsColumnSet.RecNo -1].Options + toBackup;

          CdsColumnSet.Next;
        end;
        FileListDefs.Add(TColumnSet.Create(CdsFileListDefName.AsString,
                                           CdsFileListDefDescription.AsString,
                                           AFileOption, AColumnSet));

        CdsFileListDef.Next;
      end;
    finally
      CdsFileListDef.Close;
      CdsColumnSet.Close;
    end;
  end;
end;

procedure TFEditFColumn.FormCreate(Sender: TObject);
begin
  ReadFormSizes(Self, Self.DefWindowSizes);
end;

procedure TFEditFColumn.FormShow(Sender: TObject);
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

    CdsColumnSet.IndexFieldNames := 'FileListName';
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
      if (AColumnSet.Options = [floSystem]) then
        CdsFileListDefMode.AsString := 'System'
      else if (floUserDef in AColumnSet.Options) then
        CdsFileListDefMode.AsString := 'User'
      else
        CdsFileListDefMode.AsString := 'Internal';

      CdsFileListDefDescription.AsString := AColumnSet.Desc;

      CdsFileListDef.Post;

      for Index := 0 to High(AColumnSet.ColumnDefs) do
      begin
        AColumn := AColumnSet.ColumnDefs[Index];
        CdsColumnSet.Insert;
        CdsColumnSetFileListName.AsString := AColumnSet.Name;
        CdsColumnSetName.AsString := AColumn.Caption;
        CdsColumnSetCommand.AsString := AColumn.Command;
        if ((AColumn.Options and toBackup) = toBackup) then
          CdsColumnSetBackup.AsString := 'Backup';

//TODO translate
        if ((AColumn.Options and toSys) = toSys) then
          CdsColumnSetOption.AsString := 'Sys'
        else if ((AColumn.Options and toDecimal) = toDecimal) then
          CdsColumnSetOption.AsString := 'Decimal'
        else if ((AColumn.Options and toYesNo) = toYesNo) then
          CdsColumnSetOption.AsString := 'YesNo'
        else if ((AColumn.Options and toHorVer) = toHorVer) then
          CdsColumnSetOption.AsString := 'HorVer'
        else if ((AColumn.Options and toFlash) = toFlash) then
          CdsColumnSetOption.AsString := 'Flash'
        else if ((AColumn.Options and toCountry) = toCountry) then
          CdsColumnSetOption.AsString := 'Country';
        CdsColumnSetWidth.AsInteger := AColumn.Width;
        CdsColumnSetAlignR.AsInteger := AColumn.AlignR;

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
