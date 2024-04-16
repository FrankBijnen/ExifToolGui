program CheckCity;

uses
  Vcl.Forms,
  CheckCity1 in 'CheckCity1.pas' {FrmCheckCity};

{$R *.res}
{$R 'ExifToolsGui_Data.res' 'ExifToolsGui_Data.rc'}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmCheckCity, FrmCheckCity);
  Application.Run;
end.
