This version has basically the same prereqs as the existing version.
I have tested this version with Windows 10, but it still works with Windows 8.1 and even Windows 7. 

- Place the exiftool.exe in a folder that is in your PATH, or in the same location as ExifToolGui.exe.
  Alternatively you can use an installer provided by Olliver Betz. https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows.
- The Jhead.exe en Jpegtran.exe programs are no longer needed. This functionality is now handled by Delphi native code. The affected menus are marked 'deprecated' and will be removed in a next version.
- The previews rely on WIC. (Windows Imaging Component) All file types that have a good codec installed should work. 
  The standard Microsoft Codecs installed with Windows 10 should work. Please check. I use DNG and JPG myself, so these are tested.
- The internal browser used for OSM map relies on Edge and requires the WebView2Loader dll. If you dont install this dll, the progam will still work, but the OSM map will not be available.
    
  Downloading the WebView2Loader.dll.
     This dll can be downloaded from NuGet. I recommend to save it in the same directory as ExifToolGui.exe, but any directory that Windows searches will do.   

  1) Download only the DLL. Browse to https://nuget.info/packages/Microsoft.Web.WebView2. This will open the WebView2 in NuGet Package Explorer with the current version.
     In the 'Contents' pane expand the node 'runtimes\win-x86\native', or 'runtimes\win-x64\native' depending on your platform.
     Double-Click 'WebView2Loader.dll' to start the download.
  2) Download the complete package. Browse to https://www.nuget.org/packages/Microsoft.Web.WebView2, select the version (Eg. 1.0.2194-prerelease) and click on Download package. (on the Right) 
     This will get you a file named like 'microsoft.web.webview2.1.0.2194-prerelease.nupkg'. 
     Rename the .nupkg file to .zip to open it Windows Explorer, or open with an archiver.
     (Winrar https://www.win-rar.com/ and 7-Zip https://www.7-zip.org/ are known to work)
     Extract the file 'runtimes\win-x86\native\WebView2Loader.dll' or 'runtimes\win-x64\native\WebView2Loader.dll'.
        
  More info: https://docwiki.embarcadero.com/RADStudio/Sydney/en/Using_TEdgeBrowser_Component_and_Changes_to_the_TWebBrowser_Component

  To use the browser on pre Windows 10 download and install the Edge Canaray: https://www.microsoft.com/nl-nl/edge/download/insider?form=MA13FJ

Usage Notes:

The thumbnails are now being created in separate background threads. You can see in the statubar a message 'Remaining thumbnails to generate xx'.

The menu items Program/Gui Color/Silver, Blue, Green have been replaced by styles. Check out the menu Progam/Style. A list is presented with all available styles. 
Changing to a different style means recreating and repainting the forms on the fly. It is recommended to restart the program after changing a style.

The OSM Map works different from the Google Map. Because I could not get the Google Map working I had to look at the docs to see how it should work. It is
worth mentioning 2 things.
1. The Find for places has been re-enabled as of version 6.0.3
   Type in the name of the City, optionally followed by a comma and the country. (E.g. Madrid or Madrid, Spain)
   If exactly 1 hit is found the coordinates will be filled in the textbox, and the map will reposition.
   Else a selection list is displayed, where you can choose the city.
   Notes: The queries are handled by https://geocode.maps.co. They allow 2 queries per second.
          At least 5 characters are required to start then search.

2. Use Ctrl + Click on the map to get the coordinates. These are shown in the text box.

Changed with version 6.1.0
Windows 64 Bits support has been added. If you decide to use that version please unpack the win-x64 version of the WebView2Loader.dll.

Thumbnails setting have been moved to a separate tab on the preferences form. Additional options available are:
- Disable automatic generating of the thumbnails.
- Manually generate the thumbnails.
- Cleaning the thumbnail cache.

Changed with version 6.1.1
The context menus for the ShelList and the ShellTree have been updated. (The menu that appears with a right click)
- Refresh and Generate Thumbnails are merged with the standard "Explorer like context menu's"
- The ShellList context works for multi-select.
- Ctrl/C, Ctrl/X and Ctrl/V added for the ShellList.

Changed with version 6.2.0
- A lot of changes to support UTF8 better. It should not affect functionality, but internally ExiftoolGui uses an Args file where possible. 
  Advantages of Args files compared to passing parameters on the command line.
  - There is no limit on the size of the parameters. Command line has a limit of 32K.
  - All data can be passed as UTF8, thereby enabling all international characters.
  An option has been added 'Api WindowsWideFile'. If you have directories containing international characters it is recommended to enable this option.
  If this option is disabled, the full pathname of selected images is added to the args file.
  For this option to take effect, ExifTool 12.66 or later is required. See also: https://exiftool.org/ExifTool.html#WindowsWideFile

- The log window can now show the last 10 issued commands with their output and errors.
  Use Ctrl/A, Ctrl/C to copy the data to the clipboard.
  The commmands issued are initially shown as executed. Always as Args file. But via buttons they can be converted to CommmandLine format.
  Also an option has been added to create a Cmd file, or Powershell script. To replay the commands.

- The Exiftool direct now has 2 execution modes.
  StayOpen
    This is the default mode, it uses the exiftool.exe already active for the directory, to send an args file created from the supplied parameters to.

  Classic
    Provided for compatibility. It starts a new exiftool.exe and passing all parameters via an args file.

  Notes: You can check in the log window what is actually sent.
         The Args file always contains -charset UTF8 and -charset Filenames=UTF8, EXCEPT when you add -L as a parameter. This is added for backward compatability, although I dont see how it should work better.

- Adding tags to the Workspace.
  If you have duplicate Tag Names in your workspace, they will not be discarded anymore.
  An option has been added to the Preferences to allow Double Click to add/remove to the workspace.

Changed with version 6.2.5
- Lossless rotate and crop is now coded in Delphi. You dont need external programs Jhead and JpegTran anymore. The affected menu-items are marked 'Deprecated', they will continue to work, but removed in a next release.
  The deprecated menu-items are replaced by new ones that use the Delphi code. They will show a dialog giving you more control. 
  See also: 'Readme Lossless rotate_Import_Export previews.txt'

- GeoCoding has been enhanced. You can now select a provider, and reverse GeoCoding has been implemented. Find the location (Country, Province, City) from GPS coordinates and store it in metadata.
  By default GeoCoding is NOT enabled. Even the 'The Find for places' introduced in version 6.0.3 is disabled by default! To enable go to Preferences/GeoCoding and check 'Enable GeoCoding'.
  See also: 'Readme GeoCoding.txt'

- A 'find' edit box has been added to the metadata, allowing you to search for tag names and values.

- Various small fixes, for bugs encountered when testing. 
  If you find a bug, or think you found one, dont hesitate to report. You can create an issue on Github (https://github.com/FrankBijnen/ExifToolGui/issues) or post on the ExifTool forum (https://exiftool.org/forum/index.php?board=7.0). 

Changed with version 6.2.6
- The documentation has been updated to reflect the changes from V516 to V626. You can access it from the program via 'Help/Online documentation', or by using this link:
  https://htmlpreview.github.io/?https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md

Changed with version 6.2.7
- Added the option to show folders (Directories) in the filelist. No Metadata/Image functions are available on the folders.
- Added the option to show a Breadcrumb (Address bar)in the filelist. 
  Both options can be dis/enabled in Preferences/other and only serve for easier navigation.
- Some fixes for styles were applied. Especially the style 'Green' was updated, it had some colours wrongly defined and the caption bar was ugly.
- Added a hint window for the metadata values. It can be disabled in Prefrences/Other by setting the timeout value to 0.
- Added the option to add Custom Options to Exiftool. Not needed for Normal usage. 
  If you want to experiment: Add the option '-htmldump'. (without the quotes) Open the log window, and check 'Show all commands'. Select any file.
  Dont forget to remove the option afterwards! 
- Fixed an error message in the generated Powershell script. It would always show the error 'Native Command Error'.
- Fixed an error message in the generated Powershell script. It would always show the error 'Native Command Error'.
- Added experimental support for 4K monitors. Or better: Monitors with a non-standard resolution or scaling. 
  If you want to experiment with this see: Readme 4K monitor.txt in the Docs directory.

Changed with version 6.2.8
  This was a hotfix release. Primarily released to fix issue #219, because https://geocode.maps.co started requiring an api_key.
  With this version you can add your api_key, that you can get for free after registering, to the preferences.
  These fixes are also included:
  - Camera settings for FujiFilm RAW are displayed in the Filelist.
  - Added '-Gps:all' and '-wm cg' to 'Export/Import/Copy from single file...' allowing to only copy Gps data, and not overwrite existing data.

Changed with version 6.2.9
- The experimental support for 4K monitor has become much more mature. The default settings should be correct, and provide scaling while maintaining a crisp look.
- Added a tray icon in the windows taskbar to reset the window size to default. You need to make sure the icon is not hidden in Windows.
- Optionally show hidden files and folders. You need to be an admin and enable the option in Preferences.

Changed with version 6.3.0
- A nasty bug was fixed that would prevent the OSM map to display if the GPS coordinates had negative values. (West or South)
- Created an installer. Recommended if you dont use ExifToolGui as a portable program.
- Added version checks for ExifTool and ExifToolGui. See Help/Check Versions.
- The About form was moved to Help/About
- Translations available, when installed via the installer. The language will be selected according to your Windows settings.
  Or use the commandline parm /Lang=xxx (NLD, DEU, FRA, ITA, PTB, ESP ENU) to force a specific language.
- Style fixes for darkmode styles. The selected file(s), folder are now clearly visible.
- Added support for ExifTool -geolocate and -api geolocation.
  For better compatibility with the new ExifTool features the location found is stored differently. For more details see: Readme GeoCoding.txt
- Added the option to specify a custom ExifTool Config

Changed with version 6.3.1
- ExifToolGui is now officially licensed under GPL V3. Dont worry, it's free.  
- More settings can now be saved and loaded like the Workspace settings. E.G. Exiftool Direct commands, Custom view and User defined fields. 
- Geocoding enhancements. Searching for places, and reverse geocoding. See: Readme GeoCoding.txt for details.
- Track logs can now be shown on the map, by selecting a track log in the filelist and clicking on 'Show on Map'.
- To speed up processing '.GPX' and '.KML' files, they are processed by default with '-fast3'. To disable this behaviour find the line:
  'Fast3FileTypes=*.GPX|*.KML' in ExifToolGuiV6.ini and change it to 'Fast3FileTypes='. Or change the list of extensions. 

Changed with version 6.3.2
- The Installer can now be used to download and install an alternate (larger) GeoLocation DB.
  In Preferences/GeoCoding you can specify this directory.
- Bugfixes.
  - Sort files always on Filename, within the chosen sort column. E.G. Within FileType on Filename.
  - Dont prompt to save a tag value in the Workspace, if no data is entered.
  - Keyboard shortcuts and refreshing for the Directory and Filelist panel.
  - Fixed geotaggging XMP sidecar files.
  - Message 'tag already exists' wrongly appears when adding tag to the Custom View.
  - Show label on the OSM Map, if internet access is not enabled. 

Changed with version 6.3.4
- The Installer can now be used to download and install the new ExifTool V12.88 format.

Changed with version 6.3.5
- Fixed a bug using UNC paths.
- Redesigned the functions 'Remove metadata', and 'Copy metadata...'
  - The checkboxes have been replaced by a listview.
  - Your selection will be saved and restored. (E.G. Remembered)
  - Added a Preview to check the affected tags.
  - You can add your own predefined lists, with their own tags.
  - When adding a tag GUI can help you find the correct one.
    By showing sample data, or selection from a list of writable tags.
- Added the option to show files in subfolders.
  - Make sure you enabled 'Show folders' in Preferences.
  - Define a 'File filter' with '/s', and select that.

Changed with version 6.3.6
- File dates and renaming enhanced.
- File list redesigned. New drop down buttons are used in the filelist. More details shown, for more file types.
- Configuration of the filelist enhanced.
  You can select the readmode for internal and user-defined lists.
  For internal lists (camera settings, location info and about photo) fields can be customized.
  You can define multiple User-defined lists.
  Adding fields improved, by using drop-down lists, and showing sample values.
  You can check the file filter to use on startup (E.g.: *.jpg)
- Improved performance by starting ExifTool multi-threaded to get the details, when sorting the filelist, or selecting.
- Improved performance by buffering and disabling style elements for the file list.
- Fixed memory leaks.

Changed with version 6.3.7
- Drag and drop enhancements. You can now drop multiple files (not directories) in GUI. All dropped files will be selected.
  Also GUI can be used as a dragsource. EG. Dragging files from GUI to an Explorer window, or any application that accepts dragged files
- A bug has been fixed, that could prevent displaying a preview of a RAW file. 
  If you experience problems with preview Enable 'Allow Non Microsoft Wic codecs' in Preferences/Thumbnails
- Add exiftool '-diff' feature. See documentation on Various/Show diff metadata
- Add 'QuickTime' group in date time functions.
- Removed MessageBeep, or Bell, when using the Enter key on input fields.
- Small bug fixes.

Changed with version 6.3.8
- More keyboard usage improvements. In the workspace manager you can define auto complete + drop down lists. 
  CTRL + (SHIFT) Left, Right arrow moves to/selects the previous/next word in the Workspace and ExifTool direct.
  Redesigned the Workspace manager, to support this new feature.
- Exporting, importing setting has been revised. Allowing to save a selection of settings to export and import.

Changed with version 6.3.9
- Scrolling of the Metadata panel changed. It now works the same as the File list.
- Last selected tab of the Metadata panel is saved and restored.
- Added computing a Hash of selected files in the filelist and Workspace. Added menu item in Various to create Hash files.
- Added support for displaying and editing regions in the preview.

Changed with version 6.3.10
- You can now export the 'File filters' together with other settings in an ini file. Drag and drop is supported for ini files.
- Multiple selection has changed. Fixed a few bugs with Ctrl/A. The 'First selected file' now is the file that you selected first, not the file on top of the list.
- Embedded '-execute' in ExifTool Direct are now handled better. Before the '-execute' the selected files are added, after '-execute' the options are repeated. 
  This should be more intuitive.
- Added more Base layers to the OSM map. If you register at https://www.maptiler.com and enter your Api Key in preferences/GeoCoding you get even more.

Frank
