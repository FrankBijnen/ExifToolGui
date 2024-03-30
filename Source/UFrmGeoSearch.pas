unit UFrmGeoSearch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.ValEdit,
  ExifToolsGui_ComboBox, Geomap;

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
    EdBounds: TLabeledEdit;
    GrpCitySearch: TGroupBox;
    ChkComplete: TCheckBox;
    CmbLang: TComboBox;
    Label1: TLabel;
    ChkCaseSensitive: TCheckBox;
    LblCountryRegion: TLabel;
    CmbCountryRegion: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure CmbGeoProviderChange(Sender: TObject);
    procedure ChkCaseSensitiveClick(Sender: TObject);
    procedure ChkCompleteClick(Sender: TObject);
    procedure CmbLangChange(Sender: TObject);
    procedure CmbCountryRegionChange(Sender: TObject);
    procedure CmbCountryRegionDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    procedure UpdateDesign;
  public
    { Public declarations }
    var SelectedBounds: string;
    var CountryRegion: string;
  end;

var
  FGeoSearch: TFGeoSearch;

implementation

uses
  System.StrUtils, Vcl.Themes,
  Main, MainDef, ExifTool, ExifToolsGUI_Utils, UnitLangResources;

{$R *.dfm}

procedure TFGeoSearch.UpdateDesign;
begin
  EdBounds.Enabled := GeoSettings.GetCoordProvider = TGeoCodeProvider.gpOverPass;
  if (EdBounds.Enabled) and
     (CmbCountryRegion.Text = '') then
    EdBounds.Text := SelectedBounds
  else
    EdBounds.Text := '';

  if (GeoSettings.GetCoordProvider = TGeoCodeProvider.gpGeoName) then
    LblCountryRegion.Caption := StrWithinCountry
  else
    LblCountryRegion.Caption := StrWithinCountryRegion;

  ChkCaseSensitive.Enabled := (GeoSettings.GetCoordProvider = TGeoCodeProvider.gpOverPass);
  ChkCaseSensitive.Checked := ChkCaseSensitive.Enabled and
                              GeoSettings.CaseSensitive;
  ChkComplete.Enabled := GeoSettings.GetCoordProvider = TGeoCodeProvider.gpOverPass;
  ChkComplete.Checked := ChkComplete.Enabled and
                         GeoSettings.OverPassCompleteWord;
  SetupGeoCodeLanguage(CmbLang, GeoSettings.GetCoordProvider, GeoSettings.GeoCodeLang);
  ClearCoordCache; // Make sure we dont get cached data.
end;

procedure TFGeoSearch.BtnOKClick(Sender: TObject);
begin
  GeoSettings.CheckProvider;
  ModalResult := MROK;
end;

procedure TFGeoSearch.ChkCaseSensitiveClick(Sender: TObject);
begin
  GeoSettings.CaseSensitive := ChkCaseSensitive.Checked;
end;

procedure TFGeoSearch.ChkCompleteClick(Sender: TObject);
begin
  GeoSettings.OverPassCompleteWord := ChkComplete.Checked;
end;

procedure TFGeoSearch.CmbCountryRegionChange(Sender: TObject);
var
  Indx: integer;
begin
  Indx := CmbCountryRegion.Items.IndexOf(CmbCountryRegion.Text);
  if (Indx > -1) and
     (Indx < GetCountryList.Count) then
    CountryRegion := GetCountryList.KeyNames[Indx]
  else
    CountryRegion := CmbCountryRegion.Text;
  UpdateDesign;
end;

procedure TFGeoSearch.CmbCountryRegionDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  CountryName, CountryCode: string;
  ACanvas: TCanvas;
  DrawRect: TRect;
  LinePos: integer;
begin
  // Split item in Code and name
  CountryName := TComboBox(Control).Items[index];
  CountryCode := NextField(CountryName, '|');

  // Compute the position of the dividing line
  ACanvas := TComboBox(Control).Canvas;
  ACanvas.FillRect(Rect);
  LinePos := ACanvas.TextWidth('QQQ') + Rect.Left;

  // Draw Line
  ACanvas.Pen.Color := TStyleManager.Style[GUIsettings.GuiStyle].GetStyleFontColor(TStyleFont.sfListItemTextNormal);
  ACanvas.MoveTo(LinePos, Rect.Top);
  ACanvas.LineTo(LinePos, Rect.Bottom);

  // Draw Country Code
  DrawRect:= Rect;
  DrawRect.Right := LinePos;
  ACanvas.TextRect(DrawRect, CountryCode, [TTextFormats.tfLeft, TTextFormats.tfSingleLine]);

  // Draw Country Name
  DrawRect:= Rect;
  DrawRect.Left := LinePos + ACanvas.TextWidth('Q');
  ACanvas.TextRect(DrawRect, CountryName, [TTextFormats.tfLeft, TTextFormats.tfSingleLine]);
end;

procedure TFGeoSearch.CmbGeoProviderChange(Sender: TObject);
begin
  GeoSettings.GetCoordProvider := TGeoCodeProvider(CmbGeoProvider.ItemIndex);
  UpdateDesign;
end;

procedure TFGeoSearch.CmbLangChange(Sender: TObject);
begin
  GeoSettings.GeoCodeLang := GetExifToolLanguage(CmbLang);
end;

procedure TFGeoSearch.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  StatusBar1.SimpleText := '';

  CmbGeoProvider.ItemIndex := Ord(GeoSettings.GetCoordProvider);
  CmbLang.Text := GeoSettings.GeoCodeLang;
  CmbCountryRegion.Items.Text := StringReplace(GetCountryList.Text, '=', '|', [rfReplaceAll]);
  CmbCountryRegion.ItemIndex := GetCountryList.IndexOfName(CountryRegion);
  if (CmbCountryRegion.ItemIndex = -1) then
    CmbCountryRegion.Text := CountryRegion;

  SelectedBounds := EdBounds.Text;

  UpdateDesign;
  BtnOK.SetFocus;
end;

end.
