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

uses ExifTool, ExifToolsGui_LossLess, ShellAPI;

{$R *.dfm}

function GetFileVersionNumber(Fname: string; vShort: boolean): string;
var
  v, verInfoSize, verValueSize: longword;
  minor: Word;
  verInfo: pointer;
  VerValue: PVSFixedFileInfo;
begin
  if vShort then
  begin
    v := GetFileVersion(Fname);
    minor := v and $FFFF;
    result := IntToStr(v shr 16) + '.';
    if minor < 10 then
      result := result + '0';
    result := result + IntToStr(minor);
  end
  else
  begin
    result := '-.-.-.-';
    verInfoSize := GetFileVersionInfoSize(@Fname[1], v);
    if verInfoSize = 0 then
      exit;
    GetMem(verInfo, verInfoSize);
    GetFileVersionInfo(@Fname[1], 0, verInfoSize, verInfo);
    VerQueryValue(verInfo, '\', pointer(VerValue), verValueSize);
    with VerValue^ do
    begin
      result := IntToStr(dwFileVersionMS shr 16);
      result := result + '.' + IntToStr(dwFileVersionMS and $FFFF);
      result := result + '.' + IntToStr(dwFileVersionLS shr 16);
      result := result + '.' + IntToStr(dwFileVersionLS and $FFFF);
      if (dwFileFlags and VS_FF_PRERELEASE <> 0) then
        result := result + ' Pre.';
    end;
    FreeMem(verInfo, verInfoSize);
  end;
end;

procedure TFrmAbout.FormShow(Sender: TObject);
var
  Output: string;
  I, X, Y: smallint;
begin
  // These Labels dont have a styled font, copy it from a styled one.
  LblSource.Font.Assign(LblExifTool.Font);
  LblForum.Font.Assign(LblExifTool.Font);

  // Setup captions dynamically.
  LblVersion.Caption := Application.Title + ' v' +
    GetFileVersionNumber(Application.ExeName, false) +
{$IFDEF WIN32}
    ' 32 Bits' +
{$ENDIF}
{$IFDEF WIN64}
    ' 64 Bits' +
{$ENDIF}
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
