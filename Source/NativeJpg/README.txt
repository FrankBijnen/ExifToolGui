This is a modified, minimal, version of NativeJpg by: Nils Haeck, SimDesign BV. 

Changes to the original library:

- Only the lossless functions (in sdJpegLossless.pas) were of interest to ExifToolGui. Other parts that were not needed were stripped out.

- DoDebugOut. Removed all classes TDebugComponent, TDebugObject, TDebugPersistent 
	
	- Deleted all wsInfo
	- wsWarn -> DebugMsg
	- wsFail -> Exception

- A few changes were made to enable compiling for WIN64. (Pointers cast to integer replaced by NativeInt for eaxmple)

- UTF8String -> string. To get rid of the compiler warnings.
  Note: AnsiStrings are unchanged. Especially those strings used in JPEG files.

- Uses statements. Added the prefix. (Windows -> Winapi.Windows)

- Added blank lines before procedures/functions to improve readability.

Changes to ExifToolGui.

- If jhead and jpegtran are found they will still be used. For compatibility reasons. But the Menu items are marked 'Deprecated'.
- New menu items are created that use this library, and cover the functionality of the deprecated menu items.
  - Generic extract previews. 	Crop and rotate can be selected for the exported JPEG's.
  - Generic import preview.	Optionally crop and rotate JPEG's before import
  - JPG: Lossless autorate.	Replace functionality of Jhead autorot. Using ExifTool and this library. 

Reasons to prefer this libray.

- No need to install 3rd party programs (jhead, jpegtran) anymore. All functions are compiled into the exe.
- Open source. See LICENSE.txt 
- Truly lossless. It will even handle JPEG's if their sizes are not a multiples of 8, or 16.
- The source code looks good. Very readable. This makes support easier.
