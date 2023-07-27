unit UFrmStyle;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.StdCtrls, Vcl.Buttons, System.Classes,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Forms;

type
  TFrmStyle = class(TForm)
    Panel1: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    LstStyles: TListBox;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LstStylesClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadStyles;
    procedure RequestClose;
    procedure SetNewStyle(Style: string);

  public
    { Public declarations }
  var
    CurPath: string;

  var
    CurStyle: string;
  end;

var
  FrmStyle: TFrmStyle;

implementation

uses
  Main,
  MainDef,
  Vcl.Themes,
  Vcl.Styles;

{$R *.dfm}

procedure TFrmStyle.SetNewStyle(Style: string);
begin
  GUIsettings.GuiStyle := Style;
  TStyleManager.TrySetStyle(GUIsettings.GuiStyle, false);
  Fmain.SetGuiColor;

  if (GUIsettings.GuiStyle = 'Windows') then // AV unregistering style hooks
    exit;

  Application.ProcessMessages;
  SetForegroundWindow(Self.Handle);
end;

procedure TFrmStyle.RequestClose;
begin
  Close;  // First close this form, so items can be added again to the shellist
  Fmain.ShellTree.Path := CurPath; //restore path
end;

procedure TFrmStyle.FormShow(Sender: TObject);
var Indx: integer;
begin
  Indx := LstStyles.Items.IndexOf(GUIsettings.GuiStyle);
  if (Indx > -1) then
    LstStyles.ItemIndex := Indx;
end;

procedure TFrmStyle.LoadStyles;
var
  Indx: integer;
begin
  LstStyles.Items.clear;
  for Indx := 0 to high(TStyleManager.StyleNames) do
    LstStyles.Items.Add(TStyleManager.StyleNames[Indx])
end;

procedure TFrmStyle.LstStylesClick(Sender: TObject);
begin
  SetNewStyle(LstStyles.Items[LstStyles.ItemIndex]);
end;

procedure TFrmStyle.BtnOkClick(Sender: TObject);
begin
  RequestClose;
end;

procedure TFrmStyle.BtnCancelClick(Sender: TObject);
begin
  // Restore old style
  SetNewStyle(CurStyle);

  RequestClose;
end;

procedure TFrmStyle.FormCreate(Sender: TObject);
begin
  LoadStyles;
end;

end.
