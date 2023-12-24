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

Version 6.2.5.

To replace the Jhead and Jpegtran external programs the NativeJpg library (by Nils Haeck, SimDesign BV.) was added. The source code was stripped, only the code needed for
lossless rotate and crop was kept. A few modifications were made to support Win64. The logging was extensive and used base classes like TDebugPersistent. This also was stripped. See SdDebug.pas.
You can find the modified source in the subdirectory NativeJpg, wich was also added to the search path.
See also the docs and License in the subdirectory NativeJpg.

Adding reverse geocoding involved adding a 2nd provider: Overpass. The simple solution was to duplicate the methods and rename to xxxxx_overpass and xxxxx_geocode. See Geomap.pas
I do agree it would be better to create classes and subclasses. We'll leave that for a next release.

To finally resolve the issue that ExifToolGui would hang, because the ExifTool cmd was not terminated by a CRLF, I decided to add a CRLF in ET_OpenExec if it does not end with a CRLF.
Note that instead of a CRLF, a bare LF will also work, but I decided to leave that as-is.

When looking at the original code to format the output of ExifTool I figured it needed an overhaul. So I created TPipeStream in Exiftool_PipeStream.pas. 
TPipeStream handles: Conversion to UTF8, Scanning for {Ready..., Scanning for ======= (it indicates a new file) and uses an event to communicate.
Previous versions would first read it into a Buffer (array of byte), then write it to a stream, load it in a Stringlist, then the stringlist would be checked line by line, and converted to UTF8.  
TPipeStream is more efficient, because it scans the memory directly backward, and does not use TStringList. The reads are performed in a separate thread.
You will notice the difference when ExifTool outputs > 100.000 lines.

example of an inefficiency: (It scans forward for {ready, where scanning backward would be a lot faster)
    //========= Cleanup ETout ======================
    i:=0;
    while i<ETout.Count do begin
      //no difference observed between UTF8ToString() and UTF8ToAnsi()
      ETout[i]:=UTF8ToAnsi(ETout[i]);
      if pos('{r',ETout[i])>0 then ETout.Delete(i) //delete '{ready..}' lines
                              else inc(i);
    end;

(Very) Long Filenames. Filenames that exceed MAX_PATH. The problem is that Windows 10 and later seem to support it in the File Explorer, but not all API's do.
For example: SHILCreateFromPath will only work for < MAX_PATH.
Some changes to make the basic things, like GetMetaData, ThumbNails and Preview, work are:
- Take the 'DisplayName' from the ShellList. Often a '\\?\' will be prepended, what is needed.
- Get rid of AssignFile, Blockread etc. Replace by TFileStream.
- Replace SHCreateItemFromParsingName by SHCreateItemFromIDList
Surely this is not the end....

A few new units, and forms were added.

And various fixes like: generating Thumbnails, selecting a directory while the shelllist is sorted, etc. See also: https://github.com/FrankBijnen/ExifToolGui/issues/118
 
Version 6.2.7.

Option to add folders (Directories) to the filelist.
Option to enable the control BreadCrumbBar by Andreas Rejbrand. You can find the source in the subdirectory BreadbrumbBar.
Added experimental support for 4K monitors. See UnitScaleForm.pas and UnitDpiAwareness.pas

Frank
