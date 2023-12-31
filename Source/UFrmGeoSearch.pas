unit UFrmGeoSearch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.ValEdit,
  Geomap;

type
  TFGeoSearch = class(TScaleForm)
    StatusBar1: TStatusBar;
    BtnCancel: TButton;
    BtnOK: TButton;
    PctMain: TPageControl;
    TabSearch: TTabSheet;
    CmbGeoProvider: TComboBox;
    Label2: TLabel;
    EdSearchCity: TLabeledEdit;
    EdRegion: TLabeledEdit;
    EdBounds: TLabeledEdit;
    GrpCitySearch: TGroupBox;
    ChkComplete: TCheckBox;
    CmbOverPasslang: TComboBox;
    Label1: TLabel;
    ChkCaseSensitve: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure CmbGeoProviderChange(Sender: TObject);
    procedure EdRegionChange(Sender: TObject);
    procedure ChkCaseSensitveClick(Sender: TObject);
    procedure ChkCompleteClick(Sender: TObject);
    procedure CmbOverPasslangChange(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateDesign;
  public
    { Public declarations }
    var SelectedBounds: string;
  end;

var
  FGeoSearch: TFGeoSearch;

implementation

uses System.StrUtils, Main, ExifTool, ExifToolsGUI_Utils;

{$R *.dfm}

procedure TFGeoSearch.UpdateDesign;
begin
  EdBounds.Enabled := GeoSettings.GetCoordProvider = TGeoCodeProvider.gpOverPass;
  if (EdBounds.Enabled) and
     (EdRegion.Text = '') then
    EdBounds.Text := SelectedBounds
  else
    EdBounds.Text := '';
  ChkCaseSensitve.Enabled := GeoSettings.GetCoordProvider = TGeoCodeProvider.gpOverPass;
  ChkCaseSensitve.Checked := ChkCaseSensitve.Enabled and
                             GeoSettings.OverPassCaseSensitive;
  ChkComplete.Enabled := GeoSettings.GetCoordProvider = TGeoCodeProvider.gpOverPass;
  ChkComplete.Checked := ChkComplete.Enabled and
                         GeoSettings.OverPassCompleteWord;
  CmbOverPasslang.Enabled := ChkComplete.Enabled;
end;

procedure TFGeoSearch.BtnOKClick(Sender: TObject);
begin
  ModalResult := MROK;
end;

procedure TFGeoSearch.ChkCaseSensitveClick(Sender: TObject);
begin
  GeoSettings.OverPassCaseSensitive := ChkCaseSensitve.Checked;
end;

procedure TFGeoSearch.ChkCompleteClick(Sender: TObject);
begin
  GeoSettings.OverPassCompleteWord := ChkComplete.Checked;
end;

procedure TFGeoSearch.CmbGeoProviderChange(Sender: TObject);
begin
  GeoSettings.GetCoordProvider := TGeoCodeProvider(CmbGeoProvider.ItemIndex);
  UpdateDesign;
end;

procedure TFGeoSearch.CmbOverPasslangChange(Sender: TObject);
begin
  GeoSettings.OverPassLang := CmbOverPasslang.Text;
end;

procedure TFGeoSearch.EdRegionChange(Sender: TObject);
begin
  UpdateDesign;
end;

procedure TFGeoSearch.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  StatusBar1.SimpleText := '';

  CmbGeoProvider.ItemIndex := Ord(GeoSettings.GetCoordProvider);
  CmbOverPasslang.Text := GeoSettings.OverPassLang;
  SelectedBounds := EdBounds.Text;

  UpdateDesign;
end;

end.
