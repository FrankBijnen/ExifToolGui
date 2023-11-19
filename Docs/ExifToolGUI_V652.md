<html><head>
<meta http-equiv="Keywords" content="ExifTool,ExifToolGUI,exif,editor,viewer,reader">
<meta http-equiv="Description" content="ExifToolGUI">
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1250">
<link rel="stylesheet" type="text/css" href="ExifToolGUI_V652_files/page.css">
</head>

<body>
<table class="A4">
<tbody><tr><td class="A4">
<h1>ExifToolGUI for Windows v6.xx</h1><hr>
<h2>Introduction</h2>
In the summer of 2023 I decided to revive the ExifToolGui project initally created by <b>Bogdan Hrastnik</b>. Read his complete documentation here <a href="https://exiftool.org/gui"><b>here</b></a><br><br>
This was his intro, I will quote it now, because it still holds for me:<br>
<em>
There are many tools for viewing/editing metadata inside image files. In my opinion, <b>ExifTool</b> by <b>Phil Harvey</b>, is the best I've found so far. Here's why:<br>
<li>-it shows more metadata tags than any other tool,</li>
<li>-it allows to edit almost any metadata tag,</li>
<li>-it is very secure to use, is regulary updated and has the best possible support.</li>
<br>
The only downside for many potential users is the fact, that ExifTool is
 a "command-line" utility. That means, there's no Graphic User Interface
 (GUI), so all work must be done by typing commands inside "Command 
Prompt" window. Such approach gives ExifTool great flexibility, but is 
somehow difficult to use -especially for those, who don't use ExifTool 
regulary.<br>
<br>

So, I've decided to make some simple ExifTool GUI for my private use. 
There are already some GUI's that make use of ExifTool, but some of them
 are not flexible enough (for my needs) and/or have somehow limited use.
 When making ExifToolGUI, the main goal was:<br>
