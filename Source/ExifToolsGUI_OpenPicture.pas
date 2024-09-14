unit ExifToolsGUI_OpenPicture;

// Extend TOpenPictureDialog to fallback to WIC to display preview

interface

uses Vcl.Extdlgs;

type
  TOpenPictureDialog = class(Vcl.Extdlgs.TOpenPictureDialog)
  private
    FAutoRotatePreview: boolean;
  protected
    procedure DoSelectionChange; override;
  public
    property AutoRotatePreview: boolean read FAutoRotatePreview write FAutoRotatePreview;
  end;

implementation

uses System.SysUtils, Vcl.Graphics, Vcl.Buttons, ExifInfo, ExifToolsGUI_Utils;

procedure TOpenPictureDialog.DoSelectionChange;
var
  Foto: FotoRec;
  ABitMap: TBitMap;
  Rotate: integer;
  FPreviewButton: TSpeedButton;
begin

  inherited DoSelectionChange;

  if (ImageCtrl.Picture.Graphic = nil) then // Inherited failed to load picture
  begin
    Rotate := 0;
    if FAutoRotatePreview then
    begin
      // Rotate ?
      Foto := GetMetadata(FileName, []);
      case Foto.IFD0.OrientationValue of
        0, 1:
          Rotate := 0; // no tag or don't rotate
        3:
          Rotate := 180;
        6:
          Rotate := 90;
        8:
          Rotate := 270;
      end;
    end;

    // Load bitmap from WIC
    ABitMap := GetBitmapFromWic(WicPreview(FileName, Rotate, 0, 0));
    if Assigned(ABitmap) then
    begin
      try
        ImageCtrl.Picture.Bitmap := ABitMap;

        // PreviewButton is private!
        FPreviewButton := TSpeedButton(FindComponent('PreviewButton'));
        if Assigned(FPreviewButton) then
          FPreviewButton.Enabled := true;

      finally
        ABitMap.Free;
      end;
    end;
  end;

end;

end.
