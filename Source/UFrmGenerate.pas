unit UFrmGenerate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls;

const
  CM_ThumbGenStart = WM_USer + 1;

const
  CM_ThumbGenProgress = WM_USer + 2;

const
  CM_ThumbGenWantsToClose = WM_USer + 3;

type
  TFrmGenerate = class(TScaleForm)
    LblGenerate: TLabel;
    PnlBottom: TPanel;
    PbProgress: TProgressBar;
    BtnClose: TBitBtn;
    procedure CM_Start(var Message: TMessage); message CM_ThumbGenStart;
    procedure CM_Progress(var Message: TMessage); message CM_ThumbGenProgress;
    procedure CM_WantsToClose(var Message: TMessage); message CM_ThumbGenWantsToClose;
    procedure BtnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    WantsToClose: boolean;
  public
    { Public declarations }
  end;

var
  FrmGenerate: TFrmGenerate;

implementation

uses exiftoolsgui_utils;

{$R *.dfm}

procedure TFrmGenerate.CM_Start(var Message: TMessage);
begin
  Caption := Format('Generating %d thumbnails for: %s', [Message.WParam, string(Message.LParam)]);
  PbProgress.Position := 0;
  PbProgress.Max := Message.WParam;
end;

procedure TFrmGenerate.CM_Progress(var Message: TMessage);
begin
  LblGenerate.Caption := string(Message.LParam);
  PbProgress.Position := PbProgress.Position + 1;
end;

procedure TFrmGenerate.FormShow(Sender: TObject);
begin
  LblGenerate.Caption := '';
  WantsToClose := false;
end;

procedure TFrmGenerate.BtnCloseClick(Sender: TObject);
begin
  Caption := 'Waiting for active tasks to complete';
  WantsToClose := true;
end;

procedure TFrmGenerate.CM_WantsToClose(var Message: TMessage);
begin
  Message.Result := NativeInt(WantsToClose);
end;

end.
