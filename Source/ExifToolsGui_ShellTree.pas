unit ExifToolsGui_ShellTree;

// Create eventhandlers Before and After contextmenu.
// Stop and start Exiftool, else it's impossible to remove the Directory

interface

uses System.Classes, System.SysUtils, Winapi.Windows, Vcl.Shell.ShellCtrls, ExifToolsGUI_MultiContextMenu;

type

  TShellTreeView = class(Vcl.Shell.ShellCtrls.TShellTreeView, IShellCommandVerbExifTool)
  private
    FOnBeforeContextMenu: TNotifyEvent;
    FOnAfterContextMenu: TNotifyEvent;
  protected
    procedure DoContextPopup(MousePos: TPoint; var Handled: boolean); override;
    procedure ShowMultiContextMenu(MousePos: TPoint);
  public
    procedure ExecuteCommandExif(Verb: string; var Handled: boolean);
    property OnBeforeContextMenu: TNotifyEvent read FOnBeforeContextMenu write FOnBeforeContextMenu;
    property OnAfterContextMenu: TNotifyEvent read FOnAfterContextMenu write FOnAfterContextMenu;
  end;

implementation

uses ExifToolsGUI_Thumbnails, ExiftoolsGui_ShellList, Vcl.ComCtrls, Vcl.Forms;

procedure TShellTreeView.ShowMultiContextMenu(MousePos: TPoint);
begin
  if (SelectedFolder = nil) then
    exit;
  InvokeMultiContextMenu(Self, SelectedFolder, MousePos);
end;

procedure TShellTreeView.DoContextPopup(MousePos: TPoint; var Handled: boolean);
var
  RightClickSave: boolean;
begin

  // RightClickSelect needs to be disabled within this method.
  // 'Selected' will be set to FRClickNode, leading to all kind of AV's (Especially WIN64)
  // See Vcl.ComCtrls at around line 12240 CNNotify, Case NM_RCLICK:
  RightClickSave := RightClickSelect;
  RightClickSelect := false;
  try
    if Assigned(FOnBeforeContextMenu) then
      FOnBeforeContextMenu(Self);

    ShowMultiContextMenu(MousePos);

  //  inherited;
    if Assigned(FOnAfterContextMenu) then
      FOnAfterContextMenu(Self);
  finally
    RightClickSelect := RightClickSave;
  end;
end;

procedure TShellTreeView.ExecuteCommandExif(Verb: string; var Handled: boolean);
var
  MyShellList: ExiftoolsGui_ShellList.TShellListView;
begin
  // Need a selected node
  if (Selected <> nil) then
  begin
    if (Verb = SCmdVerbRefresh) then
    begin
      Refresh(Selected);
      Handled := true;
    end;
  end;

  if (ShellListView is ExiftoolsGui_ShellList.TShellListView) then
  begin

    // Need an assigned listview with thumbnailsize
    MyShellList := ExiftoolsGui_ShellList.TShellListView(ShellListView);

    if (Verb = SCmdVerbGenThumbs) then
    begin
      GenerateThumbs(Path, false, MyShellList.ThumbNailSize, MyShellList.ShellListOnGenerateReady);
      Handled := true;
    end;

    if (Verb = SCmdVerbGenThumbsSub) then
    begin
      GenerateThumbs(Path, true, MyShellList.ThumbNailSize, MyShellList.ShellListOnGenerateReady);
      Handled := true;
    end;
  end;
end;

end.