unit ExifToolsGui_AutoEdit;

interface

uses
  System.Classes, System.Sysutils, Winapi.ShlObj, Vcl.StdCtrls, Vcl.ExtCtrls, ExifToolsGui_AutoComplete;

type
  TlabeledEdit = class(Vcl.ExtCtrls.TlabeledEdit, IShiftEdit)
  private
    FSelDirection: TSelDirection;
  public
    procedure SetSelDirection(ASelDirection: TSelDirection);
    function GetSelDirection: TSelDirection;
  end;

  TMemo = class(Vcl.StdCtrls.TMemo, IShiftEdit)
  private
    FSelDirection: TSelDirection;
  public
    procedure SetSelDirection(ASelDirection: TSelDirection);
    function GetSelDirection: TSelDirection;
  end;

  TEdit = class(Vcl.StdCtrls.TEdit, IShiftEdit)
  private
    FAutoCompleteMode: TAutoCompleteMode;
    IAutoComplete: IAutoComplete;
    FEnableAutoComplete: boolean;
    FSelDirection: TSelDirection;
  protected
    procedure CreateWnd; override;
    procedure EnableAutoComplete(Enable: boolean);
    procedure SetAutoComplete;
    procedure SetAutoCompleteMode(Value: TAutoCompleteMode);
  public
    procedure SetSelDirection(ASelDirection: TSelDirection);
    function GetSelDirection: TSelDirection;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property AutoCompleteMode: TAutoCompleteMode read FAutoCompleteMode write SetAutoCompleteMode;
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
  if (Supports(CustomEdit, IshiftEdit)) then
  begin
    if (OldSel = 0) then
      (CustomEdit as IshiftEdit).SetSelDirection(SelDir);
    SelDir := (CustomEdit as IshiftEdit).GetSelDirection;
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
  if (Supports(CustomEdit, IshiftEdit)) then
  begin
    if (OldSel = 0) then
      (CustomEdit as IshiftEdit).SetSelDirection(SelDir);
    SelDir := (CustomEdit as IshiftEdit).GetSelDirection;
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

procedure TLabeledEdit.SetSelDirection(ASelDirection: TSelDirection);
begin
  FSelDirection := ASelDirection;
end;

function TLabeledEdit.GetSelDirection: TSelDirection;
begin
  result := FSelDirection;
end;

procedure TMemo.SetSelDirection(ASelDirection: TSelDirection);
begin
  FSelDirection := ASelDirection;
end;

function TMemo.GetSelDirection: TSelDirection;
begin
  result := FSelDirection;
end;

constructor TEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FAutoCompleteMode := TAutoCompleteMode.acNone;
  IAutoComplete := nil;
  FEnableAutoComplete := false;
end;

destructor TEdit.Destroy;
begin
  EnableAutoComplete(false);
  IAutoComplete := nil;

  inherited Destroy;
end;

procedure TEdit.CreateWnd;
begin
  inherited CreateWnd;

  SetAutoComplete;
end;

procedure TEdit.EnableAutoComplete(Enable: boolean);
begin
  if (FEnableAutoComplete <> Enable) then
  begin
    FEnableAutoComplete := Enable;
    if (IAutoComplete <> nil) then
      IAutoComplete.Enable(FEnableAutoComplete);
  end;
end;

procedure TEdit.SetAutoComplete;
begin
  if (HandleAllocated) then
  begin
    IAutoComplete := AutoComplete.InitAutoComplete(Handle);
    AutoComplete.SetAutoCompleteMode(IAutoComplete, FAutoCompleteMode);
  end;
end;

procedure TEdit.SetAutoCompleteMode(Value: TAutoCompleteMode);
begin
  if (IAutoComplete <> nil) and
     (FAutoCompleteMode <> Value) then
  begin
    FAutoCompleteMode := Value;
    AutoComplete.SetAutoCompleteMode(IAutoComplete, FAutoCompleteMode);
    EnableAutoComplete(FAutoCompleteMode <> TAutoCompleteMode.acNone);
  end;
end;

procedure TEdit.SetSelDirection(ASelDirection: TSelDirection);
begin
  FSelDirection := ASelDirection;
end;

function TEdit.GetSelDirection: TSelDirection;
begin
  result := FSelDirection;
end;

end.
