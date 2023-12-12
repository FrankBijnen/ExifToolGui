unit BreadcrumbBar;
{$WARN SYMBOL_PLATFORM OFF}
{.$DEFINE SHELLEXEC}

interface

//
// Based on Andreas Rejbrand's breadcrumb bar control:
// https://privat.rejbrand.se/breadcrumbs.html
// https://stackoverflow.com/a/6216300
//
// Changes:
// - Get rid of warnings
// - Add prefix to uses eg Sysutils => System.SySutils
// - Removed Winapi.UxTheme, Added Vcl.Themes
//   Style is only used to set the colors, Kept old code for bbsFlat.
// - Removed Register. Control instantiated only in code.
// - Enable/Disable ShellExecute via IFDEF SHELLEXEC
// - Add Home button
// - Added TPopupListbox for Dropdown. Allows for a scrollbar and selecting current dir.
// - Removed FImages. Not needed for DrawIconEx
// - Added DpiScale.

uses
  System.SysUtils, System.Classes, System.Math, System.Types,
  Winapi.Windows, Winapi.Messages,
  Vcl.Themes, Vcl.Controls, Vcl.Graphics, Vcl.Menus, Vcl.StdCtrls;

resourcestring
  SCopyText = 'Copy as text';
  SEmptyDir = '(The folder is empty)';
  SPathNotFoundCaption = 'Path not found';
  SPathNotFoundText = 'The path "%s" was not found.';

