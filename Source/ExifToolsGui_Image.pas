unit ExifToolsGui_Image;

interface

uses
  System.Classes, System.Types, System.Generics.Collections,
  Winapi.Messages,
  Vcl.ExtCtrls,
  UnitRegion;

type
  TOnSelectionDone = procedure(Sender: TObject; Rect: TRegionRect) of object;

  TSelectionRect = record
    Selected: boolean;
    Rect: TRect;
  end;
  TRectList = Tlist<TSelectionRect>;

  TImage = class(Vcl.ExtCtrls.TImage)
  private
    FRotate: integer;
    FCurRects: TRectList;
    FStartX: double;
    FStartY: double;
    FSelecting: boolean;
    FSelectionEnabled: boolean;
    FSelectedRect: TRegionRect;
    FImageDimensions: TPoint;
    FOnSelectionDone: TOnSelectionDone;
  private
    procedure SetImageDimensions(ADimensions: TPoint);
  protected
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    function RegionPtX(Message: TWMMouse): double;
    function RegionPtY(Message: TWMMouse): double;
    function RectFromRegionRect(ARegionRect: TRegionRect): TRect;
    function CorrectRotation(const ARegionRect: TRegionRect; Rot: Integer): TRegionRect;
    procedure SetRotate(ARotate: integer);
    procedure DrawRectangle(ARect: TSelectionRect);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RemoveSelectionRects;
    procedure DrawSelectionRects(NewRects: TRegionList);
    property ImageDimensions: TPoint read FImageDimensions write SetImageDimensions;
    property SelectionEnabled: boolean read FSelectionEnabled write FSelectionEnabled;
    property Rotate: integer read FRotate write SetRotate;
    property OnSelectionDone: TOnSelectionDone read FOnSelectionDone write FOnSelectionDone;
  end;

implementation

uses
  Winapi.Windows, Vcl.Graphics;

const
  LineWidth = 2;

constructor TImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCurRects := TRectList.Create;

  FSelecting := false;
  FSelectionEnabled := false;
end;

destructor TImage.Destroy;
begin
  FCurRects.Free;
  inherited Destroy;
end;

procedure TImage.SetImageDimensions(ADimensions: TPoint);
begin
  FImageDimensions := ADimensions;
end;

// Converts RegionRect from/to rotated/unrotated
function TImage.CorrectRotation(const ARegionRect: TRegionRect; Rot: Integer): TRegionRect;
begin
  result := ARegionRect;

  case Rot of
    -270, 90:
      begin
        result.Y := ARegionRect.X;
        result.X := 1 - (ARegionRect.Y + ARegionRect.H);
        result.H := ARegionRect.W;
        result.W := ARegionRect.H;
      end;
    -180, 180:
      begin
        result.Y := 1 - (ARegionRect.Y + ARegionRect.H);
        result.X := 1 - (ARegionRect.X + ARegionRect.W);
      end;
    -90, 270:
      begin
        result.Y := 1 - (ARegionRect.X + ARegionRect.W);
        result.X := ARegionRect.Y;
        result.H := ARegionRect.W;
        result.W := ARegionRect.H;
      end;
  end;
end;

procedure TImage.SetRotate(ARotate: integer);
begin
  FRotate := ARotate;
  FCurRects.Clear; // Called when a new image is loaded, so no rectangles exist.
end;

// Compute Rectangle in percentage / 100 of image dimensions. On rotated image.
function TImage.RectFromRegionRect(ARegionRect: TRegionRect): TRect;
begin
  result.Left  := Round(FImageDimensions.X * ARegionRect.X) + ((Width  - FImageDimensions.X) div 2);
  result.Top   := Round(FImageDimensions.Y * ARegionRect.Y) + ((Height - FImageDimensions.Y) div 2);
  result.Width := Round(FImageDimensions.X * ARegionRect.W);
  result.Height:= Round(FImageDimensions.Y * ARegionRect.H);
end;

// Convert mousepos X to percentage / 100 of image width
function TImage.RegionPtX(Message: TWMMouse): double;
begin
  result := (Message.XPos - (Width  - FImageDimensions.X) div 2) / FImageDimensions.X;
end;

// Convert mousepos Y to percentage / 100 of image heigth
function TImage.RegionPtY(Message: TWMMouse): double;
begin
  result := (Message.YPos - (Height - FImageDimensions.Y) div 2) / FImageDimensions.Y;
end;

