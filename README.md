# ExifToolGui
<h4>A GUI for ExifTool</h4>

This is an updated version of the ExifToolGui program created by Bogdan Hrastnik. Many thanks go out to him.

Current version: <b>V6.2.7</b> updated December 25, 2023.<br>
- Deprecated functions that use Jhead or JpegTran have been removed.<br>
- Added peek preview for metadata panel. Shown as hint.<br>
- Added option to show Folders in filelist, including a Breadcrumb Bar.<br>
- Added option to add custom tags to Exiftool.<br>
- Fix for generated Powershell script.<br>
- Style fixes for Green.<br>
- Experimental support for [4K Monitors](Docs/Readme%204K%20monitor.txt).<br>
  If you experience problems with scaling, window positions etc. add <b>/HighDpi=UnAware /Scale</b> as parameters to the shortcut.

[Change log](Docs/changelog.txt)<br>
[Download Release](https://github.com/FrankBijnen/ExifToolGui/releases/latest)<br>

<h4>Important</h4>

- [Please <b>read</b> the Requirements and preparation](https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md/#m_reqs_general)<br>
- To help Bug hunting there are also Map files released. If you place the Map file in the same directory as the Executable
a stacktrace can be copied to the clipboard if an Exception occurs. Please also provide the stacktrace if you report an Exception.<br>

# Useful links

<h4>Obtaining Exiftool</h4>

1) The original version by Phil Harvey. https://exiftool.org/ <br>
   Download the zip file called: Windows Executable: exiftool-xx.yy.zip. <br>
   Unzip the exe and rename it to 'exiftool.exe' in a directory that Windows searches. (Without the quotes) <br>
   Can be the directory where 'ExifToolGui.exe' is located.

2) An installer provided by Oliver Betz. https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows

<h4>Obtaining WebWiew2Loader.dll</h4>

-  https://nuget.info/packages/Microsoft.Web.WebView2/

<h4>Online Documentation</h4>

 - [V6 Documentation html](https://htmlpreview.github.io/?https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md)
 - [V6 Documentation md](/Docs/ExifToolGUI_V6.md)
 - [Docs directory](Docs/)

Frank
