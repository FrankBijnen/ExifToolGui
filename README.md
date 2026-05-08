# ExifToolGui
<h4>A GUI for ExifTool</h4>

This is an updated version of the ExifToolGui program created by Bogdan Hrastnik. Many thanks go out to him.

<b>Released version: <b>V6.3.12</b> updated May 8, 2026</b><br>

- Updated Japanese language. Thanks coolvito!
- Improved support for HEIC images.
  - Exif and XMP tags can now be used in the filelist with readmode=internal.
  - Fixed issue with auto rotating previews.
  - Note: Windows 11 comes standard with the needed codec.
- Added SubjectArea in the Regions tab. Thanks Steerpike!
- Update MapTiler baselayers to V4, added Hybrid satellite, and fixed label sizes.
- In the field definitions for the Filelist and the Workspace you can now specify the tags like this:
<table>
<tr><td>G0:G1:Tag</td><td>Exif:Ifd0:Make</td></tr>
<tr><td>G1:Tag</td><td>Ifd0:Make</td></tr>
<tr><td>G0:Tag</td><td>Exif:Make</td></tr>
<tr><td>Tag</td><td>Make</td></tr>
</table>

- When adding a field to the FileList, or WorkSpace from the Metadata tab using right click it is always added as:<br>
Thanks KarenBbla!
<table>
<tr><td>G1:Tag</td><td>Ifd0:Make</td></tr>
</table>

Fixes include:

- Fixed Access violation error when changing styles. Thanks Gitoffthelawn!
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
