unit ExifToolsGui_LossLess;

interface

uses ExifTool, System.Types;

type TLossLessMethod = (NotTested, JheadJpegTran, Internal);

function PerformLossLess(AJpeg: string; Angle, Modulo: integer; OJpeg: string = ''): TSize;

implementation

uses sdJpegLossless, sdJpegImage, sdJpegTypes, sdJpegMarkers;

function PerformLossLess(AJpeg: string; Angle, Modulo: integer; OJpeg: string = ''): TSize;
var LossLess: TsdLosslessOperation;
    JpegImage: TsdJpegImage;
    L, T, R, B:integer;
begin
  result.cx := 0;
  result.cy := 0;

  JpegImage := TsdJpegImage.Create(nil);
  try
    JpegImage.LoadFromFile(AJpeg);
    LossLess := JpegImage.Lossless;

    case Angle of
      90: LossLess.Rotate90;
     180: LossLess.Rotate180;
     270: LossLess.Rotate270;
    end;

    if (Modulo <> 0) then
    begin
      L := 0;
      T := 0;
      R := JpegImage.Width - (JpegImage.Width mod Modulo);
      B := JpegImage.Height - (JpegImage.Height mod Modulo);
      if (R <> JpegImage.Width) or
         (B <> JpegImage.Height) then
        LossLess.Crop(L, T, R, B);
    end;

    result.cx := JpegImage.Width;
    result.cy := JpegImage.Height;

    if (OJpeg <> '') then
      JpegImage.SaveToFile(OJpeg)
    else
      JpegImage.SaveToFile(AJpeg);
  finally
    JpegImage.Free;
  end;
end;

end.
