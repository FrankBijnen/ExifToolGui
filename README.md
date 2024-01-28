# ExifToolGui
<h4>A GUI for ExifTool</h4>

This is an updated version of the ExifToolGui program created by Bogdan Hrastnik. Many thanks go out to him.

<b>Released version: <b>V6.2.9</b> updated January 28, 2024.</b><br>

- Support for 4K monitors, including scaling and resizing, completed. Commandline parameters not needed anymore.<br>
- Fixes for issues found in Geocoding. Especially Video files. [Readme GeoCoding](Docs/Readme%20GeoCoding.txt)<br>
- Optionally show hidden files & folders.<br>
- Added keyboard shortcuts.<br>
- Integration in Windows Explorer. [Readme Shell integration](Docs/Readme%20Shell%20integration.txt)<br>
- Added support for more filetypes in FileList. (Camera settings, Location info and About photo)<br>
- Add option LargeFileSupport<br>
- Preparations for multi-language
  If you're interested in creating/updating a translation, see: [Translation](Translation/README.md) <br>

[Change log](Docs/changelog.txt)<br>
[Download Release](https://github.com/FrankBijnen/ExifToolGui/releases/latest)<br>

<h4>Important</h4>

- [Please <b>read</b> the Requirements and preparation](https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md/#m_reqs_general)<br>
- To help Bug hunting also Map files are released. If you place the Map file in the same directory as the Executable
a stacktrace can be copied to the clipboard if an Exception occurs. Please also provide the stacktrace if you report an Exception.<br>

# Useful links

<h4>Obtaining Exiftool</h4>

1) The original version by Phil Harvey. https://exiftool.org/ <br>
   Download the zip file called: Windows Executable: exiftool-xx.yy.zip. <br>
   Unzip the exe and rename it to 'exiftool.exe' in a directory that Windows searches. (Without the quotes) <br>
   Can be the directory where 'ExifToolGui.exe' is located.

2) An installer provided by Oliver Betz. https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows

<h4>Obtaining WebView2Loader.dll</h4>

-  https://nuget.info/packages/Microsoft.Web.WebView2/

<h4>Online Documentation</h4>

 - [V6 Documentation html](https://htmlpreview.github.io/?https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md)
 - [V6 Documentation md](/Docs/ExifToolGUI_V6.md)
 - [Docs directory](Docs/)

<h4>Showcase</h4>

[Showcase](Docs/ShowCase/ShowCase.md)<br>

<h4>Legal, Copyright etc.</h4>

This is a continuation of the project started by Bogdan Hrastnik. He did not mention any License, and or Copyrights. Likewise I will not. 
I have used some open source components, you can find their legal info in the corresponding subdirectories.


Frank
