# ExifToolGui V6.3.0
<h4>Download portable version</h4>

- ExiftoolGui.exe Executable for Win32
- ExiftoolGui_X64.exe Executable for Win64

Note: You should handle all requirements yourself.
- Download and install ExifTool.exe.
- Download and install WebView2Loader.dll. Only needed if you want to use the OSM map.
- Download and install Language DLL's. See below.
- Download and install MAP files. Only needed to provide additional info in the event of an exception.

- Please read the Portable notes.

<h4>Download Installer</h4>
The installer should handle all requirements mentioned with the Portable version automatically.
Depending on your Windows version the WIN32 or WIN64 files will be installed.
Should you prefer the WIN32 files on a WIN64 windows, then you can add /Win32 as a parameter to the installer.

It is recommended to choose the 'Setup install mode' 'Install for all users' and choose the 'full installation'.
In the additional tasks your have the options to create a desktop icon (recommended), and to download and install the latest version of Exiftool.
If 'by Phil Harvey' is chosen, the Exiftool zip file will be download and the exe unzipped and renamed in the installation folder.
If 'by Oliver Betz' is chosen, the latest installer will be downloaded and run after the installation of ExifToolGui.
(It is recommended to choose 'Add to Path', so ExiftoolGui will be able to find ExifTool.exe)

<h4>Release info.</h4>

- As you can see an installer has been created.

- Added a menu item to check for updated versions.

- Translations are available for Dutch, German, French, Italian, Portuguese and Spanish.
  If you have selected the Language DLL's during the install, then the Language will be automatically selected according to your Windows languge. (If available)
  You can force a language by adding one of these commandline parameters: /Lang=NLD, /Lang=DEU, Lang=FRA, Lang=Ita, /Lang=PTB, Lang=ESP, Lang=ENU
  Should you regret your choice, because you feel the translation is really bad, simply uninstall ExiftoolGUI and reinstall without the Language DLL's. 

  Many translations were done with help from Deepl, if you feel they need improving add a comment to one of the issues.

- Added an option in preferences to specify a custom config

- A nasty bug has been corrected that prevented showing images/videos on the OSM map with negative GPS coordinates.

- Exiftool "-api geolocation" and "-geolocate=" support has been added, as a Geocode provider.

- Style fixes for Darkmode styles.

- For the complete info see the changelog.

Frank