type
  RectArray = array of TRect;
  IntegerArray = array of integer;
  StringArray = array of string;

  TOnEditorReturn = function(Sender: TObject; const Text: string): boolean of object;
  TOnGetBreadcrumbs = procedure(Sender: TObject; Breadcrumbs: TStrings) of object;
  TOnGetBreadcrumbList = procedure(Sender: TObject; BreadcrumbIndex: integer; List: TStrings) of object;
  TOnBreadcrumbClick = procedure(Sender: TObject; BreadcrumbIndex: integer) of object;
  TOnBreadcrumbListItemClick = procedure(Sender: TObject; BreadcrumbIndex, ListIndex: integer) of object;
  TOnBreadcrumbBarGetText = procedure(Sender: TObject; var Text: string) of object;

  TCustomBreadcrumbBar = class;

  TPopupMenu = class(Vcl.Menus.TPopupMenu)
  private
    FOnClose: TNotifyEvent;
  public
    procedure Popup(X: Integer; Y: Integer); override;
    procedure PopupAtPoint(Point: TPoint);
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

  TListObject = class
    Caption: string;
    Icon: Hicon;
  end;

  TPopupListbox = class(TlistBox)
  const LBHORMARGIN = 10;
        LBVERMARGIN = 6;
  private
    FSavedFocus: HWND;
    FBreadCrumbBar: TCustomBreadcrumbBar;
    FBreadCrumbIndex: integer;
    FListItems: TStrings;
    FOnClose: TNotifyEvent;
    FOnSelect: TNotifyEvent;
  protected
    procedure Click; override;
    procedure DoExit; override;
    procedure DoClose;
    function GetCallerText: string;
    procedure DoGetDataObject(Control: TWinControl; Index: Integer; var DataObject: TObject);
    procedure DoDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
  public
    constructor Create(AOwner: TCustomBreadcrumbBar); reintroduce;
    procedure Popup(APoint: TPoint; ABreadCrumbIndex: integer; AListItems: TStrings);
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
    property BreadCrumbIndex: integer read FBreadCrumbIndex;
  end;

  TCustomBreadcrumbBar = class(TCustomControl)
  type
    TRectState = (rsNormal, rsHover, rsDown);
    TRectStateArray = array of TRectState;
  const
    ARROW_SIZE = 8;
    ARROW_BOX_SIZE = 16;
    SEP_PADDING = 16;
    INDENT = 3;
    VERT_PADDING = 3;
  private
    { Private declarations }
    FOnGetBreadcrumbs: TOnGetBreadcrumbs;
    FOnGetBreadcrumbList: TOnGetBreadcrumbList;
    FOnBreadcrumbClick: TOnBreadcrumbClick;
    FOnBreadcrumbListItemClick: TOnBreadcrumbListItemClick;
    FOnEditorReturn: TOnEditorReturn;
    FCurrentItems: TStrings;
    FCurrentListItems: TStrings;
    FBreadcrumbRects: RectArray;
    FBreadcrumbArrowRects: RectArray;
    FBreadcrumbStates: TRectStateArray;
    FArrowStates: TRectStateArray;
    FOldBreadcrumbStates: TRectStateArray;
    FOldArrowStates: TRectStateArray;
    FPopupListBox: TPopupListbox;
    FPopupMenuOpen: Boolean;
    FEditable: boolean;
    FEdit: TEdit;
    FOnBreadcrumbBarGetText: TOnBreadcrumbBarGetText;
    FCrumbDown: Integer;
    FBarPopup: TPopupMenu;
    FHome: string;
    FStyleServices: TCustomStyleServices;
    FStyle: string;
    FDesignDPI: integer;
    FScreenDPI: integer;
    procedure DrawArrow(ArrowRect: TRect);
    procedure ResetRectStates;
    function PointInRect(X, Y: integer; const Rect: TRect): boolean; inline;
    function GetMouseState: TRectState;
    procedure HasRectStatesChanged;
    procedure ShowArrowPopup(BreadcrumbIndex: integer);
    procedure ArrowPopupClose(Sender: TObject);
    function IsEditMode: boolean;
    procedure GoEditing;
    procedure EditKeyPress(Sender: TObject; var Key: char);
    procedure HideEditor;
    procedure SetStates(X, Y: Integer);
    function MouseButtonDown: boolean; inline;
    function GetCrumbDown: integer;
    function GetCrumbHover: integer;
    procedure CopyTextClick(Sender: TObject);
    function MakeDefaultText: string;
    procedure EditExit(Sender: TObject);
    procedure ArrowItemClick(Sender: TObject);
    procedure SetHome(const Value: string);
    procedure SetStyle(const Value: string);
  protected
    function GetButtonColor(const ARectState: TRectState): TColor;
    function GetPenColor: TColor;
    function GetBackColor(const ASelected: boolean = false): TColor;
    function GetBorderColor: TColor;
    function DpiScale(const APix: integer): integer;
    procedure Paint; override;
    procedure Loaded; override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    property OnGetBreadcrumbs: TOnGetBreadcrumbs read FOnGetBreadcrumbs write FOnGetBreadcrumbs;
    property OnGetBreadcrumbList: TOnGetBreadcrumbList read FOnGetBreadcrumbList write FOnGetBreadcrumbList;
    property OnBreadcrumbClick: TOnBreadcrumbClick read FOnBreadcrumbClick write FOnBreadcrumbClick;
    property OnBreadcrumbListItemClick: TOnBreadcrumbListItemClick read FOnBreadcrumbListItemClick write FOnBreadcrumbListItemClick;
    property OnBreadcrumbBarGetText: TOnBreadcrumbBarGetText read FOnBreadcrumbBarGetText write FOnBreadcrumbBarGetText;
    property OnEditorReturn: TOnEditorReturn read FOnEditorReturn write FOnEditorReturn;
    property Editable: boolean read FEditable write FEditable default true;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateBreadcrumbs;
    function GetBreadcrumb(Index: integer): string;
    function GetBreadcrumbListItem(Index: integer): string;
    property CrumbDown: integer read GetCrumbDown;
    property DesignDPI: integer read FDesignDPI write FDesignDPI;
    property ScreenDPI: integer read FScreenDPI write FScreenDPI;
    property DoubleBuffered;
    property EditMode: boolean read IsEditMode;
    property Font;
    property Home: string read FHome write SetHome;
    property Style: string read FStyle write SetStyle;
  end;

  TBreadcrumbBar = class(TCustomBreadcrumbBar)
  published
    property DoubleBuffered;
    property Editable;
    property OnGetBreadcrumbs;
    property OnGetBreadcrumbList;
    property OnBreadcrumbClick;
    property OnBreadcrumbListItemClick;
    property OnBreadcrumbBarGetText;
  end;

  TFileExecEvent = procedure(const FileName: TFileName) of object;
  TURLExecEvent = procedure(const URL: string) of object;

  TDirBreadcrumbBar = class(TCustomBreadcrumbBar)
  private
    FDirectory: string;
    FRoot: string;
    FBreadcrumbs: StringArray;
    FShowHiddenDirs: boolean;
    FOnFileExec: TFileExecEvent;
    FOnURLExec: TURLExecEvent;
    FOnHome: TNotifyEvent;
    FOnChange: TNotifyEvent;
    procedure GetBreadcrumbs(Sender: TObject; Breadcrumbs: TStrings);
    procedure GetBreadcrumbList(Sender: TObject; BreadcrumbIndex: integer;
      List: TStrings);
    procedure BreadcrumbClick(Sender: TObject; BreadcrumbIndex: integer);
    procedure BreadcrumbListClick(Sender: TObject; BreadcrumbIndex,
      ListIndex: integer);
    procedure BreadcrumbBarGetText(Sender: TObject; var Text: string);
    procedure SetDirectory(const Value: string);
    procedure SetRoot(const Value: string);
    function SplitPath(const APath: string): StringArray;
    function GetDirUpTo(Level: integer): string;
    function EditorReturn(Sender: TObject; const Text: string): boolean;
    function IsURL(const S: string): boolean;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Color;
    property DoubleBuffered;
    property Directory: string read FDirectory write SetDirectory;
    property Root: string read FRoot write SetRoot;
    property ShowHiddenDirs: boolean read FShowHiddenDirs write FShowHiddenDirs default false;
    property Editable;
    property OnHome: TNotifyEvent read FOnHome write FOnHome;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnFileExec: TFileExecEvent read FOnFileExec write FOnFileExec;
    property OnURLExec: TURLExecEvent read FOnURLExec write FOnURLExec;
  end;

implementation

uses
  System.IOUtils,
  Winapi.ShLwApi, Winapi.CommCtrl, Winapi.ShellAPI,
  Vcl.ImgList, Vcl.Dialogs, Vcl.Clipbrd;

