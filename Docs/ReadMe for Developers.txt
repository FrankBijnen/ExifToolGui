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

Version 6.2.8.

Hotfix for Gecode requiring an Api-key. See Geomap.pas

Version 6.2.9

To overcome scaling issues:
Changed default to DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 and Scaled
Changed the TMainMenu to TActionMainMenuBar in Main.pas
Reviewed the bitmaps used. Created a subdirectory images, old ones are moved to Images_original
Added a TrayIcon, which display version info and resets window sizes
Moved GetFileVersionNumber to ExifToolGui_Utils.pas
Added a MonitorDpiChanged event
Code in MainDefs.pas reviewed, to be able to reset window sizes.
Added scaling factor to About

In order to only show hidden files for admins, code has been added to ExiftoolGui_utils to check for Elevated and Admin usage.
Added 'Administrator:' to caption if applicable.
Changed TFileStream to ThandleStream in ExifInfo.pas. To open the file ourselves with FileOpen, to prevent an exception.

Fixed typo in BreadcrumbBar directory name

Version 6.3.0

Added an installer. To build the installer yourself, you will need to install InnoSetup.
Created an RC file to hold some constants, mostly related to URL's
Added commandline parm /IniPath=
Layout changed, to accomodate for larger texts in other languages.
Style fixes. Change the background color of the ShellList selected line. Also for the BreadCrumbBar. Silver.vsf was changed.
Fixed OpenPictureDialog. Use WIC if default fails.
Added option to add custom ExifTool config
Added geolocate -api geolocation features
Dont throw error in Finalization. Causes memory leaks etc. Allow for 3 retries deleting temp dir

Version 6.3.1

- Reviewed code ExifInfo.pas.
  Removed global variables.
  Changed functions to become members of FotoRec. 
  Added Xml.VerySimple to parse XMP.

- Added code in Geomap.pas to show a track on the map. If trackpoints are written to 'ExifToolGUI.track' in the temp directory, it will be added.
  The Exiftool feature '-geotag -v4' is used to parse the Lat, Lon values. 
  See CreateTrkPoints in ExifToolsGui_Utils.pas.
  Setup extensions to use with -fast3. (.gpx and .kml) To speed up processing large tracklogs. Not configurable in GUI, only in INI file.

- Improved searching for places.
  Uses Exiftool to get a list of languages and countries to populate the comboboxes.
  Speed up Overpas api.

- Added the option to combine multiple values for Cities and Province.

- Simplified Chinese translation added. 

Version 6.3.2

- Updated the installer and preferences to allow the Alternate GeoLocation DB.
- Mainly bug fixes. See ChangeLog.txt

Version 6.3.5

- Changes to BreadcrumbBar.pas
  Fixed display when a UNC path is selected.

- Changes to exifinfo.pas 
  - Fixed an XMP bug.
  - Performance improvements JPG and Tiff. Prevent GUI calling exiftool for these types.

- Changes to ExifToolsGui_Shelllist.pas
  - Added TSubShellFolder, and PopulateSubDirs to allow scanning subfolders.
  - Refreshing updated, to prevent needless refreshing
  - FileName renamed to RelFilename. This gives the relative filename.
  - Reviewed Sorting and display Icons/Thumbnails to improve performance when icluding subfolders.
  - Introduced a new list 'FhiddenItems'. The folders that we do not want to show, but still are need 
    because they are referenced as 'ParentFolder'.
  - Changed looping thru Listview items to prevent calling 'OwnerDataFetch'.

    old:
    for AnItem in Items do
        if (AnItem.Selected) then

    new:
    for Index := 0 to Items.Count -1 do
    begin
      if (ListView_GetItemState(Handle, Index, LVIS_SELECTED) = LVIS_SELECTED) then

- Changes to ExifToolsGui_ValEdit.pas
  - Added code to show a proportional scrollbar

- Saving and restoring Form sizes and position more generic. See Maindef.pas

- Added more messages to FrmGenerate, to show progress with include subfolders.

- CopyMeta.pas, CopyMetaSingle.pas and RemoveMeta.pas
  - Redesigned to use configurable Listview
  - Added UFrmPredefinedTags and UFrmTagNames to maintain the predefined lists.

Version 6.3.6

- Created objects for ExifInfo and ExifTool to be able to use them multi-threaded.
  Introduced VarData, to make the XMP elements flexible, code-review, add more file-types and fields. EG Makernotes for Pentax, CRW and NIKON.
  Used SHGetDataFromIDList to get the filename with ext. Much more reliable and faster.
  Part of the redesign of the filelist.
  Created UnitColumnDefs to hold the file list details.
  Used many PNG's from freepik for the buttons
- Remove seClient from StyleElements for ShellTree and ShellList, to remove flickering. Set the background color manually.
- Introduce MidasLib, to be able to use ClientDatasets to configure the Filelists. Includes a Datamodule.
  Needed to create, because of conflicts with MidasLib, ExifToolsGui_ResourceStrings. It now uses rcdata to link in a complete txt file.
- Fixed Memory leaks. https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/using-umdh-to-find-a-user-mode-memory-leak
  The necessary PDB files were generated using map2dbg and cv2pdb
  The Vcl.Shell.Shellctrls.pas was modified, see readme in the Vcl.ShellControls directory.
- Reviewed usage of StringReplace. Created ReplaceAll that allows from and to pattern to be arrays.
- Fixes for getting the name of a TSubShellFolder.
- Check result of ReadFile in PipeStream, to prevent a hang in GUI. Could occur when ExifTool had compiler errors.
- BreadcrumBar. Make sure last element is always visible. Updates to colors for some styles.
- Xml.VerySimple. Add UTF16 LE and BE
- Added EnableFullTextSearch for ComboBox (Used in FrmTagNames)

Version 6.3.7
- This version is now built with RAD12.1 Community Edition.
  See issue 718 for details.
- Installer created with InnoSetup 6.4.0

Version 6.3.8
- Added Word selection and navigating. CTRL/SHIFT Left Right.
- Added auto complete options.	
  Using the IAutoComplete2 interface. https://learn.microsoft.com/en-us/windows/win32/api/shldisp/nn-shldisp-iautocomplete2
  See: ExifToolsGui_AutoComplete.pas, ExifToolsGui_AutoEdit.pas and ExifToolsGui_ValEdit.pas

Frank
