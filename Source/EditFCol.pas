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
    DBNavFileList: TDBNavigator;
    DBNavColumnSet: TDBNavigator;
    PnlDetail: TPanel;
    VSplitter: TSplitter;
    DbgTagNames: TDBGrid;
    PnlEdSearch: TPanel;
    EdSearchTag: TLabeledEdit;
    BtnLoadXMP: TButton;
    SpbAddPred: TSpeedButton;
    SpbDelPred: TSpeedButton;
    SpbEditPred: TSpeedButton;
    SpbAddTag: TSpeedButton;
    SpbDelTag: TSpeedButton;
    SpbEditTag: TSpeedButton;
    SpbDuplicate: TSpeedButton;
    SpbDefaults: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DbGridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdSearchTagKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DbgTagNamesDblClick(Sender: TObject);
    procedure DbgColumnSetEditButtonClick(Sender: TObject);
    procedure BtnLoadXMPClick(Sender: TObject);
    procedure SpbAddPredClick(Sender: TObject);
    procedure SpbDelPredClick(Sender: TObject);
    procedure SpbEditPredClick(Sender: TObject);
    procedure SpbAddTagClick(Sender: TObject);
    procedure SpbDelTagClick(Sender: TObject);
    procedure SpbEditTagClick(Sender: TObject);
    procedure SpbDefaultsClick(Sender: TObject);
    procedure SpbDuplicateClick(Sender: TObject);
  private
    { Private declarations }
    FSample: TShellFolder;
    procedure CreateDefaults;
    procedure TagNameLookup;
    procedure EndTagNameLookup(Value: string);
    procedure OnSetEditMode(Sender: Tobject);
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
  System.StrUtils, System.IniFiles, System.SysUtils,
  Vcl.Dialogs,
  UDmFileLists, UFrmTagNames,
  Main, ExifToolsGUI_Utils, MainDef, UnitColumnDefs, UnitLangResources;

function TFEditFColumn.GetDefWindowSizes: TRect;
begin
  result := Rect(108, 106, 880, 640);
end;

procedure TFEditFColumn.CreateDefaults;
var
  GUIini: TMemIniFile;
begin
  GUIini := TMemIniFile.Create('NUL', TEncoding.UTF8);
  try
    ReadFileListColumns(FMain.ShellList.Handle, GUIini);
    DmFileLists.LoadFromColumnSets(FSample);
  finally
    GUIini.Free;
  end;
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
// Create txt file with XMP tags
  DmFileLists.WriteAllXmpTags;
end;

procedure TFEditFColumn.DbgColumnSetEditButtonClick(Sender: TObject);
begin
  if DmFileLists.CdsColumnSet.ReadOnly then
    exit;
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

procedure TFEditFColumn.OnSetEditMode(Sender: Tobject);
begin
  case (TFileListOptions(DmFileLists.CdsFileListDefOptions.AsInteger)) of
    TFileListOptions.floSystem:
      begin
        DmFileLists.CdsFileListDef.ReadOnly := true;
        DbgFileListDef.ReadOnly := true;

        SpbDelPred.Enabled := false;
        SpbEditPred.Enabled := false;

        DmFileLists.CdsColumnSet.ReadOnly := true;
        DbgColumnSet.ReadOnly := true;

        SpbAddTag.Enabled := false;
        SpbDelTag.Enabled := false;
        SpbEditTag.Enabled := false;
      end;
    TFileListOptions.floInternal:
      begin
        DmFileLists.CdsFileListDef.ReadOnly := false;
        DbgFileListDef.ReadOnly := false;
        SpbDelPred.Enabled := false;
        SpbEditPred.Enabled := true;
        DbgFileListDef.Columns[0].ReadOnly := true;
        DbgFileListDef.Columns[1].ReadOnly := true;
        DbgFileListDef.Columns[2].ReadOnly := true;
        DbgFileListDef.Columns[3].ReadOnly := false;

        DmFileLists.CdsColumnSet.ReadOnly := false;
        DbgColumnSet.ReadOnly := false;
        SpbAddTag.Enabled := true;
        SpbDelTag.Enabled := true;
        SpbEditTag.Enabled := true;
      end;
    TFileListOptions.floUserDef:
      begin
        DmFileLists.CdsFileListDef.ReadOnly := false;
        DbgFileListDef.ReadOnly := false;
        SpbDelPred.Enabled := true;
        SpbEditPred.Enabled := true;
        DbgFileListDef.Columns[0].ReadOnly := not (DmFileLists.CdsFileListDef.State in [dsInsert]);
        // Readonly is not recognized
        DbgFileListDef.SelectedIndex := 1;
        DbgFileListDef.SelectedIndex := 0;
        DbgFileListDef.Columns[1].ReadOnly := false;
        DbgFileListDef.Columns[2].ReadOnly := true;
        DbgFileListDef.Columns[3].ReadOnly := false;

        DmFileLists.CdsColumnSet.ReadOnly := false;
        DbgColumnSet.ReadOnly := false;
        SpbAddTag.Enabled := true;
        SpbDelTag.Enabled := true;
        SpbEditTag.Enabled := true;
      end;
  end;
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
  DmFileLists.OnSetEditMode := OnSetEditMode;
end;

procedure TFEditFColumn.SpbAddPredClick(Sender: TObject);
begin
  DmFileLists.CdsFileListDef.Last;
  DmFileLists.CdsFileListDef.Append;
end;

procedure TFEditFColumn.SpbDefaultsClick(Sender: TObject);
begin
  if (MessageDlgEx(StrDeleteCustom, '', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel]) = IdCancel) then
    exit;

  CreateDefaults;
end;

procedure TFEditFColumn.SpbDelPredClick(Sender: TObject);
begin
  DmFileLists.CdsFileListDef.Delete;
end;

procedure TFEditFColumn.SpbEditPredClick(Sender: TObject);
begin
  DmFileLists.CdsFileListDef.Edit;
end;

procedure TFEditFColumn.SpbAddTagClick(Sender: TObject);
begin
  DmFileLists.CdsColumnSet.Insert;
end;

procedure TFEditFColumn.SpbDelTagClick(Sender: TObject);
begin
  DmFileLists.CdsColumnSet.Delete;
end;

procedure TFEditFColumn.SpbDuplicateClick(Sender: TObject);
var
  NewName: array[0..1] of string;
begin
  NewName[0] := DmFileLists.CdsFileListDefName.AsString + '_Copy';
  NewName[1] := DmFileLists.CdsFileListDefDescription.AsString + '_Copy';
  if (InputQuery('New Filelist', ['Name', 'Description'], NewName)) then
    DmFileLists.Duplicate(DmFileLists.CdsFileListDefId.AsInteger, NewName[0], NewName[1]);
end;

procedure TFEditFColumn.SpbEditTagClick(Sender: TObject);
begin
  DmFileLists.CdsColumnSet.Edit;
end;

end.