{ TBreadcrumbBar }

constructor TCustomBreadcrumbBar.Create(AOwner: TComponent);
var
  MenuItem: TMenuItem;
begin
  inherited;
  FCurrentItems := TStringList.Create;
  FCurrentListItems := TStringList.Create;
  TStringList(FCurrentListItems).Sorted := true;

  FPopupListBox := TPopupListbox.Create(Self);
  FPopupListBox.OnSelect := ArrowItemClick;
  FPopupListBox.OnClose := ArrowPopupClose;

  FPopupMenuOpen := false;

  FStyleServices := nil;
  Width := 512;
  Height := 32;
  FEdit := TEdit.Create(Self);
  FEdit.Visible := false;
  FEdit.Parent := Self;
  FEdit.Align := alClient;
  FEdit.OnKeyPress := EditKeyPress;
  FEdit.OnExit := EditExit;
  FEditable := true;
  FBarPopup := TPopupMenu.Create(Self);
  MenuItem := TMenuItem.Create(FBarPopup);
  MenuItem.Caption := SCopyText;
  MenuItem.OnClick := CopyTextClick;
  FBarPopup.Items.Add(MenuItem);
  FCrumbDown := -1;
  FDesignDPI := 96;
  FScreenDPI := 96;
end;

destructor TCustomBreadcrumbBar.Destroy;
begin
  FBarPopup.Free;
  FCurrentListItems.Free;
  FCurrentItems.Free;
  inherited;
end;

procedure TCustomBreadcrumbBar.Loaded;
begin
  inherited;
  UpdateBreadcrumbs;
end;

procedure TCustomBreadcrumbBar.EditExit(Sender: TObject);
begin
  HideEditor;
end;

procedure TCustomBreadcrumbBar.CopyTextClick(Sender: TObject);
var
  S: string;
begin
  S := MakeDefaultText;
  if Assigned(FOnBreadcrumbBarGetText) then
    FOnBreadcrumbBarGetText(Self, S);
  Clipboard.AsText := S;
end;

procedure TCustomBreadcrumbBar.HideEditor;
begin
  FEdit.Hide;
  ResetRectStates;
  Invalidate;
end;

procedure TCustomBreadcrumbBar.EditKeyPress(Sender: TObject; var Key: char);
begin
  case ord(Key) of
    VK_ESCAPE:
      begin
        HideEditor;
        Key := #0;
      end;
    VK_RETURN:
      begin
        if Assigned(FOnEditorReturn) then
          if not FOnEditorReturn(Self, FEdit.Text) then Exit;
        HideEditor;
        Key := #0;
      end;
  end;
end;

procedure TCustomBreadcrumbBar.ArrowPopupClose(Sender: TObject);
begin
  FPopupMenuOpen := false;
  ResetRectStates;
  HasRectStatesChanged;
end;

procedure TCustomBreadcrumbBar.ShowArrowPopup(BreadcrumbIndex: integer);
var
  pnt: TPoint;
begin
  pnt.X := FBreadcrumbArrowRects[BreadcrumbIndex].Left;
  pnt.Y := FBreadcrumbArrowRects[BreadcrumbIndex].Bottom;
  FPopupMenuOpen := true;
  FPopupListBox.Popup(pnt, BreadcrumbIndex, FCurrentListItems);
end;

procedure TCustomBreadcrumbBar.ArrowItemClick(Sender: TObject);
begin
  if Assigned(FOnBreadcrumbListItemClick) then
    if Sender is TMenuItem then
      with Sender as TMenuItem do
        FOnBreadcrumbListItemClick(Self, Tag shr 16, Word(Tag));
    if Sender is TPopupListbox then
      with Sender as TPopupListbox do
        FOnBreadcrumbListItemClick(Self, BreadCrumbIndex, ItemIndex);
end;

function TCustomBreadcrumbBar.MakeDefaultText: string;
var
  i: integer;
begin
  for i := 0 to FCurrentItems.Count - 1 do
    if i < FCurrentItems.Count - 1 then
      result := result + FCurrentItems[i] + '\'
    else
      result := result + FCurrentItems[i];
end;

procedure TCustomBreadcrumbBar.GoEditing;
var
  S: string;
begin
  S := MakeDefaultText;
  if Assigned(FOnBreadcrumbBarGetText) then
    FOnBreadcrumbBarGetText(Self, S);
  FEdit.Text := S;
  FEdit.Show;
  if FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TCustomBreadcrumbBar.SetStates(X, Y: Integer);
var
  i: integer;
begin
  for i := 0 to FCurrentItems.Count - 1 do
    if PointInRect(X, Y, FBreadcrumbRects[i]) then
    begin
      FBreadcrumbStates[i] := GetMouseState;
      break;
    end
    else if PointInRect(X, Y, FBreadcrumbArrowRects[i]) then
    begin
      FArrowStates[i] := GetMouseState;
      break;
    end;
end;

procedure TCustomBreadcrumbBar.SetHome(const Value: string);
begin
  if (not SameText(FHome, Value)) then
  begin
    FHome := Value;
    UpdateBreadcrumbs;
  end;
end;

