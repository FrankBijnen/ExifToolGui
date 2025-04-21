unit ExifToolsGui_Image;

interface

uses
  System.Classes, System.Types,
  Winapi.Messages,
  Vcl.ExtCtrls,
  UnitRegion;

type

  TImage = class(Vcl.ExtCtrls.TImage)
  private
    FRotate: integer;
    FCurRect: TRect;
    FStartX: double;
    FStartY: double;
    FRegionRect: TRegionRect;
    FSelectionDrawn: boolean;
    FSelecting: boolean;
    FSelectionEnabled: boolean;
    FImageDimensions: TPoint;
    FOnSelectionDone: TNotifyEvent;
  private
    procedure SetImageDimensions(ADimensions: TPoint);
  protected
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure SetCurRect;
    function RegionPtX(Message: TWMMouse): double;
    function RegionPtY(Message: TWMMouse): double;
    function CorrectRotation(const ARegionRect: TRegionRect; Rot: Integer): TRegionRect;
    function GetRegionRect: TRegionRect;
    procedure SetRegionRect(ARegion: TRegionRect);
    procedure SetRotate(ARotate: integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure RemoveSelection;
    procedure DrawSelection;
    property ImageDimensions: TPoint read FImageDimensions write SetImageDimensions;
    property RegionRect: TRegionRect read GetRegionRect write SetRegionRect;
    property SelectionEnabled: boolean read FSelectionEnabled write FSelectionEnabled;
    property Rotate: integer read FRotate write SetRotate;
    property OnSelectionDone: TNotifyEvent read FOnSelectionDone write FOnSelectionDone;
  end;

implementation

uses
  Winapi.Windows;

const
  LineWidth = 3;

constructor TImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSelecting := false;
  FSelectionEnabled := false;
end;

procedure TImage.SetImageDimensions(ADimensions: TPoint);
begin
  FImageDimensions := ADimensions;
end;

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

function TImage.GetRegionRect: TRegionRect;
begin
  result := CorrectRotation(FRegionRect, -Rotate);
end;

procedure TImage.SetRegionRect(ARegion: TRegionRect);
begin
  FRegionRect := CorrectRotation(ARegion, Rotate);
end;

procedure TImage.SetRotate(ARotate: integer);
begin
  FRotate := ARotate;
  FSelectionDrawn := false;
end;

procedure TImage.SetCurRect;
begin
  FCurRect.Left  := Round(FImageDimensions.X * FRegionRect.X) + ((Width  - FImageDimensions.X) div 2);
  FCurRect.Top   := Round(FImageDimensions.Y * FRegionRect.Y) + ((Height - FImageDimensions.Y) div 2);
  FCurRect.Width := Round(FImageDimensions.X * FRegionRect.W);
  FCurRect.Height:= Round(FImageDimensions.Y * FRegionRect.H);
end;

function TImage.RegionPtX(Message: TWMMouse): double;
begin
  result := (Message.XPos - (Width  - FImageDimensions.X) div 2) / FImageDimensions.X;
end;

function TImage.RegionPtY(Message: TWMMouse): double;
begin
  result := (Message.YPos - (Height - FImageDimensions.Y) div 2) / FImageDimensions.Y;
end;

procedure TImage.WMLButtonDown(var Message: TWMLButtonDown);
begin
  RemoveSelection;

  if (FSelectionEnabled) then
  begin
    FillChar(FRegionRect, SizeOf(FRegionRect), 0);
    FStartX := RegionPtX(Message);
    FStartY := RegionPtY(Message);

    FSelecting := true;
  end;

  inherited;
end;

procedure TImage.WMMouseMove(var Message: TWMMouseMove);
var
  FCurX: double;
  FCurY: double;
begin
  if (FSelecting) then
  begin
    FCurX := RegionPtX(Message);
    FCurY := RegionPtY(Message);

    if (FStartX < FCurX) then
    begin
      FRegionRect.X := FStartX;
      FRegionRect.W := FCurX - FStartX;
    end
    else
    begin
      FRegionRect.X := FCurX;
      FRegionRect.W := FStartX - FCurX;
    end;

    if (FStartY < FCurY) then
    begin
      FRegionRect.Y := FStartY;
      FRegionRect.H := FCurY - FStartY;
    end
    else
    begin
      FRegionRect.Y := FCurY;
      FRegionRect.H := FStartY - FCurY;
    end;
    // RegionRect is now based on rotated image
    // GetRegionRect converts to the original coordinates

    DrawSelection;
  end;

  inherited;
end;

procedure TImage.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FSelecting := false;

  if (FSelectionEnabled) and
     (Assigned(FOnSelectionDone)) then
    FOnSelectionDone(Self);

  inherited;
end;

procedure TImage.RemoveSelection;
begin
  if FSelectionDrawn then
  begin
    Canvas.Pen.Width := LineWidth;
    SetROP2(Canvas.Handle, R2_NOT);

    Canvas.MoveTo(FCurRect.Left,  FCurRect.Top);
    Canvas.LineTo(FCurRect.Right, FCurRect.Top);
    Canvas.LineTo(FCurRect.Right, FCurRect.Bottom);
    Canvas.LineTo(FCurRect.Left,  FCurRect.Bottom);
    Canvas.LineTo(FCurRect.Left,  FCurRect.Top);
  end;

  FSelectionDrawn := false;
end;

procedure TImage.DrawSelection;
begin
  RemoveSelection;

  SetCurRect;

  Canvas.Pen.Width := LineWidth;
  SetROP2(Canvas.Handle, R2_NOT);
  Canvas.MoveTo(FCurRect.Left,  FCurRect.Top);
  Canvas.LineTo(FCurRect.Right, FCurRect.Top);
  Canvas.LineTo(FCurRect.Right, FCurRect.Bottom);
  Canvas.LineTo(FCurRect.Left,  FCurRect.Bottom);
  Canvas.LineTo(FCurRect.Left,  FCurRect.Top);

  FSelectionDrawn := true;
end;

end.
