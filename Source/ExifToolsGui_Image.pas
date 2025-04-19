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
    FCurRect: TRect;
    FStartX: double;
    FStartY: double;
    FCurX: double;
    FCurY: double;
    FRegionRect: TRegionRect;
    FSelectionDrawn: boolean;
    FSelecting: boolean;
    FSelectionEnabled: boolean;
    FImageDimensions: TPoint;
    FOnSelectionDone: TNotifyEvent;
  protected
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    function RegionPtX(Message: TWMMouse): double;
    function RegionPtY(Message: TWMMouse): double;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RemoveSelection;
    procedure DrawSelection(ARect: TRegionRect);
    property ImageDimensions: TPoint read FImageDimensions write FImageDimensions;
    property SelectionDrawn: boolean read FSelectionDrawn write FSelectionDrawn;
    property RegionRect: TRegionRect read FRegionRect;
    property OnSelectionDone: TNotifyEvent read FOnSelectionDone write FOnSelectionDone;
    property SelectionEnabled: boolean read FSelectionEnabled write FSelectionEnabled;
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

    DrawSelection(FRegionRect);
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

procedure TImage.DrawSelection(ARect: TRegionRect);
begin
  RemoveSelection;

  FCurRect.Left  := Round(FImageDimensions.X * ARect.X) + ((Width  - FImageDimensions.X) div 2);
  FCurRect.Top   := Round(FImageDimensions.Y * ARect.Y) + ((Height - FImageDimensions.Y) div 2);
  FCurRect.Width := Round(FImageDimensions.X * ARect.W);
  FCurRect.Height:= Round(FImageDimensions.Y * ARect.H);

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
