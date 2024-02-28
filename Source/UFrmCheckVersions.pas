unit UFrmCheckVersions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls, System.ImageList,
  Vcl.ImgList;

type
  TFrmCheckVersions = class(TScaleForm)
    Panel1: TPanel;
    Image1: TImage;
    LblVersion: TLabel;
    LvVersions: TListView;
    BtnClose: TBitBtn;
    BtnOpenUrl: TBitBtn;
    ImgVersions: TImageList;
    procedure FormShow(Sender: TObject);
    procedure LvVersionsDblClick(Sender: TObject);
    procedure OpenUrl(Sender: TObject);
    procedure BtnOpenUrlClick(Sender: TObject);
    procedure LvVersionsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetupLvVersions;
    procedure GetVersions;
  public
    { Public declarations }
  end;

var
  FrmCheckVersions: TFrmCheckVersions;

implementation

uses Main, ExifTool, ExifToolsGUI_Utils, ShellAPI, UnitLangResources, ExifToolsGui_Versions, ExifToolsGui_Data;

{$R *.dfm}

procedure TFrmCheckVersions.OpenUrl(Sender: TObject);
begin
  ShellExecute(0, 'Open', PWideChar(LvVersions.Items[LvVersions.ItemIndex].SubItems[0]), '', '', SW_SHOWNORMAL);
end;

procedure TFrmCheckVersions.SetupLvVersions;

  procedure AddItem(const Group, Method: integer; Url: string);
  var
    AnItem: TListItem;
  begin
    AnItem := LvVersions.Items.Add;
    AnItem.GroupID := Group;
    case Method of
      0: AnItem.Caption := 'Installer';
      1: AnItem.Caption := 'Zip';
    end;
    AnItem.SubItems.Add(Url);
    AnItem.SubItems.Add('-');
    AnItem.SubItems.Add('-');
  end;

begin
  LvVersions.Items.BeginUpdate;
  try
    LvVersions.Items.Clear;
    AddItem(0, 0, ReadResourceId(ETD_Home_Gui));
    AddItem(1, 1, ReadResourceId(ETD_Home_PH));
    AddItem(1, 0, ReadResourceId(ETD_Home_OBetz));
  finally
    LvVersions.Items.EndUpdate;
  end;
end;

procedure TFrmCheckVersions.GetVersions;
var
  Indx: integer;
  ETver: string;
  AnItem: TListItem;
  CrWait, CrNormal: HCURSOR;
begin
  CrWait := LoadCursor(0, IDC_WAIT);
  CrNormal := SetCursor(CrWait);
  LvVersions.Items.BeginUpdate;
  try

    ExecET('-ver', '', '', ETver);
    ETver := Trim(ETver);
    for Indx := 0 to LvVersions.Items.Count -1 do
    begin
      AnItem := LvVersions.Items[Indx];
      case LvVersions.Items[Indx].GroupID of
        0:  begin
              AnItem.SubItems[1] := GetFileVersionNumber(Application.ExeName);
            end;
        1:  begin
              AnItem.SubItems[1] := ETver;
            end;
      end;
// Avoid Needles calls when debugging
{$IFNDEF DEBUG}
      AnItem.SubItems[2] := GetLatestVersion(TETGuiProduct(Indx));
{$ENDIF}
      if (Pos(AnItem.SubItems[2], AnItem.SubItems[1]) = 1) then
        AnItem.ImageIndex := 0
      else
        AnItem.ImageIndex := -1;
    end;
  finally
    LvVersions.Items.EndUpdate;
    SetCursor(CrNormal);
  end;
end;

procedure TFrmCheckVersions.FormCreate(Sender: TObject);
begin
  SetupLvVersions;
end;

procedure TFrmCheckVersions.FormShow(Sender: TObject);
begin
  Left := FMain.Left + FMain.GUIBorderWidth + FMain.AdvPageFilelist.Left;
  Top := FMain.Top + FMain.GUIBorderHeight;
  GetVersions;
end;

procedure TFrmCheckVersions.LvVersionsDblClick(Sender: TObject);
begin
  OpenUrl(Sender);
end;

procedure TFrmCheckVersions.LvVersionsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  BtnOpenUrl.Enabled := Selected;
end;

procedure TFrmCheckVersions.BtnOpenUrlClick(Sender: TObject);
begin
  OpenUrl(Sender);
  ModalResult := mrNone; // Dont close form yet.
end;

end.
