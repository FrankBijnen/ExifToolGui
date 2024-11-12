Long File names.

To be clear. I dont mean file names that exceed 8.3. I mean file names that exceed MAX_PATH. That is the nr. of characters including the full path is more than 260 characters.

Introduced with ExifTool 13.01, but 13.03 recommended / ExifToolGui V6.3.6:

ExifTool has added the option -Api WindowsLongPath, that adds support for Long path in ExifTool. You'll be able to use that API option in GUI V6.3.6. This option is enabled by default in GUI, if you experience problems deactivate it.
Enabling this option allows ExifTool to read and write files where the total path is longer than 260 chars
  
Example of a file name that is 280 chars long:
z:\TestPath\LONG DIR901234567890123456789012345678901234567890\SUB DIR1 01234567890123456789012345678901234567890\SUB DIR2 01234567890123456789012345678901234567890\SUB DIR3 01234567890123456789012345678901234567890\123456789012345678901234567890123456789012345678901234567890.jpg 

ExifTool API doc: https://exiftool.org/ExifTool.html#WindowsLongPath

ExifToolGui V6.2.5:

I made a few changes as described in https://github.com/FrankBijnen/ExifToolGui/issues/140 to support these long filenames. 
These changes fixed the Shelllist (the list of files you see), the preview, thumbnail generating and getting Metadata info for the filelist.
Exiftool itself may not be able to read those files, I often get Error: 'File not found ......'. Needs investigating.
I did NOT test other functions, maybe I will reopen the issue if I happen to spot an error. I dont consider this to have a high prio.

Frank
