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

Frank Bijnen