procedure TCustomBreadcrumbBar.SetStyle(const Value: string);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    FStyleServices := TStyleManager.Style[FStyle];
    Invalidate;
  end;
end;

procedure TCustomBreadcrumbBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  i: Integer;
  CRWait, CrNormal: HCURSOR;
begin
  inherited;
  ResetRectStates;
  SetStates(X, Y);
  HasRectStatesChanged;
  for i := 0 to FCurrentItems.Count - 1 do
    if FArrowStates[i] = rsDown then
    begin
      if Assigned(FOnGetBreadcrumbList) then
      begin
        FCurrentListItems.Clear;
        CRWait := LoadCursor(0, IDC_WAIT);
        CrNormal := SetCursor(CRWait);
        try
          FOnGetBreadcrumbList(Self, i, FCurrentListItems);
          ShowArrowPopup(i);
        finally
          SetCursor(CrNormal);
        end;
      end;
      break;
    end
    else
    if FBreadcrumbStates[i] = rsDown then
    begin
      FCrumbDown := i;
      break;
    end;
end;

procedure TCustomBreadcrumbBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if MouseButtonDown then Exit;
  ResetRectStates;
  SetStates(X, Y);
  HasRectStatesChanged;
end;

procedure TCustomBreadcrumbBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  ResetRectStates;
  SetStates(X, Y);
  HasRectStatesChanged;
  case Button of
    mbLeft:
        if FEditable and ((FCurrentItems.Count = 0) or
          (X > FBreadcrumbArrowRects[high(FBreadcrumbArrowRects)].Right)) then
          GoEditing
        else
          if (FCrumbDown >= 0) and (GetCrumbHover = FCrumbDown) then
            if Assigned(FOnBreadcrumbClick) then
              FOnBreadcrumbClick(Self, FCrumbDown);
    mbRight:
      FBarPopup.PopupAtPoint(ClientToScreen(Point(X, Y)));
    mbMiddle: ;
  end;
end;

function TCustomBreadcrumbBar.GetBreadcrumb(Index: integer): string;
begin
  if (Index > -1) and
     (Index < FCurrentItems.Count) then
    result := FCurrentItems[Index]
  else
    result := '';
end;

function TCustomBreadcrumbBar.GetBreadcrumbListItem(Index: integer): string;
begin
  result := FCurrentListItems[Index];
end;

function TCustomBreadcrumbBar.GetCrumbDown: integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to FCurrentItems.Count - 1 do
    if FBreadcrumbStates[i] = rsDown then
      Exit(i);
end;

function TCustomBreadcrumbBar.GetCrumbHover: integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to FCurrentItems.Count - 1 do
    if FBreadcrumbStates[i] <> rsNormal then
      Exit(i);
end;

procedure TCustomBreadcrumbBar.DrawArrow(ArrowRect: TRect);
var
  arr: array[0..2] of TPoint;
  xleft, xright,
  ytop, ybottom, ymiddle: integer;
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := GetPenColor;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
  xleft := ArrowRect.Left + (ArrowRect.Right - ArrowRect.Left - DpiScale(ARROW_SIZE)) div 2;
  xright := xleft + DpiScale(ARROW_SIZE);
  ytop := (Height - DpiScale(ARROW_SIZE)) div 2;
  ybottom := ytop + DpiScale(ARROW_SIZE);
  ymiddle := ytop + DpiScale(ARROW_SIZE) div 2;
  arr[0] := Point(xleft, ytop);
  arr[1] := Point(xleft, ybottom);
  arr[2] := Point(xright, ymiddle);
  Canvas.Polygon(arr);
end;

function TCustomBreadcrumbBar.MouseButtonDown: boolean;
begin
  MouseButtonDown := GetKeyState(VK_LBUTTON) and $8000 <> 0;
end;

function TCustomBreadcrumbBar.GetMouseState: TRectState;
begin
  if MouseButtonDown then
    result := rsDown
  else
    result := rsHover;
end;

function TCustomBreadcrumbBar.GetButtonColor(const ARectState: TRectState): TColor;
begin
  if Assigned(FStyleServices) then
  begin
    if ARectState <> rsNormal then
      result := FStyleServices.GetStyleColor(TStyleColor.scButtonFocused)
    else
      result := FStyleServices.GetStyleColor(TStyleColor.scButtonNormal);
  end
  else
  begin
    if ARectState <> rsNormal then
      result := clActiveCaption
    else
      result := Color;
  end;
end;

function TCustomBreadcrumbBar.GetPenColor: TColor;
begin
  if Assigned(FStyleServices) then
    result := FStyleServices.GetStyleFontColor(TStyleFont.sfButtonTextNormal)
  else
    result := clBlack;
end;

function TCustomBreadcrumbBar.GetBackColor(const ASelected: boolean = false): TColor;
begin
  if Assigned(FStyleServices) then
  begin
    if (ASelected) then
      result := FStyleServices.GetStyleColor(TStyleColor.scButtonHot)
    else
      result := FStyleServices.GetStyleColor(TStyleColor.scGenericGradientBase);
  end
  else
  begin
    if (ASelected) then
      result := clHighlight
    else
      result := Color;
  end;
