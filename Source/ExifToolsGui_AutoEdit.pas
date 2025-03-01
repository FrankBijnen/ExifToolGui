unit ExifToolsGui_AutoEdit;

interface

uses
  System.Classes, System.Sysutils, Winapi.ShlObj, Winapi.Windows, Winapi.Messages,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls, ExifToolsGui_AutoComplete;

const
  IID_WordSelEdit = '{60D05E0B-40F2-439A-BE00-83B3084D789A}';
  IID_AutoCompleteEdit = '{D68C7C26-11A1-4626-B39D-AD0485ECF001}';

type
  TSelDirection = (sdLeft, sdRight);

  IWordSelEdit = interface
    [IID_WordSelEdit]
    procedure SetSelDirection(ASelDirection: TSelDirection);
    function GetSelDirection: TSelDirection;
  end;

  TWordSelEdit = class(TInterfacedObject, IWordSelEdit)
  private
    FSelDirection: TSelDirection;
  public
    procedure SetSelDirection(ASelDirection: TSelDirection);
    function GetSelDirection: TSelDirection;
  end;

  IAutoCompleteEdit = interface
    [IID_AutoCompleteEdit]
    procedure EnableAutoComplete(Enable: boolean);
    procedure SetAutoComplete(AHandle: HWND);
    procedure SetAutoCompleteMode(Value: TAutoCompleteMode);
    procedure SetAutoCompleteList; overload;
    procedure SetAutoCompleteList(const [ref] Value: TStringList); overload;
    function GetAutoCompleteMode: TAutoCompleteMode;
  end;

  TAutoCompleteEdit = class(TInterfacedObject, IAutoCompleteEdit)
    IAutoComplete: IAutoComplete;
    FHandle: HWND;
    FAutoCompleteMode: TAutoCompleteMode;
    FAutoCompleteList: TStringList;
    FEnableAutoComplete: boolean;
    procedure EnableAutoComplete(Enable: boolean);
    procedure SetAutoComplete(AHandle: HWND);
    procedure SetAutoCompleteMode(Value: TAutoCompleteMode);
    procedure SetAutoCompleteList; overload;
    procedure SetAutoCompleteList(const [ref] Value: TStringList); overload;
    function GetAutoCompleteMode: TAutoCompleteMode;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TMemo = class(Vcl.StdCtrls.TMemo, IWordSelEdit)
  private
    FWordSelEdit: IWordSelEdit;
  public
    constructor Create(AOwner: TComponent); override;
    property WordSelEdit: IWordSelEdit read FWordSelEdit implements IWordSelEdit;
  end;

  TEdit = class(Vcl.StdCtrls.TEdit, IWordSelEdit, IAutoCompleteEdit)
  private
    FWordSelEdit: IWordSelEdit;
    FAutoCompleteEdit: IAutoCompleteEdit;
  protected
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    property WordSelEdit: IWordSelEdit read FWordSelEdit implements IWordSelEdit;
    property AutoCompleteEdit: IAutoCompleteEdit read FAutoCompleteEdit implements IAutoCompleteEdit;
  end;

  TlabeledEdit = class(Vcl.ExtCtrls.TlabeledEdit, IWordSelEdit, IAutoCompleteEdit)
  private
    FWordSelEdit: IWordSelEdit;
    FAutoCompleteEdit: IAutoCompleteEdit;
  protected
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    property WordSelEdit: IWordSelEdit read FWordSelEdit implements IWordSelEdit;
    property AutoCompleteEdit: IAutoCompleteEdit read FAutoCompleteEdit implements IAutoCompleteEdit;
  end;

  // Shif/Ctrl Cursor
  procedure PrevWord(const CustomEdit: TCustomEdit; const SkipChars: TSysCharSet; const UseSel: boolean);
  procedure NextWord(const CustomEdit: TCustomEdit; const SkipChars: TSysCharSet; const UseSel: boolean);

implementation

// Shif/Ctrl Cursor Left
procedure PrevWord(const CustomEdit: TCustomEdit; const SkipChars: TSysCharSet; const UseSel: boolean);
var
  NewS, OldS, OldSel: integer;
  SelDir: TSelDirection;
  T: string;
begin
  OldSel := CustomEdit.SelLength;

  SelDir := TSelDirection.sdLeft;
  if (Supports(CustomEdit, IWordSelEdit)) then
  begin
    if (OldSel = 0) then
      (CustomEdit as IWordSelEdit).SetSelDirection(SelDir);
    SelDir := (CustomEdit as IWordSelEdit).GetSelDirection;
  end;

  OldS := CustomEdit.SelStart;
  if (SelDir = TSelDirection.sdLeft) then
    NewS := OldS
  else
    NewS := OldS + CustomEdit.SelLength;
  T := CustomEdit.Text;
  while (NewS > 0) and
        (CharInSet(T[NewS], SkipChars)) do
    Dec(NewS);
  while (NewS > 0) and
        not (CharInSet(T[NewS], SkipChars)) do
    Dec(NewS);
  CustomEdit.SelStart := NewS;

  if (UseSel) then
  begin
    if (SelDir = TSelDirection.sdLeft) then
      CustomEdit.SelLength := OldSel + (OldS - NewS)
    else
      CustomEdit.SelLength := OldS - NewS;
  end
  else
    CustomEdit.SelLength := 0;
