unit sdListIndex;

interface

type
{$IFDEF VER350}
  TSdListIndex = integer;     // Up until Delphi 11 uses integer
{$ELSE}
  TSdListIndex = NativeInt;   // Delphi 12 and up uses NativeInt in TList and TObjectList
{$ENDIF}

implementation

end.