end;

function TCustomBreadcrumbBar.GetBorderColor: TColor;
begin
  if Assigned(FStyleServices) then
    result := FStyleServices.GetStyleColor(TStyleColor.scBorder)
  else
    result := clSilver;
end;

function TCustomBreadcrumbBar.DpiScale(const APix: integer): integer;
begin
  result := MulDiv(APix, FScreenDPI, FDesignDPI);
end;

procedure TCustomBreadcrumbBar.Paint;
var
  i: Integer;
  S: string;
  r: TRect;
  MaxWidth: integer;
var
  A_VERT_PADDING: integer;
  A_INDENT: integer;
const
  RectConst: array[TRectState] of integer = (BDR_RAISED, BDR_RAISED, BDR_SUNKEN);
begin
  inherited;

  if EditMode or
     (FCurrentItems.Count = 0) then
    Exit;

  MaxWidth := floor(Width / FCurrentItems.Count) - DpiScale(ARROW_BOX_SIZE) - DpiScale(SEP_PADDING);

  A_VERT_PADDING := DpiScale(VERT_PADDING);
  A_INDENT := DpiScale(INDENT);

  // Draw background, with a border
  r := ClientRect;
  Canvas.Brush.Color := GetBackColor;
  Canvas.FillRect(r);

  Canvas.Pen.Color := GetBorderColor;
  Canvas.Pen.Style := psSolid;
  with r do
    Rectangle(Canvas.Handle, Left, Top, Right, Bottom);
  Canvas.Font.Assign(Font);
  for i := 0 to FCurrentItems.Count - 1 do
  begin

  // Draw breadcrumb

  // Compute rectangle needed for text S
    if i = 0 then
      FBreadcrumbRects[i].Left := A_INDENT
    else
      FBreadcrumbRects[i].Left := FBreadcrumbArrowRects[i - 1].Right;
    FBreadcrumbRects[i].Top := A_VERT_PADDING;
    S := FCurrentItems[i];

// DrawText used to calculate the rectangle in FBreadcrumbRects[i]
    DrawText(Canvas.Handle,
      PChar(S),
      length(S),
      FBreadcrumbRects[i],
      DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_CALCRECT);  // <== DT_CALCRECT: Only calculate

    FBreadcrumbRects[i].Right := Min(FBreadcrumbRects[i].Right,
      FBreadcrumbRects[i].Left + MaxWidth);
    FBreadcrumbRects[i].Bottom := Height - A_VERT_PADDING;
    inc(FBreadcrumbRects[i].Right, DpiScale(SEP_PADDING));

// Background breadcrumb
    Canvas.Brush.Color := GetButtonColor(FBreadcrumbStates[i]);
    Canvas.Brush.Style := bsSolid;
    FillRect(Canvas.Handle,
      FBreadcrumbRects[i],
      Canvas.Brush.Handle);

    Canvas.Pen.Color := GetBorderColor;
    Canvas.Pen.Style := psSolid;
    with FBreadcrumbRects[i] do
      Rectangle(Canvas.Handle, Left, Top, Right, Bottom);

// Text breadcrumb
    Canvas.Brush.Style := bsClear;
    if Assigned(FStyleServices) then
      Canvas.Font.Color := FStyleServices.GetStyleFontColor(TStyleFont.sfButtonTextNormal)
    else
      Canvas.Font.Color := clBlack;

    DrawText(Canvas.Handle,
      PChar(S),
      length(S),
      FBreadcrumbRects[i],
      DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_END_ELLIPSIS);

  // Draw Arrow
    FBreadcrumbArrowRects[i].Left := FBreadcrumbRects[i].Right;
    FBreadcrumbArrowRects[i].Top := A_VERT_PADDING;
    FBreadcrumbArrowRects[i].Bottom := Height - A_VERT_PADDING;
    FBreadcrumbArrowRects[i].Right := FBreadcrumbArrowRects[i].Left + DpiScale(ARROW_BOX_SIZE);

    Canvas.Brush.Color := GetButtonColor(FArrowStates[i]);
    Canvas.Brush.Style := bsSolid;
    FillRect(Canvas.Handle,
      FBreadcrumbArrowRects[i],
      Canvas.Brush.Handle);
    Canvas.Pen.Color := GetBorderColor;
    Canvas.Pen.Style := psSolid;
    with FBreadcrumbArrowRects[i] do
      Rectangle(Canvas.Handle, Left, Top, Right, Bottom);

    DrawArrow(FBreadcrumbArrowRects[i]);
  end;
end;

function TCustomBreadcrumbBar.PointInRect(X, Y: integer; const Rect: TRect): boolean;
begin
  result := InRange(X, Rect.Left, Rect.Right) and InRange(Y, Rect.Top, Rect.Bottom);
end;

procedure TCustomBreadcrumbBar.ResetRectStates;
var
  i: Integer;
begin
  if FPopupMenuOpen then Exit;
  FOldBreadcrumbStates := Copy(FBreadcrumbStates);
  FOldArrowStates := Copy(FArrowStates);
  for i := 0 to FCurrentItems.Count - 1 do
  begin
    FBreadcrumbStates[i] := rsNormal;
    FArrowStates[i] := rsNormal;
  end;
