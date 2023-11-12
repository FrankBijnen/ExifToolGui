ExiftoolGui Portable?

Bogdan Hrastnik stated in his documentation on https://exiftool.org/gui/ Bullet 2. ExifToolGui.

"GUI doesn't write anything into registry file or elsewhere. After first usage, all settings are written into "ExifToolGUI.ini" file, which is automatically
created in the same folder where "ExifToolGUI.exe" has been started from."

If you read the WIKI at https://en.wikipedia.org/wiki/Portable_application Heading: Portable Windows application

"A portable application does not leave its files or settings on the host computer or modify the existing system and its configuration. The application does 
not write to the Windows registry[citation needed] nor stores its configuration files (such as an INI file) in the user's profile;"

I will not argue with these definitions, if that's the definition of a portable application. so be it. But I would like to point out a potential problem with the 
proposed location of the ini file.

Given the fact that one should be able to start a portable application from a read-only medium without installing. 
  Where read-only could be:
  - A network location that you dont have write access to.
  - A directory on the hard-drive. For example "c:\program files\exiftool". An administrator could have installed it, and the user will only have read access.
  - A usb stick that is write-protected. To make sure that it does not get infected by a virus.
  - A CDrom.
  - etc...
then saving the settings to the same location as the program is not a good choice!

That is the reason why I decided to save the ini file in %AppData%\ExifToolGui. That is a directory that is more or less guaranteed to be writable.
But then I received reports that ExifToolGui was no longer portable, because it 'left traces' on the computer. 

Reluctantly I added a program parameter '/DonSaveIni'. When specified ExifToolGui will not write the INI file. A typical use-case is this.

- Start ExifTooGui normal.
- Setup all that you need.
- Close ExifToolGui
- Move the generated INI File to the program directory.
- Create a shortcut to ExifToolGui.exe with the commandline parameter /DontSaveIni

If you burn this to a CD, or copy it to a USB stick that you write-protect afterwards, I can imagine that it will be useful. (To some)

But If you use this parameter and think you will leave no traces on the computer, you may be disappointed.

- ExifTool itself will write to the TEMP directory. To overcome this you could propably install Perl, or install the 'Oliver Betz' version. But depending on the options chosen you need to be admin to install, and it will leave traces.
- The integrated WebBrowser based on EDGE will write temp-files.
- To control ExifTool and the Edge browser temp-files are created.
- Windows may keep MRU (Most Recently Used) entries in the registry.

My personal view:

- You should be able to start ExifToolGui without admin privileges from a 'readonly' location.
- It should save it's settings to a location that's writable, (%AppData%\ExiftoolGui ....) or optionally not save any settings at all.
- The temp-files should be deleted upon closing the application. But in case of abnormal termination it's only logical that they are not deleted.
- 'Leaving no traces' should not be the goal of the design. Besides the fact that it's nearly impossible, why would you want it? To me it has a nasty smell, what do you want to hide?

Frank


