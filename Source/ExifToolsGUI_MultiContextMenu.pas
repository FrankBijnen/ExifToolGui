unit ExifToolsGUI_MultiContextMenu;

// Interface to allow custom commands in contextmenu of ShellTree and ShellList
// ExifToolsGui_ShellTree
// ExiftoolsGui_ShellList
interface

uses System.Classes, System.Win.Comobj, System.Sysutils,
     Winapi.Windows, Winapi.ShlObj, Vcl.Controls, Vcl.Shell.ShellCtrls;

// Do not localize.
// Localized strings are found in UnitLangResources
const IdCmdFirst            = 1;
      IdCmdLast             = $7fff;
const SCmdVerbRefresh       = 'Refresh';
      IDVerbRefresh         = $8000;
const SCmdVerbGenThumbs     = 'GenThumbnails';
      IDVerbGenThumbs       = $8001;
const SCmdVerbGenThumbsSub  = 'GenThumbnailsSub';
      IDVerbGenThumbsSub    = $8002;
const SCmdSelLeft           = 'SelLeft';
      IDVerbSelLeft         = $8003;
const SCmdVerDiff           = 'DiffMetadata';
      IDVerbDiff            = $8004;

type
  IShellCommandVerbExifTool = interface
    ['{E45EF43F-909E-40F9-A59E-C3FCAC3C9E4B}']
    procedure ExecuteCommandExif(Verb: string; var Handled: boolean);
    procedure CommandCompletedExif(Verb: string; Succeeded: boolean);
  end;

function InvalidMixFoldersAndFiles(FileList: TStrings; var IsFolder: boolean): boolean;
procedure DoContextMenuVerb(AFolder: TShellFolder; Verb: PAnsiChar);
procedure InvokeMultiContextMenu(Owner: TWinControl;
                                 AFolder: TShellFolder;
                                 MousePos: TPoint;
                                 var ICM2: IContextMenu2;
                                 AFileList: TStrings = nil);

implementation

uses
  UnitLangResources, ExifToolsGui_ShellList;

// Contextmenu supporting multi select

function InvalidMixFoldersAndFiles(FileList: TStrings; var IsFolder: boolean): boolean;
var
  Index: integer;
  SubFolder: TShellFolder;
begin
  result := false;
  IsFolder := false;
  for Index := 0 to FileList.Count - 1 do
  begin
    SubFolder := TShellFolder(FileList.Objects[Index]);
    if (Index = 0) then
    begin
      IsFolder := TSubShellFolder.GetIsFolder(SubFolder);
      if (IsFolder) and
         (FileList.Count > 2) then
        result := true;
    end
    else
      result := result or (IsFolder <> TSubShellFolder.GetIsFolder(SubFolder));
    if (result) then
      break;
  end;
end;

procedure InvokeMultiContextMenu(Owner: TWinControl;
                                 AFolder: TShellFolder;
                                 MousePos: TPoint;
                                 var ICM2: IContextMenu2;
                                 AFileList: TStrings = nil);
var
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

  SelCount: integer;
  IsFolder: boolean;
  MixingFolderAndFiles: boolean;
  MenuPosition: UINT;

  procedure AddMenuItem(Id: UINT; Caption: string; var Position: UINT);
  var
    Flags: UINT;
  begin
    if (Id = 0) then
      Flags := MF_SEPARATOR or MF_BYPOSITION
    else
      Flags := MF_STRING or MF_BYPOSITION;
    InsertMenu(Menu, Position, Flags, Id +1, PWideChar(Caption));
    Inc(Position);
  end;

