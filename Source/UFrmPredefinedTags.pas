unit UFrmPredefinedTags;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.ValEdit,
  ExifToolsGui_ValEdit, MainDef;

type
  TFrmPredefinedTags = class(TScaleForm)
    PnlBottom: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    PnlButtons: TPanel;
    VLPredefinedTags: TValueListEditor;
    BtnAdd: TButton;
    BtnDelete: TButton;
    BtnDefaults: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnDefaultsClick(Sender: TObject);
  private
    { Private declarations }
    function ValidRow: boolean;
  public
    { Public declarations }
    Caller: TIniTagsData;
    CallerTags: string;
  end;

var
  FrmPredefinedTags: TFrmPredefinedTags;

implementation

uses
  ExifToolsGUI_Utils, UnitLangResources;

{$R *.dfm}

function TFrmPredefinedTags.ValidRow: boolean;
begin
  result := (VLPredefinedTags.Row > 0) and
            (VLPredefinedTags.Row <= VLPredefinedTags.Strings.Count);
end;

procedure TFrmPredefinedTags.BtnAddClick(Sender: TObject);
begin
  VLPredefinedTags.Row := VLPredefinedTags.InsertRow('', CallerTags, true);
  VLPredefinedTags.Col := 0;
  VLPredefinedTags.SetFocus;
end;

procedure TFrmPredefinedTags.BtnDefaultsClick(Sender: TObject);
begin
  VLPredefinedTags.Strings.Clear;

  VLPredefinedTags.Strings.AddPair('Remove Metadata', DefRemoveTags);
  VLPredefinedTags.Strings.AddPair('Copy MetaData From Single', DefCopySingleTags);
  VLPredefinedTags.Strings.AddPair('Copy MetaData From JpgOrTiff', DefExcludeCopyTags);

  case Caller of
    TIniTagsData.idtRemoveTags:
      VLPredefinedTags.Row := 1;
    TIniTagsData.idtCopySingleTags:
      VLPredefinedTags.Row := 2;
    TIniTagsData.idtCopyTags:
      VLPredefinedTags.Row := 3;
  end;
  VLPredefinedTags.SetFocus;
  VLPredefinedTags.Col := 0;
end;

procedure TFrmPredefinedTags.BtnDeleteClick(Sender: TObject);
begin
  if ValidRow then
    VLPredefinedTags.Strings.Delete(VLPredefinedTags.Row -1);
end;

procedure TFrmPredefinedTags.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (ModalResult = IDOK) then
  begin
    if ValidRow then
      CallerTags := VLPredefinedTags.Strings.ValueFromIndex[VLPredefinedTags.Row -1];
    PredefinedTagList.Assign(VLPredefinedTags.Strings);
  end;
end;

procedure TFrmPredefinedTags.FormShow(Sender: TObject);
begin
  if (PredefinedTagList.Count = 0) then
    BtnDefaultsClick(Sender)
  else
    VLPredefinedTags.Strings.Assign(PredefinedTagList);
end;

end.

