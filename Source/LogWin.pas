unit LogWin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TFLogWin = class(TForm)
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    MemoErrs: TMemo;
    PnlMidle: TPanel;
    MemoOuts: TMemo;
    MemoCmds: TMemo;
    Splitter3: TSplitter;
    PctExecs: TPageControl;
    TabExecs: TTabSheet;
    PCTCommands: TPageControl;
    TabCommands: TTabSheet;
    PCTOutput: TPageControl;
    TabOutput: TTabSheet;
    PCTErrors: TPageControl;
    TabErrors: TTabSheet;
    LBExecs: TListBox;
    ChkShowAll: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LBExecsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
  private
    { Private declarations }
    LogId: Integer;
  public
    { Public declarations }
    EtOutStrings: TStringList;

    FExecs: TStringList;
    FCmds: TStringList;
    FEtOuts: TStringList;
    FEtErrs: TStringList;
    function NextLogId: integer;
  end;

var
  FLogWin: TFLogWin;

implementation

uses Main, MainDef;

{$R *.dfm}

function TFLogWin.NextLogId: integer;
begin
  inc(LogId);
  if (LogId > 9) then
    LogId := 0;
  result := LogId;
end;

procedure TFLogWin.FormCreate(Sender: TObject);
begin
  ReadGUILog;
  EtOutStrings := TStringList.Create;

  FExecs := TStringList.Create;
  FExecs.Text:=StringOfChar(#10,10);
  FCmds := TStringList.Create;
  Fcmds.Text:=StringOfChar(#10,10);
  FEtOuts := TStringList.Create;
  FEtOuts.Text:=StringOfChar(#10,10);
  FEtErrs := TStringList.Create;
  FEtErrs.Text:=StringOfChar(#10,10);
  LogId := -1;
  ChkShowAll.Checked := false;
end;

procedure TFLogWin.FormDestroy(Sender: TObject);
begin
  FExecs.Free;
  FCmds.Free;
  FEtOuts.Free;
  FEtErrs.Free;
  EtOutStrings.Free;
end;

procedure TFLogWin.FormShow(Sender: TObject);
begin
  LBExecs.Items.Assign(FExecs);
end;

procedure TFLogWin.LBExecsClick(Sender: TObject);
begin
  MemoCmds.Text:=(FCmds[LBExecs.ItemIndex]);
  MemoOuts.Text:=(FEtOuts[LBExecs.ItemIndex]);
  MemoErrs.Text:=(FEtErrs[LBExecs.ItemIndex]);
end;

procedure TFLogWin.MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('A')) and (ssCTRL in Shift) then // Ctrl+A
    TMemo(Sender).SelectAll;
  if (Key = Ord('C')) and (ssCTRL in Shift) then // Ctrl+C
    TMemo(Sender).CopyToClipboard;
end;

end.
