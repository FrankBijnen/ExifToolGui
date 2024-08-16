Scanning and displaying subfolder in GUI

Pereq

- Enable 'Show folders' in preferences.

Enabling

- Edit file filter (Right to 'Show all files')

- Add an entry with '/s'

  A File filter consists of entries separated by a semicolon
  Each entry specifies a mask, or the modifier '/s'.
  A mask can contain literal character, or special characters like * or ?. See the the functions MatchesMask https://docwiki.embarcadero.com/Libraries/Athens/en/System.Masks.MatchesMask

  Typical usage:             *.jpg;*.mp4;/s
  Or even (not recommended): *.*;/s 
  Advanced                   [A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9].jpg;/s    IMGP0001.jpg (first 4 chars need to be A-Z, last 4 chars need to be 0-9)

Using

- When /s is found subfolder are scanned. Obviously this can take longer, so you will see a progress form, with a button Close. Close will stop the scannning.
  - Folders are only included the next level relative to the selected folder.
  - Files are included until no more files are found matching the pattern.

  Example of 6 files on disk.
  
  c:\foto
  c:\foto\dir1\a.jpg
  c:\foto\dir1\sub\a1.jpg
  c:\foto\dir2\sub\a2.jpg
  c:\foto\dir2\b.jpg
  c:\foto\dir2\sub\b1.jpg
  c:\foto\dir2\sub\b2.jpg

  this will be shown in the filelist when c:\foto is selected. (Extension shown only when the option in Windows Explorer allows it)

  dir1                  File folder
  dir2                  File folder
  dir1\a.jpg            JPG File
  dir1\sub\a1.jpg       JPG File
  dir1\sub\a2.jpg       JPG File
  dir2\b.jpg            JPG File
  dir2\sub\b1.jpg       JPG File
  dir2\sub\b2.jpg       JPG File

- Most functions are available on the (sub)files shown, with these 2 exceptions:

  - A context menu (right click) can not be shown when multiple files from different subdirectories are selected.
    dir1\sub\a1.jpg and dir1\sub\a2.jpg can be combined, but not with dir1\a.jpg

  - Export/Import Copy metadata into all JPG or TIF files... is disabled.  
    This function can work on subdirectories, so that would be confusing.

- All other functions, including ExifTool Direct, Metadata panel, OSM panel work as expected.

- Column sorting.

  - In thumbnail mode the sort order is always Folders first, followed by files. The relative name is used for sorting. This can not be changed.
    Relative name = The name relative to the currently selected path.

  - In detail mode you can use column sorting. But beware of the performance considerations.

    - Standard file list. This works relatively fast on all columns.

    - Camera details, Location info, About photo. 
      When sorting is active on Filename this is also relatively fast.

      Sorting on other columns force GUI to get the details of all files selected, this will be much slower.
      Even more if you have enabled 'Use exiftool for unsupported files' in preferences.

      Technical background. GUI can get the info for known image types (JPG, PEF, DNG, NEF, CR3 etc.) quickly by reading the files without using ExifTool.
                            (Bogdan Hrastnik created Delphi code to achieve this.)
                            But for other filetypes (E.G. mp4, mov, pdf) this code does not work. To get the details of these files GUI has to call upon ExifTool. 

    - User defined
      Sorting on Filename is also relatively fast, any other column will be an excercise in patience.
      GUI has to execute exiftool for all files found to get the details. It does that in Stay_open mode, but nevertheless it's time-consuming.
