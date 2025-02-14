Version V6.3.7

- It appears that no additional Codecs need to be installed for Windows 11. The Raw Image Extension from the Microsoft Store is installed by default.

- Gui prefers the MS Codecs. In Preferences/Thumbnails a checkbox has been added to allow 3rd party Codecs to be used.

Since ExifToolsGui now relies on WIC (Windows Imaging Component) a few words on the codecs I have tested.

The codecs are used in 2 places. First in the Thumbnails that you can see in the filelist when you set the Details to off. Second in the preview situated Left Bottom.

I have tested 3 codecs with PEF (Pentax) and DNG images in Windows 10. 
The DNG images were either created directly by the camera, or converted with Adobe DNG Converter.
Camera's used are Pentax K100D, Pentax K-X and Pentax K5II-s.

I also have JPG's and MP4's created by an Android Samsung phone, the standard Windows Codecs are sufficient for them.

1) Raw Image Extension that you can obtain from the Microsoft store.

   Pef: Works in Preview and Thumbnails
   Dng: Works in Preview, but very often not for the Thumbnails. 

   Other Raw formats like Sony Arw, Canon CR2 and Nikon Nef seem to work, but I have a very limited amount of images to test.

2) FastPicture viewer. Download from https://www.fastpictureviewer.com/

   Looking at the website you may think it is not free. But if you only need the Raw codec the 'Home Basic' is sufficient and is free for peronal use.
   Install the 32/64 Bits version as required by your OS.
   In the installer dialog only keep the 'Images Codecs (Raw Support)' set the other to 'Entire feature will be unavailable'. Unless you want try them ofcourse.

   All tested raw formats (Pef, Dng noticeably) work for Thumbnails and Preview.
   It is worth mentioning that the preview in the raw file is extracted. So very fast, but the camera settings are not applied.

3) Adobe DNG Codec 2.0
   Adobe does not provide this Codec anymore, but if you search the net you will find the links.

   Works for Thumbnails and Preview, obviously only for DNG files.
   Contrary to the FastPicture viewer it can apply the camera settings, which makes it considerable slower.
   If you install FastPicture viewer and Abobe DNG Codec both, the latter is preferred by Windows.

Frank
