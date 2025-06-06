unit UnitLangResources;
// Use Shift + CTRL + L to create resourcestring in editor.

interface

resourcestring
  StrBackupOFF              = 'Backup: OFF';
  StrBackupON               = 'Backup: ON';

  StrIncrement              = 'Increment';
  StrDecrement              = 'Decrement';

  SrCmdVerbRefresh          = 'Refresh';
  SrCmdVerbGenThumbs        = 'Generate Thumbnails';
  SrCmdVerbGenThumbsSub     = 'Generate Thumbnails (Incl Subdirs)';
  SrCmdSelLeft              = 'Select left diff';
  SrCmdVerbDiff             = 'Show diff metadata';
  StrSelectRight            = 'Select right diff';
  StrContextMenuFailed      = 'Context menu failed';
  StrMultipleDirsInContext  = 'Context menu for files from multiple directories not supported';

  StrRemDirectoryFail       = 'Remove directory failed code %u';
  StrWriteToSFailed         = 'Write to %s failed';

  StrFilesRenamed           = ' file(s) renamed.';

  StrRequestFailedWith      = 'Request failed with:';
  StrContinueReenabl        = 'Continue ? (Re-enable in Preferences)';
  StrInvalidJson            = 'Invalid JSON received: %s';

  StrAnyGPSLogFile          = 'Any GPS log file';
  StrSelectGPSLogFile       = 'Select GPS log file';
  StrNoValidLatLon          = 'No valid Lat Lon coordinates selected.';
  StrUseTheOSMMap           = 'Use the OSM Map to select';

  StrThisMethodOnlyAnsi     = 'This method only works reliable for ANSI data.';
  StrWarningInternation     = 'Warning. International characters may not be displayed correctly.';
  StrSelectingADiff         = 'Selecting a different font for the cmd window may help.';
  StrTypeSToExecute         = 'type "%s" to execute the generated CMD file.';

  StrNoCustomTags           = 'No custom tags defined';
  StrCannotSaveGUI          = 'Cannot save GUI settings.';
  StrDeleteCustom           = 'This will remove all custom defined tags!';

  StrNotInstalled           = '(Not installed)';
  StrCheckTheGeoCodeRe      = 'Check the GeoCode requirements. (Apikey required. Max 1 call per second for a free account)';
  StrCheckOffLineProv       = 'Warning GeoCode provider changed to ExifTool.';
  StrOverwriteExistingS     = 'Overwrite Existing setting %s?';
  StrMakeSureThatYouO       = 'Make sure that you only check ''Thumbnails'' in the next dialog.';
  StrRunSAsAdminFail        = 'Run "%s" as Admin failed.';
  StrOpenWith               = 'Open with ';
  StrVerbToAddToContext     = 'Verb to add to Contextmenu';
  StrAVerbIsRequired        = 'A Verb is required.';
  StrFolderIncludingSub     = 'Folder, including subfolders, to generate thumbnails for.';
  StrGeneratingBackgr       = 'Generating will be done in the background.';
  StrSelectDefaultStart     = 'Select default startup folder';
  StrSelectDefaultExpor     = 'Select default export folder';
  StrSelectExifToolFold     = 'Select ExifTool folder to use';
  StrSelectGeoLocation      = 'Select ExifTool GeoLocation DB to use';

  StrScreenResolution       = 'Screen resolution: %d x %d at %d DPI Scaled: %d%%';
  StrMISSING                = 'MISSING!';

  StrGeneratingDThumbn      = 'Generating %d thumbnails for: %s';
  StrScanningSubFolder      = 'Total folder scanned: %d';
  StrLoadingSubFolder       = 'Loading %d sub items of: %s';
  StrIconsSubFolder         = 'Loading %d Thumbnails in subfolders of: %s';
  StrWaitingForActive       = 'Waiting for active tasks to complete';

  StrUseSrc                 = '-use as source';
  StrUseDest                = '-and copy here';

  StrRotatingSAngle         = 'Rotating %s Angle: %d Modulo: %d';
  StrCheckAtLeast1Pre       = 'Check at least 1 preview to extract';
  StrExtractingPreviews     = 'Extracting previews';
  StrAllDone                = 'All Done';
  StrSampleS                = 'Sample: %s';

  StrCheck1PreviewImp       = 'Check 1 preview to import';
  StrSelectFolderCont       = 'Select folder containing JPG images';
  StrUpdatingPreviewIn      = 'Updating preview in: %s';

  StrSettingsFor            = 'Settings for: ';
  StrResult                 = 'Result: ';
  StrAvailableData          = 'Available data:';

  StrResettingOrient        = 'Resetting Orientation, ModifyDate: %s';
  StrExtractingPreviewF     = 'Extracting preview from: %s';
  StrRotatingPreviewS       = 'Rotating preview %s Angle: %d Modulo: %d';
  StrImportingPreviewIn     = 'Importing preview into: %s';

  StrCouldNotCompleteC      = 'Could not complete clipboard operation.';
  StrSourceAndTargetSh      = 'Source and target should be different!';
  StrFileSExistsOver        = 'File %s exists. Overwrite?';
  StrOverwriteSFailed       = 'Overwrite %s failed.';

  NotSupported              = 'File type unsupported';
  NotOpened                 = 'Unable to open';
  StrNrOfPhotos             = 'Nr of photos';
  StrFocalLength            = 'Focal length';
  StrFNumber                = 'F-Number';
  StrISO                    = 'ISO';
  StrThisWillFillExif1      = 'This will fill Exif:LensInfo of selected files with relevant';
  StrThisWillFillExif2      = 'values from Makernotes data (where possible).';
  StrOKToProceed            = 'OK to proceed?';
  FileDateFromExif1         = 'This will set "Date Created" and "Date modified" of selected files';
  FileDateFromExif2         = 'according to "%s" and "%s" values.';
  ImportMetaSel1            = 'This will copy ALL metadata from any source into';
  ImportMetaSel2            = 'currently *selected* %s files.';
  ImportMetaSel3            = 'Only those selected files will be processed,';
  ImportMetaSel4            = 'where source and destination filename is equal.';
  ImportMetaSel5            = 'Next: Select source file.';
  StrSelectedDestination    = 'Selected destination file must be JPG or TIF!';
  ImportMetaSingle1         = 'This will copy metadata from single source file,';
  ImportMetaSingle2         = 'into currently selected files.';
  ImportMetaSingle3         = 'Next: 1.Select source file, 2.Select metadata to copy.';
  StrSelectSourceFile       = 'Select source file';
  ImportRecursive1          = 'This will copy metadata from files in another folder';
  ImportRecursive2          = 'into *all* %s files inside currently *selected* folder.';
  ImportRecursive3          = 'Only those files will be processed, where';
  ImportRecursive4          = 'source and destination filename is equal.';
  ImportRecursive5          = 'Should files in subfolders also be processed?';
  StrSelectAnyOfSource      = 'Select any of source files';
  StrInvalidCharsRemoved    = 'Invalid char(s) removed in Tag: %s';
  ImportXMP1                = 'This will import GPS data from XMP sidecar files into';
  ImportXMP2                = 'Exif GPS region of currently selected files.';
  ImportXMP3                = 'Only those selected files will be processed,';
  ImportXMP4                = 'where source and destination filename is equal.';
  ImportXMP5                = 'Next: Select folder containing XMP files.';
  StrChooseFolderContai     = 'Choose folder containing XMP sidecar files';
  StrSpecifyCustomOptio     = 'Specify Custom options to add to Exiftool args';
  StrCustomOptions          = 'Custom options';

  StrWorkspace              = 'Workspace';
  StrETDirect               = 'ExifTool direct';
  StrFileLists              = 'File lists';
  StrCustomView             = 'Custom view';
  StrPredefinedTags         = 'Predefined tags (Marked, Remove/Copy Metadata)';
  StrFileFilters            = 'File filters';

  StrImportIni              = 'Import ini file';
  StrIniImported            = 'Ini file: %s imported.';
  StrIniFileNotChanged      = 'Ini file does not contain data -nothing changed.';
  StrExportIni              = 'Export ini file';
  StrUseAnotherNameForIni   = 'Use another name for ini file!';
  StrIniExported            = 'Ini file: %s exported.';
  StrIniDefContaining       = 'Containing settings for: %s';
  StrIniDefNotSaved         = 'Ini file: %s file couldn''t be saved!';

  StrTagAlreadyExistsI      = 'Tag already exists in Custom view.';
  StrOK                     = 'OK';
  StrNotOK                  = 'Not OK';
  StrExecuteDSUpdat         = 'Execute: %d %s Update/ET Direct status: %s';
  StrRestRequestSUpd        = 'Rest request: %s Update/ET Direct status: %s';
  StrSelectedFileHasNo      = 'Selected file has no valid Lat Lon coordinates.';
  StrWithinCountry          = 'Within Country code';
  StrWithinCountryRegion    = 'Within Country code or Region';
  StrFiles                  = 'Files/Folders: %d';
  StrTheWebView2Loaderd     = 'The WebView2Loader.dll could not be loaded.';
  StrShowOnlineHelp         = 'Show Online help?';
  StrUnableToStartEdge      = 'Unable to start Edge browser.';
  StrExifToolNotExecute     = 'ExifTool not executed!?';
  StrNoMoreMatchesFo        = 'No (more) matches found.';
  StrMinimizedToTray        = 'Minimized to tray.';
  StrClickToDisableThi      = 'Click to disable this hint.';
  StrErrorPositioningHo     = 'Error positioning Home';
  StrYes                    = 'Yes';
  StrNo                     = 'No';
  StrHor                    = 'Hor.';
  StrVer                    = 'Ver.';
  StrRot                    = 'Rot.';
  StrERRORExifTool1         = 'ERROR: ExifTool could not be started!';
  StrERRORExifTool2         = 'To resolve this you can:';
  StrERRORExifTool3         = '- Install Exiftool in:';
  StrERRORExifTool4         = '- Install Exiftool in a directory in the Windows search sequence.';
  StrERRORExifTool5         = 'For example in a directory specified in the PATH environment variable.';
  StrERRORExifTool6         = 'For more info see the documentation on the CreateProcess function.';
  StrERRORExifTool7         = '- Locate Exiftool.exe and specify the location in Preferences/Other.';
  StrERRORExifTool8         = 'Metadata operations disabled.';
  StrERRORExifTool9         = 'Note: This error can also occur if you browse to an invalid folder.' +
                              ' A DVD/CD drive without media, or a Zip file, for example.';
  StrAdministrator          = 'Administrator:';
  StrWarningOnlyDRes        = 'Warning. Only %d results returned from %d workspace commands.';
  StrNOAst                  = '*NO*';
  StrYESAst                 = '*YES*';
  StrExifToolExecuted       = 'ExifTool executed';
  StrNoData                 = 'No data';
  StrNoFilesSelected        = 'No files selected.';
  StrErrorSSCreating        = 'Error %s %s creating thumbnail for: %s';
  StrRemainingThumbnails    = 'Remaining Thumbnails to generate: %d';
  StrDFilesRemaining        = '%d Files remaining';

  StrStandardList           = 'Standard file list';
  StrCameraList             = 'Camera settings';
  StrLocationList           = 'Location info';
  StrAboutList              = 'About photo';
  StrUserList               = 'User Defined';

  StrFLModel                = 'Model';
  StrFLLensModel            = 'LensModel';
  StrFLExpTime              = 'ExpTime';
  StrFLFNumber              = 'FNumber';
  StrFLISO                  = 'ISO';
  StrFLExpComp              = 'ExpComp.';
  StrFLFLength              = 'FLength';
  StrFLFlash                = 'Flash';
  StrFLExpProgram           = 'ExpProgram';
  StrFLOrientation          = 'Orientation';

  StrFLDateTime             = 'DateTime';
  StrFLGPS                  = 'GPS';
  StrFLCountry              = 'Country';
  StrFLProvince             = 'Province';
  StrFLCity                 = 'City';
  StrFLLocation             = 'Location';

  StrFLArtist               = 'Artist';
  StrFLRating               = 'Rating';
  StrFLType                 = 'Type';
  StrFLEvent                = 'Event';
  StrFLPersonInImage        = 'PersonInImage';

  StrFLPhotoTitle           = 'Photo title';

  StrShowAllFiles           = 'Show All Files';
  StrStartupTime            = 'Setting this item as startup could potentially increase startup time';

  StrThumbNails             = 'Thumbnails';
  StrDetails                = 'Details';
  strConfigure              = 'Configure';
  StrExistSavedFirst        = 'Existing definitions will be saved first!';
  StrNewName                = 'New Name';
  StrCopy                   = 'Copy';

  StrUseNone                = 'None (Show error)';
  StrUseStandardSeq         = 'Use standard sequence';
  StrUseCustomSeq           = 'Use custom sequence';
  StrItemsSelected          = ' (%d items selected)';

implementation

end.
