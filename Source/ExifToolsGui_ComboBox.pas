unit ExifToolsGui_ComboBox;

// Allow OwnerDraw with edit box
// Full text searching

interface

uses
  System.Classes,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.StdCtrls;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    FFullTextSearch: boolean;
    FFullTextSearchItems: TStringList;
    procedure FilterItems;
    procedure SetFullTextSearch(AValue: boolean);
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure EnableFullTextSearch;
    property FullTextSearch: boolean read FFullTextSearch write SetFullTextSearch;
  end;

implementation

uses
  System.StrUtils;

constructor TComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FFullTextSearch := false;
  FFullTextSearchItems := TStringList.Create;
end;

destructor TComboBox.Destroy;
begin
  FFullTextSearchItems.Free;
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
  if not FFullTextSearch then
    exit;

  // store the current combo edit selection
  SendMessage(Handle, CB_GETEDITSEL, WPARAM(@Selection.StartPos), LPARAM(@Selection.EndPos));

  Items.BeginUpdate;
  try
    if Text = '' then
      Items.Assign(FFullTextSearchItems)
    else
    begin
      Items.Clear;
      for ALine in FFullTextSearchItems do
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

procedure TComboBox.SetFullTextSearch(AValue: boolean);
begin
  if (FFullTextSearch <> AValue) then
    FFullTextSearch := AValue;
  AutoComplete := not FFullTextSearch;
end;

procedure TComboBox.EnableFullTextSearch;
begin
  FFullTextSearchItems.Assign(Items);
  FullTextSearch := true;
end;

end.