begin
  if (AFolder.ParentShellFolder = nil) then
    exit;

  MixingFolderAndFiles := false;
  IsFolder := TSubShellFolder.GetIsFolder(AFolder);
  if not Assigned(AFileList) then                 // get the IContextMenu Interface for FilePIDL
  begin
    PIDL := AFolder.RelativeID;
    HR := AFolder.ParentShellFolder.GetUIObjectOf(Owner.Handle, 1, PIDL, IID_IContextMenu, nil, CM);
    SelCount := 1;
  end
  else
  begin                                           // get the IContextMenu Interface for the file array
    SetLength(ItemIDListArray, AFileList.Count);  // Setup ItemIDListArray.
    for Index := 0 to AFileList.Count - 1 do
      ItemIDListArray[Index] := TShellFolder(AFileList.Objects[Index]).RelativeID;
    SelCount := AFileList.Count;
    MixingFolderAndFiles := InvalidMixFoldersAndFiles(AFileList, IsFolder);
    HR := AFolder.ParentShellFolder.GetUIObjectOf(Owner.Handle, AFileList.Count, ItemIDListArray[0], IID_IContextMenu, nil, CM);
  end;
  if ((HR <> 0) or
      (CM = nil)) and
      (Supports(Owner, IShellCommandVerbExifTool, SCVEXIF)) then
  begin                                           // Pretend nothing happened
    Handled := false;
    SCVEXIF.ExecuteCommandExif('', Handled);
    exit;
  end;

  Winapi.Windows.ClientToScreen(Owner.Handle, MousePos);
  Menu := CreatePopupMenu;
  try
    CM.QueryContextMenu(Menu, 0, IdCmdFirst, IdCmdLast, CMF_EXPLORE or CMF_CANRENAME);
    CM.QueryInterface(IID_IContextMenu2, ICM2);   // To handle submenus. Note: See WndProc of ShellTree and ShellList

    // Add Custom items on top
    MenuPosition := 0;
    AddMenuItem(IDVerbRefresh, SrCmdVerbRefresh, MenuPosition);
    AddMenuItem(IDVerbGenThumbs, SrCmdVerbGenThumbs, MenuPosition);
    AddMenuItem(IDVerbGenThumbsSub, SrCmdVerbGenThumbsSub, MenuPosition);
    AddMenuItem(0, '-', MenuPosition);
    if (MixingFolderAndFiles = false) then
    begin
      if ((SelCount = 1) and IsFolder) or
         ((SelCount > 0) and not IsFolder) then
        AddMenuItem(IDVerbSelLeft, SrCmdSelLeft, MenuPosition);
      AddMenuItem(IDVerbDiff, SrCmdVerbDiff, MenuPosition);
      AddMenuItem(0, '-', MenuPosition);
    end;
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
      ICmd := LongInt(Command) - IdCmdFirst;
      HR := 0;
      case Word(ICmd) of
        0..IdCmdLast:                             // Standard 'Explorer like'
          begin
            HR := CM.GetCommandString(ICmd, GCS_VERBA, nil, ZVerb, SizeOf(ZVerb));
            Verb := string(ZVerb);
          end;
        IDVerbRefresh:                            // Custom
          Verb := SCmdVerbRefresh;
        IDVerbGenThumbs:
          Verb := SCmdVerbGenThumbs;
        IDVerbGenThumbsSub:
          Verb := SCmdVerbGenThumbsSub;
        IDVerbSelLeft:
          Verb := SCmdSelLeft;
        IDVerbDiff:
          Verb := SCmdVerDiff;
      end;

      Handled := False;
      if not Handled and
         Supports(Owner, IShellCommandVerbExifTool, SCVEXIF) then
      begin
        HR := 0;
        SCVEXIF.ExecuteCommandExif(Verb, Handled);
      end;

      if not Handled and
         Supports(Owner, IShellCommandVerb, SCV) then
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

      if Assigned(SCVEXIF) then
        SCVEXIF.CommandCompletedExif(Verb, HR = S_OK);
    end;
  finally
    DestroyMenu(Menu);
  end;
end;

procedure DoContextMenuVerb(AFolder: TShellFolder; Verb: PAnsiChar);
var
  ICI: TCMInvokeCommandInfo;
  CM: IContextMenu;
  PIDL: PItemIDList;
begin
  if AFolder = nil then Exit;
  FillChar(ICI, SizeOf(ICI), #0);
  with ICI do
  begin
    cbSize := SizeOf(ICI);
    fMask := CMIC_MASK_ASYNCOK;
    hWND := 0;
    lpVerb := Verb;
    nShow := SW_SHOWNORMAL;
  end;
  PIDL := AFolder.RelativeID;
  AFolder.ParentShellFolder.GetUIObjectOf(0, 1, PIDL, IID_IContextMenu, nil, CM);
  CM.InvokeCommand(ICI);
end;

end.
