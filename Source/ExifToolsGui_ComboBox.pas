unit ExifToolsGui_ComboBox;

// Allow OwnerDraw with edit box
// Filtering on Full text

interface

uses
  System.Classes,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.StdCtrls;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    FFullSearch: boolean;
    FStoredItems: TStringList;
    procedure FilterItems;
    procedure StoredItemsChange(Sender: TObject);
    procedure SetStoredItems(const Value: TStringList);
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetFullSearch(AValue: boolean);
    property StoredItems: TStringList read FStoredItems write SetStoredItems;
    property FullSearch: boolean read FFullSearch;
  end;

implementation

uses
  System.StrUtils;

constructor TComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FFullSearch := false;
  FStoredItems := TStringList.Create;
  FStoredItems.OnChange := StoredItemsChange;
end;

destructor TComboBox.Destroy;
begin
  FStoredItems.Free;
  inherited;
end;

procedure TComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited;

  if Assigned(OnDrawItem) then
    Params.Style := Params.Style or CBS_OWNERDRAWFIXED
end;

procedure TComboBox.CNCommand(var AMessage: TWMCommand);
begin
  inherited;

  if AMessage.NotifyCode = CBN_EDITUPDATE then
    FilterItems;
end;

procedure TComboBox.FilterItems;
var
  ALine: string;
  Selection: TSelection;
begin
  if not FFullSearch then
    exit;

  // store the current combo edit selection
  SendMessage(Handle, CB_GETEDITSEL, WPARAM(@Selection.StartPos), LPARAM(@Selection.EndPos));

  Items.BeginUpdate;
  try
    if Text = '' then
      Items.Assign(FStoredItems)
    else
    begin
      Items.Clear;
      for ALine in FStoredItems do
      begin
        if ContainsText(ALine, Text) then
          Items.Add(ALine);
      end;
    end;
  finally
    Items.EndUpdate;
  end;

  SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(Selection.StartPos, Selection.EndPos));
end;

procedure TComboBox.StoredItemsChange(Sender: TObject);
begin
  if Assigned(FStoredItems) then
    FilterItems;
end;

procedure TComboBox.SetStoredItems(const Value: TStringList);
begin
  if Assigned(FStoredItems) then
    FStoredItems.Assign(Value)
  else
    FStoredItems := Value;
end;

procedure TComboBox.SetFullSearch(AValue: boolean);
begin
  if (FFullSearch <> AValue) then
    FFullSearch := AValue;
  AutoComplete := not FFullSearch;
end;

end.
