Being a Windows application ExifToolGui respects most keyboard shortcuts. 

A summary of the most well known.

- Alt/F4                Close
- (Shift)Tab            Moves to the previous/next field
- Esc                   Cancel, Close the dialog without saving
- Enter                 Perform action on the active control, usually a button that has the focus.
- Alt + Char            Access the program main menu. Char = The underlined character in the menu.
- CTRL C,X,V            Copy, Cut from input field, Paste into input field.

Navigating in an input field, or list.

- Home, End             Move to first, last item
- Page Up, Down         Move to the previous, next page
- Cursor Up, Down       Move to the previous, next line


In addition some specific shortcuts are worth mentioning.

(Shift)TAB              In the main window cycles the focus from the Directory treeview, to the FileList, to ExifTool Direct (If opened) to the Workspace, or OSM Map.
CTRL/D                  Focuses the Directory treeview
CTRL/L                  Focuses the File list
CTRL/T                  Opens and focuses ExifTool Direct. If open closes.
CTRL/W                  Opens and focuses the Workspace
CTRL/M                  Opens and focuses the OSM map.

In the Directory treeview:

- Cursor Left, Right    Colapses, Expands the item. 
- CTRL X,C,V            Cut, Copy, Paste directory. Note: After using CTRL/X make sure to move to another directory, before pasting.
                        If you dont, deleting will fail, because ExifTool locks the directory.
- F2                    Rename.

In the File list

- Cursor Left, Right    Move to the previous, next item in thumbnail mode
- CTRL A                Select all items.
- CTRL X,C,V            Cut, Copy, Paste directory. Note: After using CTRL/X make sure to move to another directory, before pasting.
                        If you dont, deleting will fail, because ExifTool locks the directory.
- CTRL -, + (Num pad)   In thumbnail mode, decreases, increases icon spacing.
                        Note: You can also the mouse wheel to (de)(in)crease the icon spacing.
- CTRL 0  (Num pad)     In thumbnail mode, resets icon spacing.
- F2                    Rename.

In ExifTool direct.

- Esc                   Closes ExifTool direct
- Enter                 Executes command
- Tab                   Focuses the predefined list

In the predefined list of ExifTool Direct
- Cursor Up/Down        Selects the previous/next item in the list.
- Shift Tab, Enter      Focuses on the ExifTool command
- Tab                   Focuses on the Workspace, or OSM map

In the Workspace
- CTRL C                Copies the metadata value to the clipboard
- CTRL/ALT C            Copies the metadata tag name to the clipboard
- CTRL S                Saves pending changes
- CTRL I                Inserts the tag name in the ExifTool direct command
- CTRL Cursor Up/Down   Loads the previous/next file from the file list

Line editing NOT enabled in Preferences
- Enter                 Focuses the Edit box at the bottom, to edit the current line

Line editing enabled in Preferences
- You can enter the new value directly in the grid. 
  Moving to another line marks the line as modified. (EG Cursor or Page keys)
- Enter                 Marks the line as modified and moves to the next line.
- Esc                   Reverts the pending change of the current line

In the OSM map holding the Ctrl key together with
- Left click            Sets the exact location
- Mouse wheel           To (in)(de)crease the font the map uses.
