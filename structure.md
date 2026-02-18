# Menu structure

## Menu design ##
<img width="511" height="311" align="right" alt="menu wireframe" src="https://github.com/user-attachments/assets/2b049819-e0fc-47c6-994f-f09f7db7ca42" />
Menu items consist of:

```| √ | Title          | Label | > |```

- **Checkmark (optional)** indicates if a boolean option is currently selected. Permanently takes up room whether visible or not.
- **Title** of menu option.
- **Label (optional)** shows current menu option value. Truncated with ellipsis if necessary. Could be the Title of the currently selected submenu option, or 'Short label' if available, or ### (the number of photos in that selection)
- **Disclosure arrow (optional)** if the option has a submenu.

## Exit menu
- Cancel
- Exit screensaver

## Main menu
- **Photos**
  - Displaying all photos (default)
  - This folder only
  - This day only
  - This month only
  - This year only
  - With tag...
    - Any tag (only show photos that have tags)
    - Tag 1
    - Tag 2
    - Tag 3
    - Close menu
  - Close menu
- **Order**
  - Random order (default)
  - Chronological order
  - A-Z by filename
  - Close menu
- **Settings**
  - Slide duration
    - 1 second
    - 2 seconds (default)
    - 5 seconds
    - 10 seconds
    - Manual advance
    - Close menu
  - Play settings
    - Looping (default)
    - Stop after last slide
    - Dissolve (default)
    - No transition
    - Close menu
  - Picture settings
    - Fit to screen (default)
    - Fill screen
    - Fill screen (landscape only)
    - Close menu
  - Video settings
    - Include videos
    - Don't include videos (default)
    - Sound on
    - Sound off (default)
    - Close menu
  - Library
    - Path 1 (default)
    - Path 2
    - Close menu
  - Blocklist
    - Add photo to blocklist
    - Close menu
  - Reset all to defaults
- Close menu
