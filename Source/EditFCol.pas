unit EditFCol;

interface

uses
  Winapi.Windows, System.UITypes, System.Classes,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Shell.ShellCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Data.DB, Vcl.DBCtrls,
  UnitScaleForm, Vcl.Mask;

type

  TFEditFColumn = class(TScaleForm)
    PnlBottom: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    PnlGrids: TPanel;
    PnlTop: TPanel;
    DbgFileListDef: TDBGrid;
    DbgColumnSet: TDBGrid;
    HSplitter: TSplitter;
    PnlMiddle: TPanel;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    PnlDetail: TPanel;
    VSplitter: TSplitter;
    DbgTagNames: TDBGrid;
    PnlEdSearch: TPanel;
    EdSearchTag: TLabeledEdit;
    BtnLoadXMP: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DbGridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdSearchTagKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DbgTagNamesDblClick(Sender: TObject);
    procedure DbgColumnSetEditButtonClick(Sender: TObject);
    procedure BtnLoadXMPClick(Sender: TObject);
  private
    { Private declarations }
    FSample: TShellFolder;
    procedure TagNameLookup;
    procedure EndTagNameLookup(Value: string);
    procedure FileListChanged(Sender: Tobject);
    procedure TagNamesFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  protected
    function GetDefWindowSizes: TRect; override;
  public
    { Public declarations }
    procedure PrepareShow(ASample: TShellFolder);
  end;

var
  FEditFColumn: TFEditFColumn;

implementation

{$R *.dfm}

uses
  System.StrUtils,
  UDmFileLists,
  UFrmTagNames,
  MainDef, UnitColumnDefs;

function TFEditFColumn.GetDefWindowSizes: TRect;
begin
  result := Rect(108, 106, 880, 640);
end;

procedure TFEditFColumn.TagNameLookup;
begin
  case DmFileLists.CdsFileListDefReadMode.AsInteger of
    0,1,3:  // System, Internal, +ExifTool
      begin
        // Update search string
        EdSearchTag.Text := DbgColumnSet.SelectedField.AsString;
        DmFileLists.CdsTagNames.Filtered := false;
        DmFileLists.CdsTagNames.Filtered := (EdSearchTag.Text <> '');

        PnlDetail.Visible := true;
        VSplitter.Visible := true;
        EdSearchTag.SetFocus;
        DmFileLists.CdsTagNames.Locate('TagName',
                                       DmFileLists.CdsColumnSetCommand.AsString,
                                       [TLocateOption.loCaseInsensitive, TLocateOption.loPartialKey]);
      end;
    2:    // ExifTool
      begin
        if (Assigned(FSample)) then
          FrmTagNames.SetSample(FSample.PathName);
        FrmTagNames.EnableExclude(false);
        if (FrmTagNames.ShowModal = IDOK) then
          EndTagNameLookup('-' + FrmTagNames.SelectedTag(false));
      end;
  end;
end;

procedure TFEditFColumn.EndTagNameLookup(Value: string);
begin
  if not (DmFileLists.CdsColumnSet.State in [dsInsert, dsEdit]) then
    DmFileLists.CdsColumnSet.Edit;
  DmFileLists.CdsColumnSetCommand.AsString := Value;
  PnlDetail.Visible := false;
  VSplitter.Visible := false;
end;

procedure TFEditFColumn.DbgTagNamesDblClick(Sender: TObject);
begin
  EndTagNameLookup(DmFileLists.CdsTagNamesTagName.AsString);
end;

procedure TFEditFColumn.BtnLoadXMPClick(Sender: TObject);
begin
  DmFileLists.AddAllXmpTags;
end;

procedure TFEditFColumn.DbgColumnSetEditButtonClick(Sender: TObject);
begin
  // Get Latest values
  DmFileLists.CdsColumnSet.Edit;
  DmFileLists.CdsColumnSet.UpdateRecord;
  TagNameLookup;
end;

procedure TFEditFColumn.DbGridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//TODO: Decide
  if (Key = VK_ESCAPE) then
    ModalResult := mrCancel;
end;

procedure TFEditFColumn.EdSearchTagKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  with DmFileLists do
  begin
    CdsTagNames.Filtered := false;
    CdsTagNames.Filtered := (EdSearchTag.Text <> '');
  end;
end;

procedure TFEditFColumn.TagNamesFilterRecord(DataSet: TDataSet; var Accept: Boolean);
begin
  Accept := ContainsText(DataSet.FieldByName('TagName').AsString, EdSearchTag.Text);
end;

procedure TFEditFColumn.FileListChanged(Sender: Tobject);
begin
  PnlDetail.Visible := false;
  VSplitter.Visible := false;
end;

procedure TFEditFColumn.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (ModalResult = IDOK) then
    DmFileLists.SaveToColumnSets;
end;

procedure TFEditFColumn.FormCreate(Sender: TObject);
begin
  ReadFormSizes(Self, Self.DefWindowSizes);
end;

procedure TFEditFColumn.PrepareShow(ASample: TShellFolder);
begin
  FSample := ASample;
  DmFileLists.LoadFromColumnSets(FSample);
  DmFileLists.OnFilterTag := TagNamesFilterRecord;
  DmFileLists.OnFileListChanged := FileListChanged;
end;

end.
