unit UnitLangOverride;

interface

uses
  Winapi.Windows;

function LoadNewResourceModule(Locale: string): HINST;

implementation

uses
  System.SysUtils;

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
var
  FileName: array [0..260] of char;
  DllName: string;
begin
  GetModuleFileName(HInstance, FileName, SizeOf(FileName));
  DllName := ChangeFileExt(Filename, '.' + Locale);
  result := LoadLibraryEx(PChar(DllName), 0, LOAD_LIBRARY_AS_DATAFILE);
  if result <> 0 then
    result := SetResourceHInstance(result);
end;

procedure LoadOverrideLanguage;
var
  Locale: string;
begin
  if (FindCmdLineSwitch('LangOverride', Locale, true)) then
    LoadNewResourceModule(Copy(Locale, 2)); // Skip =
end;

initialization
  LoadOverrideLanguage;

end.

