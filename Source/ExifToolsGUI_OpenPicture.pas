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

uses Vcl.Graphics, ExifInfo, ExifToolsGUI_Utils;

procedure TOpenPictureDialog.DoSelectionChange;
var
  ABitMap: TBitMap;
  Rotate: integer;
begin

  inherited DoSelectionChange;

  if (ImageCtrl.Picture.Graphic = nil) then // Inherited failed to load picture
  begin
    Rotate := 0;
    if FAutoRotatePreview then
    begin
      // Rotate ?
      GetMetadata(FileName, false, false, false, false);
      case Foto.IFD0.Orientation of
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

    // Load bitmap
    ABitMap := GetBitmapFromWic(WicPreview(FileName, Rotate, ImageCtrl.Width, ImageCtrl.Height));
    try
      ImageCtrl.Picture.Bitmap := ABitMap;
    finally
      ABitMap.Free;
    end;

  end;

end;

end.
