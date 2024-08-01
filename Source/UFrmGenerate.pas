unit UFrmGenerate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, UnitScaleForm, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls;

const
  CM_ThumbGenStart =          WM_USer + 1;
  CM_ThumbGenProgress =       WM_USer + 2;
  CM_SubFolderScan =          WM_USer + 4;
  CM_SubFolderSort =          WM_USer + 5;
  CM_SubFolderSortProgress =  WM_USer + 6;
  CM_IconStart =              WM_USer + 7;
  CM_WantsToClose =           WM_USer + 10;

type
  TFrmGenerate = class(TScaleForm)
    LblGenerate: TLabel;
    PnlBottom: TPanel;
    PbProgress: TProgressBar;
    BtnClose: TBitBtn;
    procedure CMThumbGenStart(var Message: TMessage); message CM_ThumbGenStart;
    procedure CMThumbProgress(var Message: TMessage); message CM_ThumbGenProgress;
    procedure CMSubFolderScan(var Message: TMessage); message CM_SubFolderScan;
    procedure CMSubFolderSort(var Message: TMessage); message CM_SubFolderSort;
    procedure CMSubFolderSortProgress(var Message: TMessage); message CM_SubFolderSortProgress;
    procedure CMIconStart(var Message: TMessage); message CM_IconStart;
    procedure CMWantsToClose(var Message: TMessage); message CM_WantsToClose;
    procedure BtnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    WantsToClose: boolean;
  public
    { Public declarations }
    ModCount: integer;
  end;

var
  FrmGenerate: TFrmGenerate;

implementation

uses Vcl.Forms, ExifToolsGUI_Utils, UnitLangResources;

{$R *.dfm}

procedure TFrmGenerate.CMThumbGenStart(var Message: TMessage);
begin
  Caption := Format(StrGeneratingDThumbn, [Message.WParam, string(Message.LParam)]);
  PbProgress.Position := 0;
  PbProgress.Max := Message.WParam;
end;

procedure TFrmGenerate.CMThumbProgress(var Message: TMessage);
begin
  LblGenerate.Caption := string(Message.LParam);
  PbProgress.Position := PbProgress.Position +1;
end;

procedure TFrmGenerate.CMSubFolderScan(var Message: TMessage);
begin
  Caption := Format(StrScanningSubFolder, [string(Message.LParam), Message.WParam]);
  Self.Update;
  PbProgress.Position := 0;
  PbProgress.Max := 0;
end;

procedure TFrmGenerate.CMSubFolderSort(var Message: TMessage);
begin
  Caption := Format(StrSortingSubFolder, [Message.WParam, string(Message.LParam)]);
  PbProgress.Position := 0;
  PbProgress.Max := Message.WParam;
end;

procedure TFrmGenerate.CMSubFolderSortProgress(var Message: TMessage);
begin
  LblGenerate.Caption := string(Message.LParam);
  PbProgress.Position := Message.WParam;
  Application.ProcessMessages;
end;

procedure TFrmGenerate.CMIconStart(var Message: TMessage);
begin
  Caption := Format(StrIconsSubFolder, [Message.WParam, string(Message.LParam)]);
  PbProgress.Position := 0;
  PbProgress.Max := Message.WParam;
end;

procedure TFrmGenerate.CMWantsToClose(var Message: TMessage);
begin
  Message.Result := NativeInt(WantsToClose);
end;

procedure TFrmGenerate.FormShow(Sender: TObject);
begin
  LblGenerate.Caption := '';
  WantsToClose := false;
  ModCount := 100;
end;

procedure TFrmGenerate.BtnCloseClick(Sender: TObject);
begin
  Caption := StrWaitingForActive;
  WantsToClose := true;
end;

end.
