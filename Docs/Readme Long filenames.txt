Long Filenames.

To be clear. I dont mean filenames that exceed 8.3. I mean filenames that exceed MAX_PATH. That is the nr. of characters including the full path is higher than 260 characters.

I made a few changes as described in https://github.com/FrankBijnen/ExifToolGui/issues/140 to support these long filenames. 
These changes fixed the Shelllist (the list of files you see), the preview, thumbnail generating and getting Metadata info for the filelist.
I did NOT test other functions, maybe I will reopen the issue if I happen to spot an error. I dont consider this to have a high prio.

Frank