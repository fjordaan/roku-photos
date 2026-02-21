# Functionality

What do each of the menu items in [menus.md ](menus.md) do?  

Boolean options display a checkmark if selected. Activating them again will not remove the checkmark, the user has to select a different option. 
Where I write ### it means the number of photos in that selection.

After selecting a Boolean menu option, the checkmarks and labels on the menu should be updated, and the menu should automatically close after 1 second.  
However, in the following menus, the menu should not close after selecting an option (except where specified otherwise below):
- **Settings** menu
- **Photos: With tag** sub-submenu

## Exit menu

### Cancel
- **Function:** Closes menu

### Exit screensaver
- **Function:** Closes the screensaver app and returns to the Roku home screen

## Main menu

### Photos 
- **Type:** Submenu
- **Function:** Opens Photos submenu
- **Label:** Selected option label or short label, followed by ###

#### Displaying all photos (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos in Library
- **Label:** ### (number of photos in Library)
- **Short label:** All *(displayed as label in parent menu)*

#### This folder only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos in the same directory as the current photo
- **Label:** ### (number of matching photos)

#### This day only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same date (day, month year) as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** ### (number of matching photos)

#### This month only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same month and year as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** ### (number of matching photos)

#### This year only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same year as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** ### (number of matching photos)

#### With tag...
- **Type:** Submenu AND Boolean. Display checkmark if any sub-option is selected. Cannot normally be combined with other options in Photos menu, apart from "Any tag"
- **Function:** Opens Tag sub-submenu
- **Label:** Selected tag or tags (comma-separated), or short label, followed by (###)
- After selecting any option in this sub-submenu, do not close the menu.

##### Any tag (only show photos that have tags)
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Photos menu. CANNOT be combined with other options in Tag sub-submenu
- **Function:** Sets Playlist to all photos IN THE CURRENT PLAYLIST which have one or more IPTC tags. (Which is usually those I added to Flickr.)
- **Label:** ### (number of matching photos)
- **Short label:** Any tag *(displayed as label in parent menu)*

##### Tag n
- One menu item for every IPTC tag in the current photo
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Tag sub-submenu. (So you can select multiple tags.)
- **Function:** Sets Playlist to all photos in Library that includes the selected IPTC tag

##### Close menu
- **Function:** Closes Tag sub-submnenu

*Why no "Clear tags" option? You clear tags by selecting a different option from the Photos submenu.*

#### Close menu
- **Function:** Closes Photos submnenu

### Order
- **Type:** Submenu
- **Function:** Opens Order submenu
- **Label:** Selected option label or short label
- Selecting any of these options will create a new playlist. The user will remain at the current photo, but they will not be able to go `Back` to previous photos.

#### Random order (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Order menu
- **Function:** Sets Playlist sequence to random order. The photos in the playlist stay the same, but their order is randomised. The current photo stays the same.
- **Label:** None
- **Short label:** Random order

#### Chronological order
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Order menu
- **Function:** Sets Playlist sequence to chronological order (using EXIF/IPTC metadata), with the user continuing from the current photo.
- **Label:** None

#### A-Z by filename
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Order menu
- **Function:** Sets Playlist sequence to alphanumeric order based on filename, with the user continuing from the current photo.
- **Label:** None

#### Close menu
- **Function:** Closes Order submnenu

### Settings
- **Type:** Submenu
- **Function:** Opens Settings submenu
- **Label:** None
- After selecting any option inside Settings, the menu should remain open.

#### Slide duration
- **Type:** Submenu
- **Function:** Opens Slide Duration sub-submenu
- **Label:** Selected option label or short label

##### 1 second
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Slide Duration sub-submenu.
- **Function:** Sets slide display duration to 1 second

##### 2 seconds (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Slide Duration sub-submenu.
- **Function:** Sets slide display duration to 2 seconds
- **Short label:** 2 seconds

##### 5 seconds
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Slide Duration sub-submenu.
- **Function:** Sets slide display duration to 5 seconds

##### 10 seconds
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Slide Duration sub-submenu.
- **Function:** Sets slide display duration to 10 seconds

##### Close menu
- **Function:** Closes Slide Duration sub-submnenu

#### Play settings
- **Type:** Submenu
- **Function:** Opens Play Settings sub-submenu
- **Label:** Selected option labels or short labels, comma-separated

##### Looping (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the next option.
- **Function:** When slideshow reaches the end of the playlist, start at the first slide again.
- **Short label:** Looping

##### Stop after last slide
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the previous option.
- **Function:** When slideshow reaches the end of the playlist, show the "End of slideshow" screen (see `designs/`), with 2 selectable options:
  - Restart (previous selection & settings)
  - Restart (all photos, random)
- On "End of slideshow" screen, user can still use the buttons to navigate back, but they cannot open the menu with `OK`. Pressing `Back` will open the Exit menu.

##### Dissolve (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the next option.
- **Function:** Sets transition effect between slide to dissolve.
- **Short label:** Dissolve

##### No transition
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the previous option.
- **Function:** Removes transition effect when changing slides.

##### Close menu
- **Function:** Closes Play Settings sub-submnenu

#### Picture settings
- **Type:** Submenu
- **Function:** Opens Picture Settings sub-submenu
- **Label:** Selected option label or short label

##### Fit to screen (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Picture Settings sub-submenu.
- **Function:** Scales photos to fit screen without cropping. Photos or videos smaller than the screen resolution should not be scaled up.
- **Short label:** Fit to screen

##### Fill screen
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Picture Settings sub-submenu.
- **Function:** Scales photos to fill the screen, cropping if necessary. Photos or videos smaller than the screen resolution should not be scaled up.

##### Fill screen (landscape only)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Picture Settings sub-submenu.
- **Function:** Scales landscape format photos to fill the screen, cropping if necessary. Portrait photos, or photos or videos smaller than the screen resolution should not be scaled.

##### Close menu
- **Function:** Closes Picture Settings sub-submnenu

#### Video settings
- **Type:** Submenu
- **Function:** Opens Video Settings sub-submenu
- **Label:** Selected option labels or short labels, comma-separated

##### Include videos
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the next option.
- **Function:** Playlist should include videos

##### Don't include videos (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the previous option.
- **Function:** Sets Playlist to all photos in Library that includes the selected IPTC tag
- **Short label:** Playlist should exclude videos

##### Sound on
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the next option.
- **Function:** Videos will play with sound

##### Sound off (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with the previous option.
- **Function:** Videos will play without sound
- **Short label:** Sound off

##### Close menu
- **Function:** Closes Video Settings sub-submnenu

#### Library
- **Type:** Submenu
- **Function:** Opens Library sub-submenu
- **Label:** Selected option label (which will be the directory path)
- If the label doesn't fit in the menu, it should be truncated from the *start* of the string

##### <Path 1>
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Library sub-submenu.
- **Function:** Sets the base picture folder to the specified directory path. (Directory paths will be hardcoded somewhere)
- **Label:** Default
- If the path doesn't fit in the menu, it should be truncated from the *start* of the string

##### <Path 2>
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Library sub-submenu.
- **Function:** Sets the base picture folder to another directory path. (Directory paths will be hardcoded somewhere)

##### Close menu
- **Function:** Closes Library sub-submnenu

#### Activation
- **Type:** Submenu
- **Function:** Opens Activation sub-submenu
- **Label:** Selected option label or short label

##### Start manually (default)
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Tag sub-submenu. (So you can select multiple tags.)
- **Function:** The screensaver app has to be manually launched from the Roku home screen
- **Short label:** Start manually

##### Start automatically as screensaver
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Tag sub-submenu. (So you can select multiple tags.)
- **Function:** The screensaver app will launch automatically from the Roku home screen
- It's possible that this cannot be controlled from the app, in which case we will remove the Activation sub-submenu.

##### Close menu
- **Function:** Closes Activation sub-submenu

#### Blocklist
- **Type:** Submenu
- **Function:** Opens Blocklist sub-submenu

##### Add photo to blocklist
- **Type:** Action
- **Function:** Adds the current photo to a blocklist, stored on the server, preventing it from being included in future playlists
- After activation, close the menu, move on to the next photo in the playlist, and display the message "Last photo will not be displayed again"

##### Close menu
- **Function:** Closes Blocklist sub-submnenu

#### Reset all to defaults
- **Type:** Action
- **Function:** Resets all slideshow settings to the options marked (default) above.
- After activation, update all the menu labels, but do not close the menu

#### Close menu
- **Function:** Closes Settings submnenu
