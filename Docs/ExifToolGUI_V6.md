<html><head>
<meta http-equiv="Keywords" content="ExifTool,ExifToolGUI,exif,editor,viewer,reader">
<meta http-equiv="Description" content="ExifToolGUI">
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" type="text/css" href="ExifToolGUI_V6_files/page.css">
</head>

<body>
<table class="A4">
<tbody><tr><td class="A4">
<h1>ExifToolGUI for Windows v6.xx</h1><hr>
<h2>Introduction</h2>
In the summer of 2023 I decided to revive the ExifToolGui project initally created by <b>Bogdan Hrastnik</b>.
This revival resulted in <b>Version 6</b><br>
Read his complete documentation <a href="https://htmlpreview.github.io/?https://github.com/FrankBijnen/ExifToolGui/blob/Development/Docs/Original%20notes/ExifToolGUI_V516.htm"><b>here</b></a><br><br>
This was his intro, I will quote it now, because it still holds for me:<br><br>
<em>
There are many tools for viewing/editing metadata inside image files. In my opinion, <b>ExifTool</b> by <b>Phil Harvey</b>, is the best I've found so far. Here's why:<br>
<ul>
<li>-it shows more metadata tags than any other tool,</li>
<li>-it allows to edit almost any metadata tag,</li>
<li>-it is very secure to use, is regulary updated and has the best possible support.</li>
</ul>
<br>
The only downside for many potential users is the fact, that ExifTool is
 a "command-line" utility. That means, there's no Graphic User Interface
 (GUI), so all work must be done by typing commands inside "Command 
Prompt" window. Such approach gives ExifTool great flexibility, but is 
somehow difficult to use -especially for those, who don't use ExifTool 
regularly.<br>
<br>

So, I've decided to make some simple ExifTool GUI for my private use. 
There are already some GUI's that make use of ExifTool, but some of them
 are not flexible enough (for my needs) and/or have somehow limited use.
 When making ExifToolGUI, the main goal was:<br>
