This version has basically the same prereqs as the existing version.
I have tested this version with Windows 10, but it still works with Windows 8.1 and even Windows 7. 

- Place the exiftool.exe in a folder that is in your PATH. e.g.: C:\windows, or in the program location.
- For the preview rotation the Jhead.exe en Jpegtran.exe programs are no longer needed. The menu 'Various/Jpg: lossless autorotate' still use these programs.
- The previews rely on WIC. (Windows Imaging Component) All file types that have a good codec installed should work. 
  The standard Microsoft Codecs installed with Windows 10 should work. Please check. I use DNG and JPG myself, so these are tested.
- The internal browser used for OSM map relies on Edge. To use this the 'WebView2Loader.dll' should be placed alongside the executable. If you dont install this dll, 
  the progam will still work, but the OSM map will not be available.
  
   More info: https://docwiki.embarcadero.com/RADStudio/Sydney/en/Using_TEdgeBrowser_Component_and_Changes_to_the_TWebBrowser_Component

   To use the browser on pre Windows 10 download and install the Edge Canaray: https://www.microsoft.com/nl-nl/edge/download/insider?form=MA13FJ

Usage Notes:

The thumbnails are now being created in separate background threads. You can see in the statubar a message 'Remaining thumbnails to generate xx'.
While this process is busy you can not change to a different folder.

The menu Program/Gui Color/Silver, Blue, Green have been replaced by styles. Check out the menu Progam/Style. A list is presented with all available styles. 
Changing to a different style means recreating and repainting the forms on the fly. It is recommended to restart the program after changing a style.

The OSM Map works different from the Google Map. Because I could not get the Google Map working I had to look at the docs to see how it should work. It is
worth mentioning 2 things.
1. The Find works only for GPS coordinates, you cant search for places. (E.g. Madrid)
2. Use Ctrl + Click on the map to get the coordinates. These are shown in the text box.

Frank Bijnen