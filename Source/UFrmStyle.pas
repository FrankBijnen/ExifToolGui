unit UFrmStyle;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.StdCtrls, Vcl.Buttons, System.Classes,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Forms, UnitScaleForm;

const
  cSystemStyleName = 'Windows';

type
  TFrmStyle = class(TScaleForm)
    Panel1: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    LstStyles: TListBox;
    StyleTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure StyleTimerTimer(Sender: TObject);
    procedure LstStylesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LstStylesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    procedure LoadStyles;
    procedure RequestClose;
    procedure SetNewStyle(Style: string);
    procedure ResetTimer;
  public
    { Public declarations }
    var
      CurPath: string;
      CurStyle: string;
  end;

var
  FrmStyle: TFrmStyle;

implementation

{$R *.dfm}

uses
  Main,
  MainDef,
  ExifToolsGUI_Utils,
  Vcl.Themes,
  Vcl.Styles;

procedure TFrmStyle.SetNewStyle(Style: string);
begin
  LstStyles.Enabled := false;
  try
    GUIsettings.GuiStyle := Style;
    TStyleManager.TrySetStyle(GUIsettings.GuiStyle, false);
    FMain.GetColorsFromStyle;
  finally
    LstStyles.Enabled := true;
    ProcessMessages;
    LstStyles.SetFocus;
  end;
end;

procedure TFrmStyle.StyleTimerTimer(Sender: TObject);
begin
  StyleTimer.Enabled := false;
  SetNewStyle(LstStyles.Items[LstStyles.ItemIndex]);
end;

procedure TFrmStyle.ResetTimer;
begin
  StyleTimer.Enabled := false;
  StyleTimer.Enabled := true;
end;

procedure TFrmStyle.RequestClose;
begin
  Close; // First close this form, so items can be added again to the shellist

  FMain.ShellTree.Path := CurPath; // restore path
end;

procedure TFrmStyle.FormShow(Sender: TObject);
var
  Indx: integer;
begin
  StyleTimer.Enabled := false;

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

procedure TFrmStyle.LstStylesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  ResetTimer;
end;

procedure TFrmStyle.LstStylesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ResetTimer;
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
