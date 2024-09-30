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
    PnlGrids: TPanel;
    PnlTop: TPanel;
    DbgFileListDef: TDBGrid;
    DbgColumnSet: TDBGrid;
    HSplitter: TSplitter;
    PnlMiddle: TPanel;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  protected
    function GetDefWindowSizes: TRect; override;
  public
    { Public declarations }
  end;

var
  FEditFColumn: TFEditFColumn;

implementation

{$R *.dfm}

uses
  System.StrUtils,
  UDmFileLists,
  Main, MainDef, UnitColumnDefs, ExifToolsGUI_Utils;

function TFEditFColumn.GetDefWindowSizes: TRect;
begin
  result := Rect(108, 106, 880, 640);
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

procedure TFEditFColumn.FormShow(Sender: TObject);
begin
  DmFileLists.LoadFromColumnSets;
end;

end.
