Shell integration additions.

Portable users: The functions described hereafter will write in the registry, and thereby not complying with portable use. If you have concerns with that dont use these functions.


Starting with Version 6.2.9 ExifToolGui has more integration in the Windows Shell.

- It detects if you have Admin rights, needed to:
  - Enable the option 'Show Hidden Folders and Files in FileList' in 'Preferences/Other'
  - Enable the button 'Setup Disk cleanup for thumbnails' in 'Preferences/Thumbnnails'.

- It detects if it was started as Admin. If started as an Admin:
  - It will always show Hidden Folders and Files in the FileList.
  - You can register ExifToolGui in the Contextmenu of Windows Explorer.

- In the tab 'Shell Integration' in 'Preferences' you can:
  - Enable 'When minimized move to tray'.
  - Enable 'Single instance'.
  - Add/Remove GUI to the Contextmenu.

Notes:

- If you enable 'When minimized move to tray', the tray icon provides these functions.

  - Left click will restore the main window.
  - Right click shows a popup menu with the version and an option to reset the window sizes to default.

  A balloon is shown, reminding you that there is a tray icon placed. Turn this balloon off by clicking on it.
  To make the icon permanently visible, use 'Taskbar settings' and look for 'icon settings'. Details vary with every Windows version!

- Enabling 'Single instance' is particularly useful if combined with the contextmenu, or you'll end up with lots of GUI windows.

- Add/Remove GUI to the Contextmenu.
  Start GUI as admin to add or remove it to the contextmenu!

  When you add it, you will be asked a 'Verb' (An ID in the contextmenu, use something you can remember).
  After succesful installation you can right click on a folder in Explorer and the 'Verb' should be visible. Clicking it will open GUI in that folder.
  If 'Single instance' is selected, and GUI was minimized to the tray it will restore the minimized window and open the selected directory.

  Windows 11: Read the instructions in Preferences/Shell Integration!

Frank
