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
    LblForum: TLabel;
    LblExifTool: TLabel;
    LblScreen: TLabel;
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

uses ExifTool, ExifToolsGUI_Utils, ExifToolsGui_LossLess, ShellAPI;

{$R *.dfm}

procedure TFrmAbout.FormShow(Sender: TObject);
var
  Output: string;
  I, X, Y: smallint;
begin
  // These Labels dont have a styled font, copy it from a styled one.
  LblSource.Font.Assign(LblExifTool.Font);
  LblForum.Font.Assign(LblExifTool.Font);

  // Setup captions dynamically.
  LblVersion.Caption := GetFileVersionNumber(Application.ExeName) +
    ' by Bogdan Hrastnik.' + #10 +
    'Adapted for RAD11 by Frank B';
  LblSource.Caption := 'https://github.com/FrankBijnen/ExifToolGui';
  LblForum.Caption := 'https://exiftool.org/forum/index.php';
  LblExifTool.Caption := 'ExifTool by Phil Harvey ';
  if ExecET('-ver', '', '', Output) then
    LblExifTool.Caption := LblExifTool.Caption + Output
  else
    LblExifTool.Caption := LblExifTool.Caption + 'MISSING!';

  X := Screen.Width;
  Y := Screen.Height;
  I := Screen.PixelsPerInch;
  LblScreen.Caption := 'Screen resolution: ' + IntToStr(X) + 'x' + IntToStr(Y) + ' at ' + IntToStr(I) + 'DPI, ' +
                       'Scaled: ' + IntToStr(ScaleDesignDpi(100)) + '%';
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
