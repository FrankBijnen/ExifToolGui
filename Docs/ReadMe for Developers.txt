This source can be compiled with the Delphi Community Edition. (11.3 at the time of writing).

There are 2 steps to take before compiling.

1) Install the styles. See the styles subdirectory.
2) Install the ShellControls.See the Vcl.ShellControls subdirectory.

Version 6.1.0.

Compiling for Win64.

1) The Project file (.dproj) has been changed to create a 64Bits executable
2) A .GroupProj has been added to facilitate compiling multiple platforms. Use the Build groups pane in the Project Manager.
3) You will need to put the 64Bits version of WebViewloader2.dll in the path.
4) 64 Bits has not yet been extensively tested. It is recommended to install the JEDI Code Library and enable {$DEFINE STACKTRACE} in the .dpr
   so you will get a stacktrace in the event of an exception.

Generating Thumbnails is moved to a separate unit. ExiftoolsGUI_Thumbnail.pas
The TShellListView extensions are moved to a separate unit. ExiftoolsGUI_ShellList.pas

The source has been reformatted within Delphi. (Ctrl/D) The default settings are used. Except for the right margin 80->150

Version 6.2.0.

Basically this version is about UTF8. All occurences of 'Ansi' string/char have been revised, and where possible changed to unicode.
Calling Exiftool was a challenge. The decision was made (by me) to use args files. These can be written with UTF8 encoding. Only the actual call to Exiftool has to be ANSI.
But that will only contain '-@ "<tempfilename>"' and we take care that tempfilename contains only ansi chars.
Another unit that needed revising was ExifInfo. Where possible I now use TEncoding.UTF8.Getstring to do the conversion to the 'foto' records.
Changing the type from AnsiString or ShortString to String made it necessary to introduce Clear methods to solve Memory Leaks.

Frank Bijnen
