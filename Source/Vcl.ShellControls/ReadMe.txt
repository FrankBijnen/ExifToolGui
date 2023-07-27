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

- Open the ShellControls.groupproj in Delphi, Compile and Install the 32 Bits version. The 64 Bits also works, but is not needed for ExifToolGUI.

Notes:

- If you already have these controls installed, make the modifications described above to your version.
- The subdirectoy 'Vcl.ShellControls' is in the Search path of ExifToolGUI. 

