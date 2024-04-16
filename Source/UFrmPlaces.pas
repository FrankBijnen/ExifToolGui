unit UFrmPlaces;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.StdCtrls, Vcl.Buttons, System.Classes,
  Vcl.Controls, Vcl.ExtCtrls, UnitScaleForm, Vcl.ComCtrls;

type
  TFrmPlaces = class(TScaleForm)
    Panel1: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    ListView1: TListView;
    BtnRetry: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddPlace2LV(PLace, Lat, Lon: string);
  end;

var
  FrmPlaces: TFrmPlaces;

implementation

{$R *.dfm}

procedure TFrmPlaces.AddPlace2LV(PLace, Lat, Lon: string);
begin
  with ListView1.Items.Add do
  begin
    Caption := Lat;
    Subitems.Add(Lon);
    Subitems.Add(PLace);
  end;
end;

procedure TFrmPlaces.FormShow(Sender: TObject);
begin
  ListView1.Selected := ListView1.Items[0];
end;

procedure TFrmPlaces.ListView1DblClick(Sender: TObject);
begin
  ModalResult := MROK;
end;

end.
