unit Vcl.Shell.RegShellCtrls;

interface

uses
  Vcl.Shell.ShellConsts, Vcl.Shell.ShellCtrls,
  System.SysUtils, System.Classes;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Shell Controls', [TShellListView]);
  RegisterComponents('Shell Controls', [TShellTreeView]);
  RegisterComponents('Shell Controls', [TShellChangeNotifier]);
end;

end.