end;

// Shif/Ctrl Cursor Right
procedure NextWord(const CustomEdit: TCustomEdit; const SkipChars: TSysCharSet; const UseSel: boolean);
var
  OldS, NewS, OldSel: integer;
  L: integer;
  SelDir: TSelDirection;
  T: string;
begin
  OldSel := CustomEdit.SelLength;

  SelDir := TSelDirection.sdRight;
  if (Supports(CustomEdit, IWordSelEdit)) then
  begin
    if (OldSel = 0) then
      (CustomEdit as IWordSelEdit).SetSelDirection(SelDir);
    SelDir := (CustomEdit as IWordSelEdit).GetSelDirection;
  end;

  OldS := CustomEdit.SelStart;
  if (SelDir = TSelDirection.sdRight) then
    NewS := OldS + CustomEdit.SelLength
  else
    NewS := OldS;

  T := CustomEdit.Text;
  L := Length(T);
  while (NewS < L) and
        not (CharInSet(T[NewS +1], SkipChars)) do
    Inc(NewS);
  while (NewS < L) and
        (CharInSet(T[NewS +1], SkipChars)) do
    Inc(NewS);
  CustomEdit.SelStart := NewS;

  if (UseSel) then
  begin
    if (SelDir = TSelDirection.sdRight) then
      CustomEdit.SelLength := OldS - NewS
    else
      CustomEdit.SelLength := OldSel - (NewS - Olds);
  end
  else
    CustomEdit.SelLength := 0;
end;

{ TWordSelEdit }
procedure TWordSelEdit.SetSelDirection(ASelDirection: TSelDirection);
begin
  FSelDirection := ASelDirection;
end;

function TWordSelEdit.GetSelDirection: TSelDirection;
begin
  result := FSelDirection;
end;

{ TAutoCompleteEdit }
constructor TAutoCompleteEdit.Create;
begin
  inherited Create;

  FHandle := 0;
  FAutoCompleteMode := TAutoCompleteMode.acNone;
  IAutoComplete := nil;
  FEnableAutoComplete := false;
  FAutoCompleteList := nil;
end;

destructor TAutoCompleteEdit.Destroy;
begin
  EnableAutoComplete(false);
  IAutoComplete := nil;

  inherited Destroy;
end;

procedure TAutoCompleteEdit.EnableAutoComplete(Enable: boolean);
begin
  if (FEnableAutoComplete <> Enable) then
  begin
    FEnableAutoComplete := Enable;
    if (IAutoComplete <> nil) then
      IAutoComplete.Enable(FEnableAutoComplete);
  end;
end;

procedure TAutoCompleteEdit.SetAutoComplete(AHandle: HWND);
begin
  if (AHandle <> 0) then
  begin
    FHandle := AHandle;
    IAutoComplete := AutoComplete.InitAutoComplete(FHandle);
    AutoComplete.SetAutoCompleteMode(IAutoComplete, FAutoCompleteMode);
  end;
end;

procedure TAutoCompleteEdit.SetAutoCompleteMode(Value: TAutoCompleteMode);
begin
  if (IAutoComplete <> nil) and
     (FAutoCompleteMode <> Value) then
  begin
    FAutoCompleteMode := Value;
    AutoComplete.SetAutoCompleteMode(IAutoComplete, FAutoCompleteMode);
    EnableAutoComplete(FAutoCompleteMode <> TAutoCompleteMode.acNone);
  end;
end;

procedure TAutoCompleteEdit.SetAutoCompleteList(const [ref] Value: TStringList);
begin
  FAutoCompleteList := Value;
  SetAutoCompleteList;
end;

procedure TAutoCompleteEdit.SetAutoCompleteList;
begin
  AutoComplete.SetLines(FAutoCompleteList);
end;

function TAutoCompleteEdit.GetAutoCompleteMode: TAutoCompleteMode;
begin
  result := FAutoCompleteMode;
end;

{ TMemo }
constructor TMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWordSelEdit := TWordSelEdit.Create;
end;

{ TlabeledEdit }
 constructor TlabeledEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWordSelEdit := TWordSelEdit.Create;
  FAutoCompleteEdit := TAutoCompleteEdit.Create;
end;

procedure TlabeledEdit.CreateWnd;
begin
  inherited CreateWnd;
  FAutoCompleteEdit.SetAutoComplete(Handle);
end;

procedure TlabeledEdit.CMEnter(var Message: TCMEnter);
begin
  FAutoCompleteEdit.SetAutoCompleteList;

  inherited;
end;

{ TEdit }
 constructor TEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWordSelEdit := TWordSelEdit.Create;
  FAutoCompleteEdit := TAutoCompleteEdit.Create;
end;

procedure TEdit.CreateWnd;
begin
  inherited CreateWnd;
  FAutoCompleteEdit.SetAutoComplete(Handle);
end;

procedure TEdit.CMEnter(var Message: TCMEnter);
begin
  FAutoCompleteEdit.SetAutoCompleteList;

  inherited;
end;

end.
