unit ExifToolsGUI_MultiContextMenu;

// Interface to allow custom commands in contextmenu of ShellTree and ShellList
// ExifToolsGui_ShellTree
// ExiftoolsGui_ShellList
interface

uses System.Classes, System.Win.Comobj, System.Sysutils,
     Winapi.Windows, Winapi.ShlObj, Vcl.Controls, Vcl.Shell.ShellCtrls;

const SCmdVerbRefresh       = 'Refresh';
      IDVerbRefresh         = $8000;
const SCmdVerbGenThumbs     = 'Generate Thumbnails';
      IDVerbGenThumbs       = $8001;
const SCmdVerbGenThumbsSub  = 'Generate Thumbnails (Incl Subdirs)';
      IDVerbGenThumbsSub    = $8002;

type
  IShellCommandVerbExifTool = interface
    ['{E45EF43F-909E-40F9-A59E-C3FCAC3C9E4B}']
    procedure ExecuteCommandExif(Verb: string; var Handled: boolean);
  end;

procedure InvokeMultiContextMenu(Owner: TWinControl; AFolder: TShellFolder; MousePos: TPoint;
                                 var ICM2: IContextMenu2; AFileList: TStrings = nil);

implementation

  // Contextmenu supporting multi select

procedure InvokeMultiContextMenu(Owner: TWinControl; AFolder: TShellFolder; MousePos: TPoint;
                                 var ICM2: IContextMenu2; AFileList: TStrings = nil);
var
  chEaten, dwAttributes: ULONG;
  PIDL: PItemIDList;
  CM: IContextMenu;
  Menu: HMenu;
  Command: LongBool;
  ICI: TCMInvokeCommandInfo;
  ICmd: integer;
  ZVerb: array [0..255] of AnsiChar;
  Verb: string;
  Handled: boolean;
  SCV: IShellCommandVerb;
  SCVEXIF: IShellCommandVerbExifTool;
  HR: HResult;
  ItemIDListArray: array of PItemIDList;
  Index: integer;
begin
  if (AFolder.ShellFolder = nil) then
    exit;

  if not Assigned(AFileList) then     // get the IContextMenu Interface for FilePIDL
  begin
    PIDL := AFolder.RelativeID;
    AFolder.ParentShellFolder.GetUIObjectOf(Owner.Handle, 1, PIDL, IID_IContextMenu, nil, CM);
  end
  else
  begin                             // get the IContextMenu Interface for the file array
    // Setup ItemIDListArray.
    SetLength(ItemIDListArray, AFileList.Count);
    for Index := 0 to AFileList.Count - 1 do
    begin
      // Get the relative PItemIDList of each file in the list
      OleCheck(AFolder.ShellFolder.ParseDisplayName(Owner.Handle, nil, PWideChar(AFileList[Index]), chEaten, PIDL, dwAttributes));
      ItemIDListArray[Index] := PIDL;
    end;
    AFolder.ShellFolder.GetUIObjectOf(Owner.Handle, AFileList.Count, ItemIDListArray[0], IID_IContextMenu, nil, CM);
  end;
  if CM = nil then
    exit;

  Winapi.Windows.ClientToScreen(Owner.Handle, MousePos);
  Menu := CreatePopupMenu;
  try
    CM.QueryContextMenu(Menu, 0, 1, $7FFF, CMF_EXPLORE or CMF_CANRENAME);
    CM.QueryInterface(IID_IContextMenu2, ICM2); // To handle submenus. Note: See WndProc of ShellTree and ShellList

    // Add Custom items on top
    InsertMenu(Menu, 0, MF_STRING or MF_BYPOSITION, IDVerbRefresh +1, PWideChar(SCmdVerbRefresh));
    InsertMenu(Menu, 1, MF_STRING or MF_BYPOSITION, IDVerbGenThumbs +1, PWideChar(SCmdVerbGenThumbs));
    InsertMenu(Menu, 2, MF_STRING or MF_BYPOSITION, IDVerbGenThumbsSub  +1, PWideChar(SCmdVerbGenThumbsSub));
    InsertMenu(Menu, 3, MF_SEPARATOR or MF_BYPOSITION, 0, PWideChar('-'));
    // Until here

    try
      Command := TrackPopupMenu(Menu,
                                TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON or TPM_RETURNCMD,
                                MousePos.X, MousePos.Y, 0, Owner.Handle, nil);
    finally
      ICM2 := nil;
    end;

    if Command then
    begin
      ICmd := LongInt(Command) - 1;
      HR := 0;
      case Word(ICmd) of
        0..$7fff:           // Standard 'Explorer like'
          begin
            HR := CM.GetCommandString(ICmd, GCS_VERBA, nil, ZVerb, SizeOf(ZVerb));
            Verb := string(ZVerb);
          end;
        IDVerbRefresh:      // Custom
          Verb := SCmdVerbRefresh;
        IDVerbGenThumbs:
          Verb := SCmdVerbGenThumbs;
        IDVerbGenThumbsSub:
          Verb := SCmdVerbGenThumbsSub;
      end;

      Handled := False;
      if not Handled and
         Supports(Owner , IShellCommandVerbExifTool, SCVEXIF) then
      begin
        HR := 0;
        SCVEXIF.ExecuteCommandExif(Verb, Handled);
      end;

      if not Handled and
         Supports(Owner , IShellCommandVerb, SCV) then
      begin
        HR := 0;
        SCV.ExecuteCommand(Verb, Handled);
      end;

      if not Handled then
      begin
        FillChar(ICI, SizeOf(ICI), #0);
        with ICI do
        begin
          cbSize := SizeOf(ICI);
          HWND := 0;
          lpVerb := MakeIntResourceA(ICmd);
          nShow := SW_SHOWNORMAL;
        end;
        HR := CM.InvokeCommand(ICI);
      end;

      if Assigned(SCV) then
        SCV.CommandCompleted(Verb, HR = S_OK);
    end;
  finally
    DestroyMenu(Menu);
  end;
end;

end.
