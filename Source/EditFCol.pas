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
    SpbAddPred: TSpeedButton;
    SpbDelPred: TSpeedButton;
    SpbEditPred: TSpeedButton;
    SpbAddTag: TSpeedButton;
    SpbDelTag: TSpeedButton;
    SpbEditTag: TSpeedButton;
    SpbDuplicate: TSpeedButton;
    SpbDefaults: TSpeedButton;
    BtnApplyTag: TButton;
    PnlSearch: TPanel;
    EdSearchTag: TEdit;
    LblSearchTag: TLabel;
    RadTagValues: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DbGridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdSearchTagKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DbgTagNamesDblClick(Sender: TObject);
    procedure DbgColumnSetEditButtonClick(Sender: TObject);
    procedure SpbAddPredClick(Sender: TObject);
    procedure SpbDelPredClick(Sender: TObject);
    procedure SpbEditPredClick(Sender: TObject);
    procedure SpbAddTagClick(Sender: TObject);
    procedure SpbDelTagClick(Sender: TObject);
    procedure SpbEditTagClick(Sender: TObject);
    procedure SpbDefaultsClick(Sender: TObject);
    procedure SpbDuplicateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnApplyTagClick(Sender: TObject);
    procedure ChkValuesClick(Sender: TObject);
    procedure RadTagValuesClick(Sender: TObject);
  private
    { Private declarations }
    FSample: TShellFolder;
    procedure CreateDefaults;
    procedure SetDetail(Visible: boolean);
    procedure TagNameLookup;
    procedure EndTagNameLookup(Value: string);
    procedure OnSetEditMode(Sender: Tobject);
    procedure SetFilter;
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

procedure TFEditFColumn.BtnApplyTagClick(Sender: TObject);
begin
  EndTagNameLookup(DmFileLists.CdsTagNamesTagName.AsString);
end;

procedure TFEditFColumn.ChkValuesClick(Sender: TObject);
begin
  SetFilter;
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

procedure TFEditFColumn.SetDetail(Visible: boolean);
begin
  PnlDetail.Visible := Visible;
  VSplitter.Visible := Visible;
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

        SetDetail(true);
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
  SetDetail(false);
end;

procedure TFEditFColumn.DbgTagNamesDblClick(Sender: TObject);
begin
  EndTagNameLookup(DmFileLists.CdsTagNamesTagName.AsString);
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

procedure TFEditFColumn.SetFilter;
begin
  with DmFileLists do
  begin
    CdsTagNames.Filtered := false;
    CdsTagNames.Filtered := (EdSearchTag.Text <> '') or (RadTagValues.ItemIndex = 0);
  end;
end;

procedure TFEditFColumn.EdSearchTagKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SetFilter;
end;

procedure TFEditFColumn.TagNamesFilterRecord(DataSet: TDataSet; var Accept: Boolean);
var
  SampleValue: string;
begin
  Accept := (RadTagValues.ItemIndex = 1) or
    DmFileLists.GetSampleValue(DataSet.FieldByName('TagName').AsString, SampleValue);
  Accept := Accept and
              ((EdSearchTag.Text = '') or
                ContainsText(DataSet.FieldByName('TagName').AsString, EdSearchTag.Text));
end;

procedure TFEditFColumn.OnSetEditMode(Sender: Tobject);
begin
  SetDetail(DmFileLists.CdsColumnSet.State in [dsEdit, dsInsert]);
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
        DbgFileListDef.Columns[2].ReadOnly := false;

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
        DbgFileListDef.Columns[0].ReadOnly := false;
        DbgFileListDef.Columns[2].ReadOnly := false;

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
  DmFileLists.OnSetEditMode := OnSetEditMode;
  DmFileLists.OnFilterTag := TagNamesFilterRecord;
end;

procedure TFEditFColumn.FormShow(Sender: TObject);
begin
  SetDetail(false);
end;

procedure TFEditFColumn.PrepareShow(ASample: TShellFolder);
begin
  FSample := ASample;
  DmFileLists.LoadFromColumnSets(FSample);
end;

procedure TFEditFColumn.RadTagValuesClick(Sender: TObject);
begin
  SetFilter;
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
  TagNameLookup;
end;

procedure TFEditFColumn.SpbDelTagClick(Sender: TObject);
begin
  DmFileLists.CdsColumnSet.Delete;
end;

procedure TFEditFColumn.SpbDuplicateClick(Sender: TObject);
var
  NewName: string;
begin
  NewName := DmFileLists.CdsFileListDefName.AsString + '_Copy';
  repeat
    if not (InputQuery('New Filelist', ['Name'], NewName)) then
      break;
    if DmFileLists.NameExists(NewName) then
    begin
      DmFileLists.ShowFieldExists(NewName);
      continue;
    end;
    DmFileLists.Duplicate(DmFileLists.CdsFileListDefId.AsInteger, NewName);
    break;
  until false;
end;

procedure TFEditFColumn.SpbEditTagClick(Sender: TObject);
begin
  DmFileLists.CdsColumnSet.Edit;
end;

end.
