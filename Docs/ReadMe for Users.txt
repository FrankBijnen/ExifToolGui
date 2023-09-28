This version has basically the same prereqs as the existing version.
I have tested this version with Windows 10, but it still works with Windows 8.1 and even Windows 7. 

- Place the exiftool.exe in a folder that is in your PATH. e.g.: C:\windows, or in the program location.
- For the preview rotation the Jhead.exe en Jpegtran.exe programs are no longer needed. The menu 'Various/Jpg: lossless autorotate' still use these programs.
- The previews rely on WIC. (Windows Imaging Component) All file types that have a good codec installed should work. 
  The standard Microsoft Codecs installed with Windows 10 should work. Please check. I use DNG and JPG myself, so these are tested.
- The internal browser used for OSM map relies on Edge. To use this the 'WebView2Loader.dll' should be placed alongside the executable. If you dont install this dll, 
  the progam will still work, but the OSM map will not be available.
    
  How to get the WebView2Loader.dll?
  Browse to https://www.nuget.org/packages/Microsoft.Web.WebView2, select the version (Eg. 1.0.1988-prerelease) and click on Download package. (on the Right) 
  This will get you a file named like 'microsoft.web.webview2.1.0.1988-prerelease.nupkg'. 
  Open this file with an archiver. (Winrar https://www.win-rar.com/ and 7-Zip https://www.7-zip.org/ are known to work)
  From this nupkg file extract the file 'runtimes\win-x86\native\WebView2Loader.dll' to the directory where you save the ExifToolGui.exe.       
        
  More info: https://docwiki.embarcadero.com/RADStudio/Sydney/en/Using_TEdgeBrowser_Component_and_Changes_to_the_TWebBrowser_Component

  To use the browser on pre Windows 10 download and install the Edge Canaray: https://www.microsoft.com/nl-nl/edge/download/insider?form=MA13FJ

Usage Notes:

The thumbnails are now being created in separate background threads. You can see in the statubar a message 'Remaining thumbnails to generate xx'.

The menu Program/Gui Color/Silver, Blue, Green have been replaced by styles. Check out the menu Progam/Style. A list is presented with all available styles. 
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
- A lot of changes to support UTF8 better. It should not affect functionality, but internally ExiftoolGui uses an ArgsFile where possible. 
  Advantages of Args files compared to passing parameters on the command line.
  - There is no limit on the size of the parameters. Command line has a limit of 32K.
  - All data can be passed as UTF8, thereby enabling all international characters.
  An option has been added 'Api WindowsWideFile'. If you have directories containing international characters it is recommended to enable this option.
  If this option is disabled, the full pathname of selected images is added to the args file.
  For this option to take effect, ExifTool 12.66 or later is required. See also: https://exiftool.org/ExifTool.html#WindowsWideFile

- The log window can now show the last 10 issued commands with there output and errors.
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

Frank Bijnen
