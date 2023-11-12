Starting with Version 6.2.5 the executables Jhead.exe and Jpegtran.exe are no longer needed. They can however still be used, but the menuitems are marked 'deprecated'.
This change affects: JPG Lossless rotate and Export/Import previews.

In V6.2.5 you will see 2 menu-items for Jpg Lossless rotate: 
- Various/Jpg Lossless autorotate... (Deprecated)
  This is the menu-item that uses Jhead.exe. It will be greyed out if the exe is not available.
  It will continue to function, but will be deleted in a next release.

- Various/Jpg Lossless rotate + crop
  This is the new menu-item. It uses the stripped Delphi library NativeJpg to perform rotating.

  Advantages of this new item.
  - In addition to auto-rotate you can specify 90, 180 and 270 degrees.
  - You can also specify to crop the image size to a multiple of 8, 16. This can be handy when you use other programs that require JPEG's to be a multiple of x.
  - Specify how you want the orientation to be set after rotating.
  - Select an embedded preview to rotate.

  Note: If you don't change the default settings it should work the same as the jhead.exe program.

In V6.2.5 you will see 4 menu-items for Importing (Embedding) and Extracting previews.

Menu-items deprecated. They will continue to function, but will be deleted in a next release.
- Export/Import/Extract preview from selected (Deprecated)
- Export/Import/Embed preview from selected (Deprecated) (Note: It will be greyed out if jpegtran.exe is not available)

New Menu-items.
- Generic extract previews
- Generic import preview

Besides the fact that these functions no longer require an external program (jpegtran.exe) they have additional functionality.

- Extracting.
  Generic. No restrictions imposed.
  You can now see and check the previews available. If you select multiple files, it will show the info for the first selected file.
  Options:
  - Choose to create subdirectories for extracted previews. 
  - Autorotate, and or crop, the previews.

- Importing.
  Generic. No restrictions imposed.
  You can now see the existing preview. The preview that gets overwritten. Info for 1st selected file shown.
  You should check just one (1) preview to import!
  Options:
  - Autorotate, and or crop the selected jpeg's before they are imported.

Important notes:
- Take care when you select multiple files that they have the same characteristics. The info for the preview is only for the 1st selected file.

- I have tried to make these functions as flexible as possible, and thus you can select 'illegal' combinations. Use it sensibly!
  An example is when you try to import a JPG into a PEF file and try to overwrite 'Pentax:Preview', you will get:  Warning: Sorry, Pentax:PreviewImage doesn't exist or isn't writable

Why I think the original menu-items are not 'generic'.

- The original menu-item for Export used the following fixed table for exporting:
  DNG, CR2: PreviewImage
  NEF, NRF, RW2, PEF: JpegFromRaw   

- The original menu-item for Import allowed only CR2 files and always wrote it to PreviewImage

My personal motives for updating these functions: 
- I use DNG files, created by Adobe DNG Converter. Adobe Dng Converter saves a preview in JpegFromRaw, not in PreviewImage.
- I was unable to update the preview in my DNG files, only CR2 was allowed.

Frank
