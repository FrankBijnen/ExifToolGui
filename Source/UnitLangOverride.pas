unit UnitLangOverride;

interface

procedure SetLanguage(const Locale: string);

implementation

uses
  System.SysUtils,
  Winapi.Windows,
  Vcl.Forms;

function SetResourceHInstance(NewInstance: HINST): HINST;
var
  CurModule: PLibModule;
begin
  CurModule := LibModuleList;
  Result := 0;
  while CurModule <> nil do
  begin
    if CurModule.Instance = HInstance then
    begin
      if CurModule.ResInstance <> CurModule.Instance then
        FreeLibrary(CurModule.ResInstance);
      CurModule.ResInstance := NewInstance;
      Result := NewInstance;
      Exit;
    end;
    CurModule := CurModule.Next;
  end;
end;

function LoadNewResourceModule(Locale: string): HINST;
begin
  // First search for Basename
  result := LoadLibraryEx(PChar(ChangeFileExt(Application.Title, '.' + Locale)),
                          0,
                          LOAD_LIBRARY_AS_DATAFILE);
  // Not found, search for exename
  if (result = 0) then
    result := LoadLibraryEx(PChar(ChangeFileExt(Application.ExeName, '.' + Locale)),
                            0,
                            LOAD_LIBRARY_AS_DATAFILE);

  if result <> 0 then
    result := SetResourceHInstance(result);
end;

procedure SetLanguage(const Locale: string);
begin
  LoadNewResourceModule(Locale); // This will not reload Resourcestrings!
  ResStringCleanupCache;         // That's why we need this.
end;

initialization
var
  Locale: string;
begin
  if (FindCmdLineSwitch('LangOverride', Locale, true)) then
    SetLanguage(Copy(Locale, 2));
end;

end.