end;

procedure TCustomBreadcrumbBar.HasRectStatesChanged;
var
  i: Integer;
begin
  for i := 0 to FCurrentItems.Count - 1 do
  begin
    if (FBreadcrumbStates[i] <> FOldBreadcrumbStates[i]) then
      InvalidateRect(Handle, FBreadcrumbRects[i], true);
    if (FArrowStates[i] <> FOldArrowStates[i]) then
      InvalidateRect(Handle, FBreadcrumbArrowRects[i], true);
  end;
end;

function TCustomBreadcrumbBar.IsEditMode: boolean;
begin
  IsEditMode := FEdit.Visible;
end;

procedure TCustomBreadcrumbBar.UpdateBreadcrumbs;
begin
  if (csDesigning in ComponentState) then
    Exit;
  if not (Assigned(FOnGetBreadcrumbs)) then
    raise EInvalidOperation.Create('Event FOnGetBreadcrumbs not assigned.');
  FCurrentItems.Clear;
  FOnGetBreadcrumbs(Self, FCurrentItems);
  SetLength(FBreadcrumbRects, FCurrentItems.Count);
  SetLength(FBreadcrumbArrowRects, FCurrentItems.Count);
  SetLength(FBreadcrumbStates, FCurrentItems.Count);
  SetLength(FArrowStates, FCurrentItems.Count);
  Invalidate;
end;

procedure TCustomBreadcrumbBar.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    WM_MOUSELEAVE:
      begin
        ResetRectStates;
        HasRectStatesChanged;
      end;
  end;
end;

{ TPopupMenu }

procedure TPopupMenu.Popup(X, Y: Integer);
begin
  inherited;
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

procedure TPopupMenu.PopupAtPoint(Point: TPoint);
begin
  with Point do Popup(X, Y);
end;

{ TPopupListBox }

constructor TPopupListbox.Create(AOwner: TCustomBreadcrumbBar);
begin
  inherited Create(AOwner);
  FBreadCrumbBar := AOwner;
  IntegralHeight := true;
  OnDataObject := DoGetDataObject;
  OnDrawItem := DoDrawItem;
end;

procedure TPopupListbox.Click;
begin
  inherited;

  if Assigned(FOnSelect) then
    FOnSelect(Self);
  DoClose;
end;

procedure TPopupListbox.DoExit;
begin
  inherited;

  DoClose;
end;

procedure TPopupListbox.DoClose;
begin
  Winapi.Windows.SetFocus(FSavedFocus); // Restore Focus
  Parent := nil;                        // Hides popup listbox

  if Assigned(FOnClose) then
    FOnClose(Self);
end;

function TPopupListbox.GetCallerText: string;
var CallerIndex: integer;
begin
  CallerIndex := BreadcrumbIndex;
  if (FBreadCrumbBar.Home  <> '') then
    inc(CallerIndex);
  result := FBreadCrumbBar.GetBreadcrumb(CallerIndex);
end;

procedure TPopupListbox.DoGetDataObject(Control: TWinControl; Index: Integer; var DataObject: TObject);
begin
  DataObject := TListObject.Create;
  with DataObject as TListObject do
  begin
    if (Index > -1) and
       (Index < FListItems.Count) then
    begin
      Icon := Hicon(FListItems.Objects[Index]);
      Caption := FListItems[Index];
    end;
  end;
end;

procedure TPopupListbox.DoDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ListObject: TListObject;
begin
  ListObject := TListObject(Items.Objects[Index]);
  try
    Canvas.Brush.Color := FBreadCrumbBar.GetBackColor(odSelected in State);
    Canvas.FillRect(Rect);
    DrawIconEx(Canvas.Handle, Rect.Left, Rect.Top, ListObject.Icon,
               ItemHeight - LBVERMARGIN, ItemHeight - LBVERMARGIN,  0, 0, DI_NORMAL);
    Rect.Left := Rect.Left + ItemHeight;
    Canvas.Font.Assign(FBreadCrumbBar.Canvas.Font);
    Canvas.TextRect(Rect, Rect.Left, Rect.Top, ListObject.Caption);
  finally
    ListObject.Free;
  end;
end;

procedure TPopupListbox.Popup(APoint: TPoint; ABreadCrumbIndex: integer; AListItems: TStrings);
var ALine: string;
    W, WR, HorMargin, VerMargin: integer;
    PopupPoint: TPoint;

  // So we dont need Vcl.Forms
  function GetTopParent(AControl: TWinControl): TWinControl;
  begin
    result := AControl;
    while result.Parent <> nil do
      result := result.Parent;
  end;

