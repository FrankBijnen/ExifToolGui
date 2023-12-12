unit UnitScaleForm;

interface

uses Vcl.Forms;

type TScaleForm = class(TForm)
protected
  procedure Loaded; override;
end;

implementation

uses System.SysUtils, Winapi.Windows, Winapi.ShellScaling, Vcl.Dialogs;

var DontScale: boolean;

procedure TScaleForm.Loaded;
begin
  if DontScale then
    Scaled := false;

  inherited;
end;

procedure Check(RC: Bool); overload;
begin
  if not RC then
    ShowMessage('SetProcessDpiAwarenessContext failed!' + #10 + SysErrorMessage(GetLastError));
end;

procedure Check(HR: HResult); overload;
begin
  if not (HR = S_OK) then
    ShowMessage('SetProcessDpiAwareness failed!' + #10 + SysErrorMessage(GetLastError));
end;

procedure Check(AValue: string); overload;
begin
  ShowMessage('Illegal parameter value for /HighDpi' + #10 + AValue);
end;

initialization
var
  DpiAware: string;
begin
  DontScale := FindCmdLineSwitch('DontScale', true);

  if CheckWin32Version(10, 0) and (TOSversion.Build >= 15063) then // Windows 10 1703 has 15063 as the Build number
  begin
    if (FindCmdLineSwitch('HighDPI', DpiAware, true)) then
    begin
      if SameText(DpiAware, '=UnAware') then
        Check(SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_UNAWARE))
      else if SameText(DpiAware, '=SystemAware') then
        Check(SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_SYSTEM_AWARE))
      else if SameText(DpiAware, '=PerMonitorAware') then
        Check(SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE))
      else if SameText(DpiAware, '=PerMonitorAwareV2') then
        Check(SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2))
      else if SameText(DpiAware, '=UnAwareGDIScaled') then
        Check(SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED))
      else
        Check(DpiAware);
    end
    else
      SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_SYSTEM_AWARE); // Dont check default
  end
  else if CheckWin32Version(6, 3) then  // Windows 8.1
  begin
    if (FindCmdLineSwitch('HighDPI', DpiAware, true)) then
    begin
      if SameText(DpiAware, '=UnAware') then
        Check(SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_DPI_UNAWARE))
      else if SameText(DpiAware, '=SystemAware') then
        Check(SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_SYSTEM_DPI_AWARE))
      else if SameText(DpiAware, '=PerMonitorAware') then
        Check(SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_PER_MONITOR_DPI_AWARE))
      else
        Check(DpiAware);
    end
    else
      SetProcessDpiAwareness(TProcessDpiAwareness.PROCESS_SYSTEM_DPI_AWARE);  // Dont check default
  end;
end;

end.
