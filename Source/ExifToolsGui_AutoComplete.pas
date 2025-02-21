unit ExifToolsGui_AutoComplete;

interface

uses
  WinApi.Windows, Winapi.ActiveX, Winapi.ShlObj, System.Classes;

type
  TAutoCompleteMode = (acNone, acAppend, acDropDown, acAppendDropDown);

  TAutoComplete = class(TInterfacedObject, IEnumString)
  private
    FLines: TStringList;
    FIndex: Integer;
  protected
    { IEnumString }
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumString): HResult; stdcall;
    { IEnumString end}
  public
    constructor Create;
    destructor Destroy; override;
    function InitAutoComplete(EditHandle: HWND): IAutoComplete;
    procedure SetAutoCompleteMode(AutoComplete: IAutoComplete;
                                  AutoCompleteMode: TAutoCompleteMode);
    property Lines: TStringList read FLines write FLines;
  end;

  var
    AutoComplete: TAutoComplete;

implementation

uses
  System.SysUtils;

// See Vcl.ComCtrls.pas, for implementation of TAutoComplete
type
  TPtrArray = array[0..0] of Pointer;

constructor TAutoComplete.Create;
begin
  inherited Create;

  FLines := TStringList.Create;
  FLines.Sorted := true;
  Flines.Duplicates := TDuplicates.dupIgnore;
end;

destructor TAutoComplete.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

function TAutoComplete.Next(celt: Integer; out elt; pceltFetched: PLongint): HRESULT;
var
  I: Integer;
  W: WideString;
  Size: Integer;
begin
  I := 0;
  while (I < celt) and
        (FIndex < FLines.Count) do
  begin
    W := FLines[FIndex];
    Size := Length(W) * SizeOf(WideChar);
    TPtrArray(elt)[I] := CoTaskMemAlloc(Size + SizeOf(WideChar));
    FillChar(TPtrArray(elt)[I]^, Size + SizeOf(WideChar), 0);
    CopyMemory(TPtrArray(elt)[I], PWideString(W), Size);
    Inc(I);
    Inc(FIndex);
  end;
  if pceltFetched <> nil then
    pceltFetched^ := I;
  if I = celt then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TAutoComplete.Skip(celt: Longint): HResult;
begin
  if (FIndex + celt) <= FLines.Count then
  begin
    Inc(FIndex, celt);
    Result := S_OK;
  end
  else
  begin
    FIndex := FLines.Count;
    Result := S_FALSE;
  end;
end;

function TAutoComplete.Reset: HResult;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TAutoComplete.Clone(out enm: IEnumString): HResult;
begin
  Result := E_NOTIMPL;
  enm := nil;
end;

function TAutoComplete.InitAutoComplete(EditHandle: HWND): IAutoComplete;
begin
  CoCreateInstance(CLSID_AutoComplete, nil, CLSCTX_INPROC_SERVER, IAutoComplete, result);
  result.Init(EditHandle, Self, nil, nil);
end;

procedure TAutoComplete.SetAutoCompleteMode(AutoComplete: IAutoComplete;
                                            AutoCompleteMode: TAutoCompleteMode);
var
  Options: DWORD;
  Auto2: IAutoComplete2;
begin
  if (AutoComplete <> nil) and
     (Supports(AutoComplete, IAutoComplete2, Auto2)) then
  begin
    Auto2.SetOptions(0);
    case AutoCompleteMode of
      TAutoCompleteMode.acNone:
        Options := ACO_NONE;
      TAutoCompleteMode.acAppend:
        Options := ACO_AUTOAPPEND or ACO_USETAB;
      TAutoCompleteMode.acDropDown:
        Options := ACO_AUTOSUGGEST or ACO_USETAB;
      TAutoCompleteMode.acAppendDropDown:
        Options := ACO_AUTOAPPEND or ACO_AUTOSUGGEST or ACO_USETAB;
      else
        exit;
    end;
    Auto2.SetOptions(Options);
  end
  else
    Auto2.Enable(AutoCompleteMode <> TAutoCompleteMode.acNone);
end;

initialization
  AutoComplete := TAutoComplete.Create;

finalization
  while (AutoComplete.RefCount > 0) do
    AutoComplete._Release;

end.
