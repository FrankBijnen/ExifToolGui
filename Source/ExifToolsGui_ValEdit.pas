unit ExifToolsGui_ValEdit;

// Allow all Ctrl+Key events to be used by the app.
// If the app eventhandler set Key to 0 disables standard processing

interface

uses System.Classes, Vcl.ValEdit, Vcl.Controls;

type

  TValueListEditor = class(Vcl.ValEdit.TValueListEditor)
  private
    FOnCtrlKeyDown: TkeyEvent;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    property OnCtrlKeyDown: TkeyEvent read FOnCtrlKeyDown write FOnCtrlKeyDown;
  end;

implementation

uses Winapi.Windows;

procedure TValueListEditor.KeyDown(var Key: Word; Shift: TShiftState);
begin

  if (Assigned(FOnCtrlKeyDown)) and
     (Shift = [ssCtrl]) then
    FOnCtrlKeyDown(Self, Key, Shift);

  inherited KeyDown(Key, Shift);
end;


end.
