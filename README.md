# ExifToolGui
<h4>A GUI for ExifTool</h4>

This is an updated version of the ExifToolGui program created by Bogdan Hrastnik. Many thanks go out to him.

<b>Free Software, Hope for the Future</b>
This project is freely available to everyone. If you appreciate it, you might consider supporting research into cancer or Alzheimer’s disease by donating to your local charity organisation.

<h4>Released version: V6.3.13 updated November 20, 2026</h4>

- A warning message pops up when custom options are in effect. You can ignore them!<br>
- Filtering was added, on top of the existing filtering that works on file names.<br>
  On the right side of the Bread crumb bar (that needs to be enabled) an edit box is added. Typing a search text starts selecting the files that match.
  Matching is done on all columns, not only the file name.<br>
  Pressing Enter moves to the first/next file that matches. Pressing Ctrl+Cursor Up/Down move to the previous/next file.<br>
  Clicking on the filter icon will only show the files matching.<br>
- Use the standard Windows translation for Message boxes. (EG OK, Cancel, Yes, Yes to all etc.)<br>
- When the file list details are set to 'Location info', and the OSM Map is selected, selecting one or more files will display their location on the map.
  Without the need to click 'Show on map'.<br>
- When a file filter is selected that contains ';/s' (for scanning sub files) it is no longer needed to 'Enable folders in the file list' (Preferences)
  This results in a 'cleaner' overview in the file list.<br>
- Add dresel.systems as a primary server for OverPass. [Readme GeoCoding](../../blob/main/Docs/Readme%20GeoCoding.txt)<br>
  Thanks to Christian! https://ovp.dresel.systems and https://nominatim.dresel.systems

Fixes included:

- Check versions dialog should show checkmark if installed version is newer.<br>
- Archive files do not show metadata.<br>
- Right-click to add to workspace leads to error.<br>
- Add help button to configure file lists.<br>
- Fix for ShellTreeview (Performance)<br>
- Check versions dialog should show checkmark if installed version is newer<br>
- For the complete info see the [changelog](../../blob/main/Docs/changelog.txt).<br>

# Download

[Latest release](https://github.com/FrankBijnen/ExifToolGui/releases/latest)<br>

<h4>Important</h4>

- [Please <b>read</b> the Requirements and preparation, or use the supplied installer](https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md/#m_reqs_general)<br>
- Map files are no longer released separately. If you need them use the option provided by the installer.

# Useful links

<h4>Obtaining Exiftool</h4>

1) The original version by Phil Harvey. https://exiftool.org/ <br>
   Starting with Version V12.88 the instructions for downloading and installing have changed: https://exiftool.org/install.html

2) An installer provided by Oliver Betz. https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows

<h4>Obtaining WebView2Loader.dll</h4>

-  https://nuget.info/packages/Microsoft.Web.WebView2/

<h4>Online Documentation</h4>

 - [V6 Documentation html](https://htmlpreview.github.io/?https://github.com/FrankBijnen/ExifToolGui/blob/main/Docs/ExifToolGUI_V6.md)
 - [V6 Documentation md](/Docs/ExifToolGUI_V6.md)
 - [Docs directory](Docs/)

<h4>Showcase</h4>

[Showcase](Docs/ShowCase/ShowCase.md)<br>

# GNU General Public License v3.0

<h4>Updated license statement March 23, 2024</h4>

[License Statement](LICENSE)

Frank
