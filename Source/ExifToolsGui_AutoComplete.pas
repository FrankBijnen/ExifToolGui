unit ExifToolsGui_AutoComplete;

interface

uses
  WinApi.Windows, Winapi.ActiveX, Winapi.ShlObj, System.Classes;

const
  acAutoCorrect         = $0010;
  acAutoPopulate        = $0020;

type
  TAutoCompleteMode = (acDefault = $0000,
                       acNone = $0001,
                       acAutoAppend = $0002,
                       acAutoSuggest = $0003,
                       acAutoSuggestAppend = $0004);

  TAutoCompRec = record
    AcOptions:  word;
    AcString:   string;
    AcList:     TStringList;
    procedure SetAcList(const InAclist: TStringList); overload;
    procedure SetAcList(const InAclist: string); overload;
    procedure GetAcList(AList: TStrings); overload;
    function GetAcList: string; overload;
    procedure SetAcOptions(AcMode: TAutoCompleteMode;
                           AutoCorrect: boolean;
                           AutoPopulate: boolean);
    function GetAutoCompleteMode: TAutoCompleteMode;
    function GetAutoCorrect: boolean;
    function GetAutoPopulate: boolean;
    procedure GetAcOptions(var AcMode: TAutoCompleteMode;
                           var AutoCorrect: boolean;
                           var AutoPopulate: boolean);
    function ProcessResult(ALine: string): string;
  end;
  PAutoCompRec = ^TAutoCompRec;

  TAutoComplete = class(TInterfacedObject, IEnumString)
  private
    FCurrentList: TStringList;
    FAutoCompList: TStringList;
    FAutoComp: TAutoCompRec;
    FIndex: Integer;
    procedure SetAutoCompleteMode(AutoComplete: IAutoComplete;
                                  AutoCompleteMode: TAutoCompleteMode);
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
    procedure SetAutoCompOptions(AutoComplete: IAutoComplete;
                                 const [ref] AutoComp: TAutoCompRec);
  end;

  var
    AutoComplete: TAutoComplete;

implementation

uses
  System.SysUtils, ExifToolsGUI_Utils;

{ TAutoCompRec }

procedure TAutoCompRec.SetAcList(const InAcList: string);
begin
  AcString := InAcList;
  AcList := nil;
end;

procedure TAutoCompRec.SetAcList(const InAcList: TStringList);
begin
  AcList := InAclist;
  AcString := '';
end;

procedure TAutoCompRec.GetAcList(AList: TStrings);
begin
  if Assigned(AcList) then
    Alist.Text := AcList.Text
  else
    Alist.Text := GetAcList;
end;

function TAutoCompRec.GetAcList: string;
begin
  result := ReplaceAll(AcString, ['/n'], [#10],  [rfReplaceAll]);
end;

procedure TAutoCompRec.SetAcOptions(AcMode: TAutoCompleteMode;
                                    AutoCorrect: boolean;
                                    AutoPopulate: boolean);
begin
  AcOptions := Ord(AcMode);
  if (AutoCorrect) then
    AcOptions := AcOptions + acAutoCorrect;
  if (AutoPopulate) then
    AcOptions := AcOptions + acAutoPopulate;
end;

function TAutoCompRec.GetAutoCompleteMode: TAutoCompleteMode;
begin
  result := TAutoCompleteMode(AcOptions and $0f);
end;

function TAutoCompRec.GetAutoCorrect: boolean;
begin
  result := (AcOptions and acAutoCorrect) = acAutoCorrect;
end;

function TAutoCompRec.GetAutoPopulate: boolean;
begin
  result := (AcOptions and acAutoPopulate) = acAutoPopulate;
end;

procedure TAutoCompRec.GetAcOptions(var AcMode: TAutoCompleteMode;
                                    var AutoCorrect: boolean;
                                    var AutoPopulate: boolean);
begin
  AcMode := GetAutoCompleteMode;
  AutoCorrect := GetAutoCorrect;
  AutoPopulate := GetAutoPopulate;
end;

// Process entered line. Case correction, and auto populating
function TAutoCompRec.ProcessResult(ALine: string): string;
var
  AList: TStringList;
  P: integer;
begin
  result := Aline;

  AList := TStringList.Create;
  try
    AList.CaseSensitive := false;
    AList.Sorted := true;
    AList.Duplicates := TDuplicates.dupIgnore;
    GetAcList(AList);
    if (GetAutoCorrect) then
    begin
      P := AList.IndexOf(Aline);
      if (P > -1) then
        result := AList[P];
    end;

    if (GetAutoPopulate) then
    begin
      if(AcList <> nil) then
        AcList.Add(result)
      else
      begin
        AList.Add(result);
        AcString := ReplaceAll(Alist.Text, [#13#10, #10], ['/n','/n'], [rfReplaceAll]);
      end;
    end;
  finally
    AList.Free;
  end;
end;

{ TAutoComplete }

// See Vcl.ComCtrls.pas, for implementation of TAutoComplete
type
  TPtrArray = array[0..0] of Pointer;

constructor TAutoComplete.Create;
begin
  inherited Create;

  FAutoCompList := TStringList.Create;
  FAutoCompList.Sorted := true;
  FAutoCompList.Duplicates := TDuplicates.dupIgnore;

  FCurrentList := FAutoCompList;
end;

destructor TAutoComplete.Destroy;
begin
  FAutoCompList.Free;
  inherited Destroy;
end;

procedure TAutoComplete.SetAutoCompOptions(AutoComplete: IAutoComplete;
                                           const [ref] AutoComp: TAutoCompRec);
begin
  FAutoComp := AutoComp;
  FCurrentList := FAutoComp.AcList;
  if not Assigned(FCurrentList) then
  begin
    FAutoCompList.Text := FAutoComp.GetAcList;
    FCurrentList := FAutoCompList
  end;
  SetAutoCompleteMode(AutoComplete, FAutoComp.GetAutoCompleteMode);
end;

function TAutoComplete.Next(celt: Integer; out elt; pceltFetched: PLongint): HRESULT;
var
  I: Integer;
  W: WideString;
  Size: Integer;
begin
  I := 0;
  while (I < celt) and
        (FIndex < FCurrentList.Count) do
  begin
    W := FCurrentList[FIndex];
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
  if (FIndex + celt) <= FCurrentList.Count then
  begin
    Inc(FIndex, celt);
    Result := S_OK;
  end
  else
  begin
    FIndex := FCurrentList.Count;
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
  result.Enable(false); // Default disabled !
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
    case AutoCompleteMode of
      TAutoCompleteMode.acNone:
        Options := ACO_NONE;
      TAutoCompleteMode.acAutoAppend:
        Options := ACO_AUTOAPPEND or ACO_USETAB;
      TAutoCompleteMode.acAutoSuggest:
        Options := ACO_AUTOSUGGEST or ACO_USETAB;
      TAutoCompleteMode.acAutoSuggestAppend:
        Options := ACO_AUTOAPPEND or ACO_AUTOSUGGEST or ACO_USETAB;
      else
        exit;
    end;
    Auto2.SetOptions(Options);
    Auto2.Enable(false);  // Default disabled, Enabling must be done manually
  end
  else
    AutoComplete.Enable(false);
end;

initialization
  AutoComplete := TAutoComplete.Create;

finalization
  while (AutoComplete.RefCount > 0) do
    AutoComplete._Release;

end.