begin
  // Make Listbox visible.
  Parent := GetTopParent(FBreadCrumbBar);

  // Set style
  Style := TListBoxStyle.lbVirtualOwnerDraw;

  //  Parent := ParentForm;
  PopupPoint := FBreadCrumbBar.ClientToScreen(APoint);
  PopupPoint := Parent.ScreenToClient(PopupPoint);

  // Make sure we get the focus
  FSavedFocus := Winapi.Windows.SetFocus(Self.Handle);

  // Items to draw
  FListItems := AListItems;
  Count := FListItems.Count;

  // Compute dimensions.
  // Font needed.
  Canvas.Font.Assign(FBreadCrumbBar.Canvas.Font);
  Canvas.Brush.Assign(FBreadCrumbBar.Canvas.Brush);

  // ItemHeight needed for font
  VerMargin := FBreadCrumbBar.DpiScale(LBVERMARGIN);
  ItemHeight := Canvas.TextHeight('Q') + VerMargin;

  //  Length of largest line
  W := 0;
  HorMargin := ItemHeight + FBreadCrumbBar.DpiScale(LBHORMARGIN);
  for ALine in FListItems do
  begin
    WR := Canvas.TextWidth(ALine) + HorMargin;
    if (WR > W) then
      W := WR;
  end;
  SetBounds(PopupPoint.X, PopupPoint.Y, W, (Count * ItemHeight) + VerMargin);

  // Outside ParentControl?
  if ((Top + Height) > Parent.ClientRect.Height) then
  begin
    Height := Parent.ClientRect.Height - Top;           // Note: IntegralHeight = true
    Width := Width + GetSystemMetrics(SM_CXVSCROLL);    // Adjust for Vertical Scrollbar
  end;
  if ((Left + Width) > Parent.ClientRect.Width) then
    Width := Parent.ClientRect.Width - Left;

  // Adjust ScrollWidth
  ScrollWidth := 0;
  if (W > Width) then
  begin
    ScrollWidth := W;
    Height := Height + GetSystemMetrics(SM_CYHSCROLL);  // Adjust for Horizontal Scrollbar
  end;

  // Focus and scroll to Caller control text
  FBreadCrumbIndex := ABreadCrumbIndex;
  ItemIndex := FListItems.IndexOf(GetCallerText);
  TopIndex := ItemIndex;
end;

{ TDirBreadcrumbBar }

constructor TDirBreadcrumbBar.Create(AOwner: TComponent);
begin
  inherited;
  OnGetBreadcrumbs := GetBreadcrumbs;
  OnGetBreadcrumbList := GetBreadcrumbList;
  OnBreadcrumbClick := BreadcrumbClick;
  OnBreadcrumbListItemClick := BreadcrumbListClick;
  OnBreadcrumbBarGetText := BreadcrumbBarGetText;
  OnEditorReturn := EditorReturn;
  FShowHiddenDirs := false;
end;

function TDirBreadcrumbBar.SplitPath(const APath: string): StringArray;
var
  CurPath: string;
  SepPos: IntegerArray;
  i: Integer;
begin
  if (FHome <> '') then
    CurPath := FHome + '\' + APath
  else
    CurPath := APath;

  SetLength(SepPos, 1);
  SepPos[0] := 0;

  for i := 1 to length(CurPath) do
    if CurPath[i] = '\' then
    begin
      SetLength(SepPos, length(SepPos) + 1); // I know. But paths aren't generally that long.
      SepPos[high(SepPos)] := i;
    end;
  SetLength(SepPos, length(SepPos) + 1);
  SepPos[high(SepPos)] := length(CurPath) + 1;
  SetLength(result, high(SepPos));
  for i := 0 to high(SepPos) -1 do
    result[i] := Copy(CurPath, SepPos[i] + 1, SepPos[i+1] - SepPos[i] - 1);
end;

function TDirBreadcrumbBar.IsURL(const S: string): boolean;
const
  Protocols: array[0..4] of string = ('http://', 'https://', 'ftp://',
    'mailto:', 'www');
var
  i: Integer;
begin
  result := false;
  for i := 0 to high(Protocols) do
    if SameText(Copy(S, 1, length(Protocols[i])), Protocols[i]) then
      Exit(true);
end;

function TDirBreadcrumbBar.EditorReturn(Sender: TObject; const Text: string): boolean;
var
  AText: string;
begin
  AText := Text;
  if FileExists(Text) then
  begin
    if Assigned(FOnFileExec) then
      FOnFileExec(Text)
{$IFDEF SHELLEXEC}
    else
      ShellExecute(0, nil, PChar(Text), nil, nil, SW_SHOWNORMAL)
{$ENDIF}

  end
  else if DirectoryExists(Text) then
  begin
    SetDirectory(Text);
    if Assigned(FOnChange) then
      FOnChange(Self);
  end
  else if IsURL(Text) then
  begin
    if Assigned(FOnURLExec) then
      FOnURLExec(Text)
{$IFDEF SHELLEXEC}
    else
      ShellExecute(0, nil, PChar(Text), nil, nil, SW_SHOWNORMAL)
{$ENDIF}
  end
  else
    if (Win32MajorVersion >= 6) then
      with TTaskDialog.Create(Self) do
        try
            Caption := SPathNotFoundCaption;
          Title := SPathNotFoundCaption;
          Text := Format(SPathNotFoundText, [AText]);
          MainIcon := tdiInformation;
          CommonButtons := [tcbClose];
          Execute;
        finally
          Free;
        end
    else
      MessageBox(Handle,
                 PChar(Format(SPathNotFoundText, [Text])),
                 PChar(SPathNotFoundCaption),
                 MB_ICONINFORMATION or MB_OK);
  result := true;