// Start selection
procedure TImage.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if (FSelectionEnabled) then
  begin
    FillChar(FSelectedRect, SizeOf(FSelectedRect), 0);
    FStartX := RegionPtX(Message);
    if (FStartX < 0) then
      FStartX := 0;
    FStartY := RegionPtY(Message);
    if (FStartY < 0) then
      FStartY := 0;

    FSelecting := true;
  end;

  inherited;
end;

// Move selection
procedure TImage.WMMouseMove(var Message: TWMMouseMove);
var
  FCurX: double;
  FCurY: double;
  ARect: TSelectionRect;
begin
  if (FSelecting) then
  begin
    FCurX := RegionPtX(Message);
    if (FCurX < 0) then
      FCurX := 0;
    if (FCurX > 1) then
      FCurX := 1;

    FCurY := RegionPtY(Message);
    if (FCurY < 0) then
      FCurY := 0;
    if (FCurY > 1) then
      FCurY := 1;

    if (FStartX < FCurX) then
    begin
      FSelectedRect.X := FStartX;
      FSelectedRect.W := FCurX - FStartX;
    end
    else
    begin
      FSelectedRect.X := FCurX;
      FSelectedRect.W := FStartX - FCurX;
    end;

    if (FStartY < FCurY) then
    begin
      FSelectedRect.Y := FStartY;
      FSelectedRect.H := FCurY - FStartY;
    end
    else
    begin
      FSelectedRect.Y := FCurY;
      FSelectedRect.H := FStartY - FCurY;
    end;
    RemoveSelectionRects;
    ARect.Rect := RectFromRegionRect(FSelectedRect);
    DrawRectangle(ARect);
    FCurRects.Add(ARect);
  end;

  inherited;
end;

// Selection ended
procedure TImage.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FSelecting := false;

  // Need to return the rectangle of the unrotated image.
  if (FSelectionEnabled) and
     (Assigned(FOnSelectionDone))then
    FOnSelectionDone(Self, CorrectRotation(FSelectedRect, -Rotate));

  inherited;
end;

// Also used for removing Selection.
// First call draws a rectangle. Second call restores the original.
// https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-setrop2
procedure TImage.DrawRectangle(ARect: TSelectionRect);
const
  DotLen = 3;

  procedure DrawHorzDots(Hor: integer);
  var
    Index: integer;
  begin
    Index := ARect.Rect.Left;
    while (Index < ARect.Rect.Right - DotLen) do
    begin
      Canvas.MoveTo(Index,  Hor);
      Canvas.LineTo(Index + DotLen, Hor);
      Inc(Index, DotLen);
    end;
  end;

  procedure DrawVertDots(Ver: integer);
  var
    Index: integer;
  begin
    Index := ARect.Rect.Top;
    while (Index < ARect.Rect.Bottom - DotLen) do
    begin
      Canvas.MoveTo(Ver, Index);
      Canvas.LineTo(Ver, Index + DotLen);
      Inc(Index, DotLen);
    end;
  end;

begin
  Canvas.Pen.Width := LineWidth;
  Canvas.Pen.Mode := TPenMode.pmNot;

  if (ARect.Selected) then
  begin
    Canvas.Pen.Width := LineWidth * 2;
    Canvas.MoveTo(ARect.Rect.Left,  ARect.Rect.Top);
    Canvas.LineTo(ARect.Rect.Right, ARect.Rect.Top);
    Canvas.LineTo(ARect.Rect.Right, ARect.Rect.Bottom);
    Canvas.LineTo(ARect.Rect.Left,  ARect.Rect.Bottom);
    Canvas.LineTo(ARect.Rect.Left,  ARect.Rect.Top);
  end
  else
  begin
    DrawHorzDots(ARect.Rect.Top);
    DrawVertDots(ARect.Rect.Right);
    DrawHorzDots(ARect.Rect.Bottom);
    DrawVertDots(ARect.Rect.Left);
  end;
end;

// Removes all previously drawn rectangles
procedure TImage.RemoveSelectionRects;
var
  ARect: TSelectionRect;
begin
  for ARect in FCurRects do
    DrawRectangle(ARect);
  FCurRects.Clear;
end;

// Draw all regions on the image
procedure TImage.DrawSelectionRects(NewRects: TRegionList);
var
  ARegion: TRegion;
  ARect: TSelectionRect;
begin
  RemoveSelectionRects;

  for ARegion in NewRects do
  begin
    if (ARegion.Show = false) then
      continue;

    // Need to correct for the current rotatation of the image.
    ARect.Rect := RectFromRegionRect(CorrectRotation(ARegion.RegionRect, Rotate));
    ARect.Selected := ARegion.Selected;
    DrawRectangle(ARect);
    FCurRects.Add(ARect);
  end;
end;

end.
