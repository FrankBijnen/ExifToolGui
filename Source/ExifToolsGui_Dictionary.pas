unit ExifToolsGui_Dictionary;

interface

uses
  System.Generics.Collections;

type
  TDictionary<K,V> = class(System.Generics.Collections.TDictionary<K,V>)
  public
    function AddLowerCase(const Key: K; const Value: V): boolean;
  end;
  TStringDict = TDictionary<string, string>;

implementation

uses
  System.SysUtils;

function TDictionary<K,V>.AddLowerCase(const Key: K; const Value: V): boolean;
var
  LowerKey: K;
begin
  LowerKey := Key;
  case GetTypeKind(K) of
    tkUString: PUnicodeString(@LowerKey)^ := LowerCase(PUnicodeString(@Key)^); // Length will not change
  end;
  result := not ContainsKey(LowerKey);
  if result then
    Add(LowerKey, Value);
end;

end.