<li>-view all metadata that ExifTool recognizes,</li>
<li>-ability to edit most frequently used metadata tags,</li>
<li>-batch capability (where appropriate), means: you can select multiple files and modify them at once.</li>
<br>
Basic idea behind GUI is, to keep it <u>simple!</u> Thus, only those options are implemented, which I believe, are essential for majority of users.<br>
</em>
<br>
<font class="red"><b>Important changes in ExifToolGUI v6.xx</b></font><br>
<li>The source code now compiles with Delphi Community Edition. Version used, as of writing, Rad 11.3.</li>
<li class="tab">No (closed source) 3rd party libraries needed.</li>
<li class="tab">All source code provided on GitHub.</li>
<li>Added styles.</li>
<li>Image preview is handled by WIC (Windows Imaging Component).</li>
<li>Google Maps is replaced by Open Street Map.</li>
<li>64 Bits executable available.</li>
<li>Optionally copy the stack trace to the clipboard in case of an exception. Available in the released executables, to compile Project-JEDI/JCL is required.</li>
<li>Better support for international characters. All internal code now uses Unicode (UTF16), to interface with Exiftool UTF8.</li>
<li>Enhanced Log Window. The last 10 commands are shown, with their respective output and error. Option to replay the command in PowerShell/Cmd prompt.</li>
<li>The external programs Jhead.exe and Jpegtran.exe are no longer needed. Rotation, and cropping, are handled in Delphi native code. With a modified library called NativeJpg by SimDesign B.V. (I tried contacting SimDesign to verify the Licence requirements, but was unable to.)</li>
<li>Exporting and Importing previews has been revised, and offer greater flexability.</li>
<li>GeoCoding has been enhanced. You can now choose from 2 providers (https://overpass-api.de and https://geocode.maps.co) and lookup City, Province and Country from GPS coordinates AKA reverse GeoCoding.</li>
<br>
<h2>Requirements and preparations</h2>
ExiftoolGUI should run on Windows 7, 8 32-64bit. However, it is highly recommended to use Windows 10 or 11 when you plan to use the OSM map, or GEOcoding.<br>
It will not run on Windows XP or earlier!<br>
<br>

<h3>1. ExifTool</h3>
You only need to download "Windows Executable" zip file from <a href="https://exiftool.org/"><b>here</b></a>.
After unzipping, depending on your Windows Explorer settings, you will see:<font color="CC0000">exiftool(-k)</font> or <font color="CC0000">exiftool(-k).exe</font>
Rename it to either <font color="CC0000">exiftool</font> or <font color="CC0000">exiftool.exe</font> and put it in the same folder as ExifToolGui.<br><br>
<u>Notes:</u>
<li>Bogdan Hrastnik recommended to copy exiftool into the Windows directory, but I strongly advise not to. Microsoft makes it harder with every Windows version to modify System directories.</li>
<li>If you prefer an installer, I recommend the installer provided by <a href="https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows"><b>Oliver Betz</b></a></li>
<li>You can overrule the location of exiftool in Preferences/other.</li>
<li>In case you've done something wrong in this regard, you'll see an error message when GUI starts.</li>
<br>

<h3>2. ExifToolGUI</h3>
You can download GUI from <a href="https://github.com/FrankBijnen/ExifToolGui/releases"><b>here</b></a>.
GUI doesn't need to be "installed". Just download the executable for your platform (ExifToolGui.exe or ExifToolGui_X64.exe) into any directory, create Desktop shortcut and GUI is ready to use.<br>
<font class="red">Note:</font> It is not recommended to put ExifToolGUI.exe into directories owned by operating system (Windows and Program files), unless you <u>know</u> what you're doing.<br>
<u>Portable notes:</u>
GUI doesn't write anything into the registry file. It does however create temporary files in the %TEMP% directory. <br>
It will save its settings in %APPDATA%\ExifToolGUI\ExifToolV6.ini, unless you use the commandline parameter <u>/DontSaveIni</u>.<br>  
It was decided not to save the INI file in the same directory as the executable, because that location may not be writable.<br>
<br>

<h3>3. WebView2Loader.dll</h3>
This dll is only needed when you want to use the OSM map. You can download it <a href="https://www.nuget.org/packages/Microsoft.Web.WebView2">from nuget</a>
Select the version (Eg. 1.0.2194-prerelease) and click on Download package. (on the Right)<br>
This will get you a file named like 'microsoft.web.webview2.1.0.2194-prerelease.nupkg'.<br>
Open this file with an archiver. (Winrar https://www.win-rar.com/ and 7-Zip https://www.7-zip.org/ are known to work)<br>
From this nupkg file extract the file 'runtimes\win-x86\native\WebView2Loader.dll' or 'runtimes\win-x64\native\WebView2Loader.dll' to the directory where you saved ExifToolGui(_X64).exe.<br>

<h3>4. jhead.exe &amp; jpegtran.exe</h3>
These files are no longer needed, but can still be used if available.<br>
The menu-items that use these programs are marked <u>deprecated</u> and will be removed in a next release.</br>

<h3>5. Wish to see thumbnails of raw image files?</h3>
Of course you do. What you need is a "raw codec", usually available for 
free from camera manufacturer. The best I've found so far is 
"FastPictureViewer codec" (from <a href="http://www.fastpictureviewer.com/codecs/">here</a>). It is very fast, covers many raw formats and has small package -but not free ($15 as I'm writing this).<br>
<br>
That's all you need. And when new ExifTool or GUI version is available, you only need to repeat process as described above.<br>
More info can be found here:<br>
<li><a href="changelog.txt">changelog.txt</a></li>
<li><a href="ReadMe for Developers.txt">ReadMe for Developers.txt</a></li>
<li><a href="ReadMe for Users.txt">ReadMe for Users.txt</a></li>
<li><a href="Readme GeoCoding.txt">Readme GeoCoding.txt</a></li>
<li><a href="Readme Long filenames.txt">Readme Long filenames.txt</a></li>
<li><a href="Readme Lossless rotate_Import_Export previews.txt">Readme Lossless rotate_Import_Export previews.txt</a></li>
<li><a href="Readme Portable.txt">Readme Portable.txt</a></li>
<li><a href="Readme Using Codecs.txt">Readme Using Codecs.txt</a></li>
<br>
<a name="gui_screen"><img src="ExifToolGUI_V652_files/gui01.png"></a><br>
<br>
<h3>Content</h3>
<b>Menu:</b><br>
<li><a href="#m_program">Program</a> menu</li>
<ul><li><a href="#m_workspace">Workspace manager</a> menu</li></ul>
<li><a href="#m_options">Options</a> menu</li>
<li><a href="#m_exp_imp">Export/Import</a> menu</li>
<li><a href="#m_modify">Modify</a> menu</li>
<li><a href="#m_various">Various</a> menu</li>
<b>Panel:</b><br>
<li><a href="#p_filelist">Filelist</a> panel</li>
<li><a href="#p_etdirect">ExifTool direct</a> panel</li>
<li><a href="#p_metadata">Metadata</a> panel</li>
<li><a href="#p_googlemap">GoogleMap</a> panel</li>
<a href="#final">Final words</a><br>

<br><br>
<h2><a name="m_program">Program menu</a></h2>
<h3>About</h3>
-displays ExifTool and GUI versions.<br>
<br>
<h3>Preferences</h3>
<img src="ExifToolGUI_V652_files/gui02.png"><br>
<br><br>
<b><u>General</u></b> settings tab<br>
<br>
<b>Metadata language</b><br>
Here you can choose the language for displaying metadata tag names and values in <font class="blue">Metadata</font> panel. Selected language is also used when working in <font class="blue">ExifTool direct</font> mode (output to <font class="blue">Log window</font>), or when exporting metadata to external TXT files.<br>
<br>
<b>Let GUI rotate JPG preview image</b><br>
In most cases, you will need to check this option, because Windows 
doesn't automatically rotate JPG images according to Exif:Orientation 
tag value. Anyway, if this option is checked, then GUI won't 
change/rotate your JPG files phisically: rotation (if needed) is applied
 in GUI's memory after the image has been loaded for displaying. If 
checked, GUI will only rotate image in <font class="blue">Preview</font> panel -thumbnails aren't rotated.<br>
If you're using some recent version of "FastPictureViewer" codec, then 
you should not check this option (because that codec is capable to 
deliver properly rotated JPG images).<br>
<br>
<b>Enabling internet access</b><br>
By default, this option is unchecked and if you are a bit paranoid, then
 keep it that way. In this case however, you won't be able to use GUI's <font class="blue">GoogleMap</font>
 feature for geotagging your images manually. After changing this 
option, you'll need to close and reopen GUI, to make this feature 
available.<br>
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
If checked, then <font class="blue">Details:</font> button state and selected Filelist view (Standard filelist, Camera settings,..etc.) are saved when closing GUI. Selected <b>Thumbnails size</b> is always saved.<br>
<br><br>
<b><u>Other</u></b> settings tab (not shown in above screenshot)<br>
<br>
<b>Workspace: Move focus to next tag/line after value is entered</b><br>
By default, when you hit Enter button to confirm changing tag value in 
Workspace, focus of selected tag/line automatically moves to next 
tag/line. If you prefer focus would remain on currently edited tag/line,
 then uncheck this option.
<br><br>
<br>
<h3><a name="m_workspace">Workspace manager</a></h3>
Here you define what will be shown in <font class="blue">Metadata</font> panel when <font class="blue">Workspace</font> is selected. Besides <font class="blue">ExifTool direct</font> option, this is the most powerfull GUI feature.<br>
<br>
<img src="ExifToolGUI_V652_files/gui03.png"><br>
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
numerical value.<br>
<font class="red">*</font> -if tag name ends with this character (see Artist* above), then that means, that value defined in <font class="blue">Hint text</font> will be used as default value for this tag. In this case, if you right-click on <font class="blue">Metadata</font> panel (when in <font class="blue">Workspace</font> view mode), pop-up menu appears and there's option <font class="blue">Fill in default values</font> -you get the idea, I hope.<br>
<font class="red">?</font> -if tag name ends with this character (see 
Geotagged? above), then that means, that you're not interested on tag 
value itself -what you wish to see is, if particular tag is defined or 
not. <u>Note:</u> You won't be able to edit such tag in <font class="blue">Workspace</font> view.<br>
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
numerical tag value (try with <font class="brown">-exif:Orientation#</font> to see the difference). Of course, only single tag can be defined per line.<br>
To separate group of tags in <font class="blue">Workspace</font> view, special "fake" tag is used: <font class="brown">-GUI-SEP</font> (see "About photo" on above screenshot).<br>
<br>
<b>Hint text column</b><br>
Text entered here is your <u>short</u> "private" help, which will be displayed in GUI's status bar when you start modifying tag value:<br>
<img src="ExifToolGUI_V652_files/gui03a.png"><br>
<br>
I hope you can recognize the power of <font class="blue">Workspace manager</font>:
 YOU define any metadata tag you wish to change regulary. Btw. you can 
move defined tags up/down by clicking &amp; moving tag name in first 
(Tag name) column.<br>
<br>
<h3>Workspace definition file: Load/Save</h3>
All tags defined for <font class="blue">Workspace</font> are automatically saved into <b>ExifToolGUIv5.ini</b> file. So, when you start GUI, <font class="blue">Workspace</font> content is the same as it was when you used GUI the last time. For whatever reason, you might wish to save your <u>current</u> <font class="blue">Workspace</font>
 content -to create a backup of your Workspace, so to speak. And when 
needed, you just load previously saved Workspace definition file again.<br>
<br>
When you choose <font class="blue">Save</font>, you'll be asked where to
 save the file and you'll need to set the filename. By default, save 
directory will allways be the directory where ExifToolGUI.exe is saved; 
however, you can choose any other directory.<br>
When you choose <font class="blue">Load</font>, again, default starting 
directory will be the one, where ExifToolGUI.exe is. And if you've 
messed with your Workspace inbetween, you can choose to load Workspace 
from ExifToolGUIv5.ini file -which simply reloads Workspace from last 
GUI session.<br>
<br>
However, when saving, name of Workspace definition file can not be 
ExifToolGUIv5.ini -you should use any names that reminds you on content,
 for example: MyWorkspace_XMP.ini.<br>
<br>
<h3>GUI color</h3>
My humble attempt to keep GUI up to date... to some degree :)<br>
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
-checked by default (because i.e. GoogleMap uses this notation as well).<br>
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
Show tag values as numbers<br>
Prefix tag names with ID number<br>
Group tag names by instance (-g4)</font> -this can help you to identify duplicated tags when viewing in <font class="blue">Metadata</font> panel.<br>
<br>
<br>
<h2><a name="m_exp_imp">Export/Import menu</a></h2>
<h3>Export metadata into : TXT, MIE, XMP, EXIF, HTML files</h3>
Every of these formats has different purpose: i.e. MIE is for making 
backup of complete metadata inside image file, HTML is ment for 
"studying" metadata structure, etc. So, try and see what suits your 
needs.<br>
<br>
<h3>Copy metadata from single file</h3>
This will copy metadata from single source file (can be MIE file too) 
into currently selected files. That is, all selected files will be 
populated with the same metadata. After you choose the source file, 
you'll have a chance to reduce the amount of metadata to be copied:<br>
<img src="ExifToolGUI_V652_files/gui03b.png"><br>
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
<img src="ExifToolGUI_V652_files/gui04.png"><br>
-in 99% cases, there will be no reason to check any of above option.<br>
<br>
<h3>Copy metadata into all JPG or TIF files</h3>
This option is very similar to above. The difference is:<br>
<li>No matter how many destination files you select (you must select at 
least one for menu to be enabled), metadata will always be copied into <b>all</b> JPG or TIF (but not both) files inside current folder. That is, this option behaves as if all JPG or TIF files are selected in <b>Scenario 2</b> above.</li>
<li>After you choose this menu option, you'll be first asked "<font class="blue">should files in subfolders also be processed?</font>". If we choose <font class="blue">No</font>, then again, this option behaves the same way as if all files are selected in <b>Scenario 2</b> above. However, if we coose <font class="blue">Yes</font>, then metadata will be copied into images in all subfolders as well (only where folder/file names are equal, of course).</li>
<br>
Let's see an example, where we wish to update <font class="brown">jpg</font> files with metadata from <font class="brown">raw</font> files:<br>
<img src="ExifToolGUI_V652_files/gui04a.png"><br>
<br>
1. Select any destination file inside <font class="brown">MyJpg\Dir1</font>
 folder. If you select any JPG file, then only JPG files will be 
processed; if you select TIF instead, then only TIF files will be 
processed.<br>
2. Choose menu <font class="blue">Copy metadata into all JPG or TIF files</font><br>
3. Click on <font class="blue">Yes</font> button when asked<br>
4. File browser will appear, where you select any (source) file inside <font class="brown">MyRaw\Dir1</font> folder. <u>Note:</u> You only need to select one file (to specify file extension).<br>
5. A panel will appear, where you confirm/check which of "not desired" metadata you <u>wish</u> to be copied:<br>
<img src="ExifToolGUI_V652_files/gui04.png"><br>
<u>Note:</u> Even if none of above is checked, the rest of metadata in source files (Exif, Xmp, etc.) will be copied into destination files.<br>
<br>
That's it: after click on <font class="blue">Execute</font>, metadata will be copied into all files inside <font class="brown">MyJpg\Dir1</font> folder (incl. <font class="brown">Dir2</font> folder) from files inside <font class="brown">MyRaw\Dir1</font> folder (incl. <font class="brown">Dir2</font> folder).<br>
If we would choose <font class="blue">No</font> in step 3 above, then only files inside <font class="brown">MyJpg\Dir1</font> would be processed.<br>
<br>
<br>
<h3>Import GPS data from : Log files</h3>
This option allows geotagging your files in batch by using log file of your GPS device (see here for <a href="https://exiftool.org/geotag.html">supported GPS files</a>).<br> 
<img src="ExifToolGUI_V652_files/gui05.png"><br>
<br>
<u>Step 1:</u> <b>Select log file</b> of your GPS device.<br>
As usually in GUI, you must select files you wish to geotag, first. In 
most cases, folder content will contain series of "session" photos, so 
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
This is funny one... The thing is, log files contain UTC time, while 
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
For further reading/questions see <a href="https://exiftool.org/forum/index.php/topic,3333.0.html">here</a>.<br> 
<br>
<h3>Import GPS data from : Xmp files</h3>
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
<h3>Extract preview image from selected: raw files</h3>
As known, every raw image file also contains JPG image, which serves for
 previewing raw image file content. In most cases, this JPG image is "as
 if photo would be taken in JPG mode" -while this is true for exposure 
and colors, resolution (pixel size) may differ (depends on camera).<br>
<br>
<h3>Embed preview image into selected: raw files</h3>
This does the opposite as previous option does. Because I didn't noticed
 much interest from users, JPG images can be embedded (back) into CR2 
raw files only. That is, I made this for my needs in first place.<br>
<br>
<h2><a name="m_modify">Modify menu</a></h2>
<h3>Exif: DateTime shift</h3>
<img src="ExifToolGUI_V652_files/gui06.png"><br>
<br>
<h3>Exif: DateTime equalize</h3>
<img src="ExifToolGUI_V652_files/gui07.png"><br>
<br>
<h3>Exif: LensInfo from Makernotes</h3>
This will fill <font class="brown">Exif:LensInfo</font> of selected file(s) with relevant values from <font class="brown">Makernotes</font> data (where possible).<br>
<br>
<h3>Remove metadata</h3>
<img src="ExifToolGUI_V652_files/gui08.png"><br>
<br>
Note, that in some cases (depends on image file format), it's not 
possible/safe to remove metadata you've choosed for removing. In such 
cases, ExifTool will simply refuse to remove such metadata (also see <font class="blue">Ignore minor errors in metadata</font> menu above).<br>
<br>
<h2><a name="m_various">Various menu</a></h2>
<h3>File: Date modified as in Exif</h3>
-use it, if you feel the need.<br>
<br>
<h3>File: Name=DateTime+Name</h3>
<img src="ExifToolGUI_V652_files/gui08a.png"><br>
<br>
<h3>JPG: Lossless autorotate</h3>
-this will phisically rotate selected JPG images according to Exif:Orientation value inside files.<br>
<br>
<br>
<h2><a name="p_filelist">Filelist panel</a></h2>
<img src="ExifToolGUI_V652_files/gui09.png"><br>
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
-is set to <font class="blue">Standard filelist</font> by default. This drop-down box also contain few predefined details views: <font class="blue">Camera settings, Location info</font> and <font class="blue">About photo</font> -where each of these views shows few metadata values inside files; i.e.:<br> 
<img src="ExifToolGUI_V652_files/gui10.png"><br>
<br>
No matter how disappointed you might be, you can't define/change tags 
shown in these predefined views. The main and only reason why's that is:
 that's the only way I could get reasonable speed to show this data.<br>
<br>
But to give you at least something, the last entry in this drop-down box is <font class="blue">User defined</font>. If you select that, then <font class="blue">Edit</font> button on the right side becomes enabled, and by clicking on it, you'll get:<br>
<img src="ExifToolGUI_V652_files/gui11.png"><br>
-here you can define your own columns and metadata values to be shown.<br>
<font class="red">Note:</font> Displaying <font class="blue">User defined</font>
 details view is noticeable slower than fixed predefined views. So, use 
this view on relative small amount of files in folder. In short: tryout.<br>
<br>
<h2><a name="p_etdirect">ExifTool direct panel</a></h2>
By clicking on <font class="blue">ExifTool direct</font> button, you get an input field where ExifTool commands can be entered and executed:<br>
<img src="ExifToolGUI_V652_files/gui12.png"><br>
<br>
<u><b>Note:</b></u> Don't need to write "exiftool" here -GUI will take care of calling ExifTool for executing commands you have entered.<br>
<u><b>Note:</b></u> Even you're in "direct mode", <font class="blue">Options menu</font> settings for:<br>
<li>Don't backup files when modifying</li>
<li>Preserve Date modified of files</li>
<li>Ignore existing minor errors</li>
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
<br>
If you wish to modify all files inside currently selected folder, <u>including files in subfolders</u>, then you should use <font class="brown">-r</font> option. Some examples:<br>
<code><font class="brown">-r -Xmp:all=</font></code><br>
-deletes all Xmp metadata from all files inside currently selected folder and subfolders.<br>
<code><font class="brown">-r -Exif:Artist="My Name" -ext jpg</font></code><br>
-set Exif:Artist tag value to My Name for all jpg files inside currently selected folder and subfolders.<br>
<code><font class="brown">-r -Xmp:City=Paris -ext jpg -ext tif</font></code><br>
-set Xmp:City tag value to Paris for all all jpg and tif files inside selected folder and subfolders.<br>
<u>Note:</u> If more than one extension is specified, then (processed) <font class="blue">files counter</font> only counts number of files defined by first file extension. Meaning: if more than one extension is specified, <font class="blue">files counter</font> might not reflect actual number of files.<br>
<br>
<u><b>Note:</b></u> You can't "redirect" output in <font class="blue">ExifTool direct</font>. If you need to do that (i.e. extract thumbnail image), then you should use ExifTool directly (that is, outside GUI).<br>
<br>
<h3>Using predefined ExifTool commands</h3>
There's one predefined ExifTool command in GUI, so you can see what's 
all about. To access it, you click on combo-box (blank on above image) 
and choose it:<br>
<img src="ExifToolGUI_V652_files/gui13.png"><br>
Once command is chosen, you can execute it by pressing Enter key (while 
you're in edit field). If needed, you can modify displayed command and 
execute it, without actually changing predefined command.<br>
<br>
<h3>Modifying predefined commands</h3>
By clicking on <font class="blue">Edit predefined</font> button, panel increases with additional options:<br>
<img src="ExifToolGUI_V652_files/gui14.png"><br>
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
Let's save this text as "MyData.args". <u>Note:</u> File must be saved in the same folder where exiftool.exe is saved (or inside Windows folder).<br>
To execute above commands in GUI (after desired image files are selected), we need to write the following Command into <font class="blue">ExifTool direct</font> panel:<br>
<pre>-@ MyData.args
</pre>
-and press Enter key.<br>
<br>
ExifTool full source version (can be downloaded on top of ExifTool main 
page) contains several predefined args files, which are ment for 
transferring "similar" metadata between sections. One of them is (for 
example) "xmp2iptc.args" file, which copies all "compatible" metadata 
from Xmp to Iptc section. And as said, there are more of them.<br>
<br>
<h3>Show Log Window button</h3>
When using <font class="blue">ExifTool direct</font> mode, any results are automatically written into <font class="blue">Log window</font>. Keep in mind, that content reflects only last executed command.<br>
If, for example, we select two files and execute following <font class="blue">ExifTool direct</font> command:<br>
<pre>-e -gps:all
</pre>
-we will get something like this:<br>
<img src="ExifToolGUI_V652_files/gui14a.png"><br>
<br>
<u>Note:</u> In case of errors, <font class="blue">Log window</font> with relevant messages automatically appears after ExifTool ends processing files.<br>
<br>
<h2><a name="p_metadata">Metadata panel</a></h2>
<img src="ExifToolGUI_V652_files/gui15.png"><br>
<br>
By clicking on any button on top row, relevant metadata will be shown -that is, top row is for displaying metadata only.<br>
<br>
In second row, there's only one button: <font class="blue">Workspace</font>. This button is "pressed" by default on every GUI startup and this can't be changed by user. And where are "good old" <font class="blue"><b>[ ^ ]</b></font> edit buttons, known from previous GUI versions? They're gone.. they aren't needed anymore.<br>
As explained above (see <font class="blue">Workspace manager</font> menu), <font class="blue">Workspace</font> is fully customizable: user can define which tags he wish to be listed here. And value of any tag listed in <font class="blue">Workspace</font> can be edited at will.<br>
<br>
<h3>Edit metadata in Workspace</h3>
<img src="ExifToolGUI_V652_files/gui16.png"><br>
Here's how to edit metadata in <font class="blue">Workspace</font>:
<li>Click on tag line you wish to modify</li>
<li>Press Enter key or click into Value edit field (which becomes yellow)</li>
<li>Write tag value and press Enter key when you're done (or press <b>Esc</b> key to cancel editing)</li>
<li>Tag name you've previously selected becomes yellow and contain value you've just written</li>
<li>If needed, pick another tag and repeat process</li>
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
<img src="ExifToolGUI_V652_files/gui17.png"><br>
<br>
<b>Editing tags which names ends with ± character</b><br>
This sign means tag can have multiple values defined (where keywords are
 most known). Posibilities for entering values for such tags:<br>
<font class="brown">bird</font> -all existing keywords will be deleted and keyword "bird" will be saved.<br>
<font class="brown">+flight</font> -keyword "fligt" will be added to existing list of keywords.<br>
<font class="brown">-bird</font> -keyword "bird" will be deleted from existing list of keywords (if it exist).<br>
<br>
You can also add multiple keywords at once, for example by entering: <font class="brown">+nature+daylight+sky</font><br>
or you can delete multiple keywords at once, for example: <font class="brown">-water-tree</font><br>
<br>
<u>Note:</u> As you know by now, you can't enter keywords which contain + or - sign (which is a bad keywording habbit anyway).<br>
<u>Advice:</u> Don't write stories into keywords -by it's definition, keyword is ment to be a (single) word.<br>
<br>
<h3><a name="m_popup_meta">Pop-up menu in Metadata panel</a></h3>
As mentioned, if you right-click on any tag shown in <font class="blue">Metadata</font> panel, a pop-up menu will appear:<br>
<br>
<img src="ExifToolGUI_V652_files/gui18.png">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="ExifToolGUI_V652_files/gui18a.png"><br>
<br>
<u>Note:</u> Not all options are available all the time.<br>
<u>Note:</u> Tag names will appear colored (as in image above right) only if <font class="blue">Metadata language</font> in <font class="blue">Preferences</font> is set to <font class="blue">ExifTool standard (short)</font>.<br>
<br>
<b>Fill in default values</b> -in <font class="blue">Workspace</font> only<br>
By choosing this option, all tags which names are ending with <font class="red">*</font> character, will be populated with default values (as defined in <font class="blue">Workspace manager</font>).<br>
<br>
<b>Undo selected editing</b> -in <font class="blue">Workspace</font> only <br>
As long edited tag value isn't saved (tag name has yellow background), you can "undo" changes for selected tag.<br>
<br>
<b>Add tag to Workspace</b> -in <font class="blue">Exif, Xmp</font> and <font class="blue">Iptc</font> view only<br>
By using this option, you can easy add any Exif, Xmp or Iptc tag into <font class="blue">Workspace</font>. Selected tag will be added at the end of existing <font class="blue">Workspace</font> list of tags. Once tag is added, you can make further customisation by using <font class="blue">Workspace manager</font>.<br>
<br>
<b>Remove tag from Workspace</b> -in <font class="blue">Workspace</font> only<br>
Do you really need to edit so many tags? Ok, it's your life :)<br>
<br>
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
<h2><a name="p_googlemap">GoogleMap panel</a></h2>
<img src="ExifToolGUI_V652_files/gui19.png"><br>
<br>
<u>Note:</u> <font class="blue">GoogleMap</font> panel will be available only if chosen in <font class="blue">Preferences</font>.<br>
<br>
<b>Show on map</b> button<br>
If selected image is geo-tagged (contains GPS data), then, after
clicking on this button, you can see that geo-position on the map.<br>
<br>
<b>Get location</b> button<br>
Coordinates of current map cursor position on the map are shown in <font class="blue">Find</font> field (for copy/pasting, etc.).<br>
<br>
<b>Zoom</b> trackbar<br>
GoogleMap allready contains zoom tool. The difference is, that by using <font class="blue">Zoom</font>
 trackbar, you're zooming on position where map cursor is. That is, when
 zooming, position of map cursor remains in the center of the map.<br>
<br>
<b>Find</b> field<br>
-for finding places easier...<br>
<br>
<b>Home</b> button<br>
-moves the map cursor to your predefined position.<br>
<br>
<b>Set^</b> button<br>
Current map cursor position becomes <font class="blue">Home</font> position.<br>
<br>
<b>Geotag files</b> button<br>
By clicking on this button, all selected files will be geotagged with current map cursor position.<br>
<br>
<br>
<br>
<h1><a name="final">Final words</a></h1>
Many thanks to Phil, for providing space for GUI on his server and for trusting me to access it.<br>
<br>
Well.. that's it.<br>
P.S.: Don't blame me for my English grammar -it's not my native language.<br>
<br>
Bogdan Hrastnik<br>
Modified on May, 2012<br>
<br>
And if interested: first ExifToolGUI v1.00 was "published" on May 27th, 2007.<br>
<br>

</td></tr>
</tbody></table>

</body></html>
