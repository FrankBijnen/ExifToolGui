To compile ExifToolGui you need to install the ShellCtrls, using a slightly modified version of the Embarcadero Shell Controls.
Due to the Copyright statement I can't distribute that source, but the Community Edition comes with the source code of these controls.

- Find the files Vcl.Shell.ShellConsts.pas and Vcl.Shell.ShellCtrls.pas in the Embarcadero Source directory and copy them to this directory.

- Modify the Vcl.Shell.ShellCtrls.pas file.

1) In the 'public' declarations of TShellFolder, after 'property Details...' add these lines.

//ExifTool
    property DetailStrings: TStrings read FDetails;
//ExifTool_x

2) In the 'private' declarations of TCustomShellListView, comment 'procedure EnumColumns'.

//ExifTool
//  procedure EnumColumns;
//ExifTool_x

3) In the 'protected' declarations of TCustomShellListView, before 'procedure 'procedure KeyDown...', add 'procedure EnumColumns' decorated with 'virtual'.

//ExifTool
    procedure EnumColumns; virtual;
//ExifTool_x

4) In the 'public' declarations of TCustomShellListView, after 'property Folders...', add these lines.

//ExifTool
    property FoldersList: TList read FFolders;
//ExifTool_x     

5) In the 'protected' declarations of TCustomShellTreeView, add 'virtual' to 'InitNode'. (Comment the original line, and add a new with ' virtual;')

//ExifTool
//    procedure InitNode(NewNode: TTreeNode; ID: PItemIDList; ParentNode: TTreeNode);
    procedure InitNode(NewNode: TTreeNode; ID: PItemIDList; ParentNode: TTreeNode); virtual;
//ExifTool_x

Fixes for memory leaks that show clearly when selecting many files (2500+) combined with column sorting.

6) In 'function StrRetToString', after 'if Assigned(StrRet.pOleStr) then' replace

     Result := StrRet.pOleStr

with this block

//ExifTool_Leak
//        Result := StrRet.pOleStr
      begin
        Result := StrRet.pOleStr;
        CoTaskMemFree(StrRet.pOleStr);
      end
//ExifTool_Leak_x

7) In 'procedure TCustomShellListView.Populate;', after 'AFolder := TShellFolder.Create(FRootFolder, ID, NewFolder);'

add this block

//ExifTool_Leak
        CoTaskMemFree(ID);
//ExifTool_Leak_x

Performance fixes
8) In procedure TCustomShellTreeView.Refresh(Node: TTreeNode);    

After these lines:
    ThisLevel := Node.Level;
    OldNode := Node;

Before these lines:
   if Assigned(Node.Data) then
   begin


You find this repeat until:
    repeat
      Temp := FolderExists(TShellFolder(OldNode.Data).AbsoluteID, NewNode);
      if (Temp <> nil) and OldNode.Expanded then
        Temp.Expand(False);
      OldNode := OldNode.GetNext;
    until (OldNode = nil) or (OldNode.Level = ThisLevel);


Replace it with:
//Performance
// Refreshing folder with many folder takes very long.
// Check OldNode.Expanded first before calling expensive FolderExists
(*
    repeat
      Temp := FolderExists(TShellFolder(OldNode.Data).AbsoluteID, NewNode);
      if (Temp <> nil) and OldNode.Expanded then
        Temp.Expand(False);
      OldNode := OldNode.GetNext;
    until (OldNode = nil) or (OldNode.Level = ThisLevel);
*)
    repeat
      if (OldNode.Expanded) then
      begin
        Temp := FolderExists(TShellFolder(OldNode.Data).AbsoluteID, NewNode);
        if (Temp <> nil) then
          Temp.Expand(False);
      end;
      OldNode := OldNode.GetNext;
    until (OldNode = nil) or (OldNode.Level = ThisLevel);
//Performance_X

9) In procedure TCustomShellTreeView.InitNode(NewNode: TTreeNode; ID: PItemIDList; ParentNode: TTreeNode);
Note: Need to set property DeferSubFolderCheck from ExifToolsGui_ShellTree to true, 

//Performance
//    NewNode.HasChildren := SubFolders;
    if (NewNode.StateIndex >= -1) then
      NewNode.HasChildren := SubFolders;
//Performance_x


Note: For documentation purposes the original line is kept, but commented. 

- Open the ShellControls.groupproj in Delphi, Compile and Install the 32 Bits version. The 64 Bits also works, but is not needed for the IDE.

Notes:

- If you already have these controls installed, make the modifications described above to your version.
- The subdirectory 'Vcl.ShellControls' is in the Search path of ExifToolGUI. 

