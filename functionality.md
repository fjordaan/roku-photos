# Functionality

What do each of the menu items in [structure.md ](https://github.com/fjordaan/roku-photos/blob/master/structure.md) do?  

Boolean options display a checkmark if selected. Activating them again deselects them and removes the checkmark.

## Exit menu

### Cancel
- **Function:** Closes menu

### Exit screensaver
- **Function:** Closes the screensaver app and returns to the Roku home screen

## Main menu

### Photos 
- **Function:** Opens Photos submenu
- **Label:** Selected option label or short label (###)

#### Displaying all photos (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos in Library
- **Label:** \### (number of photos in Library)
- **Short label:** All (displayed as label in parent menu)

#### This folder only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos in the same directory as the current photo
- **Label:** \### (number of matching photos)

#### This day only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same date (day, month year) as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** \### (number of matching photos)

#### This month only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same month and year as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** \### (number of matching photos)

#### This year only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same year as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** \### (number of matching photos)

#### With tag...
- **Function:** Opens Tag sub-submenu
- **Label:** Selected tag or tags (comma-separated), or short label (###)

##### Any tag (only show photos that have tags)
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Photos menu. CANNOT be combined with other options in Tag sub-submenu
- **Function:** Sets Playlist to all photos which have IN THE CURRENT PLAYLIST which have one or more IPTC tags. (Which is usually those I added Flickr.)
- **Short label:** Any tag

##### Tag n
- One menu item for every IPTC tag in the current photo
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Tag sub-submenu
- **Function:** Sets Playlist to all photos in Library that includes the selected IPTC tag

##### Close menu
- **Function:** Closes Tag sub-submnenu

*Why no "Clear tags" option? You clear tags by selecting a different option from the Photos submenu.*

#### Close menu
- **Function:** Closes Photos submnenu
- 
### Order
#### Random order