<ul>
<li>-view all metadata that ExifTool recognizes,</li>
<li>-ability to edit most frequently used metadata tags,</li>
<li>-batch capability (where appropriate), means: you can select multiple files and modify them at once.</li>
</ul>
<br>
Basic idea behind GUI is, to keep it <u>simple!</u> Thus, only those options are implemented, which I believe, are essential for majority of users.<br>
</em>
<br>
<font class="red"><b>Important changes in ExifToolGUI v6.xx</b></font><br>
<ul>
<li>The source code now compiles with Delphi Community Edition. Version used, as of writing, Rad 11.3.</li>
<li class="tab">No (closed source) 3rd party libraries needed.</li>
<li class="tab">All source code provided on GitHub.</li>
<li>Added styles.</li>
<li>Image preview is handled by WIC (Windows Imaging Component).</li>
<li>Google Maps is replaced by Open Street Map.</li>
<li>64 Bits executable available.</li>
<li>Optionally copy the stack trace to the clipboard in case of an exception. Available in the released executables, If you compile from source code the Project-JEDI/JCL is required.</li>
<li>Better support for international characters. All internal code now uses Unicode (UTF16), to interface with Exiftool UTF8.</li>
<li>Enhanced Log Window. The last 10 commands are shown, with their respective output and error. Option to replay the command in PowerShell/Cmd prompt.</li>
<li>The external programs Jhead.exe and Jpegtran.exe are no longer needed. Rotation, and cropping, are handled in Delphi native code. With a modified library called NativeJpg by SimDesign B.V. (I tried contacting SimDesign to verify the Licence requirements, but was unable to.)</li>
<li>Exporting and Importing previews has been revised, and offer greater flexibility.</li>
<li>GeoCoding has been enhanced. You can now choose from 2 providers (https://overpass-api.de and https://geocode.maps.co) and lookup City, Province and Country from GPS coordinates AKA reverse GeoCoding.</li>
<li>Option added to show folders in the FileList panel.</li>
<li>Option added to show a Breadcrumb (Address bar) in the FileList panel.</li>
<li>Possibility to add Custom options to Exiftool.</li>
<li>Support for <a href="Readme%204K%20monitor.txt"><b>4K monitors.</b></a></li>
<li>Option added to show hidden files and folders. <b>Admins only</b></li>
<li>Enhanced integration. Add to Context menu in Windows explorer, Single instance App and minimize to Tray</b></li>
<li>Camera settings, Location info and About photo in Filelist detail supported for more File types</b></li>
</ul>
<a href="changelog.txt"><b>See changelog.txt for a complete list of issues.</b></a>

<a name="m_reqs_general">
<h2>Requirements and preparations</h2>
ExiftoolGUI should run on Windows 7, 8 32-64bit. However, it is highly recommended to use Windows 10 or 11 when you plan to use the OSM map, or GEOcoding.<br>
It will not run on Windows XP or earlier!<br>

<a name="m_reqs_exiftool">
<h3>1. ExifTool</h3>
You only need to download the "Windows Executable" zip file from <a href="https://exiftool.org/"><b>here</b></a>.
After unzipping, depending on your Windows Explorer settings, you will see:<font color="CC0000">exiftool(-k)</font> or <font color="CC0000">exiftool(-k).exe</font>
Rename it to either <font color="CC0000">exiftool</font> or <font color="CC0000">exiftool.exe</font> and put it in the same folder as ExifToolGui.<br><br>
<u>Notes:</u>
<ul>
<li>Bogdan Hrastnik recommended to copy exiftool into the Windows directory, but I strongly advise not to.
Microsoft makes it harder with every Windows version to modify System directories.<br>
If you want Windows to be able to always find ExifTool, then add the directory where it is saved in your PATH.<br>
</li>
<li>If you prefer an installer, I recommend the installer provided by <a href="https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows"><b>Oliver Betz</b></a></li>
<li>You can overrule the location of exiftool in Preferences/other.</li>
<li>In case you've done something wrong in this regard, you'll see an error message when GUI starts.</li>
</ul>

<h3><a name="m_reqs_exiftoolgui">2. ExifToolGUI</h3>
You can download GUI from <a href="https://github.com/FrankBijnen/ExifToolGui/releases"><b>here</b></a>.
GUI doesn't need to be "installed". Just download the executable for your platform (ExifToolGui.exe or ExifToolGui_X64.exe) into any directory, create a Desktop shortcut and GUI is ready to use.<br>
<br>
<u>Notes:</u>
<ul>
<li>It is not recommended to put ExifToolGUI.exe into directories owned by operating system (Windows and Program files), unless you <u>know</u> what you're doing.<br></li>
<li>If a path is added at the commandline GUI will start in that path. (eg ExifToolGui &quot;c:\foto&quot;)</li>
<li>If a file is added at the commandline GUI will open that file and start in the path of the file. (eg ExifToolGui &quot;c:\foto\imgp001.jpg&quot;)</li>
<li>To open a file when GUI is already running, you can drag and drop a file from Windows Explorer.</li>
<li>Portable notes:
GUI doesn't write anything into the registry file. It does however create temporary files in the %TEMP% directory. <br>
It will save its settings in %APPDATA%\ExifToolGUI\ExifToolV6.ini, unless you use the commandline parameter <u>/DontSaveIni</u>.<br>  
It was decided not to save the INI file in the same directory as the executable, because that location may not be writable.<br>
<a href="Readme Portable.txt"><b>See Readme Portable.txt for more info on portable use.</b></a><br>
</li>
</ul>

<h3><a name="m_reqs_exiftoolgui"><a name="m_edge">3. Edge browser needed for OSM map<a></h3>
If you don't need the OSM map functionality, you can skip this step.<br>
The OSM map is hosted by an internal web browser based on Edge. There are 2 requirements. The <b>Edge Runtime</b> and the <b>WebView2Loader.dll</b>.

<h4><a name="m_edge_runtime">Edge Runtime<a></h4>
On modern Windows versions the runtime will be available standard. If it is missing on your system, or you want to install the latest version
<a href="https://www.microsoft.com/edge/download/insider?form=MA13FJ">use this link and install one of Edge Canary, Dev or Beta.</a><br>

<h4><a name="m_edge_dll">WebView2Loader.dll</a></h4>
This dll is not standard available and can be downloaded from NuGet. I recommend to save it in the same directory as ExifToolGui.exe, but any directory that Windows searches will do.
If the dll can not be loaded you will get this dialog.<br><br>
<img src="ExifToolGUI_V6_files/WebView2Loader_dll.jpg"><br><br><br>
<ul>
<li>
Download only the DLL from <a href="https://nuget.info/packages/Microsoft.Web.WebView2/"><b>Package explorer</b></a>.<br>
Navigate in the <b>Contents</b> pane to runtimes\<b>win-x86</b>\native or runtimes\<b>win-x64</b>\native, depending on your platform.<br>
Double-click on WebView2Loader.dll to start the download.<br><br>
<img src="ExifToolGUI_V6_files/package explorer.jpg"><br><br>
</li>
<li>
Download the complete package from <a href="https://www.nuget.org/packages/Microsoft.Web.WebView2"><b>NuGet</b></a> manually.<br>
Select the version (Eg. 1.0.2194-prerelease) and click on <b>Download package</b>. (on the Right)<br>
This will get you a file named like 'microsoft.web.webview2.1.0.2194-prerelease.nupkg'.<br>
Rename the .nupkg file to .zip to open it in Windows Explorer, or open it with an archiver. <br>(Winrar https://www.win-rar.com/ and 7-Zip https://www.7-zip.org/ are known to work)<br>
Extract the file 'runtimes\win-x86\native\WebView2Loader.dll' or 'runtimes\win-x64\native\WebView2Loader.dll'.</li>
</ul>
<a href="https://docwiki.embarcadero.com/RADStudio/Sydney/en/Using_TEdgeBrowser_Component_and_Changes_to_the_TWebBrowser_Component">More info for developers from Embarcadero</a>
<br>

<h3>4. Wish to see thumbnails of raw image files?</h3>
Of course you do. What you need is a "raw codec", usually available for free from the camera manufacturer.
The best I've found so far is "FastPictureViewer codec" (from <a href="http://www.fastpictureviewer.com/codecs/">here</a>).
It is very fast, covers many raw formats and is free for personal use.<br>
<a href="Readme Using Codecs.txt"><b>Readme Using Codecs.txt</b></a>

<h3>5. jhead.exe &amp; jpegtran.exe</h3>
These files are no longer needed.<br>
<br>
<br>

That's all you need. And when a new ExifTool or GUI version is available, you only need to repeat process as described above.<br>
<br>

<a name="gui_screen"><img src="ExifToolGUI_V6_files/gui_screen.jpg"></a><br>
<br>
<h3>Content</h3>
<b>Menu:</b><br>
<li><a href="#m_program">Program</a> menu</li>
<ul><li><a href="#m_workspace">Workspace manager</a> menu</li></ul>
<ul><li><a href="#m_style">Style</a> menu</li></ul>
<li><a href="#m_options">Options</a> menu</li>
<li><a href="#m_exp_imp">Export/Import</a> menu</li>
<li><a href="#m_modify">Modify</a> menu</li>
<li><a href="#m_various">Various</a> menu</li>
<li><u>Help/Online Documentation</u> menu</li>
<br>
<b>Panels:</b><br>
<li><a href="#p_filelist">Filelist</a> panel</li>
<li><a href="#p_etdirect">ExifTool direct</a> panel</li>
<li><a href="#p_metadata">Metadata</a> panel</li>
<li><a href="#p_osmmap">OSM Map</a> panel</li>
<br>
<a href="#final">Final words</a><br><br>

<h2><a name="m_program">Program menu</a></h2>
<h3>About</h3>
-Displays ExifTool and GUI versions and links.<br>
<br>
<h3>Preferences</h3>
<img src="ExifToolGUI_V6_files/preferences_general.jpg"><br>
<br><br>
<b><u>General</u></b> settings tab<br>
<br>
<b>Metadata language</b><br>
Here you can choose the language for displaying metadata tag names and values in <font class="blue">Metadata</font> panel.
Selected language is also used when working in <font class="blue">ExifTool direct</font> mode (output to <font class="blue">Log window</font>),
or when exporting metadata to external TXT files.<br>
<br>
<b>Let GUI rotate JPG preview image</b><br>
In most cases, you will need to check this option, because Windows 
doesn't automatically rotate JPG images according to Exif:Orientation 
tag value. Anyway, if this option is checked, then GUI won't 
change/rotate your JPG files physically: rotation (if needed) is applied
 in GUI's memory after the image has been loaded for displaying. If 
checked, GUI will only rotate image in <font class="blue">Preview</font> panel -thumbnails aren't rotated.<br>
<br>
<b>Enabling internet access</b><br>
By default, this option is unchecked and if you are a bit paranoid, then
keep it that way. In that case however, you won't be able to use GUI's <font class="blue">OSM Map</font>
feature for geotagging your images manually. After changing this
option, you'll need to close and reopen GUI, to make this feature 
available. You have to enable this option also if you want to use GeoCoding.<br>
<br>
<b>Default Startup &amp; Export folder</b><br>
I think, these two options don't need some special explanation.<br>
<br>
<b>Separator character</b><br>
Some metadata tags (i.e. keywords, etc.) can hold multiple values and to
 be able to separate these values when showing, some "special" character
 is needed. Keep in mind, that this character isn't stored into 
metadata! -it is just used to separate values when displaying 
multi-value tags on <u>your</u> PC.<br>
<br>
<b>Save Filelist Details state on exit</b><br>
If checked, then <font class="blue">Details:</font> button state and selected Filelist view (Standard filelist, Camera settings,..etc.) are saved when closing GUI.<br>
<br><br>

<img src="ExifToolGUI_V6_files/preferences_thumbnails.jpg"><br>
<br><br>
<b><u>Thumbnail</u></b> settings tab<br>
<br>
<b>Thumbnail size: 96, 128 or 160 pix</b><br><br>
<b>Generate thumbnails as needed</b><br>
Depending on the type of files, the codecs installed, and of course the system, generating thumbnails can be a time-consuming process.
You can disable automatic generating here.<br><br>
<b>Generate thumbnails now</b><br>
if you dont have 'Generate thumbnails as needed' checked, this option allows you to manually generate them. You can also generate them manually from the context-menus on the folder and filelist.<br><br>
<b>Cleanup Thumbnails</b><br>
The thumbnails that GUI generates are the same as Windows explorer uses. They share the same folder on your hard-drive.
Sometimes the cache gets corrupt, or you just want to cleanup. It can be done with the standard Windows program 'CleanMgr'.
For your convenience you can start that program here.<br>
<ul>
<li>First click on Setup Disk cleanup for thumbnails. If you dont know what 'Clean set' is used for, stay with the value '0000'. <br>
In the next dialog keep only 'Thumbnail' checked, and click on OK.</li>
<li>Cleanup thumbnails will start the actual cleaning.</li>
</ul>
<br><br>

<img src="ExifToolGUI_V6_files/preferences_geocoding.jpg"><br>
<br><br>
<b><u>GeoCoding</u></b> settings tab<br>
<br>
Here you can setup the GeoCoding parameters. Typically you only have to check <b>Enable GeoCoding</b><br>
For an in-depth explanation see <a href="Readme GeoCoding.txt"><b>Readme GeoCoding.txt</b></a>
<br><br>

<img src="ExifToolGUI_V6_files/preferences_shell.jpg"><br>
<br><br>
<b><u>Shell Integration</u></b> settings tab<br>
<br>
<b>-application When minimized move to tray</b><br>
Put an icon for GUI in the Windows System Tray, also known as the notification area, when GUI is minimized.<br>
You will likely have to make the icon visible in <b>Windows Taskbar Settings</b>.<br>
By clicking on the icon on the taskbar you can easily start GUI. A Right Click on the icon will show a menu with Version info, and the option to reset the window sizes.<br>
<br>
<img src="ExifToolGUI_V6_files/trayicon.jpg"><br>
<br>
<b>-application Single instance</b><br>
Allow only one running instance of GUI. If you try to start a second instance of GUI, it will try to make the running instance visible.<br>
Use this option when you have registered GUI in the Contextmenu, or you will get a new instance of GUI everytime you use the context menu.<br>
<br>
<b>Register ExifToolGui in Contextmenu (Requires elevation)</b><br>
The buttons Add and Remove are only enable when you have started GUI as Admin.<br>
If you have added GUI to the contextmenu you can start it by Right clicking on a folder.<br>
<img src="ExifToolGUI_V6_files/contextmenu.jpg"><br>
<br><br>
<u>Notes:</u>
<ul>
<li>For Windows 11 you can find the context menu item under 'Show more options', or use SHIFT/Right click. If you search the net you can also find 'registry tweaks' that show the contextmenu directly.<br></li>
<li>When you decide to add GUI to the Contextmenu data is written to the registry. If you have concerns with that, because GUI is not <b>Portable</b>, dont use it.<br> </li>
</ul>
<br><br>

<img src="ExifToolGUI_V6_files/preferences_other.jpg"><br>
<br><br>
<b><u>Other</u></b> settings tab<br>
<br>
<b>Workspace: Move focus to next tag/line after value is entered</b><br>
By default, when you hit Enter button to confirm changing tag value in
Workspace, focus of selected tag/line automatically moves to next
tag/line. If you prefer focus would remain on currently edited tag/line, then uncheck this option.
<br><br>
<b>Workspace: Double Click adds/removes tags</b><br>
If you check this, double-clicking in the Workspace will remove a tag,
double-clicking on one of the tabs Exif, Xmp, Iptc, Maker, All will add that tag to the Workspace.
<br><br>
<b>Exiftool.exe location</b><br>
If you need to override the location of exiftool.exe you can do that here.<br><br>
<b>Filelist: Show Folders in Filelist</b><br>
The default setting is to only show files in the Filelist panel. If you enable this option, also folders (directories) will be shown, allowing easier navigation.<br><br>
<b>Filelist: Show Hidden Folders and Files in Filelist (Admin required)</b><br>
Will also show hidden Folders and Files in the Folder Treeview and the Filelist panels. You need to be Admin to use this, and not everything you see may be readable/writeable.<br><br>
<b>Filelist: Show Breadcrumb (Address bar) in Filelist</b><br>
Enable a BreadCrumb bar on top of the filelist. Allows for easier navigating.<br><br>
<b>Filelist: Show Hidden Folders and Files in Filelist (Admin required)</b><br>
Will also show hidden Folders and Files in the Folder Treeview and the Filelist panels. You need to be Admin to use this, and not everything you see may be readable/writeable.<br><br>
<b>Filelist: Enable 'Camera Settings', 'Location info and 'About photo' for all file types. (Slower)</b><br>
If you have set the <b>Details</b> of the filelist panel to any of the above options, GUI will show that info only for known filetypes.<br>
If a file is not supported, or it does not contain the data, GUI will show 'File type unsupported'.<br>
Generally speaking this works only for filetypes that have <b>IFD0, ExifIFD or XMP</b> groups. <br>
Examples that work: Tiff based raw (PEF, NEF, CRW, CR2, DNG), Jpeg, and recently I added FujiFilm (RAF) and CR3.<br>
Examples that do not work: PDF, MP4<br> 
Enabling this option will result in calling Exiftool to get the data. While this works, it will slow-down getting the filedetails considerably. It is thus not enabled by default.<br><br>
<b>Hint pause timeout in Millisecs</b><br>
Hovering over the metadata panel will display the complete metadata value as a hint. This was added because long values are often not completely visible.<br>
Setting this value to 0 (zero) will effectively disable the hints.
<br><br>

<h3><a name="m_workspace">Workspace manager</a></h3>
Here you define what will be shown in <font class="blue">Metadata</font> panel when <font class="blue">Workspace</font> is selected. Besides <font class="blue">ExifTool direct</font> option, this is the most powerfull GUI feature.<br>
<br>
<img src="ExifToolGUI_V6_files/workspace.jpg"><br>
<br>
<br>
<b>Tag name column</b><br>
Here you define tag name you prefer to be displayed for particular 
metadata tag. These tag names don't have any influence on actual tag 
names and you can write anything here, i.e. instead of "ISO", you can 
have "Noise maker" here.<br>
Tag names written here, can have different "behaviour" in case special 
character is used for their ending. For now, GUI uses following ending 
characters:<br>
<br>

<font class="red">#</font> -if tag name ends with this character (see 
Flash# and Orientation# above), then content of this tag will be 
displayed as usual. However, when modifying this tag, you need to enter 
numerical value.<br><br>
<font class="red">&ast;</font> -if tag name ends with this character (see Artist* above), then that means,
that value defined in <font class="blue">Hint text</font> will be used as default value for this tag.
In this case, if you right-click on <font class="blue">Metadata</font> panel (when in <font class="blue">Workspace</font> view mode),
pop-up menu appears and there's option <font class="blue">Fill in default values</font> -you get the idea, I hope.<br><br>
<font class="red">?</font> -if tag name ends with this character (see
Geotagged? above), then that means, that you're not interested on tag
value itself -what you wish to see is, if particular tag is defined or
not. <u>Note:</u> You won't be able to edit such tag in <font class="blue">Workspace</font> view.<br><br>
<font class="red">±</font> -if tag name ends with this character (see
Type± in main screenshot above), then you'll be allowed to enter
multiple values for single tag at once (i.e. keywords and similar). Of
course, you can't use this feature for any tag, so read (Iptc &amp; Xmp)
metadata documentation to findout what tags support multi-values. Btw.
you can get ± character with Alt+0177 (typing 0177 on numerical
keyboard, while pressing Alt key).<br>
<br>
<u>Note:</u> I might use further special ending characters in future, so try to avoid their usage at the end (or start) of tag names.<br>
<br>

<b>Tag definition column</b><br>
Here you define tags as recognized by ExifTool. And if needed, you can
also add # character at the end of tag name -this will force displaying
numerical tag value (try with <font class="brown">-exif:Orientation#</font> to see the difference).
Of course, only one single tag can be defined per line.<br>
To separate group of tags in <font class="blue">Workspace</font> view, special "fake" tag is used: <font class="brown">-GUI-SEP</font>
(see "About photo" on above screenshot).<br>
<br>

<b>Hint text column</b><br>
Text entered here is your <u>short</u> "private" help, which will be displayed in GUI's status bar when you start modifying tag value:<br>
<img src="ExifToolGUI_V6_files/hint.jpg"><br>
<br>
I hope you can recognize the power of <font class="blue">Workspace manager</font>:
 YOU define any metadata tag you wish to change regulary. Btw. you can 
move defined tags up/down by clicking &amp; moving tag name in first 
(Tag name) column.<br>
<br>
<h3>Workspace definition file: Load/Save</h3>
All tags defined for <font class="blue">Workspace</font> are automatically saved into <b>ExifToolGUIv6.ini</b> file.
So, when you start GUI, <font class="blue">Workspace</font> content is the same as it was when you used GUI the last time.
If for whatever reason, you might wish to save your <u>current</u> <font class="blue">Workspace</font>
content -to create a backup of your Workspace, so to speak. And when needed, you just load previously saved Workspace definition file again.<br>
<br>
When you choose <font class="blue">Save</font>, you'll be asked where to
save the file and you'll need to set the filename. By default, save
directory will allways be the directory where ExifToolGUI.exe is saved;
however, you can choose any other directory.<br>
When you choose <font class="blue">Load</font>, again, default starting
directory will be the one, where ExifToolGUI.exe is. And if you've
messed with your Workspace inbetween, you can choose to load Workspace
from ExifToolGUIV6.ini file -which simply reloads Workspace from last
GUI session.<br>
<br>
However, when saving, name of Workspace definition file can not be
ExifToolGUIv6.ini -you should use any names that reminds you on content,
 for example: MyWorkspace_XMP.ini.<br>
<br>

<h3><a name="m_style">Style</a></h3>
Shows a list of available style/skins. To change the appearance of GUI.<br>
<img src="ExifToolGUI_V6_files/style.jpg"><br>
The Styles Silver, Green and Blue try to mimic the colors available in V516
<br>

<h2><a name="m_options">Options menu</a></h2>

<h3>Don't make backup files</h3>
-if checked (default), then ExifTool won't make "filename.ext_original"
backup files. However, if you're not sure what you're doing, then you
better uncheck this option.<br>
<br>

<h3>Preserve Date modified of files</h3>
-no matter what I think about this, some prefer having this option checked.<br>
<br>

<h3>Ignore minor errors in metadata</h3>
-by default, this option is unchecked. This results, in case metadata is
 not "as it should be", ExifTool will output warnings/errors messages 
when trying to modify such metadata. That is, ExifTool will refuse to 
write into file in case metadata is not in "perfect" condition, or if 
there's a danger that you might lose some metadata by modifying it.<br>
If this option is checked and metadata only contain "minor" errors (or 
only "minor" damage can occur), then ExifTool will do his job anyway.<br>
<br>

<h3>Show Exif:GPS in decimal notation</h3>
-checked by default (because i.e. OSM Map uses this notation as well).<br>
<br>

<h3>Show sorted tags (not in Workspace)</h3>
-if this option is unchecked (default), then metadata tags are shown 
sorted as defined internally in metadata. Many times however, it's quite
 hard to find particular tag in listing, so I can imagine, that this 
option will be checked most of the time.<br>
Obviously, this setting has no influence on <font class="blue">Workspace</font> view output (see <font class="blue">Workspace manager</font> above).<br>
<br>

<h3>Show Composite tags in view ALL</h3>
Composite tags aren't "real" tags (their values are calculated from various existing tags), so they are shown optionally.<br>
<br>

<h3>Don't show duplicated tags</h3>
It can happen that the same tag is defined more than once inside image 
file and by default, GUI will show all of them. If you don't like this 
behaviour, then check this option, but <font class="red">warning</font>: some other tags might also not be shown! -try with <font class="blue">Exif</font> GPS data, for example.<br>
<br>
All above options will be saved when exiting GUI and thus be applied in 
next GUI start. Remaining options settings however, are only temporary 
(as long GUI is running) and are not checked by default:<br>
<br>
<font class="blue">

<h3>Show tag values as numbers</h3><br>

<h3>Prefix tag names with ID number</h3><br>

<h3>Group tag names by instance (-g4)</h3></font> -This can help you to identify duplicated tags when viewing in <font class="blue">Metadata</font> panel.<br>

<h3>API WindowsWideFile (requires Exiftool v12.66)</h3> -Force the use of wide-character Windows I/O functions when the CharsetFileName option is used.<br>

<h3>Custom options</h3> -You can specify additonal options that exiftool should use. Expert option. Normally used with the Log Window.<br>
Possible use case is the option <b>-htmldump</b> and use the log window to catch the output.<br>
<br>
<br>
<h2><a name="m_exp_imp">Export/Import menu</a></h2>
<h3>Export metadata into : TXT, MIE, XMP, EXIF, HTML files</h3>
Every of these formats has different purpose: i.e. MIE is for making 
backup of complete metadata inside image file, HTML is meant for 
"studying" metadata structure, etc. So, try and see what suits your 
needs.<br>
<br>

<h3>Copy metadata from single file</h3>
This will copy metadata from single source file (can be MIE file too) 
into currently selected files. That is, all selected files will be 
populated with the same metadata. After you choose the source file, 
you'll have a chance to reduce the amount of metadata to be copied:<br>
<img src="ExifToolGUI_V6_files/copymetadatasingle.jpg"><br>
<br>

<h3>Copy metadata into JPG or TIF files</h3>
If single (JPG or TIFF) file is selected (=destination), then metadata 
can be copied from any other file containing metadata (incl. MIE file).<br>
If multiple files are selected, then metatada will be imported only where source and target files have equal names.<br>
<br>
More details on how it works:<br>
As always in GUI, before you choose menu, you select one or multiple JPG
 (or TIFF) files -this are destination files. Now you select the menu 
and, no matter how many destination files you've selected previously, 
you'll be asked to choose only one source file (see 2nd scenario). Now, 
there can be two scenarios:<br>
<b>Scenario 1:</b> If you selected only <u>one JPG or TIF destination file</u>:<br>
All metadata from source file will be copied into destination file. And 
while destination file can only be JPG or TIF, source can be any kind of
 imagefile (raw, etc.). To put it simple: it's just copying all metadata
 from any kind of file into JPG (or TIF) file.<br>
<b>Scenario 2:</b> If you selected <u>multiple JPG or TIF destination files</u>:<br>
Now, you do remember by picking only one source file... in this case, 
you actualy didn't choose particular source file, but extension(!) of 
source files and folder where source files are. After executing, 
Exiftool only compares source/destination filenames -and where filenames
 match, metadata is copied. To put it simple: it's just copying all 
metadata between files which have equal filename (but can have different
 extension).<br>
Scenario 2 is very usefull in case you have converted many raw files to 
JPG/TIFF and you know, that your raw converter doesn't copy all metadata
 from raw into resulting JPG/TIF files.<br>
<br>
<u>Note:</u> Because it's assumed, that destination file has been 
modified inbetween (resized, etc.), not all metadata is desired to be 
copied. Because of this, you'll be asked, if you also wish to copy 
following tags:<br>
<img src="ExifToolGUI_V6_files/copymetadataoptions.jpg"><br>
-in 99% cases, there will be no reason to check any of above option.<br>
<br>
<h3>Copy metadata into all JPG or TIF files</h3>
This option is very similar to above. The difference is:<br>
<li>No matter how many destination files you select (you must select at 
least one for menu to be enabled), metadata will always be copied into <b>all</b> JPG or TIF (but not both) files inside current folder. That is, this option behaves as if all JPG or TIF files are selected in <b>Scenario 2</b> above.</li>
<li>After you choose this menu option, you'll be first asked "<font class="blue">should files in subfolders also be processed?</font>". If we choose <font class="blue">No</font>, then again, this option behaves the same way as if all files are selected in <b>Scenario 2</b> above. However, if we coose <font class="blue">Yes</font>, then metadata will be copied into images in all subfolders as well (only where folder/file names are equal, of course).</li>
<br>
Let's see an example, where we wish to update <font class="brown">jpg</font> files with metadata from <font class="brown">raw</font> files:<br>
<img src="ExifToolGUI_V6_files/copymetadatamulti.jpg"><br>
<br>
1. Select any destination file inside <font class="brown">MyJpg\Dir1</font>
 folder. If you select any JPG file, then only JPG files will be 
processed; if you select TIF instead, then only TIF files will be 
processed.<br>
2. Choose menu <font class="blue">Copy metadata into all JPG or TIF files</font><br>
3. Click on <font class="blue">Yes</font> button when asked<br>
4. File browser will appear, where you select any (source) file inside <font class="brown">MyRaw\Dir1</font> folder. <u>Note:</u> You only need to select one file (to specify file extension).<br>
5. A panel will appear, where you confirm/check which of "not desired" metadata you <u>wish</u> to be copied:<br>
<img src="ExifToolGUI_V6_files/copymetadataoptions.jpg"><br>
<u>Note:</u> Even if none of above is checked, the rest of metadata in source files (Exif, Xmp, etc.) will be copied into destination files.<br>
<br>
That's it: after click on <font class="blue">Execute</font>, metadata will be copied into all files inside <font class="brown">MyJpg\Dir1</font> folder (incl. <font class="brown">Dir2</font> folder) from files inside <font class="brown">MyRaw\Dir1</font> folder (incl. <font class="brown">Dir2</font> folder).<br>
If we would choose <font class="blue">No</font> in step 3 above, then only files inside <font class="brown">MyJpg\Dir1</font> would be processed.<br>
<br>

<h3>Import GPS data from: Log files</h3>
This option allows geotagging your files in batch by using log file of your GPS device (see here for <a href="https://exiftool.org/geotag.html">supported GPS files</a>).<br> 
<img src="ExifToolGUI_V6_files/importgpsdata.jpg"><br>
<br>
<u>Step 1:</u> <b>Select log file</b> of your GPS device.<br>
As usual in GUI, you first must select files you wish to geotag. In 
most cases, folder contents will contain series of "session" photos, so 
you will select all of them.<br>
<br>
<u>Step 2:</u> Check <b>use all log files in directory</b> if more than one log file for set of files exist.<br>
Let's say you've made three day trip to Venice. In such case all photos 
will reside in single folder, but three (or more) log files will exist 
for that set of photos.<br>
Note: In this case, it doesn't matter which (of multiple) log file you 
choose -important is, all log files must have the same extension.<br>
<br>
<u>Step 3:</u> Choose <b>Reference DateTime value</b>.<br>
Here you define which photo DateTime values to compare with those in log file.<br>
<br>
<u>Step 4:</u> Choose if <b>TimeZone offset</b> is needed to be taken into account.<br>
This is a funny one... The thing is, log files contain UTC time, while 
camera is usually set to local time (of where photo is taken). In most 
cases, we are dealing with two scenarios:<br>
<ul>
<li>Case A: Photos are taken in your local (time) area<br>
-in this case there's no need to use TimeZone offset option. Short 
explanation: if TimeZone offset option doesn't exist, ExifTool "assumes"
 that camera time and PC's system time have the same TimeZone offset and
 ExifTool will handle logged UTC time automatically.</li>
<li>Case B: Photos are taken somewhere outside your local TimeZone area<br>
-in this case you must use TimeZone offset option. Example: if you live 
in New York and photo was taken in Vienna, then you must set TimeZone 
offset to +01 (depending on winter/summer time?)</li>
</ul>
In both cases above it's assumed, that camera is set to local time of 
where photos are taken. It's also assumed, that when geotagging, your 
PC/laptop is set to your local (home) TimeZone.<br>
For further reading/questions see <a href="https://exiftool.org/forum/index.php/topic,3333.0.html">here</a>.<br><br>
<u>Step 5:</u> Check Update Geo Location, if you wish to update Country, Province and City.<br>
Click on <a href="#m_geotag_setup"><b>Setup Geo</b></a> to control how these fields are filled.<br>
Note: These fields are also shown in the filelist if it's set to 'Location info'.<br>
<br>

<h3>Import GPS data from: Xmp files</h3>
By using this menu, you can copy GPS data from xmp sidecar files into Exif GPS section of selected image files.<br>
<u>Note:</u> It is expected that image and sidecar files only differ in 
extension -name part however, must be equal. Example of valid 
image-sidecar file pair is:<br>
<br>
MyPhoto.jpg - MyPhoto.xmp<br>
&nbsp;&nbsp;or<br>
img_01.cr2 - img_01.xmp<br>
&nbsp;&nbsp;etc.<br>
<br>
Because image and sidecar files usually reside in the same folder (that 
is, they are mixed), it is a good idea to use file type filter (which is
 set to "Show ALL files" by default). That is, if you wish to write GPS 
data into JPG files, you should set filter to "JPG files only". However,
 this setting is not required! <br>
Workflow is as follows:<br>
<li>Sort files by file extension (so, for example, JPG and XMP files are
 grouped -not mixed) or use desired file type filter (i.e. "CR2 files 
only"). The only reason for doing this is: you can select (only) image 
files easier.</li>
<li>Select all image files you wish to modify.</li>
<li>After choosing menu <b>Import GPS data from xmp file(s)</b>, you'll 
be prompted to select folder containing (xmp) sidecar files -in most 
cases, that will be the same folder where image files reside.</li>
...and that's it.<br>
<br>

<h3>Generic extract previews</h3>
As you may know raw image files can also contain a JPG image, which serves for
previewing raw image file content. In most cases, this JPG image is "as
if photo would be taken in JPG mode" -while this is true for exposure 
and colors, resolution (pixel size) may differ (depends on camera).<br>
Because there are many flavours possible I created a generic function.
It shows, for the selected file, what previews are available, and their sizes.<br>
You can check which preview(s) to extract and optionally perform autorate, and or crop.<br>
<img src="ExifToolGUI_V6_files/genericextractpreviews.jpg">
<br><br>

<h3>Generic import preview</h3>
Use this option to update a preview. Before you choose this option select in the filelist which files to update.<br>
In this dialog select which preview to update. Optionally rotate and or crop.<br>
When you click on <b>Execute</b> browse to the folder containing the previews. The previews should have
the same base name as the raw files. Typically they are created by the previous option.<br>
<img src="ExifToolGUI_V6_files/genericimportpreview.jpg">
<br>
<br>
See also the readme.<a href="Readme Lossless rotate_Import_Export previews.txt">Readme Lossless rotate_Import_Export previews.txt</a><br>

<h2><a name="m_modify">Modify menu</a></h2>

<h3>Exif: DateTime shift</h3>
<img src="ExifToolGUI_V6_files/exifdatetimeshift.jpg"><br>
<br><br>

<h3>Exif: DateTime equalize</h3>
<img src="ExifToolGUI_V6_files/exifdatetimeequalize.jpg"><br>
<br>

<h3>Exif: LensInfo from Makernotes</h3>
This will fill <font class="brown">Exif:LensInfo</font> of selected file(s) with relevant values from <font class="brown">Makernotes</font> data (where possible).<br>
<br>

<h3>Remove metadata</h3>
<img src="ExifToolGUI_V6_files/removemetadata.jpg"><br>
<br>
Note, that in some cases (depending on the image file format), it's not 
possible/safe to remove the metadata you've selected to remove. In such 
cases, ExifTool will simply refuse to remove such metadata (also see <font class="blue">Ignore minor errors in metadata</font> menu above).<br>
<br>

<h3>Update City, Province, Country from GPS coordinates</h3>
This option can update the location info (Country, Province and City) for the selected files.<br>
The selected files should already be geotagged, that is contain lat and lon values.<br>
For every selected file a lookup is done using the selected provider. To reduce the nbr of calls a cache is used.<br>
In the dialog you can customize how the fields are filled.<br><br>
<img src="ExifToolGUI_V6_files/updatelocationfromgps.jpg"><br><br>
Notes:<br>
- Due to the nature of this function, it uses an external webservice, there are some 'point of failures'.<br>
<ul>
<li>You need a reliable internet connection.</li>
<li>The external webservice could be (temporarily) out of service for various reasons.</li>
<li>The external webservice might change it's API.</li>
<li>etc...</li>
</ul>
- If you open the log window you can see the rest requests and their responses.<br><br>
<a href="Readme GeoCoding.txt">See also Readme GeoCoding.txt</a><br>

<h2><a name="m_various">Various menu</a></h2>

<h3>File: Date modified as in Exif</h3>
-use it, if you feel the need.<br>
This is a remark originally made by Bogdan. I would like to add my comment why it's not a good idea.<br>
If you have a backup tool that relies on the Date Modified, it will not notice that a file is modified. Example: Robocopy<br>

<br>
<h3>File: Name=DateTime+Name</h3>
<img src="ExifToolGUI_V6_files/renamefiles.jpg"><br>
<br>

<h3>JPG: Lossless autorotate + crop</h3>
This will physically rotate selected JPG images according to Exif:Orientation value inside files.<br>
It uses a library NativeJpg by SimDesign B.V. to do the actual rotating. No external program is needed.<br>
In addition you have more control over how the function is performed.<br><br>
<img src="ExifToolGUI_V6_files/jpeglosslessrotate.jpg"><br><br>
<a href="Readme Lossless rotate_Import_Export previews.txt">See also Readme Lossless rotate_Import_Export previews.txt</a>
<br>
<br>

<h2><a name="p_filelist">Filelist panel</a></h2>
<img src="ExifToolGUI_V6_files/filelistpanel.jpg"><br>
<br>

<b>Refresh</b> button<br>
-will update folder (directory) content in filelist panel. This might be
 usefull in cases you're interested on file characteristics changes 
(size, etc.) after applied operations.<br>
<br>
<b>File filter</b> drop-down box<br>
-is set to <font class="blue">Show ALL files</font> by default on every 
GUI startup and this behaviour can't be changed. This drop-down box 
allready contain few predefined file filters and by clicking on <font class="blue">Edit</font> button, you can add additional filters which you need most often.<br>
<br>

<b>Details:</b> button<br>
-is "pressed" by default, which means, files are listed with detals 
about files. If this button is "de-pressed" then thumbnails are shown 
instead of file details.<br>
<u>Note:</u> Only thumbnails for "registered" image files will be shown 
as images. Meaning, for raw image files, you'll need to install 
appropriate raw "codec", to be able to see thumbnails and previews.<br>
<br>

<b>Details</b> drop-down box<br>
-is set to <font class="blue">Standard filelist</font> by default. This drop-down box also contain few predefined details views:<br>
<font class="blue">Camera settings, Location info</font> and <font class="blue">About photo</font> -where each of these views shows few metadata values inside files; i.e.:<br> 
<u><b>Note:</b></u> The Folders and the Breadcrumb bar are shown only when enabled in Preferences/Other.<br>
<img src="ExifToolGUI_V6_files/filelistcamerasettings.jpg"><br>
<br>

No matter how disappointed you might be, you can't define/change tags 
shown in these predefined views. The main and only reason why's that is:
that's the only way I could get reasonable speed to show this data.<br>
<br>

But to give you at least something, the last entry in this drop-down box is <font class="blue">User defined</font>. If you select that, then <font class="blue">Edit</font> button on the right side becomes enabled, and by clicking on it, you'll get:<br>
<img src="ExifToolGUI_V6_files/filelistuserdefined.jpg"><br>
-here you can define your own columns and metadata values to be shown.<br>
<font class="red">Note:</font> Displaying <font class="blue">User defined</font>
 details view is noticeable slower than fixed predefined views. So, use 
this view on relative small amount of files in folder. In short: tryout.<br>
<br>

Developer note: Bogdan Hrastnik used JAM Shellbrowser for the filelist, and folderlist. I wanted to have sourcecode that did not rely on 3rd party libraries. The additional functionality needed for
ExifToolGui required extending the standard Embarcadero TShellTreeView and TShellListView. It proved to be more difficult than I anticipated. By now it works satisfactory.<br>
A few small modifications to the Embarcadero source are needed. You can find the ReadMe and source code in GitHub. 
<a href="..\Source\Vcl.ShellControls\ReadMe.txt">ReadMe ShellControls.txt</a>
<br>

<h2><a name="p_etdirect">ExifTool direct panel</a></h2>
By clicking on <font class="blue">ExifTool direct</font> button, you get an input field where ExifTool commands can be entered and executed:<br>
<img src="ExifToolGUI_V6_files/exiftooldirect.jpg"><br>
<br>
<b>StayOpen/Classic</b> Starting with version 6.2.0 you can choose how the commands are executed.<br>
<li>StayOpen. Send the commands to the ExifTool.exe program using stay open mode. This is the default, and doesn't start a new instance of ExifTool.exe.</li>
<li>Classic. Starts a new instance of ExifTool.exe, sends the commands, and waits for ExifTool.exe to complete. This was the default in previous versions. Retained for compatibility reasons.</li>
<br>
<u><b>Note:</b></u> Don't need to type "exiftool" here -GUI will take care of calling ExifTool for executing commands you have entered.<br>
<u><b>Note:</b></u> Even you're in "direct mode", <font class="blue">Options menu</font> settings for:<br>
<li>Don't backup files when modifying</li>
<li>Preserve Date modified of files</li>
<li>Ignore existing minor errors</li>
<li>Api WindowsWideFile</li>
are automatically applied by GUI -meaning: these settings are still valid.<br>
<br>

If you're a bit familiar with ExifTool usage, then here, you can execute commands not covered by GUI. Usage is very simple:<br>
<li>select one or more files</li>
<li>enter desired command and press Enter key</li>
Btw. you can close ExifTool direct mode by clicking on <font class="blue">ExifTool direct</font> button again, or Esc key while you're in edit line.
<br>
<h3>Some examples for exercise:</h3>
<code><font class="brown">-Exif:Copyright&lt;Exif:Artist</font></code> -copy value of Exif:Artist into Exif:Copyright<br>
<code><font class="brown">-Exif:DocumentName&lt;$filename</font></code> -save filename into Exif:DocumentName tag<br>
<code><font class="brown">-Xmp-aux:All=</font></code> -delete complete Xmp-aux section<br>
<code><font class="brown">-Exif:Artist="My Name"</font></code> -it's obvious, isn't it?<br>
etc... You can find more info <a href="https://exiftool.org/exiftool_pod.html">here</a>, on homepage of ExifTool.<br>
<br>

As mentioned, selected files are automatically added to the end of 
command, so you don't need to type them. However, there are cases, when 
you should <u>not</u> select source file, i.e.:<br>
<code><font class="brown">-tagsfromfile MyPhoto.jpg Result.xmp</font></code><br>
-here, source file "MyPhoto.jpg" can't be placed at the end of command, 
so selecting it in filelist isn't what you want. If you select it 
anyway, then (in this case) xmp file will be created first (as 
expected), and after that, xmp file content will be added back to 
selected file -that's what you don't want.<br>
<b>Tip</b> Use the file filter to make sure no files are selected.<br>
<br>

If you wish to modify all files inside currently selected folder, <u>including files in subfolders</u>, then you should use <font class="brown">-r</font> option. Some examples:<br>
<code><font class="brown">-r -Xmp:all=</font></code><br>
-deletes all Xmp metadata from all files inside currently selected folder and subfolders.<br>
<code><font class="brown">-r -Exif:Artist="My Name" -ext jpg</font></code><br>
-set Exif:Artist tag value to My Name for all jpg files inside currently selected folder and subfolders.<br>
<code><font class="brown">-r -Xmp:City=Paris -ext jpg -ext tif</font></code><br>
-set Xmp:City tag value to Paris for all jpg and tif files inside selected folder and subfolders.<br>
<u>Note:</u> If more than one extension is specified, then (processed) <font class="blue">files counter</font> only counts number of files defined by first file extension. Meaning: if more than one extension is specified, <font class="blue">files counter</font> might not reflect actual number of files.<br>
<br>

<u><b>Note:</b></u> You can't "redirect" output in <font class="blue">ExifTool direct</font>. If you need to do that (i.e. extract thumbnail image), then you should use ExifTool directly (that is, outside GUI).<br>
<br>

<h3>Using predefined ExifTool commands</h3>
There's one predefined ExifTool command in GUI, so you can see what's 
all about. To access it, you click on combo-box (blank on above image) 
and choose it:<br>
<img src="ExifToolGUI_V6_files/exiftooldirect.jpg"><br>
Once command is chosen, you can execute it by pressing Enter key (while 
you're in edit field). If needed, you can modify displayed command and 
execute it, without actually changing predefined command.<br>
<br>

<h3>Modifying predefined commands</h3>
By clicking on <font class="blue">Edit predefined</font> button, panel increases with additional options:<br>
<img src="ExifToolGUI_V6_files/exiftooldirectpredefined.jpg"><br>
<br>
<font class="blue">^Delete</font> -deletes currently selected predefined command permanently.<br>
<font class="blue">^Replace</font> -replaces currently selected predefined command (i.e. after changes have been made).<br>
<font class="blue">^Add new</font> -adds new command to the end of the list.<br>
<font class="blue">^Default</font> -makes currently selected predefined command selected by default each time GUI starts.<br>
<font class="blue">Deselect</font> -sets predefined commands combobox to "none selected" state.<br>
<br>
<font class="red">Note:</font> Don't use <font class="red">=</font> character in <font class="blue">Command name</font> field! -because in INI file, this character is used as separator between command name and actual command.<br>
<br>
<h3>Using args files</h3>
<b>args</b> file is a text file, usually containing several ExifTool 
commands, which are all executed by simple call of single args file. 
Here's a example of args file, containing two commands, written by 
Notepad:
<pre>-Exif:Artist="My Name"
-Exif:Copyright="C2012 by My Name"
</pre>
Let's save this text as "MyData.args". <u>Note:</u> File must be saved in the same folder where exiftool.exe is saved (or specify the full path to the args file).<br>
To execute above commands in GUI (after desired image files are selected), we need to write the following Command into <font class="blue">ExifTool direct</font> panel:<br>
<pre>-@ MyData.args
</pre>
-and press Enter key.<br>
<br>

ExifTool full source version (can be downloaded on top of ExifTool main 
page) contains several predefined args files, which are meant for 
transferring "similar" metadata between sections. One of them is (for 
example) "xmp2iptc.args" file, which copies all "compatible" metadata 
from Xmp to Iptc section. And as said, there are more of them.<br>
<br>
<h3>Show Log Window button</h3>
When using <font class="blue">ExifTool direct</font> mode, any results are written into the <font class="blue">Log window</font> when it is opened.<br>
If, for example, we select two files and execute following <font class="blue">ExifTool direct</font> command:<br>
<pre>-e -gps:all
</pre>
-we will get something like this:<br>
<img src="ExifToolGUI_V6_files/logwindow.jpg"><br>
<br>
<u>Note:</u> In case of errors, the <font class="blue">Log window</font> with relevant messages automatically appears after ExifTool ends processing files.<br>
Starting with version 6.2.0 the Log window will show the last 10 commands. In the top panel you can select the command issued, <br>
on the left you will see what was sent to ExifTool, on the right you see the output it generated and in the bottom panel the errors, if applicable.<br>
To help identifying the commands an execnum is send to ExifTool, you can see this in the command window 'execute14 and -echo4 {ready14}', <br>
Exiftool will return this in the Output and Error. <br>
GUI uses execnums from 10-99, and when 100 is reached it is reset to 10.<br>
In the top you will see a checkbox 'Show all commands'. By default only the commands issued from Direct mode, or that return an error, are displayed. <br>
If you check this also the commands that GUI uses internally are displayed.<br>
With the buttons <b>Cmd prompt</b> and <b>PowerShell</b> you can generate a <b>.cmd</b> or <b>.ps1</b> script to replay the commmands.<br>
<br>
<img src="ExifToolGUI_V6_files/powershell.jpg"><br>

<h2><a name="p_metadata">Metadata panel</a></h2>
<img src="ExifToolGUI_V6_files/metadataworkspace.jpg"><br>
<br>
By clicking on any button on top row, relevant metadata will be shown -that is, top row is for displaying metadata only.<br>
<br>
In the second row, there's only one button: <font class="blue">Workspace</font>. This button is "pressed" by default on every GUI startup and this can't be changed by user.<br>
And where are the "good old" <font class="blue"><b>[ ^ ]</b></font> edit buttons, known from previous GUI versions? They're gone.. they aren't needed anymore.<br>
As explained above (see <font class="blue">Workspace manager</font> menu), <font class="blue">Workspace</font> is fully customizable: user can define which tags he wishes to be listed here.<br>
And the value of any tag listed in <font class="blue">Workspace</font> can be edited at will.<br><br>

<img src="ExifToolGUI_V6_files/metadataworkspacefind.jpg"><br><br>
In the <b>Find</b> edit box you can enter a text, press Enter and the first line containing that text in 'Tag name' or 'Value' is highlighted.<br>
Pressing Enter again searches for the next occurence.<br>
<br>

<h3>Edit metadata in Workspace</h3>
<br><img src="ExifToolGUI_V6_files/metadataworkspaceedit.jpg"><br>
Here's how to edit metadata in <font class="blue">Workspace</font>:
<li>Click on tag line you wish to modify</li>
<li>Press Enter key or click into Value edit field (which becomes yellow)</li>
<li>Write tag value and press Enter key when you're done (or press <b>Esc</b> key to cancel editing)</li>
<li>Tag name you've previously selected becomes yellow and contains the value you've just entered.</li>
<li>If needed, pick another tag and repeat the process.</li>
<u>Note:</u> Data isn't saved yet!<br>

<br>
If you've changed your mind and don't wish to change particular tag,
then select that tag, right-click (to show pop-up menu) and choose <font class="blue">Undo selected editing</font> -this is usefull in cases when many tags are allready edited and not saved.<br>
If you've changed your mind completely (don't wish to apply any changes), then just click on <font class="blue">Workspace</font> button and changes will dissapear.<br>
<u>Note:</u> Changes are lost in most cases when you click elsewhere outside Metadata view area.<br>
<br>
<li>When you're finished with editing metadata values, click on <font class="blue">Save</font> button.</li>
<br>
Some tag values may require a bit longer text to be entered (just <u>a bit</u> longer, please). To do that more comfortable, click on <font class="blue">Large</font> button and you'll get some more space:<br>
<img src="ExifToolGUI_V6_files/metadataworkspacelong.jpg"><br>
<br>

<b>Keyboard shortcuts</b><br>
These keyboard shortcuts are recognized:
<li>Enter, Starts editing the field, confirms editing the value.</li>
<li>Esc, Abandons editing the value.</li>
<li>CTRL + C, Copies the value of the current row to the Clipboard.</li>
<li>CTRL + S, Saves the pending changes. (Same as clicking Save)</li>
<li>CTRL + Home, CTRL + End, Moves to first, last line of the metadata.</li>
<li>CTRL + Up, CTRL + Down, Loads the previous, next file. The changed data is not saved.</li>
<br>

<b>Editing tags which names ends with ± character</b><br>
This sign means tag can have multiple values defined (where keywords are
 most known). Posibilities for entering values for such tags:<br>
<font class="brown">bird</font> -all existing keywords will be deleted and keyword "bird" will be saved.<br>
<font class="brown">+flight</font> -keyword "flight" will be added to existing list of keywords.<br>
<font class="brown">-bird</font> -keyword "bird" will be deleted from existing list of keywords (if it exist).<br>
<br>
You can also add multiple keywords at once, for example by entering: <font class="brown">+nature+daylight+sky</font><br>
or you can delete multiple keywords at once, for example: <font class="brown">-water-tree</font><br>
<br>
<u>Note:</u> As you know by now, you can't enter keywords which contain + or - sign (which is a bad keywording habbit anyway).<br>
<u>Advice:</u> Don't write stories into keywords -by it's definition, a keyword is meant to be a (single) word.<br>
<br>

<h3><a name="m_popup_meta">Pop-up menu in Metadata panel</a></h3>
As mentioned, if you right-click on any tag shown in <font class="blue">Metadata</font> panel, a pop-up menu will appear:<br>
<br>
<img src="ExifToolGUI_V6_files/metadataworkspacepopup.jpg">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="ExifToolGUI_V6_files/metadataworkspacemark.jpg"><br>
<br>
<u>Note:</u> Not all options are available all the time.<br>
<u>Note:</u> Tag names will appear colored (as in image above right) only if <font class="blue">Metadata language</font> in <font class="blue">Preferences</font> is set to <font class="blue">ExifTool standard (short)</font>.<br>
<br>

<b>Fill in default values</b> -in <font class="blue">Workspace</font> only<br>
By choosing this option, all tags which names are ending with <font class="red">*</font> character, will be populated with default values (as defined in <font class="blue">Workspace manager</font>).<br>
<br>

<b>Undo selected editing</b> -in <font class="blue">Workspace</font> only <br>
As long as an edited tag value isn't saved (tag name has a yellow background), you can "undo" the changes for the selected tag.<br>
<br>

<b>Add tag to Workspace</b> -in <font class="blue">Exif, Xmp</font> and <font class="blue">Iptc</font> view only<br>
By using this option, you can easily add any Exif, Xmp or Iptc tag into the <font class="blue">Workspace</font>. Selected tag will be added at the end of existing <font class="blue">Workspace</font> list of tags.<br>
Once tag is added, you can make further customisations by using the <font class="blue">Workspace manager</font>.<br>
<br>

<b>Remove tag from Workspace</b> -in <font class="blue">Workspace</font> only<br>
Do you really need to edit so many tags? Ok, it's your life :)<br>
<br>
Note: If you checked <b>Double Click adds/removes tags</b> in Preferences/Other you can also use Double click to Add/Remove Tags from the Workspace.<br><br>

<b>Add tag to Custom view</b> -NOT in <font class="blue">Workspace</font><br>
Adds selected tag to be shown in <font class="blue">Custom</font> view.<br>
<br>
<b>Remove tag from Custom view</b> -in <font class="blue">Custom</font> view only.<br>
It is a good practice, to keep only those tags in <font class="ble">Custom</font> view, on which you are temporary interested. Once number of tags listed here becomes too long, the meaning/purpose of <font class="blue">Custom</font> view is lost.<br>
<br>
<b>Add tag to Filelist Details</b> -in <font class="blue">Exif, Xmp</font> and <font class="blue">Iptc</font> view only<br>
This command adds selected tag into Filelist <font class="blue">Details: User defined</font> columns.<br>
<br>

<b>Mark/Unmark tag</b> -NOT in <font class="blue">Workspace</font><br>
As name implies, this option serves to mark/unmark tags of interest.
Marked tag name is shown in red color in any view (except in <font class="blue">Workspace</font>), so you can locate it easier later.<br>
<u>Note:</u> This selection is only available if <font class="blue">Exiftool standard (short)</font> language is selected in <font class="blue">Preferences</font>.<br>
<br>
<br>

<h2><a name="p_osmmap">OSM Map panel</a></h2>
<img src="ExifToolGUI_V6_files/osmmap.jpg"><br>
<br>
<u>Notes:</u>
<ul>
<li><font class="blue">OpenStreet Map</font> panel will only be available if chosen in <font class="blue">Preferences</font>.<br> </li>
<li><font class="blue">GeoCoding</font> Finding places from coordinates and vice versa,  will only be available if chosen in <font class="blue">Preferences</font>.<br> </li>
</ul>
<br>

<b>Show on map</b> button<br>
If selected images are geo-tagged (contain GPS data), clicking this button will display their geo-position on the map.<br><br>
<img src="ExifToolGUI_V6_files/osmmapshowonmap.jpg"><br>
<br>

<b><< Back</b> and <b>Forward >></b> buttons<br>
Selected images are shown as a hyperlink. You can use these buttons to go back to the map.
Hyperlinks work only for filetypes supported in your browser.<br>
Jpg usually works, raw formats likely not.<br><br>

<b>Get location</b> button<br>
Tries to get the location (City, Province and Country) from the currently selected center of the map.<br>
<u>Notes:</u>
<ul>
<li>Ctrl Left-click will also retrieve the location.</li>
<li>You can customize how City and Province are shown by using the <a href="#m_geotag_setup"><b>Setup Geo</b></a> button in the <b>Geotag files</b> function.<br>
<li>The coordinates of the map, and the bounds, are updated automatically when you zoom or move the map.</li>
</ul>
<br>

<b>Find</b> field<br>
-for finding places easier...<br>
<br>
<u>Notes:</u>
<ul>
<li>If valid lat-lon coordinates are entered (eg. 40.524832, -3.771568) the map is repositioned accordingly.</li>
<li>If no valid lat-lon coordinates were found, GUI assumes you're searching for a City.</li>
<li>Enter the name of a City, optionally followed by a comma and the Country. (eg: Amsterdam or Amsterdam, NL) Enter a least 5 characters.</li>
<li>The <b>Search place</b> dialog appears, where you can adjust your query.<br><br></li>
<img src="ExifToolGUI_V6_files/osmmapsearch.jpg"><br><br>
<li>You can disable this dialog in Preferences.<br></li>
<li>Click on <b>OK</b> to start the search.<br><br></li>
<li>The <b>Places found</b> dialog appears.<br><br></li>
<img src="ExifToolGUI_V6_files/osmmapplacesfound.jpg"><br><br>
<li>Click on <b>OK</b>, or Double-click to reposition the map to the selected place.</li>
</ul>
<br>
<a href="Readme GeoCoding.txt">Readme GeoCoding.txt</a>
<br>
<br>

<b>Home</b> button<br>
-moves the map cursor to your predefined position.<br>
<br>

<b>Set^</b> button<br>
Current map cursor position becomes <font class="blue">Home</font> position.<br>
<br>

<b>Geotag files</b> button<br>
By clicking on this button, all selected files will be geotagged with current map cursor position.<br>
<u>Notes:</u>
<ul>
<li>The coordinates displayed in the <b>Find:</b> edit box are used. They could be different from the center of the map!<br>
Examples that have happened to me:</li>
<ul>
<li>You type the name of a City, but dont press Enter to search.</li>
<li>You paste coordinates in the edit box.</li>
</ul>
<li>The Geotag files dialog appears.<br></li>
<li>You can disable this dialog in Preferences.<br><br></li>
<img src="ExifToolGUI_V6_files/geotagfiles.jpg"><br><br>
<ul>
</li><a name="m_geotag_setup">Setting up Geo tagging<a><br></li>
<li>Use the <b>Setup Geo</b> button to customize how City, Province and Country are filled.<br><br></li>
<img src="ExifToolGUI_V6_files/setupgeotag.jpg"><br><br>
</ul>
<li>You can also manually update these fields.</li>
<li>Location is an exception, it will never be automatically filled. You can only update it manually.<br></li>
<li>Choose which fields to update:</li>
<ul>
<li>Coordinates (Lat, Lon)</li>
<li>Location (Country, Province, City)</li>
<li>Coordinates and Location</li>
</ul>
<li>Click on <b>OK</b>, to GeoTag the files.</li>
</ul>
<br>
<br>

<h1><a name="final">Final words</a></h1>
All credits go to Phil and Bogdan. A quote from Bogdan that still applies:<br>
<em>
Well.. that's it.<br>
P.S.: Don't blame me for my English grammar -it's not my native language.<br>
</em>
<br>
Frank<br>
Modified on December, 2023<br>
<br>

<u>You may find additional info in the ReadMe files:</u>
<ul>
<li><a href="ReadMe for Developers.txt">ReadMe for Developers</a></li>
<li><a href="..\Source\Vcl.ShellControls\ReadMe.txt">ReadMe ShellControls</a></li>
<li><a href="..\Source\NativeJpg\README.txt">ReadMe NativeJpg</a></li>
<li><a href="..\Source\BeadcrumbBar\README.txt">ReadMe Breaddcrum Bar</a></li>
<li><a href="ReadMe for Users.txt">ReadMe for Users</a></li>
<li><a href="Readme GeoCoding.txt">Readme GeoCoding</a></li>
<li><a href="Readme Long filenames.txt">Readme Long filenames</a></li>
<li><a href="Readme Lossless rotate_Import_Export previews.txt">Readme Lossless rotate_Import_Export previews</a></li>
<li><a href="Readme Portable.txt">Readme Portable</a></li>
<li><a href="Readme Using Codecs.txt">Readme Using Codecs</a></li>
</ul>
</td></tr>
</tbody></table>

</body></html>
