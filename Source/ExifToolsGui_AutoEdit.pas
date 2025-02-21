unit ExifToolsGui_AutoEdit;

interface

uses
  System.Classes, Winapi.ShlObj, Vcl.StdCtrls, ExifToolsGui_AutoComplete;

type
  TEdit = class(Vcl.StdCtrls.TEdit)
  private
    FAutoCompleteMode: TAutoCompleteMode;
    IAutoComplete: IAutoComplete;
    FEnableAutoComplete: boolean;
  protected
    procedure CreateWnd; override;
    procedure EnableAutoComplete(Enable: boolean);
    procedure SetAutoComplete;
    procedure SetAutoCompleteMode(Value: TAutoCompleteMode);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property AutoCompleteMode: TAutoCompleteMode read FAutoCompleteMode write SetAutoCompleteMode;
  end;

implementation

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

end.
