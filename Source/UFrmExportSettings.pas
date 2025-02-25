unit UFrmExportSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls, System.ImageList, Vcl.ImgList,
  UnitScaleForm;

type
  TFrmExportSettings = class(TScaleForm)
    PnlBot: TPanel;
    BtnCancel: TBitBtn;
    BtnOK: TBitBtn;
    MemoTransfer: TMemo;
    LvSelections: TListView;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure SetPrefs;
    procedure StorePrefs;
    { Private declarations }
  public
    { Public declarations }
    CompleteRoute: boolean;
  end;

var
  FrmExportSettings: TFrmExportSettings;

implementation

uses
  System.TypInfo, MainDef, UnitLangResources;

{$R *.dfm}

procedure TFrmExportSettings.SetPrefs;

  procedure AddItem(Caption: string; Id: TIniData);
  var
    AnItem: TListItem;
  begin
    AnItem := LvSelections.Items.Add;
    AnItem.Caption  := Caption;
    AnItem.Checked  := Id in GUIsettings.SelIniData;
    AnItem.Data     := Pointer(Id);
  end;

begin
  LvSelections.Items.BeginUpdate;
  try
    LvSelections.Items.Clear;
    AddItem(StrWorkspace,       idWorkSpace);
    AddItem(StrETDirect,        idETDirect);
    AddItem(StrFileLists,       idFileLists);
    AddItem(StrCustomView,      idCustomView);
    AddItem(StrPredefinedTags,  idPredefinedTags);
  finally
    LvSelections.Items.EndUpdate;
  end;
end;

procedure TFrmExportSettings.StorePrefs;
var
  AnItem: TListItem;
begin
  GUIsettings.SelIniData := [];
  for AnItem in LvSelections.Items do
  begin
    if (AnItem.Checked) then
      Include(GUIsettings.SelIniData, TIniData(AnItem.Data));
  end;
end;

procedure TFrmExportSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = ID_Ok then
    StorePrefs;
end;

procedure TFrmExportSettings.FormShow(Sender: TObject);
begin
  SetPrefs;
end;

end.

