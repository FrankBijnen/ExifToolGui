unit ExifToolsGui_ComboBox;

// Allow OwnerDraw with edit box

interface

uses
  Winapi.Windows, Vcl.Controls, Vcl.StdCtrls;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  public
    procedure CreateParams(var Params: TCreateParams); override;
  end;


implementation

procedure TComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Assigned(OnDrawItem) then
    Params.Style := Params.Style or CBS_OWNERDRAWFIXED
end;

end.
