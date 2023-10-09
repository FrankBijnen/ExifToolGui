unit ExifToolsGui_LossLess;

interface
uses ExifTool;

type TLossLessMethod = (NotTested, JheadJpegTran, Internal);

function GetLossLessMethod: TLossLessMethod;
function HasJHead: boolean;
function HasJpegTran: boolean;
function PerformLossLess(AJpeg: string; Angle, Modulo: integer; OJpeg: string = ''): boolean;

implementation

uses sdJpegLossless, sdJpegImage, sdJpegTypes, sdJpegMarkers;

var LossLessMethod: TLossLessMethod;

function HasJHead: boolean;
begin
  result := ExecCMD('jhead', '');
end;

function HasJpegTran: boolean;
begin
  result := ExecCMD('jpegtran', '');
end;

function GetLossLessMethod: TLossLessMethod;
begin
  if (LossLessMethod = TLossLessMethod.NotTested) then
  begin
    if HasJHead and
       HasJpegTran then
      LossLessMethod := TLossLessMethod.JheadJpegTran
    else
      LossLessMethod := TLossLessMethod.Internal;
  end;
  result := LossLessMethod;
end;

function PerformLossLess(AJpeg: string; Angle, Modulo: integer; OJpeg: string = ''): boolean;
var LossLess: TsdLosslessOperation;
    JpegImage: TsdJpegImage;
    L, T, R, B:integer;
begin
  if (GetLossLessMethod <> TLossLessMethod.Internal) then
    exit(false);

  if (Angle = 0) and
     (Modulo = 0) then
    exit(false);

  result := true;
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
    if (OJpeg <> '') then
      JpegImage.SaveToFile(OJpeg)
    else
      JpegImage.SaveToFile(AJpeg);
  finally
    JpegImage.Free;
  end;
end;

initialization
begin
  LossLessMethod := TLossLessMethod.NotTested;
end;

end.
