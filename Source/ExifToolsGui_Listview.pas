unit ExifToolsGui_Listview;

interface
uses
  System.Classes,
  Winapi.Messages,
  Vcl.ComCtrls, Winapi.CommCtrl;

type
  TListView = class(Vcl.ComCtrls.TListView)
  private
    FOnColumnResized: TNotifyEvent;
  protected
    procedure WMNotify(var Msg: TWMNotify); message WM_NOTIFY;
  public
    procedure ScrollToItem(ItemIndex: Integer);
    property OnColumnResized: TNotifyEvent read FOnColumnResized write FOnColumnResized;

  end;

implementation

uses
  System.Types;

procedure TListView.WMNotify(var Msg: TWMNotify);
var
  Column: TListColumn;
  ResizedColumn: integer;
begin
  inherited;

  case Msg.NMHdr^.code of
    HDN_ENDTRACK,
    HDN_DIVIDERDBLCLICK:
      begin
        ResizedColumn := pHDNotify(Msg.NMHdr)^.Item;
        Column := Columns[ResizedColumn];
        if (Assigned(FOnColumnResized)) then
          FOnColumnResized(Column);
      end;
    HDN_BEGINTRACK:
      ;
    HDN_TRACK:
      ;
  end;
end;

procedure TListView.ScrollToItem(ItemIndex: Integer);
var
  R: TRect;
begin
  R := Items[ItemIndex].DisplayRect(drBounds);
  Scroll(0, R.Top - R.Height);
end;

end.
