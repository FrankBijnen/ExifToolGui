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
    procedure InstallAutoComplete(AHandle: HWND);
    procedure EnableAutoComplete(Enable: boolean);
    procedure UpdateAutoComplete;
    procedure SetAutoCompOptions(const [ref] Value: TAutoCompRec);
    function GetAutoCompleteMode: TAutoCompleteMode;
  end;

  TAutoCompleteEdit = class(TInterfacedObject, IAutoCompleteEdit)
    IAutoComplete: IAutoComplete;
    FEnabled: boolean;
    FHandle: HWND;
    FAutoComp: TAutoCompRec;
    procedure InstallAutoComplete(AHandle: HWND);
    procedure EnableAutoComplete(Enable: boolean);
    procedure UpdateAutoComplete;
    procedure SetAutoCompOptions(const [ref] Value: TAutoCompRec);
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

  TLabeledEdit = class(Vcl.ExtCtrls.TLabeledEdit, IWordSelEdit, IAutoCompleteEdit)
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

  // Shift/Ctrl Cursor
  procedure PrevWord(const CustomEdit: TCustomEdit; const SkipChars: TSysCharSet; const UseSel: boolean);
  procedure NextWord(const CustomEdit: TCustomEdit; const SkipChars: TSysCharSet; const UseSel: boolean);

implementation

// Shift/Ctrl Cursor Left
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

// Shift/Ctrl Cursor Right
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
  IAutoComplete := nil;
  FAutoComp.AcOptions := 0;
  FAutoComp.AcList := nil;
  FAutoComp.AcString := '';
  FEnabled := false;
end;

destructor TAutoCompleteEdit.Destroy;
begin
  EnableAutoComplete(false);
  IAutoComplete := nil;

  inherited Destroy;
end;

procedure TAutoCompleteEdit.EnableAutoComplete(Enable: boolean);
begin
  if (IAutoComplete <> nil) then
  begin
    if (FEnabled <> Enable) then
    begin
      FEnabled := Enable;
      IAutoComplete.Enable(FEnabled);
    end;
  end
  else
    FEnabled := false;
end;

procedure TAutoCompleteEdit.InstallAutoComplete(AHandle: HWND);
begin
  if (AHandle <> 0) then
  begin
    FHandle := AHandle;
    IAutoComplete := AutoComplete.InitAutoComplete(FHandle);
    FEnabled := false;
  end;
end;

procedure TAutoCompleteEdit.UpdateAutoComplete;
begin
  if (IAutoComplete <> nil) then
    AutoComplete.SetAutoCompOptions(IAutoComplete, FAutoComp);
  FEnabled := false;
end;

procedure TAutoCompleteEdit.SetAutoCompOptions(const [ref] Value: TAutoCompRec);
begin
  FAutoComp := Value;
  UpdateAutoComplete;
end;

function TAutoCompleteEdit.GetAutoCompleteMode: TAutoCompleteMode;
begin
  result := FAutoComp.GetAutoCompleteMode;
end;

{ TMemo }
constructor TMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWordSelEdit := TWordSelEdit.Create;
end;

{ TlabeledEdit }
 constructor TLabeledEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWordSelEdit := TWordSelEdit.Create;
  FAutoCompleteEdit := TAutoCompleteEdit.Create;
end;

procedure TLabeledEdit.CreateWnd;
begin
  inherited CreateWnd;
  FAutoCompleteEdit.InstallAutoComplete(Handle);
end;

procedure TLabeledEdit.CMEnter(var Message: TCMEnter);
begin
  FAutoCompleteEdit.UpdateAutoComplete;
  FAutoCompleteEdit.EnableAutoComplete(FAutoCompleteEdit.GetAutoCompleteMode > TAutoCompleteMode.acNone);

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
  FAutoCompleteEdit.InstallAutoComplete(Handle);
end;

procedure TEdit.CMEnter(var Message: TCMEnter);
begin
  FAutoCompleteEdit.UpdateAutoComplete;
  FAutoCompleteEdit.EnableAutoComplete(FAutoCompleteEdit.GetAutoCompleteMode > TAutoCompleteMode.acNone);

  inherited;
end;

end.