end;

procedure TDirBreadcrumbBar.GetBreadcrumbs(Sender: TObject;
  Breadcrumbs: TStrings);
var
  i: Integer;
begin
  for i := 0 to high(FBreadcrumbs) do
    Breadcrumbs.Add(FBreadcrumbs[i]);
end;

function TDirBreadcrumbBar.GetDirUpTo(Level: integer): string;
var
  i: Integer;
  p: integer;
begin
  p := 0;
  if (FHome <> '') then
    inc(p);
  result := FBreadcrumbs[p];
  for i := p +1 to Level do
    result := result + '\' + FBreadcrumbs[i];
end;

procedure TDirBreadcrumbBar.SetDirectory(const Value: string);
var
  AValue: string;
begin
  SetLength(AValue, MAX_PATH);
  PathCanonicalize(PChar(AValue), PChar(Value));
  SetLength(AValue, StrLen(PChar(AValue)));
  while (length(AValue) > 0) and (AValue[length(AValue)] = '\') do
    SetLength(AValue, length(AValue) - 1);
  if (not SameText(FDirectory, AValue)) and DirectoryExists(AValue) then
  begin
    FDirectory := AValue;
    FBreadcrumbs := SplitPath(FDirectory);
    UpdateBreadcrumbs;
  end;
end;

procedure TDirBreadcrumbBar.SetRoot(const Value: string);
begin
  if (not SameText(FRoot, Value)) and DirectoryExists(Value) then
  begin
    FRoot := Value;
    UpdateBreadcrumbs;
  end;
end;

procedure TDirBreadcrumbBar.GetBreadcrumbList(Sender: TObject;
  BreadcrumbIndex: integer; List: TStrings);
var
  SubPath: string;
  SR: TSearchRec;
  SFI: TSHFileInfo;
  IconHandles: IntegerArray;

  function IconHandlesContains(h: integer): boolean;
  var
    j: Integer;
  begin
    result := false;
    for j := 0 to high(IconHandles) do
      if IconHandles[j] = h then
        Exit(true);
  end;

  function IconHandlesIndexOf(h: integer): integer;
  var
    j: Integer;
  begin
    result := 0;
    for j := 0 to high(IconHandles) do
      if IconHandles[j] = h then
        Exit(j);
  end;

  procedure GetDrives;
  var
    Drives: TStringDynArray;
    Drive: string;
  begin
    Drives := TDirectory.GetLogicalDrives;
    for Drive in Drives do
    begin
      if (DirectoryExists(Drive)) then
      begin
        if SHGetFileInfo(PChar(Drive), 0, SFI, sizeof(SFI),
          SHGFI_ICON or SHGFI_SMALLICON) <> 0 then
          List.AddObject(Drive, TObject(SFI.hIcon))
        else
          List.AddObject(Drive, nil);
       end;
    end;
  end;

begin
  if (FHome <> '') and
     (BreadcrumbIndex = 0) then
  begin
    GetDrives;
    exit;
  end;

  SubPath := GetDirUpTo(BreadcrumbIndex);

  if not DirectoryExists(SubPath) then Exit;
    SubPath := IncludeTrailingBackslash(SubPath);
  if System.SysUtils.FindFirst(SubPath + '*.*', faDirectory or faHidden, SR) = 0 then
    try
      repeat
        if (SR.Attr and faDirectory <> 0) and (SR.Name <> '..') and
          (SR.Name <> '.') and (FShowHiddenDirs or ((SR.Attr and faHidden = 0)
          and (Copy(SR.Name, 1, 1) <> '.'))) then
          begin
            if SHGetFileInfo(PChar(SubPath + SR.Name), 0, SFI, sizeof(SFI),
              SHGFI_ICON or SHGFI_SMALLICON) <> 0 then
              List.AddObject(SR.Name, TObject(SFI.hIcon))
            else
              List.AddObject(SR.Name, nil);
          end;
      until System.Sysutils.FindNext(SR) <> 0;
    finally
      System.Sysutils.FindClose(SR);
    end;
end;

procedure TDirBreadcrumbBar.BreadcrumbClick(Sender: TObject;
  BreadcrumbIndex: integer);
begin
  SetDirectory(GetDirUpTo(BreadcrumbIndex));
  if (BreadcrumbIndex = 0) and
     (FHome <> '') then
  begin
    if Assigned(FOnHOme) then
      FOnHome(Self);
  end
  else
  begin
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TDirBreadcrumbBar.BreadcrumbListClick(Sender: TObject;
  BreadcrumbIndex, ListIndex: integer);
var NewPath: string;
begin
  if (FHome <> '') and
     (BreadcrumbIndex = 0) then
    NewPath := ''
  else
    NewPath := IncludeTrailingBackslash(GetDirUpTo(BreadcrumbIndex));
  SetDirectory(NewPath + GetBreadcrumbListItem(ListIndex));
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

// Future Use?
procedure TDirBreadcrumbBar.BreadcrumbBarGetText(Sender: TObject;
  var Text: string);
begin
  {}
end;

end.
