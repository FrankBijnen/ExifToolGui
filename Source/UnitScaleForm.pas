unit UnitScaleForm;

// Allows Forms to scale by using command line parameter /Scale.
// Change the declaration of the form from TSomeForm = Class(TForm) to TSomeForm = Class(TScaleForm)
// and add this unit to the uses.

interface

uses Vcl.Forms;

type TScaleForm = class(TForm)
protected
  procedure Loaded; override;
end;

implementation

uses System.SysUtils;

var Scale: boolean;

// Scaling has to be set before 'Loaded'
procedure TScaleForm.Loaded;
begin
  Scaled := Scale;

  inherited;
end;

initialization
begin
  Scale := FindCmdLineSwitch('Scale', true);
end;

end.
