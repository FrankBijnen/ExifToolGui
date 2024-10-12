program CheckCity;

{$R 'ExifToolsGui_Files.res' 'Resources\ExifToolsGui_Files.rc'}

uses
  Vcl.Forms,
  CheckCity1 in 'CheckCity1.pas' {FrmCheckCity};

{$R *.res}
{$R 'ExifToolsGui_Strings.res' 'ExifToolsGui_Strings.rc'}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmCheckCity, FrmCheckCity);
  Application.Run;
end.
