unit UFrmAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TFrmAbout = class(TScaleForm)
    Panel1: TPanel;
    BtnOk: TBitBtn;
    Image1: TImage;
    LblVersion: TLabel;
    LblSource: TLabel;
    LblExifTool: TLabel;
    LblScreen: TLabel;
    LblExifToolHome: TLabel;
    LblLicense: TLabel;
    LblGNUGPL: TLabel;
    GrpLicense: TGroupBox;
    procedure FormShow(Sender: TObject);
    procedure LblOpenUrl(Sender: TObject);
    procedure LblUrlEnter(Sender: TObject);
    procedure LblUrlLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAbout: TFrmAbout;

implementation

uses
  Winapi.ShellAPI,
  Main, ExifTool, ExifToolsGUI_Utils, ExifToolsGui_ResourceStrings, ExifToolsGui_LossLess,  UnitLangResources;

{$R *.dfm}

procedure TFrmAbout.FormShow(Sender: TObject);
var
  Output: string;
  I, X, Y: integer;
begin
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  // These Labels dont have a styled font, copy it from a styled one.
  LblSource.Font.Assign(LblExifTool.Font);
  LblExifToolHome.Font.Assign(LblExifTool.Font);

  // Setup captions dynamically.
  LblVersion.Caption      := GetFileVersionNumberPlatForm(Application.ExeName) + #10 +
                              StringResource(ETD_Credits_GUI);
  LblSource.Caption       := StringResource(ETD_Home_Gui);
  LblExifToolHome.Caption := StringResource(ETD_Home_PH);
  LblExifTool.Caption     := StringResource(ETD_Credits_ET);
  LblGNUGPL.Caption       := StringResource(ETD_GNUGPL);

  if TExifTool.ExecET('-ver', '', '', Output) then
    LblExifTool.Caption := LblExifTool.Caption + ' ' + Output
  else
    LblExifTool.Caption := LblExifTool.Caption + ' ' + StrMISSING;

  X := Screen.Width;
  Y := Screen.Height;
  I := Screen.PixelsPerInch;
  LblScreen.Caption := Format(StrScreenResolution, [X, Y, I, ScaleDesignDpi(100)]);
end;

procedure TFrmAbout.LblUrlEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Color := clRed;
end;

procedure TFrmAbout.LblUrlLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Color := clWindowText;
end;

procedure TFrmAbout.LblOpenUrl(Sender: TObject);
begin
  ShellExecute(0, 'Open', PWideChar(TLabel(Sender).Caption), '', '', SW_SHOWNORMAL);
end;

end.
