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

  TEdit = class(Vcl.StdCtrls.TEdit, IAutoCompleteEdit)
  private
    FAutoCompleteEdit: IAutoCompleteEdit;
  protected
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    property AutoCompleteEdit: IAutoCompleteEdit read FAutoCompleteEdit implements IAutoCompleteEdit;
  end;

  TLabeledEdit = class(Vcl.ExtCtrls.TLabeledEdit, IAutoCompleteEdit)
  private
    FAutoCompleteEdit: IAutoCompleteEdit;
  protected
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    property AutoCompleteEdit: IAutoCompleteEdit read FAutoCompleteEdit implements IAutoCompleteEdit;
  end;

implementation

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

{ TlabeledEdit }
 constructor TLabeledEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
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
